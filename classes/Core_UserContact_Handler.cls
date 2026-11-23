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
                if(mapActiveUsers.get(con.Id)== false){ //If User is not there in mapActiveUsers, then make its Contact's User_Status__c to "Not Active"
                    con.Core_AGS_Inactive__c = true;
                    //------------------ Draco Change [START] - 11/03/2022 - Update Core_Is_FederationId_Valid_Ind__c field upon User based on User IsActive and ContactId fields ------------------------//
                    if(mapActiveUsersfedid.get(con.Id)== null && con.Core_Enterprise_Id__c == null){
                        con.Core_Is_FederationId_Valid_Ind__c = 'false';
                     
                    }
                    else if(mapActiveUsersfedid.get(con.Id)==con.Core_Enterprise_Id__c){
                        con.Core_Is_FederationId_Valid_Ind__c = 'true';   
                       
                    }                    
                    else{
                        con.Core_Is_FederationId_Valid_Ind__c = 'false';
                        
                    }
                    //------------------ Draco Change [END] - 11/03/2022 - Update User_Status__c field upon User based on User IsActive and ContactId fields ------------------------//
                    contactList.add(con);        
                }
                if(mapActiveUsers.get(con.Id)== true){ //If User is there in mapActiveUsers, then make its Contact's User_Status__c to "Active"
                    con.Core_AGS_Inactive__c = false;
                    //------------------ Draco Change [START] - 11/03/2022 - Update Core_Is_FederationId_Valid_Ind__c field upon User based on User IsActive and ContactId fields ------------------------//
                    if(mapActiveUsersfedid.get(con.Id) == null && con.Core_Enterprise_Id__c == null){
                        con.Core_Is_FederationId_Valid_Ind__c = 'false';
                      
                    }
                    else if(mapActiveUsersfedid.get(con.Id)==con.Core_Enterprise_Id__c){
                        con.Core_Is_FederationId_Valid_Ind__c = 'true';   
                       
                    } 
                    else{
                        con.Core_Is_FederationId_Valid_Ind__c = 'false';
                        
                    }
                    //------------------ Draco Change [END] - 11/03/2022 - Update User_Status__c field upon User based on User IsActive and ContactId fields ------------------------//
                    contactList.add(con);
                }  
            }
            //Updating the contact list
            if(!contactList.isEmpty() && contactList.size()>0){
                Database.update(contactList);    
            }
        } 
    }