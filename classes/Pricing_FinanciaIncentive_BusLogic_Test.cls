/**
 * @description       : Test class for Financial Incentive Business Logic class
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 04-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public without sharing class Pricing_FinanciaIncentive_BusLogic_Test {

    @testSetUp
    public static void setUpData() {
        Pricing_Test_Utility.createPriceBook();
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]) {
            Test.startTest();
            	Account acc = Pricing_Test_Utility.createAccount();
            	Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            	List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            	List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                Opportunity oppList = Pricing_Test_Utility.createOpportunity();
                List<OpportunityLineItem> oppItemList = Pricing_Test_Utility.createOpportunityProduct(oppList.Id, 2);
            	AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            	insert accTeam;
                List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createFIQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);  
            	List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createFIQuoteLines(quoteList[0].Id, 1);
        	Test.stopTest();
        }
    }

    static testMethod void opportunityToQuoteLineChangeReqTest () {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_New_Quantity_qty__c,RecordTypeId,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        
        System.runAs(adminUser){
            List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper> fiCRWrapperList = new List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper>();
            Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper fiWrapperInstance = 
            new Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper(Integer.valueOf(quoteLineList[0].Pricing_New_Quantity_qty__c ?? 0)+1,quoteLineList[0].Pricing_Approved_Start_Date_Dt__c,quoteLineList[0].Pricing_Approved_End_Date_Dt__c, quoteLineList[0].Id, 'test');
            fiCRWrapperList.add(fiWrapperInstance);
            List<String> result = Pricing_FinancialIncentive_BusinessLogic.opportunityToQuoteLineChangeReq(fiCRWrapperList);
            Assert.isTrue(result.size() > 0, 'Error in Insert');
        }
        Test.stopTest();
    }
    
    static testMethod void opportunityToQuoteLineChangeReqSuccessTest () {
        Test.startTest();
        List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_New_Quantity_qty__c,RecordTypeId,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        
        System.runAs(adminUser){
            List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper> fiCRWrapperList = new List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper>();
            Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper fiWrapperInstance = 
            new Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper(Integer.valueOf(quoteLineList[0].Pricing_New_Quantity_qty__c ?? 0)+1,Date.today() , Date.today().addDays(30), quoteLineList[0].Id, 'test');
            fiCRWrapperList.add(fiWrapperInstance);
            List<String> result = Pricing_FinancialIncentive_BusinessLogic.opportunityToQuoteLineChangeReq(fiCRWrapperList);
            System.assertEquals(result.size() > 0, true);
        }
        Test.stopTest();
    }

    static testMethod void testCreateQuoteQuoteLine () {
        Test.startTest();
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Core_Design_Registration__c desigRegRec = Pricing_Test_Utility.createDesignRegistration();
        Opportunity opp = [SELECT Id,Core_Design_Registration_Id__c FROM Opportunity LIMIT 1];
        opp.Core_Design_Registration_Id__c = desigRegRec.id;
        update opp;
        List<OpportunityLineItem> oppItemList = Pricing_Test_Utility.createOpportunityProduct(opp.Id, 1);
        Pricing_Integration_Staging__c pisRecord = new Pricing_Integration_Staging__c();
        pisRecord.Pricing_Status__c = 'Pending';
        pisRecord.Pricing_Message_Type__c = 'Financial Incentive';
        pisRecord.Pricing_SObjectId__c = opp.id;
        insert pisRecord;
        List<Product_Additional_Attribute__c> dealProducts = [SELECT Id FROM Product_Additional_Attribute__c];
        Map<Id, String> qlErrorMessageMap = new Map<Id, String>();
        qlErrorMessageMap.put(oppItemList[0].Id,'QuoteLine insertion Failed');
        System.runAs(adminUser){
            Pricing_FinancialIncentive_BusinessLogic.createQuoteQuoteLine(new List<Id>{opp.Id});
            Pricing_FinancialIncentive_BusinessLogic.createQlErrorLogEntry(qlErrorMessageMap);
            System.assertEquals(oppItemList.size() > 0, true);
            System.assertEquals(dealProducts.size() > 0, true);
        }
        Test.stopTest();
    }
    
    static testMethod void testUpdateQuoteQuoteLine () {
        Test.startTest();
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Core_Design_Registration__c desigRegRec = Pricing_Test_Utility.createDesignRegistration();
        Opportunity opp = [SELECT Id,Core_Design_Registration_Id__c FROM Opportunity LIMIT 1];
        opp.Core_Design_Registration_Id__c = desigRegRec.id;
        update opp;
        List<OpportunityLineItem> oppItemList = Pricing_Test_Utility.createOpportunityProduct(opp.Id, 1);
        Pricing_Integration_Staging__c pisRecord = new Pricing_Integration_Staging__c();
        pisRecord.Pricing_Status__c = 'Pending';
        pisRecord.Pricing_Message_Type__c = 'Financial Incentive Update';
        pisRecord.Pricing_SObjectId__c = opp.id;
        insert pisRecord;
        List<Product_Additional_Attribute__c> dealProducts = [SELECT Id FROM Product_Additional_Attribute__c];
        
        System.runAs(adminUser){
            Pricing_FinancialIncentive_BusinessLogic.createQuoteQuoteLine(new List<Id>{opp.Id});
            System.assertEquals(oppItemList.size() > 0, true);
            System.assertEquals(dealProducts.size() > 0, true);
        }
        Test.stopTest();
    }
    
       static testMethod void testupdateQuoteLineStatus () {
        Test.startTest();
        List<SBQQ__QuoteLine__c> QLList =  [SELECT Id,Pricing_Quote_Program_Nm__c,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oppItemsList = [SELECT Id,Product2Id,Core_Status__c,SBQQ__QuoteLine__c FROM OpportunityLineItem where Opportunity.id =: opp.id];
        QLList[0].Pricing_Status_Nm__c = 'Approved';
     	update QLList;
        oppItemsList[0].SBQQ__QuoteLine__c = QLList[0].id;
        oppItemsList[0].Core_Status__c = 'Cancelled';
        oppItemsList[0].Core_Loss_Cancel_Details__c = 'test Lost';
        oppItemsList[0].Core_Competitor__c = 'Apple';
        oppItemsList[0].Core_Competitor_Product__c = 'AMD Genoa';
        oppItemsList[0].Core_Loss_Cancel_Reason__c = 'Lost - Another IA Bid Selected';
        update oppItemsList;
                   
		Pricing_FinancialIncentive_BusinessLogic.updateQuoteLineStatus(oppItemsList);
        System.assertEquals(oppItemsList.size() > 0, true);
        Test.stopTest(); 
    }
    
    static testMethod void testpopulateQLNumberOnOppLineItem () {
        Test.startTest();
        Map<String,String> oppLineIdToProdIdMap = new Map<String,String>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oppItemList = [SELECT Id,Product2Id,Opportunity.id,SBQQ__QuoteLine__c FROM OpportunityLineItem where Opportunity.id =: opp.id];
        oppLineIdToProdIdMap.put(oppItemList[0].Opportunity.id,oppItemList[0].Product2Id);
        List<SBQQ__QuoteLine__c> parentQLList =  [SELECT Id,Pricing_Additional_Comments_Txt__c,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        parentQLList[0].Pricing_Status_Nm__c = 'Approved';
     	update parentQLList;
        oppItemList[0].SBQQ__QuoteLine__c = parentQLList[0].id;
        update oppItemList;
        
           Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Financial_Incentive_Quote_Line_Edit);
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;
           	quoteLine.SBQQ__Quote__c = parentQLList[0].SBQQ__Quote__c;
            quoteLine.Pricing_Product_Nm__c = oppItemList[0].Product2Id;
            quoteLine.SBQQ__Product__c = oppItemList[0].Product2Id;
        	quoteLine.Pricing_Additional_Comments_Txt__c = 'test comments';
            quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        	quoteLine.Pricing_Reference_Quote_Line_Nbr__c = parentQLList[0].Id;
            insert quoteLine;
        	Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItem(parentQLList[0].id,quoteLine.id,'create');
        	Pricing_FinancialIncentive_BusinessLogic.createLogEntry(oppLineIdToProdIdMap);
        System.assertEquals(quoteLine.Pricing_Additional_Comments_Txt__c, 'test comments');
        Test.stopTest();    
    }
    static testMethod void testpopulateQLNumberOnOppLineItemReject () {
        Test.startTest();
        List<id> productId = new List<id>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oppItemList = [SELECT Id,Product2Id,SBQQ__QuoteLine__c FROM OpportunityLineItem where Opportunity.id =: opp.id];
        productId.add(oppItemList[0].Product2Id);
        List<SBQQ__QuoteLine__c> parentQLList =  [SELECT Id,Pricing_Additional_Comments_Txt__c,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        parentQLList[0].Pricing_Status_Nm__c = 'Approved';
     	update parentQLList;
        oppItemList[0].SBQQ__QuoteLine__c = parentQLList[0].id;
        update oppItemList;
        
           Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Financial_Incentive_Quote_Line_Edit);
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
            quoteLine.RecordTypeId=quoteLineCreateRecordId;
           	quoteLine.SBQQ__Quote__c = parentQLList[0].SBQQ__Quote__c;
            quoteLine.Pricing_Product_Nm__c = oppItemList[0].Product2Id;
            quoteLine.SBQQ__Product__c = oppItemList[0].Product2Id;
        	quoteLine.Pricing_Additional_Comments_Txt__c = 'test comments';
            quoteLine.Pricing_Status_Nm__c = 'Rejected';
        	quoteLine.Pricing_Reference_Quote_Line_Nbr__c = parentQLList[0].Id;
            insert quoteLine;
        	Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItem(parentQLList[0].id,quoteLine.id,'Reject');
        System.assertEquals(quoteLine.Pricing_Additional_Comments_Txt__c, 'test comments');
        Test.stopTest();    
    }
    
    static testMethod void testupdateOpportunityOwnerName () {
        Test.startTest();
        Map<Id,Opportunity> oppIdToOpptyRecordMap = new Map<Id,Opportunity>();
        List<SBQQ__Quote__c> quoteList = [Select Id,SBQQ__Opportunity2__c,SBQQ__PrimaryContact__r.OwnerId,SBQQ__SalesRep__c from SBQQ__Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity where id =: quoteList[0].SBQQ__Opportunity2__c LIMIT 1];
        oppIdToOpptyRecordMap.put(opp.id,opp);
        Pricing_FinancialIncentive_BusinessLogic.updateOpportunityOwnerName(oppIdToOpptyRecordMap);
        System.assertEquals((quoteList.size() > 0), true);
		Test.stopTest();  
    }

    static testMethod void testPopulateQLNumberOnOppLineItemBulk () {
        Test.startTest();
        List<id> productId = new List<id>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oppItemList = [SELECT Id,Product2Id,SBQQ__QuoteLine__c FROM OpportunityLineItem where Opportunity.id =: opp.id];
        productId.add(oppItemList[0].Product2Id);
        List<SBQQ__QuoteLine__c> parentQLList =  [SELECT Id,Pricing_Additional_Comments_Txt__c,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        parentQLList[0].Pricing_Status_Nm__c = 'Approved';
     	update parentQLList;
        oppItemList[0].SBQQ__QuoteLine__c = parentQLList[0].id;
        update oppItemList;
        List<Id> quoteLineIdList = new List<Id>{parentQLList[0].Id};
        Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItemBulk(quoteLineIdList,'Approved');
        System.assertEquals(parentQLList[0].Pricing_Status_Nm__c, 'Approved');
    }
}