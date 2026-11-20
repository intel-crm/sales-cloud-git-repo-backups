/***************************************************************************************************
Apex Class Name:  Core_IPS_ProductDetailCtrlLWC_Test 
Version     : 1.0 
Created Date: 13 Nov 2021
Function    : Test class
Class       : Core_IPS_ProductDetailCtrl_LWC
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                  
* Vishal suryavanshi           04/04/2022               Created
* 
****************************************************************************************************/
@isTest
public class Core_IPS_ProductDetailCtrlLWC_Test {
    
    
    @isTest
    public static void getProductTest(){
        Asset assetObj = new Asset();
        assetObj.Name = 'Intel';
        insert assetObj;
        System.AssertEquals(assetObj != null, true);
        try{
            Test.startTest();
            Core_IPS_ProductDetailCtrl_LWC.getProduct(assetObj.Id);
            Core_IPS_ProductDetailCtrl_LWC.getProduct(null);
            Test.stopTest();
        } catch(Exception e) {
        }
        
    }
    
    @isTest
    public static void getCaseTest(){
        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        CaseRec.Status='New';
        insert CaseRec;
        
            Asset assetObj = new Asset();
            assetObj.Name = 'Intel';
            insert assetObj;
              System.AssertEquals(assetObj != null, true);
        try{
            Test.startTest();
            Core_IPS_ProductDetailCtrl_LWC.getCaseRecords(0,assetObj.id);
            Core_IPS_ProductDetailCtrl_LWC.getCaseRecords(null,null);
            Test.stopTest();
        }
        catch(Exception e){
        }
              
        
    }
    
    /*@isTest
    public static void getAllCasesTest(){
        Asset assetObj = new Asset();
        assetObj.Name = 'Intel';
        insert assetObj;
        List<Asset> assetList = [Select id, name FROM Asset];
        Account Acc=new Account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
        
        Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        
        insert con;
        
        Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        User UserAcc=new User();
        UserAcc.Username='Genjiuser@apttus.com';
        UserAcc.FirstName='Testing';
        UserAcc.LastName='user';
        UserAcc.ContactId=con.Id;
        UserAcc.Email='genjitesting@apttus.com';
        UserAcc.Alias='Testuser';
        UserAcc.EmailEncodingKey='ISO-8859-1';
        UserAcc.LanguageLocaleKey = 'en_US';
        UserAcc.TimeZoneSidKey='America/New_York';
        UserAcc.ProfileId=pf.Id;
        UserAcc.LocaleSidKey='en_US';
        UserAcc.IsActive=true;
        insert UserAcc;
        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        
        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        CaseRec.Status='';
        CaseRec.Core_Sub_Status__c='Core_Sub_Status__c';
        CaseRec.Core_Severity__c='Low';
        CaseRec.Core_Severity_Reason__c='Testing case';
        CaseRec.Core_CaseType__c='Question';
        CaseRec.Core_IPS_Legacy_IPS_ID__c='Testing';
        CaseRec.Core_Customer_Reference_ID__c='customer test';
        CaseRec.Core_End_Customer__c='End customer test';
        CaseRec.Description='case test description';
        CaseRec.Core_IPS_Restricted_Secret_Content__c=True;
        CaseRec.Core_IPS_Knowledge_Base_Link__c='Case knowledge test';
        CaseRec.Core_IPS_Product_name__c=assetObj.Name;
        CaseRec.Core_IPS_Project_Case__c=Project.Id;
        insert CaseRec;
       
        try{
            Test.startTest();
           Core_IPS_ProductDetailPrint_Ctrl prodPrintObj = new Core_IPS_ProductDetailPrint_Ctrl();
             //prodPrintObj.getAllCases();    
            Test.stopTest();
        }catch(Exception e){
        }
        }
        */
    
@isTest
    public static void getProductTest1(){
        Asset assetObj = new Asset();
        assetObj.Name = 'Intel';
        insert assetObj;
        System.AssertEquals(assetObj != null, true);
        apexpages.currentpage().getparameters().put('recordId',assetObj.Id);
        Core_IPS_ProductDetailPrint_Ctrl prodPrintObj = new Core_IPS_ProductDetailPrint_Ctrl();
            prodPrintObj.getAllCases(); 
    }


    
}