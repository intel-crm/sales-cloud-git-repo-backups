/****************************************************************************************************************************************
* Class Name        : Core_MDF_PGM_BatchHelper
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
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/  
	public static void createObjectShareRecords(List<Core_MDF_Partner_Group_Mapping__c> newPGMList) {

		Set<Id> accIdSet = new Set<Id>();
		Set<Id> programIdSet = new Set<Id>();
		Set<String> uniqueKeySet = new Set<String>();
		try{
			if(newPGMList.size() > 0) {
				for(Core_MDF_Partner_Group_Mapping__c pgm : newPGMList) {
					if(pgm.Core_MDF_Type_of_Access__c == 'Internal'){
						accIdSet.add(pgm.Core_MDF_Account__c);
						programIdSet.add(pgm.Core_MDF_Channel_Program__c);
						String accIdProgramId = (String)pgm.Core_MDF_Account__c + pgm.Core_MDF_Channel_Program__c;
						uniqueKeySet.add(accIdProgramId);
					}
				} 
			}
            
			if(accIdSet.size() > 0 && programIdSet.size() > 0) {
                
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountShareRecords').Core_Active__c){
                    createAccountShareRecords(accIdSet, programIdSet, uniqueKeySet);
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
				
                if(mapFunctionalityNameTriggerExecution.containsKey('createAllocationShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAllocationShareRecords').Core_Active__c){
                    createAllocationShareRecords(accIdSet, programIdSet, uniqueKeySet);
                }
				
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountUserShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountUserShareRecords').Core_Active__c){
                    createAccountUserShareRecords(accIdSet, programIdSet, uniqueKeySet);
                }
				
                if(mapFunctionalityNameTriggerExecution.containsKey('createAccountTransferLogShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createAccountTransferLogShareRecords').Core_Active__c){
                    createAccountTransferLogShareRecords(accIdSet, programIdSet, uniqueKeySet);
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
                    createExceptionShareRecords(accIdSet, programIdSet, uniqueKeySet);
                }
				
                if(mapFunctionalityNameTriggerExecution.containsKey('createEscalationShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createEscalationShareRecords').Core_Active__c){
                    createEscalationShareRecords(accIdSet, programIdSet, uniqueKeySet);
                }
				
                if(mapFunctionalityNameTriggerExecution.containsKey('createECMShareRecords') &&
                   mapFunctionalityNameTriggerExecution.get('createECMShareRecords').Core_Active__c){
                    createECMShareRecords(accIdSet, programIdSet, uniqueKeySet);
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
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createAccountShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {
        
		String accQuery = 'Select Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c,Core_Geo__c,Core_Sub_Geo__c,'
						  +'Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,'
						  +'Core_MDF_Parent_Fund_Account__c From Account WHERE Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Account', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Account));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createBudgetShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Budget Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createBudgetShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet){
        
		String accQuery = 'Select Id,Core_MDF_Budget_Partner__c,Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__c, '
					   	  +'Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c,Core_MDF_Budget_Partner__r.Core_Geo__c, Core_MDF_Budget_Status__c, '
		  				  +'Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c '
					 	  +'From PartnerMarketingBudget WHERE Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Core_MDF_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerMarketingBudget', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Budget));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createBudgetCapShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Budget Cap Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createBudgetCapShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet){
        
		String accQuery = 'Select Id,Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__c,'
						  +' Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c, Core_MDF_Budget_Status_txt__c '
						  +' From Core_MDF_Budget_Cap__c WHERE Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Budget_Cap__c', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet),Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Budget_Cap));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createCampaignShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Campaign Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createCampaignShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, RecordTypeId, Core_MDF_Program__c, Core_MDF_Channel_Program__c , Core_MDF_Account__c,Core_MDF_Region_cd__c, '
		+'Core_MDF_Sub_Region_cd__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_External_Visibility_Date__c'
		+' FROM Campaign WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Core_MDF_Channel_Program__c IN ';
		Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Campaign', accQuery, programQuery, 
												   intelAccIdSet, channelProgramIdSet, uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Campaign));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createAllocationShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Allocation Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createAllocationShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Budget.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__r.Id, '
		+'Budget.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c, Budget.Core_MDF_Program__r.Id, '
		+'Budget.Core_MDF_Budget_Partner__r.Core_Geo__c,Budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c '
		+'FROM PartnerFundAllocation WHERE Budget.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__r.Id IN ';
		String programQuery = ' AND Budget.Core_MDF_Program__r.Id IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerFundAllocation', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Allocation)); 
	}
	
    /***************************************************************************************************** 
    Method Name   :        createAccountUserShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account User Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createAccountUserShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, '
            			  +'Core_MDF_Account__r.Core_MDF_Channel_Program__c '
			   			  +'FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Partner_Node_User_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_PNUM));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createAccountTransferLogShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Account Transfer Log Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createAccountTransferLogShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Core_MDF_Source_Account__c, Core_MDF_Source_Account__r.Core_MDF_Channel_Program__c, '
            			  +'Core_MDF_Source_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
						  +'FROM Core_MDF_Budget_Transfer_Log__c WHERE Core_MDF_Source_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery = ' AND Core_MDF_Source_Account__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Budget_Transfer_Log__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Acc_Transfer_Log));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createPFRShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for PFR Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createPFRShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,'
		+'ChannelPartner.Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c'
		+' FROM PartnerFundRequest WHERE Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerFundRequest', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet,
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_PFR));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createClaimAndPaymentShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for PFC & Payment Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createClaimAndPaymentShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Core_MDF_AccountCompany__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Program__c, '
		+'ChannelPartner.Core_MDF_Channel_Program__r.Name,RequestId,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, '
        +'Core_MDF_Country_Location_nm__c, Core_MDF_Region_Cd__c, Core_MDF_Sub_Region_Cd__c, Amount, ChannelPartnerId, '
        +'Core_MDF_Bank__c, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Status__c, Core_MDF_Payment_Id__c, '
        +'ChannelPartner.Core_MDF_Channel_Program__c, Core_MDF_Budget_Type_Nm__c '
		+'FROM PartnerFundClaim WHERE ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('PartnerFundClaim', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Claim)); 
	}
	
    /***************************************************************************************************** 
    Method Name   :        createAdjustmentRequestShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Adjustment Share
    Added By      :        Accenture - JV - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createAdjustmentRequestShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_Channel_Program__c, '
		+'Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c'
		+' FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Adjustment_Request__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Adjsutment_Request));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createCaseShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Case Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createCaseShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, AccountId, Core_Account_Geo__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, '
		+'Account.Core_MDF_Channel_Program__c,Core_IPS_Account_Sub_Geo__c,Core_MDF_Channel_Program_txt__c'
		+' FROM Case WHERE Account.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Account.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Case', accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Case));		
	}
	
    /***************************************************************************************************** 
    Method Name   :        createBankShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Bank Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createBankShareRecords(Set<Id> intelAccIdSet, Set<String>  uniqueKeySet) {

		String query = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Program__c,Core_MDF_ESD_Update__c FROM Core_MDF_Bank__c '
		+'WHERE Core_MDF_ESD_Update__c = TRUE AND Core_MDF_Account__c IN ';

        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Bank__c', 
                                                                                                query, null, 
                                                                                                intelAccIdSet, null, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Bank));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createAccBankMappingShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for ABM Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createAccBankMappingShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String accQuery = 'SELECT Id, Core_MDF_Account__r.Core_MDF_Channel_Program__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c '
		+'FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
		String programQuery = ' AND Core_MDF_Account__r.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Account_Bank_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_ABM));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createExceptionShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Exception Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/ 
	public static void createExceptionShareRecords(Set<Id> intelAccIdSet,Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet) {

		String query = 'SELECT Id, Core_MDF_Account_id__c, Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Program_nm__c,Core_MDF_Country_Region_nm__c, '
		+'Core_MDF_Select_All_Country_ind__c FROM Core_MDF_Exception__c WHERE Core_MDF_Select_All_Accounts_ind__c = TRUE OR Core_MDF_Account_id__c IN ';

        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Exception__c', 
                                                                                                query, null, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Exception));
	}
	
    /***************************************************************************************************** 
    Method Name   :        createEscalationShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Escalation Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
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
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_Escalation));

	}
    
    /***************************************************************************************************** 
    Method Name   :        createECMShareRecords
    @return       :        void
    @parameters   :        Set of AccountId, Set of ProgramId and Set of AccId+ProgramId
    Description   :        method to call batch for Exception Case Mapping Share
    Added By      :        Accenture - VK - 11/24/2019
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/
    public static void createECMShareRecords(Set<Id> intelAccIdSet, Set<Id> channelProgramIdSet, Set<String>  uniqueKeySet){
        
        String accQuery = 'SELECT Id, Core_MDF_Case_id__c,Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c, '
            +'Core_MDF_Exception_id__c, Core_MDF_Case_id__r.Account.Core_MDF_Channel_Program__c FROM Core_MDF_Exception_Case_Mapping__c WHERE '
            +'Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c IN ';
        String programQuery =  ' AND Core_MDF_Case_id__r.Account.Core_MDF_Channel_Program__c IN ';
        Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecordsInternal('Core_MDF_Exception_Case_Mapping__c', 
                                                                                                accQuery, programQuery, 
                                                                                                intelAccIdSet, channelProgramIdSet, 
                                                                                                uniqueKeySet), Integer.valueOf(Label.Core_MDF_PGM_Batch_Size_For_ECM));
    }
}