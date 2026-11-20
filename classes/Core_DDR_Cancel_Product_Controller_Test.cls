@isTest(seeAllData = false)
public class Core_DDR_Cancel_Product_Controller_Test
{
    
    @IsTest
    public static void testAuraMethod(){
       
        
        List<Product2> lstProduct = new List<Product2>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = true;
        product1.IsActive = true;
        lstProduct.add(product1);
        
        Product2 product12 = new Product2();
        product12.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product12.IsActive = TRUE;
        product12.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product12.Core_Sales_Visible_Flag__c = TRUE;
        product12.Core_Partner_Visible_Ind__c  = TRUE;
        product12.Core_Design_Registration_Eligible_Ind__c = true;
        //product12.Core_Design_Registration_Eligible_Ind__c = false;
        lstProduct.add(product12);
        
        insert lstProduct;
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
         Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.recordTypeId = accountRecordTypeIntel;
        testAcct.Core_Sales_Groups__c = 'EMEA Sales Group';
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.Today().addDays(24);
        testOpp.StageName = 'Qualify';
        testOpp.Name = 'Test1';
           
        testOpp.AccountId = testAcct.Id;
        insert testOpp;
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        OpportunityLineItem testOppLineItem1;
        testOppLineItem1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_Loss_Cancel_Details__c = 'Test Loss',
                                                  Core_Loss_Cancel_Reason__c='Cancelled - Design Reg. Product Swap', Core_Status__c='Production Win' /*Core_Design_Registration_Product_Id__c = DRproducts.Id*/);
        insert testOppLineItem1;
        
         Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            
            DRproducts.Core_Design_Registration_Id__c = DDRLst[0].id;
            DRproducts.Core_Product_Id__c = lstProduct[0].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts.Core_Opportunity_Product_Id__c = testOppLineItem1.Id;
        	DRproducts.Core_Comment_Txt__c ='Test comment';

        insert DRproducts;
        //DRproducts.Core_External_Id__c ='ABCDFEGHIJKLMONPRSTUVXWZabcdefghihlmnopqrstuvwxyz16874';
        //    update DRproducts;
        
        Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
            
            DRproducts1.Core_Design_Registration_Id__c = DDRLst[0].id;
            DRproducts1.Core_Product_Id__c = lstProduct[1].id;
            DRproducts1.Core_Target_Resale_Amt__c = 20;
            DRproducts1.Core_Full_Year_Qty__c = 3;
            DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
        DRproducts1.Core_Comment_Txt__c ='Test comment';
        insert DRproducts1;
        lstProduct[1].Core_Design_Registration_Eligible_Ind__c = false;
        //lstProduct.add(product12);
        
        update lstProduct;
        
        
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_Loss_Cancel_Details__c = 'Test Loss',
                                                  Core_Loss_Cancel_Reason__c='Cancelled - Design Reg. Product Swap', Core_Status__c='Production Win', Core_Design_Registration_Product_Id__c = DRproducts.Id);
        insert testOppLineItem;
        Test.startTest();
        String result = Core_DDR_Cancel_Product_Controller.cancelProduct(DRproducts.Id);
        String result1 = Core_DDR_Cancel_Product_Controller.cancelProduct(DRproducts1.Id);
		
        System.assertNotEquals(null,result);
        Core_DDR_Cancel_Product_Controller.updateOppLineItem(DRproducts.Id);
        Core_DDR_Cancel_Product_Controller.updatingComments(DRproducts.Id,'cancel');
        Core_DDR_Cancel_Product_Controller.updatingComments(DRproducts1.Id,'cancel');
		
        Core_DDR_Cancel_Product_Controller.callAlertFunc = 'test';
        
        Test.stopTest();
    }

    @IsTest
    public static void testAuraMethod2(){
        List<Product2> lstProduct = new List<Product2>();
        
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = true;
        product1.Core_Design_Registration_Eligible_Ind__c = true;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        product1.IsActive = true;
        lstProduct.add(product1);
        
        Product2 product12 = new Product2();
        product12.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product12.IsActive = TRUE;
        product12.Core_Design_Registration_Eligible_Ind__c = true;
        product12.Core_Sales_Visible_Flag__c = TRUE;
        product12.Core_Partner_Visible_Ind__c  = TRUE;
        product12.IsActive = true;
        lstProduct.add(product12);
        
        Product2 product3 = new Product2();
        product3.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product3.IsActive = TRUE;
        product3.Core_Design_Registration_Eligible_Ind__c = true;
        product3.Core_Sales_Visible_Flag__c = TRUE;
        product3.Core_Partner_Visible_Ind__c  = TRUE;
       product12.Core_Design_Registration_Eligible_Ind__c = true;
        lstProduct.add(product3);
        
        insert lstProduct;
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.recordTypeId = accountRecordTypeIntel;
        testAcct.Core_Sales_Groups__c = 'Americas US Sales Group';
        testAcct.Industry = 'Telecommunications';
        testAcct.Core_Sub_Industry__c = 'Diversified Telecommunications Services';
        insert testAcct;
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.Today().addDays(24);
        testOpp.StageName = 'Qualify';
        testOpp.Name = 'Test1';
           
        testOpp.AccountId = testAcct.Id;
        insert testOpp;
        
        OpportunityLineItem testOppLineItem1;
        testOppLineItem1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_Loss_Cancel_Details__c = 'Test Loss',
                                                  Core_Loss_Cancel_Reason__c='Cancelled - Design Reg. Product Swap', Core_Status__c='Production Win' /*Core_Design_Registration_Product_Id__c = DRproducts.Id*/);
        insert testOppLineItem1;
        
         list<Core_Design_Registration_Product__c> DRproductslst = new list<Core_Design_Registration_Product__c>();
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            DRproducts.Core_Design_Registration_Id__c = DDRLst[0].id;
            DRproducts.Core_Product_Id__c = lstProduct[0].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Approved';
        	DRproducts.Core_Comment_Txt__c = 'abcd';
        	DRproductslst.add(DRproducts);
            Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
       		DRproducts1.Core_Design_Registration_Id__c = DDRLst[0].id;
            DRproducts1.Core_Product_Id__c = lstProduct[2].id;
            DRproducts1.Core_Target_Resale_Amt__c = 20;
            DRproducts1.Core_Full_Year_Qty__c = 3;
            DRproducts1.Core_Design_Product_Status_Nm__c = 'Approved';
       		DRproductslst.add(DRproducts1);
        Core_Design_Registration_Product__c DRproducts2 = new Core_Design_Registration_Product__c();
       		DRproducts2.Core_Design_Registration_Id__c = DDRLst[0].id;
            DRproducts2.Core_Product_Id__c = lstProduct[2].id;
            DRproducts2.Core_Target_Resale_Amt__c = 20;
            DRproducts2.Core_Full_Year_Qty__c = 3;
            DRproducts2.Core_Design_Product_Status_Nm__c = 'Approved';
        	DRproducts2.Core_Opportunity_Product_Id__c = testOppLineItem1.Id;
       		DRproductslst.add(DRproducts2);
        
        	insert DRproductslst;
        //insert DRproducts;
        //DRproducts.Core_External_Id__c ='ABCDFEGHIJKLMONPRSTUVXWZabcdefghihlmnopqrstuvwxyz16874';
        //    update DRproducts;
        
         
        
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11, Core_Loss_Cancel_Details__c = 'Test Loss',
                                                  Core_Loss_Cancel_Reason__c='Cancelled - Design Reg. Product Swap', Core_Status__c='Production Win', Core_Design_Registration_Product_Id__c = DRproductslst[0].Id);
        insert testOppLineItem;
        Test.startTest();
        String result = Core_DDR_Cancel_Product_Controller.cancelProduct(DRproductslst[0].Id);
        String result1 = Core_DDR_Cancel_Product_Controller.cancelProduct(DRproductslst[1].Id);
        String result2 = Core_DDR_Cancel_Product_Controller.cancelProduct(DRproductslst[2].Id);
        //System.assertNotEquals(null,result);
        Core_DDR_Cancel_Product_Controller.updateOppLineItem(DRproductslst[0].Id);
        Core_DDR_Cancel_Product_Controller.updatingComments(DRproductslst[0].Id,'cancel');
        Test.stopTest();
        //System.assertNotEquals(null,result);
    }
}