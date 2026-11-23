/******************************************************************************************************
* Class Name  : Core_MDF_Account_Sharing 
* Version     : 1.0 
* Created Date: 21-09-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AS      22/9/2020          Class for sharing accounts records based on geo
*******************************************************************************************************/
public without sharing class Core_MDF_Account_Sharing { 
    
    @testVisible public static List<Core_MDF_ChannelProgram__mdt> channelProgramMapping{ 
        get{ 
            if(channelProgramMapping == NULL){ 
                channelProgramMapping = [Select Label,Core_MDF_Program_ID__c from Core_MDF_ChannelProgram__mdt LIMIT 1000]; //ATHR limit 1000
            } 
            return channelProgramMapping; 
        } 
        set; 
    } 
    
    /*****************************************************************************************************
Method Name:        invokeAccountShareRecordToGeoGroup
@return  :          void
@parameters:        List of Account record
Description:        This is invocable method to perform Geo Based Sharing for a Account record
Added By:           Accenture-AS
Date :              21-Sept-2020
Modified By:        Date:       Changes:
*****************************************************************************************************/
    @InvocableMethod
    public static void invokeAccountShareRecordToGeoGroup(List<Account> listOfAccounts){
        //list for channel program share records
        List<Core_MDF_RecordGeoShare> accountshareList= new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        //Map of ChannelProgram ID and Channel Program Name
        Map<ID,String> channelProgramIDToNameMap = new Map<ID,String>();
        // to retrieve Channel Program Metadata
        List<Core_MDF_ChannelProgram__mdt> metadataRecordsList=Core_MDF_Account_Sharing.channelProgramMapping;
        List<Id> accIdList = new List<Id>();
        List<AccountShare> accShareListToBeDlt = new List<AccountShare>();
        Savepoint sp = Database.setSavepoint();
        try{
            shareWithExternalCoMarketingCreators(listOfAccounts);
            //To Save Values of ProgramID and Program Name for Each Program in Map
            if(metadataRecordsList!=null && metadataRecordsList.size()>0){
                for (Core_MDF_ChannelProgram__mdt metadataRec : metadataRecordsList){
                    channelProgramIDToNameMap.put(metadataRec.Core_MDF_Program_ID__c, metadataRec.Label);
                }
            }                
            //if(channelProgramIDToNameMap!=null && channelProgramIDToNameMap.size()>0){
              //  if(listOfAccounts != NULL && listOfAccounts.size() > 0){
                //ATHR Fix for deeply nested if
                if(channelProgramIDToNameMap!=null && channelProgramIDToNameMap.size()>0 && listOfAccounts != NULL && listOfAccounts.size() > 0){ 
                    for (Account acc : listOfAccounts){
                        if(channelProgramIDToNameMap.containskey(acc.Core_MDF_Channel_Program__c)){
                            /*if(!Core_MDF_Utility.byPassFeature('Bypass_AccShareDltOnGeoUpdate') && channelProgramIDToNameMap.get(acc.Core_MDF_Channel_Program__c) == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name')){
                                accIdList.add(acc.Id); 
                            }*/                        
                            accountshareList.add(new Core_MDF_RecordGeoShare(acc.ID,acc.Core_Geo__c,acc.Core_Sub_Geo__c,channelProgramIDToNameMap.get(acc.Core_MDF_Channel_Program__c)));
                            recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(acc.ID,acc.Core_Geo__c,acc.Core_Sub_Geo__c,channelProgramIDToNameMap.get(acc.Core_MDF_Channel_Program__c),acc.Core_MDF_CoMarketing_Ultimate_Account__c));
                        }
                    }
                }  
             //   }  
           // }
            /*if(accIdList != NULL && accIdList.size()>0){
                accShareListToBeDlt = [SELECT Id, AccountId, UserOrGroupId, UserOrGroup.name FROM AccountShare WHERE AccountId IN : accIdList AND RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual') AND (NOT UserOrGroup.name LIKE '%EXT%')];
            }
            if(accShareListToBeDlt != NULL && accShareListToBeDlt.size()>0){
                Database.deleteResult[] srList = Database.delete(accShareListToBeDlt, false);
            }*/
            //To share record on the basis of Channel Program
            if(accountshareList!=null && accountshareList.size()>0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Account',accountshareList);
            } 
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Account', recordPGMShareList);
            }
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); Database.rollback(sp); throw e;}
    }    
    
    private static void shareWithExternalCoMarketingCreators(List<Account> listOfAccounts) {
        if (listOfAccounts == null || listOfAccounts.isEmpty()) {
            return;
        }
		Map<Id, Id> creatorByAccountId = new Map<Id, Id>();
        for (Account accountRecord : listOfAccounts){
			if (accountRecord.OwnerId != accountRecord.CreatedById && accountRecord.OwnerId == System.Label.Core_MDF_Dummy_Account_Owner_Id) {
                creatorByAccountId.put(accountRecord.Id, accountRecord.CreatedById);
            }
        }

        if (creatorByAccountId.isEmpty()) {
            return;
        }

        List<AccountShare> sharesToInsert = new List<AccountShare>();
        for (Id accountId : creatorByAccountId.keySet()) {
            Id creatorId = creatorByAccountId.get(accountId);
                sharesToInsert.add(new AccountShare(
                    AccountId = accountId,
                    UserOrGroupId = creatorId,
                    AccountAccessLevel = 'Read',
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'None',
                    RowCause = Schema.AccountShare.RowCause.Manual
                ));
        }

        if (!sharesToInsert.isEmpty()) {
            insert sharesToInsert;
        }
    }
}