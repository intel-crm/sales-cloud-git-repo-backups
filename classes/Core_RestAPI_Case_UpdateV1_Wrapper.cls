/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Case_CreateV1_Wrapper 
* Version     : 1.0 
* Created Date: 3/7/2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         3/7/2018              RestAPI Wrapper class for update case api request
*****************************************************************************************************************************************/

global class Core_RestAPI_Case_UpdateV1_Wrapper extends Core_RestAPI_Request {
    
    //optional, mapping : Case.status
    public String status {get;set;}
    
    //Required, mapping : Case.Subject
    public String subject {get;set;}
    //Required, mapping : Case.Description
    public String caseDescription {get;set;}
    //Required, mapping : Case.Core_CaseType__c (PickList)
    public String caseType {get;set;}
    //Required, mapping : Case.Core_Severity__c (Picklist)
    public String caseSeverity {get;set;}
    //Required, mapping : Case.Core_Severity_Reason__c
    public String severityReason {get;set;}
    //Optional, mapping : Case.Core_Customer_Reference_ID__c
    public String customerReferenceId {get;set;}
    //Required, mapping : Case.Core_End_Customer__c
    public String endCustomer {get;set;}
    //Optional, mapping : Case.Contact.id
    //public String contactId{get;set;}
    
    public String caseCategoryId{get;set;}
    public String subCategoryId{get;set;}
    
    //CHANGE START
    public List<EnvQuestionWrapper> envDetails{set;get;}
    
    //Wrapper for Environment Questions
    public class EnvQuestionWrapper { 
        
        //mapping: Core_Question__c
        public String envDetQuestion{get;set;}
        //mapping: Auto generated number
        public String envDetQuestionId{get;set;}
        //mapping : List of another wrapper
        public List<AnsWrapper> answers{get;set;}
        
    }
    //Wrapper for answers
    public class AnsWrapper{ 
        //mapping: Core_Answer__c 
        public String answer{get;set;}
        public String answerId{get;set;}
        public List<EnvQuestionWrapper> dependentEnvDetails {get;set;}
    } 
    //CHANGE END
    
    
} 
/*
 SAMPLE REQUEST

{
  "updateCase": {
     "SeverityReason": null,
    "endCustomer": null,
    "customerReferenceId": null,
    "caseType": "Question",
    "subject": "Case create api testing",
    "caseSeverity": "Low",
    "caseDescription": "API testing ",
    "caseCategory": "Devices",
    "caseSubCategory": "Power"
    
    "envDetails" :[
    {
    
    "environmentDetailQuestion" : "Test question2",
     "answers" : [ {
        "answer" : "B2B test Picklist1"
      }, {
        "answer" : "B2B test Picklist2"
      }, {
        "answer" : "B2B test Picklist3"
      }, {
        "answer" : "B2B test Picklist4"
      }, {
        "answer" : "B2B test Picklist5"
      } ]
      }
    ]
    //end
  }
}
*/