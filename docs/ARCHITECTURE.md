# Architecture and Data Flow Diagrams

These diagrams match the repository's **Blob-to-Blob** implementation. Azure SQL is an optional future extension, not part of the checked-in pipeline. Arrows distinguish orchestration commands from actual CSV data movement.

## 1. Azure deployment architecture

```mermaid
flowchart TB
    U["Operator / Azure CLI"]
    A["Azure Data Factory<br/>pl_employee_transform"]
    R["Azure Integration Runtime<br/>Managed Spark compute"]
    I[("Azure Blob Storage<br/>raw container<br/>input/employees.csv")]
    O[("Azure Blob Storage<br/>clean container<br/>output/employees_clean.csv")]
    MI["ADF system-assigned<br/>managed identity"]
    RB["Storage Blob Data Contributor<br/>on storage account"]
    MON["ADF Monitor<br/>pipeline and activity runs"]

    U -->|"Create and start pipeline"| A
    A -->|"ExecuteDataFlow activity"| R
    R -->|"Read input CSV"| I
    R -->|"Write transformed CSV"| O
    A -.->|"Run status"| MON
    MI -.->|"Assigned role"| RB
    RB -.->|"Authorizes storage access"| I
    RB -.->|"Authorizes storage access"| O
```

**Note:** Source and sink containers reside in the same Azure Storage account in this lab. ADF uses managed identity for authorization. The Integration Runtime runs the Spark-based mapping data flow; the pipeline orchestrates its execution.

## 2. Mapping Data Flow — actual transformation sequence

```mermaid
flowchart LR
    S["sourceEmployees<br/>Read CSV<br/>4 records"]
    D["deriveBonus<br/>salary_with_bonus =<br/>round(salary * 1.10, 2)"]
    F{"filterAdults<br/>age > 25"}
    C["selectColumns<br/>id, name, age, salary,<br/>salary_with_bonus, department"]
    K["sinkEmployees<br/>Write CSV<br/>3 records"]
    X["Excluded<br/>Neha, age 22"]

    S --> D --> F
    F -->|"3 rows match"| C
    F -.->|"1 row excluded"| X
    C --> K
```

The filter does **not** create a separate rejection sink: excluded rows are dropped. The `selectColumns` stage retains six columns, and `sinkEmployees` writes the output under the clean container.

## 3. Execution sequence

```mermaid
sequenceDiagram
    autonumber
    actor User as Operator
    participant ADF as ADF Pipeline
    participant IR as Azure IR / Spark
    participant Raw as Blob: raw/input
    participant Clean as Blob: clean/output
    User->>ADF: Start pl_employee_transform
    ADF->>IR: Execute df_employee_transform
    IR->>Raw: Read employees.csv
    Raw-->>IR: 4 source records
    Note over IR: Derive bonus, filter age > 25, select columns
    IR->>Clean: Write transformed CSV (3 records)
    Clean-->>IR: Write completion
    IR-->>ADF: Activity succeeded or failed
    ADF-->>User: Pipeline run status
```

## 4. Example data and expected output

| id | name | age | salary | salary_with_bonus | department | Outcome |
|---:|---|---:|---:|---:|---|---|
| 1 | Atul | 28 | 50000 | 55000 | IT | Included |
| 2 | Rahul | 35 | 70000 | 77000 | HR | Included |
| 3 | Neha | 22 | 30000 | 33000 | IT | Filtered out |
| 4 | Ankit | 40 | 90000 | 99000 | Finance | Included |

The excluded row is shown only to explain the transformation; it does not appear in the destination.

## 5. Scope and validation

- **Implemented in repository:** one Blob linked service, two delimited-text datasets, one Mapping Data Flow, and one pipeline containing an ExecuteDataFlow activity.
- **Not implemented:** Azure SQL sink, schedule trigger, rejection/quarantine output, or external orchestration services.
- **Requires Azure verification:** data flow script parsing, managed identity connection, sink file naming, pipeline execution, and actual output. Diagrams document the intended design, not a verified deployment.
- **Compute:** Mapping Data Flow uses Spark cores configured on the ExecuteDataFlow activity; Copy Activity DIUs are not applicable here.

See [deployment steps](AZURE-DEPLOYMENT.md).
