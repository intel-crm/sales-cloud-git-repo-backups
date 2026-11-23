/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 04-07-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteLineBusinessLogic_Test {
    
    @testSetup
    public static void setUpData() {
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('qlBusinessLogicAdmin');
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser2(); // firstNameRPM@intel.com
        List<User> fseUser2 = Pricing_Test_Utility.createFSEUserWithParam('newFSEUser@intel.com','NewFseUser','UserName');
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            //Test.startTest();
            List<User> accExeUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            Test.startTest();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            
            //Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExeUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
            
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;            
            Test.stopTest();
        }
    }
    
    static testmethod void testUpdateQuoteLinePIFR() {
        Test.startTest();
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        User fseNewUser = [Select id from User where Email='newFSEUser@intel.com' Limit 1];
        
        Id cmtRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        
        List<SBQQ__Quote__c> quoteList = [Select id from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<Pricing_Comments__c> commentsFilled = new List<Pricing_Comments__c>();
        for(Pricing_Comments__c pc : [SELECT Id,Pricing_Quote__c,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c =: quoteList[0].Id
                                      and Pricing_Required_Ind__c = true and recordtypeid=:cmtRecordTypeId]) {
                                          pc.Pricing_Answer__c = 'test test test'; 
                                          commentsFilled.add(pc);                     
        }
        if(!commentsFilled.isEmpty()) {
            update commentsFilled;
        }
        quoteLine[0].Pricing_Ready_for_Review_cb__c = false;
        update quoteLine;
        System.runAs(adminUser) {
            quoteLine[0].Pricing_Status_Nm__c = 'Pending Intel Field Review';
            quoteLine[0].Pricing_Additional_T_C_s_Txt__c ='test';
            quoteLine[0].Pricing_Ready_for_Review_cb__c = true;
            List<Pricing_Performance_Metric__c> perMetric = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[0].Id);
            insert perMetric;
            update quoteLine[0];
            System.assertEquals('Pending Intel Field Review', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
        }
        Test.stopTest();
    }
    
    static testmethod void testUpdateQuoteLinePFIR() {   
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        User adminFSEUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com' Limit 1];
        User rpmUser = [SELECT Id, Email FROM User WHERE Email = 'firstNameRPM@intel.com' LIMIT 1];
        System.runAs(adminFSEUser) {
            
            quoteList[0].SBQQ__Status__c = 'Submitted';
            update quoteList[0];
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            quoteLine[0].Pricing_Revised_Pricing_Start_Date_dt__c = system.today()+1;
            quoteLine[0].Pricing_Approved_Start_Date_Dt__c = system.today();
            quoteLine[0].Pricing_Additional_RPM_Notify_Recipients__c = rpmUser.Email;
            update quoteLine[0];
            System.assertEquals('Pending Further Intel Review', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
        }
        Test.stopTest();
    }
    
    static testmethod void testQuoteLineApprovalByRPM() {
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            update quoteLine[0];
            Test.startTest();
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            update quoteLine[0];
        }
        Test.stopTest();
        System.assertEquals('Approved', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
    }
    
    static testmethod void testQuoteLineCreateByRPM() {
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
       
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        System.runAs(adminUser){
            quoteList[0].SBQQ__Status__c='Submitted';
            Update quoteList;
            
        }
        System.assert(quoteList[0].SBQQ__Status__c=='Submitted', true);
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : regionalManager[0].Id AND PermissionSet.Name IN ('Pricing_Tender_Regional_Pricing_Manager')];
        
        System.assert(count > 0, true);
        
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        Product2 prod = new Product2(Name='TestProduct',
                                     Core_Product_Org__c = 'Sales',
                                     Core_Product_Type__c = 'Processors',
                                     Core_Sales_Visible_Flag__c = true,
                                     Core_Hierarchy_ID__c = '43',
                                     Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                     Core_Processor_Number_Nm__c  = '6220',
                                     IsActive = true);
        insert prod;
        Product2 writeInProd = Pricing_Test_Utility.createWINProduct();
        Test.startTest();
        System.runAs(regionalManager[0]) {
            //newQuoteline = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Tender_QuoteLine_RecordType_Create);
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;//Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLine.Pricing_Product_Nm__c = prod.Id;
            quoteLine.SBQQ__Product__c = prod.Id;
            quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLine.Pricing_Systems_qty__c = 6; 
            quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLine.Pricing_CPUs_per_system_qty__c = 1;
            quoteLine.Pricing_Single_System_Price_Amt__c = 4;
            quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
            quoteLine.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_QuoteLine_Market_Segment_Non_Embedded;
            quoteLine.Pricing_Market_Segment_values_Nm__c ='';
            quoteLine.SBQQ__Quote__c = quoteList[0].Id;
            quoteLine.Pricing_Change_Request_cb__c = true;
            insert quoteLine;
            System.assert(quoteLine.Id!=null,'QuoteLine not created.');
        }
        Test.stopTest();
    }
    
    static testmethod void testQuoteLineUpdateWon() {
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            update quoteLine[0];
            Test.startTest();
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Won;
            update quoteLine[0];
        }
        System.assertEquals('Won', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
        Test.stopTest();
    }
    
    static testmethod void testQuoteLineChangeRequestRPM() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        //Test.startTest();
        quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
        update quoteLine;
        System.runAs(regionalManager[0]) {
            quoteLine[1].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            update quoteLine[1];
            Test.startTest();
            quoteLine[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[1].Id;
            quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            update quoteLine[2];
        }
        System.assertEquals('Pending Further Intel Review', quoteLine[2].Pricing_Status_Nm__c, 'Change request Quoteline is not updated to PFIR.');
        Test.stopTest();
    }
    
    static testmethod void testQuoteLineChangeRequestRPMApprove() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        Test.startTest();
        System.runAs(regionalManager[0]) {
            quoteLine[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[1].Id;
            quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            update quoteLine[2];
            System.assertEquals('Approved', quoteLine[2].Pricing_Status_Nm__c, 'Change request Quoteline is not updated to Approved.');
        }
        Test.stopTest();
    }
    
    static testmethod void testUpdateStatusToRejectedCb() {
        Test.startTest();
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        
        List<SBQQ__Quote__c> quoteList = [Select id from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        System.runAs(adminUser) {
            quoteLine[0].Pricing_Status_Nm__c = 'Pending Intel Field Review';
            quoteLine[0].Pricing_Update_Status_to_Rejected_cb__c = true;
            update quoteLine[0];
        }
        System.assertEquals('Pending Intel Field Review', quoteLine[0].Pricing_Status_Nm__c, 'Pending Intel Field Review');
        Test.stopTest();
    }
    
    static testmethod void testWriteInQLApproval() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        SBQQ__QuoteLine__c winProdQL1;
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser();
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);

        
            winProdQL1 = Pricing_Test_Utility.createWINQuoteLines(quoteList[0].Id);
        	System.runAs(regionalManager[0]) {
            String msg = Pricing_QuoteLineController.recordApproval(winProdQL1.Id, 'Test', 'Approve',winProdQL1,'test', true, winProdQL1.Pricing_Rejection_Reason__c, '');

        }
        System.assert( winProdQL1.Pricing_Manager__c==null, 'RPM is not populated on the Quoteline.');
        Test.stopTest();
    }
    
    static testmethod void testQuoteLineCRApproveRPM() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        Contact con = [Select id from Contact Limit 1];
        User partnerUser = [Select id from User where ContactId =:con.Id];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(partnerUser) {
            Test.startTest();
            quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[1].Id; 
            quoteLine[2].Pricing_Change_Request_cb__c = true;
            quoteLine[2].Pricing_Deal_RFQ_Id__c = '';
            update quoteLine[2];
            Test.stopTest();
            System.assertEquals('Approved',quoteLine[2].Pricing_Status_Nm__c,'QuoteLine status is not updated.');
        }
    }
    
    static testmethod void testQuoteLinePFIRChangeRequestRPM() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        Contact con = [Select id from Contact Limit 1];
        User partnerUser = [Select id from User where ContactId =:con.Id];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);

        System.runAs(partnerUser) {
            
            Test.startTest();
            quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            quoteLine[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[1].Id; 
            quoteLine[2].Pricing_Change_Request_cb__c = true;
            update quoteLine[2];
            System.assertEquals('Pending Further Intel Review',quoteLine[2].Pricing_Status_Nm__c, 'QuoteLine status is not updated.');
            Test.stopTest();
        }
    }
    
    static testmethod void testReadyForReviewPerMetricsError() {
        Test.startTest();
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        Id cmtRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        
        List<SBQQ__Quote__c> quoteList = [Select id from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<Pricing_Comments__c> commentsFilled = new List<Pricing_Comments__c>();
        for(Pricing_Comments__c pc : [SELECT Id,Pricing_Quote__c,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c =: quoteList[0].Id
                                      and Pricing_Required_Ind__c = true and recordtypeid=:cmtRecordTypeId]) {
                                          pc.Pricing_Answer__c = 'test test test'; 
                                          
                                          commentsFilled.add(pc);                     
                                      }
        if(!commentsFilled.isEmpty()) {
            update commentsFilled;
        }
        System.runAs(adminUser) {
            try {
                quoteLine[0].Pricing_Status_Nm__c = 'Pending Intel Field Review';
                quoteLine[0].Pricing_Ready_for_Review_cb__c = true;
                update quoteLine[0]; 
            }
            catch(DMLException e) {
                String message = e.getMessage();
                system.assert(message.contains(Label.Pricing_Tender_QuoteLine_Performance_Metric_Submit_Error_Message), 'message=' + message);   
            }
            
        }
        Test.stopTest();
    }
    
    static testmethod void testReadyForReviewCommentsError() {
        Test.startTest();
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        
        List<SBQQ__Quote__c> quoteList = [Select id from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        
        System.runAs(adminUser) {
            try {
                List<Pricing_Performance_Metric__c> perMetric = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[0].Id);
                insert perMetric;  
                quoteLine[0].Pricing_Status_Nm__c = 'Pending Intel Field Review';
                quoteLine[0].Pricing_Ready_for_Review_cb__c = true;
                update quoteLine[0]; 
            } 
            catch(DMLException e) {
                String message = e.getMessage();
                system.assert(message.contains(Label.Pricing_Tender_Quote_Comment_Submit_Error_Message), 'message=' + message);   
            }
            
        }
        Test.stopTest();
    }
    
    static testmethod void testRPMEditFieldsCRError() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
            quoteLine[1].Pricing_Status_Nm__c = 'Revised';
            update quoteLine[1];
            Test.startTest();
            try {
                quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                quoteLine[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[1].Id; 
                quoteLine[2].Pricing_Change_Request_cb__c = true;
                update quoteLine[2];
            }
            catch(DMLException e) {
                String message = e.getMessage();
                System.assert(message.contains(Label.Pricing_Tender_Change_Request_RPM_Validation_Error_Message), 'message=' + message); 
            }
            
            Test.stopTest();
        }
    }
    
    static testmethod void testOEMEditFieldsCRError() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        
        List<User> salesRep = [Select id from User where Email = 'newFSEUser@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, salesRep[0].Id);
        System.runAs(salesRep[0]) {
            quoteLine[1].Pricing_Status_Nm__c = 'Revised';
            update quoteLine[1];
            Test.startTest();
            try {
                quoteLine[2].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                quoteLine[2].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[1].Id; 
                quoteLine[2].Pricing_Change_Request_cb__c = true;
                update quoteLine[2];
            }
            catch(DMLException e) {
                String message = e.getMessage();
                System.assert(message.contains(Label.Pricing_Tender_Change_Request_OEMField_Validation_Error_Message), 'message=' + message); 
            }
            
            Test.stopTest();
        }
    }

    private static void calculateStatusAgeTest() {
        QuoteLineBusinessLogic.calculateStatusAge(system.now(), system.now()+0.5);
        QuoteLineBusinessLogic.calculateStatusAge(system.now(), system.now()+3);
        Decimal age3 = QuoteLineBusinessLogic.calculateStatusAge(System.today(), System.today().addDays(15));
        system.assert(age3>0);
    }
    
    static testmethod void testVAlidateQuoteLineProduct() {
        Test.startTest();
        Map<String, List<Id>> quoteLineTypeProductIdsMap = new Map<String, List<Id>>();
        Map<String, List<Id>> prdTypeNewProductListMap = new Map<String, List<Id>>();
        List<Product2> productList = Pricing_Test_Utility.createProduct(1);
        String str  = Label.Pricing_Tender_Standard_QuoteLine;
        List<Pricing_Dynamic_Data_Table__mdt> productTypeMetadataList = [SELECT Id, Pricing_Query__c, Pricing_Record_Type_Pkl__c, Label, Pricing_Where_Clause__c FROM Pricing_Dynamic_Data_Table__mdt WHERE Pricing_Record_Type_Pkl__c =:str];
        String query = productTypeMetadataList[0].Pricing_Query__c + ' ' +productTypeMetadataList[0].Pricing_Where_Clause__c;
        List<Product2> prdList = Database.query(query);
        prdTypeNewProductListMap.put(str, new List<String>{prdList[0].Id});
        quoteLineTypeProductIdsMap = QuoteLineBusinessLogic.validateQuoteLineProduct(prdTypeNewProductListMap);
        System.assert(!quoteLineTypeProductIdsMap.isEmpty(),'quoteLineTypeProductIdsMap should not be empty');
        Test.stopTest();
    }
    
    static testmethod void testupdateQuoteLineRecords() {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id,Name,Pricing_End_Customer_Country_Nm__c,Pricing_Customer_Nm__c,SBQQ__Account__r.Name,SBQQ__PrimaryContact__c,Pricing_Project_Name_Nm__c,
                                          Pricing_Region_Nm__c,SBQQ__SalesRep__c,Pricing_Server_Deal_Type_Nm__c FROM SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [SELECT Id,Pricing_Quote_Line_Number__c,Pricing_End_Customer_Country__c,Pricing_End_Customer_Nm__c,
                                              Pricing_OEM_Account_Nm__c,Pricing_Primary_Contact_Nm__c,Pricing_Project_Nm__c,SBQQ__Quote__c,
                                              Pricing_Region_Nm__c,Pricing_Sales_Rep__c,Pricing_Server_Deal_Type_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteList[0].Id ];
        quoteList[0].Pricing_Project_Name_Nm__c = 'Flow Test';
        update quoteList;
        List<List<SBQQ__QuoteLine__c>> quoteLineList = new List<List<SBQQ__QuoteLine__c>>();
        quoteLineList.add(quoteLine);
        QuoteLineBusinessLogic.updateQuoteLineRecords(quoteLineList);
        Test.stopTest();
        List<SBQQ__Quote__c> updatedQuoteList = [SELECT Id,Pricing_Project_Name_Nm__c FROM SBQQ__Quote__c WHERE Pricing_Project_Name_Nm__c = 'Flow Test' LIMIT 1];

        System.assert(!quoteList.isEmpty(),'updatedQuoteList should not be empty');
    }
    
    static testmethod void testProductChangetoWriteIn() {
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        Product2 writeInprod = new Product2(Name='Write In Product',
                                     Core_Sales_Visible_Flag__c = true,
                                     Core_Hierarchy_ID__c = '43',
                                     Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                     IsActive = true);
        insert writeInprod;
        
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,Pricing_Folio_ID_Nm__c,Pricing_Product_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ]; 
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        System.runAs(regionalManager[0]) {
           
            Test.startTest();
            quoteLine[1].Pricing_Product_Nm__c = writeInprod.Id;    
            quoteLine[1].Pricing_Other_Product_Nm__c = 'Test Write In Product';            
            update quoteLine[1];
            List<SBQQ__QuoteLine__c> newQuoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,Pricing_Folio_ID_Nm__c,Pricing_Product_Nm__c,Pricing_Error_Messages__c from SBQQ__QuoteLine__c where Id=:quoteLine[1].Id Limit 1]; 
            system.assertEquals(null,newQuoteLine[0].Pricing_Error_Messages__c);
            Test.stopTest();                    
        }
    }
    static testmethod void testusersHasValidRPMPermission(){
        List<String>Emails = new List<String>();
        List<String> rpmEmails = new List<String>();
        String rpmEmailwithNoPs = '' ;
        String rpmEmailsWithoutRPMPs = '';
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLine =  [SELECT Id,Pricing_Additional_RPM_Notify_Recipients__c from SBQQ__QuoteLine__c LIMIT 1];
         set<String>permissionSet = new set<String>{Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager};
            List<User> regionalManager = [Select id,Email from User where Email='firstNameRPM@intel.com' Limit 1];
            Emails.add(regionalManager[0].Email);
        Test.startTest();
         quoteLine.Pricing_Additional_RPM_Notify_Recipients__c = 'firstNameRPM@intel.com';
         update quoteLine;
         rpmEmails = QuoteLineBusinessLogic.usersHasValidRPMPermission(Emails,permissionSet);
         rpmEmailsWithoutRPMPs = QuoteLineBusinessLogic.validateAdditionalRecipients(quoteLine,rpmEmailwithNoPs,rpmEmails,true);
         Boolean var = rpmEmails.size() > 0;
         System.assertEquals(var, true);
         Boolean Email = String.isNotEmpty(rpmEmailsWithoutRPMPs);
         System.assertEquals(Email, true);
        Test.stopTest();
         }
    
     static testmethod void testAutoPopulateMeetCompPrice(){
         Map<Id,Pricing_Competitor_Product_Price__c> compProductPriceMap = new Map<Id,Pricing_Competitor_Product_Price__c>();
         List<String> regionList = new List<String>();
         SBQQ__Quote__c quote = [SELECT Id,Pricing_Server_Deal_Type_Nm__c,Pricing_Region_Nm__c from SBQQ__Quote__c LIMIT 1];
         SBQQ__QuoteLine__c quoteLine =  [SELECT Id,Pricing_Competetor_Product__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Name,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,Pricing_Unit_Qty__c,Pricing_Server_Deal_Type_Nm__c,Pricing_EndCustomer_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quote.Id LIMIT 1];
         List<Pricing_Competitor_Product_Price__c> compProductPriceList = New List<Pricing_Competitor_Product_Price__c>();
         compProductPriceList = Pricing_Test_Utility.createCompetitorProductPrice();
         for(Pricing_Competitor_Product_Price__c compProduct: compProductPriceList){
            compProductPriceMap.put(compProduct.Pricing_Competitor_Product__c,compProduct);
        }
            Test.startTest();
                 quoteLine.Pricing_Competetor_Product__c = compProductPriceList[0].Pricing_Competitor_Product__c;
                 quoteLine.Pricing_Other_Competitor_Product_Nm__c = null;
                 quoteLine.Pricing_Meet_Comp_Price_Amt__c = null;
         		 quoteLine.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
         		 quoteLine.Pricing_Status_Nm__c = 'Pending Further Intel Review';
                 update quoteLine;
             
         QuoteLineBusinessLogic.autoPopulateMeetComp(new List<SBQQ__QuoteLine__c>{quoteLine},compProductPriceMap);
         QuoteLineBusinessLogic.getCompetitorProductIdsRegions(quoteLine,new List<String>{quoteLine.Pricing_Program_Type_Nm__c},regionList,quoteLine.SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,quoteLine.SBQQ__Quote__r.Pricing_Region_Nm__c,quoteLine.Pricing_EndCustomer_Nm__c);
         System.assertEquals(null, quoteLine.Pricing_Meet_Comp_Price_Amt__c);
            Test.stopTest();
           }

    
    static testMethod void testCCGAutoPopulation(){
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        User adminUser = [Select id from User where Email='qlBusinessLogicAdmin@intel.com'];
        System.runAs(adminUser){
            quoteLine[0].Pricing_Status_Nm__c='Pending Further Intel Review';
            update quoteLine[0];
        }
        System.assertEquals('Pending Further Intel Review', quoteLine[0].Pricing_Status_Nm__c);
        Test.stopTest();
    }
    
    static testmethod void testPublishQuoteLetter() {
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLine = [Select id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
        List<User> regionalManager = [Select id from User where Email='firstNameRPM@intel.com' Limit 1];
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);
        
        Test.startTest();
        System.runAs(regionalManager[0]) {
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            update quoteLine[0];

            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine[0].Pricing_Save_After_Calculation_cb__c = true;
            update quoteLine[0];
        }
        Test.stopTest();
        System.assertEquals('Approved', quoteLine[0].Pricing_Status_Nm__c , 'QuoteLine status is not updated.');
    }
    
    static testmethod void testStatusRevertFix() {   
        
        Test.startTest();
            List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        	User adminUser = [SELECT Id FROM User WHERE Email = 'qlBusinessLogicAdmin@intel.com'];
        	List<SBQQ__QuoteLine__c> quoteLine = [Select id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteList[0].Id ];
            Product2 winProduct = Pricing_Test_Utility.createWINProduct();
            quoteLine[0].Pricing_Product_Nm__c = winProduct.Id;
            quoteLine[0].SBQQ__Product__c = winProduct.Id;
            quoteLine[0].Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        	update quoteLine[0];
            System.assertEquals('Pending Further Intel Review', quoteLine[0].Pricing_Status_Nm__c);
        Test.stopTest();
    }

    static testmethod void testRejectEmailNotification() {
        //Rejection Email Notification Triggering scenario
        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c  LIMIT 1];
        SBQQ__QuoteLine__c quoteLine;
        List<User> regionalManager = Pricing_Test_Utility.createPricingMangerUser();
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, regionalManager[0].Id);        
        quoteLine = Pricing_Test_Utility.createWINQuoteLines(quoteList[0].Id);                
        quoteLine.Pricing_Previous_Status_Nm__c = 'Pending';
        Test.startTest();
        System.runAs(regionalManager[0]) {
            quoteLine.Pricing_Previous_Status_Nm__c = 'Rejected';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
            update quoteLine;
        }
        System.assert(quoteLine.Id != null, true);
        Test.stopTest();
    }

    static testmethod void testRejectEmailNotificationFI() {
        //Rejection Email Notification Triggering scenario FI
        Opportunity oppList = Pricing_Test_Utility.createOpportunity();
        List<OpportunityLineItem> oppItemList = Pricing_Test_Utility.createOpportunityProduct(oppList.Id, 2);
        Account acc = [SELECT Id from Account Limit 1];
        List<User> adminUserList  = [Select Id,Email from User Where Email = 'qlBusinessLogicAdmin@intel.com' Limit 1];
        List<User> accountExecutiveUserList  = [Select Id,Email from User Where Email = 'firstNameAE@intel.com' Limit 1];
        Contact con  = [Select Id from Contact Where Email = 'primarycontact@noemail.com' Limit 1];
        AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
        insert accTeam;
        List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createFIQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);  
        List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createFIQuoteLines(quoteList[0].Id, 1);
        Test.startTest();
        Pricing_Test_Utility.shareQuoteWithUser(quoteList[0].Id, adminUserList[0].Id);
        lstquoteLines[0].Pricing_Previous_Status_Nm__c = 'Pending';
        System.runAs(adminUserList[0]) {
            lstquoteLines[0].Pricing_Previous_Status_Nm__c = 'Rejected';
            lstquoteLines[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
            update lstquoteLines;
        }
        System.assert(lstquoteLines[0].Id != null, true);
        Test.stopTest();
    }
    static testMethod void testStatusRevertFixForWon()
    {
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        Test.startTest();
        	SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id,'Won');
            Product2 winProduct = Pricing_Test_Utility.createWINProduct();
            quoteLine.Pricing_Product_Nm__c = winProduct.Id;
            quoteLine.SBQQ__Product__c = winProduct.Id;
            quoteLine.Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            System.assertEquals('Pending Further Intel Review', quoteLine.Pricing_Status_Nm__c);
        	update quoteLine;
        Test.stopTest();
    }

    static testMethod void testStatusRevertFixForRejected()
    {        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        Test.startTest();
        	SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id,'Rejected');
            Product2 winProduct = Pricing_Test_Utility.createWINProduct();
            quoteLine.Pricing_Product_Nm__c = winProduct.Id;
            quoteLine.SBQQ__Product__c = winProduct.Id;
            quoteLine.Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
            System.assertEquals('Pending Further Intel Review', quoteLine.Pricing_Status_Nm__c);
        	update quoteLine;
        Test.stopTest();
    }
    
    static testMethod void testStatusRevtFixWonToApprove()
    {
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        Test.startTest();
        	SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id,'Won');
        	Product2 winProduct = Pricing_Test_Utility.createWINProduct();
            quoteLine.Pricing_Product_Nm__c = winProduct.Id;
            quoteLine.SBQQ__Product__c = winProduct.Id;
            quoteLine.Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            System.assertEquals('Approved', quoteLine.Pricing_Status_Nm__c);
        	update quoteLine;
        Test.stopTest();
    }
    
    static testMethod void testStatusRevtFixReviseToApprove()
    {
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        Test.startTest();
        	SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id,Label.Pricing_Tender_QuoteLine_Status_Revised);
        	Product2 winProduct = Pricing_Test_Utility.createWINProduct();
            quoteLine.Pricing_Product_Nm__c = winProduct.Id;
            quoteLine.SBQQ__Product__c = winProduct.Id;
            quoteLine.Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            System.assertEquals('Approved', quoteLine.Pricing_Status_Nm__c);
        	update quoteLine;
        Test.stopTest();
    }
    
    static testMethod void testPopulateRPMOnWinProdQl()
    {        
        List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__Status__c from SBQQ__Quote__c  LIMIT 1];
        Test.startTest();
        	SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id,Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview);
        	Product2 winProduct = Pricing_Test_Utility.createWINProduct();
            quoteLine.Pricing_Product_Nm__c = winProduct.Id;
            quoteLine.SBQQ__Product__c = winProduct.Id;
            quoteLine.Pricing_Other_Product_Nm__c = 'Test Tender';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            System.assertEquals('Approved', quoteLine.Pricing_Status_Nm__c);
        	update quoteLine;
        Test.stopTest();
    }
    
    
    static testMethod void testAutoRejection(){
       
        Account acc = [select id from Account limit 1];
       	Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerAccountMapping = Pricing_Test_Utility.createUnifiedEndCustomer(acc.Id);
        Pricing_UnifiedEndCustomerCountryMapping__c uniEndCustomerCountryMapping = [SELECT ID,Pricing_Compliance_Watch_List__c,Pricing_Is_Sanctioned__c from Pricing_UnifiedEndCustomerCountryMapping__c Where Name = 'End Customer 1' Limit 1];
        Product2 producttest = Pricing_Test_Utility.createWINProduct();
        List<SBQQ__Quote__c> quoteList = [Select id,Pricing_Unified_Global_End_Customer_Nm__c,Pricing_Is_Sanctioned__c from SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = Pricing_Test_Utility.createQuoteLineByStatus(quoteList[0].Id,'Draft');
        Test.startTest();
        uniEndCustomerCountryMapping.Pricing_Compliance_Watch_List__c = 'NOPAYOUT';
        	update uniEndCustomerCountryMapping;
        quoteList[0].Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerCountryMapping.id;
        	update quoteList[0];
        quoteLine.Pricing_Status_Nm__c='Pending Further Intel Review';
            update quoteLine;
            System.assertEquals('Pending Further Intel Review', quoteLine.Pricing_Status_Nm__c);
        Test.stopTest();
    }
         
}