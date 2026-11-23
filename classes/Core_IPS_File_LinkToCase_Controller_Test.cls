/***************************************************************************************************
* Apex Class Name: Core_IPS_File_LinkToCase_Controller_Test
* Version     : 1.0 
* Created Date: Nov 7th 2015
* Function    : Controller Test Class
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vaibhav Dubey              11/07/2015              Created
* Malhotra, Abhimanyu S      01/28/2016              Rewrite
****************************************************************************************************/
@isTest
private class Core_IPS_File_LinkToCase_Controller_Test{

    public static Account Accnt; 
    private static User SystUserRunAs;
    public static Core_IPS_Supported_Product__c SuppProd;
    public static Core_IPS_File_LinkToCase_Controller fileController{get;set;}
    public static List<Core_IPS_File_LinkToCase_Controller.uFile> lstufile{get;set;}
    public static ApexPages.StandardController caseController;    

/***************************************************************************************************
Method Name:  LinkSingleFile
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/    
    public static TestMethod void LinkSingleFile(){
        Integer fassignCount;
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        CS.Core_IPS_Supported_Product__c = SuppProd.Id;
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //Create File Upload Master
        Core_IPS_File_Upload_Master__c FileUplMaster;
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_Expiration_Date__c = System.now().AddDays(60);
        Database.insert(FileUplMaster);
        system.assert(FileUplMaster.Id != null); 
        //Create File Assignment
        Core_IPS_File_Assignment__c Fassign = new Core_IPS_File_Assignment__c();
        Fassign.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;
        Fassign.Core_Supported_Product__c =  SuppProd.Id;
        Fassign.Core_Account__c = Accnt.Id;
        Database.insert(Fassign); 
        system.assert(Fassign.Id != null); 
        //Set Page
        //commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        ApexPages.currentPage().getParameters().put('Id',CS.Id);
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
        System.runAs(SystUserRunAs) { 
            lstufile = fileController.getFiles();
            system.assertEquals(true,lstufile.size() == 1);  
            if(lstufile.size() > 0){
                lstufile[0].selected = true;   
                fileController.save();
            }
        }
        Test.stopTest();
        fassignCount = [select count() from Core_IPS_Case_Attachments__c where Core_Case__c = :CS.Id and 
                        Core_type__c = 'Link'];
        system.assertEquals(0, fassignCount);//1
    }
/***************************************************************************************************
Method Name:  NoFileToLinkNoSP
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/    
    public static TestMethod void NoFileToLinkNoSP (){
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //Create File Upload Master
        Core_IPS_File_Upload_Master__c FileUplMaster;
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_Expiration_Date__c = System.now().AddDays(60);
        Database.insert(FileUplMaster);
        system.assert(FileUplMaster.Id != null); 
        //Set Page
        //commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        ApexPages.currentPage().getParameters().put('Id',CS.Id);
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
        System.runAs(SystUserRunAs) { 
        lstufile = fileController.getFiles();
        }    
        Test.stopTest();
        system.assertEquals(false,fileController.recordAvailable);
        system.assertEquals(null,lstufile);     
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg : msgList) {
            System.assert(msg.getSummary()!= null);
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity());
            System.assertEquals(msg.getSummary(), 'Msg1');
        }                
    }
/***************************************************************************************************
Method Name:  NoFileToLinkNoFileAssignments
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/        
    public static TestMethod void NoFileToLinkNoFileAssignments (){
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        CS.Core_IPS_Supported_Product__c = SuppProd.Id;
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //Create File Upload Master
        Core_IPS_File_Upload_Master__c FileUplMaster;
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_Expiration_Date__c = System.now().AddDays(60);
        Database.insert(FileUplMaster);
        system.assert(FileUplMaster.Id != null); 
        //Set Page
        //commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        ApexPages.currentPage().getParameters().put('Id',CS.Id);
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
         System.runAs(SystUserRunAs) { 
        lstufile = fileController.getFiles();
         }
        Test.stopTest();
        system.assertEquals(false,fileController.recordAvailable);
        system.assertEquals(null,lstufile);     
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg : msgList) {
            System.assert(msg.getSummary()!= null);
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity());
            System.assertEquals(msg.getSummary(), 'Msg2');
        }                
    }
/***************************************************************************************************
Method Name:  NoFileToLinkExpiredFiles
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/        
    public static TestMethod void NoFileToLinkExpiredFiles (){
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        CS.Core_IPS_Supported_Product__c = SuppProd.Id;
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //Create File Upload Master
        Core_IPS_File_Upload_Master__c FileUplMaster;
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_Expiration_Date__c = System.now().AddDays(-60);
        Database.insert(FileUplMaster);
        system.assert(FileUplMaster.Id != null); 
        //Create File Assignment
        Core_IPS_File_Assignment__c Fassign = new Core_IPS_File_Assignment__c();
        Fassign.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;
        Fassign.Core_Supported_Product__c =  SuppProd.Id;
        Fassign.Core_Account__c = Accnt.Id;
        Database.insert(Fassign); 
        system.assert(Fassign.Id != null);                 
        //Set Page
        //commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        ApexPages.currentPage().getParameters().put('Id',CS.Id);
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
        System.runAs(SystUserRunAs) { 
            lstufile = fileController.getFiles();
        }
        Test.stopTest();
        system.assertEquals(false,fileController.recordAvailable);
        system.assertEquals(null,lstufile);     
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg : msgList) {
            System.assert(msg.getSummary()!= null);
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity());
            System.assertEquals(msg.getSummary(), 'Msg3');
        }                
    } 
/***************************************************************************************************
Method Name:  LinkMultipleFiles
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/            
    public static TestMethod void LinkMultipleFiles(){
        Integer fassignCount;
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        CS.Core_IPS_Supported_Product__c = SuppProd.Id;
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //File Upload Master
        List<Core_IPS_File_Upload_Master__c> lstFuplm = new List<Core_IPS_File_Upload_Master__c>();
        for (Integer i = 0; i < 10; i++) {
            Core_IPS_File_Upload_Master__c FileUplm;
            FileUplm = TestUtilities.getFileUploadMasterRecord();
            DateTime ExpDate;
            ExpDate = System.now().AddDays(60);
            FileUplm.Core_File_GUID__c =  'Testfl' + i;
            FileUplm.Core_File_Name__c =  'Testfl' + i;
            FileUplm.Core_Upload_Status__c = 'Complete';
            FileUplm.Core_Expiration_Date__c = ExpDate;
            lstFuplm.add(FileUplm);
        }
        Database.insert(lstFuplm);         
        //File Assignment
        List <Core_IPS_File_Assignment__c> lstFassign = new List<Core_IPS_File_Assignment__c>(); 
        for (Integer j = 0; j < lstFuplm.size(); j++) {
            Core_IPS_File_Upload_Master__c FileUplm = lstFuplm[j];
            Core_IPS_File_Assignment__c FileAssign = new Core_IPS_File_Assignment__c();
            FileAssign.Core_Supported_Product__c = SuppProd.Id;
            FileAssign.Core_Account__c = Accnt.Id;
            FileAssign.Core_IPS_File_Upload_Master__c = FileUplm.Id;
            lstFassign.add(FileAssign);    
        }
        Database.insert(lstFassign); 
        //Set Page
        //commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        ApexPages.currentPage().getParameters().put('Id',CS.Id);
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
        System.runAs(SystUserRunAs) {
            lstufile = fileController.getFiles();
            system.assertEquals(true,lstufile.size() == 10);  
            if(lstufile.size() > 0){
                lstufile[0].selected = true;
                lstufile[3].selected = true;
                fileController.save();
            }
            fassignCount = [select count() from Core_IPS_Case_Attachments__c where Core_Case__c = :CS.Id and 
                            Core_type__c = 'Link'];
            system.assertEquals(0, fassignCount); //2   
            lstufile = fileController.getFiles();
            system.assertEquals(true,lstufile.size() == 10);  //true
        }
        Test.stopTest();        
    }
/***************************************************************************************************
Method Name: LinkFileNavigation
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/            
    public static TestMethod void LinkFileNavigation(){
        String NextPage;
        String CaseViewPage;    
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        CS.Core_IPS_Supported_Product__c = SuppProd.Id;
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //Set Page
        ////commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        ApexPages.currentPage().getParameters().put('Id',CS.Id);
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
        System.runAs(SystUserRunAs) {    
            NextPage = fileController.Cancel().getUrl();
            CaseViewPage = '/' + CS.Id;
        }
        Test.stopTest();
        System.assertEquals(CaseViewPage, NextPage);               
    }
/***************************************************************************************************
Method Name: LinkFileNavigationNoId
Method Type: Test Method
Version     : 1.0 
Created Date: 01/28/2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/                
    public static TestMethod void LinkFileNavigationNoId(){
        String NextPage;
        String CaseViewPage;    
        init();
        //Create Case 
        Case CS = TestUtilities.getCase();
        CS.Core_IPS_Supported_Product__c = SuppProd.Id;
        Database.insert(CS);
        system.assert(CS.Id != null);  
        //Set Page
        ////commented for Classic EOL :Tejaswini
     /*   PageReference PageRef = Page.Core_IPS_File_LinkToCase;
        Test.setCurrentPage(PageRef); */
        caseController = new ApexPages.StandardController(CS);  
        fileController = new Core_IPS_File_LinkToCase_Controller(caseController);
        Test.startTest();
        NextPage = fileController.Cancel().getUrl();
        CaseViewPage = '/500/o';
        System.assertEquals(CaseViewPage, NextPage);                   
        NextPage = fileController.Save().getUrl();
        CaseViewPage = '/500/o';
        System.assertEquals(CaseViewPage, NextPage);                   
        Test.stopTest();
        
    }
    
/***************************************************************************************************
Method Name:  init
Method Type: Test Data preparation Method
Version     : 1.0 
Created Date: 28rd Jan 2016
Description:   
Scenario Type: NA
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      01/28/2016              Create
****************************************************************************************************/   
    private static void init(){    
        Id RoleId;
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
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
        //Account 
        Accnt = new Account(); //TestUtilities Account creation has issues
        Accnt.Name = 'Test Account';
        Accnt.BillingCountryCode = 'USA';
        Accnt.BillingStateCode = 'AL';
        Accnt.BillingCity = 'Alabama';
        Accnt.BillingStreet = 'street';
        Accnt.Core_IPS_Active__c = true;
        Database.insert(Accnt);
        system.assert(Accnt.Id != null);
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
        SuppProd = TestUtilities.getSupportedProduct();
        SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
        SuppProd.Core_Product__c = Prod.id;
        SuppProd.Core_Supported_Product_Name__c = Prod.Name;
        SuppProd.Core_EOIS__c = false;
        Database.insert(SuppProd);
        system.assert(SuppProd.Id != null);
        // Custom Setting
        List<Core_IPS_Error_Code__c> lstIPSErrorCodes = new List<Core_IPS_Error_Code__c>();
        for (Integer i = 0; i < 3; i++) {
            Core_IPS_Error_Code__c IPSErrorCode = new Core_IPS_Error_Code__c();
            if (i == 0) {    
                IPSErrorCode.Name = 'F104';
                IPSErrorCode.Core_Error_Message__c = 'Msg1';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
            if (i == 1) {    
                IPSErrorCode.Name = 'F105';
                IPSErrorCode.Core_Error_Message__c = 'Msg2';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
            if (i == 2) {    
                IPSErrorCode.Name = 'F106';
                IPSErrorCode.Core_Error_Message__c = 'Msg3';
                lstIPSErrorCodes.add(IPSErrorCode);
            }
        }
        Database.insert(lstIPSErrorCodes);        
    } 
    
    
}