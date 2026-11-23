@isTest
public with sharing class PMP_Batch_Locale_Outbound_Msg_Test {
    
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_Batch_Locale_Outbound_Msg.isWorking();
        System.assertEquals(true, result);
    }
//IPA2.0 - As part of TWC729-7977 commented the entire class 
   /* static TestMethod void ValidateOutboundJSon()
    {
        test.startTest();
        PMP_Partner_Offering__c ppo = new PMP_Partner_Offering__c();
        ppo.Name = 'Test Offering';
        ppo.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo.PMP_Offering_Language_Nm__c = 'English';
        ppo.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        insert ppo;
        
        PMP_Partner_Offering__c ppo1 = new PMP_Partner_Offering__c();
        ppo1.Name = 'Test Offering';
        ppo1.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo1.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo1.PMP_Offering_Language_Nm__c = 'Japanese';
        ppo1.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        insert ppo1;
        
        PMP_Partner_Offering__c ppo2 = new PMP_Partner_Offering__c();
        ppo2.Name = 'Test Offering';
        ppo2.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo2.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo2.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo2.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        ppo2.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        insert ppo2;
        
        PMP_Partner_Offering__c ppo3 = new PMP_Partner_Offering__c();
        ppo3.Name = 'Test Offering';
        ppo3.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo3.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo3.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo3.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo3.PMP_Offering_Language_Nm__c = 'English';
        ppo3.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        insert ppo3;
        
        PMP_Locale_Outbound_Msg_Scheduler lsc = new PMP_Locale_Outbound_Msg_Scheduler();
        String sch = '0  00 1 3 * ?';
        
        system.schedule('Market Place Locale Test', sch, lsc);
        
        PMP_Batch_Locale_Outbound_Msg bc = new PMP_Batch_Locale_Outbound_Msg('3');
		ID batchId = database.executeBatch(bc);
        
        PMP_Batch_Locale_Outbound_Msg bc1 = new PMP_Batch_Locale_Outbound_Msg();
		Id batchId1 = database.executeBatch(bc1);
        // system.debug('###batchId->' + batchId);
        System.assert((batchId!= null) && (batchId1!= null));
        test.stopTest();
        
    }*/
}