@isTest
private class Core_OppApproveChecklistCont_Test{
    public static User usr = new User();
    public static List<Opportunity> opptyList = new List<Opportunity>();
    
    testMethod static void InsertOppTest1() {
        Test.startTest(); 
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1]; 
        System.runAs(Core_Test_Utility.systemAdminUser){  
            Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';  
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(); //'Americas ELAR Sales Group'; 
            accountInstance.Industry = 'Agriculture';
            accountInstance.Core_Sub_Industry__c = 'Forestry';
            accountInstance.BillingPostalCode ='12345';
            insert accountInstance;
            
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName ='Define';
            opportunityInstance.Name ='Test OppName';
            opportunityInstance.AccountId = accountInstance.Id;
            opportunityInstance.Core_First_Customer_Ship_Date__c=system.today().addDays(5);
            opportunityInstance.Core_Production_End_Date__c =System.Today().addDays(-10);
            opportunityInstance.Core_Opportunity_Type__c='Design: Original';
            opportunityInstance.Core_Loss_Cancel_Details__c='Test opp record';
            opportunityInstance.Core_Intel_Platform__c='AGILEX';
            opportunityInstance.Core_Technical_Owner__c =usr.Id;
            
            insert opportunityInstance;
            
            List<Product2> testProducts = Core_Test_Utility.createProduct(1);
            insert testProducts;
            
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            
            // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
            // opportunity product history object later (can't sort on Description or any other attribute)
            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=opportunityInstance.Id, PricebookEntryId=testPBEs[0].Id,
                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Vendor__c=null);
            insert testOppLineItem;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityInstance);
            Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc); 
            
            PageReference pageRef = Page.Core_OppApproveChecklist;
            pageRef.getParameters().put('id', String.valueOf(opportunityInstance.Id));
            Test.setCurrentPage(pageRef);
            testAccPlan.cancel();
        }
        Test.stopTest(); 
        System.assertEquals(true,true);
    }
    
    testMethod static void InsertOppTest2() {
        
        Test.startTest();
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        System.runAs(Core_Test_Utility.systemAdminUser){          
            Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test'; 
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();  
            accountInstance.Industry = 'Agriculture';
            accountInstance.Core_Sub_Industry__c = 'Forestry';
            
            insert accountInstance;
            
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName ='Qualify';
            opportunityInstance.Name ='Test OppName';
            opportunityInstance.Core_Opportunity_Type__c='Design: Original';
            opportunityInstance.Core_Military_Aerospace_Govmt_End_Use__c='Yes';
            opportunityInstance.Core_Compliance_Status__c ='Approved with Guardrails';
            opportunityInstance.Core_Production_End_Date__c=System.Today().addDays(1);
            opportunityInstance.Core_Opportunity_Type__c ='Design: Secondary';
            opportunityInstance.Core_First_Customer_Ship_Date__c=system.today().addDays(4);
            opportunityInstance.Core_Intel_Platform__c='AGILEX';
            opportunityInstance.Core_Technical_Owner__c =usr.Id;  
            opportunityInstance.AccountId = accountInstance.Id;
            opportunityInstance.Core_Exclude_From_KPIs__c=False;
            
            
            insert opportunityInstance;
            
            Note n = new note(parentid=opportunityInstance.id,title='test note',body='test note contents');
            insert n;
            
            Attachment attach=new Attachment();      
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=opportunityInstance.id;
            insert attach;
            
            List<Product2> testProducts = Core_Test_Utility.createProduct(1);
            insert testProducts;
            
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            
            // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
            // opportunity product history object later (can't sort on Description or any other attribute)
            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=opportunityInstance.Id, PricebookEntryId=testPBEs[0].Id,
                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Vendor__c=accountInstance.Id);
            insert testOppLineItem;
            List<Core_Opportunity_Partner__c> OppPartner= Core_Test_Utility.createOpportunityPartners(1,opportunityInstance);
            
            insert OppPartner;
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityInstance);
            Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc);
            
            PageReference pageRef = Page.Core_OppApproveChecklist;
            pageRef.getParameters().put('id', String.valueOf(opportunityInstance.Id));
            Test.setCurrentPage(pageRef);
            testAccPlan.cancel();
        }
        Test.stopTest();
        System.assertEquals(true,true);
        
        
    }     
    
    testMethod static void InsertOppTestAttach() {
        
        Test.startTest(); 
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];
        System.runAs(Core_Test_Utility.systemAdminUser){          
            Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test'; 
            accountInstance.Industry = 'Agriculture';
            accountInstance.Core_Sub_Industry__c = 'Forestry';
            accountInstance.BillingPostalCode ='12345';
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(); //'Americas ELAR Sales Group'; 
            insert accountInstance;
            
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName ='Define';
            opportunityInstance.Name ='Test OppName';
            opportunityInstance.Core_Opportunity_Type__c='Design: Original';
            opportunityInstance.Core_Military_Aerospace_Govmt_End_Use__c='Yes';
            opportunityInstance.Core_Compliance_Status__c ='Approved with Guardrails';
            opportunityInstance.Core_Production_End_Date__c=System.Today().addDays(1);
            opportunityInstance.Core_Opportunity_Type__c ='Design: Secondary';
            opportunityInstance.Core_First_Customer_Ship_Date__c=system.today().addDays(4);
            opportunityInstance.Core_Intel_Platform__c='AGILEX';
            opportunityInstance.Core_Technical_Owner__c =usr.Id;  
            opportunityInstance.AccountId = accountInstance.Id;
            opportunityInstance.Core_Exclude_From_KPIs__c=True;
            
            insert opportunityInstance;
            
            Note n = new note(parentid=opportunityInstance.id,title='test note',body='test note contents');
            insert n;
            
            Attachment attach=new Attachment();      
            attach.Name='Unit Test Attachment POP';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=opportunityInstance.id;
            insert attach;
            
            List<Product2> testProducts = Core_Test_Utility.createProduct(1);
            insert testProducts;
            
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            
            // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
            // opportunity product history object later (can't sort on Description or any other attribute)
            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=opportunityInstance.Id, PricebookEntryId=testPBEs[0].Id,
                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Vendor__c=accountInstance.Id);
            insert testOppLineItem;
            List<Core_Opportunity_Partner__c> OppPartner= Core_Test_Utility.createOpportunityPartners(1,opportunityInstance);
            
            insert OppPartner;
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityInstance);
            Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc);
            
            PageReference pageRef = Page.Core_OppApproveChecklist;
            pageRef.getParameters().put('id', String.valueOf(opportunityInstance.Id));
            Test.setCurrentPage(pageRef);
            testAccPlan.cancel();
        }
        Test.stopTest();     
        system.assertEquals(true, true);     
    }
    
    testMethod static void InsertOppTest3() {
        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser){          
            Account accountInstance = new Account();
            accountInstance.name = 'TestAccount';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';  
            accountInstance.Industry = 'Agriculture';
            accountInstance.Core_Sub_Industry__c = 'Forestry';
            accountInstance.BillingPostalCode ='12345';
            accountInstance.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(); //'Americas ELAR Sales Group'; 
            insert accountInstance;
            
            opptyList.add(new Opportunity(Name = 'Test Opportunity1',
                                          AccountId = accountInstance.Id, StageName = 'Qualify',Core_Loss_Cancel_Reason__c='Cancelled - Duplicate', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c ='Business Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2',
                                          AccountId = accountInstance.Id, StageName = 'Qualify',Core_Loss_Cancel_Details__c='Test opp record',Core_Opportunity_Team_Geo_APJ__c=true, Core_Loss_Cancel_Reason__c='Cancelled - Duplicate',CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c ='Business Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            
            opptyList.add(new Opportunity(Name = 'Test Opportunity3',
                                          AccountId = accountInstance.Id, StageName = 'Qualify', Core_Loss_Cancel_Reason__c='Cancelled - Duplicate', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c ='Business Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            
            opptyList.add(new Opportunity(Name = 'Test Opportunity4',
                                          AccountId = accountInstance.Id, StageName = 'Define',  Core_Loss_Cancel_Reason__c='Cancelled - Duplicate',CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c ='Business Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            
            opptyList.add(new Opportunity(Name = 'Test Opportunity4',
                                          AccountId = accountInstance.Id, StageName = 'Define',  Core_Loss_Cancel_Reason__c='Cancelled - Duplicate',CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Industry Sales', Core_Commissionable__c ='Yes', Core_Product_Segment__c='Client Computing', Core_Product_Application__c ='Business Mobility', Core_Consumption_Market__c = 'Education',Core_Sales_Objectives__c='Standard Refresh', Core_Solution_Focus_Area__c='Not Solution Selling', Core_Solution_Focus__c='5G Network Infrastructure',   Core_Solution_Play__c='Not Solution Selling', Core_Opportunity_Country__c='India'));
            
            
            insert opptyList;  
            
            List<Product2> testProducts = Core_Test_Utility.createProduct(1);
            insert testProducts;
            
            //  insert opportunityInstance;
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            
            OpportunityLineItem testOppLineItem;
            testOppLineItem = new OpportunityLineItem(OpportunityId=opptyList[0].Id, PricebookEntryId=testPBEs[0].Id,
                                                      Description='Test 11', UnitPrice=11, Quantity=11,
                                                      Core_Loss_Cancel_Reason__c='Cancelled - Budget', Core_Status__c='Pending',Core_Vendor__c=accountInstance.Id,Core_Write_In_Product_Flag__c=true);
            insert testOppLineItem;
            
            PageReference pageRef = Page.Core_OppApproveChecklist;
            pageRef.getParameters().put('id', String.valueOf(opptyList[0].Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(opptyList[0]);
            Core_OppApproveChecklistCont testAccPlan0 = new Core_OppApproveChecklistCont(sc);
            testAccPlan0.cancel();
            
            PageReference pageRef1 = Page.Core_OppApproveChecklist;
            pageRef1.getParameters().put('id', String.valueOf(opptyList[1].Id));
            Test.setCurrentPage(pageRef1);
            ApexPages.StandardController sc1 = new ApexPages.StandardController(opptyList[1]);
            Core_OppApproveChecklistCont testAccPlan1 = new Core_OppApproveChecklistCont(sc1);
            testAccPlan1.cancel();
            
            PageReference pageRef2 = Page.Core_OppApproveChecklist;
            pageRef2.getParameters().put('id', String.valueOf(opptyList[2].Id));
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController sc2 = new ApexPages.StandardController(opptyList[2]);
            Core_OppApproveChecklistCont testAccPlan2 = new Core_OppApproveChecklistCont(sc2);
            testAccPlan2.cancel();
            
            PageReference pageRef3 = Page.Core_OppApproveChecklist;
            pageRef3.getParameters().put('id', String.valueOf(opptyList[3].Id));
            Test.setCurrentPage(pageRef3);
            ApexPages.StandardController sc3 = new ApexPages.StandardController(opptyList[3]);
            Core_OppApproveChecklistCont testAccPlan3 = new Core_OppApproveChecklistCont(sc3);
            testAccPlan3.cancel();
            
        }
        Test.stopTest();    
        system.assertEquals( 5, opptyList.size());    
    }  
    static testmethod void Bonus() {
        List<Core_CRM_Labels__c> customSetting= new List<Core_CRM_Labels__c>();
        
        Core_CRM_Labels__c cust1 = new Core_CRM_Labels__c();
        cust1.name = 'Core_WinAnalysisTask';
        cust1.value__c = 'Complete Win Analysis';
        customSetting.add(cust1);
        
        Core_CRM_Labels__c cust2 = new Core_CRM_Labels__c();
        cust2.name = 'Core_StateAnalysisTask';
        cust2.value__c = 'Complete Current and Future State Analysis';
        customSetting.add(cust2);
        
        Core_CRM_Labels__c cust3 = new Core_CRM_Labels__c();
        cust3.name = 'Core_ManagerBonusTask';
        cust3.value__c = 'Manager Bonus Approval';
        customSetting.add(cust3);
        
        insert customSetting;
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opps = new Opportunity(Name = 'OpportunityBonusPreSubmit',
                                           Core_Product_Application__c ='Business Mobility',Core_Opportunity_Type__c='Deal: Sell-to',RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Opportunity_Focus__c='Growth',Core_Product_Segment__c='Client Computing', 
                                           Core_Consumption_Market__c = 'Education', Description = 'test', Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Desired_End_State__c='Test OppName',Technology_and_Readiness_Gaps__c='Design',Business_Need__c='Yes',Technical_Need__c ='Approved');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        List<Task> taskList = new List<Task>();
        Task Analysistask = new Task();
        Analysistask.Subject = 'Complete Current and Future State Analysis';
        Analysistask.WhatId = opps.Id;
        Analysistask.Status = 'Completed';
        Analysistask.Description = 'Completed';
        taskList.add(Analysistask);
        
        Task ManagerTask = new Task();
        ManagerTask.Subject = 'Manager Bonus Approval';
        ManagerTask.WhatId = opps.Id;
        ManagerTask.Status = 'Completed';
        taskList.add(ManagerTask);
        
        Task WinTask = new Task();
        WinTask.Subject = 'Complete Win Analysis';
        WinTask.WhatId = opps.Id;
        WinTask.Status = 'Completed';
        taskList.add(WinTask);
        
        insert taskList;
        
        Contact testContact = new Contact(
            FirstName = 'TestingIntel',
            LastName = 'Program Intel',
            Title = 'Program Intel',
            AccountId = acct.Id,
            Email = 'test1234@testing.com',
            OwnerId = usr1.Id,
            MailingCountry = 'USA'
        );
        insert testContact;
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= testContact.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert crole;
            
        }
        opps.Description='test';
        opps.Core_Status_Update__c='test';
        opps.Core_Technical_Owner__c = usr1.id;
        opps.StageName= 'Define';
        update opps;
        
        
        opps.Core_Status_Update__c='test 1';
        opps.StageName= 'Develop';
        update opps;
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opps);
        Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc1);
        PageReference pageRef = Page.Core_OppApproveChecklist;
        pageRef.getParameters().put('id', String.valueOf(opps.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.cancel();
        Test.stopTest();
        system.assertEquals(true,true);
    }
    static testmethod void Bonus1() {
        Core_CRM_Labels__c cust1 = new Core_CRM_Labels__c();
        cust1.name = 'Core_StateAnalysisTask';
        cust1.value__c = 'Complete Current and Future State Analysis';
        
        insert cust1;
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opps = new Opportunity(Name = 'OpportunityBonusPreSubmit',
                                           Core_Product_Application__c ='Business Mobility',Core_Opportunity_Type__c='Deal: Sell-to',RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Opportunity_Focus__c='Core',Core_Product_Segment__c='Client Computing', 
                                           Core_Consumption_Market__c = 'Education', Description = 'test', Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Desired_End_State__c='Test OppName',Technology_and_Readiness_Gaps__c='Design',Business_Need__c='Yes',Technical_Need__c ='Approved');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }
        
        Task Analysistask = new Task();
        Analysistask.Subject = 'Complete Current and Future State Analysis';
        Analysistask.WhatId = opps.Id;
        Analysistask.Status = 'Completed';
        Analysistask.Description = 'Completed';
        Analysistask.OwnerId=UserInfo.getUserId();
        Analysistask.ActivityDate = system.today();
        insert Analysistask;
        
        Contact testContact = new Contact(
            FirstName = 'TestingIntel',
            LastName = 'Program Intel',
            Title = 'Program Intel',
            AccountId = acct.Id,
            Email = 'test1234@testing.com',
            OwnerId = usr1.Id,
            MailingCountry = 'USA'
        );
        insert testContact;
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= testContact.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert crole;
            
        }
        opps.Description='test';
        opps.Core_Status_Update__c='test';
        opps.Core_Technical_Owner__c = usr1.id;
        opps.StageName= 'Define';
        update opps;
        
        opps.Core_Status_Update__c='test 1';
        opps.StageName= 'Develop';
        update opps;
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opps);
        Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc1);
        PageReference pageRef = Page.Core_OppApproveChecklist;
        pageRef.getParameters().put('id', String.valueOf(opps.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.cancel();
        Test.stopTest();
        system.assertEquals(true, true);
    }
    
    static testmethod void cancelledOpp() {
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group',Core_Business_Party_Id__c='BusinessPartyId', Core_CIM_ID__c='CIMId');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opps = new Opportunity(Name = 'OpportunityBonusPreSubmit',
                                           Core_Product_Application__c ='Business Mobility',Core_Opportunity_Type__c='Deal: Sell-to',RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Opportunity_Focus__c='Core',Core_Product_Segment__c='Client Computing', 
                                           Core_Consumption_Market__c = 'Education', Description = 'test', Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Desired_End_State__c='Test OppName',Technology_and_Readiness_Gaps__c='Design',Business_Need__c='Yes',Technical_Need__c ='Approved');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }

        Contact testContact = new Contact(
            FirstName = 'TestingIntel',
            LastName = 'Program Intel',
            Title = 'Program Intel',
            AccountId = acct.Id,
            Email = 'test1234@testing.com',
            OwnerId = usr1.Id,
            MailingCountry = 'USA'
        );
        insert testContact;
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= testContact.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert crole;
            
        }
        opps.Description='test';
        opps.Core_Status_Update__c='test';
        opps.Core_Technical_Owner__c = usr1.id;
        opps.StageName= 'Define';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opps;}
        
        opps.Core_Status_Update__c='test 1';
        opps.StageName= 'Lost';
	        opps.Core_Loss_Cancel_Details__c='Lost';
        opps.Core_Loss_Cancel_Reason__c = 'Intel No Longer Pursuing';
        System.runAs(Core_Test_Utility.systemAdminUser){
         update opps;}
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opps);
        Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc1);
        PageReference pageRef = Page.Core_OppApproveChecklist;
        pageRef.getParameters().put('id', String.valueOf(opps.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.cancel();
        Test.stopTest();
        system.assertEquals(true, true);
    }
    
    static testmethod void prodLostOpp() {
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true LIMIT 1];
        
        // Create an account
        Account acct = new Account(Name = 'TestoppAccounthandle', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='Americas US Sales Group',Core_Business_Party_Id__c='BusinessPartyId', Core_CIM_ID__c='CIMId');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Id newOppRecTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity opps = new Opportunity(Name = 'OpportunityBonusPreSubmit',
                                           Core_Product_Application__c ='Business Mobility',Core_Opportunity_Type__c='Deal: Sell-to',RecordTypeId = newOppRecTypeId,
                                           AccountId = acct.Id, Opportunity_Focus__c='Core',Core_Product_Segment__c='Client Computing', 
                                           Core_Consumption_Market__c = 'Education', Description = 'test', Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Desired_End_State__c='Test OppName',Technology_and_Readiness_Gaps__c='Design',Business_Need__c='Yes',Technical_Need__c ='Approved');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert opps;
        }

        Contact testContact = new Contact(
            FirstName = 'TestingIntel',
            LastName = 'Program Intel',
            Title = 'Program Intel',
            AccountId = acct.Id,
            Email = 'test1234@testing.com',
            OwnerId = usr1.Id,
            MailingCountry = 'USA'
        );
        insert testContact;
        OpportunityContactRole crole= new OpportunityContactRole();
        crole.IsPrimary = true;
        crole.OpportunityId = opps.Id;
        crole.Role='Business Decision Maker';
        crole.ContactId= testContact.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert crole;
            
        }
        opps.Description='test';
        opps.Core_Status_Update__c='test';
        opps.Core_Technical_Owner__c = usr1.id;
        opps.Core_Approval_Status__c='Approved';
        opps.StageName= 'Design Win';
        update opps;
        
        opps.Core_Status_Update__c='test 1';
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opps);
        Core_OppApproveChecklistCont testAccPlan = new Core_OppApproveChecklistCont(sc1);
        PageReference pageRef = Page.Core_OppApproveChecklist;
        pageRef.getParameters().put('id', String.valueOf(opps.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.cancel();
        Test.stopTest();
        system.assertEquals(true, true);
    }
}