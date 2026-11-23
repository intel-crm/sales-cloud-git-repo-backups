/***************************************************************************************************
Class Name:  Core_IPS_Project_Controller_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 11 Feb 2016
Function    : This class contains test coverage for Core_IPS_Project_Controller class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Project_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              01/02/2016                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_Project_Controller_Test {
    
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 25 Jan 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty       25/01/2016              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        UserRole role = new UserRole();
        role.name='Admin';
        insert role; 
        ListOfUser.get(0).UserRoleId= role.Id;
        List<Profile> ProfileList2 = [select id, name from Profile where name LIKE '%Sales Rep%' LIMIT 1];
        System.debug('ProfileList2[0].Id: '+ProfileList2[0].Id);
        ListOfUser.get(1).ProfileID=ProfileList2[0].Id;
        insert ListOfUser;
        System.debug('ListOfUser[1].ProfileID: '+ListOfUser[1].ProfileID);
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
    }
/***************************************************************************************************
Method Name:  ProjectNoDuplicate_test
Method Type: Test Method
Version     : 1.0 
Created Date: 1 Feb 2016
Description:  Testing with Project with no Duplicates
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/ 
    static testmethod void ProjectMethod_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Ips Labels added by Aayushi
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='Core_IPS_MPNDA_ErrorMsg'){
             IL.Value__c = 'A valid MPNDA is required prior to adding secondary Accounts to a Premier Support Project';
   
            }
            
            if(IL.name=='CoreStatus_Draft'){
             IL.Value__c = 'Draft';
   
            }
            
             if(IL.name=='Core_IPS_NonNDA_ErrorMSg'){
                IL.Value__c = 'Projects with multi-party Accounts should only have Accounts with NDAs   ' ;
            }
            
            if(IL.name=='Core_IPS_cndaErrorMsg'){
                IL.Value__c = 'Any existing Account must have a CNDA prior to adding additional Accounts to a Premier Support Project' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        //Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        System.runAs(ListOfUser.get(0)){
            ListOfContacts[0].AccountId = ListOfAccounts[0].Id;
            insert ListOfContacts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects_Test = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects_Test.get(0).name='ipsProjectNameTest';
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects_Test;
        ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
        }
        System.assert(ListOfIpsProjects_Test[0].Id != null, 'Record not created');        
        
        Core_IPS_Account__c acc = new Core_IPS_Account__c();
        acc.Core_Account__c = ListOfAccounts[0].Id;
        acc.Core_IPS_Project__c = ListOfIpsProjects_Test[0].Id;
        System.runAs(ListOfUser.get(0)){
            insert acc;
        }
        
        PageReference PageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(PageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects_Test[0].id);        
      
        Core_IPS_Project_Controller projectCntrl1 = new Core_IPS_Project_Controller(new ApexPages.StandardController(ListOfIpsProjects_Test[0]));
        Core_IPS_Project_Controller projectCntrl = new Core_IPS_Project_Controller();
        projectCntrl.displayExistingAccounts = true;
        //projectCntrl.displayAddSection = true;    //commented by Aayushi US80368
        projectCntrl.errorMsg = 'test';
        projectCntrl.AlreadySubmitted = true;
        
        Core_IPS_Project_Controller.IPSMemberWrapper wrpr = new Core_IPS_Project_Controller.IPSMemberWrapper();
        wrpr.Selected = true;
        wrpr.con = ListOfContacts[0];
        wrpr.Usr = ListOfUser.get(0);
        Core_IPS_Project_Controller.IPSAccountWrapper wrpr1 = new Core_IPS_Project_Controller.IPSAccountWrapper();
        wrpr1.Selected = true;
        wrpr1.acc = ListOfAccounts[0];
        wrpr1.participantTypeSelected = 'test';
        wrpr1.participants = new List<SelectOption>();
        projectCntrl1.changeStatusToSubmitted();
        Core_IPS_Project_Controller.getAccountsWrapper(String.valueOf(ListOfIpsProjects_Test[0].id));
        //projectCntrl.getExistingIPSAccountIds(String.valueOf(ListOfIpsProjects_Test[0].id));
        //projectCntrl.getExistingIPSContIds();
        //List<SelectOption> so = projectCntrl.getParticipantTypes();
        projectCntrl.addIPSAccounts();
        projectCntrl.addIPSAccountsAndDone();        
        projectCntrl.actionMethod();
        projectCntrl.checkPageException();
        Core_IPS_Project_Controller.getIPSUserType();
        //projectCntrl.getAccounts();
        Core_IPS_Project_Controller.getFAEAccounts();
        //projectCntrl.getAccountsByISO();        
        Core_IPS_Project_Controller.getManuallySharedAccounts();
        Core_IPS_Project_Controller.getSelectiveAccounts(String.valueOf(ListOfIpsProjects_Test[0].id));
        Set<Id> accIdset = new Set<Id>();
        accIdset.add(ListOfIpsProjects_Test[0].id);        
        Core_IPS_Project_Controller.getProjectMembers(accIdSet);
        // start modified by Aayushi US80368
        Core_IPS_Project_Controller.getAllIPSAccounts(accIdSet,true);
        Core_IPS_Project_Controller.getAllIPSAccounts(accIdSet,false);
        //end
        Core_IPS_Project_Controller.getAccountsByTeam();
        Core_IPS_Project_Controller.getAccountsByISO();
        projectCntrl1.throwPageException();
        projectCntrl.addIPSProjectMembers();
        projectCntrl.add();
        projectCntrl.addAndDone();
        projectCntrl.redirecttoparent();
        projectCntrl.cancel();
        
        Test.stopTest();
    }
    
    static testmethod void ProjectMethod_test1(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        User CommunityUser ;
        System.runAs(ListOfUser.get(0)){
           CommunityUser = TestUtilities.getCustomerUser('IPS External Customer'); 
        }
         
        // Create Ips Labels added by Aayushi
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
            
            if(IL.name=='Core_IPS_NonNDA_ErrorMSg'){
                IL.Value__c = 'Projects with multi-party Accounts should only have Accounts with NDAs   ' ;
            } 
            
            if(IL.name=='Core_IPS_cndaErrorMsg'){
                IL.Value__c = 'Any existing Account must have a CNDA prior to adding additional Accounts to a Premier Support Project' ;
            }

        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        //Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        System.runAs(ListOfUser.get(0)){
            ListOfContacts[0].AccountId = ListOfAccounts[0].Id;
            insert ListOfContacts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //added by naresh related to the Test Coverage Story US41854 on 5/30/16
        // inserting Product Orgs
         List<Core_IPS_Product_Organization__c> prodOrgList = TestUtilities.getListOfSupportOrg(1);
        System.runAs(ListOfUser.get(0)){
        insert prodOrgList;
        }
        //inserting products
        list<Product2> ProductList = TestUtilities.getListOfProduct(1);
        ProductList[0].Core_Code_Name_EPM_ID__c='L1 Id1';
        ProductList[0].Core_Hierarchy_ID__c='59';
        System.runAs(ListOfUser.get(0)){
        insert ProductList;
        }
        //inserting supported products
        List<Core_IPS_Supported_Product__c> SuppProductList=TestUtilities.getListOfSupportedProduct(1);
        SuppProductList[0].Core_Product__c = ProductList.get(0).id;
        SuppProductList[0].Core_Product_Organization__c = prodOrgList[0].id;
        SuppProductList[0].Core_Product_EPM_ID__c = ProductList.get(0).id;
        SuppProductList[0].core_EOIS__C = false;
        SuppProductList[0].Core_Flag_Status__c='Auto Approve';
        System.runAs(ListOfUser.get(0)){
        insert SuppProductList;
        }
        //end
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects_Test = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects_Test.get(0).name='ipsProjectNameTest';
        ListOfIpsProjects_Test.get(0).Core_Status__c = 'Draft';
        
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            // Create Ips Labels
       
            insert ListOfIpsProjects_Test;
            
        //added by naresh related to the Test Coverage Story US41854 on 5/30/16
        List<Core_IPS_Product__c> listProjectProduct = new List<Core_IPS_Product__c>();
        Core_IPS_Product__c projectProduct = new Core_IPS_Product__c();
        projectProduct.Core_IPS_Project__c = ListOfIpsProjects_Test[0].Id;
        projectProduct.Core_Supported_Product__c = SuppProductList[0].id;
        projectProduct.Core_IPS_IsAutoApprove__c=true;
        projectProduct.Status__c='Submitted Pending';
        projectProduct.Core_IsSubmitted_Header__c=true;
        //projectProduct.Core_Supported_Product__r.Core_Flag_Status__c=null;
        listProjectProduct.add(projectProduct); 
        insert listProjectProduct;
        //end
        //ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
         ListOfIpsProjects_Test = [select id, Name, core_status__c, Core_Number_of_Accounts__c, Core_Number_of_Products__c,Core_Number_of_Users__c,
                    (Select id,Status__c,Core_IPS_IsAutoApprove__c, Core_Supported_Product__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_IPS_Project__c,Core_IsSubmitted_Header__c from IPS_Products__r) 
                    from core_ips_project__c where id=:ListOfIpsProjects_Test[0].Id];           
        }
        System.assert(ListOfIpsProjects_Test[0].Id != null, 'Record not created');  
    
        Core_IPS_Account__c acc = new Core_IPS_Account__c();
        acc.Core_Account__c = [select id,accountid from  user  where id=:CommunityUser.id].accountid;
        acc.Core_IPS_Project__c = ListOfIpsProjects_Test[0].Id;
        System.runAs(ListOfUser.get(0)){
            insert acc;
        }
        Core_IPS_Project_Member__c PM =  TestUtilities.getProjectMember();
        PM.Core_IPS_Contact__c = [select id,contactid from  user  where id=:CommunityUser.id].contactid;
        PM.Core_IPS_Project__c =  ListOfIpsProjects_Test[0].Id;
        //PM.Core_User__c = CommunityUser.id;
         System.runAs(ListOfUser.get(0)){
            //insert PM;
        
        PageReference PageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(PageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects_Test[0].id);        
      
        Core_IPS_Project_Controller projectCntrl1 = new Core_IPS_Project_Controller(new ApexPages.StandardController(ListOfIpsProjects_Test[0]));
        Core_IPS_Project_Controller projectCntrl = new Core_IPS_Project_Controller();
        projectCntrl.displayExistingAccounts = true;
        //projectCntrl.displayAddSection = true;     //commented by Aayushi US80368
        projectCntrl.errorMsg = 'test';
        projectCntrl.AlreadySubmitted = true;
        
        Core_IPS_Project_Controller.IPSMemberWrapper wrpr = new Core_IPS_Project_Controller.IPSMemberWrapper();
        wrpr.Selected = true;
        wrpr.con = ListOfContacts[0];
        wrpr.Usr = ListOfUser.get(0);
        Core_IPS_Project_Controller.IPSAccountWrapper wrpr1 = new Core_IPS_Project_Controller.IPSAccountWrapper();
        wrpr1.Selected = true;
        wrpr1.acc = ListOfAccounts[0];
        wrpr1.participantTypeSelected = 'test';
        wrpr1.participants = new List<SelectOption>();
        projectCntrl1.changeStatusToSubmitted();
        //added by naresh related to the Test Coverage Story US41854 on 5/30/16   
        projectCntrl.contWrapperList= new List<Core_IPS_Project_Controller.IPSMemberWrapper>();  
        projectCntrl.contWrapperList.add(wrpr);
        projectCntrl.addIPSProjectMembers();     
        //end     
        }
        Test.stopTest();
    }
    static testmethod void ProjectMethod_test3(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        User CommunityUser ;
        System.runAs(ListOfUser.get(0)){
           CommunityUser = TestUtilities.getCustomerUser('IPS External Customer'); 
        }
         
        // Create Ips Labels added by Aayushi
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='Core_IPS_MPNDA_ErrorMsg'){
             IL.Value__c = 'A valid MPNDA is required prior to adding secondary Accounts to a Premier Support Project';
   
            }
            
            if(IL.name=='CoreStatus_Draft'){
             IL.Value__c = 'Draft';
   
            }
            
             if(IL.name=='Core_IPS_NonNDA_ErrorMSg'){
                IL.Value__c = 'Projects with multi-party Accounts should only have Accounts with NDAs   ' ;
            }
            
            if(IL.name=='Core_IPS_cndaErrorMsg'){
                IL.Value__c = 'Any existing Account must have a CNDA prior to adding additional Accounts to a Premier Support Project' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(4);      //modified by to add 3 accounts by Aayushi US80368
        System.runAs(ListOfUser.get(0)){
            ListOfAccounts[1].Core_CNDA_Number__c='123';                        //added CNDA value to accounts Aayushi US80368
            ListOfAccounts[2].Core_CNDA_Number__c='1234';
            insert ListOfAccounts;
                    }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        //Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        System.runAs(ListOfUser.get(0)){
            ListOfContacts[0].AccountId = ListOfAccounts[0].Id;
            insert ListOfContacts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects_Test = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects_Test.get(0).name='ipsProjectNameTest';
        ListOfIpsProjects_Test.get(0).Core_Status__c = 'Draft';
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects_Test;
        ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
        }
       /* Core_IPS_Project_Controller projectCntrlNew= new Core_IPS_Project_Controller();
        projectCntrlNew.addIPSProjectMembers();*/
        System.assert(ListOfIpsProjects_Test[0].Id != null, 'Record not created');        
        System.runAs(ListOfUser.get(0)){
                    TestUtilities.addAccMemProdToProject(ListOfIpsProjects_Test);
           
        }
        Core_IPS_Account__c acc = new Core_IPS_Account__c();
        acc.Core_Account__c = [select id,accountid from  user  where id=:CommunityUser.id].accountid;
        acc.Core_IPS_Project__c = ListOfIpsProjects_Test[0].Id;
       
        System.runAs(ListOfUser.get(0)){
            insert acc;
        }
        Core_IPS_Project_Member__c PM =  TestUtilities.getProjectMember();
        PM.Core_IPS_Contact__c = [select id,contactid from  user  where id=:CommunityUser.id].contactid;
        PM.Core_IPS_Project__c =  ListOfIpsProjects_Test[0].Id;
        //PM.Core_User__c = CommunityUser.id;
         System.runAs(ListOfUser.get(0)){
            //insert PM;
        
        PageReference PageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(PageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects_Test[0].id);        
      
        Core_IPS_Project_Controller projectCntrl1 = new Core_IPS_Project_Controller(new ApexPages.StandardController(ListOfIpsProjects_Test[0]));
        Core_IPS_Project_Controller projectCntrl = new Core_IPS_Project_Controller();
        ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c,Core_Status__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
        System.debug('Status'+ListOfIpsProjects_Test[0].Core_Status__c);
        projectCntrl1.changeStatusToSubmitted();
        List<Contact> ListOfContacts1 = TestUtilities.getListOfContact(1);
        List<Core_IPS_Account__c> projAccountList=[Select Id,Core_Account__c,Core_Account__r.OwnerId,Core_IPS_Project__c from Core_IPS_Account__c where Core_IPS_Project__c =:ListOfIpsProjects_Test[0].Id];
        
             System.debug('>>>SelAccountId>>> '+projAccountList[0].Core_Account__c);
            // System.runAs(ListOfUser.get(0)){         //commented by Aayushi as it was redundant US80368
            ListOfContacts1[0].AccountId = projAccountList[0].Core_Account__c;
            ListOfContacts1[0].Email='Contact1Dell2@gmail.com';
            ListOfContacts1[0].Core_IPS_Active__c=true;
            insert ListOfContacts1;
            
       // }
             System.debug('NEw Contact: '+ListOfContacts1[0].Id);
            Set<Id> projContact=new Set<Id>();
        List<Core_IPS_Project_Member__c> projMemList = [Select Id,Core_IPS_Contact__c,Core_IPS_Project__c from Core_IPS_Project_Member__c where Core_IPS_Project__c =:ListOfIpsProjects_Test[0].Id];
             for(Core_IPS_Project_Member__c projMem: projMemList){
                 projContact.add(projMem.Core_IPS_Contact__c);
             }
        projectCntrl.projectId=ListOfIpsProjects_Test[0].Id;
       // projectCntrl.getContactsWrapper(projContact);
        projectCntrl.addIPSProjectMembers();
       // start added by Aayushi US80368
       projectCntrl.addIPSAccounts();
       projectCntrl.addIPSAccountsAndDone();
       //end
        ListOfIpsProjects_Test[0].Core_Status__c='Active';
        Core_IPS_Project_Controller projectCntrl2 = new Core_IPS_Project_Controller(new ApexPages.StandardController(ListOfIpsProjects_Test[0]));
        projectCntrl2.changeStatusToSubmitted();
             
        Core_IPS_Project_Controller.getAccountsWrapper(String.valueOf(ListOfIpsProjects_Test[0].id));
        
             System.runAs(ListOfUser.get(1)){
        Core_IPS_Project_Controller.getAccountsWrapper(String.valueOf(ListOfIpsProjects_Test[0].id));
                 
                 
             }
        projectCntrl.displayExistingAccounts = true;
        //projectCntrl.displayAddSection = true;            //commented by Aayushi US80368
        projectCntrl.errorMsg = 'test';
        projectCntrl.AlreadySubmitted = true;
        
        Core_IPS_Project_Controller.IPSMemberWrapper wrpr = new Core_IPS_Project_Controller.IPSMemberWrapper();
        wrpr.Selected = true;
        wrpr.con = ListOfContacts[0];
        wrpr.Usr = ListOfUser.get(0);
        Core_IPS_Project_Controller.IPSAccountWrapper wrpr1 = new Core_IPS_Project_Controller.IPSAccountWrapper();
        wrpr1.Selected = true;
        wrpr1.acc = ListOfAccounts[0];
        wrpr1.participantTypeSelected = 'test';
        wrpr1.participants = new List<SelectOption>();
        // start modifed by Aayushi US80368
        projectCntrl1.strAccountInfo = string.valueof(ListOfAccounts[1].Id) + '=' + 'None'+','+string.valueof(ListOfAccounts[2].Id)+'=' + 'None';
        projectCntrl1.addIPSAccounts();
        projectCntrl1.strAccountInfo = string.valueof(ListOfAccounts[3].Id) + '=' + 'None';
        projectCntrl1.addIPSAccountsAndDone();
        //end
        //Integer val=projectCntrl1.addAccounts();
       /* projectCntrl1.strAccountInfo = string.valueof(account1.Id) + '=' + 'None';
        Integer val1=projectCntrl1.addAccounts();*/
       }
        Test.stopTest();
    }
 //added by Aayushi DE39928  
    static testmethod void ProjectMethod_test4(){
      getrecords();
      // Create Ips Labels added by Aayushi
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
            }
            if(IL.name=='Core_IPS_MPNDA_ErrorMsg'){
             IL.Value__c = 'A valid MPNDA is required prior to adding secondary Accounts to a Premier Support Project';
   
            }
            
            if(IL.name=='CoreStatus_Draft'){
             IL.Value__c = 'Draft';
   
            }
            
             if(IL.name=='Core_IPS_NonNDA_ErrorMSg'){
                IL.Value__c = 'Projects with multi-party Accounts should only have Accounts with NDAs   ' ;
            }
            
            if(IL.name=='Core_IPS_cndaErrorMsg'){
                IL.Value__c = 'Any existing Account must have a CNDA prior to adding additional Accounts to a Premier Support Project' ;
            }
        }
        System.runAs(ListOfUser.get(0)){
            Insert IPSLabels;
        }
        
        List<Core_IPS_Project__c> ListOfIpsProjects_Test = TestUtilities.getListOfIpsProjects(1);
        ListOfIpsProjects_Test.get(0).name='ipsProjectNameTest';
        ListOfIpsProjects_Test.get(0).Core_Status__c = 'Draft';
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects_Test;
        ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
        }
       
        System.assert(ListOfIpsProjects_Test[0].Id != null, 'Record not created'); 
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects_Test[0].id);
        Core_IPS_Project_Controller projectCntrl = new Core_IPS_Project_Controller();
    }
 }