/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_ManageCPQLicenseAssignmentTest {
    static testMethod void assignLicense(){
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        List<User> fseUser = Pricing_Test_Utility.createUser();
        
        PackageLicense pl = [SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, ExpirationDate, Status FROM PackageLicense WHERE NamespacePrefix = 'SBQQ' LIMIT 1];
        
        UserPackageLicense upl = new UserPackageLicense();
        upl.PackageLicenseId = pl.Id;
        upl.UserId = adminUser[0].Id;
		Database.insert(upl, false);
        
        PermissionSet ps = [SELECT Id from PermissionSet where Name =: Label.Pricing_CPQ_Managed_License_User LIMIT 1]; 
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = adminUser[0].Id;
        psa.PermissionSetId = ps.Id;   
        psaList.add(psa);
        
        PermissionSetAssignment psa1 = new PermissionSetAssignment();
        psa1.AssigneeId = fseUser[0].Id;
        psa1.PermissionSetId = ps.Id;         
        psaList.add(psa1);
        
        insert(psaList);

        Test.startTest();
        
        Pricing_ManageCPQLicenseAssignment instance = new Pricing_ManageCPQLicenseAssignment();
        Database.executeBatch(instance);

        // Test covergae for Scheduler
        SchedulableContext sc = null;
        Pricing_ManageCPQLicense_Scheduler mpls = new Pricing_ManageCPQLicense_Scheduler();
        mpls.execute(sc);

        List<UserPackageLicense> faseUserLicense = [SELECT Id FROM UserPackageLicense];
        System.assert(faseUserLicense != null, 'FSE User not assigned a CPQ License');
        
        Test.stopTest();        
    }
}