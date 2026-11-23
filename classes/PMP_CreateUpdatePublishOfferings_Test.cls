@isTest
public class PMP_CreateUpdatePublishOfferings_Test {

    static testMethod void testMethod1(){
        List<PMP_Partner_Offering__c> offeringsList = new List<PMP_Partner_Offering__c>();
        for(Integer i=0 ;i <20;i++)
        {
            PMP_Partner_Offering__c offRec = new PMP_Partner_Offering__c();
            offRec.Name ='Name'+i;
            offeringsList.add(offRec);
        }
        insert offeringsList;
         Test.startTest();
        PMP_CreateUpdatePublishOfferings batchJob = new PMP_CreateUpdatePublishOfferings(offeringsList);
        Database.executeBatch(batchJob);
		Test.stopTest();  
    }

}