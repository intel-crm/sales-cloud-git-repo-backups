public class CRM_ShowRecordsDash {
    @AuraEnabled
    public static List<Dashboard> UserDashboard(List<UserEmails> Emails){
        //List<Id> OWnID = new List<Id>();
        List<Dashboard> DashID = new List<Dashboard>();
        User usID = [SELECT Id FROM user WHERE email=: Emails[0].FromUserEmail];
        DashID = [SELECT Id, DeveloperName,FolderName,  CreatedDate,CreatedBy.Name,CreatedBy.IsActive,CreatedBy.Profile.Name FROM Dashboard where CreatedById =: usID.Id];
        //OWnID.add(usID.Id);
        return DashID;
    }
    public class UserEmails {
        @InvocableVariable(required=true)
        public String FromUserEmail;
        
    }
    
}