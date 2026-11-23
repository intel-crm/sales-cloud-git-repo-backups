@isTest
public class Pricing_ApproveRejCmntsUpdBatch_Test {
    @testSetup
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('qlBusinessLogicAdmin');
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2();
        List<User> fseUser2 = Pricing_Test_Utility.createFSEUserWithParam('newFSEUser@intel.com','NewFseUser','UserName');
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Approve_Reject_UpdtBatch');
            List<User> accExeUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            Test.startTest();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExeUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 2);
            test.stopTest();
        }
    }
    static testmethod void testBulkUpdateApproveCommentsOnQLI(){
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            update quoteLine[0];
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            update quoteLine[0];
        }
        Test.startTest();
        Pricing_ApproveRejectCmntsUpdate_Batch updBatch = new Pricing_ApproveRejectCmntsUpdate_Batch();
        Database.executeBatch(updBatch);
        Test.stopTest();
    }
    static testmethod void testBulkUpdateRejectCommentsOnQLI(){
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            update quoteLine[0];
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
            update quoteLine[0];
        }
        Test.startTest();
        Pricing_ApproveRejectCmntsUpdate_Batch updBatch = new Pricing_ApproveRejectCmntsUpdate_Batch();
        Database.executeBatch(updBatch);
        Test.stopTest();
    }
    static testmethod void testBulkUpdateApproveCommentsOnQLIErrorValidation(){
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [Select Id,SBQQ__Status__c from SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLineFromSetup = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        List<User> regionalManager = [Select Id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        User adminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'qlBusinessLogicAdmin@intel.com' LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        System.runAs(adminUser){
            List<Product2> products = new List<Product2>();
            Product2 prod = new Product2(Name='TestProduct123',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                         Core_Processor_Number_Nm__c = 'P6500',
                                         IsActive = true);
            products.add(prod);
            insert products;
            Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
            for(Product2 prod1:products){
                SBQQ__QuoteLine__c quoteLineUpd = new SBQQ__QuoteLine__c(); 
                quoteLineUpd.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
                quoteLineUpd.Pricing_Product_Nm__c = prod1.Id;
                quoteLineUpd.SBQQ__Product__c = prod1.Id;
                quoteLineUpd.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
                quoteLineUpd.Pricing_Systems_qty__c = 6; 
                quoteLineUpd.Pricing_pm_approval_comments_nm__c = 'Test Comment';
                quoteLineUpd.Pricing_CPUs_per_system_qty__c = 1;
                quoteLineUpd.Pricing_Single_System_Price_Amt__c = 4;
                quoteLineUpd.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
                quoteLineUpd.Pricing_Req_Discounted_Unit_Price__c = 1;
                quoteLineUpd.Pricing_Additional_OEM_Discount_Amt__c = 1;
                quoteLineUpd.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
                quoteLineUpd.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded;
                quoteLineUpd.Pricing_Market_Segment_values_Nm__c ='';
                quoteLineUpd.SBQQ__Quote__c = quoteList[0].Id;
                quoteLineUpd.Pricing_Quote_Program_Nm__c = Label.Pricing_Program_Code_Tender;
                quoteLineUpd.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                quoteLines.add(quoteLineUpd);
                quoteLines[0].Pricing_End_Date_dt__c = system.today()-10;
            }
        }
        Pricing_ApproveRejectCmntsUpdate_Batch updBatch = new Pricing_ApproveRejectCmntsUpdate_Batch();
        Database.BatchableContext bc;
        updBatch.execute(bc, quoteLines);
        Test.stopTest();
    }
}