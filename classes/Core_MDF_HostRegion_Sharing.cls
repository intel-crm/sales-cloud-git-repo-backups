/****************************************************************************************************************************************
* Class Name        : Core_MDF_HostRegion_ShareBatch
* Created Date      : 
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -         class to call batch for sharing of each record with metadata and pgm's group on Host Geo Update
*****************************************************************************************************************************************/
public without sharing class Core_MDF_HostRegion_Sharing  {
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    /**
     * Wrapper class to encapsulate common sharing parameters // 14285
     */
    public class SharingParams {
        public Set<Id> intelAccIdSet;
        public Set<Id> channelProgramIdSet;
        public Set<String> uniqueKeySet;
        public Set<String> hostGeo;
        
        public SharingParams(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, 
                           Set<String> uniqueKeySet, Set<String> hostGeo) {
            this.intelAccIdSet = intelAccIdSet;
            this.channelProgramIdSet = channelProgramIdSet;
            this.uniqueKeySet = uniqueKeySet;
            this.hostGeo = hostGeo;
        }
    }
    
    /***************************************************************************************************** 
    Method Name   :        createObjectShareRecords
    @return       :        void
    @parameters   :        List<Account>
    Description   :        
    Added By      :        Accenture -
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/  
    public static void createObjectShareRecords(List<Account> oldAcctList,List<Account> newAcctList) {

        Set<Id> accIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<String> uniqueKeySet = new Set<String>();
        Set<String> hostGeo = new Set<String>();
        Map<Id,string> accIdToGeoMap = new Map<Id,string>();

        try{
            if(oldAcctList.size() > 0) {
                for(Account acc : oldAcctList) {
                        accIdSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                        programIdSet.add(acc.Core_MDF_Channel_Program__c);
                        String accIdProgramId = (String)acc.Core_MDF_CoMarketing_Ultimate_Account__c + acc.Core_MDF_Channel_Program__c;
                        uniqueKeySet.add(accIdProgramId);
                        hostGeo.add(acc.Core_Geo__c);
                    }
                } 

                for(Account acc : newAcctList) {
                    accIdToGeoMap.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c, acc.Core_Geo__c);
                }
            
            
            if(accIdSet.size() > 0 && programIdSet.size() > 0) {
                
                // Create wrapper object with common parameters // 14285
                SharingParams sharingParams = new SharingParams(accIdSet, programIdSet, uniqueKeySet, hostGeo);
                
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicForAccount') &&
                mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicForAccount').Core_Active__c){
                  createAccountShareRecords(sharingParams);
               }
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicForCamp') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicForCamp').Core_Active__c){
                    createCampaignShareRecords(sharingParams); //14285
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicForPFR') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicForPFR').Core_Active__c){
                   createPFRShareRecords(sharingParams); //14285
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicForClaim') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicForClaim').Core_Active__c){
                    createClaimAndPaymentShareRecords(sharingParams); //14285
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicAuditDoc') &&
                mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicAuditDoc').Core_Active__c){
                   createAuditDocShareRecords(sharingParams);//14285
                }
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicForPNUM') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicForPNUM').Core_Active__c){
                    createAccountUserShareRecords(sharingParams); //14285
                }

                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicForCase') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicForCase').Core_Active__c){
                    createCaseShareRecords(sharingParams); //14285
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicEscalation') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicEscalation').Core_Active__c){
                    createEscalationShareRecords(sharingParams); //14285
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_HostGeoSharingLogicException') &&
                   mapFunctionalityNameTriggerExecution.get('Core_MDF_HostGeoSharingLogicException').Core_Active__c){
                    //createExceptionShareRecords(accIdSet,accIdToGeoMap);
                    createExceptionAccountMappingShareRecords(accIdSet,accIdToGeoMap);
                }
                
            }

        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAccountShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for Account Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createAccountShareRecords(SharingParams params) {
        
        String accQuery = 'Select Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c,Core_Geo__c,Core_Sub_Geo__c,'
                          +'Core_MDF_Channel_Program__r.Name'
                          +' From Account WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Account', accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, 
                                                                                                params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Account)); 
    }

    /***************************************************************************************************** 
    Method Name   :        createCampaignShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for Campaign Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        
    ******************************************************************************************************/ 
    public static void createCampaignShareRecords(SharingParams params) {

        String accQuery = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, Core_MDF_Market__c,Core_MDF_Program__c, Core_MDF_Channel_Program__c , Core_MDF_Account__c,Core_MDF_Region_cd__c, '
        +'Core_MDF_Sub_Region_cd__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_External_Visibility_Date__c,'
        +'Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Host_Region_cd__c,Core_MDF_Proposal_Based_Ind__c FROM Campaign WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
  
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Campaign', accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Claim));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAccountUserShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for Account User Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createAccountUserShareRecords(SharingParams params) {
        String accQuery = 'SELECT Id, Core_MDF_Active_Ind__c,Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
                          +'Core_MDF_Account__r.Core_MDF_Channel_Program__c '
                          +'FROM Core_MDF_Partner_Node_User_Mapping__c WHERE  Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN ';
        
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_HostGeoPNUMShareInsert('Core_MDF_Partner_Node_User_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, 
                                                                                                params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_PNUM));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createPFRShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for PFR Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createPFRShareRecords(SharingParams params) {

        String accQuery = 'SELECT Id, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,'
        +'ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_nm__c,Core_MDF_Sub_Region_nm__c'
        +' FROM PartnerFundRequest WHERE Core_MDF_Activity_Level_nm__c != \'Sub Activity\''
            + ' AND Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Integer batchSize = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Batch_Size_PFR'));
        
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('PartnerFundRequest', 
                                                                                                accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet,
                                                                                                params.uniqueKeySet, params.hostGeo), batchSize);
    }
    
    /***************************************************************************************************** 
    Method Name   :        createClaimAndPaymentShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for PFC & Payment Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createClaimAndPaymentShareRecords(SharingParams params) {

        String accQuery = 'SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_AccountCompany__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Program__c, '
        +'ChannelPartner.Core_MDF_Channel_Program__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,RequestId,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Country_Location_nm__c, Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c, Amount, ChannelPartnerId,ChannelPartner.Core_MDF_Group_Id__c, '
        +'Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Status__c, Core_MDF_Payment_Id__c, '
        +'ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Budget_Type_Options_Nm__c '
        +'FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c = null AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('PartnerFundClaim', 
                                                                                                accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, 
                                                                                                params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Claim));
    }

    /***************************************************************************************************** 
    Method Name   :        createAuditDocShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for Audit Document Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createAuditDocShareRecords(SharingParams params) {

        String accQuery = 'SELECT Id,Core_MDF_Claim__r.Core_MDF_Type_Txt__c, Core_MDF_Claim__r.Core_MDF_AccountCompany__c,Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Claim__r.Core_MDF_Program__c, '
        +'Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Claim__r.RequestId,Core_MDF_Claim__r.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Claim__r.Core_MDF_Country_Location_nm__c, Core_MDF_Claim__r.Core_MDF_Region_Cd__c, Core_MDF_Claim__r.Core_MDF_Sub_Region_Cd__c, Core_MDF_Claim__r.Amount, Core_MDF_Claim__r.ChannelPartnerId,Core_MDF_Claim__r.ChannelPartner.Core_MDF_Group_Id__c, '
        +'Core_MDF_Claim__r.Core_MDF_Bank__c, Core_MDF_Claim__r.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Claim__r.Core_MDF_Status__c, Core_MDF_Claim__r.Core_MDF_Payment_Id__c, '
        +'Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Claim__r.Core_MDF_Budget_Type_Options_Nm__c '
        +'FROM Core_MDF_Audit_Document__c WHERE Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN '; 
        String programQuery = ' AND Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c IN ';
        
        Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Core_MDF_Audit_Document__c', 
                                                                                                accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, 
                                                                                                params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Claim)); 
    }
       
    /***************************************************************************************************** 
    Method Name   :        createCaseShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for Case Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:18/10/2022     Changes: Added Core_MDF_Budget_Type_nm__c to SOQL Query
    ******************************************************************************************************/ 
    public static void createCaseShareRecords(SharingParams params) {

        String accQuery = 'SELECT Id, AccountId,OwnerId, Core_Account_Geo__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Account.Core_MDF_Channel_Program__c,Core_IPS_Account_Sub_Geo__c,Core_MDF_Channel_Program_txt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Budget_Type_Txt__c'
        +' FROM Case WHERE Account.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Account.Core_MDF_Channel_Program__c IN ';
       
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Case', accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, 
                                                                                                params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Case));  
    }
    
    /***************************************************************************************************** 
    Method Name   :        createEscalationShareRecords
    @return       :        void
    @parameters   :        SharingParams
    Description   :        method to call batch for Escalation Share
    Added By      :        Accenture - Mayuri - 06/10/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createEscalationShareRecords(SharingParams params) {
        String accQuery = 'SELECT Id, recordTypeId, Core_MDF_Budget_ID_Number_id__c, Core_MDF_Case_ID_Number_id__c, Core_MDF_Co_Marketing_Activity_id__c, '
        +'Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program_id__c, '
        +'Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c '
        +'FROM Core_MDF_Escalation__c WHERE ' 
        +'(Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet OR '
        +'Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet OR '
        +'Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet';
        String programQuery =  ') AND (Core_MDF_Channel_Program_id__c IN ';
          
         Id batchInstanceId =  Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Core_MDF_Escalation__c', 
                                                                                                accQuery, programQuery, 
                                                                                                params.intelAccIdSet, params.channelProgramIdSet, 
                                                                                                params.uniqueKeySet, params.hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Escalation));
    }
    
    
    /***************************************************************************************************** 
    Method Name   :        createExceptionShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Exception Share
    Added By      :        Accenture - Shiva - 13/10/2023 (dd/mm/yyyy)
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    /*public static void createExceptionShareRecords(Set<Id> intelAccIdSet,Map<Id,string> accIdToGeoMap) {
        List<Core_MDF_Exception__c> exceptionToBeProcessed = new List<Core_MDF_Exception__c>();
        List<Core_MDF_Exception__c> exptList = [SELECT Id,OwnerId,Core_MDF_HostRegion_txt__c,Core_MDF_Approver_1_Comments_Txt__c,Core_MDF_Activity_Cate_and_Type_nm__c,Core_MDF_Account_id__c, Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Program_nm__c,Core_MDF_Country_Region_nm__c,Core_MDF_Region_txt__c,
                                                Core_MDF_Budget_Type_nm__c,Core_MDF_Select_All_Country_ind__c 
                                                FROM Core_MDF_Exception__c 
                                                WHERE Core_MDF_Account_id__c IN: intelAccIdSet];                      
                                               
                                               if(exptList != null && !exptList.isEmpty()) {
                                                   for(Core_MDF_Exception__c expt : exptList){
                                                       if(accIdToGeoMap != null && accIdToGeoMap.containsKey(expt.Core_MDF_Account_id__c)){
                                                           Core_MDF_Exception__c exp = new Core_MDF_Exception__c();
                                                           exp.Id = expt.Id;
                                                           exp.Core_MDF_HostRegion_txt__c = accIdToGeoMap.get(expt.Core_MDF_Account_id__c);
                                                           exceptionToBeProcessed.add(exp);
                                                       }
                                                   }
                                               }
                        
                                               if(!exceptionToBeProcessed.isEmpty()){
                                                   Database.executeBatch(new Core_MDF_BulkUpdate_Batch(exceptionToBeProcessed),Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Exception));
                                               }                                                                                 
    }*/
    /***************************************************************************************************** 
    Method Name   :        createExceptionAccountMappingShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Map of Account id to geo map
    Description   :        method to call batch for Exception Account Mapping Share
    Added By      :        Accenture - Mohit - 11/05/2025 (dd/mm/yyyy)
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createExceptionAccountMappingShareRecords(Set<Id> intelAccIdSet,Map<Id,string> accIdToGeoMap) {
        List<Core_MDF_Exception_Account_Mapping__c> exceptionAccMapToBeProcessed = new List<Core_MDF_Exception_Account_Mapping__c>();
        List<Core_MDF_Exception_Account_Mapping__c> exptAccMapList = [SELECT Id,OwnerId,Core_MDF_HostRegion_txt__c,Core_MDF_Account_id__c, Core_MDF_Select_All_Accounts_ind__c, 
                                                                Core_MDF_Program_nm__c,Core_MDF_Country_Region_txt__c,Core_MDF_Budget_Type_txt__c 
                                                                FROM Core_MDF_Exception_Account_Mapping__c 
                                                                WHERE Core_MDF_Account_id__c IN: intelAccIdSet];                      
                                               
                                               if(exptAccMapList != null && !exptAccMapList.isEmpty()) {
                                                   for(Core_MDF_Exception_Account_Mapping__c expt : exptAccMapList){
                                                       if(accIdToGeoMap != null && accIdToGeoMap.containsKey(expt.Core_MDF_Account_id__c)){
                                                           Core_MDF_Exception_Account_Mapping__c expAccMap = new Core_MDF_Exception_Account_Mapping__c();
                                                           expAccMap.Id = expt.Id;
                                                           expAccMap.Core_MDF_HostRegion_txt__c = accIdToGeoMap.get(expt.Core_MDF_Account_id__c);
                                                           exceptionAccMapToBeProcessed.add(expAccMap);
                                                       }
                                                   }
                                               }
                        
                                               if(!exceptionAccMapToBeProcessed.isEmpty()){
                                                   Database.executeBatch(new Core_MDF_BulkUpdate_Batch(exceptionAccMapToBeProcessed),Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Exception));
                                               }                                                                                 
    }
}