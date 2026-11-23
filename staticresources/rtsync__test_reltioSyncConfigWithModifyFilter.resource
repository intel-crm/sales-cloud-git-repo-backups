{
"Name":"Config",
"Retry_Count_Config__c":5,
"Scheduler_Record_Count__c":20,
"Config_JSON__c":
{
  "FieldsConfig": {
    "Account": {
      "checkFieldsChanged": true,
      "fieldList": [
        "RecordTypeId",
        "Id",
        "FirstName"
      ],
      "fieldListToCheck": [
        "LastName",
        "SomeWrongField"
      ],
      "lookupFieldList": [],
      "requiredFieldList": [
        "RecordTypeId",
        "Id",
        "FirstName"
      ],
      "ignoreSyncUserFieldList": [],
      "priority": 1
    },
    "Contact": {
      "fieldList": [
        "Id",
        "LastName",
        "FirstName",
        "uri__c",
        "Phone"
      ],
      "lookupFieldList": [],
      "requiredFieldList": [
        "Id",
        "LastName",
        "FirstName",
        "uri__c",
        "Phone"
      ],
      "ignoreSyncUserFieldList": [],
      "priority": 1
    }
  },
  "RetryCount": "1",
  "RestrictedUsers": [
    "c.dev@r.com.dev07",
    "r_sync_c@r.com.test"
  ],
  "EndPointURL": {
    "00D550000006mFNEAY": "https://mpe.r.com/d4KlmWJ6",
    "00D36000001FOqPEAW": "https://tsts.r.com/KXmX"
  }
}}