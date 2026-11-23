@isTest
public class Core_IPS_Portal_Project_CTL_new_t {
    @isTest
    public static void AvailablecontactsforaddingtoprojectMembers_Test(){
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        // Contact con=new Contact();
        //con.Firstname='test';
        //con.lastname='test contact';
        //con.Email='test@gmail.com';
        //con.AccountId=Acc.Id;
        //insert con;
        Test.startTest();
        try{
            Core_IPS_Portal_Project_Controller.AvailablecontactsforaddingtoprojectMembers(Project.id);
            
        }
        catch(exception e)
        {
        }     
        Test.stopTest();
    }
     @isTest
    public static void AvailableIPSProducts_Test(){
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_IPS_Project__c=Project.Id;
        insert assetProduct;
        System.assert(assetProduct.Id != null, 'Record not created');

        list<Id> lstId = new list<Id>();
        lstId.add(assetProduct.Id);
        Test.startTest();
        try{
            Core_IPS_Portal_Project_Controller.AvailableIPSProducts(Project.id);
            // Core_IPS_Portal_Project_Controller.upsertIPSProducts(lstId,Project.id);
        }
        catch(exception e){}     
        Test.stopTest();
        
        
    }
    @isTest
    public static void createProjects_Test(){
        Set<String> customerUserTypes = new Set<String> {'Executive', 'Manager', 'Worker'};
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
        System.assert(Acc.Id != null, 'Record not created');

        Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        con.MailingCountry='India';
        insert con;
        System.assert(con.Id != null, 'Record not created');

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs ( thisUser ) {
            UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
            Profile p = [select id from profile where name = 'IPS External Customer' limit 1];
            
            User newUser = new User(
                UserRoleId = ur.Id,
                profileId = p.id,
                username = 'newUser22@yahoo.com',
                email = 'pb22@ff.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
            );
            insert newUser;  
            System.assert(newUser.Id != null, 'Record not created');

           Core_IPS_Project__c Project=new Core_IPS_Project__c();
           Project.Name='test project';
           Project.Core_Project_Description__c='test description';
           Project.Core_Status__c='Draft';
           upsert Project;
            Core_IPS_Project_Member__c ProjectMember=new Core_IPS_Project_Member__c();
            ProjectMember.Core_IPS_Project__c=Project.id;
            ProjectMember.Core_Status__c='Active';
            insert ProjectMember;
            System.assert(ProjectMember.Id != null, 'Record not created');

            list<Id> lstId = new list<Id>();
            lstId.add(con.Id);   
            asset assetProduct=new asset();
            assetProduct.Name='TestAsset';
            assetProduct.Core_IPS_Project__c=Project.Id;
            insert assetProduct;
            System.assert(assetProduct.Id != null, 'Record not created');

            list<Id> AlstId = new list<Id>();
            AlstId.add(assetProduct.Id);
            Test.startTest();
            Core_IPS_Portal_Project_Controller.createProjects(Project.Name,Project.Core_Project_Description__c,true,true,newUser.username);
            Core_IPS_Portal_Project_Controller.upsertProjectMembers(lstId,Project.id); 
            //Core_IPS_Portal_Project_Controller.upsertIPSProducts(AlstId,Project.id);
            //Core_IPS_Portal_Project_Controller.updateAssertsStatus(AlstId,Project.id);
            Test.stopTest();
        }
        
    }
     @istest
    public static void getChildIPSProdctsToProject_test(){
        List<Core_IPS_Project__c> Proj=new List<Core_IPS_Project__c>();
        Core_IPS_Project__c Project=new  Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        Proj.add(project);
        insert Proj;
        System.assert(Proj[0].Id != null, 'Record not created');

        Test.startTest();
        Core_IPS_Portal_Project_Controller.getChildIPSProdctsToProject(Proj[0].id);
        Test.stopTest();   
        
    }
     @isTest
    public static void getcaseRecordsUnderprojectTest(){
        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        CaseRec.Status='Open';
        CaseRec.Core_Sub_Status__c='Core_Sub_Status__c';
        CaseRec.Core_Severity__c='Low';
        CaseRec.Core_Severity_Reason__c='Testing case';
        CaseRec.Core_CaseType__c='Question';
        CaseRec.Description='case test description';
        CaseRec.Core_IPS_Restricted_Secret_Content__c=True;
        CaseRec.Core_IPS_Knowledge_Base_Link__c='Case knowledge test';
        CaseRec.Core_IPS_Product_name__c='Test product';
        CaseRec.Core_IPS_Project_Case__c=Project.Id;
        insert CaseRec;
        System.assert(CaseRec.Id != null, 'Record not created');

        String projId = Project.Id; 
        Core_IPS_Portal_Project_Controller.getcaseRecordsUnderproject(CaseRec.id,'Load Data');
        Core_IPS_Portal_Project_Controller.getcaseRecordsUnderproject(CaseRec.id,'All Data');
    }
     @isTest
    public static void removeIPSProductsfromProjTest(){
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        insert Project;
        System.assert(Project.Id != null, 'Record not created');

        Core_IPS_Product__c projectProduct = new Core_IPS_Product__c();
        projectProduct.Core_IPS_Project__c = Project.Id;
        projectProduct.Core_IPS_IsAutoApprove__c=true;
        projectProduct.Status__c='Submitted Pending';
        projectProduct.Core_IsSubmitted_Header__c=true;
        
        
        
        Product2 pdtObj = new Product2();
        pdtObj.Core_Product_Name_EPM_ID__c='750235';
        pdtObj.IsActive = true;
        pdtObj.Core_Code_Name_EPM_ID__c ='750235';
        pdtObj.Core_Sales_Visible_Flag__c = false;
        pdtObj.IsActive = true;
        pdtObj.Core_Product_Status__c= 'Active';
        pdtObj.Core_IPS_Visible_Flag_External__c = true;
        pdtObj.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        pdtObj.Core_Product_Org__c = 'IPS';
        pdtObj.Core_Hierarchy_ID__c = '43';
        pdtObj.Core_Unique_ID__c = pdtObj.Name; 
        pdtObj.Name = 'testProd5';   
        insert pdtObj;
        System.assert(pdtObj.Id != null, 'Record not created');

        List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
        prodOrgList = TestUtilities.getListOfSupportOrg(3);
        insert prodOrgList;
        System.assert(prodOrgList[0].Id != null, 'Record not created');

        Core_IPS_Supported_Product__c SupportedProductRecord = new Core_IPS_Supported_Product__c();
        SupportedProductRecord.Core_Product__c = pdtObj.id;
        SupportedProductRecord.Core_Product_Organization__c = prodOrgList.get(0).id;
        SupportedProductRecord.Core_Product_EPM_ID__c=pdtObj.core_code_name_EPM_ID__c;
        SupportedProductRecord.core_EOIS__C=false; 
        SupportedProductRecord.Core_Flag_Status__c = 'Approval Required';
        insert SupportedProductRecord;
        System.assert(SupportedProductRecord.Id != null, 'Record not created');

        
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_IPS_Project__c=Project.Id;
        assetProduct.Core_Supported_Product__c=SupportedProductRecord.Id;
        insert assetProduct;
        System.assert(assetProduct.Id != null, 'Record not created');

        
        list<Id> lstId = new list<Id>();
        lstId.add(assetProduct.Id);
        Test.startTest();
        String projectID=project.Id;
        Core_IPS_Portal_Project_Controller.upsertIPSProducts(lstId, projectID);
       // Core_IPS_Portal_Project_Controller.removeIPSProductsfromProj(lstId, projectID);
         //       Core_IPS_Portal_Project_Controller.addOrRemoveProducts(lstId,lstId, projectID);
        
        Test.stopTest();
        
    }
    

}