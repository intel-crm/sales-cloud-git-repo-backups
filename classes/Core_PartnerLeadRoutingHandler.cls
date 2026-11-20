/********************************************************************************************************************
Apex Class Name:  Core_PartnerLeadRoutingHandler  
Version      : 1.0 
Created Date : 05/26/22
Function     : Class to handle new Lead routing logic.
Modification Log :
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Megha Kumari              05/26/22            
*******************************************************************************************************************/
public without sharing class Core_PartnerLeadRoutingHandler {
    /*
* Method name  : reprocessLeadRouting
* Description  : reprocess lead sharing on insert of junction object 
* Return Type  : void
* Parameter    : List<Core_Partner_Queue_Mapping__c> newList
*/
    public static void reprocessLeadRoutingOnInsert(List<Core_Partner_Queue_Mapping__c> newList){
        
        Set<String> mpIdSet = new Set<String>();
        String partnerRecTypeId = Schema.SObjectType.Core_Partner_Queue_Mapping__c.getRecordTypeInfosByName().get(Label.Core_Partner_Queue_Mapping_RecordTypeId).getRecordTypeId();
        
        for(Core_Partner_Queue_Mapping__c opmp: newList){
            
            if(opmp.Core_Active__c && opmp.PMP_MDA_BizOrg_Id__c!='' && opmp.PMP_MDA_BizOrg_Id__c !=null && opmp.RecordTypeId==partnerRecTypeId){
                
                mpIdSet.add(opmp.Core_Partner_Name__c);
            }
        }
        
        if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
            callBatch();
        }
    }
    /*
* Method name  : reprocessLeadRoutingonUpdate
* Description  : reprocess lead sharing on update of junction object
* Return Type  : void
* Parameter    : List<Core_Partner_Queue_Mapping__c> newList,Map<Id, Core_Partner_Queue_Mapping__c> oldMapOPIDList
*/
    public static void reprocessLeadRoutingOnUpdate(List<Core_Partner_Queue_Mapping__c> newList,Map<Id, Core_Partner_Queue_Mapping__c> oldMapOPIDList){
        
        Set<String> mpIdSet = new Set<String>();
       // Set<String> opIdSet = new Set<String>();
        String partnerRecTypeId = Schema.SObjectType.Core_Partner_Queue_Mapping__c.getRecordTypeInfosByName().get(Label.Core_Partner_Queue_Mapping_RecordTypeId).getRecordTypeId();
        
        for(Core_Partner_Queue_Mapping__c opmp: newList){
            if(opmp.RecordTypeId==partnerRecTypeId){
                mpIdSet.add(opmp.Core_Partner_Name__c);
            }
            
            
        }
        
        if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
            callBatch();
        }
        
        
    }
    public static void callBatch(){
        
        List<Lead> leadList = [SELECT id,Core_Remove_Current_Sharing_Ind__c, Core_Reprocess_Lead_Sharing__c from LEAD where OwnerId =:label.Core_Partner_Invalid_Queue_Id and RecordType.DeveloperName = 'Partner_Lead' limit 1];
        
        if(leadList.size()>0){
            database.executeBatch(new Core_Batch_ReprocessPartnerLeadShare(),Integer.valueOf(Label.Core_Reprocess_Batch_Size));
        }
    }
    
    Public Static void updateStoreFront(List<Core_Partner_Queue_Mapping__c> newList){
        
        Set<Id> bizOrgId = new Set<Id>();
        List<Core_Partner_Queue_Mapping__c> newQueueMap = new List<Core_Partner_Queue_Mapping__c>([select id,PMP_MDA_BizOrg_Id__c,Core_Storefront_Id__c,
                                                                                                   name,Core_Storefront_Name__c from Core_Partner_Queue_Mapping__c where id =: newList]);
        
        Map<String,Core_Partner_Queue_Mapping__c> queMap= new Map<String,Core_Partner_Queue_Mapping__c> ();
        for(Core_Partner_Queue_Mapping__c opmp: newQueueMap){
            bizOrgId.add(opmp.PMP_MDA_BizOrg_Id__c);  
            queMap.put(opmp.PMP_MDA_BizOrg_Id__c,opmp);
        }  
        
        
        if( bizOrgId.size()>0 && !bizOrgId.isEmpty())
            updateStoreFrontIdandName( bizOrgId, queMap);    
    }
    
    Public static void updateStoreFrontIdandName(Set<Id> account, Map<String,Core_Partner_Queue_Mapping__c> newList){
        try{
            List<PMP_OPID_MPI_Rel__c> opId = new List<PMP_OPID_MPI_Rel__c> ([Select id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c,Is_Active__c, 
                                                                             PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.id from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c In: account and Is_Active__c=: true]);
            
            //Map<String,PMP_OPID_MPI_Rel__c> opidRelMap= new Map<String,PMP_OPID_MPI_Rel__c>();
            List<Core_Partner_Queue_Mapping__c> partnerQueueUpdate = new List<Core_Partner_Queue_Mapping__c>();
            if(opId.size()>0 && !opId.isEmpty()){
                for(PMP_OPID_MPI_Rel__c opIdupdate : opId)
                {
                    if(newList.keySet().contains(opIdupdate.PMP_One_Partner_ID__c)){
                        Core_Partner_Queue_Mapping__c queMap= newList.get(opIdupdate.PMP_One_Partner_ID__c);
                        queMap.Core_Storefront_Id__c=(String)opIdupdate.PMP_Marketing_Profile_Id__r.Id;
                        queMap.Core_Storefront_Name__c=opIdupdate.PMP_Marketing_Profile_Id__r.Name;
                        partnerQueueUpdate.add(queMap);
                        
                    } 
                    
                }
            }
            
            if(partnerQueueUpdate.size()>0 && !partnerQueueUpdate.isEmpty())
                update  partnerQueueUpdate;
        }
        Catch(Exception e){
            Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_PatnerLead_StoreFrontIdName', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Login_User_Id__c= userInfo.getUserId());
            insert ExcepLog;
        }
    }
}