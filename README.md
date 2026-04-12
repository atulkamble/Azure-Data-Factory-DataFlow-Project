Here’s a **complete Azure Data Factory (ADF) Data Flow Project** — structured exactly in your preferred **trainer + README style**, with **clear steps, architecture, and hands-on implementation**.

---

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

![Image](https://images.openai.com/static-rsc-4/lVVpWUOISIYaQoYrYgJLfQh5-oeKmLc7DCPIrIn4hYNfwi9rE84PpDlbqxEfAN3F7RcAq6sP43aIS94ahhauwSCBcaVpWZy7L3hEdGvsyUGEl9sO9WgVXQD2IXokkV3wyMNR-igFrlXgdBGDzwjHLioRZGXLnHJ9IYsFh0uQel_nCtU9s-21tUSGVvcP4QM4?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/bOaWXNIwjeaqthDCoAdx4D1FLqB_Eod23B46p1pFg-NmNrPttAmKx8yKnk_Rnx2yFNMScWGg7_UbHPt3DjKY4OpaGQkWqvrcvFVdXqc9TioQ49NJADAEf8CP1i32MkrWWAFWsR4CRzTUDdxutYo4SmRTtfHM0GZtbNmIYiNGO6s_j-hb8RSRzZVC468B9oCi?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/MQrI-S9wtF0wusIgKxA1jIevDG3lk7EOoGSzCVsqo6BaXoqgrghYnGY189vdHtl5d_AvcBBViFUBdizviWOg2s509aP2KGNvChxxnNUQ9ds6e5hoWKW_Vn93IOoKNVOpP3W03ij2d15m4iA2B8218CrJehTk1LAFNW0KjgZCWxr4o6IN2XRwM7nFFAppdfco?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/ehfpuZOqBjobb4UIPcsiIf5BLS469VhNJLIa3hbCD_GqkQDHyhslI7Y3LUmnDd8LMCoy657T3NkVX1gOh0HOMeY73C26oZSQPK-Xkic_KekFVNJM4h5Ru8TAGzvzdlRUsgCfdPT842sZwkQ4xB08Px9f-bdcDj0PMDyfACIHtjxrDZ05T_PVlTL7uZ4O1ofu?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/4BB18GHvHfF0ePBkSBnmU3FoEuZim7WHJiLOEQdB8fPYiBgmRPsbCRDeNK7qXLJtCh-Kqrp69il4LEMKNYSTTBC-sdeYYM-utJbPhU722mb4nDffipjQX4f9aeqhnA6gzB7gAZgI6TpdboaYGgU3XBs7y5AjoJv0pgKwapJEd71B3FgSp5Lhap_vUsJSgdTv?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/snLgQKi3w1IRVUSgNugTNmHUaaXMxG0gOj4UIwYepF-KwIDTOJrCgK5NM_1PF6iOgUW5ZyP6Jd6_u4Bn3vUviRXmt7_s5rweLLgSvPIMOXXo6btCL86EDKVyalmF2XhDPgleX5fhYvhwRYQYcb3k3luqcl_Vels_IDviUgLf1W5zxeTsIgy7OGrCYDXxCZVS?purpose=fullsize)

### Flow:

1. Source → Blob Storage (Raw Data)
2. ADF Pipeline triggers Data Flow
3. Data Flow performs transformations
4. Sink → Azure SQL Database / Clean Storage

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
