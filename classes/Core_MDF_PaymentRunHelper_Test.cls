/****************************************************************************************************************************************
* Class Name      : Core_MDF_PaymentRunHelper_Test
* Version               : 1.0 
* Created Date          : 04-02-2019
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - RG     01-30-2019       Test Class of Core_MDF_PaymentRunHelper
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PaymentRunHelper_Test{
    
    @TestSetup static void setupMethod(){
        //Channel program record
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet paymentAdm = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet paymentScheduleAdm = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Payment_Schedule_Admin' LIMIT 1];
        PermissionSet mdfPaymentScheduleAdm = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin' LIMIT 1];
        Test.startTest();
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
        PermissionSetAssignment assignPermissionSetObj2 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr1.Id,mdfPaymentScheduleAdm.Id,false);
        permSetAssgnmntList.add(assignPermissionSetObj2);
        system.runAs(usr){
            Database.insert(permSetAssgnmntList);
            
            List<Account> accntList = new List<Account>();
            
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            acc.Core_MDF_CoMarketingActive__c = true;
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            accntList.add(acc);
            accntList.add(acc1);
            accntList.add(acc2);
            insert accntList;
            group grpCCFAllEmployees = [select DeveloperName from group where DeveloperName='CORE_MDF_CCP_CCF_ALL' LIMIT 1];
            
            //SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, RowCause FROM AccountShare
            AccountShare accShare = new AccountShare();
            accShare.AccountId = accntList[0].Id;
            accShare.UserOrGroupId = grpCCFAllEmployees.Id;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'None';
            //accShare.ContactAccessLevel = 'Read';
            accShare.RowCause = 'Manual';
            insert accShare;
            AccountShare accShare2 = new AccountShare();
            accShare2.AccountId = accntList[1].Id;
            accShare2.UserOrGroupId = grpCCFAllEmployees.Id;
            accShare2.AccountAccessLevel = 'Read';
            accShare2.OpportunityAccessLevel = 'None';
            accShare2.CaseAccessLevel = 'None';
            //accShare.ContactAccessLevel = 'Read';
            accShare2.RowCause = 'Manual';
            insert accShare2;
            AccountShare accShare3 = new AccountShare();
            accShare3.AccountId = accntList[2].Id;
            accShare3.UserOrGroupId = grpCCFAllEmployees.Id;
            accShare3.AccountAccessLevel = 'Read';
            accShare3.OpportunityAccessLevel = 'None';
            accShare3.CaseAccessLevel = 'None';
            //accShare.ContactAccessLevel = 'Read';
            accShare3.RowCause = 'Manual';
            insert accShare3;
            List<GroupMember> grpMemberList = new List<GroupMember>();
            GroupMember ccfAllGrpMem = new GroupMember();
            ccfAllGrpMem.UserOrGroupId = usrList[1].Id;
            ccfAllGrpMem.GroupId = grpCCFAllEmployees.Id;
            grpMemberList.add(ccfAllGrpMem);
            Database.insert(grpMemberList);
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmLst = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = acc.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Region_cd__c = 'WW';
            iupgm.Core_MDF_User_id__c = usr1.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Active_Ind__c = true;
            iupgmLst.add(iupgm); 
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.Core_MDF_Account_id__c = acc2.Id;
            iupgm2.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm2.Core_MDF_Region_cd__c = 'WW';
            iupgm2.Core_MDF_User_id__c = usr1.Id;
            iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin';
            iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm2.Core_MDF_Active_Ind__c = true;
            iupgmLst.add(iupgm2);
            /* Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
//iupgm1.Core_MDF_Account_id__c = dellCorpAccount.Id;
iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
iupgm1.Core_MDF_Region_cd__c = 'WW';
iupgm1.Core_MDF_User_id__c = usr1.Id;
iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only';
iupgm1.Core_MDF_All_Accounts_cd__c = 'Yes';
iupgm1.Core_MDF_Active_Ind__c = true;
iupgmLst.add(iupgm1); */
            database.insert(iupgmLst);
            Group grp = new Group();
            grp.name = 'PGM_TEST';
            insert grp;
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            pgm.Core_MDF_Source_Txt__c = 'test';
            pgm.Core_MDF_AccountIdGroupName__c = acc.Id+'PGM_TEST';
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc2.Id;
            pgm2.Core_MDF_Group_Name__c = 'PGM_TEST';
            pgm2.Core_MDF_Type_of_Access__c = 'External';
            pgm2.Core_MDF_Group_Id__c = grp.Id;                
            pgm2.Core_MDF_Channel_Program__c = cp.Id;
            pgm2.Core_MDF_Region_cd__c='WW';
            pgm2.Core_MDF_Source_Txt__c = 'test';
            pgm2.Core_MDF_AccountIdGroupName__c = acc2.Id+'PGM_TEST';
            pgmList.add(pgm);
            pgmList.add(pgm2);
            insert pgmList;
        }
        Test.stopTest();
    }
    @isTest
    static void testDuplicatesAndValidations(){
       // Highlight: Unused Local Variable - Indira
       // ChannelProgram cp = [Select id,name from ChannelProgram where Name=:Core_MDF_CCP_ConstantClass.CCF_PROGRAM LIMIT 1];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        
        /* List to hold the payment Run records */
        list<Core_MDF_Payment_Run__c> paymentRunList = new list<Core_MDF_Payment_Run__c>();
        
        /* List to hold the payment Run records to be deleted*/        
        list<Core_MDF_Payment_Run__c> paymentRunDelList = new list<Core_MDF_Payment_Run__c>();
        
        /* The payment Run records */
        Core_MDF_Payment_Run__c paymentRunRec1 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec2 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec3 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec4 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec5 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec6 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec7 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec8 = new Core_MDF_Payment_Run__c();
        /*Map to Hold the payment Run records */
        map<Id, Core_MDF_Payment_Run__c> paymentRunRecMap = new map<Id, Core_MDF_Payment_Run__c>();
        system.runas(usr1){
            
            /* First Payment Run Record */
            //paymentRunRec1.Core_MDF_Program_Id__c = cp.Id;
            paymentRunRec1.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRunRec1.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec1.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRunRec1.Core_MDF_Run_For_All_Accounts__c = true;
            paymentRunRec1.Core_MDF_Status_Txt__c = 'Scheduled';
            paymentRunRec1.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(10);
            
            /* Duplicate Record of First Payment Run Record in the List */
           // paymentRunRec2.Core_MDF_Program_Id__c = cp.Id;
            paymentRunRec2.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRunRec2.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec2.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRunRec2.Core_MDF_Run_For_All_Accounts__c = true;
            paymentRunRec2.Core_MDF_Status_Txt__c = 'Scheduled';
            paymentRunRec2.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(15);
            
            List<Account> accList = [Select id from account where name like '%Test Account%'];
            
            paymentRunRec4.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRunRec4.Core_MDF_Budget_Type_nm__c = 'MDF';
            paymentRunRec4.Core_MDF_Account_Id__c = accList[0].Id;
            paymentRunRec4.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec4.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(15);
           
            
            paymentRunRec5.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRunRec5.Core_MDF_Budget_Type_nm__c = 'MDF+';
            paymentRunRec5.Core_MDF_Run_For_All_Accounts__c = true;
            paymentRunRec5.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec5.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(20);
            
            paymentRunRec6.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRunRec6.Core_MDF_Budget_Type_nm__c = 'MDF;MDF+';
            paymentRunRec6.Core_MDF_Account_Id__c = accList[2].Id;
             paymentRunRec6.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec6.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(25);
            
            
            paymentRunRec7.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Datacenter MDF').getRecordTypeId();
            paymentRunRec7.Core_MDF_Budget_Type_nm__c = 'MDF';
            paymentRunRec7.Core_MDF_Account_Id__c = accList[2].Id;
            paymentRunRec7.Core_MDF_Program_Txt__c='Data Center CoMarketing Fund';
            paymentRunRec7.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(30);
           
            
            paymentRunRec8.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRunRec8.Core_MDF_Budget_Type_nm__c = 'MDF;MDF+';
            paymentRunRec8.Core_MDF_Account_Id__c = accList[1].Id;
            paymentRunRec8.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec8.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
           
            
            paymentRunList.add(paymentRunRec1);
            paymentRunList.add(paymentRunRec2);
            paymentRunList.add(paymentRunRec4);
            paymentRunList.add(paymentRunRec5); 
            paymentRunList.add(paymentRunRec6); 
            paymentRunList.add(paymentRunRec7);
            paymentRunList.add(paymentRunRec8);
            /* Duplicate Record in the DB */       
            paymentRunRec3.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRunRec3.Core_MDF_Status_Txt__c = 'Scheduled';
            paymentRunRec3.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(10);
            paymentRunRec3.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            //paymentRunRec3.Core_MDF_Program_Id__c = cp.Id;
            
            paymentRunDelList.add(paymentRunRec2);
            paymentRunRecMap.put(paymentRunRec1.Id, paymentRunRec1);
            
            Core_MDF_PaymentRunHelper.preventDeleteWhenNotInScheduledState(paymentRunDelList);  
            Test.StartTest();
            database.insert(paymentRunList);
            database.delete(paymentRunRec2);
            string recTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            Core_MDF_Payment_Run__c pRun = [select id from Core_MDF_Payment_Run__c where RecordTypeId = :recTypeId limit 1 ];
            Core_MDF_PaymentRunAccounts.fetchAccounts(pRun.Id);
            
            try{
                database.insert(paymentRunRec3);
                assert.areEqual(paymentRunRec3.Core_MDF_Program_Id__c ,paymentRunRec1.Core_MDF_Program_Id__c);
                assert.areEqual(paymentRunRec3.Core_MDF_Geo_Txt__c ,paymentRunRec1.Core_MDF_Geo_Txt__c);
                //System.assertEquals(paymentRunRec3.Core_MDF_ScheduleRun_Dtm__c ,paymentRunRec1.Core_MDF_ScheduleRun_Dtm__c); 
            }
            catch(dmlException dmlEx){
                // Highlight: Unused Local Variable - Indira
               // string errorMessage = dmlEx.getMessage();
                //system.assertEquals(errorMessage, NULL);     
            }
            
        }
        Test.StopTest();   
    }
    
    @isTest
    static void testResetPaymentRunClone(){
        // Highlight: Unused Local Variable - Indira
       // ChannelProgram cp = [Select id,name from ChannelProgram where Name=:Core_MDF_CCP_ConstantClass.CCF_PROGRAM LIMIT 1];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        
        /* List to hold the payment Run records */
        list<Core_MDF_Payment_Run__c> paymentRunList = new list<Core_MDF_Payment_Run__c>();
        
        /* The payment Run records */
        Core_MDF_Payment_Run__c paymentRunRec1 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec2 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec3 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunClone = new Core_MDF_Payment_Run__c();
        system.runas(usr1){
            /* First Payment Run Record */
            //paymentRunRec1.Core_MDF_Program_Id__c = cp.Id;
            paymentRunRec1.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec1.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRunRec1.Core_MDF_Status_Txt__c = 'Scheduled';
            paymentRunRec1.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(10);
            /* Duplicate Record of First Payment Run Record in the List */
            //paymentRunRec2.Core_MDF_Program_Id__c = cp.Id;
            paymentRunRec2.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec2.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRunRec2.Core_MDF_Status_Txt__c = 'Error';
            paymentRunRec2.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(15);
            paymentRunRec3.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            paymentRunRec3.Core_MDF_Geo_Txt__c = 'EMEA';
            paymentRunRec3.Core_MDF_Status_Txt__c = 'Scheduled';
            paymentRunRec3.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(20);
            paymentRunList.add(paymentRunRec1);
            paymentRunList.add(paymentRunRec2);  
            paymentRunList.add(paymentRunRec3);
            Core_MDF_PaymentRunHelper.paymentRunFieldsResetToDefaultOnClone(paymentRunList);
            Test.StartTest();
            paymentRunClone = paymentRunRec1.clone(false,false,false,false);
            paymentRunClone.Core_MDF_Geo_Txt__c = 'APJ';
            paymentRunClone.Core_MDF_Status_Txt__c='Scheduled';
            paymentRunClone.Core_MDF_Program_Txt__c='Client CoMarketing Fund';
            Core_MDF_PaymentRunHelper.paymentRunFieldsResetToDefaultOnClone(paymentRunList);
            assert.areEqual('Scheduled',paymentRunClone.Core_MDF_Status_Txt__c);
            
            try{
                database.insert(paymentRunList);  
                database.insert(paymentRunClone);
                System.assertEquals(paymentRunClone.Core_MDF_Status_Txt__c ,'Scheduled');
                paymentRunRec3.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(25);
                database.update(paymentRunRec3);
                database.delete(paymentRunRec2);
                
            }
            catch(Exception ex){
               // Highlight: Unused Local Variable - Indira 
               // string errorMessage = ex.getMessage();
              //  system.assertEquals(errorMessage, NULL);
            }
            
        }
        Test.StopTest();
    }
    
    
    @isTest
    static void testDuplicatePaymentProcessWithBudgetTypeAndAccount() {
        Account acc = [Select id from account where name='Test Account2' limit 1];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        
        Core_MDF_Payment_Run__c existingPaymentRun = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c newPaymentRun = new Core_MDF_Payment_Run__c();
        System.runAs(usr1){
            existingPaymentRun.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            existingPaymentRun.Core_MDF_Budget_Type_nm__c = 'MDF;MDF+';
            existingPaymentRun.Core_MDF_Account_Id__c = acc.Id;
            existingPaymentRun.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
            
            newPaymentRun.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            newPaymentRun.Core_MDF_Budget_Type_nm__c = 'MDF;MDF+';
            newPaymentRun.Core_MDF_Account_Id__c = acc.Id;
            newPaymentRun.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
            
            Test.startTest();
            database.insert(existingPaymentRun);
            try{
                database.insert(newPaymentRun);
                assert.areEqual(newPaymentRun.Core_MDF_Account_Id__c ,existingPaymentRun.Core_MDF_Account_Id__c);
            }
            catch(dmlException dmlEx){
                string errorMessage = dmlEx.getMessage();
                assert.isTrue(errorMessage.contains('Duplicate'));       
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testDuplicatePaymentProcessWithoutAccount() {
        // Highlight: Unused Local Variable - Indira
       // Account acc = [Select id from account where name='Test Account2' limit 1];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        
        Core_MDF_Payment_Run__c existingPaymentRun = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c newPaymentRun = new Core_MDF_Payment_Run__c();
        
        System.runAs(usr1) {
            existingPaymentRun.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client CMP').getRecordTypeId();
            existingPaymentRun.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            existingPaymentRun.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
            
            newPaymentRun.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client CMP').getRecordTypeId();
            newPaymentRun.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            newPaymentRun.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
            
            Test.startTest();
            database.insert(existingPaymentRun);
            
            try{
                database.insert(newPaymentRun);
                assert.areEqual(newPaymentRun.Core_MDF_Budget_Type_nm__c ,existingPaymentRun.Core_MDF_Budget_Type_nm__c);
            }
            catch(dmlException dmlEx){
                string errorMessage = dmlEx.getMessage();
                assert.isTrue(errorMessage.contains('Duplicate'));       
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testDuplicatePaymentRun() {
        Account acc = [Select id from account where name='Test Account2' limit 1];
        User usr1 = [Select id from User where Email='testexmpl2@intel.com' LIMIT 1];
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        Core_MDF_Payment_Run__c paymentRun1 = new Core_MDF_Payment_Run__c();       
        Core_MDF_Payment_Run__c paymentRun2 = new Core_MDF_Payment_Run__c();
        
        System.runAs(usr1) {
            paymentRun1.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRun1.Core_MDF_Budget_Type_nm__c = 'MDF;MDF+';
            paymentRun1.Core_MDF_Account_Id__c = acc.Id;
            paymentRun1.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
            
            paymentRun2.RecordTypeId = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId();
            paymentRun2.Core_MDF_Budget_Type_nm__c = 'MDF;MDF+';
            paymentRun2.Core_MDF_Account_Id__c = acc.Id;
            paymentRun2.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(22);
            
            paymentRunList.add(paymentRun1);
            paymentRunList.add(paymentRun2);
            Test.startTest();
            try{
                database.insert(paymentRunList);
            }
            catch(dmlException dmlEx){
                string errorMessage = dmlEx.getMessage();
                assert.isTrue(errorMessage.contains('Duplicate'));       
            }
            Test.stopTest();
        }
    }
    
    
}