/*********************************************************************************************************************
Class Name    : Sales_ContractMerge
Version       : 1.0
Created Date  : March 2022
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           23-Mar-2022           TWC3144-308 :SPIKE: Contract Merge
* *********************************************************************************************************************/
public without sharing class Sales_ContractMerge {
    public static void updateContractOnLicenses(List<String> licenseIds,Id targetContractId){
        Set<Id> licIds = new Set<Id>();
        Set<Id> ordProdIds = new Set<Id>();
        Set<Id> sourceContractIds =  new Set<Id>();
        Set<Id> productIds =  new Set<Id>();
        Set<Id> subsTerminate = new Set<Id>();
        Set<Id> contractRecords = new Set<Id>();
        Set<Id> corpProdIds = new Set<Id>();
        Set<Id> swipContractIds = new Set<Id>();
        Set<Id> targetProducts = new Set<Id>();
        List<Sales_License__c> licUpdateList = new List<Sales_License__c>();
        List<Sales_License_Order_Product__c> licOrdProdList = new List<Sales_License_Order_Product__c>();
        List<OrderItem> ordProdList = new List<OrderItem>();
        List<SBQQ__Subscription__c> targetSubsList = new List<SBQQ__Subscription__c>();
        Map<Id,SBQQ__Subscription__c> prodSubscMap = new Map<Id,SBQQ__Subscription__c>();
        Map<Id,Sales_License__c> sourceLiContMap = new Map<Id,Sales_License__c>();
        Map<String,SBQQ__Subscription__c> corpSubsTargetContract = new Map<String,SBQQ__Subscription__c>();
        Map<String,Id> corpFeatureMap = new Map<String,Id>();
        String corpOPN ;
        for(Sales_License__c lic : [Select id,Name,Sales_License_Contract__c,Sales_License_Product__c,Sales_License_Order_Product__c from Sales_License__c where ID IN:licenseIds or Name IN:licenseIds]){
            sourceLiContMap.put(lic.Id,lic); 
            licIds.add(lic.Id);
            ordProdIds.add(lic.Sales_License_Order_Product__c); 
            sourceContractIds.add(lic.Sales_License_Contract__c); 
            contractRecords.add(lic.Sales_License_Contract__c);
            productIds.add(lic.Sales_License_Product__c);
            lic.Sales_License_Contract__c = targetContractId;
            licUpdateList.add(lic);
        }
        if(targetContractId!=null){
            contractRecords.add(targetContractId);
        }
        for(Sales_License_Order_Product__c licOrdProd : [Select Id,Name,Sales_License__c,Sales_License_ContractId__c from Sales_License_Order_Product__c where Sales_License__c IN:licIds]){
            if(licOrdProd.Sales_License_ContractId__c==sourceLiContMap.get(licOrdProd.Sales_License__c).Sales_License_Contract__c){
                licOrdProd.Sales_License_ContractId__c = targetContractId;
                licOrdProdList.add(licOrdProd); 
            }
        }
        for(OrderItem oi : [SELECT Id,OrderId,SBQQ__Contract__c from OrderItem where Id IN: ordProdIds]){
            oi.SBQQ__Contract__c = targetContractId;
            ordProdList.add(oi);
        }
        for(SBQQ__Subscription__c subs :[Select id ,Name,SBQQ__Contract__c,SBQQ__Contract__r.StartDate,SBQQ__Product__c,SBQQ__Product__r.Core_OPN__c,SBQQ__Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,SBQQ__Quantity__c,SBQQ__BundledQuantity__c,SBQQ__RenewalQuantity__c,SBQQ__RequiredByProduct__c,SBQQ__RequiredById__c,SBQQ__DynamicOptionId__c,SBQQ__TerminatedDate__c from SBQQ__Subscription__c where SBQQ__Contract__c IN:contractRecords]){
            if(sourceContractIds.contains(subs.SBQQ__Contract__c) && productIds.contains(subs.SBQQ__Product__c)){
                prodSubscMap.put(subs.SBQQ__Product__c,subs);
            }
            else if(subs.SBQQ__Contract__c == targetContractId && subs.SBQQ__Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =='CORPORATE' && subs.SBQQ__TerminatedDate__c==null ){
                if(subs.SBQQ__Product__r.Core_OPN__c=='SWIP-BUNDLE'){
                    swipContractIds.add(subs.SBQQ__Contract__c);
                }
                corpSubsTargetContract.put(subs.SBQQ__Product__r.Core_OPN__c,subs);
                corpProdIds.add(subs.SBQQ__Product__c);
            }
            else if(subs.SBQQ__Contract__c == targetContractId){
                targetProducts.add(subs.SBQQ__Product__c);
            }
        }
        for(SBQQ__ProductFeature__c prodFeature : [Select id,Name,SBQQ__ConfiguredSKU__c,SBQQ__ConfiguredSKU__r.Core_OPN__c from SBQQ__ProductFeature__c where SBQQ__ConfiguredSKU__c IN:corpProdIds] ){
            corpFeatureMap.put(prodFeature.SBQQ__ConfiguredSKU__r.Core_OPN__c,prodFeature.Id);
        }
        for(SBQQ__Subscription__c subs :[Select id ,Name,SBQQ__Contract__c,SBQQ__Contract__r.StartDate,SBQQ__Contract__r.EndDate,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,SBQQ__Product__c,SBQQ__Product__r.Core_OPN__c,SBQQ__Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,SBQQ__Quantity__c,SBQQ__BundledQuantity__c,SBQQ__RenewalQuantity__c,SBQQ__RequiredByProduct__c,SBQQ__RequiredById__c,SBQQ__DynamicOptionId__c,SBQQ__TerminatedDate__c from SBQQ__Subscription__c where SBQQ__Contract__c IN:contractRecords ]){
            if( subs.SBQQ__Contract__c == targetContractId && prodSubscMap.containsKey(subs.SBQQ__Product__c)){
                if(subs.SBQQ__TerminatedDate__c != null){
                    subs.SBQQ__TerminatedDate__c = null;
                    subs.SBQQ__RenewalQuantity__c = prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Quantity__c;
                    if(subs.SBQQ__BundledQuantity__c!=null){
                        subs.SBQQ__BundledQuantity__c = prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Quantity__c;
                    }
                    subs.SBQQ__Quantity__c = prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Quantity__c;
                }
                else{
                    if(subs.SBQQ__BundledQuantity__c!=null){
                        subs.SBQQ__BundledQuantity__c = subs.SBQQ__BundledQuantity__c + prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Quantity__c;
                    }
                    if(subs.SBQQ__RenewalQuantity__c!=null){
                        subs.SBQQ__RenewalQuantity__c = subs.SBQQ__RenewalQuantity__c + prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Quantity__c;
                    }
                    subs.SBQQ__Quantity__c = subs.SBQQ__Quantity__c + prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Quantity__c;
                }
                subsTerminate.add(subs.SBQQ__Product__c);
            }
            else if((prodSubscMap.containsKey(subs.SBQQ__Product__c) || subsTerminate.contains(subs.SBQQ__Product__c)) && targetProducts.contains(subs.SBQQ__Product__c) && subs.SBQQ__Contract__c != targetContractId){
                subs.SBQQ__TerminatedDate__c = prodSubscMap.get(subs.SBQQ__Product__c).SBQQ__Contract__r.StartDate;
            }
            else if(!(targetProducts.contains(subs.SBQQ__Product__c)) && (prodSubscMap.containsKey(subs.SBQQ__Product__c)) && subs.SBQQ__Contract__c != targetContractId ){
                if(subs.SBQQ__Product__r.Core_OPN__c.startsWith('SW-') && (swipContractIds.isEmpty()) && corpSubsTargetContract.containsKey('SW-CORPORATE')){
                    corpOPN = 'SW-CORPORATE';
                }
                else if(subs.SBQQ__Product__r.Core_OPN__c.startsWith('IP-') && (swipContractIds.isEmpty()) && corpSubsTargetContract.containsKey('IP-CORPORATE') ){
                    corpOPN = 'IP-CORPORATE';
                }
                else if((subs.SBQQ__Product__r.Core_OPN__c.startsWith('SW-')) && (swipContractIds.isEmpty()) && !(corpSubsTargetContract.containsKey('SW-CORPORATE')) ){
                    corpOPN = 'IP-CORPORATE';
                }
                else if((subs.SBQQ__Product__r.Core_OPN__c.startsWith('IP-')) && (swipContractIds.isEmpty()) && !(corpSubsTargetContract.containsKey('IP-CORPORATE')) ){
                    corpOPN = 'SW-CORPORATE';
                }
                else if((subs.SBQQ__Product__r.Core_OPN__c.startsWith('SW-') || subs.SBQQ__Product__r.Core_OPN__c.startsWith('IP-')) && !(swipContractIds.isEmpty())  ){
                    corpOPN = 'SWIP-BUNDLE';
                }
                if( corpSubsTargetContract.containsKey(corpOPN) && corpSubsTargetContract.get(corpOPN).SBQQ__Contract__c!=null && !(corpProdIds.contains(subs.SBQQ__Product__c))){
                    subs.SBQQ__Contract__c = targetContractId;
                    subs.SBQQ__RequiredByProduct__c = corpSubsTargetContract.get(corpOPN).SBQQ__Product__c;
                    subs.SBQQ__RequiredById__c = corpSubsTargetContract.get(corpOPN).Id;  
                    subs.SBQQ__SubscriptionStartDate__c = subs.SBQQ__Contract__r.StartDate;
                    subs.SBQQ__SubscriptionEndDate__c = subs.SBQQ__Contract__r.EndDate;
                    if(!(corpFeatureMap.isEmpty())){
                        subs.SBQQ__DynamicOptionId__c = corpFeatureMap.get(corpOPN)+':'+subs.SBQQ__Product__c;
                    }    
                }
                else if(!(corpSubsTargetContract.containsKey(corpOPN))  && !(corpProdIds.contains(subs.SBQQ__Product__c))){
                    subs.SBQQ__Contract__c = targetContractId;
                    subs.SBQQ__SubscriptionStartDate__c = subs.SBQQ__Contract__r.StartDate;
                    subs.SBQQ__SubscriptionEndDate__c = subs.SBQQ__Contract__r.EndDate;
                }
            }    
            targetSubsList.add(subs);
        }
        if(licUpdateList.size() > 0){
            update licUpdateList;  
        }
        if(licOrdProdList.size() > 0){
            update licOrdProdList;
        }
        if(ordProdList.size() > 0){
            update ordProdList;
        }
        if(targetSubsList.size() > 0){
            update targetSubsList;
        }
    }
    public static void corporateSubscriptionCreation(Id corpId, Id contractId){
        Map<Id,Contract> contractMap = new Map<Id,Contract>([Select id,ContractNumber, AccountId, StartDate, EndDate from Contract where Id =:contractId]);
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Contract__c = contractId;
        subs.SBQQ__Product__c = corpId;
        subs.SBQQ__Bundle__c = TRUE;
        subs.SBQQ__Quantity__c = 1;
        subs.SBQQ__RenewalQuantity__c = 1;
        subs.SBQQ__BundledQuantity__c = 1;
        subs.SBQQ__ProductSubscriptionType__c = 'Renewable';
        subs.SBQQ__SubscriptionType__c = 'Renewable';
        subs.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        subs.SBQQ__SubscriptionStartDate__c = contractMap.get(contractId).StartDate ;
        subs.SBQQ__SubscriptionEndDate__c = contractMap.get(contractId).EndDate ;
        subs.SBQQ__Account__c = contractMap.get(contractId).AccountId ;
        subs.SBQQ__PricingMethod__c = 'List';
        subs.SBQQ__CustomerPrice__c = 0;
        subs.SBQQ__ListPrice__c = 0;
        subs.SBQQ__RegularPrice__c = 0;
        subs.SBQQ__SpecialPrice__c = 0;
        subsList.add(subs);
        if(subsList.size()>0){
            insert subsList;
        }    
    }
    public static void updateNonCorpSubscription(Id contractId, Id corpId,Id corpTargetSubscription,Id corpFeatureId){
        List<String> dynamicOptionProd = new List<String>();
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c subs :[Select id ,Name,SBQQ__Contract__c,SBQQ__Product__c,SBQQ__RequiredByProduct__c,SBQQ__RequiredById__c,SBQQ__DynamicOptionId__c,SBQQ__TerminatedDate__c from SBQQ__Subscription__c where SBQQ__Contract__c =:contractId and SBQQ__Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c != 'CORPORATE' ]){
            subs.SBQQ__RequiredByProduct__c = corpId;
            subs.SBQQ__RequiredById__c = corpTargetSubscription;
            if(subs.SBQQ__DynamicOptionId__c!=null){
                dynamicOptionProd = subs.SBQQ__DynamicOptionId__c.split(':');
                subs.SBQQ__DynamicOptionId__c = corpFeatureId+':'+dynamicOptionProd[1];
            }
            subsList.add(subs);
            dynamicOptionProd.clear();
        } 
        if(subsList.size()>0){
            update subsList;
        }
    }
}