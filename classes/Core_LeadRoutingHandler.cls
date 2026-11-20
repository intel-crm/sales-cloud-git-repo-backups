/********************************************************************************************************************
Apex Class Name:  Core_LeadRoutingHandler  
Version      : 1.0 
Created Date : 11/19/21
Function     : Class to handle new Lead routing logic.
Modification Log :
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Sanket Mahajan               11/19/2021            
*******************************************************************************************************************/

public without sharing class Core_LeadRoutingHandler{
    
    /*
    * Method name  : reprocessLeadRouting
    * Description  : reprocess lead sharing on insert of junction object 
    * Return Type  : void
    * Parameter    : List<PMP_OPID_MPI_Rel__c> newList
    */
    public static void reprocessLeadRoutingOnInsert(List<PMP_OPID_MPI_Rel__c> newList){
        Set<id> mpIdSet = new Set<id>();
        for(PMP_OPID_MPI_Rel__c opmp: newList){
            if(opmp.Is_Active__c){
                mpIdSet.add(opmp.PMP_Marketing_Profile_Id__c);
            }
        }
        if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
            if(!System.isBatch()){
                callBatch(mpIdSet);
            }else{
                Core_Batch_ReprocessLeadShare.reprocessLeadShareUtility();
            }
        }
    }
    
    /*
    * Method name  : reprocessLeadRoutingonUpdate
    * Description  : reprocess lead sharing on update of junction object
    * Return Type  : void
    * Parameter    : List<PMP_OPID_MPI_Rel__c> newList,Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList
    */
    public static void reprocessLeadRoutingOnUpdate(List<PMP_OPID_MPI_Rel__c> newList,Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList){
        Set<id> mpIdSet = new Set<id>();
       // Set<String> opIdSet = new Set<String>();
        for(PMP_OPID_MPI_Rel__c opmp: newList){
            if(opmp.Is_Active__c <> oldMapOPIDList.get(opmp.id).Is_Active__c){
                mpIdSet.add(opmp.PMP_Marketing_Profile_Id__c);
            }
        }
        if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
            if(!System.isBatch()){
                callBatch(mpIdSet);
            }else{
                Core_Batch_ReprocessLeadShare.reprocessLeadShareUtility();
            }
        }
        
        
    }
    /*
    * Method name  : reprocessLeadRoutingonDelete
    * Description  : reprocess lead sharing on delete of junction object
    * Return Type  : void
    * Parameter    : List<PMP_OPID_MPI_Rel__c> newList,Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList
    */
    /*public static void reprocessLeadRoutingOnDelete(Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList){
        Set<id> mpIdSet = new Set<id>();
        try{
        	List<PMP_OPID_MPI_Rel__c> opmpList = [Select id,PMP_Marketing_Profile_Id__c,Core_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where id in:oldMapOPIDList.keySet()];
            for(PMP_OPID_MPI_Rel__c opmp: opmpList){
            //if(opmp.PMP_Marketing_Profile_Id__c != ''){
            	mpIdSet.add(opmp.PMP_Marketing_Profile_Id__c);
            //}
        	}
        	if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
        		callBatch(mpIdSet);
        	}
        }catch(Exception e){
        	Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_LeadRoutingHandler', Core_Method_Name__c = 'reprocessLeadRoutingOnDelete', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Login_User_Id__c= userInfo.getUserId());
        	insert ExcepLog;
        }
	}*/
    
    public static void callBatch(Set<id> mpIdSet){
        database.executeBatch(new Core_Batch_ReprocessLeadShare(mpIdSet),100);
    }
}