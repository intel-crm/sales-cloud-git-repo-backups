/****************************************************************************************************
Apex Class Name : ForwardCostTriggerHandler
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Trigger Handler class for Forward Cost trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
@isTest
public class ForwardCostTriggerHandler {
    /*extends TriggerHandler{
    public List<price_forward_cost__c> psgTriggerNewList = new List<price_forward_cost__c>();
    public Map<Id,price_forward_cost__c> psgTriggerOldMap = new Map<Id,price_forward_cost__c>();
    
    public forwardCostTriggerHandler(){
        Id psgFCRecordTypeId =  Schema.SObjectType.price_forward_cost__c.getRecordTypeInfosByDeveloperName().get(Label.PSG_Forward_Cost_Record_Type).getRecordTypeId();
        for(price_forward_cost__c forwCost : (List<price_forward_cost__c>)Trigger.new){
            if(forwCost.RecordTypeId == psgFCRecordTypeId){
                psgTriggerNewList.add(forwCost);
            }
            if(Trigger.oldMap != null){
                psgTriggerOldMap.put(forwCost.Id,(price_forward_cost__c)Trigger.oldMap.get(forwCost.Id));
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : beforeInsert
    *Created Date: 08/13/2021
    *Author: Hema
    *Description : Performs operations on before insert context of trigger.
    ************************************************************************************************************/
    /*public override void beforeInsert() {
        if(!psgTriggerNewList.isEmpty()){
            PSG_ForwardCostBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
        }
    }*/
    
    /************************************************************************************************************
    *Method Name : beforeUpdate
    *Created Date: 08/13/2021
    *Author: Hema
    *Description : Performs operations on before Update context of trigger.
    ************************************************************************************************************/
    /*public override void beforeUpdate() {
        if(!psgTriggerNewList.isEmpty()){
            PSG_ForwardCostBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
        }
    }*/
    
}