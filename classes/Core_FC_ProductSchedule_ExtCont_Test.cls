/****************************************************************************************************
Apex Class Name : Core_FC_ProductSchedule_ExtCont_Test
Version         : 1.0 
Created Date    : 10/22/17
Function        : Test class for Forecasting 6Quarter Product Schedule Controller class
Modifications:
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Ashwin Dash                10/22/17                Original Version
*****************************************************************************************************/
@isTest
public class Core_FC_ProductSchedule_ExtCont_Test{
    
    public static List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
    public static List<Opportunity> opptyList = new List<Opportunity>();
    public static List <Account> AccListList = new List <Account> ();
       
    public static List<OpportunityLineItem> oliTestList = new List<OpportunityLineItem>();
    public static List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
    public static List<Product2> testProducts = new List<Product2>();
    public static List<PricebookEntry> testPBEs = new List<PricebookEntry>();
    public static List<Core_Opp_FC_Prod_Schedule__c> foreCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
    public static List<User> sysAdminList = new List<User>();
    
    public static List<Core_FC_Commission_Criterias__c> fcCommsnCriteriaList = new List<Core_FC_Commission_Criterias__c>();
    public static List<Core_Commissions_Percent_Contribution__c> comsnPrcntList = new List<Core_Commissions_Percent_Contribution__c>();
    
    
    static void getTriggerExecutionPopulated(){
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityLineItemAfterHandler', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='insertForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='trackOpportunityProductHistory', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='deleteForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='determineApprovers', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateProductLineItems', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityStageUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastUpdateFromOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='beforeFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='afterFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastCommissionCreate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        insert triggExecList;
    }
    @testSetup
    static void setupData(){
        
        getTriggerExecutionPopulated();
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
       
        Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true and isActive = true LIMIT 1];
        
        Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry',RecordTypeId = recTypeId, 
                                   BillingStreet = '123 Fake St',BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='EMEA Sales Group');
        insert acct;
        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity oppty = new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,
                                            AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                            StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        insert oppty;
        
       
        
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        
        // Test users
        User runAsUser = createTestUserInGeo(1, profileId, '')[0];
        List<User> apjUsers = createTestUserInGeo(150, profileId, 'APJ');
        List<User> asmoUsers = createTestUserInGeo(6, profileId, 'ASMO');
        List<User> emeaUsers = createTestUserInGeo(1, profileId, 'EMEA');
        List<User> prcUsers = createTestUserInGeo(55, profileId, 'PRC');
        
        
        // Create a few opportunities:
        // 
        // Oppty 2: 50 APJ team members, 1 EMEA team member, so should have APJ + EMEA set
        //          ...then make sure we can insert 100 APJ and 5 ASMO team members and have APJ + EMEA + ASMO set
        //          ...then make sure we can update 150 APJ members and still have flags set
        //          ...then make sure we can delete 100 APJ members and still have flags set
        //          ...then make sure we can delete the remaining 50 APJ and 5 ASMO and just have EMEA set
        // Oppty 3: 1 ASMO team member, so should have ASMO set
        //          ...then make sure we can insert 55 PRC team members and have ASMO + PRC set
        //          ...then make sure we can update 55 PRC team members and have ASMO + PRC set
        //          ...then make sure we can delete 55 PRC team members and just have ASMO set
        // 
        // Inserts, updates, & deletes will be performed all at once to test batch processing
        // Get the profile we'll use for our test users
        Profile p = [select Id from Profile where Name = 'IT Admin'];
        
        // Test users
        User u = new User(Alias = 'stsndt', Email='standarduser@intel.com',
                          EmailEncodingKey='UTF-8', LastName='Testig123', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standard123xys@mail.com');
        insert u;
        
        For(integer i = 0; i <5; i++) {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.RecordtypeId = recTypeId; 
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountInstance.Core_Sales_Groups__c='Americas Brazil Sales Group';
            accountInstance.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            accountInstance.Industry = 'Telecommunications';
            AccListList.add(accountInstance);
        }
        System.runAs(u) {
            insert AccListList;
        }
      
        for(integer i = 0; i < 5; i++) {
            Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'Test' + i;
            opportunityInstance.Core_External_User__c=true;
            opportunityInstance.AccountId =AccListList[0].id ;
            opportunityInstance.OwnerId= sysAdminList[0].Id; 
            //  UserInfo.getUserId();
            opportunityInstance.Core_Technical_Owner__c = sysAdminList[0].Id;
            opportunityInstance.Core_Sales_Group__c='Global Accounts';
            opportunityInstance.Core_Commissionable__c ='No';
            opportunityInstance.Core_Opportunity_Type__c='Deal: Sell-to';
            opportunityInstance.Core_Product_Segment__c='Data Center Computing';
            opportunityInstance.Core_Product_Application__c = 'Storage';
            opportunityInstance.Core_Consumption_Market__c = 'Education';
            opportunityInstance.Core_Intel_Platform__c='ALDER LAKE D';
            opportunityInstance.Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8);
            opportunityInstance.Core_Solution_Area__c='DCG Compute Deal $';
            opportunityInstance.RecordTypeId = newOppRecTypeId;
            opptyList.add(opportunityInstance);
        }
     
        
        System.runAs(u) {
            insert opptyList;
        }
        
          System.runAs(Core_Test_Utility.systemAdminUser){
            testProducts = Core_Test_Utility.createProduct(3);            
            for(Product2 prd : testProducts){
                prd.Core_Sales_Visible_Flag__c = true;
            }            
            insert testProducts;            
            testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[0].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=2345,  Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=123,  Core_Loss_Cancel_Reason__c = null, Core_Status__c ='Pending')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=11, Quantity=1230,  Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending'));                 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000,  Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000,  Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending'));  
            insert oliTestList;
        }   
             
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Quantity__c = 100, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = true));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[4].Id, Core_Opp_FC_Product__c = oliTestList[4].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Quantity__c = 0, Core_Opp_FC_isdeleted__c = true));

        insert insertForeCastList;
        Set<Id> oliSet = new Set<Id>();
        for(OpportunityLineItem oli : oliTestList){
            oliSet.add(oli.Id);
        }
        foreCastList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_Line_Item_RecordID__c IN : oliSet];
    }
    
    static List<User> createTestUserInGeo(Integer numUsers, Id profileId, String geo) {
        List<User> testUsers = new List<User>();
        for (Integer i=0; i<numUsers; i++) {
            User testUser = new User();
            testUser.Firstname = 'test Abcdsfe';
            testUser.LastName = 'userabcdjkte ' + geo + i;
            testUser.UserName = 'testusertestsstes.' + geo + i + '@intel.com.crm';
            testUser.Email = 'testusertestt.' + geo + i + '@intel.com';
            testUser.Alias = geo + i;
            testUser.CommunityNickName = 'testsss.' + geo + i;
            testUser.ProfileId = profileId;
            testUser.LANGUAGELOCALEKEY = 'en_US';
            testUser.LOCALESIDKEY = 'en_US';
            testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser.Core_User_Geo__c = geo;
            testUsers.add(testUser);
        }
        return testUsers;
    }
    
    static testMethod void recallLastApprovedFCTest(){
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        Test.startTest();
        
        System.runAs(sysAdminList[0]){
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test1'];
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        apexpages.currentpage().getparameters().put('id' , opp.Id);
        apexpages.currentpage().getparameters().put('isNew' , 'true');
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
        qps_cont.submitForApproval();        
        qps_cont.approvalMethod();
        qps_cont.lastApprovedProdList = [SELECT id, Core_Opp_FC_Claim_Date__c, Core_Forecast_Old_Claim_Date__c, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Core_FC_Appvd_SalesPrice__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c from Core_Opp_FC_Prod_Schedule__c where Core_Opp_FC_Approval_Status__c =: 'Approved' AND Core_Opp_FC_Opportunity__c =: opp.Id];
        qps_cont.recallLastApprovedFC();
        }     
        Test.stopTest();
    }
    
    static testmethod void deleteAllBlankQuantityTest(){   
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test1'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.deleteAllBlankQuantity();
        }
        Test.stopTest();
    }
    
    static testmethod void editAllMethodTest(){ 
        
        Test.startTest();
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test1'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            apexpages.currentpage().getparameters().put('edit' , 'true');
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            
            for(Core_FC_ProductSchedule_ExtController.displayWrapper dw : qps_cont.forecastTable){
                for(Integer i=0; i<dw.fcObjList.size(); i++){
                    dw.viewQuantityList[i] = '34567';
                }
            }
            qps_cont.editAllMethod();
            //qps_cont.flag = true;
            qps_cont.addQuarterMethod();
            qps_cont.cancelMethod();
            List<Core_Opp_FC_Prod_Schedule__c> fcList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
            for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_Line_Item_RecordID__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c = :opp.id AND Core_Opp_FC_isdeleted__c = false]){
                if(fc.Core_Opp_FC_Quantity__c == null || String.valueOf(fc.Core_Opp_FC_Quantity__c) == ''){
                    fc.Core_Opp_FC_Quantity__c = 10;
                    fcList1.add(fc);
                }
            }
            update fcList1;
            qps_cont.saveAllMethod();
            fcList1.clear();
            
        }
        Test.stopTest();
    }
    
    static testmethod void submitAndAddQuarterMethod(){ 
        
        Test.startTest();
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            apexpages.currentpage().getparameters().put('isAddQuarter' , 'true');
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.submitForApproval();
            qps_cont.approvalMethod();
            qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.isAddQuarter = true;
            qps_cont.addQuarterMethod();
            qps_cont.saveAllMethod();
            qps_cont.cancelMethod();
            qps_cont.addQuarterMethod();
            qps_cont.cancelRecentFC();
        }
        Test.stopTest();
    }
    
    static testmethod void migrateAndClearMethod(){        
        
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
       
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        apexpages.currentpage().getparameters().put('id' , opp.Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        Test.startTest();
        qps_cont.migrate6QPSMethod();
        qps_cont.clearQuantities();
        Test.stopTest();
    }
    
    static testmethod void submitAndRejectMethodTest(){ 
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            qps_cont.submitForApproval();
            qps_cont.rejectionMethod();  
        }       
        Test.stopTest();
    }
    
    static testmethod void submitAndRejectQtrTest(){ 
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
            Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap1 = qps_cont.getQtrSortedForecastRec(qps_cont.qtrNameList ,qps_cont.productSortedForecastMap);
            List<Core_Opp_FC_Prod_Schedule__c> updtList = new List<Core_Opp_FC_Prod_Schedule__c>();
            for(String qtr : qtrFCMap1.keySet()){
                for(Core_Opp_FC_Prod_Schedule__c fcQtr : qtrFCMap1.get(qtr)){
                    fcQtr.Core_Opp_FC_Quantity__c = 0;
                    updtList.add(fcQtr);
                }
            }
            if(!updtList.isEmpty())
                update updtList;
            
            qps_cont.submitForApproval();
            qps_cont.isAllZeroQuantity(qtrFCMap1);
        }
        Test.stopTest();
    }
    
    static testmethod void blankForecastMethodTest(){ 
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
        Test.startTest();
        PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
        Test.setCurrentPage(FC_6QPS_Page);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        apexpages.currentpage().getparameters().put('id' , opp.Id);
        Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        Map<String, List<Core_Opp_FC_Prod_Schedule__c>> qtrFCMap1 = qps_cont.getQtrSortedForecastRec(qps_cont.qtrNameList ,qps_cont.productSortedForecastMap);
        List<Core_Opp_FC_Prod_Schedule__c> updtList = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(String qtr : qtrFCMap1.keySet()){
            updtList.addAll(qtrFCMap1.get(qtr));
        }
        if(!updtList.isEmpty())
            delete updtList;
        qps_cont = new Core_FC_ProductSchedule_ExtController(sc);
        Test.stopTest();
    }
    
    static testmethod void deleteOliMethodTest(){ 
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
        Opportunity opp3 = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test3'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            qps_cont.submitForApproval();
            qps_cont.approvalMethod();
            delete opp3;
            qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
        }       
        Test.stopTest();
    }
    
     static testmethod void removeQuantitiesTest(){
         Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
         sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
         Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id' , opp.Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            qps_cont.removeQuantities();
            //delete oliTestList[4];
            //qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
        }       
        Test.stopTest();
         
     }
   
    //Adding comment to migrate
    
    static testmethod void FChandlerBeforeUpdateTest(){ 
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test2'];
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND /*Email LIKE '%intel.com' AND*/ Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' and manager.IsActive =true LIMIT 1];
        Test.startTest();
        System.runAs(sysAdminList[0]){
            PageReference FC_6QPS_Page = Page.Core_FC_Product_Schedule;
            Test.setCurrentPage(FC_6QPS_Page);
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            apexpages.currentpage().getparameters().put('id', opp.Id);
            Core_FC_ProductSchedule_ExtController qps_cont = new Core_FC_ProductSchedule_ExtController(sc); 
            List<OpportunityLineItem> oliOppty2List = [SELECT id, Core_Status__c FROM OpportunityLineItem WHERE OpportunityId = :opp.id LIMIT 1];
            oliOppty2List[0].Core_Status__c = 'Lost';
            oliOppty2List[0].Core_Loss_Cancel_Reason__c = 'Lost';
            oliOppty2List[0].Core_Loss_Cancel_Details__c = 'test';
            oliOppty2List[0].Core_Competitor__c = 'Acer';
            oliOppty2List[0].Core_Competitor_Product__c = 'AMD Athlon';
            update oliOppty2List;
        }       
        Test.stopTest();
    }
    
    
    
    
    
    
    static void getTriggerExecutionPopulated1(){
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityLineItemAfterHandler', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='insertForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='trackOpportunityProductHistory', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='deleteForecast', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='determineApprovers', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='updateProductLineItems', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='opportunityStageUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastUpdateFromOppty', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='beforeFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='afterFCUpdate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        triggExecList.add(new Core_Trigger_Executions__c(Name='forecastCommissionCreate', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        insert triggExecList;
        
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN01', Core_BU_Focus__c='any', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN02', Core_BU_Focus__c='DCG-Cloud', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN03', Core_BU_Focus__c='any', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN04', Core_BU_Focus__c='any', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN05', Core_BU_Focus__c='DCG-Cloud', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN06', Core_BU_Focus__c='any', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN07', Core_BU_Focus__c='any', Core_Account_Tier__c='any', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN08', Core_BU_Focus__c='DCG-Cloud', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        fcCommsnCriteriaList.add(new Core_FC_Commission_Criterias__c(Name='FCCMSN09', Core_BU_Focus__c='any', Core_Account_Tier__c='DCG-Tier 2', Core_Opportunity_Type__c='Deal: Sell-to', Core_Schedule_Quarter_Start_Date__c=date.today().addMonths(-3), Core_Schedule_Quarter_End_Date__c=date.today().addMonths(3)));
        insert fcCommsnCriteriaList;
        
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Opportunity Owner', Core_Percent_Contribution__c=100));
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Technical Owner', Core_Percent_Contribution__c=100));
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Team Member', Core_Percent_Contribution__c=100));
        comsnPrcntList.add(new Core_Commissions_Percent_Contribution__c(Name='Viewer', Core_Percent_Contribution__c=0));
        insert comsnPrcntList;
    }
    
    
    static void setupData1(){
        
        getTriggerExecutionPopulated();
        sysAdminList =  [SELECT Id, Name FROM User WHERE isActive = TRUE AND Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId != '' AND Core_User_Type__c != 'External User' LIMIT 1];
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
        Account acct;
        System.runAs(Core_Test_Utility.systemAdminUser){  
        //System.runAs(sysAdminList[0]){
            acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St', Core_Account_Tier__c = 'DCG-Tier 2; CCG-Tier 1', Core_Account_BU_Focus__c = 'DCG-Cloud',
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Core_Sales_Groups__c='Americas Brazil Sales Group',
                                           BillingPostalCode = '12345', Industry ='Agriculture', Core_Sub_Industry__c='Forestry', Core_Account_Primary_Coverage__c='Intel Covered');
            insert acct;
        }
        
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
        Profile p = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        
        System.runAs(Core_Test_Utility.systemAdminUser){  
        //System.runAs(sysAdminList[0]){
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, Core_Commissionable__c = 'Yes', Core_Exclude_From_KPIs__c = false,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Global Accounts', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId, Core_Commissionable__c = 'Yes', Core_Exclude_From_KPIs__c = false,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Regional Sales', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId, Core_Commissionable__c = 'Yes', Core_Exclude_From_KPIs__c = false,
                AccountId = acct.Id, StageName = 'Define', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdminList[0].Id, Core_Sales_Group__c='Regional Sales', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='AGILEX', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'));
            insert opptyList;
        }
        
        testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        System.runAs(Core_Test_Utility.systemAdminUser){
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[0].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=2345, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=123, Core_Loss_Cancel_Reason__c = null, Core_Status__c ='Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=11, Quantity=1230, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));                 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending', Core_Approved_KPI_Product_Group__c='test', CRM_DW_App_UCD_Customer_Name__c='test', Core_Opp_Approved_Sales_Group__c='test'));  
            insert oliTestList;
        }        
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 654, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = true));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insert insertForeCastList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : insertForeCastList){
            fc.Core_Opp_FC_Quantity__c = 500;
            fc.Core_Opp_FC_Prod_Sales_Price__c = 50;
        }
        update insertForeCastList;
        system.debug('forecastlist '+[select Id, Core_Opp_FC_Quantity__c, Core_Opp_FC_Sched_Revenue__c from Core_Opp_FC_Prod_Schedule__c where Id IN: insertForeCastList]);
    }
    
    static testMethod void commissionTest(){
        List<Core_Opp_FC_Prod_Schedule__c> fcList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c];
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Approved';
            fc.Core_Opp_FC_Approved_Date__c = datetime.now();
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = null;
        }
        update fcList;
    }
    
    static testMethod void commissionTest1(){
        List<Core_Commissions_Percent_Contribution__c> comsnPrsnList = Core_Commissions_Percent_Contribution__c.getAll().values();
        delete comsnPrsnList;
        List<Core_Opp_FC_Prod_Schedule__c> fcList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c];
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Approved';
            fc.Core_Opp_FC_Approved_Date__c = datetime.now();
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = null;
        }
        update fcList;
        
        /*Core_Opp_FC_Handler.getMonths('2021-Q1');
        Core_Opp_FC_Handler.getMonths('2021-Q2');
        Core_Opp_FC_Handler.getMonths('2021-Q3');
        Core_Opp_FC_Handler.getMonths('2021-Q4');*/
    }
        static testMethod void createFCTasks_Test(){
        List<Core_Opp_FC_Prod_Schedule__c> fcList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Opportunity__r.Core_Opportunity_Coverage_Nm__c, Core_Opp_FC_Opportunity__r.Core_Coverage_Type_Nm__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Approved_Date__c, Core_Opp_FC_Prod_Sales_Price__c, Core_Opp_FC_Sched_Revenue__c FROM Core_Opp_FC_Prod_Schedule__c];

        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Opportunity__r.Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity';
          fc.Core_Opp_FC_Opportunity__r.Core_Coverage_Type_Nm__c ='Deal Registration';
            fc.Core_Opp_FC_Approval_Status__c = 'Submitted';
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Approved';
            fc.Core_Opp_FC_Approved_Date__c = datetime.now();
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = 'Submitted';
        }
        update fcList;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcList){
            fc.Core_Opp_FC_Approval_Status__c = null;
        }
        update fcList;
        
    }
    
    
}