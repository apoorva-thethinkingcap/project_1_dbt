# dbt Dual-Platform Playbook — Complete, Start to End
**Project:** `dbt_project_apoorva` · **Platforms:** Databricks (dev/prod) + BigQuery (sandbox)
**Machine:** Windows 11, PowerShell · **Last validated:** July 2026

This is the full sequence from a bare machine to a green build on both platforms and a clean push.

**How to use this playbook — where do I start today?**

| Situation | Start at |
|---|---|
| New laptop / reformatted machine / recreating the venv | PART 0 |
| Normal work session (opened the laptop, want to build) | PART 1 → 2 → 3 |
| Ready to push changes to GitHub | PART 4 |
| Setting up GitHub Actions | PART 5 |

⚠️ **Every step in PART 0 is ONE-TIME.** It is already done on your current laptop.
Do NOT rerun it — rerunning (e.g. `python -m venv .venv` over an existing venv) causes
permission errors and can break the working setup. Parts 1–4 are repeatable any time.

---

## PART 0 — One-time setup (per machine) 🔒 ONE-TIME — already done, skip in normal sessions

### 0.1 Project folder and virtual environment (ONE-TIME)

```powershell
cd "C:\Users\APOORVA KULKARNI\OneDrive\Job Hunting\Projects\DBT - Ansh Lamba"
python -m venv .venv
.venv\Scripts\activate
```

If pip is missing inside the venv (`No module named pip`):

```powershell
python -m ensurepip --upgrade
```

### 0.2 Install dbt adapters (ONE-TIME)

```powershell
python -m pip install dbt-databricks dbt-bigquery
```

> If `pip install ...` is ever blocked by Application Control policy, always use the
> `python -m pip` form — it runs through python.exe instead of the blocked pip.exe.

Verify:

```powershell
python -m pip list | findstr dbt
```

Expect to see `dbt-core`, `dbt-databricks`, `dbt-bigquery`, `dbt-adapters`.

### 0.3 GCP service account key (ONE-TIME)

One-time console work (already done): GCP → IAM & Admin → Service accounts → create `dbt-runner`
→ role **BigQuery Admin** → Manage keys → Add key → JSON → downloads a file like
`gcp-dbt-project-503007-af3f5e45ba44.json`.

Store it outside the repo and outside OneDrive:

```powershell
mkdir "C:\Users\APOORVA KULKARNI\.gcp"
move "C:\Users\APOORVA KULKARNI\Downloads\gcp-dbt-project-503007-af3f5e45ba44.json" "C:\Users\APOORVA KULKARNI\.gcp\dbt-runner-key.json"
```

(Adjust the Downloads filename to whatever the actual download is called.)

Verify:

```powershell
Test-Path "C:\Users\APOORVA KULKARNI\.gcp\dbt-runner-key.json"   # must print True
```

### 0.4 Databricks token as environment variable (ONE-TIME — redo only if token is rotated)

Generate a token in Databricks (User Settings → Developer → Access tokens), then:

```powershell
setx DBT_DATABRICKS_TOKEN "dapi-PASTE-YOUR-ACTUAL-TOKEN-HERE"
```

**Important:** `setx` only affects NEW terminals. Close and reopen the terminal, then verify:

```powershell
echo $env:DBT_DATABRICKS_TOKEN     # must print the token
```

(To also use it in the *current* terminal without reopening: `$env:DBT_DATABRICKS_TOKEN = "dapi-..."`)

If the token is ever exposed (pasted in a file, committed, screenshotted): revoke it in
Databricks, generate a new one, and rerun the `setx` with the new value.

### 0.5 profiles.yml (lives in the project folder, gitignored) (ONE-TIME — edit only when targets change)

Location: `...\DBT - Ansh Lamba\dbt_project_apoorva\profiles.yml`
Full contents:

```yaml
dbt_project_apoorva:
  outputs:
    dev:
      catalog: dbt_project
      host: dbc-a920f698-7997.cloud.databricks.com
      http_path: /sql/1.0/warehouses/d21e700deeacaec8
      schema: default
      threads: 1
      token: "{{ env_var('DBT_DATABRICKS_TOKEN') }}"
      type: databricks
    prod:
      catalog: dbt_project_prod
      host: dbc-a920f698-7997.cloud.databricks.com
      http_path: /sql/1.0/warehouses/d21e700deeacaec8
      schema: default
      threads: 1
      token: "{{ env_var('DBT_DATABRICKS_TOKEN') }}"
      type: databricks
    bigquery:
      type: bigquery
      method: service-account
      project: gcp-dbt-project-503007
      dataset: dbt_sales
      location: asia-south1
      threads: 4
      keyfile: C:\Users\APOORVA KULKARNI\.gcp\dbt-runner-key.json
  target: bigquery
```

Notes:
- `location: asia-south1` must match where the BigQuery datasets actually live. All datasets
  (`dbt_sales`, `bronze`, `silver`, `gold`) are in asia-south1. Locations cannot be changed later.
- `target: bigquery` makes BigQuery the default; Databricks needs an explicit `--target`.

### 0.6 Confirm profiles.yml is gitignored (ONE-TIME)

```powershell
cd "C:\Users\APOORVA KULKARNI\OneDrive\Job Hunting\Projects\DBT - Ansh Lamba\dbt_project_apoorva"
git check-ignore profiles.yml
```

Must print `profiles.yml` back. If it prints nothing:

```powershell
Add-Content .gitignore "profiles.yml"
git rm --cached profiles.yml
```

---

## PART 1 — Session startup (EVERY SESSION)

```powershell
cd "C:\Users\APOORVA KULKARNI\OneDrive\Job Hunting\Projects\DBT - Ansh Lamba\dbt_project_apoorva"
..\.venv\Scripts\activate
```

Prompt must show `(dbt-ansh-lamba)` (or your venv name). Then:

```powershell
echo $env:DBT_DATABRICKS_TOKEN      # sanity: token is present
git branch                          # confirm: on main
git status                          # see uncommitted work from last time
```

If `git status` shows uncommitted work from a previous session, deal with it before starting
new changes — don't let sessions pile up in one messy commit:

```powershell
git add <the changed files>         # stage them explicitly
git commit -m "Describe what that work was"
git push origin main
git status                          # rerun: should now say "working tree clean"
```

(If you don't recognize the changes or aren't sure they're good, review with `git diff` first.
Only commit what you understand.)

Connection checks (run whichever platforms you'll use today):

```powershell
dbt debug --target bigquery
dbt debug --target dev
```

All checks passed = ready. Notes:
- "Unable to do partial parsing..." lines are informational, not errors.
- Databricks first command may take 1–2 min while the SQL warehouse auto-starts.

---

## PART 2 — Running the pipeline (EVERY SESSION, as needed)

> **Default target:** `profiles.yml` sets `target: bigquery`, so any dbt command without a
> `--target` flag runs against **BigQuery**. To hit Databricks you must pass `--target dev`
> or `--target prod` explicitly.

### 2.1 BigQuery (default target)

```powershell
dbt build --exclude gold_items
```

- `--exclude gold_items` is REQUIRED on BigQuery: the SCD2 snapshot uses MERGE (DML),
  which the free sandbox blocks. Expected: `PASS=18 ERROR=0 SKIP=0`.
- If billing is ever enabled on the GCP project, drop the exclude flag.

### 2.2 Databricks dev

```powershell
dbt build --target dev
```

Full build including the snapshot. Expected: `PASS=19 ERROR=0 SKIP=0`.

### 2.3 Databricks prod

```powershell
dbt build --target prod
```

Same expectation. (Catalog `dbt_project_prod` must exist — it does; if ever rebuilt from
scratch, first run in Databricks SQL: `CREATE CATALOG IF NOT EXISTS dbt_project_prod;`)

### 2.4 Useful variants

```powershell
dbt run  --exclude gold_items              # models only, no tests/seeds (BigQuery)
dbt test                                    # tests only
dbt build --select silver_sales_info        # one model + its tests
dbt build --select lookup gold_items --target dev   # rerun specific failures
dbt compile --target dev                    # render SQL without running (inspect target\compiled\)
```

---

## PART 3 — Validation (AFTER EVERY BUILD)

### BigQuery (console → BigQuery Studio)

- Explorer → `gcp-dbt-project-503007` → datasets `bronze`, `silver`, `gold`, `dbt_sales`
  all present, all **asia-south1**
- Query spot-check:

```sql
SELECT * FROM `gcp-dbt-project-503007.silver.silver_sales_info` LIMIT 10;
SELECT COUNT(*) FROM `gcp-dbt-project-503007.silver.silver_sales_info`;
```

### Databricks (SQL editor)

```sql
SHOW TABLES IN dbt_project.silver;
SELECT COUNT(*) FROM dbt_project.silver.silver_sales_info;
```

Matching row counts across both platforms for the same model = port validated.

### Cross-platform gotchas (memorize these)

| Gotcha | Rule |
|---|---|
| `target.catalog` | Databricks-only; cross-platform YAML branches on `target.type` |
| DATE vs TIMESTAMP | BigQuery won't coerce; sentinel must match column type: `timestamp('9999-12-31')` |
| Dataset locations | Jobs only see datasets in the profile's `location`; locations are immutable |
| Source schemas | Raw data: `source` schema (Databricks) vs `dbt_sales` dataset (BigQuery) — handled in `sources.yaml` |
| Sandbox DML | No MERGE on BigQuery free tier → snapshot excluded there |

---

## PART 4 — Pushing changes to GitHub (WHEN PUSHING)

### 4.1 Pre-flight: no secrets, no artifacts

```powershell
git status
git ls-files | findstr /i "json"        # dbt-runner-key must NEVER appear
git check-ignore profiles.yml           # must print profiles.yml
```

Nothing from `target\`, `prod\`, or `.gcp\` should be tracked or staged.

### 4.2 Review the diff

```powershell
git diff --stat
git diff snapshots\gold_items.yml
git diff models\source\sources.yaml
```

### 4.3 Stage explicitly (no blanket add), commit, push

```powershell
git add models\source\sources.yaml snapshots\gold_items.yml README.md
git commit -m "Add BigQuery target support with cross-platform configs"
git push origin main
```

Longer commit message version if you prefer detail:

```powershell
git commit -m "Add BigQuery target support with cross-platform configs" -m "Target-aware database/schema in sources and snapshot configs; BigQuery-compatible timestamp sentinel for SCD2; token moved to DBT_DATABRICKS_TOKEN env var"
```

### 4.4 Post-push check

- Open the repo on GitHub → `main` branch → confirm the commit landed
- Click through the changed files — final visual check that no token, key, or personal path leaked
- If a secret DID get pushed: revoke/regenerate the credential immediately (a push is public
  the moment it lands), then clean up the repo

---

## PART 5 — CI/CD readiness (ONE-TIME, upcoming milestone)

The repo is ready for GitHub Actions when:

- [x] Token via `env_var('DBT_DATABRICKS_TOKEN')` — done
- [ ] GitHub Secrets created (repo → Settings → Secrets and variables → Actions):
      `DBT_DATABRICKS_TOKEN` (token string), `GCP_KEYFILE_JSON` (paste the FULL contents of dbt-runner-key.json)
- [ ] Keyfile path made overridable via env var (one-line profiles.yml change, needed so CI can point at its temp file)
- [ ] `.github\workflows\dbt.yml` created — the workflow file itself

The workflow will: checkout → setup Python → `pip install dbt-bigquery` → write keyfile from
secret to a temp path → `dbt build --target bigquery --exclude gold_items`.
First green run on a push = CI/CD goes on the resume.
