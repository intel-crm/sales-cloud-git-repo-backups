public without sharing class core_AccountPlanRevenueController {
    @AuraEnabled(cacheable=true)
    public static List<CRM_Intel_Account_Plan_Rev__c> getAccountPlans(Id accountplanId) {
        return [SELECT Id, CRM_Year__c, CRM_BU__c, CRM_Account_Potential_Revenue__c FROM CRM_Intel_Account_Plan_Rev__c
 WHERE CRM_Account_Plan__c = :accountplanId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id accountPlanId) {
        AccountPlan accountPlan = [
            SELECT AccountId FROM AccountPlan WHERE Id = :accountPlanId LIMIT 1
        ];

        return [
            SELECT Id, Name,  OwnerId,Owner.Name, Core_Technical_Owner__c,Core_Technical_Owner__r.Name, Amount, CloseDate ,AccountId,Account.Name, StageName,Core_Approval_Status__c,Core_Push_Counter__c,Core_Total_Days_From_Creation__c
            FROM Opportunity 
            WHERE AccountId = :accountPlan.AccountId
            ORDER BY CloseDate DESC
        ];
    }
    @AuraEnabled(cacheable=false)
    public static AccountPlan getOpportunityDetails(Id recordId) {
        return [SELECT Id, Transformational_Opportunities__c, Transformational_Opportunities_Comment_N__c ,Transformational_Opportunities_Comment__c
                FROM AccountPlan 
                WHERE Id = :recordId 
                LIMIT 1];
    }
    @AuraEnabled(cacheable=false)
    public static AccountPlan getPreOpportunityDetail(Id recordId) {
        return [SELECT Id, Transformational_Opportunities__c,Transformational_Opportunities_Comment_N__c
                FROM AccountPlan 
                WHERE Id = :recordId 
                LIMIT 1];
    }
   @AuraEnabled(cacheable=false)
    public static Void saveOpportunityComments(Id recordId, List<Id> opportunitys, String comment) {
        String transOptyId = '';
        String htmlLinks = '';
        String opptyNames = '';
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        
        for(Opportunity OpptyName : [SELECT Id, Name FROM Opportunity where Id IN:opportunitys ORDER BY CloseDate DESC]){
            transOptyId = transOptyId + OpptyName.Id + ',';
            opptyNames = opptyNames +opptyName.Name+',';
            //htmlLinks += '<a href="'+baseUrl+'/lightning/r/Opportunity/' + OpptyName.Id + '/view" target="_blank">' + OpptyName.Name + '</a><br/>';
        }
        if (transOptyId.endsWith(',') || opptyNames.endsWith(',')) {
            transOptyId = transOptyId.substring(0, transOptyId.length() - 1);
            opptyNames = opptyNames.substring(0, opptyNames.length() - 1);
        }
        AccountPlan accPlanDetail = [SELECT Id, Transformational_Opportunities__c, Transformational_Opportunities_Comment_N__c,Transformational_Opportunities_Comment__c FROM AccountPlan WHERE Id = :recordId LIMIT 1]; 
        accPlanDetail.Transformational_Opportunities__c = transOptyId;
        //accPlanDetail.Transformational_Opportunities_Comment__c = opptyNames;
        accPlanDetail.Transformational_Opportunities_Comment_N__c = comment;
          
        upsert accPlanDetail;
    }
}