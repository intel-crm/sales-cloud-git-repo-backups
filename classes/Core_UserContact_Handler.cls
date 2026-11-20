/**************************************************************************************
Apex Class Name:  Core_UserContact_Handler
Version     : 1.0 
Created Date: 20 June 2020
Function    : Method to update AGS Inactive field of contact when User is activated/deactivated
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree H R            06/20/2020              Original Version
* Draco						11/03/2022				Update User_Status__c field upon User based on User IsActive and ContactId fields
*************************************************************************************/
public without sharing  class Core_UserContact_Handler{
    
    /*
* Method name  : updateAGSInactiveField
* Description  : Method to update AGS Inactive field of contact when User is activated/deactivated
* Return Type  : void
* Parameter    : Set<Id>
*/
    @future
    public static void updateAGSInactiveField(Set<Id> userListId){ //This method makes update only for User which has ContactId present and takes list of all triggered Users Id as Input
        try {
            Map<Id, Boolean> mapActiveUsers = new Map<Id, Boolean>();
            Map<Id, string> mapActiveUsersfedid = new Map<Id, string>();
            //Set<Id> userContactIdSet = new Set<Id>();
            List<User> userList = [SELECT id, IsActive,FederationIdentifier, ContactId FROM User WHERE Id=:userListId]; //Get the Cantact Id (after user Update) and IsActive field from input User list
            for(User userRec: userList){            
                mapActiveUsers.put(userRec.ContactId, userRec.IsActive); //Put the ContactId and IsActive status in mapActiveUsers for all users
                mapActiveUsersfedid.put(userRec.ContactId, userRec.FederationIdentifier);
                // userContactIdSet.add(userRec.ContactId);
            }
            //Populating the field Core_AGS_Inactive__c when the user is deactivated/activated
            List<Contact> contactList = new List<Contact>();
            for(Contact con: [SELECT id, Name, Core_AGS_Inactive__c, OwnerId, Core_Enterprise_Id__c, Core_Is_FederationId_Valid_Ind__c FROM Contact WHERE Id=: mapActiveUsers.keySet()]){ //Iterate over list of all Contacts from the User Record
                if(mapActiveUsers.containsKey(con.Id)) {
                    Boolean userIsActive = mapActiveUsers.get(con.Id);
                    // Update Core_AGS_Inactive__c based on User IsActive value (preserve existing behavior)
                    if (userIsActive == false) {
                        con.Core_AGS_Inactive__c = true;
                    } else if (userIsActive == true) {
                        con.Core_AGS_Inactive__c = false;
                    } else {
                        // Preserve current behavior: if map value is null, do not change Core_AGS_Inactive__c
                    }
                    
                    // Evaluate federation validity once using helper
                    con.Core_Is_FederationId_Valid_Ind__c = evaluateFederationValidity(mapActiveUsersfedid.get(con.Id), con.Core_Enterprise_Id__c);
                    
                    contactList.add(con);
                }  
            }
            //Updating the contact list
            if(!contactList.isEmpty() && contactList.size()>0 && Schema.sObjectType.Contact.isUpdateable()){
                Database.update(contactList);    
            }
        }
        //Added try catch block to catch unhandled exceptions 
        catch (DmlException dmlEx) {
            List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
            Core_Log_Entry__c coreLogEntry = new Core_Log_Entry__c(Core_Message__c = 'Exception in updateAGSInactiveField',Core_Project__c = 'Core_UserContact_Handler',Core_Origin__c = 'updateAGSInactiveField',Core_Details__c  = dmlEx.getMessage(),Core_Severity__c = 'Error',Core_When__c = System.now());
            logEntries.add(coreLogEntry);
            if (!logEntries.isEmpty()) {
                insert logEntries;
            }
        }
    }
    
    // Helper method to reduce cognitive complexity while preserving logic
    private static String evaluateFederationValidity(String fedId, String enterpriseId) {
        if (fedId == null && enterpriseId == null) {
            return 'false';
        } else if (fedId == enterpriseId) {
            return 'true';
        } else {
            return 'false';
        }
    }
}