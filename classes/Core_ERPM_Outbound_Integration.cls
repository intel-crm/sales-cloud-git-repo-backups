public class Core_ERPM_Outbound_Integration {

    public static void evaluateAndSetERPMOutboundIntegrationStatus(List<Contact> contactList, Set<Id> contactIdList, Boolean agsFlag) {
        system.debug('evaluateAndSetERPMOutboundIntegrationStatus enter');
        if((contactList != null && contactList.size() > 0) || (contactIdList != null && contactIdList.size() > 0)){
            /*List<Id> contactIdList = new List<Id>();
            for(Contact contact : contactList) {
                contactIdList.add(contact.Id);
            }*/
            
            if(contactIdList == null) {   
                contactIdList = new Set<Id>();
                for(Contact contact : contactList) {
                    contactIdList.add(contact.Id);
                }
            }
            List<Contact> contactUpdateList = new List<Contact>();
            for(Contact contact : [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id IN : contactIdList]) {
                System.debug('ERPM_Outbound_Inegration  :  Core_ERPM_Integration_Queue_txt__c - ' +contact.Core_ERPM_Integration_Queue_txt__c);
                System.debug('ERPM_Outbound_Inegration  :  Core_ERPM_Integration_Status__c - ' +contact.Core_ERPM_Integration_Status__c);
                system.debug('agsFlag - '+agsFlag);
                if(agsFlag) {
                    System.debug('Updating Contact ' + contact.Id + ' Core_AGS_Integration_Status__c value to Pending');
                    contact.Core_AGS_Integration_Status__c = 'Pending';
                }
                if(contact.Core_ERPM_Integration_Status__c != 'Pending' && contact.Core_ERPM_Integration_Status__c != 'In-Progress') {
                    System.debug('Updating Contact ' + contact.Id + ' Core_ERPM_Integration_Status__c value to Pending && Core_ERPM_Integration_Queue_txt__c value to Empty');
                    contact.Core_ERPM_Integration_Status__c = 'Pending';
                    contact.Core_ERPM_Integration_Queue_txt__c = 'Empty';                    
                    contactUpdateList.add(contact);
                } else if((contact.Core_ERPM_Integration_Status__c == 'Pending' || contact.Core_ERPM_Integration_Status__c == 'In-Progress') 
                          && contact.Core_ERPM_Integration_Queue_txt__c != 'Full') {
                    System.debug('Updating Contact ' + contact.Id + ' Core_ERPM_Integration_Queue_txt__c value to Full');
                    contact.Core_ERPM_Integration_Queue_txt__c = 'Full';
                    contactUpdateList.add(contact);
                } else {
                    System.debug('No change done to  Contact ' + contact.Id + ' for Core_ERPM_Integration_Queue_txt__c && Core_ERPM_Integration_Status__c');
                    System.debug('Core_ERPM_Integration_Status__c ' + contact.Core_ERPM_Integration_Status__c);
                    System.debug('Core_ERPM_Integration_Queue_txt__c ' + contact.Core_ERPM_Integration_Queue_txt__c);
                    if(agsFlag) {
                        contactUpdateList.add(contact);
                    }                    
                }               
            }
            if(contactUpdateList.size() > 0) {
                system.debug('before update');
                update contactUpdateList;
            }
        }
    }

    public static void forceSetERPMOutboundIntegrationStatus(List<Contact> contactList) {
        if(contactList != null && contactList.size() > 0) {
            List<Contact> contactUpdateList = new List<Contact>();
            for(Contact contact : contactList) {
                if(contact.Core_Republish_OBM_s__c && !contact.Core_IPS_Employee_Customer__c){
                    System.debug('Updating Contact ' + contact.Id + ' Core_ERPM_Integration_Status__c value to Pending && Core_ERPM_Integration_Queue_txt__c value to Empty');
                    //contact.Core_ERPM_Integration_Status__c = 'Pending';
                    //contact.Core_AGS_Integration_Status__c = 'Pending';
                    //contact.Core_Republish_OBM_s__c = false;                  
                    //contact.Core_ERPM_Integration_Queue_txt__c = 'Empty';
                    //contactUpdateList.add(contact);
                    contactUpdateList.add(new Contact(
                        Id = contact.Id,
                        Core_ERPM_Integration_Status__c = 'Pending',
                        Core_AGS_Integration_Status__c = 'Pending',
                        Core_Republish_OBM_s__c = false,                  
                        Core_ERPM_Integration_Queue_txt__c = 'Empty'));
                }
            }
            if(contactUpdateList.size() > 0) {
                update contactUpdateList;
            }
        }
    }    
}