@isTest
global class Core_IPS_BES_LogEntry_Utility_Test {
    @testSetup
    static void setup(){
        Core_IPS_System_Credentails_Apigee__c customSetting = new Core_IPS_System_Credentails_Apigee__c();
        customSetting.Name = 'Core_IPS_Transaction_Tracking';
        customSetting.Core_IPS_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a8225308';
        customSetting.Core_IPS_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.Core_IPS_EndPointURL__c = 'https://apis-satage.intel.com/m2r/cases/v1/transactions';
        customSetting.Core_IPS_GrantType__c = 'client_credentials';
        customSetting.Core_IPS_Authorization_URL__c = 'https://apis-sandbox.intel.com/v1/auth/token';
        insert customSetting;
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        Case cs = TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert cs;

        Core_IPS_BES_Outbound_Message__c outboundRec = new Core_IPS_BES_Outbound_Message__c();
        outboundRec.core_IPS_Outbound_Message_ID__c = '123';
        outboundRec.Core_IPS_Case_ID__c = cs.Id;
        outboundRec.Status__c = 'Apigee Success';
        //outboundRec.Comment_Id__c = '';
        insert outboundRec;

        Core_IPS_BES_Inbound_Message__c inboundRec = new Core_IPS_BES_Inbound_Message__c();
        inboundRec.Core_IPS_Inbound_Message_ID__c = '1234';
        insert inboundRec;
    }
    @isTest
    global static void testMethod1(){
        String errorCode = '200';
        Core_IPS_BES_Outbound_Message__c outbound = [SELECT Id,Core_IPS_Case_ID__c,Name FROM Core_IPS_BES_Outbound_Message__c LIMIT 1];
        Core_IPS_BES_Inbound_Message__c inbound = [SELECT Id,Name FROM Core_IPS_BES_Inbound_Message__c LIMIT 1];
        try{
            throw new StringException('Custom exception thrown');
        } catch(Exception e){
            
			System.assertEquals('Custom exception thrown', e.getMessage(), 'Exception should match');
            Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c='test description',Core_IPS_Status__c = 'test status');
            insert errorLog;

            Test.setMock(HttpCalloutMock.class, new Core_IPS_myIntelHttpCalloutMock());
            Test.startTest();
            Core_IPS_BES_LogEntry_Utility.insertLog(e , outbound, inbound, errorCode, null);
            Core_IPS_BES_LogEntry_Utility.insertLog(e.getLineNumber() , errorLog.Core_IPS_Error_Description__c, errorLog.Core_IPS_Status__c);
            Test.stopTest();

            
            
        }
    }
    
    
    
}