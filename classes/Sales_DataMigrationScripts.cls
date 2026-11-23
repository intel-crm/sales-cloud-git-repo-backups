/*********************************************************************************************************************
Class Name    : Sales_DataMigrationScripts
Version       : 1.0
Created Date  : July 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma         6 July 2021            Class to store all Data Migration related Scripts
* *********************************************************************************************************************/
public class Sales_DataMigrationScripts {

    /**************************************************
Method Name : createSubscriptionRecordsForContract
Function    : creating subscription records for the contracts migrated
Developer   : Nilesh Mithapelli
********************************************************/
    public static void createSubscriptionRecordsForContract(){
        //List<Contract> contractList = [Select Id ,AccountId,Name,Sales_Account_Name_Txt__c,SBQQ__Order__c,SBQQ__Quote__c from Contract where Sales_Legacy_Contract_Id__c!=null Order by CreatedDate desc];
        Map<Id,Id> orderToContractMap = new Map<Id,Id>();
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        List<OrderItem> ordItemList = new List<OrderItem>();
      //  List<SBQQ__Subscription__c> subList = new  List<SBQQ__Subscription__c>();
        Map<Id,Sales_License_Order_Product__c> licenseOrderProdMap = new Map<Id,Sales_License_Order_Product__c>();
        Map<Id,OrderItem> ordItemMap = new Map<Id,OrderItem>();
        List<SBQQ__Subscription__c> subscriptionToInsert =  new List<SBQQ__Subscription__c>();
        Set<Id> productIdSet = new Set<Id>();
        Map<Id,Decimal> LicenseQuantityMap = new Map<Id,Decimal>();	
        Map<Id,Core_Product_Ext_Attribute__c> productExtMap =  new Map<Id,Core_Product_Ext_Attribute__c>();
        for(Contract cont : [Select Id ,AccountId,Name,Sales_Account_Name_Txt__c,SBQQ__Order__c,SBQQ__Quote__c,EndDate,StartDate,Sales_Legacy_Contract_Id__c from Contract where Sales_Legacy_Contract_Id__c!=null]){
            orderToContractMap.put(cont.Id,cont.SBQQ__Order__c);
            contractMap.put(cont.Id,cont);
            System.debug('Contract map>>'+contractMap);
        }
        for(OrderItem ordItem : [Select id ,OrderId,SBQQ__QuoteLine__c, Quantity,Product2Id,SBQQ__Contract__c from OrderItem where SBQQ__Contract__c IN:orderToContractMap.keySet() and Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c='CORPORATE']){
            ordItemMap.put(ordItem.Id,ordItem);
           	List<SBQQ__Subscription__c> newSubscriptionList = new List<SBQQ__Subscription__c>();
          	newSubscriptionList = processSubscription(ordItem,contractMap);
          	subscriptionToInsert.addAll(newSubscriptionList);  
        }
      
        for(AggregateResult queryResult : [Select count(Sales_License_Quantity__c) Product_Quantity, Sales_License_Order__c, Sales_License_Product__c from Sales_License__c where Sales_License_Order__c IN:orderToContractMap.values()  group by Sales_License_Product__c,Sales_License_Order__c]){
            LicenseQuantityMap.put((Id)queryResult.get('Sales_License_Product__c'),(Decimal)(queryResult.get('Product_Quantity')));
        }
        
       if(subscriptionToInsert.size()>0){
            Database.SaveResult[] insertResult = Database.insert(subscriptionToInsert);
            System.debug(insertResult);
        }
    }
        
        private static List<SBQQ__Subscription__c> processSubscription(OrderItem ordItem,Map<Id,Contract> contractMap){
            List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
            SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
          	subs.SBQQ__OrderProduct__c = ordItem.Id; 
            subs.SBQQ__Contract__c = ordItem.SBQQ__Contract__c; 
           	subs.SBQQ__QuoteLine__c = ordItem.SBQQ__QuoteLine__c; 
            subs.SBQQ__Quantity__c = ordItem.Quantity;
            subs.SBQQ__SubscriptionStartDate__c = contractMap.get(ordItem.SBQQ__Contract__c).StartDate; 
            subs.SBQQ__SubscriptionEndDate__c = contractMap.get(ordItem.SBQQ__Contract__c).EndDate;
            subs.SBQQ__Account__c = contractMap.get(ordItem.SBQQ__Contract__c).AccountId;  
            subs.SBQQ__Product__c = ordItem.Product2Id;
            subList.add(subs);
            return subList;
        }
 }