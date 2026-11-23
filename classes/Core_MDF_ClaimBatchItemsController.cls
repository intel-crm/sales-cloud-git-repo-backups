public class Core_MDF_ClaimBatchItemsController {
    @AuraEnabled
    public static list<Core_MDF_Claim_Batch_Stage__c> getRelatedStageRecordList(Id recordId)
    {
        List<Core_MDF_Claim_Batch_Stage__c> claimStagerecordlist = [Select id,Core_MDF_Claim_Nm__c,Name,Core_MDF_Activity_Nbr__c, Core_MDF_Message_txt__c,Core_MDF_Ad_Run_Start_Dt__c, Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Upload_POP_Document__c from Core_MDF_Claim_Batch_Stage__c  where Core_MDF_Batch_ID__c=: recordId ];
        return claimStagerecordlist;
    }
    @AuraEnabled
    public static void updateRelatedStageRecordList(List<Core_MDF_Claim_Batch_Stage__c> StageList)
    {
        if(StageList!= null && StageList.size()>0)
        {
            update StageList;
        }
    }
    /****************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of claim and activity recordtype 
@parameters:        N/A
Description:        This method is used to fetch record type meta data and create a map
Added By:           Accenture - 
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> fetchRecordTypeMetaData(){
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Claim_Activity_Name_Swap_Ind__c,Core_MDF_POP_Mandatory_Ind__c,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Claim_RecordType_txt__c,recTypeMetaData);
                                                                       }
        return mapOfRecordTypes;
    }
    
}