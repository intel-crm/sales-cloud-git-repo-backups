@isTest
public class Core_DDR_Utility_Test
{
    public static testmethod void DDR_UtilityTest()
    {
        List <Account> accountList = new List <Account> ();
        For(integer i = 0; i <3; i++) 
        {
            Account accountInstance = new Account();
            accountInstance.name = 'Test ' + i;
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
            accountList.add(accountInstance);
       } 
        insert accountList;
        
        List<Core_Design_Registration__c> TestDDRlst = new List<Core_Design_Registration__c>();
        TestDDRlst = Core_DDR_Utility.createDDR(3, accountList);
        
        insert TestDDRlst;
        system.debug('Test'+TestDDRlst);
        List<Product2> lstProduct = new List<Product2>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product1);
        
        //Product2 price book entry create scenario
        Product2 product2 = new Product2();
        product2.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product2.IsActive = TRUE;
        product2.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product2.Core_Sales_Visible_Flag__c = TRUE;
        product2.Core_Partner_Visible_Ind__c  = TRUE;
        lstProduct.add(product2);      
        
        insert lstProduct;
        system.debug('Test'+lstProduct);
        
        Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, lstProduct);
        Core_DDR_Utility.CreateProduct(5);
    }
}