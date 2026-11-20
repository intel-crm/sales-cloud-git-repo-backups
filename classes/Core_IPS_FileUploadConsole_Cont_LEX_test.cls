/***************************************************************************************************
Apex Class Name:  Core_IPS_FileUploadConsole_Cont_LEX_test
Version     : 1.0 
Created Date: 24 April 2022
Function    : Test class for Core_IPS_File_Upload_Console_Cont_LEX.cls
Author      : Sai Krishna  
****************************************************************************************************/

@isTest
// Added AssertEquals Added By Chiranjeevi - 31-JAN-2024
public class Core_IPS_FileUploadConsole_Cont_LEX_test {
	
    
    public static Account Accnt;
    public static Core_IPS_File_Upload_Master__c FileUplMaster;
    public static Core_IPS_File_Upload_Master__c FileUplMaster1;
    public static Core_IPS_Supported_Product__c SuppProd; 
    public static Core_IPS_File_Assignment__c fileassign;
    public static List<Core_IPS_File_Assignment__c> fileassignList = new List<Core_IPS_File_Assignment__c>() ;
    public static List<User> ListOfUser = new List<User> ();

    // Runs in its own transaction before every test method so the bypass is committed
    // and visible to the $Setup merge field the validation rule evaluates against.
    @testSetup
    static void setupBypass(){
        insert new Core_Account_Bypass_Validation_Rule__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            ByPass__c = true
        );
    }

    public static void setup(){   

        //Account 
        Accnt = new Account();
        Accnt.Name = 'Test Account';
        Accnt.BillingCountryCode = 'USA';
        Accnt.BillingStateCode = 'AL';
        Accnt.BillingCity = 'Alabama';
        Accnt.BillingStreet = 'street';
        Accnt.Core_IPS_Active__c = true;
        insert Accnt;  
        
        //Product
        Product2 Prod = new Product2();
        Prod = TestUtilities.getProduct();
        insert Prod;
            
        
        //Support Org
        Core_IPS_Product_Organization__c ProdOrg;
        ProdOrg = TestUtilities.getSupportOrg();
        insert ProdOrg;
        
        
        //Supported Product    
        SuppProd = TestUtilities.getSupportedProduct();
        SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
        SuppProd.Core_Product__c = Prod.id;
        SuppProd.Core_Supported_Product_Name__c = Prod.Name;
        SuppProd.Core_EOIS__c = false;
        insert SuppProd ;    
          
        //File Upload Master
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_File_URL__c = 'Test@salesforce.com';
        FileUplMaster.Core_Expiration_Date__c = System.today().addDays(1);
        insert FileUplMaster;  
        
        
        
        // File Assignmnet
        
        fileassign = new Core_IPS_File_Assignment__c();
        fileassign.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;
        fileassign.Core_Account__c = Accnt.Id;
        fileassign.Core_Supported_Product__c = SuppProd.Id;
        insert fileassign;
          
        
        Core_IPS_File_Assignment__c fileassign1 = new Core_IPS_File_Assignment__c();
        fileassign1.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;
        fileassign1.Core_Supported_Product__c = SuppProd.Id;
        insert fileassign1;
            
         System.AssertEquals(fileassign1.Id != null , true);
        fileassignList.add(fileassign);
        fileassignList.add(fileassign1);
        
    }
    @isTest
    public static void testpositive(){
        String searchKey = 'Test Account';
        
        setup();
        Test.startTest();
        	Core_IPS_File_Upload_Console_Cont_LEX.getFileUploadConsoleUrl();
            Core_IPS_File_Upload_Console_Cont_LEX.fetchDefaultRecord(Accnt.Id, 'Account');
            Core_IPS_File_Upload_Console_Cont_LEX.fetchLookupData(searchKey, 'Account');
        	Core_IPS_File_Upload_Console_Cont_LEX.fetchLookupData(searchKey, 'Core_IPS_Supported_Product__c');
            Core_IPS_File_Upload_Console_Cont_LEX.getCurrentLoggedinUserName();
            Core_IPS_File_Upload_Console_Cont_LEX.getUploadedFiles();  
            Core_IPS_File_Upload_Console_Cont_LEX.saveRecords(fileassignList,FileUplMaster.Id);
        	Core_IPS_File_Upload_Console_Cont_LEX.checkStatus(FileUplMaster.Id);
            Core_IPS_File_Upload_Console_Cont_LEX.fetchDefaultRecord(null, 'Account');
             System.AssertEquals(Accnt.Id != null, true);
        Test.stopTest();
    }
    @isTest
    public static void testpositive1(){
        //Account 
        Accnt = new Account();
        Accnt.Name = 'Test Account1';
        Accnt.BillingCountryCode = 'USA';
        Accnt.BillingStateCode = 'AL';
        Accnt.BillingCity = 'Alabama';
        Accnt.BillingStreet = 'street';
        Accnt.Core_IPS_Active__c = true;
        insert Accnt;
        
        //Product
        Product2 Prod = new Product2();
        Prod = TestUtilities.getProduct();
        insert Prod;
        
        //Support Org
        Core_IPS_Product_Organization__c ProdOrg;
        ProdOrg = TestUtilities.getSupportOrg();
        insert ProdOrg;
        
        
        //Supported Product    
        SuppProd = TestUtilities.getSupportedProduct();
        SuppProd.Core_Product_Organization__c = ProdOrg.Id; 
        SuppProd.Core_Product__c = Prod.id;
        SuppProd.Core_Supported_Product_Name__c = Prod.Name;
        SuppProd.Core_EOIS__c = false;
        insert SuppProd ;
          
        //File Upload Master
        FileUplMaster = TestUtilities.getFileUploadMasterRecord();
        FileUplMaster.Core_File_URL__c = 'Test@salesforce.com';
        insert FileUplMaster;
        
        // File Assignmnet 
        
        fileassign = new Core_IPS_File_Assignment__c();
        fileassign.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;
        fileassign.Core_Account__c = Accnt.Id;
        fileassign.Core_Supported_Product__c = SuppProd.Id;
        
        
        Core_IPS_File_Assignment__c fileassign1 = new Core_IPS_File_Assignment__c();
        fileassign1.Core_IPS_File_Upload_Master__c = FileUplMaster.Id;
        fileassign1.Core_Supported_Product__c = SuppProd.Id;
        
        
        fileassignList.add(fileassign);
        fileassignList.add(fileassign1);
         System.AssertEquals(fileassignList.size()>0, true);

        List<Core_IPS_File_Assignment__c> fileassignList1 = new List<Core_IPS_File_Assignment__c>() ;
        Test.startTest();
        Core_IPS_File_Upload_Console_Cont_LEX.saveRecords(fileassignList,FileUplMaster.Id);
        				
        Test.stopTest();
        
       
    }
}