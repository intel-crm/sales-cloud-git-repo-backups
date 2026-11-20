public with sharing class Core_IPS_AgentCaseClosureControllerLEX {
    public static Boolean isEditable= false;
    @AuraEnabled
    public  static List<String> initialValidations(id caseID){
        case newCase;
        List<String> errorCodeList = new List<String>();
        Boolean success = TRUE;
	//FLS Check Added - Madhuri
        if(Case.SObjectType.getDescribe().isAccessible()){
            newCase = [Select id , Core_Sub_Status__c, Status from Case where id = :caseID];
        }
            isEditable = [SELECT HasEditAccess, RecordId 
                          FROM UserRecordAccess 
                          WHERE UserId =:userinfo.getuserId() 
                          AND RecordId = :caseID].HasEditAccess;
        
        
        User loggedInUser = [SELECT ProfileId, Profile.Name 
                             FROM User
                             WHERE Id =:userinfo.getuserId()];
        if (!isEditable) {                    
           // String A=  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Insufficient_Privileges_Case')));
            errorCodeList.add(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Insufficient_Privileges_Case'));
	    return errorCodeList;
            
        }
        
        if(!System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.ValueOf(loggedInUser.ProfileId).substring(0,15)) 
           && 
           !System.Label.Core_IPS_Button_Override_ITAdmins.contains(loggedInUser.Profile.Name)
           && !System.Label.Core_IPS_DataOps.contains(loggedInUser.ProfileId)
           &&
           loggedInUser.Profile.Name != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Profile_IPS_Agent_Partner')){
	          errorCodeList.add(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Insuff_Access_Req_CaseClosure'));
	          return errorCodeList;
           } 
        if (!String.isBlank(newCase.Core_Sub_Status__c) && newCase.Core_Sub_Status__c.equals(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus'))){
            //errorCodeList.add(Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Case_Close_Pending_Msg')); 
            errorCodeList.add('Case status already set to "Close Pending".');
            return errorCodeList;
        }               
        return null;
    }
    
    @AuraEnabled
    public static String getAuthorType() {
        String profileIdStr =  String.valueOf(userInfo.getProfileId()).substring(0,15);
        String userIdStr = String.valueOf(userinfo.getuserId()).substring(0,15);
        String commentAuthorType = Core_IPS_AddCommentController.getAuthr(profileIdStr, userIdStr);
        return commentAuthorType;
    }
    @AuraEnabled
    public static Boolean getCaseClosureAccess() {
        SetupEntityAccess[] checkAccess = [SELECT Id FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM ApexPage WHERE Name = 'Core_IPS_AgentCaseClosure') AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()) LIMIT 1];
        if(checkAccess.size()>0)
          return true;
        else
          return false;  
    }
    @AuraEnabled
    public static Boolean getCaseCloneAccess() {
        SetupEntityAccess[] checkAccess = [SELECT Id FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM ApexPage WHERE Name = 'Core_IPS_CaseClone') AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()) LIMIT 1];
        if(checkAccess.size()>0)
          return true;
        else
          return false;  
    }
}