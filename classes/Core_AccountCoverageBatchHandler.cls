/**************************************************************************************
Apex Class Name:  Core_AccountCoverageBatchHandler
Version     : 1.0 
Created Date: 08 Dec 2016
Description    : This Batch Service Class for all the business logic for the account coverage
*************************************************************************************/
public class Core_AccountCoverageBatchHandler {
    
    // Get all Subordinate Users by User.Id
    public Set<ID> getAllSubordinateUsersByUser(Id idUser) {
        Set<Id> setUserId = new Set<Id>();
        try{
            System.debug('Core_AccountCoverageBatchHandler getAllSubordinateUsersByUser: idUser ' + idUser);
            
            User objUser = [SELECT UserRoleId   FROM User  WHERE Id = :idUser LIMIT 1];
            
            System.debug('Core_AccountCoverageBatchHandler.getAllSubordinateUsersByUser: objUser ' + objUser);
            
            Set<ID> allSubRoleIds = getAllSubRoleIds(new Set<Id>{objUser.UserRoleId});
            System.debug('Core_AccountCoverageBatchHandlergetAllSubordinateUsersByUser  All Ids of subbordinates Size: ' + allSubRoleIds.size());
            
            for (User objUsr : [SELECT Id, UserRole.Name  FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE Id IN :allSubRoleIds)]){
                setUserId.add(objUsr.Id);
            }
        }catch(Exception e){
            System.debug(logginglevel.Error,' Invalid Id Field : '+idUser);
        }
        return setUserId;
    }
    
    
    // Get all Subordinate Users //Id idUser
    public List<User> getAllSubordinateUsersByUserRoleId(Id userRoleId) {
        List<User> lstUser = null;
        try{
            Set<ID> allSubRoleIds = getAllSubRoleIds(new Set<Id>{userRoleId});
            System.debug(' >>> userRoleId ' + userRoleId +'Core_AccountCoverageBatchHandlergetAllSubordinateUsersByUser  All Ids of subbordinates Size: ' + allSubRoleIds.size());
            
            lstUser = [SELECT Id, UserRole.Name 
                       FROM User
                       WHERE UserRoleId IN (SELECT Id
                                            FROM UserRole
                                            WHERE Id IN :allSubRoleIds)];
        }catch(Exception e){
            System.debug(logginglevel.Error,' Invalid Id Field : '+userRoleId);
            lstUser = new List<User>();
        }
        return lstUser;
    }
    
    //Gets the The top level parent ID
    //Note- Currently Not Using 
    
    //Gets all the subordinates users recursively 
    public Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        system.debug(' Core_AccountCoverageBatchHandler.getAllSubRoleIds  roleIds '+roleIds);
        Set<ID> currentRoleIds = new Set<ID>();
        
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[SELECT Id
                                FROM UserRole
                                WHERE ParentRoleId IN :roleIds
                                AND ParentRoleID != null]) {
                                    currentRoleIds.add(userRole.Id);
                                }
        System.debug(' Core_AccountCoverageBatchHandler.getAllSubRoleIds  == currentRoleIds  '+currentRoleIds);
        
        // go fetch some more, let it roll!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        system.debug(' >>>>>>> Core_AccountCoverageBatchHandler.getAllSubRoleIds  ==  Returning '+currentRoleIds);
        return currentRoleIds;
        
    }
    

    //Converts the Map to String    
    public String convertMapToString(Map<String, String> failedUsers){
        String resultStr = '';
        if(failedUsers != null && !failedUsers.isEmpty()){
            resultStr = 'Batch Job did not processed the below list of User\'s Records... \n \n \n ';
            for(String key : failedUsers.keySet()){
                resultStr = resultStr +'\n \n User.Id : '+ key +' '+failedUsers.get(key);
            }
        }
        System.debug(' resultStr '+resultStr);
        return resultStr;
    }
    
    
}