/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class core_updateOpptyLineItemLWC_test {
    @isTest
    public static void updateOpptyLineItemRecord_test(){
        System.runAs(Core_Test_Utility.systemAdminUser) {
            Account testAcct = Core_Test_Utility.createAccount(1)[0];
            testAcct.Core_Sales_Groups__c =Core_CRM_Utility.getSalesGroupAPI(); 
            testAcct.Industry = 'Telecommunications'; 
            testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
            insert testAcct;
            
            Opportunity testOpp = Core_Test_Utility.createOpportunity(1)[0];
            testOpp.AccountId = testAcct.Id;  
            testOpp.Core_Opportunity_Type__c = 'Design: Original';
            testOpp.StageName ='Qualify';
            insert testOpp;
            
            List<Product2> testProd = Core_Test_Utility.createProduct(1);
            insert testProd[0];
            
            List<PricebookEntry> testPBE = Core_Test_Utility.createPriceBookEntry(1, testProd, Test.getStandardPricebookId());
            insert testPBE;
            
            List<OpportunityLineItem> lstOP= new List<OpportunityLineItem>();
            lstOP = Core_Test_Utility.createOpportunityLineItems(1, testPBE, testOpp);
            OpportunityLineItem opItem = lstOP.get(0);
            opItem.Core_Write_In_Product_Name__c = 'Test WIP name';
            opItem.Core_Group__c = 'PEG Adm';
            opItem.Core_Status__c = 'Pending';
            opItem.Quantity=10; 
            opItem.UnitPrice = 100.0;
            opItem.Core_Loss_Cancel_Reason__c = 'Price';//TWC3123-6699 changed from 'Lost - Price';
            opItem.Core_Loss_Cancel_Details__c = 'Test Lost';
            //opItem.Core_Advanced_Technology__c = 'INTEL® VPRO™ TECHNOLOGY';
            opItem.Core_Competitor__c = 'Alibaba';
            opItem.Core_Competitor_Product__c = 'Picasso';
            opItem.Core_OtherCompetitor_Product_Txt__c = 'Processor';
            insert opItem;
            core_updateOpptyLineItemLWC.getRecords(opItem.Id);
            core_updateOpptyLineItemLWC.getLoggedInUserType();
            core_updateOpptyLineItemLWC.updateOpptyLineItemRecord(opItem.Id, opItem.Core_Write_In_Product_Name__c, opItem.Core_Group__c, opItem.Core_Status__c, opItem.Quantity, opItem.Core_PW_Quantity__c, opItem.UnitPrice, opItem.Core_PW_Sales_Price__c, opItem.Core_Loss_Cancel_Reason__c, opItem.Core_Loss_Cancel_Details__c, opItem.Core_Vendor__c,/* opItem.Core_Advanced_Technology__c,*/ opItem.Core_Competitor__c, opItem.Core_Competitor_Product__c, opItem.Core_OtherCompetitor_Product_Txt__c, opItem.Core_BU_Mapping_record__c, false, false );
        }
        
    }
}