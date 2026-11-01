# ADF Datasets

| Setting | Source | Sink |
|---|---|---|
| Dataset | `ds_employees_raw` | `ds_employees_clean` |
| Linked service | `ls_blob_storage` | `ls_blob_storage` |
| Format | DelimitedText (CSV) | DelimitedText (CSV) |
| Container | `raw` | `clean` |
| Folder | `input` | `output` |
| File | `employees.csv` | Set by Data Flow sink |
| Columns | id, name, age, salary, department | id, name, age, salary, salary_with_bonus, department |

Both datasets use UTF-8, comma delimiter, LF row delimiter and a header row. The Data Flow source projection defines numeric types.

## Deploy

Run from the repository root after creating the linked service and setting `RG` and `FACTORY` (see [Azure deployment](AZURE-DEPLOYMENT.md)).

```bash
mkdir -p .deployment
jq '.properties' dataset/ds_employees_raw.json > .deployment/raw.json
jq '.properties' dataset/ds_employees_clean.json > .deployment/clean.json

az datafactory dataset create -g "$RG" --factory-name "$FACTORY" --dataset-name ds_employees_raw --properties @.deployment/raw.json
az datafactory dataset create -g "$RG" --factory-name "$FACTORY" --dataset-name ds_employees_clean --properties @.deployment/clean.json

az datafactory dataset show -g "$RG" --factory-name "$FACTORY" --dataset-name ds_employees_raw
az datafactory dataset show -g "$RG" --factory-name "$FACTORY" --dataset-name ds_employees_clean
```

Expected pipeline output: 3 employee records after filtering `age > 25`. Azure execution is not yet verified.
