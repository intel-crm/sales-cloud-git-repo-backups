/**************************************************************************************
Apex Class Name:  Core_CustomContactLookupController_Test
Version     : 1.0 
Created Date: 16 Feb 2017
Description    : This class is Test class for Core_CustomContactLookupController
*************************************************************************************/
@isTest
public class Core_CustomContactLookupController_Test{
 public static testMethod void contactLookupMethod(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
     
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        
       
        system.runas(itAdminUser){
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts',Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_English_Only_Name__c ='samplename',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_Alternate_Language_Name__c='test',
                                        BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124');
        insert testAccount; 
                                      
        List<Contact> lsttestContactUpdate = new List<Contact>();
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',Core_English_Only_First_Name__c='',Core_English_Only_Last_Name__c='',
                                          AccountId=testAccount.Id,Core_Local_First_Name__c='david',Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id,Core_Contact_B2B_Indicator__c=false,Core_Personal_Email_Indicator__c=false,MailingCountry='USA',
                                         Core_Enterprise_Id__c='12345',Core_ERPM_Integration_Status__c = 'Pending',Core_eRPM_Person_Id__c = '111111');
   
        insert testContact;
        
        Contact testConUpdate = new Contact();
        testConUpdate = [select id,firstname,lastname from contact where id=:testContact.id];
        testConUpdate.firstname = 'TestName123234';
        testConUpdate.lastname = 'testLastName123';
        update testConUpdate;
        
        Test.startTest();
        PageReference pageRef = Page.Core_CustomContactLookup;
        Test.setCurrentPage(pageRef);
        Core_CustomContactLookupController lookupcontroller = new Core_CustomContactLookupController();
        lookupcontroller.getFormTag();
        lookupcontroller.getTextBox();
        lookupcontroller.search();
        Test.stopTest(); 
   }
 }
}