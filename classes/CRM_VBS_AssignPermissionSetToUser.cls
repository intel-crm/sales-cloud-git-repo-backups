public class CRM_VBS_AssignPermissionSetToUser {
    @InvocableMethod(label='Permission Set to QB resorce' description='Assigns the specified permission set to user.')
    public static void assignPermissionSet(List<CRM_VBS_SOAR__c> QBresource) {
        try {
            
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
        
        
    }
   
    
    @future
    public static void assignPermissionSetAsync(String studentId) {
        /*try {
            // Retrieve the Student record
            Student__c student = [SELECT Id, Student_Name__c FROM Student__c WHERE Id = :studentId LIMIT 1];
            
            if (student != null && student.Student_Name__c != null) {
                // Query for the User associated with the Student
                User studentUser = [SELECT Id FROM User WHERE Username = :student.Student_Name__c LIMIT 1];
                
                if (studentUser != null) {
                    // Query for the Permission Set
                    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'accessStudentRecord' LIMIT 1];
                    
                    if (ps != null) {
                        // Assign Permission Set to the User
                        PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                        psAssignment.PermissionSetId = ps.Id;
                        psAssignment.AssigneeId = studentUser.Id;
                        insert psAssignment;
                    } else {
                        System.debug('Permission Set not found.');
                    }
                } else {
                    System.debug('User not found.');
                }
            } else {
                System.debug('Student record not found or Student Name is null.');
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }*/
    }
}