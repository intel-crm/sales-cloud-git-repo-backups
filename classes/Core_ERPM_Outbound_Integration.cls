public without sharing class Core_ERPM_Outbound_Integration {
    
    public static boolean updateContIPAIntStatus = false;
    public static boolean updateContIPAIntStsOnCIMChange = false;
    public static boolean hasEntWithERPMEnga = false; //DRACO Change - Don't change ERPM Integration Status in case of 2.0 flow
    public static boolean UpdateERPMStatus = true; //DRACO Change - Don't change ERPM Integration Status in case of 2.0 flow
    public static boolean UpdateAGSStatus = true; //DRACO Change - Don't Change AGS Integration Status in case of Email-subject change
    
    //public static boolean doNotPublishERPMOBM = true;
    public static List<Contact> contactsToUpdateOnCIMChange = new List<Contact>();
    public static void evaluateAndSetERPMOutboundIntegrationStatus
	(List<Contact> contactList, Set<Id> contactIdList, Boolean agsFlag) {
        system.debug('evaluateAndSetERPMOutboundIntegrationStatus enter');
		Core_Entitlement_Outbound_Integrations.logEntryMsgString+='\nentered in evaluateAndSetERPMOutboundIntegrationStatus --Core_ERPM_Outbound_Integration'+contactList
		+'\ncontId:'+contactIdList+'\nagsFlag'+agsFlag;
        Map<id,Contact> contactsMap = new Map<Id,Contact>();
        Map<Id,Contact> contactsToBeUpdated = new Map<Id,Contact>();
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
            if(updateContIPAIntStatus){
                contactsMap = PRM_SalesCloudContactIntStatus_Handler.getContactsMap(contactIdList);
            }
            
            
            List<Contact> contactUpdateList = new List<Contact>();
            //for(Contact contact : [SELECT Id,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c FROM Contact WHERE Id IN : contactIdList]) {
            //[SELECT Id, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =: contactIdList AND Core_Status__c = 'Pending'])
            for(Contact contact : [SELECT Id,Core_AGS_Integration_Status__c,Core_AGS_Republish_Ind__c,Core_ERPM_Integration_Queue_txt__c,Core_ERPM_Integration_Status__c,PRM_IPA_Integration_Status__c,
                                   (SELECT Id,Core_Entitlement_Id__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c,Core_Entitlement_Id__r.name,Core_Entitlement_Id__r.Core_Entitlement_Type__c,Core_Status__c FROM Contact_Entitlements__r) FROM Contact WHERE Id IN : contactIdList]) {  //TWC729-3874
                                       // System.debug('$$$$MP'+contact);
                                       System.debug('ERPM_Outbound_Inegration  :  Core_ERPM_Integration_Queue_txt__c - ' +contact.Core_ERPM_Integration_Queue_txt__c);
                                       System.debug('ERPM_Outbound_Inegration  :  Core_ERPM_Integration_Status__c - ' +contact.Core_ERPM_Integration_Status__c);
                                       system.debug('agsFlag - '+agsFlag);
                                       boolean addedToContactList = false;
                                       for(Core_Contact_Entitlement__c contEnt: contact.Contact_Entitlements__r){
                                           if(contEnt.Core_Status__c == 'Pending' && contEnt.Core_Entitlement_Id__r.Core_Entitlement_Type__c == 'AGS'){
                                               UpdateAGSStatus = true;
                                           }
                                       }
                                       
                                       if(agsFlag && UpdateAGSStatus) {
                                                                                     
                                           /***********************Draco : AGS Multiple OBM issue 14 Aug - START****************************/
                   
                                           if(contact.Core_AGS_Integration_Status__c != 'Pending' && contact.Core_AGS_Integration_Status__c!= 'In-Progress'){
                                               contact.Core_AGS_Integration_Status__c = 'Pending';
                                               contact.Core_AGS_Republish_Ind__c = false;
                                           }
                                           else if((/*contact.Core_AGS_Integration_Status__c == 'Pending' ||*/ contact.Core_AGS_Integration_Status__c == 'In-Progress')
                                                   && !contact.Core_AGS_Republish_Ind__c){
                                                       contact.Core_AGS_Republish_Ind__c = true;
                                                   }
                                           
                                           /***********************Draco : AGS Multiple OBM issue 14 Aug - END******************************/
                                       }
                                                                           
                                       // To Skip ACR update for ERPM OBM generation (multiple OBM was coming so) - hsk
                                       //if(doNotPublishERPMOBM)
                                       //{
                                       
                                       //**************************** DRACO Change [START] - Don't change ERPM Integration Status in case of 2.0 flow ****************************//
                                       hasEntWithERPMEnga = false;
                                       for(Core_Contact_Entitlement__c conEnt: contact.Contact_Entitlements__r){
                                           if(conEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__c != null){
                                               hasEntWithERPMEnga = true;
                                           }   
                                       }
                                       if(hasEntWithERPMEnga == false && Core_ContactEntitlementHelper.startedFromDataLoad){
                                           UpdateERPMStatus = false;
                                       }
                                       if(contact.Core_ERPM_Integration_Status__c != 'Pending' && contact.Core_ERPM_Integration_Status__c != 'In-Progress' && UpdateERPMStatus) { //Commented " && hasEntWithERPMEnga" and added "UpdateERPMStatus" as ERPM OBM was not sending while self registration
                                           System.debug('Updating Contact ' + contact.Id + ' Core_ERPM_Integration_Status__c value to Pending && Core_ERPM_Integration_Queue_txt__c value to Empty');
                                           contact.Core_ERPM_Integration_Status__c = 'Pending';
                                           contact.Core_ERPM_Integration_Queue_txt__c = 'Empty';                    
                                           //contactUpdateList.add(contact);                    
                                           //addedToContactList = true;
                                           contactsToBeUpdated.put(contact.id, contact);
                                       } else if((contact.Core_ERPM_Integration_Status__c == 'Pending' || contact.Core_ERPM_Integration_Status__c == 'In-Progress' && UpdateERPMStatus) //Commented " && hasEntWithERPMEnga" and added "UpdateERPMStatus" as ERPM OBM was not sending while self registration
                                                 && contact.Core_ERPM_Integration_Queue_txt__c != 'Full') {
                                                     System.debug('Updating Contact ' + contact.Id + ' Core_ERPM_Integration_Queue_txt__c value to Full');
                                                     contact.Core_ERPM_Integration_Queue_txt__c = 'Full';
                                                     //contactUpdateList.add(contact);                    
                                                     //addedToContactList = true;
                                                     contactsToBeUpdated.put(contact.id, contact);
                                                 } 
                                       else {
                                           System.debug('No change done to  Contact ' + contact.Id + ' for Core_ERPM_Integration_Queue_txt__c && Core_ERPM_Integration_Status__c');
                                           System.debug('Core_ERPM_Integration_Status__c ' + contact.Core_ERPM_Integration_Status__c);
                                           System.debug('Core_ERPM_Integration_Queue_txt__c ' + contact.Core_ERPM_Integration_Queue_txt__c);
                                           if(agsFlag) {
                                               //contactUpdateList.add(contact);                    
                                               //addedToContactList = true;
                                               contactsToBeUpdated.put(contact.id, contact);
                                           }                    
                                       } 
                                       
                                       //}
                                       if(updateContIPAIntStatus && contactsMap!=null && contactsMap.containsKey(contact.Id) && contact.PRM_IPA_Integration_Status__c != 'Pending') {
                                           //contact.PRM_IPA_Integration_Status__c = 'Pending';
                                           //if(!addedToContactList) {
                                           //    contactUpdateList.add(contact);  
                                           //}  
                                           if(contactsToBeUpdated.containsKey(contact.id)){
                                               contactsToBeUpdated.get(contact.id).PRM_IPA_Integration_Status__c = 'Pending';
                                           }else{
                                               contact.PRM_IPA_Integration_Status__c = 'Pending';
                                               contactsToBeUpdated.put(contact.id, contact);
                                           }    
                                       }               
                                       
                                   }            
        }
        if(updateContIPAIntStsOnCIMChange && contactsToUpdateOnCIMChange.size() > 0 ){
                //Set<Id> alreadyAddedContIds = new Set<Id>();                    
                for(Contact cont: contactsToUpdateOnCIMChange) {
                    if(contactsToBeUpdated.size()> 0 && contactsToBeUpdated.containsKey(cont.id)){
                        contactsToBeUpdated.get(cont.id).PRM_IPA_Integration_Status__c = 'Pending';
                    }else{
                        cont.PRM_IPA_Integration_Status__c = 'Pending';
                        contactsToBeUpdated.put(cont.id, cont);
                    }
                }
                Core_Entitlement_Outbound_Integrations.logEntryMsgString+='\nentered 4th if(updateContIPAIntStsOnCIMChange) block '+contactsToBeUpdated;								  					
                
                
            }
            /*
System.debug('$$$$MP contactUpdateList'+contactUpdateList);
if(contactUpdateList.size() > 0) {
system.debug('before update');
update contactUpdateList;
}*/
            if(contactsToBeUpdated.size() > 0){
                update contactsToBeUpdated.values();
            }
			Core_Entitlement_Outbound_Integrations.logEntryMsgString+='\nupdated contactsToBeUpdated: '+contactsToBeUpdated;								  					
    }
    
    public static void forceSetERPMOutboundIntegrationStatus(List<Contact> contactList) {
        Map<String,Integer> contactEntitilementCountMapping = new Map<String,Integer>();
        Map<Id,String> contactEntitilementStatusMap = new Map<Id,String>();
        Set<Id> contactIdSet= new Set<id>();
        for(Contact contact : contactList){
            contactIdSet.add(contact.id);
        }
        System.debug('ContactIdSet'+contactIdSet);
        
                  
            for(AggregateResult ar : [SELECT count(id),Core_Contact_Id__c from Core_Contact_Entitlement__c  WHERE  Core_Contact_Id__c IN : contactIdSet AND Core_Type__c = 'Entitlement' AND Core_Status__c = 'Pending' group by Core_Contact_Id__c]){
                Integer countResult = Integer.valueOf(ar.get('expr0'));
                contactEntitilementCountMapping.put((Id)ar.get('Core_Contact_Id__c'),countResult);
                
            }
        
        System.debug('contactEntitilementCountMapping'+  contactEntitilementCountMapping);
        System.debug('contactEntitilementStatusMap'+  contactEntitilementStatusMap);
        if(contactList != null && contactList.size() > 0) {
            List<Contact> contactUpdateList = new List<Contact>();
            for(Contact contact : contactList) {
                if(contact.Core_Republish_OBM_s__c && !contact.Core_IPS_Employee_Customer__c){
                    System.debug('Updating Contact ' + contact.Id + ' Core_ERPM_Integration_Status__c value to Pending && Core_ERPM_Integration_Queue_txt__c value to Empty');

                    if(contactEntitilementCountMapping.containsKey(contact.id) && contactEntitilementCountMapping.get(contact.id)>0){
                        
                        contact.Core_ERPM_Integration_Status__c = 'Pending';
                        contact.Core_AGS_Integration_Status__c = 'Pending';
                        contact.Core_Republish_OBM_s__c = false;
                        contact.Core_AGS_Republish_Ind__c = false;
                        contact.Core_ERPM_Integration_Queue_txt__c = 'Empty';
                    }
                    else{
                        
                        contact.Core_ERPM_Integration_Status__c = 'Pending';
                        //Core_AGS_Integration_Status__c = 'Pending',
                        contact.Core_AGS_Republish_Ind__c = false;
                        contact.Core_Republish_OBM_s__c = false;                
                        contact.Core_ERPM_Integration_Queue_txt__c = 'Empty';
                    }
                }
                /* if(contactUpdateList.size() > 0) {
update contactUpdateList;
}*/
            }
        }
    }    
}