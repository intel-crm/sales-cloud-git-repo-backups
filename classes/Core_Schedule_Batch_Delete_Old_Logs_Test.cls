@isTest
public class Core_Schedule_Batch_Delete_Old_Logs_Test {
    static testMethod void testMethod1(){
        List<Core_IPS_BES_Batch_Delete__c> deleteLogList = new List<Core_IPS_BES_Batch_Delete__c>();
        deleteLogList.add(new Core_IPS_BES_Batch_Delete__c(Name = 'BES Error Log', Core_IPS_BES_ObjectName__c = 'Core_IPS_BES_Error_Log__c',
                                                           Core_IPS_BES_No_of_Days__c = 0, Core_IPS_BES_Where_Condition__c = ''));
        deleteLogList.add(new Core_IPS_BES_Batch_Delete__c(Name = 'BES Inbound', Core_IPS_BES_ObjectName__c = 'Core_IPS_BES_Inbound_Message__c',
                                                           Core_IPS_BES_No_of_Days__c = 0, Core_IPS_BES_Where_Condition__c = ''));
        deleteLogList.add(new Core_IPS_BES_Batch_Delete__c(Name = 'BES Outbound', Core_IPS_BES_ObjectName__c = 'Core_IPS_BES_Outbound_Message__c',
                                                           Core_IPS_BES_No_of_Days__c = 0, Core_IPS_BES_Where_Condition__c = ''));
        deleteLogList.add(new Core_IPS_BES_Batch_Delete__c(Name = 'Log Entry', Core_IPS_BES_ObjectName__c = 'Core_Log_Entry__c',
                                                           Core_IPS_BES_No_of_Days__c = 0, Core_IPS_BES_Where_Condition__c = 'Core_Message__c = \'Dynamic Mapping Json\''));
        insert deleteLogList;
        List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
        outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        insert outboundObject;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(outboundObject[0].Id, yesterday);
        outboundObject[0].core_IPS_Outbound_Message_ID__c = '123';
        outboundObject[0].Core_IPS_Case_ID__c = ''; 
       	outboundObject[0].Status__c = 'Apigee Success';
        update outboundObject;
        
        Test.startTest();
        System.schedule('Delete BES Outbound Logs',  '0 05 * * * ?', new Core_Schedule_Batch_Delete_BES_Logs('BES Outbound'));
        System.schedule('Delete BES Outbound Logs1',  '0 05 * * * ?', new Core_Schedule_Batch_Delete_BES_Logs());       
        Core_IPS_BES_Delete_All_Old_Logs_Batch outboundBatch = new Core_IPS_BES_Delete_All_Old_Logs_Batch('BES Outbound',true);
        Database.executeBatch(outboundBatch);
        Core_IPS_BES_Delete_All_Old_Logs_Batch outboundBatch1 = new Core_IPS_BES_Delete_All_Old_Logs_Batch('Log Entry',false);
        Database.executeBatch(outboundBatch1);
        
        Test.stopTest();
        system.assertEquals(outboundObject!=null,true,'Record Created');
    }
    
}