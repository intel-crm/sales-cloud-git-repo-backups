@isTest
public class PMP_PartnerOnGoingVisitNotifyBatchTest {
//IPA2.0 - As part of TWC729-7977 commented the entire class
 /*   
    @testSetup
    public static void setup() {
        
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
        
        List<Contact> contList = new List<contact>();
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=testAccount.Id;
        cont3.lastName='Johnny';
        cont3.FirstName='Parker';
        cont3.email='testemail@intel.com';
        cont3.Core_Job_Function__c='Branch Manager';
        //cont3.Core_Profession__c='Sales';
        cont3.Core_IPA_PartnerRole__c='FPGA Designer';
        cont3.Core_Preferred_Language__c='FRA';
        insert cont3;
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',
                                    UserName='test2usr@xyz.com', ContactId=cont3.Id,ProfileId=partnerProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London',
                                    isActive = true);
        
        insert partnerUser;
        
        //Create sample Core_Apex_EmailNotification__c records.
        Core_Apex_EmailNotification__c record1 = New Core_Apex_EmailNotification__c(Name='Partner_OnGoing_Visit', Core_Date_Reference_Txt__c = 'PMP_Company_Status_Update_Dt__c',
                                                                                    Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin,PMP_External_Marketing_Specialist',
                                                                                    Core_Description_Txt__c='Reminder Emails for users who have not logged in since some time',
                                                                                    Core_Email_Template_Nm__c = 'PMP_Company_Under_Review_Template_for_Admin',
                                                                                    Core_IsActive_Ind__c = true,Core_IsRecurring_Ind__c = false, Core_Query_String_Txt__c = 'NA',
                                                                                    Core_Object_Nm__c = 'User',Core_NumberOfDays_Nbr__c = 1);
        
        insert record1;
    }    
    
    @isTest
    public static void batchTest(){
        test.startTest();
        
        PMP_PartnerOnGoingVisitNotifyBatch batch = new PMP_PartnerOnGoingVisitNotifyBatch(); 
        database.executebatch(batch);
        test.stopTest();
        system.assertNotEquals(batch, null);
    }*/
}