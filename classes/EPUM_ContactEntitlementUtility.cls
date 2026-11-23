public without sharing class EPUM_ContactEntitlementUtility {
    @AuraEnabled
    public list<PRM_AccountChannelMembership__c> lstAccChannelMembership {get;set;}
    
    @AuraEnabled
    public list<PRM_Account_Contact_Relationship__c> lstAccContRelationship {get;set;}
    
    @AuraEnabled
    public user currentUserInf{get;set;}
    
    @AuraEnabled
    public static EPUM_ContactEntitlementUtility getData(){
		user loggedInUser = EPUM_ContactEntitlementUtility.getUserInformation();
        EPUM_ContactEntitlementUtility classObj = new EPUM_ContactEntitlementUtility();
        classObj.currentUserInf = loggedInUser;
        String intelAccountOfPC = loggedInUser.AccountId;
        String onePartnerIdOfPC = loggedInUser.Core_IPA_One_Partner_Id__c ;
        String partnerRoleIStr = loggedInUser.Contact.Core_IPA_PartnerRole__c;
        classObj.lstAccChannelMembership = new list<PRM_AccountChannelMembership__c>();
        classObj.lstAccChannelMembership = EPUM_ContactEntitlementUtility.getAccountTierDetails(intelAccountOfPC, onePartnerIdOfPC);
        classObj.lstAccContRelationship = EPUM_ContactEntitlementUtility.getAccountContactRelationship(intelAccountOfPC, onePartnerIdOfPC,partnerRoleIStr);
        return classObj;
    }
    
    @AuraEnabled
    public static user getUserInformation(){
        try{
      		Id userId = userInfo.getUserId();
            // userId ='0050n0000038RHL';
            user loggedInUser = [SELECT Id,Name,ContactId,AccountId,Contact.Core_IPA_PartnerRole__c, Core_IPA_One_Partner_Id__c 
                            FROM User
                            WHERE Id =:userId];
            return loggedInUser;
        }catch(exception ex){
            System.debug('Need to catch error and insert in exception table');
            return null;
        }
    }
    public static list<PRM_Account_Contact_Relationship__c> getAccountContactRelationship(String intelAccountIDStr, String onePartnerIdOfPC_D, String partnerRoleIStr){
        try{
            String strRolesCodeToFetchIds = 'PRIMARY,PRIMCONTDEL';
            list<String> setEligibleRoles =strRolesCodeToFetchIds.split(','); 

            //Search all contact that belongs to OPID or PC's Account
            return [SELECT Id, Name, PRM_Account_Id__r.Name, PRM_Contact_Id__r.Name, PRM_Relationship_Id__r.Name ,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c 
                                                            FROM PRM_Account_Contact_Relationship__c 
                                                            WHERE PRM_Status_Nm__c ='Complete' and
                    											  PRM_Contact_Id__r.Core_IPA_PartnerRole__c=:partnerRoleIStr and 
                    											  PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c =: setEligibleRoles and
                                                            	  (PRM_Contact_Id__r.Core_IPA_One_Partner_Id__c  =:onePartnerIdOfPC_D OR 
                                                             	PRM_Account_Id__c =:intelAccountIDStr) Order by PRM_Relationship_Id__r.Name ASC];
        }catch(Exception ex){
            System.debug('EPUM_ContactEntitlementUtility getContactEntitlements exception '+ex);
        }
        
        return null;
    }

    public static list<PRM_AccountChannelMembership__c> getAccountTierDetails(String intelAccountOfPC, String onePartnerIdOfPC){
       return [SELECT PRM_Partner_Role__c,PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name
               FROM PRM_AccountChannelMembership__c 
               WHERE PRM_Status_Nm__c = 'Approved' and (PRM_Account_Id__c =:onePartnerIdOfPC or PRM_Account_Id__c =:intelAccountOfPC)
               LIMIT 1000
              ];
    }
    
    @AuraEnabled
    public static list<contact> getContactsWithRole(){
        user loggedInUser = EPUM_ContactEntitlementUtility.getUserInformation();
        String intelAccountOfPC = loggedInUser.AccountId;
        String onePartnerIdOfPC = loggedInUser.Core_IPA_One_Partner_Id__c ;
        String partnerRoleIStr = loggedInUser.Contact.Core_IPA_PartnerRole__c;
        Set<Id> setEntIds = new Set<Id>();
            for(PRM_VXEnttlmntMatrix__c vxe: [SELECT PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c 
                                              WHERE PRM_IPA_Partner_Role_Nm__c=:partnerRoleIStr AND 
                                              		PRM_Approval_Type_Nm__c = 'Manual' and
                                                    PRM_IsActive_Ind__c = true
                                             ]){
                    setEntIds.add(vxe.PRM_Entitlement_Id__c);
            }
        return [SELECT Id,Name,phone,
                (SELECT Core_Contact_Id__c,Core_Entitlement_Id__r.Core_Display_Name__c,Core_Entitlement_Id__c FROM Contact_Entitlements__r WHERE Core_Selected__c =true AND Core_Status__c ='Complete' and Core_Entitlement_Id__c =:setEntIds),
                (SELECT Id , PRM_Contact_Id__c,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM Account_Contact_Relationships__r WHERE PRM_Status_Nm__c ='Complete')
              FROM Contact
              WHERE Core_IPA_PartnerRole__c=:partnerRoleIStr and
               		(AccountID =:intelAccountOfPC or
              		Core_IPA_One_Partner_Id__c  =:onePartnerIdOfPC) ];
    }
    @AuraEnabled
     public static PRM_Account_Contact_Relationship__c getLoggedInUserRole(){
        try{
         user loggedInUser = EPUM_ContactEntitlementUtility.getUserInformation();
         String loggedInContactID = loggedInUser.ContactId;
            
            //Search all contact that belongs to OPID or PC's Account
            return [SELECT PRM_Contact_Id__c,PRM_Contact_Id__r.Name,PRM_Contact_Id__r.Phone,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c 
                                                            FROM PRM_Account_Contact_Relationship__c 
                                                            WHERE PRM_Contact_Id__c=:loggedInContactID limit 1];
        }catch(exception ex){
        	 System.debug('EPUM_ContactEntitlementUtility getContactEntitlements exception '+ex);
        }
        
        return null;
    }
    
    @AuraEnabled
    public static list<sObject> getDataUtility(String typeOfAction){
        list<sObject> objectToReturn;
        if(typeOfAction == 'getUserInfo'){
            objectToReturn = new list<sObject>();
            sObject sObj = EPUM_ContactEntitlementUtility.getLoggedInUserRole();
            objectToReturn.add(sObj);
        }
        if(typeOfAction == 'getContactRoleInfo'){
            objectToReturn = EPUM_ContactEntitlementUtility.getContactsWithRole();
        }
     return objectToReturn; 
    }
}