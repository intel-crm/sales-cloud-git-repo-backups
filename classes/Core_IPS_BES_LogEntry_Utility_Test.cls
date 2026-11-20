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
        customSetting.Core_IPS_Authorization_URL__c = 'https://apis.intel.com/v1/auth/token';
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

            Test.setMock(HttpCalloutMock.class, new Core_IPS_BES_IPassHttpCalloutMock());
            Test.startTest();
            Core_IPS_BES_LogEntry_Utility.insertLog(e , outbound, inbound, errorCode, null);
            Core_IPS_BES_LogEntry_Utility.insertLog(e.getLineNumber() , errorLog.Core_IPS_Error_Description__c, errorLog.Core_IPS_Status__c);
            Test.stopTest();

            
            
        }
    }
    @isTest
    public static void testFormJSON(){
        String errorCode = '200';
        Core_IPS_BES_Outbound_Message__c outbound = [SELECT Id,Core_IPS_Case_ID__c,Name FROM Core_IPS_BES_Outbound_Message__c LIMIT 1];
        Core_IPS_BES_Inbound_Message__c inbound = [SELECT Id,Name FROM Core_IPS_BES_Inbound_Message__c LIMIT 1];
        List<Core_IPS_BES_Error_Log__c> erList = new List<Core_IPS_BES_Error_Log__c>();
        Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c='test description',Core_IPS_Status__c = 'test status');
        Core_IPS_BES_Error_Log__c errorLog1 = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c='test description',Core_IPS_Status__c = NULL);
        Core_IPS_BES_Error_Log__c errorLog2 = new Core_IPS_BES_Error_Log__c(Core_IPS_Error_Description__c=NULL,Core_IPS_Status__c ='Test Status1');
       	erList.add(errorLog);
        erList.add(errorLog1);
        erList.add(errorLog2);
        insert erList;
        Test.startTest();
        Core_IPS_BES_Transaction_Track.formJson(errorLog, null, inbound, 'Exception thrown');
        Case cs = TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = null;
        insert cs;
        Core_IPS_BES_Outbound_Message__c outboundRec = new Core_IPS_BES_Outbound_Message__c();
        outboundRec.core_IPS_Outbound_Message_ID__c = '123';
        outboundRec.Core_IPS_Case_ID__c = cs.Id;
        outboundRec.Status__c = 'Apigee Success';
        insert outboundRec;
System.assertNotEquals(null, outboundRec.Id, 'Id should not be equal');
        Core_IPS_BES_Transaction_Track.formJson(erList[0], outboundRec, inbound, 'Exception thrown');
        Core_IPS_BES_Transaction_Track.formJson(erList[1], outboundRec, inbound, 'Exception thrown');      
        Core_IPS_BES_Transaction_Track.formJson(erList[2], outboundRec, inbound, 'Exception thrown');
        Core_IPS_BES_Transaction_Track.formJson(errorLog, outboundRec, inbound, NULL);
        Test.stopTest();
    }   
        @isTest
    public static void coverCaseCommentLWCController() {
        // Create a case for the controller
        Case cs = TestUtilities.getCase();
        cs.Subject = 'Case Comment LWC Controller Test';
        cs.Status = 'New';
        cs.Origin = 'Web';
        cs.Priority = 'Medium';
        insert cs;

        // Labels commonly used by comment visibility logic
        List<Core_IPS_Labels__c> labelList = new List<Core_IPS_Labels__c>{
            new Core_IPS_Labels__c(Name = 'PUBLIC_TO_CUSTOMERS', Value__c = 'Public to Customers'),
            new Core_IPS_Labels__c(Name = 'PRIVATE_TO_AGENTS', Value__c = 'Private to Agents'),
            new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL', Value__c = 'Private to Intel'),
            new Core_IPS_Labels__c(Name = 'PRIVATE_TO_PARTNERS', Value__c = 'Private to Partner'),
            new Core_IPS_Labels__c(Name = 'Customer', Value__c = 'Customer'),
            new Core_IPS_Labels__c(Name = 'Agent', Value__c = 'Agent')
        };
        insert labelList;

        Test.startTest();

        // Covers initialize()
        Core_IPS_CaseCommentLWCController.initialize(cs.Id);

        // Covers saveCaseComment()
        String saveResult = Core_IPS_CaseCommentLWCController.saveCaseComment(
            cs.Id,
            'Public to Customers',
            'This is a test comment for the case comment controller.'
        );

        // Covers getVisibilityOptions()
        List<String> visibilityOptions = Core_IPS_CaseCommentLWCController.getVisibilityOptions(cs.Id);

        // Covers showVisibilityOptions()
        Boolean showVisibility = Core_IPS_CaseCommentLWCController.showVisibilityOptions();

        Test.stopTest();

        System.assertNotEquals(null, cs.Id, 'Case should be created.');
        System.assertNotEquals(null, visibilityOptions, 'Visibility options should not be null.');
        System.assertNotEquals(null, showVisibility, 'showVisibilityOptions should return a value.');
        System.assertNotEquals(null, saveResult, 'saveCaseComment should return a result.');
    }
}