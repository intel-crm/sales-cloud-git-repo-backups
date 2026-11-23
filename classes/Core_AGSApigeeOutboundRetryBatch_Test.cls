/******************************************************************************************************************************************
Class Name: Core_AGSApigeeOutboundRetryBatch_Test
Version     : 1.0
Created Date: 15 OCT 2021
Function    : Test class for the class Core_AGSApigeeOutboundRetryBatch

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Sankarshana               10/15/2021              Original version
*****************************************************************************************************************************************/
@isTest
public class Core_AGSApigeeOutboundRetryBatch_Test {
	static testmethod void batchAGSApigeeOutboundRetryTest(){
        List<Core_Integration_Outbound_Message__c> lstOutb = New List<Core_Integration_Outbound_Message__c>();
        Core_Integration_Outbound_Message__c objOutb = new Core_Integration_Outbound_Message__c();
        objOutb.Core_Retry_Number__c = 1;
        objOutb.Core_Status__c = 'Failed';
        objOutb.Core_MessageType__C='AGS Contact Entitlement 2.0';
        lstOutb.add(objOutb);
        insert lstOutb;
        test.startTest();
        Core_AGSApigeeOutboundRetryBatch btch = new Core_AGSApigeeOutboundRetryBatch();
        Database.executeBatch(btch,1);
        //Database.QueryLocator ql = btch.start(null);
        //btch.execute('', lstOutb);
        test.stopTest();
    }
}