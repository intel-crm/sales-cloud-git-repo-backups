public without sharing class Core_IPS_UserHelper {

    public static List<User> getUsers(
        Set<Id> accountIds,
        Set<Id> excludeContactIds,
        Integer limitSize,
        Integer offset,
        String fetchType
    ){
        if(fetchType == 'Load Data'){
            return [
                SELECT Id, ContactId,
                       Contact.FirstName, Contact.LastName,
                       Contact.Email, Contact.Account.Name
                FROM User
                WHERE Contact.Core_IPS_Active__c = true
                AND AccountId IN :accountIds
                AND ContactId NOT IN :excludeContactIds
                LIMIT :limitSize OFFSET :offset
            ];
        } else {
            return [
                SELECT Id, ContactId,
                       Contact.FirstName, Contact.LastName,
                       Contact.Email, Contact.Account.Name
                FROM User
                WHERE Contact.Core_IPS_Active__c = true
                AND AccountId IN :accountIds
                AND ContactId NOT IN :excludeContactIds
            ];
        }
    }
    // 🔥 NEW: Insert method (without sharing)
    public static String insertProjectMembersHelper(List<Core_IPS_Project_Member__c> records){
        try{
            insert records;
            return 'Success';
        } catch (Exception e){
            System.debug('Insert Error: ' + e.getMessage());
            return 'exception: ' + e.getMessage();
        }
    }
}