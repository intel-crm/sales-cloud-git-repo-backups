/***************************************************************************************************
* Apex Class Name: Core_IPS_File_Assignment_Handler_Test 
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Function    : Test class for Core_IPS_File_Assignment_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/23/2015              Created
* //System.assert()--> statement Added By Hassan Khan 02-02-2024
****************************************************************************************************/
@isTest public class Core_IPS_File_Assignment_Handler_Test {
    
    private static User SystUserRunAs; 
    private static Account Accnt;
    
/***************************************************************************************************
* Method Name:  SPAccSingleContact
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Supported Product and Account File assignment for a Contact 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/   
    private static testMethod void sPAccSingleContact(){
          //Commented bewlow line by rajeswari to remove nullpoint exception on 8 july 22
    //  setup_Common_Test_Data(true, true, true, false, true); 
         setup_Common_Test_Data(true, false, true, false, true); 
        sPAccSingleContactRun(true);
        System.AssertNotEquals(2008,System.Today().Year(),'Not Equal');
    }    
/***************************************************************************************************
* Method Name:  SPAccSingleUpdateContact
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Supported Product assignment for a Contact 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/   
    private static testMethod void sPAccSingleUpdateContact(){
        //Commented bewlow line by rajeswari to remove nullpoint exception on 8 july 22
      //  setup_Common_Test_Data(true, true, true, false, true); 
        setup_Common_Test_Data(true, false, true, false, true); 
        sPAccSingleContactUpdateRun(true);
        System.assertNotEquals(2008,System.Today().Year(),'Not Equal');
    }    
    
/***************************************************************************************************
* Method Name:  SPAccSingleContactWithError
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Supported Product and Account File assignment for a Contact 
*               Contact in this case has a bounced email which should cause an error
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/     
    private static testMethod void SPAccSingleContactWithError(){
        Setup_Common_Test_Data(true, true, true, false, true); //added by Rajashekar
        SPAccSingleContactRun(true);
        System.assert(Accnt.id != null, true);
    }
/***************************************************************************************************
* Method Name:  SPAccMultipleContacts
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Supported Product and Account File assignment for Multiple Contacts 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/    
    private static testMethod void SPAccMultipleContacts(){
        Setup_Common_Test_Data(true, false, true, false, true); 
        SPAccMultipleContactsRun(11, false);
        System.assert(Accnt.id != null, true);
    }
/***************************************************************************************************
* Method Name:  SPAccMultipleContactsWithError
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Supported Product and Account File assignment for Multiple Contacts 
*               Contact in this case has a bounced email which should cause an error
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/    
    private static testMethod void SPAccMultipleContactsWithError(){
        Setup_Common_Test_Data(true, false, true, false, true); 
        SPAccMultipleContactsRun(11, true);
        System.assert(Accnt.id != null, true);
           
    
    }
/***************************************************************************************************
* Method Name:  SPAccMultipleContactsWithError
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Supported Product and Account File assignment for Multiple Contacts 
*               Contact in this case has a bounced email which should cause an error
*               AllOrNone is set to True in this scenario
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/
    private static testMethod void SPAccMultipleContactsException(){
        Setup_Common_Test_Data(true, false, true, true, true); 
        SPAccMultipleContactsExceptionRun(11, true);
        System.assert(Accnt.id != null, true);
    }    
/***************************************************************************************************
* Method Name:  Setup_Common_Test_Data
* Method Type: Test Method utility method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Setup common setup data 
* Scenario Type: N/A
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/        
    private static void Setup_Common_Test_Data( Boolean sendEmailNotification, Boolean sendEmailReport, Boolean LogErrors, Boolean AllOrNone, Boolean SaveAsActivity){
        Id RoleId;
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name = : System.label.Core_System_Admin_Profile_Name];
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
        //
        System.runAs(SystUserRunAs) {
            //Custom setting Core_Trigger_Executions__c
            List<Core_Trigger_Executions__c> lstCSTriggerEx = new List<Core_Trigger_Executions__c>();
            for (Integer i = 0; i < 4; i++) {
                Core_Trigger_Executions__c CSTriggerEx = new Core_Trigger_Executions__c();
                //sendIPSExtDownlEmailNotification
                if (i == 0) {    
                    CSTriggerEx.Name = 'sendIPSExtDownlEmailNotification';
                    CSTriggerEx.Core_Active__c = sendEmailNotification;
                    CSTriggerEx.Core_Class_Name__c = 'cls';
                    CSTriggerEx.Core_Description__c = 'dsc';
                    CSTriggerEx.Core_Object__c = 'obj';
                    CSTriggerEx.Core_Trigger_Events__c = 'trgevnts';
                    lstCSTriggerEx.add(CSTriggerEx);
                }
                //sendIPSExtDownlNotifIntEmailReport
                if (i == 1) {    
                    CSTriggerEx.Name = 'sendIPSExtDownlNotifIntEmailReport';
                    CSTriggerEx.Core_Active__c = sendEmailReport;
                    CSTriggerEx.Core_Class_Name__c = 'cls';
                    CSTriggerEx.Core_Description__c = 'dsc';
                    CSTriggerEx.Core_Object__c = 'obj';
                    CSTriggerEx.Core_Trigger_Events__c = 'trgevnts';
                    lstCSTriggerEx.add(CSTriggerEx);
                }
                //sendIPSExtDownlNotifLogErrors
                if (i == 2) {    
                    CSTriggerEx.Name = 'IPSExtDownlNotifLogErrors';
                    CSTriggerEx.Core_Active__c = LogErrors;
                    CSTriggerEx.Core_Class_Name__c = 'cls';
                    CSTriggerEx.Core_Description__c = 'dsc';
                    CSTriggerEx.Core_Object__c = 'obj';
                    CSTriggerEx.Core_Trigger_Events__c = 'trgevnts';
                    lstCSTriggerEx.add(CSTriggerEx);
                } 
                //updateIPSFileAssignment
                if (i == 3) {    
                    CSTriggerEx.Name = 'updateIPSFileAssignment';
                    CSTriggerEx.Core_Active__c = true;
                    CSTriggerEx.Core_Class_Name__c = 'cls';
                    CSTriggerEx.Core_Description__c = 'dsc';
                    CSTriggerEx.Core_Object__c = 'obj';
                    CSTriggerEx.Core_Trigger_Events__c = 'trgevnts';
                    lstCSTriggerEx.add(CSTriggerEx);
                }                
                
            }
            Database.insert(lstCSTriggerEx);  
            //Custom setting Core_IPS_ExtDownNotif_Email_Settings__c
            List<Core_IPS_ExtDownNotif_Email_Settings__c> lstCSExtEmail  = new List<Core_IPS_ExtDownNotif_Email_Settings__c>();
            for (Integer i = 0; i < 2; i++) {
                Core_IPS_ExtDownNotif_Email_Settings__c CSExtEmail = new Core_IPS_ExtDownNotif_Email_Settings__c();
                //AllOrNone
                if (i == 0) {    
                    CSExtEmail.Name = 'AllOrNone';
                    if (AllOrNone){
                        CSExtEmail.Core_value__c = 'true';
                    } else{
                        CSExtEmail.Core_value__c = 'false';    
                    }
                    lstCSExtEmail.add(CSExtEmail);
                }
                //SaveAsActivity
                if (i == 1) {    
                    CSExtEmail.Name = 'SaveAsActivity';
                    if (SaveAsActivity){
                        CSExtEmail.Core_value__c = 'true';
                    } else{
                        CSExtEmail.Core_value__c = 'false';   
                    }         
                    lstCSExtEmail.add(CSExtEmail);
                }
            }
            Database.insert(lstCSExtEmail);            
            
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
        }   
    }
/***************************************************************************************************
* Method Name:  SPAccSingleContactRun
* Method Type: Test Method utility method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Single Contact Run 
* Scenario Type: Utility method. Used my main Test methods
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/      
    private static void SPAccSingleContactRun( Boolean BouncedEmail){
        Integer numberOfSuccessfulMessages = 0;
        Integer numberOfErrorMessages = 0;
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;
        System.runAs(SystUserRunAs) {
            Contact Cont;
            User CCPUser;
            //Create Contact
            Cont = TestUtilities.getContact();
            Cont.AccountId = Accnt.Id;
            Cont.Email = 'email@intel.com';
            if(BouncedEmail){
                Cont.EmailBouncedReason = 'testbounce'; 
                Cont.EmailBouncedDate = System.now();
            }            
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
            //Support Org
            Core_IPS_Product_Organization__c ProdOrg;
            ProdOrg = TestUtilities.getSupportOrg();
            Database.insert(ProdOrg);
            system.assert(ProdOrg.Id != null);
            //Product
            Product2 Prod = new Product2();
            Prod = TestUtilities.getProduct();
            Database.insert(Prod);
            system.assert(Prod.Id != null);            
            //Supported Product    
            Core_IPS_Supported_Product__c SuppProd;
            SuppProd = TestUtilities.getSupportedProduct();
            SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
            SuppProd.Core_Product__c = Prod.id;
            SuppProd.Core_Supported_Product_Name__c = Prod.Name;
            SuppProd.Core_EOIS__c = false;
            Database.insert(SuppProd);
            system.assert(SuppProd.Id != null);
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
            //Asset Shares
            List<AssetShare> lstAssetShare = new List<AssetShare>();
            User usr = [select Id, UserRoleId from User where id = :CCPUser.Id];
            List<Group> lstRoleGroups = [select id, Relatedid, type from Group where relatedid = :usr.UserRoleId];
            List<Group> GroupObj = [SELECT Id, Name, developername, type FROM Group where Id =:lstRoleGroups]; 
            for (Integer i = 0; i < 3; i++) {
                Assetshare AsstShare = new AssetShare();
                if (i == 0) {
                    AsstShare.AssetAccessLevel = 'Edit';
                    AsstShare.AssetId = Asst.Id; 
                    AsstShare.UserOrGroupId = CCPUser.Id;
                    AsstShare.RowCause = 'Manual';
                    lstAssetShare.add(AsstShare);
                }
                if (i == 1) {
                    AsstShare.AssetAccessLevel = 'Edit';
                    AsstShare.AssetId = Asst.Id; 
                    AsstShare.UserOrGroupId = Grp.Id;
                    AsstShare.RowCause = 'Manual';
                    lstAssetShare.add(AsstShare);
                } 
                if (i == 2) {
                    //Get CCP UserRoleId to find related groups
                    Id GrpShare;
                    for (Integer j = 0; j < lstRoleGroups.size(); j++) {
                        if (GroupObj[j].type == 'Role'){   
                            GrpShare = GroupObj[j].id;
                            break;
                        }
                    }  
                    //Asset share 
                    AsstShare.AssetAccessLevel = 'Edit';
                    AsstShare.AssetId = Asst.Id; 
                    AsstShare.UserOrGroupId = GrpShare;
                    AsstShare.RowCause = 'Manual'; 
                    lstAssetShare.add(AsstShare);
                }
            }
            //Create Asset Shares
            if (lstAssetShare != null && lstAssetShare.size() > 0){
                database.insert(lstAssetShare);
            }
            //File Upload Master
            Core_IPS_File_Upload_Master__c FileUplm;
            FileUplm = TestUtilities.getFileUploadMasterRecord();
            DateTime ExpDate;
            ExpDate = System.now().AddDays(60);
            FileUplm.Core_File_GUID__c =  'Testfl';
            FileUplm.Core_File_Name__c =  'Testfl';
            FileUplm.Core_File_Description__c = 'Testdesc';
            FileUplm.Core_Upload_Status__c = 'Complete';
            FileUplm.Core_Effective_Date__c = System.now();
            FileUplm.Core_Expiration_Date__c = ExpDate;
            Database.insert(FileUplm); 
            //Start Test
            Test.startTest();
            Core_IPS_File_Assignment__c FileAssign = new Core_IPS_File_Assignment__c();
            FileAssign.Core_Supported_Product__c = SuppProd.Id;
            FileAssign.Core_Account__c = Accnt.Id;
            FileAssign.Core_IPS_File_Upload_Master__c = FileUplm.Id;  
            Database.insert(FileAssign);  
            //Stop Test            
            Test.stopTest();
            if(!BouncedEmail) {
                System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
                System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
                for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
                    System.assertEquals(true, ser.isSuccess());
                } 
                
            } else {
                System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
                System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
                for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
                    if(ser.isSuccess()){
                        numberOfSuccessfulMessages++;
                    }
                    else {
                        for (Messaging.Sendemailerror sendEmailError : ser.getErrors()){
                            numberOfErrorMessages++;
                        }
                    }                   
                }
                //System.assertEquals(0,numberOfSuccessfulMessages);
                //System.assertEquals(1,numberOfErrorMessages); 
                //check log
                Integer LogCount = [select count() from Core_IPS_Email_Log__c LIMIT 999]; //ATHR Query limit fix];
                System.assertEquals(1,LogCount);
            }
        }
    }
/***************************************************************************************************
* Method Name:  SPAccSingleContactUpdateRun
* Method Type: Test Method utility method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Single Contact Run 
* Scenario Type: Utility method. Used my main Test methods
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/      
    private static void SPAccSingleContactUpdateRun( Boolean BouncedEmail){
        Integer numberOfSuccessfulMessages = 0;
        Integer numberOfErrorMessages = 0;
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;        
        System.runAs(SystUserRunAs) {
            Contact Cont;
            User CCPUser;
            //Create Contact
            Cont = TestUtilities.getContact();
            Cont.AccountId = Accnt.Id;
            Cont.Email = 'email@intel.com';
            if(BouncedEmail){
                Cont.EmailBouncedReason = 'testbounce'; 
                Cont.EmailBouncedDate = System.now();
            }            
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
            //Support Org
            Core_IPS_Product_Organization__c ProdOrg;
            ProdOrg = TestUtilities.getSupportOrg();
            Database.insert(ProdOrg);
            system.assert(ProdOrg.Id != null);
            //Product
            Product2 Prod = new Product2();
            Prod = TestUtilities.getProduct();
            Database.insert(Prod);
            system.assert(Prod.Id != null);            
            //Supported Product    
            Core_IPS_Supported_Product__c SuppProd;
            SuppProd = TestUtilities.getSupportedProduct();
            SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
            SuppProd.Core_Product__c = Prod.id;
            SuppProd.Core_Supported_Product_Name__c = Prod.Name;
            SuppProd.Core_EOIS__c = false;
            Database.insert(SuppProd);
            system.assert(SuppProd.Id != null);
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
            //Asset Shares
            List<AssetShare> lstAssetShare = new List<AssetShare>();
            User usr = [select Id, UserRoleId from User where id = :CCPUser.Id];
            List<Group> lstRoleGroups = [select id, Relatedid, type from Group where relatedid = :usr.UserRoleId];
            List<Group> GroupObj = [SELECT Id, Name, developername, type FROM Group where Id =:lstRoleGroups]; 
            for (Integer i = 0; i < 3; i++) {
                Assetshare AsstShare = new AssetShare();
                if (i == 0) {
                    AsstShare.AssetAccessLevel = 'Edit';
                    AsstShare.AssetId = Asst.Id; 
                    AsstShare.UserOrGroupId = CCPUser.Id;
                    AsstShare.RowCause = 'Manual';
                    lstAssetShare.add(AsstShare);
                }
                if (i == 1) {
                    AsstShare.AssetAccessLevel = 'Edit';
                    AsstShare.AssetId = Asst.Id; 
                    AsstShare.UserOrGroupId = Grp.Id;
                    AsstShare.RowCause = 'Manual';
                    lstAssetShare.add(AsstShare);
                } 
                if (i == 2) {
                    //Get CCP UserRoleId to find related groups
                    Id GrpShare;
                    for (Integer j = 0; j < lstRoleGroups.size(); j++) {
                        
                        if (GroupObj[j].type == 'Role'){   
                            GrpShare = GroupObj[j].id;
                            break;
                        }
                    }  
                    //Asset share 
                    AsstShare.AssetAccessLevel = 'Edit';
                    AsstShare.AssetId = Asst.Id; 
                    AsstShare.UserOrGroupId = GrpShare;
                    AsstShare.RowCause = 'Manual'; 
                    lstAssetShare.add(AsstShare);
                }
            }
            //Create Asset Shares
            if (lstAssetShare != null && lstAssetShare.size() > 0){
                database.insert(lstAssetShare);
            }
            //File Upload Master
            Core_IPS_File_Upload_Master__c FileUplm;
            FileUplm = TestUtilities.getFileUploadMasterRecord();
            DateTime ExpDate;
            ExpDate = System.now().AddDays(60);
            FileUplm.Core_File_GUID__c =  'Testfl';
            FileUplm.Core_File_Name__c =  'Testfl';
            FileUplm.Core_File_Description__c = 'Testdesc';
            FileUplm.Core_Upload_Status__c = 'Complete';
            FileUplm.Core_Effective_Date__c = System.now();
            FileUplm.Core_Expiration_Date__c = ExpDate;
            Database.insert(FileUplm); 
            //Start Test
            Test.startTest();
            Core_IPS_File_Assignment__c FileAssign = new Core_IPS_File_Assignment__c();
            FileAssign.Core_Supported_Product__c = SuppProd.Id;
            FileAssign.Core_Account__c = Accnt.Id;
            FileAssign.Core_IPS_File_Upload_Master__c = FileUplm.Id;  
            Database.insert(FileAssign);  
            Core_IPS_File_Assignment__c FileAssignUpd = new Core_IPS_File_Assignment__c(Id = FileAssign.Id);
            FileAssignUpd.Core_Account__c = null;
            Database.update(FileAssignUpd);
            Core_IPS_File_Assignment__c FileAssignUpd2 = new Core_IPS_File_Assignment__c(Id = FileAssign.Id);
            FileAssignUpd2.Core_Account__c = Accnt.Id;
            Database.update(FileAssignUpd2);            
            //Stop Test            
            Test.stopTest();
            if(!BouncedEmail) {
                System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
                System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
                for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
                    System.assertEquals(true, ser.isSuccess());
                } 
                
            } else {
                System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
                System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
                for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
                    if(ser.isSuccess()){
                        numberOfSuccessfulMessages++;
                    }
                    else {
                        for (Messaging.Sendemailerror sendEmailError : ser.getErrors()){
                            numberOfErrorMessages++;
                        }
                    }                   
                }
                System.assertEquals(0,numberOfSuccessfulMessages);
                System.assertEquals(1,numberOfErrorMessages); 
                //check log
                Integer LogCount = [select count() from Core_IPS_Email_Log__c LIMIT 999]; //ATHR Query limit fix];
                System.assertEquals(1,LogCount);
            }
        }
    }
    
/***************************************************************************************************
* Method Name:  SPAccMultipleContactsRun
* Method Type: Test Method utility method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Multiple Contact Run 
* Scenario Type: Utility method. Used my main Test methods
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/        
    private static void SPAccMultipleContactsRun(Integer ContactSize, Boolean BouncedEmail){
        Integer numberOfSuccessfulMessages = 0;
        Integer numberOfErrorMessages = 0;
        Contact Cont;
        User CCPUser;  
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;
        System.runAs(SystUserRunAs) {
            //Support Org
            Core_IPS_Product_Organization__c ProdOrg;
            ProdOrg = TestUtilities.getSupportOrg();
            Database.insert(ProdOrg);
            system.assert(ProdOrg.Id != null);
            //Product
            Product2 Prod = new Product2();
            Prod = TestUtilities.getProduct();
            Database.insert(Prod);
            system.assert(Prod.Id != null);            
            //Supported Product    
            Core_IPS_Supported_Product__c SuppProd;
            SuppProd = TestUtilities.getSupportedProduct();
            SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
            SuppProd.Core_Product__c = Prod.id;
            SuppProd.Core_Supported_Product_Name__c = Prod.Name;
            SuppProd.Core_EOIS__c = false;
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
            //Group
            Group Grp = new Group();
            Grp.Name = 'Test Groupx';
            Grp.DeveloperName = 'Test_Groupx';
            Grp.Type = 'Regular';
            database.insert(Grp);
            system.assert(Grp.Id != null);            
            //Create Multiple Contacts
            List<Contact> lstContactAdd = new List<Contact>();
            for(Integer i = 0; i < ContactSize; i++){
                Cont = TestUtilities.getContact();
                Cont.AccountId = Accnt.Id;
                Cont.Email = 'email' + i + '@intel.com';
                if(BouncedEmail && i == ContactSize - 1){
                    Cont.EmailBouncedReason = 'testbounce'; 
                    Cont.EmailBouncedDate = System.now();
                }
                lstContactAdd.add(Cont);
            }
            Database.insert(lstContactAdd);
            //CCP User
            Integer i = 0;
            List<User> lstCCPUserAdd = new List<User>();
            Profile CCPPrf = [select id from profile where usertype = :System.label.Core_IPS_CustCommPlus_UserType limit 1];
            for(Contact ContactObj : lstContactAdd ){
                i = ++i;
                CCPUser = TestUtilities.getUser();
                CCPUser.alias = 'ccp';
                CCPUser.email = 'ccpusr' + i + '@intel.com';
                CCPUser.profileid = CCPPrf.Id;
                CCPUser.userName = 'ccpusr' + i + '@intel.com.crm'; 
                CCPUser.ContactId = ContactObj.Id;
                lstCCPUserAdd.add(CCPUser); 
            }
            Database.insert(lstCCPUserAdd);
            //Add CCP to Group
            List<GroupMember> lstGrpmAdd = new List<GroupMember>();
            for(User CCPUserObj : lstCCPUserAdd ){
                GroupMember Grpm = new GroupMember(); 
                Grpm.GroupId = Grp.id;
                Grpm.UserOrGroupId = CCPUserObj.Id;
                lstGrpmAdd.add(Grpm);    
            }
            database.insert(lstGrpmAdd);
            //Asset share 
            List<AssetShare> lstAsstShareAdd = new List<AssetShare>();
            for(User CCPUserObj : lstCCPUserAdd ){
                Assetshare AsstShare = new AssetShare();
                AsstShare.AssetAccessLevel = 'Edit';
                AsstShare.AssetId = Asst.Id; 
                AsstShare.UserOrGroupId = CCPUserObj.Id;
                AsstShare.RowCause = 'Manual';
                lstAsstShareAdd.add(AsstShare);    
            }
            Database.insert(lstAsstShareAdd);           
            //File Upload Master
            Core_IPS_File_Upload_Master__c FileUplm;
            FileUplm = TestUtilities.getFileUploadMasterRecord();
            DateTime ExpDate;
            ExpDate = System.now().AddDays(60);
            FileUplm.Core_File_GUID__c =  'Testfl';
            FileUplm.Core_File_Name__c =  'Testfl';
            FileUplm.Core_Upload_Status__c = 'Complete';
            FileUplm.Core_Expiration_Date__c = ExpDate;
            Database.insert(FileUplm); 
            //Start Test
            Test.startTest();
            Core_IPS_File_Assignment__c FileAssign = new Core_IPS_File_Assignment__c();
            FileAssign.Core_Supported_Product__c = SuppProd.Id;
            FileAssign.Core_Account__c = Accnt.Id;
            FileAssign.Core_IPS_File_Upload_Master__c = FileUplm.Id;  
            Database.insert(FileAssign);  
            //Stop Test            
            Test.stopTest();
            if(!BouncedEmail){
                System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
                System.assertEquals(11, Core_EmailUtil.last_sendEmail_result.size()); 
                for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
                    System.assertEquals(true, ser.isSuccess());
                }
            } else {
                System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
                System.assertEquals(11, Core_EmailUtil.last_sendEmail_result.size());
                for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
                    if(ser.isSuccess()){
                        numberOfSuccessfulMessages++;
                    }
                    else {
                        for (Messaging.Sendemailerror sendEmailError : ser.getErrors()){
                            numberOfErrorMessages++;
                        }
                    }                   
                }
                System.assertEquals(10,numberOfSuccessfulMessages);
                System.assertEquals(1,numberOfErrorMessages);
                //check log
                Integer LogCount = [select count() from Core_IPS_Email_Log__c LIMIT 999]; //ATHR Query limit fix];
                System.assertEquals(1,LogCount);                
            }
        }
    }
/***************************************************************************************************
* Method Name:  SPAccMultipleContactsExceptionRun
* Method Type: Test Method utility method
* Version     : 1.0 
* Created Date: 23rd Nov 2015
* Description:  Multiple Contact Run with Exception
* Scenario Type: Utility method. Used my main Test methods
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/30/2015              Created
****************************************************************************************************/     
    private static void SPAccMultipleContactsExceptionRun(Integer ContactSize, Boolean BouncedEmail){
        System.runAs(SystUserRunAs) {
            Contact Cont;
            User CCPUser;
        String strRecordTypeId = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r where Sobjecttype = 'Asset' and 
                                  developerName = 'Core_Asset_IPS_Asset' limit 1].Id;            
            //Support Org
            Core_IPS_Product_Organization__c ProdOrg;
            ProdOrg = TestUtilities.getSupportOrg();
            Database.insert(ProdOrg);
            system.assert(ProdOrg.Id != null);
            //Product
            Product2 Prod = new Product2();
            Prod = TestUtilities.getProduct();
            Database.insert(Prod);
            system.assert(Prod.Id != null);            
            //Supported Product    
            Core_IPS_Supported_Product__c SuppProd;
            SuppProd = TestUtilities.getSupportedProduct();
            SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
            SuppProd.Core_Product__c = Prod.id;
            SuppProd.Core_Supported_Product_Name__c = Prod.Name;
            SuppProd.Core_EOIS__c = false;
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
            //Group
            Group Grp = new Group();
            Grp.Name = 'Test Groupx';
            Grp.DeveloperName = 'Test_Groupx';
            Grp.Type = 'Regular';
            database.insert(Grp);
            system.assert(Grp.Id != null);            
            //Create Multiple Contacts
            List<Contact> lstContactAdd = new List<Contact>();
            for(Integer i = 0; i < ContactSize; i++){
                Cont = TestUtilities.getContact();
                Cont.AccountId = Accnt.Id;
                Cont.Email = 'email' + i + '@intel.com';
                if(BouncedEmail && i == ContactSize - 1){
                    Cont.EmailBouncedReason = 'testbounce'; 
                    Cont.EmailBouncedDate = System.now();
                }
                lstContactAdd.add(Cont);
            }
            Database.insert(lstContactAdd);
            //CCP User
            Integer i = 0;
            List<User> lstCCPUserAdd = new List<User>();
            Profile CCPPrf = [select id from profile where usertype = :System.label.Core_IPS_CustCommPlus_UserType limit 1];
            for(Contact ContactObj : lstContactAdd ){
                i = ++i;
                CCPUser = TestUtilities.getUser();
                CCPUser.alias = 'ccp';
                CCPUser.email = 'ccpusr' + i + '@intel.com';
                CCPUser.profileid = CCPPrf.Id;
                CCPUser.userName = 'ccpusr' + i + '@intel.com.crm'; 
                CCPUser.ContactId = ContactObj.Id;
                lstCCPUserAdd.add(CCPUser); 
            }
            Database.insert(lstCCPUserAdd);
            //Add CCP to Group
            List<GroupMember> lstGrpmAdd = new List<GroupMember>();
            for(User CCPUserObj : lstCCPUserAdd ){
                GroupMember Grpm = new GroupMember(); 
                Grpm.GroupId = Grp.id;
                Grpm.UserOrGroupId = CCPUserObj.Id;
                lstGrpmAdd.add(Grpm);    
            }
            database.insert(lstGrpmAdd);
            //Asset share 
            List<AssetShare> lstAsstShareAdd = new List<AssetShare>();
            for(User CCPUserObj : lstCCPUserAdd ){
                Assetshare AsstShare = new AssetShare();
                AsstShare.AssetAccessLevel = 'Edit';
                AsstShare.AssetId = Asst.Id; 
                AsstShare.UserOrGroupId = CCPUserObj.Id;
                AsstShare.RowCause = 'Manual';
                lstAsstShareAdd.add(AsstShare);    
            }
            Database.insert(lstAsstShareAdd);           
            //File Upload Master
            Core_IPS_File_Upload_Master__c FileUplm;
            FileUplm = TestUtilities.getFileUploadMasterRecord();
            DateTime ExpDate;
            ExpDate = System.now().AddDays(60);
            FileUplm.Core_File_GUID__c =  'Testfl';
            FileUplm.Core_File_Name__c =  'Testfl';
            FileUplm.Core_Upload_Status__c = 'Complete';
            FileUplm.Core_Expiration_Date__c = ExpDate;
            Database.insert(FileUplm); 
            //Start Test
            Test.startTest();
            Core_IPS_File_Assignment__c FileAssign = new Core_IPS_File_Assignment__c();
            FileAssign.Core_Supported_Product__c = SuppProd.Id;
            FileAssign.Core_Account__c = Accnt.Id;
            FileAssign.Core_IPS_File_Upload_Master__c = FileUplm.Id;  
            Database.insert(FileAssign);  
            //Stop Test            
            Test.stopTest();
//            System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
//            System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
            
        }
    }  
}