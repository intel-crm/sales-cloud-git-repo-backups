public with sharing class AccountPlanController {
    public AccountPlan accountPlan { get; set; }

    public AccountPlanController(ApexPages.StandardController controller) {
        Id recordId = controller.getId();
       system.debug('line 10 '+recordId);
        accountPlan = [SELECT Id, Name,account.name,owner.name
                       FROM AccountPlan 
                       WHERE Id = :recordId];
        
    }
}