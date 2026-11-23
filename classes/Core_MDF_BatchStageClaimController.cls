/******************************************************************************************************
* Class Name  : Core_MDF_BatchStageClaimController 
* Version     : 1.0 
* Created Date: 10-30-2019
* Modification Log :
* Developer  AD          Date               Description : This class is called from Batch Stage Create Claim lightning component
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public with sharing class Core_MDF_BatchStageClaimController {
/****************************************************************************************************** 
Method Name:        fetchClaimRecordType
@return  :          <String> record type developer name
@parameters:        <String> stage claim record ID
Description:        This method is used to fetch activity record type by passing stage claim record ID
Added By:           Accenture - AD - 10/30/2019
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static String fetchClaimRecordType(Id stageClaimRecordId){
        //To fetch record type metadata
        Map<String,String> mapOfActToClaimRecordType = fetchRecordTypeMetaData();
        //To hold activity record type dev name
        String claimRecordTypeDevName;
        //To hold pfr record
        PartnerFundRequest pfrRecord = null;
        //query exisitng stage claim record
        Core_MDF_Claim_Batch_Stage__c claimStageRecord =
            [SELECT Id,Core_MDF_Activity_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE Id =: stageClaimRecordId];
        if(claimStageRecord!=null && 
           claimStageRecord.Core_MDF_Activity_Nbr__c!=null){
               //query exisitng pfr record
               pfrRecord = [SELECT Id,RecordType.DeveloperName FROM PartnerFundRequest WHERE Core_MDF_Activity_Number__c =: claimStageRecord.Core_MDF_Activity_Nbr__c];
               if(pfrRecord!=null && pfrRecord.RecordType.DeveloperName!=null){
                   claimRecordTypeDevName = mapOfActToClaimRecordType.containsKey(pfrRecord.RecordType.DeveloperName) ?
                       mapOfActToClaimRecordType.get(pfrRecord.RecordType.DeveloperName) : null;
               }
           }
        return claimRecordTypeDevName;
    }
    
/****************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of activity and claim recordtype 
@parameters:        N/A
Description:        This method is used to fetch record type meta data and create a map
Added By:           Accenture - AD - 10/31/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static Map<String,String> fetchRecordTypeMetaData(){
        Map<String,String> mapOfRecordTypes = new Map<String,String>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Activity_RecordType_txt__c,recTypeMetaData.Core_MDF_Claim_RecordType_txt__c);  
                                                                       }
        return mapOfRecordTypes;   
    }    
}