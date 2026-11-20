/**************************************************************************************************************************************************
* Apex Class Name : Core_Batch_A_E_DisableExtUser_Test
* Created Date: 25/09/2020 
* Description : Test class to cover Core_Batch_A_E_DisableExtUser and Core_Batch_A_E_DisableExtUser_Queue classes 
* Developer                 Date                     Description
* -------------------------------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre            24/09/2020               US731342 - Pipeline: IPS Issue fix implementation
*************************************************************************************************************************************************/

@isTest(SeeAllData=false)
public class Core_Batch_A_E_DisableExtUser_Test {
    
    @testSetup
    public static void testDataSetup()
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile usrprofile = [Select Id from Profile where name = 'System Administrator'];       
        
                
        User portalAccountOwner1 = new User(UserRoleId = portalRole.Id, Alias = 'admUse2r', Email='test1234@example.com', 
                                      EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US',FederationIdentifier ='8974563',
                                      LocaleSidKey='en_US', ProfileId = usrprofile.Id,TimeZoneSidKey='America/Los_Angeles', 
                                      UserName='forumuser22@example.com',PortalRole = 'Manager');
        
        User usr = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (usr) {
            insert portalAccountOwner1;  
            // put test setup code in here
        }        
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',RecordTypeId=intelAccRecTypeId,
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',OwnerId = portalAccountOwner1.Id);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',MailingCountry='India',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Success',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId(),
                                         Core_Login_Status__c ='deleted');
        
        insert testContact;        
        
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='Partner' ];
        User user1 = new User(Alias = 'admUse2r', Email='test1234@testing.com.testsetup', 
                              EmailEncodingKey='UTF-8', LastName='Admin', LanguageLocaleKey='en_US',FederationIdentifier ='9342657',
                              LocaleSidKey='en_US', ProfileId = profile1.Id, contactid = testContact.Id,isActive = false,
                              TimeZoneSidKey='America/Los_Angeles', UserName='forumuser22@test.com',PortalRole = 'Manager');
        System.runAs (usr) {
            insert user1;
            // put test setup code in here
        }     
        
    }
    
    @isTest public static void testScheduler(){
        Test.startTest();
            Core_Batch_A_E_DisableExtUser_Scheduler sch1 = new Core_Batch_A_E_DisableExtUser_Scheduler();        
            String sch = '0 0 23 * * ?';
            String jobId = system.schedule('Test check', sch, sch1);
            
            Core_Batch_A_E_DisableExtUser_Queue.createLogEntry(1,system.now()); 
        
        Test.stopTest();
        system.assertEquals(true, jobId != null? true : false , 'Scheduled successfully');
        

    }
}