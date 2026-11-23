/****************************************************************************************************************************************
 * Class Name        : Core_MDF_CreateBatchShareRecordsInternal
 * Created Date      : 11/24/2019
 * Modification Log
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - JV       11/24/2019         Batch class to call the respective objects sharing class
 *****************************************************************************************************************************************/
global class Core_MDF_CreateBatchShareRecordsInternal implements Database.Batchable<sObject> {

	global String sobjectName;	
	global String accQuery;
	global String programQuery;

	Set<Id> setOfAccountId = new Set<Id>();
	Set<Id> setOfProgramId = new Set<Id>();
	Set<String> accIdProgramIdSet = new Set<String>();
	
    
	//Constructor called from PGM_BatchHelper class
	global Core_MDF_CreateBatchShareRecordsInternal(String objectName, String firstQuery, String secondQuery, 
                                                    Set<Id> accIdSet, Set<Id> programIdSet, Set<String> uniqueKeySet) {
		this.sobjectName = objectName;
		this.accQuery = firstQuery;
		this.setOfAccountId = accIdSet;
		this.accIdProgramIdSet = uniqueKeySet;

		if(programIdSet != null) {
			this.setOfProgramId = programIdSet;
		}

		if(secondQuery != null) {
			this.programQuery = secondQuery;
		}
	}
    
	/*****************************************************************************************************
	   Method Name :   start
	   @return     :   List of records
	   @parameters :   Database.BatchableContext
	   Description :   It fetches all records based on input parameters
	   Added By    :   Accenture - VK - 11-24-2019
	   Modified By :                               Date:                   Changes:
	 ******************************************************************************************************/
	global Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            if(sobjectName == 'Core_MDF_Escalation__c') {
                accQuery = accQuery.replace('toAddIntelAccSet', ':setOfAccountId');
                return Database.getQueryLocator(accQuery + programQuery + ':setOfProgramId' + ')');
            }
            else if(programQuery != null && setOfProgramId != null) {
                return Database.getQueryLocator(accQuery + ':setOfAccountId' + programQuery + ':setOfProgramId');
            } 
            else {
                return Database.getQueryLocator(accQuery + ':setOfAccountId');
            }
        } catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }

	}

	/********************************************************************************************************
	   Method Name :   execute
	   @return     :   void
	   @parameters :   Database.BatchableContext
	   Description :   Calls the respective method for sharing
	   Added By    :   Accenture - VK - 11-24-2019
	   Modified By :                               Date:         Changes:
	 **********************************************************************************************************/
	global void execute(Database.BatchableContext bc, List<sObject> scope) {		            
        
        try{
            switch on sobjectName {
                when 'Account' {
                    List<Account> accList = (List<Account>) scope;
                    List<Account> accListToBeProcessed = new List<Account>();
                    
                    for(Account acc :accList) {
                        if(accIdProgramIdSet.contains((String) acc.Core_MDF_CoMarketing_Ultimate_Account__c + acc.Core_MDF_Channel_Program__c)){
                            accListToBeProcessed.add(acc);
                        }
                    }
                    
                    
                    if(accListToBeProcessed != NULL && accListToBeProcessed.Size() > 0) {
                        createAccountShareRecords(accListToBeProcessed);
                    }
                }
    
                when 'PartnerMarketingBudget' {
                    List<PartnerMarketingBudget> budgetList = (List<PartnerMarketingBudget>) scope;
                    List<PartnerMarketingBudget> budgetListToBeProcessed = new List<PartnerMarketingBudget>();
                    
                    for(PartnerMarketingBudget pmb :budgetList) {
                        if(accIdProgramIdSet.contains((String) pmb.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__c + pmb.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c)) {
                            budgetListToBeProcessed.add(pmb);
                        }
                    }
                    
                    if(budgetListToBeProcessed != NULL && budgetListToBeProcessed.Size() > 0) {
                        createBudgetShareRecords(budgetListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Budget_Cap__c' {
                    List<Core_MDF_Budget_Cap__c> budgetCapList = (List<Core_MDF_Budget_Cap__c>) scope;
                    List<Core_MDF_Budget_Cap__c> budgetCapListToBeProcessed = new List<Core_MDF_Budget_Cap__c>();
                    
                    for(Core_MDF_Budget_Cap__c bCap :budgetCapList) {
                        if(accIdProgramIdSet.contains((String) bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__c + bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c)) {
                            budgetCapListToBeProcessed.add(bCap);
                        }
                    }
                    
                    if(budgetCapListToBeProcessed != NULL && budgetCapListToBeProcessed.Size() > 0) {
                        createBudgetCapShareRecords(budgetCapListToBeProcessed);
                    }
                }
    
                when 'Campaign' {
                    List<Campaign> campaignList = (List<Campaign>) scope;
                    List<Campaign> campaignListToBeProcessed = new List<Campaign>();
                    
                    for(Campaign cmp :campaignList) {
                        if(accIdProgramIdSet.contains((String) cmp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + cmp.Core_MDF_Channel_Program__c)) {
                            campaignListToBeProcessed.add(cmp);
                        }
                    }
                    
                    if(campaignListToBeProcessed != NULL && campaignListToBeProcessed.Size() > 0) {
                        campaignShare(campaignListToBeProcessed);
                    }
                }
    
                when 'PartnerFundRequest' {
                    List<PartnerFundRequest> pfrList = (List<PartnerFundRequest>) scope;
                    List<PartnerFundRequest> pfrListToBeProcessed = new List<PartnerFundRequest>();
                    
                    for(PartnerFundRequest pfr :pfrList) {
                        if(accIdProgramIdSet.contains((String) pfr.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pfr.ChannelPartner.Core_MDF_Channel_Program__c)) {
                            pfrListToBeProcessed.add(pfr);
                        }
                    }
                    
                    if(pfrListToBeProcessed != NULL && pfrListToBeProcessed.Size() > 0) {
                        pfrShare(pfrListToBeProcessed);
                    }
                }
    
                when 'PartnerFundClaim' {
                    List<PartnerFundClaim> pfcList = (List<PartnerFundClaim>) scope;
                    List<PartnerFundClaim> pfcListToBeProcessed = new List<PartnerFundClaim>();
    
                    for(PartnerFundClaim pfc :pfcList) {
                        if(accIdProgramIdSet.contains((String) pfc.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + pfc.ChannelPartner.Core_MDF_Channel_Program__c)){
                            pfcListToBeProcessed.add(pfc);
                        }
                    }
                    
                    if(pfcListToBeProcessed != NULL && pfcListToBeProcessed.Size() > 0) {
                        createClaimAndPaymentShareRecords(pfcListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Adjustment_Request__c' {
                    List<Core_MDF_Adjustment_Request__c> adjRequestList = (List<Core_MDF_Adjustment_Request__c>) scope;
                    List<Core_MDF_Adjustment_Request__c> adjRequestListToBeProcessed = new List<Core_MDF_Adjustment_Request__c>();
                    
                    for(Core_MDF_Adjustment_Request__c adjReq :adjRequestList) {
                        if(accIdProgramIdSet.contains((String) adjReq.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + adjReq.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartner.Core_MDF_Channel_Program__c)){
                            adjRequestListToBeProcessed.add(adjReq);
                        }
                    }
                    
                    if(adjRequestListToBeProcessed != NULL && adjRequestListToBeProcessed.Size() > 0) {
                        createAdjustmentRequestShareRecords(adjRequestListToBeProcessed);
                    }
                }
    
                when 'Case' {
                    List<Case> caseList = (List<Case>) scope;
                    List<Case> caseListToBeProcessed = new List<Case>();
                    
                    for(Case cs : caseList) {
                        if(accIdProgramIdSet.contains((String) cs.Account.Core_MDF_CoMarketing_Ultimate_Account__c + cs.Account.Core_MDF_Channel_Program__c)){
                            caseListToBeProcessed.add(cs);
                        }
                    }
                    
                    if(caseListToBeProcessed != NULL && caseListToBeProcessed.Size() > 0) {
                        caseShare(caseListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Bank__c' {
    
                    Map<String, String> channelProgramBankProgramMap = new Map<String, String>();
                    Map<String, String> bankProgramChannelProgramIdMap = new Map<String, String>();
                    List<Core_MDF_Bank__c> bankList = (List<Core_MDF_Bank__c>) scope;
                    List<Core_MDF_Bank__c> bankListToBeProcessed = new List<Core_MDF_Bank__c>();
                    
                    for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem :([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                              FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])){
                        channelProgramBankProgramMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);
                    }
                    
                    for(ChannelProgram cp :[SELECT Id, Name
                                            FROM ChannelProgram
                                            WHERE Name IN :channelProgramBankProgramMap.keySet()])  {
                        if(channelProgramBankProgramMap.get(cp.Name) != NULL) {
                            bankProgramChannelProgramIdMap.put(channelProgramBankProgramMap.get(cp.Name), cp.Id);
                        }
                    }
                    
                    for(Core_MDF_Bank__c bank : bankList) {
                        for(String bankProgram : bank.Core_MDF_Program__c.Split(';')) {
                            if(accIdProgramIdSet.contains((String) bank.Core_MDF_Account__c + bankProgramChannelProgramIdMap.get(bankProgram))){
                                if(!bankListToBeProcessed.contains(bank)) {
                                    bankListToBeProcessed.add(bank);
                                }
                            }
                        }
                    }
    
                    if(bankListToBeProcessed != NULL && bankListToBeProcessed.Size() > 0) {
                        bankShare(bankListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Account_Bank_Mapping__c' {
    
                    List<Core_MDF_Account_Bank_Mapping__c> abmList = (List<Core_MDF_Account_Bank_Mapping__c>) scope;
                    List<Core_MDF_Account_Bank_Mapping__c> abmListToBeProcessed = new List<Core_MDF_Account_Bank_Mapping__c>();
                    
                    for(Core_MDF_Account_Bank_Mapping__c abm : abmList) {
                        if(accIdProgramIdSet.contains((String) abm.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + abm.Core_MDF_Account__r.Core_MDF_Channel_Program__c)){
                            abmListToBeProcessed.add(abm);
                        }
                    }
                    
                    if(abmListToBeProcessed != NULL && abmListToBeProcessed.Size() > 0) {
                        abmShare(abmListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Exception__c' {
                    
                    Map<String, String> channelProgramBankProgramMap = new Map<String, String>();
                    Map<String, String> exptProgramChannelProgramIdMap = new Map<String, String>();
                    List<Core_MDF_Exception__c> exptList = (List<Core_MDF_Exception__c>) scope;
                    List<Core_MDF_Exception__c> exptListToBeProcessed = new List<Core_MDF_Exception__c>();
                    
                    for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem :([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                              FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt])) {
                        channelProgramBankProgramMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);
                    }
                        
                    for(ChannelProgram cp :[SELECT Id, Name
                                            FROM ChannelProgram
                                            WHERE Name IN :channelProgramBankProgramMap.keySet()]){
                        if(channelProgramBankProgramMap.get(cp.Name) != NULL) {
                            exptProgramChannelProgramIdMap.put(channelProgramBankProgramMap.get(cp.Name), cp.Id);
                        }
                    }
                    
                    for(Core_MDF_Exception__c expt :exptList) {
                        for(String exptProgram :expt.Core_MDF_Program_nm__c.Split(';')) {
                            if((setOfProgramId.contains(exptProgramChannelProgramIdMap.get(exptProgram))) && expt.Core_MDF_Select_All_Accounts_ind__c == TRUE) {
                                exptListToBeProcessed.add(expt);
                            }
                            else if(expt.Core_MDF_Select_All_Accounts_ind__c == FALSE && expt.Core_MDF_Account_id__c != NULL &&
                                    accIdProgramIdSet.contains((String) expt.Core_MDF_Account_id__c + exptProgramChannelProgramIdMap.get(exptProgram))) {
                                        exptListToBeProcessed.add(expt);
                                    }
                        }
                    }                              
                    
                    if(exptListToBeProcessed != NULL && exptListToBeProcessed.Size() > 0) {
                        exceptionShare(exptListToBeProcessed);
                    }
                }
                
                when 'Core_MDF_Exception_Case_Mapping__c'{
                    List<Core_MDF_Exception_Case_Mapping__c> ecmList = (List<Core_MDF_Exception_Case_Mapping__c>) scope;
                    List<Core_MDF_Exception_Case_Mapping__c> ecmListToBeProcessed = new List<Core_MDF_Exception_Case_Mapping__c>();
                    
                    for(Core_MDF_Exception_Case_Mapping__c ecm :ecmList) {
                        if(accIdProgramIdSet.contains((String)ecm.Core_MDF_Case_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c+ecm.Core_MDF_Case_id__r.Account.Core_MDF_Channel_Program__c)){
                            ecmListToBeProcessed.add(ecm);
                        }
                    }
                    
                    if(ecmListToBeProcessed != NULL && ecmListToBeProcessed.Size() > 0){
                        ecmShare(ecmListToBeProcessed);
                    }
                }
                when 'Core_MDF_Escalation__c' {
                    List<Core_MDF_Escalation__c> escalationList = (List<Core_MDF_Escalation__c>) scope;
                    List<Core_MDF_Escalation__c> esclnToBeProcessed = new List<Core_MDF_Escalation__c>();
    
                    for(Core_MDF_Escalation__c escln :escalationList) {
                        if(escln.Core_MDF_Budget_ID_Number_id__c != NULL &&
                           (accIdProgramIdSet.contains((String) escln.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + escln.Core_MDF_Channel_Program_id__c))){
                               esclnToBeProcessed.add(escln);
                           }
                        else if(escln.Core_MDF_Case_ID_Number_id__c != NULL &&
                                (accIdProgramIdSet.contains((String) escln.Core_MDF_Case_ID_Number_id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c + escln.Core_MDF_Channel_Program_id__c))){
                                    esclnToBeProcessed.add(escln);
                                }
                        else if(escln.Core_MDF_Co_Marketing_Activity_id__c != NULL &&
                                (accIdProgramIdSet.contains((String) escln.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + escln.Core_MDF_Channel_Program_id__c))){
                                    esclnToBeProcessed.add(escln);
                                }
                    }
    
                    if(esclnToBeProcessed != NULL && esclnToBeProcessed.Size() > 0) {
                        escalationShare(esclnToBeProcessed);
                    }
                }
    
                when 'PartnerFundAllocation' {
                    List<PartnerFundAllocation> allocationList = (List<PartnerFundAllocation>) scope;
                    List<PartnerFundAllocation> pfaListToBeProcessed = new List<PartnerFundAllocation>();
                    
                    for(PartnerFundAllocation pfa :allocationList) {
                        if(accIdProgramIdSet.contains((String) pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__r.Id + pfa.Budget.Core_MDF_Program__r.Id)){
                            pfaListToBeProcessed.add(pfa);
                        }
                    }
                    
                    if(pfaListToBeProcessed != NULL && pfaListToBeProcessed.Size() > 0) {
                        createAllocationShareRecords(pfaListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Partner_Node_User_Mapping__c' {
                    List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = (List<Core_MDF_Partner_Node_User_Mapping__c>) scope;
                    List<Core_MDF_Partner_Node_User_Mapping__c> pnumListToBeProcessed = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                    
                    for(Core_MDF_Partner_Node_User_Mapping__c pnum :pnumList) {
                        if(accIdProgramIdSet.contains((String) pnum.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + pnum.Core_MDF_Account__r.Core_MDF_Channel_Program__c)){
                            pnumListToBeProcessed.add(pnum);
                        }
                    }
                    
                    if(pnumListToBeProcessed != NULL && pnumListToBeProcessed.Size() > 0) {
                        createAccountUserShareRecords(pnumListToBeProcessed);
                    }
                }
    
                when 'Core_MDF_Budget_Transfer_Log__c' {
                    List<Core_MDF_Budget_Transfer_Log__c> accountTransferLogList = (List<Core_MDF_Budget_Transfer_Log__c>) scope;
                    List<Core_MDF_Budget_Transfer_Log__c> accLogListToBeProcessed = new List<Core_MDF_Budget_Transfer_Log__c>();
                    
                    for(Core_MDF_Budget_Transfer_Log__c btl :accountTransferLogList) {
                        if(accIdProgramIdSet.contains((String) btl.Core_MDF_Source_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c + btl.Core_MDF_Source_Account__r.Core_MDF_Channel_Program__c)){
                            accLogListToBeProcessed.add(btl);
                        }
                    }
    
                    if(accLogListToBeProcessed != NULL && accLogListToBeProcessed.Size() > 0) {
                        createAccountTransferLogShareRecords(accLogListToBeProcessed);
                    }
                }
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createAccountShareRecords
	   @return       :        void
	   @parameters   :        List of Account
	   Description   :        method to call the flow for Account Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createAccountShareRecords(List<Account> accList) {
		// Prepare params to be passed to the
		//Map<String, Object> params = new Map<String, Object>();
        List<Map<String, Object>> paramsList = new List<Map<String, Object>>();
        
        try{        
            for(Account acc :accList) {
                Map<String, Object> params =new Map<String, Object>();
                if(acc.Core_MDF_Parent_Fund_Account__c == acc.Core_MDF_CoMarketing_Ultimate_Account__c) {
                    params.put('vCoMarketingRecordTypeBln', false);
                } else {
                    params.put('vCoMarketingRecordTypeBln', true);
                }
                params.put('vAccountId', acc.Id);
                params.put('vParentFundAccountId', acc.Core_MDF_Parent_Fund_Account__c);
                params.put('vProgram', acc.Core_MDF_Channel_Program__c);
                params.put('vCoMarketingUltimateAccount', acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                params.put('vRegionv', acc.Core_Geo__c);
                params.put('vSubRegion', acc.Core_Sub_Geo__c);
                params.put('Core_MDF_ProgramName', acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                Flow.Interview.Core_MDF_CreateAccountShareForInternalAccountManagers accountShareFlow = new Flow.Interview.Core_MDF_CreateAccountShareForInternalAccountManagers(params);
                accountShareFlow.start();            
            } 
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createBudgetShareRecords
	   @return       :        void
	   @parameters   :        List of PartnerMarketingBudget
	   Description   :        method to call flow for Budget Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createBudgetShareRecords(List<PartnerMarketingBudget> budgetList) {
		
        try{
            //Params to be passed to the Budget Sharing FLow
            Map<String, Object> params = new Map<String, Object>();
            for (PartnerMarketingBudget budget :budgetList) {
                params.put('so_BudgetRecord', budget);
                params.put('vAccountId', budget.Core_MDF_Budget_Partner__c);
                params.put('vBudgetId', budget.Id);
                params.put('vPGMAccountID', budget.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__c);
                params.put('vChannelProgram', budget.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c);
                params.put('vRegion', budget.Core_MDF_Budget_Partner__r.Core_Geo__c);
                params.put('vSubRegion', budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c);
                params.put('ProgramName', budget.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                // Call the Budget Sharing Flow
                Flow.Interview.Core_MDF_PartnerMarketingBudgetShare_Record_Creation budgetFLowInstance = new Flow.Interview.Core_MDF_PartnerMarketingBudgetShare_Record_Creation(params);
                budgetFLowInstance.start();
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createBudgetCapShareRecords
	   @return       :        void
	   @parameters   :        List of Budget Cap records
	   Description   :        method to call flow for Budget Cap Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createBudgetCapShareRecords(List<Core_MDF_Budget_Cap__c> budgetCapList) {
		
        try{
            //Params to be passed to the Budget Cap Sharing FLow
            Map<String, Object> params = new Map<String, Object>();
            for (Core_MDF_Budget_Cap__c budgetCap :budgetCapList) {
                params.put('vBudgetCapId', budgetCap.Id);
                params.put('vPGMAccountID', budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__c);
                params.put('vChannelProgram', budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_Channel_Program__c);
                params.put('so_BudgetCapRecord', budgetCap);
                // Call the Budget Cap Sharing Flow
                Flow.Interview.Core_MDF_BudgetCapShare_Record_Creation budgetCapFLowInstance = new Flow.Interview.Core_MDF_BudgetCapShare_Record_Creation(params);
                budgetCapFLowInstance.start();
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createAllocationShareRecords
	   @return       :        void
	   @parameters   :        List of pfa
	   Description   :        method to call flow for Allocation Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createAllocationShareRecords(List<PartnerFundAllocation> allocationList) {
		
        try{
            //Params to be passed to the Budget Sharing FLow
            Map<String, Object> params = new Map<String, Object>();
            for (PartnerFundAllocation pfa :allocationList) {
                params.put('vIntelAccountId', pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_Parent_Fund_Account__r.Id);
                params.put('vPFAId', pfa.Id);
                params.put('vProgram', pfa.Budget.Core_MDF_Program__r.Id);
                params.put('vRegion', pfa.Budget.Core_MDF_Budget_Partner__r.Core_Geo__c);
                params.put('vSubRegion', pfa.Budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c);
                params.put('ProgramName', pfa.Budget.Core_MDF_Program__r.Core_MDF_Technical_Program_Name__c);
                // Call the Budget Cap Sharing Flow
                Flow.Interview.Core_MDF_CreatePFAShareForInternalAccountManagers allocationFLowInstance = new Flow.Interview.Core_MDF_CreatePFAShareForInternalAccountManagers(params);
                allocationFLowInstance.start();
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createAccountUserShareRecords
	   @return       :        void
	   @parameters   :        List of pnums
	   Description   :        method to call class for PNUM Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createAccountUserShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> pnumList){
        
        try{
			Core_MDF_ManualSharing.sharingAccountUser(pnumList);
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createAccountTransferLogShareRecords
	   @return       :        void
	   @parameters   :        List of Account Transfer Log
	   Description   :        method to call class for Account Transfer Log Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createAccountTransferLogShareRecords(List<Core_MDF_Budget_Transfer_Log__c> accountTransferLogList){
        
        try{
			Core_MDF_ManualSharing.sharingAccountTransfer(accountTransferLogList);
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        campaignShare
	   @return       :        void
	   @parameters   :        List of Campaigns
	   Description   :        method to call batch for Campaign Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void campaignShare(List<Campaign> campaignList) {
		
        try{
            if(campaignList.size() > 0) {
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(campaignList, null, true, false);
            }	
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        pfrShare
	   @return       :        void
	   @parameters   :        List of PFR
	   Description   :        method to call class for PFR Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void pfrShare(List<PartnerFundRequest> pfrList) {
		
        try{
            List<Id> pfrIdList = new List<Id>();
            for(PartnerFundRequest pFRRecord :pfrList) {
                pfrIdList.add(pFRRecord.Id);
            }
            if(pfrIdList.size() > 0) {
                Core_MDF_GeoBasedGenericSharing.createShareForPFR(pfrIdList);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createClaimAndPaymentShareRecords
	   @return       :        void
	   @parameters   :        List of Claims
	   Description   :        method to call class for PFC & Payment Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createClaimAndPaymentShareRecords(List<PartnerFundClaim> pfcList) {
		
        try{
            Core_MDF_PFC_Sharing.shareClaimToInternalUsers(pfcList);
    
            List<PartnerFundClaim> paidClaimList = new List<PartnerFundClaim>();
            //looping through the Claims and Passing the Paid / Pending Payment Claims to Share the Payment Records
            for(PartnerFundClaim pfc :pfcList) {
                if((pfc.Core_MDF_Status__c == 'Pending Payment' || pfc.Core_MDF_Status__c == 'Paid') && pfc.Core_MDF_Payment_Id__c != NULL) {
                    paidClaimList.add(pfc);
                }
            }
            
            if(paidClaimList != NULL && paidClaimList.Size() > 0) {
                Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap = Core_MDF_PaymentProcess.groupClaimsforPayment(paidClaimList);
                // Call the Payment Share method for Internal sharing
                Core_MDF_Payment_Sharing.sharePaymentRecordsToInternalUsers(paymentWrapperMap);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        createAdjustmentRequestShareRecords
	   @return       :        void
	   @parameters   :        List of Adjustment Request records
	   Description   :        method to call class for Adjustment Share
	   Added By      :        Accenture - JV - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createAdjustmentRequestShareRecords(List<Core_MDF_Adjustment_Request__c> adjRequestList) {
		
        try{
			Core_MDF_AdjustmentRequest_Sharing.shareAdjustmentRequestToInternalUsers(adjRequestList);
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        caseShare
	   @return       :        void
	   @parameters   :        List of Case
	   Description   :        method to call class for Case Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void caseShare(List<Case> caseList) {
		
        try{
            if(caseList.size() > 0) {
                Core_MDF_ClaimReviewCaseShare.claimReviewCaseShare(caseList);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        bankShare
	   @return       :        void
	   @parameters   :        List of Bank
	   Description   :        method to call class for Bank Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void bankShare(List<Core_MDF_Bank__c> bankList) {

        try{
            List<Id> bankIdList = new List<Id>();
            for(Core_MDF_Bank__c bank :bankList) {
                bankIdList.add(bank.Id);
            }
            if(bankIdList.size() > 0) {
                Core_MDF_GeoBasedGenericSharing.createShareForBank(bankIdList);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        abmShare
	   @return       :        void
	   @parameters   :        List of ABM
	   Description   :        method to call class for ABM Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void abmShare(List<Core_MDF_Account_Bank_Mapping__c> abmList) {

        try{
            Map<Id, Core_MDF_Account_Bank_Mapping__c> abmMap = new Map<Id, Core_MDF_Account_Bank_Mapping__c>();
            for(Core_MDF_Account_Bank_Mapping__c abm :abmList) {
                abmMap.put(abm.Id, abm);
            }
            if(abmMap.size() > 0) {
                Core_MDF_BankAccountServiceHandler.createABMShareForInternalUsers(abmMap);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        exceptionShare
	   @return       :        void
	   @parameters   :        List of Exception
	   Description   :        method to call class for Exception Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void exceptionShare(List<Core_MDF_Exception__c> exptList) {

        try{
            Map<Id, Core_MDF_Exception__c> exceptionMap = new Map<Id, Core_MDF_Exception__c>();
            for(Core_MDF_Exception__c expt :exptList) {
                exceptionMap.put(expt.Id, expt);
            }
            if(exceptionMap.size() > 0) {
                Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(exceptionMap, false);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name   :        escalationShare
	   @return       :        void
	   @parameters   :        List of Escalation
	   Description   :        method to call class for Escalation Share
	   Added By      :        Accenture - VK - 11/24/2019
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void escalationShare(List<Core_MDF_Escalation__c> escalationList) {

        try{
            Map<Id, Core_MDF_Escalation__c> escalationMap = new Map<Id, Core_MDF_Escalation__c>();
    
            for(Core_MDF_Escalation__c escalation :escalationList) {
                escalationMap.put(escalation.Id, escalation);
            }
            if(escalationMap.size() > 0) {
                Core_MDF_Escalation_ServiceHandler.shareEscalation(escalationMap, null, true);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}
    
    /*****************************************************************************************************
	   Method Name   :        ecmShare
	   @return       :        void
	   @parameters   :        List of Exception Case Mapping
	   Description   :        method to call class for ECM Share
	   Added By      :        Accenture - VK - 11/24/2019O
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
    public void ecmShare(List<Core_MDF_Exception_Case_Mapping__c> ecmList) {

        try{
            Map<Id,Core_MDF_Exception_Case_Mapping__c> ecmIdMap = new Map<Id,Core_MDF_Exception_Case_Mapping__c>();
            
            for(Core_MDF_Exception_Case_Mapping__c ecm : ecmList) {
                ecmIdMap.put(ecm.Id, ecm);
            }
            
            if(ecmIdMap.size() > 0) {
                Core_MDF_ExpCaseMp_TriggerServiceHandler.shareECMRecordWithusers(ecmIdMap);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

	/*****************************************************************************************************
	   Method Name :   finish
	   @return     :   void
	   @parameters :   Database.BatchableContext
	   Description :
	   Added By    :   Accenture - VK - 11-24-2019
	   Modified By :                               Date:                     Changes:None
	 ******************************************************************************************************/
	global void finish(Database.BatchableContext bc) {
		
	}    
}