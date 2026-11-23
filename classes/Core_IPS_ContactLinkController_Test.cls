@isTest
public class Core_IPS_ContactLinkController_Test{
    static testmethod void getActiveUserMethod(){
    
        List<User> u = [select id,ContactId from user where usertype='Standard' AND ISActive=true limit 1 ];
        Test.startTest();
        Account accountRecord = new Account(
            Name = 'Dell Products',
            Core_Account_Type__c = 'Distributor',
            Core_Sales_Segment__c = 'Compute',
            Industry = 'Banking',
            BillingCity = 'Delhi',
            BillingCountry = 'USA',
            billingState = 'AK',
            billingStreet = 'Bratislava 1',
            Core_IPS_Active__c = true
        );
        insert accountRecord;
        System.AssertEquals('Dell Products',accountRecord.Name);
        
        Contact contactRecord = new Contact(
            FirstName = 'Ding Dong', 
            Lastname = 'Dell',
            Email = 'Contact1Dell@gmail.com',
            Accountid = accountRecord.id,
            Core_IPS_Intel_Support_Owner__c=u[0].id,
            Core_IPS_Active__c = true,
            MailingCountry = 'India'
        );
        insert contactRecord;
        System.assertNotEquals(null, contactRecord);
        
        Core_IPS_ContactLinkController ipsCustomerCaseController = new Core_IPS_ContactLinkController();
        ipsCustomerCaseController.showActiveUsers();
        Test.stopTest();
       
}
}