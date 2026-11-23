@isTest
public class Core_MDF_TrgtSetngLineItemHandler_Test {
    public static Id lineItemIPARecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id lineItemCCFRecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    
    Public Static List<Core_MDF_Target_Setting_Line_Item__c> lineItemList = new List<Core_MDF_Target_Setting_Line_Item__c>();
    @TestSetup static void setUpData(){
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test11';
        usr.IsActive = true;
        usrList.add(usr);
        User ccfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccfAccManager.LastName = 'CCF Account Manager';
        ccfAccManager.IsActive = true;
        usrList.add(ccfAccManager);
        insert usrList;
        System.runAs(usr){
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet cmpPLanAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CMP_Plan_Administrator' LIMIT 1];
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();      
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccManager.Id);
            permissionSetAssignmentList.add(psa1);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = cmpPLanAdminPS.Id, AssigneeId = ccfAccManager.Id);
            permissionSetAssignmentList.add(psa2);
            insert permissionSetAssignmentList;
        }
        System.runAs(usr){
            Test.startTest();
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            
            List<Account> intelAccList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Geo__c = 'APJ';
            acc1.Core_Sub_Geo__c = 'SA';
            acc1.BillingCountryCode = 'JPN';
            intelAccList.add(acc1);
            insert intelAccList;
            
            List<Account> accList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            acc.Core_MDF_Is_Top_Account_Ind__c = true;
            accList.add(acc);
            
            Account iPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,
                                                                                    Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            iPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            iPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            iPACoMarketingAcc.Core_Geo__c = 'APJ';
            iPACoMarketingAcc.Core_Sub_Geo__c = 'SA';
            iPACoMarketingAcc.BillingCountryCode = 'JPN';
            iPACoMarketingAcc.Core_MDF_Is_Top_Account_Ind__c = true;
            accList.add(iPACoMarketingAcc);
            insert accList;
            
            List<Core_MDF_Target_Setting__c> newTargetSettingList= new List<Core_MDF_Target_Setting__c>();
            Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
            targetSetting.Core_MDF_Program_Name__c=cp.Id;
            targetSetting.Core_MDF_Name__c='Trgt Settings';
            targetSetting.Core_MDF_Start_Date__c= System.today()+2;
            targetSetting.Core_MDF_End_Date__c=System.today()+4;            
            newTargetSettingList.add(targetSetting);
            
            Core_MDF_Target_Setting__c targetSettingIPA = new Core_MDF_Target_Setting__c();
            targetSettingIPA.Core_MDF_Program_Name__c=ipaCP.Id;
            targetSettingIPA.Core_MDF_Name__c='IPA Trgt Settings';
            targetSettingIPA.Core_MDF_Start_Date__c= System.today()+2;
            targetSettingIPA.Core_MDF_End_Date__c=System.today()+4;
            newTargetSettingList.add(targetSettingIPA);
            
            insert newTargetSettingList;
            
            List<Core_MDF_Spending_Targets_Version__c> versionList = new List<Core_MDF_Spending_Targets_Version__c>();
            Core_MDF_Spending_Targets_Version__c version = new 	Core_MDF_Spending_Targets_Version__c();
            version.Core_MDF_Spending_Targets__c = targetSetting.Id;
            version.Core_MDF_Version_nbr__c = 1;
            version.Core_MDF_Is_Active_Ind__c = TRUE;
            versionList.add(version);
            
            Core_MDF_Spending_Targets_Version__c versionIPA = new 	Core_MDF_Spending_Targets_Version__c();
            versionIPA.Core_MDF_Spending_Targets__c = targetSettingIPA.Id;
            versionIPA.Core_MDF_Version_nbr__c = 1;
            versionIPA.Core_MDF_Is_Active_Ind__c = TRUE;
            versionList.add(versionIPA);
            insert versionList;
            
            List<Core_MDF_Target_Setting_Line_Item__c> lineItemList = new List<Core_MDF_Target_Setting_Line_Item__c>();
            
            Core_MDF_Target_Setting_Line_Item__c lineItemRecordIPA = new Core_MDF_Target_Setting_Line_Item__c();
            lineItemRecordIPA.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            lineItemRecordIPA.Core_MDF_Region_nm__c = 'APJ';
            lineItemRecordIPA.Core_MDF_Country_Name_nm__c = 'CANADA';
            lineItemRecordIPA.Core_MDF_Amount__c = 0;
            lineItemRecordIPA.Core_MDF_Spending_Targets_Version__c = versionIPA.Id;
            lineItemRecordIPA.RecordTypeId = lineItemIPARecTypeId;
            lineItemRecordIPA.Core_MDF_Account__c= iPACoMarketingAcc.id;
            lineItemList.add(lineItemRecordIPA);
            
            insert lineItemList;
            
            
            Test.stopTest(); 
        } 
    }
    
    
    
    @isTest static void testValidateRegion1(){
        
        User usr = [Select id from User where LastName = 'CCF Account Manager'];
        Account acc = [Select id from Account where name = 'Test Account 1'];
        Account viracc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Id LIMIT 1];
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
            lineItemRecord1.Core_MDF_Region_nm__c = 'ASMO';
            lineItemRecord1.Core_MDF_Country_Name_nm__c = 'CANADA';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItemCCFRecTypeId;
            lineItemRecord1.Core_MDF_Account__c= viracc.id;
            
            insert lineItemRecord1;
            
            lineItemRecord1.Core_MDF_Amount__c = 1;
            lineItemRecord1.Core_MDF_Region_nm__c = 'ASMO';
            update lineItemRecord1;
            
            List<Core_MDF_Target_Setting_Line_Item__c> TSLIList = new List<Core_MDF_Target_Setting_Line_Item__c>([Select Id, Core_MDF_Account__c,Core_MDF_Ultimate_Account_Id__c, Core_MDF_Amount__c,
                                                                                                                  Core_MDF_Region_nm__c,Core_MDF_Host_Region_Txt__c,
                                                                                                                  Core_MDF_ProgramName_Txt__c,Core_MDF_Budget_Type_nm__c  from Core_MDF_Target_Setting_Line_Item__c where Id =: lineItemRecord1.Id]);
            Map<Id,Core_MDF_Target_Setting_Line_Item__c> oldmap = new Map<Id,Core_MDF_Target_Setting_Line_Item__c>();
            Core_MDF_TrgtSetngLineItemServiceHandler.shareRecords(TSLIList, oldmap, true);
            Core_MDF_TrgtSetngLineItemServiceHandler.sumOfAmount(TSLIList, oldmap, true);
            Assert.areEqual(true, TSLIList != null);
            Core_MDF_TrgtSetngLineItemServiceHandler.validateUserRegion(TSLIList, oldmap, true);
            Core_MDF_TrgtSetngLineItemServiceHandler.shareRecords(null, null, null);
            Core_MDF_TrgtSetngLineItemServiceHandler.sumOfAmount(null, null, null);
        }
    }
    @isTest static void testValidateRegion2(){
        
        User usr = [Select id from User where LastName = 'CCF Account Manager'];
        Account acc = [Select id from Account where name = 'Test Account 1'];
        Account viracc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Id LIMIT 1];
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
            lineItemRecord1.Core_MDF_Region_nm__c = 'ASMO';
            lineItemRecord1.Core_MDF_Country_Name_nm__c = 'CANADA';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItemCCFRecTypeId;
            lineItemRecord1.Core_MDF_Account__c= viracc.id;
            
            insert lineItemRecord1;
            
            
            List<Core_MDF_Target_Setting_Line_Item__c> TSLIList = new List<Core_MDF_Target_Setting_Line_Item__c>([Select Id, Core_MDF_Account__c,Core_MDF_Ultimate_Account_Id__c, Core_MDF_Amount__c,
                                                                                                                  Core_MDF_Region_nm__c,Core_MDF_Host_Region_Txt__c,
                                                                                                                  Core_MDF_ProgramName_Txt__c,Core_MDF_Budget_Type_nm__c  from Core_MDF_Target_Setting_Line_Item__c where Id =: lineItemRecord1.Id]);
            Map<Id,Core_MDF_Target_Setting_Line_Item__c> oldmap = new Map<Id,Core_MDF_Target_Setting_Line_Item__c>();
            
            Assert.areEqual(true, TSLIList != null);
            Core_MDF_TrgtSetngLineItemServiceHandler.validateUserRegion(TSLIList, oldmap, true);
            
        }
    }
}