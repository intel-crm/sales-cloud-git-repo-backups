@isTest
public class CRM_OpportunitySLAEmailBatch_Test {
    
    public static List<Account> accountList;
    public static Opportunity opp;
    public static Opportunity opp1;
    public static Opportunity opp2;
    public static Date twoMonthsBack = System.today().addMonths(-2);
    public static Date threeMonthsBack = System.today().addMonths(-3);
    public static Date fourMonthsBack = System.today().addMonths(-4);

    
    @testSetup
    static void setupTest() {
        
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;
		List<CRM_Opportunity_SLA_Config__mdt> metadataList = [SELECT CRM_Record_Type__c, CRM_Stage_Name__c, CRM_SLA_Breach_1__c, CRM_SLA_Breach_2__c, CRM_Required_Fields__c 
                                                       FROM CRM_Opportunity_SLA_Config__mdt];
            
        List<User> users = new List<User>();
        
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user1@intel.com',
                           Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Sales Rep-CW' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        users.add(new User(UserName='test.user2.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user2@intel.com',
                           Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Sales Rep-CW' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        users.add(new User(UserName='test.user3.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user3@intel.com',
                           Alias='tclass3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Sales Rep-CW' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        users.add(new User(UserName='test.user4.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user4@intel.com',
                           Alias='tclass4', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
                           ProfileId=[select Id from Profile where Name='Sales Rep-CW' limit 1][0].Id, LanguageLocaleKey='en_US'));
        
        insert users;
        
        users[0].ManagerId = users[1].Id;
        users[2].ManagerId = users[3].Id;
        users[1].ManagerId = users[2].Id;
        
        // Create Permission Set and assign to users
        PermissionSet ps = new PermissionSet(
            Name = 'Test_Permission_Set',
            Label = 'Test Permission Set'
        );
        System.runAs(Core_Test_Utility.systemAdminUser) {
        	insert ps;
        }
        
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (User u : users) {
            psAssignments.add(new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = ps.Id
            ));
        }
        System.runAs(Core_Test_Utility.systemAdminUser) {
        	insert psAssignments;
        }
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update users;
        }
        
        
        
        accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        insert accountList;
        
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(3);
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Id oppDesignID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        opp = listOpportunity[0];  
        opp.Name ='Test Opp';
        opp.AccountId = accountList[0].Id;
        opp.Core_Commissionable__c='Yes'; 
        opp.RecordTypeId = oppDealID;
        opp.StageName = 'Develop';    
        opp.Core_Opportunity_Type__c='Deal: Sell-to';
        opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp.Core_Lead_Conversion_Flag__c = false;
        opp.OwnerId = users[0].Id;
        opp.Core_Technical_Owner__c = users[2].Id;
       	opp.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        
        
        ////
        opp1 = listOpportunity[1]; 
        opp1.Name ='Test Opp 1';
        opp1.AccountId = accountList[0].Id;
        opp1.Core_Commissionable__c='Yes';
        opp1.RecordTypeId = oppDesignID;
        opp1.StageName = 'Develop';     
        opp1.Core_Opportunity_Type__c='Design: Original';
        opp1.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp1.Core_Lead_Conversion_Flag__c = false;
        opp1.Core_Intel_Platform__c = 'ALDER LAKE M';
        opp1.Core_First_Customer_Ship_Date__c = date.newInstance(2022, 08, 07);
        //opp1.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
        opp1.OwnerId = users[0].Id;
        opp1.Core_Technical_Owner__c = users[2].Id;
       	opp1.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opp1.CloseDate = System.today().addMonths(2);
        
        opp2 = listOpportunity[2];    
        opp2.Name ='Test Opp 2';
        opp2.AccountId = accountList[0].Id;
        opp2.RecordTypeId = oppDealID;
        opp2.StageName = 'Design';     
        opp2.Core_Intel_Platform__c = 'ALDER LAKE M';
        opp2.Core_First_Customer_Ship_Date__c = date.newInstance(2022, 08, 07);
        opp2.OwnerId = users[1].Id;
        opp2.Core_Technical_Owner__c = users[2].Id;
       	opp2.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opp2.CloseDate = System.today().addMonths(2);
        
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert opp;
            insert opp1;
            insert opp2;
        }
        
       // Add 14 days to the CreatedDate
        DateTime adjustedCreatedDate = threeMonthsBack.addDays(-14);
        DateTime adjustDesignDate = twoMonthsBack.addDays(-4);
        DateTime adjustCreatedDateOpp1 = threeMonthsBack.addDays(-4);
            
        Test.setCreatedDate(opp1.Id, adjustedCreatedDate); 
        Test.setCreatedDate(opp.Id, adjustCreatedDateOpp1); 
        Test.setCreatedDate(opp2.Id, adjustDesignDate);
        Opportunity opp = [SELECT Id, createddate FROM Opportunity WHERE Id =: opp.Id];
        Opportunity opp1 = [SELECT Id, createddate FROM Opportunity WHERE Id =: opp1.Id];
        Opportunity opp2 = [SELECT Id, createddate FROM Opportunity WHERE Id =: opp2.Id];
        
        /*opp2.Description='test';
        opp2.Core_Status_Update__c='test';
        opp2.StageName= 'Design';
        opp2.Core_Product_Segment__c='Client Computing';
        opp2.Core_Consumption_Market__c = 'Education';
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opp2;
        }*/

        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        
        Core_CRM_Labels__c slaRec = new Core_CRM_Labels__c();
        slaRec.Name = 'CRM_Opp_SLA_Lowest_Threshold';
        slaRec.Value__c = '60';
        insert slaRec;
        
        Core_CRM_Labels__c slaStartRec = new Core_CRM_Labels__c();
        slaStartRec.Name = 'CRM_Opp_SLA_Batch_Start_Date';
        slaStartRec.Value__c = '2025-08-08';
        insert slaStartRec;
        
        Core_CRM_Labels__c slaSellerReportId = new Core_CRM_Labels__c();
        slaSellerReportId.Name = 'CRM_SLA_Seller_Report_Id';
        slaSellerReportId.Value__c = '00OWA000000xaQr2AI';
        insert slaSellerReportId;
        
        Core_CRM_Labels__c slaManagerReportId = new Core_CRM_Labels__c();
        slaManagerReportId.Name = 'CRM_SLA_Manger_Report_Id';
        slaManagerReportId.Value__c = '00OWA000000x8kj2AA';
        insert slaManagerReportId;
        
        
    }
    
    
    static testMethod void validateOpportunitySLA(){
        try{   
            Test.startTest();
           // Create an instance of the batch
            CRM_OpportunitySLAEmailBatch batch = new CRM_OpportunitySLAEmailBatch();
            
            // Execute the batch with a small scope
            Database.executeBatch(batch, 10);
            
            Test.stopTest();
            
        }catch(Exception ex){
       		Core_Log_Entry__c log = new Core_Log_Entry__c(Core_Details__c = 'CRM_OpportunitySLAEmailBatch_Test' ,Core_Message__c=  ex.getMessage(), Core_Severity__c = 'Info', Core_Origin__c = 'CRM_OpportunitySLAEmailBatch_Test', Core_When__c = System.now());
            insert log;
               
        }   
    }
    static testMethod void validateOpportunitySLADesign(){
        try{  
            
            List<Opportunity> oppList = [SELECT Id,Name,Core_Days_in_Current_Stage__c,StageName,CreatedDate,LastStageChangeDate,OwnerId, Owner.ManagerId, RecordType.Name, RecordTypeId,Owner.IsActive,Owner.Manager.IsActive,Core_Opportunity_Coverage_Nm__c 
                                         FROM Opportunity];
            
            Test.startTest();
           // Create an instance of the batch
            CRM_OpportunitySLAEmailBatch batch = new CRM_OpportunitySLAEmailBatch();
           
            // Manually invoking the execute method with mock data
            batch.execute(null, oppList);
            Test.stopTest();
            
        }catch(Exception ex){
       		Core_Log_Entry__c log = new Core_Log_Entry__c(Core_Details__c = 'CRM_OpportunitySLAEmailBatch_Test' ,Core_Message__c=  ex.getMessage(), Core_Severity__c = 'Info', Core_Origin__c = 'CRM_OpportunitySLAEmailBatch_Test', Core_When__c = System.now());
            insert log;
               
        }   
    }
}