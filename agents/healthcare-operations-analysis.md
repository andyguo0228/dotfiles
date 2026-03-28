# agent.md — Coding Agent Context Guide

> **Project:** Healthcare Operations Analysis  
> **Purpose:** Portfolio-grade Power BI dashboard backed by a Python synthetic data generator, targeting healthcare data analyst roles.  
> **Owner:** Andy Guo · Medical Scribe → Data Analyst transition  
> **Stack:** Python 3.12+ · Power BI (PBIP/TMDL) · Power Query M · DAX

---

## Project Overview

This project has two coupled halves:

1. **`synthetic_data_generator/`** — A Python package that produces realistic, HIPAA-safe synthetic data modeling an outpatient oncology/hematology clinic. Output: four CSV files (`patients.csv`, `providers.csv`, `appointments.csv`, `treatments.csv`).

2. **`healthcare_operation_analysis.SemanticModel/` + `healthcare_operation_analysis.Report/`** — A Power BI project (PBIP format, Developer Mode) that ingests those CSVs via OneDrive-hosted `Web.Contents()` URLs, transforms them in Power Query M, models them as a star schema, and visualizes clinic operations.

The CSVs are the contract between the two halves. Column names in the generator map to column renames in Power Query. If you change one, you must change the other.

---

## Repository Structure

```
.
├── build_dataset.py                          # Entry point — runs all generators, writes to data/
├── synthetic_data_generator/
│   ├── __init__.py
│   ├── config.py                             # Seeds, constants, diagnosis weights, visit type weights
│   ├── utils.py                              # Faker instance, weighted_choice, date helpers, MRN/zip generators
│   ├── generate_patients.py                  # 3,600 patients — demographics, dx, stage, comorbidity, insurance
│   ├── generate_providers.py                 # 6 providers — name, years_experience, FTE
│   ├── generate_appointments.py              # ~22K appointments — room-level transitions, timestamps, durations
│   └── generate_treatments.py                # ~3,300 treatment episodes — regimen, line of therapy, intent
├── data/                                     # Generated CSVs (gitignored, regenerate with build_dataset.py)
│   ├── patients.csv
│   ├── providers.csv
│   ├── appointments.csv
│   └── treatments.csv
├── healthcare_operation_analysis.pbip        # Power BI project file
├── healthcare_operation_analysis.Report/     # Report definition (pages, theme, visuals)
│   ├── .platform
│   ├── definition/
│   │   ├── pages/                            # Page JSON definitions
│   │   ├── report.json                       # Theme binding, settings
│   │   └── version.json
│   └── StaticResources/
│       └── SharedResources/
│           └── BaseThemes/
│               └── Fluent2-CY26SU03.json     # Active theme (Fluent 2 Preview)
├── healthcare_operation_analysis.SemanticModel/
│   ├── .platform
│   ├── definition.pbism
│   ├── diagramLayout.json                    # Model view layout coordinates
│   └── definition/
│       ├── model.tmdl                        # Model root — table refs, annotations
│       ├── database.tmdl                     # Compatibility level 1600
│       ├── relationships.tmdl                # All 5 relationships
│       ├── expressions.tmdl                  # Shared Power Query M expressions (raw_Appointments, helper_arrivaltimes)
│       ├── cultures/en-US.tmdl
│       └── tables/
│           ├── Appointments.tmdl             # Fact table — deduped from raw, joined with helper_arrivaltimes
│           ├── Rooms.tmdl                    # Fact table — room-transition grain, sequence, Is Waiting Room
│           ├── Patients.tmdl                 # Dimension — demographics, clinical attributes
│           ├── Providers.tmdl                # Dimension — name, experience, FTE
│           ├── Treatments.tmdl               # Fact/SCD — regimen, line, intent, dates
│           ├── Date.tmdl                     # Date dimension — generated from data range, marked as Date Table
│           └── _Measures.tmdl                # Dedicated measures table (currently has Placeholder only)
└── agent.md                                  # This file
```

---

## Data Flow & Architecture

```
build_dataset.py
    │
    ├─→ generate_patients()    → data/patients.csv
    ├─→ generate_providers()   → data/providers.csv
    ├─→ generate_appointments(patients, providers) → data/appointments.csv
    └─→ generate_treatments(patients, appointments) → data/treatments.csv
                │
                ▼
        OneDrive (SharePoint hosted CSVs)
                │
                ▼
        Power Query M (expressions.tmdl)
            │
            ├─→ raw_Appointments   ← appointments.csv (room-transition grain, ~134K rows)
            ├─→ helper_arrivaltimes ← grouped aggregation of raw_Appointments
            │
            ▼
        Semantic Model Tables
            ├─→ Appointments  (deduped from raw, joined with helper for First Arrival / Last Timestamp / Total Duration)
            ├─→ Rooms         (raw with sequence numbering, Is Waiting Room flag, appointment-level columns removed)
            ├─→ Patients      (direct load + rename)
            ├─→ Providers     (direct load + rename)
            ├─→ Treatments    (direct load + rename)
            └─→ Date          (generated dynamically from max appointment date, 3-year lookback)
```

### Critical: The CSV-to-Model Column Contract

The Python generator outputs **snake_case** columns. Power Query renames them to **Title Case** in each table's M expression. The mapping is 1:1 — for example:

| Generator Column         | Power Query Rename       | Table       |
|--------------------------|--------------------------|-------------|
| `appointment_id`         | `Appointment ID`         | Appointments, Rooms |
| `mrn`                    | `MRN`                    | Appointments, Patients |
| `provider_id`            | `Provider ID`            | Appointments, Providers |
| `appointment_date`       | `Appointment Date`       | Appointments |
| `visit_type`             | `Visit Type`             | Appointments |
| `primary_diagnosis`      | `Diagnosis`              | Patients |
| `diagnosis_group`        | `Dx Group`               | Patients |
| `insurance_type`         | `Insurance`              | Patients |
| `active_treatment_flag`  | `Active Treatment Flag`  | Patients |
| `line_of_therapy`        | `Line of Therapy`        | Treatments |
| `regimen_name`           | `Regimen Name`           | Treatments |
| `treatment_category`     | `Treatment Category`     | Treatments |

**If you add or rename a column in the generator, you must update the corresponding TMDL file's M expression and column definition.**

---

## Semantic Model — Star Schema

### Relationships (all Many-to-One, single-direction cross-filter)

```
Date.Date                    ←── Appointments.Appointment Date
Patients.MRN                 ←── Appointments.MRN
Providers.Provider ID        ←── Appointments.Provider ID
Appointments.Appointment ID  ←── Rooms.Appointment ID
Patients.Patient ID          ←── Treatments.Patient ID
```

### Hidden Columns (already configured)

- `Appointments[Provider ID]` — hidden, use `Providers[Provider ID]`
- `Appointments[Appointment Date]` — hidden, use `Date[Date]`
- `Treatments[Patient ID]` — hidden, use `Patients[Patient ID]`

### Date Table

- Marked as `dataCategory: Time` with `Date` as the key column
- Dynamically generated: 3-year lookback from `MAX(raw_Appointments[Appointment Date])` through end of that max year
- `Month Year` is sorted by `Month Year Sort` (YYYYMM integer)

### Measures Table (`_Measures`)

- Currently contains only a `Placeholder` measure
- All DAX measures should be added here — not scattered across fact/dimension tables
- Convention: prefix the table name with `_` so it sorts to the top of the field list

---

## Python Generator — Architecture & Conventions

### Dependencies

- `pandas`, `numpy`, `faker`
- No additional packages. Keep it lean.

### Seeding

All randomness is seeded via `config.SEED = 42`. The seed is applied to `random`, `numpy`, and `Faker` in `utils.py`. **Deterministic output is a design goal** — identical seed should produce identical CSVs. If you add new random calls, ensure they flow through the existing seeded instances.

### Generator Execution Order (matters)

```python
patients_df = generate_patients()           # Independent
providers_df = generate_providers()         # Independent
appointments_df = generate_appointments(patients_df, providers_df)  # Depends on patients + providers
treatments_df = generate_treatments(patients_df, appointments_df)   # Depends on patients + appointments
```

`generate_appointments` is the most complex — it produces one row per room transition per appointment (not one row per appointment). The CSV is at room-transition grain (~134K rows for ~22K appointments). Power Query then splits this into two tables: `Appointments` (deduped, one row per appointment) and `Rooms` (full transition detail with sequence numbering).

### Key Design Decisions

1. **Patient population split:** 60% IDA (Iron Deficiency Anemia), 40% malignant oncology. Controlled by `config.DIAGNOSIS_GROUPS`. This mirrors a real community hematology/oncology practice.

2. **Visit count per patient** is driven by diagnosis, active treatment status, stage, and a Poisson noise term (`generate_appointments.patient_visit_count`). Malignant + active + late-stage patients visit more.

3. **Room flow** (`build_patient_flow`) is deterministic per visit type and status — e.g., a Follow-up goes Lab Waiting Room → Lab → Waiting Room → Exam Room → Ready to Check Out → Checked Out. Some visit types have a random chance of including infusion steps.

4. **Duration allocation** (`allocate_room_durations`) distributes total visit time across room states using bounded random sampling + proportional scaling. The bounds in `room_duration_bounds` are clinically plausible ranges.

5. **Treatment lines** follow real oncology patterns: 1st line is universal, 2nd line for ~18% of patients, 3rd line for ~1%. Attrition is intentional and clinically meaningful.

6. **Regimen-to-category mapping** (`TREATMENT_CATEGORIES`) is hardcoded and clinically accurate. If adding new regimens, maintain this mapping and the corresponding `TREATMENT_ROUTE` map.

### Adding a New Column to an Existing Table

1. Add the field to the generator function (e.g., `generate_patients.py`)
2. If using a dataclass (like `PatientProfile`), add it there
3. Add it to the `rows.append(...)` logic
4. Run `python build_dataset.py` to regenerate CSVs
5. In the corresponding `.tmdl` file, add the column definition after the existing columns
6. In the table's M partition source, add the column to `#"Changed Type"` and `#"Renamed Columns"` steps
7. Verify the relationship model isn't affected

### Adding a New Table

1. Create `generate_newtable.py` following the existing pattern
2. Add the call to `build_dataset.py` (respecting dependency order)
3. Upload the CSV to OneDrive
4. Create a new `.tmdl` file in `definition/tables/`
5. Add any relationships to `relationships.tmdl`
6. Add the table ref to `model.tmdl`
7. Update `PBI_QueryOrder` annotation in `model.tmdl`

---

## Power BI (PBIP/TMDL) — Conventions

### Format

This project uses **Power BI Project (PBIP)** format with **TMDL** (Tabular Model Definition Language) for the semantic model. This is the Developer Mode / Git-integrated format — not a monolithic `.pbix`.

### TMDL Syntax Quick Reference

```tmdl
table TableName
    lineageTag: <guid>

    column 'Column Name'
        dataType: string | int64 | double | dateTime | boolean
        formatString: 0 | Long Date | General Date | "0.0%"
        lineageTag: <guid>
        summarizeBy: none | sum | count | average
        sourceColumn: Column Name     // must match the M output column name

    measure MeasureName = <DAX expression>
        lineageTag: <guid>
        formatString: "0.0%"

    partition TableName = m
        mode: import
        source = <M expression>
```

### Power Query M — Key Expressions

Two shared expressions in `expressions.tmdl` are referenced by multiple tables:

- **`raw_Appointments`** — Loads `appointments.csv` from OneDrive via `Web.Contents(...)`, applies type casting, renames columns from snake_case to Title Case, replaces "Rm" with "Room" in the Room column, and adds a `Room Time` column (time-only extraction from `Room Timestamp`).

- **`helper_arrivaltimes`** — Groups `raw_Appointments` by `Appointment ID` to compute `First Arrival` (min timestamp), `Last Timestamp` (max timestamp), and `Total Duration` (sum of durations) per appointment.

These are consumed by:
- `Appointments.tmdl` — deduplicates `raw_Appointments` by Appointment ID, drops room columns, left-joins `helper_arrivaltimes`
- `Rooms.tmdl` — groups `raw_Appointments` by Appointment ID, adds sequence index, adds `Is Waiting Room` boolean, drops appointment-level columns (MRN, Provider ID, etc.)

### Data Source

All CSVs are loaded via `Web.Contents()` pointing to a SharePoint/OneDrive URL:
```
https://northwell-my.sharepoint.com/personal/aguo1_northwell_edu/Documents/Data%20Projects/healthcare_operations_analysis/data/{filename}.csv
```

If the data source URL changes, update it in:
- `expressions.tmdl` → `raw_Appointments` (appointments.csv)
- `Patients.tmdl` → partition source (patients.csv)
- `Providers.tmdl` → partition source (providers.csv)
- `Treatments.tmdl` → partition source (treatments.csv)

### Theme

The report uses **Fluent 2 (Preview)** (`Fluent2-CY26SU03.json`) as the base theme. It's a comprehensive theme with visual style overrides for nearly every visual type. Key design tokens:

| Token | Value | Usage |
|---|---|---|
| `foreground` | `#242424` | Primary text |
| `foregroundNeutralSecondary` | `#616161` | Labels, secondary text |
| `background` | `#FFFFFF` | Visual backgrounds |
| `secondaryBackground` | `#F5F5F5` | Alternating row fill |
| `tableAccent` | `#118DFF` | Primary accent / data color |
| `good` | `#1AAB40` | Positive KPIs |
| `bad` | `#D64554` | Negative KPIs / alerts |
| `shapeStroke` | `#D1D1D1` | Borders, outlines |

Page size is set to **1920×1080** (custom) in the theme. The page background is `#FAFAFA` at 14% transparency.

### DAX Measures — Where to Put Them

All measures go in `_Measures.tmdl`. The table uses a blank partition (single empty row, column removed). When adding a measure:

```tmdl
measure 'Measure Name' =
    <DAX expression>
    lineageTag: <generate a new GUID>
    formatString: "0.0%"
```

Generate a fresh GUID for `lineageTag` — don't reuse existing ones. Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.

---

## Common Tasks

### Regenerate the dataset

```bash
python build_dataset.py
```

Outputs to `data/`. Then upload the four CSVs to the OneDrive location for Power BI to pick up on refresh.

### Change the number of patients

Edit `config.py` → `NUM_PATIENTS`. Downstream counts (appointments, treatments) scale proportionally since they're driven per-patient.

### Change the date range

Edit `config.py` → `START_DATE` / `END_DATE`. The Date table in Power BI dynamically adjusts (it's generated from the data, not hardcoded).

### Add a new diagnosis

1. Add to `config.MALIGNANT_CANCERS` and `config.MALIGNANT_WEIGHTS`
2. Add regimen mappings in `generate_treatments.REGIMENS`
3. Add category mappings in `generate_treatments.TREATMENT_CATEGORIES`
4. Verify staging logic in `generate_patients.assign_stage`
5. Regenerate dataset

### Add a DAX measure

1. Write the DAX
2. Add the measure block to `_Measures.tmdl` with a new `lineageTag` GUID
3. Open the `.pbip` in Power BI Desktop — it will pick up the change

### Add a new report page

1. Create a new folder under `definition/pages/` with a random hex ID (e.g., `a1b2c3d4e5f6a7b8c9d0`)
2. Add a `page.json` with schema, name, displayName, dimensions
3. Add the page ID to `pages.json` → `pageOrder` array
4. Add visual JSON files inside the page folder

---

## Data Quality & Validation Targets

When validating the generated data or the Power BI model, these are the expected baseline metrics (seed=42, 3,600 patients):

| Metric | Expected Value |
|---|---|
| Total Appointments | ~22,100 |
| Completion Rate | ~87.5% |
| No-Show Rate | ~5.9% |
| Cancellation Rate | ~6.6% |
| Avg Total Duration (Completed) | ~96-97 min |
| Avg Wait Time (Waiting Rooms) | ~9-10 min |
| Active Patients | ~2,400 |
| IDA Patients | ~2,100 (59%) |
| Malignant Patients | ~1,480 (41%) |
| Treatments (total episodes) | ~3,300 |
| 1st Line Treatments | ~2,770 |
| 2nd Line Treatments | ~486 |
| 3rd Line Treatments | ~35 |
| Venofer Count | ~1,500 |

If metrics deviate significantly after changes, investigate whether seed ordering was disrupted or new random calls changed the sampling sequence.

---

## Guardrails for Agents

1. **Do not hardcode PHI or real patient data.** This is synthetic data. Keep it that way. Names come from Faker, MRNs are sequential, zip codes are from a fixed Queens/Manhattan list.

2. **Do not break the seed determinism.** If adding random sampling, use the existing `random`, `np.random`, or `fake` instances from `utils.py`. Don't create new `Random()` instances.

3. **Do not change column names in the generator without updating TMDL.** The CSV→Power Query column contract is brittle. A rename in Python that isn't reflected in the M expressions will silently produce nulls.

4. **Do not add bidirectional cross-filtering** to relationships unless there's an explicit, justified reason. The model uses single-direction by design.

5. **Do not scatter measures across fact/dimension tables.** All DAX measures go in `_Measures.tmdl`.

6. **Do not edit the theme JSON casually.** The Fluent 2 theme is 1,500+ lines of carefully coordinated visual styles. If you need a custom color override, create a separate theme layer or use report-level formatting — don't patch the base theme.

7. **Preserve clinically plausible distributions.** The weights in `config.py` and the generator functions are tuned to produce realistic healthcare data. Don't flatten distributions or use uniform random unless you have a reason.

8. **TMDL lineageTags must be unique GUIDs.** Never copy an existing `lineageTag` to a new object. Generate a fresh one.

9. **When modifying M expressions in TMDL files,** be aware that the backtick-fenced M blocks (` ```...``` `) are used for multi-line expressions (see `Rooms.tmdl`), while simpler expressions use indented blocks. Match the existing style.

10. **Test Power Query changes by opening the .pbip in Power BI Desktop** and checking the Applied Steps in Power Query Editor. TMDL doesn't validate M syntax at rest — errors only surface at refresh time.