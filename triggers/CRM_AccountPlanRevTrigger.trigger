trigger CRM_AccountPlanRevTrigger on CRM_Intel_Account_Plan_Rev__c (after insert, after delete, after update) {
Set<Id> accountPlanIds = new Set<Id>();
    
    for (CRM_Intel_Account_Plan_Rev__c obj : Trigger.isDelete ? Trigger.old : Trigger.new) {
        if (obj.CRM_Account_Plan__c != null) {
            accountPlanIds.add(obj.CRM_Account_Plan__c);
        }
    }

    // Update the count field on the Account Plan object
    List<AccountPlan> accountPlansToUpdate = [SELECT Id, CRM_IAR_count__c FROM AccountPlan WHERE Id IN :accountPlanIds];

    for (AccountPlan plan : accountPlansToUpdate) {
        plan.CRM_IAR_count__c = [SELECT COUNT() FROM CRM_Intel_Account_Plan_Rev__c WHERE CRM_Account_Plan__c = :plan.Id];
    }
    
    update accountPlansToUpdate;
}