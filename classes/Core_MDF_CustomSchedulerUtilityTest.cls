@isTest
public class Core_MDF_CustomSchedulerUtilityTest {
    
    @testSetup static void setup() {
        Map<String,Id> profileToId = new Map<String,Id>();
        
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ( 'Core_MDF_CCP_Internal_APJ_User',
                                                                                 'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                                                                                 'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                                                                                 'View_All_Data','Core_Modify_All_Data',
                                                                                 'Core_MDF_CCP_Internal_CCF_Payment_Adm')]) {
                                                                                     nameToPerSet.put(pSet.Name,pSet);
                                                                                 }
        
        PermissionSet modifyAllDataPS = nameToPerSet.get('Core_Modify_All_Data');
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet paymentAdmRMFPS = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Payment_Adm'); 
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data'); 
        PermissionSet ccpPSadmin = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_Payment_Adm'); 
        
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        list<user> userList = new list<user>();
        User usr = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                            EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                            UserPermissionsMarketingUser = TRUE);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        User usr2 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                             EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                             UserPermissionsMarketingUser = TRUE);  
        usr2.Email='testPayment@example.com';
        usr2.LastName='ProgAdmUser';
        usr2.profileId = profileToId.get('CCP - Core Access');
        usr2.IsActive = true;
        userList.add(usr2);
        database.insert(userList);
        
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr2.Id;
        assignPermissionSetObj.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr2.Id;
        assignPermissionSetObj2.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj2);
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr2.Id;
        assignPermissionSetObj1.PermissionSetId = ccpPSadmin.Id;
        permSetAssgnLst.add(assignPermissionSetObj1);
        
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = usr2.Id;
        assignPermissionSetObj3.PermissionSetId = modifyAllDataPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj3);
        system.runAs(usr){
            insert permSetAssgnLst;
        }
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Core_MDF_Configuration__c setting = new Core_MDF_Configuration__c();
        setting.Name = 'CUSTOM_SCHEDULER_FREQUENCY_MIN';
        setting.Core_MDF_Value__c = '5';
        insert setting;
        
    }
    
    @isTest static void testMethod1() {
        test.startTest();
        List<Core_MDF_Payment_Run__c> paymemtRunList = new List<Core_MDF_Payment_Run__c>();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        System.runAs(payAdmUser){  
            
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            paymemtRunList.add(payRunRecord);
            Database.insert(paymemtRunList);
            System.assertNotEquals(paymemtRunList[0].Id,null);
            
            DateTime newDateTime = system.now().addMinutes(5);
            String timeOfExecution = 0+' '+newDateTime.minute()+' '+newDateTime.hour()+' '+newDateTime.day()+'-'+newDateTime.day()+' '+newDateTime.month()+'  ? '+newDateTime.year();
            Core_MDF_CustomScheduler customSch = new Core_MDF_CustomScheduler();
            string jobId = system.schedule('CustomSchedulerTest', timeOfExecution, customSch);
            Core_MDF_Custom_Scheduler__c cusSchedule = new Core_MDF_Custom_Scheduler__c();
            cusSchedule.Core_MDF_Batch_Class_Name_Txt__c='sampleBatchName';
            cusSchedule.Core_MDF_Batch_Size_Nbr__c = 200;
            /*Core_MDF_Batch_PaymentFileGenerator batchClassInstance = new Core_MDF_Batch_PaymentFileGenerator(paymemtRunList[0]);
String serializedInstance = JSON.serialize(batchClassInstance); */
            cusSchedule.Core_MDF_Object_JSON_Txt__c='testString';
            cusSchedule.Core_MDF_Status__c = 'Pending';
            cusSchedule.Core_MDF_Job_Id_Txt__c= jobId;
            insert cusSchedule;
            DateTime newDateTime1 = system.now().addMinutes(10);
            String timeOfExecution1 = 0+' '+newDateTime.minute()+' '+newDateTime.hour()+' '+newDateTime.day()+'-'+newDateTime.day()+' '+newDateTime.month()+'  ? '+newDateTime.year();
            Core_MDF_CustomScheduler customSch1 = new Core_MDF_CustomScheduler();
            string jobId1 = system.schedule('CustomSchedulerTest1', timeOfExecution1, customSch1);
            test.stopTest();            
            
            list<Core_MDF_Custom_Scheduler__c> scheduleList=[select id,Core_MDF_Job_Id_Txt__c,Core_MDF_Batch_Class_Name_Txt__c,Core_MDF_Status__c,Core_MDF_Batch_Size_Nbr__c from Core_MDF_Custom_Scheduler__c ];
            system.debug(scheduleList.size());
            system.debug(scheduleList);
            for(Core_MDF_Custom_Scheduler__c schedule :scheduleList ){
                
                system.assertEquals('Pending', schedule.Core_MDF_Status__c);
                system.assertNotEquals(null, schedule.Core_MDF_Job_Id_Txt__c);    
            }
            
        }        
    }
    
    @isTest static void testMethod2() {
        test.startTest();
        List<Core_MDF_Payment_Run__c> paymemtRunList = new List<Core_MDF_Payment_Run__c>();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        System.runAs(payAdmUser){  
            
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            paymemtRunList.add(payRunRecord);
            Database.insert(paymemtRunList);
            System.assertNotEquals(paymemtRunList[0].Id,null);
            
            DateTime newDateTime = system.now().addMinutes(5);
            String timeOfExecution = 0+' '+newDateTime.minute()+' '+newDateTime.hour()+' '+newDateTime.day()+'-'+newDateTime.day()+' '+newDateTime.month()+'  ? '+newDateTime.year();
            Core_MDF_CustomScheduler customSch = new Core_MDF_CustomScheduler();            
            string jobId = system.schedule('CustomSchedulerTest', timeOfExecution, customSch);
            test.stopTest();
            Core_MDF_Custom_Scheduler__c scheduleList=[select Id,Core_MDF_Job_Id_Txt__c,Core_MDF_Batch_Class_Name_Txt__c,Core_MDF_Status__c,Core_MDF_Batch_Size_Nbr__c from Core_MDF_Custom_Scheduler__c where Core_MDF_Status__c='Pending' limit 1 ];
            system.debug(scheduleList.Core_MDF_Job_Id_Txt__c);
            Core_MDF_CustomSchedulerUtility.cancelJob(scheduleList.Id);
            list<AsyncApexJob> jobList = [select Id from AsyncApexJob where Status= 'Aborted'];
            system.assertEquals(1, jobList.size());
            
        }
    } 
    @isTest static void testMethod3() {         
        test.startTest();
        System.schedule('Hourly', '0 0 * * * ?', new Core_MDF_CustomSchedulerRestart() );
        test.stopTest();
        List<string> statuslist = new List<String>{'Holding', 'Queued', 'Preparing', 'Processing'};
        List<AsyncApexJob> jobList = [SELECT Id, ApexClass.Name from AsyncApexJob  where ApexClass.Name = 'Core_MDF_CustomScheduler' and status in:statuslist ];
            system.assertEquals(1, jobList.size());
    }
}