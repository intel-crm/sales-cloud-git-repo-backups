/*********************************************************************************************************************
Class Name    : Sales_Mock_CloneOrderwithProdTest
Version       : 1.0
Created Date  : June 2021
Project       : SALES Project

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        30.6.2021               POC Controller Test-Class
*----------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class Sales_Mock_CloneOrderwithProdTest {

    @isTest static void testCloneOrderProduct(){

        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Sales_SelectorInterfaces selectorMock = (Sales_SelectorInterfaces)mocks.mock(Sales_Selectors.class);

        Id existingOrderId = Sales_Selectors.generateSObjectId(Schema.Order.SObjectType);
        Id newOrderId = Sales_Selectors.generateSObjectId(Schema.Order.SObjectType);
		//Mock query records
        List<OrderItem> orderProductList = new List<OrderItem>{
            new OrderItem  (Id=Sales_Selectors.generateSObjectId(Schema.OrderItem.SObjectType),
                            OrderId=existingOrderId,
                            PricebookEntryId=Sales_Selectors.generateSObjectId(Schema.PricebookEntry.SObjectType),
                            Product2Id=Sales_Selectors.generateSObjectId(Schema.Product2.SObjectType),
                            Sales_Contact__c=Sales_Selectors.generateSObjectId(Schema.Contact.SObjectType),
                            Quantity=1, ListPrice=50, UnitPrice=50
        )};


        //Mock - Stubbing 
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(OrderItem.SObjectType);
        mocks.when(selectorMock.selectOPWithOrderId( existingOrderId )).thenReturn( orderProductList );
        mocks.stopStubbing();

        //Setting Mock
        Application.Selector.setMock(selectorMock);

        //Test method
        Test.startTest();
        Sales_Mock_CloneOrderwithProdController.insertOrderProducts(newOrderId,existingOrderId);
        Test.stopTest();

        //Verify
        ((Sales_Selectors) mocks.verify(selectorMock)).selectOPWithOrderId( existingOrderId );
            
    }

}