public with sharing class UCD_ACM_ContactService  implements UCD_ACM_ServiceContracts.IAContactService{

    private static UCD_ACM_ServiceContracts.IAContactService instance = null;

    public static UCD_ACM_ServiceContracts.IAContactService getInstance(){
        if (instance  == null){
            instance  = new UCD_ACM_ContactService();
        }
        return instance;
    }

    private UCD_ACM_ContactService() { 

    }

    public static Core_UCD_MoveContactWithCases_Model.initializeWrapper getCurrContactDetails(String contactId){
		UCD_ACM_ServiceContracts.IContactMoveGovernance contactMoveGov = UCD_ACM_ContactMoveGovernance.getInstance();
		return contactMoveGov.getCurrContactDetails(contactId);
    }

    public static String caseUpdate(){
        UCD_ACM_ServiceContracts.IContactMoveGovernance contactMoveGov = UCD_ACM_ContactMoveGovernance.getInstance();

	    return contactMoveGov.caseUpdate();
    }

}