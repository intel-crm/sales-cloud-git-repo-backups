/*********************************************************************************************************************
Class Name    : Sales_DisplayWarning
Version       : 1.0
Created Date  : Dec 2020
Function      : Controller class for corePSGDisplayWrning.cmp
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           22-Jan-2020              US862469:Price & Quantity Logic of a Order Product for different types of orders
* *********************************************************************************************************************/
@isTest
public with sharing class Sales_DisplayWarning {
    /*@AuraEnabled
    public static String validateMaintainenceDate(String orderId){
        String warningMessage;
        String LICENSE_TYPE_ORIGINAL = 'Original';
        Boolean isRenewal=false;
        Boolean isAddSeat=false;
        Boolean isBundled=false;
        Set<id> contactId = new Set<id>();
        Set<id> prodId = new Set<id>();
        //List<String> qty = new List<String>();-- unused variable
        Set<Id> foundProdIdSet=new Set<Id>();
        Set<Id> conIdSet=new Set<Id>();
        Map<Id,Id> foundationProdRenewalProdMap = new Map<id, Id>();
        Map<Id, Decimal> orderItemQuantityMap = new Map<Id, Decimal>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        Map<Id,Id> OptionalBaseMap = new Map<Id,Id>();
        List<OrderItem> orderItemRec=[Select Sales_Contact__c,Product2Id,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Quantity,Order.Sales_Order_Sub_Type__c,Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,OrderItemNumber, Order.Status from OrderItem where 
                                      (Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'RENEWAL' OR Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'ADD SEAT') 
                                      and OrderId =: orderId and Order.Status='Draft' and Order.Sales_Order_Sub_Type__c != 'Corporate Order'];
        if(orderItemRec.size() > 0){
            for(OrderItem oi : orderItemRec){ 
                orderItemQuantityMap.put(oi.Product2Id,oi.Quantity);
                foundationProdRenewalProdMap.put(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,oi.Product2Id);
                contactId.add(oi.Sales_Contact__c);
                prodId.add(oi.Product2Id);
                if(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'RENEWAL'){
                    isRenewal=true;  }  else if(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'ADD SEAT'){    isAddSeat= true;  }   
                foundProdIdSet.add(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
            }
        }
        List<SBQQ__ProductOption__c> compositeBundleChildList=[Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c 
                                                               from SBQQ__ProductOption__c 
                                                               where SBQQ__Type__c ='Accessory'  AND SBQQ__ConfiguredSKU__c IN:foundProdIdSet AND SBQQ__Bundled__c=true];
        if(compositeBundleChildList.size()>0){ 
            isBundled=true;
            for(SBQQ__ProductOption__c childProd:compositeBundleChildList){
                OptionalBaseMap.put(childProd.SBQQ__OptionalSKU__c,childProd.SBQQ__ConfiguredSKU__c);
                foundProdIdSet.add(childProd.SBQQ__OptionalSKU__c);
            }
        }
        if(contactId.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactId);
        }
        for(Id conId1 : delPrimaryContactMap.keySet()) {
            conIdSet.addAll(delPrimaryContactMap.get(conId1));
        }
        List<Sales_License__c> lcList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c, Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c 
                                         FROM Sales_License__c where Sales_License_Product__c IN:foundProdIdSet AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
                                                                                                                     OR(Sales_License_Primary_Admin_Contact__c IN : conIdSet)) AND (Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL)];
        if(lcList.isEmpty()){	
            if(isAddSeat){warningMessage = System.label.Sales_AddSeat_ErrMsg;
                         }
            return warningMessage;
        }
        Integer expiredLicCount = 0;
        for(Sales_License__c lc : lcList){
            if(isAddSeat){
                if(lc.Sales_License_Maintenance_Exp_Dt__c < System.today() || lc.Sales_License_Maintenance_Exp_Dt__c == null){  expiredLicCount = expiredLicCount + 1;                
                                                                                                                             }
            }
        }
        if(expiredLicCount == lcList.size()){warningMessage = System.label.Sales_AddSeat_ErrMsg;	}
        return warningMessage;
    }
    @AuraEnabled
    public static String validateQuantity(String orderId,String selectedField){
        String warningMessage = validateMaintainenceDate(orderId);
        List<String> orderIds = new List<String>();
        orderIds.add(orderId);
        String warnMsg = validatePriceChange(orderIds,selectedField,null);
        String finalMsg;
        if(warningMessage != null){  finalMsg = warnMsg!=null?warningMessage+' '+warnMsg:warningMessage; 
                                  }
        if(warnMsg!=null && warningMessage == null){ finalMsg = warnMsg;
                                                   }
        return finalMsg;
    }
    @AuraEnabled
    public static String validatePriceChange(List<String> orderId,String msg,Map<Id,Order> newOrdMap){
        String warningMsg ;
        Map<Id,Id> orderToQuote = new Map<Id,Id>();
        Set<Id> orderIdSet = new Set<Id>(); 
        Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderItemToPricebookEntry = new Map<Id,Id>();
        Set<Id> productIdSet = new Set<Id>();
        List<String> orderItemList = new List<String>();
        Set<String> columnOrderItemList = new Set<String>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,PricebookEntry> pbEntryMap = new Map<Id,PricebookEntry>();
        Map<id, List<core_cpq_list_price__c>> pbeIdVsListPriceMap = new Map<id, List<core_cpq_list_price__c>>();
        List<OrderItem> orderItemToUpdateList = new List<OrderItem>();
        Boolean orderproductCount = false;
        Boolean columnCheck = false;
        Boolean distiCheck = false;
        for(Order order:[Select Id,Type,SBQQ__Quote__c,AccountId,Sales_Sold_To_Account__c,Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c, Status,Sales_Req_Ship_Date_Dt__c,OrderItemCount__c,Pricebook2Id from Order where Id IN:orderId and Status='Draft']){
            if(order.Sales_Req_Ship_Date_Dt__c < Date.today() && msg!='Trigger'){ throw new AuraHandledException(System.Label.Sales_Req_Ship_Error); 
                                                                                }
            else if(order.Sales_Sold_To_Account__c==null && msg!='Trigger' && order.Type!='Non Commercial Order'){throw new AuraHandledException(System.Label.Sales_SoldTo_Error);
                                                                                                                 }
            else if(order.Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c==null && msg!='Trigger' && order.Type!='Non Commercial Order'){throw new AuraHandledException(System.Label.Sales_Disti_Channel_Error);
                                                                                                                                                       }
            else if(order.Type==null && msg!='Trigger'){throw new AuraHandledException(System.Label.Sales_OrderType_Error );}
            else if(order.Pricebook2Id==null && msg!='Trigger'){ throw new AuraHandledException(System.Label.sales_Pricebook_Error_On_Order);}
            else if(order.OrderItemCount__c==0){orderproductCount = true; }
            else{
                orderIdSet.add(order.Id);
                if(order.SBQQ__Quote__c!=null){
                    orderToQuote.put(order.Id,order.SBQQ__Quote__c);
                }    
                orderMap.put(order.Id,order);
            }
        }    
        if(orderToQuote.size()>0){
            for(SBQQ__QuoteLine__c qline : [Select Id , SBQQ__Quote__c,price_brokencost_amt__c,price_suggested_resale_amt__c,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:orderToQuote.values() ]){
                qlineMap.put(qline.Id,qline);
                quotelineToQuoteMap.put(qline.Id,qline.SBQQ__Quote__c);
                productIdSet.add(qline.SBQQ__Product__c);
            }
            if(quotelineToQuoteMap.size()>0){
                for(OrderItem oi : [Select Id ,OrderItemNumber,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId,UnitPriceForceOverride__c,Product2Id from OrderItem where SBQQ__QuoteLine__c IN:quotelineToQuoteMap.keySet() and OrderId IN:orderToQuote.keySet() and Product2Id IN:productIdSet]){
                    if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(oi.OrderId).type!='Non Commercial Order' && (orderMap.get(oi.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='02') && (oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c) && (qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c!=null) && (oi.UnitPriceForceOverride__c==null)  && (orderMap.get(oi.OrderId).Status=='Draft')){
                        orderItemList.add(oi.OrderItemNumber);
                        if(msg=='Trigger'){newOrdMap.get(oi.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                                           warningMsg = 'Error';
                                          }   else{ warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                                                  }
                    }
                    else if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(oi.OrderId).type!='Non Commercial Order' && ((orderMap.get(oi.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01') || (orderMap.get(oi.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04')) && (oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c) && qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c!=null && oi.UnitPriceForceOverride__c==null && (orderMap.get(oi.OrderId).Status=='Draft')){
                        orderItemList.add(oi.OrderItemNumber);
                        if(msg=='Trigger'){
                            newOrdMap.get(oi.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                            warningMsg = 'Error';
                        }
                        else{warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                            }    
                    }
                    else if((orderMap.get(oi.OrderId).type=='Non Commercial Order') && (oi.UnitPrice!=0) && (oi.UnitPriceForceOverride__c==null)&& (orderMap.get(oi.OrderId).Status=='Draft')){
                        orderItemList.add(oi.OrderItemNumber);
                        if(msg=='Trigger'){newOrdMap.get(oi.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                                           warningMsg = 'Error';
                                          }
                        else{
                            warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                        }    
                    }
                }
            }
        }
        else if(orderToQuote.size()==0 && orderIdSet.size()>0){
            for(OrderItem oitem : [Select Id ,OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c from OrderItem where OrderId IN:orderMap.keySet()]){
                orderItemToPricebookEntry.put(oitem.Id,oitem.PricebookEntryId);
                productIdSet.add(oitem.Product2Id);
                if(orderMap.get(oitem.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='02'){    distiCheck=true;}
                else{
                    distiCheck=false;
                }
            }
            if(orderItemToPricebookEntry.size()>0 && productIdSet.size()>0){
                for(PricebookEntry pbEntry : [Select Id,UnitPrice,price_disty_cost__c,Product2Id from PricebookEntry where Id IN:orderItemToPricebookEntry.values() And Product2Id IN:productIdSet]){
                    pbEntryMap.put(pbEntry.Id,pbEntry);
                }
            }
            if(orderItemToPricebookEntry.size()>0 && distiCheck==false){
                for(core_cpq_list_price__c listPriceRec: [select id, core_cpq_list_price_amt__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, core_cpq_product_name__c, Pricebookentry__c from core_cpq_list_price__c where Pricebookentry__c in: orderItemToPricebookEntry.values() And core_cpq_product_name__c in: productIdSet]){
                    if(pbeIdVsListPriceMap.containsKey(listPriceRec.Pricebookentry__c)){List<core_cpq_list_price__c> listPriceRecLst = pbeIdVsListPriceMap.get(listPriceRec.Pricebookentry__c);
                                                                                        listPriceRecLst.add(listPriceRec);
                                                                                        pbeIdVsListPriceMap.put(listPriceRec.Pricebookentry__c, listPriceRecLst);
                                                                                       }else{pbeIdVsListPriceMap.put(listPriceRec.Pricebookentry__c, new List<core_cpq_list_price__c> { listPriceRec });
                                                                                            }
                }
            }
            for(OrderItem ilist : [Select Id , OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c,SBQQ__QuoteLine__c,Quantity from OrderItem where PricebookEntryId IN:pbEntryMap.keySet() and Product2Id IN:productIdSet and OrderId IN:orderMap.keySet()]){
                if(orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(ilist.OrderId).type!='Non Commercial Order' && (orderMap.get(ilist.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='02') && (pbEntryMap.get(ilist.PricebookEntryId).price_disty_cost__c!=null) && (ilist.UnitPrice!=pbEntryMap.get(ilist.PricebookEntryId).price_disty_cost__c) && ilist.UnitPriceForceOverride__c==null && (orderMap.get(ilist.OrderId).Status=='Draft')){orderItemList.add(ilist.OrderItemNumber);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  if(msg=='Trigger'){newOrdMap.get(ilist.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     warningMsg = 'Error';
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  else{ warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      } 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 }
                if(ilist.UnitPriceForceOverride__c==null && (orderMap.get(ilist.OrderId).Status=='Draft') && (orderMap.get(ilist.OrderId).type=='Non Commercial Order') && (ilist.UnitPrice!=0)){
                    orderItemList.add(ilist.OrderItemNumber);
                    if(msg=='Trigger'){newOrdMap.get(ilist.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                                       warningMsg = 'Error';}
                    else{ warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                        } }
                if(ilist.UnitPriceForceOverride__c==null && (orderMap.get(ilist.OrderId).Status=='Draft') && (orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c!=null) && (((orderMap.get(ilist.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01') || (orderMap.get(ilist.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04')) && (orderMap.get(ilist.OrderId).type!='Non Commercial Order'))){
                    if(pbeIdVsListPriceMap.size()>0 && pbeIdVsListPriceMap.containsKey(ilist.PricebookEntryId) && pbeIdVsListPriceMap.get(ilist.PricebookEntryId)!=null && ilist.SBQQ__QuoteLine__c==null){
                        for(core_cpq_list_price__c listPriceRec: pbeIdVsListPriceMap.get(ilist.PricebookEntryId)){
                            if(ilist.Quantity>=listPriceRec.core_cpq_lowerbound_qty__c && (ilist.Quantity<=listPriceRec.core_cpq_upperbound_qty__c || listPriceRec.core_cpq_upperbound_qty__c==null) && (ilist.UnitPrice!=listPriceRec.core_cpq_list_price_amt__c)){columnCheck=true;
                                                                                                                                                                                                                                                                    columnOrderItemList.add(ilist.OrderItemNumber);
                                                                                                                                                                                                                                                                    orderItemList.add(ilist.OrderItemNumber);
                                                                                                                                                                                                                                                                    if(msg=='Trigger'){newOrdMap.get(ilist.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                                                                                                                                                                                                                                                                                       warningMsg = 'Error';}
                                                                                                                                                                                                                                                                    else{ warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                                                                                                                                                                                                                                                                        }  
                                                                                                                                                                                                                                                                   }
                            else{columnOrderItemList.add(ilist.OrderItemNumber);
                                 columnCheck=false;}
                        }
                    }
                }  
                if(ilist.UnitPriceForceOverride__c==null && (orderMap.get(ilist.OrderId).Status=='Draft') && (orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c!=null) && (((orderMap.get(ilist.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01') || (orderMap.get(ilist.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04'))  && (orderMap.get(ilist.OrderId).type!='Non Commercial Order')) && (ilist.UnitPrice!=pbEntryMap.get(ilist.PricebookEntryId).UnitPrice) && (!columnOrderItemList.contains(ilist.OrderItemNumber))){  
                    if(msg=='Trigger'){newOrdMap.get(ilist.OrderId).addError(System.Label.Sales_PriceMismatch_Error);
                                       warningMsg = 'Error';}
                    else{ warningMsg = System.Label.Sales_UnitPrice_Mismatch_Error;
                        }   orderItemList.add(ilist.OrderItemNumber);
                }                
            }
        }
        if(msg=='Recalculate' && (orderItemList.size()>0) && (orderproductCount==false)){ warningMsg = recalculateOrderProduct(orderItemList,productIdSet,orderMap);
                                                                                        }
        else if(msg=='Recalculate' && (orderproductCount==true)){ warningMsg = 'No product';}
        return warningMsg;
    }
    public static String recalculateOrderProduct(List<String> orderItems,Set<Id> productIdSet,Map<Id,Order>orderMap){
        String retmessage;
        List<OrderItem> orderItemToUpdateList = new List<OrderItem>();
        if(orderItems.size()>0){
            for(OrderItem ilist : [Select Id , OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c from OrderItem where OrderItemNumber IN:orderItems and Product2Id IN:productIdSet and OrderId IN:orderMap.keySet()]){
                ilist.Sales_IsRecalculated__c = true; 
                orderItemToUpdateList.add(ilist);
            }
        } 
        if(orderItemToUpdateList.size()>0){
            try{	
                update orderItemToUpdateList;
                retmessage = 'Success';
            }catch (DmlException ex) {	
                throw new AurahandledException('' + ex.getDmlMessage(0));
            }catch (Exception ex) {	
                throw new AurahandledException('' + ex.getMessage());
            }
        }
        return retmessage;
    }*/
}