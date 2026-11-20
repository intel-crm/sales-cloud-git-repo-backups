@isTest
public class Core_OpptyController_Test {
 
static List<Product2>  lstProducts;
     static Opportunity                        opportunityToClone;
     static Account                            accountForClone;
   
      static testMethod void opp_clone_controller_test_2()
    { 
                lstProducts = Core_Test_Utility.createProduct(20);
        for (Product2 prod : lstProducts) {
            prod.IsActive = true;
        }
        insert lstProducts;
//create your opportunity line item.  This assumes you already have an opportunity created, called opp
       List<PriceBookEntry> lstPriceBookEntry = Core_Test_Utility.createPriceBookEntry(20, lstProducts,Test.getStandardPricebookId() );
        
        insert lstPriceBookEntry;
         accountForClone = Core_Test_Utility.createAccount(1)[0];
        
        accountForClone.Core_Military_Aerospace_and_Government__c=true; 
       
        accountForClone.Core_Sales_Groups__c = 'Americas ELAR Sales Group';
        
     
        ID intelAccID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountForClone.RecordTypeId = intelAccID;
        insert accountForClone;
        opportunityToClone = Core_Test_Utility.createOpportunity(1)[0];
        opportunityToClone.Core_Opportunity_Type__c ='Design: Secondary';
        opportunityToClone.AccountId = accountForClone.Id;
        opportunityToClone.StageName = 'Qualify';
        //opportunityToClone.PriceBook2Id = lstPriceBook[0].Id;
        opportunityToClone.Core_Channel_Opportunity_Ind__c = true;
        insert opportunityToClone;
        List<OpportunityLineItem> lstOpportunityLineItem = Core_Test_Utility.createOpportunityLineItems(20, lstPriceBookEntry, opportunityToClone);
        insert lstOpportunityLineItem;
        test.startTest();
        list<opportunityLineItem> oli = new list<opportunityLineItem>();
        Core_OpptyController ctrl = new Core_OpptyController();
        List<OpportunityLineItem> litem1 = [select Product2.Name,Core_Status__c,Core_Claim_Date__c,Quantity,UnitPrice,TotalPrice from opportunityLineItem where Opportunity.id =: opportunityToClone.id];
		oli = ctrl.getopp();
        system.assertequals(litem1.size()>0,true);
	        test.stopTest();
    }
    

}