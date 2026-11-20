@isTest
public class PRM_ExternalAPIControllerTest {
	@isTest
    public static void getAccountId(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_OnePartnerID__c = testAccount.Id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=testAccount.Id;
        cont3.lastName='Johnny';
        cont3.FirstName='Parker';
        cont3.MailingCountry='USA';
        cont3.email='Peterparker1@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_IPA_PartnerRole__c='Distributor';
        cont3.Core_Preferred_Language__c='FRA';
        insert cont3;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',
                                    UserName='test2usr@xyz.com', ContactId=cont3.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser;
		Boolean accessCheck;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PRM_ExternalAPIControllerMock());
        System.runAs(partnerUser){
           // PRM_ExternalAPIController.getAccountId();
            PRM_ExternalAPIController.getAccountId('pageName');
           
            PRM_ExternalAPIController.getReportDetails('points-opportunity');
            accessCheck = PRM_ExternalAPIController.checkAccess();
            PRM_ExternalAPIController.getEmbeddingDataForReport('f3afa893-d30d-44f1-9f77-742047b7072f', '9b495f3c-f535-4be5-91c4-3a266ef14107','points-opportunity');
            
        }
		Test.stopTest();        
		System.assertNotEquals(null, accessCheck);
    }
}