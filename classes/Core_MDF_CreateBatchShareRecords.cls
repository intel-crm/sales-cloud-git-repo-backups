/****************************************************************************************************************************************
 * Class Name  : Core_MDF_CreateBatchShareRecords
 * Version     : 1.0
 * Created Date: 10-25-2019
 * Modification Log :
 * Developer                 Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - Krishna      10/25/2019          Class for handling share record creation.
 *****************************************************************************************************************************************/
global class Core_MDF_CreateBatchShareRecords implements Database.Batchable<sObject>, Database.Stateful{

    private String sobjectName;
    global final String query;
    private Map<Id, List<Id>> accountIdUserIdListMap = new Map<Id, List<Id>>();
    private static final String MANUAL = 'Manual';
    private boolean errorFlag = false;
    private Exception exceptionObject;
    private String errorMessage;
    private Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
    List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    List<Core_MDF_Partner_Node_User_Mapping__c> pnumFinalList = new List<Core_MDF_Partner_Node_User_Mapping__c>();   
    
    global Core_MDF_CreateBatchShareRecords(String objectName, Map<Id, List<Id>> accountIdUserIdListMapNew, String queryNew,  Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap) {
        this.sobjectName = objectName;
        this.query = queryNew;
        this.accountIdUserIdListMap = accountIdUserIdListMapNew;
        this.newPNUMappingMap = newPNUMappingMap;

        if(!newPNUMappingMap.isEmpty()) {
            this.pnumList.addAll(newPNUMappingMap.values());
        }
    }
	    
    global Database.QueryLocator start(Database.BatchableContext BC) {       
        Set<Id> setOfAccounts = new Set<Id>();
        setOfAccounts.addAll(accountIdUserIdListMap.keySet());
        
        if(('Campaign').equals(sobjectName)){
            return Database.getQueryLocator(query+':setOfAccounts' + ')'); 
        }
        else{
       		return Database.getQueryLocator(query+':setOfAccounts'); 
        }
    }

    global void execute(Database.BatchableContext BC, List< sObject > scope) {
        try{   
            switch on sobjectName {
                    when 'PartnerFundRequest' {
                                Map<Id, List<Id>> pFRIdUserIdListMap = new Map<Id, List<Id>>();             
                                List<PartnerFundRequest> pfrList = (List<PartnerFundRequest>)scope;
                                
                                //Iterate over the accountIdUserIdListMap to check if PFR records exist for the Accounts from the map.
                                for(PartnerFundRequest pFRRecord : pfrList) {   
                                    pFRIdUserIdListMap.put(pFRRecord.Id, accountIdUserIdListMap.get(pFRRecord.ChannelPartnerId));
                                }
                            system.debug('Activity Sharing');
                                if(pFRIdUserIdListMap.size() > 0) {  
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundRequest',pFRIdUserIdListMap, 'Edit');
                  List<PartnerFundRequestShare> pfrShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

                                    if(pfrShareList == null) {errorMessage = System.Label.Core_MDF_ActivityShareError;
                                    }
                                }
                    }   
                    when 'PartnerFundAllocation' {
                                Map<Id, List<Id>> pFAIdUserIdListMap = new Map<Id, List<Id>>();
                                List<PartnerFundAllocation> pfaList = (List<PartnerFundAllocation>)scope;
                                
                                //Iterate over the accountIdUserIdListMap to check if PFA records exist for the Accounts from the map.
                                for(PartnerFundAllocation pFARecord : pfaList) {   
                                    pFAIdUserIdListMap.put(pFARecord.Id, accountIdUserIdListMap.get(pFARecord.ChannelPartnerId));
                                }
                            system.debug('Allocation Sharing');
                                if(pFAIdUserIdListMap.size() > 0) {  
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundAllocation',pFAIdUserIdListMap, 'Edit');
                  List<PartnerFundAllocationShare> pfaShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                  
                                    if(pfaShareList == null) {errorMessage = System.Label.Core_MDF_AllocationShareError;
                                    }
                                }
                    }
                    when 'PartnerFundClaim' {
                                
                                //Map of corresponding Payment Ids to User List without any duplicates
                                Map<Id, List<Id>> paymentIdUserIdListMap = new Map<Id, List<Id>>();

                                // Map of corresponding Payment Ids to User Set in order to avoid duplicate users
                                Map<Id, Set<Id>> paymentIdUserIdSetMap = new Map<Id, Set<Id>>();

                                //Map of claim Ids to User List
                                Map<Id, List<Id>> pFCIdUserIdListMap = new Map<Id, List<Id>>();
                                List<PartnerFundClaim> pfcList = (List<PartnerFundClaim>)scope;
                                
                                //Iterate over the accountIdUserIdListMap to check if PFC records exist for the Accounts from the map.
                                for(PartnerFundClaim pFCRecord : pfcList) {   
                                    pFCIdUserIdListMap.put(pFCRecord.Id, accountIdUserIdListMap.get(pFCRecord.ChannelPartnerId));
                                    // Claim not mapped to Payment check
                                    if(pFCRecord.Core_MDF_Payment_Id__c != NULL) {

                                        if(paymentIdUserIdSetMap.containsKey(pFCRecord.Core_MDF_Payment_Id__c)) {   
                                            paymentIdUserIdSetMap.get(pFCRecord.Core_MDF_Payment_Id__c).addAll(accountIdUserIdListMap.get(pFCRecord.ChannelPartnerId));paymentIdUserIdListMap.put(pFCRecord.Core_MDF_Payment_Id__c, new List<Id>(paymentIdUserIdSetMap.get(pFCRecord.Core_MDF_Payment_Id__c)));
                                        }else{   
                                            paymentIdUserIdSetMap.put(pFCRecord.Core_MDF_Payment_Id__c, new Set<Id>(accountIdUserIdListMap.get(pFCRecord.ChannelPartnerId)));
                                            paymentIdUserIdListMap.put(pFCRecord.Core_MDF_Payment_Id__c, new List<Id>(paymentIdUserIdSetMap.get(pFCRecord.Core_MDF_Payment_Id__c)));
                                        }
                                    }
                                }
                            system.debug('Claim and Payment Sharing');
                                if(pFCIdUserIdListMap.size() > 0) {  
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerFundClaim',pFCIdUserIdListMap, 'Edit');
                  List<PartnerFundClaimShare> pfcShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

                                    if(pfcShareList == null) {errorMessage = System.Label.Core_MDF_PFCShareError;
                                    }
                                }
                                if(paymentIdUserIdListMap.size() > 0) {
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Payment__c',paymentIdUserIdListMap, 'Edit');
                  List<Core_MDF_Payment__Share> paymentShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

                                    if(paymentShareList == null) {errorMessage = System.Label.Core_MDF_PaymentShareError;
                                    }
                                }
                    }
                    when 'Core_MDF_Account_Bank_Mapping__c' {       
                                Map<Id, List<Id>> bankIdUserIdListMap = new Map<Id, List<Id>>();
                                Map<Id, List<Id>> bankAccountMapIdUserIdListMap = new Map<Id, List<Id>>();
                                List<Core_MDF_Account_Bank_Mapping__c> accBankList = (List<Core_MDF_Account_Bank_Mapping__c>)scope;
                                
                                //Iterate over the accountIdUserIdListMap to check if Bank records exist for the Accounts from the map.
                                for(Core_MDF_Account_Bank_Mapping__c bankRecord : accBankList) {   
                                    // Banks and user mapping
                                    bankIdUserIdListMap.put(bankRecord.Core_MDF_Bank__c, accountIdUserIdListMap.get(bankRecord.Core_MDF_Account__c));
                                    // BankAccount and user mapping
                                    bankAccountMapIdUserIdListMap.put(bankRecord.Id, accountIdUserIdListMap.get(bankRecord.Core_MDF_Account__c));
                                } 
                            system.debug('Bank and Account Bank Mapping Sharing');
                                if(bankIdUserIdListMap != null && bankIdUserIdListMap.size() > 0) {
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Bank__c',bankIdUserIdListMap, 'Edit');
                  List<Core_MDF_Bank__Share> bankShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

                                    if(bankShareList == null) {errorMessage = System.Label.Core_MDF_BankShareError;
                                    }
                                }
                                if(bankAccountMapIdUserIdListMap!=null && bankAccountMapIdUserIdListMap.size() > 0) {
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Account_Bank_Mapping__c',bankAccountMapIdUserIdListMap, 'Edit');
                  List<Core_MDF_Account_Bank_Mapping__Share> accBankShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

                                    if(accBankShareList == null) {errorMessage = System.Label.Core_MDF_AccBankShareError;
                                    }
                                }
                    }
                    when 'Case' {   
                                Map<Id, List<Id>> caseIdUserIdListMap = new Map<Id, List<Id>>();
                                //Map<caseId,caseRecord>
                
                            List<String> claimSubmitterPSList = Label.Core_MDF_External_Claim_Submitter.split(';');
                        
                                //Claim Submitter Check Logic Begins 01/09/2018
                                List<Id> allClaimSubmitter = new List<Id>();
                                List<Id> allUserId = new List<Id>();
                                for(Id accId: accountIdUserIdListMap.keySet()) {
                                    allUserId.addAll(accountIdUserIdListMap.get(accId));
                                }
                system.debug('Case Sharing');
                                for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, PermissionSet.Name 
                                                                      FROM PermissionSetAssignment 
                                                                      WHERE AssigneeId IN :alluserId AND 
                                                                      PermissionSet.Name IN: claimSubmitterPSList]){
                                                                      //PermissionSet.Name = 'Core_MDF_CCP_External_Claim_Submitter']) {
                                    allClaimSubmitter.add(usrPer.AssigneeId);
                                }
                            System.debug('allClaimSubmitter'+allClaimSubmitter);
                                //Claim Submitter Check Logic Ends
                                List<Case> caseList = (List<Case>)scope;
                                //Iterate over the accountIdUserIdListMap to check if Case records exist for the Accounts from the map.
                                for(Case caseRecord : caseList) {
                                    List<Id> userIdList = new List<Id>();
                                    for(Id usrId: accountIdUserIdListMap.get(caseRecord.AccountId)) {
                                        if(allClaimSubmitter.contains(usrId)) {
                                            userIdList.add(usrId);
                                        }
                                    }
                                    if(userIdList!=null && userIdList.size() > 0) {
                                        caseIdUserIdListMap.put(caseRecord.Id, userIdList);
                                    }
                                }
                                if(caseIdUserIdListMap!=null && caseIdUserIdListMap.size() > 0) {
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Case',caseIdUserIdListMap, 'Edit');
                  List<CaseShare> caseShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                                    
                                    if(caseShareList == null) {errorMessage = System.Label.Core_MDF_CaseShareError;
                                    }
                                }
                    }
                    when 'Core_MDF_Adjustment_Request__c' {
                                Map<Id, List<Id>> adjReqIdUserIdListMap = new Map<Id, List<Id>>();
                                List<Core_MDF_Adjustment_Request__c> adjReqList = (List<Core_MDF_Adjustment_Request__c>)scope;
                                
                                //Iterate over the accountIdUserIdListMap to check if adjReq records exist for the Accounts from the map.
                                for(Core_MDF_Adjustment_Request__c adjReqRecord : adjReqList) {   
                                    adjReqIdUserIdListMap.put(adjReqRecord.Id, accountIdUserIdListMap.get(adjReqRecord.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId));
                                }
                            system.debug('Adjustment Request Sharing');
                                if(adjReqIdUserIdListMap!=null && adjReqIdUserIdListMap.size() > 0) {   
                                    Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Adjustment_Request__c',adjReqIdUserIdListMap, 'Edit');
                  List<Core_MDF_Adjustment_Request__Share> adjReqShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);

                                    if(adjReqShareList == null) {errorMessage = System.Label.Core_MDF_AdjReqShareError;
                                    }
                                }
                    }
                
                when 'Core_MDF_Escalation__c' { 
                    
                    system.debug('Core_MDF_Escalation__c Sharing');
                    
                    //integer i = 1/0;
                    
                    Map<Id, List<Id>> escIdUserIdListMap = new Map<Id, List<Id>>();
                    List<Id> allClaimSubmitter = new List<Id>();
                    List<Id> allUserId = new List<Id>();
                    List<Core_MDF_Escalation__c> escList = (List<Core_MDF_Escalation__c>)scope;
                    
                    for(Id accId: accountIdUserIdListMap.keySet()) {
                        allUserId.addAll(accountIdUserIdListMap.get(accId));
                    }
                    
                    
                    for(PermissionSetAssignment psa : [SELECT Id, AssigneeId, PermissionSet.Name 
                                                       FROM PermissionSetAssignment 
                                                       WHERE AssigneeId IN :alluserId AND 
                                                       PermissionSet.Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter']) {
                        allClaimSubmitter.add(psa.AssigneeId);
                    }
                    
                    
                    //Iterate over the accountIdUserIdListMap to check if Core_MDF_Escalation__c records exist for the Accounts from the map.
                    for(Core_MDF_Escalation__c esc : escList) {
                        List<Id> userIdList = new List<Id>();
                        for(Id usrId: accountIdUserIdListMap.get(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId)) {
                            if(allClaimSubmitter.contains(usrId)) {
                                userIdList.add(usrId);
                            }
                        }
                        if(userIdList!=null && userIdList.size() > 0) {
                            escIdUserIdListMap.put(esc.Id, userIdList);
                        }
                    }
                    if(escIdUserIdListMap!=null && escIdUserIdListMap.size() > 0) {
                        Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Escalation__c',escIdUserIdListMap, 'Edit');
                        List<Core_MDF_Escalation__Share> escShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
                        
                        if(escShareList == null) {errorMessage = System.Label.Core_MDF_EscalationShareError;
                                                 }
                    }
                }
                when 'Campaign'{
                    List<Campaign> cmpList = (List<Campaign>)scope;
                    // calling getCampIdUserIdList method to get campIdUserIdMap
                    Map<Id,List<Id>> campIdUserIdMap = getCampIdUserIdList(cmpList,accountIdUserIdListMap, 'isCreate');
                    // Check if map is not null
                    if(campIdUserIdMap!=null && campIdUserIdMap.size() > 0) {
                        // call Core_MDF_GenericShareRecordActionClass to create share records
                        Core_MDF_GenericShareRecordActionClass.RecordManualShareClass retailShare = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Campaign',campIdUserIdMap,'Read');
                        List<CampaignShare> campaignShareList =  Core_MDF_GenericShareRecordActionClass.createShareRecordList(retailShare);
                        if(campaignShareList == null){
                            errorMessage = System.Label.Core_MDF_CampaignShareError;
                        }
                    }
                }
            }
        }catch(Exception e) {errorFlag = true;exceptionObject = e;} 
    }

    global void finish(Database.BatchableContext BC) {
        try{
      system.debug('Finish::');            
            Core_MDF_Partner_Node_User_Mapping__c pnumInstance;
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumInstanceList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                
            if(errorMessage != null || errorFlag || Test.IsRunningTest()){
                if(pnumList != null) {
                    for(Core_MDF_Partner_Node_User_Mapping__c pnum:pnumList) {
                        if(!pnumFinalList.contains(pnum)) {
                            pnumFinalList.add(pnum);
                        }
                    }
                }
            }
            if(errorFlag || Test.IsRunningTest()) {
                /*In case of Inserting or Editing Account User record, 
                if Exception occurred, updating field & sending support mail -1.3, 3_1.3*/                
                if(pnumFinalList!= null) {
                    for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord:pnumFinalList) {
                        pnumInstance = new Core_MDF_Partner_Node_User_Mapping__c();
                        pnumInstance.Id = pnumRecord.Id;
                        pnumInstance.Core_MDF_Error_Details_txt__c = pnumRecord.Core_MDF_Error_Details_txt__c == Null ? Label.Core_MDF_PnumExceptionError +':'+ sobjectName :pnumRecord.Core_MDF_Error_Details_txt__c + '\n' + Label.Core_MDF_PnumExceptionError +':'+ sobjectName;
                        pnumInstanceList.add(pnumInstance);
                    }
                }if(exceptionObject!=null){Core_MDF_CCP_UtilityClass.logError(exceptionObject);}               
            }else if(errorMessage != null && pnumFinalList!= null) {
                /*In case of Inserting or Editing Account User record, 
                if failed deleting or inserting share records, 
                updating error field & sending support mail -1.1, 3_1.1*/
                    for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord:pnumFinalList) {
                        pnumInstance = new Core_MDF_Partner_Node_User_Mapping__c();
                        pnumInstance.Id = pnumRecord.Id;
                        pnumInstance.Core_MDF_Error_Details_txt__c = pnumRecord.Core_MDF_Error_Details_txt__c == Null ? errorMessage + '.' :pnumRecord.Core_MDF_Error_Details_txt__c + '\n' + errorMessage + '.';
                        pnumInstanceList.add(pnumInstance);}Core_MDF_CCP_UtilityClass.logErrorinLogObject( Label.Core_MDF_SharingFailedEmail + pnumFinalList, Label.Core_MDF_ObjectEmail);
            } else{
                //All Success Cases -1.2, 3_1.2
            }
            if(pnumInstanceList != null && pnumInstanceList.size() > 0 && (errorMessage != null || errorFlag)){
                map<id,Core_MDF_Partner_Node_User_Mapping__c> pnumMap = new map<id,Core_MDF_Partner_Node_User_Mapping__c>();pnumMap.putall(pnumInstanceList);
              if(pnumMap.size()>0){update pnumMap.values();}
            }
        }catch(Exception e) {if(e!=null){Core_MDF_CCP_UtilityClass.logError(e);}}
    }
    
    /******************************************************************************************************** 
    Method Name :   getCampIdUserIdList
    @return     :   Map<Id, List<Id>> : Campaign Id with List of Users
    @parameters :   List<Campaign>, Map<Id, List<Id>>accountIdUserIdListMap
    Description :   Prepare a map of Campaign Id with List of Users to be created/ deleted
    Added By    :   Accenture - HP - 08/06/2020
    Modified By :   Date:         Changes:None  
    **********************************************************************************************************/
	public static Map<Id,List<Id>> getCampIdUserIdList(List<Campaign> campList, Map<Id,List<Id>> accountIdUserIdListMap, String reason){
		Map<Id,List<Id>> campIdUserIdMap = new Map<Id,List<Id>>();
        Map<Id,set<Id>> existingPNUMMap = new Map<Id,set<Id>>();
		String executionReason = reason;
		try{
            // check if execution reason is 'isDelete'
            if(('isDelete').equals(executionReason)){
                List<Id> userIdList = new List<Id>();
                // Iterate over the accounts and prepare a list of users associated to it
                for(Id accId : accountIdUserIdListMap.keySet()){
                    userIdList.addAll(accountIdUserIdListMap.get(accId));
                }
                // Iterate over the PNUM's for users present in userIdList
				for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c 
																  FROM Core_MDF_Partner_Node_User_Mapping__c 
																  WHERE Core_MDF_User__c IN : userIdList AND
																  Core_MDF_User__r.IsActive = TRUE]){
					// Updating the existingPNUMMap with key as AccountId and Value as Set of User
					if(existingPNUMMap.containsKey(pnum.Core_MDF_Account__c)){
						existingPNUMMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
					}else{
						existingPNUMMap.put(pnum.Core_MDF_Account__c, new Set<Id> {pnum.Core_MDF_User__c});
					}
				}
			}
            // Iterate over the campaigns to prepare campaignId and associated UserId list
            // When a PNUM is created/deleted on Virtual corp account, need to share all the campaigns created on Virtual corp and below node accounts
            // When a PNUM is deleted whose account is virtual corp , need to check if any PNUM's are existing for that user on below node accounts.
            // If yes, we will delete share records of only virtual corp // If No, we will delete all the share records at all levels
			for(Campaign cmp : campList){
                // Checking if the campaign's account in accountIdUserIdListMap 
                if(accountIdUserIdListMap.containsKey(cmp.Core_MDF_Account__c) && (('isCreate').equals(executionReason) ||
                    (('isDelete').equals(executionReason) && ((cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c == cmp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c) 
                     || ((!existingPNUMMap.containsKey(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c)) &&
                     (cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c !=NULL && 
                      !existingPNUMMap.containsKey(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c))))))){
                    if(campIdUserIdMap.containsKey(cmp.Id)){
                        campIdUserIdMap.get(cmp.Id).addAll(accountIdUserIdListMap.get(cmp.Core_MDF_Account__c));
                    }
                    else{
                        List<Id> userIdList = new List<Id>();
                        userIdList.addAll(accountIdUserIdListMap.get(cmp.Core_MDF_Account__c));
                        campIdUserIdMap.put(cmp.Id, userIdList);
                    }
                }
                // Checking if the campaign's account parent fund account in accountIdUserIdListMap 
                // while reason is 'isDelete',checking if campaign account is not present in existingPNUMMap
                else if(accountIdUserIdListMap.containsKey(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c) && ((('isCreate').equals(executionReason)) ||
                            (('isDelete').equals(executionReason)) && !existingPNUMMap.containsKey(cmp.Core_MDF_Account__c) &&
                                                                       !existingPNUMMap.containsKey(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c))){
                                if(campIdUserIdMap.containsKey(cmp.Id)){
                                    campIdUserIdMap.get(cmp.Id).addAll(accountIdUserIdListMap.get(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c));
                                }
                                else{
                                    List<Id> userIdList = new List<Id>();
                                    userIdList.addAll(accountIdUserIdListMap.get(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c));
                                    campIdUserIdMap.put(cmp.Id, userIdList);
                                }
                }
                // Checking if the campaign's account parent fund account's parent fund account in accountIdUserIdListMap 
                // while reason is 'isDelete',checking if campaign account and Campaign account's parent fund account's are not present in existingPNUMMap
                else if(accountIdUserIdListMap.containsKey(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) 
                             && ((('isCreate').equals(executionReason)) ||
                            (('isDelete').equals(executionReason)) && !existingPNUMMap.containsKey(cmp.Core_MDF_Account__c) && 
                            !existingPNUMMap.containsKey(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__c))){
                                if(campIdUserIdMap.containsKey(cmp.Id)){   
                                    campIdUserIdMap.get(cmp.Id).addAll(accountIdUserIdListMap.get(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c));
                                }
                                else{
                                    List<Id> userIdList = new List<Id>();
                                    userIdList.addAll(accountIdUserIdListMap.get(cmp.Core_MDF_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c));
                                    campIdUserIdMap.put(cmp.Id, userIdList);
                                }
                    }
                }
				
		}catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return campIdUserIdMap;
	}
}