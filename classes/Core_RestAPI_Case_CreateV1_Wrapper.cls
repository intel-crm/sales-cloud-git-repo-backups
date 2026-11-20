/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Case_CreateV1_Wrapper 
* Version     : 1.0 
* Created Date: 18 Jan 2018
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/20/2018              RestAPI Wrapper class for create case api request
*****************************************************************************************************************************************/

global class Core_RestAPI_Case_CreateV1_Wrapper extends Core_RestAPI_Request {
    
    //Required and mapping to Case.Core_IPS_Project_Case__c
    //public String ipsProjectId {get;set;}
    //Required mapping : Case.assetId   
    public String intelProductId {get;set;}
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
    public Boolean customerVisible = true;
    
    public String caseCategoryId{get;set;}
    public String subCategoryId{get;set;}
    
    //CHANGE START
    public List<EnvQuestionWrapper> envDetails{set;get;}
    
    //Wrapper for Environment Questions
    public class EnvQuestionWrapper{ 
        
        //mapping: Core_Question__c
        public String envDetQuestion{get;set;}
        //mapping: Auto generated number
        public String envDetQuestionId{get;set;}
        //mapping: Auto generated number
    //    public String envDetParentQuestionId{get;set;}
        //mapping : List of another wrapper
        public List<AnsWrapper> answers{get;set;}
        
    }
    //Wrapper for answers
    public class AnsWrapper{ 
        //mapping: Core_Answer__c 
        public String answer{get;set;}
        public String answerId{get;set;}
       // public List<EnvQuestionWrapper> subQuestion{get;set;}
    } 
    //CHANGE END
    
    
} 
/*
 SAMPLE REQUEST

{
  "newCase": {
     "SeverityReason": null,
    "intelProductAssetId": "02i3F000002KJyg",
    "ipsProjectId": "",
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