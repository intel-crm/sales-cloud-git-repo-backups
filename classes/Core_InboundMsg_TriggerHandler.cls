/***************************************************************************************************
Handler class -Core_OnePartner_Inbound_Message -Trigger
Update status of OPID Sync Request Object based on the inbound SF records status as Success/Failed
******************************************************************************************************/
public without sharing class Core_InboundMsg_TriggerHandler {
            
    public static void updateOnDemandSyncRecords(Set<Id>onDemandSyncRecIds){
        Integer totalRecsCount=0;
        List<OPID_Sync_Request__c> opidsyncRecstoUpdateList = new List<OPID_Sync_Request__c>();
		List<OPID_Sync_Request__c> opidSyncwithCIMRecsList = [SELECT Id, Status__c,(SELECT Id,Core_Status__c,Error_Description__c FROM One_Partner_Inbound_Messages__r) FROM OPID_Sync_Request__c WHERE Id IN: onDemandSyncRecIds];        
        
        for(OPID_Sync_Request__c opsync:opidSyncwithCIMRecsList){
            for(Core_OnePartner_Inbound_Message__c cim: opsync.One_Partner_Inbound_Messages__r){
                //If all the inbound SF records status is Processed
                if(cim.Core_Status__c == System.label.PRM_INBOUNDMSG_PROCESSED){//Processed
                	totalRecsCount++;
            	}
                //If any one of the inbound record is in failed/discarded, we are setting the status as Failed
                else if(cim.Core_Status__c != System.label.PRM_INBOUNDMSG_PROCESSED && cim.Error_Description__c != null){
                    opsync.Status__c = 'Failed';
                    opidsyncRecstoUpdateList.add(opsync);
                }
            }
            //totalRecsCound will match the associated child record size if all inbound recs staus is processed
            if(totalRecsCount == opsync.One_Partner_Inbound_Messages__r.size()){
                opsync.Status__c = 'Success';
                opidsyncRecstoUpdateList.add(opsync);
            }
        }
        if(!opidsyncRecstoUpdateList.isEmpty()){
            update opidsyncRecstoUpdateList;
        }
    }
    /**
        *  @description      : incase of lock row issue reset the inbound to get processed by batch again 
        *  @name             : retryInboundProcessing
        *  @param            : List<Core_OnePartner_Inbound_Message__c> inbndNewList
        *  @throws exception : NONE
        * @userstory         : TWC729-7912
    **/
    public static void retryInboundProcessing(List<Core_OnePartner_Inbound_Message__c> inbndNewList){
        List<Core_OnePartner_Inbound_Message__c> inbndToUpdate = new List<Core_OnePartner_Inbound_Message__c>();
        String errorMsg='';
        for(Core_OnePartner_Inbound_Message__c inbnd:inbndNewList){
            //if the inbound has failed with lock row issue then the mechanism will reset the record maximum 2 times so next batch can process them
            if(inbnd.Core_Status__c.equals(System.label.PRM_INBOUNDMSG_PROCESS_FAILED) && inbnd.Error_Description__c.contains('UNABLE_TO_LOCK_ROW') && inbnd.PRM_Retry_Counter__c<3){
                Core_OnePartner_Inbound_Message__c inbound = new Core_OnePartner_Inbound_Message__c();
                inbound.id = inbnd.id;
                inbound.Core_Status__c='NEW';
                inbound.Error_Description__c='';
                inbound.PRM_Retry_Counter__c= inbnd.PRM_Retry_Counter__c+1;
                inbndToUpdate.add(inbound);
            }
        }
        if(!inbndToUpdate.isEmpty()){
            try{
                Database.SaveResult[] srList = Database.update(inbndToUpdate, false);
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg +=err.getMessage()+' ';
                        } 
                        errorMsg+= '\n';
                    }
                }
            }catch(Exception ex){
                errorMsg+=ex.getMessage();   
            }finally{
                Core_Log_Entry.logEntryWithDetails('OPID Inbound Batch','IPA','OPID Inbound Batch','Error','',errorMsg ,'', '', '');
            }
        }
    }

}