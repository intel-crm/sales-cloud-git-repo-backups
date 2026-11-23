/****************************************************************************************************************************************
 * Class Name  : Core_MDF_DeleteBatchShareRecords
 * Version     : 1.0
 * Created Date: 10-25-2019
 * Modification Log :
 * Developer                 Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - Krishna      10/25/2019          Class for handling share record deletion.
 *****************************************************************************************************************************************/
global class Core_MDF_DeleteBatchShareRecords implements Database.Batchable<sObject>, Database.Stateful{
    
    private String sobjectName;
    global final String query;
    private Map<Id, List<Id>> accountIdUserIdListMap = new Map<Id, List<Id>>();
    private Map<Id, List<Id>> accountIdUserIdListMapCreateBatch = new Map<Id, List<Id>>();
    private static final String MANUAL = 'Manual';
    private boolean errorFlag = false;
    private Exception exceptionObject;
    private String errorMessage;
    private List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    List<Core_MDF_Partner_Node_User_Mapping__c> pnumFinalList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    private Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
    private boolean isDeleteDuringEdit = false;
    
    global Core_MDF_DeleteBatchShareRecords(String objectName, Map<Id, List<Id>> accountIdUserIdListMapNew, String queryNew, List<Core_MDF_Partner_Node_User_Mapping__c> oldPNUMappingList, boolean isDeleteDuringEdit, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap, Map<Id, List<Id>> accountIdUserIdListMapForCreateShare) {
        this.sobjectName = objectName;
        this.query = queryNew;
        this.accountIdUserIdListMap = accountIdUserIdListMapNew;
        this.accountIdUserIdListMapCreateBatch = accountIdUserIdListMapForCreateShare;
        this.oldPNUMappingList = oldPNUMappingList;
        this.isDeleteDuringEdit = isDeleteDuringEdit;
        this.newPNUMappingMap = newPNUMappingMap;
        
        if(!oldPNUMappingList.isEmpty()) {
            for(Core_MDF_Partner_Node_User_Mapping__c pnum:oldPNUMappingList) {
                this.pnumList.add(pnum);
            }
        }
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC) {    
        Set<Id> setOfAccounts = new Set<Id>();
        setOfAccounts.addAll(accountIdUserIdListMap.keySet());
        if(('CampaignShare').equals(sobjectName)){
            return Database.getQueryLocator(query + ':setOfAccounts' + ')');
        }else{
            return Database.getQueryLocator(query+':setOfAccounts');
        }
    }
    
    global void execute(Database.BatchableContext BC, List< sObject > scope) {
        try{
            switch on sobjectName { 
                when 'PartnerFundAllocationShare' {     
                    //Check what PFA records are associated with the accounts
                    List<PartnerFundAllocationShare> pFAShareListToBeDeleted = new List<PartnerFundAllocationShare>();
                    Map<Id, List<Id>> pFAIdUserIdListMap = new Map<Id, List<Id>>();
                    List<PartnerFundAllocation> pfaList = (List<PartnerFundAllocation>)scope;
                    
                    for(PartnerFundAllocation pFARecord : pfaList) {   
                        pFAIdUserIdListMap.put(pFARecord.Id, accountIdUserIdListMap.get(pFARecord.ChannelPartnerId));
                    }
                    //Map<pfaShareId,pfaShareRecord>
                    Map<Id, PartnerFundAllocationShare> pfaShareMap = new Map<Id, PartnerFundAllocationShare>([SELECT Id, ParentId, UserOrGroupId
                                                                                                               FROM PartnerFundAllocationShare
                                                                                                               WHERE ParentId IN : pFAIdUserIdListMap.keySet()AND RowCause =:MANUAL]);
                    
                    for(PartnerFundAllocationShare pFAShareRecord : pfaShareMap.values()) {   
                        //check if the Share record exist
                        if(pFAIdUserIdListMap.containsKey(pFAShareRecord.ParentId) &&
                           pFAIdUserIdListMap.get(pFAShareRecord.ParentId).contains(pFAShareRecord.UserOrGroupId)) {   
                               pFAShareListToBeDeleted.add(pFAShareRecord);
                           }
                    }
                   
                    if(pFAShareListToBeDeleted != null && 
                       pFAShareListToBeDeleted.size() > 0) {
                           Database.deleteResult[] srList = Database.delete(pFAShareListToBeDeleted, false);
                           // Iterate through each returned result
                           for (Database.deleteResult sr : srList) {
                               if (!sr.isSuccess()) {errorMessage = System.Label.Core_MDF_AllocationShareDeleteError;
                                                    }
                           }
                       }
                }
                when 'PartnerFundRequestShare' {        
                    //Check what PFR records are associated with the accounts
                    List<PartnerFundRequestShare> pFRShareListToBeDeleted = new List<PartnerFundRequestShare>();
                    Map<Id, List<Id>> pFRIdUserIdListMap = new Map<Id, List<Id>>();
                    List<PartnerFundRequest> pfrList = (List<PartnerFundRequest>)scope;
                    
                    for(PartnerFundRequest pFRRecord : pfrList) {   
                        pFRIdUserIdListMap.put(pFRRecord.Id, accountIdUserIdListMap.get(pFRRecord.ChannelPartnerId));
                    }
                    //Map<pfrShareId,pfrShareRecord
                    Map<Id, PartnerFundRequestShare> pfrShareMap = new Map<Id, PartnerFundRequestShare>([SELECT Id, ParentId, UserOrGroupId
                                                                                                         FROM PartnerFundRequestShare
                                                                                                         WHERE ParentId IN : pFRIdUserIdListMap.keySet() AND
                                                                                                         RowCause =:MANUAL]);
                    for(PartnerFundRequestShare pFRShareRecord : pfrShareMap.values()) {   
                        //check if the Share record exist
                        if(pFRIdUserIdListMap.containsKey(pFRShareRecord.ParentId) &&
                           pFRIdUserIdListMap.get(pFRShareRecord.ParentId).contains(pFRShareRecord.UserOrGroupId)) {   
                               pFRShareListToBeDeleted.add(pFRShareRecord);
                           }
                    }
                  
                    if(pFRShareListToBeDeleted != null && 
                       pFRShareListToBeDeleted.size() > 0) {
                           Database.deleteResult[] srList = Database.delete(pFRShareListToBeDeleted, false);
                           // Iterate through each returned result
                           for (Database.deleteResult sr : srList) {
                               if (!sr.isSuccess()) {errorMessage = System.Label.Core_MDF_PFRShareDeleteError;
                                                    }
                           }
                       }
                }
                when 'Core_MDF_Bank__Share' {       
                    //Check what Bank records are associated with the accounts
                    List<Core_MDF_Bank__Share> bankShareListToBeDeleted = new List<Core_MDF_Bank__Share>();
                    
                    Map<Id, List<Id>> bankIdUserIdListMap = new Map<Id, List<Id>>();
                    Map<Id, List<Id>> bankMapIdUserIdListMap = new Map<Id, List<Id>>();
                    List<Core_MDF_Account_Bank_Mapping__c> accBankList = (List<Core_MDF_Account_Bank_Mapping__c>)scope;
                    
                    for(Core_MDF_Account_Bank_Mapping__c bankRecord : accBankList) {   
                        bankIdUserIdListMap.put(bankRecord.Core_MDF_Bank__c, accountIdUserIdListMap.get(bankRecord.Core_MDF_Account__c));
                        bankMapIdUserIdListMap.put(bankRecord.Id, accountIdUserIdListMap.get(bankRecord.Core_MDF_Account__c));
                    }
                    //Map<bankShareId,bankShareRecord>
                    Map<Id, Core_MDF_Bank__Share> bankShareMap = new Map<Id, Core_MDF_Bank__Share>([SELECT Id, ParentId, UserOrGroupId
                                                                                                    FROM Core_MDF_Bank__Share
                                                                                                    WHERE ParentId IN : bankIdUserIdListMap.keySet() AND
                                                                                                    RowCause =:MANUAL]);
                    for(Core_MDF_Bank__Share bankShareRecord : bankShareMap.values()) {   
                        //check if the Share record exist
                        if(bankIdUserIdListMap.containsKey(bankShareRecord.ParentId) &&
                           bankIdUserIdListMap.get(bankShareRecord.ParentId).contains(bankShareRecord.UserOrGroupId)) {   
                               bankShareListToBeDeleted.add(bankShareRecord);
                           }
                    }
                   
                    if(bankShareListToBeDeleted != null && 
                       bankShareListToBeDeleted.size() > 0) {
                           Database.deleteResult[] srList = Database.delete(bankShareListToBeDeleted, false);
                           // Iterate through each returned result
                           for (Database.deleteResult sr : srList) {
                               if (!sr.isSuccess()) {
                                   errorMessage = System.Label.Core_MDF_BankShareDeleteError;
                               }
                           }
                       }
                    
                    // Delete acocunt and bank mapping shared records
                    List<Core_MDF_Account_Bank_Mapping__Share> bankAccountShareListToBeDeleted = new List<Core_MDF_Account_Bank_Mapping__Share>();
                    //Map<AccountBankMappingShareId,AccountBankMappingShareRecord>
                    Map<Id, Core_MDF_Account_Bank_Mapping__Share> accountBankMappingShareMap = new Map<Id, Core_MDF_Account_Bank_Mapping__Share>([SELECT Id, ParentId, UserOrGroupId
                                                                                                                                                  FROM Core_MDF_Account_Bank_Mapping__Share
                                                                                                                                                  WHERE ParentId IN : bankMapIdUserIdListMap.keySet() AND
                                                                                                                                                  RowCause =:MANUAL]);
                    for(Core_MDF_Account_Bank_Mapping__Share bankAccountShareRecord : accountBankMappingShareMap.values()) {   
                        //check if the Share record exist
                        if(bankMapIdUserIdListMap.containsKey(bankAccountShareRecord.ParentId) &&
                           bankMapIdUserIdListMap.get(bankAccountShareRecord.ParentId).contains(bankAccountShareRecord.UserOrGroupId)) {   
                               bankAccountShareListToBeDeleted.add(bankAccountShareRecord);
                           }
                    }
                    if(bankAccountShareListToBeDeleted != null && 
                       bankAccountShareListToBeDeleted.size() > 0) {
                           Database.deleteResult[] srList = Database.delete(bankAccountShareListToBeDeleted, false);
                           // Iterate through each returned result
                           for (Database.deleteResult sr : srList) {
                               if (!sr.isSuccess()) {
                                   errorMessage = System.Label.Core_MDF_AccBankShareDeleteError;
                               }
                           }
                       }
                }
                when 'PartnerFundClaimShare' {
                    List<PartnerFundClaimShare> pFCShareListToBeDeleted = new List<PartnerFundClaimShare>();
                    List<Core_MDF_Payment__share> paymentShareListToBeDeleted = new List<Core_MDF_Payment__share>();
                    Map<Id, List<Id>> paymentIdUserIdListMap = new Map<Id, List<Id>>();
                    Map<Id, Set<Id>> paymentIdUserIdSetMap = new Map<Id, Set<Id>>();
                    Map<Id, List<Id>> pFCIdUserIdListMap = new Map<Id, List<Id>>();
                    List<PartnerFundClaim> pfcList = (List<PartnerFundClaim>)scope;
                    
                    for(PartnerFundClaim pFCRecord : pfcList) {   
                        pFCIdUserIdListMap.put(pFCRecord.Id, accountIdUserIdListMap.get(pFCRecord.ChannelPartnerId));
                        if(pFCRecord.Core_MDF_Payment_Id__c != NULL) {
                            if(paymentIdUserIdSetMap.containsKey(pFCRecord.Core_MDF_Payment_Id__c)) {   
                                paymentIdUserIdSetMap.get(pFCRecord.Core_MDF_Payment_Id__c).addAll(accountIdUserIdListMap.get(pFCRecord.ChannelPartnerId));paymentIdUserIdListMap.put(pFCRecord.Core_MDF_Payment_Id__c, new List<Id>(paymentIdUserIdSetMap.get(pFCRecord.Core_MDF_Payment_Id__c)));
                            }else{   
                                paymentIdUserIdSetMap.put(pFCRecord.Core_MDF_Payment_Id__c, new Set<Id>(accountIdUserIdListMap.get(pFCRecord.ChannelPartnerId)));
                                paymentIdUserIdListMap.put(pFCRecord.Core_MDF_Payment_Id__c, new List<Id>(paymentIdUserIdSetMap.get(pFCRecord.Core_MDF_Payment_Id__c)));
                            }
                        }
                    }
                    Map<Id, PartnerFundClaim> hierarchyNodeClaimsHavingSamePaymentIdsMap = new Map<Id, PartnerFundClaim>([SELECT Id, ChannelPartnerId, Core_MDF_Payment_Id__c
                                                                                                                          FROM PartnerFundClaim
                                                                                                                          WHERE ChannelPartnerId NOT IN :accountIdUserIdListMap.keySet() AND Core_MDF_Payment_Id__c  IN: paymentIdUserIdListMap.keySet()]);
                   
                    if(hierarchyNodeClaimsHavingSamePaymentIdsMap != NULL && hierarchyNodeClaimsHavingSamePaymentIdsMap.size() > 0) {
                        for(PartnerFundClaim nodeClaim : hierarchyNodeClaimsHavingSamePaymentIdsMap.values()) {
                            if(paymentIdUserIdListMap.containsKey(nodeClaim.Core_MDF_Payment_Id__c)) {paymentIdUserIdListMap.remove(nodeClaim.Core_MDF_Payment_Id__c);}
                        }
                    }
                    if(paymentIdUserIdListMap != NULL && 
                       paymentIdUserIdListMap.size() > 0) {   
                           Map<Id, Core_MDF_Payment__share> paymentShareMap = new Map<Id, Core_MDF_Payment__share>([SELECT Id, ParentId, UserOrGroupId
                                                                                                                    FROM Core_MDF_Payment__share
                                                                                                                    WHERE ParentId IN : paymentIdUserIdListMap.keySet() AND
                                                                                                                    RowCause =:MANUAL]);
                           
                           for(Core_MDF_Payment__share paymentShareRecord :paymentShareMap.values()) {   
                               if(paymentIdUserIdListMap.containsKey(paymentShareRecord.ParentId) && paymentIdUserIdListMap.get(paymentShareRecord.ParentId).contains(paymentShareRecord.UserOrGroupId)) {paymentShareListToBeDeleted.add(paymentShareRecord);
                                                                                                                                                                                                         }
                           }
                       }
                    Map<Id, PartnerFundClaimShare> pfcShareMap = new Map<Id, PartnerFundClaimShare>([SELECT Id, ParentId, UserOrGroupId
                                                                                                     FROM PartnerFundClaimShare
                                                                                                     WHERE ParentId IN : pFCIdUserIdListMap.keySet() AND
                                                                                                     RowCause =:MANUAL]);
                    
                    for(PartnerFundClaimShare pFCShareRecord :pfcShareMap.values()) {   
                        if(pFCIdUserIdListMap.containsKey(pFCShareRecord.ParentId) &&
                           pFCIdUserIdListMap.get(pFCShareRecord.ParentId).contains(pFCShareRecord.UserOrGroupId)) {   
                               pFCShareListToBeDeleted.add(pFCShareRecord);
                           }
                    }
                    
                    if(pFCShareListToBeDeleted != null && pFCShareListToBeDeleted.size() > 0) {
                        Database.deleteResult[] srList = Database.delete(pFCShareListToBeDeleted, false);
                        for (Database.deleteResult sr : srList) {
                            if (!sr.isSuccess()) {
                                errorMessage = System.Label.Core_MDF_PFCShareDeleteError;
                            }
                        }
                    }
                    if(paymentShareListToBeDeleted != null && paymentShareListToBeDeleted.size() > 0) {Database.deleteResult[] srList = Database.delete(paymentShareListToBeDeleted, false);
                                                                                                       for (Database.deleteResult sr : srList) {if (!sr.isSuccess()) {errorMessage = System.Label.Core_MDF_PaymentShareDeleteError;
                                                                                                                                                                     }
                                                                                                                                               }
                                                                                                      }
                }
                when 'CaseShare' {  
                    //Check what Case records are associated with the accounts
                    List<CaseShare> caseShareListToBeDeleted = new List<CaseShare>();
                    List<Case> caseList = (List<Case>)scope;
                    
                    Map<Id, List<Id>> caseIdUserIdListMap = new Map<Id, List<Id>>();
                    for(Case caseRecord : caseList) {   
                        caseIdUserIdListMap.put(caseRecord.Id, accountIdUserIdListMap.get(caseRecord.AccountId));
                    }
                    //Map<CaseShareId,CaseShareRecord
                    Map<Id, CaseShare> caseShareMap = new Map<Id, CaseShare>([SELECT Id, CaseId, UserOrGroupId
                                                                              FROM CaseShare
                                                                              WHERE CaseId IN : caseIdUserIdListMap.keySet() AND
                                                                              RowCause =:MANUAL]);
                   
                    for(CaseShare caseShareRecord : caseShareMap.values()) {   
                        //check if the Share record exist
                        if(caseIdUserIdListMap.containsKey(caseShareRecord.CaseId) && caseIdUserIdListMap.get(caseShareRecord.CaseId).contains(caseShareRecord.UserOrGroupId)) {caseShareListToBeDeleted.add(caseShareRecord);}
                    }
                   
                    if(caseShareListToBeDeleted != null && caseShareListToBeDeleted.size() > 0) {
                        Database.deleteResult[] srList = Database.delete(caseShareListToBeDeleted, false);
                        // Iterate through each returned result
                        for (Database.deleteResult sr : srList) {if (!sr.isSuccess()) {errorMessage = System.Label.Core_MDF_CaseShareDeleteError;}}
                    }
                }
                when 'Core_MDF_Adjustment_Request__Share' { 
                    //Check what AdjReq records are associated with the accounts
                    List<Core_MDF_Adjustment_Request__Share> adjReqShareListToBeDeleted = new List<Core_MDF_Adjustment_Request__Share>();
                    Map<Id, List<Id>> adjReqIdUserIdListMap = new Map<Id, List<Id>>();
                    List<Core_MDF_Adjustment_Request__c> adjReqList = (List<Core_MDF_Adjustment_Request__c>)scope;
                    
                    for(Core_MDF_Adjustment_Request__c adjReqRecord : adjReqList) {   
                        adjReqIdUserIdListMap.put(adjReqRecord.Id, accountIdUserIdListMap.get(adjReqRecord.Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId));
                    }
                    //Map<AdjReqShareId,AdjReqShareRecord>
                    Map<Id, Core_MDF_Adjustment_Request__Share> adjReqShareMap = new Map<Id, Core_MDF_Adjustment_Request__Share>([SELECT Id, ParentId, UserOrGroupId
                                                                                                                                  FROM Core_MDF_Adjustment_Request__Share
                                                                                                                                  WHERE ParentId IN : adjReqIdUserIdListMap.keySet() AND
                                                                                                                                  RowCause =:MANUAL]);
                    
                    for(Core_MDF_Adjustment_Request__Share adjReqShareRecord : adjReqShareMap.values()) {   
                        //check if the Share record exist
                        if(adjReqIdUserIdListMap.containsKey(adjReqShareRecord.ParentId) &&
                           adjReqIdUserIdListMap.get(adjReqShareRecord.ParentId).contains(adjReqShareRecord.UserOrGroupId)) {   
                               adjReqShareListToBeDeleted.add(adjReqShareRecord);
                           }
                    }
                   
                    if(adjReqShareListToBeDeleted != null && 
                       adjReqShareListToBeDeleted.size() > 0) {
                           Database.deleteResult[] srList = Database.delete(adjReqShareListToBeDeleted, false);
                           // Iterate through each returned result
                           for (Database.deleteResult sr : srList) {
                               if (!sr.isSuccess()) {
                                   errorMessage = System.Label.Core_MDF_AdjReqShareDeleteError;
                               }
                           }
                       }
                }
                
                when 'Core_MDF_Escalation__Share' { 
                    
                    List<Core_MDF_Escalation__Share> escShareListToBeDeleted = new List<Core_MDF_Escalation__Share>();
                    List<Core_MDF_Escalation__c> escList = (List<Core_MDF_Escalation__c>)scope;
                    Map<Id, List<Id>> escIdUserIdListMap = new Map<Id, List<Id>>();
                    
                    for(Core_MDF_Escalation__c esc : escList) {   
                        escIdUserIdListMap.put(esc.Id, accountIdUserIdListMap.get(esc.Core_MDF_Co_Marketing_Activity_id__r.ChannelPartnerId));
                    }
                    
                    Map<Id, Core_MDF_Escalation__Share> escShareMap = new Map<Id, Core_MDF_Escalation__Share>([SELECT Id, ParentId, UserOrGroupId
                                                                                                               FROM Core_MDF_Escalation__Share
                                                                                                               WHERE ParentId IN : escIdUserIdListMap.keySet() AND
                                                                                                               RowCause =:MANUAL]);
                    
                    
                    for(Core_MDF_Escalation__Share escShare : escShareMap.values()) {   
                        //check if the Share record exist
                        if(escIdUserIdListMap.containsKey(escShare.ParentId) && 
                           escIdUserIdListMap.get(escShare.ParentId).contains(escShare.UserOrGroupId)) {
                               escShareListToBeDeleted.add(escShare);
                           }
                    }
                    

                    
                    if(escShareListToBeDeleted != null && escShareListToBeDeleted.size() > 0) {
                        Database.deleteResult[] srList = Database.delete(escShareListToBeDeleted, false);
                        // Iterate through each returned result
                        for (Database.deleteResult sr : srList) {if (!sr.isSuccess()) {errorMessage = System.Label.Core_MDF_EscalationShareDeleteError;}}
                    }
                }
                when 'CampaignShare' {
                    /*List<CampaignShare> campShareListToBeDeleted = new List<CampaignShare>();
                    List<Campaign> campList = (List<Campaign>)scope;
                    // calling getCampIdUserIdList method to get campIdUserIdMap
                    Map<Id, List<Id>> campIdUserIdMap = Core_MDF_CreateBatchShareRecords.getCampIdUserIdList(campList,accountIdUserIdListMap, 'isDelete');
                    Map<Id, CampaignShare> campShareMap = new Map<Id, CampaignShare>([SELECT Id, CampaignId, UserOrGroupId
                                                                                      FROM CampaignShare
                                                                                      WHERE CampaignId IN : campIdUserIdMap.keySet() AND
                                                                                      RowCause =:MANUAL]);
                    if(campShareMap != NULL && campShareMap.size()>0){
                        for(CampaignShare cmpShare : campShareMap.values()) {   
                            //check if the Share record exist
                            if(campIdUserIdMap.containsKey(cmpShare.CampaignId) && 
                               campIdUserIdMap.get(cmpShare.CampaignId).contains(cmpShare.UserOrGroupId) && String.valueOf(cmpShare.UserOrGroupId).startsWith('005')) {
                                   campShareListToBeDeleted.add(cmpShare);
                               }
                        }
                    }
                    
                    // Check if list is not null
                    if(campShareListToBeDeleted != null && campShareListToBeDeleted.size() > 0) {
                        Database.deleteResult[] srList = Database.delete(campShareListToBeDeleted, false);
                        // Iterate through each returned result
                        for (Database.deleteResult sr : srList) {
                            if (!sr.isSuccess()) {
                                errorMessage = System.Label.Core_MDF_CampaignShareDeleteError;
                            }
                        }
                    }*///Commented as part of WW14 unused code
                }
                
                when else {}
            }
        }catch(Exception e) {errorFlag = true;exceptionObject = e;}
    }
    
    global void finish(Database.BatchableContext BC) {
        try{
           
            Core_MDF_Partner_Node_User_Mapping__c pnumInstance = new Core_MDF_Partner_Node_User_Mapping__c();
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumInstanceList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            //ATHR - Deeply Nested if 16209
            if(((isDeleteDuringEdit && errorFlag) || (isDeleteDuringEdit && errorMessage != null) || Test.IsRunningTest()) && pnumList != null){
                //if(pnumList != null) {
                    for(Core_MDF_Partner_Node_User_Mapping__c pnum:pnumList) {
                        if(!pnumFinalList.contains(pnum)) {
                            pnumFinalList.add(pnum);
                        }
                    }
                //}
            }
            if((isDeleteDuringEdit && errorFlag) || Test.IsRunningTest()) {
                /*In case of Editing Account User record, 
                if Exception occurred, updating field & sending support mail - 3_2.3*/
                if(!pnumFinalList.isEmpty()) {
                    for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord:pnumFinalList) {
                        pnumInstance.Id = pnumRecord.Id;
                        pnumInstance.Core_MDF_Error_Details_txt__c = pnumRecord.Core_MDF_Error_Details_txt__c == Null ? Label.Core_MDF_PnumExceptionError +':'+ sobjectName :pnumRecord.Core_MDF_Error_Details_txt__c + '\n' + Label.Core_MDF_PnumExceptionError +':'+ sobjectName;
                        pnumInstanceList.add(pnumInstance);
                    }
                }
                if(exceptionObject!=null){Core_MDF_CCP_UtilityClass.logError(exceptionObject);}
            }else if(isDeleteDuringEdit && errorMessage != null) {
                /*In case of Editing Account User record, 
                if failed deleting or inserting share records, 
                updating error field & sending support mail -3_2.1*/
                if(!pnumFinalList.isEmpty()) {
                    for(Core_MDF_Partner_Node_User_Mapping__c pnumRecord:pnumFinalList) {pnumInstance.Id = pnumRecord.Id;
                                                                                         pnumInstance.Core_MDF_Error_Details_txt__c = pnumRecord.Core_MDF_Error_Details_txt__c == Null ? errorMessage + '.' :pnumRecord.Core_MDF_Error_Details_txt__c + '\n' + errorMessage + '.';
                                                                                         pnumInstanceList.add(pnumInstance);}Core_MDF_CCP_UtilityClass.logErrorinLogObject( Label.Core_MDF_SharingFailedEmail + pnumFinalList, Label.Core_MDF_ObjectEmail);
                }
                /*In case of deleting account user record, 
                if got an exception or some share records failed to delete, 
                then sending email with proper message -2.1,2.3*/
                //To send email
            } else if(!isDeleteDuringEdit && (errorFlag || errorMessage != null)) {Core_MDF_CCP_UtilityClass.logErrorinLogObject( Label.Core_MDF_DeleteFailedEmail + pnumList, Label.Core_MDF_ObjectEmail);
                                                                                  }
            if(pnumInstanceList != null && pnumInstanceList.size() > 0 && (errorMessage != null || errorFlag)){
                map<id,Core_MDF_Partner_Node_User_Mapping__c> pnumMap = new map<id,Core_MDF_Partner_Node_User_Mapping__c>();pnumMap.putall(pnumInstanceList);
                if(pnumMap.size()>0){update pnumMap.values();}    
            }
            if(isDeleteDuringEdit){
                Core_MDF_AccountUserUtility.createObjectShareRecords(sobjectName,accountIdUserIdListMapCreateBatch,newPNUMappingMap);
            }
        }catch(Exception e) {if(e!=null){Core_MDF_CCP_UtilityClass.logError(e);}}
    }
    
    
}