/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_Utility
* Version     : 1.0 
* Created Date: 25-02-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************************************/

//The method should return list of users who do not want notification for the notification types they have selected in the record
//I have been receiving notification for A,B,C. I donot want to receive the notification for C 
public class Core_MDF_CCP_Utility {

    public static List<Id> subscriptionBasedNotification(String notificationType, String objectName, List<Id> usersList) {
        List<Id> finaListOfSubscribedUsers = new List<Id>();
        try{
        // Query to fetch user subscriptions who do not want notifications
        List<Core_MDF_User_Notification_Subscriptions__c> unsubscribedUsers = [SELECT  Id,Core_MDF_User_Id__c,Core_MDF_Object_nm__c, Core_MDF_Unsubscribed_nm__c
                                                                                FROM Core_MDF_User_Notification_Subscriptions__c
                                                                                WHERE Core_MDF_Object_nm__c = :objectName
                                                                                AND Core_MDF_Unsubscribed_nm__c includes (:notificationType)
                                                                                AND Core_MDF_User_Id__c IN :usersList
        ];
        
        // Create a set of user IDs who do not want notifications
        Set<Id> unsubscribedUserIds = new Set<Id>();
        for (Core_MDF_User_Notification_Subscriptions__c subscription : unsubscribedUsers) {
            unsubscribedUserIds.add(subscription.Core_MDF_User_Id__c);
        }
        System.debug('Unsubscribed Users---'+unsubscribedUserIds);
        // Iterate through the original usersList and add only those who are not in unsubscribedUserIds to finalList
        for (Id userId : usersList) {
            if (!unsubscribedUserIds.contains(userId)) {
                finaListOfSubscribedUsers.add(userId);
            }
        }
        System.debug('Final List Of Users---'+finaListOfSubscribedUsers);
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);} 
        return finaListOfSubscribedUsers;
    }
    
 }