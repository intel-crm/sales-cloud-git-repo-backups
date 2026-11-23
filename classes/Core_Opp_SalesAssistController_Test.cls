@isTest
public class Core_Opp_SalesAssistController_Test {
    static testMethod void getEOLDataTest() {
        List<account> LstAcc = Core_Test_Utility.createAccountIntel(1);
        insert LstAcc;
        List <Opportunity> oppList= Core_Test_Utility.createOpportunity(5);
        List <Opportunity> oppListItem=new List<Opportunity>();
        for(Opportunity opportunity: oppList){
            opportunity.Core_Sales_Assist_Pop_Up_Enabled__c=True;
            opportunity.accountid = LstAcc[0].id;
            oppListItem.add(opportunity);
        }
        insert oppListItem;
        List<Product2> testProducts_BU = Core_Test_Utility.createProduct(1);
        insert testProducts_BU[0];
        
        List<PricebookEntry> testPBEs_BU = Core_Test_Utility.createPriceBookEntry(1, testProducts_BU, Test.getStandardPricebookId());
        insert testPBEs_BU;
        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        oppItemList.add(new OpportunityLineItem(OpportunityId=oppListItem[0].Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending', Core_Is_Product_EOL__c=true));
        insert oppItemList;
        Test.startTest();
        //for(Opportunity opportunities: oppListItem) {
            Core_Opp_SalesAssistController.getEOLData(oppListItem[0].Id);
        //}     
        Test.stopTest();
        Assert.areEqual(true, oppListItem!= null);
    }
    
    static testMethod void getUserSessionDataTest() {
        List<account> LstAcc = Core_Test_Utility.createAccountIntel(1);
        insert LstAcc;
        List <Opportunity> oppList2= Core_Test_Utility.createOpportunity(5);
        List <Opportunity> oppListItem=new List<Opportunity>();
        for(Opportunity opportunity: oppList2) {
            opportunity.accountid = LstAcc[0].id;
            oppListItem.add(opportunity);
        }
        insert oppListItem;
        List<Product2> testProducts_BU = Core_Test_Utility.createProduct(1);
        insert testProducts_BU[0];
        
        List<PricebookEntry> testPBEs_BU = Core_Test_Utility.createPriceBookEntry(1, testProducts_BU, Test.getStandardPricebookId());
        insert testPBEs_BU;
        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
        oppItemList.add(new OpportunityLineItem(OpportunityId=oppList2[0].Id, PricebookEntryId=testPBEs_BU[0].Id,
                                                  Description='0001', UnitPrice=11, Quantity=11, 
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending', Core_Is_Product_EOL__c=true));
        insert oppItemList;
        Test.startTest();
        //for(Opportunity opportunities: oppList2) {
            Core_Opp_SalesAssistController.getUserSessionData(oppList2[0].Id);
        //}
        Test.stopTest();
        Assert.areEqual(true, oppList2!= null);
    }
       
    
    static testMethod void enableSalesAssistCheckBoxTest() {
        List<account> LstAcc = Core_Test_Utility.createAccountIntel(1);
        insert LstAcc;
        List <Opportunity> oppList1= Core_Test_Utility.createOpportunity(5);
        List <Opportunity> oppListItem=new List<Opportunity>();
        for(Opportunity opportunity: oppList1) {
            opportunity.accountid = LstAcc[0].id;
            oppListItem.add(opportunity);
        }
        insert oppListItem;
        Test.startTest();
        //for(Opportunity opportunities: oppList1) {
            Core_Opp_SalesAssistController.enableSalesAssistCheckBox(oppList1[0].Id);
        //}     
        Test.stopTest();
        Assert.areEqual(true, oppList1!= null);
    }
}