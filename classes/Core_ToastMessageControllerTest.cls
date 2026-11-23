@isTest
public class Core_ToastMessageControllerTest {

    static testMethod void getCheckBoxTest(){
        // Get the profile we'll use for our test users
        Profile p = [select Id from Profile where Name = 'IT Admin'];
        
        // Test users
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@mail.com');
     insert u;
        
         List <Account> AccListList = new List <Account> ();
        For(integer i = 0; i <5; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c='CCG Sales Group';
            AccListList.add(accountInstance);
        }
         System.runAs(u) {
        insert AccListList;
         }
        system.assertEquals(5, AccListList.size());
        List<Opportunity> opportunityList=new List<Opportunity>();
         for(integer i = 0; i < 5; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Prospecting';
            opportunityInstance.Name = 'Test' + i;
             opportunityInstance.Core_External_User__c=true;
             opportunityInstance.AccountId =AccListList[0].id ;
            opportunityList.add(opportunityInstance);
        }
           System.runAs(u) {
            insert opportunityList;
    }
        system.assertEquals(5, opportunityList.size());
        test.startTest();
        Core_ToastMessageController.isCheck=False;
        Core_ToastMessageController.isCheck2=False;
        Core_ToastMessageController.getCheckBox(opportunityList[0].id);
        Core_ToastMessageController.setcheckfalse(opportunityList[0].id);
        test.stopTest();
    }
}