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
        productInstance.Core_Division_Code__c = '11111';
        productInstance.Core_Division_Code_Short_Name__c = 'Division 1';
        productInstance.Core_Group_Code__c = '55555';
        productInstance.Core_Group_Code_Short_Name__c = 'Group 1';

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
        
        // Creating a list of opportunity and inserting it
        lstOpportunity = Core_Test_Utility.createOpportunity(2);
        insert lstOpportunity;
        
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

            // Setting up the page to be tested
            PageReference productEditPage = Page.Core_OpportunityProduct;
    
            Test.setCurrentPage(productEditPage);
    
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityLineItemInstance);
    
            ApexPages.currentPage().getParameters().put('oppId', lstOpportunity.get(0).id);
    
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
            ApexPages.currentPage().getParameters().put('oppId', lstOpportunity.get(1).id);
    
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