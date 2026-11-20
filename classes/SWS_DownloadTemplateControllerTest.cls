@isTest
public class SWS_DownloadTemplateControllerTest {
    @testSetup 
    private static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='requestoremail@example.com', 
                          EmailEncodingKey='UTF-8', LastName='requestorUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='requestoremail@testorg.com');
        insert u;
        PermissionSet ps = [SELECT Id  FROM PermissionSet WHERE Name = 'SWS_IDC_Business_Ops'];        
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
    }

    @isTest 
    private static void downloadTemplateTest(){
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        String result = SWS_DownloadTemplateController.downloadTemplate();
        system.assert(!String.isblank(result),'Test');
    }
}