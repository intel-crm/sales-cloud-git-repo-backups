/*********************************************************************************************************************
Class Name    : Sales_CloneOrderwithProdController
Version       : 1.0
Created Date  : Sep 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari 			21/9/2021               Pilot Project for testing framework.
* *********************************************************************************************************************/
public without sharing class Sales_CloneOrderwithProdController {
    private static final String ORDER_CANCELLED = 'Order Cancelled';
    private static final String ORDER_CANCELLED_BY_SAP='Order Cancelled by SAP';
    
    @AuraEnabled //updated by Shalini/Jasmine as a part of  US871094 and US950999
    public static String insertOrderProducts(Id newRecId,Id originalRecId)//new RecId=> cloned record Id, originalRecId=> record which is being cloned
    {
        String isReturnMsg='';
        List<OrderItem> itemsList = new List<OrderItem>();
        List<OrderItem> oiList = Database.query(System.Label.Sales_OrderProduct_Query1 + System.Label.Sales_OrderProduct_Query2);//fetching all the fields of order products from original Order 
        for(OrderItem  oi:oiList){
            if(oi.Product2.Core_Item_Orderable_Ind__c == true){
                OrderItem itemcopy = oi.clone(false,false);//cloning order products
                itemcopy.OrderId = newRecId;//assigning new Order id to Ordproducts records
                if(oi.Order.Sales_status__c == ORDER_CANCELLED|| oi.Order.Sales_status__c == ORDER_CANCELLED_BY_SAP){//if Order is cancelled then nullify the Quoteline from Original Order
                    itemcopy.SBQQ__QuoteLine__c = oi.Sales_Cancelled_Quoteline_No__c;
                    itemcopy.Sales_Cancelled_Quoteline_No__c = null;
                }
                itemcopy.SBQQ__Status__c = 'Draft';
                itemsList.add(itemcopy);
            }else{
                isReturnMsg = 'success';//return sucess msg
            }
        }
        if(itemsList.size()> 0){
            try{
                upsert itemsList;//inserting new order products in newly cloned order
                isReturnMsg = 'success';//return sucess msg
            }catch(Exception e){if(e.getMessage().contains('_EXCEPTION')){String pureErrorMessage = e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                    isReturnMsg = pureErrorMessage;//if exception contains this string then return filtered msg
            }else{isReturnMsg = e.getMessage();}//else return complete error message
            }finally{
                if(isReturnMsg!='success'){List<Order> ordList = new List<Order>();
                    for(Order ord : [SELECT Id from Order where id  =:newRecId]){ordList.add(ord);}  
                    if(ordList.size() > 0){ delete ordList;}//in case of any exception delete the created order if any
                }
            }
        }
        return isReturnMsg;//return final msg(success or error)
    }
}