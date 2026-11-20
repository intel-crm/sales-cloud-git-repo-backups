/**************************************************************************************
Apex Class Name : Core_Draco_PSLicenceCleanupBatchTest 
Created Date: 6th June 2024
Description : Test class to cleanup Permission Set License from the user record who does not have permission set assigned
* Modification Log :
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Akshay                  6th-June-2024             	Original Version
*************************************************************************************/
@isTest(SeeAllData=false)
public class Core_Draco_PSLicenceCleanupBatchTest {
    @isTest
    static void testPSLicenceCleanupBatch() {
        PermissionSetLicense psLicense1=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='EinsteinAnalyticsPlusPsl' LIMIT 1];
        PermissionSetLicense psLicense2=[SELECT Id,DeveloperName from PermissionSetLicense WHERE DeveloperName='SalesCloudUnlimitedPsl' LIMIT 1];

        //PermissionSets associated with the License
        PermissionSet permSet1 = new PermissionSet();
        permSet1.Label = 'Test PermissionSet1';
        permSet1.Name = 'Test_PermissionSet1';
        permSet1.LicenseId = psLicense1.Id;
        insert permSet1;

        PermissionSet permSet2 = new PermissionSet();
        permSet2.Label = 'Test PermissionSet2';
        permSet2.Name = 'Test_PermissionSet2';
        permSet2.LicenseId = psLicense2.Id;
        insert permSet2;

        Profile p = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        User testUser1 = new User(
            Username = 'testuser1@intel.com',
            Alias = 'test1',
            Email = 'testuser1@intel.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            LastName = 'User1'
        );
        insert testUser1;

        // Assign PermissionSetLicense to testUser1
        PermissionSetLicenseAssign psla1=new PermissionSetLicenseAssign();
        psla1.AssigneeId = testUser1.Id;
        psla1.PermissionSetLicenseId = psLicense1.Id;
        insert psla1;

        PermissionSetLicenseAssign psla2 = new PermissionSetLicenseAssign();
        psla2.AssigneeId = testUser1.Id;
        psla2.PermissionSetLicenseId = psLicense2.Id;
        insert psla2;
        
        //Assign PermissionSet to the testUser1
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.AssigneeId = testUser1.Id;
        psa1.PermissionSetId = permSet1.Id;
        insert psa1;

        PermissionSetAssignment psa2 = new PermissionSetAssignment();
        psa2.AssigneeId = testUser1.Id;
        psa2.PermissionSetId = permSet2.Id;
        insert psa2;

        User testUser2 = new User(
            Username = 'testuser2@intel.com',
            Alias = 'test2',
            Email = 'testuser2@intel.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            LastName = 'User2'
        );
        insert testUser2;

        // Assign PermissionSetLicense to testUser2
        PermissionSetLicenseAssign psla3=new PermissionSetLicenseAssign();
        psla3.AssigneeId = testUser2.Id;
        psla3.PermissionSetLicenseId = psLicense1.Id;
        insert psla3;

        PermissionSetLicenseAssign psla4= new PermissionSetLicenseAssign();
        psla4.AssigneeId = testUser2.Id;
        psla4.PermissionSetLicenseId = psLicense2.Id;
        insert psla4;

        //Assign PermissionSet to the testUser2
        PermissionSetAssignment psa3 = new PermissionSetAssignment();
        psa3.AssigneeId = testUser2.Id;
        psa3.PermissionSetId = permSet2.Id;
        insert psa3;
            
        User testUser3 = new User(
            Username = 'testuser3@intel.com',
            Alias = 'test3',
            Email = 'testuser3@intel.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            LastName = 'User3'
        );
        insert testUser3;

        // Assign PermissionSetLicense to testUser3
        PermissionSetLicenseAssign psla5=new PermissionSetLicenseAssign();
        psla5.AssigneeId = testUser3.Id;
        psla5.PermissionSetLicenseId = psLicense1.Id;
        insert psla5;

        PermissionSetLicenseAssign psla6= new PermissionSetLicenseAssign();
        psla6.AssigneeId = testUser3.Id;
        psla6.PermissionSetLicenseId = psLicense2.Id;
        insert psla6;

        //Assign PermissionSet to the testUser3
        PermissionSetAssignment psa4 = new PermissionSetAssignment();
        psa4.AssigneeId = testUser3.Id;
        psa4.PermissionSetId = permSet1.Id;
        insert psa4;
    
        User testUser4 = new User(
            Username = 'testuser4@intel.com',
            Alias = 'test4',
            Email = 'testuser4@intel.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            LastName = 'User4'
        );
        insert testUser4;

        // Assign PermissionSetLicense to testUser4
        PermissionSetLicenseAssign psla7=new PermissionSetLicenseAssign();
        psla7.AssigneeId = testUser4.Id;
        psla7.PermissionSetLicenseId = psLicense1.Id;
        insert psla7;

        PermissionSetLicenseAssign psla8= new PermissionSetLicenseAssign();
        psla8.AssigneeId = testUser4.Id;
        psla8.PermissionSetLicenseId = psLicense2.Id;
        insert psla8;
        
        Test.startTest();
        Core_Draco_PSLicenceCleanupBatch batch=new Core_Draco_PSLicenceCleanupBatch();
        Database.executeBatch(batch,200);
        Test.stopTest();

        // Verify the results
        List<PermissionSetLicenseAssign> remainingAssignments1 = [SELECT Id, AssigneeId, PermissionSetLicenseId FROM PermissionSetLicenseAssign where AssigneeId=:testUser1.Id];
        System.assertEquals(2, remainingAssignments1.size());
    }

}