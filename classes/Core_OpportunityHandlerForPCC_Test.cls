//Areefa
@isTest
public class Core_OpportunityHandlerForPCC_Test {

    @testSetup
    static void setupData(){
        Pricing_Test_Utility.createPriceBook();
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]) {
            Test.startTest();
                Account acc = Pricing_Test_Utility.createAccount();
            
                Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            
                Opportunity oppList = Pricing_Test_Utility.createOpportunity();
            
                oppList.CloseDate = System.today().addDays(5); 
                update oppList;
            
                system.debug('oppList:'+oppList);
                List<OpportunityLineItem> oppItemList = Pricing_Test_Utility.createOpportunityProduct(oppList.Id, 2);
            
                AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
                insert accTeam;
            
                List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);                
            
                List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
                system.debug('QL record-->'+lstquoteLines);
                /*lstquoteLines[0].Pricing_Quote_Program_Nm__c = 'Financial Incentive'; 
                //lstquoteLines[0].Pricing_Start_Date_dt__c = System.today().addDays(3);            
                SBQQ.TriggerControl.disable();
                update lstquoteLines;
                SBQQ.TriggerControl.enable();*/
            Test.stopTest();
        }
    }
    
    
static testMethod void OPTYQuoteSyncTest()
    { 
    System.runAs(Core_Test_Utility.systemAdminUser) { 
         Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec; 
       
         List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
         List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        // Create a product/price book entry to use on the opportunities
        Product2 p = new Product2(Name = 'Test Product 03-24-2015');
         
           insert p;
       
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = p.Id, Pricebook2Id = Test.getStandardPricebookId(),
                                                UnitPrice = 0, IsActive = true);
        
            insert pbe;
     
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OppDecisionDtCannotGreaterOLIofQLStrDt'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHelper';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='beforeUpdate'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'PSAMValidationOpptDecisionDateCannotGreaterThanOLIofQL_StartDate';
        triggerExecList.add(triggerExec25);
        
        insert triggerExecList;
     
        Test.startTest();
        Map<Id,String> oppLineIdToProdIdMap = new Map<Id,String>();
        Map<Id, Date> oppIdAndDecisionDt = new Map<Id, Date>();
        
        Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry', 
                                   BillingStreet = '123 Fake St',BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='EMEA Sales Group');
        
        insert acct;
       
        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Opportunity oppty = new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,
                                            AccountId = acct.Id, OwnerId= UserInfo.getUserId(),Core_Coverage_Type_Nm__c = 'Deal Registration',
                                            StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity');
        
        insert oppty;
      
            // Since a workflow rule ensures all new line items are Pending, we need to first insert, then update
        List<OpportunityLineItem> oppLnItems = new List<OpportunityLineItem>();
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
        oppLnItems.add(new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id,
                                                    UnitPrice = 200, Quantity = 10, Core_Competitor__c = 'Acer', Core_Competitor_Product__c = 'AMD Athlon'));
       
            insert oppLnItems;
      
        
        oppLnItems[0].Core_Status__c = 'Pending';
        oppLnItems[1].Core_Status__c = 'Lost';
        oppLnItems[1].Core_Loss_Cancel_Reason__c = 'Lost already';
        oppLnItems[2].Core_Status__c = 'Cancelled';
        oppLnItems[2].Core_Loss_Cancel_Reason__c = 'Cancelled already';
        oppLnItems[3].Core_Status__c = 'Pending';
        oppLnItems[4].Core_Status__c = 'Won';
        oppLnItems[5].Core_Status__c = 'Deleted';
        oppLnItems[6].Core_Status__c = 'Pending';
        
             
            update oppLnItems;
        
         List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acct.Id, UserInfo.getUserId(), 1,adminUserList[0].Email,accountExecutiveUserList[0].Email);                
            
         List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
        
        Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Financial_Incentive_Quote_Line_Edit);
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
        quoteLine.RecordTypeId=quoteLineCreateRecordId;
        //quoteLine.Pricing_Quote_Program_Nm__c ='Financial Incentive';
        quoteLine.Pricing_Start_Date_dt__c = System.Date.today().addDays(11);
        quoteLine.Pricing_Approved_Start_Date_Dt__c = System.Date.today().addDays(11);
        quoteLine.SBQQ__Quote__c = lstquoteLines[0].SBQQ__Quote__c;
        quoteLine.Pricing_Product_Nm__c = oppLnItems[0].Product2Id;
        quoteLine.SBQQ__Product__c = oppLnItems[0].Product2Id;
        quoteLine.Pricing_Additional_Comments_Txt__c = 'test comments';
        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        quoteLine.Pricing_Reference_Quote_Line_Nbr__c = lstquoteLines[0].Id;
        
        insert quoteLine;
        
        Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItem(lstquoteLines[0].id,quoteLine.id,'create');
        /*
        List<Opportunity> newOppList = new List<Opportunity>();              
        newOppList.add(oppty);
        oppty.Pricing_Status_Nm__c = 'Approved';
        update newOppList;
        */
        
        oppLnItems[0].SBQQ__QuoteLine__c = lstquoteLines[0].id;
        
        update oppLnItems;
       
        Test.stopTest(); 
        }   
    }

    
    static testMethod void testValidatePSAMDecisionDate(){
        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec25 = new Core_Trigger_Executions__c();
        triggerExec25.Name='OppDecisionDtCannotGreaterOLIofQLStrDt'; 
        triggerExec25.Core_Class_Name__c='Core_OpportunityHelper';
        triggerExec25.Core_Object__c='Opportunity';
        triggerExec25.Core_Trigger_Events__c='beforeUpdate'; 
        triggerExec25.Core_Active__c=true; 
        triggerExec25.Core_Description__c = 'PSAMValidationOpptDecisionDateCannotGreaterThanOLIofQL_StartDate';
        triggerExecList.add(triggerExec25);
        
        insert triggerExecList;
        
        
        Test.startTest();
        Map<Id,String> oppLineIdToProdIdMap = new Map<Id,String>();
        Map<Id, Date> oppIdAndDecisionDt = new Map<Id, Date>();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        opp.CloseDate = System.Date.today().addDays(10);
        oppIdAndDecisionDt.put(opp.Id, opp.CloseDate);
        opp.Core_Opportunity_Coverage_Nm__c = 'Partner-Led Opportunity';
        opp.Core_Coverage_Type_Nm__c = 'Deal Registration';     
        update opp;
        
        system.debug('Opportunity record'+opp);
        
        List<OpportunityLineItem> oppItemList = [SELECT Id,Core_QL_Start_Dt__c,Product2Id,Opportunity.id,Core_QL_Additional_Comments_Txt__c,SBQQ__QuoteLine__c FROM OpportunityLineItem where Opportunity.id =: opp.id];
        
        oppLineIdToProdIdMap.put(oppItemList[0].Opportunity.id,oppItemList[0].Product2Id);
        
        List<SBQQ__QuoteLine__c> parentQLList =  [SELECT Id,Pricing_Additional_Comments_Txt__c,Pricing_Status_Nm__c,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        
        parentQLList[0].Pricing_Status_Nm__c = 'Approved';
        update parentQLList;
        
        oppItemList[0].SBQQ__QuoteLine__c = parentQLList[0].id;
        update oppItemList;
        
        Id quoteLineCreateRecordId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c',Label.Pricing_Financial_Incentive_Quote_Line_Edit);
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
        quoteLine.RecordTypeId=quoteLineCreateRecordId;
        //quoteLine.Pricing_Quote_Program_Nm__c ='Financial Incentive';
        quoteLine.Pricing_Start_Date_dt__c = System.Date.today().addDays(11);
        quoteLine.Pricing_Approved_Start_Date_Dt__c = System.Date.today().addDays(11);
        quoteLine.SBQQ__Quote__c = parentQLList[0].SBQQ__Quote__c;
        quoteLine.Pricing_Product_Nm__c = oppItemList[0].Product2Id;
        quoteLine.SBQQ__Product__c = oppItemList[0].Product2Id;
        quoteLine.Pricing_Additional_Comments_Txt__c = 'test comments';
        quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
        quoteLine.Pricing_Reference_Quote_Line_Nbr__c = parentQLList[0].Id;
        insert quoteLine;
        system.debug('@@oppItemList@'+oppItemList);
        Pricing_FinancialIncentive_BusinessLogic.populateQLNumberOnOppLineItem(parentQLList[0].id,quoteLine.id,'create');
         try {
             List<Opportunity> newOppList = new List<Opportunity>();              
             newOppList.add(opp);
             newOppList[0].StageName = 'Define';
             update newOppList;
             //Core_OpportunityHandler.validatePSAMDecisionDate(newOppList,);              
                         
        } catch (DmlException e) {
            system.debug('@inside catch');
            String expectedErrorMessage = 'Decision Date cannot be greater than Quote Start date';
            Boolean hasExpectedError = e.getMessage().contains(expectedErrorMessage);
            System.assert(hasExpectedError, 'The expected validation error should be thrown.');
        }
        Test.stopTest();    
    }
    
}