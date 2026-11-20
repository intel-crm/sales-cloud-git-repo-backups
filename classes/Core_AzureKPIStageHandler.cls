/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_AzureKPIStageHandler 
Version     : 1.0 
Created Date: 15 JUNE 2022
Function    : Utility methods to handle Delta Load
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             06/15/2022              Original Version

*****************************************************************************************************************************************************************************************************/

public class Core_AzureKPIStageHandler {
    public static integer KPIDeltaLoadCount = 1;
    
    /*
    * Method name  : updateOldStageRecords
    * Description  : 
    * Return Type  : VOID
    * Parameter    : List<Core_KPI_Staging__c> newList
    */
    
    public static void updateOldStageRecords(List<Core_KPI_Staging__c> newList,List<Core_KPI_Staging__c> oldList) {
        set<id> oppIdSet = new set<id>();
        set<id> oppIdFailedSet = new set<id>();
        
        if(KPIDeltaLoadCount == 1){
            for(Core_KPI_Staging__c ks : newList){
                if(ks.Core_Status__c == 'Success' && ks.Core_End_Of_File__c && ks.Core_Refresh_Type__c == 'Incremental'){
                
                    //batchIdSet.add(ks.Core_Batch_ID__c);
                    oppIdSet.add(ks.Core_Opportunity_ID_Txt__c);
                }
                /*if(ks.Core_End_Of_File__c && ks.Core_Status__c !='Success' && ks.Core_Refresh_Type__c == 'Incremental'){
                    system.debug('Batch id new'+ks.Core_Batch_ID__c);
                    oppIdFailedSet.add(ks.Core_Opportunity_ID_Txt__c);
                }*/
            }
            
            if(oppIdSet.size()>0 ){
                System.enqueueJob(new Core_UpdateStatusQueue(oppIdSet));
            }
            
        }
        else if(KPIDeltaLoadCount == 0){
            KPIDeltaLoadCount++;
        }
    }
}