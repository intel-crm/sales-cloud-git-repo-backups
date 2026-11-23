/**************************************************************************************
Apex Class Name:  Core_Batch_User_GroupMembership_Test
Version     : 1.0 
Created Date: 11/30/2016
Function    : Test
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Aran Wongsaprome            11/30/2016             New
*************************************************************************************/

@isTest
public class Core_Batch_User_GroupMembership_Test {
    static Profile Marketing;
    static Group NonGroup;
	static Group AllGroup;
    static Group CTWGroup;
    static List<User> TestUsers;

    static User MakeUser(String Type, String Tag) {
        return new User(
			Core_Employee_Type_Code__c = Type, ProfileId = Marketing.id, LastName='IOCLast', alias='IOCU',
            LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT',
			email='aran.d.wongsaprome@intel.com', UserName = '10645638.'+Tag+'@test.intel.com'
		);
    }
    
	/* Setup for testing:
	* Add a user without the group membership who should be in the all employees group.
	* Add rules to for associations to the groups.
	* (triggers not enabled)
	*/
	@testSetup static void setup() {
		Marketing = [ SELECT id FROM profile WHERE Name = 'Marketing User' LIMIT 1 ];
		
        TestUsers = new List<User>(); 
        TestUsers.add(MakeUser('CTW','CW'));
        TestUsers.add(MakeUser('EMP','EW'));
        TestUsers.add(MakeUser('Non-Badged','NW'));
        TestUsers.add(MakeUser('CTW','CC'));
        TestUsers.add(MakeUser('EMP','EC'));
        TestUsers.add(MakeUser('Non-Badged','NC'));
        Database.Insert(TestUsers);

        NonGroup = [ SELECT id FROM Group WHERE DeveloperName = 'Core_All_Non_Badged_Users_Group' ];
		AllGroup = [ SELECT id FROM Group WHERE DeveloperName = 'Core_All_Employees_Group' ];
        CTWGroup = [ SELECT id FROM Group WHERE DeveloperName = 'Core_All_Contingent_Workers_Group' ];
      	
        // Set memberships so there are two wrong and one correct for each of the three groups
        Database.Insert(new List<GroupMember> {
        	new GroupMember(GroupID=NonGroup.id, UserOrGroupId=TestUsers[0].id),
            new GroupMember(GroupID=AllGroup.id, UserOrGroupId=TestUsers[0].id),
            new GroupMember(GroupID=NonGroup.id, UserOrGroupId=TestUsers[1].id),
            new GroupMember(GroupID=CTWGroup.id, UserOrGroupId=TestUsers[1].id),
            new GroupMember(GroupID=AllGroup.id, UserOrGroupId=TestUsers[2].id),
            new GroupMember(GroupID=CTWGroup.id, UserOrGroupId=TestUsers[2].id),
            new GroupMember(GroupID=CTWGroup.id, UserOrGroupId=TestUsers[3].id),
            new GroupMember(GroupID=AllGroup.id, UserOrGroupId=TestUsers[4].id),
            new GroupMember(GroupID=NonGroup.id, UserOrGroupId=TestUsers[5].id)
        });

        System.runAs(Core_Test_Utility.systemAdminUser) {            
            // copy of rules asof today
            Database.Insert(new List<Core_User_Group_Rule__c> {
                new Core_User_Group_Rule__c(
                    Name = 'Employees Group Rule', Core_Field_Name__c  = 'Core_Employee_Type_Code__c', 
                    Core_Field_Value__c = 'EMP', Core_Group_Name__c  = 'Core_All_Employees_Group'
                ),
                new Core_User_Group_Rule__c(
                    Name = 'Non-Badged Group Rule', Core_Field_Name__c  = 'Core_Employee_Type_Code__c',  
                    Core_Field_Value__c = 'Non-Badged', Core_Group_Name__c  = 'Core_All_Non_Badged_Users_Group'
                ),
                new Core_User_Group_Rule__c(
                    Name = 'Contingent Workers Group Rule', Core_Field_Name__c  = 'Core_Employee_Type_Code__c', 
                    Core_Field_Value__c = 'CTW', Core_Group_Name__c  = 'Core_All_Contingent_Workers_Group'
                )
            });
        }
       
	}
    
    static Boolean CheckCTW() {
        return [ // wrong group is assigned
			SELECT id FROM GroupMember WHERE GroupID = :CTWGroup.id AND UserOrGroupId IN (
                SELECT id FROM User WHERE Core_Employee_Type_Code__c <> 'CTW' AND id in :TestUsers
           	)
		].isEmpty();
    }

    static Boolean CheckEMP() {
        return [ // wrong group is assigned
			SELECT id FROM GroupMember WHERE GroupID = :AllGroup.id AND UserOrGroupId IN (
                SELECT id FROM User WHERE Core_Employee_Type_Code__c <> 'EMP' AND id in :TestUsers
           	)
		].isEmpty();
    }
    
    static Boolean CheckNon() {
        return [ // wrong group is assigned
			SELECT id FROM GroupMember WHERE GroupID = :NonGroup.id AND UserOrGroupId IN (
                SELECT id FROM User WHERE Core_Employee_Type_Code__c <> 'Non-Badged' AND id in :TestUsers
           	)
		].isEmpty();
    }
    
	@isTest static void CheckBatch() {
        NonGroup = [ SELECT id FROM Group WHERE DeveloperName = 'Core_All_Non_Badged_Users_Group' ];
		AllGroup = [ SELECT id FROM Group WHERE DeveloperName = 'Core_All_Employees_Group' ];
        CTWGroup = [ SELECT id FROM Group WHERE DeveloperName = 'Core_All_Contingent_Workers_Group' ];
		TestUsers = [ select id, UserName, Core_Employee_Type_Code__c FROM User WHERE UserName LIKE '10645638.%' ];
        
		List<GroupMember> G = [ // wrong group is assigned
			SELECT id FROM GroupMember WHERE GroupID = :CTWGroup.id AND UserOrGroupId IN (
                SELECT id FROM User WHERE Core_Employee_Type_Code__c = 'CTW' AND id in :TestUsers
           	)
		];
        
		System.assert(!CheckCTW());
		System.assert(!CheckEMP());
        System.assert(!CheckNon());
        
		Test.startTest();
        Core_Batch_User_GroupMembership MyTest = new Core_Batch_User_GroupMembership();
		Database.executeBatch(MyTest);
        MyTest.CompareGroup('x','x','x');
		Test.stopTest();
        
		System.assert(CheckCTW());
		System.assert(CheckEMP());
        System.assert(CheckNon());
	}
}