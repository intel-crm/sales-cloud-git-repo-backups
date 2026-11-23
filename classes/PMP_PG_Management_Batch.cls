global class PMP_PG_Management_Batch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    global List<Account> lstAllPartnerAccount = new List<Account>();
    
    global static Database.QueryLocator start(Database.BatchableContext context) {
        
        String strPartnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        String strQueryPartnerAccount = 'SELECT Id,Name,Core_PMP_Membership_Change_Ind__c FROM Account WHERE RecordTypeId =:strPartnerAccRecTypeId AND Core_PMP_Membership_Change_Ind__c=true';
        return Database.getQueryLocator(strQueryPartnerAccount);
    }
    
    global void execute(Database.BatchableContext context, List<Account> lstAllPartnerAccountScope) {
        String COMPLETE_STR = 'Complete';
        String Core_Entitlement_Id_Label = System.Label.PMP_External_Entitlement_Ids;
        List<String> lstEntitlementIds = new List<String>();
        if(!Test.isRunningTest()){
            lstEntitlementIds = Core_Entitlement_Id_Label.split(';');
        }else{
            //Querying Entitlement Detail
            for(Core_Entitlement__c coreEntitlement : [SELECT Id, Name, Core_Display_Name__c FROM Core_Entitlement__c]){
                lstEntitlementIds.add(coreEntitlement.Id);
            }
        }
        lstAllPartnerAccount.addAll(lstAllPartnerAccountScope);
        String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;
        Set<Id> setAllPartnerAccId = new Set<Id>();
        Set<Id> setInactiveIntelAccounts = new Set<Id>();
        List<Core_Contact_Entitlement__c> lstMPConEntList = new List<Core_Contact_Entitlement__c>();
        List<Account> lstAllMPPartnerAccount = new List<Account>();
        List<Group> lstAllPublicGrps = new List<Group>();
        List<PMP_Public_Group_Management_Settings__c> lstPGManagmentSettings = new List<PMP_Public_Group_Management_Settings__c>();
        List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForAddition = new List<PMP_Public_Group_Management_Settings__c>();
        List<PMP_Public_Group_Management_Settings__c> lstActivePGMgmSettingsForRemoval = new List<PMP_Public_Group_Management_Settings__c>();
        Map<String,Set<Id>> mapPGToUserExpectedForAddition = new Map<String,Set<Id>>();
        Map<String,Set<Id>> mapPGToUserExpectedForRemoval = new Map<String,Set<Id>>();
        Map<String,Set<Id>> mapPGToUserExpectedForRemovalLastMPAccount = new Map<String,Set<Id>>();
        Map<Id, Id> mapPartnerAccountToPAGGroupId = new Map<Id, Id>();
        Map<Id,Id> mapConIdtoUsrId = new Map<Id,Id>();
        Map<string, Group> mapPAGToPAGGroup = new Map<string, Group>();
        /*All Partner Account id's in the context*/
        for(Account acc:lstAllPartnerAccountScope){
            setAllPartnerAccId.add(acc.id);
        }
        
       	lstPGManagmentSettings = PMP_Public_Group_Management_Settings__c.getall().values();
        
        for(PMP_Public_Group_Management_Settings__c PGMgmSetting : lstPGManagmentSettings) {
            if(!PGMgmSetting.PMP_Inactive_Ind__c && PGMgmSetting.PMP_Action_Txt__c == 'Add') {
                lstActivePGMgmSettingsForAddition.add(PGMgmSetting);
            }
            if(!PGMgmSetting.PMP_Inactive_Ind__c && PGMgmSetting.PMP_Action_Txt__c == 'Remove') {
                lstActivePGMgmSettingsForRemoval.add(PGMgmSetting);
            }
        }
        System.debug('$$$lstAllPartnerAccountScope'+lstAllPartnerAccountScope);
        lstMPConEntList = PMP_PG_Management_Handler.getAllContactEntitlementwithOPID(setAllPartnerAccId);        
		System.debug('$$$lstMPConEntList'+lstMPConEntList);
        lstAllMPPartnerAccount = PMP_PG_Management_Handler.refinePartnerAccounts(lstMPConEntList);
        System.debug('$$$lstAllMPPartnerAccount'+lstAllMPPartnerAccount);
        setInactiveIntelAccounts = PMP_PG_Management_Handler.getInactiveIntelAccIds(setAllPartnerAccId);
        
        mapConIdtoUsrId = PMP_PG_Management_Handler.getconIdToUserIdMap(setAllPartnerAccId);
        
        mapPGToUserExpectedForAddition = PMP_PG_Management_Handler.getPublicGroupExpectedMap(setInactiveIntelAccounts, lstMPConEntList, lstActivePGMgmSettingsForAddition, mapConIdtoUsrId);
        System.debug('$$$mapPGToUserExpectedForAddition'+mapPGToUserExpectedForAddition);
        mapPGToUserExpectedForRemoval = PMP_PG_Management_Handler.getPublicGroupExpectedMap(setInactiveIntelAccounts, lstMPConEntList, lstActivePGMgmSettingsForRemoval, mapConIdtoUsrId);
        
        //for last MP Entitlement
        List<Core_Contact_Entitlement__c> lstConEntNonMP = [SELECT Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Status__c, 
                                                            Core_Contact_Id__r.AccountId, Core_Selected__c, 
                                                            Core_Contact_Id__r.Core_IPA_One_Partner_Id__c, 
                                                            Core_Contact_Id__r.Core_IPA_Contact_Segment__c,
                                                            Core_Entitlement_Id__r.Name
                                                            FROM Core_Contact_Entitlement__c
                                                            WHERE Core_Status__c = :COMPLETE_STR AND Core_Selected__c = false 
                                                            AND Core_Entitlement_Id__c = :lstEntitlementIds 
                                                            AND Core_Contact_Id__r.Core_IPA_One_Partner_Id__c = : setAllPartnerAccId];
        if(!lstConEntNonMP.isEmpty()){
            System.debug('lstConEntNonMP$$$'+lstConEntNonMP);
        	mapPGToUserExpectedForRemovalLastMPAccount = PMP_PG_Management_Handler.getPublicGroupExpectedMap(setInactiveIntelAccounts, lstConEntNonMP, lstActivePGMgmSettingsForAddition, mapConIdtoUsrId);
            System.debug('mapPGToUserExpectedForRemovalLastMPAccount$$$'+mapPGToUserExpectedForRemovalLastMPAccount);
        }
        
        for(String strPGName : mapPGToUserExpectedForRemovalLastMPAccount.keySet()) {
            if(mapPGToUserExpectedForRemoval.containsKey(strPGName)) {
                mapPGToUserExpectedForRemoval.get(strPGName).addAll(mapPGToUserExpectedForRemovalLastMPAccount.get(strPGName));
            } else {
                mapPGToUserExpectedForRemoval.put(strPGName, new Set<Id>(mapPGToUserExpectedForRemovalLastMPAccount.get(strPGName)));
            }
        }
        System.debug('mapPGToUserExpectedForRemoval$$$'+mapPGToUserExpectedForRemoval);
        lstAllPublicGrps = PMP_PG_Management_Handler.createPublicGroups(mapPGToUserExpectedForAddition.keySet());
        
        PMP_PG_Management_Handler.assignRemoveUserstoPublicGroups(lstAllPublicGrps, mapPGToUserExpectedForAddition, mapPGToUserExpectedForRemoval);
        
        Set<String> setOdmPAGAccId = PMP_PG_Management_Handler.getOdmPAGforAccountIds(lstAllMPPartnerAccount);
        
        Set<String> setNonOdmPartner = PMP_PG_Management_Handler.getNonOdmPAGAccounts(lstAllMPPartnerAccount);
        
        PMP_PG_Management_Handler.assignRemoveMembersToODMNonODM(setOdmPAGAccId, setNonOdmPartner);
        
        for(Group grp : lstAllPublicGrps){    
                mapPAGToPAGGroup.put(grp.DeveloperName, grp);           
        }
        
        for(Account acc : lstAllMPPartnerAccount){ 
            if(mapPAGToPAGGroup.containsKey(CORE_MP_STR + acc.Id)){
                mapPartnerAccountToPAGGroupId.put(acc.Id, mapPAGToPAGGroup.get(CORE_MP_STR + acc.Id).Id);
            }               
        }       
        PMP_PG_Management_Handler.sharePartAccWithPartAcGrp(mapPartnerAccountToPAGGroupId);
        
        PMP_PG_Management_Handler.removeInactiveIntelContactsFromPG(setInactiveIntelAccounts);
        
        //PMP_PG_Management_Handler.deleteMemebersForEntitlementAndAccount(setAllPartnerAccId, setInactiveIntelAccounts, lstActivePGMgmSettingsForAddition);
    
    }
    
    global void finish(Database.BatchableContext context) {
        
        List<Account> accToUpdate = new List<Account>();
        for(Account acc :lstAllPartnerAccount) {
            
            if(acc.Core_PMP_Membership_Change_Ind__c = true) {
                acc.Core_PMP_Membership_Change_Ind__c = false;
                accToUpdate.add(acc);
            } 
        }
        Database.update(accToUpdate, false);
    }
    
    global void execute(SchedulableContext ctx) {
        
    }
}