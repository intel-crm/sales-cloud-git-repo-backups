trigger PRM_Bulk_DataLoad_Trigger on PRM_Bulk_Data_Upload__c (before Insert,after insert,after update) {
	system.debug('Bulk DataLoad trigger entry');
    new PRM_Bulk_DataLoad_TriggerHandler().run();
}