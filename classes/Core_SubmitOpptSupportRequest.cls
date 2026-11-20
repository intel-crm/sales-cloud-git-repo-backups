/**************************************************************************************
Apex Class Name:  Core_SubmitOpptSupportRequest
Version     : 1.0 
Created Date: 13 Apr 2023
Function    : 
Test Class Name: Core_OpptySupportServiceHandlerTest
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areefa Banu             13/04/2023              Original Version
* 
*************************************************************************************/
public without sharing class Core_SubmitOpptSupportRequest { //TWC3123-5376: code scan fix
   

    @AuraEnabled(cacheable=true)
    public static boolean submitApproval(String opptSuppReqId){
        List<Core_Opportunity_Support__c> opptSuppReq=  new List<Core_Opportunity_Support__c>();
        boolean isThereAnOpenOpptSupportReq = false; 
        try{
            // from opptid,check for submitted status record. if present/Not send  falg(pass to lwc)
            if(opptSuppReqId != null)  {          
                opptSuppReq = [select Opportunity__r.Id,RecordType.DeveloperName from Core_Opportunity_Support__c where id=:opptSuppReqId];
               
                opptSuppReq = [Select Id from Core_Opportunity_Support__c where RecordType.DeveloperName = 'Core_CSA_RecordType' and Core_Status__c='Submitted' and Opportunity__c =:opptSuppReq[0].Opportunity__r.Id and RecordTypeId=: opptSuppReq[0].RecordTypeId limit 1];
                if(opptSuppReq.size()>0){
                    isThereAnOpenOpptSupportReq=true;                    
                } 
            }
           
        }catch (Exception e) { Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = '@Failure:'+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_SubmitOpptSupportRequest',Core_Method_Name__c ='submitApproval'); }
        return isThereAnOpenOpptSupportReq;
    }
    
}