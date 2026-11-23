/*********************************************************************************************************************
Class Name    : Pilot_Sales_PriceOverrideControllerTest
Version       : 1.0
Created Date  : Sep 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari           20/09/2021              Pilot Project for testing framework.
* *********************************************************************************************************************/
@isTest
public class Pilot_Sales_PriceOverrideControllerTest {
    
    @isTest
    static void test_setPricebook(){
        
        Id pricebookId = Test.getStandardPricebookId();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
                
        SEL_Order orderSelectorMock = (SEL_Order) mocks.mock(SEL_Order.class);
        
        Account acc = new Account();
        acc.id = fflib_IDGenerator.generate(Schema.Account.SObjectType);
        
        Order ord = new Order();
        ord.Id = fflib_IDGenerator.generate(Schema.Order.SObjectType);
        
        mocks.startStubbing();
        
        //mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        //mocks.when(quoteSelectorMock.selectByIds(new Set<id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        
        mocks.when(orderSelectorMock.sObjectType()).thenReturn(Schema.Order.SObjectType);
        mocks.when(orderSelectorMock.selectByOrderId(new List<Id>{ord.Id})).thenReturn(new List<Order>{ord});
        
        mocks.stopStubbing();
        
        Sales_Application.Selector.setMock(orderSelectorMock);
        
        Test.startTest();
        Pilot_Sales_PriceBookOverrideController.setPricebook(ord.Id, pricebookId);
        Test.stopTest();
        
        ((SEL_Order) mocks.verify(orderSelectorMock,1)).selectByOrderId(new List<Id>{ord.Id});
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        //((SEL_Quote) mocks.verify(quoteSelectorMock,1)).selectByIds(new Set<id>{quote.id});
        //System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
        

}