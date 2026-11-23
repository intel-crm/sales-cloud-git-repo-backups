/**************************************************************************************
Apex Class Name:  Core_UserContact_Handler
Version     : 1.0 
Created Date: 20 June 2020
Function    : Method to update AGS Inactive field of contact when User is activated/deactivated
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree H R            06/20/2020              Original Version
*************************************************************************************/
public class Core_UserContact_Handler{

    /*
     * Method name  : updateAGSInactiveField
     * Description  : Method to update AGS Inactive field of contact when User is activated/deactivated
     * Return Type  : void
     * Parameter    : Set<Id>
     */
    @future
    public static void updateAGSInactiveField(Set<Id> userListId){
        Map<Id, Boolean> mapActiveUsers = new Map<Id, Boolean>();
        List<User> userList = [SELECT id, IsActive, ContactId FROM User WHERE Id=:userListId];
        for(User userRec: userList){            
            mapActiveUsers.put(userRec.ContactId, userRec.IsActive);                        
        }
        //Populating the field Core_AGS_Inactive__c when the user is deactivated/activated
        List<Contact> contactList = new List<Contact>();
        for(Contact con: [SELECT id, Name, Core_AGS_Inactive__c, OwnerId FROM Contact WHERE Id=: mapActiveUsers.keySet()]){
            if(mapActiveUsers.get(con.Id)== false){
                con.Core_AGS_Inactive__c = true;
                contactList.add(con);
            }
            if(mapActiveUsers.get(con.Id)== true){
                con.Core_AGS_Inactive__c = false;
                contactList.add(con);
            }
        }
        //Updating the contact list
        if(!contactList.isEmpty() && contactList.size()>0){
            Database.update(contactList);    
        }
    }
}