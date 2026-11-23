/*
 * Class Name: core_IPS_case_Banner
 * Usage : To show banner for those users who doesnt hv CCP permission set
 * created by: Sriranjini JN
test class : core_IPS_case_Banner_Test
*/

public without sharing class core_IPS_case_Banner {
    public boolean permission {get;set;}
    //private final Case caseVar;
    
    public core_IPS_case_Banner(ApexPages.StandardController stdController) {
       // this.caseVar = (Case)stdController.getRecord();
        permission = getPermision();
    }
    
    
    public static Boolean getPermision(){
    
       List<Core_IPS_Banner_CustomSetting__c> bannerSettings = Core_IPS_Banner_CustomSetting__c.getall().values();
       List<String> whereParts = new List<String>();
       String profiles ='';
       for(Core_IPS_Banner_CustomSetting__c bannerSetting: bannerSettings ){

           whereParts.add('PermissionSet.Label like \''+String.escapesinglequotes(bannerSetting.Name)+'\'');
       } 
       
       if(whereParts.size() > 0){
           if(profiles == ''){
                profiles = profiles + ' And (';
            }
          profiles = profiles + String.join(whereParts, String.escapesinglequotes(' OR '));
          profiles = profiles + String.escapesinglequotes(')');
       }
       
        
       
       String userId = UserInfo.getUserId();
       String query = 'SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId =\''+String.escapesinglequotes(userId)+'\''; 
        
        query = query + profiles;
        list<PermissionSetAssignment> permissionAssignment = new List<PermissionSetAssignment>();
        if(PermissionSetAssignment.SObjectType.getDescribe().isQueryable()){
            permissionAssignment = Database.query(query);
         }
        if(permissionAssignment != null && permissionAssignment.size()!=0 ){
            
            return true;
        }else
        {
           return false;
        }
       
    }
}