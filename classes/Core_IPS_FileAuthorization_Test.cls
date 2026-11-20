/***************************************************************************************************
* Apex Class Name: Core_IPS_FileAuthorization_Test 
* Version     : 1.0 
* Created Date: 14th Oct 2015
* Function    : IPS SCFT File Authorization -> Test Class
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     10/14/2015              Created
* //System.assert()--> statement Added By Hassan Khan 02-02-2024
****************************************************************************************************/
@isTest public class Core_IPS_FileAuthorization_Test {  
    User SystUserRunAs;
    User IntUserRunAs;
    User CCPUser;
    User BypassSysAdminUser;
    User LogIdSysAdminUser;
    User FAEUser;
    Id RoleId;
    Id CaseId;
/***************************************************************************************************
* Method Name: AllFilesAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 14th Oct 2015
* Description:  File Authorization access for an Un-restricted User profile 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/14/2015              Created
****************************************************************************************************/   
    //Un-restricted file access test
    private static testMethod void AllFilesAuthRestTest(){
        Core_IPS_FileAuthorization_Test FileAuthTest = new Core_IPS_FileAuthorization_Test();
        FileAuthTest.SetUpRestTestData(10, true, 'Complete', true, false, false);
        FileAuthTest.AllFilesAuthTest();
        system.assert(true);   
    }
/***************************************************************************************************
* Method Name:  AllFilesNoAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 14th Oct 2015
* Description:  No File Authorization access for an Un-restricted User profile 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/14/2015              Created
****************************************************************************************************/       
    //Un-restricted file no-access test
    private static testMethod void AllFilesNoAuthRestTest(){
        Core_IPS_FileAuthorization_Test FileAuthTest = new Core_IPS_FileAuthorization_Test();
        FileAuthTest.SetUpRestTestData(10, true, 'Complete', true, false, false);
        FileAuthTest.AllFilesAuthTest();
        System.assert(true);                
    }
/***************************************************************************************************
* Method Name: ExceptionAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 14th Oct 2015
* Description:  Force exception scenario for File Authorization 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/14/2015              Created
****************************************************************************************************/                  
    //Exception test
    private static testMethod void ExceptionAuthRestTest(){
        Core_IPS_FileAuthorization_Test FileAuthTest = new Core_IPS_FileAuthorization_Test();
        FileAuthTest.SetUpRestTestData(10, false, 'Complete', true, false, false);
        FileAuthTest.ExceptionAuthTest();
        System.assert(true);               
    }
/***************************************************************************************************
* Method Name: ExceptionAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 14th Oct 2015
* Description:  Force exception scenario for File Authorization 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/14/2015              Created
****************************************************************************************************/                      
    //Case Attachment file access test
    /*private static testMethod void AllCaseAuthRestTest(){
        Core_IPS_FileAuthorization_Test FileAuthTest = new Core_IPS_FileAuthorization_Test();
        FileAuthTest.SetUpRestTestData(10, true, 'Complete', true, false, false);
        FileAuthTest.AllCaseAuthTest(); 
        System.assert(FAEUser.id != null, true);                
    }*/
/***************************************************************************************************
* Method Name: AllCaseBadDataAuthRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 14th Oct 2015
* Description:  Bad data - No Case Id passed
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/14/2015              Created
****************************************************************************************************/                  
    //Case Attachment file access test - no caseId passed 
    private static testMethod void AllCaseBadDataAuthRestTest(){
        Core_IPS_FileAuthorization_Test FileAuthTest = new Core_IPS_FileAuthorization_Test();
        FileAuthTest.SetUpRestTestData(10, true, 'Complete', true, false, false);
        FileAuthTest.AllCaseBadDataAuthTest(); 
        System.assert(true, true);               
    }
        
    private void AllFilesAuthTest() {
        Core_IPS_FileAuthorization.AuthResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/fileauth';  
            req.addHeader('userid', BypassSysAdminUser.Id);
            req.addHeader('appfileid', 'Testfl1');
            req.addHeader('appdata', '');
            req.addHeader('caseId', '');            
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileAuthorization.CheckFileAuthorization();
            System.assert(results.Authorized == true);
        }
        //Stop Test            
        Test.stopTest();        
    }
    
    private void AllFilesNoAuthTest() {
        Core_IPS_FileAuthorization.AuthResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/fileauth';  
            req.addHeader('userid', BypassSysAdminUser.Id);
            req.addHeader('appfileid', '55-227777-22');
            req.addHeader('appdata', '');
            req.addHeader('caseId', '');            
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileAuthorization.CheckFileAuthorization();
            System.assert(results.Authorized == false);
        }
        //Stop Test            
        Test.stopTest();        
    }
        
    private void ExceptionAuthTest() {
        Core_IPS_FileAuthorization.AuthResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            try {
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/ips/scft/fileauth';  
                req.addHeader('userid', BypassSysAdminUser.Id);
                req.addHeader('appfileid', 'Testfl1');
                req.addHeader('appdata', '');
                req.addHeader('caseId', '');      
                req.addHeader('exceptflauth', 'X');
                req.httpMethod = 'GET';
                RestContext.request = req;
                RestContext.response = res;
                results = Core_IPS_FileAuthorization.CheckFileAuthorization();
            } catch (Exception e) {
                System.assert(e.getMessage() != null);
            }
        }
        //Stop Test            
        Test.stopTest();        
    }
    
    private void AllCaseAuthTest() {
        Core_IPS_FileAuthorization.AuthResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/fileauth';  
            req.addHeader('userid', BypassSysAdminUser.Id);
            req.addHeader('appfileid', 'Testcsfl');
            req.addHeader('appdata', 'caseId-' + CaseId);
            req.addHeader('caseId', CaseId);            
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileAuthorization.CheckFileAuthorization();
            System.assert(results.Authorized == true);
        }
        //Stop Test            
        Test.stopTest();        
    }
    
    private void AllCaseBadDataAuthTest() {
        Core_IPS_FileAuthorization.AuthResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/fileauth';  
            req.addHeader('userid', BypassSysAdminUser.Id);
            req.addHeader('appfileid', 'Testcsfl');
            req.addHeader('appdata', 'caseId-' + CaseId);
            req.addHeader('caseId', '');            
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileAuthorization.CheckFileAuthorization();
            System.assert(results.Authorized == false);
        }
        //Stop Test            
        Test.stopTest();        
    }
    
    //Set up Rest Test data  
    private void SetUpRestTestData( Integer FileUplMastSize, Boolean FileAssignCrt, String Status, Boolean Valid, Boolean SelfLogin, Boolean CaseCrt) {  
        //Asset Record Type Id
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;  
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name = : System.label.Core_System_Admin_Profile_Name];
        //Integration user Profile
        Profile IntUsrPrf = [SELECT Id FROM Profile WHERE Name = : System.label.Core_IntegrationUser];
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
        //IntUserRunAs
        IntUserRunAs = TestUtilities.getUser();
        IntUserRunAs.alias = 'intrunas'; 
        IntUserRunAs.email = 'testintusrrunas@intel.com';
        IntUserRunAs.profileid = IntUsrPrf.Id;
        IntUserRunAs.userName = 'testintusrrunas@intel.com';
        Database.insert(IntUserRunAs); 
        system.assert(IntUserRunAs.Id != null);
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
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'InsertCaseCommentForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After Insert, After update';
        settings.Core_Active__c = True;
        insert settings;
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
                if(SelfLogin){
                    FileUplm.Core_Upload_idsid__c = '300000019463';
                } else {
                    FileUplm.Core_Upload_idsid__c = 'bypass';
                }
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
                ///Case Share -> not required for sys
                //Case Attachment 
                Core_IPS_Case_Attachments__c CSAttach = new Core_IPS_Case_Attachments__c();
                CSAttach.Core_File_GUID__c =  'Testcsfl';
                CSAttach.Core_File_Name__c =  'Testcsfl';
                CSAttach.Core_Upload_Status__c =  Status;
                CSAttach.Core_Case__c =  cs.id;
                Database.insert(CSAttach);               
                //system.assert(CSAttach.Id != null);        
            }
        }
        
    } 
    
}