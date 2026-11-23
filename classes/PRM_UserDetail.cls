public without sharing class PRM_UserDetail {
    @AuraEnabled(cacheable=true)
    public static String contactPrefferedLanguage(){
    //system.debug('crrUserId-->'+crrUserId);
        User u;
        Contact con;
        u = [Select id,Name,ContactId From User where id=:UserInfo.getUserId()];
        if(u.ContactId!=null)
        { con = [Select Id,/*Name,*/Core_Preferred_Language__c From Contact where Id =:u.ContactId]; }//ATHR Fix - TWC729-9556 - SJ
        if(con!=null && con.Core_Preferred_Language__c!=null) 
        { return con.Core_Preferred_Language__c; }
        
        return null;
    }
}