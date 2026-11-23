/**
* @File Name : CRM_UserPillContainerController .cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : February 24, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 24, 2025 |   | Initial Version
**/

/*public class CRM_UserPillContainerController  {
	@AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchTerm) {
        return [SELECT Id, Name FROM User WHERE IsActive = true AND Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }
}*/


public with sharing class CRM_UserPillContainerController {
    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchTerm) {
        return [SELECT Id, Name FROM User WHERE IsActive = true AND Name LIKE :('%' + searchTerm + '%') LIMIT 10];
    }
}