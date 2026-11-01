# 🚀 Azure Data Factory (ADF) Data Flow Project

## 📌 Project Title

**End-to-End Data Transformation using Azure Data Factory Mapping Data Flow**

---

## 🎯 Objective

Build a pipeline to:

* Ingest raw data (CSV/JSON)
* Transform data using **Mapping Data Flow**
* Load cleaned data into destination (Azure SQL / Blob)

---

## 🏗️ Architecture Overview

```mermaid
flowchart LR
    RAW["Azure Blob Storage<br/>raw/input/employees.csv"]
    ADF["ADF Pipeline<br/>pl_employee_transform"]
    FLOW["Mapping Data Flow<br/>df_employee_transform<br/>Azure IR / Spark"]
    CLEAN["Azure Blob Storage<br/>clean/output/"]

    ADF -->|"ExecuteDataFlow activity"| FLOW
    RAW -->|"Read CSV"| FLOW
    FLOW -->|"Write transformed CSV"| CLEAN
```

**Transformation:** Source → Derived Column (`salary_with_bonus = round(salary * 1.10, 2)`) → Filter (`age > 25`) → Select → Sink.

**Expected output:** 3 records from 4 input records. Both Blob containers are in the same storage account. The ADF pipeline orchestrates the Data Flow; the Spark runtime reads and writes Blob data.

[Detailed architecture and sequence diagrams](docs/ARCHITECTURE.md) · [Azure deployment commands](docs/AZURE-DEPLOYMENT.md)

---

## Terraform Deployment

Deploy the full Azure Data Factory lab, including storage, sample CSV, managed identity permissions, linked service, datasets, Data Flow, and pipeline, using the [Terraform configuration](terraform/README.md).

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Set subscription_id in terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform provisions the resources; run the pipeline separately using the commands in `terraform/README.md`. Terraform deployment verified on 1 November 2026: **13 resources created** in `centralindia` (`rg-adf-dataflow-ukamp80b`, factory `adf-dataflow-ukamp80b`). Pipeline execution remains to be verified.

---

## 🧰 Services Used

* Azure Data Factory
* Azure Blob Storage
* Azure SQL Database (optional)
* Mapping Data Flow
* Integration Runtime

---

## 📁 Sample Dataset

Example CSV:

```csv
id,name,age,salary,department
1,Atul,28,50000,IT
2,Rahul,35,70000,HR
3,Neha,22,30000,IT
4,Ankit,40,90000,Finance
```

---

# ⚙️ Step-by-Step Implementation

## 🔹 Step 1: Create Azure Resources

* Create **Resource Group**
* Create:

  * Storage Account → Upload CSV file
  * Azure Data Factory
  * Azure SQL Database (optional)

---

## 🔹 Step 2: Create Linked Services

In ADF:

* Blob Storage → connect using access key
* SQL Database → connect using credentials

---

## 🔹 Step 3: Create Datasets

* Source Dataset → CSV from Blob
* Sink Dataset → SQL Table / Blob

---

## 🔹 Step 4: Create Mapping Data Flow

### 🔧 Transformations Used:

### 1️⃣ Source

* Select dataset (CSV)
* Enable schema import

---

### 2️⃣ Derived Column

Add new column:

```text
salary_with_bonus = salary * 1.1
```

---

### 3️⃣ Filter

Condition:

```text
age > 25
```

---

### 4️⃣ Select

* Choose required columns
* Rename columns if needed

---

### 5️⃣ Sink

* Load into SQL table or Blob

---

### Azure Data Factory Studio – Deployed Mapping Data Flow

![Deployed ADF Mapping Data Flow showing sourceEmployees, deriveBonus, filterAdults, selectColumns, and sinkEmployees](docs/images/adf-mapping-data-flow.png)

*Screenshot captured 1 November 2026 in Azure Data Factory Studio. It shows the deployed visual transformation; pipeline execution is not yet verified.*

---

## 🔹 Step 5: Create Pipeline

* Add **Data Flow Activity**
* Select created Data Flow
* Debug → Publish → Trigger

---

## 🔹 Step 6: Trigger Pipeline

* Manual Trigger OR Scheduled Trigger

---

## 📊 Output Example

| id | name  | age | salary | salary_with_bonus | department |
| -- | ----- | --- | ------ | ----------------- | ---------- |
| 1  | Atul  | 28  | 50000  | 55000             | IT         |
| 2  | Rahul | 35  | 70000  | 77000             | HR         |
| 4  | Ankit | 40  | 90000  | 99000             | Finance    |

---

# 📌 Key Concepts (Exam-Oriented AZ-104 / AZ-305)

### 🔹 Mapping Data Flow

* Visual data transformation
* Runs on Spark cluster (auto-managed)

### 🔹 Integration Runtime

* Compute engine for ADF
* Types:

  * Azure IR
  * Self-hosted IR

### 🔹 Data Flow vs Pipeline

| Feature        | Pipeline      | Data Flow |
| -------------- | ------------- | --------- |
| Control Flow   | Yes           | No        |
| Transformation | Limited       | Advanced  |
| Compute        | Orchestration | Spark     |

---

# ⚡ Real-Time Use Cases

* Data cleaning before ML models
* ETL pipelines for data warehouse
* Log processing
* Batch data transformation

---

# 🚀 Best Practices

* Use **Debug mode** for testing
* Partition large datasets
* Use **parameterization**
* Monitor via **ADF Monitor tab**
* Use staging for large loads

---

# ⚠️ Common Issues & Fix

| Issue           | Fix                        |
| --------------- | -------------------------- |
| Data Flow slow  | Increase compute (DIUs)    |
| Schema mismatch | Import schema properly     |
| Pipeline fails  | Check activity output logs |

---


# 📌 Interview Questions (ADF Data Flow – Updated)

---

## 🔹 1. Difference between Data Flow and Copy Activity?

| Feature     | Data Flow                       | Copy Activity                |
| ----------- | ------------------------------- | ---------------------------- |
| Purpose     | Data Transformation (ETL logic) | Data Movement (Lift & Shift) |
| Compute     | Spark Cluster (ADF managed)     | Integration Runtime          |
| Use Case    | Complex transformations         | Simple copy (Blob → SQL)     |
| Performance | Slower (heavy compute)          | Faster (direct copy)         |
| UI          | Visual transformation designer  | Simple config                |

👉 **Short Answer:**

* Copy Activity = Move Data
* Data Flow = Transform Data

---

## 🔹 2. What is Integration Runtime (IR)?

👉 **Definition:**
Integration Runtime is the **compute infrastructure** used by Azure Data Factory to perform data movement and transformation.

### Types:

* **Azure IR** → Cloud-based (default)
* **Self-hosted IR** → On-premise data access
* **Azure-SSIS IR** → Run SSIS packages

👉 **Use Case:**

* Connect on-prem DB → Cloud
* Execute pipelines & copy activity

---

## 🔹 3. How does ADF scale?

👉 ADF scales automatically using **serverless architecture**:

* **Copy Activity:** Scales using parallel threads
* **Data Flow:** Uses auto-managed **Spark clusters**
* **DIU (Data Integration Units):** Controls performance
* **Parallel pipelines:** Multiple pipelines can run simultaneously

👉 **Key Point:**
ADF is **fully managed → no infra management required**

---

## 🔹 4. What is Debug mode in Data Flow?

👉 **Definition:**
Debug mode allows you to **test Data Flow transformations without running full pipeline**

### Features:

* Uses temporary Spark cluster
* Preview data at each transformation
* Faster testing & validation

👉 **Important:**

* Debug cluster runs → **cost is incurred**
* Must stop debug after use

---

# 🔥 Additional Important Questions (Must Know)

---

## 🔹 5. What is Mapping Data Flow?

* Visual transformation tool in ADF
* Runs on Apache Spark
* No-code / low-code ETL

---

## 🔹 6. What is the difference between Pipeline and Data Flow?

| Pipeline      | Data Flow       |
| ------------- | --------------- |
| Orchestration | Transformation  |
| Control Flow  | Data Processing |
| Lightweight   | Compute Heavy   |

---

## 🔹 7. What is Dataset in ADF?

👉 Dataset represents:

* Structure of data (schema)
* Location of data (Blob, SQL, etc.)

---

## 🔹 8. What is Linked Service?

👉 Linked Service = Connection to data source
Example:

* Blob Storage
* SQL Database

---

## 🔹 9. What is Trigger in ADF?

* Schedule pipeline execution
* Types:

  * Schedule Trigger
  * Tumbling Window
  * Event-based

---

## 🔹 10. What is DIU?

👉 **Data Integration Unit (DIU)** = Measure of compute power in ADF

* Higher DIU → Better performance
* Used in Copy Activity

---

## 🔹 11. What is Sink and Source?

* **Source:** Input data
* **Sink:** Output destination

---

## 🔹 12. What are common transformations in Data Flow?

* Filter
* Derived Column
* Join
* Aggregate
* Sort

---

# 🎯 Final Tip (Interview Ready)

👉 Always explain like this:

> “ADF is used for orchestration and ETL.
> Copy Activity handles data movement,
> while Data Flow handles transformation using Spark.”


---
