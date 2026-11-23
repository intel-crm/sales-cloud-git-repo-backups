public with sharing class UCD_ACM_ContactDomain implements UCD_ACM_DomainContracts.IContactDomain{

    private static UCD_ACM_DomainContracts.IContactDomain instance = null;

    private UCD_ACM_ContactDomain() {}

    public static UCD_ACM_DomainContracts.IContactDomain getInstance() {
        if (instance  == null) {
            instance  = new UCD_ACM_ContactDomain();
        }
        return instance;
    }

    public Core_UCD_MoveContactWithCases_Model.initializeWrapper GECCaseValidation(List<Case> caseDetails, Core_UCD_MoveContactWithCases_Model.initializeWrapper  initializeWrapper){

        for(Case caseDetail :caseDetails){
             if(!initializeWrapper.gecCaseFound && caseDetail.Core_IPS_GEC_Case__c && String.isNotBlank(caseDetail.Core_IPS_GEC_Status__c) &&  caseDetail.Core_IPS_GEC_Status__c.startsWith('On Hold')){
                    initializeWrapper.gecCaseFound = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' GEC Case Found, moving contact is not allowed.'));
                }
        }
        return initializeWrapper;
    }

}