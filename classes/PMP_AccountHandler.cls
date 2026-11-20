/**************************************************************************************
Apex Class Name:  PMP_AccountHandler
Version     : 1.0 
Created Date: 13 JAN 2021
Function    : methods to handle the company records updation.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gopala Krishna Ch              01/13/2021              Original Version
*************************************************************************************/



public without sharing class PMP_AccountHandler {
    
    /***************************************************************************************************** 
Method Name:                                             filterDistiBizOrgs
@return  :                                               String
Modified By:                          Date:              Changes: 
Gopala Krishna Ch                     01/13/2021         US854868 - KTBE : Changes in Biz org, Specialty, Partner Segment should show the updated data. 
******************************************************************************************************/    
    public static String filterDistiBizOrgs(String accountBizType){
        
        String bizorgtype = '';
        if(accountBizType!=''){
            for(String biz : accountBizType.split('\\;')){
                if(PMP_StaticConstants_Partner.bizOrgTypes.contains(biz)){
                    
                    bizorgtype += biz + ';';
                }
            }
            
            if(bizorgtype.endsWith(';')) {
                bizorgtype = bizorgtype.substring(0, bizorgtype.length() - 1);
            }
        }
        return bizorgtype;
    }
    
    /***************************************************************************************************** 
Method Name:                                             updatePartnerInfo
@return  :                                               String
Description                                              This method is used to update the company records
Modified By:                          Date:              Changes: 
Gopala Krishna Ch                     01/13/2021         US854868 - KTBE : Changes in Biz org, Specialty, Partner Segment should show the updated data. 
Sathish                               12/9/2021          OPID Restructure - update company details when any account related to the Company changes
******************************************************************************************************/    
    public static void updatePartnerInfo(List<Account> newList, Map<Id, Account> newMap, Map<Id, Account> oldMap) {
    Set<Id> accountsChanged = new Set<Id>();
    
    Id intelaccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Id pagRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PMP_StaticConstants_Partner.pagRecordTypeName).getRecordTypeId();
              
    Set<Id> accountsAccTypeChanged = new Set<Id>();
    
        try {
            updateChangedAccounts(newList, oldMap, accountsChanged, accountsAccTypeChanged, intelaccRecordTypeId, pagRecordTypeId);
            PMP_AccountBenefitPartnerUtility.updateTierOnMPI(accountsChanged);
        } catch (Exception ex) {
            PMP_Utility.logError(ex, 'PMP_AccountHandler');
        }
    }

    private static void updateChangedAccounts(List<Account> newList, Map<Id, Account> oldMap, Set<Id> accountsChanged, Set<Id> accountsAccTypeChanged, Id intelaccRecordTypeId, Id pagRecordTypeId) {
        if (!newList.isEmpty()) {
            for (Account acc : newList) {
                Account old = oldMap.get(acc.Id);
                
                if (isPartnerSegmentChanged(acc, old, pagRecordTypeId)) {
                    accountsChanged.add(acc.Id);
                }
                if (isAccountTypeChanged(acc, old, pagRecordTypeId)) {
                    accountsChanged.add(acc.Id);
                    accountsAccTypeChanged.add(acc.Id);
                }
                if (isIntelAccountChanged(acc, old, intelaccRecordTypeId)) {
                    accountsChanged.add(acc.Id);
                }
            }
        }
    }

    private static boolean isPartnerSegmentChanged(Account acc, Account old, Id pagRecordTypeId) {
        return (acc.RecordTypeId == pagRecordTypeId) && (acc.Core_IPA_Partner_Segment__c != old.Core_IPA_Partner_Segment__c);
    }

    private static boolean isAccountTypeChanged(Account acc, Account old, Id pagRecordTypeId) {
        return (acc.RecordTypeId == pagRecordTypeId) && (acc.Core_Account_Type__c != old.Core_Account_Type__c);
    }

    private static boolean isIntelAccountChanged(Account acc, Account old, Id intelaccRecordTypeId) {
        return (acc.RecordTypeId == intelaccRecordTypeId) && 
            (acc.Name != old.Name || 
                acc.Core_User_Defined_Website__c != old.Core_User_Defined_Website__c ||
                acc.Core_IPA_Partner_Role__c != old.Core_IPA_Partner_Role__c);
    }


    
}