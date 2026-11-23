/****************************************************************************************************
Apex Class Name:  Core_OpportunityProductController_Test
Version     : 1.0 
Created Date: 21 OCT 2014
Function    : Test class for testing the "Core_OpportunityProduct" Page
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             06/10/2014              Original Version
*****************************************************************************************************/
@isTest
private class Core_OpportunityProductController_Test {
    
    // To store opporunity line instance
    private static OpportunityLineItem opportunityLineItemInstance {
        get;
        set;
    }
    
    // To store the list of Opportunities to be inserted
    private static List<Opportunity> lstOpportunity {
        get;
        set;
    }
    
    // To store the list of products to be inserted
    private static List<Product2> lstProducts {
        get;
        set;
    }



    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data
     * Return Type  : None
     * Parameter    : None
     */
    static void setupTestData() {
       
        // Creating the list of products and inserting it
        lstProducts = Core_Test_Utility.createProduct(20);

        Product2 productInstance = lstProducts.get(19);
        productInstance.Core_Division_Code__c = '11111;2222';
        productInstance.Core_Division_Code_Short_Name__c = 'Division 1;Division 2';
        productInstance.Core_Group_Code__c = '55555;6666';
        productInstance.Core_Group_Code_Short_Name__c = 'Group 1;Group 2';

        Product2 productInstance2 = lstProducts.get(18);
        productInstance2.Core_Division_Code__c = '';
        productInstance2.Core_Division_Code_Short_Name__c = '';
        productInstance2.Core_Group_Code__c = '';
        productInstance2.Core_Group_Code_Short_Name__c = '';

        Product2 productInstance3 = lstProducts.get(17);
        productInstance3.Core_Division_Code__c = '11111';
        productInstance3.Core_Division_Code_Short_Name__c = 'Division 1';
        productInstance3.Core_Group_Code__c = '55555';
        productInstance3.Core_Group_Code_Short_Name__c = 'Group 1';

        insert lstProducts;
        
        // Creating a list of Pricebookentry and inserting it
        List<PriceBookEntry> lstPriceBookEntry = Core_Test_Utility.createPriceBookEntry(20, lstProducts, Test.getStandardPricebookId());
        insert lstPriceBookEntry;
         list<Account> acclist = new list<Account>();
          list<Opportunity> lstOpportunity = new list<Opportunity>();
          Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
            Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
            Account acct1 = new Account(Name = 'Test Account territory1', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
            Account acct2 = new Account(Name = 'Test Account territory2', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                       BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
            
            acclist.add(acct);acclist.add(acct1);acclist.add(acct2);
            insert acclist;
        
          Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
            Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acclist[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            Opportunity opp1 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acclist[1].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            Opportunity opp2 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                   AccountId = acclist[2].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
            lstOpportunity.add(opp);lstOpportunity.add(opp1);lstOpportunity.add(opp2);
            insert lstOpportunity;
        
        // Creating a list of opportunity and inserting it
       // lstOpportunity = Core_Test_Utility.createOpportunity(2);
        //insert lstOpportunity;
        
        // Creating a list of Opportunity line item and inserting it
        List<OpportunityLineItem> lstOpportunityLineItem = Core_Test_Utility.createOpportunityLineItems(20, lstPriceBookEntry, lstOpportunity.get(0));

        OpportunityLineItem OpportunityLineItemInstanceNew = lstOpportunityLineItem.get(19);
        OpportunityLineItemInstanceNew.Core_Division_Code__c = '';
        OpportunityLineItemInstanceNew.Core_Division__c = '';
        OpportunityLineItemInstanceNew.Core_Group_Code__c = '';
        OpportunityLineItemInstanceNew.Core_Group__c = '';

        OpportunityLineItem OpportunityLineItemInstanceNew2 = lstOpportunityLineItem.get(17);
        OpportunityLineItemInstanceNew2.Core_Division_Code__c = '11111';
        OpportunityLineItemInstanceNew2.Core_Division__c = 'Division 1';
        OpportunityLineItemInstanceNew2.Core_Group_Code__c = '55555';
        OpportunityLineItemInstanceNew2.Core_Group__c = 'Group 1';

        insert lstOpportunityLineItem;

        opportunityLineItemInstance = lstOpportunityLineItem.get(0);

    }



    /*
     * Method name  : productEditControllerTest
     * Description  : Testmethod method for testing "Core_ProductEdit" Page and its controller
     * Return Type  : None
     * Parameter    : None
     */


    public static testMethod void productEditControllerTest() {
    
        // Setting up the enivronment for testing 
        setupTestData();

        Test.startTest();
        
			List<Opportunity> oppList = [select Id, Name, RecordTypeId, AccountId, StageName, CloseDate from Opportunity];
            // Setting up the page to be tested
            PageReference productEditPage = Page.Core_OpportunityProduct;
    
            Test.setCurrentPage(productEditPage);
    
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityLineItemInstance);
    
            ApexPages.currentPage().getParameters().put('oppId', oppList[0].id);
    
            // Creating the instance of controller to be tested      
            Core_OpportunityProductController pageController = new Core_OpportunityProductController(sc);
            
            // Updating the Opportunity Line item's divsion and group details
            Core_OpportunityProductController.opportunityProductWrapper wrapperInstance = pageController.lstOpportunityProductsWrapper.get(1);
            
            // Asserting that there are opportunity product records related to an opportunity
            System.assertEquals(pageController.bNoRecords, false);
            wrapperInstance.sSelectedDivision = 'Division 2';
            wrapperInstance.sSelectedGroup = 'Group 2';
    
            pageController.saveDetails();
            
            // Asserting the group and division details after updating the opportunity line item records
//[BM] 8/7            System.assertEquals(Integer.valueOf(wrapperInstance.opportunityLineItemInstance.Core_Division_Code__c), 22222);
//[BM] 8/7            System.assertEquals(Integer.valueOf(wrapperInstance.opportunityLineItemInstance.Core_Group_Code__c), 66666);
            
            // Asserting whether there is only one division and group code related to opportunity product
//[BM] 8/7            Core_OpportunityProductController.opportunityProductWrapper wrapperInstance1 = pageController.lstOpportunityProductsWrapper.get(19);
//[BM] 8/7            System.assertEquals(wrapperInstance1.bIsSingleGroupCode, true);
//[BM] 8/7            System.assertEquals(wrapperInstance1.bIsSingleDivisionCode, true);
            
            // Passing opportunity Id which doesn't have opportunity product records
            ApexPages.currentPage().getParameters().put('oppId', oppList.get(1).id);
    
            ApexPages.StandardController sc1 = new ApexPages.StandardController(opportunityLineItemInstance);
            
            Core_OpportunityProductController pageController1 = new Core_OpportunityProductController(sc1);
            
            // Asserting that the page throws error since there are no opportunity product records related to opportunity
//[BM] 8/7            System.assertEquals(pageController1.bNoRecords, true);
    
            // Passing invalid Opportunity Id to the page
            ApexPages.currentPage().getParameters().put('oppId', '01pq00000004Wfiii');
    
            ApexPages.StandardController sc2 = new ApexPages.StandardController(opportunityLineItemInstance);
    
            Core_OpportunityProductController pageController2 = new Core_OpportunityProductController(sc2);
            
            // Asserting that the page throws error since there are no opportunity product records related to opportunity
//[BM] 8/7            System.assertEquals(pageController1.bNoRecords, true);


        Test.stopTest();

    }
}