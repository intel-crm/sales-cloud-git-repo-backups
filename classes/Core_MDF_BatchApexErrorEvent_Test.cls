@isTest(SeeAllData=false)
public class Core_MDF_BatchApexErrorEvent_Test {
    @TestSetup static void setUpData() {
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        
        Profile coreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        
        PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];

        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User accMgr =  Core_MDF_CCP_TestDataUtility.createUser(false);
        accMgr.profileId = coreProfile.Id;
        accMgr.LastName = 'IUPGM Test User';
        accMgr.UserRoleId = adminRole.Id;
        userList.add(accMgr);
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        userList.add(usr);
        
        database.insert(userList);
        
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = accMgr.Id);
        permissionSetAssignmentList.add(psa);
        
        database.insert(permissionSetAssignmentList);
        
        system.runAs(usr){
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            
            Core_Trigger_Executions__c accountShareSetting = new Core_Trigger_Executions__c();
            accountShareSetting.Core_Active__c = true;
            accountShareSetting.Core_Class_Name__c = 'Core_MDF_PGM_BatchHelper';
            accountShareSetting.Core_Trigger_Events__c = 'after insert';
            accountShareSetting.Core_Object__c = 'Core_MDF_Partner_Group_Mapping__c';
            accountShareSetting.Name = 'createAccountShareRecords';
            accountShareSetting.Core_Description__c = 'test';
            executionList.add(accountShareSetting);
            
            Database.insert(executionList);
            
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);            

            //Creating Intel Account
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Intel Account', 
                                                                                    Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                    false);
            intelAccount.Core_Account_Type__c = 'Reseller';
            intelAccount.Core_Sales_Groups__c = 'Automotive Sales Group';
            intelAccount.Industry = 'Food & Beverage';
            intelAccount.Core_MDF_Channel_Program__c = ccfCp.Id;
            intelAccount.Core_MDF_CoMarketingActive__c=true;
            Database.insert(intelAccount);
            
            //Creating Co-marketing Account with utility class
            Account intelCCF = Core_MDF_CCP_TestDataUtility.createAccount ('To get Error Account', ccfCp.Id,
                                                                           Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCCF.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelCCF.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            Database.insert(intelCCF);            
            
            Account intelCcfApj = Core_MDF_CCP_TestDataUtility.createAccount ('Second Level Account', ccfCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCcfApj.Core_MDF_Parent_Fund_Account__c = intelCCF.Id;
            intelCcfApj.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            Database.insert(intelCcfApj);
            
            Account intelCcfApjIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Third Level Account', ccfCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelCcfApjIndia.Core_MDF_Parent_Fund_Account__c = intelCcfApj.Id;
            intelCcfApjIndia.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            Database.insert(intelCcfApjIndia);
            
            test.startTest();
            
            try{
                Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                iupgm.Core_MDF_Account_id__c = intelAccount.Id;
                iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
                iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
                iupgm.Core_MDF_User_id__c = accMgr.Id;
                iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
                
                database.insert(iupgm); 
                
                test.stopTest();
            }catch(System.MathException e){}
            Test.getEventBus().deliver();
        }
    }
    
    @isTest
    static void checkLog(){
        
        try{
            test.startTest();
            
            Core_MDF_Batch_Apex_Error_Log__c log = [SELECT Id, Core_MDF_Apex_Class_txt__c, Core_MDF_Counter_nbr__c, Core_MDF_Details_txt__c,
                                                    Core_MDF_Exception_Message_txt__c, Core_MDF_Job_Id__c,Core_MDF_Scope_txt__c, Core_MDF_Status_nm__c,
                                                    Core_MDF_Type_of_exception_txt__c FROM Core_MDF_Batch_Apex_Error_Log__c LIMIT 1];
            
            Core_MDF_SubmitLogForRetry.submitRetry(log.Id);
            test.stopTest();
        }catch(exception e){}
        Test.getEventBus().deliver();
    }
}