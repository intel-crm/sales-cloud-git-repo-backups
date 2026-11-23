public class core_OppSupport_EditController {
    private ApexPages.StandardController standardController;
    
    public core_OppSupport_EditController(ApexPages.StandardController controller) {
        standardController = controller;
    }
    
    public PageReference saveRecord() {
        // Perform your custom save logic here
        // For example:
        system.debug('---inside this vs code--');
        Core_Opportunity_Support__c obj = (Core_Opportunity_Support__c)standardController.getRecord();
        update obj; // Save the changes
        
        // Redirect back to the record detail page
        PageReference detailPage = standardController.view();
        return detailPage;
    }
}