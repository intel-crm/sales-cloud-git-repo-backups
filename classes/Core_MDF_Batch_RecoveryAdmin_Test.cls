@isTest(SeeAllData=false)
public class Core_MDF_Batch_RecoveryAdmin_Test {
    @isTest static void testScheduleRecoveryNotification(){
        Test.startTest();
        Database.executeBatch(new Core_MDF_Batch_RecoveryAdminNotification('Intel Partner Alliance', Core_MDF_CCP_ConstantClass.SCHEDULE_RECOVERY_NOTIFICATION, '2026-06-29'));
        List<Core_MDF_Batch_Scheduler__c> bsList = [SELECT Id FROM Core_MDF_Batch_Scheduler__c WHERE Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_Batch_RecoveryAdminNotification'];
        //assert.isTrue(bsList.size() > 0);
        Test.stopTest();
    }
    
    @isTest static void testSendEmailRecoveryNotification(){
        Test.startTest();
        Database.executeBatch(new Core_MDF_Batch_RecoveryAdminNotification('Intel Partner Alliance', Core_MDF_CCP_ConstantClass.SEND_EMAIL, '2026-06-29'));
        Test.stopTest();
    }
    
    @isTest static void testScheduleApexRecoveryNotification(){
        Test.startTest();
        Core_MDF_Batch_RecoveryAdminNotification sh1 = new Core_MDF_Batch_RecoveryAdminNotification(Core_MDF_CCP_ConstantClass.SCHEDULE_RECOVERY_NOTIFICATION);
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Schedule', sch, sh1); 
        Test.stopTest();
    }
    
    
}