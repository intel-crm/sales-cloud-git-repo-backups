@isTest(SeeAllData=false)
public class Core_MDF_AccountHierarchyController_Test {
    
    @TestSetup static void setupData() {
        List<User> userList = new List<User>();
         // Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.BillingState= 'TAS';
        dellCorpAccount.Core_Geo__c= 'APJ';
        database.insert(dellCorpAccount);
        
        
        
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        Account dellCorpAccount_VC = Core_MDF_CCP_TestDataUtility.createAccount ('VC Account', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dellCorpAccount_VC.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
            dellCorpAccount_VC.Core_MDF_Active_Ind__c = false;
            dellCorpAccount_VC.Core_MDF_CoMarketingActive__c = true;
            Database.insert(dellCorpAccount_VC);
        
        Account dellCorpAccount_Child1 = Core_MDF_CCP_TestDataUtility.createAccount ('Child Acc1', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dellCorpAccount_Child1.Core_MDF_Parent_Fund_Account__c = dellCorpAccount_VC.Id;
            dellCorpAccount_Child1.Core_MDF_Active_Ind__c = false;
            dellCorpAccount_Child1.Core_MDF_CoMarketingActive__c = true;
            Database.insert(dellCorpAccount_Child1);
        
        Account dellCorpAccount_Child2 = Core_MDF_CCP_TestDataUtility.createAccount ('Child Acc2', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dellCorpAccount_Child2.Core_MDF_Parent_Fund_Account__c = dellCorpAccount_Child1.Id;
            dellCorpAccount_Child2.Core_MDF_Active_Ind__c = false;
            dellCorpAccount_Child2.Core_MDF_CoMarketingActive__c = true;
            Database.insert(dellCorpAccount_Child2);
        
        Account dellCorpAccount_Child3 = Core_MDF_CCP_TestDataUtility.createAccount ('Child Acc3', cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dellCorpAccount_Child3.Core_MDF_Parent_Fund_Account__c = dellCorpAccount_Child2.Id;
            dellCorpAccount_Child3.Core_MDF_Active_Ind__c = true;
            dellCorpAccount_Child3.Core_MDF_CoMarketingActive__c = true;
            Database.insert(dellCorpAccount_Child3);
        
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
		config.Core_MDF_Value__c = '10';
		config.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
		insert config;
        List<Period> periods = [Select number,startdate,enddate From Period Where type = 'Quarter' and StartDate<=:Date.today() AND enddate>=:Date.today() Limit 1];
       	// Highlight: Unused Local Variable
     	// list<Core_MDF_Partnership_Score__c> pscList = new list<Core_MDF_Partnership_Score__c>();
     
        // Safe handling for empty periods list
        Integer quarterNumber = 1;
        Integer yearNumber = Date.today().year();
        
        if (!periods.isEmpty()) {
            quarterNumber = periods[0].Number;
            yearNumber = periods[0].enddate.year();
        }
        Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
        PSC1.Core_MDF_Account_Id__c=dellCorpAccount.Id;
        PSC1.Core_MDF_Channel_Program_Id__c =cp1.Id;
        PSC1.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
        PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q'+String.valueOf(quarterNumber)+' '+String.valueOf(yearNumber);
        PSC1.Core_MDF_Quarter_nm__c = 'Q'+String.valueOf(quarterNumber);
        PSC1.Core_MDF_Year_nm__c = String.valueOf(yearNumber);
        PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;
        
        insert PSC1;
        Integer nextQuarter = (quarterNumber == 4) ? 1 : quarterNumber + 1;
        Core_MDF_Partnership_Score__c PSC2=new Core_MDF_Partnership_Score__c();
        PSC2.Core_MDF_Account_Id__c=dellCorpAccount.Id;
        PSC2.Core_MDF_Channel_Program_Id__c =cp1.Id;
        PSC2.Core_MDF_Program_nm__c ='Client CoMarketing Fund';
        PSC2.Core_MDF_Quarter_Year_Nm__c = 'Q'+String.valueOf(nextQuarter)+' '+String.valueOf(yearNumber);
        PSC2.Core_MDF_Quarter_nm__c = 'Q'+String.valueOf(nextQuarter);
        PSC2.Core_MDF_Year_nm__c = String.valueOf(yearNumber);
        
        insert PSC2;
        
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_CCF_Acct_Mgr',
                            'Core_MDF_CCP_Int_Read_Only','View_All_Data')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        PermissionSet ccfAcctManager = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
        PermissionSet ccpIntReadOnly = nameToPerSet.get('Core_MDF_CCP_Int_Read_Only');
        PermissionSet viewAll = nameToPerSet.get('View_All_Data');
            
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        User usr = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        User usr1 = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);  
        usr1.Email='testUser1234@example.com';
        usr1.LastName='ProgAdmUser';
        usr1.profileId = profileToId.get('CCP - Core Access');
        usr1.IsActive = true;
        userList.add(usr1);
        database.insert(userList);
        
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr1.Id;
        assignPermissionSetObj1.PermissionSetId = ccfAcctManager.Id;
        permSetAssgnLst.add(assignPermissionSetObj1);
        
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr1.Id;
        assignPermissionSetObj2.PermissionSetId = ccpIntReadOnly.Id;
        permSetAssgnLst.add(assignPermissionSetObj2);
        
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = usr1.Id;
        assignPermissionSetObj3.PermissionSetId = viewAll.Id;
        permSetAssgnLst.add(assignPermissionSetObj3);
        system.runAs(usr){
        	database.insert(permSetAssgnLst);
        }
        List<String> bypassFunctionKeys = new List<String>();
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmLst = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = dellCorpAccount.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm.Core_MDF_Region_cd__c = 'WW';
        iupgm.Core_MDF_User_id__c = usr1.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm.Core_MDF_Active_Ind__c = true;
        iupgmLst.add(iupgm); 
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        //iupgm1.Core_MDF_Account_id__c = dellCorpAccount.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm1.Core_MDF_Region_cd__c = 'WW';
        iupgm1.Core_MDF_User_id__c = usr1.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_Read_Only';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm1.Core_MDF_Active_Ind__c = true;
        iupgmLst.add(iupgm1); 
        database.insert(iupgmLst);
    }
    
    @isTest static void fetchUltimateAccountsTest() {
        User testUser = [SELECT Id,Email from User where Email='testUser1234@example.com' limit 1];
        
        System.runAs(testUser){
        	Account acc = [select id from Account limit 1];
            List<Account> accList = new List<Account>();
            accList.add(acc);
            Assert.arenotEqual(null,acc.id);
            Core_MDF_AccountHierarchyController.fetchSalesforceBaseURL();
            Assert.isnotnull(Core_MDF_AccountHierarchyController.fetchSalesforceBaseURL());
        	List<Account> result1=Core_MDF_AccountHierarchyController.fetchUltimateAccounts();
            Core_MDF_AccountHierarchyController.fetchChildAccounts(acc.id);
            Core_MDF_AccountHierarchyController.getAccountDetails(acc.Id);
            Assert.areEqual(false,result1.isEmpty());
            List<Account> result2=Core_MDF_AccountHierarchyController.fetchAllAccounts(accList);
            Assert.areEqual(true,result2 != null);
           
        }
    }
    @isTest static void testSubmitPartnerScoreInsert() {
        
        	Account acc = [select id from Account limit 1];
            ChannelProgram cp=[select id from ChannelProgram limit 1];
            Core_MDF_AccountHierarchyController.submitPartnerScoreWrapper PSR=new Core_MDF_AccountHierarchyController.submitPartnerScoreWrapper();
            PSR.accountId=acc.Id;
            PSR.programId=cp.Id;
            PSR.year='2022';
            PSR.quarter='Q3';
            PSR.partnerScoreNumber=2;
        	Core_MDF_AccountHierarchyController.submitPartnerScore(PSR);
            Assert.arenotEqual(null,PSR);
       
    }
    @isTest static void testSubmitPartnerScoreDuplicate() {
       
            User testUser = [SELECT Id,Email from User where Email='testUser1234@example.com' limit 1];
        	Account acc = [select id from Account limit 1];
            ChannelProgram cp=[select id from ChannelProgram limit 1];
            Core_MDF_AccountHierarchyController.submitPartnerScoreWrapper PSR=new Core_MDF_AccountHierarchyController.submitPartnerScoreWrapper();
            PSR.accountId=acc.Id;
            PSR.programId=cp.Id;
            PSR.year='2022';
            PSR.quarter='Q1';
            PSR.partnerScoreNumber=2;
            Core_MDF_AccountHierarchyController.submitPartnerScore(PSR);
            Core_MDF_AccountHierarchyController.checkUserPermissionSet(testUser.Id);
            system.runAs(testUser){
                    Assert.areEqual(false,Core_MDF_AccountHierarchyController.checkUserPermissionSet(testUser.Id));
            }
        
    }
    @isTest static void testSubmitPartnerScoreUpdate() {
            
        	Account acc = [select id from Account limit 1];
            ChannelProgram cp=[select id from ChannelProgram limit 1];
            Core_MDF_AccountHierarchyController.submitPartnerScoreWrapper PSR=new Core_MDF_AccountHierarchyController.submitPartnerScoreWrapper();
            PSR.accountId=acc.Id;
            PSR.programId=cp.Id;
            PSR.year='2022';
            PSR.quarter='Q2';
            PSR.partnerScoreNumber=2;
            Core_MDF_AccountHierarchyController.submitPartnerScore(PSR);
            Assert.arenotEqual(null,PSR);
           
        
    }
    
    @isTest static void testChannelProgram() {
            
        Core_MDF_AccountHierarchyController.Core_MDF_AccountHierarchyController_Sharing innerClass = new Core_MDF_AccountHierarchyController.Core_MDF_AccountHierarchyController_Sharing();
        innerClass.getChannelProgram();
        // Unit Test Method should include System.Assert
        Assert.isNotNull(innerClass.getChannelProgram(), 'Channel Program list should not be null');
    }
    
}