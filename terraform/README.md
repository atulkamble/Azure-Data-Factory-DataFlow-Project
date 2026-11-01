# Deploy the ADF Data Flow lab with Terraform

Creates: resource group, StorageV2 account, `raw` and `clean` containers, uploaded sample CSV, Azure Data Factory (system-assigned managed identity), Blob Data Contributor role assignment, linked service, two datasets, Mapping Data Flow, and pipeline.

**Requirements:** Terraform >= 1.6, Azure CLI, an Azure subscription, and permission to assign Azure RBAC roles. Uses AzureRM 4.x and AzAPI 2.x. Run from the repository's `terraform/` directory.

## 1. Authenticate

```bash
az login
az account list -o table
az account set --subscription "08b7b8d4-af42-4972-9517-11ea256ea068"
```

## 2. Configure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Subscription ID is prefilled in the example file
```

## 3. Deploy

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

Terraform uploads `../sample-data/employees.csv` to `raw/input/employees.csv`. It creates the ADF artifacts from the JSON files in the parent repository. ADF linked-service storage endpoint is generated from the new account.

## Verified deployment (1 November 2026)

Terraform deployment succeeded in Azure subscription `08b7b8d4-af42-4972-9517-11ea256ea068`, region `centralindia`.

| Resource | Deployed name |
|---|---|
| Resource group | `rg-adf-dataflow-ukamp80b` |
| Data Factory | `adf-dataflow-ukamp80b` |
| Storage account | `stadfukamp80b` |
| Containers | `raw`, `clean` |
| Source blob | `raw/input/employees.csv` |
| Linked service | `ls_blob_storage` |
| Datasets | `ds_employees_raw`, `ds_employees_clean` |
| Mapping Data Flow | `df_employee_transform` |
| Pipeline | `pl_employee_transform` |
| Permissions | Data Factory managed identity: Storage Blob Data Contributor |

The first apply created 8 resources, then stopped because the linked service explicitly referenced `AutoResolveIntegrationRuntime`. Removing that reference resolved the Azure API error. The next apply completed with **5 added, 0 changed, 0 destroyed**, bringing the total to **13 resources**.

`terraform validate` and `terraform plan` succeeded. **Pipeline execution and CSV output have not yet been verified.**

## 4. Run the pipeline

```bash
RG=$(terraform output -raw resource_group_name)
FACTORY=$(terraform output -raw data_factory_name)
STORAGE=$(terraform output -raw storage_account_name)

RUN_ID=$(az datafactory pipeline create-run \
  -g "$RG" --factory-name "$FACTORY" \
  --name pl_employee_transform --query runId -o tsv)
echo "$RUN_ID"

az datafactory pipeline-run show \
  -g "$RG" --factory-name "$FACTORY" --run-id "$RUN_ID" \
  --query "{status:status,message:message}" -o json
```

Check the pipeline in ADF Studio **Monitor**. Once successful, verify `clean/output/`:

```bash
az storage blob list --account-name "$STORAGE" \
  --container-name clean --prefix output/ --auth-mode login -o table
```

For `--auth-mode login`, your own Azure identity needs a Blob data role. Terraform grants **the Data Factory identity**, not your user, the Storage Blob Data Contributor role. You can alternatively verify the output in Azure Portal with suitable access.

**Important:** Terraform provisions resources and publishes the checked-in ADF definitions; it does **not** automatically run the pipeline. The existing Mapping Data Flow script has not been validated in a live ADF runtime, so an Azure run may reveal script or sink configuration changes needed. Role assignments can take several minutes to propagate.

## 5. Destroy resources

```bash
terraform destroy
```

This deletes the lab resources managed by this Terraform state. Keep `terraform.tfstate` secure; use remote state for team usage.
