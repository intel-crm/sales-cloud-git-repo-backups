//**User JIT Handler class for Partner License freeup**// - 11/06/2024 - added by Sai Narahari/Soumy Mangal
global with sharing class Core_UserJITHandler implements Auth.SamlJitHandler {
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id userId, String assertion, Map<String, String> attributes, String identityType) {
        return null;
    }
    
    global void updateUser(Id userId,Id samlSsoProviderId, Id communityId, Id portalId, String federationId, Map<String, String> attributes, String assertion) {
        try{
            List<String> excludedProfileList = System.Label.Core_Draco_PartnerLicExcludedProfiles.split(';');
            // Query for the existing user
            List<User> existingUser = [SELECT Id,IsActive,Partner_License_Reclaimed__c,Core_License_Reclaimed_on_Creation__c,contactId FROM User 
                                       WHERE Id = :userId AND IsActive = false AND contactId != NULL AND ((Partner_License_Reclaimed__c = true 
                                                                                                           AND  (Profile.Name NOT IN :excludedProfileList)) OR Core_License_Reclaimed_on_Creation__c = true) LIMIT 1];
            
            if (existingUser.size() > 0) {
                existingUser[0].IsActive = true;
                existingUser[0].Partner_License_Reclaimed__c = false;
                existingUser[0].Core_License_Reclaimed_on_Creation__c = false;
                update existingUser;                
                Core_UserJITHandler.createUpdateContENTANDContact(existingUser[0].contactId);
            }
        }catch(exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = 'Error in class Core_UserJITHandler', Core_Origin__c = 'updateUser', Core_Project__c = 'Draco' , Core_Details__c = e.getMessage(), Core_Severity__c = 'info', Core_When__c = System.Now());     
            insert excepLog;
        }
    }
    /*@future
public static void updateContENTANDContact(Id ContId) {
try{
//Query the Partner Portal Contact Entitlement to update the core selected and core status.
Core_Contact_Entitlement__c conPartnerPortEnt = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,
Core_Entitlement_Id__r.Name,Core_Status__c,Core_Selected__c
FROM Core_Contact_Entitlement__c 
WHERE Core_Contact_Id__c =: ContId and Core_Entitlement_Id__r.Name ='Partner Portal' LIMIT 1];            
conPartnerPortEnt.Core_Selected__c = true;
conPartnerPortEnt.Core_Status__c = 'Pending';
conPartnerPortEnt.Core_Data_Loaded__c=true;
conPartnerPortEnt.Removal_as_part_of_License_Reclaim__c=false;
Update conPartnerPortEnt;
}         catch(exception e){
Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = 'Error in class Core_UserJITHandler', Core_Origin__c = 'updateContENTANDContact', Core_Project__c = 'Draco' , Core_Details__c = e.getMessage(), Core_Severity__c = 'info', Core_When__c = System.Now());     
insert excepLog;
}      
} */
    @future
    public static void createUpdateContENTANDContact(Id ContId) {
        try{
            List<Core_Contact_Entitlement__c> conPartnerPortEnt = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,
                                                                   Core_Entitlement_Id__r.Name,Core_Status__c,Core_Selected__c
                                                                   FROM Core_Contact_Entitlement__c 
                                                                   WHERE Core_Contact_Id__c =: ContId and Core_Entitlement_Id__r.Name ='Partner Portal' LIMIT 1];            
            if(conPartnerPortEnt.size() > 0){    
                conPartnerPortEnt[0].Core_Selected__c = true;
                conPartnerPortEnt[0].Core_Status__c = 'Pending';
                conPartnerPortEnt[0].Core_Data_Loaded__c=true;
                conPartnerPortEnt[0].Removal_as_part_of_License_Reclaim__c=false;
                Update conPartnerPortEnt;
            }else{
                List<Core_Entitlement__c> partPortalEnt = [SELECT id,Name from Core_Entitlement__c where Name = 'Partner Portal' LIMIT 1];
                Core_Contact_Entitlement__c newPartnerPortalEnt = New  Core_Contact_Entitlement__c();
                newPartnerPortalEnt.Core_Selected__c = true;
                newPartnerPortalEnt.Core_Status__c = 'Pending';
                newPartnerPortalEnt.Core_Data_Loaded__c=true;
                newPartnerPortalEnt.Core_Contact_Id__c=ContId;
                newPartnerPortalEnt.Core_Entitlement_Id__c = partPortalEnt[0].Id;
                insert newPartnerPortalEnt; 
            } 
        }catch(exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = 'Error in class Core_UserJITHandler' , Core_Origin__c = 'createUpdateContENTANDContact', Core_Project__c = 'Draco' , Core_Details__c = e.getMessage(), Core_Severity__c = 'info', Core_When__c = System.Now());     
            insert excepLog;
        }          
    }  
}