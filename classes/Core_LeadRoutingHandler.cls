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

public class Core_LeadRoutingHandler{
    
    /*
    * Method name  : reprocessLeadRouting
    * Description  : reprocess lead sharing on insert of junction object 
    * Return Type  : void
    * Parameter    : List<PMP_OPID_MPI_Rel__c> newList
    */
    public static void reprocessLeadRoutingOnInsert(List<PMP_OPID_MPI_Rel__c> newList){
        system.debug('after insert newList-'+newList.size());
        Set<id> mpIdSet = new Set<id>();
        for(PMP_OPID_MPI_Rel__c opmp: newList){
            system.debug('opmp-'+opmp.PMP_Marketing_Profile_Id__c);
            if(opmp.Is_Active__c){
                mpIdSet.add(opmp.PMP_Marketing_Profile_Id__c);
            }
        }
        system.debug('mpIdSet-'+mpIdSet.size());
        if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
            callBatch(mpIdSet);
        }
    }
    
    /*
    * Method name  : reprocessLeadRoutingonUpdate
    * Description  : reprocess lead sharing on update of junction object
    * Return Type  : void
    * Parameter    : List<PMP_OPID_MPI_Rel__c> newList,Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList
    */
    public static void reprocessLeadRoutingOnUpdate(List<PMP_OPID_MPI_Rel__c> newList,Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList){
        system.debug('after update newList-'+newList.size());
        Set<id> mpIdSet = new Set<id>();
        Set<String> opIdSet = new Set<String>();
            for(PMP_OPID_MPI_Rel__c opmp: newList){
                if(opmp.Is_Active__c <> oldMapOPIDList.get(opmp.id).Is_Active__c){
                    system.debug('active');
                    mpIdSet.add(opmp.PMP_Marketing_Profile_Id__c);
                }
            }
            system.debug('mpIdSet-'+mpIdSet.size());
            if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
                callBatch(mpIdSet);
            }
        
    
    }
    /*
    * Method name  : reprocessLeadRoutingonDelete
    * Description  : reprocess lead sharing on delete of junction object
    * Return Type  : void
    * Parameter    : List<PMP_OPID_MPI_Rel__c> newList,Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList
    */
    /*public static void reprocessLeadRoutingOnDelete(Map<Id, PMP_OPID_MPI_Rel__c> oldMapOPIDList){
        system.debug('before delete'+oldMapOPIDList);
        Set<id> mpIdSet = new Set<id>();
        try{
            List<PMP_OPID_MPI_Rel__c> opmpList = [Select id,PMP_Marketing_Profile_Id__c,Core_Marketing_Profile_Id__c from PMP_OPID_MPI_Rel__c where id in:oldMapOPIDList.keySet()];
            for(PMP_OPID_MPI_Rel__c opmp: opmpList){
                //if(opmp.PMP_Marketing_Profile_Id__c != ''){
                    mpIdSet.add(opmp.PMP_Marketing_Profile_Id__c);
                //}
            }
            system.debug('mpIdSet-'+mpIdSet.size());
            if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
                callBatch(mpIdSet);
            }
        }
        Catch(Exception e){
            system.debug('**exception** -->'+ e);
            system.debug('line number-->'+e.getLineNumber());
            system.debug('msg-->'+e.getStackTraceString());
            Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_LeadRoutingHandler', Core_Method_Name__c = 'reprocessLeadRoutingOnDelete', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_Login_User_Id__c= userInfo.getUserId());
            insert ExcepLog;
        }
    }*/
    
    public static void callBatch(Set<id> mpIdSet){
        system.debug('mpIdSet-->'+mpIdSet);
        database.executeBatch(new Core_Batch_ReprocessLeadShare(mpIdSet));
    }
}