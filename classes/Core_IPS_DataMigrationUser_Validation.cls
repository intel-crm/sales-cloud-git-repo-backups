/*--------------------------------------------------------------------------------------------------------
Description: Core_IPS_DataMigrationUser_Validation has the methods isIPSDatamigrationUser which is used 
to validate the given userid is datamigration user or not.
---------------------------------------------------------------------------------------------------------*/
public class Core_IPS_DataMigrationUser_Validation {
    //validating the datamigration userid and return the user profile name
    @AuraEnabled(cacheable=true)
	public static Boolean isIPSDatamigrationUser(String userid){
	//List<PermissionSetAssignment> assignedUsers = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Core_IPS_Data_Migration_Permission_Set'];
	List<IPSDataMigrationUsersList__c> dmusers = IPSDataMigrationUsersList__c.getAll().values(); 
    //List<Id> userIds = new List<Id>();
	for(IPSDataMigrationUsersList__c dmulst : dmusers){
        if(userid == dmulst.IntelSupportRepresentativeId__c){return true;}
    }
    return false;
}
    //validating the datamigration userid and return the user profile name
  /*  @AuraEnabled(cacheable=true)
	public static Boolean isDatamigrationUser_withCCPCoreAccessProfile(String userid){
	//List<PermissionSetAssignment> assignedUsers = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Core_IPS_Data_Migration_Permission_Set'];
	///Map<Id,Profile> dmuprof = new Map<Id,Profile>([SELECT Id,Name FROM Profile]);
	//String profName = dmuprof.get(UserInfo.getProfileId()).Name;
	profile pname = [select name from profile where Id =: userid];
	System.debug('user profile name' +pname);
    List<IPSDataMigrationUsersList__c> dmusers = IPSDataMigrationUsersList__c.getAll().values(); 
    //List<Id> userIds = new List<Id>();
	for(IPSDataMigrationUsersList__c dmulst : dmusers)
	{
        if(dmulst.IntelSupportRepresentativeId__c == userid){
        	System.debug('**userid match found'+dmulst.IntelSupportRepresentativeId__c);
    		return true;
        }
    }
    System.debug('False');
    return false;
} */
    //@AuraEnabled(cacheable=true)
 /*   public static Boolean isIPSDatamigrationUser(){
	//List<PermissionSetAssignment> assignedUsers = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Core_IPS_Data_Migration_Permission_Set'];
	List<IPSDataMigrationUsersList__c> dmusers = IPSDataMigrationUsersList__c.getAll().values(); 
    List<Id> userIds = new List<Id>();
	for(IPSDataMigrationUsersList__c dmulst : dmusers)
	{
        if(userInfo.getUserId() == dmulst.IntelSupportRepresentativeId__c){
        	System.debug('**userid match found'+dmulst.IntelSupportRepresentativeId__c);
    		return true;
        }
    }
    System.debug('False');
    return false;
    } */
}