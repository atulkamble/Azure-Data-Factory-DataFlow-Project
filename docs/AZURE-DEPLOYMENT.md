# Azure CLI deployment — step-by-step

This lab deploys the repository's Blob → Mapping Data Flow → Blob pipeline. Commands target **Bash** (Azure Cloud Shell, macOS or Linux) with Azure CLI and Git installed. ADF Mapping Data Flow requires a supported Azure region and incurs Spark compute charges.

> **Prerequisites:** Azure subscription with permission to create resource groups, storage accounts, factories and role assignments. Use a subscription you control. Resource names are examples and storage/factory names must be globally unique.

## 1. Clone and authenticate

```bash
git clone https://github.com/atulkamble/Azure-Data-Factory-DataFlow-Project.git
cd Azure-Data-Factory-DataFlow-Project
az login
az account list -o table
az account set --subscription "<SUBSCRIPTION_ID>"
az account show --query "{name:name,id:id}" -o table
```

## 2. Set deployment variables

```bash
export LOCATION=centralindia
export RG=rg-adf-dataflow-lab
export SUFFIX=$(openssl rand -hex 4)
export STORAGE="stadf${SUFFIX}"
export FACTORY="adf-dataflow-${SUFFIX}"
echo "$RG $STORAGE $FACTORY"
```

## 3. Create resource group and storage

```bash
az group create --name "$RG" --location "$LOCATION"
az storage account create --name "$STORAGE" --resource-group "$RG" --location "$LOCATION" --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false
az storage container create --account-name "$STORAGE" --name raw --auth-mode login
az storage container create --account-name "$STORAGE" --name clean --auth-mode login
```

The container commands require your signed-in identity to have **Storage Blob Data Contributor** (or an equivalent data-plane role). If you have permission to grant roles, assign it at storage-account scope:

```bash
export STORAGE_ID=$(az storage account show -g "$RG" -n "$STORAGE" --query id -o tsv)
export USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee-object-id "$USER_OBJECT_ID" --assignee-principal-type User --role "Storage Blob Data Contributor" --scope "$STORAGE_ID"
```

Role propagation can take several minutes. Retry container creation after permissions propagate.

## 4. Upload sample input

```bash
az storage blob upload --account-name "$STORAGE" --container-name raw --name input/employees.csv --file sample-data/employees.csv --auth-mode login --overwrite
az storage blob list --account-name "$STORAGE" --container-name raw --prefix input/ --auth-mode login -o table
```

## 5. Create Data Factory and grant its managed identity access

```bash
az datafactory create --resource-group "$RG" --factory-name "$FACTORY" --location "$LOCATION"
export FACTORY_PRINCIPAL_ID=$(az datafactory show --resource-group "$RG" --factory-name "$FACTORY" --query identity.principalId -o tsv)
echo "$FACTORY_PRINCIPAL_ID"
az role assignment create --assignee-object-id "$FACTORY_PRINCIPAL_ID" --assignee-principal-type ServicePrincipal --role "Storage Blob Data Contributor" --scope "$STORAGE_ID"
```

Wait for RBAC propagation before executing the data flow. The linked service uses the factory's managed identity rather than an embedded storage key.

## 6. Configure the storage linked service

The checked-in `linkedService/ls_blob_storage.json` contains the placeholder `REPLACE_STORAGE_ACCOUNT`. Create a deployment copy and replace it:

```bash
mkdir -p .deployment
sed "s/REPLACE_STORAGE_ACCOUNT/$STORAGE/g" linkedService/ls_blob_storage.json > .deployment/ls_blob_storage.json
az datafactory linked-service create --resource-group "$RG" --factory-name "$FACTORY" --linked-service-name ls_blob_storage --properties @.deployment/ls_blob_storage.json
```

**Important:** Azure CLI `--properties` expects the linked service *properties object*, not the full exported `{name,properties}` wrapper. The repository's exported JSON files use the wrapper format. Extract `.properties` for CLI deployments with `jq` (available in Azure Cloud Shell):

```bash
jq '.properties' .deployment/ls_blob_storage.json > .deployment/ls-properties.json
az datafactory linked-service create -g "$RG" --factory-name "$FACTORY" --linked-service-name ls_blob_storage --properties @.deployment/ls-properties.json
```

If the initial wrapper-form command above fails, use the extracted-properties command. For identity-based Blob authentication, confirm the linked service uses a supported managed-identity configuration in ADF Studio (Manage → Linked services → Test connection).

## 7. Deploy source and sink datasets

```bash
jq '.properties' dataset/ds_employees_raw.json > .deployment/raw-properties.json
jq '.properties' dataset/ds_employees_clean.json > .deployment/clean-properties.json
az datafactory dataset create -g "$RG" --factory-name "$FACTORY" --dataset-name ds_employees_raw --properties @.deployment/raw-properties.json
az datafactory dataset create -g "$RG" --factory-name "$FACTORY" --dataset-name ds_employees_clean --properties @.deployment/clean-properties.json
```

The source reads `raw/input/employees.csv`. The sink writes to `clean/output/`.

## 8. Deploy Mapping Data Flow

```bash
jq '.properties' dataflow/df_employee_transform.json > .deployment/dataflow-properties.json
az datafactory data-flow create -g "$RG" --factory-name "$FACTORY" --data-flow-name df_employee_transform --properties @.deployment/dataflow-properties.json
```

Transformations:

| Order | Stage | Expression / behavior |
|---|---|---|
| 1 | Source | Read employee CSV; cast id, age and salary |
| 2 | Derived Column | `round(salary * 1.10, 2)` |
| 3 | Filter | `age > 25` |
| 4 | Select | Keep id, name, age, salary, salary_with_bonus, department |
| 5 | Sink | Write transformed CSV |

**Validation note:** Mapping Data Flow script syntax, sink file naming and CSV type inference must be validated in ADF Studio before production use. The repository artifacts are teaching examples, not deployment-tested templates.

## 9. Deploy pipeline

```bash
jq '.properties' pipeline/pl_employee_transform.json > .deployment/pipeline-properties.json
az datafactory pipeline create -g "$RG" --factory-name "$FACTORY" --name pl_employee_transform --pipeline @.deployment/pipeline-properties.json
az datafactory pipeline show -g "$RG" --factory-name "$FACTORY" --name pl_employee_transform -o json
```

## 10. Run pipeline

```bash
export RUN_ID=$(az datafactory pipeline create-run -g "$RG" --factory-name "$FACTORY" --name pl_employee_transform --query runId -o tsv)
echo "Pipeline run: $RUN_ID"
az datafactory pipeline-run show -g "$RG" --factory-name "$FACTORY" --run-id "$RUN_ID" --query "{runId:runId,status:status,message:message}" -o json
```

Re-run the status command until it reports `Succeeded` or `Failed`. First-run Spark startup may take several minutes.

## 11. Verify output

```bash
az storage blob list --account-name "$STORAGE" --container-name clean --prefix output/ --auth-mode login -o table
az storage blob download-batch --account-name "$STORAGE" --source clean --destination .deployment/download --pattern 'output/*' --auth-mode login
find .deployment/download -type f
```

Expected business result: three records (ages 28, 35, 40) and bonus salaries 55000, 77000, 99000. Compare the generated CSV to `sample-data/expected-output.csv` (column ordering and numeric formatting may differ).

## 12. Monitor and troubleshoot

```bash
az datafactory activity-run query-by-pipeline-run -g "$RG" --factory-name "$FACTORY" --run-id "$RUN_ID" --last-updated-after "$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ)" --last-updated-before "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

The `date -v-1d` option is macOS-specific; on GNU/Linux use `date -u -d '1 day ago'` instead. For a portable alternative, use the ADF Studio **Monitor** tab and select the pipeline run.

Common failures:
- **403 / authorization:** Verify both your user and ADF managed identity have Blob data-plane access and wait for role propagation.
- **Invalid linked service:** Confirm storage endpoint and managed identity configuration.
- **Data Flow script validation:** Open the Data Flow in ADF Studio, inspect projection and sink options, and publish any fixes.
- **No output:** Check the run's activity error, input blob path, and sink location.
- **Unexpected charges:** Stop Data Flow Debug and remove the lab resources when finished.

## 13. Cleanup

**Destructive:** This deletes the resource group and every resource in it.

```bash
az group delete --name "$RG" --yes --no-wait
```

See [Architecture and logic diagrams](ARCHITECTURE.md) and the [project README](../README.md).
