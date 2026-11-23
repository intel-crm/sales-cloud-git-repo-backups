/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchScheduler_Test
* Version     : 1.0 
* Created Date: 8-Apr-2021
* Modification Log :
* Developer   Vivek                  Date                          Description
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_BatchScheduler_Test {
        
    
    @TestSetup static void setUpData(){ 
               
        Test.startTest();      
        List<ChannelProgram> cpList = new List<ChannelProgram>();           
        ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        cpList.add(ccfCp);
                
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet paymentAdm = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet paymentScheduleAdm = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Payment_Schedule_Admin' LIMIT 1];
        
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'testexmpl1@intel.com';
        usr.IsActive=true;
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.Email='testexmpl2@intel.com';
        usr1.profileId=ccpCoreProfile.Id;
        usr1.UserPermissionsMarketingUser=true;
        usr1.isActive=true;
        usrList.add(usr1);
        
        Database.insert(usrList);
        
        List<PermissionSetAssignment> permSetAssgnmntList = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr1.Id,paymentAdm.Id,false);
        permSetAssgnmntList.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj1 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr1.Id,paymentScheduleAdm.Id,false);
        permSetAssgnmntList.add(assignPermissionSetObj1);
        
        system.runAs(usr){
            Database.insert(permSetAssgnmntList);
        }
        
        system.runAs(usr1){
         
            List<Core_MDF_Payment_Run__c> PayRun = new List<Core_MDF_Payment_Run__c>();
            
            Core_MDF_Payment_Run__c paymentRun1 = new Core_MDF_Payment_Run__c();
            paymentRun1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            paymentRun1.Core_MDF_Geo_Txt__c = 'ASMO';
            paymentRun1.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            paymentRun1.Core_MDF_Status_Txt__c = 'Scheduled';
            //paymentRun1.Core_MDF_Program_Id__c = cpList[0].Id;
            //insert paymentRun1; 
            PayRun.add(paymentRun1);
            
            Core_MDF_Payment_Run__c paymentRun2 = new Core_MDF_Payment_Run__c();
            paymentRun2.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(100);
            paymentRun2.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRun2.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            paymentRun2.Core_MDF_Status_Txt__c = 'Scheduled';
            //paymentRun2.Core_MDF_Program_Id__c = cpList[0].Id;
            //insert paymentRun2;   
            PayRun.add(paymentRun2); 
            Database.insert(PayRun);
                    
            List<Core_MDF_Batch_Scheduler__c> BatchSch = new List<Core_MDF_Batch_Scheduler__c>();
            
            Core_MDF_Batch_PaymentFileGenerator batchClassInstance1 = new Core_MDF_Batch_PaymentFileGenerator(paymentRun1);
            Core_MDF_Batch_Scheduler__c customSch1 = new Core_MDF_Batch_Scheduler__c();
            String serializedInstance1 = JSON.serialize(batchClassInstance1); 
            customSch1.Core_MDF_Object_JSON_Txt__c = serializedInstance1;
            customSch1.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch1.Scheduled_Time_Dt__c = DateTime.Now()+2;
            DateTime dt = DateTime.now();
            customSch1.Core_MDF_Time__c = dt.time();
            customSch1.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance1).split(':')[0];
            //customSch1.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch1.Core_MDF_Job_Frequency__c = 'Once';
            customSch1.Core_MDF_Priority__c = 'High';
            customSch1.Core_MDF_Program_Txt__c = 'CCP';
            //insert(customSch1);
            BatchSch.add(customSch1);
            
            //Database.insert(PayRun);
            
            Core_MDF_Batch_PaymentFileGenerator batchClassInstance2 = new Core_MDF_Batch_PaymentFileGenerator(paymentRun2);
            Core_MDF_Batch_Scheduler__c customSch2 = new Core_MDF_Batch_Scheduler__c();
            String serializedInstance2 = JSON.serialize(batchClassInstance2); 
            customSch2.Core_MDF_Object_JSON_Txt__c = serializedInstance2;
            customSch2.Core_MDF_Batch_Size_Nbr__c = 111;
            customSch2.Core_MDF_Effective_Start_Time_Dt__c = DateTime.Now().addMinutes(100);
            customSch2.Scheduled_Time_Dt__c = DateTime.Now().addMinutes(100);
            customSch2.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance2).split(':')[0];
            //customSch2.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch2.Core_MDF_Job_Frequency__c = 'Days of Week';
            customSch2.Core_MDF_Days_of_Week__c = 'Tuesday';
            customSch2.Core_MDF_Priority__c = 'High';
            customSch2.Core_MDF_Program_Txt__c = 'CCP';
            customSch2.Core_MDF_GMT_Time__c = dt.time();
            BatchSch.add(customSch2);
            
            Core_MDF_Batch_Scheduler__c customSch3 = new Core_MDF_Batch_Scheduler__c();
            customSch3.Core_MDF_Object_JSON_Txt__c = serializedInstance1;
            customSch3.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch3.Core_MDF_Effective_Start_Time_Dt__c = DateTime.Now()+1;
            customSch3.Scheduled_Time_Dt__c = DateTime.Now().addMinutes(100);
            customSch3.Core_MDF_Effective_End_Time_Dt__c = DateTime.Now()+5;
            customSch3.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance1).split(':')[0];
            //customSch3.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch3.Core_MDF_Job_Frequency__c = 'Daily';
            customSch3.Core_MDF_Priority__c = 'High';
            customSch3.Core_MDF_Program_Txt__c = 'CCP';
            customSch3.Core_MDF_GMT_Time__c = dt.time();
            BatchSch.add(customSch3);
            
            
            Core_MDF_Batch_Scheduler__c customSch4 = new Core_MDF_Batch_Scheduler__c();
            customSch4.Core_MDF_Object_JSON_Txt__c = serializedInstance1;
            customSch4.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch4.Core_MDF_Effective_Start_Time_Dt__c = DateTime.Now()+1;
            //customSch4.Scheduled_Time_Dt__c = DateTime.Now().addMinutes(100);
            customSch4.Core_MDF_Effective_End_Time_Dt__c = DateTime.Now()+5;
            customSch4.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance1).split(':')[0];
            //customSch4.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch4.Core_MDF_Job_Frequency__c = 'Every X Hour';
            customSch4.Core_MDF_Priority__c = 'High';
            customSch4.Core_MDF_Program_Txt__c = 'CCP';
            customSch4.Core_MDF_GMT_Time__c = dt.time();
            customSch4.Core_MDF_Every_X_Hour_Nbr__c = '2';
            BatchSch.add(customSch4);
            
            
            Core_MDF_Batch_Scheduler__c customSch5 = new Core_MDF_Batch_Scheduler__c();
            customSch5.Core_MDF_Object_JSON_Txt__c = serializedInstance1;
            customSch5.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch5.Core_MDF_Effective_Start_Time_Dt__c = DateTime.Now()+1;
            customSch5.Scheduled_Time_Dt__c = DateTime.Now().addMinutes(100);
            customSch5.Core_MDF_Effective_End_Time_Dt__c = DateTime.Now()+2;
            customSch5.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance1).split(':')[0];
            //customSch5.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch5.Core_MDF_Job_Frequency__c = 'Every X Minute';
            customSch5.Core_MDF_Priority__c = 'High';
            customSch5.Core_MDF_Program_Txt__c = 'CCP';
            customSch5.Core_MDF_GMT_Time__c = dt.time();
            customSch5.Core_MDF_Every_X_Minute_Nbr__c = '5';
            BatchSch.add(customSch5);
            
            Core_MDF_Batch_Scheduler__c customSch6 = new Core_MDF_Batch_Scheduler__c();
            customSch6.Core_MDF_Object_JSON_Txt__c = '';
            customSch6.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch6.Core_MDF_Effective_Start_Time_Dt__c = DateTime.Now()+1;
            customSch6.Scheduled_Time_Dt__c = DateTime.Now().addMinutes(100);
            customSch6.Core_MDF_Effective_End_Time_Dt__c = DateTime.Now()+5;
            customSch6.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance1).split(':')[0];
            //customSch6.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch6.Core_MDF_Job_Frequency__c = 'Daily';
            customSch6.Core_MDF_Priority__c = 'High';
            customSch6.Core_MDF_Program_Txt__c = 'CCP';
            customSch6.Core_MDF_GMT_Time__c = dt.time();
            BatchSch.add(customSch6);


            Database.insert(BatchSch);
            List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineList = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
            Core_MDF_Batch_Scheduler_Line_Item__c lineItem1 = new Core_MDF_Batch_Scheduler_Line_Item__c();
            lineItem1.Core_MDF_Batch_Scheduler__c = customSch1.Id;
            lineItem1.Core_MDF_Scheduled_Time_Dt__c =customSch1.Scheduled_Time_Dt__c; 
            lineItem1.Core_MDF_Status_Txt__c = 'Scheduled'; 
            schLineList.add(lineItem1);
            Core_MDF_Batch_Scheduler_Line_Item__c lineItem2 = new Core_MDF_Batch_Scheduler_Line_Item__c();
            lineItem2.Core_MDF_Batch_Scheduler__c = customSch3.Id;
            lineItem2.Core_MDF_Scheduled_Time_Dt__c =customSch3.Scheduled_Time_Dt__c; 
            lineItem2.Core_MDF_Status_Txt__c = 'Scheduled'; 
            schLineList.add(lineItem2);
            Database.insert(schLineList);
            
            List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Name = 'CUSTOM_SCHEDULER_JOB_LIMIT_MIN';
            config.Core_MDF_Value__c = '50';
            configList.add(config);
            Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
            config1.Name = 'CUSTOM_SCHEDULER_JOB_LIMIT_MAX';
            config1.Core_MDF_Value__c = '100';
            configList.add(config1);
            Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
            config2.Name = 'CUSTOM_SCHEDULER_BATCH_JOB_NAME';
            config2.Core_MDF_Value__c = 'CustomBatchSchedulerJob-';
            configList.add(config2);
            Core_MDF_Configuration__c config3 = new Core_MDF_Configuration__c();
            config3.Name = 'CUSTOM_SCHEDULER_FREQUENCY_MIN';
            config3.Core_MDF_Value__c = '5';
            configList.add(config3);
            Core_MDF_Configuration__c config4 = new Core_MDF_Configuration__c();
            config4.Name = 'BATCH_SCHEDULER_CANCELLATION_ERROR';
            config4.Core_MDF_Value__c = 'You can only cancel Scheduled jobs';
            configList.add(config4);
            Core_MDF_Configuration__c config5 = new Core_MDF_Configuration__c();
            config5.Name = 'INVALID_BATCH_CLASS_ERROR';
            config5.Core_MDF_Value__c = 'Please provide valid batch class name';
            configList.add(config5);
            Database.insert(configList);
            
        }
        
        
        
       
        
        //PaymentRun_ServiceHandler
        
                                          
        Test.stopTest();
        
    }
    
    @isTest static void scheduleBatchJob(){
        
        Test.startTest();
        
        //Core_MDF_BatchSchedulerUtility.startBatchJob('CCP');                      				                     
        Core_MDF_Custom_BatchJobSch s=new Core_MDF_Custom_BatchJobSch('CCP');
		s.execute(null);
        
        //List<Core_MDF_Batch_Scheduler_Line_Item__c> lst = [select id,Core_MDF_Status_Txt__c from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Status_Txt__c = 'Pending'];
      	//System.assert(lst.size()>0, 'List has rows');
      	
        Test.stopTest();
        // Highlight: Unused Local Variable 
       /* List<Core_MDF_Batch_Scheduler_Line_Item__c> lst2 = */ Core_MDF_BatchSchedulerUtility.updateStatusForCompletedOrFailedJob('CCP');
        try{
            Core_MDF_Custom_BatchJobSch obj =new Core_MDF_Custom_BatchJobSch('');
            
			obj.execute(null);
        }catch (Exception e) {
         // Highlight: Unused Local Variable    
        //	String message = e.getMessage();
            System.assert(e.getMessage().contains('Program cannot be empty'), 'message=' + e.getMessage());
        }        
    }
    @isTest static void restartBatchJob(){
		Test.startTest();
        try{
        	Core_MDF_BatchJobRestart obj = new Core_MDF_BatchJobRestart('CCP');
			obj.execute(null);
        }catch(Exception e){
           // Highlight: Unused Local Variable
          //  String message = e.getMessage();
            System.assert(e.getMessage().contains('Attempt to de-reference a null object'),'message=' + e.getMessage());
            //System.assert(e.getMessage().contains('This is not a valid job to restart.Please check the input parameter'), 'message=' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest static void updateTest(){
        try{
        Core_MDF_Batch_Scheduler_Line_Item__c schline1 = [select Id,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__c from Core_MDF_Batch_Scheduler_Line_Item__c Limit 1 ];
        schline1.Core_MDF_Status_Txt__c = 'Pending';
        update schline1;
        Core_MDF_Batch_Scheduler__c sch1 = [select id from Core_MDF_Batch_Scheduler__c where Core_MDF_Job_Frequency__c = 'Once' limit 1];
        sch1.Core_MDF_Inactive__c = True;
        update sch1;
        }catch(exception e){
           // Highlight: Unused Local Variable
          //  String message = e.getMessage();
            System.assert(e.getMessage().contains(' Batch Schedule cannot be cancelled in current status'), 'message=' + e.getMessage());
        }
        
        
        Core_MDF_Batch_Scheduler__c sch2 = [select id,Core_MDF_Scheduler_Status_Txt__c from Core_MDF_Batch_Scheduler__c where Core_MDF_Job_Frequency__c = 'Daily' limit 1];
        // Highlight: Unused Local Variable
       // Core_MDF_Batch_Scheduler_Line_Item__c schline2 = [select Id,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__c from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Batch_Scheduler__c=:sch2.Id  Limit 1 ];
        sch2.Core_MDF_Inactive__c = True;
        update sch2;
    }
   @isTest Public static void batchNameTest() {
       try{ Core_MDF_Batch_Scheduler__c customSch6 = new Core_MDF_Batch_Scheduler__c();
            //customSch6.Core_MDF_Object_JSON_Txt__c = serializedInstance1;
            customSch6.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch6.Core_MDF_Effective_Start_Time_Dt__c = DateTime.Now()+1;
            customSch6.Scheduled_Time_Dt__c = DateTime.Now();
            customSch6.Core_MDF_Effective_End_Time_Dt__c = DateTime.Now()+2;
            customSch6.Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_BatchScheduler_Test';
            //customSch5.Core_MDF_Status_Txt__c = 'Scheduled';
            customSch6.Core_MDF_Job_Frequency__c = 'Every X Minute';
            customSch6.Core_MDF_Priority__c = 'High';
            customSch6.Core_MDF_Program_Txt__c = 'CCP';
           DateTime dt = DateTime.now();
            customSch6.Core_MDF_GMT_Time__c = dt.time();
            customSch6.Core_MDF_Every_X_Minute_Nbr__c = '5';
            insert customSch6;
       }catch(exception e){
           // Highlight: Unused Local Variable
           // String message = e.getMessage();
            System.assert(e.getMessage().contains('Please provide valid batch class name'), 'message=' + e.getMessage());
        }
    }
}