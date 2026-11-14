// ADF // Copy

1. Create Storage Account
2.
Source - Blob Storage - Object Storage - Container - mycontainer - test.txt
Destination - FileShares - myfileshares -

3. create adf - azure data favtory - myadf686966
4. create dataset - blob storage - myblob - mycontainer
5. create dataset - fileshares - myfileshares
6. create pipeline - drag and drop - copy
6.                                       source - blob storage - myblob - mycontainer
7.                                       sink - myfileshares  - myblob
8. publish all
9. trigger now



// ADF - move

1. Create Storage Account
2.
Source - Blob Storage - Object Storage - Container - mycontainer - test.txt
Destination - FileShares - myfileshares -

3. create adf - azure data favtory - myadf686966
4. create dataset - blob storage - myblob - mycontainer
5. create dataset - blob storage - myblob - newcontainer DelimitedText datasets
6. create pipeline - drag and drop - move
6.                                       source - blob storage - myblob - mycontainer / excel  DelimitedText datasets
7.                                       sink - blob storage - newcontainer DelimitedText datasets
8. validate before >> excel visible >> publish all
9. trigger now

employees.csv

id,name,salary
1,Atul,50000
2,Rahul,25000
3,Amit,60000

filter salary = 30000










{
  "name": "Transform data1",
  "type": "ExecuteDataFlow",
  "dependsOn": [],
  "policy": {
    "timeout": "0.12:00:00",
    "retry": 0,
    "retryIntervalInSeconds": 30,
    "secureOutput": false,
    "secureInput": false
  },
  "userProperties": [],
  "typeProperties": {
    "dataflow": {
      "referenceName": "DataFlow1",
      "type": "DataFlowReference",
      "datasetParameters": {}
    },
    "compute": {
      "coreCount": 8,
      "computeType": "General"
    },
    "traceLevel": "Fine"
  }
}



{
  "name": "DataFlow1",
  "properties": {
    "type": "MappingDataFlow",
    "typeProperties": {
      "sources": [
        {
          "dataset": {
            "referenceName": "SourceCSV",
            "type": "DatasetReference"
          },
          "name": "source1"
        }
      ],
      "sinks": [
        {
          "dataset": {
            "referenceName": "SinkCSV",
            "type": "DatasetReference"
          },
          "name": "sink1"
        }
      ],
      "transformations": [
        {
          "name": "filter1"
        },
        {
          "name": "derive1"
        }
      ],
      "scriptLines": [
        "source(output(",
        "    id as integer,",
        "    name as string,",
        "    salary as integer",
        "),",
        "allowSchemaDrift: true,",
        "validateSchema: false) ~> source1",
        "source1 filter(salary > 30000) ~> filter1",
        "filter1 derive(bonus = salary * 0.10) ~> derive1",
        "derive1 sink(allowSchemaDrift: true,",
        "validateSchema: false) ~> sink1"
      ]
    }
  }
}
