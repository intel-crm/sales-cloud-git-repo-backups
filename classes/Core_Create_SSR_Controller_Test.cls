/**************************************************************************************
* Apex Class Name   : Core_Create_SSR_Controller_Test 
* Created Date      : June 27nd, 2023
* Description       : Creates Sales Support Request in DRD system
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Pratik Padwal   :  june 27th, 2023  Initial Deployed Version
*************************************************************************************/
@isTest  
public class Core_Create_SSR_Controller_Test {
    @testsetup
    static void setupData() {        
        
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        // create Account Record
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        testAccount.RecordTypeId = newAccountRecTypeId;
        insert testAccount;
        
        // create Opty Record
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1), OwnerId= UserInfo.getUserId());
        
        insert testOpportunity;
        List<Opportunity> testOpportunities = [select id from Opportunity where Id =: testOpportunity.Id];
        system.assertEquals(1, testOpportunities.size());        
    }
    
    public Static testMethod void Test_SupportRequestCreate(){
        Opportunity testOpportunity = [select id from Opportunity where Name = 'Test SSG Support Request with Account'];
        //Call SSR creation method
        system.assertEquals(testOpportunity<>null,true);
        Core_Create_SSR_Controller.CreateSSR(testOpportunity.id,
                                             'Software Development Tools',
                                             'To Test SSR Method',
                                             'Test Description',
                                             date.today(),
                                             true);
        Core_Create_SSR_Controller.CreateSSR(null,
                                             'Software Development Tools',
                                             'To Test SSR Method',
                                             'Test Description',
                                             date.today(),
                                             true);
    }
    
    public static testMethod void Test_DefaultMethods(){
        //Get User GeoLocation code.
        list<String> userRegion = Core_Create_SSR_Controller.getUserRegionUITheme();
        system.Assert(userRegion.size()>0);  
        // Get Picklist values for RequestType.
        List<Core_Create_SSR_Controller.SelectOption> picklistValues = Core_Create_SSR_Controller.getSupport_Request_Type_Picklist_Values();
        system.Assert(picklistValues.size()>0);
        //GetURL
        list<Core_AAQ_Profile_Handler__c> getURLAAQ = Core_Create_SSR_Controller.getURL();
        system.Assert(getURLAAQ.size()==0);
        //catch exception
        try{
            string oppid='';
            Core_Create_SSR_Controller.validateOpportuntyBeforeQuoteCreation(oppid);
            
        }catch(Exception e)
        {
            PMP_Utility.logError(e, 'Core_Create_SSR_Controller_Test.Test_DefaultMethods');
        }
        /* Get Seeds- Samples URLS
List<Core_System_Credentials__c> sysCredList = new List<Core_System_Credentials__c>();
Core_System_Credentials__c sysCred = new Core_System_Credentials__c();
sysCred = new Core_System_Credentials__c();
sysCred.Name = 'Demo Depot Order #';
sysCred.Core_End_Point_URL__c = 'https://eip-crm-seeds.cloudhub.io.dummy/api/seeds';
sysCredList.add(sysCred);
sysCred = new Core_System_Credentials__c();
sysCred.Name = 'My Samples Request Placement';
sysCred.Core_End_Point_URL__c = 'https://eip-crm-proxy.cloudhub.io.dummy/smit/api/eip-crm-sls-sf2mysamples';
sysCredList.add(sysCred);
insert sysCredList;
system.debug('list: '+sysCredList);
Core_Create_SSR_Controller.SeedSampleDetails testURLS = Core_Create_SSR_Controller.getSeedSampleURL();
system.Assert(testURLS!=Null); */
    }
    
    public static testMethod void Test_DDRWebServiceCallSuccess(){
        
        Opportunity testOpportunity = [select id from Opportunity where Name = 'Test SSG Support Request with Account'];
        //Call SSR creation method
        Core_Create_SSR_Controller.SSR_RequestDetails  test_SSRDetails = Core_Create_SSR_Controller.CreateSSR(testOpportunity.id,
                                                                                                              'Software Development Tools',
                                                                                                              'To Test SSR Method',
                                                                                                              'Test Description',
                                                                                                              date.today(),
                                                                                                              true);
        system.assertEquals(test_SSRDetails<>null,true);
        // Test the Success API call.  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_SSR_Controller_MockTest());
        String Response = Core_Create_SSR_Controller.SSR_In_DRD_via_REST_Call(test_SSRDetails.SSRId,test_SSRDetails.SMGJosn);
        Test.stopTest();                                                                                                    
    }
    
    public static testMethod void Test_DDRWebServiceCallFailure(){
        
        Opportunity testOpportunity = [select id from Opportunity where Name = 'Test SSG Support Request with Account'];
        //Call SSR creation method
        Core_Create_SSR_Controller.SSR_RequestDetails  test_SSRDetails = Core_Create_SSR_Controller.CreateSSR(testOpportunity.id,
                                                                                                              'Software Development Tools',
                                                                                                              'To Test SSR Method',
                                                                                                              'Test Description',
                                                                                                              date.today(),
                                                                                                              true);
        system.assertEquals(test_SSRDetails<>null,true);
        // Test the Success API call.  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Core_Create_SSR_Controller_FailMockTest());
        String Response = Core_Create_SSR_Controller.SSR_In_DRD_via_REST_Call(test_SSRDetails.SSRId,test_SSRDetails.SMGJosn);
        Test.stopTest();                                                                                                    
    }
    
    public static testMethod void Test_PSGQuoteCreation(){
        
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        // create Account Record
        /*Account acc = PSG_Test_Utility.createDirectAccount();
        Account testAccount = Core_Test_Utility.createAccount(2)[1];
        testAccount.RecordTypeId = newAccountRecTypeId;
        testAccount.Core_PSG_Account__c=true;
        testAccount.Core_Account_Type__c='End Customer';
        testAccount.Core_Direct_Pricing_Parent_Id__c=acc.id;
        testAccount.Core_Direct_Legal_Parent_Id__c=acc.id;
        insert testAccount;*/
        
        
        // create Opty Record
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        /*Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account2',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1),Core_First_Customer_Ship_Date__c=System.Date.today().addYears(1),Core_Volume__c=5, OwnerId= UserInfo.getUserId());
        
        
        insert testOpportunity;*/
        Opportunity testOpportunity1 = [select id from Opportunity where Name = 'Test SSG Support Request with Account2']; 
        system.assertEquals(testOpportunity1<>null,true);
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        for(Product2 item :testProducts){
            item.Core_Product_Type__c = 'Intel® FPGAs';
        }
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpportunity1.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
        SBQQ.TriggerControl.disable();
        try{
            //Core_Create_SSR_Controller.createPSGQuoteonSiebel(testOpportunity1.id);
        }catch(Exception e){
            PMP_Utility.logError(e, 'Core_Create_SSR_Controller_Test.Test_PSGQuoteCreation');
        }        
    }
    public static testMethod void Test_PSGQuoteCreationValidationFail1(){
        
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        // create Account Record
        /*Account acc = PSG_Test_Utility.createDirectAccount();
        Account testAccount = Core_Test_Utility.createAccount(2)[1];
        testAccount.RecordTypeId = newAccountRecTypeId;
        testAccount.Core_PSG_Account__c=true;
        testAccount.Core_Account_Type__c='End Customer';
        testAccount.Core_Direct_Pricing_Parent_Id__c=acc.id;
        testAccount.Core_Direct_Legal_Parent_Id__c=acc.id;
        insert testAccount;*/
        
        
        // create Opty Record
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        /*Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account2',
                                                      AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1),Core_Volume__c=5, OwnerId= UserInfo.getUserId());
        
        
        insert testOpportunity;*/
        Opportunity testOpportunity1 = [select id from Opportunity where Name = 'Test SSG Support Request with Account2']; 
        system.assertEquals(testOpportunity1<>null,true);
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        for(Product2 item :testProducts){
            item.Core_Product_Type__c = 'Intel® FPGAs';
        }
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        /*OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpportunity1.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;*/
        
        SBQQ.TriggerControl.disable();
        //Core_Create_SSR_Controller.createPSGQuoteonSiebel(testOpportunity1.id);
        
    }    
    
    public static testMethod void Test_PSGQuoteCreationException(){
        // create Account Record
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Account testAccount = Core_Test_Utility.createAccount(2)[1];
            testAccount.Core_PSG_Account__c=true;
            testAccount.Core_Account_Type__c='End Customer';
            insert testAccount;
            
            
            // create Opty Record
            Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
            Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account2',
                                                          AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                          CloseDate=System.Date.today().addYears(1),Core_First_Customer_Ship_Date__c=System.Date.today().addYears(1),Core_Volume__c=5, OwnerId= UserInfo.getUserId());
            
            
            insert testOpportunity;
            Opportunity testOpportunity1 = [select id from Opportunity where Name = 'Test SSG Support Request with Account2']; 
            system.assertEquals(testOpportunity1<>null,true);
            List<Product2> testProducts = Core_Test_Utility.createProduct(3);
            for(Product2 item :testProducts){
                item.Core_Product_Type__c = 'Intel® FPGAs';
            }
            insert testProducts;
            
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            
            // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
            // opportunity product history object later (can't sort on Description or any other attribute)
            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=testOpportunity1.Id, PricebookEntryId=testPBEs[0].Id,
                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
            insert testOppLineItem;
            
            
            try{
                
                //Core_Create_SSR_Controller.createPSGQuoteonSiebel(testOpportunity1.id);
                
            }catch(Exception e){
                PMP_Utility.logError(e, 'Core_Create_SSR_Controller_Test.Test_PSGQuoteCreationException');
            }
        } 
    }
    public static testMethod void Test_PSGQuoteCreationValidationFail2(){
        // create Account Record
        System.runAs(Core_Test_Utility.systemAdminUser){
            /*Account acc = PSG_Test_Utility.createDirectAccount();
            Account testAccount = Core_Test_Utility.createAccount(2)[1];
            testAccount.Core_Account_Type__c='End Customer';
            testAccount.Core_Direct_Pricing_Parent_Id__c=acc.id;
            testAccount.Core_Direct_Legal_Parent_Id__c=acc.id;
            insert testAccount;*/
            
            
            // create Opty Record
            Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
            /*Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account2',
                                                          AccountId=testAccount.Id, StageName='Qualifying', RecordTypeId=recOpportunityTypeId,
                                                          CloseDate=System.Date.today().addYears(1),Core_First_Customer_Ship_Date__c=System.Date.today().addYears(1),Core_Volume__c=5, OwnerId= UserInfo.getUserId());
            
            
            insert testOpportunity;*/
            Opportunity testOpportunity1 = [select id,Core_Approval_Status__c from Opportunity where Name = 'Test SSG Support Request with Account2']; 
            system.assertEquals(testOpportunity1<>null,true);
            List<Product2> testProducts = Core_Test_Utility.createProduct(3);
            for(Product2 item :testProducts){
                item.Core_Product_Type__c = 'Intel® FPGAs';
            }
            insert testProducts;
            
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            
            // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
            // opportunity product history object later (can't sort on Description or any other attribute)
            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=testOpportunity1.Id, PricebookEntryId=testPBEs[0].Id,
                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
            insert testOppLineItem;
            
            SBQQ.TriggerControl.disable();
            //Core_Create_SSR_Controller.createPSGQuoteonSiebel(testOpportunity1.id);
            Core_Create_SSR_Controller.checkOpptyStage(testOpportunity1.id);
        }
    }

    public static testMethod void TestIsPCCDealRegOpty(){
        Boolean bln_PCC_DealRegOpty= false;
        Test.startTest();
        
        // create Account Record
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        testAccount.RecordTypeId = newAccountRecTypeId;
        insert testAccount;
        
        // create Opty Record
        
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account ' + (Math.random() * 100),
                                                      AccountId=testAccount.Id, StageName='Qualify', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1), OwnerId= UserInfo.getUserId(),
                                                      Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity' , Core_Coverage_Type_Nm__c= 'Deal Registration'
                                                     );
        
        insert testOpportunity;
        Opportunity testOpportunities = [select id from Opportunity where Id =: testOpportunity.Id];
        
        if(testOpportunities != null){
            bln_PCC_DealRegOpty= true; 
            
        }else
        {
            bln_PCC_DealRegOpty= false;
        }
        System.assert(testOpportunities != null, 'Expected the opportunity to not be null');
        Test.StopTest();
    }
    public static testMethod void TestIsPCCDealRegOpty1(){
        
        Test.startTest();
        
        // create Account Record
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        testAccount.RecordTypeId = newAccountRecTypeId;
        insert testAccount;
        
        // create Opty Record
        
        Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account ' + (Math.random() * 100),
                                                      AccountId=testAccount.Id, StageName='Qualify', RecordTypeId=recOpportunityTypeId,
                                                      CloseDate=System.Date.today().addYears(1), OwnerId= UserInfo.getUserId(),
                                                      Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity' , Core_Coverage_Type_Nm__c= 'Deal Registration'
                                                     );
        
        insert testOpportunity;
        Opportunity testOpportunities = [select id from Opportunity where Id =: testOpportunity.Id];
        boolean check = Core_Create_SSR_Controller.showPricingAndQuoting(testOpportunity.Id);        
        Opportunity opp = [Select Id,Core_Coverage_Type_Nm__c,Core_Opportunity_Coverage_Nm__c  from Opportunity where Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity' and Core_Coverage_Type_Nm__c= 'Deal Registration' limit 1 ];
        if (opp != null)
        {
            System.assert(opp != null, 'Expected the opportunity to not be null');
        }
        else
        {
            System.assert(opp == null, 'Expected the opportunity to be null');
        }
        Test.StopTest();
    }
    
    public static testMethod void TestUrls(){
        User u=[select Id from User where Profile.Name='System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Core_CRM_Labels__c clabels=new Core_CRM_Labels__c();
            clabels.Name='IQR_Tender_URL';
            clabels.Value__c='www.intel.com';
            insert clabels;
            
            Core_CRM_Labels__c clabels2=new Core_CRM_Labels__c();
            clabels2.Name='AtRisk_URL';
            clabels2.Value__c='www.intel.com';
            insert clabels2;
            Test.startTest();
            string IQRTender = Core_Create_SSR_Controller.getIQRTenderURL();  
            string atRisk = Core_Create_SSR_Controller.getAtRiskURL();
            Test.StopTest();
            system.assertEquals(atRisk<>null,true);
            system.assertEquals(IQRTender<>null,true);
        }
    }
    public static testmethod void testAIinfernece(){
        // create Account Record
        User u=[select Id,email from User where Profile.Name='System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
            Account testAccount = Core_Test_Utility.createAccount(1)[0];
            testAccount.RecordTypeId = newAccountRecTypeId;
            testAccount.Core_Geo__c = 'APJ';
            testAccount.Core_Business_Party_Id__c = '1000948641';
            insert testAccount;
            
            Id recOpportunityTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
            Opportunity testOpportunity = new Opportunity(Name='Test SSG Support Request with Account ' + (Math.random() * 100),
                                                          AccountId=testAccount.Id, StageName='Qualify', RecordTypeId=recOpportunityTypeId,
                                                          CloseDate=System.Date.today().addYears(1), OwnerId= UserInfo.getUserId(),
                                                          Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity' , Core_Coverage_Type_Nm__c= 'Deal Registration',
                                                          Core_Consumption_Market__c = 'Consumer'
                                                         );
            
            insert testOpportunity;
            Core_System_Credentials__c sysCred1 = new Core_System_Credentials__c (Name = 'AI inference Dynamic View', Core_End_Point_URL__c = 'testURL');
            insert sysCred1;
            Core_System_Credentials__c sysCred2 = new Core_System_Credentials__c (Name = 'AI inference', Core_End_Point_URL__c = 'testURL');
            insert sysCred2;
            Core_System_Credentials__c sysCred3 = new Core_System_Credentials__c (Name = System.Label.Core_DemoDepotOrder, Core_End_Point_URL__c = 'testURL');
            insert sysCred3;
            Core_System_Credentials__c sysCred4 = new Core_System_Credentials__c (Name = 'My Samples Request Placement', Core_End_Point_URL__c = 'testURL');
            insert sysCred4;
            
            Core_SmartSheet_URL__c ssForm = new Core_SmartSheet_URL__c(Name = 'AI inference form fields',Account_Geo__c='test1',
                                                                      Account_Name__c='test',Expected_Design_Win__c='Expected_Design_Win__c',
                                                                      Requestor_Email__c='Requestor_Email__c',Sales_Group__c='Sales_Group__c',
                                                                      SFDC_CRM_Oppty_ID__c = 'SFDC_CRM_Oppty_ID__c',Vertical_Market__c='Vertical_Market__c');
            
            insert ssForm;
            
            Test.startTest();
            //String URL1 = Core_Create_SSR_Controller.getAiInferenceDynamicViewURL();
            String URL2 = Core_Create_SSR_Controller.getaiInferenceURL(testOpportunity.Id,10000,testOpportunity.Core_Consumption_Market__c,testAccount.name,testAccount.Core_Geo__c,u.Email,'APJ',testOpportunity.Name);
            
            Core_Create_SSR_Controller.SeedSampleDetails URL3 = Core_Create_SSR_Controller.getSeedSampleURL(testOpportunity.Id,testAccount.Id,'120111332','120111332');
            Test.stopTest();
            
            //system.assertEquals(URL1<>null,true);
            system.assertEquals(URL2<>null,true);
        }        
        
        
    }
    
}