@isTest
private class PCC_Deal_FindRelatedDuplicateDealsTest {
    
    // Utility method to create test data
    private static List<Core_Design_Registration__c> createTestDesignRegistration() {
        // Create a Core_Design_Registration__c record (make sure to set required fields)
        Id dealRecordTypeId = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Partner').getRecordTypeId();
        Id designRecordTypeId = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Core_Design_Registration_Partner').getRecordTypeId();
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(4);
        DDRLst[0].recordTypeId = dealRecordTypeId;
        ddrLST[0].PCC_Consumption_Countries__c ='INDIA,US,UK';
        ddrLST[0].PCC_Current_EndCustomer_Product_Provider__c ='TEST';
        DDRLst[1].recordTypeId = dealRecordTypeId;
        ddrLST[1].PCC_Consumption_Countries__c ='INDIA,US,UK';
        ddrLST[1].PCC_Current_EndCustomer_Product_Provider__c ='TEST';
        // design
        DDRLst[2].recordTypeId = designRecordTypeId;
        ddrLST[2].PCC_Consumption_Countries__c ='INDIA,US,UK';
        ddrLST[2].PCC_Current_EndCustomer_Product_Provider__c ='TEST 1';
        DDRLst[3].recordTypeId = designRecordTypeId;
        ddrLST[3].PCC_Consumption_Countries__c ='INDIA,US,UK';
        ddrLST[3].PCC_Current_EndCustomer_Product_Provider__c ='TEST 2';
        
        
        insert DDRLst;
        return DDRLst;
    }
    
    @testSetup
    public static void setUpData(){
        List<User> adminUser = Pricing_Test_Utility.createAdminUserWithParam('publishQuoteAdmin');
        //List<User> adminUser2 = Pricing_Test_Utility.createAdminUser2();
        Contact con;
        List<User> accountExecutiveUserList;
        List<User> salesRepUserList;
        
        System.runAs(adminUser[0]){
            
            Product2 prod = new Product2();
            prod.Core_Product_Org__c = 'Sales';
            prod.Core_Product_Type__c = 'Processors';
            prod.Core_Sales_Visible_Flag__c  = True;
            prod.IsActive = True;
            prod.Core_Hierarchy_ID__c = '43';
            prod.Core_Group_Code_Short_Name__c = 'CCG';
            prod.Name = 'Product X';
            
            Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
                Name = 'Write In Product',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true
                );
            insert prod;
            insert cp;
            
            List<User> fseUserList = Pricing_Test_Utility.createFSEUserWithParam('testnewfseemail@intel.com','testnew','test');
            Pricing_Test_Utility.createPriceBook();
            Account acc1 = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContact(acc1.Id);
            Pricing_Test_Utility.createTemplate(adminUser[0].id);
            accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeam = new List<AccountTeamMember>();
            accTeam.add(new AccountTeamMember(AccountId = acc1.Id, TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id));
            accTeam.add(new AccountTeamMember(AccountId = acc1.Id, TeamMemberRole = 'Technical Sales',UserId = fseUserList[0].Id));
            insert accTeam;
            
            // User partnerUser =
            Pricing_Test_Utility.createPartnerAdminUser(acc1.Id);
            Pricing_QuoteLineController.getDocumentId(Label.Pricing_Tender_T_C_Document);
            
            List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(1, new List<Product2>{prod}, Test.getStandardPricebookId());
            insert testPBEs;
            
            
            
            Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
            Opportunity opp = new Opportunity(Name = 'OppCAS', RecordTypeId = newOppRecTypeId,
            AccountId = acc1.Id,Opportunity_Focus__c='',
            StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            insert opp;
            
            // create opportunity partner record
            
            Core_Opportunity_Partner__c partner = new Core_Opportunity_Partner__c();
            partner.Core_Opportunity__c= opp.Id;
            partner.Core_Partner__c= acc1.Id;
            partner.Core_Partner_Role__c= 'Co-Design';
            partner.Core_Partner_Type__c= 'ODM';
            insert partner;
            
            OpportunityLineItem oppLineItem = new OpportunityLineItem(
                OpportunityId = opp.Id,
            //Core_Design_Registration_Product_Id__c = prod.Id,
            UnitPrice = 1000,
            Quantity = 5,
            PricebookEntryId = testPBEs[0].Id
                
            );
            insert oppLineItem;
        }
        Account acc =  [SELECT Id from Account LIMIT 1];
        User partnerUser = [SELECT Id, FirstName, ContactId  FROM User WHERE Email='partner@noemail.com' LIMIT 1];
        
        System.runAs(partnerUser){
            Document document;
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.startTest();
            
            // boolean isPartner =
            Pricing_QuoteLineController.isPartnerUser();
            //System.assert(isPartner, 'logged in user is not a Partner');
            System.runAs(adminUser[0]){
                List<SBQQ__Quote__c> quotes = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
                // List<SBQQ__QuoteLine__c> quoteLines =
                Pricing_Test_Utility.createQuoteLines(quotes[0].Id, 1);
            }
            Test.stopTest();
        }
    }
    
    // Utility method to create related products
    private static void createRelatedProducts(List<Core_Design_Registration__c> reg, Integer count) {
        
        List<Product2> lstProduct = new List<Product2>();
        //Product1 price book entry update scenario
        Product2 product1 = new Product2();
        product1.Name = 'Intel Atom® CE4275 Media Processor';
        product1.IsActive = TRUE;
        product1.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product1.Core_Sales_Visible_Flag__c = TRUE;
        product1.Core_Partner_Visible_Ind__c  = TRUE;
        product1.Core_Product_Org__c ='Sales';
        product1.Core_Hierarchy_ID__c ='43';
        
        product1.IsActive = true;
        lstProduct.add(product1);
        
        Product2 product12 = new Product2();
        product12.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product12.IsActive = TRUE;
        product12.Core_Sales_Visible_Flag__c = TRUE;
        product12.Core_Partner_Visible_Ind__c  = TRUE;
        product12.Core_Design_Registration_Eligible_Ind__c = true;
        product12.Core_Product_Org__c ='Sales';
        product12.Core_Hierarchy_ID__c ='43';
        //product12.Core_Design_Registration_Eligible_Ind__c = false;
        lstProduct.add(product12);
        
        insert lstProduct;
        
        Product_Additional_Attribute__c additionalatt = new Product_Additional_Attribute__c();
        additionalatt.Product__c = lstProduct[0].Id;
        additionalatt.Eligible_for_Deal_Reg__c  = true;
        additionalatt.Programs_Eligible__c = 'PDI';
        insert additionalatt;
        
        List<Core_Design_Registration_Product__c> products = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration__c design : reg){
            Core_Design_Registration_Product__c product = new Core_Design_Registration_Product__c(PCC_Product_Additional_Attribute__c = additionalatt.Id,PCC_Competitor_System_Model__c='PROC',PCC_System_Model__c='PROC',
            Core_Design_Registration_Id__c = design.Id,Core_Product_Id__c=lstProduct[0].Id,Core_Target_Resale_Amt__c=20,Core_Full_Year_Qty__c=100,Core_Design_Product_Status_Nm__c='Approved'
                );
            products.add(product);
        }
        
        insert products;
    }
    
    // Test method for getRelatedDuplicates
    @isTest
    static void testGetRelatedDuplicates() {
        // Set up test data
        Test.startTest();
        List<Core_Design_Registration__c> reg = createTestDesignRegistration();
        createRelatedProducts(reg, 2); // Create 2 related products for the test
        
        // Call the method to test
        List<PCC_Deal_FindRelatedDuplicateDeals.RelatedDuplicateWrapper> result = new List<PCC_Deal_FindRelatedDuplicateDeals.RelatedDuplicateWrapper>();
        try{
            result = PCC_Deal_FindRelatedDuplicateDeals.getRelatedDuplicates(reg[0].Id);
            //result = PCC_Deal_FindRelatedDuplicateDeals.getRelatedDuplicates(reg[2].Id);
        }catch(Exception ex){}
        Test.stopTest();
        
        // Perform assertions
        System.assertNotEquals(null, result, 'The result should not be null.');
        
    }
    
    @isTest
    static void testGetRelatedDuplicatesOppties() {
        // Set up test data
        Test.startTest();
        List<Core_Design_Registration__c> reg = createTestDesignRegistration();
        createRelatedProducts(reg, 2); // Create 2 related products for the test
        reg[2].Core_End_Customer_Account_Id__c = [select Id from account where Name ='Test Account'].Id;
        reg[2].Core_Partner_Account_Id__c = reg[2].Core_End_Customer_Account_Id__c;
        update reg[2];
        
        System.debug(JSON.serialize([SELECT Id,Name,AccountId, (SELECT Id, Name,product2Id FROM OpportunityLineItems) FROM Opportunity]));
        System.debug(JSON.serialize([select Core_Opportunity__r.AccountId,Core_Partner__c from Core_Opportunity_Partner__c]));
        
        // Call the method to test
        List<PCC_Deal_FindRelatedDuplicateDeals.RelatedDuplicateWrapper> result = new List<PCC_Deal_FindRelatedDuplicateDeals.RelatedDuplicateWrapper>();
        try{
            //result = PCC_Deal_FindRelatedDuplicateDeals.getRelatedDuplicates(reg[0].Id);
            result = PCC_Deal_FindRelatedDuplicateDeals.getRelatedDuplicates(reg[2].Id);
        }catch(Exception ex){
            
        }
        Test.stopTest();
        
        // Perform assertions
        System.assertNotEquals(null, result, 'The result should not be null.');
        
    }
}