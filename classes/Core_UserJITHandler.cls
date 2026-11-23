//**User JIT Handler class for Partner Liscence freeup**// - 11/06/2024 - added by Sai Narahari/Soumy Mangal
global class Core_UserJITHandler implements Auth.SamlJitHandler {
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id userId, String assertion, Map<String, String> attributes, String identityType) {
    
        return null;
    }
    
    global void updateUser(Id userId,Id samlSsoProviderId, Id communityId, Id portalId, String federationId, Map<String, String> attributes, String assertion) {
        List<String> excludedProfileList = System.Label.Core_Draco_PartnerLicExcludedProfiles.split(';');
        // Query for the existing user
        List<User> existingUser = [SELECT Id,IsActive,Partner_License_Reclaimed__c,contactId FROM User 
                             WHERE Id = :userId AND IsActive = false AND Partner_License_Reclaimed__c = true 
                             AND contactId != NULL AND (Profile.Name NOT IN :excludedProfileList) LIMIT 1];
        
        if (existingUser.size() > 0) {
            existingUser[0].IsActive = true;
            existingUser[0].Partner_License_Reclaimed__c = false;
            update existingUser;
            
            Core_UserJITHandler.updateContENTANDContact(existingUser[0].contactId);
        }
    }
    @future
    public static void updateContENTANDContact(Id ContId) {
        
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
    }
}