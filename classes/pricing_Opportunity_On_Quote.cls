public with sharing class pricing_Opportunity_On_Quote {
    
    @AuraEnabled(cacheable=true)
    public static String getOpportunityRecordTypeId(){
        Schema.DescribeSObjectResult oppo = Opportunity.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordType = oppo.getRecordTypeInfos();
        return JSON.serialize(recordType);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isAEorFSEUser(){
        return userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_TenderUser,
            Label.Pricing_Tender_PermissionSets_TenderAccountExecutive}) ? true : false;
    }

    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : UserInfo.getUserId() AND PermissionSet.Name IN: permissionSets
                        ];
        return count > 0;
    }
}