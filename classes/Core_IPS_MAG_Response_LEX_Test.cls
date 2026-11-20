@isTest
public without sharing class Core_IPS_MAG_Response_LEX_Test {
    @TestSetup
    static void makeData(){
        Case caseRec1 = TestUtilities.getCase();
        insert caseRec1;
        Id profileId= UserInfo.getProfileId();
        User userRec = new User();
        userRec.Alias = 'tAlisa';
        userRec.Email ='testingEmail@example.com';
        userRec.EmailEncodingKey ='UTF-8';
        userRec.LastName='Testing';
        userRec.LanguageLocaleKey='en_US';
        userRec.LocaleSidKey='en_US';
        userRec.ProfileId = profileId;
        userRec.TimeZoneSidKey='America/Los_Angeles';
        userRec.UserName='t1e2s3t@username.com';
        insert userRec;
        Core_IPS_GEC_Details__c gecRec = new Core_IPS_GEC_Details__c();
        gecRec.Core_IPS_Case__c = caseRec1.Id;
        gecRec.Core_IPS_GEC_Question1__c = 'Test_Question';
        gecRec.Core_IPS_GEC_Question2__c = 'Test_Answer';
        gecRec.LastModifiedBy = userRec;
        gecRec.CreatedDate = Date.Today();
        insert gecRec;
 
        Case caseRec2 = TestUtilities.getCase();
        insert caseRec2;
        caseRec2.Status = 'Open';
        update caseRec2;
        Core_IPS_Question__c queRec = new Core_IPS_Question__c();
        queRec.Core_IPS_Question__c = 'Sample Question';
        queRec.RecordTypeId = Schema.sObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('MAG Question').getRecordTypeId();
        queRec.Core_IPS_Datatype__c = 'Picklist';
        insert queRec;
        Core_IPS_Response__c resRec = new Core_IPS_Response__c();
        resRec.Core_IPS_Case__c = caseRec2.Id;
        resRec.Core_IPS_Question_Master__c = queRec.Id;
        resRec.Core_IPS_Answer__c = 'Test Answer';
        resRec.LastModifiedById = userRec.Id;
        resRec.CreatedDate = Date.today();
        insert resRec;
        Core_IPS_Answer__c ansRec = new Core_IPS_Answer__c();
        ansRec.Core_IPS_Question__c = queRec.Id;
        ansRec.Core_IPS_Answer__c = 'Test Answer';
        insert ansRec;
        queRec.Core_IPS_Environment_Detail_Answer__c = ansRec.Id;
        update queRec;
    }
    @isTest
    public static void getGecDetails(){
        Case caseRec = [SELECT Id, Status FROM Case WHERE Status = 'New'];
        List<Core_IPS_GEC_Details__c> lst = Core_IPS_MAG_Response_LEX_Controller.getMagResponses(caseRec.Id);
        System.assertEquals(true, lst.size() > 0,'SUCCESS');
    }
    @isTest
    public static void getResponses(){
        Case caseRec = [SELECT Id, Status FROM Case WHERE Status = 'Open'];
        List<Case> lst = Core_IPS_MAG_Response_LEX_Controller.getEnvironmentalDetailResponse(caseRec.Id);
        System.assertEquals(true, lst.size() > 0,'SUCCESS');
    }
}