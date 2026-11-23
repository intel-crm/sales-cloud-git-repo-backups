public class deploymentChanges {
 @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User where id ='0052D000008JWGzQAO'];
    }
    
     @AuraEnabled
    public static List<SetupAuditTrail> getAuditTrail(Id userId) {
        return [SELECT Action, CreatedDate, Display, Section FROM SetupAuditTrail WHERE CreatedById = :userId limit 50];
    }
}