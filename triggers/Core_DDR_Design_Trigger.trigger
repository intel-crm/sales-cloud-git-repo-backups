trigger Core_DDR_Design_Trigger on Core_Design_Registration__c (before insert, before update, after insert, after update)
{

    User loginUser = new User();

    if(Trigger.isInsert)
    {
        if(Trigger.isBefore)
        {
        
            loginUser = [SELECT id, Name,Contact.Account.Id,Contact.Account.BillingCountry,Contact.Account.BillingState from USER WHERE ID=:UserInfo.getUserId() limit 1];  
        
            Core_DDR_Design_Handler.processBeforeInsert(trigger.old, trigger.new, trigger.oldMap, trigger.newMap, loginUser);
        }
        else
        {
            Core_DDR_Design_Handler.processAfterInsert(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        }
        
    
    }
    else if(Trigger.isUpdate)
    {
    
        if(Trigger.isBefore)
        {
        
            loginUser = [SELECT id, Name,Contact.Account.Id,Contact.Account.BillingCountry,Contact.Account.BillingState from USER WHERE ID=:UserInfo.getUserId() limit 1];  
        
            Core_DDR_Design_Handler.processBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap, loginUser);
        }
        else
        {
            Core_DDR_Design_Handler.processAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
            Core_DDR_Design_Handler.postApprovalFromResubmittedDR(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        }
        
    }
}