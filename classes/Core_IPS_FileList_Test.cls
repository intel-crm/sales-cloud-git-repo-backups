/***************************************************************************************************
* Apex Class Name: Core_IPS_FileList_Test 
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Function    : IPS SCFT File Downloads -> Test Class
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     10/12/2015              Created
****************************************************************************************************/
@isTest public class Core_IPS_FileList_Test {    
    User SystUserRunAs;
    User IntUserRunAs;
    User CCPUser;
    User BypassSysAdminUser;
    User FAEUser;
    Id RoleId;
/***************************************************************************************************
* Method Name:  AllFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  Un-restricted File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/ 
    //Un-restricted file list test
    private static testMethod void AllFilesListRestTest(){ 
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, true, 'Complete', true);
        FileListTest.AllFilesListTest();       
    }
/***************************************************************************************************
* Method Name:  FAEFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  FAE File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/     
    //FAE file list test
    private static testMethod void FAEFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, true, 'Complete', true);
        FileListTest.FAEFilesListTest();
    }
/***************************************************************************************************
* Method Name:  CCPFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  Contact File List access 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/     
    //Contact file list with response data test
    private static testMethod void CCPFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, true, 'Complete', true);
        FileListTest.CCPFilesListTest();    
    }
/***************************************************************************************************
* Method Name:  CCPNoFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  Contact Null File List access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/         
    //Contact file list null response test
    private static testMethod void CCPNoFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, false, 'Complete', true);
        FileListTest.CCPNoFilesListTest();
    }
/***************************************************************************************************
* Method Name:  CCPExpFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  Contact Null Expired File List access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/         
    //Contact file list null response due to expired files
    private static testMethod void CCPExpFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, false, 'Complete', false);
        FileListTest.CCPNoFilesListTest();
    }
/***************************************************************************************************
* Method Name:  UserIdErrorFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  No User id passed from Rest Request File List access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/             
    //No user id passed from GRDC - Error response
    private static testMethod void UserIdErrorFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, true, 'Complete', true);
        FileListTest.UserIdErrorFilesListTest();
    }
/***************************************************************************************************
* Method Name:  ExceptionFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  Exception scenario forced in main Rest class for File List access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/               
    //System Exception scenario test
    private static testMethod void ExceptionFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, true, 'Complete', true);
        FileListTest.ExceptionsFilesListTest();
    }
/***************************************************************************************************
* Method Name:  ExceptionUtilFilesListRestTest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 12 Oct 2015
* Description:  Exception scenario forced in File Utility class called frm Rest class for File List access 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/                  
    //System Exception in File Utility scenario test
    private static testMethod void ExceptionUtilFilesListRestTest(){
        Core_IPS_FileList_Test FileListTest = new Core_IPS_FileList_Test();
        FileListTest.SetUpRestTestData(10, true, 'Complete', true);
        FileListTest.ExceptionsUtilFilesListTest();
    }      
    private void AllFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/filelist';  
            req.addHeader('userid', BypassSysAdminUser.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileList.GetFileList();
        }
        //Stop Test            
        Test.stopTest();
        System.assert(results.FileData.size() == 10);
        
    }
    
    private void FAEFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/filelist';  
            req.addHeader('userid', FAEUser.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileList.GetFileList();
        }
        //Stop Test            
        Test.stopTest();
        System.assert(results.FileData.size() == 10);
    }
    
    private void CCPFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/filelist';  
            req.addHeader('userid', CCPUser.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileList.GetFileList();
        }
        //Stop Test
        Test.stopTest();            
        System.assert(results.FileData.size() == 10);
        
    }
    
    private void CCPNoFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/filelist';  
            req.addHeader('userid', CCPUser.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileList.GetFileList();
        }
        //Stop Test
        Test.stopTest();            
        System.assert(results.FileData.size() == 0);
    }
    
    private void CCPExpFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/filelist';  
            req.addHeader('userid', CCPUser.Id);
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileList.GetFileList();
        }
        //Stop Test   
        Test.stopTest();         
        System.assert(results.FileData.size() == 0);
        
    }
    
    
    private void UserIdErrorFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/ips/scft/filelist';  
            req.addHeader('userid', '');
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            results = Core_IPS_FileList.GetFileList();
        }
        //Stop Test            
        Test.stopTest();        
        System.assert(results.Errors.size() == 1);
    }
    
    private void ExceptionsFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            try {
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/ips/scft/filelist';  
                req.addHeader('userid', BypassSysAdminUser.Id);
                req.addHeader('exceptfllst', 'X');
                req.httpMethod = 'GET';
                RestContext.request = req;
                RestContext.response = res;
                results = Core_IPS_FileList.GetFileList();
            } catch (Exception e) {
                System.assert(e.getMessage() != null);
            }
        }
        //Stop Test
        Test.stopTest();   
        
    }
    
    private void ExceptionsUtilFilesListTest() {
        Core_IPS_FileList.FileTypeResp results;
        //Start Test
        Test.startTest();
        System.runAs(IntUserRunAs) {
            try {
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/ips/scft/filelist';  
                req.addHeader('userid', BypassSysAdminUser.Id);
                req.addHeader('exceptutil', 'X');
                req.httpMethod = 'GET';
                RestContext.request = req;
                RestContext.response = res;
                results = Core_IPS_FileList.GetFileList();
            } catch (Exception e) {
                System.assert(e.getMessage() != null);
            }
        }
        //Stop Test
        Test.stopTest();   
        
    }
    
    
    private void SetUpRestTestData( Integer FileUplMastSize, Boolean FileAssignCrt, String Status, Boolean Valid) {
        //Asset Record Type Id
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name =:System.label.Core_System_Admin_Profile_Name];
        //Integration user Profile
        Profile IntUsrPrf = [SELECT Id FROM Profile WHERE Name =:System.label.Core_IntegrationUser];
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
            //Accnt =  TestUtilities.getAccount();@@@Utility has issues
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
            Grp.Name = 'Test Groupx';
            Grp.DeveloperName = 'Test_Groupx';
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
        }
        
    }    
    
}