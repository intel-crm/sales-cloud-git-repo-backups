@isTest
public class Sales_OrderConfirmationControllerTest {
    @isTest 
    public static void testOrderConfirmation(){
        Id dummyOrderId = Sales_TestDataFactory.getFakeId(Order.SObjectType);
        Test.startTest();
        Sales_OrderConfirmationController orderConfirm= new Sales_OrderConfirmationController();
        orderConfirm.orderItem = null;
        List<OrderItem> returnedList = orderConfirm.getOrderItems();
        Test.stopTest();
        System.assert(returnedList.isEmpty());
    }
}