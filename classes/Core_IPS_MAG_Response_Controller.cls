public with sharing class Core_IPS_MAG_Response_Controller {
    public Core_IPS_MAG_Response_Controller() {

    }

    public class CustomCase{
        @AuraEnabled public String question {get; set;}
        @AuraEnabled public String answer {get; set;}
        @AuraEnabled public String lastModifiedBy {get; set;}
        @AuraEnabled public Datetime createdDate {get; set;}
        @AuraEnabled public Id lastModifiedById {get; set;}
    }

    @AuraEnabled (cacheable=true)
    public static List<CustomCase> fetchCaseData(Id recordID){

        //List<Case>  = [Select GEC_Details__r from Case];
        //List<Case> responce = [Select GEC_Details__r, Core_IPS_Responses__r  from Case];


        List<Case> responce = [Select 
                                    (
                                        Select 
                                            Core_IPS_GEC_Question1__c,
                                            Core_IPS_GEC_Question2__c,
                                            LastModifiedById,
                                            LastModifiedBy.Name,
                                            CreatedDate from GEC_Details__r
                                    ),

                                    (
                                        Select 
                                            Core_IPS_Question_Master__r.RecordType.DeveloperName,
                                            Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c,
                                            Core_IPS_Answer__c,
                                            Core_IPS_Question__c,
                                            LastModifiedById,
                                            LastModifiedBy.Name,
                                            CreatedDate from Core_IPS_Responses__r
                                    )

                                    from Case where Id =: recordID];

        List<CustomCase> customCaseObj = new List<CustomCase>();

        if(responce.size() > 0){

            for(Case s: responce){
                CustomCase customObj = new CustomCase();

                if(s.GEC_Details__r.size() > 0){
                    for(Core_IPS_GEC_Details__c gecObj: s.GEC_Details__r){
                        customObj.question = gecObj.Core_IPS_GEC_Question1__c;
                        customObj.answer = gecObj.Core_IPS_GEC_Question2__c;
                        customObj.lastModifiedById = gecObj.LastModifiedById;
                        customObj.createdDate = gecObj.CreatedDate;
                        customObj.lastModifiedBy = gecObj.LastModifiedBy.Name;
                    }

                }else{
                    for(Core_IPS_Response__c gecObj: s.Core_IPS_Responses__r){
                        if(!(gecObj.Core_IPS_Question_Master__r.RecordType.DeveloperName=='Core_IPS_MAG_Question' && gecObj.Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c==null) || (gecObj.Core_IPS_Answer__c != null && gecObj.Core_IPS_Question_Master__r.RecordType.DeveloperName=='Core_IPS_MAG_Question' && gecObj.Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c!=null)){
                        
                            customObj.question = gecObj.Core_IPS_Question__c;
                            customObj.answer = gecObj.Core_IPS_Answer__c;
                            customObj.lastModifiedById = gecObj.LastModifiedById;
                            customObj.createdDate = gecObj.CreatedDate;
                            customObj.lastModifiedBy = gecObj.LastModifiedBy.Name;
                        }
                    }
                }
                customCaseObj.add(customObj);
            }
        }
        return customCaseObj;
    }
}