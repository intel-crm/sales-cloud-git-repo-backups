/******************************************************************************************************************************************
Class Name  : Core_ContactEntitlementHandler
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Handles all trigger logic for the object Contact Entitlement. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Zay Montalbo              11/03/2016              Original version 
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
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
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
             Core_ContactEntitlementValidation.addContactEntitlementSubordinates(lstNewList);
            }
        }
    }
    
    
    // Handle all "Before" logic on Contact Entilement
    public static void beforeMethod(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newList,
                                    Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap)
    {
        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
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
            Core_ContactEntitlementValidation.validateContactEntitlement(oldList, newList, oldMap, newMap);
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
            //lstNewConEntitlement[0].addError('You cannot edit');
        }
        
          

    }
    
    /***************************************************************************************************
Version     : 1.0 
Function    : This method shares assets to customers
Input Parameters: User New List
Output Parameters: None
Transactions: After Intert           
Used in     : Core_User Trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ganapati                    22/04/2020              Created for US618169 - PRB000091747: Fix issue with Product Access and when Contacts become IPS Active
****************************************************************************************************/     
    public static void shareAssetsToCustomers(Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap) {
        System.debug('shareAssetsToCustomers called');
        List<User> usrList;
        Set<Id> contactIdSet = new Set<Id>();
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('shareAssetsToCustomers')) {
            return;
        }
        if(oldMap != null && newMap != null) {
        	for(Id entitlementId : newMap.keySet()) {
                if( (Label.Core_Entitlement_IPS_Id.contains(String.valueOf(newMap.get(entitlementId).Core_Entitlement_Id__c).substring(0, 15)) || Label.Core_Entitlement_Partner_IPS_Id.contains(String.valueOf(newMap.get(entitlementId).Core_Entitlement_Id__c).substring(0, 15))) && oldMap.get(entitlementId).Core_Status__c != newMap.get(entitlementId).Core_Status__c &&  'Complete'.equalsIgnoreCase(newMap.get(entitlementId).Core_Status__c)) {
                    contactIdSet.add(newMap.get(entitlementId).Core_Contact_Id__c);                    
                }
        	}    
        }
        System.debug('contactIdSet '+contactIdSet);
        if(!contactIdSet.isEmpty()) {
            List<User> userList = new List<User>();
            if(User.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.User.fields.ContactId.isAccessible() && Schema.SObjectType.User.fields.UserRoleId.isAccessible()) {
                userList = [SELECT Id, Contact.AccountId, ContactId, UserRoleId FROM User WHERE ContactId != null and Contact.Core_IPS_Active__c = true and Contact.Account.Core_IPS_Active__c = true AND ContactId IN :contactIdSet AND (Profile.Name = : System.Label.Core_IPS_Profile_Name OR Profile.Name =: System.Label.Core_IPS_Partner_AE_ProfileName OR  Profile.Name =: 'Partner') ];
            }
            if(userList!=null && !userList.isEmpty()) {
                Set<Id> accountIdSet = new Set<Id>();
                Map<Id, Set<Id>> assetUsrRoleIdMap = new Map<Id, Set<Id>>();
                Map<Id, Id> assetShareIdMap = new Map<Id, Id>();
                List<Asset> assetToShare = new List<Asset>();
                Map<Id, Id> groupUsrRoleIdMap = new Map<Id, Id>();
                Map<Id, Asset> assetMap;
                List<AssetShare> assetShareList;
                List<Group> groupList;
                
                for(User usr : userList ) {
                    accountIdSet.add(usr.Contact.AccountId);
                }
                
                if(!accountIdSet.isEmpty()) {
                    if(Asset.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Asset.fields.AccountId.isAccessible() && Schema.SObjectType.Asset.fields.Status.isAccessible() && Schema.SObjectType.Asset.fields.Core_IPS_Project__c.isAccessible() && Schema.SObjectType.Asset.fields.RecordTypeId.isAccessible()) {
                        assetMap = new Map<Id, Asset>([SELECT Id, AccountId, Status, Core_IPS_Project__c, RecordTypeId FROM Asset WHERE AccountId IN :accountIdSet]);
                    }
                    if(AssetShare.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.AssetShare.fields.AssetId.isAccessible() && Schema.SObjectType.AssetShare.fields.UserOrGroupId.isAccessible()) { 
                        assetShareList = [select AssetId, Asset.AccountId, UserOrGroupId from AssetShare  where Asset.AccountId IN : accountIdSet];
                    }
                    if(Group.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Group.fields.RelatedId.isAccessible()) {
                        groupList  = [SELECT Id, RelatedId FROM Group WHERE Id IN ( SELECT UserOrGroupId FROM AssetShare WHERE Asset.AccountId IN : accountIdSet)];
                    }
                }
                if( groupList != null && !groupList.isEmpty()) {				
                    for(Group grpObj : groupList) {
                        groupUsrRoleIdMap.put(grpObj.Id, grpObj.RelatedId);
                    }
                }
                if(assetShareList!=null && !assetShareList.isEmpty() && !groupUsrRoleIdMap.isEmpty()) {
                    for(AssetShare assetShareObj : assetShareList) {	
                        if(assetUsrRoleIdMap.get(assetShareObj.AssetId)!= null) {
                            assetUsrRoleIdMap.get(assetShareObj.AssetId).add(groupUsrRoleIdMap.get(assetShareObj.UserOrGroupId));
                        } else {
                            Set<Id> usrRoleSet = new Set<Id>();
                            usrRoleSet.add(groupUsrRoleIdMap.get(assetShareObj.UserOrGroupId));
                            assetUsrRoleIdMap.put(assetShareObj.AssetId, usrRoleSet);
                        }
                    }
                }
                if(assetMap!=null && !assetMap.isEmpty()) {
                    for(User usr : userList ) {
                        for(Id assetid : assetMap.keySet()) {
                            if(!(assetUsrRoleIdMap != null && !assetUsrRoleIdMap.isEmpty() && assetUsrRoleIdMap.get(assetid).contains(usr.UserRoleId))) {
                                assetToShare.add(assetMap.get(assetid));
                            } 
                        }
                    }
                }
                if(assetToShare!=null && !assetToShare.isEmpty()) {
                    List<Asset> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Asset',assetToShare);
                    if(ipsNewRecordList!=null && !ipsNewRecordList.isEmpty()) {
                        String newListStr = JSON.serialize(ipsNewRecordList);
                        System.debug('newListStr '+newListStr);
                        Core_Asset_Handler.grantAssetAccesstoCustomers(newListStr); //Sharing asset to IPS External
                    }
                }
            }   
        }
    }   
    

}