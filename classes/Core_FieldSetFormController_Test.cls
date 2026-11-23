@isTest
public class Core_FieldSetFormController_Test {
    @isTest
    public static void getFormFieldsAndSectionLabelTest(){
        Account testAcct_BU = Core_Test_Utility.createAccount(1)[0];
        testAcct_BU.Core_Sales_Groups__c ='Americas US Sales Group'; 
        testAcct_BU.Industry = 'Telecommunications'; 
        testAcct_BU.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct_BU;
        
          
        Opportunity testOpp = Core_Test_Utility.createOpportunity(1)[0];
        testOpp.AccountId = testAcct_BU.Id;  
        testOpp.Core_Opportunity_Type__c = 'Design: Original';
        testOpp.StageName ='Qualify';
        insert testOpp;
        
        List<Product2> testPR = Core_Test_Utility.createProduct(1);
        insert testPR[0];
        
        List<PricebookEntry> testPBE = Core_Test_Utility.createPriceBookEntry(1, testPR, Test.getStandardPricebookId());
        insert testPBE;
        
        List<OpportunityLineItem> lstOP= new List<OpportunityLineItem>();
        lstOP = Core_Test_Utility.createOpportunityLineItems(1, testPBE, testOpp);
        OpportunityLineItem opItem = lstOP.get(0);
        opItem.Core_Status__c = 'Pending';
        opItem.Core_Approved_Commissionable__c=Null; 
        opItem.Core_Claim_Date__c = System.today();
        insert opItem;
        
        Core_FieldSetFormController.getFormFieldsAndSectionLabel(opItem.Id);
    }

}