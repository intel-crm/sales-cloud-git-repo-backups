@isTest
public without sharing class Core_ERPMBlackBoxInbndMsg_ContactTest {

    @TestSetup
    public static void setupTestData(){
        Core_IntegrationTestUtility.setupAcctContactEntitlementTestData(false);

        A_E_Error_Mapping__c errEntry = new A_E_Error_Mapping__c(
        A_E_Error_Code_Txt__c='Invalid Individual/Account Engagement Code.');
        insert errEntry;
    }

    public static Core_Integration_Inbound_Message__c newERPMBlackboxMessage(String payload) {
        Core_Integration_Inbound_Message__c message=new Core_Integration_Inbound_Message__c();
        message.Core_Source_System__c='ERPM';
        message.Core_Message_Type__c='Blackbox';
        message.Core_Processing_Status__c = 'Pending';
        message.Core_Payload__c=payload;
        return message;
    }

    @isTest
    private static void testERPMBlackboxMessage_SuccessPersonId(){

        String msg = TEST_ERPM_BLACKBOX_SUCCESS_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      '');
        msg = msg.replace('REPLACE_BB_ACCT1_NUMBER',  '301392141');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMBlackboxMessage(msg);
        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMBlackBoxInbndMsg_ContactService.processBlackboxMessages(integrationinboundMessage);
        Test.stopTest();
    }

    @isTest
    private static void testERPMBlackboxMessage_FailurePersonId(){
        String msg = TEST_ERPM_BLACKBOX_FAILURE_JSON;
        msg = msg.replace('REPLACE_BB_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_BB_ENTERPRISE_ID', '1000001000');
        msg = msg.replace('REPLACE_BB_LOGIN_ID',      'test0');
        msg = msg.replace('REPLACE_BB_EMAIL_ID',      'testcontact0@acct0.com');
        msg = msg.replace('REPLACE_BB_ERROR_CODE',    'ERRCODE');
        msg = msg.replace('REPLACE_BB_ERROR_TEXT',    'ERRTEXT');
        msg = msg.replace('REPLACE_BB_ERROR_DETAILS', 'ERRDETAILS');

        Core_Integration_Inbound_Message__c integrationinboundMessage=newERPMBlackboxMessage(msg);
        Test.startTest();
        insert integrationinboundMessage;
        Core_ERPMBlackBoxInbndMsg_ContactService.processBlackboxMessages(integrationinboundMessage);
        Test.stopTest();
    }

    private static final String TEST_ERPM_BLACKBOX_SUCCESS_JSON = '{ ' +
        '"Status": "Success", ' +
        '"ErrorCode":null, ' +
        '"ErrorText": null, ' +
        '"ErrorDetails": null, ' +
        '"PersonID": REPLACE_BB_PERSON_ID, ' +
        '"EnterpriseID": "REPLACE_BB_ENTERPRISE_ID", ' +
        '"LoginID": "REPLACE_BB_LOGIN_ID", ' +
        '"EmailID": "REPLACE_BB_EMAIL_ID", ' +
        '"Accounts": [ ' +
        '{ ' +
        '"AccountNumber": REPLACE_BB_ACCT1_NUMBER, ' +
        '"CIMID": "REPLACE_BB_ACCT1_CIMID", ' +
        '"SalesCloudID": "REPLACE_BB_ACCT1_SFDCID" ' +
        '} ' +
        '] ' +
        '}';
    
    private static final String TEST_ERPM_BLACKBOX_FAILURE_JSON = '{ ' +
        '"Status": "Failure", ' +
        '"ErrorCode": "REPLACE_BB_ERROR_CODE", ' +
        '"ErrorText": "REPLACE_BB_ERROR_TEXT", ' +
        '"ErrorDetails": "REPLACE_BB_ERROR_DETAILS", ' +
        '"PersonID": REPLACE_BB_PERSON_ID, ' +
        '"EnterpriseID": "REPLACE_BB_ENTERPRISE_ID", ' +
        '"LoginID": "REPLACE_BB_LOGIN_ID", ' +
        '"EmailID": "REPLACE_BB_EMAIL_ID", ' +
        '"Accounts": null ' +
        '}';

}