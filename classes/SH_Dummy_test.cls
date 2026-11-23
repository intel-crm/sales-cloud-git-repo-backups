@isTest
public class SH_Dummy_test {
    
    @isTest
    static void testUpdateContactEntitlementList() {
        // Step 1: Create test data (Contact and Core_Contact_Entitlement__c records)
        Account testAccount1 = new Account(Name='testAccount1', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_IPS_Active__c =false,
            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
            BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false);
        insert testAccount1;
        
        Contact testContact =new Contact(FirstName='testFirstName1', LastName='testLastName', Email='testContact1@testing.com.test',
            Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount1.Id, MailingCountry = 'India');
        insert testContact;
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c(name ='Customer Sales Order Reporting', 
                                                                  Core_Category__c='Order Management',
                                                                  Core_Sub_Category__c='Web Reporting',
                                                                  Core_Help_Text__c='Help text',
                                                                  Core_ERPM_Engagement_Id__c=cee.id,
                                                                  Core_Display_Name__c='test',
            Core_IsActive__c = true
        );
        insert entitlement;

        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = testContact.Id, 
            Core_Entitlement_Id__c = entitlement.Id,
            Core_Selected__c = true,
            Core_Status__c = 'Complete'
        );
        insert new List<Core_Contact_Entitlement__c>{ce1};

        // Step 2: Start test context to handle future methods
        Test.startTest();

        // Step 3: Call the method you want to test
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        UCD_ACM_MoveContactWithCases_Cont.updateContactEntitlementList(testContact.Id);

        // Step 4: Stop test context and handle async methods (future call)
        Test.stopTest();

        // Step 5: Assert the results
        // Re-query the Core_Contact_Entitlement__c records to check if they were updated
        Core_Contact_Entitlement__c updatedCe1 = [SELECT Core_Selected__c, Core_Status__c, Core_Update_Reason__c, Core_Status_of_Assignment_Failure__c FROM Core_Contact_Entitlement__c WHERE Id = :ce1.Id];
        //Core_Contact_Entitlement__c updatedCe2 = [SELECT Core_Selected__c, Core_Status__c, Core_Update_Reason__c, Core_Status_of_Assignment_Failure__c FROM Core_Contact_Entitlement__c WHERE Id = :ce2.Id];
        
        // Assertions to verify the updates
        System.assertEquals(false, updatedCe1.Core_Selected__c, 'Core_Selected__c should be false');
        System.assertEquals('PENDING', updatedCe1.Core_Status__c, 'Core_Status__c should be PENDING');
        System.assertEquals('UPDATE_REASON_CHANGE_ACCOUNT', updatedCe1.Core_Update_Reason__c, 'Core_Update_Reason__c should be UPDATE_REASON_CHANGE_ACCOUNT');
        System.assertEquals('Pending Removal', updatedCe1.Core_Status_of_Assignment_Failure__c, 'Core_Status_of_Assignment_Failure__c should be Pending Removal');

       /* System.assertEquals(false, updatedCe2.Core_Selected__c, 'Core_Selected__c should be false');
        System.assertEquals('PENDING', updatedCe2.Core_Status__c, 'Core_Status__c should be PENDING');
        System.assertEquals('UPDATE_REASON_CHANGE_ACCOUNT', updatedCe2.Core_Update_Reason__c, 'Core_Update_Reason__c should be UPDATE_REASON_CHANGE_ACCOUNT');
        System.assertEquals('Pending Removal', updatedCe2.Core_Status_of_Assignment_Failure__c, 'Core_Status_of_Assignment_Failure__c should be Pending Removal');*/
    }
    
}