@isTest
public class Core_IPS_Portal_Project_Controller_Test {
    
    
    @isTest
    public static void existingProjectMembers_Test(){
        try{
            Set<String> customerUserTypes = new Set<String> {'Executive', 'Manager', 'Worker'};
             Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
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
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        con.MailingCountry = 'India';
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');
        
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
        UserAcc.ProfileId= pf.Id;
        UserAcc.LocaleSidKey='en_US';
        insert UserAcc;
        System.assert(UserAcc.Id != null, 'Record not created');
        
            system.runas(UserAcc) {
                Core_IPS_Project__c Project=new Core_IPS_Project__c();
                Project.Name='test project';
                Project.Core_Project_Description__c='test description';
                Project.Core_Status__c='Active';
                insert Project;
                System.assert(Project.Id != null, 'Record not created');
        
                Core_IPS_Project_Member__c ProjectMember=new Core_IPS_Project_Member__c();
                ProjectMember.Core_IPS_Project__c=Project.id;
                ProjectMember.Core_Status__c='Active';
                ProjectMember.Core_IPS_Contact__c = con.Id; //Added by Nuthana
                insert ProjectMember;
                System.assert(ProjectMember.Id != null, 'Record not created');
        
                list<Id> lstId = new list<Id>();
                lstId.add(con.Id);          
                Core_IPS_Portal_ProjectUtility_LWC.upsertProjectMembers(lstId,Project.id);

                    Test.startTest();
                    Core_IPS_Portal_ProjectUtility_LWC.existingProjectMembers(Project.id);
                    Core_IPS_Portal_Project_Controller.upsertProjectMembers(lstId,Project.id); 
                    
                    //  Core_IPS_Portal_ProjectUtility_LWC.addProjectMem(lstId,Project.id); 
                    // Core_IPS_Portal_ProjectUtility_LWC.removeProjectMem(lstId,Project.id);
                    //  Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProjMembers(lstId,lstId,Project.id); 
                    Test.stopTest();
            }
            
        }catch(Exception e){
        }
    }
    
    
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
    public static void existingIPSProducts_Test(){
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
        //insert projectProduct;
        Test.startTest();
        try{
            Core_IPS_Portal_ProjectUtility_LWC.existingIPSProducts(Project.id);
            // Core_IPS_Portal_Project_Controller.upsertProjectMembers(,Project.id);
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
         Profile pf= [Select Id from profile where Name='IPS External Customer'];
         User AccountOwner= TestUtilities.getAccountOwner();
              System.runas(AccountOwner){
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
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        con.MailingCountry = 'India';
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');
             
          }
          Contact con = [select Id from Contact Limit 1];
        
       
        
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
        UserAcc.ProfileId= pf.Id;
        UserAcc.LocaleSidKey='en_US';
        insert UserAcc; 
        System.assert(UserAcc.Id != null, 'Record not created');
        
                system.runas(UserAcc){
                Core_IPS_Project__c Project=new Core_IPS_Project__c();
                Project.Name='test project';
                Project.Core_Project_Description__c='test description';
                Project.Core_Status__c='Draft';
                insert Project;
                System.assert(Project.Id != null, 'Record not created');
        
                Test.startTest();
                Core_IPS_Portal_Project_Controller.createProjects(Project.Name,Project.Core_Project_Description__c,true,true,UserAcc.Username);
                Test.stopTest();
             }
              
        }
    @isTest
    public static void editProjectRecord_Test(){
        List<Core_IPS_Project__c> Proj=new List<Core_IPS_Project__c>();
        Core_IPS_Project__c Project=new  Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        Proj.add(project);
        insert Proj;
        System.assert(Proj[0].Id != null, 'Record not created');
        
        Test.startTest();
        Core_IPS_Portal_ProjectUtility_LWC.editProjectRecord(Proj[0].id,Proj[0]);
        Test.stopTest();   
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
        Core_IPS_Portal_Project_Controller.getcaseRecordsUnderproject(Project.Id,'Load Data');
        Core_IPS_Portal_Project_Controller.getcaseRecordsUnderproject(Project.Id,'All Data');
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
       
        asset assetProduct2=new asset();
        assetProduct2.Name='TestAsset2';
        //     assetProduct2.Core_IPS_Project__c=Project.Id;
        //     assetProduct2.Core_Supported_Product__c=SupportedProductRecord.Id;
        insert assetProduct2;
        System.assert(assetProduct2.Id != null, 'Record not created');
       
        list<Id> lstId = new list<Id>();
        lstId.add(assetProduct.Id);
        
        List<Id> selectedIdList = new List<Id>();
        selectedIdList.add(assetProduct.Id);
        selectedIdList.add(assetProduct2.Id);
        Test.startTest();
        String projectID=project.Id;
        Core_IPS_Portal_Project_Controller.upsertIPSProducts(lstId, projectID);
        //       Core_IPS_Portal_ProjectUtility_LWC.upsertIPSProducts(lstId, projectID);
        Core_IPS_Portal_ProjectUtility_LWC.removeIPSProductsfromProj(lstId, projectID);
        Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProducts(lstId,selectedIdList, projectID);
        Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProducts(selectedIdList,lstId, projectID);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void removeIPSProductsfromProjTest2(){
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
       
        asset assetProduct2=new asset();
        assetProduct2.Name='TestAsset2';
        assetProduct2.Core_IPS_Project__c=Project.Id;
        assetProduct2.Core_Supported_Product__c=SupportedProductRecord.Id;
        insert assetProduct2;
        System.assert(assetProduct2.Id != null, 'Record not created');
       
        list<Id> lstId = new list<Id>();
        lstId.add(assetProduct.Id);
        
        List<Id> selectedIdList = new List<Id>();
        selectedIdList.add(assetProduct.Id);
        selectedIdList.add(assetProduct2.Id);
        Test.startTest();
        String projectID=project.Id;
        Core_IPS_Portal_Project_Controller.upsertIPSProducts(lstId, projectID);
        //       Core_IPS_Portal_ProjectUtility_LWC.upsertIPSProducts(lstId, projectID);
        Core_IPS_Portal_ProjectUtility_LWC.removeIPSProductsfromProj(lstId, projectID);
        Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProducts(lstId,selectedIdList, projectID);
        Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProducts(selectedIdList,lstId, projectID);
        
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void getOwnerOfProject_Test(){
        try{
              Set<String> customerUserTypes = new Set<String> {'Executive', 'Manager', 'Worker'};
             Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
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
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
		System.assert(conLst[0].Id != null, 'Record not created');
        
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
        UserAcc.ProfileId= pf.Id;
        UserAcc.LocaleSidKey='en_US';
        insert UserAcc;
        System.assert(UserAcc.Id != null, 'Record not created');
        
                Core_IPS_Project__c Project=new Core_IPS_Project__c();
                Project.Name='test project';
                Project.Core_Project_Description__c='test description';
                Project.Core_Status__c='Draft';
                Project.OwnerId = UserAcc.id;
                insert Project;
                System.assert(Project.Id != null, 'Record not created');

                
                Core_IPS_Portal_ProjectUtility_LWC.getOwnerOfProject(Project.id);
              
        }catch(Exception e){
        }
        
    }
    @istest
    public static void addOrRemoveProjMembers_test(){
        
        /*    
account Acc=new account();
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

Contact con1=new Contact();
con.Firstname='tes1t';
con.lastname='test contact';
con.Email='tes1t@gmail.com';
con.AccountId=Acc.Id;
insert con1;
*/
        Test.startTest(); 
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        //User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
        
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston'+Crypto.getRandomLong()+'@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        System.assert(usr.Id != null, 'Record not created');
       
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA'
        );
        
        insert newAccount;        
        System.assert(newAccount.Id != null, 'Record not created');

        Contact cc = new Contact(  
            
            FirstName='Joe',
            LastName='Schmoe',
            Email='Joe.Schmoe@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            //Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc;
        System.assert(cc.Id != null, 'Record not created');

        Core_IPS_Project__c pr = new Core_IPS_Project__c();
        pr.name = 'test';
        pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
        pr.Core_IPS_EnableMemberasInterestedParties__c =True;
        insert pr;   
        System.assert(pr.Id != null, 'Record not created');

        Core_IPS_Intel_Support_Team__c steam = new Core_IPS_Intel_Support_Team__c();
        steam.Core_IPS_Project__c = pr.id;   
        steam.Status__c='Active';
        steam.Core_IPS_User__c=usr.id;           
        insert steam;
        System.assert(steam.Id != null, 'Record not created');

        Map<Id,Core_IPS_Intel_Support_Team__c> mapTeam = new Map<Id,Core_IPS_Intel_Support_Team__c>();
        // mapTeam.put(id,pr.id);  
        
        List<Case> caselst = new List<Case>();
        
        Case cas = new Case();          
        cas.Core_IPS_Project_Case__c = pr.id;
        cas.status = 'open';   
        cas.AccountId=newAccount.Id;
        caselst.add(cas);
        
        Case cas1 = new Case();          
        // cas1.Core_IPS_Project_Case__c = pr.id;
        cas1.status = 'open'; 
        cas1.AccountId=newAccount.Id;
        caselst.add(cas1);
        
        insert caselst;  
        System.assert(caselst[0].Id != null, 'Record not created');

        List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
        
        Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
        party.User__c = usr.id;
        party.Case__c = cas.id;
        party.Contact__c=cc.id;
        party.Active__c= true ;
        party.Type__c= 'External';
        Iparty.add(party);
        
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.User__c = usr.id;
        party1.Case__c = cas1.id;
        party1.Contact__c=cc.id;
        Iparty.add(party1);   
        insert Iparty;
        System.assert(Iparty[0].Id != null, 'Record not created');

        List<Core_IPS_Project_Member__c> Pmem = new List<Core_IPS_Project_Member__c>();
        
        Core_IPS_Project_Member__c mem = new Core_IPS_Project_Member__c();
        mem.Core_IPS_Project__c = pr.id;
        mem.Core_User__c = usr.id;
        mem.Core_IPS_Contact__c = cc.id;
        mem.Core_Status__c='Active';
        mem.Core_IPS_Project__c=cas.Core_IPS_Project_Case__c;
        
        
        Pmem.add(mem);
        //Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' 
        //AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false
        Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
        mem1.Core_IPS_Project__c = pr.id;
        mem1.Core_User__c = usr.id;
        mem1.Core_IPS_Contact__c = cc.id;
        mem1.Core_Status__c='Active';
        mem1.Core_Status__c='Active';
        mem1.Core_IPS_Project__c=cas.Core_IPS_Project_Case__c;
        Pmem.add(mem1);  
        
        insert Pmem;
        System.assert(Pmem[0].Id != null, 'Record not created');

        Contact cc1 = new Contact(  
            
            FirstName='Joe1',
            LastName='Schmoe1',
            Email='Joe.Schmoe1@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc1;
        System.assert(cc1.Id != null, 'Record not created');

        Contact cc2 = new Contact(  
            
            FirstName='Joe2',
            LastName='Schmoe2',
            Email='Joe.Schmoe2@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc2;
        System.assert(cc2.Id != null, 'Record not created');

        Contact cc3 = new Contact(  
            
            FirstName='Joe3',
            LastName='Schmoe3',
            Email='Joe.Schmoe3@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc3;
        System.assert(cc3.Id != null, 'Record not created');

        List<Id> addIdList = new List<Id>();
        addIdList.add(cc1.Id);
        addIdList.add(cc2.Id);
        List<Id> removeIdList = new List<Id>();
        removeIdList.add(cc3.Id);
        List<Id> addIdList1 = new List<Id>();
        addIdList1.add(cc1.Id);
        addIdList1.add(cc2.Id);
        List<Id> removeIdList1 = new List<Id>();
        removeIdList1.add(cc3.Id);
        set<Id> removeIdList2 = new set<Id>();
        removeIdList2.add(cc3.Id);
        Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProjMembers(addIdList, removeIdList1, pr.id);
        Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProjMembers(removeIdList1, addIdList, pr.id);
        
        
        //       Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProducts(initialProjMemIds,selectedProMemIds,Project.id);
        
        
    }
    //To cover getOwnerOfProject Method - Nuthana
    @istest
    public static void getOwnerOfProjectTest(){
    User AccountOwner= TestUtilities.getAccountOwner();
                   System.runas(AccountOwner){
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
              
          }
          Contact con = [select Id from Contact Limit 1];
    String profileId = [SELECT Id from Profile where Name='Partner'].Id;
    User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012@amamama.com',
            Username = 'puser00012@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
        System.runas(uu){
            Core_IPS_Project__c project = new Core_IPS_Project__c();
    		project.Name = 'test project';
    		project.Core_Project_Description__c = 'test description';
    		project.Core_Status__c = 'Draft';
    		project.OwnerId = uu.Id;
    		insert project;
	    
    	System.assert(project.Id != null, 'Record not created');
    
    	String result = Core_IPS_Portal_ProjectUtility_LWC.getOwnerOfProject(project.Id);
    
    	System.assertEquals(uu.ContactId, result, 'Returned ContactId should match owner');
            
        }
    
	}

    
    
    
    
}