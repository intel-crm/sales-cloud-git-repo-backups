@isTest
public class PCC_ChangeRequestTest {
    @testSetup static void setData(){
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Product2> NewProducts = new List<Product2>();
            List<Account> aclist = new List<Account>();
            Account acct = new Account(Name = 'Test AccountCAS', BillingStreet = '123 Fake St CAS',
                                       BillingCity = 'SpringfieldCAS', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='Americas US Sales Group');
            acct.recordTypeId = accountRecordTypeIntel;
            aclist.add(acct);
            insert aclist;
            
            Product2 prod = new Product2();
            
            prod.name = 'Intel Atom® CE4275 Media Processor';
            prod.Core_Design_Registration_Eligible_Ind__c  = true;
            prod.Core_Sales_Visible_Flag__c = true;
            prod.isActive = true;
            prod.Core_Partner_Visible_Ind__c = true;
            prod.Core_Avail_for_New_Designs__c = true;
            NewProducts.add(prod);
            insert NewProducts;
            Product_Additional_Attribute__c testProductAttribute1 = new Product_Additional_Attribute__c(name ='New',Product__c=NewProducts[0].id);
            
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;       
            Opportunity oppForLoss = new Opportunity(Name = 'OppCAS', RecordTypeId = newOppRecTypeId,
                                                     AccountId = acct.Id, 
                                                     StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            // insert oppForLoss;
            insert oppForLoss;
      //  }
        
    }
    
    @isTest
    static void testGetProductsIds() {
        List<Product_Additional_Attribute__c> lst = [Select id from Product_Additional_Attribute__c];
        List<Id> prodIds = new List<Id>();
        for (Product_Additional_Attribute__c prod1: lst ){
            prodIds.add(prod1.id);
        }
        Map<Id, Id> productIds = PCC_ChangeRequest.getProductsIds(prodIds);
        Opportunity opp =[Select id from opportunity limit 1];
        String url1 ='hello';
        List<Map<String, String>> fieldMappings = new List<Map<String, String>>();
        fieldMappings= PCC_ChangeRequest.getRecords(opp.id,url1);
    }
    
    
    
}