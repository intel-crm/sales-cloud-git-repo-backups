public with sharing class Sales_RecalculatePrice {
	 @AuraEnabled
    public static String recalculatePriceChange(String orderId){
        //String msg='Recalculated';
         System.debug('Inside price change method');
        String warningMsg ;
        Map<Id,Id> orderToQuote = new Map<Id,Id>();
        Set<Id> orderIdSet = new Set<Id>(); //set of order Id's.
        Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Id> orderItemToPricebookEntry = new Map<Id,Id>();
      	Set<Id> productIdSet = new Set<Id>();
        List<String> orderItemList = new List<String>();
        Set<String> columnOrderItemList = new Set<String>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,PricebookEntry> pbEntryMap = new Map<Id,PricebookEntry>();
       	List<core_cpq_list_price__c> listPriceLst = new List<core_cpq_list_price__c>();
        List<OrderItem> orderItemToUpdateList = new List<OrderItem>();
        Map<Id,core_cpq_list_price__c> cpqMap = new Map<Id,core_cpq_list_price__c>();
        Map<id, List<core_cpq_list_price__c>> pbeIdVsListPriceMap = new Map<id, List<core_cpq_list_price__c>>();
        Boolean brokenCheck = false;
        Boolean suggestedCheck = false;
        Boolean columnCheck=false;
        System.debug('Order Id >>'+orderId);
        
        for(Order order:[Select Id,Type,SBQQ__Quote__c,AccountId,Sales_Sold_To_Account__c,Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c, Status,Sales_Req_Ship_Date_Dt__c from Order where Id =:orderId and Status='Draft']){
            if(order.Sales_Req_Ship_Date_Dt__c < Date.today()){
                throw new AuraHandledException('Req. Ship date should be present or future date, Please update the Req. Ship date, to proceed with Recalculation of Price.');
            }
            else{
                orderIdSet.add(order.Id);
                if(order.SBQQ__Quote__c!=null){
                    orderToQuote.put(order.Id,order.SBQQ__Quote__c);
                }    
                orderToAccountMap.put(order.Id,order.Sales_Sold_To_Account__c);
                orderMap.put(order.Id,order);
                /*System.debug('orderMap>>'+orderMap);
                System.debug('orderToQuote>>'+orderToQuote);
                System.debug('orderToAccountMap>>'+orderToAccountMap);*/
            }    
        }
      
        if(orderToAccountMap.size()>0){
            for(Account acc : [Select Id,type,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:orderToAccountMap.values()]){
                accMap.put(acc.Id,acc);
                System.debug('accMap>>'+accMap);
            }
        }
        //with quote scenarios
        if(orderToQuote.size()>0){
            for(SBQQ__QuoteLine__c qline : [Select Id , SBQQ__Quote__c,price_brokencost_amt__c,price_suggested_resale_amt__c,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:orderToQuote.values() ]){
                qlineMap.put(qline.Id,qline);
                quotelineToQuoteMap.put(qline.Id,qline.SBQQ__Quote__c);
                productIdSet.add(qline.SBQQ__Product__c);
                /*System.debug('qlineMap>>'+qlineMap);
                System.debug('quotelineToQuoteMap>>'+quotelineToQuoteMap);*/
            }
            if(quotelineToQuoteMap.size()>0){
                for(OrderItem oi : [Select Id ,OrderItemNumber,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId,UnitPriceForceOverride__c,Product2Id from OrderItem where SBQQ__QuoteLine__c IN:quotelineToQuoteMap.keySet() and OrderId IN:orderToQuote.keySet() and Product2Id IN:productIdSet]){
                    Id accountId =  orderToAccountMap.get(oi.OrderId);
                    Account accRecord = accMap.get(accountId); 
                    /*System.debug('account type>>'+orderToAccountMap.get(oi.OrderId));
                    System.debug('Order product>>');
                    System.debug('Broken cost>>'+qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c);
                    System.debug('Unit price'+oi.UnitPrice);*/
                    if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(oi.OrderId).type!='Non Commercial Order' && accRecord.Core_Direct_Distributor_Channel_Nm__c=='02' && (oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c) && qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c!=null && oi.UnitPriceForceOverride__c==null){
                        orderItemList.add(oi.OrderItemNumber);
                        brokenCheck = true ;
                        System.debug('brokenCheck>>'+brokenCheck); 
                        
                    }
                    else if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(oi.OrderId).type!='Non Commercial Order' && accRecord.Core_Direct_Distributor_Channel_Nm__c=='01' && (oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c) && qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c!=null && oi.UnitPriceForceOverride__c==null){
                        orderItemList.add(oi.OrderItemNumber);
                        suggestedCheck = true;
                        System.debug('suggestedCheck>>'+suggestedCheck);   
                        
                    }
                }
            }
        }
        //without quote scenarios
        else if(orderToQuote.size()==0 && orderIdSet.size()>0){
            for(OrderItem oitem : [Select Id ,OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c from OrderItem where OrderId IN:orderMap.keySet()]){
                orderItemToPricebookEntry.put(oitem.Id,oitem.PricebookEntryId);
                System.debug('OrderItemtoPricebookentry>>'+orderItemToPricebookEntry);
                productIdSet.add(oitem.Product2Id);
                System.debug('Productset'+productIdSet);
            }
            if(orderItemToPricebookEntry.size()>0 && productIdSet.size()>0){
            	for(PricebookEntry pbEntry : [Select Id,UnitPrice,price_disty_cost__c,Product2Id from PricebookEntry where Id IN:orderItemToPricebookEntry.values() And Product2Id IN:productIdSet]){
                	pbEntryMap.put(pbEntry.Id,pbEntry);
                    System.debug('PricebookentryMap'+pbEntryMap);
            	}
            }
            if(orderItemToPricebookEntry.size()>0){
            	listPriceLst = [select id, core_cpq_list_price_amt__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, core_cpq_product_name__c, Pricebookentry__c from core_cpq_list_price__c where Pricebookentry__c in: orderItemToPricebookEntry.values() And core_cpq_product_name__c in: productIdSet]; //fetch all core cpq list price records for product
        	}
            if(listPriceLst.size()>0){
                for(core_cpq_list_price__c listPriceRec: listPriceLst){
                    if(pbeIdVsListPriceMap.containsKey(listPriceRec.Pricebookentry__c)){
                        List<core_cpq_list_price__c> listPriceRecLst = pbeIdVsListPriceMap.get(listPriceRec.Pricebookentry__c);
                        listPriceRecLst.add(listPriceRec);
                        pbeIdVsListPriceMap.put(listPriceRec.Pricebookentry__c, listPriceRecLst);
                    }else{
                        pbeIdVsListPriceMap.put(listPriceRec.Pricebookentry__c, new List<core_cpq_list_price__c> { listPriceRec });
                    }
                }
            }
            
            for(OrderItem ilist : [Select Id , OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c,SBQQ__QuoteLine__c,Quantity from OrderItem where PricebookEntryId IN:pbEntryMap.keySet() and Product2Id IN:productIdSet and OrderId IN:orderMap.keySet()]){
                System.debug('Orderitem>>'+ilist); 
                 Id accountId =  orderToAccountMap.get(ilist.OrderId);
                 Account accRecord = accMap.get(accountId); 
                /*System.debug('Sold to account'+orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c);
                System.debug('Order type>>'+orderMap.get(ilist.OrderId).type);*/
                System.debug('Here at line389');
                
                //unit price mismatch with disti cost
                if(orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(ilist.OrderId).type!='Non Commercial Order' && accRecord.Core_Direct_Distributor_Channel_Nm__c=='02' && (ilist.UnitPrice!=pbEntryMap.get(ilist.PricebookEntryId).price_disty_cost__c) && ilist.UnitPriceForceOverride__c==null){
                    System.debug('Inside disti check');
                    orderItemList.add(ilist.OrderItemNumber);
                }
                //unit price mismatch with column resale
                if(pbeIdVsListPriceMap.size()>0 && ilist.UnitPriceForceOverride__c==null && (orderMap.get(ilist.OrderId).Status=='Draft') && (orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c!=null) && ((orderMap.get(ilist.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01') && (orderMap.get(ilist.OrderId).type!='Non Commercial Order'))){
                    if(pbeIdVsListPriceMap.containsKey(ilist.PricebookEntryId) && pbeIdVsListPriceMap.get(ilist.PricebookEntryId)!=null && ilist.SBQQ__QuoteLine__c==null){
                        for(core_cpq_list_price__c listPriceRec: pbeIdVsListPriceMap.get(ilist.PricebookEntryId)){
                            //if(orderProduct.Quantity>=listPriceRec.core_cpq_lowerbound_qty__c && orderProduct.Quantity<=listPriceRec.core_cpq_upperbound_qty__c){
                            if(ilist.Quantity>=listPriceRec.core_cpq_lowerbound_qty__c && (ilist.Quantity<=listPriceRec.core_cpq_upperbound_qty__c || listPriceRec.core_cpq_upperbound_qty__c==null) && (ilist.UnitPrice!=listPriceRec.core_cpq_list_price_amt__c)){
                                columnCheck=true;  
                                orderItemList.add(ilist.OrderItemNumber);
                                columnOrderItemList.add(ilist.OrderItemNumber);
                            }
                            else{
                                columnCheck=false;
                                columnOrderItemList.add(ilist.OrderItemNumber);
                            }
                        }
                    }
                }
                //unit price mismatch with default pricebookentry
                if(orderMap.get(ilist.OrderId).Sales_Sold_To_Account__c!=null && orderMap.get(ilist.OrderId).type!='Non Commercial Order' && accRecord.Core_Direct_Distributor_Channel_Nm__c=='01' && ilist.UnitPriceForceOverride__c==null && (ilist.UnitPrice!=pbEntryMap.get(ilist.PricebookEntryId).UnitPrice) && (!columnOrderItemList.contains(ilist.OrderItemNumber)) && columnCheck==false){
                    System.debug('Inside direct change');
                     orderItemList.add(ilist.OrderItemNumber);
                }
            }
        }
        System.debug('warningMsg>>'+warningMsg);
        if(orderItemList.size()>0){
            for(OrderItem ilist : [Select Id , OrderItemNumber,PricebookEntryId,Product2Id,UnitPrice,OrderId,UnitPriceForceOverride__c from OrderItem where OrderItemNumber IN:orderItemList and Product2Id IN:productIdSet and OrderId IN:orderMap.keySet()]){
                ilist.Sales_IsRecalculated__c = true; 
                orderItemToUpdateList.add(ilist);
            }
        } 
		if(orderItemToUpdateList.size()>0){
            System.debug('Inside update>>'+orderItemToUpdateList);
                update orderItemToUpdateList;
            	warningMsg = 'Success';
        }
        
		return warningMsg;
    }
}