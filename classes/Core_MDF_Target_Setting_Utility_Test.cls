@isTest
public class Core_MDF_Target_Setting_Utility_Test {
    public static Id lineItemIPARecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id lineItemCCFRecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    public static Id DCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_Co_Marketing_Fund').getRecordTypeId();
    @TestSetup static void setUpData(){
        // Highlight unused local variable - 14285 - Suma
        // List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test11';
        usr.IsActive = true;
        insert usr;
        
        System.runAs(usr){
            // 14285 Indira - start
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // 14285 Indira - end
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet cmpPLanAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CMP_Plan_Administrator' LIMIT 1];  
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            List<User> userList = new List<User>();
            User ccfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccManager.LastName = 'CCF Account Manager';
            userList.add(ccfAccManager);
            insert userList;
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccManager.Id);
            permissionSetAssignmentList.add(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = cmpPLanAdminPS.Id, AssigneeId = ccfAccManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            insert permissionSetAssignmentList;
            
        }  
        System.runAs(usr){
            Test.startTest(); 
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            
            
            
            List<Account> intelAccList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Geo__c = 'APJ';
            acc1.Core_Sub_Geo__c = 'SA';
            acc1.BillingStateCode = '';
            acc1.BillingCountryCode = '';
            intelAccList.add(acc1);
            insert intelAccList;
            
            List<Account> accList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            acc.Core_MDF_Is_Top_Account_Ind__c = true;
            accList.add(acc);
            
            
            insert accList;
            
            List<Core_MDF_Target_Setting__c> newTargetSettingList= new List<Core_MDF_Target_Setting__c>();
            Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
            targetSetting.Core_MDF_Program_Name__c=cp.Id;
            targetSetting.Core_MDF_Name__c='Trgt Settings';
            targetSetting.Core_MDF_Start_Date__c= System.today()+2;
            targetSetting.Core_MDF_End_Date__c=System.today()+4;            
            newTargetSettingList.add(targetSetting);
            insert newTargetSettingList;
            
            List<Core_MDF_Spending_Targets_Version__c> versionList = new List<Core_MDF_Spending_Targets_Version__c>();
            Core_MDF_Spending_Targets_Version__c version = new 	Core_MDF_Spending_Targets_Version__c();
            version.Core_MDF_Spending_Targets__c = targetSetting.Id;
            version.Core_MDF_Version_nbr__c = 1;
            version.Core_MDF_Is_Active_Ind__c = TRUE;
            versionList.add(version);
            
            insert versionList;
            
            
            
            Test.stopTest(); 
        }
    }
    
    @isTest 
    static void testGetValidateUserRegion(){
        
        User usr = [Select id from User where LastName = 'CCF Account Manager' LIMIT 1];
        Account acc = [Select id from Account where name = 'Test Account 1'];
        Account viracc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Id];
        Core_MDF_Target_Setting__c trgtSetting = [SELECT Id, Core_MDF_Name__c FROM Core_MDF_Target_Setting__c WHERE Core_MDF_Name__c='Trgt Settings'];
        Core_MDF_Spending_Targets_Version__c version1 = [SELECT Id from Core_MDF_Spending_Targets_Version__c WHERE Core_MDF_Spending_Targets__c=: trgtSetting.Id LIMIT 1];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_User_id__c = usr.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        insert iupgmList;
        System.runAs(usr){
            Test.startTest();
            Core_MDF_Target_Setting_Line_Item__c lineItemRecord1 = new Core_MDF_Target_Setting_Line_Item__c();
            lineItemRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            lineItemRecord1.Core_MDF_Region_Name_nm__c = 'APJ';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItemCCFRecTypeId;
            lineItemRecord1.Core_MDF_Country_Name_nm__c = 'INDIA;JAPAN';
            lineItemRecord1.Core_MDF_Account__c= viracc.id;
            
           // insert lineItemRecord1;
            
            Boolean result = Core_MDF_Target_Setting_Utility.getvalidateUserRegion(version1.Id, 'INDIA;JAPAN');
            system.assertEquals(false, result);
            
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testGetValidateUserRegion1(){
        
        User usr = [Select id from User where LastName = 'CCF Account Manager' LIMIT 1];
        Account acc = [Select id from Account where name = 'Test Account 1'];
        Account viracc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Id];
        Core_MDF_Target_Setting__c trgtSetting = [SELECT Id, Core_MDF_Name__c FROM Core_MDF_Target_Setting__c WHERE Core_MDF_Name__c='Trgt Settings'];
        Core_MDF_Spending_Targets_Version__c version1 = [SELECT Id from Core_MDF_Spending_Targets_Version__c WHERE Core_MDF_Spending_Targets__c=: trgtSetting.Id LIMIT 1];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = usr.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        insert iupgmList;
        System.runAs(usr){
            Test.startTest();
            Core_MDF_Target_Setting_Line_Item__c lineItemRecord1 = new Core_MDF_Target_Setting_Line_Item__c();
            lineItemRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            lineItemRecord1.Core_MDF_Region_Name_nm__c = 'EMEA';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItemCCFRecTypeId;
            lineItemRecord1.Core_MDF_Country_Name_nm__c = 'All Other EMEA';
            lineItemRecord1.Core_MDF_Account__c= viracc.id;
            
           // insert lineItemRecord1;
            
            Boolean result = Core_MDF_Target_Setting_Utility.getvalidateUserRegion(version1.Id, 'All Other EMEA');
            system.assertEquals(false, result);
            
            Test.stopTest();
        }
    }
    @isTest 
    static void testGetValidateUserRegion2(){
        
        User usr = [Select id from User where LastName = 'CCF Account Manager' LIMIT 1];
        Account acc = [Select id from Account where name = 'Test Account 1'];
        Account viracc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Id];
        Core_MDF_Target_Setting__c trgtSetting = [SELECT Id, Core_MDF_Name__c FROM Core_MDF_Target_Setting__c WHERE Core_MDF_Name__c='Trgt Settings'];
        Core_MDF_Spending_Targets_Version__c version1 = [SELECT Id from Core_MDF_Spending_Targets_Version__c WHERE Core_MDF_Spending_Targets__c=: trgtSetting.Id LIMIT 1];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO';
        iupgm.Core_MDF_User_id__c = usr.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        insert iupgmList;
        System.runAs(usr){
            Test.startTest();
            Core_MDF_Target_Setting_Line_Item__c lineItemRecord1 = new Core_MDF_Target_Setting_Line_Item__c();
            lineItemRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            lineItemRecord1.Core_MDF_Region_Name_nm__c = 'ASMO';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItemCCFRecTypeId;
            lineItemRecord1.Core_MDF_Country_Name_nm__c = 'All Other ASMO';
            lineItemRecord1.Core_MDF_Account__c= viracc.id;
            
            //insert lineItemRecord1;
            
            Boolean result = Core_MDF_Target_Setting_Utility.getvalidateUserRegion(version1.Id, 'All Other ASMO');
            system.assertEquals(false, result);
            
            Test.stopTest();
        }
    }
    @isTest 
    static void testGetValidateUserRegion3(){
        
        User usr = [Select id from User where LastName = 'CCF Account Manager' LIMIT 1];
        Account acc = [Select id from Account where name = 'Test Account 1'];
        Account viracc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Id];
        Core_MDF_Target_Setting__c trgtSetting = [SELECT Id, Core_MDF_Name__c FROM Core_MDF_Target_Setting__c WHERE Core_MDF_Name__c='Trgt Settings'];
        Core_MDF_Spending_Targets_Version__c version1 = [SELECT Id from Core_MDF_Spending_Targets_Version__c WHERE Core_MDF_Spending_Targets__c=: trgtSetting.Id LIMIT 1];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm.Core_MDF_User_id__c = usr.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        insert iupgmList;
        System.runAs(usr){
            Test.startTest();
            Core_MDF_Target_Setting_Line_Item__c lineItemRecord1 = new Core_MDF_Target_Setting_Line_Item__c();
            lineItemRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            lineItemRecord1.Core_MDF_Region_Name_nm__c = 'APJ';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItemCCFRecTypeId;
            lineItemRecord1.Core_MDF_Country_Name_nm__c = 'All Other APJ';
            lineItemRecord1.Core_MDF_Account__c= viracc.id;
            
          //  insert lineItemRecord1;
            
            Boolean result = Core_MDF_Target_Setting_Utility.getvalidateUserRegion(version1.Id, 'All Other APJ');
            system.assertEquals(false, result);
            
            Test.stopTest();
        }
    }
    
    
}