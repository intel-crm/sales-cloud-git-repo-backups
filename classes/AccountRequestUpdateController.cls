public class AccountRequestUpdateController {
     private final Account_Create_Request__c acc;

    public AccountRequestUpdateController(ApexPages.StandardController stdController) {
        this.acc = (Account_Create_Request__c)stdController.getRecord();
    }

    public PageReference updateAccountRequestField() {
        try {
            acc.Address_Standardization_Time__c = System.now();
            update acc;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Account Request field updated successfully!'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating Account field: ' + e.getMessage()));
        }
        return null;
    }
}