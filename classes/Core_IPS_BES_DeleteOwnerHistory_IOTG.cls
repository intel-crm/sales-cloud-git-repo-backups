public with sharing class Core_IPS_BES_DeleteOwnerHistory_IOTG {
    public static void deleteOwnerHistory(List<case> casesForIOTG){
        List<String> caseIds = new List<String>();
        for(Case caseObj: casesForIOTG){
            if(caseObj.Core_IPS_New_Backend_System__r.Name == 'EMBED - HSDES IoT Platform'){
                caseIds.add(caseObj.Id);
            }
        }
        if(caseIds.size() > 0){
            List<CaseHistory> caseHistory = [SELECT Id, IsDeleted, CaseId, CreatedById, CreatedDate, Field, DataType, OldValue, NewValue from CaseHistory WHERE CaseId IN : caseIds AND (Field = 'Owner' OR Field='Core_IPS_Assigned_Queue__c' OR Field = 'ownerAssignment') AND CreatedBy.Name LIKE '%Backend Integration%' ] ;
            Database.delete(caseHistory);
        }
    }
}