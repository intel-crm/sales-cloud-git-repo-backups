public class Core_Batch_SyncContact_AGS implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
       // return Database.getQueryLocator([SELECT ID, NAME, Core_Enterprise_Id__c FROM Contact  where Core_Enterprise_Id__c != null limit 99 ]);
        List<String> Contacts=Label.Core_Contact_AGS_Sync_Label1.split(',');
        contacts.addAll(Label.Core_Contact_AGS_Sync_Label2.split(','));
        System.debug('Contacts ID: '+contacts);
        return Database.getQueryLocator([SELECT ID, NAME, Core_Enterprise_Id__c FROM Contact  where Id in :contacts ]);
   }
    
    public void execute(Database.BatchableContext BC, List<Contact> lContacts){
        System.debug('lContacts ID: '+lContacts);
        for(Contact c : lContacts){
            String rep = Core_HttpCallouts_Handler.getUpdatedAGSStatus(c);
            System.debug(' Response '+rep);
            
        }
    } 
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    
}