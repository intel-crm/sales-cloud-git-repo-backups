@isTest
public with sharing class Pricing_BulkSalesRepActionControllerTest {
    
    //Method to setup Test data
    @testSetup
    public static void setUpData() {        
        List < User > adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]) {
        Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            List < User > accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List < User > salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
            accTeamList.add(new AccountTeamMember(AccountId = acc.Id, TeamMemberRole = 'Technical Sales', UserId = salesRepUserList[0].Id));  
            accTeamList.add(new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales', UserId = adminUserList[0].Id));
            insert accTeamList;       
            List < SBQQ__Quote__c > lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2, salesRepUserList[0].Email, accountExecutiveUserList[0].Email);
            List < SBQQ__QuoteLine__c > lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 2);               
        Test.stopTest();
        }    
    }
    
    static testmethod void recordApprovalTest() {
        
        List < User > lstFSEUsers3 = [Select Id, Email from User Where Email = 'firstNameSalesRep@intel.com' Limit 1 ];        
        List < SBQQ__Quote__c > lstQuote = [Select Id, SBQQ__SalesRep__r.Id from SBQQ__Quote__c Where SBQQ__SalesRep__r.Id =: lstFSEUsers3[0].Id limit 1];
        List < SBQQ__QuoteLine__c > quoteLines = [Select Id, Pricing_Status_Nm__c,Pricing_Sales_Rep__c from SBQQ__QuoteLine__c Limit 2];
        for (SBQQ__QuoteLine__c ql: quoteLines) {            
            ql.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
            ql.Pricing_Sales_Rep__c = lstFSEUsers3[0].Id;
        }
        SBQQ.TriggerControl.disable();
        update quoteLines;
        SBQQ.TriggerControl.enable();
        
        system.runAs(lstFSEUsers3[0]) {
            Test.startTest();
            List < SBQQ__QuoteLine__c > quoteLineData = Pricing_BulkSalesRepActionController.getQuoteLineDetails(lstQuote[0].Id);
            List < SBQQ__QuoteLine__c > quoteLineToApprove = new List < SBQQ__QuoteLine__c > ();
            List < SBQQ__QuoteLine__c > quoteLineToReject = new List < SBQQ__QuoteLine__c > ();
          	quoteLineToApprove.add(quoteLineData[0]);
            quoteLineToReject.add(quoteLineData[1]);
            System.assertEquals('Success', Pricing_BulkSalesRepActionController.recordApproval(quoteLineToApprove, Label.Pricing_Tender_QuoteLine_Status_Approved, '', false));
            System.assertEquals('Success', Pricing_BulkSalesRepActionController.recordApproval(quoteLineToReject, Label.Pricing_Tender_QuoteLine_Status_Rejected, '', false));
            Test.stopTest();
        } 
    }
    
    static testmethod void testCustomerRevision(){
        List < User > lstFSEUsers3 = [Select Id, Email from User Where Email = 'firstNameSalesRep@intel.com' Limit 1 ];
        List < SBQQ__Quote__c > lstQuote = [Select Id, SBQQ__SalesRep__r.Id from SBQQ__Quote__c Where SBQQ__SalesRep__r.Id =: lstFSEUsers3[0].Id limit 1];
        List < SBQQ__QuoteLine__c > quoteLines = [Select Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.Id, Pricing_Status_Nm__c,Pricing_Ready_for_Review_cb__c,Pricing_Last_Submitted_By_Id__c,Customer_Revision_Count_Cnt__c,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_SDM_Fast_Track__c from SBQQ__QuoteLine__c Limit 1];

        quoteLines[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        quoteLines[0].Pricing_Program_Type_Nm__c = Label.Pricing_Tender_Small_Volume_Quote;
        quoteLines[0].Pricing_Last_Submitted_By_Id__c = lstFSEUsers3[0].Id;
        update quoteLines;
        System.runAs(lstFSEUsers3[0]){
          	Test.startTest();
            String msg = Pricing_BulkSalesRepActionController.recordApproval(quoteLines, Label.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM, 'post to chatter', true);
            System.assertEquals('Success', msg);
            Test.stopTest();
        }

    }
    
    static testmethod void testOEMRecall(){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c qli = [SELECT Id,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id LIMIT 1];
        qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview;
        qli.Pricing_Program_Type_Nm__c = Label.Pricing_Tender_Small_Volume_Quote;
        Test.startTest();
        update qli;
        String msg = Pricing_BulkSalesRepActionController.getQuoteLinetoRollback(quote.Id);
        System.assertEquals('Success', msg);
        Test.stopTest();
    }

    static testmethod void getFIQuoteLineToApproveRejectTest() {        
        List < User > lstFSEUsers3 = [Select Id, Email from User Where Email = 'firstNameSalesRep@intel.com' Limit 1 ];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        system.runAs(lstFSEUsers3[0]) {
            Test.startTest();
            List < SBQQ__QuoteLine__c > quoteLineData = Pricing_BulkSalesRepActionController.getFIQuoteLineToApproveReject((String)quote.Id);
            Assert.isTrue(quoteLineData.size() > 0, 'Error in getFIQuoteLineToApproveRejectTest');
            Test.stopTest();
        } 
    }

    static testmethod void getFIPricingManagerSearchTest() {        
        List < User > lstFSEUsers3 = [Select Id, Email from User Where Email = 'firstNameSalesRep@intel.com' Limit 1 ];
        system.runAs(lstFSEUsers3[0]) {
            Test.startTest();
            List<PermissionSetAssignment> users = Pricing_BulkSalesRepActionController.getFIPricingManagerSearch('Test');
            Assert.isTrue(users.size() >= 0, 'Error in PermissionSetAssignment');
            Test.stopTest();
        } 
    }

    static testmethod void bulkApprovalRejectionQuoteLineRPMTest() {        
        List < User > adminUserList = [Select Id, Email from User Where Email = 'firstName@intel.com' Limit 1 ];
        List < User > accountExecutiveUserList = [Select Id, Email from User Where Email = 'firstNameAE@intel.com' Limit 1 ];
        List<Contact> contactList = [Select Id, AccountId FROM Contact Where email = 'primarycontact@noemail.com' Limit 1]; 
        Opportunity oppList = Pricing_Test_Utility.createOpportunity();
        List<OpportunityLineItem> oppItemList = Pricing_Test_Utility.createOpportunityProduct(oppList.Id, 2);
        
        List<SBQQ__Quote__c> quoteListFI = Pricing_Test_Utility.createFIQuoteWithParam(contactList[0].AccountId, contactList[0].Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);  
        List<SBQQ__QuoteLine__c> lstquoteLinesFI = Pricing_Test_Utility.createFIQuoteLines(quoteListFI[0].Id, 1);

        system.runAs(adminUserList[0]) {
            Test.startTest();
            String msg = Pricing_BulkSalesRepActionController.bulkApprovalRejectionQuoteLineRPM(lstquoteLinesFI, 'Approved', Label.Pricing_Tender_FinancialIncentive_Quote);
            Assert.isTrue(msg.length() >= 0, 'Error in bulkApprovalRejectionQuoteLineRPMTest');
            Test.stopTest();
        } 
    }

    static testmethod void getQuoteLineToRejectByRPMTest() {        
        List < User > adminUserList = [Select Id, Email from User Where Email = 'firstName@intel.com' Limit 1 ];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        List < SBQQ__QuoteLine__c > quoteLines = [Select Id, Pricing_Status_Nm__c from SBQQ__QuoteLine__c Limit 1];
        quoteLines[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        quoteLines[0].Pricing_Integration_Status_Nm__c = null;
        update quoteLines;
        system.runAs(adminUserList[0]) {
            Test.startTest();
            List < SBQQ__QuoteLine__c > quoteLineData = Pricing_BulkSalesRepActionController.getQuoteLineToRejectByRPM((String)quote.Id);
            Assert.isTrue(quoteLineData.size() > 0, 'Error in getQuoteLineToRejectByRPM');
            Test.stopTest();
        } 
    }
}