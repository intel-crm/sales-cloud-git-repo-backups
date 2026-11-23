public with sharing class ApprovalPageMessage {
    @AuraEnabled(cacheable=true)
    public static Boolean hasPermissionSet(String permissionSetName) {
        // Query the PermissionSetAssignment object for the specific Permission Set and the current user
        Id currentUserId = UserInfo.getUserId();
        PermissionSetAssignment[] assignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'PCC_Deal_Reg_Internal_Admin'
            AND AssigneeId = :currentUserId
            LIMIT 1
        ];
        return !assignments.isEmpty();
    }
    @AuraEnabled(cacheable=true)
   
        public static Boolean registrationType(Id recordId) {
            try { 
                ProcessInstanceWorkitem rec = [SELECT ProcessInstanceId FROM ProcessInstanceWorkitem WHERE Id = :recordId LIMIT 1];
                ProcessInstance[] record = [ SELECT Id,TargetObject.Type FROM ProcessInstance WHERE Id = :rec.ProcessInstanceId AND TargetObject.Type='Core_Design_Registration__c'];
               

                return !record.isEmpty(); 
            } catch (Exception e) {
                throw new AuraHandledException('Error fetching record field: ' + e.getMessage());
            }
        }
    }