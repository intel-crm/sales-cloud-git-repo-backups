{
  "mappings": [
    {
      "name": "Business Account Mapping",
      "sbcOnly": false,
      "sfdcObject": {
        "name": "Account",
        "label": "Account",
        "recordType": {
          "id": "a062p00001tuvFs",
          "label": "Business Account"
        },
        "childrenMappings": [
          {
            "sfdcObject": {
              "name": "Address_vv__c",
              "label": "Veeva Address",
              "recordType": {
                "id": "a062p00001tuvFd",
                "label": "Shipping"
              }
            },
            "reltioObjects": [
              {
                "uri": "configuration/entityTypes/Organization/attributes/Address",
                "label": "Address",
                "reltioObjects": [
                ]
              }
            ]
          }
        ]
      },
      "reltioObject": {
        "uri": "configuration/entityTypes/Organization",
        "label": "Organization",
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Phone",
            "label": "Phone",
            "reltioObjects": [
            ]
          }
        ]
      }
    },
    {
      "name": "Person Account Mapping",
      "sbcOnly": true,
      "sfdcObject": {
        "name": "Account",
        "label": "Account",
        "recordType": {
          "id": "a062p00001tuvFf",
          "label": "Person Account"
        },
        "childrenMappings": [
          {
            "sfdcObject": {
              "name": "Address_vv__c",
              "label": "Veeva Address",
              "recordType": {
                "id": "a062p00001tuvFg",
                "label": "Shipping"
              }
            },
            "reltioObjects": [
              {
                "uri": "configuration/entityTypes/Organization/attributes/Address",
                "label": "Address",
                "reltioObjects": [
                ]
              }
            ]
          }
        ]
      },
      "reltioObject": {
        "uri": "configuration/entityTypes/Organization",
        "label": "Organization",
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Phone",
            "label": "Phone",
            "reltioObjects": [
            ]
          }
        ]
      }
    },
    {
      "name": "SBC mapping Organization - Account",
      "sbcOnly": true,
      "sfdcObject": {
        "name": "Account",
        "label": "Account",
        "childrenMappings": []
      },
      "reltioObject": {
        "uri": "configuration/entityTypes/Organization",
        "label": "Organization",
        "reltioObjects": [
          {
            "uri": "configuration/entityTypes/Organization/attributes/Address",
            "label": "Address",
            "reltioObjects": []
          }
        ]
      }
    }
  ]
}