@isTest
public class Core_DDR_Design_Handler_Test{
    
    public static testmethod void DDRhappy(){
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        insert LstAcc;
        /*
            // Insert a test product.
            List<Product2> prod = new List<Product2>{
            new Product2(Name = 'Laptop X2000', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2001', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2002', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2003', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2004', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true)
            };
            insert prod;
            
            // Get standard price book ID.
            Id pricebookId = Test.getStandardPricebookId();
            
            // Insert a price book entry for the standard price book.
            // Standard price book entries require the standard price book ID we got earlier.
            PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod[0].Id,
            UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            // Create a custom price book
            Pricebook2 customPB = new Pricebook2(Name='Partner Price Book', isActive=true);
            insert customPB;
            
            // Insert a price book entry with a custom price.
            PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod[0].Id,
            UnitPrice = 12000, IsActive = true);
            insert customPrice;
        */
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();  
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.name = 'Standard Price Book';
        pb1.isActive = TRUE;
        
        lstPriceBook.add(pb1);
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Partner Price Book';
        pb2.isActive = TRUE;
        
        lstPriceBook.add(pb2); 
        
        insert lstPriceBook;  
        
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
        
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        
        /*******Partner price book entry update scenario ********/
        PricebookEntry PriceBookEntry1 = new PricebookEntry();
        PriceBookEntry1.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry1.Product2Id = lstProduct[0].id;
        PriceBookEntry1.IsActive = true;
        PriceBookEntry1.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry1);
        
        PricebookEntry PriceBookEntry2 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry2.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry2.Product2Id = lstProduct[0].id;
        PriceBookEntry2.IsActive = true;
        PriceBookEntry2.UnitPrice = 100;
        PriceBookEntry2.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry2);
        
        PricebookEntry PriceBookEntry3 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry3.Pricebook2Id =  iPB.ID;
            }
        }
        PriceBookEntry3.Product2Id = lstProduct[0].id;
        PriceBookEntry3.IsActive = true;
        PriceBookEntry3.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry3);      
        
        /*******Partner price book entry update scenario - Close ********/
        
        /*******Partner price book entry create scenario ********/
        
        PricebookEntry PriceBookEntry4 = new PricebookEntry();
        PriceBookEntry4.Pricebook2Id =  Test.getStandardPricebookId();
        PriceBookEntry4.Product2Id = lstProduct[1].id;
        PriceBookEntry4.IsActive = true;
        PriceBookEntry4.UnitPrice = 100;
        
        lstPriceBookEntry.add(PriceBookEntry4);         
        
        PricebookEntry PriceBookEntry5 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Standard Price Book')
            {
                PriceBookEntry5.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry5.Product2Id = lstProduct[1].id;
        PriceBookEntry5.IsActive = true;
        PriceBookEntry5.UnitPrice = 100;
        PriceBookEntry5.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry5);
        
        PricebookEntry PriceBookEntry6 = new PricebookEntry();
        for(Pricebook2 iPB : lstPriceBook)
        {
            if(iPB.Name == 'Partner Price Book')
            {
                PriceBookEntry6.Pricebook2Id =  iPB.Id;
            }
        }
        PriceBookEntry6.Product2Id = lstProduct[1].id;
        PriceBookEntry6.IsActive = true;
        PriceBookEntry6.UnitPrice = 100;
        PriceBookEntry6.UseStandardPrice = true;    
        
        lstPriceBookEntry.add(PriceBookEntry6);
        
        insert lstPriceBookEntry;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(2, LstAcc);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(2, TestDDRlst, lstProduct);
        insert TestDDRProd;
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update TestDDRProd;
        
        List <Account> UpdateAccLst = Core_Test_Utility.Core_Account(5);
        insert UpdateAccLst;
        
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Product_Segment_Nm__c = 'Embedded';
            upDDR.Core_Product_Application_Nm__c = 'Energy - Other';
            upDDR.Core_Partner_Account_Id__c = UpdateAccLst[0].id;
            upDDR.Core_End_Customer_Account_Id__c = LstAcc[1].id;
        }        
        update TestDDRlst;
        
    }
    
    public static testmethod void DRtest1() {
        
        Id DistiProid = [select id, name from profile where name='Partner'].id;
        Id IsrProid = [select id, name from profile where name='Sales Rep-BB'].id;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        List<contact> LstCon = Core_Test_Utility.createContacts(5);
        
        List<contact> LstConInsert = new List<contact>();
        for(contact con: LstCon){
            con.accountId = LstAcc[0].id;
            LstConInsert.add(con);
        }
        insert LstConInsert;
        
        User DistiUser = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = DistiProid, IsActive =true,
        ContactId = LstConInsert[0].Id,
        timezonesidkey='America/Los_Angeles', username='tester@Intelnoemail.com');
        
        insert DistiUser;
        
        User IsrUser = new User(alias = 'test123', email='test1234@itp-intel.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = IsrProid, IsActive =true,
        timezonesidkey='America/Los_Angeles', username='tester@itp-intel.com');
        
        insert IsrUser;
        
        // Insert a test product.
        List<Product2> prod = new List<Product2>{
            new Product2(Name = 'Laptop X2000', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2001', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2002', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2003', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
            new Product2(Name = 'Laptop X2004', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true)
        };
        insert prod;
        
        // Get standard price book ID.
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod[0].Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Partner Price Book', isActive=true);
        insert customPB;
        
        // Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
        Pricebook2Id = customPB.Id, Product2Id = prod[0].Id,
        UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        Test.startTest();
        system.runAs(DistiUser) {        
            List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
            insert TestDDRlst;
            
            List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, prod);
            insert TestDDRProd;
        }
        
        List<Core_Design_Registration_Product__c> DRP_Update = [select id, Core_Design_Product_Status_Nm__c from Core_Design_Registration_Product__c limit 5000];
        
        for(Core_Design_Registration_Product__c pupdate: DRP_Update){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate = [select id from Core_Design_Registration__c limit 5000];
        List <Account> UpdateAccLst = Core_Test_Utility.Core_Account(5);
        insert UpdateAccLst;
        
        for(Core_Design_Registration__c upDDR: TestDDRupdate){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Product_Segment_Nm__c = 'Embedded';
            upDDR.Core_Product_Application_Nm__c = 'Energy - Other';
            upDDR.Core_End_Customer_Account_Id__c = UpdateAccLst[0].id;
        }
        
        update TestDDRupdate;
        
        //Test.stopTest();
        
        system.runAs(DistiUser) {
            
            // Insert a test product.
            List<Product2> prod2 = new List<Product2>{
                new Product2(Name = 'Laptop X2000', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
                new Product2(Name = 'Laptop X2001', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
                new Product2(Name = 'Laptop X2002', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
                new Product2(Name = 'Laptop X2003', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true),
                new Product2(Name = 'Laptop X2004', Core_Design_Registration_Eligible_Ind__c = true, IsActive = true, Family = 'Hardware', Core_Sales_Visible_Flag__c = true)
            };
            insert prod2;
            
            // Get standard price book ID.
            Id pricebookId2 = Test.getStandardPricebookId();
            
            // Insert a price book entry for the standard price book.
            // Standard price book entries require the standard price book ID we got earlier.
            PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId2, Product2Id = prod2[0].Id,
            UnitPrice = 10000, IsActive = true);
            insert standardPrice2;
            
            // Insert a price book entry with a custom price.
            PricebookEntry customPrice2 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod2[0].Id,
            UnitPrice = 12000, IsActive = true);
            insert customPrice2;
            
            List<Core_Design_Registration__c> TestDDRlst = [select id from Core_Design_Registration__c limit 5000];
            List<Core_Design_Registration_Product__c> TestDDRProd2 = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, prod2);
            insert TestDDRProd2;
        }
        List<Core_Design_Registration_Product__c> DRP_Update_re = [select id, Core_Design_Product_Status_Nm__c from Core_Design_Registration_Product__c where Core_Design_Product_Status_Nm__c = 'Pending' limit 5000];
        
        for(Core_Design_Registration_Product__c pupdate: DRP_Update_re){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRP_Update_re;
        
        List<Core_Design_Registration__c> TestDDRupdate_re = [select id, Core_End_Customer_Account_Id__c from Core_Design_Registration__c where Core_Design_Registration_Status_Nm__c = 'Re-Submitted' limit 5000];
        id accid = TestDDRupdate_re[0].Core_End_Customer_Account_Id__c;
        
        for(Core_Design_Registration__c upDDR: TestDDRupdate_re){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
        }
        update TestDDRupdate_re;
        
        Test.stopTest();
    }
    
    public static testmethod void DDR_Handler_Export() {
        Test.startTest();
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
        insert TestDDRlst;
        
        List <Account> UpdateAccLst = Core_Test_Utility.Core_Account(5);
        for(account Acc: UpdateAccLst){
            acc.Core_Export_Compliance_Block__c = true;
        }
        insert UpdateAccLst;
        
        for(Core_Design_Registration__c DDR_hand: TestDDRlst){
            DDR_hand.Core_End_Customer_Account_Id__c = UpdateAccLst[0].id;
        }
        update TestDDRlst;
        
        for(Core_Design_Registration__c DDR_hand: TestDDRlst){
            DDR_hand.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        }
        update TestDDRlst;
        Test.stopTest();
        }
}