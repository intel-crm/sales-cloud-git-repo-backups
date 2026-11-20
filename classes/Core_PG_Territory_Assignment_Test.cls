@isTest
public class Core_PG_Territory_Assignment_Test	 { 
    static Profile Marketing;
    static Group NonGroup;
    static Group AllGroup;
    static List<User> TestUsers;
    
    static User MakeUser(String Type, String Tag) {
        return new User(
            Core_Employee_Type_Code__c = Type, ProfileId = Marketing.id, LastName='IOCLast', alias='IOCU',
            LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT',
            email='aran.d.wongsaprome@intel.com', UserName = '10645638.'+Tag+'@test.intel.com'
        );
    }
    @testSetup static void setup() {
        Marketing = [ SELECT id FROM profile WHERE Name = 'Marketing User' LIMIT 1 ];
        TestUsers = new List<User>(); 
        TestUsers.add(MakeUser('CTW','CW'));
        TestUsers.add(MakeUser('EMP','EW'));
        Database.Insert(TestUsers);
        //Create Parent Group
        List<Group> publicGroupList = new List<Group>();
        Group grp1 = new Group();
        grp1.name = 'Test Group1';
        grp1.Type = 'Regular'; 
        publicGroupList.add(grp1);
        
        //Create Group2
        Group grp2 = new Group();
        grp2.name = 'Test Group2';
        grp2.Type = 'Regular'; 
        publicGroupList.add(grp2);
        
        insert publicGroupList;
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = TestUsers[0].id;
        grpMem1.GroupId = grp1.Id;
        Insert grpMem1;
        
        //Create Group Memeber2
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = TestUsers[1].id;
        grpMem2.GroupId = grp1.Id;
        Insert grpMem2;
        
        
        //Create Group Member
        GroupMember grpMem3 = new GroupMember();
        grpMem3.UserOrGroupId = TestUsers[0].id;
        grpMem3.GroupId = grp2.Id;
        Insert grpMem3;
        
        // public static testMethod void testPopulateterri(){
        list<territory2type> tTypeList = new list<territory2type>();
        list<territory2> territoryList = new list<territory2>();
        Territory2Model tModel = new Territory2Model();
        tModel.name = 'testModel';
        tModel.developername = 'test';
        insert tModel;
        // DML not allowed on Territory2Type object. so extracting recrds using Soql.
        Id tBusinessType = [Select id from territory2type where MasterLabel = 'Business Units and Specialists'].Id;
        Id tGeographicType = [Select id from territory2type where MasterLabel = 'Geographic World Wide'].Id;
        Id tNamedType = [Select id from territory2type where MasterLabel = 'Named / Strategic Accounts'].Id;
        territory2 t = new territory2();
        t.name = 'test';
        t.developername = 'test';
        t.Territory2ModelId = tModel.Id;
        t.territory2typeId = tBusinessType;
        territoryList.add(t);
        territory2 t1 = new territory2();
        t1.name = 'test1';
        t1.developername = 'test1';
        t1.Territory2ModelId = tModel.Id;
        t1.territory2typeId = tGeographicType;
        territoryList.add(t1);
        insert territoryList;
        
        List<UserTerritory2Association> lstuserassociation = new List<UserTerritory2Association>();
        UserTerritory2Association userassociation1 = new UserTerritory2Association();
        userassociation1.Territory2Id = t.id;
        userassociation1.UserId = TestUsers[0].id;
        lstuserassociation.add(userassociation1);
        
        UserTerritory2Association userassociation2 = new UserTerritory2Association();
        userassociation2.Territory2Id = t1.id;
        userassociation2.UserId = TestUsers[1].id;
        lstuserassociation.add(userassociation2);
        
        insert lstuserassociation;
        System.debug('===userassociation===>'+lstuserassociation);
        
        
        
    }
    
    static testmethod void CheckBatch(){
        Test.startTest();
        List<Core_PublicGroup_Territory_Mapping__mdt> cpgtList = new List<Core_PublicGroup_Territory_Mapping__mdt>();
        Core_PublicGroup_Territory_Mapping__mdt  pgtMapping1 = new Core_PublicGroup_Territory_Mapping__mdt();
        pgtMapping1.Core_Public_Group_Name_txt__c = 'Test Group1';
        pgtMapping1.Core_Territory_Name_txt__c = 'test';
        cpgtList.add(pgtMapping1);
        Core_PublicGroup_Territory_Mapping__mdt  pgtMapping2 = new Core_PublicGroup_Territory_Mapping__mdt();
        pgtMapping2.Core_Public_Group_Name_txt__c = 'Test Group2';
        pgtMapping2.Core_Territory_Name_txt__c = 'test1';
        system.assertEquals('Test Group2', pgtMapping2.Core_Public_Group_Name_txt__c);
        system.assertEquals('test1',  pgtMapping2.Core_Territory_Name_txt__c);
        cpgtList.add(pgtMapping2);
        Core_PG_Territory_Assignment.addOrRemoveUsers(cpgtList);
        Test.stopTest();
    }
}