/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PMP_PublishTranslationsToPIMBatchTest {
    
    static testMethod  void testMethod1() {
		List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
        
        PMP_Partner_Offering__c offeringRecTest = new PMP_Partner_Offering__c();
        offeringRecTest.Name = 'Test';
        offeringRecTest.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test';
        offeringRecTest.PMP_Partner_Offering_Dsc__c  = 'Test Desc';
        insert offeringRecTest;
        
        PMP_Partner_Offering__c offeringRec = new PMP_Partner_Offering__c();
        offeringRec.Name = 'Test';
        offeringRec.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test';
        offeringRec.PMP_Partner_Offering_Dsc__c  = 'Test Desc';
        offeringRec.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offeringRec.PMP_Working_Copy_Id__c = offeringRecTest.Id;
        offeringRec.PMP_Partner_Offering_Id__c='NPP15803672747012507';
        insert offeringRec;
        
        Test.startTest();
        PMP_PublishTranslationsToPIMBatch obj = new PMP_PublishTranslationsToPIMBatch();
        	Database.executeBatch(obj);
        Test.stopTest();
    }
}