/**************************************************************************************************************
Version     	: 1.0 
Created Date	: 21 April 2020
Function    	: Test class for batch class to delete Integration Outbound Message records
Apex Class Name : Core_Batch_Del_Old_Outbnd_Msgs
Modification Log :
* Developer             		 Date              Description
* ----------------------------------------------------------------------------                 
* Manikanta Polamada             21/04/2020        Initial version
***************************************************************************************************************/

@isTest(SeeAllData=false)
public class Core_Batch_Del_Old_Outbnd_Msgs_Test {
	@testSetup
    static void testDataSetup() {
        List<Core_Integration_Outbound_Message__c> listOutboundMsgs = new List<Core_Integration_Outbound_Message__c>();
        
        Datetime dateTimeNow = datetime.now();
        Integer daysToSubtract = ((Integer.valueof(system.label.Core_Batch_Del_Old_Outbnd_Msgs_Days_To_Retain)+1)*-1);
		Datetime dateTimeOld = dateTimeNow.addDays(daysToSubtract);

        for (Integer i=0;i<200;i++) {
            listOutboundMsgs.add(new Core_Integration_Outbound_Message__c(Core_MessageType__c = 'test data'+i));
        }
        
        insert listOutboundMsgs;     

        for (Core_Integration_Outbound_Message__c inboundMsg : listOutboundMsgs) {
            //system.debug('in Test class | recID '+ inboundMsg.Id);
            Test.setCreatedDate(inboundMsg.Id, dateTimeOld);
        }
        system.debug('after changing the created date'+listOutboundMsgs );
    }
    
    @isTest
    static void testBatch() {
        Test.startTest();
        Core_Batch_Del_Old_Outbnd_Msgs batchOutboundMSg = new Core_Batch_Del_Old_Outbnd_Msgs();
        Id idBatch = Database.executeBatch(batchOutboundMSg);
        system.debug('batch id -->'+ idBatch);
        Test.stopTest();
        system.assertEquals(0, [SELECT count() FROM Core_Integration_Outbound_Message__c], 'deleted successfully');
    }
    
    @isTest
    static void testSchedular(){
        Test.startTest();
        	String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new Core_Batch_Del_Old_Outbnd_Msgs_Scheduler());
        Test.stopTest();
        system.assertEquals(true, jobId != null? true : false , 'Scheduled successfully');
        system.debug('batch scheduler  -->'+ jobId != null? true : false);
    }
}