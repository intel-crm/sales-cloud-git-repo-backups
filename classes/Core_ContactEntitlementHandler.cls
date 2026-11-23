/******************************************************************************************************************************************
Class Name  : Core_ContactEntitlementHandler
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Handles all trigger logic for the object Contact Entitlement. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Zay Montalbo              11/03/2016              Original version 
* NP(11630236)				7/20/2020				Added code to process CCP Entitlements
*****************************************************************************************************************************************/
public class Core_ContactEntitlementHandler {
    // Static variables to prevent unwanted re-entry
    public static Boolean memberDeletionTaskCleanup = false;
    public static Boolean assignToUserLookup = false;
    
    
    // DML static variables to perform all DML in consolidated operations at the end
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;
    
    // Map of our Trigger execution flags
    //public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    
    public static void afterMethod(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newList,
                                    Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap)
    {
        System.debug(' ++++++++++++++++ afterMethod  '+newList.size()+'++++++'+newList);
        System.debug(' ++++++++++++++++ afterMethod  ++++++'+oldList);

        if (Trigger.isInsert) {
            System.debug('Zay - Inside After Insert Contact Entitlement Trigger');
            Core_ContactEntitlementValidation.addContactEntitlementSubordinates(newList);
        } 
        if (Trigger.isUpdate) {
            List<Core_Contact_Entitlement__c> lstNewList = new List<Core_Contact_Entitlement__c>();
            System.debug('Zay - Inside After Update Contact Entitlement Trigger');
            for(Core_Contact_Entitlement__c conEntRef : newList){
              Core_Contact_Entitlement__c conEntRefOld = oldMap.get(conEntRef.Id);
             if(conEntRef.Core_Selected__c != conEntRefOld.Core_Selected__c){
              lstNewList.add(conEntRef);
             }
            }
            if(lstNewList.size()>0){
             //Core_ContactEntitlementValidation.addContactEntitlementSubordinates(lstNewList);
            }
        
            //Process CCP Entitlements
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_CCPContactsProcessingOnCE') 
               && mapFunctionalityNameTriggerExecution.get('Core_MDF_CCPContactsProcessingOnCE').Core_Active__c){
                
                Map<string,string> ccpEntitlementMap = new Map<string,string>();
                List<Core_Contact_Entitlement__c> toBeProcessed = new List<Core_Contact_Entitlement__c>();
                   
                //Querying for all CCP Entitlements
                for(string entitlementToChannelProgram : Label.Core_MDF_User_Group_Mapping_Automation_Audience_List.split(';')){
                    List<string> record = entitlementToChannelProgram.split(':');
                    ccpEntitlementMap.put(record[0].toUpperCase(),record[1]);
                }                 
            
                for(Core_Contact_Entitlement__c ce: newList){
                    if(ce.Core_Status__c == 'Complete' && ccpEntitlementMap.get((ce.Core_Entitlement_Nm__c).toUpperCase()) != null){
                        toBeProcessed.add(ce); 
                    }
                }
            
                if(toBeProcessed.size()>0){
                    system.debug('Inside CCP Code');
                    ID jobID = System.enqueueJob(new Core_MDF_Process_CCP_Contacts(toBeProcessed));
                }
            }
        }
        
    }
    
    
    // Handle all "Before" logic on Contact Entilement
    public static void beforeMethod(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newList,
                                    Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap)
    {
        //mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        system.debug('mapFunctionalityNameTriggerExecution keys:'+mapFunctionalityNameTriggerExecution.keySet());
        System.debug(' ++++++++++++++++ beforeMethod '+newList.size()+'++++++'+newList);
        System.debug(' ++++++++++++++++ beforeMethod ++++++'+oldList);
       
        // Filtering Contact Entitlement with only selected true for validation
        //Moved the below lines of code into handler -- Sudhir 
        /*List<Core_Contact_Entitlement__c> newselectedList=new List<Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c ce: newList){
            if(ce.Core_Selected__c){
                newselectedList.add(ce);
            }
        }*/
        
        if (Trigger.isInsert || Trigger.isUpdate) {
              if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntValidationSwitch') &&
               mapFunctionalityNameTriggerExecution.get('Core_ContactEntValidationSwitch').Core_Active__c){
                   system.debug('new code called');
                   Core_ContactEntitlementValidation.validateContactEntitlementModified(oldList, newList, oldMap, newMap);
               }
            else{
                 system.debug('old code called');
                Core_ContactEntitlementValidation.validateContactEntitlement(oldList, newList, oldMap, newMap);
            }
        }
        //if (Trigger.isUpdate) {
        // Placeholder for future code
        //}
        //if (Trigger.isDelete) {
        // Placeholder for future code
        //}
        
        // Perform any inserts, if we have anything to insert
        /*if (!objectsToInsertCounter) {
//objectsToInsertCounter = true;

//if (objectsToInsert.size() > 0) {
//insert objectsToInsert.values();
//objectsToInsert.clear();
//}
//}*/
        
        // Perform any updates, if we have anything to update
        /*if (!objectsToUpdateCounter) {
objectsToUpdateCounter = true;

if (objectsToUpdate.size() > 0) {
update objectsToUpdate.values();
objectsToUpdate.clear();
}
}*/
        
        // Perform any deletions, if we have anything to delete
        /*if (!objectsToDeleteCounter) {
objectsToDeleteCounter = true;

if (objectsToDelete.size() > 0) {
delete objectsToDelete.values();
objectsToDelete.clear();
}
}*/
    }
    public static void updateIntegrationStatusAfterDataLoad(List<Core_Contact_Entitlement__c> newList) {
        Set<Id> sContactIds = new Set<Id>();
        List<Contact> lContactsToUpdate = new List<Contact>();
        for(Core_Contact_Entitlement__c conEntObj : newList) {
            if(conEntObj.Core_Data_Loaded__c) {
                sContactIds.add(conEntObj.Core_Contact_Id__c);
            }
        }
        for(Id contactId : sContactIds) {
            Contact conToUpdate = new Contact(id=contactId,Core_ERPM_Integration_Status__c = 'Pending', 
                                              Core_AGS_Integration_Status__c = 'Pending');
            lContactsToUpdate.add(conToUpdate);
        }
        if(lContactsToUpdate != null && lContactsToUpdate.size() > 0) {
            update lContactsToUpdate;
        }
    }
    /*This method is to update IPS Active flag for account and contact objects when Contact Entitlement Selected flag is updated    */
    public static void updateIPSActiveOnContact(List<Core_Contact_Entitlement__c> lstNewConEntitlement,List<Core_Contact_Entitlement__c> lstOldConEntitlement,Boolean isInserted,Boolean isUpdated){
        set<Id> stContactEnts = new set<Id>();
        List<Core_Contact_Entitlement__c> lstConEnt = new List<Core_Contact_Entitlement__c>();
        List<Contact> lstContactsUpdate = new List<Contact>();
        
        if(isInserted){
            for(Core_Contact_Entitlement__c refNewConEnt :lstNewConEntitlement){
                if(refNewConEnt.Core_Selected__c == true && (refNewConEnt.Core_Entitlement_Id__c == Label.Core_Entitlement_IPS_Id || refNewConEnt.Core_Entitlement_Id__c == Label.Core_Entitlement_Partner_IPS_Id || refNewConEnt.Core_Entitlement_Id__c == Label.Core_Partner_FAE_Entitlement_ID)){
                    stContactEnts.add(refNewConEnt.Id);
                }
            }
            
            if(stContactEnts.size()>0){
                lstConEnt = [Select id,Core_Selected__c,Core_Contact_Id__c,Core_Contact_Id__r.Accountid,Core_Contact_Id__r.Core_IPS_Active__c,Core_Contact_Id__r.Account.Core_IPS_Active__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c WHERE Id IN : stContactEnts];  
            }
            for(Core_Contact_Entitlement__c objConEnt : lstConEnt){
                if(objConEnt.Core_Selected__c == true && objConEnt.Core_Contact_Id__r.Core_IPS_Active__c == false){
                    Contact conRef = new Contact(id=objConEnt.Core_Contact_Id__c);
                    conRef.Core_IPS_Active__c = true;
                    lstContactsUpdate.add(conRef);
                }
            }
        }
        
        if(isUpdated){
            System.debug('===In Update===');
            Map<Id,Core_Contact_Entitlement__c> mapOldRec = new Map<Id,Core_Contact_Entitlement__c>();
            for(integer i=0;i<lstNewConEntitlement.size();i++){
                Core_Contact_Entitlement__c refNewConEnt = lstNewConEntitlement[i];
                Core_Contact_Entitlement__c refOldConEnt = lstOldConEntitlement[i];
                if(refNewConEnt.Core_Selected__c != refOldConEnt.Core_Selected__c && (refNewConEnt.Core_Entitlement_Id__c == Label.Core_Entitlement_IPS_Id || refNewConEnt.Core_Entitlement_Id__c == Label.Core_Entitlement_Partner_IPS_Id || refNewConEnt.Core_Entitlement_Id__c == Label.Core_Partner_FAE_Entitlement_ID)){
                    mapOldRec.put(refOldConEnt.id,refOldConEnt);
                    stContactEnts.add(refNewConEnt.Id);
                }
            }
            
            if(stContactEnts.size()>0){
                lstConEnt = [Select id,Core_Selected__c,Core_Contact_Id__c,Core_Contact_Id__r.Accountid,Core_Contact_Id__r.Core_IPS_Active__c,Core_Contact_Id__r.Account.Core_IPS_Active__c,Core_Entitlement_Id__r.Name From Core_Contact_Entitlement__c WHERE Id IN : stContactEnts];  
            }
            System.debug('==lstConEnt==='+lstConEnt);
            
            for(Core_Contact_Entitlement__c refNewConEnt : lstConEnt){
                Core_Contact_Entitlement__c refOldConEnt = mapOldRec.get(refNewConEnt.id);
                System.debug('==1==>'+refNewConEnt.Core_Selected__c);
                System.debug('==2==>'+refOldConEnt.Core_Selected__c);
                System.debug('==3==>'+refNewConEnt.Core_Contact_Id__r.Core_IPS_Active__c);
                System.debug('==4==>'+refNewConEnt.Core_Contact_Id__r.Account.Core_IPS_Active__c);
                if(refNewConEnt.Core_Selected__c == true && refOldConEnt.Core_Selected__c == false  && refNewConEnt.Core_Contact_Id__r.Core_IPS_Active__c == false){
                    Contact conRef = new Contact(id=refNewConEnt.Core_Contact_Id__c);
                    conRef.Core_IPS_Active__c = true;
                    lstContactsUpdate.add(conRef);
                }else if(refNewConEnt.Core_Selected__c == false && refOldConEnt.Core_Selected__c == true   && refNewConEnt.Core_Contact_Id__r.Core_IPS_Active__c == true){
                    Contact conRef = new Contact(id=refNewConEnt.Core_Contact_Id__c);
                    conRef.Core_IPS_Active__c = false;
                    lstContactsUpdate.add(conRef);
                }
            }
            
        }
        try{
            System.debug('==lstContactsUpdate.size()==='+lstContactsUpdate.size());
            if(lstContactsUpdate.size()>0){
                update lstContactsUpdate;
            }
        }catch(Exception e){
            System.debug('Exception : '+e);
        }
    }
    

}