/****************************************************************************************************
Apex Class Name : PSG_DistyVisibilityBusinessLogic
Version         : 1.0 
Created Date    : 07/07/2021
Function        : This class is Helper class for Disty Visibility Object Trigger Operations. 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sushmita                  07/07/2021                 Created
*****************************************************************************************************/
@isTest
public class PSG_DistyVisibilityBusinessLogic {

    /****************************************************************************************************************
    * Method Name:afterInsertOperations
    * Date: 07/07/2021    
    * Description: Method performs are the operations in after context.
    ***************************************************************************************************************************/
    /*public static void afterInsertOperations(List < core_cpq_disty_visibility__c > dvList, Map < Id, core_cpq_disty_visibility__c > oldMap, Boolean isInsert) {
        if (isInsert && !dvList.isEmpty()) {
            Map < Id, Account > accountMap = new Map < Id, Account > ();
            set < Id > accountIdSet = new set < Id > ();
            set < Id > quoteIdSet = new set < Id > ();
            for (core_cpq_disty_visibility__c DVObj: dvList) {
                if (DVObj.core_cpq_quote__r.core_cpq_quote_type_nm__c == 'Contract Pricing') {
                    if (DVObj.core_cpq_quote__r.SBQQ__Status__c == 'Approved' && DVObj.core_cpq_quote__r.core_cpq_active_cb__c && DVObj.core_cpq_quote__r.core_cpq_Process_flag__c) {
                        if (DVObj.core_cpq_distributor__c != null) {
                            accountIdSet.add(DVObj.core_cpq_distributor__c);
                            quoteIdSet.add(DVObj.core_cpq_quote__c);
                        }
                    }
                } else {
                    if (DVObj.core_cpq_distributor__c != null) {
                        accountIdSet.add(DVObj.core_cpq_distributor__c);
                        quoteIdSet.add(DVObj.core_cpq_quote__c);
                    }
                }

            }
            if (!accountIdSet.isEmpty()) {
                manageQuoteShareWithDistyContacts(dvList, accountIdSet, 'grant');
                manageDpaAlnShareWithDistyContacts(dvList, accountIdSet, quoteIdSet, 'grant');
            }

        }
    }
    /****************************************************************************************************************
    * Method Name:afterDeleteOperations
    * Date: 07/07/2021    
    * Description: Method performs the operations in after delete context.
    ***************************************************************************************************************************/
    /*public static void afterDeleteOperations(List < core_cpq_disty_visibility__c > dvList, Map < Id, core_cpq_disty_visibility__c > oldMap, Boolean isDelete) {
        if (isDelete && !dvList.isEmpty()) {
            Map < Id, Account > accountMap = new Map < Id, Account > ();
            set < Id > accountIdSet = new set < Id > ();
            set < Id > quoteIdSet = new set < Id > ();

            for (core_cpq_disty_visibility__c DVObj: dvList) {
                if (DVObj.core_cpq_distributor__c != null) {
                    accountIdSet.add(DVObj.core_cpq_distributor__c);

                }
                if (DVObj.core_cpq_quote__c != null) {
                    quoteIdSet.add(DVObj.core_cpq_quote__c);
                }
            }

            if (!accountIdSet.isEmpty()) {
                manageQuoteShareWithDistyContacts(dvList, accountIdSet, 'delete');
                manageDpaAlnShareWithDistyContacts(dvList, accountIdSet, quoteIdSet, 'delete');
            }
        }
    }
    /****************************************************************************************************************
    * Method Name:manageDpaAlnShareWithDistyContacts
    * Date: 07/07/2021    
    * Description: Method to share and unshare DPA/ALNs related to the quote with it's extended distributor accounts.
    ***************************************************************************************************************************/    
    /*public static void manageDpaAlnShareWithDistyContacts(List < core_cpq_disty_visibility__c > dvList, set < Id > accountIdSet, set < Id > quoteIdSet, String operation) {
        try {
            if (dvList != null && !dvList.isEmpty()) {
                Map < Id, Set < Id >> distyAccountToUserIdMap = new Map < Id, Set < Id >> ();
                Set < Id > userIds = new Set < Id > ();
                Set < Id > dpaIds = new Set < Id > ();
                if (!accountIdSet.isEmpty()) {
                    for (user distyUser: [SELECT Id, accountId, Contact.accountId FROM User WHERE accountId IN: accountIdSet and IsActive = true]) {
                        if (distyAccountToUserIdMap.containsKey(distyUser.accountId)) {
                            distyAccountToUserIdMap.get(distyUser.accountId).add(distyUser.Id);
                        } else {
                            distyAccountToUserIdMap.put(distyUser.accountId, new Set < Id > {distyUser.Id});
                        }
                        userIds.add(distyUser.Id);
                    }
                }
                Map < Id, Set < Id >> qTodpaMap = new Map < Id, Set < Id >> ();
                List < core_cpq_dpa_aln__c > dpaList = [Select Id, core_cpq_active_quote__c from core_cpq_dpa_aln__c where core_cpq_active_quote__c in: quoteIdSet];
                for (core_cpq_dpa_aln__c dpa: dpaList) {
                    if (qTodpaMap.containsKey(dpa.core_cpq_active_quote__c)) {
                        qTodpaMap.get(dpa.core_cpq_active_quote__c).add(dpa.Id);
                    } else {
                        qTodpaMap.put(dpa.core_cpq_active_quote__c, new Set < Id > {dpa.Id});
                    }
                    dpaIds.add(dpa.Id);
                }

                Map < String, core_cpq_dpa_aln__share > dpaSharingMap = new Map < String, core_cpq_dpa_aln__share > ();
                List < core_cpq_dpa_aln__share > dpaSharingList = [Select Id, UserOrGroupId, ParentId from core_cpq_dpa_aln__share where ParentId in: dpaIds and UserOrGroupId in: userIds];
                for (core_cpq_dpa_aln__share dpaShareRec: dpaSharingList) {
                    dpaSharingMap.put('' + dpaShareRec.UserOrGroupId + dpaShareRec.ParentId, dpaShareRec);
                }
                List < core_cpq_dpa_aln__share > sharToDelete = new List < core_cpq_dpa_aln__share > ();
                List < core_cpq_dpa_aln__share > dpaAlnShareList = new List < core_cpq_dpa_aln__share > ();
                for (core_cpq_disty_visibility__c DVObj: dvList) {
                    if (qTodpaMap.containsKey(DVObj.core_cpq_quote__c)) {
                        Set < Id > dpaIdToIterate = qTodpaMap.get(DVObj.core_cpq_quote__c);
                        Set < Id > userIdToIterate = distyAccountToUserIdMap.get(DVObj.core_cpq_distributor__c);
                        for (Id dpaId: dpaIdToIterate) {
                            for (Id userId: userIdToIterate) {
                                if (operation.equalsIgnoreCase('delete')) {
                                    if (dpaSharingMap.containsKey('' + userId + dpaId)) { 
                                        sharToDelete.add(dpaSharingMap.get('' + userId + dpaId));
                                    }
                                }
                                if (operation.equalsIgnoreCase('grant')) {
                                    if (!dpaSharingMap.containsKey('' + userId + dpaId)) {
                                        dpaAlnShareList.add(new core_cpq_dpa_aln__share(ParentId = dpaId,
                                            UserOrGroupId = userId,
                                            AccessLevel = 'Read',
                                            RowCause = Schema.core_cpq_dpa_aln__share.RowCause.Manual));
                                    }
                                }
                            }
                        }
                    }
                }
                if (!sharToDelete.isEmpty()) {
                    delete sharToDelete;
                }
                if (!dpaAlnShareList.isEmpty()) {
                    insert dpaAlnShareList;
                }

            }
        } catch (Exception e) {
            PSG_Utility.logError(e);
        }

    }
    /****************************************************************************************************************
    * Method Name:manageQuoteShareWithDistyContacts
    * Date: 07/07/2021    
    * Description: Method to share and unshare quotes with extended disty accounts.
    ***************************************************************************************************************************/    
    /*public static void manageQuoteShareWithDistyContacts(List < core_cpq_disty_visibility__c > dvList, set < Id > accountIdSet, String operation) {
        if (dvList != null && !dvList.isEmpty()) {


            Map < String, Set < Id >> distyAccountToUserIdMap = new Map < String, Set < Id >> ();
            List < SBQQ__Quote__Share > listQuoteShareGrantAccess = new List < SBQQ__Quote__Share > ();
            try {
                if (!accountIdSet.isEmpty()) {
                    for (user distyUser: [SELECT Id, accountId, Contact.accountId FROM User WHERE accountId IN: accountIdSet and IsActive = true]) {
                        if (distyAccountToUserIdMap.containsKey(distyUser.accountId)) {
                            distyAccountToUserIdMap.get(distyUser.accountId).add(distyUser.Id);
                        } else {
                            distyAccountToUserIdMap.put(distyUser.accountId, new Set < Id > {distyUser.Id});
                        }
                    }

                    if (operation.equalsIgnoreCase('grant')) {
                        for (core_cpq_disty_visibility__c DVObj: dvList) {
                            if (distyAccountToUserIdMap.containsKey(DVObj.core_cpq_distributor__c)) {
                                for (Id userId: distyAccountToUserIdMap.get(DVObj.core_cpq_distributor__c)) {
                                    listQuoteShareGrantAccess.add(new SBQQ__Quote__Share(ParentId = DVObj.core_cpq_quote__c,
                                        UserOrGroupId = userId,
                                        AccessLevel = 'Read',
                                        RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual));
                                }
                            }
                        }
                        if (!listQuoteShareGrantAccess.isEmpty()) {
                            Insert listQuoteShareGrantAccess;
                        }
                    }
                    if (operation.equalsIgnoreCase('delete')) {
                        set < Id > parentQuoteIds = new set < Id > ();
                        set < Id > userIds = new set < Id > ();
                        for (core_cpq_disty_visibility__c DVObj: dvList) {
                            if (distyAccountToUserIdMap.containsKey(DVObj.core_cpq_distributor__c)) {
                                for (Id userId: distyAccountToUserIdMap.get(DVObj.core_cpq_distributor__c)) {
                                    userIds.add(userId);
                                    parentQuoteIds.add(dvObj.core_cpq_quote__c);
                                }
                            }
                        }

                        List < SBQQ__Quote__Share > quoteShareToDelete = [SELECT Id FROM SBQQ__Quote__Share
                            WHERE ParentId IN: parentQuoteIds AND UserORGroupId IN: userIds AND RowCause = 'Manual'
                        ];

                        if (!quoteShareToDelete.isEmpty()) {
                            delete quoteShareToDelete;
                        }
                    }
                }
            } catch (Exception e) {
                PSG_Utility.logError(e);

            }

        }
    }*/
}