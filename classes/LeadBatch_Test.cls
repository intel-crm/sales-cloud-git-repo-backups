@isTest
public class LeadBatch_Test {

    @TestSetup
    static void createSetupData(){
        Lead ld=new Lead();
        ld.Status='Marketing Qualified Lead';
        ld.Core_Lead_Status__c='Accepted';
        ld.FirstName='LeadTre';
        ld.LastName='Testtre';
        ld.Company='Intel internal use – one-time or ongoing use for internal development and research projects';
        ld.Phone='6578098765';
        ld.Email='testls@mailinator.com';
        ld.LeadSource='IDC Credit Request';
        insert ld;
    }
    @isTest
    static void testLead(){
        Test.startTest();
        LeadBatch cpe = new LeadBatch();
        Id batchJobId = Database.ExecuteBatch(cpe);
        Test.stopTest();
    }

}