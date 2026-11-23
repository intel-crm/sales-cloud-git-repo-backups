/**************************************************************************************
Apex Class Name:  Core_AccountCoverageBatchHandler
Version     : 1.0 
Created Date: 08 Dec 2016
Description    : This Batch Service Class for all the business logic for the account coverage
*************************************************************************************/
public class Core_AccountCoverageBatchHandler {
    
    Map<String,Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
    
    // Get all Subordinate Users by User.Id
    public Set<ID> getAllSubordinateUsersByUser(Id idUser) {
        Set<Id> setUserId = new Set<Id>();
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageBatchHandler') && mapAcmClassCheckToEol.get('AccountCoverageBatchHandler').IsActive__c) {
            
            try{
                
                
                User objUser = [SELECT UserRoleId   FROM User  WHERE Id = :idUser LIMIT 1];
                
                
                
                Set<ID> allSubRoleIds = getAllSubRoleIds(new Set<Id>{objUser.UserRoleId});
                
                
                for (User objUsr : [SELECT Id, UserRole.Name  FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE Id IN :allSubRoleIds)]){
                    setUserId.add(objUsr.Id);
                }
            }catch(Exception ex){
                UCD_ACM_Logger.error('Core_AccountCoverageBatchHandler','exegetAllSubordinateUsersByUsercute','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
            }
            return setUserId;
        }
        
        else
        {
            return null;
        }
    }
    
    
    // Get all Subordinate Users //Id idUser
    public List<User> getAllSubordinateUsersByUserRoleId(Id userRoleId) {
        List<User> lstUser = null;
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageBatchHandler') && mapAcmClassCheckToEol.get('AccountCoverageBatchHandler').IsActive__c) {
            try{
                Set<ID> allSubRoleIds = getAllSubRoleIds(new Set<Id>{userRoleId});
                
                
                lstUser = [SELECT Id, UserRole.Name 
                           FROM User
                           WHERE UserRoleId IN (SELECT Id
                                                FROM UserRole
                                                WHERE Id IN :allSubRoleIds)];
            }catch(Exception ex){
                UCD_ACM_Logger.error('Core_AccountCoverageBatchHandler','getAllSubordinateUsersByUserRoleId','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),null);
                lstUser = new List<User>();
            }
            return lstUser;
        }
        else
        {
            return lstUser;  
        }
    }
    
    //Gets the The top level parent ID
    //Note- Currently Not Using 
    
    //Gets all the subordinates users recursively 
    public Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageBatchHandler') && mapAcmClassCheckToEol.get('AccountCoverageBatchHandler').IsActive__c) {
            // get all of the roles underneath the passed roles
            for(UserRole userRole :[SELECT Id
                                    FROM UserRole
                                    WHERE ParentRoleId IN :roleIds
                                    AND ParentRoleID != null]) {
                                        currentRoleIds.add(userRole.Id);
                                    }
            
            
            // go fetch some more, let it roll!
            if(currentRoleIds.size() > 0) {
                currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
            }
            
            return currentRoleIds;
        }
        else
        {
            return null;
        }
    }
    
    
    //Converts the Map to String    
    public String convertMapToString(Map<String, String> failedUsers){
        String resultStr = '';
        if(mapAcmClassCheckToEol.containsKey('AccountCoverageBatchHandler') && mapAcmClassCheckToEol.get('AccountCoverageBatchHandler').IsActive__c) {
            if(failedUsers != null && !failedUsers.isEmpty()){
                resultStr = 'Batch Job did not processed the below list of User\'s Records... \n \n \n ';
                for(String key : failedUsers.keySet()){
                    resultStr = resultStr +'\n \n User.Id : '+ key +' '+failedUsers.get(key);
                }
            }
            
            return resultStr;
        }
        else
        {
            return resultStr;
        }
    }
    
    
}