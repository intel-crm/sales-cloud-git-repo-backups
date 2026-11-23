/******************************************************************************************************************************************
Class Name  : Core_ContactEntitlementHelper
Version     : 1.0 
Created Date: 01 Dec 2021
Function    : Handles all trigger logic for the object Contact Entitlement. This implements the new trigger framework.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Harshita              1/12/2021             Original version 
* Subhadeep             25/02/2022            Changes made for multiple P set assignment for single entitlement
* Akshay [Draco]    11/09/2023        Moved logic to "Before" context of the trigger to populate "Status Change Date/Time" from the Workflow rule to reduce SOQL due to trigger re-firing
* Akshay [Draco]        13/11/2023            Added logic to update B2B Flag on Account to TRUE if certain Entitlements are made to TRUE-Complete
*****************************************************************************************************************************************/
public without sharing class Core_ContactEntitlementHelper {    
    //Start---added by popcornapps
    public static Boolean updatePsPgAssignmentRemovalCheck = true;
    //End----added by popcornapps
    public static Boolean UpdateACRCheck = true;
    public static Boolean IPAfirstentUpdate=false;
    public static Boolean triggerMethodFirstEntry = true;
    public static Boolean triggerAfterMethodFirstEntry = true;
    public static boolean startedFromDataLoad = false; //DRACO Change - Don't change ERPM Integration Status in case of 2.0 flow
    public static Boolean updateIPAIntegrationStatus = false;
    
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh); // :RUBY - IPA 2.0 ADDED BY DINESH
    
    public static List<Account> updateMembershipChangeInd(List<Core_Contact_Entitlement__c> newList, Map<Id,Core_Contact_Entitlement__c> oldMap, String  triggerEvent) {
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
                     (ce.Core_Selected__c==true && ce.Core_Selected__c != oldMap.get(ce.Id).Core_Selected__c ))) {
                         
                         setConIds.add(ce.Core_Contact_Id__c);
                     } 
        }
        
        // End of changes made by Manikanta
        Map<String, Account> mapAccsToUpdate = new Map<String, Account>();
        if(!setConIds.isEmpty()){
            for(Contact con: [Select Core_IPA_One_Partner_Id__c from Contact where Id IN :setConIds]) {
                Id idAcc = con.Core_IPA_One_Partner_Id__c;
                if(idAcc != null){
                    Account accTemp = new Account();
                    accTemp.Id = idAcc;
                    accTemp.Core_PMP_Membership_Change_Ind__c = true;
                    mapAccsToUpdate.put(idAcc, accTemp);
                }
            }
        }
        return mapAccsToUpdate.values();
        
    }
    public static void removeSharingForStorefronts(List<Core_Contact_Entitlement__c> newList, Map<Id,Core_Contact_Entitlement__c> oldMap, String  triggerEvent){
        List<String> lstEntitlementIds = new List<String>();
        list<Core_ACM_Account_Staging__c> lstAccStging=new list<Core_ACM_Account_Staging__c>();
        List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
        String strMPEntitlementIds = System.Label.PMP_External_Entitlement_Ids;
        set<Id> setConIdToRemove=new set<Id>();
        if(!Test.isRunningTest()){
            lstEntitlementIds = strMPEntitlementIds.split(';');
        }else{
            //Querying Entitlement Detail
            entitlementDetails = [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c];
            for(Core_Entitlement__c coreEntitlement : entitlementDetails){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        for(Core_Contact_Entitlement__c ce: newList){
            if(triggerEvent == 'AFTER_UPDATE' && lstEntitlementIds.contains(ce.Core_Entitlement_Id__c) &&
               (ce.Core_Selected__c==false && ce.Core_Selected__c != oldMap.get(ce.Id).Core_Selected__c )) {
                   
                   setConIdToRemove.add(ce.Core_Contact_Id__c);
               } else if(triggerEvent == 'AFTER_DELETE' && lstEntitlementIds.contains(ce.Core_Entitlement_Id__c)) {
                   setConIdToRemove.add(ce.Core_Contact_Id__c);
               }
        }
        
        if(setConIdToRemove!=null && !setConIdToRemove.isEmpty()){
            for(contact con:[Select Core_IPA_One_Partner_Id__c  from contact where id in:setConIdToRemove])
                if(con.Core_IPA_One_Partner_Id__c!=null){
                    Core_ACM_Account_Staging__c accstg =new Core_ACM_Account_Staging__c(
                        AccountId__c= con.Id,
                        Core_Status__c ='NEW',
                        Core_Action__c='REMOVE_MPSHARE'
                    );
                    
                    lstAccStging.add(accstg);
                }
            
        }
        if(lstAccStging!=null && !lstAccStging.isEmpty()){
            insert lstAccStging;
        }
    }
    
    public static List<Account> updateB2BFlagOnAccount(List<Core_Contact_Entitlement__c> newList, Map<Id,Core_Contact_Entitlement__c> oldMap, String  triggerEvent){
        set<Id> B2BEligibleContactsSet = new Set<Id>();
        List<Account> B2BEligibleAccountsList = new List<Account>();
        for(Core_Contact_Entitlement__c currCE : newList){
            // Check if new CE record is TRUE-Complete but Old record was not TRUE-Complete AND that Entitlement is in the list of B2B Entitlements. If YES then add the Contact Id to set to turn Account's B2B Indicator to TRUE.
            if(triggerEvent == 'AFTER_UPDATE' && (currCE.Core_Selected__c == true && currCE.Core_Status__c == 'Complete') && !(oldMap.get(currCE.Id).Core_Selected__c == true && oldMap.get(currCE.Id).Core_Status__c == 'Complete') && System.Label.Core_Entitlements_B2B_Indicator_Update.split(';').contains(currCE.Core_Display_Nm__c)){
                B2BEligibleContactsSet.add(currCE.Core_Contact_Id__c);
            } else if (triggerEvent == 'AFTER_INSERT' && (currCE.Core_Selected__c == true && currCE.Core_Status__c == 'Complete') && System.Label.Core_Entitlements_B2B_Indicator_Update.split(';').contains(currCE.Core_Display_Nm__c)){
                B2BEligibleContactsSet.add(currCE.Core_Contact_Id__c);
            }
        }
        if(!B2BEligibleContactsSet.isEmpty()){
            for(AggregateResult B2BCon : [SELECT AccountId AccountId FROM Contact WHERE Id IN : B2BEligibleContactsSet Group By AccountId]){
                Account tempAcc = new Account();
                tempAcc.Id = (Id) B2BCon.get('AccountId');
                tempAcc.Core_B2B_Entitlement__c = true;
                B2BEligibleAccountsList.add(tempAcc);
            }
        }
        return B2BEligibleAccountsList;
    }
    
    /* In this method we will combine the 2 accounts list and update them at a time. */
    public static void updateAccountFields(List<Account> updateMembChngIndAccounts, List<Account> updateB2BFlagAccounts){
        Set<Id> allAccIdsSet = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        Map<Id, Account> membChangIndAccMap = new  Map<Id, Account>();
        Map<Id, Account> b2bFlagAccMap = new  Map<Id, Account>();
        List<Account> validAccounts = new List<Account>();
        List<Account> validB2BAccounts = new List<Account>();
        if(updateMembChngIndAccounts != null && !updateMembChngIndAccounts.isEmpty()){
            /*  membChangIndAccMap = new Map<Id, Account>(updateMembChngIndAccounts);
allAccIdsSet.addAll(membChangIndAccMap.keySet());*/
            /* for (Id accId : membChangIndAccMap.keySet()) {
if (accId != null) {
allAccIdsSet.add(accId);
}
}*/
            
            for (Account acc : updateMembChngIndAccounts) {
                if (acc.Id != null) {
                    validAccounts.add(acc);
                }
            }
            
            membChangIndAccMap = new Map<Id, Account>(validAccounts);   
            allAccIdsSet.addAll(membChangIndAccMap.keySet());
        }
        if(updateB2BFlagAccounts != null && !updateB2BFlagAccounts.isEmpty()){
            b2bFlagAccMap = new Map<Id, Account>(updateB2BFlagAccounts);
            /* for (Id accId1 : b2bFlagAccMap.keySet()) {
if (accId1 != null) {
allAccIdsSet.add(accId1);
}
}*/
            
            for (Account acc1 : updateB2BFlagAccounts) {
                if (acc1.Id != null) {
                    validB2BAccounts.add(acc1);
                }
            }
            
            b2bFlagAccMap = new Map<Id, Account>(validB2BAccounts);
            allAccIdsSet.addAll(b2bFlagAccMap.keySet());
            
        }
        for(Id accId : allAccIdsSet){
            if(membChangIndAccMap.containsKey(accId) && !b2bFlagAccMap.containsKey(accId)){
                accToUpdate.add(new Account(Id = accId, Core_PMP_Membership_Change_Ind__c= true));
            } else if(b2bFlagAccMap.containsKey(accId) && !membChangIndAccMap.containsKey(accId)){
                accToUpdate.add(new Account(Id = accId, Core_B2B_Entitlement__c= true));
            } else if(membChangIndAccMap.containsKey(accId) && b2bFlagAccMap.containsKey(accId)){
                accToUpdate.add(new Account(Id = accId, Core_PMP_Membership_Change_Ind__c= true, Core_B2B_Entitlement__c= true));
            }
        }
        if(accToUpdate != null){
            update accToUpdate;
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
            
            for(Core_Contact_Entitlement__c refNewConEnt : lstConEnt){
                Core_Contact_Entitlement__c refOldConEnt = mapOldRec.get(refNewConEnt.id);
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
            if(lstContactsUpdate.size()>0){
                update lstContactsUpdate;
            }
        }catch(Exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'updateIPSActiveOnContact', Core_Project__c = 'Core_ContactEntitlementHelper' , Core_Details__c = 'Getting exception for IPS Active flag updation', Core_Severity__c = 'info', Core_When__c = System.Now());
            //insert excepLog;
        }
    }
    
    //Updated Permission set method
    public static void assignRemovePermissionSetsPublicGroups(List<Core_Contact_Entitlement__c> newList, Map<Id,Core_Contact_Entitlement__c> oldMap){
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
        if(!lstEntitlementIds.isEmpty() && updatePsPgAssignmentRemovalCheck){
            updatePsPgAssignmentRemovalCheck = false;
            for(Core_Entitlement__c ed : [SELECT Id, Core_Permission_Set_API_Nm__c, Core_Public_Group_API_Nm__c FROM Core_Entitlement__c WHERE id IN : lstEntitlementIds AND (Core_Permission_Set_API_Nm__c != null or Core_Public_Group_API_Nm__c != null)]) {
                if(ed.Core_Permission_Set_API_Nm__c != null) {
                    List<string> psList = new List<string>();
                    if(ed.Core_Permission_Set_API_Nm__c != null)
                        psList = ed.Core_Permission_Set_API_Nm__c.split(';');
                    mapEntitlementIdPSName.put(ed.Id,ed.Core_Permission_Set_API_Nm__c);
                }
                if(ed.Core_Public_Group_API_Nm__c != null) {
                    List<string> pgList = new List<string>();
                    pgList = ed.Core_Public_Group_API_Nm__c.split(';');
                    mapEntitlementPGName.put(ed.Id,ed.Core_Public_Group_API_Nm__c);
                }
            }
            if(!mapEntitlementIdPSName.values().isEmpty() || !mapEntitlementPGName.values().isEmpty()){
                
                //Subhadeep changes START
                //for(User usr : [SELECT Id, Name, ContactId, Contact.Name, CreatedDate FROM User WHERE IsActive = TRUE AND Profile.Name = 'Partner' AND (ContactId IN : mapContactAssignedCE.keySet() OR ContactId IN : mapContactRemovedCE.keySet())]){
                for(User usr : [SELECT Id, ContactId  FROM User WHERE Profile.Name = 'Partner' AND ((ContactId IN : mapContactAssignedCE.keySet() AND IsActive = TRUE) OR ContactId IN : mapContactRemovedCE.keySet())]){
                    //Subhadeep changes END
                    mapContactIdUserId.put(usr.ContactId,usr.Id);
                }
                
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
                    for(PermissionSet ps: [SELECT Id, Name, Label FROM PermissionSet WHERE Name IN: string.join(mapEntitlementIdPSName.values(),';').split(';')]) {//Changes made for multiple P set assignment for single entitlement
                        mapPermissionsetNameID.put(ps.Name, ps.Id);
                    }
                    for(Id conId : mapContactAssignedCE.keySet()) {
                        for(Core_Contact_Entitlement__c ceAssigned : mapContactAssignedCE.get(conId)) {
                            if(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c) !=null &&
                               mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c) != null)
                                //------START-----Changes made for multiple P set assignment for single entitlement
                                /* &&
mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c))!= null &&
!mapUserPermissionsets.get(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c)).contains(mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c))))*/{
    for(string pSetName :mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c).split(';')){//Changes made for multiple P set assignment for single entitlement
        if(mapPermissionsetNameID.get(pSetName) != null && !mapUserPermissionsets.get(mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c)).contains(mapPermissionsetNameID.get(pSetName))){
            //------END-----Changes made for multiple P set assignment for single entitlement
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c);
            psa.PermissionSetId = mapPermissionsetNameID.get(pSetName);
            lstPSAInsert.add(psa);
        }
    }
    /*PermissionSetAssignment psa = new PermissionSetAssignment();
psa.AssigneeId = mapContactIdUserId.get(ceAssigned.Core_Contact_Id__c);
psa.PermissionSetId = mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceAssigned.Core_Entitlement_Id__c));
lstPSAInsert.add(psa);*/
}
                        }
                    }
                    
                    for(Id conId : mapContactRemovedCE.keySet()) {
                        for(Core_Contact_Entitlement__c ceRemoved : mapContactRemovedCE.get(conId)) {
                            if(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c) !=null &&
                               mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c) != null)
                                //------START-----Changes made for multiple P set assignment for single entitlement
                                /*&&
mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c))!= null &&
mapUserPermissionsets.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)).contains(mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c))))*/{
    for(string pSetName :mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c).split(';')){//Changes made for multiple P set assignment for single entitlement
        if(mapPermissionsetNameID.get(pSetName) != null && mapUserPermissionsets.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)).contains(mapPermissionsetNameID.get(pSetName))){
            lstPSADelete.add(mapUserPSkeyId.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)+''+mapPermissionsetNameID.get(pSetName)));
        }
        //------END-----Changes made for multiple P set assignment for single entitlement
    }
    //lstPSADelete.add(mapUserPSkeyId.get(mapContactIdUserId.get(ceRemoved.Core_Contact_Id__c)+''+mapPermissionsetNameID.get(mapEntitlementIdPSName.get(ceRemoved.Core_Entitlement_Id__c))));
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
                //Draco Change(3 April 2024) Added check for Future and Batch context to avoid calling future method of updatePsPgAssignmentRemoval
                if(!System.isFuture() && !System.isBatch()){
                    updatePsPgAssignmentRemoval(JSON.serialize(lstPSAInsert), JSON.serialize(lstPSADelete), JSON.serialize(lstGMInsert), JSON.serialize(lstGMDelete));
                }
            }
        }
    }
    
    @future
    public static void updatePsPgAssignmentRemoval(String strPSAInsert, String strPSADelete, String strGMInsert, String strGMDelete) {
        try{
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
                    //delete lstPSADelete;
                    //Ganesh Changes
                    Set<Id> psaIds = new Set<Id>();
                    
                    for(PermissionSetAssignment psa : lstPSADelete){
                        if(psa != null && psa.Id != null){
                            psaIds.add(psa.Id);
                        }
                    }
                    
                    List<PermissionSetAssignment> existingPSAs = [SELECT Id FROM PermissionSetAssignment WHERE Id IN :psaIds];
                    
                    if(!existingPSAs.isEmpty()){
                        Database.DeleteResult[] deleteResults = Database.delete(existingPSAs, false);
                        
                        for(Integer i = 0; i < deleteResults.size(); i++){
                            if(!deleteResults[i].isSuccess()){
                                for(Database.Error err : deleteResults[i].getErrors()){
                                    UCD_ACM_Logger.error('Core_ContactEntitlementHelper', 'updatePsPgAssignmentRemoval', 'Failed to delete PSA Id: ' + existingPSAs[i].Id + ' Error: ' + err.getMessage(), null);
                                }
                            }
                        }
                        
                        UCD_ACM_Logger.setLogDetails();
                    }
                    //Ganesh Changes End
                }
                if(!lstGMInsert.isEmpty()){
                    insert lstGMInsert;
                }
                if(!lstGMDelete.isEmpty()){
                    delete lstGMDelete;
                }
            }
        }catch(Exception e){
            UCD_ACM_Logger.error('Core_ContactEntitlementHelper','updatePsPgAssignmentRemoval',e.getMessage(), null);
            UCD_ACM_Logger.setLogDetails();
        }
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
            Contact conToUpdate = new Contact(id=contactId
                                              //,Core_ERPM_Integration_Status__c = 'Pending',
                                              //Core_AGS_Integration_Status__c = 'Pending'
                                             );
            lContactsToUpdate.add(conToUpdate);
        }
        if(lContactsToUpdate != null && lContactsToUpdate.size() > 0) {
            //update lContactsToUpdate;
            //eRPM - Trigger logic - atb
            //Setting AGs and eRPM integration status to pending
            startedFromDataLoad = true; //This variable will tell wheather the transaction is initiated from dataload. Used in Core_Entitlement_Outbound_Integrations from ERPM bypass
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(lContactsToUpdate, null, true);
        }
    }
    
    /* public static void updateACR(Map<Id,Core_Contact_Entitlement__c> mapNewConEntitlement,Map<Id,Core_Contact_Entitlement__c> mapOldConEntitlement){

if(UpdateACRCheck){
UpdateACRCheck = true; //subhadeep changes
string STR_COMPLETE = 'Complete';
String STR_ELIGIBLE_ENTITLEMENT = 'Partner Admin,Partner Admin Delegate,Employee';
String STR_PARTNER_PROGRAME = 'Intel Partner Alliance (IPA)';

set<Id> ceIds = new set<Id>();
set<Id> conIds = new set<Id>();
set<Id> entIds = new set<Id>();
Map<String,Id> mapPCRNameWithId = new Map<String,Id>();
for(Core_Contact_Entitlement__c ce : mapNewConEntitlement.values()){
Core_Contact_Entitlement__c oldCE = mapOldConEntitlement.get(ce.Id);
if ( ce.Core_Status__c == STR_COMPLETE && oldCE.Core_Status__c != ce.Core_Status__c
&& ce.Core_Selected__c == oldCE.Core_Selected__c
&& ce.Core_Category__c == STR_PARTNER_PROGRAME){
ceIds.add(ce.Id);
conIds.add(ce.Core_Contact_Id__c);
entIds.add(ce.Core_Entitlement_Id__c);
}

}
list<PRM_Account_Contact_Relationship__c> acrToCreate = new list<PRM_Account_Contact_Relationship__c>();
list<PRM_Account_Contact_Relationship__c> acrToUpdate = new list<PRM_Account_Contact_Relationship__c>();

if(conIds != null && !conIds.isEmpty()) {
// [DRACO Change] - Added null check for reducing stray SOQLs - 29-04-2022
for(PRM_ContactRelationships__c pcr : [SELECT Name,Id FROM PRM_ContactRelationships__c]){
mapPCRNameWithId.put(pcr.Name,pcr.Id);
}
list<Contact> lstContacts = [SELECT Id,AccountId, (SELECT Id, Core_Selected__c,Core_Entitlement_Id__r.Core_Display_Name__c,    Core_Entitlement_Id__c FROM Contact_Entitlements__r WHERE Id =:ceIds),(SELECT Id,PRM_Relationship_Id__r.Name,PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c FROM Account_Contact_Relationships__r order by PRM_Relationship_Id__r.Name desc) FROM Contact
WHERE Id =:conIds ];
Map<String,Boolean> mapEntitlemenNameWithActiveIndicator;
for(Contact conObj : lstContacts){
mapEntitlemenNameWithActiveIndicator = new Map<String,Boolean>();
map<String,PRM_Account_Contact_Relationship__c> mapRelationshipWithACR = new map<String,PRM_Account_Contact_Relationship__c>();
if(conObj.Contact_Entitlements__r.size() > 0){
for(Core_Contact_Entitlement__c ce : conObj.Contact_Entitlements__r){
if ( STR_ELIGIBLE_ENTITLEMENT.contains(ce.Core_Entitlement_Id__r.Core_Display_Name__c) ){
mapEntitlemenNameWithActiveIndicator.put(ce.Core_Entitlement_Id__r.Core_Display_Name__c,ce.Core_Selected__c);
}
}

if(conObj.Account_Contact_Relationships__r.size() > 0){
for(PRM_Account_Contact_Relationship__c acr : conObj.Account_Contact_Relationships__r){
mapRelationshipWithACR.put(acr.PRM_Relationship_Id__r.Name,acr);
}
for(String str : mapEntitlemenNameWithActiveIndicator.keySet()){
if(mapRelationshipWithACR.containsKey(str)){
PRM_Account_Contact_Relationship__c acr = mapRelationshipWithACR.get(str);

acr.PRM_InActive_Ind__c = !mapEntitlemenNameWithActiveIndicator.get(acr.PRM_Relationship_Id__r.Name);
acrToUpdate.add(acr);
}else{
acrToCreate.add(new PRM_Account_Contact_Relationship__c (
PRM_Account_Id__c = conObj.AccountId,
PRM_Contact_Id__c = conObj.Id,
PRM_Relationship_Id__c = mapPCRNameWithId.get(str),
PRM_Status_Reason_Txt__c = STR_COMPLETE
//PRM_Status_Nm__c = STR_COMPLETE
));
}
}
}else{

for(String entName : mapEntitlemenNameWithActiveIndicator.keySet()){
acrToCreate.add(new PRM_Account_Contact_Relationship__c (
PRM_Account_Id__c = conObj.AccountId,
PRM_Contact_Id__c = conObj.Id,
PRM_Relationship_Id__c =  mapPCRNameWithId.get(entName),
PRM_Status_Reason_Txt__c = STR_COMPLETE
//PRM_Status_Nm__c = STR_COMPLETE
));

}
}
}
}
if(!acrToCreate.isEmpty()){
Database.insert(acrToCreate);
}
if(!acrToUpdate.isEmpty()){
Database.update(acrToUpdate);
}
} // [DRACO Change] - Added null check for reducing stray SOQLs - 29-04-2022
}
}*/ 
    
    
    // IPA 2.0 Refresh  : 29/4/2025 - Changes added for IPA2.0 refresh
    // As per IPA2.0 welcome email will be sent only after Benefits are assigned at OPID
    // COmmented by DINESH - UNUSED CODE
    /*
public static void sendEmailOnCEUpdateToComplete(Map<Id,Core_Contact_Entitlement__c> mapNewConEntitlement,Map<Id,Core_Contact_Entitlement__c> mapOldConEntitlement){
// get employee and Partner admin entitlement id

Map<Id,Core_Contact_Entitlement__c> mapNewConEntitlementCloned = mapNewConEntitlement; // DINESH : Cloned to manipulate the map
Map<String, contactWrapper> contactToWrapperMap = new Map<String, contactWrapper>();
boolean isEmployeeOnly = false;
Id firstContactId = null;
String firstContactEmail =null;
boolean proccessEmployee=false;
// get all the contact ids from Entitlement
Set<Id> ctIds = new Set<Id>();
Map<Id, Integer> contactEntitlementsCntMap = new Map<Id, Integer>();

Set<id> contactMissingEntitlement = new Set<Id>(); // Updated Contacts when existing entitlement is already complete

for(Core_Contact_Entitlement__c ce : mapNewConEntitlementCloned.values()){
if(Label.PRM_Employee_and_Super_user_Entitlements.split(';').contains(ce.Core_Entitlement_Nm__c)){
ctIds.add(ce.Core_Contact_Id__c);
}else{
contactMissingEntitlement.add(ce.Core_Contact_Id__c);
}
}


// find difference
if(ipaRefresh){
contactMissingEntitlement.removeAll(ctIds);
}
if(!contactMissingEntitlement.isEmpty() && ipaRefresh)ctIds.addAll(contactMissingEntitlement);

Set<Id> onePartnerIds = new Set<Id>();

// get contact entitlement for ctIds
if(ctIds!=null && !ctIds.isEmpty()){

contactWrapper cw;

for(Core_Contact_Entitlement__c ce : [select id, name,Core_Contact_Id__r.AccountId, Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Entitlement_Id__r.name from Core_Contact_Entitlement__c
where Core_Contact_Id__c in :ctIds and Core_Entitlement_Id__r.name in :Label.PRM_Employee_and_Super_user_Entitlements.split(';')]){

onePartnerIds.add(ce.Core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c);
if(contactEntitlementsCntMap.containskey(ce.Core_Contact_Id__c)){
contactEntitlementsCntMap.put(ce.Core_Contact_Id__c, contactEntitlementsCntMap.get(ce.Core_Contact_Id__c)+1);//contactEntitlementsMap.get(ce.Core_Contact_Id__c).add(ce.Core_Entitlement_Id__c)
}else{
contactEntitlementsCntMap.put(ce.Core_Contact_Id__c, 1);
}

// IPA 2.0 refresh changes : DINESH
// add the entitlements to the map
if(contactMissingEntitlement.contains(ce.Core_Contact_Id__c) && ipaRefresh){
mapNewConEntitlementCloned.put(ce.id, ce);
}

if(!contactToWrapperMap.containsKey(ce.Core_Contact_Id__c)){
cw = new contactWrapper();
cw.contactId = ce.Core_Contact_Id__c;
cw.accountId = ce.Core_Contact_Id__r.AccountId;
cw.onePartnerId = ce.core_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c;
contactToWrapperMap.put(ce.Core_Contact_Id__c, cw);
}

}
}

//added by DINESH
Map<Id, Integer> accountIdToBnftMap = new Map<Id, Integer>();
List<AggregateResult> aggrResult = new List<AggregateResult>();
// get OPID Benefits
if(ipaRefresh){
aggrResult = [select count(Id) benefitsCount, PRM_Account_Id__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :onePartnerIds  and PRM_Status_Nm__c ='Active' group by PRM_Account_Id__c];
for(AggregateResult result : aggrResult){
accountIdToBnftMap.put((Id)result.get('PRM_Account_Id__c'), (integer)result.get('benefitsCount'));
}

}



for(Core_Contact_Entitlement__c ce : mapNewConEntitlementCloned.values()){
if((mapNewConEntitlementCloned.get(ce.id).Core_Status__c==Label.PRM_Complete && mapNewConEntitlementCloned.get(ce.id).core_selected__c)){

if((mapNewConEntitlementCloned.get(ce.id).Core_Entitlement_Nm__c==Label.PRM_Partner_Admin || mapNewConEntitlementCloned.get(ce.id).Core_Entitlement_Nm__c==Label.PRM_Partner_Admin_Delegate)){

proccessEmployee= false;
firstContactId = ce.Core_Contact_Id__c;
firstContactEmail=ce.Core_Contact_Id__r.Email;
break;
}else if(mapNewConEntitlementCloned.get(ce.id).Core_Entitlement_Nm__c==Label.PRM_Entitlement_Employee){

if(contactEntitlementsCntMap!=null && !contactEntitlementsCntMap.isEmpty() && contactEntitlementsCntMap.containskey(ce.Core_Contact_Id__c) && contactEntitlementsCntMap.get(ce.Core_Contact_Id__c)==1){
proccessEmployee = true;
firstContactId = ce.Core_Contact_Id__c;
firstContactEmail=ce.Core_Contact_Id__r.Email;
break;
}
}
}
}


if(proccessEmployee || !isEmployeeOnly){

if(firstContactId!=null ){
// get all pending email queue records for that contact
List<PRM_EmailQueue__c> emailQueueList = new List<PRM_EmailQueue__c>();

for(PRM_EmailQueue__c eq : [Select Id,PRM_Business_Event__c,PRM_Contact__c,PRM_Contact__r.AccountId,PRM_Contact__r.Account.Core_IPA_Badge_Tier__c,
PRM_Contact__r.Core_Preferred_Language__c,PRM_Contact__r.Email,PRM_Contact__r.Core_Do_Not_Contact__c,
PRM_Status__c,PRM_PartnerRole__c,PRM_Registration_Request__c,CreatedDate from PRM_EmailQueue__c 
where prm_contact__c = :firstContactId and PRM_Status__c = :Label.PRM_Status_Pending AND PRM_Business_Event__c != '' and PRM_IsInactive__c= false ORDER BY PRM_Priority__c NULLS LAST,CreatedDate]){
emailQueueList.add(eq);
}

Map<String,PRM_EmailQueue__c> mapOfProcessContactId = new Map<String,PRM_EmailQueue__c>();  // processed contact and associated Email Queue

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
//Map<String,String> c= new Map<String,String>();
//Set<Id> processedIds = new Set<Id>();

if(emailQueueList!=null && !emailQueueList.isEmpty()){
for(PRM_EmailQueue__c ec : emailQueueList){
//processedIds.add(ec.Id);// email q ids
partnerRoleEmailQueueMap.put(ec.PRM_Contact__c,ec);
if(mapEmailConfiguration.containsKey(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c)){
String entitlements = '';
entitlements = mapEmailConfiguration.get(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c).PRM_Entitlement_List__c;
mapOfContactEntitlement.put(ec.PRM_Contact__c,entitlements);

}else if(mapEmailConfigurationOnTier.containsKey(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c+ec.PRM_Contact__r.Account.Core_IPA_Badge_Tier__c)){
String entitlements = '';
entitlements = mapEmailConfigurationOnTier.get(ec.PRM_Business_Event__c+ec.PRM_PartnerRole__c+ec.PRM_Contact__r.Account.Core_IPA_Badge_Tier__c).PRM_Entitlement_List__c;
mapOfContactEntitlement.put(ec.PRM_Contact__c,entitlements);

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
if(mdtRec.PRM_Country_Cd__c != null && conRecord.MailingCountryCode.equalsIgnoreCase('USA') && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us')){
langCultureForEmail.put(conRecord.Id, mdtRec);
}
if(langCultureForEmail!=null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(conRecord.MailingCountryCode) && mdtRec.MasterLabel == conRecord.Core_Preferred_Language__c){
langCultureForEmail.put(conRecord.Id, mdtRec);
}
}
}


if(firstContactId!=null){
// for(String conId : empContactIds){
if((partnerRoleEmailQueueMap.keySet().contains(firstContactId) && !ipaRefresh) || (ipaRefresh && partnerRoleEmailQueueMap.keySet().contains(firstContactId) && accountIdToBnftMap.get(contactToWrapperMap.get(firstContactId).onePartnerId) > 0)){
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
String metadata = langCultureForEmail.containsKey(firstContactId)?langCultureForEmail.get(firstContactId).id:englishMdt.Id;// need to add english metadat record id
inputParameters.put('LanguageCulture_MDT',metadata);
}

if(objEmailNotif.BusinessEvent == System.Label.PRM_Email_Admin_Approval_Event){
objEmailNotif.PartnerType=System.Label.PRM_CsP;
inputParameters.put('Account_ID',partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.AccountId);
}
else{
inputParameters.put('Account_ID',partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.AccountId);
}

if(partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.Core_Do_Not_Contact__c  == false)
{

mapOfProcessContactId.put(partnerRoleEmailQueueMap.get(firstContactId).PRM_Contact__r.Email,partnerRoleEmailQueueMap.get(firstContactId));

//added as part of governor limit story:4380
PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});
}
}

}

//update email logs on contact for which email is triggered
//-- update
List<PRM_EmailLog__c> emailLogsToUpdate = new List<PRM_EmailLog__c>();

Map<String,PRM_EmailLog__c> mapOfContactEmailLog = new Map<String,PRM_EmailLog__c>();
Set<String> setOfEmail = new Set<String>();


for(PRM_EmailLog__c eLog: [SELECT Id,PRM_Subject__c,PRM_Contact__c,PRM_EmailContent__c,PRM_EmailHTMLContent__c,PRM_User__c,PRM_EmailDeliverabilityStatus__c,PRM_ToEmailID__c,Email_Template_Name__c,
PRM_Contact__r.Core_Preferred_Language__c FROM PRM_EmailLog__c where PRM_ToEmailID__c IN: mapOfProcessContactId.keySet()]){
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


if(conList.size() > 0){
mapOfContactEmailLog.get(Id).PRM_Contact__c = conList[0].Id;
if(userList.size() > 0){
mapOfContactEmailLog.get(Id).PRM_User__c = userList[0].id;
}

if(mapOfContactEmailLog.get(Id).Email_Template_Name__c.contains(System.Label.PRM_Registration_Template) ||mapOfContactEmailLog.get(Id).Email_Template_Name__c.contains(System.Label.PRM_Reuse_Registration_Template)){

mapOfEmailLog.put(mapOfContactEmailLog.get(Id).PRM_ToEmailID__c,mapOfContactEmailLog.get(Id));

}
emailLogsToUpdate.add(mapOfContactEmailLog.get(Id));
}
}

if(emailLogsToUpdate.size()>0){
Database.update(emailLogsToUpdate,false);
}

List<PRM_EmailQueue__c> ipaEmailQueueToUpdate = new List<PRM_EmailQueue__c>();
for(String email : mapOfProcessContactId.keySet()){
if(mapOfEmailLog.containsKey(email)){

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

}
}

if(ipaEmailQueueToUpdate.size()>0){

Database.update(ipaEmailQueueToUpdate,false);
}
}
catch(Exception e){
PRM_ErrorUtilityClass.logError(e);
}
}else{
}
}
}


//IPA 2.0 Change : Dinesh
public class contactWrapper{
public String contactId{get;set;}
public String accountId{get;set;}
public String onePartnerId{get;set;}

}*/
    //Shashwat Changes Start 11/4/2022
    public static void updateStatusofAssign(List <Core_Contact_Entitlement__c> newList, Map<ID, Core_Contact_Entitlement__c> oldMap)
    {
        // List <Core_Contact_Entitlement__c> pendingStatus = new  List <Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c ce : newList)
        {
            //Core_Contact_Entitlement__c cep = new Core_Contact_Entitlement__c();
            if (ce.Core_Status__c == 'Pending' && oldMap.get(ce.Id).Core_Status__c == 'Complete' && ce.Core_Selected__c == true && oldMap.get(ce.Id).Core_Selected__c == true )
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Assignment';
                //cep.Id = ce.Id;
            }
            if (ce.Core_Status__c == 'Pending' && oldMap.get(ce.Id).Core_Status__c == 'Complete' && ce.Core_Selected__c == true && oldMap.get(ce.Id).Core_Selected__c == false )
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Assignment';
                //cep.Id = ce.Id;
            }
            if(oldMap.get(ce.Id).Core_Status__c == 'Complete' && oldMap.get(ce.Id).Core_Selected__c == true && ce.Core_Status__c == 'Pending' && ce.Core_Selected__c == false )
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                //cep.Id = ce.Id;
            }
            if (ce.Core_Status__c == 'Complete' && oldMap.get(ce.Id).Core_Status__c == 'Pending' && ce.Core_Selected__c == true && oldMap.get(ce.Id).Core_Selected__c == true )
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                //cep.Id = ce.Id;
            }
            if (ce.Core_Status__c == 'Pending' && oldMap.get(ce.Id).Core_Status__c == 'Complete' && ce.Core_Selected__c == false && oldMap.get(ce.Id).Core_Selected__c == false)
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                //cep.Id = ce.Id;
            }
            if (ce.Core_Status__c == 'Pending' && oldMap.get(ce.Id).Core_Status__c == 'Pending' && ce.Core_Selected__c == true && oldMap.get(ce.Id).Core_Selected__c == false)
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Assignment';
                //cep.Id = ce.Id;
            }
            if (ce.Core_Status__c == 'Pending' && oldMap.get(ce.Id).Core_Status__c == 'Pending' && ce.Core_Selected__c == false && oldMap.get(ce.Id).Core_Selected__c == true)
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Removal';
                //cep.Id = ce.Id;
            }
            //if(cep.Id!= null)
            //pendingStatus.add(cep);
        }
        //if(pendingStatus.size() !=0){
        //update pendingStatus;
        //}
    }
    public static void updateStatusofAssign(List <Core_Contact_Entitlement__c> newList)
    {
        //List <Core_Contact_Entitlement__c> completeStatus = new  List <Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c ce : newList)
        {
            //Core_Contact_Entitlement__c cep = new Core_Contact_Entitlement__c();
            if (ce.Core_Status__c == 'Complete' && ce.Core_Selected__c == true)
            {
                ce.Core_Status_of_Assignment_Failure__c = '';
                //cep.Id = ce.Id;
            }
            if (ce.Core_Status__c == 'Pending' && ce.Core_Selected__c == true)
            {
                ce.Core_Status_of_Assignment_Failure__c = 'Pending Assignment';
                //cep.Id = ce.Id;
            }
            //if(cep.Id!= null)
            //completeStatus.add(cep);
            
        }
        //if(completeStatus.size() !=0){
        //update completeStatus;
        //}
    }
    //Shashwat Changes End 11/4/2022
    
    /*****************************************************************************************************
Method name  : publishContactMsgOnEnttl
Description  : To update IPA Integration status as Pending whenever the entitlements(R4C) is added for the contact(After insert)
Parameter    : List<Core_Contact_Entitlement__c> newList
Created By   : Monisha Pandurangan
Date         : 21 feb, 2023
******************************************************************************************************/
    public static void publishContactMsgOnEnttl(List<Core_Contact_Entitlement__c> newList,Map<Id,Core_Contact_Entitlement__c> oldmap){
        if(!updateIPAIntegrationStatus){
            List<String> lstEntitlements = new List<String>();
            Set<Id> setConIds=new Set<Id>();
            String strServiceCloudEntitlement = System.Label.UCD_Contact_Entitlements;
            lstEntitlements = (String.isNotBlank(strServiceCloudEntitlement) ? strServiceCloudEntitlement.split(',') : null);
            if(!lstEntitlements.isEmpty()){
                for(Core_Contact_Entitlement__c ce: newList)
                {
                    Core_Contact_Entitlement__c oldContEnt = oldmap.get(ce.Id);
                    
                    if(lstEntitlements.contains(ce.Core_Entitlement_Nm__c) && (ce.Core_Status__c != oldContEnt.Core_Status__c) && ce.Core_Selected__c && ce.Core_Status__c == 'Complete')
                    {
                        setConIds.add(ce.Core_Contact_Id__c);
                    }
                }
            }
            if(!setConIds.isEmpty()){
                Map<String, Contact> mapConsToUpdate = new Map<String, Contact>();
                for(Contact con: [Select PRM_IPA_Integration_Status__c from Contact where Id IN :setConIds and PRM_IPA_Integration_Status__c != 'Pending']) {
                    con.PRM_IPA_Integration_Status__c= 'Pending';
                    mapConsToUpdate.put(con.id, con);
                }
                if(!mapConsToUpdate.isEmpty()){
                    update mapConsToUpdate.values();
                }
            }
            updateIPAIntegrationStatus = true;
        }
    }
    
    /*****************************************************************************************************
Method name  : updateCEStatusChangeDateTime
Description  : To update "Status Change Date/Time" field on the CE Record in "before" context of the trigger. This has been moved to trigger from the Workflow rule "Capture_Contact_Entitlement_Status_Change_DateTime"
to avoid re-hitting the trigger and reduce the SOQL count.[TWC1811-5410]
Parameter    : List<Core_Contact_Entitlement__c> newList, List<Core_Contact_Entitlement__c> oldMap
Created By   : Akshay More
Date         : 11th Sept, 2023
******************************************************************************************************/
    
    public static void updateCEStatusChangeDateTime(List<Core_Contact_Entitlement__c> newList, Map<Id, Core_Contact_Entitlement__c> oldMap, String operationType){
        if(operationType == 'BEFORE_INSERT'){
            for(Core_Contact_Entitlement__c conEnt : newList){
                conEnt.Core_Status_Change_Date_Time__c = system.now();
            }
        } else if(operationType == 'BEFORE_UPDATE'){
            for(Core_Contact_Entitlement__c conEnt : newList){
                if(conEnt.Core_Status__c != oldMap.get(conEnt.Id).Core_Status__c){
                    conEnt.Core_Status_Change_Date_Time__c = system.now();
                }
            }
        }
    }
    
}