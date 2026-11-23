@isTest
public class Prm_emailOptOutCtrl_Test {
    
    @isTest
    public static void mainTest(){
        //get role
        
        //get profile
        //create user
        //runas user
        //create account, contact, user
        //
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User u2 = new User(Alias = 'admn', Email='testadminuser@intel.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId=usRole.id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@intel.com');
        
        System.runAs(u2) {
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            
            Test.startTest();
            Account newAccount= new Account ();
            newAccount.name ='Test Account';
            newAccount.Industry = 'Banking';
            newAccount.BillingCity = 'Texas';
            newAccount.BillingCountry = 'USA';
            newAccount.BillingStreet = 'G-2101'; 
            newAccount.BillingState='MT';
            newAccount.RecordTypeId = recordTypeId;
            insert newAccount;
            
            Contact testContact = new Contact(
                LastName = 'Contact',
                firstName='Test',
                email ='testadminuser@intc.com',
                accountId = newAccount.Id
                
            );
            
            insert testContact;
            User runningUser = new User(FirstName='Test',LastName='AdminUser',alias='tauser',Email='testadminuser@int.com',
                                        UserName='testadminuser@intc.com', ContactId=[Select id from Contact].Id,ProfileId=[SELECT id FROM Profile WHERE Name='Partner'].Id,
                                        emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London', IsActive=true);//, UserRoleId = r.id);
            
            //insert runningUser;
            System.runAs(runningUser){
                
                List<Prm_emailOptOutCtrl.OptionWrapper> options = Prm_emailOptOutCtrl.getPicklistValues('Contact', 'Core_Country_Region__c');
                User result = Prm_emailOptOutCtrl.getCurrentUserDetails();
                
                // Prepare the response JSON string
                Map<String, Object> responseMap = new Map<String, Object>();
                Map<String, Object> response = new Map<String, Object>();
                Id id = [select id from contact where email = 'testadminuser@intc.com'].Id;
                System.debug(' Id -->'+id);
                response.put('contactId', id);
                response.put('tradeComplianceValue', true);
                response.put('selectedTimeZone', 'America/Los_Angeles');
                response.put('selectedCountry', 'USA');
                response.put('emailOptOut', false);
                
                responseMap.put('response', response);
                String responses = JSON.serialize(responseMap);
                Boolean result1 = Prm_emailOptOutCtrl.updateContact(responses);
            }
            
            Test.stopTest();
        }
    }
}