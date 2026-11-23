/**************************************************************************************************************
Version     	: 1.0 
Created Date	: 08 April 2020
Function    	: Test class for Batch class to delete Integration Inbound Message records
Apex Class Name : Core_Batch_Delete_Int_Inbound_Msgs
Modification Log :
* Developer             		 Date              Description
* ----------------------------------------------------------------------------                 
* Manikanta Polamada             08/04/2020        Initial version
***************************************************************************************************************/

@isTest(SeeAllData=false)
public class Core_Batch_Delete_Int_Inbound_Msgs_Test {
    @testSetup
    static void testDataSetup() {
        List<Core_Integration_Inbound_Message__c> listInboundMsgs = new List<Core_Integration_Inbound_Message__c>();
        
        Datetime dateTimeNow = datetime.now();
        Integer intDaysToSubtract = ((Integer.valueof(system.label.Core_No_of_Days_of_Entries_In_Integration_Inbound_Message)+1)*-1);
		Datetime dateTimeOld = dateTimeNow.addDays(intDaysToSubtract);

        for (Integer i=0;i<200;i++) {
            listInboundMsgs.add(new Core_Integration_Inbound_Message__c());
        }
        
        insert listInboundMsgs;     

        for (Core_Integration_Inbound_Message__c inboundMsg : listInboundMsgs) {
            //system.debug('in Test class | recID '+ inboundMsg.Id);
            Test.setCreatedDate(inboundMsg.Id, dateTimeOld);
        }
        system.debug('after changing the created date'+listInboundMsgs );
    }
    
    @isTest
    static void testBatch() {
        Test.startTest();
        Core_Batch_Delete_Int_Inbound_Msgs batchInboundMSg = new Core_Batch_Delete_Int_Inbound_Msgs();
        Id idBatch = Database.executeBatch(batchInboundMSg);
        system.debug('batch id -->'+ idBatch);
        Test.stopTest();
        system.assertEquals(0, [SELECT count() FROM Core_Integration_Inbound_Message__c], 'deleted successfully');
    }
    
    @isTest
    static void testSchedular(){
        Test.startTest();
        	String jobId = System.schedule('ScheduleApexClassTest', '0 0 0 15 3 ? 2022', new Core_Schedule_Batch_Int_Inbound_Msgs());
        Test.stopTest();
    }

}