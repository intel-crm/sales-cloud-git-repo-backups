/**********************************************************************************
@Author: Accenture
@Description: Test Class for Core_MDF_BatchSchedularArchival
@CreatedDate: November 15 2021
@Version: <V.1.0>
**********************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_BatchSchedularArchival_Test {
    @TestSetup
    static void testData(){
        Test.startTest();
        List<ChannelProgram> cpList = new List<ChannelProgram>();
        ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        cpList.add(ccfCp);
        
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'testexmpl1@intel.com';
        usr.IsActive=true;
        usrList.add(usr);
        Database.insert(usrList);
        
        List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.Name = 'Core_MDF_CustomBatch_Archival_Limit';
        config.Core_MDF_Value__c = '5000';
        configList.add(config);
        database.insert(configList);
        
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.Email='testexmpl2@intel.com';
        usr1.profileId=ccpCoreProfile.Id;
        usr1.UserPermissionsMarketingUser=true;
        usr1.isActive=true;
        usrList.add(usr1);
        
        system.runAs(usr){
            List<Core_MDF_Payment_Run__c> PayRun = new List<Core_MDF_Payment_Run__c>();
            
            Core_MDF_Payment_Run__c paymentRun1 = new Core_MDF_Payment_Run__c();
            paymentRun1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            paymentRun1.Core_MDF_Geo_Txt__c = 'ASMO';
            //paymentRun1.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            paymentRun1.Core_MDF_Status_Txt__c = 'Scheduled';
            paymentRun1.Core_MDF_Program_Id__c = cpList[0].Id;
            PayRun.add(paymentRun1);
            database.insert(PayRun);
            
            Core_MDF_Batch_PaymentFileGenerator batchClassInstance1 = new Core_MDF_Batch_PaymentFileGenerator(paymentRun1);
        
            Core_MDF_Batch_Scheduler__c customSch1 = new Core_MDF_Batch_Scheduler__c();
            customSch1.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch1.Scheduled_Time_Dt__c = DateTime.Now()+2;
            customSch1.Core_MDF_Job_Frequency__c = 'Once';
            customSch1.Core_MDF_Priority__c = 'High';
            customSch1.Core_MDF_Status_Txt__c='Completed';
            customSch1.Core_MDF_Program_Txt__c = 'CCP';
            customSch1.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance1).split(':')[0];
            
            database.insert(customSch1);
        }
        Test.stopTest();
    }
    @isTest Static Void scheduleBatchArchival(){
        
        Integer archivalLimit = Integer.valueOf(Core_MDF_Configuration__c.getValues('Core_MDF_CustomBatch_Archival_Limit').Core_MDF_Value__c);
        List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineList = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineList1 = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        
        List<Core_MDF_Batch_Scheduler__c>  batchIdsLst = [Select id,Scheduled_Time_Dt__c,Core_MDF_Status_Txt__c,Core_MDF_Priority__c,(SELECT Core_MDF_Batch_Scheduler__c,Core_MDF_Status_Txt__c
                                                                                                                                      FROM Batch_Scheduler_Line_Items__r) FROM Core_MDF_Batch_Scheduler__c WHERE Core_MDF_Program_Txt__c = 'CCP'];
        
        
        for(Core_MDF_Batch_Scheduler_Line_Item__c lineItem : [select id,Core_MDF_Status_Txt__c from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Batch_Scheduler__c=:batchIdsLst[0].id]){
            lineItem.Core_MDF_Status_Txt__c = 'Completed';
            schLineList1.add(lineItem);
        }
        update schLineList1;
        Test.startTest();
        integer totalLineItems=archivalLimit+10;
        for(Integer i=0;i<totalLineItems;i++){
            Core_MDF_Batch_Scheduler_Line_Item__c lineItem1 = new Core_MDF_Batch_Scheduler_Line_Item__c();
            lineItem1.Core_MDF_Batch_Scheduler__c = batchIdsLst[0].Id;
            lineItem1.Core_MDF_Scheduled_Time_Dt__c =batchIdsLst[0].Scheduled_Time_Dt__c; 
            lineItem1.Core_MDF_Status_Txt__c = 'Completed'; 
            schLineList.add(lineItem1);
        }  
        database.insert(schLineList);
        List<Core_MDF_BatchSchedularArchival.BatchSchedularParams> bsParamsList=new List<Core_MDF_BatchSchedularArchival.BatchSchedularParams>();
        List<id> inputBatchSchedulersList=new List<id>();
        Core_MDF_BatchSchedularArchival.BatchSchedularParams batchScheduleParam=new Core_MDF_BatchSchedularArchival.BatchSchedularParams();
       for(Core_MDF_Batch_Scheduler__c bs:batchIdsLst){
           inputBatchSchedulersList.add(bs.id);
       }
        batchScheduleParam.inputBatchSchedulers=inputBatchSchedulersList;
        bsParamsList.add(batchScheduleParam);
        Core_MDF_BatchSchedularArchival.scheduleArchival(bsParamsList);
        
        id schId=batchIdsLst[0].id;
        List<Core_MDF_Batch_Scheduler_Line_Item__c> remainingLineItems=([Select id from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Batch_Scheduler__c=:schId]);
        
        //System.assertEquals(remainingLineItems.size(),archivalLimit);
     
        Test.stopTest();    
    }
    
    @isTest Static Void scheduleBatchArchival1(){
        
        Integer archivalLimit = Integer.valueOf(Core_MDF_Configuration__c.getValues('Core_MDF_CustomBatch_Archival_Limit').Core_MDF_Value__c);
        List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineList = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineList1 = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        
        List<Core_MDF_Batch_Scheduler__c>  batchIdsLst = [Select id,Scheduled_Time_Dt__c,Core_MDF_Status_Txt__c,Core_MDF_Priority__c,(SELECT Core_MDF_Batch_Scheduler__c,Core_MDF_Status_Txt__c
                                                                                                                                      FROM Batch_Scheduler_Line_Items__r) FROM Core_MDF_Batch_Scheduler__c WHERE Core_MDF_Program_Txt__c = 'CCP'];
        
        
        for(Core_MDF_Batch_Scheduler_Line_Item__c lineItem : [select id,Core_MDF_Status_Txt__c from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Batch_Scheduler__c=:batchIdsLst[0].id]){
            lineItem.Core_MDF_Status_Txt__c = 'Completed';
            schLineList1.add(lineItem);
        }
        update schLineList1;
        Test.startTest();
        integer totalLineItems=archivalLimit+5000;
        for(Integer i=0;i<totalLineItems;i++){
            Core_MDF_Batch_Scheduler_Line_Item__c lineItem1 = new Core_MDF_Batch_Scheduler_Line_Item__c();
            lineItem1.Core_MDF_Batch_Scheduler__c = batchIdsLst[0].Id;
            lineItem1.Core_MDF_Scheduled_Time_Dt__c =batchIdsLst[0].Scheduled_Time_Dt__c; 
            lineItem1.Core_MDF_Status_Txt__c = 'Completed'; 
            schLineList.add(lineItem1);
        }  
        database.insert(schLineList);
        List<Core_MDF_BatchSchedularArchival.BatchSchedularParams> bsParamsList=new List<Core_MDF_BatchSchedularArchival.BatchSchedularParams>();
        List<id> inputBatchSchedulersList=new List<id>();
        Core_MDF_BatchSchedularArchival.BatchSchedularParams batchScheduleParam=new Core_MDF_BatchSchedularArchival.BatchSchedularParams();
       for(Core_MDF_Batch_Scheduler__c bs:batchIdsLst){
           inputBatchSchedulersList.add(bs.id);
       }
        batchScheduleParam.inputBatchSchedulers=inputBatchSchedulersList;
        bsParamsList.add(batchScheduleParam);
        Core_MDF_BatchSchedularArchival.scheduleArchival(bsParamsList);
        
        id schId=batchIdsLst[0].id;
        List<Core_MDF_Batch_Scheduler_Line_Item__c> remainingLineItems=([Select id from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Batch_Scheduler__c=:schId]);
        
        System.assertEquals(remainingLineItems.size(),10001);
     
        Test.stopTest();    
    }
}