/*********************************************************************************************************************
Class Name    : Pilot_Sales_OrderTriggerUtility_Test
Version       : 1.0
Created Date  : Sep 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Subhanku Ghosh           1/09/2021              Pilot Project for testing framework.
* *********************************************************************************************************************/
@isTest
public class Pilot_Sales_OrderTriggerUtility_Test {
    @isTest
    static void test_createOrdersfromQuote(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
                
        SEL_Quote quoteSelectorMock = (SEL_Quote) mocks.mock(SEL_Quote.class);
        
        Account acc = new Account();
        acc.id = fflib_IDGenerator.generate(Schema.Account.SObjectType);
        acc.type = 'Distributor';
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Id = fflib_IDGenerator.generate(Schema.SBQQ__Quote__c.SObjectType);
        quote.SBQQ__Ordered__c = true;
		quote.SBQQ__StartDate__c = System.today();
		quote.SBQQ__Account__r = acc;
                
        
        Order ord = new Order();
        ord.EffectiveDate = System.today();
		ord.SBQQ__Quote__c = quote.Id;
		ord.Status = '';
		ord.Sales_status__c = '';
		ord.Type = '';
		ord.Sales_Order_Reason__c = '';
		ord.Sales_Corporate_Order__c = true;
             
        mocks.startStubbing();
        
        mocks.when(quoteSelectorMock.sObjectType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.when(quoteSelectorMock.selectByIds(new Set<id>{quote.id})).thenReturn(new List<SBQQ__Quote__c>{quote});
        
        mocks.stopStubbing();
        
        Sales_Application.Selector.setMock(quoteSelectorMock);
        
        Test.startTest();
        Pilot_Sales_OrderTriggerUtility.createOrdersfromQuote(new List<Order>{ord},null);
        Test.stopTest();
                
        ((SEL_Quote) mocks.verify(quoteSelectorMock,1)).selectByIds(new Set<id>{quote.id});
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_checkAccountCompetitorVendor(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
                
        SEL_OrderItem orderItemSelectorMock = (SEL_OrderItem) mocks.mock(SEL_OrderItem.class);
        SEL_Sales_License_Control salesLCControlSelectorMock = (SEL_Sales_License_Control) mocks.mock(SEL_Sales_License_Control.class);
        
        Account acc = new Account();
        acc.id = fflib_IDGenerator.generate(Schema.Account.SObjectType);
        
        Order newOrder = new Order();
        newOrder.id = fflib_IDGenerator.generate(Schema.Order.SObjectType);
        newOrder.status = 'Draft';
		newOrder.AccountId = acc.Id;
		newOrder.Sales_End_Customer_Account__c = acc.id;
        
        Order oldOrder = new Order();
        oldOrder.status = 'Activated';
		oldOrder.AccountId = null;
		oldOrder.Sales_End_Customer_Account__c = null;
        
        Product2 prod = new Product2();
        prod.Core_OPN__c='SW-QUARTUS-SE-FIX';        
        
        OrderItem orderItem = new OrderItem();
        orderItem.Product2 = prod;
        orderItem.OrderId = newOrder.id;
        
        Sales_License_Control__c slc = new Sales_License_Control__c();
        slc.Sales_Account_Competitor__c = acc.id;
        slc = (Sales_License_Control__c)fflib_ApexMocksUtils.setReadOnlyFields(
        slc,
        Sales_License_Control__c.class,
        new Map<SObjectField, Object> {Sales_License_Control__c.Sales_OPN__c => 'SW-QUARTUS-SE-FIX'}
         );
            
        mocks.startStubbing();
        
        mocks.when(orderItemSelectorMock.sObjectType()).thenReturn(Schema.OrderItem.SObjectType);
        mocks.when(salesLCControlSelectorMock.sObjectType()).thenReturn(Schema.Sales_License_Control__c.SObjectType);
        mocks.when(orderItemSelectorMock.selectByOrderIds(new Set<id>{newOrder.id})).thenReturn(new List<OrderItem>{orderItem});
        mocks.when(salesLCControlSelectorMock.selectByEndCustIdSet(new Set<id>{acc.id})).thenReturn(new List<Sales_License_Control__c>{slc});
        
        mocks.stopStubbing();
        
        Sales_Application.Selector.setMock(orderItemSelectorMock);
        Sales_Application.Selector.setMock(salesLCControlSelectorMock);
        
        Test.startTest();
        Pilot_Sales_OrderTriggerUtility.checkAccountCompetitorVendor(new List<Order>{neworder},new Map<Id,Order>{newOrder.id=>oldOrder});
        Test.stopTest();
                
        ((SEL_OrderItem) mocks.verify(orderItemSelectorMock,1)).selectByOrderIds(new Set<id>{newOrder.id});
        ((SEL_Sales_License_Control) mocks.verify(salesLCControlSelectorMock,1)).selectByEndCustIdSet(new Set<id>{acc.id});
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_sendEmailNotification(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
                
        SEL_User userSelectorMock = (SEL_User) mocks.mock(SEL_User.class);
        
        User usr = new User();
        usr.id=fflib_IDGenerator.generate(Schema.User.SObjectType);
        usr.Email = 'xyz@intel.com';
        
        Order testodr = (Order) new BLD_Order()
            .orderType('')
            //.createdById(UserInfo.getUserId())
            .orderCity('')
            .mock();
        
        mocks.startStubbing();
        
        mocks.when(userSelectorMock.sObjectType()).thenReturn(Schema.User.SObjectType);
        mocks.when(userSelectorMock.selectById((Set<Id>) fflib_Match.anyObject())).thenReturn(new List<User>{usr});
        
        mocks.stopStubbing();
        
        Sales_Application.Selector.setMock(userSelectorMock);
        Sales_Application.UnitOfWork.setMock(uowMock);
        
        Test.startTest();
        Pilot_Sales_OrderTriggerUtility.sendEmailNotification(new List<Order>{testodr});
        Test.stopTest();
                
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    @isTest
    static void test_checkOrderTypeandSubType(){
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
                
        SEL_OrderItem orderItemSelectorMock = (SEL_OrderItem) mocks.mock(SEL_OrderItem.class);
        SEL_Order OrderSelectorMock = (SEL_Order) mocks.mock(SEL_Order.class);

        Order order = new Order();
        order.id = fflib_IDGenerator.generate(Schema.Order.SObjectType);
        order.status = 'Draft';
        
        Product2 prod = new Product2();
        prod.Core_OPN__c='SW-QUARTUS-SE-FIX';        
        
        OrderItem orderItem = new OrderItem();
        orderItem.Product2 = prod;
        orderItem.OrderId = order.id;
            
        mocks.startStubbing();
        
        mocks.when(orderItemSelectorMock.sObjectType()).thenReturn(Schema.OrderItem.SObjectType);
        mocks.when(orderSelectorMock.sObjectType()).thenReturn(Schema.Order.SObjectType);
        mocks.when(orderItemSelectorMock.selectByOrderIds(new Set<id>{order.id})).thenReturn(new List<OrderItem>{orderItem});
        
        mocks.stopStubbing();
        
        Sales_Application.Selector.setMock(orderItemSelectorMock);
        Sales_Application.Selector.setMock(orderSelectorMock);
        
        Test.startTest();
        Pilot_Sales_OrderTriggerUtility.checkOrderTypeandSubType(new List<Order>{order});
        Test.stopTest();
                
        ((SEL_OrderItem) mocks.verify(orderItemSelectorMock,1)).selectByOrderIds(new Set<id>{order.id});
        ((SEL_Order) mocks.verify(orderSelectorMock,1)).selectByIds(new List<Order>{order});
        System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
}