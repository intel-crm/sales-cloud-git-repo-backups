@isTest
public class Core_MDF_checkSObjectCRUDPermission_Test {
	@isTest
    static void testCreatePermission(){
    	Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = itAdminProfile.Id;
        insert usr;
        
        System.runAs(usr){
        	String objectName = 'PartnerFundRequest';
        	Boolean result1 = Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission(objectName);
            system.assert(result1, true);
        }    
    }

    @isTest 
    static void testEditPermission(){
    	Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = itAdminProfile.Id;
        insert usr;
        
        System.runAs(usr){
        	String objectName = 'PartnerFundRequest';
        	Boolean result2 = Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission(objectName); 
            system.assert(result2, true);
        }    
    }
    
    @isTest 
    static void testDeletePermission(){
    	Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = itAdminProfile.Id;
        insert usr;
        
        System.runAs(usr){
        	String objectName = 'PartnerFundRequest';
        	Boolean result2 = Core_MDF_checkSObjectCRUDPermission.checkSObjectDeletePermission(objectName);  
            system.assert(result2, true);
        }
    }
}