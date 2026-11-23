/*********************************************************************************************************************
Class Name    : Sales_Mock_CloneOrderwithProdController
Version       : 1.0
Created Date  : June 2021
Project       : SALES Project

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        30.6.2021               POC Controller Class
*----------------------------------------------------------------------------------------------------------*/

public with sharing class Sales_Mock_CloneOrderwithProdController {

    private static final String ORDER_CANCELLED = 'Order Cancelled';
    private static final String ORDER_CANCELLED_BY_SAP='Order Cancelled by SAP';
    
    @AuraEnabled //updated by Shalini/Jasmine as a part of  US871094 and US950999
    public static String insertOrderProducts(Id newRecId,Id originalRecId)//new RecId=> cloned record Id, originalRecId=> record which is being cloned
    {
        String isReturnMsg='';
        List<OrderItem> itemsList = new List<OrderItem>();      

        /*String fullQuery = 'SELECT Product2Id, SBQQ__Activated__c,SBQQ__Status__c, SBQQ__Asset__c, Sales_Asset_Id_Txt__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c,'+
                            'SBQQ__BlockPrice__c, SBQQ__BookingsIndicator__c, Sales_Broken_Price_Amt__c, SBQQ__BundleRoot__c, SBQQ__ChargeType__c, Sales_Contact__c, SBQQ__Contract__c, '+
                            'SBQQ__ContractAction__c, SBQQ__Contracted__c, SBQQ__ContractingMethod__c, Sales_Customer_frght_collect_account__c, SBQQ__DefaultSubscriptionTerm__c, '+
                            'SBQQ__DiscountSchedule__c, Sales_Due_Date_Dt__c, Order.Sales_status__c,Sales_Email_Address_Txt__c,SBQQ__TaxAmount__c, Sales_First_Name_Txt__c, '+
                            'SBQQ__UnproratedNetPrice__c, Sales_Last_Name_Txt__c, Sales_License_Vendor_Txt__c, Description, ListPrice, Core_PSG_Maint_Exp_Dt__c, Sales_Cancelled_Quoteline_No__c, '+
                            'Sales_Net_Discount_Percent_Pct__c,Sales_New_RU_Guard_Id_Txt__c,Sales_Order_Notes_Txt__c,SBQQ__OrderProductBookings__c,Product2.Core_Item_Orderable_Ind__c, '+
                            'OriginalOrderItemId,SBQQ__QuoteLine__c,SBQQ__OrderedQuantity__c,Sales_Parent_Order_Item_Id_Txt__c, SBQQ__PriceDimension__c, SBQQ__PriceSchedule__c, '+
                            'SBQQ__PricingMethod__c, SBQQ__ProductSubscriptionType__c, SBQQ__ProrateMultiplier__c, Quantity, SBQQ__QuotedListPrice__c, SBQQ__QuotedQuantity__c,SBQQ__RequiredBy__c, '+
                            'SBQQ__RevisedOrderProduct__c, Sales_RU_Guard_Id_Txt__c, Sales_RU_Node_Id_Txt__c, Sales_SAP_LAC_Rule_Txt__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, '+
                            'SBQQ__DimensionType__c, SBQQ__ShippingAccount__c,Sales_Status__c,SBQQ__Subscription__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c, '+
                            'SBQQ__SubscriptionType__c,Sales_Suggested_Resale_Price__c,SBQQ__TaxCode__c,SBQQ__TermDiscountSchedule__c,SBQQ__TerminatedDate__c,TotalPrice, Order.SBQQ__Quote__c, '+
                            'Sales_Training_No_Txt__c,UnitPriceForceOverride__c,UnitPrice,SBQQ__UpgradedSubscription__c,PricebookEntryId FROM OrderItem WHERE OrderId = : originalRecId	';
        List<OrderItem> oiList = Database.query(fullQuery);         //fetching all the fields of order products from original Order 
                            */

        //POC Code Start
		System.debug('Inside POC Code');
        List<OrderItem> oiList =   Sales_Selectors.newInstance().selectOPWithOrderId(originalRecId);
        
        //POC Code End

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