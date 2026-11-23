/****************************************************************************************************
Apex Class Name : core_S2S_ViewICSCases
Version         : 1.0 
Test Class      : core_S2S_ViewICSCasesTest
Created Date    : 2024-03-28
Function        : Handle view functionality for ICS Case Management
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2024-07-19                Created
*****************************************************************************************************/
public without sharing class core_S2S_ViewICSCases {
    
    /************************************************************************************************************
    *Method Name : getReportData
    *Created Date: 2024-07-19
    *Author      : Bishal Singh
    *Description : Get list data based on Sales Cloud Account Id
    ************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SObject> getListViewData(String accountId, String userEmail,Integer limitSize,Integer offset){
        if (String.isBlank(accountId) && String.isBlank(userEmail)) {
            throw new AuraHandledException('Both accountId and userEmail cannot be null');
        }
        String query = 'SELECT ' + Label.View_ICS_Cases + ' FROM Case__x WHERE ';
        List<String> conditions = new List<String>();
        if (!String.isBlank(accountId)) {
            conditions.add('AccountId__r.Sales_Cloud_Id__c = :accountId');
            conditions.add('ICS_WR_Target_Contact_Center_c__c <> \'AAQ Contact Center\'');
        
        } else if (!String.isBlank(userEmail)) {
            conditions.add('ContactEmail__c = :userEmail and (ICS_WR_Target_Contact_Center_c__c = \'AAQ Contact Center\' OR Product__r.Name__c = \'IPA-Field\')');
        }
        query += String.join(conditions, ' AND ') + ' ORDER BY CreatedDate__c DESC LIMIT :limitSize OFFSET :offset';
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean hasAccess(String recordId,String userId){
        Id memberId = [SELECT Id FROM AccountTeamMember where AccountId =:recordId and UserId =: userId WITH SECURITY_ENFORCED]?.Id;
        if(memberId == null){
            memberId = [SELECT Id FROM Account WHERE Id =:recordId and OwnerId=:userId WITH SECURITY_ENFORCED]?.Id;
        }
        return memberId == null ? false : true;
    }
}