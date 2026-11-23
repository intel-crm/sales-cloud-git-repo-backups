public without sharing class CRM_AccountPlanController {
   @AuraEnabled(cacheable=true)
    public static AccountPlan getAccountPlan(Id recordId) {
        system.debug('line 4');
        return [SELECT id,Name, Core_Market_Cap__c, Core_Revenue__c, Core_Net_Income__c, 
                       Core_Account_Revenue__c, Core_Employees__c
                FROM AccountPlan               
                WHERE Id = :recordId
                LIMIT 1];
    }
    
     @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getAccountPlanRevenue(Id accountPlanId) {
       return [
            SELECT CRM_BU__c , SUM(CRM_Account_Potential_Revenue__c) totalRevenue
            FROM CRM_Intel_Account_Plan_Rev__c
            WHERE CRM_Account_Plan__c = :accountPlanId
            GROUP BY CRM_BU__c
            
        ];

    }
	@AuraEnabled
	public static void updateSWOT(AccountPlan accountPlan) {
    update accountPlan;
}
@AuraEnabled(cacheable=true)
public static AccountPlan getSWOTFields(Id recordId) {
    return [SELECT RelationshipStrengths, RelationshipOpportunities, RelationshipWeaknesses, RelationshipThreats FROM AccountPlan WHERE Id = :recordId LIMIT 1];
}    
}