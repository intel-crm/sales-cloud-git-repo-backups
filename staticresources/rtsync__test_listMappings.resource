{
  "name": "Business Account Mapping",
  "sfdcObject": {
    "name": "Account",
    "label": "Account",
    "recordType": {
      "id": "XXJSDLFKJ5343",
      "label": "Business Account"
    }
  },
  "to_reltio": {
    "filter": "equals(Name, Vaso)",
    "reltioObjects": [
      {
        "uri": "configuration/entityTypes/Organization",
        "label": "Organization",
        "filter": "equals(configuration/entityTypes/Organization/attributes/SyncFlag, true)",
        "fieldMappings": [
          {
            "sfdcAttributes": [
              {
                "name": "FirstName",
                "label": "First Name"
              },
              {
                "name": "LastName",
                "label": "Last Name"
              }
            ],
            "isExpression": true,
            "expression": "=source(FirstName).concat(LastName)",
            "reltioAttribute": {
              "uri": "configuration/entityTypes/Organization/attributes/Name",
              "label": "Name"
            }
          },
          {
            "sfdcAttributes": [
              {
                "name": "FirstName",
                "label": "First Name"
              }
            ],
            "isExpression": false,
            "expression": "",
            "reltioAttribute": {
              "uri": "configuration/entityTypes/Organization/attributes/FirstName",
              "label": "First Name"
            }
          }
        ],
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Phone",
            "label": "Phone",
            "filter": "",
            "fieldMappings": [
              {
                "sfdcAttributes": [
                ],
                "isExpression": true,
                "expression": "='Work",
                "reltioAttribute": {
                  "uri": "configuration/entityTypes/Organization/attributes/Phone/Type",
                  "label": "Type"
                }
              },
              {
                "sfdcAttributes": [
                  {
                    "name": "WorkPhone",
                    "label": "Work Phone"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "reltioAttribute": {
                  "uri": "configuration/entityTypes/Organization/attributes/Phone/Number",
                  "label": "Number"
                }
              }
            ],
            "reltioObjects": [
            ]
          }
        ]
      }
    ],
    "childrenSFDCObjects": [
      {
        "sfdcObject": {
          "name": "Address_vv__c",
          "label": "Veeva Address",
          "recordType": {
            "id": "XXJSDLFKJ323333",
            "label": "Billing"
          }
        },
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Address",
            "label": "Address",
            "filter": "",
            "fieldMappings": [
              {
                "sfdcAttributes": [
                  {
                    "name": "Street__c",
                    "label": "Street"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "reltioAttribute": {
                  "uri": "configuration/entityTypes/Organization/attributes/Address/attributes/Street",
                  "label": "Street"
                }
              },
              {
                "sfdcAttributes": [
                  {
                    "name": "City__c",
                    "label": "City"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "reltioAttribute": {
                  "uri": "configuration/entityTypes/Organization/attributes/Address/attributes/City",
                  "label": "City"
                }
              }
            ],
            "reltioObjects": [
            ]
          }
        ]
      },
      {
        "sfdcObject": {
          "name": "Address_vv__c",
          "label": "Veeva Address",
          "recordType": {
            "id": "XXKHLLLL2223",
            "label": "Shipping"
          }
        },
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Address",
            "label": "Address",
            "filter": "",
            "fieldMappings": [
              {
                "sfdcAttributes": [
                  {
                    "name": "Street__c",
                    "label": "Street"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "reltioAttribute": {
                  "uri": "configuration/entityTypes/Organization/attributes/Address/attributes/Street",
                  "label": "Street"
                }
              },
              {
                "sfdcAttributes": [
                  {
                    "name": "City__c",
                    "label": "City"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "reltioAttribute": {
                  "uri": "configuration/entityTypes/Organization/Address/attributes/City",
                  "label": "City"
                }
              }
            ],
            "reltioObjects": [
            ]
          }
        ]
      }
    ]
  },
  "to_salesforce": {
    "reltioObjects": [
      {
        "uri": "configuration/entityTypes/Organization",
        "label": "Organization",
        "filter": "equals(configuration/entityTypes/Organization/attributes/SyncFlag, true)",
        "fieldMappings": [
          {
            "reltioAttributes": [
              {
                "uri": "configuration/entityTypes/Organization/attributes/FirstName",
                "label": "First Name"
              },
              {
                "uri": "configuration/entityTypes/Organization/attributes/LastName",
                "label": "Last Name"
              }
            ],
            "isExpression": true,
            "expression": "=source(FirstName).concat(LastName)",
            "sfdcAttribute": {
              "name": "Name",
              "label": "Name"
            }
          }
        ]
      }
    ],
    "childrenSFDCObjects": [
      {
        "sfdcObject": {
          "name": "Address_vv__c",
          "label": "Veeva Address",
          "recordType": {
            "id": "XXJSDLFKJ323333",
            "label": "Billing"
          }
        },
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Address",
            "label": "Address",
            "fieldMappings": [
              {
                "reltioAttributes": [
                  {
                    "uri": "configuration/entityTypes/Organization/attributes/Address/Street",
                    "label": "Street"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "sfdcAttribute": {
                  "name": "Street__c",
                  "label": "Street"
                }
              }
            ],
            "reltioObjects": [
            ]
          }
        ]
      },
      {
        "sfdcObject": {
          "name": "Address_vv__c",
          "label": "Veeva Address",
          "recordType": {
            "id": "LLLLKK0008888",
            "label": "Shipping"
          }
        },
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Address",
            "label": "Address",
            "fieldMappings": [
              {
                "reltioAttributes": [
                  {
                    "uri": "configuration/entityTypes/Organization/attributes/Address/Street",
                    "label": "Street"
                  }
                ],
                "isExpression": false,
                "expression": "",
                "sfdcAttribute": {
                  "name": "Street__c",
                  "label": "Street"
                }
              }
            ],
            "reltioObjects": [
            ]
          }
        ]
      }
    ]
  }
}