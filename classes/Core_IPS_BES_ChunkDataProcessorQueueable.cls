/***************************************************************************************************
   Created Date: 29 Nov 2024
    Class Name : Core_IPS_BES_ChunkDataProcessorQueueable
    Description: This class is used to process chunk data in the new bridge outbound flow to reduce the limit exceptions (heap size,callout).This class
				 is called from Core_IPS_BES_JSONTriggerHandler class.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Pavani                    11/29/2024              Created  TWC745-7219
****************************************************************************************************/  
public without sharing class Core_IPS_BES_ChunkDataProcessorQueueable implements Queueable,Database.AllowsCallouts {
    List<Id> recordIdList = new List<Id>();
    
    public Core_IPS_BES_ChunkDataProcessorQueueable(List<Id> recordIdList) {
        System.debug('BES IPS-HSD Core_IPS_BES_ChunkDataProcessorQueueable 1: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
        this.recordIdList = recordIdList;
    }
	public void execute(QueueableContext qc) {
        try{
            System.debug('BES IPS-HSD Core_IPS_BES_ChunkDataProcessorQueueable 2 Execute: '+ Limits.getLimitHeapSize() + '--'+ Limits.getHeapSize());
        	//Core_IPS_BES_JSONTriggerHandler jsonCls = new Core_IPS_BES_JSONTriggerHandler();
        	Core_IPS_BES_JSONTriggerHandler.getJson(recordIdList);
        }
        catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(recordIdList,','));
        }
    }


}