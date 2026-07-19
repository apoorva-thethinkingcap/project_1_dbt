# Sales Analytics Pipeline (dbt + Databricks)

An ELT pipeline built with **dbt Core** on **Databricks**, transforming sales data through bronze, silver, and gold layers (medallion architecture). Built as a hands-on learning project to practice modern analytics engineering tooling end to end.

## Architecture

```
Raw CSVs → Databricks Catalog (bronze) → dbt models (silver) → dbt marts (gold) → BI-ready tables
```

- **Bronze**: raw data as ingested, untouched and replayable
- **Silver**: cleaned and standardized: deduplication, type fixes, conformed IDs, incremental loads
- **Gold**: business-ready fact and dimension tables for reporting

## Tech stack

| Tool | Role |
|---|---|
| dbt Core | Transformation, testing, documentation |
| Databricks (Free Edition) | Compute + storage (Unity Catalog) |
| Jinja | Templated SQL, macros, incremental logic |
| Git + GitHub | Version control |
| Python (uv) | Virtual environment management |

## What this project demonstrates

- **Modular dbt models** across medallion layers, with `ref()`-driven lineage (DAG)
- **Incremental loads** implemented via Jinja macros
- **Data tests**: generic tests (`unique`, `not_null`) declared in model properties, plus singular tests for multi-table business logic
- **Seeds** for developer-maintained mapping tables
- **Snapshots** implementing SCD Type 2: tracking dimension history with `dbt_valid_from` / `dbt_valid_to`
- **Multi-environment deployment**: dev and prod catalogs switched via dbt profile targets, with dynamic `{{ target.catalog }}` references instead of hardcoded names
- **Analyses** folder used for exploratory Jinja/SQL kept out of the DAG

## Project structure

```
├── models/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── macros/
├── seeds/
├── snapshots/
├── analyses/
├── tests/
└── dbt_project.yml
```

## Running locally

1. Clone the repo and create a virtual environment (`uv venv`), then install dbt with the Databricks adapter: `uv pip install dbt-databricks`
2. Configure `~/.dbt/profiles.yml` with your Databricks host, HTTP path, and a personal access token (never committed to this repo)
3. Verify the connection: `dbt debug`
4. Load seeds and build: `dbt seed && dbt build`
5. Deploy to prod: `dbt build --target prod`

## Roadmap

- [ ] CI with GitHub Actions: run `dbt build` and tests automatically on pull requests
- [ ] Slim CI using `state:modified+` to rebuild only changed models
- [ ] Gold-layer dashboard (Tableau)
- [ ] Replace the tutorial dataset with a synthetic payroll/compensation dataset and custom models

## Acknowledgements

Built by following [Ansh Lamba's dbt masterclass](https://www.youtube.com/watch?v=B8uwFmVt4sU).
