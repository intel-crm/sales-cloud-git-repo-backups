/****************************************************************************************************************************************
* Class Name        : Core_MDF_HostRegion_ShareBatch
* Created Date      : 
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -         class to call batch for sharing of each record with pgm's group
*****************************************************************************************************************************************/
public without sharing class Core_MDF_HostRegion_ShareBatch  {
    
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    /***************************************************************************************************** 
    Method Name   :        createObjectShareRecords
    @return       :        void
    @parameters   :        List<Account>
    Description   :        
    Added By      :        Accenture -
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/  
    public static void createObjectShareRecords(List<Account> newAcctList) {

        Set<Id> accIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<String> uniqueKeySet = new Set<String>();
        Set<String> hostGeo = new Set<String>();
        try{
            if(newAcctList.size() > 0) {
                for(Account acc : newAcctList) {
                        accIdSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                        programIdSet.add(acc.Core_MDF_Channel_Program__c);
                        String accIdProgramId = (String)acc.Core_MDF_CoMarketing_Ultimate_Account__c + acc.Core_MDF_Channel_Program__c;
                        uniqueKeySet.add(accIdProgramId);
                        hostGeo.add(acc.Core_Geo__c);
                    }
                } 
            
            
            if(accIdSet.size() > 0 && programIdSet.size() > 0) {
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountShareRecords') &&
                mapFunctionalityNameTriggerExecution.get('createAccountShareRecords').Core_Active__c){
                 createAccountShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
               }
                if(mapFunctionalityNameTriggerExecution.containsKey('createCampaignShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createCampaignShareRecords').Core_Active__c){
                    createCampaignShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createPFRShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createPFRShareRecords').Core_Active__c){
                   createPFRShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createClaimAndPaymentShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createClaimAndPaymentShareRecords').Core_Active__c){
                    createClaimAndPaymentShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAuditDocumentShareRecords') &&
                mapFunctionalityNameTriggerExecution.get('createAuditDocumentShareRecords').Core_Active__c){
                 createAuditDocShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountUserShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountUserShareRecords').Core_Active__c){
                    createAccountUserShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }

                if(mapFunctionalityNameTriggerExecution.containsKey('createCaseShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createCaseShareRecords').Core_Active__c){
                    createCaseShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createEscalationShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createEscalationShareRecords').Core_Active__c){
                   createEscalationShareRecords(accIdSet, programIdSet, uniqueKeySet,hostGeo);
                }
                
            }


        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }
    }
    /***************************************************************************************************** 
    Method Name   :        createAccountShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createAccountShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {
        
        String accQuery = 'Select Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c,Core_Geo__c,Core_Sub_Geo__c,'
                          +'Core_MDF_Channel_Program__r.Name'
                          +' From Account WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Account', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Account));
    }

    /***************************************************************************************************** 
    Method Name   :        createCampaignShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Campaign Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        NK-Date:18/10/2022 Changes: Added Core_MDF_Market__c field in SOQL
    ******************************************************************************************************/ 
    public static void createCampaignShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {

        String accQuery = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, Core_MDF_Market__c,Core_MDF_Program__c, Core_MDF_Channel_Program__c , Core_MDF_Account__c,Core_MDF_Region_cd__c, '
        +'Core_MDF_Sub_Region_cd__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_External_Visibility_Date__c,'
        +'Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Host_Region_cd__c,Core_MDF_Proposal_Based_Ind__c FROM Campaign WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Campaign', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Claim));
    }
    
    /***************************************************************************************************** 
    Method Name   :        createAccountUserShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account User Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createAccountUserShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {
        String accQuery = 'SELECT Id, Core_MDF_Active_Ind__c,Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
                          +'Core_MDF_Account__r.Core_MDF_Channel_Program__c '
                          +'FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Active_Ind__c = TRUE AND Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN ';

        /*Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_HostGeoPNUMShareInsert('Core_MDF_Partner_Node_User_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_PNUM));*/
    }
    
    
    /***************************************************************************************************** 
    Method Name   :        createPFRShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for PFR Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createPFRShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {

        String accQuery = 'SELECT Id, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,'
        +'ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c'
        +' FROM PartnerFundRequest WHERE Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Integer batchSize = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PGM_Batch_Size_PFR'));
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('PartnerFundRequest', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet,
                                                                                                uniqueKeySet,hostGeo),batchSize);
    }
    
    /***************************************************************************************************** 
    Method Name   :        createClaimAndPaymentShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for PFC & Payment Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createClaimAndPaymentShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {

        String accQuery = 'SELECT Id,Core_MDF_Type_Txt__c, Core_MDF_AccountCompany__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Program__c, '
        +'ChannelPartner.Core_MDF_Channel_Program__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,RequestId,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Country_Location_nm__c, Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c, Amount, ChannelPartnerId,ChannelPartner.Core_MDF_Group_Id__c, '
        +'Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Status__c, Core_MDF_Payment_Id__c, '
        +'ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Budget_Type_Options_Nm__c '
        +'FROM PartnerFundClaim WHERE Core_MDF_Claim_Id__c = null AND ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('PartnerFundClaim', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Claim)); 
    }

     /***************************************************************************************************** 
    Method Name   :        createAuditDocShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Audit Document Share
    Added By      :        Accenture - Sandesh - 7/21/2023
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    
    public static void createAuditDocShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {

        String accQuery = 'SELECT Id,Core_MDF_Claim__r.Core_MDF_Type_Txt__c, Core_MDF_Claim__r.Core_MDF_AccountCompany__c,Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Claim__r.Core_MDF_Program__c, '
        +'Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__r.Name,Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Claim__r.RequestId,Core_MDF_Claim__r.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Claim__r.Core_MDF_Country_Location_nm__c, Core_MDF_Claim__r.Core_MDF_Region_Cd__c, Core_MDF_Claim__r.Core_MDF_Sub_Region_Cd__c, Core_MDF_Claim__r.Amount, Core_MDF_Claim__r.ChannelPartnerId,Core_MDF_Claim__r.ChannelPartner.Core_MDF_Group_Id__c, '
        +'Core_MDF_Claim__r.Core_MDF_Bank__c, Core_MDF_Claim__r.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Claim__r.Core_MDF_Status__c, Core_MDF_Claim__r.Core_MDF_Payment_Id__c, '
        +'Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Claim__r.Core_MDF_Budget_Type_Options_Nm__c '
        +'FROM Core_MDF_Audit_Document__c WHERE Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN '; 
        String programQuery = ' AND Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Core_MDF_Audit_Document__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_HostGeo_Batch_Size_For_Claim));
    }
       
    /***************************************************************************************************** 
    Method Name   :        createCaseShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Case Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:18/10/2022     Changes: Added Core_MDF_Budget_Type_nm__c to SOQL Query
    ******************************************************************************************************/ 
    public static void createCaseShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {

        String accQuery = 'SELECT Id, AccountId,OwnerId, Core_Account_Geo__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Account.Core_MDF_Channel_Program__c,Core_IPS_Account_Sub_Geo__c,Core_MDF_Channel_Program_txt__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Budget_Type_Txt__c'
        +' FROM Case WHERE Account.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Account.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Case', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Case));        
    }
    
    
    /***************************************************************************************************** 
    Method Name   :        createEscalationShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Escalation Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:            Changes: 
    ******************************************************************************************************/ 
    public static void createEscalationShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet, Set<String> hostGeo) {
        String accQuery = 'SELECT Id, recordTypeId, Core_MDF_Budget_ID_Number_id__c, Core_MDF_Case_ID_Number_id__c, Core_MDF_Co_Marketing_Activity_id__c, '
        +'Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program_id__c, '
        +'Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c '
        +'FROM Core_MDF_Escalation__c WHERE ' 
        + 'Core_MDF_Escalation_Name_txt__c != null AND '
        + 'Core_MDF_Activity_Name_txt__c != null AND '
        +'(Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet OR '
        +'Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet OR '
        +'Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN toAddIntelAccSet';
        String programQuery =  ') AND (Core_MDF_Channel_Program_id__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_CreateHostGeoBasedSharing('Core_MDF_Escalation__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet,hostGeo), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Escalation));

    }

}