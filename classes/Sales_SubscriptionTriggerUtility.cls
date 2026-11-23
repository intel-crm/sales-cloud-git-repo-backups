/*********************************************************************************************************************
Class Name    : Sales_SubscriptionTriggerUtility
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           11-Jan-2021              Subscription Trigger Utility  
* Shivam Vishwakarma          12-Feb-2021              US919632: Changed field API Name
* *********************************************************************************************************************/
public class Sales_SubscriptionTriggerUtility{
    
    //Added by Nilesh as part of US862291 for order activation code generation      
    /*
    public static void createOrderActCode(List<SBQQ__Subscription__c> subscriptionList){
        Set<Id> orderProductIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Map<Id, Order> orderMap = new Map<Id,Order>();
        Map<Id,OrderItem> orderProductMap = new Map<Id,OrderItem>();
        List<SBQQ__Subscription__c> newSubscriptionList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c subList: subscriptionList){
            orderIdSet.add(subList.Core_PSG_Order__c);
            orderProductIdSet.add(subList.SBQQ__OrderProduct__c);
        }
        orderMap = new Map<Id,Order>([Select Id,Type from Order where Id IN:orderIdSet ]);
        orderProductMap = new Map<Id,OrderItem>([Select Id,OrderItemNumber from OrderItem where Id IN:orderProductIdSet and OrderId IN: orderIdSet]);
        for(SBQQ__Subscription__c subs :subscriptionList){
            if(orderMap.containsKey(subs.Core_PSG_Order__c) && orderProductMap.containsKey(subs.SBQQ__OrderProduct__c)){
                if(orderMap.get(subs.Core_PSG_Order__c).Type !=null){
                    String val = 'TBD'+''+orderProductMap.get(subs.SBQQ__OrderProduct__c).OrderItemNumber +''+Math.round((Math.random() * (900000) + 100000));
                    
                    subs.Sales_License_Activation_Code__c = val;    //Previously subs.Core_PSG_License_Activation_Code__c = val; - Changed as part of US919632
                    
                }   
            }
        }
    }
    
    public static void updateSubscriptionStartEndDate(List<SBQQ__Subscription__c> subscriptionList){
        Set<Id> orderProductIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        Map<Id, Order> orderMap = new Map<Id,Order>();
        System.debug('@@Subscription'+subscriptionList);
        //Map<Id,OrderItem> orderProductMap = new Map<Id,OrderItem>();
        Map<Id,Product2> productMap = new Map<Id,Product2>();
        for(SBQQ__Subscription__c subList: subscriptionList){
            orderIdSet.add(subList.Core_PSG_Order__c);
            productIdSet.add(subList.SBQQ__Product__c);
        }
        //Previously(changed for US919632) for(Order ord : [Select Id ,Type,Core_PSG_Order_Sub_Type__c, Status,status__c,Core_PSG_Order_Reason__c from Order where Id IN:orderIdSet]) 
        for(Order ord : [Select Id ,Type,Sales_Order_Sub_Type__c, Status,Sales_status__c,Sales_Order_Reason__c from Order where Id IN:orderIdSet]){
            orderMap.put(ord.Id,ord);
        }
        for(Product2 prod : [Select Id , Core_PSG_License__r.PSG_Product_Expiration_Duration_Nbr__c,Core_PSG_License__r.PSG_Maintenance_Duration_Nbr__c  from Product2 where Id IN:productIdSet]){ //If uncommented - Update to Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c
            productMap.put(prod.Id,prod);
        }
        // Map<Id,SBQQ__Subscription__c> sublist = Sales_SubscriptionValidationUtility.subscriptionStartDateUpdate(subscriptionList,productMap);
        for(SBQQ__Subscription__c subList: subscriptionList){
            System.debug('Inside for'+subList);
            if(subList.SBQQ__SubscriptionStartDate__c!=null){
                 System.debug('Inside if'+subList.SBQQ__SubscriptionStartDate__c);
                //Previously(changed for US919632) if(orderMap.get(subList.Core_PSG_Order__c).Core_PSG_Order_Sub_Type__c == 'Corporate Order' && orderMap.get(subList.Core_PSG_Order__c).Core_PSG_Order_Reason__c=='Non Stocking Order'){ - US919632
                Integer productexp = Integer.valueOf(productMap.get(subList.SBQQ__Product__c).Core_PSG_License__r.PSG_Product_Expiration_Duration_Nbr__c); //If uncommented - Update to Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c
                Date result = subList.SBQQ__SubscriptionStartDate__c.addDays(productexp);
                Integer numberOfDays = Date.daysInMonth(result.year(), result.month());
                Date lastDayOfMonth = Date.newInstance(result.year(), result.month(), numberOfDays);
                Datetime dt = datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(),lastDayOfMonth.day());
                subList.Sales_Expiration_Date_Dtm__c = dt ; //Previously was subList.Core_PSG_Expiration_Date_Dtm__c = dt ; - Changed as part of US919632
                
                Integer maintduration = Integer.valueOf(productMap.get(subList.SBQQ__Product__c).Core_PSG_License__r.PSG_Maintenance_Duration_Nbr__c ); 
                Date mainresult = subList.SBQQ__SubscriptionStartDate__c.addMonths(maintduration);
                Integer MaintnumberOfDays = Date.daysInMonth(mainresult.year(), mainresult.month());
                Date MaintlastDayOfMonth = Date.newInstance(mainresult.year(), mainresult.month(), MaintnumberOfDays);
                subList.Sales_Maintenance_Expiration_Dt__c = MaintlastDayOfMonth;   //Previously was subList.Core_PSG_Maintainence_Expiration_Dt__c = MaintlastDayOfMonth;  -US919632
                
            } 
        }
    }
    */
    public static void updateSubscriptionLicenses(List<SBQQ__Subscription__c> subsList){
    /*
        try{
            Map<Id, SBQQ__Subscription__c> orderProdSubscriptionMap = new Map<Id, SBQQ__Subscription__c>();
            SBQQ__Subscription__c sub;     
            List<Sales_License__c> licList = new List<Sales_License__c>();
            List<Sales_Subscription_License__c> subLicenseList = new List<Sales_Subscription_License__c>();
            
            for(SBQQ__Subscription__c subcription: subsList){
                orderProdSubscriptionMap.put(subcription.SBQQ__OrderProduct__c, subcription);
            }
            system.debug('orderProdSubscriptionMap'+orderProdSubscriptionMap);
            for(Sales_Subscription_License__c subLic: [Select Id,Sales_License_Subscription__c, Sales_License__c, Sales_License__r.Sales_License_Order_Product__c from Sales_Subscription_License__c where Sales_License__r.Sales_License_Order_Product__c IN: orderProdSubscriptionMap.keyset()]){
                sub =  orderProdSubscriptionMap.get(subLic.Sales_License__r.Sales_License_Order_Product__c);                       
                subLic.Sales_License_Subscription__c = sub.id;           
                subLicenseList.add(subLic);
                
                Sales_License__c lic = new Sales_License__c();
                lic.id = subLic.Sales_License__c;
                lic.Sales_License_SubscriptionId__c =sub.id;
                
                licList.add(lic);
            }
            if(subLicenseList.size() > 0){
                update subLicenseList;
            }
            
            if(licList.size() > 0){
                update licList;
            }
            
        }catch(Exception e){
           System.debug('Subscription License creation failed due to error:'+e.getMessage()); 
        } */
    }
}