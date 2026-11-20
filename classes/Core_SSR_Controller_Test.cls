/**************************************************************************************
* Apex Class Name   : Core_SSR_Controller_Test 
* Created Date      : Aug 22nd, 2017
* Description       : Creates Sales Support Request in DRD system
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Rangesh Kona	  :  Aug 22nd, 2017  Initial Deployed Version
* Rangesh Kona	  :  Aug 31st, 2017  Update to improve code coverage
*************************************************************************************/
@isTest  
public class Core_SSR_Controller_Test {
    
    @testsetup
    static void setupData() {
        
        // select standard Profile
        Id profId = [select Id from Profile where Name='Standard User' limit 1][0].Id;
        
        // create User Record
        User testUser =   new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
                                   Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                                   ProfileId=profId, LanguageLocaleKey='en_US');
        insert testUser;
        List<User> testUsers =[select id from User where Id=: testUser.Id];
        system.assertEquals(1,testUsers.size());
        
        
        // create Account Record
        //Id recAccountTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account testAccount =   new Account(Name='Test SMG SSR Account', Industry='Agriculture', Core_Sub_Industry__c = 'Crop Production',
                                            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA', Core_Sales_Groups__c = 'Americas US Sales Group');
        insert testAccount;      
        List<Account> testAccounts = [select id from Account where Id =: testAccount.Id];
        system.assertEquals(1, testAccounts.size());
        
        
        // create Opty Record
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1), OwnerId=testUser.Id);
        
        insert testOpportunity;
        List<Opportunity> testOpportunities = [select id from Opportunity where Id =: testOpportunity.Id];
        system.assertEquals(1, testOpportunities.size());        
    }
    
    // to call methods in sequence
    public static testMethod void executeTestMethods() {
        performValidations_Test();
        Core_SSR_Controller_Test(); 
    }
    
    
    // Method to perform only validations
    private static void performValidations_Test() {
        
        // with opty Id check
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('id', '');
        Core_SSR_Controller csc_without_opty_id = new Core_SSR_Controller();
        system.assertEquals(false,csc_without_opty_id.runAction);
        
        // with opty Id check
        Opportunity testOpportunity = [select id from Opportunity where Name = 'Test SSG Support Request with Account'];
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('id', testOpportunity.Id);
        Core_SSR_Controller CSC = new Core_SSR_Controller();
        system.assertEquals(true,csc.runAction);
        
        // check for blank Service Request Type
        Boolean validation_success;
        csc.runAction                  = true;
        csc.Support_Request_Type       = '';                               // Support Request Blank
        csc.Description                = 'Test Description for SMG SSR ';
        csc.Subject                    = 'Test Subject for SMG SSR ';
        csc.User_Agreed_to_Share_Opty  = true;
        csc.performValidations();
        system.assertEquals(false,csc.runAction);
        
        // check for blank Description
        csc.runAction                  = true;
        csc.Support_Request_Type       = 'Engineering Request';                            
        csc.Description                = '';                           // Description Blank
        csc.Subject                    = 'Test Subject for SMG SSR ';
        csc.User_Agreed_to_Share_Opty  = true;
        csc.performValidations();
        system.assertEquals(false,csc.runAction);
        
        // check for blank Subject
        csc.runAction                  = true;
        csc.Support_Request_Type       = 'Engineering Request';                            
        csc.Description                = 'Test Description for SMG SSR ';                  
        csc.Subject                    = '';                           // Subject Blank
        csc.User_Agreed_to_Share_Opty  = true;
        csc.performValidations();
        system.assertEquals(false,csc.runAction);
        
        // check for blank User_Agreed_to_Share_Opty
        csc.runAction                  = true;
        csc.Support_Request_Type       = 'Engineering Request';                            
        csc.Description                = 'Test Description for SMG SSR ';                  
        csc.Subject                    = 'Test Subject for SMG SSR ';                          
        csc.User_Agreed_to_Share_Opty  = false;                        // User_Agreed_to_Share_Opty blank
        csc.performValidations();
        system.assertEquals(false,csc.runAction);
        
        // all Validations are passed
        csc.runAction                  = true;
        csc.Support_Request_Type       = 'Engineering Request';                            
        csc.Description                = 'Test Description for SMG SSR ';                  
        csc.Subject                    = 'Test Subject for SMG SSR ';                          
        csc.User_Agreed_to_Share_Opty  = true;                     // User_Agreed_to_Share_Opty blank
        csc.deadlineForResults			=  Date.valueOf('2013-05-05');
        csc.performValidations();
        system.assertEquals(true,csc.runAction);
    }
    
    // Method to perform all tests
    private static void Core_SSR_Controller_Test() {
        // with opty Id check
        Opportunity testOpportunity = [select id from Opportunity where Name = 'Test SSG Support Request with Account'];
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('id', testOpportunity.Id);
        Core_SSR_Controller csc_with_opty_id = new Core_SSR_Controller();
        system.assertEquals(true,csc_with_opty_id.runAction);
        
        Core_SSR_Controller CSC = new Core_SSR_Controller();
        csc.hasOptyUpdated 			    = true;
        csc.runAction                  = true;
        csc.Support_Request_Type       = 'Engineering Request';                            
        csc.Description                = 'Test Description for SMG SSR ';                  
        csc.Subject                    = 'Test Subject for SMG SSR ';                          
        csc.User_Agreed_to_Share_Opty  = true;                     // User_Agreed_to_Share_Opty blank
        csc.deadlineForResults			=  Date.valueOf('2013-05-05');
   
        //      csc.performValidations();
        
        //csc.runAction = true;
        csc.pre_webservice_call_save();       
        String errorMsg = 'Error Message from Webervice Call';
        csc.webserviceCallFailed(errorMsg);
        system.assertEquals(false, csc.runAction);
        List<Core_Sales_Support_Request__C> cssrTest1 = [select ID from Core_Sales_Support_Request__C];
        system.assertEquals(0,cssrTest1.size());
        
        csc.InsertSSRRecord();
        List<Core_Sales_Support_Request__C> cssr = [select ID from Core_Sales_Support_Request__C];
        String testSSRId = cssr[0].ID;
        system.assertEquals(1,cssr.size());
        
        csc.updateOptyRecord(testOpportunity.Id);
        Opportunity opty_test = [select Core_DRD_Support_Request_Created__c from Opportunity where Id = :testOpportunity.Id];
        system.assertEquals(true,opty_test.Core_DRD_Support_Request_Created__c);
             
        
        csc.InsertOptySSRRecord(testSSRId,testOpportunity.Id );
        
        List<SelectOption> type_list = csc.getSupport_Request_Type_Picklist_Values();
        csc.InsertOutboundMessage();

        
        Test.startTest();
        // Core_CreateSSRDRDController_MockTest
        // Set mock callout class 
        // 
        Test.setMock(HttpCalloutMock.class, new Core_SSR_Controller_MockTest()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        //  
        csc.Create_SSR_In_DRD_via_REST_Call();
        // Verify that the response received contains fake values
        String actualValue = csc.Response_Msg;
  
        csc.InsertInboundMessage();
        csc.FinalPageRedirect();
         Test.stopTest();     
        
       
    }
    
    
}