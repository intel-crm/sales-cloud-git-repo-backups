//Batch to check whether CSC user have marketing user checkbox checked or not
global class Core_MDF_CSC_MarketingUser_Batch implements Database.Batchable<sObject> {
    
    Public List<Database.SaveResult> srList = new List<Database.SaveResult>();
    Public static Integer LONG_TEXT_AREA_LIMIT = Core_MDF_CCP_ConstantClass.LONG_TEXT_AREA_LIMIT;
    final String internalCSCPs = Core_MDF_CCP_ConstantClass.INTERNAL_CSC_PS;
    /*Start Method*/
    Public Iterable<sObject> start(Database.BatchableContext bc) {
        
        return [SELECT  Id,UserPermissionsMarketingUser 
                FROM User 
                WHERE id IN (select AssigneeId 
                     from PermissionSetAssignment 
                     where PermissionSet.Name = :internalCSCPs 
                     and Assignee.UserPermissionsMarketingUser = false 
                     and Assignee.IsActive = true)];
        
    }
    /*Execute Method*/
    public void execute (Database.BatchableContext bc, list<User> userList) {
        system.Debug('userList-->'+userList);
        List<User> userListToBeUpdated = new List<User>();
        Map<Id,List<string>> usrIdToErrorsMap = new Map<Id,List<string>>();
        try { 
            if (!userList.isEmpty()) {
                for (User usr:userList) {
                    User user = new User();
                    user.Id = usr.Id;
                    user.UserPermissionsMarketingUser=true;
                    userListToBeUpdated.add(user);
                }
                
                if(!userListToBeUpdated.isEmpty()) {
                    List<Database.SaveResult> srList = Database.update (userListToBeUpdated,false);
                    
                    for (Database.SaveResult sr : srList) {
                        if(!sr.isSuccess()) {
                            List<string> errorMsgs = new List<string>();
                            for(Database.Error err : sr.getErrors()) { string errorMsg = err.getStatusCode() + ': ' + err.getFields() + ': ' + err.getMessage();
                                system.debug('errorMsg-->'+errorMsg);
                                errorMsgs.add(errorMsg);
                            }
                            usrIdToErrorsMap.put(sr.getId(),errorMsgs); }
                    } createLogEntry(usrIdToErrorsMap);
                }
            }
            
        }
        catch (DmlException ex) {
            System.debug('Exception is : ' + ex.getMessage());
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    /*Finish Method*/
	Public void finish(Database.BatchableContext BC) { 
        
    }
    /*To Capture Logs for the Records which fails*/
     public static void createLogEntry(Map<Id,List<string>> usrIdToErrorsMap) {
        Map<String, String> coreLogMap = new Map<String, String>();
        coreLogMap.put('Core_Origin__c','Core_MDF_CSC_MarketingUser_Batch');
        coreLogMap.put('Core_Severity__c','Low');
        coreLogMap.put('Core_sObjectType__c','User');
        coreLogMap.put('Core_Project__c','Consolidated Co-Marketing Program (CCP)');
        
        if(usrIdToErrorsMap != null && !usrIdToErrorsMap.values().isEmpty()) {
            final Integer strLength = JSON.serialize(usrIdToErrorsMap).length();
            string details;
            coreLogMap.put('Core_Message__c','Records Failed: '+JSON.serialize(usrIdToErrorsMap.keySet()));
            details = strLength < LONG_TEXT_AREA_LIMIT ? JSON.serialize(usrIdToErrorsMap) : JSON.serialize(usrIdToErrorsMap).substring(0,LONG_TEXT_AREA_LIMIT);
            coreLogMap.put('Core_Details__c',details);
            Core_MDF_CCP_UtilityClass.createLogEntry(coreLogMap);
            system.debug('details-->'+details);}
    }
}