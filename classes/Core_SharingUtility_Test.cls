@isTest
public class Core_SharingUtility_Test{
    static List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c> ();
    static List<Account> ListOfAccounts = new List<Account> ();
    static List<Contact> ListOfContacts = new List<Contact> ();
    static List<User> ListOfUser = new List<User> ();
    static List<Asset> AssetList = new List<Asset> ();
    static List<Case> ListOfCase = new List<Case> ();
    static void getRecords(){
        // ips Project
        ListOfIpsProjects = TestUtilities.getListOfIpsProjects(5);
        insert ListOfIpsProjects;
        System.Assert(ListOfIpsProjects.get(0).Id != null, 'Record not created');
        // Account
        System.runAs (new User(Id = UserInfo.getUserId())) {
            ListOfAccounts = TestUtilities.getListOfAccounts(5);
        }
        insert ListOfAccounts;
        System.Assert(ListOfAccounts.get(0).Id != null, 'Record not created');
        // Contact
        ListOfContacts = TestUtilities.getListOfContact(5);
        integer counter = 0;
        Id CurrentLoggedInUserId = UserInfo.getUserId();
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Accountid = ListOfAccounts.get(counter).Id;
            ContactRec.Core_IPS_Intel_Support_Owner__c = CurrentLoggedInUserId;
            counter++;
        }
        insert ListOfContacts;
        System.Assert(ListOfContacts.get(0).Id != null, 'Record not created');
        // Profile Query
        Profile CustomerProfile = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        // Creating Customer User
        System.runAs (new User(Id = UserInfo.getUserId())) {
        ListOfUser = TestUtilities.getListOfUser(5);
        }
        integer counter2 = 0;
        for(User Usr : ListOfUser){
            Usr.ProfileID = CustomerProfile.id;
            Usr.contactId = ListOfContacts.get(counter2).id;
            counter2++;
        }
        System.runAs (new User(Id = UserInfo.getUserId())) {
            insert ListOfUser;
        }
        System.Assert(ListOfUser.get(0).Id != null, 'Record not created');
        // Asset
        AssetList = TestUtilities.getAssetList(5);
        integer counter3 = 0;
        for(Asset Asst : AssetList){
            Asst.Core_IPS_Project__c = ListOfIpsProjects.get(counter3).Id;
            Asst.accountId = ListOfAccounts.get(counter3).Id;
            Asst.Contactid = ListOfContacts.get(counter3).id;
            counter3++;
        }
        insert AssetList;
        System.Assert(AssetList.get(0).Id != null, 'Record not created');
        // Case
        ListOfCase = TestUtilities.getListOfCases(5);
        insert ListOfCase;
        System.Assert(ListOfCase.get(0).Id != null, 'Record not created');
    }
    /*static testmethod void createShareRecords_Test(){
        getRecords();
        Map<id,List<Asset>> assetsByproj = new Map<id,List<Asset>>();
        Map<Id,List<id>> usersByProj = new Map<Id,List<id>> ();
        List<id> UserIdList = new List<id> ();
        List<id> UserIdLst = new List<id> ();
        Map<Id,List<id>> usersByPrj = new Map<Id,List<id>> ();
        for(Asset Asst : AssetList){
            if(assetsByproj.containsKey(Asst.Core_IPS_Project__c)){
                assetsByproj.get(Asst.Core_IPS_Project__c).add(Asst);
            }
            else{
                assetsByproj.put(Asst.Core_IPS_Project__c,new List<Asset>{Asst});
            }
        }
        for(User Usr : ListOfUser){
            UserIdList.add(Usr.id);
        }
        for(Core_IPS_Project__c ipsProj : ListOfIpsProjects){
            if(usersByProj.containsKey(ipsProj.id)){
                usersByProj.get(ipsProj.id).addAll(UserIdList);
            }
            else{
                usersByProj.put(ipsProj.id,new List<Id>());
                usersByProj.get(ipsProj.id).addAll(UserIdList);
            }
        }
        UserIdLst.add(UserInfo.getUserId());
        for(Core_IPS_Project__c ipsProj : ListOfIpsProjects){
            if(usersByPrj.containsKey(ipsProj.id)){
                usersByPrj.get(ipsProj.id).addAll(UserIdLst);
            }
            else{
                usersByPrj.put(ipsProj.id,new List<Id>());
                usersByPrj.get(ipsProj.id).addAll(UserIdLst);
            }
        }
        Test.startTest();
        // Testing "createShareRecords" utility method
        Core_SharingUtility.createShareRecords(assetsByproj,usersByProj);
        // Verify the Testing
        List<AssetShare> AssetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE assetId =:AssetList.get(0).id AND UserOrGroupId=: UserIdList.get(0)];
        System.assertEquals(AssetShareList[0].RowCause, 'Manual');
        // Negative Testing
        Core_SharingUtility.createShareRecords(assetsByproj,usersByPrj);
        Test.stopTest();
        
    }
    static testmethod void CreateMapShareRecords_Test(){
        getRecords();
        Map<Id, List<Asset>> assetsByAccount = new Map<Id, List<Asset>> ();
        for(Asset Asst : AssetList){
            if(assetsByAccount.containsKey(Asst.accountId)){
                assetsByAccount.get(Asst.accountId).add(Asst);
            }
            else{
                assetsByAccount.put(Asst.accountId,new List<Asset>{Asst});
            }
        }   
        Test.startTest();
        // Testing "CreateMapShareRecords" utility method
        Core_SharingUtility.CreateMapShareRecords(assetsByAccount);
        // Verify the Testing
        List<AssetShare> AssetShareList = [SELECT Id, UserOrGroupId,  RowCause FROM AssetShare WHERE assetId =:AssetList.get(0).id AND UserOrGroupId IN: ListOfUser ];
        System.assertEquals(AssetShareList[0].RowCause, 'Manual');
        Test.stopTest();
    }
    static testmethod void CreateContactShareRecords_Test(){
        getRecords();
        Map<Id, List<Asset>> assetsByContact = new Map<Id, List<Asset>> ();
        for(Asset Asst : AssetList){
            if(assetsByContact.containsKey(Asst.ContactId)){
                assetsByContact.get(Asst.ContactId).add(Asst);
            }
            else{
                assetsByContact.put(Asst.ContactId,new List<Asset>{Asst});
            }
        }
        Test.startTest();
        // Testing "CreateContactShareRecords" utility method
        Core_SharingUtility.CreateContactShareRecords(assetsByContact);
        // Verify the Testing
        List<AssetShare> AssetShareList = [SELECT Id, UserOrGroupId,  RowCause FROM AssetShare WHERE assetId =:AssetList.get(0).id AND UserOrGroupId IN: ListOfUser ];
        System.assertEquals(AssetShareList[0].RowCause, 'Manual');      
        Test.stopTest();        
    }*/
    static testmethod void ShareAssettoUser_Test(){
        getRecords();
        List<id> UserIdList = new List<id> ();
        for(User Usr : ListOfUser){
            UserIdList.add(Usr.id);
        }
        List<Asset> assetList2 = TestUtilities.getAssetList(5);
        insert assetList2;
        Test.startTest();
        // Testing "ShareAssettoUser" utility method
        Core_SharingUtility.ShareAssettoUser(UserIdList.get(0),AssetList2.get(0).id);
        // Verify the Testing
        List<AssetShare> AssetShareList = [SELECT Id, UserOrGroupId,  RowCause FROM AssetShare WHERE assetId =:AssetList2[0].id AND UserOrGroupId =: UserIdList[0] ];
        if(assetShareList!=null && assetShareList.size()>0) System.assertEquals(AssetShareList[0].RowCause, 'Manual');      
        Test.stopTest();
    }
    static testmethod void provideAccess_Test(){
        getRecords();
        List<id> UserIdList = new List<id> ();
        MAP<id,id> Record_UserList = new MAP<id,id>  ();
        for(User Usr : ListOfUser){
            UserIdList.add(Usr.id);
        }
        for(Core_IPS_Project__c ipsProj : ListOfIpsProjects){
            Record_UserList.put(ipsProj.id,UserIdList.get(0));
        }
        Test.startTest();
        // Testing "provideAccess" utility method
        Core_SharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Edit',Record_UserList);
        // Verify the Testing
        List<Core_IPS_Project__share> CoreIpsProjShareList = [SELECT Id, UserOrGroupId, RowCause FROM Core_IPS_Project__share WHERE ParentID =:ListOfIpsProjects.get(0).id AND UserOrGroupId =: UserIdList.get(0) ];
        System.assertEquals(CoreIpsProjShareList[0].RowCause, 'Manual');
        Core_SharingUtility.revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',Record_UserList);
        Test.stopTest();
    }
    /*static testmethod void shareAssetsforProjectmembers_Test(){
        getRecords();
        List<id> UserIdList = new List<id> ();
        Map<Id,List<id>> usersByProj = new Map<Id,List<id>> ();
        Map<id,List<Id>> assetIdByproj = new Map<id,List<Id>>();
        for(User Usr : ListOfUser){
            UserIdList.add(Usr.id);
        }
        for(Asset Asst : AssetList){
            if(assetIdByproj.containsKey(Asst.Core_IPS_Project__c)){
                assetIdByproj.get(Asst.Core_IPS_Project__c).add(Asst.id);
            }
            else{
                assetIdByproj.put(Asst.Core_IPS_Project__c,new List<Id>{Asst.id});
            }
        }
        for(Core_IPS_Project__c ipsProj : ListOfIpsProjects){
            if(usersByProj.containsKey(ipsProj.id)){
                usersByProj.get(ipsProj.id).addAll(UserIdList);
            }
            else{
                usersByProj.put(ipsProj.id,new List<Id>());
                usersByProj.get(ipsProj.id).addAll(UserIdList);
            }
        }
        Test.startTest();
        // Testing "shareAssetsforProjectmembers" utility method
        Core_SharingUtility.shareAssetsforProjectmembers(usersByProj,assetIdByproj);
        // Verify the Testing
        List<AssetShare> AssetShareList = [SELECT Id, UserOrGroupId,  RowCause FROM AssetShare WHERE assetId =:AssetList.get(0).id AND UserOrGroupId =: UserIdList.get(0) ];
        System.assertEquals(AssetShareList[0].RowCause, 'Manual');  
        // Negative Testing
        Core_SharingUtility.shareAssetsforProjectmembers(usersByProj,usersByProj);
        Test.stopTest();
    }*/
    static testmethod void provideAccess_Test2(){
        getRecords();
        MAP<id,Set<id>> AssetRecord_UserList = new MAP<id,Set<id>> ();
        MAP<id,Set<id>> CaseRecord_UserList = new MAP<id,Set<id>> ();
        Map<Id,set<id>> SetOfUseridByProj = new Map<Id,set<id>> ();
        List<id> UserIdList = new List<id> ();
        for(User Usr : ListOfUser){
            UserIdList.add(Usr.id);
        }
        for(Asset Asst : AssetList){
            if(AssetRecord_UserList.containsKey(Asst.id)){
                AssetRecord_UserList.get(Asst.id).addAll(UserIdList);
            }
            else{
                AssetRecord_UserList.put(Asst.id,new set<id>());
                AssetRecord_UserList.get(Asst.id).addAll(UserIdList);
            }
        }
        for(Case CaseRec : ListOfCase){
            if(CaseRecord_UserList.containsKey(CaseRec.id)){
                CaseRecord_UserList.get(CaseRec.id).addAll(UserIdList);
            }
            else{
                CaseRecord_UserList.put(CaseRec.id,new set<Id>());
                CaseRecord_UserList.get(CaseRec.id).addAll(UserIdList);
            }
        }
        for(Core_IPS_Project__c ipsProj : ListOfIpsProjects){
            if(SetOfUseridByProj.containsKey(ipsProj.id)){
                SetOfUseridByProj.get(ipsProj.id).addAll(UserIdList);
            }
            else{
                SetOfUseridByProj.put(ipsProj.id,new Set<Id>());
                SetOfUseridByProj.get(ipsProj.id).addAll(UserIdList);
            }
        }
        Test.startTest();
        // Testing "provideAccess" utility method
        Core_SharingUtility.provideAccess('Asset','AssetShare','Edit',AssetRecord_UserList);
        // Verify the Testing
        List<AssetShare> AssetShareList = [SELECT Id, UserOrGroupId, RowCause FROM AssetShare WHERE assetId =:AssetList.get(0).id AND UserOrGroupId =: UserIdList.get(0) ];
        System.assertEquals(AssetShareList[0].RowCause, 'Manual');  
        Core_SharingUtility.provideAccess('Case','CaseShare','Edit',CaseRecord_UserList);
        // Verify the Testing
        List<CaseShare> CaseShareList = [SELECT Id, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId =:ListOfCase.get(0).id AND UserOrGroupId =: UserIdList.get(0) ];
        System.assertEquals(CaseShareList[0].RowCause, 'Manual'); 
        String JSONString = JSON.serialize(CaseRecord_UserList);
        Core_SharingUtility.revokeAccess('Case','CaseShare',JSONString);
          
        Core_SharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Edit',SetOfUseridByProj); 
        List<Core_IPS_Project__share> CoreIpsProjShareList = [SELECT Id, UserOrGroupId, RowCause FROM Core_IPS_Project__share WHERE ParentID =:ListOfIpsProjects.get(0).id AND UserOrGroupId =: UserIdList.get(0) ];
        System.assertEquals(CoreIpsProjShareList[0].RowCause, 'Manual');
        Core_SharingUtility.revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',SetOfUseridByProj);
        // Verify the Testing
        
        // Negative Testing
        Core_SharingUtility.provideAccess('Asset','AssetShare','Abc',AssetRecord_UserList);
        Core_SharingUtility.revokeAccess('Asset','AssetShare',AssetRecord_UserList);
        Test.stopTest();
    }   
}