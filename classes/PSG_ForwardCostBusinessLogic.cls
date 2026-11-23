/****************************************************************************************************
Apex Class Name : PSG_ForwardCostBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2021
Function        : This class is used used as part of Forward Cost trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_ForwardCostBusinessLogic {
    /************************************************************************************************************
	*Method Name : beforeInsertUpdateOperations
	*Created Date: 08/13/2021
	*Author: Hema
	*Description : Performs operations on before context of trigger.
	************************************************************************************************************/
    /*public static void beforeInsertUpdateOperations(List<price_forward_cost__c> newList,Map<Id,price_forward_cost__c> oldMap,Boolean isInsert){
        try{
            list<price_forward_cost__c> psgForwardCostList = new list<price_forward_cost__c>();
            set<String> productOPNSet = new set<String>(); 
            for(price_forward_cost__c fcObj : newList){
                fcObj.price_forward_cost_amt__c = fcObj.price_forward_cost_amt__c != null? fcObj.price_forward_cost_amt__c : 0;
                if(isInsert){
                    psgForwardCostList.add(fcObj);
                    /*if(fcObj.core_cpq_product_nm__c != null){
                        productIdSet.add(fcObj.core_cpq_product_nm__c);
                    }else if(fcObj.core_cpq_product_opn_txt__c != null){
                        productOPNSet.add(fcObj.core_cpq_product_opn_txt__c);
                    }else{
                        fcObj.addError('Product/OPN is mandatory.');
                    }
                    fcObj.core_cpq_unique_id__c = fcObj.Name + String.ValueOf(fcObj.core_cpq_product_opn_txt__c);
                    
                }else{
                    //if(fcObj.core_cpq_product_nm__c != oldMap.get(fcObj.Id).core_cpq_product_nm__c){
                    //if(fcObj.core_cpq_product_opn_txt__c != oldMap.get(fcObj.Id).core_cpq_product_opn_txt__c){
                    if(fcObj.core_cpq_product_opn_txt__c != null){                                   
                        psgForwardCostList.add(fcObj);
                        productOPNSet.add(fcObj.core_cpq_product_opn_txt__c);  
                    }
                    
                }
            }
            
            if(!psgForwardCostList.isEmpty()){
                //Map<Id,Product2> productMap = new Map<Id,Product2>();
                Map<String, Product2> productOPNWithProductMap = new Map<String,Product2>();
                for(Product2 prod : [SELECT Name, Core_OPN__c FROM Product2 WHERE /*Id =: productIdSet OR Core_OPN__c =: productOPNSet and IsActive = true and Core_Product_Type__c ='Intel® FPGAs' and Core_Product_Org__c ='Sales']){
                    /*if(prod.Core_OPN__c != null && productOPNSet.contains(prod.Core_OPN__c)){
                        productOPNWithProductMap.put(prod.Core_OPN__c,prod);
                    }
                    //productMap.put(prod.Id,prod);
                }                                                                                               
                for(price_forward_cost__c fcObj : psgForwardCostList){
                    if(fcObj.Name == null){
                        fcObj.addError('Forward Cost Name is mandatory.');
                    }                   
                    /*if(!productMap.isEmpty() && productMap.containsKey(fcObj.core_cpq_product_nm__c)){
                        fcObj.core_cpq_product_name_txt__c = productMap.get(fcObj.core_cpq_product_nm__c).Name;
                        fcObj.core_cpq_product_opn_txt__c = productMap.get(fcObj.core_cpq_product_nm__c).Core_OPN__c;                    
                    }*/
                    /*if(!productOPNSet.isEmpty()){
                        if(!productOPNWithProductMap.isEmpty() && productOPNWithProductMap.containsKey(fcObj.core_cpq_product_opn_txt__c)){
                            //fcObj.core_cpq_product_name_txt__c = productOPNWithProductMap.get(fcObj.core_cpq_product_opn_txt__c).Name;
                            //fcObj.core_cpq_product_nm__c = productOPNWithProductMap.get(fcObj.core_cpq_product_opn_txt__c).Id;
                            fcObj.core_cpq_product_opn_txt__c = productOPNWithProductMap.get(fcObj.core_cpq_product_opn_txt__c).Core_OPN__c;                    
                        }else{
                            fcObj.addError('Invalid OPN : '+fcObj.core_cpq_product_opn_txt__c);
                        }
                    }
                }            
            }       
        }
        catch(Exception ex){
            PSG_Utility.logError(ex);
        } 
    }*/
}