public with sharing class generateUserChanges {
    @AuraEnabled(cacheable=true)
    public static List<AuditTrailWrapper> getUserAuditTrail(String username){
        List<AuditTrailWrapper> auditTrails = new List<AuditTrailWrapper>();

        List<User> users = [SELECT Id, Username FROM User WHERE Username = :username LIMIT 1];

        if(!users.isEmpty()){
            User user = users[0];
            
            Date twoWeeksAgo = System.today().addDays(-14);

            List<SetupAuditTrail> setupAuditTrails = [
                SELECT Action, Section, Display, CreatedDate, CreatedBy.Name 
                FROM SetupAuditTrail
                WHERE CreatedById = :user.Id
                AND CreatedDate >= :twoWeeksAgo 
                ORDER BY CreatedDate DESC
                LIMIT 20
            ];

            for (SetupAuditTrail auditTrail : setupAuditTrails) {
                auditTrails.add(new AuditTrailWrapper(
                    auditTrail.Action,
                    auditTrail.Section,
                    auditTrail.Display,
                    auditTrail.CreatedDate,
                    auditTrail.CreatedBy.Name
                ));               
            }
        }

        return auditTrails;
    }

    public class AuditTrailWrapper {
        @AuraEnabled public String action;
        @AuraEnabled public String section;
        @AuraEnabled public String display;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String createdBy;

        public AuditTrailWrapper(String action, String section, String display, DateTime createdDate, String createdBy){
            this.action = action;
            this.section = section;
            this.display = display;
            this.createdDate = createdDate;
            this.createdBy = createdBy;
        }
    }
}