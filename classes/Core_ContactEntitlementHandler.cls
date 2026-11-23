/******************************************************************************************************************************************
Class Name  : Core_ContactEntitlementHandler
Version     : 1.0 
Created Date: 05 OCT 2015
Function    : Handles all trigger logic for the object Contact Entitlement. This implements the new trigger framework agreed on in Q3 2015.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Zay Montalbo              11/03/2016              Original version 
* Subhadeep Sadhu			5/11/2021				Modified assignRemovePermissionSetsPublicGroups method as a part of PS assignment and removal fixed
*****************************************************************************************************************************************/
public without sharing class Core_ContactEntitlementHandler {
    // Static variables to prevent unwanted re-entry
    public static Boolean memberDeletionTaskCleanup = false;
    public static Boolean assignToUserLookup = false;
    public static Boolean beforeMethodFirstEntry = true; // Added by Akshay [Draco] to have check on re-entering methods on false triggers - 17-09-2021
    public static Boolean afterMethodFirstEntry = true; // Added by Akshay [Draco] to have check on re-entering methods on false triggers - 17-09-2021
    public static Boolean IPAfirstentUpdate = true;// Added by Agate to avoid recurssion
    
    public static Boolean UpdateACRCheck = true;
    public static Boolean updatePsPgAssignmentRemovalCheck = true;
    // DML static variables to perform all DML in consolidated operations at the end
    public static Map<Id,sObject> objectsToInsert = new Map<Id,sObject>();
    public static Boolean objectsToInsertCounter = false;
    
    public static Map<Id,sObject> objectsToUpdate = new Map<Id,sObject>();
    public static Boolean objectsToUpdateCounter = false;
    
    public static Map<Id,sObject> objectsToDelete = new Map<Id,sObject>();
    public static Boolean objectsToDeleteCounter = false;
    
    // Map of our Trigger execution flags
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution;
    
    public static final Integer MAX_SOQL_COUNT = 50000;
    
    public static void afterMethod(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newList,
                                   Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap)
    {
        System.debug(' ++++++++++++++++ afterMethod  '+newList.size()+'++++++'+newList);
        System.debug(' ++++++++++++++++ afterMethod  ++++++'+oldList);
        
        //if (Trigger.isInsert){ //|| Trigger.isUpdate) {
        //Update membershipchange ind in Account on change MP Entitlements 
        if (Trigger.isInsert) {
            updateMembershipChangeInd(newList, null, 'AFTER_INSERT');
        }
        if (Trigger.isUpdate) {
            updateMembershipChangeInd(newList, oldMap, 'AFTER_UPDATE');
        }
        
        if (Trigger.isInsert && Core_ContactEntitlementValidation.isAddContactEntitlementTriggerAgain < 1) {
            System.debug('Zay - Inside After Insert Contact Entitlement Trigger');
            System.debug('::::::::::PM Insert Beging::::::::'+ Limits.getQueries());
            Core_ContactEntitlementValidation.addContactEntitlementSubordinates(newList);
            System.debug('::::::::::PM Insert End::::::::'+Limits.getQueries());
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
            if(lstNewList.size()>0 && Core_ContactEntitlementValidation.isAddContactEntitlementTriggerAgain < 4){
                Core_ContactEntitlementValidation.addContactEntitlementSubordinates(lstNewList);
            }
            Boolean triggerExecution = [Select Active__c from Trigger_Execution__mdt where MasterLabel ='assignRemovePermissionSetsPublicGroups' Limit 1].Active__c;
            if(triggerExecution) {
                assignRemovePermissionSetsPublicGroups(newList, oldMap);
            }
        }
        System.debug('::::::::::PM Finally::::::::'+Limits.getQueries());
    }
    
    
    // Handle all "Before" logic on Contact Entilement
    public static void beforeMethod(List<Core_Contact_Entitlement__c> oldList, List<Core_Contact_Entitlement__c> newList,
                                    Map<Id,Core_Contact_Entitlement__c> oldMap, Map<Id,Core_Contact_Entitlement__c> newMap){
                                        
                                        mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
                                        System.debug(' ++++++++++++++++ beforeMethod > oldList = '+ oldList);
                                        
                                        // Filtering Contact Entitlement with only selected true for validation
                                        //Moved the below lines of code into handler -- Sudhir 
                                        /*List<Core_Contact_Entitlement__c> newselectedList=new List<Core_Contact_Entitlement__c>();
for(Core_Contact_Entitlement__c ce: newList){
if(ce.Core_Selected__c){
newselectedList.add(ce);
}
}*/
                                        
                                        if (Trigger.isInsert || Trigger.isUpdate) {
                                            //Added by Ealisha: Switch based on trigger execution setting for refering to new code if active else old code
                                            if(mapFunctionalityNameTriggerExecution.containsKey('Core_ContactEntValidationSwitch') &&
                                               mapFunctionalityNameTriggerExecution.get('Core_ContactEntValidationSwitch').Core_Active__c){
                                                   system.debug('new code called');
                                                   Core_ContactEntitlementValidation.validateContactEntitlementModified(oldList, newList, oldMap, newMap);
                                               }
                                            else{
                                                system.debug('old code called');
                                                Core_ContactEntitlementValidation.validateContactEntitlement(oldList, newList, oldMap, newMap);
                                            }
                                            //Core_ContactEntitlementValidation.validateContactEntitlement(oldList, newList, oldMap, newMap);
                                        }
                                        
                                        //if (Trigger.isDelete || Trigger.isUpdate) {
                                        if (Trigger.isDelete) {
                                            //Update membershipchange ind in Account on change MP Entitlements
                                            updateMembershipChangeInd(oldList, null, 'AFTER_DELETE'); 
                                        }
                                        
                                        //end of Trigger.isUpdate & Trigger.isDelete check
                                        
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
    public static void assignRemovePermissionSetsPublicGroups(List<Core_Contact_Entitlement__c> newList, Map<Id,Core_Contact_Entitlement__c> oldMap){
        system.debug('entering method-->');
        List<Id> lstEntitlementIds = new List<Id>();
        //Subhadeep changes START
        Set<PermissionSetAssignment> lstPSAInsert = new Set<PermissionSetAssignment>();
        Set<PermissionSetAssignment> lstPSADelete = new Set<PermissionSetAssignment>();
        Set<GroupMember> lstGMInsert = new Set<GroupMember>();
        Set<GroupMember> lstGMDelete = new Set<GroupMember>();
        //Subhadeep changes END
        Map<Id, String> mapEntitlementIdPSName = new Map<Id, String>();
        Map<Id, String> mapEntitlementPGName = new Map<Id, String>();
        Map<Id, List<Core_Contact_Entitlement__c>> mapContactAssignedCE = new Map<Id, List<Core_Contact_Entitlement__c>>();
        Map<Id, List<Core_Contact_Entitlement__c>> mapContactRemovedCE = new Map<Id, List<Core_Contact_Entitlement__c>>();
        Map<String, Id> mapPermissionsetNameID = new Map<String, Id>();
        Map<String, Id> mapPublicGroupNameID = new Map<String, Id>();
        Map<Id, Id> mapContactIdUserId = new Map<Id, Id>();
        Map<Id, List<Id>> mapUserPermissionsets = new Map<Id, List<Id>>();
        Map<String, PermissionSetAssignment> mapUserPSkeyId = new Map<String, PermissionSetAssignment>();
        Map<Id, List<Id>> mapUserGroupMembers = new Map<Id, List<Id>>();
        Map<String, GroupMember> mapUserPGkeyId = new Map<String, GroupMember>();
        for(Core_Contact_Entitlement__c ce : newList) {
            if(ce.Core_Status__c == 'Complete' && ce.Core_Status__c != oldMap.get(ce.Id).Core_Status__c && ce.Core_Type__c == 'Entitlement'){
                lstEntitlementIds.add(ce.Core_Entitlement_Id__c);
                if(ce.Core_Selected__c) {
                    if(mapContactAssignedCE.containsKey(ce.Core_Contact_Id__c)) {
                        mapContactAssignedCE.get(ce.Core_Contact_Id__c).add(ce);
                    } else {
                        mapContactAssignedCE.put(ce.Core_Contact_Id__c, new List<Core_Contact_Entitlement__c>{ce});
                    }
                }
                if(!ce.Core_selected__c){
                    if(mapContactRemovedCE.containsKey(ce.Core_Contact_Id__c)) {
                        mapContactRemovedCE.get(ce.Core_Contact_Id__c).add(ce);
                    } else {
                        mapContactRemovedCE.put(ce.Core_Contact_Id__c, new List<Core_Contact_Entitlement__c>{ce});
                    }
                }  
            }
            
        }
        System.debug('hey i\'m Here 1');
        if(!lstEntitlementIds.isEmpty() && updatePsPgAssignmentRemovalCheck){
            updatePsPgAssignmentRemovalCheck = false;
            for(Core_Entitlement__c ed : [SELECT Id,Core_Display_Name__c, Core_Permission_Set_API_Nm__c, Core_Public_Group_API_Nm__c FROM Core_Entitlement__c WHERE id IN : lstEntitlementIds AND (Core_Permission_Set_API_Nm__c != null or Core_Public_Group_API_Nm__c != null)]) {
                if(ed.Core_Permission_Set_API_Nm__c != null) {
                    System.debug('hey i\'m Here 1 inside ' + ed.Id + ed.Core_Permission_Set_API_Nm__c);
                    mapEntitlementIdPSName.put(ed.Id,ed.Core_Permission_Set_API_Nm__c);
                }
                if(ed.Core_Public_Group_API_Nm__c != null) {
                    mapEntitlementPGName.put(ed.Id,ed.Core_Public_Group_API_Nm__c);
                }    
            }
            if(!mapEntitlementIdPSName.values().isEmpty() || !mapEntitlementPGName.values().isEmpty()){
                System.debug('hey i\'m Here 2');
                //Subhadeep changes START
                //for(User usr : [SELECT Id, Name, ContactId, Contact.Name, CreatedDate FROM User WHERE IsActive = TRUE AND Profile.Name = 'Partner' AND (ContactId IN : mapContactAssignedCE.keySet() OR ContactId IN : mapContactRemovedCE.keySet())]){
                for(User usr : [SELECT Id, Name, ContactId, Contact.Name, CreatedDate FROM User WHERE Profile.Name = 'Partner' AND (ContactId IN : mapContactAssignedCE.keySet() OR ContactId IN : mapContactRemovedCE.keySet())]){
                //Subhadeep changes END    
                    mapContactIdUserId.put(usr.ContactId,usr.Id);
                }
                System.debug('hey i\'m Here 3');
                //PermissionSets Assignment & Removal Logic 
                if(!mapEntitlementIdPSName.values().isEmpty()) {
                    for(PermissionSetAssignment ps : [SELECT Id,AssigneeId, PermissionSetId, PermissionSet.Name  FROM PermissionSetAssignment WHERE AssigneeId IN : mapContactIdUserId.values()]) {
                        mapUserPSkeyId.put(ps.AssigneeId+''+ps.PermissionSetId,ps);
                        if(mapUserPermissionsets.containsKey(ps.AssigneeId)){
                            mapUserPermissionsets.get(ps.AssigneeId).add(ps.PermissionSetId);
                        } else {
                            mapUserPermissionsets.put(ps.AssigneeId, new List<Id>{ps.PermissionSetId});
                        }
                    }
                    System.debug('hey i\'m Here 4');
                    for(PermissionSet ps: [SELECT Id, Name, Label FROM PermissionSet WHERE Name IN: mapEntitlementIdPSName.values()]) {
                        mapPermissionsetNameID.put(ps.Name, ps.Id);
                    }
                    System.debug('hey i\'m Here 5');
                    for(Id conId : mapContactAssignedCE.keySet()) {
                        for(Core_Contact_Entitlement__c ceAssigned : mapContactAssignedCE.get(conId)) {
                            if(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c) !=null && 
                               mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c) != null && 
                               mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c))!= null && 
                               !mapUserPermissionsets.get(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c)).contains(mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c)))){
                                   PermissionSetAssignment psa = new PermissionSetAssignment();
                                   psa.AssigneeId = mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c);
                                   psa.PermissionSetId = mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c));
                                   lstPSAInsert.add(psa);
                               }
                        }
                    }
                    
                    for(Id conId : mapContactRemovedCE.keySet()) {
                        for(Core_Contact_Entitlement__c ceRemoved : mapContactRemovedCE.get(conId)) {
                            if(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c) !=null &&
                               mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c) != null &&
                               mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c))!= null && 
                               mapUserPermissionsets.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)).contains(mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c)))){
                                   lstPSADelete.add(mapUserPSkeyId.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)+''+mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c)))); 
                               }
                        }
                    }
                }
                
                //Public Group Assignment and removal
                if(!mapEntitlementPGName.values().isEmpty()) {
                    for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN : mapContactIdUserId.values()]) {
                        mapUserPGkeyId.put(gm.UserOrGroupId+''+gm.GroupId,gm);
                        if(mapUserGroupMembers.containsKey(gm.UserOrGroupId)){
                            mapUserGroupMembers.get(gm.UserOrGroupId).add(gm.GroupId);
                        } else {
                            mapUserGroupMembers.put(gm.UserOrGroupId, new List<Id>{gm.GroupId});
                        }
                    }
                    
                    for(Group grp: [SELECT Id, DeveloperName  FROM Group WHERE DeveloperName IN: mapEntitlementPGName.values()]) {
                        mapPublicGroupNameID.put(grp.DeveloperName, grp.Id);
                    }
                    
                    for(Id conId : mapContactAssignedCE.keySet()) {
                        for(Core_Contact_Entitlement__c ceAssigned : mapContactAssignedCE.get(conId)) {
                            
                            if(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c) !=null && 
                               mapEntitlementPGName.get(ceAssigned.Core_Entitlement_Id__c) != null && 
                               mapPublicGroupNameID.get(mapEntitlementPGName.get(ceAssigned.Core_Entitlement_Id__c))!= null /*&& 
                               !mapUserGroupMembers.get(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c)).contains(mapPublicGroupNameID.get(mapEntitlementPGName.get(ceAssigned.Core_Entitlement_Id__c)))*/)//Subhadeep commented
                            {//Subhadeep changes START
                                   If(mapUserGroupMembers.get(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c)) != null)
                                       If(!mapUserGroupMembers.get(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c)).contains(mapPublicGroupNameID.get(mapEntitlementPGName.get(ceAssigned.Core_Entitlement_Id__c)))){
                                           //Subhadeep changes END
                                   GroupMember gm = new GroupMember();
                                   gm.UserOrGroupId = mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c);
                                   gm.GroupId = mapPublicGroupNameID.get(mapEntitlementPGName.get(ceAssigned.Core_Entitlement_Id__c));
                                   lstGMInsert.add(gm);
                                       }
                               }
                        }
                    }
                    
                    for(Id conId : mapContactRemovedCE.keySet()) {
                        for(Core_Contact_Entitlement__c ceRemoved : mapContactRemovedCE.get(conId)) {
                
                            if(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c) !=null &&
                               mapEntitlementPGName.get(ceRemoved.Core_Entitlement_Id__c) != null &&
                               mapPublicGroupNameID.get(mapEntitlementPGName.get(ceRemoved.Core_Entitlement_Id__c))!= null /*&& 
                               mapUserGroupMembers.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)).contains(mapPublicGroupNameID.get(mapEntitlementPGName.get(ceRemoved.Core_Entitlement_Id__c)))*/)//SUBHADEEP commented
                            {
                                //Subhadeep changes START
                                   If(mapUserGroupMembers.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)) != null)
                                       If(mapUserGroupMembers.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)).contains(mapPublicGroupNameID.get(mapEntitlementPGName.get(ceRemoved.Core_Entitlement_Id__c)))){
                                       //Subhadeep changes END
                                   lstGMDelete.add(mapUserPGkeyId.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)+''+mapPublicGroupNameID.get(mapEntitlementPGName.get(ceRemoved.Core_Entitlement_Id__c)))); 
                                       }
                               }
                        }
                    }
                }
                updatePsPgAssignmentRemoval(JSON.serialize(lstPSAInsert), JSON.serialize(lstPSADelete), JSON.serialize(lstGMInsert), JSON.serialize(lstGMDelete));
            }
        }
    }
    @future
    public static void updatePsPgAssignmentRemoval(String strPSAInsert, String strPSADelete, String strGMInsert, String strGMDelete) {
        system.debug('entering removal method-->');
        if(updatePsPgAssignmentRemovalCheck){
            updatePsPgAssignmentRemovalCheck = false; 
            List<PermissionSetAssignment> lstPSAInsert = (List<PermissionSetAssignment>)JSON.deserialize(strPSAInsert, List<PermissionSetAssignment>.class);
            List<PermissionSetAssignment> lstPSADelete = (List<PermissionSetAssignment>)JSON.deserialize(strPSADelete, List<PermissionSetAssignment>.class);
            List<GroupMember> lstGMInsert = (List<GroupMember>)JSON.deserialize(strGMInsert, List<GroupMember>.class);
            List<GroupMember> lstGMDelete = (List<GroupMember>)JSON.deserialize(strGMDelete, List<GroupMember>.class);
            if(!lstPSAInsert.isEmpty()){
                insert lstPSAInsert;
            }
            if(!lstPSADelete.isEmpty()){
                delete lstPSADelete;
            }
            if(!lstGMInsert.isEmpty()){
                insert lstGMInsert;
            }
            if(!lstGMDelete.isEmpty()){
                delete lstGMDelete;
            }
        }
    }
    
    public static void updateMembershipChangeInd(List<Core_Contact_Entitlement__c> newList, Map<Id,Core_Contact_Entitlement__c> oldMap, String  triggerEvent) {
        Set<Id> setConIds=new Set<Id>();
        List<String> lstEntitlementIds = new List<String>();
        List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
        String strMPEntitlementIds = System.Label.PMP_External_Entitlement_Ids;
        
        if(!Test.isRunningTest()){
            lstEntitlementIds = strMPEntitlementIds.split(';');             
        }else{
            //Querying Entitlement Detail
            entitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        // Changes made by Manikanta 
        for(Core_Contact_Entitlement__c ce: newList){
            
            if(triggerEvent == 'AFTER_INSERT' && lstEntitlementIds.contains(ce.Core_Entitlement_Id__c) && ce.Core_Status__c == 'Complete' && ce.Core_Selected__c == True) {
                setConIds.add(ce.Core_Contact_Id__c);
            }
            else if(triggerEvent == 'AFTER_UPDATE' && lstEntitlementIds.contains(ce.Core_Entitlement_Id__c) && 
                    ((ce.Core_Status__c == 'Complete' && oldMap.get(ce.Id).Core_Status__c != 'Complete') || 
                     (ce.Core_Selected__c != oldMap.get(ce.Id).Core_Selected__c && ce.Core_Status__c == 'Complete' && oldMap.get(ce.Id).Core_Status__c == 'Complete'))) {
                         
                         setConIds.add(ce.Core_Contact_Id__c);
                     } else if(triggerEvent == 'AFTER_DELETE' && lstEntitlementIds.contains(ce.Core_Entitlement_Id__c)) {
                         setConIds.add(ce.Core_Contact_Id__c);
                     }
        }
        // End of changes made by Manikanta 
        if(setConIds.isEmpty()){
            return;
        }
        
        Map<String, Account> mapAccsToUpdate = new Map<String, Account>();
        for(Contact con: [Select Name, AccountId, Core_IPA_One_Partner_Id__c from Contact where Id IN :setConIds]) {
            Id idAcc = con.Core_IPA_One_Partner_Id__c != null ? con.Core_IPA_One_Partner_Id__c : con.AccountId;
            Account accTemp = new Account();
            accTemp.Id = idAcc;
            accTemp.Core_PMP_Membership_Change_Ind__c = true;
            mapAccsToUpdate.put(idAcc, accTemp);
        }
        
        if(!mapAccsToUpdate.isEmpty()){
            update mapAccsToUpdate.values();
        }
        
    }
    
    
    public static void updateIntegrationStatusAfterDataLoad(List<Core_Contact_Entitlement__c> newList) {
        system.debug('entering method');
        Set<Id> sContactIds = new Set<Id>();
        List<Contact> lContactsToUpdate = new List<Contact>();
        for(Core_Contact_Entitlement__c conEntObj : newList) {
            if(conEntObj.Core_Data_Loaded__c) {
                sContactIds.add(conEntObj.Core_Contact_Id__c);
            }
        }
        for(Id contactId : sContactIds) {
            Contact conToUpdate = new Contact(id=contactId
                                              //,Core_ERPM_Integration_Status__c = 'Pending', 
                                              //Core_AGS_Integration_Status__c = 'Pending'
                                             );
            lContactsToUpdate.add(conToUpdate);
        }
        if(lContactsToUpdate != null && lContactsToUpdate.size() > 0) {
            system.debug('entering if');
            //update lContactsToUpdate;
            //eRPM - Trigger logic - atb
            //Setting AGs and eRPM integration status to pending
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(lContactsToUpdate, null, true);
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
    
    public static void updateACR(Map<Id,Core_Contact_Entitlement__c> mapNewConEntitlement,Map<Id,Core_Contact_Entitlement__c> mapOldConEntitlement){
        
        if(UpdateACRCheck){
            UpdateACRCheck = true;    //Changes temp
            string STR_COMPLETE = 'Complete';
            String STR_ELIGIBLE_ENTITLEMENT = 'Partner Admin,Partner Admin Delegate,Employee';
            String STR_PARTNER_PROGRAME = 'Intel Partner Alliance (IPA)'; 
            
            set<Id> ceIds = new set<Id>();
            set<Id> conIds = new set<Id>();
            set<Id> entIds = new set<Id>();
            Map<String,Id> mapPCRNameWithId = new Map<String,Id>();
            for(PRM_ContactRelationships__c pcr : [SELECT Name,Id FROM PRM_ContactRelationships__c]){
                mapPCRNameWithId.put(pcr.Name,pcr.Id);
            }		
            for(Core_Contact_Entitlement__c ce : mapNewConEntitlement.values()){
                Core_Contact_Entitlement__c oldCE = mapOldConEntitlement.get(ce.Id);
                system.debug('Inside 0 If$$$$'+ce.Core_Status__c + oldCE.Core_Status__c + ce.Core_Category__c);
                if ( ce.Core_Status__c == STR_COMPLETE && oldCE.Core_Status__c != ce.Core_Status__c
                    && ce.Core_Selected__c == oldCE.Core_Selected__c
                    && ce.Core_Category__c == STR_PARTNER_PROGRAME){
                        ceIds.add(ce.Id);
                        conIds.add(ce.Core_Contact_Id__c);
                        entIds.add(ce.Core_Entitlement_Id__c);
                        system.debug('Inside 1 If$$$$');
                    }
                
            }
            list<PRM_Account_Contact_Relationship__c> acrToCreate = new list<PRM_Account_Contact_Relationship__c>();
            list<PRM_Account_Contact_Relationship__c> acrToUpdate = new list<PRM_Account_Contact_Relationship__c>();
            
            list<Contact> lstContacts = [SELECT Id,AccountId, (SELECT Id, Core_Selected__c,Core_Entitlement_Id__r.Core_Display_Name__c,		Core_Entitlement_Id__c FROM Contact_Entitlements__r WHERE Id =:ceIds),(SELECT Id,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM Account_Contact_Relationships__r order by PRM_Relationship_Id__r.Name desc) FROM Contact
                                         WHERE Id =:conIds ]; //Shashwat Changes
            Core_Contact_Entitlement__c coreEntitlements; 
            Map<String,Boolean> mapEntitlemenNameWithActiveIndicator;
            for(Contact conObj : lstContacts){
                system.debug('Inside 2 If$$$$');
                mapEntitlemenNameWithActiveIndicator = new Map<String,Boolean>();	
                map<String,PRM_Account_Contact_Relationship__c> mapRelationshipWithACR = new map<String,PRM_Account_Contact_Relationship__c>();
                if(conObj.Contact_Entitlements__r.size() > 0){
                    for(Core_Contact_Entitlement__c ce : conObj.Contact_Entitlements__r){
                        if ( STR_ELIGIBLE_ENTITLEMENT.contains(ce.Core_Entitlement_Id__r.Core_Display_Name__c) ){
                            system.debug('Inside 3 If$$$$');
                            mapEntitlemenNameWithActiveIndicator.put(ce.Core_Entitlement_Id__r.Core_Display_Name__c,ce.Core_Selected__c);
                        }	
                        system.debug('Inside 3.1 If$$$$'+mapEntitlemenNameWithActiveIndicator);
                    }
                    
                    if(conObj.Account_Contact_Relationships__r.size() > 0){
                        system.debug('Inside 4 Size If$$$$'+conObj.Account_Contact_Relationships__r.size());
                        for(PRM_Account_Contact_Relationship__c acr : conObj.Account_Contact_Relationships__r){
                            mapRelationshipWithACR.put(acr.PRM_Relationship_Id__r.Name,acr);
                        }
                        system.debug('Inside 4.1 If$$$$'+mapPCRNameWithId);
                        for(String str : mapEntitlemenNameWithActiveIndicator.keySet()){						
                            system.debug('Inside 4.2 If$$$$'+str);
                            system.debug('Inside 4.3 If$$$$'+mapEntitlemenNameWithActiveIndicator);
                            if(mapRelationshipWithACR.containsKey(str)){
                                system.debug('Inside 5 If$$$$');
                                PRM_Account_Contact_Relationship__c acr = mapRelationshipWithACR.get(str);
                                
                                acr.PRM_InActive_Ind__c = !mapEntitlemenNameWithActiveIndicator.get(acr.PRM_Relationship_Id__r.Name);
                                acrToUpdate.add(acr);
                            }else{
                                system.debug('Inside 6 If$$$$');
                                acrToCreate.add(new PRM_Account_Contact_Relationship__c (
                                    PRM_Account_Id__c = conObj.AccountId,
                                    PRM_Contact_Id__c = conObj.Id,
                                    PRM_Relationship_Id__c = mapPCRNameWithId.get(str)
                                    //PRM_Status_Nm__c = STR_COMPLETE
                                ));
                            }
                        }
                    }else{
                        
                        for(String entName : mapEntitlemenNameWithActiveIndicator.keySet()){
                            system.debug('Inside 7 If$$$$');
                            acrToCreate.add(new PRM_Account_Contact_Relationship__c (
                                PRM_Account_Id__c = conObj.AccountId,
                                PRM_Contact_Id__c = conObj.Id,
                                PRM_Relationship_Id__c =  mapPCRNameWithId.get(entName)
                                //PRM_Status_Nm__c = STR_COMPLETE
                            ));
                            
                        }
                    }
                }
            }  
            if(!acrToCreate.isEmpty()){
                system.debug('Inside 8 If$$$$'+acrToCreate);
                Database.insert(acrToCreate);            
            }
            if(!acrToUpdate.isEmpty()){
                Database.update(acrToUpdate);            
            }
        }
    } 
    
    public static void sendEmailOnCEUpdateToComplete(Map<Id,Core_Contact_Entitlement__c> mapNewConEntitlement,Map<Id,Core_Contact_Entitlement__c> mapOldConEntitlement){
        System.debug('Start of Method \nUsed -->'+limits.getQueries()+'Limit -->'+limits.getLimitQueries());
        System.debug(' Recieved Entlmnt -->'+mapNewConEntitlement.values());
        // get employee and Partner admin entitlement id
        
        Map<Id,String> entitlmentIdName = new Map<Id, String>();
        Map<Id, Integer> entitlementsInQueue = new Map<Id, Integer>();
        
        boolean isEmployeeOnly = false;
        Boolean isPartnerAdmin = false;
        Id firstContactId = null;
        String firstContactEmail =null;
        boolean proccessEmployee=false;
        // get all the contact ids from Entitlement
        Set<Id> ctIds = new Set<Id>();
        Map<Id, Integer> contactEntitlementsCntMap = new Map<Id, Integer>();
        
        for(Core_Contact_Entitlement__c ce : mapNewConEntitlement.values()){            
            if(Label.PRM_Employee_and_Super_user_Entitlements.split(';').contains(ce.Core_Entitlement_Nm__c)){
                ctIds.add(ce.Core_Contact_Id__c);                     
            }            
        }
        System.debug('Contact ids -->'+ctIds);
        
        // get contact entitlement for ctIds
        if(ctIds!=null && !ctIds.isEmpty()){
            for(Core_Contact_Entitlement__c ce : [select id, name, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Entitlement_Id__r.name from Core_Contact_Entitlement__c
                                                  where Core_Contact_Id__c in :ctIds and Core_Entitlement_Id__r.name in :Label.PRM_Employee_and_Super_user_Entitlements.split(';')]){                                                      
                                                      if(contactEntitlementsCntMap.containskey(ce.Core_Contact_Id__c)){
                                                          contactEntitlementsCntMap.put(ce.Core_Contact_Id__c, contactEntitlementsCntMap.get(ce.Core_Contact_Id__c)+1);//contactEntitlementsMap.get(ce.Core_Contact_Id__c).add(ce.Core_Entitlement_Id__c)
                                                      }else{
                                                          contactEntitlementsCntMap.put(ce.Core_Contact_Id__c, 1);
                                                      }
                                                  }
        }
        
        System.debug('contactEntitlementsCntMap -->'+contactEntitlementsCntMap);
        for(Core_Contact_Entitlement__c ce : mapNewConEntitlement.values()){
            System.debug('ce -->'+ce);
            if((mapNewConEntitlement.get(ce.id).Core_Status__c==Label.PRM_Complete && mapNewConEntitlement.get(ce.id).core_selected__c)){
                    if((mapNewConEntitlement.get(ce.id).Core_Entitlement_Nm__c==Label.PRM_Partner_Admin || mapNewConEntitlement.get(ce.id).Core_Entitlement_Nm__c==Label.PRM_Partner_Admin_Delegate)){
                        proccessEmployee= false;                        
                        firstContactId = ce.Core_Contact_Id__c;
                        firstContactEmail=ce.Core_Contact_Id__r.Email;
                        break;
                    }else if(mapNewConEntitlement.get(ce.id).Core_Entitlement_Nm__c==Label.PRM_Entitlement_Employee){
                        if(contactEntitlementsCntMap!=null && !contactEntitlementsCntMap.isEmpty() && contactEntitlementsCntMap.containskey(ce.Core_Contact_Id__c) && contactEntitlementsCntMap.get(ce.Core_Contact_Id__c)==1){
                            proccessEmployee = true;                            
                            firstContactId = ce.Core_Contact_Id__c;
                            firstContactEmail=ce.Core_Contact_Id__r.Email;
                            break;
                        }
                    }
                }
        }
        System.debug('ctIds -->'+ctIds);        
        System.debug('contactEntitlementsCntMap -->'+contactEntitlementsCntMap);       
        
        Set<Id> empContactIds = new Set<Id>();                
        if(proccessEmployee || !isEmployeeOnly){
            Boolean SupressEmail =false;
            List<PRM_Bulk_Data_Upload__c> bulkUploadrecord =[SELECT Id,PRM_Suppress_Email__c,PRM_Contact_Email__c from PRM_Bulk_Data_Upload__c Where PRM_Contact_Email__c=:firstContactEmail order by CreatedDate LIMIT 1];        
            if(bulkUploadrecord.size()>0){
                SupressEmail=bulkUploadrecord[0].PRM_Suppress_Email__c;
            }
            if(firstContactId!=null ){
                // get all pending email queue records for that contact
                List<PRM_EmailQueue__c> emailQueueList = new List<PRM_EmailQueue__c>();
                
                for(PRM_EmailQueue__c eq : [Select Id,PRM_Business_Event__c,PRM_Contact__c,PRM_Contact__r.AccountId,PRM_Contact__r.Account.Core_IPA_Badge_Tier__c,
                                            PRM_Contact__r.Core_Preferred_Language__c,PRM_Contact__r.Email,PRM_Contact__r.Core_Do_Not_Contact__c,
                                            PRM_Status__c,PRM_PartnerRole__c,PRM_Registration_Request__c,CreatedDate from PRM_EmailQueue__c 
                                            where prm_contact__c = :firstContactId and PRM_Status__c = :Label.PRM_Status_Pending AND PRM_Business_Event__c != '' and PRM_IsInactive__c= false ORDER BY PRM_Priority__c NULLS LAST,CreatedDate]){
                                                emailQueueList.add(eq);
                                            }    
                
                
                
                System.debug('emailQueueList -->'+emailQueueList);
                
                Map<String,PRM_EmailQueue__c> contactEmailQueue = new Map<String,PRM_EmailQueue__c>();         // contact and email queue
                Map<String,PRM_EmailQueue__c> mapOfProcessContactId = new Map<String,PRM_EmailQueue__c>();	// processed contact and associated Email Queue
                
                Map<String,PRM_EmailConfiguration__mdt> mapEmailConfiguration = new Map<String,PRM_EmailConfiguration__mdt>();
                Map<String,PRM_EmailConfiguration__mdt> mapEmailConfigurationOnTier = new Map<String,PRM_EmailConfiguration__mdt>();
                
                Set<String> partnerRoleonTier = new Set<String>();
                
                
                try{
                    List<PRM_EmailConfiguration__mdt> emailConfigList= [Select Id,PRM_BusinessEvent__c,PRM_PartnerRole__c,PRM_Entitlement_List__c,PRM_Priority__c,PRM_Tier__c from PRM_EmailConfiguration__mdt ORDER BY PRM_Priority__c];
                    PRM_EmailConfiguration__mdt eConfig;
                    for(PRM_EmailConfiguration__mdt emailCon : emailConfigList){
                        //map of business event+partner role , emailCon 
                        if(mapEmailConfiguration.containsKey(emailCon.PRM_BusinessEvent__c+emailCon.PRM_PartnerRole__c)){
                            eConfig = mapEmailConfiguration.get(emailCon.PRM_BusinessEvent__c+emailCon.PRM_PartnerRole__c);
                            mapEmailConfiguration.remove(emailCon.PRM_BusinessEvent__c+emailCon.PRM_PartnerRole__c);
                            mapEmailConfigurationOnTier.put(eConfig.PRM_BusinessEvent__c+eConfig.PRM_PartnerRole__c+eConfig.PRM_Tier__c, eConfig);
                            mapEmailConfigurationOnTier.put(emailCon.PRM_BusinessEvent__c+emailCon.PRM_PartnerRole__c+emailCon.PRM_Tier__c, emailCon);
                            partnerRoleonTier.add(emailCon.PRM_PartnerRole__c);
                        }else if(partnerRoleonTier.contains(emailCon.PRM_PartnerRole__c)){
                            mapEmailConfigurationOnTier.put(emailCon.PRM_BusinessEvent__c+emailCon.PRM_PartnerRole__c+emailCon.PRM_Tier__c, emailCon);
                        }else{
                            mapEmailConfiguration.put(emailCon.PRM_BusinessEvent__c+emailCon.PRM_PartnerRole__c,emailCon);
                        }
                    }
                    
                    //contact Id - entitlement List Map from Email Queue
                    //starts
                    Map<String,PRM_EmailQueue__c> partnerRoleEmailQueueMap = new Map<String,PRM_EmailQueue__c>(); //contact and email que            
                    Map<String,String> mapOfContactEntitlement= new Map<String,String>();//
                    Map<String,String> mapOfContactandBusinessEvent= new Map<String,String>();
                    //Set<Id> processedIds = new Set<Id>();
                    
                    if(emailQueueList!=null && !emailQueueList.isEmpty()){
                        for(PRM_EmailQueue__c ec : emailQueueList){
                            //processedIds.add(ec.Id);// email q ids
                            partnerRoleEmailQueueMap.put(ec.PRM_Contact__c,ec);               
                            if(mapEmailConfiguration.containsKey(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c)){
                                String entitlements = '';
                                entitlements = mapEmailConfiguration.get(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c).PRM_Entitlement_List__c;                   
                                mapOfContactEntitlement.put(ec.PRM_Contact__c,entitlements);
                                //     mapOfContactandBusinessEvent.put(ec.PRM_Contact__c,ec.PRM_Business_Event__c);
                            }else if(mapEmailConfigurationOnTier.containsKey(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c+ec.PRM_Contact__r.Account.Core_IPA_Badge_Tier__c)){
                                String entitlements = '';
                                entitlements = mapEmailConfigurationOnTier.get(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c+ec.PRM_Contact__r.Account.Core_IPA_Badge_Tier__c).PRM_Entitlement_List__c;
                                mapOfContactEntitlement.put(ec.PRM_Contact__c,entitlements);
                                //     mapOfContactandBusinessEvent.put(ec.PRM_Contact__c,ec.PRM_Business_Event__c);
                            }
                        }
                    }
                    
                    Map<String,Set<String>> mapOfQueueContactEntitlement= new Map<String,Set<String>>();
                    if(mapOfContactEntitlement!=null){
                        for(String contactId : mapOfContactEntitlement.keySet()){
                            String en = mapOfContactEntitlement.get(contactId);
                            Set<String> finalSetOfQueueEntitlements = new Set<String>(en.split(','));                
                            mapOfQueueContactEntitlement.put(contactId,finalSetOfQueueEntitlements);
                        }
                    }
                    
                    System.debug('mapOfQueueContactEntitlement -->'+mapOfQueueContactEntitlement);
                    
                    
                    List<PRM_Language_Culture_Mapping__mdt> cultureMdt = new List<PRM_Language_Culture_Mapping__mdt>();
                    PRM_Language_Culture_Mapping__mdt englishMdt = new PRM_Language_Culture_Mapping__mdt();
                    for(PRM_Language_Culture_Mapping__mdt mdt : [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt]){
                        cultureMdt.add(mdt);
                        if(mdt.PRM_Country__c =='USA'){
                            englishMdt= mdt;                       
                        }
                    }
                    
                    
                    Map<Id,PRM_Language_Culture_Mapping__mdt> langCultureForEmail =  new Map<Id,PRM_Language_Culture_Mapping__mdt>();
                    for(Contact conRecord : [Select Id,MailingCountryCode,Core_Preferred_Language__c from Contact where Id =:firstContactId]){      
                        for(PRM_Language_Culture_Mapping__mdt mdtRec:cultureMdt){              
                            System.debug('mdtRec -->'+mdtRec);
                            if(mdtRec.PRM_Country_Cd__c != null && conRecord.MailingCountryCode.equalsIgnoreCase('USA') && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us')){
                                langCultureForEmail.put(conRecord.Id, mdtRec);
                            }
                            if(langCultureForEmail!=null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(conRecord.MailingCountryCode) && mdtRec.MasterLabel == conRecord.Core_Preferred_Language__c){
                                langCultureForEmail.put(conRecord.Id, mdtRec);
                            }               
                        }
                    }
                    
                    System.debug('langCultureForEmail -->'+langCultureForEmail);
                    
                    if(firstContactId!=null){
                        // for(String conId : empContactIds){            
                        if(partnerRoleEmailQueueMap.keySet().contains(firstContactId)){                    
                            PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();                       
                            map<String, String> inputParameters = new map<String, String>();
                            objEmailNotif.InputParameters=inputParameters;
                            objEmailNotif.BusinessEvent=partnerRoleEmailQueueMap.get(firstContactId).PRM_Business_Event__c;
                            objEmailNotif.Language = partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.Core_Preferred_Language__c;
                            objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                            objEmailNotif.EmailID= partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.Email;                                       
                            objEmailNotif.partnerAdmin = isEmployeeOnly?false:true;//contactEntitlementsCntMap.get(firstContactId)>1?true:false;                    
                            
                            //set registration request Id only for self registration process
                            if(objEmailNotif.BusinessEvent == System.Label.PRM_Welcome_Email_New_Event || 
                               objEmailNotif.BusinessEvent == System.Label.PRM_Welcome_Email_Existing_Event || objEmailNotif.BusinessEvent == System.label.PRM_Email_Admin_Approval_Event){
                                   inputParameters.put('Registration_Request_ID',partnerRoleEmailQueueMap.get(firstContactId).PRM_Registration_Request__c);
                               }
                            //
                            if(langCultureForEmail != null){
                                System.debug('langCultureForEmail.get(empContactIds[0]).id -->'+langCultureForEmail.containsKey(firstContactId));
                                String metadata = langCultureForEmail.containsKey(firstContactId)?langCultureForEmail.get(firstContactId).id:englishMdt.Id;// need to add english metadat record id
                                inputParameters.put('LanguageCulture_MDT',metadata);                      
                            }
                            
                            if(objEmailNotif.BusinessEvent == System.Label.PRM_Email_Admin_Approval_Event){
                                objEmailNotif.PartnerType=System.Label.PRM_CsP;
                            }
                            else{
                                inputParameters.put('Account_ID',partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.AccountId);
                            }
                            
                            if(partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.Core_Do_Not_Contact__c  == false && SupressEmail==false)
                            {                   
                                //String notification  = JSON.serialize(objEmailNotif);
                                mapOfProcessContactId.put(partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.Email,partnerRoleEmailQueueMap.get(firstContactId)); 
                                //String mpofctids = JSON.serialize(mapOfProcessContactId);*/
                                PRM_EmailUtility.sendEmail(objEmailNotif);//notification, mpofctids, firstContactId, true
                            }
                        }
                        //}
                    }
                    System.debug('mapOfProcessContactId -->'+mapOfProcessContactId);
                    //update email logs on contact for which email is triggered
                    System.debug('Start of Method \nUsed -->'+limits.getQueries()+'Limit -->'+limits.getLimitQueries());
                    //-- update
                    List<PRM_EmailLog__c> emailLogsToUpdate = new List<PRM_EmailLog__c>();
                    
                    Map<String,PRM_EmailLog__c> mapOfContactEmailLog = new Map<String,PRM_EmailLog__c>();
                    Set<String> setOfEmail = new Set<String>();
                    //Set<String> subjectSet = new Set<String>{'[Chinese]Intel® Partner Alliance Gold','Intel® Partner Alliance Gold'};
                    
                    for(PRM_EmailLog__c eLog: [SELECT Id,PRM_Subject__c,PRM_Contact__c,PRM_EmailContent__c,PRM_EmailHTMLContent__c,PRM_User__c,PRM_EmailDeliverabilityStatus__c,PRM_ToEmailID__c,Email_Template_Name__c,
                                               PRM_Contact__r.Core_Preferred_Language__c FROM PRM_EmailLog__c where PRM_ToEmailID__c IN: mapOfProcessContactId.keySet()]){
                                                   System.debug('@@ eLog'+eLog);
                                                   setOfEmail.add(eLog.PRM_ToEmailID__c);
                                                   mapOfContactEmailLog.put(eLog.Id,eLog);
                                               }
                    
                    List<Contact> conList = new List<Contact>();
                    Map<String,PRM_EmailLog__c> mapOfEmailLog = new Map<String,PRM_EmailLog__c>();
                    conList = [Select Id,Email from contact where Email IN: setOfEmail];
                    
                    List<User> userList = new List<User>();
                    
                    if(conList.size()>0){
                        userList = [Select id,Email,contactId from User where contactId=:conList[0].Id];
                    }
                    
                    for(String Id : mapOfContactEmailLog.keyset()){
                        
                        System.debug('@@ conList'+conList);  
                        System.debug('@@ userList'+userList);
                        
                        if(conList.size() > 0){
                            mapOfContactEmailLog.get(Id).PRM_Contact__c = conList[0].Id;
                            if(userList.size() > 0){
                                mapOfContactEmailLog.get(Id).PRM_User__c = userList[0].id;
                            }
                            
                            if(mapOfContactEmailLog.get(Id).Email_Template_Name__c.contains(System.Label.PRM_Registration_Template) ||mapOfContactEmailLog.get(Id).Email_Template_Name__c.contains(System.Label.PRM_Reuse_Registration_Template)){
                                
                                System.debug('@@ Template Name'+mapOfContactEmailLog.get(Id).Email_Template_Name__c);
                                mapOfEmailLog.put(mapOfContactEmailLog.get(Id).PRM_ToEmailID__c,mapOfContactEmailLog.get(Id));
                                
                            }
                            System.debug('@@ mapOfContactEmailLog.get(Id)'+mapOfContactEmailLog.get(Id));
                            System.debug('@@ mapOfContactEmailLog.get(Id).PRM_Contact__c'+mapOfContactEmailLog.get(Id).PRM_Contact__c);
                            emailLogsToUpdate.add(mapOfContactEmailLog.get(Id));
                        }
                    }
                    
                    
                    if(emailLogsToUpdate.size()>0){
                        System.debug('<--Update Email Log 2-->');
                        Database.update(emailLogsToUpdate,false);
                    }
                    
                    system.debug('Total queries executed after updating email logs--->'+Limits.getQueries());
                    system.debug('Total DML Statements after updating email logs--->'+Limits.getDmlStatements());
                    
                    List<PRM_EmailQueue__c> ipaEmailQueueToUpdate = new List<PRM_EmailQueue__c>();
                    for(String email : mapOfProcessContactId.keySet()){
                        if(mapOfEmailLog.containsKey(email)){
                            System.debug('<--Update IPA Email Queue 1-->');
                            
                            //update email content & status to complete only when email deliverability status is true
                            if(mapOfEmailLog.get(email).PRM_EmailDeliverabilityStatus__c == true){
                                if(mapOfEmailLog.get(email).PRM_EmailHTMLContent__c != null){
                                    mapOfProcessContactId.get(email).PRM_Email_Content__c = mapOfEmailLog.get(email).PRM_EmailHTMLContent__c;
                                }
                                else if(mapOfEmailLog.get(email).PRM_EmailContent__c != null){
                                    mapOfProcessContactId.get(email).PRM_Email_Content__c = mapOfEmailLog.get(email).PRM_EmailContent__c;
                                }
                                mapOfProcessContactId.get(email).PRM_Status__c = System.Label.PRM_Complete;
                            }
                            
                            //update status to error when email deliverability status is false
                            else{
                                mapOfProcessContactId.get(email).PRM_Status__c = System.Label.PRM_Error;
                            }
                            ipaEmailQueueToUpdate.add(mapOfProcessContactId.get(email));
                            System.debug('ipaEmailQueueToUpdate '+ipaEmailQueueToUpdate);
                        }
                    }
                    
                    if(ipaEmailQueueToUpdate.size()>0){
                        System.debug('<--Update IPA Email Queue 2-->');
                        Database.update(ipaEmailQueueToUpdate,false);
                    }
                }
                catch(Exception e){
                    PRM_ErrorUtilityClass.logError(e);
                }
            }else{
                System.debug('No Contacts to process.');
            }
        }
    }
    
}