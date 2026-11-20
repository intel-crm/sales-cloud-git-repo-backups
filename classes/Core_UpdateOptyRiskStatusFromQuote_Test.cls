/****************************************************************************************************************************************
* Class Name  : Core_UpdateOptyRiskStatusFromQuote_Test 
* Version     : 1.0 
* Created Date: 25-08-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mula Yeshwanth        25/08/2022                   Created Core_updateRiskStatusApprover_Test to test 
*****************************************************************************************************************************************/
@isTest
public class Core_UpdateOptyRiskStatusFromQuote_Test {
    public static Set<Id> sqIds = new Set<Id>();
    
     /*static testmethod void testCreateQuoteWithPartnerUser() {       
         List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        List<Id> accountTeamMemberIds = new List<Id>();
        //List<User> lstATMUsers = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers3 = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers2 = Pricing_Test_Utility.createAdminUser();
        List<User> lstATMUsers4 = Pricing_Test_Utility.createAEUser();
        Map<Id,Set<Id>> accIdToUserIdMap = new Map<Id,Set<Id>>();
        Set<ID> assignedIds=new Set<ID>();
        //Id userId = lstATMUsers[0].id;
        Id userId1 = lstATMUsers3[0].id;
        Boolean ischeck = false;
        Test.startTest();
        system.runAs(lstATMUsers2[0]){
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact primaryContactList = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            //List<AccountTeamMember> lstAccountTeamMember = Pricing_Test_Utility.createAccountTeamMember(acc.Id, userId);
            accountTeamMembers = Pricing_Test_Utility.createAccountTeamMember(acc.Id, userId1);
            Pricing_Test_Utility.createTemplate(lstATMUsers2[0].id);
            TriggerHandler.clearAllBypasses();
                   
        Test.stopTest();        
    }
    }*/
    
       static testmethod void testupdateAtRiskForTenderQuotes(){
        List<User> lstATMUsers3 = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers2 = Pricing_Test_Utility.createAdminUser();
        List<User> lstATMUsers4 = Pricing_Test_Utility.createAEUser();
        Test.startTest();
        system.runAs(lstATMUsers2[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact primaryContactList = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            TriggerHandler.bypass('QuoteTriggerHandler');
            TriggerHandler.bypass('QuoteLineTriggerHandler');
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, primaryContactList.Id,1, lstATMUsers3[0].Email, lstATMUsers4[0].Email);
            List<SBQQ__QuoteLine__c> quoteLineList = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
            List<SBQQ__QuoteLine__c> updatequolist=new List<SBQQ__QuoteLine__c>(); 
            List<SBQQ__Quote__c> updatequotelist=new List<SBQQ__Quote__c>(); 
            //List<SBQQ__QuoteLine__c> quoteLineList2 = Pricing_Test_Utility.createQuoteLines(lstquote[1].Id, 1);
            TriggerHandler.clearAllBypasses();
            
            for(SBQQ__QuoteLine__c quo:[Select Id from SBQQ__QuoteLine__c])
            {
                quo.Pricing_Status_Nm__c =  system.label.Quote_Pricing_Status;
                updatequolist.add(quo);
            }
            if(updatequolist.size()>0){
                TriggerHandler.bypass('QuoteLineTriggerHandler');
                update updatequolist;
            }
            sqIds.add(lstquote[0].Id);
            
            for(SBQQ__Quote__c quo:[Select Id from SBQQ__Quote__c ]){                
                quo.Pricing_Quote_Program_Nm__c =  system.label.Pricing_Tender_Quote_Program;         
                //quo.Pricing_Quote_Program_Nm__c = system.label.Pricing_PSG_Quote_Program;
                quo.SBQQ__Status__c = system.label.Quote_Pricing_Status;
                updatequotelist.add(quo);
            }
            
            if(updatequolist.size()>0){
                TriggerHandler.bypass('QuoteTriggerHandler');
                update updatequotelist;
            }
            
            /*Opportunity testOpp=[select id from Opportunity];
            List<Product2> testProducts = Core_Test_Utility.createProduct(3);
            insert testProducts;
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
            insert testPBEs;
            OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[2].Id,
                                                  Description='Test 13', UnitPrice=13, Quantity=13,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_At_Risk__c=true,Core_Risk_Reason1__c='Competition',Core_Risk_Detail__c = 'test',Core_Risk_Priority__c='3 Medium – Unusual Risk, Action Required',Core_Risk_Category__c='Support Requested',
                                                  Core_At_Risk_Status__c='In-Progress');
            insert testOppLineItem; */            
            Core_UpdateOptyRiskStatusFromQuote.updateAtRiskForTenderQuotes(sqIds);
            //Core_UpdateOptyRiskStatusFromQuote.updateAtRiskForPSGQuotes(sqIds);
            
        }
        Test.stopTest();
        
    }
    
    
    
        static testmethod void testupdateAtRiskForPSGQuotesTest(){
        List<User> lstATMUsers3 = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers2 = Pricing_Test_Utility.createAdminUser();
        List<User> lstATMUsers4 = Pricing_Test_Utility.createAEUser();
        Test.startTest();
        system.runAs(lstATMUsers2[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact primaryContactList = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            TriggerHandler.bypass('QuoteTriggerHandler');
            TriggerHandler.bypass('QuoteLineTriggerHandler');
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, primaryContactList.Id,1, lstATMUsers3[0].Email, lstATMUsers4[0].Email);
            List<SBQQ__QuoteLine__c> quoteLineList = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 1);
            List<SBQQ__QuoteLine__c> updatequolist=new List<SBQQ__QuoteLine__c>(); 
            List<SBQQ__Quote__c> updatequotelist=new List<SBQQ__Quote__c>(); 
            //List<SBQQ__QuoteLine__c> quoteLineList2 = Pricing_Test_Utility.createQuoteLines(lstquote[1].Id, 1);
            TriggerHandler.clearAllBypasses();
            
            for(SBQQ__QuoteLine__c quo:[Select Id from SBQQ__QuoteLine__c]){
                //quo.Pricing_Status_Nm__c=system.label.Quote_Pricing_Status;
                quo.Pricing_Status_Nm__c=system.label.Pricing_Status_Won;
                updatequolist.add(quo);
            }
                        
            if(updatequolist.size()>0){
                TriggerHandler.bypass('QuoteLineTriggerHandler');
                update updatequolist;
            }
            sqIds.add(lstquote[0].Id);
            
            
            for(SBQQ__Quote__c quo:[Select Id from SBQQ__Quote__c ]){
              //  quo.Pricing_Quote_Program_Nm__c =  system.label.Pricing_Tender_Quote_Program;
                quo.Pricing_Quote_Program_Nm__c = system.label.Pricing_PSG_Quote_Program;
                quo.SBQQ__Status__c = system.label.Quote_Pricing_Status;
                updatequotelist.add(quo);
            }
                       
            if(updatequolist.size()>0){
                TriggerHandler.bypass('QuoteTriggerHandler');
                update updatequotelist;
            }
            //Core_UpdateOptyRiskStatusFromQuote.updateAtRiskForTenderQuotes(sqIds);
            Core_UpdateOptyRiskStatusFromQuote.updateAtRiskForPSGQuotes(sqIds);
            
        }
        
    }
    
}