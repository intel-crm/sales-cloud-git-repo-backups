/*********************************************************************************************************************
Apex Class Name  : PRM_UserDetail
Version       : 1.0
Created Date  : August 2022
Function      : contactPrefferedLanguage

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Utkarsh                 11/08/2022              This class is server side controller for ipaSupportFooterComponent and returns loggedin user preferred language .

*********************************************************************************************************************/
public without sharing class PRM_UserDetail {
    @AuraEnabled(cacheable=true)
    public static String contactPrefferedLanguage(){
        User u;
        Contact con;
        u = [Select id,Name,ContactId From User where id=:UserInfo.getUserId()];
        con = [Select Id,Name,Core_Preferred_Language__c From Contact where Id =:u.ContactId];
        //system.debug('con.Core_Preferred_Language__c-->'+con.Core_Preferred_Language__c);
        return con.Core_Preferred_Language__c;
    }
}