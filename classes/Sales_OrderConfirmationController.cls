public with sharing class Sales_OrderConfirmationController{
public Id ordId{get;set;}
public OrderItem orderItem{get;set;}
private List<OrderItem> orderItems{get;set;}
public Sales_OrderConfirmationController(){}
public List<OrderItem> getOrderItems(){
    orderItems = new List<OrderItem>();
    orderItems =  [SELECT Id, Order.OrderNumber, Product2.Name, Quantity FROM OrderItem WHERE OrderId != null AND OrderId =:ordId];
    return orderItems;
}
}