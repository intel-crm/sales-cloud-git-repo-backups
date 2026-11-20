/***************************************************************************************************
* Apex Class Name: Core_IPS_File_Utility_Test 
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Function    : IPS SCFT/SFT File Downloads -> Test Class
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     10/24/2015              Created
****************************************************************************************************/
@isTest public class Core_IPS_File_Utility_Test { 
    User SystUserRunAs;
    User CCPUser;
    User BypassSysAdminUser;
    User FAEUser;
    Id RoleId;
    Id CaseId;
    /***************************************************************************************************
* Method Name:  AllFilesUtilityListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  Un-restricted File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/     
    //Un-restricted file list test
    private static testMethod void AllFilesUtilityListRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.AllFilesUtilityListTest();  
        System.assert(FileUtilityListTest!= null);
    }
    /***************************************************************************************************
* Method Name:  AllFilesUtilityAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  Un-restricted File Authorization access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/     
    //Un-restricted file Auth test
    private static testMethod void AllFilesUtilityAuthRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.AllFilesUtilityAuthTest(); 
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  FAEFilesUtilityListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  FAE File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/         
    //FAE file list test
    private static testMethod void FAEFilesUtilityListRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.FAEFilesUtilityListTest(); 
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  FAEFilesUtilityAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  FAE File Authorization test 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/         
    //FAE file list test
    private static testMethod void FAEFilesUtilityAuthRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.FAEFilesUtilityListTest();
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  CCPFilesUtilityListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  Contact File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/             
    //Contact file list with data test
    private static testMethod void CCPFilesUtilityListRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.CCPFilesUtilityListTest(); 
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  CCPFilesUtilityAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  Contact File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/             
    //Contact file list with data test
    private static testMethod void CCPFilesUtilityAuthRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.CCPFilesUtilityAuthTest();
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  CCPNoFilesUtilityAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 11th Nov 2015
* Description:  Contact File List access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/11/2015              Created
****************************************************************************************************/             
    //Contact file list with data test
    private static testMethod void CCPNoFilesUtilityAuthRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, true, 'Complete', true, false);
        FileUtilityListTest.CCPNoFilesUtilityAuthTest();  
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  CCPExpFilesUtilityListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  Contact Null File List  access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/                 
    //Contact file list with null data -> expired files test
    private static testMethod void CCPExpFilesUtilityListRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, false, 'Complete', false, false);
        FileUtilityListTest.CCPNoFilesUtilityListTest(); 
        System.assert(FileUtilityListTest!= null);
        
    }
    /***************************************************************************************************
* Method Name:  CaseFilesUtilityAllAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 24th Oct 2015
* Description:  Case access by Un-restricted User Profile File Authorization check 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/24/2015              Created
****************************************************************************************************/                     
    //Case Attachment file access test
    private static testMethod void CaseFilesUtilityAllAuthRestTest(){ 
        Core_IPS_File_Utility_Test FileUtilityListTest = new Core_IPS_File_Utility_Test();
        FileUtilityListTest.SetUpRestTestData(10, false, 'Complete', false, true);
        FileUtilityListTest.CaseFilesUtilityAllAuthTest();
        System.assert(FileUtilityListTest!= null);
        
    }
    
    private void AllFilesUtilityListTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, Profile.name, ProfileId From User where Id= :BypassSysAdminUser.Id ];                       
            Results = Core_IPS_File_Utility.GetUserFileIDs(Usr);
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 10);     
    }
    
    private void AllFilesUtilityAuthTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, Profile.name, ProfileId From User where Id= :BypassSysAdminUser.Id ];                       
            Results = Core_IPS_File_Utility.GetAuthUserFileID(Usr, 'Testfl1');
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 1);     
    }
    
    private void FAEFilesUtilityListTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, Profile.name, ProfileId From User where Id= :FAEUser.Id ];                       
            Results = Core_IPS_File_Utility.GetUserFileIDs(Usr);
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 10);     
    }
    
    private void FAEFilesUtilityAuthTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, Profile.name, ProfileId From User where Id= :FAEUser.Id ];                       
            Results = Core_IPS_File_Utility.GetAuthUserFileID(Usr, 'Testfl1');
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 1);     
    }
    
    private void CCPFilesUtilityListTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, UserRoleId, Profile.name, ProfileId, UserType, 
                        ContactId, Contact.AccountId From User where Id= :CCPUser.Id ];                       
            Results = Core_IPS_File_Utility.GetUserFileIDs(Usr);
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 10);     
    }
    
    private void CCPFilesUtilityAuthTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, UserRoleId, Profile.name, ProfileId, UserType, 
                        ContactId, Contact.AccountId From User where Id= :CCPUser.Id ];                       
            Results = Core_IPS_File_Utility.GetAuthUserFileID(Usr, 'Testfl1');
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 1);     
    }
    
    private void CCPNoFilesUtilityAuthTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, UserRoleId, Profile.name, ProfileId, UserType, 
                        ContactId, Contact.AccountId From User where Id= :CCPUser.Id ];                       
            Results = Core_IPS_File_Utility.GetAuthUserFileID(Usr, '55667-7789-2345566');
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 0);     
    }
    
    private void CCPNoFilesUtilityListTest() {
        Set<Id> Results;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id, UserRoleId, Profile.name, ProfileId, UserType, 
                        ContactId, Contact.AccountId From User where Id= :CCPUser.Id ];                       
            Results = Core_IPS_File_Utility.GetUserFileIDs(Usr);
        }
        //Stop Test            
        Test.stopTest();
        System.assert(Results.size() == 0);     
    }
    
    private void CaseFilesUtilityAllAuthTest() {
        Boolean HasAccess;
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            User Usr = [Select Id From User where Id= :BypassSysAdminUser.Id];                       
            HasAccess = Core_IPS_File_Utility.CheckUserRecordAccess(Usr.Id, CaseId);
        }
        //Stop Test            
        Test.stopTest();
        System.assert(HasAccess == true);     
    }
    
    
    private void SetUpRestTestData( Integer FileUplMastSize, Boolean FileAssignCrt, String Status, Boolean Valid, Boolean CaseCrt) {   
        //Asset Record Type
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;  
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name =:System.label.Core_System_Admin_Profile_Name];
        //Get an Existing System Admin User
        List<User> lstSysUsers = [select id, Name, UserRoleId from User where isActive = true and 
                                  ProfileId =:SysAdmPrf.Id and UserRoleId != null and 
                                  id !=:userinfo.getuserid() limit 1];
        if (lstSysUsers != null && lstSysUsers.size()> 0 ) {
            SystUserRunAs = lstSysUsers[0];  
            system.assert(SystUserRunAs.Id != null);
        } else {
            //Create a New Sys User with New Role
            UserRole TestRl = new UserRole(name = 'TEST ROLE');
            Database.insert(TestRl);
            system.assert(TestRl.Id != null);
            RoleId = TestRl.Id; 
            SystUserRunAs = TestUtilities.getUser();
            SystUserRunAs.userroleid = RoleId;
            SystUserRunAs.alias = 'sysrunas'; 
            SystUserRunAs.email = 'testsysusrrunas@intel.com';
            SystUserRunAs.profileid = SysAdmPrf.Id;
            SystUserRunAs.userName = 'testsysusrrunas@intel.com';
            Database.insert(SystUserRunAs); 
            system.assert(SystUserRunAs.Id != null);            
        }
        //BypassUser ->Sys Admin Profile
        BypassSysAdminUser = TestUtilities.getUser();
        BypassSysAdminUser.alias = 'bypass';
        BypassSysAdminUser.email = 'testbypassusr@intel.com';
        BypassSysAdminUser.profileid = SysAdmPrf.Id;
        BypassSysAdminUser.userName = 'testbypassusr@intel.com.crm';        
        Database.insert(BypassSysAdminUser);
        system.assert(BypassSysAdminUser.Id != null);
        //FAE User
        //Get value from Label with possibly multiple values maintained
        //The first value maintained in the label will be used as the FAE Profile
        String sFAEProfileName;
        if (System.label.Core_IPS_FAE_ProfileName != null) {
            String sFAEProfileNames = System.label.Core_IPS_FAE_ProfileName;
            List<String> lstFAEProfileNames =  sFAEProfileNames.split(';');
            if (!lstFAEProfileNames.isEmpty()) {
                sFAEProfileName = lstFAEProfileNames[0]; 
            }
            Profile FAEPrf = [SELECT Id FROM Profile WHERE Name = : sFAEProfileName];
            FAEUser = TestUtilities.getUser();
            FAEUser.alias = 'fae';
            FAEUser.email = 'testfaeusr@intel.com';
            FAEUser.profileid = FAEPrf.Id;
            FAEUser.userName = 'testfaeuser@intel.com.crm';                
            Database.insert(FAEuser);
        }
        system.assert(FAEUser.Id != null);  
        //
        System.runAs(SystUserRunAs) {
            Account Accnt;
            Contact Cont;
            //Custom setting Core_IPS_Labels__c 
            List<Core_IPS_Labels__c> lstCSIPSLabels = new List<Core_IPS_Labels__c>();
            for (Integer i = 0; i < 2; i++) {
                Core_IPS_Labels__c CSIPSLabel = new Core_IPS_Labels__c();
                //Rowcause_Owner
                if (i == 0) {    
                    CSIPSLabel.Name = 'Rowcause_Owner';
                    CSIPSLabel.Value__c = 'Owner';
                    lstCSIPSLabels.add(CSIPSLabel);
                }
                //RowCause_Team
                if (i == 1) {    
                    CSIPSLabel.Name = 'RowCause_Team';
                    CSIPSLabel.Value__c = 'Team';
                    lstCSIPSLabels.add(CSIPSLabel);
                }
            }
            Database.insert(lstCSIPSLabels);            
            //Create Account        
            //Accnt =  TestUtilities.getAccount();
            Accnt = new Account();
            Accnt.Name = 'Test Account';
            Accnt.BillingCountryCode = 'USA';
            Accnt.BillingStateCode = 'AL';
            Accnt.BillingCity = 'Alabama';
            Accnt.BillingStreet = 'street';
            Accnt.Core_IPS_Active__c = true;
            Database.insert(Accnt);
            system.assert(Accnt.Id != null);
            //Create Contact
            Cont = TestUtilities.getContact();
            Cont.AccountId = Accnt.Id;
            Database.insert(Cont);
            system.assert(Cont.Id != null);
            //CCP User
            Profile CCPPrf = [select id from profile where usertype = :System.label.Core_IPS_CustCommPlus_UserType limit 1];
            CCPUser = TestUtilities.getUser();
            CCPUser.alias = 'ccp';
            CCPUser.email = 'testccpusr@intel.com';
            CCPUser.profileid = CCPPrf.Id;
            CCPUser.userName = 'testccpuser@intel.com.crm'; 
            CCPUser.ContactId = Cont.Id;
            Database.insert(CCPuser);
            system.assert(CCPUser.Id != null);
            //Account Team -> for FAE
            AccountTeamMember AccntTMMember;
            AccntTMMember = new AccountTeamMember();
            AccntTMMember.AccountId = Accnt.Id;
            AccntTMMember.UserId = FAEUser.Id;
            AccntTMMember.TeamMemberRole = 'Team Member';
            Database.insert(AccntTMMember); 
            system.assert(AccntTMMember.Id != null);
            //Support Org
            Core_IPS_Product_Organization__c ProdOrg;
            ProdOrg = TestUtilities.getSupportOrg();
            ProdOrg.Core_IPS_Support_Org_Name__c = 'Test Org';
            ProdOrg.Core_Organization_Description__c = 'Test Org Desc';
            Database.insert(ProdOrg);
            system.assert(ProdOrg.Id != null);
            //Product
            Product2 Prod;
            Prod = TestUtilities.getProduct();
            Database.insert(Prod);
            system.assert(Prod.Id != null);
            //Supported Product    
            Core_IPS_Supported_Product__c SuppProd;
            SuppProd = TestUtilities.getSupportedProduct();
            SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
            SuppProd.Core_Product__c = Prod.id;
            SuppProd.Core_Supported_Product_Name__c = Prod.Name;
            Database.insert(SuppProd);
            system.assert(SuppProd.Id != null);
            //Asset
            Asset Asst;
            Asst = TestUtilities.getAsset();
            Asst.Name = Prod.Name; 
            Asst.Product2Id = Prod.Id; 
            Asst.AccountId = Accnt.id; 
            Asst.Core_Supported_Product__c = SuppProd.id;
            Asst.Core_Product_Organization__c = ProdOrg.id;
            Asst.RecordTypeId = strRecordTypeId;
            Database.insert(Asst);
            system.assert(Asst.Id != null);
            //Asset share 
            Assetshare AsstShare = new AssetShare();
            AsstShare.AssetAccessLevel = 'Edit';
            AsstShare.AssetId = Asst.Id; 
            AsstShare.UserOrGroupId = CCPUser.Id;
            AsstShare.RowCause = 'Manual';
            Database.insert(AsstShare);
            system.assert(AsstShare.Id != null);
            //Group
            Group Grp = new Group();
            Grp.Name = 'Test Groupx1';
            Grp.DeveloperName = 'Test_Groupx1';
            Grp.Type = 'Regular';
            database.insert(Grp);
            system.assert(Grp.Id != null);
            //Add CCP to Group
            GroupMember Grpm = new GroupMember(); 
            Grpm.GroupId = Grp.id;
            Grpm.UserOrGroupId = CCPUser.Id;
            database.insert(Grpm);
            system.assert(Grpm.Id != null);
            //File Upload Master
            List<Core_IPS_File_Upload_Master__c> lstFuplm = new List<Core_IPS_File_Upload_Master__c>();
            for (Integer i = 0; i < FileUplMastSize; i++) {
                Core_IPS_File_Upload_Master__c FileUplm;
                FileUplm = TestUtilities.getFileUploadMasterRecord();
                DateTime ExpDate;
                DateTime EffDate;
                EffDate = System.now().AddDays(-120);
                if (Valid) {
                    ExpDate = System.now().AddDays(60);
                } else {
                    ExpDate = System.now().AddDays(-60);
                }
                FileUplm.Core_File_GUID__c =  'Testfl' + i;
                FileUplm.Core_File_Name__c =  'Testfl' + i;
                FileUplm.Core_Upload_Status__c = Status;
                FileUplm.Core_Effective_Date__c = EffDate;
                FileUplm.Core_Expiration_Date__c = ExpDate;
                lstFuplm.add(FileUplm);
            }
            Database.insert(lstFuplm); 
            //File Assignment
            List <Core_IPS_File_Assignment__c> lstFassign = new List<Core_IPS_File_Assignment__c>(); 
            if (FileAssignCrt){
                for (Integer j = 0; j < lstFuplm.size(); j++) {
                    Core_IPS_File_Upload_Master__c FileUplm = lstFuplm[j];
                    Core_IPS_File_Assignment__c FileAssign = new Core_IPS_File_Assignment__c();
                    FileAssign.Core_Supported_Product__c = SuppProd.Id;
                    FileAssign.Core_Account__c = Accnt.Id;
                    FileAssign.Core_IPS_File_Upload_Master__c = FileUplm.Id;
                    lstFassign.add(FileAssign);    
                }
                Database.insert(lstFassign); 
            }
            //Case Create
            if (CaseCrt){
                Case cs;
                cs = TestUtilities.getCase();
                Database.insert(cs);
                system.assert(cs.id != null);
                CaseId = cs.Id;
                // start added by rajeswari for remove nullpoint exception 24 june 22
                Core_Trigger_Executions__c  triggerExecution = new Core_Trigger_Executions__c();
                triggerExecution.Name = 'myIntelIntegration';
                triggerExecution.Core_Active__c = true;
                triggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
                triggerExecution.Core_Description__c = 'To update Case fields.';
                triggerExecution.Core_Object__c = 'Case';
                triggerExecution.Core_Trigger_Events__c = 'before insert';
                insert triggerExecution;
                Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
                settings.Name = 'InsertCaseCommentForAttach';
                settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
                settings.Core_Description__c = 'ABC';
                settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
                settings.Core_Trigger_Events__c = 'After Insert, After update';
                settings.Core_Active__c = True;
                insert settings;
                // Create Ips Labels added by Aayushi for US79852
                List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
                for(Core_IPS_Labels__c IL: IPSLabels){
                    if(IL.name=='ProjectGroupPrefix'){
                        IL.Value__c = 'IPS_Proj_';
                    }
                    if(IL.name=='CoreStatus_SPtoActive_Error'){
                        IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
                    }
                    if(IL.name=='Core_OneProjProdMem_Error'){
                        IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
                    }
                    if(IL.name=='CoreStatus_Draft'){
                        IL.Value__c = 'Draft'; 
                    }
                    if(IL.name=='CoreStatus_Active'){
                        IL.Value__c = 'Active' ;
                    }
                    if(IL.name=='CoreStatus_Inactive'){
                        IL.Value__c = 'Inactive' ;
                    }
                    if(IL.name=='CoreStatus_SP'){
                        IL.Value__c = 'Submitted Pending' ;
                    }
                }
                // Avoid Hardcoding Id Fix  - Shipra
                //Profile dataMigPrf = [select id, name from Profile where name = 'IPS Data Migration' Limit 1];
                
                Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
                labels2.name= 'Data Migration Profile Id';
                //labels2.value__c=dataMigPrf.Id;
                labels2.value__c='00eo0000000f7Gd';
                
                insert labels2; 
                Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
                labels.name= 'COMPLETE';
                labels.value__c='COMPLETE';
                insert labels;
                
                //end  added by rajeswari for remove nullpoint exception 24 june 22  
                
                ///Case Share -> not required for sys
                //Case Attachment 
                Core_IPS_Case_Attachments__c CSAttach = new Core_IPS_Case_Attachments__c();
                CSAttach.Core_File_GUID__c =  'Testcsfl';
                CSAttach.Core_File_Name__c =  'Testcsfl';
                CSAttach.Core_Upload_Status__c =  Status;
                CSAttach.Core_Case__c =  cs.id;
                //Database.insert(CSAttach);
                //system.assert(CSAttach.Id != null);        
            }
            
        }
        
    }     
    
}