@isTest
public class CRM_APControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create an Account Plan record
        AccountPlan accountPlan = new AccountPlan(Name = 'Test Account Plan');
        insert accountPlan;

        // Create test Hot Buttons related to the Account Plan
        List<CRM_Hot_Button__c> hotButtons = new List<CRM_Hot_Button__c>{
            new CRM_Hot_Button__c(Name = 'Test Button 1', CRM_Description__c = 'Desc 1', CRM_Priority__c = 'High', CRM_Account_Plan__c = accountPlan.Id),
            new CRM_Hot_Button__c(Name = 'Test Button 2', CRM_Description__c = 'Desc 2', CRM_Priority__c = 'Medium', CRM_Account_Plan__c = accountPlan.Id)
        };
        insert hotButtons;
    }

    @isTest
    static void testGetHotButtons() {
        // Fetch the Account Plan ID
        accountPlan accountPlan = [SELECT Id FROM accountPlan LIMIT 1];

        // Call the method
        Test.startTest();
        List<CRM_Hot_Button__c> hotButtons = CRM_APController.getHotButtons(accountPlan.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, hotButtons, 'Hot Buttons list should not be null');
        System.assertEquals(2, hotButtons.size(), 'Expected two Hot Buttons to be returned');
    }

    @isTest
    static void testSaveHotButtonsSuccess() {
        // Fetch the Account Plan ID
        accountPlan accountPlan = [SELECT Id FROM accountPlan LIMIT 1];

        // Create a new Hot Button record
        CRM_Hot_Button__c newHotButton = new CRM_Hot_Button__c(
            Name = 'New Test Button',
            CRM_Description__c = 'New Desc',
            CRM_Priority__c = 'Low',
            CRM_Account_Plan__c = accountPlan.Id
        );

        // Call the method inside test context
        Test.startTest();
        CRM_APController.saveHotButtons(new List<CRM_Hot_Button__c>{ newHotButton });
        Test.stopTest();

        // Verify the record was inserted
        CRM_Hot_Button__c savedHotButton = [SELECT Id, Name FROM CRM_Hot_Button__c WHERE Name = 'New Test Button' LIMIT 1];
        System.assertNotEquals(null, savedHotButton, 'Saved Hot Button should not be null');
    }


    @isTest
    static void testGetPriorityPicklistValues() {
        Test.startTest();
        List<String> picklistValues = CRM_APController.getPriorityPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        System.assert(picklistValues.size() > 0, 'There should be at least one picklist value');
    }
}