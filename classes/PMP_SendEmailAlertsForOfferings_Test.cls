/****************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForOfferings_Test 
* Version     : 1.0 
* Created Date: 11/24/2020
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Priyanka                                11/24/2020           Test class for the class PMP_SendEmailAlertsForOfferings
*****************************************************************************************************************************************/

@isTest
public class PMP_SendEmailAlertsForOfferings_Test {
    
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_SendEmailAlertsForOfferings.isWorking();
        System.assertEquals(true, result);
    }
    // @testSetup static void setup() {
    //     User u =PMP_TestDataUtility.createUser(true); 
    //     User u1 =PMP_TestDataUtility.createInactiveUser(true); 
        
    //     System.runAs(u){
    //         Account testAccount = new Account();
    //         testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
    //         testAccount.Name = 'Test Account 19-Jun-19';       
    //         testAccount.Core_Account_Country__c='India';
    //         testAccount.Core_Sales_Group_New__c='US Sales Group';
    //         testAccount.Core_Account_Type__c='ODM';
    //         testAccount.BillingStreet='Bangalore Central';
    //         testAccount.BillingCity='Bangalore';
    //         testAccount.BillingCountry='IND';
    //         testAccount.BillingState='KA';
    //         testAccount.BillingPostalCode='560029';
    //         testAccount.Industry='Agriculture';
    //         insert testAccount;
            
    //         Core_Apex_EmailNotification__c  emNotif=new Core_Apex_EmailNotification__c ();
    //         emNotif.name ='unique_name_addSomethingSpecialHere';
    //         emNotif.Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin';
    //         emNotif.Core_IsActive_Ind__c=true;
    //         emNotif.Core_IsRecurring_Ind__c=false;
    //         emNotif.Core_Email_Template_Nm__c='unique_name_addSomethingSpecialHere';
    //         insert emNotif;
            
    //         PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',
    //                                                         PMP_Account_Id__c=testAccount.Id);
    //         insert testCompany;
    //         PMP_Company__c partner_wc = new PMP_Company__c(Name='workingPartner1', 
    //                                                    PMP_Is_Working_Copy_Ind__c = true,
    //                                                    PMP_Is_Enabled_Lead_Gen_Nm__c = 'true',
    //                                                    PMP_Is_Lead_Gen_Limited_Nm__c = 'true',
    //                                                    PMP_Company_Lead_Gen_Language_Nm__c = 'English',
    //                                                    PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review);
    //     insert partner_wc;
        
    //     PMP_Company__c Partner_pc = new PMP_Company__c(Name='pubPartner2', 
    //                                                    PMP_Is_Published_Ind__c=true, 
    //                                                    PMP_Working_Copy_Id__c=partner_wc.Id,
    //                                                    PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Approved,
    //                                                    PMP_Is_Working_Copy_Ind__c = false,
    //                                                    PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced);
    //     insert Partner_pc;
	// 	partner_wc.PMP_Published_Copy_Id__c = Partner_pc.Id;
    //     update partner_wc;
        
            
    //         //id subUserId = u1.Id;
    //         PMP_Partner_Offering__c testOffering1 =PMP_TestDataUtility.createOffering('Test 19 feb 8:50 PM', 'Public Content','Test 19 feb 8:50 PM',Partner_pc.id,true,'Published','The paper Company');
    //         testOffering1.PMP_Offering_Submitter_UserId__c=u1.Id;
    //         PMP_Partner_Offering__c testOffering2=PMP_TestDataUtility.createOffering('Test 19 feb 8:51 PM', 'Public Content','Test 19 feb 8:51 PM',Partner_pc.id,true,'Published','The paper Company2');
    //         testOffering2.PMP_Offering_Submitter_UserId__c=u1.Id;
            
    //         List<PMP_Partner_Offering__c> offlist= new List<PMP_Partner_Offering__c>{testOffering1,testOffering2};
    //             update offlist;
            
    //         List<PMP_OPID_MPI_Rel__c> junction= new List<PMP_OPID_MPI_Rel__c>();
    //     Set<Id> s = new Set<Id>();
    //     PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
    //     jun.PMP_One_Partner_ID__c= testAccount.Id;
    //     jun.PMP_Marketing_Profile_Id__c= Partner_pc.Id;
    //     jun.Is_Active__c=true;
    //     junction.add(jun);
    //     insert junction;
        
    //         EmailTemplate validEmailTemplate = new EmailTemplate();
    //         validEmailTemplate.isActive = true;
    //         validEmailTemplate.Name = 'name';
    //         validEmailTemplate.Body = 'test email body';
    //         validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
    //         validEmailTemplate.TemplateType = 'text';
    //         validEmailTemplate.FolderId = UserInfo.getUserId();
    //         insert validEmailTemplate;
    //     } 
        
    // }
    
    // @isTest
    // public static void sendEmailTest(){
    //     // usersetup();  
    //     EmailTemplate empTemp=[select id,Name,DeveloperName from EmailTemplate where DeveloperName ='unique_name_addSomethingSpecialHere' LIMIT 1];
    //     test.startTest();
    //     PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper reqWrp1 = new PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper();
    //     PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper reqWrp2 = new PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper();
        
    //     List<PMP_Partner_Offering__c> offlist = [select Id from PMP_Partner_Offering__c limit 2];
    //     reqWrp1.offeringId=offlist[0].Id;
    //     // reqWrp1.submitterId=UserInfo.getUserId();
    //     reqWrp1.templateName=empTemp.DeveloperName;
        
    //     reqWrp2.offeringId=offlist[1].Id;
    //     //reqWrp2.submitterId=UserInfo.getUserId();
    //     reqWrp2.templateName=empTemp.DeveloperName;
        
    //     List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper> reqWrapper = new List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper>();
    //     reqWrapper.add(reqWrp1);
    //     reqWrapper.add(reqWrp2);
        
        
    //     Integer beforeInvocations = Limits.getEmailInvocations();
    //     System.assertEquals(0,beforeInvocations,'no email sent');
    //     PMP_SendEmailAlertsForOfferings.sendOfferingEmailNotifications(reqWrapper);
    //     test.stopTest();
        
    // }
    
    // @isTest
    // public static void getGroupPAPADPOEUsersTest(){
    //     Account accInt = [select Id, Name from Account where Name = 'Test Account 19-Jun-19'];
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     Account pagAcc = PMP_TestDataUtility.createAccount('TestPag',devRecordTypeId,true);
        
    //     PMP_Company__c Partner_pc =[select Id, Name from PMP_Company__c where Name ='pubPartner2'];
        
    //     Core_Account_Group_Member__c cagm = new Core_Account_Group_Member__c();
    //     cagm.Core_Intel_Account_Id__c = accInt.Id;
    //     cagm.Core_Partner_Account_Id__c = pagAcc.Id;
    //     insert cagm;
        
    //     PMP_Partner_Offering__c offering = [Select Id, Name, PMP_Company_Id__c from PMP_Partner_Offering__c where Name = 'Test 19 feb 8:50 PM'];
    //     PMP_Partner_Offering__c offering2 = [Select Id, Name, PMP_Company_Id__c from PMP_Partner_Offering__c where Name = 'Test 19 feb 8:51 PM'];
    //     Map<Id, PMP_Partner_Offering__c> offList = new Map<Id, PMP_Partner_Offering__c>{offering.Id=>offering, offering2.Id=>offering2};
            
    //         Map<Id,Set<Id>> mapOfferingToAccntIdList = new Map<Id,Set<Id>>{offering.Id=>new Set<Id>{pagAcc.Id},offering2.Id=>new Set<Id>{pagAcc.Id}};
    //     PMP_SendEmailAlertsForOfferings.getGroupPAPADPOEUsers(offList, mapOfferingToAccntIdList);
    // }
}