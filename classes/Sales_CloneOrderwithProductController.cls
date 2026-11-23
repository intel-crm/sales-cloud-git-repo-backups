/*********************************************************************************************************************
Class Name    : Sales_CloneOrderwithProductController
Version       : 1.0
Created Date  : Feb 2021
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           14-Feb-2021             Sales_CloneOrderwithProductController 
Shalini Kumari		   8-April-2021
*----------------------------------------------------------------------------------------------------------*/
public without sharing class Sales_CloneOrderwithProductController {
    private static final String ORDER_CANCELLED = 'Order Cancelled';
    private static final String ORDER_CANCELLED_BY_SAP='Order Cancelled by SAP';
    @AuraEnabled 
    public static String insertOrderProducts(Id newRecId,Id originalRecId)
    {
        String isReturnMsg='';
        List<OrderItem> itemsList = new List<OrderItem>();
        List<OrderItem> oiList = Database.query(System.Label.Sales_OrderProduct_Query1 + System.Label.Sales_OrderProduct_Query2);
        for(OrderItem  oi:oiList){
            if(oi.Product2.Core_Item_Orderable_Ind__c == true){
                OrderItem itemcopy = oi.clone(false,false);
                itemcopy.OrderId = newRecId;
                if(oi.Order.Sales_status__c == ORDER_CANCELLED|| oi.Order.Sales_status__c == ORDER_CANCELLED_BY_SAP){
                    itemcopy.SBQQ__QuoteLine__c = oi.Sales_Cancelled_Quoteline_No__c;
                    itemcopy.Sales_Cancelled_Quoteline_No__c = null;
                }
                itemcopy.SBQQ__Status__c = 'Draft';
                itemsList.add(itemcopy);
            }else{
                isReturnMsg = 'success';
            }
        }
        if(itemsList.size()> 0){
            try{
                upsert itemsList;
                isReturnMsg = 'success';
            }catch(Exception e){if(e.getMessage().contains('_EXCEPTION')){String pureErrorMessage = e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                    isReturnMsg = pureErrorMessage;
            }else{isReturnMsg = e.getMessage();}
            }finally{
                if(isReturnMsg!='success'){List<Order> ordList = new List<Order>();
                    for(Order ord : [SELECT Id from Order where id  =:newRecId]){ordList.add(ord);}  
                    if(ordList.size() > 0){ delete ordList;}
                }
            }
        }
        return isReturnMsg;
    }
}