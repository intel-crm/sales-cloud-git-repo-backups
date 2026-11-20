/*--------------------------------------------------------------------------------------------------------
Description: Core_IPS_DataMigrationUser_Validation has the methods isIPSDatamigrationUser which is used 
to validate the given userid is datamigration user or not.
---------------------------------------------------------------------------------------------------------*/
public class Core_IPS_DataMigrationUser_Validation {
   
    @AuraEnabled(cacheable=true)
	public static Boolean isIPSDatamigrationUser(String userid){
	List<IPSDataMigrationUsersList__c> dmusers = IPSDataMigrationUsersList__c.getAll().values(); 
	for(IPSDataMigrationUsersList__c dmulst : dmusers){
        if(userid == dmulst.IntelSupportRepresentativeId__c){return true;}
    }
    return false;
	}
}