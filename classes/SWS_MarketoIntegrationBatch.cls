/****************************************************************************************************
Apex Class Name : SWS_MarketoIntegrationBatch
Version         : 1.0 
Created Date    : 2025-03-13
Function        : Batch job to share the 6Sense Enabled Account Opportunities to 6Senese Integration User.
User Story      : TWC5945-1897
Test Class      : SWS_Marketo_ContactShareTest
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shijas KM              2025-03-13                 Created
*****************************************************************************************************/

public without sharing class SWS_MarketoIntegrationBatch {
    public String SWS_UserOrGroupId;
   	public List<Id> ContactIds = new List<Id>();
@InvocableMethod(label='Share Marketo Related Contact' description='Use to share Marketo related Contacts with Marketo Integration User' category='Contact')
    public static void createContactShare(List<Id> contactIds) {
        /*
            List<ContactShare> shares = new List<ContactShare>();
        for (Id contactId : contactIds) {
            ContactShare share = new ContactShare();
            share.ContactId = contactId;
            share.UserOrGroupId = '005XXXXXXXXXXXXXXX'; // Replace with the actual User or Group ID
            share.ContactAccessLevel = 'Read'; // Set the desired access level
            share.RowCause = Schema.ContactShare.RowCause.Manual; // Set the reason for sharing
            shares.add(share);
        }
        insert shares;
*/
    }
	/*
	@InvocableMethod
    public static void deleteContactShare(Id con_Id) {
        List<ContactShare> ContactShares = [select Id from ContactShare where UserOrGroup.name='' and ContactId =  con_Id];
        delete ContactShares;
    }

    
    
    
      public SWS_MarketoIntegrationBatch(List<Id> contact_Ids){
        this.ContactIds = contact_Ids;
    }
    
	public Database.queryLocator start(Database.BatchableContext bc){        
        SWS_UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName ='']?.Id;
    	String query = 'SELECT Id FROM Contact WHERE Id IN :ContactIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){       
       
        List<ContactShare> contactShared = new List<ContactShare>([SELECT Id FROM ContactShare WHERE UserOrGroupId =:SWS_UserOrGroupId AND ContactId  IN :contactList]);
        List<ContactShare> ContactShares = new List<ContactShare>();
        if(contactShared.isEmpty()){
		
		  for(Contact con : contactList){
                ContactShare conShare = new ContactShare();
                conShare.ContactId  = con.Id;
                conShare.RowCause = Schema.ContactShare.RowCause.Manual;
                conShare.UserOrGroupId = SWS_UserOrGroupId;
                conShare.ContactAccessLevel  = 'Read';
                ContactShares.add(conShare);
            }
            Database.insert(ContactShares,true);
        }		
    }
    
    public void finish(Database.BatchableContext bc) {
         
    }
*/
}