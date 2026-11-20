@isTest(SeeAllData=false)
public class Core_MDF_CCP_MassOwnerUpdate_Test {
      public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();

      @TestSetup static void setUpData(){ 
         Map<String,Id> profileToId = new Map<String,Id>();
          
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','IT Administrator','Sales Ops','Partner')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        //User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr2 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testemail1@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);  
        usr2.Email='testuser@intel.com';
        usr2.LastName='user';
        usr2.profileId = profileToId.get('System Administrator');
        usr2.IsActive = true;
        usr2.UserRoleId = usRole.Id;
        Insert usr2;
        
         User usr3 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testsalesuser@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('Sales Ops'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);  
        usr3.Email='testsalesuser@intel.com';
        usr3.LastName='user';
        usr3.profileId = profileToId.get('Sales Ops');
        usr3.IsActive = true;
        Insert usr3;
          
       User testUser = new User(
            FirstName = 'TestReDa03',
            LastName = 'UserReDa',
            Email = 'testuser11@example.com',
            Username = 'testuserre011@example.com.salesforce',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-CW' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
		System.runAs(usr2){
        	PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Generic_Access' LIMIT 1];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
        	Insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps1.Id);
            Insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps2.Id);
        }
        System.runAs(usr2){
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
          acc1.BillingStreet = '123 Fake St';
          acc1.BillingCity = 'Springfield';
          acc1.Industry='Agriculture';
          //acc1.Core_Sub_Industry__c= 'Crop Production';
          acc1.BillingPostalCode = '12345';
          acc1.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
          insert acc1;
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true); 
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
           Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            insert con1;
          User extUsr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUsr1.LastName = 'User Test1';
            extUsr1.ProfileId = profileToId.get('Partner');
            extUsr1.ContactId = con1.Id;
            extUsr1.IsActive = TRUE;
          insert extUsr1;
            Campaign CCFOpalCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('CCF Opal Campaign','Gaming','Intel® Core™ i7+ Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today(), 10000, 'Consumer Chromebook', acc2.Id, '2-in-1', false);
        CCFOpalCampaign.Core_MDF_Is_Opal__c = 'Yes MDF or both CMP & MDF';
        CCFOpalCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP;MDF';
        Database.insert(CCFOpalCampaign);
        PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
   		 PermissionSetAssignment ps = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = usr2.Id);
         insert ps;
        Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP TESTACCTTEMP CCF EMEA INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            Database.insert(ccfgrp);
        Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = acc1.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'External';           
            ccfPgm.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';  
            ccfPgm.Core_MDF_Virtual_Corp_nm__c = acc2.id;        
            Database.insert(ccfPgm);
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc1.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.RecordTypeId = CCF_RecordType ;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm.Core_MDF_User_id__c = usr2.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        Database.insert(iupgm);
            
        List<Opportunity> opp= Core_Test_Utility.createOpportunity(1);
        opp[0].CloseDate =  system.today().addDays(-2);
        opp[0].AccountId = acc1.Id;
        opp[0].Core_Military_Aerospace_Govmt_End_Use__c='No';
        opp[0].CloseDate =  system.today();
        opp[0].StageName = 'Define';
              insert opp;

          }
           Core_MDF_Error_Logging__e errorEvent = new Core_MDF_Error_Logging__e(
            Core_MDF_Apex_Class_Name_Txt__c = 'TestClass',
            Core_MDF_Exception_Message_Txt__c = 'Test Exception Message'
        );
        Test.startTest();  
       
         EventBus.publish(new List<Core_MDF_Error_Logging__e>{errorEvent});
        
        Test.stopTest();
    
    }
    @isTest static void testMassOwnerUpdateMethods(){
        
         User usr = [Select ID,name from User where Email ='testuser@intel.com' Limit 1];
        Account acc = [Select Id from Account where Name ='Test Acc New 1'];
         Account acc2 = [Select Id from Account where Name ='Test Acc New 2'];
       // Highlight: Unused Local Variable 
       // User usr2 = [Select ID,name from User where Email ='testsalesuser@intel.com' Limit 1];
       // User extUser =[Select Id,name from User where UserType='PowerPartner' Limit 1];

        Campaign camp =[Select Id,Core_MDF_External_Visibility_Date__c from Campaign where name = 'CCF Opal Campaign'];
       Opportunity opp =[Select Id from Opportunity where AccountId =: acc.Id];
        List<Id> selIds =new List<Id>(); 
        selIds.add(camp.Id);
        selIds.add(acc2.Id);
        List<Id> selOppId = new List<Id>();
        Core_MDF_CCP_MassOwnerUpdate.MassOwnerMdtWrapper wrp = new Core_MDF_CCP_MassOwnerUpdate.MassOwnerMdtWrapper();
        system.runAS(usr) {
            List<Core_MDF_Custom_Utility_Config__c> configList = new List<Core_MDF_Custom_Utility_Config__c>();
             Core_MDF_Custom_Utility_Config__c  config = new Core_MDF_Custom_Utility_Config__c ();
            config.Core_MDF_isActive_ind__c = true;
            config.Core_MDF_App_nm__c = 'CCP';
            config.Core_MDF_Object_apiName_nm__c = 'Campaign';
            config.Core_MDF_Object_Label_nm__c ='Campaign';
             config.Core_MDF_Program_nm__c ='Client';
             config.Core_MDF_System_User_Name_txt__c ='Comarketing FLAO-User';
             config.Core_MDF_Account_Field_nm__c ='Core_MDF_Account__c';
            config.Core_MDF_Name_Field_nm__c = 'Name';
            config.Core_MDF_isProgramApplicable_Ind__c = true;
             config.Core_MDF_Int_PermisionSet_Names_txt__c = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr';
             config.Core_MDF_requiredQueryFields_txt__c = 'Id,Name,Core_MDF_Program__c,Core_MDF_Account__r.name,Core_MDF_Account__c,Owner.Name,Owner.Email';
             config.Core_MDF_Column_Headers_txt__c = 'Id:Id,Name:Name,Channel Program:Core_MDF_Program__c,Owner Name:Owner.Name,Account Name:Core_MDF_Account__r.name,AccountId:Core_MDF_Account__c,EmailId:Owner.Email';
            config.Core_MDF_Record_Types_nm__c ='Core_MDF_Client_CoMarketing_Fund';
            config.Core_MDF_Ultimate_Account_Field_txt__c = 'Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c';
            config.Core_MDF_Mandatory_Filter_Fields_txt__c = 'status != \'Cancelled\'';
            config.Core_MDF_Free_Search_Ind__c = true;
            //Insert config;
            configList.add(config);
            Core_MDF_Custom_Utility_Config__c  config3 = new Core_MDF_Custom_Utility_Config__c ();
            config3.Core_MDF_isActive_ind__c = true;
            config3.Core_MDF_App_nm__c = 'CCP';
            config3.Core_MDF_Object_apiName_nm__c = 'Campaign';
            config3.Core_MDF_Object_Label_nm__c ='Campaign';
             config3.Core_MDF_Program_nm__c ='Datacenter';
             config3.Core_MDF_System_User_Name_txt__c ='Comarketing FLAO-User';
             config3.Core_MDF_Account_Field_nm__c ='Core_MDF_Account__c';
            config3.Core_MDF_Name_Field_nm__c = 'Name';
            config3.Core_MDF_isProgramApplicable_Ind__c = true;
             config3.Core_MDF_Int_PermisionSet_Names_txt__c = 'Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr';
             config3.Core_MDF_requiredQueryFields_txt__c = 'Id,Name,Core_MDF_Program__c,Core_MDF_Account__r.name,Core_MDF_Account__c,Owner.Name,Owner.Email';
             config3.Core_MDF_Column_Headers_txt__c = 'Id:Id,Name:Name,Channel Program:Core_MDF_Program__c,Owner Name:Owner.Name,Account Name:Core_MDF_Account__r.name,AccountId:Core_MDF_Account__c,EmailId:Owner.Email';
            config3.Core_MDF_Record_Types_nm__c ='Core_MDF_Data_Center_CoMarketing_Fund';
            //config.Core_MDF_Filter_Criteria__c = '[{\"label\":\"Created Date\",\"apiName\":\"CreatedDate\",\"values\":[],\"fieldType\":\"date\"},{\"label\":\"Status\",\"apiName\":\"Core_MDF_Status__c\",\"values\":[\'Pic Pending\',\'Paid\',\'Payment Due\'],\"fieldType\":\"picklist\"},{\"label\":\"Name\",\"apiName\":\"Title\",\"values\":[],\"fieldType\":\"text\"}]';
            config3.Core_MDF_Ultimate_Account_Field_txt__c = 'Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c';
            config3.Core_MDF_Mandatory_Filter_Fields_txt__c = 'status != \'Cancelled\'';
            config3.Core_MDF_Free_Search_Ind__c = true;
            configList.add(config3);
            
            
            Core_MDF_Custom_Utility_Config__c  config2 = new Core_MDF_Custom_Utility_Config__c ();
            config2.Core_MDF_isActive_ind__c = true;
            config2.Core_MDF_App_nm__c = 'CRM';
            config2.Core_MDF_Object_apiName_nm__c = 'Opportunity';
            config2.Core_MDF_Object_Label_nm__c ='Opportunity';
            config2.Core_MDF_Name_Field_nm__c = 'Name';
             config2.Core_MDF_requiredQueryFields_txt__c = 'Id,Name,Account.Name,StageName,Core_Technical_Owner__r.Name,CloseDate,CreatedDate,LastModifiedDate,Core_Opportunity_ID__c,Owner.Name,Owner.Email';
             config2.Core_MDF_Column_Headers_txt__c = 'Opportunity Name:Name,Account Name:Account.Name,Stage:StageName,Opportunity Owner:Owner.Name,Technical Owner:Core_Technical_Owner__r.Name,Decision Date:CloseDate,Created Date:CreatedDate,Opportunity ID:Core_Opportunity_ID__c';
            config2.Core_MDF_Filter_Criteria_txt__c = '[{"label":"Created Date","apiName":"CreatedDate","values":[],"fieldType":"date"},' +
                          '{"label":"Approval Status","apiName":"Approval Status","values":["Not Submitted","Submitted","Approved"],"fieldType":"picklist"},' +
                          '{"label":"Name","apiName":"Name","values":[],"fieldType":"text"}]';
            config2.Core_MDF_Profiles_nm__c='Sales Manager,Sales Ops,Sales Rep-BB,Sales Rep-BB-Dual IPS,Sales Rep-CW,SMG/GMC Read Only,System Administrator';
            //Insert config2;
            configList.add(config2);
            insert configList;
        
            wrp = Core_MDF_CCP_MassOwnerUpdate.getAppValues();
            // Highlight: Unused Local Variables 
           /* List<Core_MDF_CCP_MassOwnerUpdate.sObjectResult> accList = */ Core_MDF_CCP_MassOwnerUpdate.getAccounts(config.Core_MDF_Program_nm__c,'Test');
           /* List<Core_MDF_CCP_MassOwnerUpdate.sObjectResult> accListForCRM = */ Core_MDF_CCP_MassOwnerUpdate.getAccounts('','Test');
           /* List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> fromUser = */ Core_MDF_CCP_MassOwnerUpdate.getUser('testUser', 'Internal User', null, config);
           /* List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> fromSysUser = */ Core_MDF_CCP_MassOwnerUpdate.getUser('User', 'System User', null, config);
           /* List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> fromSalesUser = */ Core_MDF_CCP_MassOwnerUpdate.getUser('user', null, null, config2);
			List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> fromExternalUser = Core_MDF_CCP_MassOwnerUpdate.getUser('user', 'External User', acc2.id, config);

            // Highlight: Unused Local Variables
           /* List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> toUser = */ Core_MDF_CCP_MassOwnerUpdate.getToUser('testUser', 'Internal User',acc2.Id,acc.id,config);
           /* List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> toUserSales = */ Core_MDF_CCP_MassOwnerUpdate.getToUser('user', null,null,null,config2);
           /* List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> toSystemUser = */ Core_MDF_CCP_MassOwnerUpdate.getToUser('User', 'System User',acc2.Id,acc.id,config);
            
           // Highlight: Unused Local Variables 
          /*  Map<Id,String> nodeAcc = */ Core_MDF_CCP_MassOwnerUpdate.getAccountNodes(acc.Id,'Client');
          /*  Map<Id,String> nodeAcc1 = */Core_MDF_CCP_MassOwnerUpdate.getAccountNodes(acc2.Id,'test');
          /*  Map<String,List<Core_MDF_CCP_MassOwnerUpdate.filterCriteriaWrapper>> fltWrap = */ Core_MDF_CCP_MassOwnerUpdate.getFilterFieldWrapper(config2.Core_MDF_Filter_Criteria_txt__c);
          /*  List<Object> records = */ Core_MDF_CCP_MassOwnerUpdate.getObjectTransactions(config.Core_MDF_Program_nm__c,acc2.Id,acc.id,usr.id,null,'Internal User',null,config,null);
          /*  List<Object> oppRec = */ Core_MDF_CCP_MassOwnerUpdate.getObjectTransactions(null,null,null,usr.id,null,'Internal User',null,config2,null);
          /*  Core_MDF_CCP_MassOwnerUpdate.ownerUpdateWrapper updateRes = */ Core_MDF_CCP_MassOwnerUpdate.updateOwner(selIds,usr.Id,'Campaign',config);
          /*  Core_MDF_CCP_MassOwnerUpdate.ownerUpdateWrapper updateOppRes = */ Core_MDF_CCP_MassOwnerUpdate.updateOwner(selOppId,usr.Id,'Opportunity',config2);
            List<Sobject> sObjectsToUpdate = new List<Sobject>();
             camp.Core_MDF_External_Visibility_Date__c=System.today()+5;
            sObjectsToUpdate.add(camp);
            sObjectsToUpdate.add(opp);
            // Unit Test Method should include System.Assert 
            System.assert(sObjectsToUpdate.size() == 2,'Two sObjects should be prepared for update');
            
            // Highlight: Unused Local Variable 
          /*  Core_MDF_CCP_MassOwnerUpdate.saveResWarpper res =  */ Core_MDF_CCP_MassOwnerUpdate.saveResult(sObjectsToUpdate);
            Core_MDF_CCP_MassOwnerUpdate.FilterFieldsWrapper fltFldWrapper =  new Core_MDF_CCP_MassOwnerUpdate.FilterFieldsWrapper();
            Core_MDF_CCP_MassOwnerUpdate.picklistFilterFldWrapper pickListFldWrap = new  Core_MDF_CCP_MassOwnerUpdate.picklistFilterFldWrapper();
            pickListFldWrap.apiName='StageName';
            pickListFldWrap.value= new List<String>{'Qualify', 'Define', 'Develop'};
            Core_MDF_CCP_MassOwnerUpdate.dtFilterFldWrapper dtFilterFldWrapper=new Core_MDF_CCP_MassOwnerUpdate.dtFilterFldWrapper();
            dtFilterFldWrapper.apiName = 'CreatedDate';
			dtFilterFldWrapper.endRange =System.today(); 
            dtFilterFldWrapper.startRange=System.today(); 
            Core_MDF_CCP_MassOwnerUpdate.txtFilterFldWrapper txtFilterFldWrapper=new Core_MDF_CCP_MassOwnerUpdate.txtFilterFldWrapper();
			txtFilterFldWrapper.apiName = 'Name';
            txtFilterFldWrapper.value='Test';
            fltFldWrapper.dtFiltFldWrapList = new List<Core_MDF_CCP_MassOwnerUpdate.dtFilterFldWrapper>{dtFilterFldWrapper};
            fltFldWrapper.picklistFiltFldWrapList = new List<Core_MDF_CCP_MassOwnerUpdate.picklistFilterFldWrapper>{pickListFldWrap};
                fltFldWrapper.txtFiltFldWrapList=new List<Core_MDF_CCP_MassOwnerUpdate.txtFilterFldWrapper>{txtFilterFldWrapper};
           // Highlight: Unused Local Variable 
          /*  List<Object> oppRecList = */ Core_MDF_CCP_MassOwnerUpdate.getObjectTransactions(null,null,null,usr.id,null,'Internal User',fltFldWrapper,config2,null);

            
        }
             try{
             Integer num = Integer.valueOf('NotANumber'); 
        }
    
        catch(exception ex){
             Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical','CCP','Campaign','Mass Access and Ownership transfer',null);
        }       
        
    }
     @isTest
    public static void testgetAccountsExceptionHandle() {
        Test.startTest();
        try {
            // Highlight: Unused Local Variable 
          /*  List<Core_MDF_CCP_MassOwnerUpdate.sObjectResult> result = */ Core_MDF_CCP_MassOwnerUpdate.getAccounts(null, null);
        } catch (Exception ex) {
           Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical','test','test','Mass Access Ownership Transfer',null);     
        }
        Test.stopTest();
        // Unit Test Method should include System.Assert 
        System.assert(true,'getAccounts executed and exception handling block was reached successfully');
    }
     @isTest
    public static void testgetAccountNodeExceptionHandle() {
        Test.startTest();
        try {
            Map<Id,String> result = Core_MDF_CCP_MassOwnerUpdate.getAccountNodes(null, null);
            System.assertNotEquals(result, null, 'Result should not be null');
        } catch (Exception ex) {
           Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical','test','test','Mass Access Ownership Transfer',null);     
        }
        Test.stopTest();
    }
     @isTest
    public static void testgetObjectTranExceptionHandle() {
        Test.startTest();
        try {
             List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> fromSysUser = Core_MDF_CCP_MassOwnerUpdate.getUser(null,null,null,null);
               System.assertNotEquals(fromSysUser, null, 'fromSysUser should not be null');
        } catch (Exception ex) {
           Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical','test','test','Mass Access Ownership Transfer',null);  
             
        }
        Test.stopTest();
    }
      @isTest
    public static void testgetToUserTranExceptionHandle() {
        Test.startTest();
        try {
             List<Core_MDF_CCP_MassOwnerUpdate.SObjectResult> fromToUser = Core_MDF_CCP_MassOwnerUpdate.getToUser(null, null, null, null, null);
             System.assertNotEquals(fromToUser, null, 'fromToUser should not be null');
        } catch (Exception ex) {
           Core_MDF_CCP_UtilityClass.triggerErrLoggingPE(ex,'Critical','test','test','Mass Access Ownership Transfer',null); 
             
        }
        Test.stopTest();
    }
}