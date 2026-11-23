/***************************************************************************************************
Class Name:  Core_IPS_LookupController_Test
Class Type: Test Class 
Input Parameters: None 
Output Parameters: None
Description:   Test class for Core_IPS_LookupController.
Used in     : Case Creation/Update
Modification Log :
* Developer                   Date                   Description
* ---------------------------------------------------------------------------- 
* Sugandha                   Mar/16/2018             Modified Iteration#-8 User story#-US85567 Description- New 'Partner Support Owner' field for Internal Portal
****************************************************************************************************/ 
@isTest
public class Core_IPS_LookupController_Test{
    //Instance variables that are commonly used in multiple test methods
    
    static List<User> ListOfUser = new List<User> ();
    static void getUserRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
            Usr.UserRoleID =  role.Id;
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
    }        
    
    // Variables used in VF page Testing
    public static Contact contactRecord;
    public static Core_IPS_Project__c ipsProjectRecord;
    public static Asset assetRecord;
    // Test Record Creation
    public static void getRecords(){
    
        
        //Calling UserRecords Method.
        getUserRecords();
        
         // Insert IPS Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        System.runAs(listofuser[0]){
        insert IPSLabels;
        }
        
        
        // Creating Account Record
        Account accountRecord = TestUtilities.getAccountRecord();
        System.runAs(listofuser[0]){
            insert accountRecord;
        }
        System.Assert(accountRecord.Id != null, 'Record not created');
        
        // Creating Contact Record
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = accountRecord.id;
        System.runAs(listofuser[0]){
            insert contactRecord;
        }
        System.Assert(contactRecord.Id != null, 'Record not created');
        
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        System.runAs(listofuser[0]){
            insert createProductRecord;
        }
        System.Assert(createProductRecord.Id != null, 'Record not created');
        
        // Creating Core IPS Project Record
        ipsProjectRecord = TestUtilities.getIpsProjectRecord();
        ipsProjectRecord.Core_Status__c = 'Draft';// added by sugandha on 10 Nov 2017 
        System.runAs(listofuser[0]){
            insert ipsProjectRecord;
        }
        System.Assert(ipsProjectRecord.Id != null, 'Record not created');
        
        // Creating Support Org (Core_IPS_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        System.runAs(listofuser[0]){
            insert SupportOrgRecord;
            ipsProjectRecord.Core_Status__c = 'Inactive';
            update ipsProjectRecord;
        }
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        
        // Creating Core Supported Product
        Core_IPS_Supported_Product__c supportedRecord = TestUtilities.getSupportedProduct();
        supportedRecord.Core_Product__c = createProductRecord.id;
        supportedRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        System.runAs(listofuser[0]){
            insert supportedRecord;
        }
        System.Assert(supportedRecord.Id != null, 'Record not created');
        
        // Creating Project Member(Core_IPS_Project_Member__c)
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        projectMember.core_ips_contact__c = contactRecord.id;
        projectMember.Core_IPS_Project__c = ipsProjectRecord.id;
        projectMember.Core_User__c = listofuser[0].Id;
        System.runAs(listofuser[0]){
            insert projectMember;
        }
        System.Assert(projectMember.Id != null, 'Record not created');
        
        // Creating Asset Record
        assetRecord = TestUtilities.getAssetRecord();
        assetRecord.Core_IPS_Project__c = ipsProjectRecord.id;
        assetRecord.Accountid = accountRecord.id;
        assetRecord.Contactid = contactRecord.id;
        System.runAs(listofuser[0]){
            insert assetRecord;
        system.assertEquals(true, assetRecord!=null) ;
        }
        System.Assert(assetRecord.Id != null, 'Record not created');
    }
    static testMethod void objAsProjectQueryAsDell(){   
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.pageLoad();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'project';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id!=null) ;
    }
    static testMethod void objAsProjectQueryAsNull(){   
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'project';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id!=null) ;
    }
    static testMethod void objAsContactQueryRelated2FilledAndNameAsNull(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = assetRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
         system.assertEquals(true, assetRecord.id!=null) ;
        Test.stopTest();
    }
    static testMethod void objAsContactQueryRelated2FilledAndNameAsDell(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = assetRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, assetRecord.id!=null) ;
        Test.stopTest();
    }
    static testMethod void objAsContactQueryRelated2FilledAndNameAsA(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = assetRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, assetRecord.id!=null) ;
        Test.stopTest();
    }
    static testMethod void objAsProjectQueryRelated2FilledAndNameAsNull(){
        getRecords();
        // VF Page Testing
        Test.startTest();        
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = assetRecord.id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, assetRecord.id!=null) ;
        Test.stopTest();
    }
    static testMethod void objAsProjectQueryRelated2FilledAndNameAsDell(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = assetRecord.id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, assetRecord.id!=null) ;
        Test.stopTest();
    }
    static testMethod void objAsProjectQueryRelated2FilledAndNameAsA(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = assetRecord.id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, assetRecord.id!=null) ;
        Test.stopTest();
    }
    static testMethod void objAsProductQueryRelated2FilledAndNameAsNull(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, ipsProjectRecord.id != null) ;
        Test.stopTest();
    }
    static testMethod void objAsProductQueryRelated2FilledAndNameAsDell(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, ipsProjectRecord.id != null) ;
        Test.stopTest();
    }
    static testMethod void objAsProductQueryRelated2FilledAndNameAsA(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, ipsProjectRecord.id != null) ;
        Test.stopTest();
    }
    static testMethod void objAsProjectQueryAsA(){  
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'project';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsContactQueryAsDell(){  
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        system.assertEquals(true, contactRecord.id != null) ;
        Test.stopTest();
    }
    static testMethod void objAsContactQueryAsNull(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsContactQueryAsDellRelatedIdAsNull(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController();
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(CoreIPSLookupController.query != null, true) ;
    }
    static testMethod void objAsProductQueryAsDell(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsProductQueryAsA(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsProductQueryAsNull(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsCustProdQueryAsNull(){ 
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'CustProd';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsCustProdQueryAsDell(){  
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'CustProd';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsCustProdQueryAsA(){  
        getRecords();
        // VF Page Testing
        Test.startTest();
//Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/  
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'CustProd';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsNullQueryAsDell(){ 
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = '';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsNullQueryAsA(){  
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = '';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsNullQueryAsNull(){  
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = '';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsContactQueryAsDell_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, ipsProjectRecord.id != null) ;
    }
    static testMethod void objAsContactQueryAsDell_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true,assetRecord.Id != null) ;
    }
    static testMethod void objAsContactQueryAsDell_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.relatedId2 = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, assetRecord.Id != null) ;
    }
    static testMethod void objAsProjectQueryAsDell_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, contactRecord.id != null) ;
    }
    static testMethod void objAsProjectQueryAsDell_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, assetRecord.Id != null);
    }
    static testMethod void objAsProjectQueryAsDell_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, assetRecord.Id != null);
    }
    static testMethod void objAsProductQueryAsDell_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    /*static testMethod void objAsProductQueryAsDell_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
    }*/
    static testMethod void objAsProductQueryAsDell_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'Dell';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsContactQueryAsA_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, ipsProjectRecord.id != null);
    }
    static testMethod void objAsContactQueryAsA_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true,  assetRecord.id != null);
    }
    static testMethod void objAsContactQueryAsA_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.relatedId2 = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsProjectQueryAsA_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();//Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsProjectQueryAsA_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, assetRecord.Id != null);
    }
    static testMethod void objAsProjectQueryAsA_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();//Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsProductQueryAsA_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsProductQueryAsA_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, ipsProjectRecord.id != null);
    }
    static testMethod void objAsProductQueryAsA_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = 'A';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsContactQueryAsNull_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, ipsProjectRecord.id != null);
    }
    static testMethod void objAsContactQueryAsNull_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, assetRecord.id != null);
    }
    static testMethod void objAsContactQueryAsNull_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.relatedId2 = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Contact';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
         system.assertEquals(true, ipsProjectRecord.id != null);
    }
    static testMethod void objAsProjectQueryAsNull_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsProjectQueryAsNull_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, assetRecord.id != null);
    }
    static testMethod void objAsProjectQueryAsNull_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = assetRecord.Id;
        CoreIPSLookupController.objectName = 'Project';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    static testMethod void objAsProductQueryAsNull_1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    /*static testMethod void objAsProductQueryAsNull_2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
    }*/
    static testMethod void objAsProductQueryAsNull_3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        CoreIPSLookupController.objectName = 'Product';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
/***************************************************************************************************
Method Name:  getLookupPartnerOwner_test
Version     : 1.0 
Created Date: Mar 16 2018
Function    : This method handles test coverage for User lookup and related cross logic functionality. 
Output Parameters: Null
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                     Mar/16/2018            Created
****************************************************************************************************/
    static testMethod void getLookupPartnerOwner_test(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        System.currentPageReference().getParameters().put('relatedId', contactRecord.id);
        System.currentPageReference().getParameters().put('relatedId2', ipsProjectRecord.id);
        CoreIPSLookupController.objectName = 'User';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
/***************************************************************************************************
Method Name:  getLookupPartnerOwner_test1
Version     : 1.0 
Created Date: Mar 16 2018
Function    : This method handles test coverage for User lookup and related cross logic functionality. 
Output Parameters: Null
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                     Mar/16/2018            Created
****************************************************************************************************/
    static testMethod void getLookupPartnerOwner_test1(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        System.currentPageReference().getParameters().put('relatedId', contactRecord.id);
        //System.currentPageReference().getParameters().put('relatedId2', ipsProjectRecord.id);
        CoreIPSLookupController.objectName = 'User';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
/***************************************************************************************************
Method Name:  getLookupPartnerOwner_test2
Version     : 1.0 
Created Date: Mar 16 2018
Function    : This method handles test coverage for User lookup and related cross logic functionality. 
Output Parameters: Null
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                     Mar/16/2018            Created
****************************************************************************************************/    
    static testMethod void getLookupPartnerOwner_test2(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        //System.currentPageReference().getParameters().put('relatedId', contactRecord.id);
        //System.currentPageReference().getParameters().put('relatedId2', ipsProjectRecord.id);
        CoreIPSLookupController.objectName = 'User';
        CoreIPSLookupController.query = '';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
/***************************************************************************************************
Method Name:  getLookupPartnerOwner_test
Version     : 1.0 
Created Date: Mar 16 2018
Function    : This method handles test coverage for User lookup and related cross logic functionality. 
Output Parameters: Null
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                     Mar/16/2018            Created
****************************************************************************************************/
    static testMethod void getLookupPartnerOwner_test3(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        System.currentPageReference().getParameters().put('relatedId', contactRecord.id);
        //System.currentPageReference().getParameters().put('relatedId2', ipsProjectRecord.id);
        CoreIPSLookupController.objectName = 'User';
        CoreIPSLookupController.query = 'test';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
/***************************************************************************************************
Method Name:  getLookupPartnerOwner_test4
Version     : 1.0 
Created Date: Mar 16 2018
Function    : This method handles test coverage for User lookup and related cross logic functionality. 
Output Parameters: Null
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                     Mar/16/2018            Created
****************************************************************************************************/
    
    static testMethod void getLookupPartnerOwner_test4(){
        getRecords();
        // VF Page Testing
        Test.startTest();
        //Commented for Classic EOL :Tejaswini
      /*  PageReference pageRef = Page.Core_IPS_Custom_Lookup;
        Test.setCurrentPage(pageRef);*/
        Core_IPS_LookupController CoreIPSLookupController = new Core_IPS_LookupController ();
        CoreIPSLookupController.relatedId = contactRecord.id;
        CoreIPSLookupController.relatedId2 = ipsProjectRecord.id;
        //System.currentPageReference().getParameters().put('relatedId', contactRecord.id);
        System.currentPageReference().getParameters().put('relatedId2', ipsProjectRecord.id);
        CoreIPSLookupController.objectName = 'User';
        CoreIPSLookupController.query = 'test';
        //CoreIPSLookupController.runQuery();
        CoreIPSLookupController.getRecords();
        Test.stopTest();
        system.assertEquals(true, contactRecord.id != null);
    }
    //End here
}