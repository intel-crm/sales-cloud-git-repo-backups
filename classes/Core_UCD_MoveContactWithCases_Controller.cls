public with sharing class Core_UCD_MoveContactWithCases_Controller {

    UCD_ACM_ServiceContracts.IAContactService contactServiceInstance = UCD_ACM_ContactService.getInstance();


    public Core_UCD_MoveContactWithCases_Controller(ApexPages.standardcontroller controller) {
        Core_UCD_MoveContactWithCases_Model.initializeWrapper wrapper = contactServiceInstance.getCurrContactDetails(controller.getId());
    }

    public PageReference updateCasesOnSave(){
        PageReference page = null;
        String ErrorMessage = contactServiceInstance.caseUpdate();
        return page;
    }
}