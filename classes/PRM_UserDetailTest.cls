@isTest
public class PRM_UserDetailTest{
    @istest static void testPrefferLangOfUser(){
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick'; //Account
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.abc.com';  
        insert testAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.MailingCountry='USA';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.Core_Preferred_Language__c = 'ENG';
        insert cont;
    
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        UserRole r = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
        //system.debug('role-->'+r);
        //system.debug('communityUsrProfile-->'+communityUsrProfile);
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',
                                        UserName='test2usr@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,IsActive = true,
                                        emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        test.startTest();
        insert partnerUser;
        System.runAs(partnerUser){
            PRM_UserDetail.contactPrefferedLanguage();
        }
        test.stopTest();
        System.assertEquals(cont.Id,partnerUser.ContactId,'Value does not match');
    }
}