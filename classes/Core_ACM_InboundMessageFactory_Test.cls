@IsTest
private class Core_ACM_InboundMessageFactory_Test {

    /*
     * ✅ Test: createSuccessMessage
     */
    @IsTest
    static void testCreateSuccessMessage() {

        String responseJson = '{"status":"ok"}';

        Core_Integration_Inbound_Message__c msg =
            Core_ACM_InboundMessageFactory.createSuccessMessage(responseJson);

        System.assertNotEquals(null, msg);
        System.assertEquals(responseJson, msg.Core_Payload__c);
        System.assertEquals(Core_ACM_Constants.STATUS_PENDING, msg.Core_Processing_Status__c);
        System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_BLACKBOX, msg.Core_Message_Type__c);
        System.assertEquals(Core_ACM_Constants.SOURCE_ERPM, msg.Core_Source_System__c);
    }

    /*
     * ✅ Test: createFailureMessage
     */
    @IsTest
    static void testCreateFailureMessage() {

        String responseJson = '{"error":"failed"}';

        Core_ACM_PayloadWrapper.ResponseWrapper wrapper =
            new Core_ACM_PayloadWrapper.ResponseWrapper();
        wrapper.ErrorCode = '400';
        wrapper.ErrorDetails = 'Bad Request';

        Core_Integration_Inbound_Message__c msg =
            Core_ACM_InboundMessageFactory.createFailureMessage(wrapper, responseJson);

        System.assertNotEquals(null, msg);
        System.assertEquals(responseJson, msg.Core_Payload__c);
        System.assertEquals(Core_ACM_Constants.STATUS_PENDING, msg.Core_Processing_Status__c);
        System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_BLACKBOX, msg.Core_Message_Type__c);
        System.assertEquals(Core_ACM_Constants.SOURCE_ERPM, msg.Core_Source_System__c);
        System.assertEquals('400', msg.Core_Error_Code__c);
        System.assertEquals('Bad Request', msg.Core_Error_Description__c);
    }

    /*
     * ✅ Test: createAGSSuccessMessage
     */
    @IsTest
    static void testCreateAGSSuccessMessage() {

        String responseJson = '{"status":"ags success"}';

        Core_Integration_Inbound_Message__c msg =
            Core_ACM_InboundMessageFactory.createAGSSuccessMessage(responseJson);

        System.assertNotEquals(null, msg);
        System.assertEquals(responseJson, msg.Core_Payload__c);
        System.assertEquals(Core_ACM_Constants.STATUS_PENDING, msg.Core_Processing_Status__c);
        System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_AGS, msg.Core_Message_Type__c);
        System.assertEquals(Core_ACM_Constants.SOURCE_AGS, msg.Core_Source_System__c);
    }

    /*
     * ✅ Test: createAGSFailureMessage
     */
    @IsTest
    static void testCreateAGSFailureMessage() {

        String responseJson = '{"error":"ags failed"}';

        Core_ACM_PayloadWrapper.ResponseWrapper wrapper =
            new Core_ACM_PayloadWrapper.ResponseWrapper();
        wrapper.ErrorCode = '500';
        wrapper.ErrorDetails = 'Internal Server Error';

        Core_Integration_Inbound_Message__c msg =
            Core_ACM_InboundMessageFactory.createAGSFailureMessage(wrapper, responseJson);

        System.assertNotEquals(null, msg);
        System.assertEquals(responseJson, msg.Core_Payload__c);
        System.assertEquals(Core_ACM_Constants.STATUS_PENDING, msg.Core_Processing_Status__c);
        System.assertEquals(Core_ACM_Constants.MESSAGE_TYPE_AGS, msg.Core_Message_Type__c);
        System.assertEquals(Core_ACM_Constants.SOURCE_AGS, msg.Core_Source_System__c);
        System.assertEquals('500', msg.Core_Error_Code__c);
        System.assertEquals('Internal Server Error', msg.Core_Error_Description__c);
    }
}