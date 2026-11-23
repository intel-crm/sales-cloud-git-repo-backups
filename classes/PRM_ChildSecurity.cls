public with sharing class PRM_ChildSecurity {

    public static list<PRM_Security_Test__c> getRecords(){
        List<PRM_Security_Test__c> securityTestData = new List<PRM_Security_Test__c>();
        //if(PRM_Security_Test__c.SObjectType.getDescribe().isAccessible()){
            securityTestData = [Select id, Name from PRM_Security_Test__c order by createdDate Asc];
        //}
        return securityTestData;
    }
}