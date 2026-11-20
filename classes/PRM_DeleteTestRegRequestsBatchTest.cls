/*********************************************************************************************************************
Class Name    : PRM_DeleteTestRegRequestsBatchTest
Version       : 1.0
Created Date  : August 2026
Function      : Test Class for 'PRM_DeleteTestRegRequestsBatchTest'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  August,2026              Test Class for 'PRM_DeleteTestRegRequestsBatchTest'
*********************************************************************************************************************/
@IsTest
private class PRM_DeleteTestRegRequestsBatchTest {

    @TestSetup
    static void createTestData() {
        
        List<ChannelProgram> channelPrograms = new List<ChannelProgram>();
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        channelPrograms.add(cp);
        insert channelPrograms;

        PRM_Registration_Request__c newRegistrationRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRegistrationRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        newRegistrationRequest.PRM_Partner_Type__c = 'FPGA Design Services';
        newRegistrationRequest.PRM_Contact_Login_ID__c = 'testrequest@maildrop.cc';
        newRegistrationRequest.PRM_Status__c = 'New';
        newRegistrationRequest.Name = 'Auto Approve Request On Partner Role';
        newRegistrationRequest.PRM_Legal_Agreements__c = 'IPA_TANDC';
        newRegistrationRequest.PRM_Profile_Response__c = 'test pr'; 
        newRegistrationRequest.PRM_Email_ID__c = 'testrequest@spamok.com';
        newRegistrationRequest.PRM_Country__c = 'US';
        newRegistrationRequest.PRM_Preferred_Language__c = 'ENG';
        newRegistrationRequest.PRM_Channel_Program__c=cp.Id;
        insert newRegistrationRequest;
    }

    @IsTest
    static void testDeleteTestRegistrations() {

        Test.startTest();
            Database.executeBatch(new PRM_DeleteTestRegistrationRequestsBatch(),200);
        Test.stopTest();
    }
}