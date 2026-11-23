/****************************************************************************************************************************************
 * Class Name        : Core_MDF_CreateBatchShareRecordsInternal
 * Test Class		: Core_MDF_PGM_BatchHelper_Test
 * Created Date      : 11/24/2019
 * Modification Log
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - JV       11/24/2019         Batch class to call the respective objects sharing class
 *****************************************************************************************************************************************/
global without sharing class Core_MDF_CreateBatchShareRecordsInternal implements Database.Batchable<sObject>,Database.AllowsCallouts {

	global String sobjectName;	
	global String accQuery;
	global String programQuery;

	Set<Id> setOfAccountId = new Set<Id>();
	Set<Id> setOfProgramId = new Set<Id>();
	Set<String> accIdProgramIdSet = new Set<String>();
	Map<ID,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap = new Map<ID,List<Core_MDF_Partner_Mapping__c>>();
    String primaryPartnerType = Core_MDF_CCP_ConstantClass.PRIMARY_PARTNER;

	//Constructor called from PGM_BatchHelper class
	global Core_MDF_CreateBatchShareRecordsInternal(String objectName, String firstQuery, String secondQuery, 
                                                    Set<Id> accIdSet, Set<Id> programIdSet, Set<String> uniqueKeySet,  Map<Id,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap) {
		this.sobjectName = objectName;
		this.accQuery = firstQuery;
		this.setOfAccountId = accIdSet;
		this.accIdProgramIdSet = uniqueKeySet;
        this.primaryIntelAccIdToPartnerMap = primaryIntelAccIdToPartnerMap;

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
                if(sobjectName == 'Core_MDF_Budget_Transfer_Log__c') {
                    return Database.getQueryLocator(accQuery + programQuery + ':setOfProgramId');    
                }else{
                    return Database.getQueryLocator(accQuery + ':setOfAccountId' + programQuery + ':setOfProgramId'); 
                }
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
                        createAccountShareRecords(accListToBeProcessed,primaryIntelAccIdToPartnerMap);
                    }
                }
                
                when 'Core_MDF_Partnership_Score__c' {
                    List<Core_MDF_Partnership_Score__c> psList = (List<Core_MDF_Partnership_Score__c>) scope;
                    List<Core_MDF_Partnership_Score__c> psListToBeProcessed = new List<Core_MDF_Partnership_Score__c>();
                    
                    for(Core_MDF_Partnership_Score__c ps :psList) {
                        if(accIdProgramIdSet.contains((String) ps.Core_MDF_Account_Id__c + ps.Core_MDF_Channel_Program_Id__c)){
                            psListToBeProcessed.add(ps);
                        }
                    }
                    if(psListToBeProcessed != NULL && psListToBeProcessed.Size() > 0) {
                        createPartnerShipScoreShareRecords(psListToBeProcessed);
                    }
                }
    
                when 'PartnerMarketingBudget' {
                    List<PartnerMarketingBudget> budgetList = (List<PartnerMarketingBudget>) scope;
                    List<PartnerMarketingBudget> budgetListToBeProcessed = new List<PartnerMarketingBudget>();
                    
                    for(PartnerMarketingBudget pmb :budgetList) {
                        if(accIdProgramIdSet.contains((String) pmb.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + pmb.Core_MDF_Program__c)) {
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
                        if(accIdProgramIdSet.contains((String) bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + bCap.Core_MDF_Budget_Name_id__r.Core_MDF_Program__c)) {
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
                 
                when 'Core_MDF_Camp_to_ActPartner__c' {
                    List<Core_MDF_Camp_to_ActPartner__c> campToActivatingList = (List<Core_MDF_Camp_to_ActPartner__c>) scope;
                    List<Core_MDF_Camp_to_ActPartner__c> campToActivatingListToBeProcessed = new List<Core_MDF_Camp_to_ActPartner__c>();
                    
                    for(Core_MDF_Camp_to_ActPartner__c cmp : campToActivatingList) {
                        if(accIdProgramIdSet.contains((String) cmp.Core_MDF_PrimPartner_Ultimate_Acc_Id__c + cmp.Core_MDF_Channel_Program__c)) {
                            campToActivatingListToBeProcessed.add(cmp);
                        }
                    }
                    if(campToActivatingListToBeProcessed != NULL && campToActivatingListToBeProcessed.Size() > 0) {
                        campToActShare(campToActivatingListToBeProcessed);
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
                
                when 'Core_MDF_Audit_Document__c'{
                    
                    List<Core_MDF_Audit_Document__c> auditDocList = (List<Core_MDF_Audit_Document__c>) scope;
                    List<Core_MDF_Audit_Document__c> auditDocListToBeProcessed = new List<Core_MDF_Audit_Document__c>();
                    
                    for(Core_MDF_Audit_Document__c auditDoc :auditDocList) {
                        if(accIdProgramIdSet.contains((String) auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + auditDoc.Core_MDF_Claim__r.ChannelPartner.Core_MDF_Channel_Program__c)){
                            auditDocListToBeProcessed.add(auditDoc);
                        }
                    }
                    
                    if(auditDocListToBeProcessed != NULL && auditDocListToBeProcessed.Size() > 0) {
                        createAuditDocShareRecords(auditDocListToBeProcessed);
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
                                                                              FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt LIMIT 1000])){
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
    
                /*when 'Core_MDF_Exception__c' {
                    
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
                            if(expt.Core_MDF_Select_All_Accounts_ind__c == FALSE && expt.Core_MDF_Account_id__c != NULL &&
                                    accIdProgramIdSet.contains((String) expt.Core_MDF_Account_id__c + exptProgramChannelProgramIdMap.get(exptProgram))) {
                                        exptListToBeProcessed.add(expt);
                                    }
                        }
                    }                              
                    
                    if(exptListToBeProcessed != NULL && exptListToBeProcessed.Size() > 0) {
                        exceptionShare(exptListToBeProcessed);
                    }
                }*/
                
                 when 'Core_MDF_Exception_Account_Mapping__c' {
                    
                    Map<String, String> channelProgramBankProgramMap = new Map<String, String>();
                    Map<String, String> exptProgramChannelProgramIdMap = new Map<String, String>();
                    List<Core_MDF_Exception_Account_Mapping__c> exptList = (List<Core_MDF_Exception_Account_Mapping__c>) scope;
                    List<Core_MDF_Exception_Account_Mapping__c> exptListToBeProcessed = new List<Core_MDF_Exception_Account_Mapping__c>();
                    
                    for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem :([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                              FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt LIMIT 1000])) {
                        channelProgramBankProgramMap.put(bpem.Core_MDF_Channel_Program__c, bpem.Core_MDF_Bank_Program_Name__c);
                    }
                        
                    for(ChannelProgram cp :[SELECT Id, Name
                                            FROM ChannelProgram
                                            WHERE Name IN :channelProgramBankProgramMap.keySet()]){
                        if(channelProgramBankProgramMap.get(cp.Name) != NULL) {
                            exptProgramChannelProgramIdMap.put(channelProgramBankProgramMap.get(cp.Name), cp.Id);
                        }
                    }
                    
                    for(Core_MDF_Exception_Account_Mapping__c expt :exptList) {
                        for(String exptProgram :expt.Core_MDF_Program_nm__c.Split(';')) {
                            if(expt.Core_MDF_Select_All_Accounts_ind__c == FALSE && expt.Core_MDF_Account_id__c != NULL &&
                                accIdProgramIdSet.contains((String) expt.Core_MDF_Account_id__c + exptProgramChannelProgramIdMap.get(exptProgram))) {
                                    exptListToBeProcessed.add(expt);
                            }
                        }
                    }                              
                    
                    if(exptListToBeProcessed != NULL && exptListToBeProcessed.Size() > 0) {
                        exceptionAccountMapShare(exptListToBeProcessed);
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
                    
                    /*if(ecmListToBeProcessed != NULL && ecmListToBeProcessed.Size() > 0){
                        ecmShare(ecmListToBeProcessed);
                    }*/
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
                        if(accIdProgramIdSet.contains((String) pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c + pfa.Budget.Core_MDF_Program__c)){
                            pfaListToBeProcessed.add(pfa);
                        }
                    }
                    
                    if(pfaListToBeProcessed != NULL && pfaListToBeProcessed.Size() > 0) {
                        createAllocationShareRecords(pfaListToBeProcessed);
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
	public void createAccountShareRecords(List<Account> accList, Map<Id,List<Core_MDF_Partner_Mapping__c>> primaryIntelAccIdToPartnerMap) {
		List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        try{  
            Set<Id> primaryIntelAcctIdSet = new Set<Id>();      
            for(Account acc :accList) {
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(acc.ID,acc.Core_Geo__c,acc.Core_Sub_Geo__c,acc.Core_MDF_Channel_Program__r.Name,acc.Core_MDF_CoMarketing_Ultimate_Account__c));                          
                if(acc.Core_MDF_Channel_Program__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && acc.Core_MDF_Partner_Type_nm__c !=null && acc.Core_MDF_Partner_Type_nm__c.contains(primaryPartnerType)) {
                    primaryIntelAcctIdSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                }
            } 
            if(primaryIntelAcctIdSet != null && primaryIntelAcctIdSet.size() >0) {
               for(Id acc : primaryIntelAcctIdSet) {
                 if(primaryIntelAccIdToPartnerMap.containsKey(acc)) {
                   for(Core_MDF_Partner_Mapping__c rec : primaryIntelAccIdToPartnerMap.get(acc)) {
                     recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(rec.Core_MDF_Activating_Partner_Account_id__c,null,null,rec.Core_MDF_Activating_Partner_Account_id__r.Core_MDF_Channel_Program__r.Name,null,rec.Core_MDF_PrimPartner_Ultimate_Acc_Id__c,'Read'));    
                    }
                }   
              }
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Account', recordPGMShareList);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}
    
    /*****************************************************************************************************
	   Method Name   :        createPartnerShipScoreShareRecords
	   @return       :        void
	   @parameters   :        List of partnership score
	   Added By      :        Accenture
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void createPartnerShipScoreShareRecords(List<Core_MDF_Partnership_Score__c> psList) {
		List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        try{        
            for(Core_MDF_Partnership_Score__c ps :psList) {
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(ps.ID,ps.Core_MDF_Account_Id__r.Core_Geo__c,ps.Core_MDF_Account_Id__r.Core_Sub_Geo__c,ps.Core_MDF_Channel_Program_Id__r.Name,ps.Core_MDF_Account_Id__c));                
            } 
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Partnership_Score__c', recordPGMShareList);
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
            // Create a set of program names from metadata directly in the query loop
            Set<String> programNamesFromMetadata = new Set<String>();
            for (Core_MDF_ChannelProgram__mdt mdtRec : [
            SELECT DeveloperName, Core_MDF_Program_ID__c, Label, Core_MDF_BudgetTypeBasedSharing_Ind__c 
            FROM Core_MDF_ChannelProgram__mdt
            WHERE Core_MDF_BudgetTypeBasedSharing_Ind__c  = True]) {
            programNamesFromMetadata.add(mdtRec.Label);
            }
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
            for (PartnerMarketingBudget budget :budgetList) {
                if (programNamesFromMetadata != null && programNamesFromMetadata.contains(budget.Core_MDF_Program__r.Name)) {
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(budget.id, budget.Core_MDF_Budget_Partner__r.Core_Geo__c,budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,budget.Core_MDF_Program__r.Name,budget.Core_MDF_Budget_Type_Txt__c,budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c));
                }else{
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(budget.id, budget.Core_MDF_Budget_Partner__r.Core_Geo__c,budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c,budget.Core_MDF_Program__r.Name,budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c));
                }                 
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerMarketingBudget', recordPGMShareList);
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
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
            for (Core_MDF_Budget_Cap__c budgetCap :budgetCapList) {                
                if(budgetCap.Core_MDF_Budget_Name_id__c != NULL){
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(budgetCap.id, budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Geo__c, budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c, budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Program__r.Name, budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c));
                }
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Budget_Cap__c', recordPGMShareList);
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
		String ACTIVATING_PARTNER = Core_MDF_CCP_ConstantClass.ACTIVATING_PARTNER ;     
        try{
         // Create a set of program names from metadata directly in the query loop
            Set<String> programNamesFromMetadata = new Set<String>();
            for (Core_MDF_ChannelProgram__mdt mdtRec : [
            SELECT DeveloperName, Core_MDF_Program_ID__c, Label, Core_MDF_BudgetTypeBasedSharing_Ind__c 
            FROM Core_MDF_ChannelProgram__mdt
            WHERE Core_MDF_BudgetTypeBasedSharing_Ind__c  = True]) {
            programNamesFromMetadata.add(mdtRec.Label);
            }
            List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
            for (PartnerFundAllocation pfa :allocationList) {
            if (programNamesFromMetadata != null && programNamesFromMetadata.contains(pfa.Budget.Core_MDF_Program__r.Name)) {
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfa.id, pfa.Budget.Core_MDF_Budget_Partner__r.Core_Geo__c, pfa.Budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c, pfa.Budget.Core_MDF_Program__r.Name, pfa.Budget.Core_MDF_Budget_Type_Txt__c, pfa.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                    
                    if(pfa.Budget.Core_MDF_Program__r.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && 
                       ((pfa.ChannelPartner.Core_MDF_Partner_Type_nm__c != NULL && pfa.ChannelPartner.Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER) && pfa.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c != pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c) ||
                        (pfa.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__c != NULL && pfa.ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__r.Core_MDF_Partner_Type_nm__c.contains(ACTIVATING_PARTNER)))
                      ){
                          recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfa.id, pfa.Budget.Core_MDF_Budget_Partner__r.Core_Geo__c, pfa.Budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c, pfa.Budget.Core_MDF_Program__r.Name, pfa.Budget.Core_MDF_Budget_Type_Txt__c, pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c));
                      }
                }else{
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfa.id, pfa.Budget.Core_MDF_Budget_Partner__r.Core_Geo__c, pfa.Budget.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c, pfa.Budget.Core_MDF_Program__r.Name, pfa.Budget.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c));
                } 
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerFundAllocation', recordPGMShareList);
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
	/*public void createAccountUserShareRecords(List<Core_MDF_Partner_Node_User_Mapping__c> pnumList){
        
        try{
			Core_MDF_ManualSharing.sharingAccountUser(pnumList);
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}*/

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
   
            if(campaignList != NULL && campaignList.Size() > 0){
                Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign(campaignList, null, true, false);
            }
            
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}
  /*****************************************************************************************************
	   Method Name   :        campToActShare
	   @return       :        void
	   @parameters   :        List of Core_MDF_Camp_to_ActPartner__c
	   Description   :        method to call batch for campToActShare
	   Added By      :        Accenture MD - 4/16/2024
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
   public void campToActShare(List<Core_MDF_Camp_to_ActPartner__c> campToActPartnerList)
   {
      try{
            if(campToActPartnerList != NULL && campToActPartnerList.Size() > 0){
                Core_MDF_CampActPartnerServiceHandler.shareCamToActPartner(campToActPartnerList);
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
		List<String> legacyPaidclmStsLst = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_PostPaid_Legacy_Claim_Statuses');
        try{
           
    
            List<PartnerFundClaim> paidClaimList = new List<PartnerFundClaim>();
            //looping through the Claims and Passing the Paid / Pending Payment Claims to Share the Payment Records
            for(PartnerFundClaim pfc :pfcList) {
                if((pfc.Core_MDF_Status__c == 'Pending Payment' || pfc.Core_MDF_Status__c == 'Paid'||legacyPaidclmStsLst.contains(pfc.Core_MDF_Status__c)) && pfc.Core_MDF_Payment_Id__c != NULL) {
                    paidClaimList.add(pfc);
                }
            }
            
            if(paidClaimList != NULL && paidClaimList.Size() > 0) {
                Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap = Core_MDF_PaymentProcess.groupClaimsforPayment(paidClaimList);
                // Call the Payment Share method for Internal sharing
                Core_MDF_Payment_Sharing.sharePaymentRecordsToInternalUsers(paymentWrapperMap,'PGM');
            }

            Core_MDF_PFC_Sharing.shareClaimToInternalUsers(pfcList);
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}

    
    /*****************************************************************************************************
       Method Name   :        createAuditDocShareRecords
       @return       :        void
       @parameters   :        List of Audit Document
       Description   :        method to call class for Audit Document Share
       Added By      :        Accenture - Sandesh H - 7/21/2023
       Modified By   :        Date:             Changes:
     ******************************************************************************************************/
    
    public void createAuditDocShareRecords(List<Core_MDF_Audit_Document__c> auditDocList) {
        try{
           if(auditDocList.size() > 0) {
                Core_MDF_Audit_Document_Sharing.shareAuditDocToInternalUsers(auditDocList);
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
                Core_MDF_BankServiceHandler.createShareForBank(bankIdList,'IntPGMSharing');
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
	/*public void exceptionShare(List<Core_MDF_Exception__c> exptList) {

        try{
            Map<Id, Core_MDF_Exception__c> exceptionMap = new Map<Id, Core_MDF_Exception__c>();
            for(Core_MDF_Exception__c expt :exptList) {
                exceptionMap.put(expt.Id, expt);
            }
            if(exceptionMap.size() > 0) {
                Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers(exceptionMap, false);
            }
        }catch(Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
	}*/
    
    /*****************************************************************************************************
	   Method Name   :        exceptionAccountMapShare
	   @return       :        void
	   @parameters   :        List of Exception Account Mapping
	   Description   :        method to call class for Exception Account Mapping Share which will create sharing for Exception and Exception Account Mapping
	   Added By      :        Accenture - Mohit - 11/05/2025
	   Modified By   :        Date:       		Changes:
	 ******************************************************************************************************/
	public void exceptionAccountMapShare(List<Core_MDF_Exception_Account_Mapping__c> exptList) {

        try{
            Map<Id, Core_MDF_Exception_Account_Mapping__c> exptAccMapMap = new Map<Id, Core_MDF_Exception_Account_Mapping__c>();
            for(Core_MDF_Exception_Account_Mapping__c expt :exptList) {
                exptAccMapMap.put(expt.Id, expt);
            }
            if(exptAccMapMap.size() > 0) {
                Core_MDF_Expt_AccMap_ServiceHandler.shareEAM(exptAccMapMap);
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
	 ******************************************************************************************************
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
	}*/

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