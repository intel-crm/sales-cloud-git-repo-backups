public without sharing class CRM_ShowRecords_inFlow {
    @InvocableMethod
    public static List<Id> UserReports(List<UserEmails> Emails){
        List<Id> OWnID = new List<Id>();
        User usID = [SELECT Id FROM user WHERE email=: Emails[0].FromUserEmail];
        OWnID.add(usID.Id);
        return OWnID;
    }
    public class UserEmails {
        @InvocableVariable(required=true)
        public String FromUserEmail;
       
    }
    
}