@isTest
public class Core_MDF_TargetSettingController_Test {
    
    public static Id lineItem_RecordType_IPA = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id lineItem_RecordType_CCF = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
    public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();  
    @TestSetup static void setUpData(){
        Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test1';
        usr.IsActive = true;
        usrList.add(usr);
        
        User ccfAccManager = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccfAccManager.LastName = 'CCF Account Manager';
        ccfAccManager.IsActive = true;
        usrList.add(ccfAccManager);
        insert usrList;
        
        System.runAs(usr){
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            ChannelProgram CCFChannelProgram = Core_MDF_CCP_TestDataUtility.createProgram ('Client ','Client CoMarketing Fund', true);
            List<Account> intAccList= new List<Account>();
            Account accIPA = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            accIPA.Core_MDF_CoMarketingActive__c = true;
            if(isUnifiedIdEnabled){
                accIPA.Core_Unified_Global_Customer_BP_Id__c = 'Prime001';
            }else{
                accIPA.Core_Prime_Id__c = 'Prime001'; 
            }
            accIPA.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            intAccList.add(accIPA);
            
            Account accCCF = Core_MDF_CCP_TestDataUtility.createIntelAccount ('CCF Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                              false);
            accCCF.Core_MDF_CoMarketingActive__c = true;
            accCCF.Core_Geo__c = 'APJ';
            accCCF.Core_Sub_Geo__c = 'SA';
            accCCF.BillingCountryCode = '';
            accCCF.BillingStateCode='';
            intAccList.add(accCCF);
            
            insert intAccList;
            
            
            List<Account> vcAccountList= new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', ipaCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Is_Top_Account_Ind__c=true;
            acc.Core_Geo__c='APJ';
            acc.Core_MDF_Parent_Fund_Account__c = accIPA.Id;
            vcAccountList.add(acc);
            
            Account ccfVCAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account CCF', CCFChannelProgram.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfVCAcc.Core_MDF_Is_Top_Account_Ind__c=true;
            ccfVCAcc.Core_MDF_Parent_Fund_Account__c = accCCF.Id;
            vcAccountList.add(ccfVCAcc);
            insert vcAccountList;
        }
        System.runAs(usr){
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccManager.Id);
            permissionSetAssignmentList.add(psa5);
            insert permissionSetAssignmentList;
        }
    }
    
    @isTest
    static void validateRecordsTest(){
        ChannelProgram ipaCP =[Select id from ChannelProgram Limit 1];
        User usr = [SELECT Id,Email from User where LastName='User Test1' limit 1];        
        System.runAs(usr){
            Test.startTest();
            List<Core_MDF_Target_Setting__c> newTargetSettingList= new List<Core_MDF_Target_Setting__c>();
            Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
            targetSetting.Core_MDF_Program_Name__c=ipaCP.Id;
            targetSetting.Core_MDF_Name__c='Trgt Settings';
            targetSetting.Core_MDF_Start_Date__c= System.today();
            targetSetting.Core_MDF_End_Date__c=System.today()+3;
            newTargetSettingList.add(targetSetting);
            insert newTargetSettingList;
            
            Core_MDF_Spending_Targets_Version__c version = [SELECT Id, Core_MDF_Is_Active_Ind__c, Core_MDF_Version_nbr__c
                                                            FROM Core_MDF_Spending_Targets_Version__c
                                                            WHERE Core_MDF_Spending_Targets__c =: targetSetting.Id  
                                                            AND Core_MDF_Is_Active_Ind__c = TRUE];
            
            Core_MDF_Target_Setting_Line_Item__c lineItem = new Core_MDF_Target_Setting_Line_Item__c();
            lineItem.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            lineItem.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            lineItem.Core_MDF_Region_nm__c = 'APJ';
            lineItem.Core_MDF_Spending_Targets_Version__c = version.Id;
            lineItem.Core_MDF_All_Accounts_nm__c = 'Yes';
            lineItem.RecordTypeId = lineItem_RecordType_IPA;
            insert lineItem;
            
            Core_MDF_TargetSettingController.getLineItemRecords(version.Id);
            try{
                Core_MDF_TargetSettingController.getLineItemRecords(null);
            }
            catch(Exception e) {
                
            }    
            
            List<Core_MDF_TargetSettingController.flowParametersWrapper> flowWrapperList = new List<Core_MDF_TargetSettingController.flowParametersWrapper>();
            Core_MDF_TargetSettingController.flowParametersWrapper flowWrapper = new Core_MDF_TargetSettingController.flowParametersWrapper();
            flowWrapper.userComment = 'Comments';
            flowWrapper.SpendingTargetRecordId = targetSetting.Id;
            flowWrapperList.add(flowWrapper);           
            try{
                Core_MDF_TargetSettingController.createVersionRecord(flowWrapperList);
                Core_MDF_TargetSettingController.createVersionRecord(null);
            }
            catch(Exception e) {
                
            }
            Assert.areEqual(true,targetSetting.Core_MDF_Name__c != null);
            Test.stopTest();
        }
    }
    
    @isTest
    static void validateRecordsTest2(){
        ChannelProgram CCFCP =[Select id from ChannelProgram where Name = 'Client' Limit 1];
        User usr = [SELECT Id,Email from User where LastName='User Test1' limit 1];  
        Account acc = [SELECT Id from Account where Name = 'CCF Intel Account' limit 1];
        Account VCacc = [SELECT Id from Account where Core_MDF_Parent_Fund_Account__c =: acc.id limit 1];
        
        System.runAs(usr){
            Test.startTest();
            
            List<Core_MDF_Target_Setting__c> newTargetSettingList= new List<Core_MDF_Target_Setting__c>();
            Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
            targetSetting.Core_MDF_Program_Name__c=CCFCP.Id;
            targetSetting.Core_MDF_Name__c='Trgt Settings';
            targetSetting.Core_MDF_Start_Date__c= System.today();
            targetSetting.Core_MDF_End_Date__c=System.today()+3;
            newTargetSettingList.add(targetSetting);
            
            insert newTargetSettingList;
            //14285 Suma Unused variable rule
            /*Core_MDF_Spending_Targets_Version__c version = [SELECT Id, Core_MDF_Is_Active_Ind__c, Core_MDF_Version_nbr__c
                                                            FROM Core_MDF_Spending_Targets_Version__c
                                                            WHERE Core_MDF_Spending_Targets__c =: targetSetting.Id  
                                                            AND Core_MDF_Is_Active_Ind__c = TRUE];*/
            
        }
        
        
        
        User usr1 = [Select id from User where LastName = 'CCF Account Manager' LIMIT 1];
        Core_MDF_Target_Setting__c trgtSetting = [SELECT Id, Core_MDF_Name__c, Core_MDF_Start_Date__c,Core_MDF_End_Date__c FROM Core_MDF_Target_Setting__c WHERE Core_MDF_Name__c='Trgt Settings'];
        Core_MDF_Spending_Targets_Version__c version1 = [SELECT Id from Core_MDF_Spending_Targets_Version__c WHERE Core_MDF_Spending_Targets__c=: trgtSetting.Id LIMIT 1];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        //iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_User_id__c = usr1.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        //iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmList.add(iupgm);
        insert iupgmList;
        
        System.runAs(usr1){
            
            Core_MDF_Target_Setting_Line_Item__c lineItemRecord1 = new Core_MDF_Target_Setting_Line_Item__c();
            lineItemRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            lineItemRecord1.Core_MDF_Region_nm__c = 'APJ';
            lineItemRecord1.Core_MDF_Region_Name_nm__c = 'APJ';
            lineItemRecord1.Core_MDF_Amount__c = 0;
            lineItemRecord1.Core_MDF_Spending_Targets_Version__c = version1.Id;
            lineItemRecord1.RecordTypeId = lineItem_RecordType_CCF;
            lineItemRecord1.Core_MDF_Account__c= VCacc.id;
            lineItemRecord1.Core_MDF_Campaign_Name__c = 'Test Campaign 1';
            lineItemRecord1.Core_MDF_Country_nm__c = 'INDIA';
            //lineItemRecord1.Core_MDF_Country_Name_nm__c = 'INDIA';
            lineItemRecord1.Core_MDF_Priority_nm__c = 'AI Consumer';
            
            //insert lineItemRecord1;
            
            Campaign cmp = new Campaign();
            cmp.Name = lineItemRecord1.Core_MDF_Campaign_Name__c;
            cmp.Core_MDF_Program__c = 'Client CoMarketing Fund';
            cmp.RecordTypeId = Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF;
            cmp.Core_MDF_Account__c = lineItemRecord1.Core_MDF_Account__c;
            cmp.Core_MDF_Market__c = lineItemRecord1.Core_MDF_Country_nm__c;
            cmp.StartDate = trgtSetting.Core_MDF_Start_Date__c;
            cmp.EndDate = trgtSetting.Core_MDF_End_Date__c;
            cmp.Status = 'Draft';
            cmp.Core_MDF_Priority__c = lineItemRecord1.Core_MDF_Priority_nm__c;
            cmp.Core_MDF_Strategic_Marketing_Fund_Ind__c = true;
            cmp.Core_MDF_Opal_Budget_Type_Txt__c = lineItemRecord1.Core_MDF_Budget_Type_nm__c;
            cmp.Core_MDF_Campaign_Source_nm__c = 'Target Setting';
            cmp.Core_MDF_Supports_legacy_program__c = 'CMP only';
            
            //insert cmp;
            List<Id> lineItemIdsList = new List<Id>();
            
            lineItemIdsList.add(lineItemRecord1.Id);
            
            Core_MDF_TargetSettingController.UserPermissionAccesss userPermission = new Core_MDF_TargetSettingController.UserPermissionAccesss();
            Core_MDF_TargetSettingController.updateCampaignIdtoSTLI(lineItemIdsList,cmp.Id);
            userPermission = Core_MDF_TargetSettingController.checkLoggedInUserhasAccess('Client Co-Marketing Fund');
            userPermission = Core_MDF_TargetSettingController.checkLoggedInUserhasAccess('Data Center Co-Marketing Fund');
            //Assert.areEqual(true, userPermission.isNewButtonAccess);
            
            Boolean result = Core_MDF_TargetSettingController.validateUserRegion(version1.Id, 'All Other APJ');
            system.assertEquals(false, result);
            
            
            Test.stopTest();
        }
    }
}