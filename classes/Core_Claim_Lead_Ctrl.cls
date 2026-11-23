/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Claim_Lead_Ctrl
Version     : 1.0 
Created Date: 22 November 2018
Function    : Apex class for Claim button to change the ownership of record to loggrdin user on click of claim button
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            22/11/2018              Original Version
--------------------------------------------------------------------------------------------*/

public without sharing class Core_Claim_Lead_Ctrl {
    
    @auraEnabled
    public static String verifyOwner(String leadId){
        String loggedInUserId = UserInfo.getUserId();
        String alertMsg;
        Lead leadRecord = [select Id,Recordtype.Name,OwnerId,Status,Core_Lead_State__c, Core_Rejection_Comments__c, Core_Rejection__c,
                           Core_Partner_Lead_Owner__c from Lead where Id =: leadId];
        String SalesleadID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
        String PartnerLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        
        If (leadRecord.RecordtypeId == PartnerLeadId){
            leadRecord.Core_Partner_Lead_Owner__c = UserInfo.getUserId();
            alertMsg=System.Label.Core_Lead_Claimed;
        }
        //If the lead is Sales record type
        If (leadRecord.RecordtypeId != PartnerLeadId){
            
            if(loggedInUserId.equalsIgnoreCase(leadRecord.OwnerId)){
                alertMsg='You are already an owner of this lead';
            }else{
                leadRecord.OwnerId = loggedInUserId;
                alertMsg=System.Label.Core_Lead_Claimed;
                
            }
        }
        try{
            update leadRecord;
        }catch(DmlException de){
            alertMsg = '';
            Integer numErrors = de.getNumDml();
            for(Integer i=0;i<numErrors;i++) {
                System.debug('getDmlMessage=' + de.getDmlMessage(i));
                alertMsg += de.getDmlMessage(i);
                if(i < numErrors-1){
                    alertMsg += ';';
                }
            }
        }
        return alertMsg;
    }
    
    @auraEnabled
    public static Lead validateLeadRecord(String leadRecordId){
        String partnerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        Lead leadRecord = [select Id, Core_Lead_State__c, Core_Lead_Status__c, Status, RecordTypeId from Lead where Id =: leadRecordId AND RecordTypeId =: partnerRecTypeId];
        return leadRecord;
    }
}