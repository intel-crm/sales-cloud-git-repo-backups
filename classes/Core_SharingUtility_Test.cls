@isTest
public class Core_SharingUtility_Test {
    static List<Core_IPS_Project__c> ipsProjects = new List<Core_IPS_Project__c>();
    static List<Account> accounts = new List<Account>();
    static List<Contact> contacts = new List<Contact>();
    static List<User> users = new List<User>();
    static List<Asset> assetList = new List<Asset>();
    static List<Case> caseList = new List<Case>();
    static List<User> faeUsers = new List<User>();

    static void getRecords() {
        ipsProjects = TestUtilities.getListOfIpsProjects(5);
        insert ipsProjects;
        System.Assert(ipsProjects.get(0).Id != null, 'Record not created');

        System.runAs(new User(Id = UserInfo.getUserId())) {
            accounts = TestUtilities.getListOfAccounts(5);
        }
        insert accounts;
        System.Assert(accounts.get(0).Id != null, 'Record not created');

        contacts = TestUtilities.getListOfContact(5);
        Integer counter = 0;
        Id currentLoggedInUserId = UserInfo.getUserId();
        for (Contact contactRec : contacts) {
            contactRec.AccountId = accounts.get(counter).Id;
            contactRec.Core_IPS_Intel_Support_Owner__c = currentLoggedInUserId;
            counter++;
        }
        insert contacts;
        System.Assert(contacts.get(0).Id != null, 'Record not created');

        Profile customerProfile = [SELECT Id, Name FROM Profile WHERE UserType = 'PowerCustomerSuccess' LIMIT 1];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            users = TestUtilities.getListOfUser(5);
        }
        Integer counter2 = 0;
        for (User userRecord : users) {
            userRecord.ProfileId = customerProfile.Id;
            userRecord.ContactId = contacts.get(counter2).Id;
            counter2++;
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert users;
        }
        System.Assert(users.get(0).Id != null, 'Record not created');

        assetList = TestUtilities.getAssetList(5);
        Integer counter3 = 0;
        for (Asset assetRecord : assetList) {
            assetRecord.Core_IPS_Project__c = ipsProjects.get(counter3).Id;
            assetRecord.AccountId = accounts.get(counter3).Id;
            assetRecord.ContactId = contacts.get(counter3).Id;
            counter3++;
        }
        insert assetList;
        System.Assert(assetList.get(0).Id != null, 'Record not created');

        caseList = TestUtilities.getListOfCases(5);
        insert caseList;
        System.Assert(caseList.get(0).Id != null, 'Record not created');

        Profile profileRec = [SELECT Id, Name FROM Profile WHERE Name = 'Sales Rep-BB'];

        faeUsers = TestUtilities.getListOfUser(1);
        faeUsers.get(0).ProfileId = profileRec.Id;
        insert faeUsers;
    }

    /*static testmethod void createShareRecordsTest(){
        getRecords();
        Map<Id, List<Asset>> assetsByProj = new Map<Id, List<Asset>>();
        Map<Id, List<Id>> usersByProj = new Map<Id, List<Id>>();
        List<Id> userIdList = new List<Id>();
        List<Id> userIdListTwo = new List<Id>();
        Map<Id, List<Id>> usersByPrj = new Map<Id, List<Id>>();
        for (Asset assetRecord : assetList) {
            if (assetsByProj.containsKey(assetRecord.Core_IPS_Project__c)) {
                assetsByProj.get(assetRecord.Core_IPS_Project__c).add(assetRecord);
            } else {
                assetsByProj.put(assetRecord.Core_IPS_Project__c, new List<Asset>{ assetRecord });
            }
        }
        for (User userRecord : users) {
            userIdList.add(userRecord.Id);
        }
        for (Core_IPS_Project__c ipsProj : ipsProjects) {
            if (usersByProj.containsKey(ipsProj.Id)) {
                usersByProj.get(ipsProj.Id).addAll(userIdList);
            } else {
                usersByProj.put(ipsProj.Id, new List<Id>());
                usersByProj.get(ipsProj.Id).addAll(userIdList);
            }
        }
        userIdListTwo.add(UserInfo.getUserId());
        for (Core_IPS_Project__c ipsProj : ipsProjects) {
            if (usersByPrj.containsKey(ipsProj.Id)) {
                usersByPrj.get(ipsProj.Id).addAll(userIdListTwo);
            } else {
                usersByPrj.put(ipsProj.Id, new List<Id>());
                usersByPrj.get(ipsProj.Id).addAll(userIdListTwo);
            }
        }
        Test.startTest();
        Core_SharingUtility.createShareRecords(assetsByProj, usersByProj);
        List<AssetShare> assetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE AssetId = :assetList.get(0).Id AND UserOrGroupId = :userIdList.get(0)];
        System.assertEquals(assetShareList[0].RowCause, 'Manual');
        Core_SharingUtility.createShareRecords(assetsByProj, usersByPrj);
        Test.stopTest();
    }
    static testmethod void createMapShareRecordsTest(){
        getRecords();
        Map<Id, List<Asset>> assetsByAccount = new Map<Id, List<Asset>>();
        for (Asset assetRecord : assetList) {
            if (assetsByAccount.containsKey(assetRecord.AccountId)) {
                assetsByAccount.get(assetRecord.AccountId).add(assetRecord);
            } else {
                assetsByAccount.put(assetRecord.AccountId, new List<Asset>{ assetRecord });
            }
        }
        Test.startTest();
        Core_SharingUtility.CreateMapShareRecords(assetsByAccount);
        List<AssetShare> assetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE AssetId = :assetList.get(0).Id AND UserOrGroupId IN :users];
        System.assertEquals(assetShareList[0].RowCause, 'Manual');
        Test.stopTest();
    }
    static testmethod void createContactShareRecordsTest(){
        getRecords();
        Map<Id, List<Asset>> assetsByContact = new Map<Id, List<Asset>>();
        for (Asset assetRecord : assetList) {
            if (assetsByContact.containsKey(assetRecord.ContactId)) {
                assetsByContact.get(assetRecord.ContactId).add(assetRecord);
            } else {
                assetsByContact.put(assetRecord.ContactId, new List<Asset>{ assetRecord });
            }
        }
        Test.startTest();
        Core_SharingUtility.CreateContactShareRecords(assetsByContact);
        List<AssetShare> assetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE AssetId = :assetList.get(0).Id AND UserOrGroupId IN :users];
        System.assertEquals(assetShareList[0].RowCause, 'Manual');
        Test.stopTest();
    }*/

    static testmethod void shareAssetToUserTest() {
        getRecords();
        List<Id> userIdList = new List<Id>();
        for (User userRecord : users) {
            userIdList.add(userRecord.Id);
        }
        List<Asset> assetList2 = TestUtilities.getAssetList(5);
        insert assetList2;
        Test.startTest();
        Core_SharingUtility.ShareAssettoUser(userIdList.get(0), assetList2.get(0).Id);
        List<AssetShare> assetShareList = [
            SELECT Id, UserOrGroupId, RowCause
            FROM AssetShare
            WHERE AssetId = :assetList2[0].Id AND UserOrGroupId = :userIdList[0]
        ];
        if (assetShareList != null && assetShareList.size() > 0) {
            System.assertEquals(assetShareList[0].RowCause, 'Manual');
        }
        Test.stopTest();
    }

    static testmethod void provideAccessTest() {
        getRecords();
        List<Id> userIdList = new List<Id>();
        Map<Id, Id> recordUserList = new Map<Id, Id>();
        Set<Id> projIdSet = new Set<Id>();
        for (User userRecord : users) {
            userIdList.add(userRecord.Id);
        }
        for (Core_IPS_Project__c ipsProj : ipsProjects) {
            recordUserList.put(ipsProj.Id, userIdList.get(0));
            projIdSet.add(ipsProj.Id);
        }
        Test.startTest();
        Core_SharingUtility.provideAccess('Core_IPS_Project__c', 'Core_IPS_Project__Share', 'Edit', recordUserList);
        List<Core_IPS_Project__share> coreIpsProjShareList = [
            SELECT Id, UserOrGroupId, RowCause
            FROM Core_IPS_Project__share
            WHERE ParentId = :ipsProjects.get(0).Id AND UserOrGroupId = :userIdList.get(0)
        ];
        System.assertEquals(coreIpsProjShareList[0].RowCause, 'Manual');
        Core_SharingUtility.revokeAccess('Core_IPS_Project__c', 'Core_IPS_Project__Share', recordUserList);
        Core_SharingUtility.getGroupIdByProject(projIdSet);
        Test.stopTest();
    }

    /*static testmethod void shareAssetsForProjectMembersTest(){
        getRecords();
        List<Id> userIdList = new List<Id>();
        Map<Id, List<Id>> usersByProj = new Map<Id, List<Id>>();
        Map<Id, List<Id>> assetIdByProj = new Map<Id, List<Id>>();
        for (User userRecord : users) {
            userIdList.add(userRecord.Id);
        }
        for (Asset assetRecord : assetList) {
            if (assetIdByProj.containsKey(assetRecord.Core_IPS_Project__c)) {
                assetIdByProj.get(assetRecord.Core_IPS_Project__c).add(assetRecord.Id);
            } else {
                assetIdByProj.put(assetRecord.Core_IPS_Project__c, new List<Id>{ assetRecord.Id });
            }
        }
        for (Core_IPS_Project__c ipsProj : ipsProjects) {
            if (usersByProj.containsKey(ipsProj.Id)) {
                usersByProj.get(ipsProj.Id).addAll(userIdList);
            } else {
                usersByProj.put(ipsProj.Id, new List<Id>());
                usersByProj.get(ipsProj.Id).addAll(userIdList);
            }
        }
        Test.startTest();
        Core_SharingUtility.shareAssetsforProjectmembers(usersByProj, assetIdByProj);
        List<AssetShare> assetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE AssetId = :assetList.get(0).Id AND UserOrGroupId = :userIdList.get(0)];
        System.assertEquals(assetShareList[0].RowCause, 'Manual');
        Core_SharingUtility.shareAssetsforProjectmembers(usersByProj, usersByProj);
        Test.stopTest();
    }*/

    static testmethod void provideAccessTest2() {
        getRecords();
        Map<Id, Set<Id>> assetRecordUserList = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> caseRecordUserList = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> setOfUserIdByProj = new Map<Id, Set<Id>>();
        List<Id> userIdList = new List<Id>();
        for (User userRecord : users) {
            userIdList.add(userRecord.Id);
        }
        for (Asset assetRecord : assetList) {
            if (assetRecordUserList.containsKey(assetRecord.Id)) {
                assetRecordUserList.get(assetRecord.Id).addAll(userIdList);
            } else {
                assetRecordUserList.put(assetRecord.Id, new Set<Id>());
                assetRecordUserList.get(assetRecord.Id).addAll(userIdList);
            }
        }
        for (Case caseRecord : caseList) {
            if (caseRecordUserList.containsKey(caseRecord.Id)) {
                caseRecordUserList.get(caseRecord.Id).addAll(userIdList);
            } else {
                caseRecordUserList.put(caseRecord.Id, new Set<Id>());
                caseRecordUserList.get(caseRecord.Id).addAll(userIdList);
            }
        }
        for (Core_IPS_Project__c ipsProj : ipsProjects) {
            if (setOfUserIdByProj.containsKey(ipsProj.Id)) {
                setOfUserIdByProj.get(ipsProj.Id).addAll(userIdList);
            } else {
                setOfUserIdByProj.put(ipsProj.Id, new Set<Id>());
                setOfUserIdByProj.get(ipsProj.Id).addAll(userIdList);
            }
        }
        Test.startTest();
        Core_SharingUtility.provideAccess('Asset', 'AssetShare', 'Edit', assetRecordUserList);
        List<AssetShare> assetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE AssetId = :assetList.get(0).Id AND UserOrGroupId = :userIdList.get(0)];
        System.assertEquals(assetShareList[0].RowCause, 'Manual');

        Core_SharingUtility.provideAccess('Case', 'CaseShare', 'Edit', caseRecordUserList);
        List<CaseShare> caseShareList = [SELECT Id, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId = :caseList.get(0).Id AND UserOrGroupId = :userIdList.get(0)];
        System.assertEquals(caseShareList[0].RowCause, 'Manual');

        String jsonString = JSON.serialize(caseRecordUserList);
        Core_SharingUtility.revokeAccess('Case', 'CaseShare', jsonString);

        Core_SharingUtility.provideAccess('Core_IPS_Project__c', 'Core_IPS_Project__Share', 'Edit', setOfUserIdByProj);
        List<Core_IPS_Project__share> coreIpsProjShareList = [SELECT Id, UserOrGroupId, RowCause FROM Core_IPS_Project__share WHERE ParentId = :ipsProjects.get(0).Id AND UserOrGroupId = :userIdList.get(0)];
        System.assertEquals(coreIpsProjShareList[0].RowCause, 'Manual');
        Core_SharingUtility.revokeAccess('Core_IPS_Project__c', 'Core_IPS_Project__Share', setOfUserIdByProj);

        Core_SharingUtility.provideAccess('Asset', 'AssetShare', 'Abc', assetRecordUserList);
        Core_SharingUtility.revokeAccess('Asset', 'AssetShare', assetRecordUserList);
        Test.stopTest();
    }

    static testmethod void provideAccessTest4() {
        getRecords();
        List<Core_IPS_Labels__c> labelList = new List<Core_IPS_Labels__c>();
        labelList.add(new Core_IPS_Labels__c(Name = 'RowCause_Team', Value__c = 'Team'));
        labelList.add(new Core_IPS_Labels__c(Name = 'Rowcause_Owner', Value__c = 'Owner'));
        labelList.add(new Core_IPS_Labels__c(Name = 'AccessLevel_Edit', Value__c = 'Edit'));
        labelList.add(new Core_IPS_Labels__c(Name = 'AccessLevel_Read', Value__c = 'Read'));

        Account accountRecord = TestUtilities.getAccountRecord();
        accountRecord.OwnerId = faeUsers.get(0).Id;

        Core_IPS_Project__c projectRecord = TestUtilities.getIpsProjectRecord();
        projectRecord.OwnerId = faeUsers.get(0).Id;
        projectRecord.Core_Status__c = 'Draft';

        insert accountRecord;
        insert projectRecord;

        List<Core_IPS_Account__c> projectAccounts = TestUtilities.getListOfIpsAccounts(1);
        for (Core_IPS_Account__c projectAccount : projectAccounts) {
            projectAccount.Core_IPS_Project__c = projectRecord.Id;
            projectAccount.Core_Account__c = accountRecord.Id;
        }
        insert projectAccounts;

        Set<Id> accountIdSet = new Set<Id>();
        for (Account accountRec : accounts) {
            accountIdSet.add(accountRec.Id);
        }

        Set<Id> projIdSet = new Set<Id>();
        projIdSet.add(ipsProjects.get(0).Id);

        Set<Id> userIds = new Set<Id>();
        userIds.add(faeUsers.get(0).Id);

        Map<Id, Set<Id>> projectMemberIdMap = new Map<Id, Set<Id>>();
        projectMemberIdMap.put(projectRecord.Id, userIds);

        Test.startTest();
        Core_SharingUtility.getCustomerUserRoleIdsByAccountId(accountIdSet);
        try {
            Core_SharingUtility.revokeProjectAccess(projectMemberIdMap);
        } catch (Exception e) {}
        Core_SharingUtility.getGroupIdByProject(projIdSet);
        Test.stopTest();
    }
}