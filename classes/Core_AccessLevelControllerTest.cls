@isTest
private with sharing class Core_AccessLevelControllerTest {
    @TestSetup static void setup() {

        Profile spuProfile = [select id, name from Profile where name = 'System Administrator' Limit 1];
        UserRole ur = new UserRole(DeveloperName = 'SharingRole', Name = 'Sharing Role');
        insert ur;
        User user = new User(Alias = 'stdusr', 
                             Email='stdusr@example.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='std',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = spuProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='stduseraccess@test.com',
                             UserRoleId = ur.Id);
        insert user;
        
        List<PermissionSet> perms = new List<PermissionSet>();
        PermissionSet ps1 = new PermissionSet(Name='testps',Label='test ps');
        perms.add(ps1);
        PermissionSet ps2 = new PermissionSet(Name='testps2',Label='test ps2');
        perms.add(ps2);
        
        insert perms;

        List<ObjectPermissions> op = new List<ObjectPermissions>();

        op.add(new ObjectPermissions(ParentId=perms[0].Id,SobjectType='Account',PermissionsRead=true,PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=perms[1].Id,SobjectType='Account',PermissionsRead=true,PermissionsEdit=true,PermissionsDelete=true,PermissionsViewAllRecords=true,PermissionsModifyAllRecords=true));
        insert op;
        
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.PermissionSetId = perms[0].Id;
        psa1.AssigneeId = user.Id;
        psas.add(psa1);
        
        PermissionSetAssignment psa2 = new PermissionSetAssignment();
        psa2.PermissionSetId = perms[1].Id;
        psa2.AssigneeId = user.Id;
        psas.add(psa2);
            
        insert psas;
        List<Group> grps = new List<Group>();
        
        Group testGroup = new Group();
        testGroup.Name = 'testGroupSharing';
        testGroup.DeveloperName = 'testGroupSharing';
        grps.add(testGroup);
        
        Group testGroup1 = new Group();
        testGroup1.Name = 'testGroupSharing1';
        testGroup1.DeveloperName = 'testGroupSharing1';
        grps.add(testGroup1);
        
        insert grps;
        
        List<GroupMember> gms = new List<GroupMember>();
        GroupMember gm = new GroupMember();
        gm.GroupId = grps[0].Id;
        gm.UserOrGroupId = user.Id;
        gms.add(gm);
        
        GroupMember gm1 = new GroupMember();
        gm1.GroupId = grps[1].Id;
        gm1.UserOrGroupId = grps[0].Id;
        gms.add(gm1);
        
        GroupMember gm2 = new GroupMember();
        gm2.GroupId = grps[1].Id;
        gm2.UserOrGroupId = [SELECT Id FROM Group WHERE Type = 'Role' and DeveloperName = 'SharingRole'].Id;
        gms.add(gm2);
        
        insert gms;
        
    }

    @isTest static void checkAccessLevelMethod() {
        Account acc = returnAccount();
        insert acc;
        
        List<Core_Design_Registration__c> ddrList = Core_DDR_Utility.createDDR(1);
        insert ddrList;
 
        List<User> usrs = [SELECT Id FROM User Where UserName = 'stduseraccess@test.com'];
        
        List<Group> grps = [SELECT Id FROM Group Where DeveloperName like '%testGroupSharing%'];

        List<AccountShare> acss = new List<AccountShare>();
        
        acss.add(returnAccountShare(acc.Id,usrs[0].Id));
        acss.add(returnAccountShare(acc.Id,grps[0].Id));
        acss.add(returnAccountShare(acc.Id,grps[1].Id));
        acss.add(returnAccountShare(acc.Id,[SELECT Id FROM Group WHERE Type = 'Role' and DeveloperName = 'SharingRole'].Id));
        
        Database.insert(acss,false);
		
        Test.startTest();
        Core_AccessLevelController.getAccessLevel(ddrList[0].Id, usrs[0].Id);
        Core_AccessLevelController.getAccessLevel(acc.Id, usrs[0].Id);
        Core_AccessLevelController.getAccessLevel('test', usrs[0].Id);
        Core_AccessLevelController.getAccessLevel(acc.Id, 'test');
        acc.OwnerId = usrs[0].Id;
        update acc;
        Core_AccessLevelController.ResponseWrapper res = Core_AccessLevelController.getAccessLevel(acc.Id, usrs[0].Id);
        Assert.isTrue(res.editRecAccess, 'Edit access should be present');
        Test.stopTest();
    }

    private static Account returnAccount () {
        Account acc = new Account();
        acc.Name = 'test account';
        acc.BillingCountryCode = 'USA';
        acc.BillingStateCode = 'AL';
        acc.BillingCity = 'Alabama';
        acc.BillingStreet = 'street';
        return acc;
    }

    private static AccountShare returnAccountShare (Id accId, Id usId) {
        AccountShare acd = new AccountShare();
        acd.AccountAccessLevel = 'Edit';
        acd.OpportunityAccessLevel = 'Edit';
        acd.CaseAccessLevel = 'Edit';
        acd.AccountId = accId;
        acd.RowCause = 'Manual';
        acd.UserOrGroupId = usId;
        return acd;
    }
}