{
  "Name": "Config",
  "Config_JSON__c": {
    "FieldsConfig": {
      "Account": {
        "fieldList": [
          "RecordTypeId",
          "Id",
          "FirstName",
          "MiddleName",
          "LastName",
          "Salutation",
          "Suffix",
          "PersonDoNotCall",
          "PersonEmail",
          "PersonHomePhone",
          "PersonMobilePhone",
          "PersonMailingCity",
          "PersonMailingCountry",
          "PersonMailingPostalCode",
          "PersonMailingStateCode",
          "PersonMailingStreet",
          "PersonHasOptedOutOfEmail",
          "LastModifiedDate"
        ],
        "lookupFieldList": [],
        "requiredFieldList": [
          "RecordTypeId",
          "Id",
          "FirstName",
          "MiddleName",
          "LastName",
          "Salutation",
          "Suffix",
          "PersonDoNotCall",
          "PersonEmail",
          "PersonHomePhone",
          "PersonMobilePhone",
          "PersonMailingCity",
          "PersonMailingCountry",
          "PersonMailingPostalCode",
          "PersonMailingStateCode",
          "PersonMailingStreet",
          "PersonHasOptedOutOfEmail",
          "LastModifiedDate"
        ],
        "ignoreSyncUserFieldList": [],
        "priority": 1
      },
      "Contact": {
        "fieldList": [
          "Id",
          "LastName",
          "FirstName",
          "Phone"
        ],
        "lookupFieldList": [],
        "requiredFieldList": [
          "Id",
          "LastName",
          "FirstName",
          "Phone"
        ],
        "ignoreSyncUserFieldList": [],
        "priority": 1
      },
      "Address_vod__c": {
        "fieldList": [
          "Id",
          "Name"
        ],
        "lookupFieldList": [],
        "requiredFieldList": [
          "Id",
          "Name"
        ],
        "ignoreSyncUserFieldList": [],
        "priority": 1
      },
      "Contact_Information_MVN__c": {
        "fieldList": [
          "Id"
        ],
        "lookupFieldList": [],
        "requiredFieldList": [
          "Id"
        ],
        "ignoreSyncUserFieldList": [],
        "priority": 1
      }
    },
    "RetryCount": "1",
    "RestrictedUsers": [
      "test@reltio.com",
      "test2@reltio.com"
    ],
    "EndPointURL": {
      "00D550000006mFNEAY": "https://connector.com/tenantName2",
      "00D36000001FOqPEAW": "https://connector.com/tenantName1?username=connector&password=password"
    }
  },
  "Retry_Count_Config__c": 5,
  "Scheduler_Record_Count__c": 20
}