@isTest
public class PSG_CreateQuoteController_Test {
    
    @TestSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();       
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        System.runAs(lstUsers2[0]){
            Test.startTest();
            PriceBook2 pb = PSG_Test_Utility.createPriceBook('abcd');
            List<Product2> pdt = PSG_Test_Utility.createProduct(1);
            PSG_Test_Utility.createProductDetails();
            Account acc = PSG_Test_Utility.createDirectAccount();
            Account acc1= PSG_Test_Utility.createAccount();
            acc1.Core_Direct_Pricing_Parent_Id__c=acc.id;
            acc1.Core_Direct_Legal_Parent_Id__c=acc.id;
            update acc1;
            Test.stopTest();
            List<PriceBookEntry> pbe = [Select Id from PriceBookEntry limit 1];
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Opportunity opportunityRecord =new Opportunity();
            opportunityRecord.Name='TestOpty';
            opportunityRecord.accountId = acc1.Id;
            opportunityRecord.CloseDate= system.today();
            opportunityRecord.Core_First_Customer_Ship_Date__c=date.parse('12/01/2020');
            opportunityRecord.Core_Production_End_Date__c=date.parse('12/16/2020');
            opportunityRecord.Core_Volume__c=90;
            opportunityRecord.Core_Product_Segment__c='Client Computing';
            opportunityRecord.Core_Product_Application__c='';
            opportunityRecord.Core_Technical_Owner__c = userInfo.getUserId();
            
            opportunityRecord.StageName='Qualify';
            opportunityRecord.Core_Consumption_Market__c='Agriculture';
            opportunityRecord.Core_Military_Aerospace_Govmt_End_Use__c='No';
            insert opportunityRecord;
            
            Core_Design_Registration__c designRegistration =new Core_Design_Registration__c();
            
            designRegistration.Core_Opportunity_Id__c=opportunityRecord.id;
            
            designRegistration.Core_Product_Group_Nm__c='FPGA/Power';
            designRegistration.Core_Design_Registration_Nm__c='testDesignres';
            designRegistration.Core_Design_Registration_Dsc__c='desing res decription';
            designRegistration.Core_Opportunity_Volume_Cnt__c=20;
            designRegistration.Core_Partner_FAE_Nm__c='Me';
            designRegistration.Core_End_Customer_Nm__c='testNameEndcust';
            designRegistration.Core_End_Customer_Street_Addr_Line1_Txt__c='bakerstreet';
            designRegistration.Core_End_Customer_City_Nm__c='Texas';
            designRegistration.Core_End_Customer_Country_Subdivision_Nm__c='Bihar';
            designRegistration.Core_End_Customer_Postal_Cd__c='78100006';
            
            designRegistration.Core_End_Customer_Country_Nm__c='USA';
            designRegistration.Core_End_Customer_Account_Id__c=acc1.id;
            
            designRegistration.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='No';
            
            designRegistration.Core_Product_Segment_Nm__c='Client Computing';
            designRegistration.Core_Product_Application_Nm__c='Business Desktop';
            designRegistration.Core_Opportunity_Decision_Dt__c=system.today().addYears(1);
            designRegistration.Core_First_Customer_Ship_Dt__c=System.today().addYears(2);
            designRegistration.Core_Production_End_Dt__c=System.today().addYears(3);
            designRegistration.Core_Vertical_Market_Nm__c='Agriculture';
            designRegistration.Core_Intel_Platform_Nm__c='Agilex';
            designRegistration.Core_Submission_Type__c='M2M'; 
            insert designRegistration;
            List<Product2> prods=new List<Product2>();
            Product2 product = new Product2(Name='TestProduct',
                                            Core_Product_Org__c = 'Sales',
                                            Core_Product_Type__c = 'Processors',
                                            Core_Design_Registration_Eligible_Ind__c = true,
                                            Core_Sales_Visible_Flag__c = true,
                                            Core_Hierarchy_ID__c = '43',
                                            Core_Group_Code_Short_Name__c = 'DCG',
                                            Core_Item_Quotable_Ind__c = true,
                                            Core_Item_Orderable_Ind__c = true,
                                            IsActive = true);
            prods.add(product);
            Product2 product1 = new Product2(Name='TestProduct1',
                                             Core_Product_Org__c = 'Sales',
                                             Core_Product_Type__c = 'Processors',
                                             Core_Design_Registration_Eligible_Ind__c = true,
                                             Core_Sales_Visible_Flag__c = false,
                                             Core_Hierarchy_ID__c = '43',
                                             Core_Group_Code_Short_Name__c = 'DCG',
                                             Core_Item_Quotable_Ind__c = false,
                                             Core_Item_Orderable_Ind__c = false,
                                             IsActive = false);
            prods.add(product1);
            insert prods;
            
            Core_Design_Registration_Product__c designRegistrationProduct=new Core_Design_Registration_Product__c();
            designRegistrationProduct.Core_Target_Resale_Amt__c=200;
            designRegistrationProduct.Core_Product_Id__c=product.id;
            designRegistrationProduct.Core_Design_Registration_Id__c=designRegistration.id;
            designRegistrationProduct.Core_Full_Year_Qty__c=10;
            
            insert designRegistrationProduct;
            List<OpportunityLineItem> opportunityProduct = new List<OpportunityLineItem>();
            OpportunityLineItem optypdt =new OpportunityLineItem();
            optypdt.product2id = prods[0].Id;
            optypdt.OpportunityId = opportunityRecord.Id;
            optypdt.Core_Design_Registration_Product_Id__c = designRegistrationProduct.Id;
            optypdt.Quantity =10;
            optypdt.TotalPrice = 240;
            optypdt.Core_At_Risk_Status__c = 'In-Progress';
            optypdt.PricebookEntryId = pbe[0].Id;
            opportunityProduct.add(optypdt);
            
            OpportunityLineItem optypdt1 =new OpportunityLineItem();
            optypdt1.product2id = prods[1].Id;
            optypdt1.OpportunityId = opportunityRecord.Id;
            optypdt1.Core_Design_Registration_Product_Id__c = null;
            optypdt1.Quantity = 10; 
            optypdt1.TotalPrice = 240;
            optypdt1.Core_At_Risk_Status__c = 'In-Progress';
            optypdt1.PricebookEntryId = pbe[0].Id;
            opportunityProduct.add(optypdt1);
            insert opportunityProduct;
        }
    }
    @isTest
    public static void testCreateQuote()
    {
        SBQQ.TriggerControl.disable();
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser(); 
        List<User> SOSUser = PSG_Test_Utility.createDistyUser();
        Account acc=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c = null LIMIT 1];
        Account acc1=[Select id,BillingCountry from Account where Core_Direct_Pricing_Parent_Id__c != null LIMIT 1];
        Opportunity opportunityRecord=[Select Id,Core_First_Customer_Ship_Date__c from Opportunity LIMIT 1];
        Core_Design_Registration_Product__c designRegistrationProduct=[Select Id from Core_Design_Registration_Product__c LIMIT 1];
        List<product2> prods=[Select id from Product2];
        System.runAs(lstUsers2[0]){
            System.assertEquals(acc.BillingCountry,'USA');            
            Contact con = PSG_Test_Utility.createContact(acc1.Id); 
            //List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc1.Id, con.Id, 2);
            SBQQ.TriggerControl.disable();
            //PSG_CreateQuoteController.createQuoteLine(opportunityRecord.Id, lstquote[0].id,opportunityRecord.Core_First_Customer_Ship_Date__c);
            //PSG_CreateQuoteController.createQuote(opportunityRecord.Id); 
            Test.startTest();
            System.runAs(SOSUser[0]){
                PSG_CreateQuoteController.getLoginUserType();
            }
            System.runAs(lstUsers2[0]){
                PSG_CreateQuoteController.createQuote(opportunityRecord.Id);     
            }
			Test.stopTest();
        }
    }
}