/****************************************************************************************************************************************
* Class Name        : Core_MDF_PGM_BatchHelper
* Test Class    : Core_MDF_PGM_BatchHelper_Test
* Created Date      : 11/24/2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       11/24/2019         Helper class to call batch for sharing of each record with pgm's group
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PGM_BatchHelper {
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
  /***************************************************************************************************** 
    Method Name   :        createObjectShareRecords
    @return       :        void
    @parameters   :        List<Core_MDF_Partner_Group_Mapping__c>
    Description   :        method to check the type of PGM
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/  
  public static void createObjectShareRecords(List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {

    Set<Id> accIdSet = new Set<Id>();
          Set<Id> primaryAccIds = new Set<Id>();
          Set<Id> activatingAccIds = new Set<Id>();
          Set<Id> EEFAccountIds = new Set<Id>();
    Set<Id> programIdSet = new Set<Id>();
          Set<Id> EEFprogramIdSet = new Set<Id>();
    Set<String> uniqueKeySet = new Set<String>();
        List<Core_MDF_Partner_Group_Mapping__c> EEFpgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        Map<ID,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap = new Map<ID,List<Core_MDF_Partner_Mapping__c>>();
    try{
      if(newPGMList.size() > 0) {
        for(Core_MDF_Partner_Group_Mapping__c pgm : newPGMList) {
          if(pgm.Core_MDF_Type_of_Access__c == 'Internal'){
                        if(pgm.Core_MDF_Channel_Program_Name_Txt__c  != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')) {
            accIdSet.add(pgm.Core_MDF_Account__c);
            programIdSet.add(pgm.Core_MDF_Channel_Program__c);
            String accIdProgramId = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c;
            uniqueKeySet.add(accIdProgramId);
          }
                        else {
                            EEFAccountIds.add(pgm.Core_MDF_Account__c);
                            EEFprogramIdSet.add(pgm.Core_MDF_Channel_Program__c);
                            EEFpgmList.add(pgm);
                            String accIdProgramId = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c;
                            uniqueKeySet.add(accIdProgramId);
                        }            
                    }
                }
            }
            
            //share all the object records with new PGM Groups for all the programs except EEF
            if(accIdSet.size() > 0 && programIdSet.size() > 0) {
                shareObjectswithPGMGroups(accIdSet,programIdSet,uniqueKeySet,newPGMList); 
           }
            
            //WW21 - PGM Batch Sharing Changes for EEF Program
            if(EEFAccountIds != NULL && EEFAccountIds.size() >0 && EEFprogramIdSet != NULL && EEFprogramIdSet.size() >0) {
                for(Core_MDF_Partner_Mapping__c rec : [SELECT id,Core_MDF_Channel_Program__c,Core_MDF_Primary_Partner_Account_id__c, Core_MDF_Activating_Partner_Account_id__c,Core_MDF_ActPartner_Ultimate_Acc_Id__c, Core_MDF_PrimPartner_Ultimate_Acc_Id__c,Core_MDF_Activating_Partner_Account_id__r.Core_MDF_Channel_Program__r.Name 
                                                       FROM Core_MDF_Partner_Mapping__c 
                                                       WHERE Core_MDF_PrimPartner_Ultimate_Acc_Id__c  IN: EEFAccountIds or Core_MDF_ActPartner_Ultimate_Acc_Id__c IN: EEFAccountIds]) {
                    primaryAccIds.add(rec.Core_MDF_PrimPartner_Ultimate_Acc_Id__c);
                    activatingAccIds.add(rec.Core_MDF_ActPartner_Ultimate_Acc_Id__c);
                    String accIdProgramId = (String)rec.Core_MDF_PrimPartner_Ultimate_Acc_Id__c + rec.Core_MDF_Channel_Program__c;
                    uniqueKeySet.add(accIdProgramId);
                    accIdProgramId = (String)rec.Core_MDF_ActPartner_Ultimate_Acc_Id__c + rec.Core_MDF_Channel_Program__c;
                    uniqueKeySet.add(accIdProgramId);
                    if(primaryIntelAccIdToPartnerMap.containsKey(rec.Core_MDF_PrimPartner_Ultimate_Acc_Id__c)) {
                     primaryIntelAccIdToPartnerMap.get(rec.Core_MDF_PrimPartner_Ultimate_Acc_Id__c).add(rec);
                    }
                    else {
                     primaryIntelAccIdToPartnerMap.put(rec.Core_MDF_PrimPartner_Ultimate_Acc_Id__c, new List<Core_MDF_Partner_Mapping__c> {rec});
                    }
                }
                
                pgmSharingForEEFObjects(EEFAccountIds,EEFprogramIdSet,primaryAccIds,activatingAccIds,uniqueKeySet,primaryIntelAccIdToPartnerMap,EEFpgmList);
            }
            
        }catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAccountShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
    public static void createAccountShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Map<ID,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap) {
        
        String accQuery = 'Select Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c,Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Partner_Type_nm__c,'
              +'Core_MDF_Channel_Program__r.Name'
              +' From Account WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Account', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,primaryIntelAccIdToPartnerMap), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Account));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createPartnerShipScoreShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for createPartnerShipScoreShareRecords Share
    Added By      :        Accenture
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createPartnerShipScoreShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {
        
    String accQuery = 'Select Id, Core_MDF_Account_Id__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Account_Id__r.Core_Geo__c,Core_MDF_Account_Id__r.Core_Sub_Geo__c,'
              +'Core_MDF_Channel_Program_Id__r.Name'
            +' From Core_MDF_Partnership_Score__c WHERE Core_MDF_IsRecordShared_ind__c = TRUE AND Core_MDF_Account_Id__c IN ';
    String programQuery = ' AND Core_MDF_Channel_Program_Id__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Partnership_Score__c', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Account));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createBudgetShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Budget Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createBudgetShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet){
        
    String accQuery = 'Select Id,Core_MDF_Budget_Partner__c, '
                 +'Core_MDF_Program__c,Core_MDF_Budget_Partner__r.Core_Geo__c, Core_MDF_Budget_Status__c, Core_MDF_Budget_Type_Txt__c,'
                +'Core_MDF_Budget_Partner__r.Core_Sub_Geo__c, Core_MDF_Program__r.Name, Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c '
               +'From PartnerMarketingBudget WHERE Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND Core_MDF_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerMarketingBudget', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Budget));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createBudgetCapShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Budget Cap Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createBudgetCapShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet){
        
    String accQuery = 'Select Id,Core_MDF_Budget_Name_id__c, Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c,'
                    +'Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c, Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,'
              +' Core_MDF_Budget_Name_id__r.Core_MDF_Program__c, Core_MDF_Budget_Name_id__r.Core_MDF_Program__r.Name, Core_MDF_Budget_Status_txt__c '
              +' From Core_MDF_Budget_Cap__c WHERE Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND Core_MDF_Budget_Name_id__r.Core_MDF_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Budget_Cap__c', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null),Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Budget_Cap));
    }
    
    /***************************************************************************************************** 
Method Name   :        createCampaignShareRecords
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        method to call batch for Campaign Share
Added By      :        Accenture - VK - 11/24/2019
Modified By   :        NK-Date:18/10/2022 Changes: Added Core_MDF_Market__c field in SOQL
******************************************************************************************************/ 
    public static void createCampaignShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {
        
        String accQuery = 'SELECT Id, Core_MDF_Partner_Mapping_Txt__c,RecordTypeId, RecordType.DeveloperName, Core_MDF_Market__c,Core_MDF_Program__c, Core_MDF_Channel_Program__c , Core_MDF_Account__c,Core_MDF_Region_cd__c, '
            +'Core_MDF_Sub_Region_cd__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_External_Visibility_Date__c,'
            +'Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Host_Region_cd__c,Core_MDF_Proposal_Based_Ind__c FROM Campaign WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Campaign', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, uniqueKeySet,null), 
                                                   Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Campaign));
    }
    
    
    /***************************************************************************************************** 
Method Name   :        createCampToActShareRecords
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        method to call batch for Campaign To Activating Records Sharing
Added By      :        Accenture - MD - 03/22/2024
Modified By   :        
******************************************************************************************************/ 
    public static void createCampToActShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {
        
        String accQuery ='Select id,Core_MDF_Channel_Program__c,Core_MDF_Campaign_Id__c, Core_MDF_Activating_Partner_Account_id__c, Core_MDF_Campaign_Id__r.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_PrimPartner_Ultimate_Acc_Id__c,Core_MDF_ActPartner_Ultimate_Acc_Id__c,Core_MDF_Active_Ind__c,Core_MDF_Campaign_Id__r.Core_MDF_Region_cd__c,Core_MDF_Campaign_Id__r.Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Campaign_Id__r.Core_MDF_External_Visibility_Date__c  from Core_MDF_Camp_to_ActPartner__c where Core_MDF_PrimPartner_Ultimate_Acc_Id__c IN ';
        
        String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Camp_to_ActPartner__c', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, uniqueKeySet,null), 
                                                   Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Campaign));
        
    }
    /***************************************************************************************************** 
Method Name   :        createAllocationShareRecords
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        method to call batch for Allocation Share
Added By      :        Accenture - JV - 11/24/2019
Modified By   :        Date:           Changes: 
******************************************************************************************************/ 
    public static void createAllocationShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {
        
        String accQuery = 'SELECT Id,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
            +'Budget.Core_MDF_Program__r.Name, Budget.Core_MDF_Program__c,ChannelPartner.Core_MDF_Partner_Type_nm__c,Budget.Core_MDF_Budget_Partner__c,ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__c, '
            +'Budget.Core_MDF_Budget_Partner__r.Core_Geo__c,Budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,Budget.Core_MDF_Budget_Type_Txt__c,ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__r.Core_MDF_Partner_Type_nm__c '
            +'FROM PartnerFundAllocation WHERE ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Budget.Core_MDF_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerFundAllocation', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Allocation)); 
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAccountUserShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account User Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createAccountUserShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {
        String accQuery = 'SELECT Id, Core_MDF_Active_Ind__c,Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
                    +'Core_MDF_Account__r.Core_MDF_Channel_Program__c '
                 +'FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Active_Ind__c = TRUE AND Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_PNUMShareRecordInsert('Core_MDF_Partner_Node_User_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,newPGMList), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_PNUM));
  }
  
    /***************************************************************************************************** 
    Method Name   :        createAccountTransferLogShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account Transfer Log Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
    public static void createAccountTransferLogShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Boolean isEEFProg) {
        String accQuery = 'SELECT Id, Core_MDF_Source_Account__c,Core_MDF_Partner_Marketing_Budget__c,Core_MDF_Target_Account__c, Core_MDF_Source_Account__r.Core_MDF_Channel_Program__c, '
            +'Core_MDF_Source_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Partner_Marketing_Budget__r.Core_MDF_Budget_Type_Txt__c '
            +'FROM Core_MDF_Budget_Transfer_Log__c';
        
        if(isEEFProg){
            accQuery += ' WHERE (Core_MDF_Source_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN :setOfAccountId OR Core_MDF_Target_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN :setOfAccountId)';
        }else{
            accQuery += ' WHERE Core_MDF_Source_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN :setOfAccountId';
        }
         
        String programQuery = ' AND Core_MDF_Source_Account__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Budget_Transfer_Log__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Acc_Transfer_Log));
    }
    
    /***************************************************************************************************** 
Method Name   :        createPFRShareRecords
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        method to call batch for PFR Share
Added By      :        Accenture - VK - 11/24/2019
Modified By   :        Date:           Changes: 
******************************************************************************************************/ 
    public static void createPFRShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {
        
        String accQuery = 'SELECT Id, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,'
            +'ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_nm__c,Core_MDF_Sub_Region_nm__c'
            +' FROM PartnerFundRequest WHERE Core_MDF_Activity_Level_nm__c != \'Sub Activity\''
            + ' AND channelPartner.Core_MDF_CoMarketing_Ultimate_Account__c  IN ';
        String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Integer batchSize = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Batch_Size_PFR'));
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerFundRequest', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet,
                                                                                                uniqueKeySet,null),batchSize);
        //Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_PFR));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createClaimAndPaymentShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for PFC & Payment Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createClaimAndPaymentShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

    String accQuery = 'SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_AccountCompany__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Program__c, '
    +'ChannelPartner.Core_MDF_Channel_Program__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,RequestId,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Country_Location_nm__c, Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c, Amount, ChannelPartnerId,ChannelPartner.Core_MDF_Group_Id__c, '
        +'Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Status__c, Core_MDF_Payment_Id__c, '
        +'ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Budget_Type_Options_Nm__c '
		+'FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c = null AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerFundClaim', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Claim)); 
        Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
        customSch.Core_MDF_Batch_Size_Nbr__c = 40;
        customSch.Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_BatchRequestUpdateLog';
        customSch.Core_MDF_Object_JSON_Txt__c = '{"recordTypeDevName" : "Core_MDF_Payment_Share","objectApiName" : "Core_MDF_Payment__Share","action" : "Insert","queryLimit" : 40}';
        customSch.Core_MDF_Job_Frequency__c = 'Every X Minute';
        customSch.Core_MDF_Every_X_Minute_Nbr__c = '5';
        customSch.Core_MDF_Effective_Start_Time_Dt__c = system.now().addMinutes(5);
        customSch.Core_MDF_Effective_End_Time_Dt__c = system.now().addMinutes(25);
        customSch.Core_MDF_Priority__c = 'High';
        customSch.Core_MDF_Program_Txt__c = 'CCP'; 
        insert customSch;
    }
    
    
     /***************************************************************************************************** 
    Method Name   :        createAuditDocShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Audit Document Share
    Added By      :        Accenture - Sandesh - 7/21/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    
    public static void createAuditDocShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

        String accQuery = 'SELECT Id,Core_MDF_Claim__r.Core_MDF_Type_Txt__c, Core_MDF_Claim__r.Core_MDF_AccountCompany__c,Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Claim__r.Core_MDF_Program__c, '
        +'Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Claim__r.RequestId,Core_MDF_Claim__r.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Claim__r.Core_MDF_Country_Location_nm__c, Core_MDF_Claim__r.Core_MDF_Region_Cd__c, Core_MDF_Claim__r.Core_MDF_Sub_Region_Cd__c, Core_MDF_Claim__r.Amount, Core_MDF_Claim__r.ChannelPartnerId,Core_MDF_Claim__r.ChannelPartner.Core_MDF_Group_Id__c, '
        +'Core_MDF_Claim__r.Core_MDF_Bank__c, Core_MDF_Claim__r.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Claim__r.Core_MDF_Status__c, Core_MDF_Claim__r.Core_MDF_Payment_Id__c, '
        +'Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Claim__r.Core_MDF_Budget_Type_Options_Nm__c '
        +'FROM Core_MDF_Audit_Document__c WHERE Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN '; 
        String programQuery = ' AND Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Audit_Document__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Claim));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAdjustmentRequestShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Adjustment Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createAdjustmentRequestShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

    String accQuery = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_Channel_Program__c, '
    +'Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c'
    +' FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Adjustment_Request__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Adjsutment_Request));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createCaseShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Case Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:18/10/2022     Changes: Added Core_MDF_Budget_Type_nm__c to SOQL Query
    ******************************************************************************************************/ 
  public static void createCaseShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

    String accQuery = 'SELECT Id, AccountId, Core_Account_Geo__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, '
    +'Account.Core_MDF_Channel_Program__c,Core_IPS_Account_Sub_Geo__c,Core_MDF_Channel_Program_txt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Budget_Type_Txt__c'
    +' FROM Case WHERE Account.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND Account.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Case', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Case));    
    }
    
    /***************************************************************************************************** 
    Method Name   :        createBankShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Bank Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createBankShareRecords(Set<Id> intelAccIdSet, Set<String>  uniqueKeySet) {

    String query = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Program__c,Core_MDF_ESD_Update__c FROM Core_MDF_Bank__c '
    +'WHERE Core_MDF_ESD_Update__c = TRUE AND Core_MDF_Account__c IN ';

        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Bank__c', 
                                                                                                query, null, 
                                                                                                intelAccIdSet, null, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Bank));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAccBankMappingShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for ABM Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createAccBankMappingShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

    String accQuery = 'SELECT Id, Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
    +'FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
    String programQuery = ' AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Account_Bank_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_ABM));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createExceptionShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Exception Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  /*public static void createExceptionShareRecords(Set<Id> intelAccIdSet,Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

        String query = 'SELECT Id,OwnerId,Core_MDF_HostRegion_txt__c,Core_MDF_Approver_1_Comments_Txt__c,Core_MDF_Activity_Cate_and_Type_nm__c,Core_MDF_Account_id__c, Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Program_nm__c,Core_MDF_Country_Region_nm__c,Core_MDF_Region_txt__c,'
        +'Core_MDF_Budget_Type_nm__c,Core_MDF_Select_All_Country_ind__c FROM Core_MDF_Exception__c WHERE Core_MDF_Account_id__c IN ';

        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Exception__c', 
                                                                                                query, null, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Exception));
    }*/
    
     
    /***************************************************************************************************** 
    Method Name   :        createExceptionAccMapShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Exception Account Mapping Share which will create share records for both Exception and Exception Account Mapping
    Added By      :        Accenture - Mohit 11/05/2025(DD/MM/YYYY)
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createExceptionAccMapShareRecords(Set<Id> intelAccIdSet,Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

        String query = 'SELECT Id,Core_MDF_Country_Region_txt__c,Core_MDF_Account_id__c,Core_MDF_Program_nm__c,Core_MDF_Select_All_Accounts_ind__c,Core_MDF_Program_txt__c,Core_MDF_HostRegion_txt__c,Core_MDF_Budget_Type_txt__c,'
        +'Core_MDF_Exception_id__c,Core_MDF_Select_All_Country_ind__c FROM Core_MDF_Exception_Account_Mapping__c WHERE Core_MDF_Account_id__c IN ';

        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Exception_Account_Mapping__c', 
                                                                                                query, null, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Exception));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createEscalationShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Escalation Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/ 
  public static void createEscalationShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

    String accQuery = 'SELECT Id, recordTypeId, Core_MDF_Budget_ID_Number_id__c, Core_MDF_Case_ID_Number_id__c, Core_MDF_Co_Marketing_Activity_id__c, '
    +'Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
    +'Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program_id__c, '
    +'Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c '
    +'FROM Core_MDF_Escalation__c WHERE '
    +'(Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet OR '
    +'Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet OR '
    +'Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet';
    String programQuery =  ') AND (Core_MDF_Channel_Program_id__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Escalation__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,null), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Escalation));
        
    }

    
    /***************************************************************************************************** 
    Method Name   :        createECMShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Exception Case Mapping Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************
    public static void createECMShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet){
        
        String accQuery = 'SELECT Id, Core_MDF_Case_id__c,Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, '
            +'Core_MDF_Exception_id__c, Core_MDF_Case_id__r.Account.Core_MDF_Channel_Program__c FROM Core_MDF_Exception_Case_Mapping__c WHERE '
            +'Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery =  ' AND Core_MDF_Case_id__r.Account.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Exception_Case_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_ECM));
    }*/
    
    /***************************************************************************************************** 
Method Name   :        pgmSharingForEEFObjects
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        
Added By      :        Accenture - 
Modified By   :        Date:           Changes: 
******************************************************************************************************/
    public static void pgmSharingForEEFObjects(set<Id> EEFAccountIds, set<Id> EEFprogramIdSet, set<Id> primaryAccIds, set<Id> activatingAccIds, set<String> uniqueKeySet,  Map<Id,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap , List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {
        
        //objects sharing which are independent of Partner Mapping like Account,PNUM, Allocation, Transfer Log
        shareAccountBasedObjects(EEFAccountIds,EEFprogramIdSet,primaryAccIds,activatingAccIds,uniqueKeySet,primaryIntelAccIdToPartnerMap,newPGMList);
        
        //objects sharing which are independent on Partner Mapping 
        
        //Transactions exists on Primary Account like Budget,Campaign
          sharePrimaryPartnerObjects(EEFAccountIds,EEFprogramIdSet,primaryAccIds,activatingAccIds,uniqueKeySet,primaryIntelAccIdToPartnerMap,newPGMList);
       
        //Transactions exists on Primary Account like Activity,Claim
         shareActivatingPartnerObjects(EEFAccountIds,EEFprogramIdSet,primaryAccIds,activatingAccIds,uniqueKeySet,primaryIntelAccIdToPartnerMap,newPGMList);  
    }
    
    /***************************************************************************************************** 
Method Name   :        shareAccountBasedObjects
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        
Added By      :        Accenture - 
Modified By   :        Date:           Changes: 
******************************************************************************************************/
    public static void shareAccountBasedObjects(set<Id> EEFAccountIds, set<Id> EEFprogramIdSet, set<Id> primaryAccIds, set<Id> activatingAccIds, set<String> uniqueKeySet, Map<Id,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap, List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {
        if(EEFAccountIds.size() >0 && EEFprogramIdSet.size() > 0) {
            Set<Id> accIds = new Set<Id>();
      accIds.addAll(primaryAccIds);
            accIds.addAll(activatingAccIds);
            
            if(mapFunctionalityNameTriggerExecution.containsKey('CreateAccountShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('CreateAccountShareRecordsEEF').Core_Active__c){
                   createAccountShareRecords(EEFAccountIds, EEFprogramIdSet, uniqueKeySet,primaryIntelAccIdToPartnerMap);
               }
            
            if(mapFunctionalityNameTriggerExecution.containsKey('createPartnerShipScoreShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createPartnerShipScoreShareRecordsEEF').Core_Active__c){
                   createPartnerShipScoreShareRecords(EEFAccountIds, EEFprogramIdSet, uniqueKeySet);
               }
            
            if(mapFunctionalityNameTriggerExecution.containsKey('createAccountUserShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createAccountUserShareRecordsEEF').Core_Active__c){
                   createAccountUserShareRecords(EEFAccountIds, EEFprogramIdSet, uniqueKeySet,newPGMList);
               }
            
            //Merge primary and activating account Id sets and call batch class for Allocation and Transfer Log Objects  
            if(mapFunctionalityNameTriggerExecution.containsKey('createAllocationShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createAllocationShareRecordsEEF').Core_Active__c){
                   createAllocationShareRecords(accIds, EEFprogramIdSet, uniqueKeySet);
               }
            if(mapFunctionalityNameTriggerExecution.containsKey('createAccountTransferLogShareRecsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createAccountTransferLogShareRecsEEF').Core_Active__c){
                   createAccountTransferLogShareRecords(accIds, EEFprogramIdSet, uniqueKeySet, true);
               }
            
        }
        
    }
    /***************************************************************************************************** 
Method Name   :        sharePrimaryPartnerObjects
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        
Added By      :        Accenture - 
Modified By   :        Date:           Changes: 
******************************************************************************************************/
    public static void sharePrimaryPartnerObjects(set<Id> EEFAccountIds, set<Id> EEFprogramIdSet, set<Id> primaryAccIds, set<Id> activatingAccIds, set<String> uniqueKeySet, Map<Id,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap, List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {
        if(primaryAccIds.size() > 0 && EEFprogramIdSet.size() > 0) {
            
            if(mapFunctionalityNameTriggerExecution.containsKey('createBudgetShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createBudgetShareRecordsEEF').Core_Active__c){
                   createBudgetShareRecords(primaryAccIds, EEFprogramIdSet, uniqueKeySet);
               }
            
            if(mapFunctionalityNameTriggerExecution.containsKey('createCampaignShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createCampaignShareRecordsEEF').Core_Active__c){
                   createCampaignShareRecords(primaryAccIds, EEFprogramIdSet, uniqueKeySet);
               }
            if(mapFunctionalityNameTriggerExecution.containsKey('createCampToActShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createCampToActShareRecordsEEF').Core_Active__c){
                   createCampToActShareRecords(primaryAccIds, EEFprogramIdSet, uniqueKeySet);
               }
            
            
        }
    }
    
    /***************************************************************************************************** 
Method Name   :        shareActivatingPartnerObjects
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        
Added By      :        Accenture - 
Modified By   :        Date:           Changes: 
******************************************************************************************************/
    public static void shareActivatingPartnerObjects(set<Id> EEFAccountIds, set<Id> EEFprogramIdSet, set<Id> primaryAccIds, set<Id> activatingAccIds, set<String> uniqueKeySet, Map<Id,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap, List<Core_MDF_Partner_Group_Mapping__c> newPGMList)
    {
        if(activatingAccIds.size() > 0 && EEFprogramIdSet.size() > 0) {
            if(mapFunctionalityNameTriggerExecution.containsKey('createCampaignShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createCampaignShareRecordsEEF').Core_Active__c){
                   createCampaignShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
               }
            if(mapFunctionalityNameTriggerExecution.containsKey('createPFRShareRecordsEEF') &&
               mapFunctionalityNameTriggerExecution.get('createPFRShareRecordsEEF').Core_Active__c){
                   createPFRShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
               }  
            //Below method will be used post WW42.
            if(mapFunctionalityNameTriggerExecution.containsKey('createClaimAndPaymentShareRecords') &&
               mapFunctionalityNameTriggerExecution.get('createClaimAndPaymentShareRecords').Core_Active__c){
                  createClaimAndPaymentShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
               }
            if(mapFunctionalityNameTriggerExecution.containsKey('createAuditDocumentShareRecords') &&
               mapFunctionalityNameTriggerExecution.get('createAuditDocumentShareRecords').Core_Active__c){
                  createAuditDocShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
               }

           if(mapFunctionalityNameTriggerExecution.containsKey('createAdjustmentRequestShareRecords') &&
              mapFunctionalityNameTriggerExecution.get('createAdjustmentRequestShareRecords').Core_Active__c){                       
                createAdjustmentRequestShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
               }

           if(mapFunctionalityNameTriggerExecution.containsKey('createCaseShareRecords') &&
              mapFunctionalityNameTriggerExecution.get('createCaseShareRecords').Core_Active__c){
                createCaseShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
               }

           if(mapFunctionalityNameTriggerExecution.containsKey('createExceptionShareRecords') &&
             mapFunctionalityNameTriggerExecution.get('createExceptionShareRecords').Core_Active__c){
                //createExceptionShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
                createExceptionAccMapShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
                
              }

          if(mapFunctionalityNameTriggerExecution.containsKey('createEscalationShareRecords') &&
            mapFunctionalityNameTriggerExecution.get('createEscalationShareRecords').Core_Active__c){
               createEscalationShareRecords(activatingAccIds, EEFprogramIdSet, uniqueKeySet);
              }
          if(mapFunctionalityNameTriggerExecution.containsKey('createBankShareRecords') &&
            mapFunctionalityNameTriggerExecution.get('createBankShareRecords').Core_Active__c){
              createBankShareRecords(EEFAccountIds, uniqueKeySet);
              }

          if(mapFunctionalityNameTriggerExecution.containsKey('createAccBankMappingShareRecords') &&
              mapFunctionalityNameTriggerExecution.get('createAccBankMappingShareRecords').Core_Active__c){
               createAccBankMappingShareRecords(EEFAccountIds, EEFprogramIdSet, uniqueKeySet);
               }
            
    }
}
   /***************************************************************************************************** 
Method Name   :        shareObjectswithPGMGroups
@return       :        void
@parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
Description   :        Call all object sharing methods
Added By      :        Accenture - 
Modified By   :        Date:           Changes: 
******************************************************************************************************/
    public static void shareObjectswithPGMGroups(set<Id> accIdSet, set<Id> programIdSet, set<String> uniqueKeySet, List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {
        
        if(mapFunctionalityNameTriggerExecution.containsKey('createAccountShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountShareRecords').Core_Active__c){
                       createAccountShareRecords(accIdSet, programIdSet, uniqueKeySet,null);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createPartnerShipScoreShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createPartnerShipScoreShareRecords').Core_Active__c){
                       createPartnerShipScoreShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createBudgetShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createBudgetShareRecords').Core_Active__c){
                       createBudgetShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createBudgetCapShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createBudgetCapShareRecords').Core_Active__c){
                       createBudgetCapShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createCampaignShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createCampaignShareRecords').Core_Active__c){
                       createCampaignShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createPFRShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createPFRShareRecords').Core_Active__c){
                       createPFRShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createClaimAndPaymentShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createClaimAndPaymentShareRecords').Core_Active__c){
                       createClaimAndPaymentShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                if(mapFunctionalityNameTriggerExecution.containsKey('createAuditDocumentShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAuditDocumentShareRecords').Core_Active__c){
                       createAuditDocShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                if(mapFunctionalityNameTriggerExecution.containsKey('createAllocationShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAllocationShareRecords').Core_Active__c){
                       createAllocationShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountUserShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountUserShareRecords').Core_Active__c){
                       createAccountUserShareRecords(accIdSet, programIdSet, uniqueKeySet,newPGMList);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountTransferLogShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountTransferLogShareRecords').Core_Active__c){
                       createAccountTransferLogShareRecords(accIdSet, programIdSet, uniqueKeySet, false);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAdjustmentRequestShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAdjustmentRequestShareRecords').Core_Active__c){                       
                       createAdjustmentRequestShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createCaseShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createCaseShareRecords').Core_Active__c){
                       createCaseShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createBankShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createBankShareRecords').Core_Active__c){
                       createBankShareRecords(accIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccBankMappingShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccBankMappingShareRecords').Core_Active__c){
                       createAccBankMappingShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createExceptionShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createExceptionShareRecords').Core_Active__c){
                       //createExceptionShareRecords(accIdSet, programIdSet, uniqueKeySet);
                       createExceptionAccMapShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createEscalationShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createEscalationShareRecords').Core_Active__c){
                       createEscalationShareRecords(accIdSet, programIdSet, uniqueKeySet);
                   }
                
                /*if(mapFunctionalityNameTriggerExecution.containsKey('createECMShareRecords') &&
                          mapFunctionalityNameTriggerExecution.get('createECMShareRecords').Core_Active__c){
                       createECMShareRecords(accIdSet, programIdSet, uniqueKeySet);
                    }*/
    }  
}