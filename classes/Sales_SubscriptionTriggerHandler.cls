/*********************************************************************************************************************
Class Name    : Sales_SubscriptionTriggerHandler
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           11-Jan-2021              Subscription Trigger Handler 
* *********************************************************************************************************************/
public class Sales_SubscriptionTriggerHandler extends TriggerHandler {
    
    //Added by Nilesh as part of US862291 for order activation code generation 
    public override void beforeInsert() {
        if(isActive('PSG_Subscription_Before_Insert_Trigger')) { 
            //Sales_SubscriptionTriggerUtility.createOrderActCode((List<SBQQ__Subscription__c>)Trigger.new);
         //  Sales_SubscriptionTriggerUtility.updateSubscriptionStartEndDate((List<SBQQ__Subscription__c>)Trigger.new);
        }
    }
    public override void afterInsert() {
        if(isActive('Sales_Subscription_After_Insert_Trigger')) {           
            //Sales_SubscriptionTriggerUtility.createOrderActCode((List<SBQQ__Subscription__c>)Trigger.new);
            Sales_SubscriptionTriggerUtility.updateSubscriptionLicenses((List<SBQQ__Subscription__c>)Trigger.new);           
        }
    }
    /* public override void beforeUpdate() {
        if(isActive('PSG_Subscription_Before_Insert_Trigger')) { 
            //Sales_SubscriptionTriggerUtility.createOrderActCode((List<SBQQ__Subscription__c>)Trigger.new);
           Sales_SubscriptionTriggerUtility.updateSubscriptionStartEndDate((List<SBQQ__Subscription__c>)Trigger.new);
        }
    }*/
    
        
}