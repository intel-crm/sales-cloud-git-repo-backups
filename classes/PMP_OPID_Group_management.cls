global with sharing class PMP_OPID_Group_management implements Database.Batchable<Id>,Database.Stateful{
    global List<Account> lstAllPartnerAccount = new List<Account>();
    global String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
    public static List<Database.SaveResult> lstSaveResultErrors = new List<Database.SaveResult>();
    public static List<Database.DeleteResult> lstDeleteResultErrors = new List<Database.DeleteResult>();
    public static Set<Id> setFailedGrpMembrIds = new Set<Id>();
    public static list<Core_Account_Group_Member__c> lstPAGInactive=new list<Core_Account_Group_Member__c>();
    private  list<Id> accountIds=new list<Id>();
    global  set<id> activeOPIDs=new set<id>();
    public static list<account> activeAccountsScope=new list<account>();
    public static Map<Id, Account> opidsWithAccount = new Map<Id, Account>();
    public static List<Id> failedOpidGrpIds = new List<Id>();
    public static string entitlementLabel=system.label.PMP_Egligble_Entitlement;
    public static list<string> entitlementLabelValues=entitlementLabel.split(';');
    public PMP_OPID_Group_management() {
    
    }
    public PMP_OPID_Group_management(list<Id> soqlFilter) {
    
        this.accountIds = soqlFilter;
    
    }    
    global  Iterable<Id> start(Database.BatchableContext context)
    { 
        //check if another apex job for this batch class is already running or in hold   
        Id currentJobId = context.getJobId();
        List<AsyncApexJob> apexJobsList = [Select id from AsyncApexJob where Status IN ('Holding', 'Preparing', 'Processing') 
        and ApexClass.Name = 'PMP_OPID_Group_management' and id != :currentJobId];
        if(!apexJobsList.isEmpty()){            
            System.abortJob(currentJobId);
        }
        /********Querying all The partner accounts where the flag has been updated **********/
               system.debug('accountIds'+accountIds);
           if(accountIds!=null && !accountIds.isEmpty()) {
              for(account acc:[SELECT Id, Name, RecordTypeId, Core_PMP_Membership_Change_Ind__c, Core_Account_Type__c 
              FROM Account 
              WHERE id in: accountIds 
              and Core_PMP_Membership_Change_Ind__c = true ]){
                activeOPIDs.add(acc.id);
              }
           }
           else{
                opidsWithAccount = new Map<Id, Account>(
                [SELECT Id, Name, RecordTypeId, Core_PMP_Membership_Change_Ind__c, Core_Account_Type__c
                FROM Account
                WHERE Id IN (
                    SELECT PRM_Account_Id__c
                    FROM PRM_AccountchannelMembership__c
                    WHERE PRM_Status_Nm__c = 'Approved'
                )
                AND RecordTypeId = :partnerAccRecTypeId
                AND Core_PMP_Membership_Change_Ind__c = true
                ORDER BY LastModifiedDate DESC]
        );
        system.debug('opidsWithAccount'+opidsWithAccount);
       
           system.debug('entitlementLabel'+entitlementLabel);
           system.debug('entitlementLabelValues'+entitlementLabelValues);
          for (Core_Contact_Entitlement__c ce: [SELECT Core_Contact_Id__r.Core_IPA_One_Partner_Id__c,Core_Entitlement_Id__r.name 
               FROM Core_Contact_Entitlement__c 
               WHERE Core_Contact_Id__r.Core_IPA_One_Partner_Id__c in: opidsWithAccount.keyset() 
               and Core_Selected__c =true 
               and Core_Status__c = : system.label.PRM_ACR_Status
               and Core_Entitlement_Id__r.name in: entitlementLabelValues ]){
              activeOPIDs.add(ce.Core_Contact_Id__r.Core_IPA_One_Partner_Id__c ); }   
            }
        system.debug('activeOPIDs'+activeOPIDs.size());
          return activeOPIDs;            
    }
    global void execute(Database.BatchableContext context, List<Id> activeOPIDs){
        system.debug('opidsWithAccount'+opidsWithAccount);
        system.debug('activeOPIDs'+activeOPIDs.size());
          Map<String, Set<Id>> mapOpidUserids = new Map<String, Set<Id>>();
       // STEP 0: Get OPID Groups first
        Set<string> opidGroups = new Set<string>();// opidid1234
        string pmpStr='PMP_';
        if(activeOPIDs!=null && !activeOPIDs.isEmpty()){
            for(string opid:activeOPIDs){
            opidGroups.add(pmpStr+opid); //pMP_opidid1234
        }

        // STEP 1: Build mapOpidUserids
      

        for (User u : [SELECT Id,contact.Core_IPA_One_Partner_Id__c
            FROM User
            WHERE isActive=true and contact.Core_IPA_One_Partner_Id__c in :activeOPIDs
            and ContactId in (SELECT Core_Contact_Id__c
            FROM Core_Contact_Entitlement__c 
            WHERE Core_Selected__c =true 
            and Core_Status__c = 'Complete'
            and Core_Entitlement_Id__r.name in :entitlementLabelValues)
            
        ]) {
            if (!mapOpidUserids.containsKey(u.contact.Core_IPA_One_Partner_Id__c)) {
                mapOpidUserids.put(u.contact.Core_IPA_One_Partner_Id__c, new Set<Id>());
            }
            mapOpidUserids.get(u.contact.Core_IPA_One_Partner_Id__c).add(u.Id);//id opidid1234,user1,user2
        }
        }
        

        // STEP 2: Get Groups by DeveloperName
        Map<String, Id> mapGroupNameToId = new Map<String, Id>();
if(opidGroups!=null && !opidGroups.isEmpty()){
     for (Group g : [
            SELECT Id, DeveloperName
            FROM Group
            WHERE DeveloperName IN :opidGroups
        ]) {
            mapGroupNameToId.put(g.DeveloperName, g.Id);
        }
}
       

        // STEP 3: Get existing Group Members
        Map<Id, Set<Id>> mapGroupIdWithUserIDs = new Map<Id, Set<Id>>();
if(mapGroupNameToId!=null){
    for (GroupMember gm : [
            SELECT GroupId, UserOrGroupId
            FROM GroupMember
            WHERE GroupId IN :mapGroupNameToId.values()
        ]) {
            if (!mapGroupIdWithUserIDs.containsKey(gm.GroupId)) {
                mapGroupIdWithUserIDs.put(gm.GroupId, new Set<Id>());//user1
            }
            mapGroupIdWithUserIDs.get(gm.GroupId).add(gm.UserOrGroupId);
        }
}
        

        // STEP 4: Prepare records to insert
List<GroupMember> listToInsertIntoGroupMember = new List<GroupMember>();
if(opidGroups!=null && !opidGroups.isEmpty() ){
     for (String groupName : opidGroups) {
            Id groupId = mapGroupNameToId.containskey(groupName)?mapGroupNameToId.get(groupName):'';
            String opidId = groupName.split('_')[1];
            Set<Id> opidUsers =mapOpidUserids.containskey(opidId)? mapOpidUserids.get(opidId): new Set<Id>();//opid id--userset
            Set<Id> existingUsers = mapGroupIdWithUserIDs.containskey(groupId)?mapGroupIdWithUserIDs.get(groupId):new Set<Id>();
            if(opidUsers!=null){
                for (Id userId : opidUsers) {
                            if (!existingUsers.contains(userId)) {
                                listToInsertIntoGroupMember.add(new GroupMember(
                                    GroupId = groupId,
                                    UserOrGroupId = userId
                                ));
                            }
                        }
            }
            
        }
}
       

        // STEP 5: Insert with partial success handling
        if (!listToInsertIntoGroupMember.isEmpty()) {

            Database.SaveResult[] results = Database.insert(listToInsertIntoGroupMember, false);

            for (Integer i = 0; i < results.size(); i++) {

                    for (Database.Error err : results[i].getErrors()) {

                        failedOpidGrpIds.add(listToInsertIntoGroupMember[i].GroupId);

                    }
                }
            }

    }
    global void finish(Database.BatchableContext context){
        // STEP 6: Get failed OPIDs from Groupids
        List<String> failedOpids = new List<String>();

        if (!failedOpidGrpIds.isEmpty()) {

            for (Group g : [
                SELECT DeveloperName
                FROM Group
                WHERE Id IN :failedOpidGrpIds
            ]) {
                if (g.DeveloperName != null && g.DeveloperName.contains('_')) {
                    List<String> parts = g.DeveloperName.split('_');
                    if (parts.size() > 1) {
                        failedOpids.add(parts[1]);
                    }
                }
            }
        }

        // STEP 7: Update Accounts
        List<Account> accToUpdate = new List<Account>();
        system.debug('finishactiveOPIDs'+activeOPIDs+'size'+activeOPIDs.size());
        if(activeOPIDs!=null && !activeOPIDs.isEmpty()){
            for (Account acc : [select id,Core_PMP_Membership_Change_Ind__c from account
                                    where id in :activeOPIDs]) {
                    if (!failedOpids.contains(acc.Id) &&
                        acc.Core_PMP_Membership_Change_Ind__c == true) {

                        acc.Core_PMP_Membership_Change_Ind__c = false;
                        accToUpdate.add(acc);
                    }
                }
        }
    if (!accToUpdate.isEmpty()) {
            update accToUpdate;
        }
        
    }    
    
}