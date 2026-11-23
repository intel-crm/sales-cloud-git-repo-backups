/**************************************************************************************
Apex Class Name : Core_Mp_Public_Group_Creation_Batch
Version     : 1.0 
Created Date: 20th may, 2019
Description : Batch to create public group, Assignment of group members 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  20/05/2019               Original Version
* Vaibhav                  14/06/2020              Refactored Code v2
* Manikanta           10/07/2020         Refactored Code v3
* Akshay [Draco]            08/06/2022              Added logic to keep Membership Change Ind Flag to TRUE in case of any APEX Exception
*************************************************************************************/

global class PMP_Batch_Group_Management_Scheduler implements Database.Batchable<sObject>, Database.Stateful{
    
    global List<Account> lstAllPartnerAccount = new List<Account>();
    global String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
    public static List<Database.SaveResult> lstSaveResultErrors = new List<Database.SaveResult>();
    public static List<Database.DeleteResult> lstDeleteResultErrors = new List<Database.DeleteResult>();
    public static Set<Id> setFailedGrpMembrIds = new Set<Id>();
    public static list<Core_Account_Group_Member__c> lstPAGInactive=new list<Core_Account_Group_Member__c>();
    global static Database.QueryLocator start(Database.BatchableContext context)
    {    
      
        /********Querying all The partner accounts where the flag has been updated **********/
        String queryPartnerAccount = 'SELECT Id, Name, RecordTypeId, Core_PMP_Membership_Change_Ind__c, Core_Account_Type__c FROM Account WHERE Core_PMP_Membership_Change_Ind__c = true Limit ' + System.Label.PMP_Group_Management_Total_Size;                  
        return Database.getQueryLocator(queryPartnerAccount);

        
    }
    global void execute(Database.BatchableContext context, List<Account> lstAllPartnerAccountScope){
        
        String ALL_PARTNERS_GROUP= System.Label.Partner_Users_Marketplace;
        lstAllPartnerAccount.addAll(lstAllPartnerAccountScope);
        String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;// 'PMP_'
        Set<String> setEntitlementNames = new Set<String>();
        List<Core_Contact_Entitlement__c> lstMPConEnts = new List<Core_Contact_Entitlement__c>();
        List<Group> lstAllPublicGrps = new List<Group>();
        List<PMP_Public_Group_Management_Settings__c> lstPGManagmentSettings = new List<PMP_Public_Group_Management_Settings__c>();
        List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForAddition = new List<PMP_Public_Group_Management_Settings__c>();
        List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForRemoval = new List<PMP_Public_Group_Management_Settings__c>();
        Map<String,Set<Id>> mapPGToUserExpectedForAddition = new Map<String,Set<Id>>();
        Map<String,Set<Id>> mapPGToUserExpectedForRemoval = new Map<String,Set<Id>>();
        Map<Id,Id> mapConIdtoUsrId = new Map<Id,Id>();
        set<Id> setAllPartnerAccs=new set<Id>();
        Map<Id,Account> mapAllPartnerAccs = new Map<Id,Account>();
        Map<Id,Account> mapAllIntelAccs = new Map<Id,Account>();
        /*All Partner Account id's in the context*/
        for(Account acc:lstAllPartnerAccountScope){
            if(acc.RecordTypeId == partnerAccRecTypeId){
                mapAllPartnerAccs.put(acc.id,acc);
                setAllPartnerAccs.add(acc.id);  //ipa 2.0 simplification: sharing all partner users as odm non odm EOL
            } else {
                mapAllIntelAccs.put(acc.id,acc);
            }
        }
        
        //get the data from PMP_Public_Group_Management_Settings__c custom settings
        lstPGManagmentSettings = PMP_Public_Group_Management_Settings__c.getall().values();
        
        for(PMP_Public_Group_Management_Settings__c PGMgmSetting : lstPGManagmentSettings) {
            if(!PGMgmSetting.PMP_Inactive_Ind__c){ 
                setEntitlementNames.add(PGMgmSetting.PMP_Contributing_Entitlement_Nm__c);
                if(PGMgmSetting.PMP_Action_Txt__c == 'Add') {
                    lstActivePGMgmSettingsForAddition.add(PGMgmSetting);
                }
                if(PGMgmSetting.PMP_Action_Txt__c == 'Remove') {
                    lstActivePGMgmSettingsForRemoval.add(PGMgmSetting);
                }
            }   
        }
        
        //This returns MP Contact Entitlement with OPID and for active Intel Account Contacts
        lstMPConEnts = PMP_Batch_Group_Management.getAllContactEntitlementwithOPID(mapAllPartnerAccs.keySet(), setEntitlementNames);        
        //System.debug('$$$lstMPConEnts'+lstMPConEnts);
        
        //This returns a map of Contact Id and User Id
        mapConIdtoUsrId = PMP_Batch_Group_Management.getconIdToUserIdMap(mapAllPartnerAccs.keySet());
        
        //This Returns a Map with Group Name and the list of users to be added to the group
        mapPGToUserExpectedForAddition = PMP_Batch_Group_Management.getPublicGroupExpectedMap(lstMPConEnts, lstActivePGMgmSettingsForAddition, mapConIdtoUsrId, mapAllPartnerAccs.values());
        //System.debug('$$$mapPGToUserExpectedForAddition'+mapPGToUserExpectedForAddition);
        
        //This Returns a Map with Group Name and the list of users to be removed from the group
        mapPGToUserExpectedForRemoval = PMP_Batch_Group_Management.getPublicGroupExpectedMap(lstMPConEnts, lstActivePGMgmSettingsForRemoval, mapConIdtoUsrId, mapAllPartnerAccs.values());
        //System.debug('mapPGToUserExpectedForRemoval$$$'+mapPGToUserExpectedForRemoval);
        
        //System.debug('mapPGToUserExpectedForAddition.keySet()$$$'+mapPGToUserExpectedForAddition.keySet());
        Set<String> setPublicGroupsToCreate = new Set<String>();
        for(String groupname : mapPGToUserExpectedForAddition.keySet()) {
            if(!mapPGToUserExpectedForAddition.get(groupname).isEmpty()) {
                setPublicGroupsToCreate.add(groupname);
            }
        }
        
        //System.debug('setPublicGroupsToCreate$$$'+setPublicGroupsToCreate);
        //creates a public group if it is not already present
        PMP_Batch_Group_Management.createPublicGroups(setPublicGroupsToCreate);
        lstAllPublicGrps = [SELECT Id,DeveloperName,Name FROM Group where DeveloperName IN :mapPGToUserExpectedForAddition.keySet()];
        PMP_Batch_Group_Management.assignRemoveUserstoPublicGroups(lstAllPublicGrps, mapPGToUserExpectedForAddition, mapPGToUserExpectedForRemoval);
        
      
         Set<String> setOpidGroups = new Set<String>();
         for(Id accId : setAllPartnerAccs) {
            setOpidGroups.add(CORE_MP_STR + accId);
        }
        List<Group> lstOpidGroups = [SELECT Id, DeveloperName, Name FROM Group WHERE DeveloperName IN :setOpidGroups];
      PMP_Batch_Group_Management.assignRemoveToAllPartnerUsersGroup(lstOpidGroups,ALL_PARTNERS_GROUP);
        //Share Partner Accounts and intel Accounts to Main PAG Group       
        PMP_Batch_Group_Management.shareAccountwithMainPAGGroup(lstAllPublicGrps,mapAllPartnerAccs.keySet());
        
        /*****Sharing intel Accounts with ODM & NON-ODM groups***/
        List<Account> lstRefinedIntelAccount = PMP_Batch_Group_Management.refineIntelAccounts(mapAllIntelAccs.keySet(),setEntitlementNames);
        list<group> lstIntelAllPartnerGroups= [SELECT Id, Name, DeveloperName, RelatedId, Type FROM Group WHERE Type = 'Role' AND RelatedId IN (SELECT UserRoleId FROM User WHERE AccountId IN: lstRefinedIntelAccount AND UserRole.PortalType = 'Partner' AND UserRole.PortalRole = 'Worker')];      
        PMP_Batch_Group_Management.assignRemoveToAllPartnerUsersGroup(lstIntelAllPartnerGroups,ALL_PARTNERS_GROUP);
       lstPAGInactive=[SELECT Id,Core_Inactive_Ind__c,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c 
        FROM Core_Account_Group_Member__c where Core_Partner_Account_Id__c in : setAllPartnerAccs  and 
        Core_Intel_Account_Id__c in :mapAllIntelAccs.keyset() and Core_Inactive_Ind__c =true];
        if(!lstPAGInactive.isempty()){
            PMP_Batch_Group_Management.removeUsersFromAllPartnersGrp(lstPAGInactive,setOpidGroups);
        }
        
    }
    global void finish(Database.BatchableContext context){
        
        
        Set<Id> errorAccIdSet = new Set<Id>();
        //set<Id> errorRoleIdSet = new Set<Id>();
        
        if(!setFailedGrpMembrIds.isEmpty()){
            List<User> errorUserList = [SELECT Id, Contact.AccountId, Contact.Core_IPA_One_Partner_Id__c FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE ID =: setFailedGrpMembrIds)];
            for(User usr : errorUserList){
                errorAccIdSet.add(usr.Contact.AccountId);
                errorAccIdSet.add(usr.Contact.Core_IPA_One_Partner_Id__c);
            }
            if(errorAccIdSet.contains(null)){
                errorAccIdSet.remove(null);
            }
        }
        
        List<Account> accToUpdate = new List<Account>();
        for(Account acc :lstAllPartnerAccount) {
            if(!errorAccIdSet.contains(acc.Id) && acc.Core_PMP_Membership_Change_Ind__c == true) {
                acc.Core_PMP_Membership_Change_Ind__c = false;
                accToUpdate.add(acc);
            } 
        }
        Database.update(accToUpdate, false);    
    }
    
   /* global void execute(SchedulableContext ctx) 
    {
        List<AsyncApexJob> jobAlreadyRunning = new List<AsyncApexJob>([SELECT ParentJobId,  Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, ApexClass.Name FROM AsyncApexJob WHERE Status = 'Processing' AND ApexClass.Name = 'PMP_Batch_Group_Management_Scheduler' AND ParentJobId = null]);
        //system.debug('Currently Running Jobs: ' + jobAlreadyRunning);
        if(jobAlreadyRunning.size() == 0){
            PMP_Batch_Group_Management_Scheduler schduleBatch = new PMP_Batch_Group_Management_Scheduler();
            database.executebatch(schduleBatch, integer.valueof(System.Label.PMP_Group_Management_Batch_Size));
        }
    }*/
    
}