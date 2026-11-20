/****************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForPartners_Test 
* Version     : 1.0 
* Created Date: 11/25/2020
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Priyanka                                11/25/2020           Test class for the class PMP_SendEmailAlertsForPartners
*****************************************************************************************************************************************/

@isTest
public class PMP_SendEmailAlertsForPartners_Test {
    
    @testSetup
    public static void testDataSetUp() {
        User u =PMP_TestDataUtility.createUser(true); 
        User u1 =PMP_TestDataUtility.createInactiveUser(true); 
        System.runAs(u){
            Account testAccount = new Account();
            testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
            testAccount.Name = 'Test Account 19-Jun-19';       
            testAccount.Core_Account_Country__c='India';
            testAccount.Core_Sales_Group_New__c='US Sales Group';
            testAccount.Core_Account_Type__c='ODM';
            testAccount.BillingStreet='Bangalore Central';
            testAccount.BillingCity='Bangalore';
            testAccount.BillingCountry='IND';
            testAccount.BillingState='KA';
            testAccount.BillingPostalCode='560029';
            testAccount.Industry='Agriculture';
            insert testAccount;
            
            Core_Apex_EmailNotification__c  emNotif=new Core_Apex_EmailNotification__c ();
            emNotif.name ='unique_name_addSomethingSpecialHere';
            emNotif.Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin';
            emNotif.Core_IsActive_Ind__c=true;
            emNotif.Core_Email_Template_Nm__c='unique_name_addSomethingSpecialHere';
            emNotif.Core_IsRecurring_Ind__c=false;
            insert emNotif;
            
            // Create Document for headerURL test
            Document testDoc = new Document();
            testDoc.Name = 'IntelLogo';
            testDoc.Body = Blob.valueOf('Test Document Body');
            testDoc.ContentType = 'image/png';
            testDoc.FolderId = UserInfo.getUserId();
            insert testDoc;
            
            List<PMP_Company__c> compList= new List<PMP_Company__c>();
            PMP_Company__c companyInfo = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
                                                            PMP_Account_Id__c=testAccount.Id);
            companyInfo.PMP_Partner_Submitter_UserId__c=u1.Id;
            compList.add(companyInfo);
            PMP_Company__c companyInfo1 = new PMP_Company__c(Name='TestCompany2',PMP_Account_Industry__c='Others',
                                                             PMP_Account_Id__c=testAccount.Id);
            companyInfo1.PMP_Partner_Submitter_UserId__c=u1.Id;
            compList.add(companyInfo1);
            insert compList;
            
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.Body = 'test email body';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
          
            
        }
    }
    
    
    
    public static testMethod void sendEmailTest(){
        
        EmailTemplate empTemp=[select id,Name,DeveloperName from EmailTemplate where DeveloperName ='unique_name_addSomethingSpecialHere' LIMIT 1];
        test.startTest();
        List<PMP_Company__c> partners = [Select Name, PMP_Account_Id__c from PMP_Company__c limit 2 ];
        List<PMP_SendEmailAlertsForPartners.SendEmailRequestWrapper> reqwrplist = new List<PMP_SendEmailAlertsForPartners.SendEmailRequestWrapper>();
        
        PMP_SendEmailAlertsForPartners.SendEmailRequestWrapper req1 = new PMP_SendEmailAlertsForPartners.SendEmailRequestWrapper();
        req1.partnerId = partners[0].Id;
        req1.templateName=empTemp.DeveloperName;
        reqwrplist.add(req1);
        PMP_SendEmailAlertsForPartners.SendEmailRequestWrapper req2 = new PMP_SendEmailAlertsForPartners.SendEmailRequestWrapper();
        req2.partnerId = partners[0].Id;
        req2.templateName=empTemp.DeveloperName;
        reqwrplist.add(req2);
        Integer beforeInvocations = Limits.getEmailInvocations();
        System.assertEquals(0,beforeInvocations,'no email sent');
        PMP_SendEmailAlertsForPartners.sendPartnerEmailNotifications(reqwrplist);
        test.stopTest(); 
        
    }
     @isTest
    public static void testGetHeaderURL() {
        Test.startTest();
        PMP_SendEmailAlertsForPartners emailAlert = new PMP_SendEmailAlertsForPartners();
        String headerURL = emailAlert.getHeaderURL();
        Test.stopTest();
        
        System.assertNotEquals(null, headerURL, 'Header URL should not be null');
        System.assert(headerURL.contains('servlet.ImageServer'), 'Header URL should contain servlet.ImageServer');
    }
    

    
}