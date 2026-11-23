trigger CRM_share_of_Wallet_Trigger on CRM_share_of_Wallet__c (after insert, after delete, after update) {
Set<Id> accountPlanIds = new Set<Id>();
    
    // Collect the Account Plan IDs from the Custom Object records
    for (CRM_Share_of_Wallet__c obj : Trigger.isDelete ? Trigger.old : Trigger.new) {
        if (obj.CRM_Account_Plan__c != null) {
            accountPlanIds.add(obj.CRM_Account_Plan__c);
        }
    }

    // Update the count field on the Account Plan object
    List<AccountPlan> accountPlansToUpdate = [SELECT Id, CRM_SOW_count__c FROM AccountPlan WHERE Id IN :accountPlanIds];

    for (AccountPlan plan : accountPlansToUpdate) {
        plan.CRM_SOW_count__c = [SELECT COUNT() FROM CRM_Share_of_Wallet__c WHERE CRM_Account_Plan__c = :plan.Id];
    }
    
    update accountPlansToUpdate;

}