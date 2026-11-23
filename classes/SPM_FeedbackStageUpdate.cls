/**************************************************************************************
Apex Class Name:  SPM_FeedbackStageUpdate
Version     : 1.0 
Created Date: 27 Oct 2023
Function    : Update the Customer and Account feedback based on the regional view 
Test Class Name: CST_CreateFeedbackTest
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay					  27/10/2023			  Queried Version
*************************************************************************************/

public without sharing class SPM_FeedbackStageUpdate implements Database.Batchable<SObject>, Database.Stateful {
    private String objectName;
    private String queryString;
    private Map<id,SPM_Regional_Customer__c> regionStageUpdate;
    private string errorMessage = '';
    
    public SPM_FeedbackStageUpdate(String objectName, String queryString,Map<id,SPM_Regional_Customer__c> regionStageUpdate) {
        this.objectName = objectName;
        this.queryString = queryString;
        this.regionStageUpdate = regionStageUpdate;
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        List<Id> regionalId = new List<Id>();
        regionalId.addAll(regionStageUpdate.keySet());
        String soqlQuery = queryString ;
        return Database.getQueryLocator(soqlQuery);
    }
    
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        
        List<SPM_Customer_Feedback__c> customerDataStageUpdate = new List<SPM_Customer_Feedback__c>();
        try{ 
            for (SObject record : scope) {
                
                if(objectName == 'SPM_Customer_Feedback__c'){
                    
                    SPM_Customer_Feedback__c custFeedback = new SPM_Customer_Feedback__c();
                    custFeedback = (SPM_Customer_Feedback__c)record;
                    string stage = regionStageUpdate.get(custFeedback.Customer_ID__r.Core_Regional_Customer_Id__c).stage__c;                
                    
                    custFeedback.Feedback_Type__c = stage;
                    customerDataStageUpdate.add(custFeedback);
                }
                
            }
            
          
            if(objectName == 'SPM_Customer_Feedback__c' && customerDataStageUpdate.size() > 0)
                update customerDataStageUpdate;
            
        } catch (Exception e) {
            errorMessage = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage();
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='SPM_FeedbackStageUpdate',Core_Method_Name__c ='Bacth execute',Core_IPS_Object_Name__c = 'SPM_Account_Feedback__c && SPM_Customer_Feedback__c');
            insert excep;
        }
    }
    
    public void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> toAddresses = Core_CRM_Utility.getCRMLabel('CST_Error_Email').split(';');
        email.setToAddresses(toAddresses);
        if(errorMessage != '' && errorMessage != null )
            email.setSubject(' Error Occurred While updating Feedback records '+objectName);
        else 
            email.setSubject('Feedback records updated succesfully '+objectName);    
        
        email.setPlainTextBody(errorMessage);  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}