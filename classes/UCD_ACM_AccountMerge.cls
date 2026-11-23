public without sharing class UCD_ACM_AccountMerge {

    private static Id intelAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    public static Map<Id, List<Id>> cwlIdMap = new Map<Id, List<Id>>();
    public static Map<Id, List<Id>> cpeIdMap = new Map<Id, List<Id>>();

    public static void beforeDeleteAccountMerge(List<Account> oldRecords) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : oldRecords) {
            accountIds.add(acc.Id);
        }

        List<Core_Account_Compliance_Watch_List__c> cwlRecords = [
            SELECT Id, Core_Account_Id__c FROM Core_Account_Compliance_Watch_List__c
            WHERE Core_Account_Id__c IN :accountIds
        ];

        List<Account_Business_Types__c> cpeRecords = [
            SELECT Id, Account__c FROM Account_Business_Types__c
            WHERE Account__c IN :accountIds
        ];

        for (Core_Account_Compliance_Watch_List__c cwl : cwlRecords) {
            if (!cwlIdMap.containsKey(cwl.Core_Account_Id__c)) {
                cwlIdMap.put(cwl.Core_Account_Id__c, new List<Id>());
            }
            cwlIdMap.get(cwl.Core_Account_Id__c).add(cwl.Id);
        }

        for (Account_Business_Types__c cpe : cpeRecords) {
            if (!cpeIdMap.containsKey(cpe.Account__c)) {
                cpeIdMap.put(cpe.Account__c, new List<Id>());
            }
            cpeIdMap.get(cpe.Account__c).add(cpe.Id);
        }
    }

    public static void afterDeleteAccountMerge(List<Account> accList) {
        Map<Id, String> accMap = new Map<Id, String>();
        for (Account acc : accList) {
            if((acc.MasterRecordId != null && acc.RecordTypeId  == intelAcctRTId)){
                accMap.put(acc.Id,acc.Core_Business_Party_Id__c);
            }
        }

        String cwlIdMapJson = JSON.serialize(cwlIdMap);
        String cpeIdMapJson = JSON.serialize(cpeIdMap);
        
        setAcctXWalkOnMerge(accMap, cwlIdMapJson, cpeIdMapJson);
    }

    @Future(callout=true)
    public static void setAcctXWalkOnMerge(Map<Id, String> accMap, String cwlIdMapJson, String cpeIdMapJson) {
        Map<Id, List<Id>> cwlIdMap = (Map<Id, List<Id>>) JSON.deserialize(cwlIdMapJson, Map<Id, List<Id>>.class);
        Map<Id, List<Id>> cpeIdMap = (Map<Id, List<Id>>) JSON.deserialize(cpeIdMapJson, Map<Id, List<Id>>.class);

        for (Id acc : accMap.keySet()) {
            UCD_ACM_AccountDeactivationService acctRelitoService = new UCD_ACM_AccountDeactivationService();
            UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation responseFromRelito = acctRelitoService.removeAcctXwalk(accMap.get(acc), acc, 'Deactivate');
            if(cwlIdMap.get(acc) != null){
                acctRelitoService.removeCWLXWalk(accMap.get(acc), 'DEACTIVATE', new Set<Id>(cwlIdMap.get(acc)));
            }
            if(cpeIdMap.get(acc) != null){
                acctRelitoService.removeCPEXWalk(accMap.get(acc), 'DEACTIVATE', new Set<Id>(cpeIdMap.get(acc)));
            }
        }
    }
}