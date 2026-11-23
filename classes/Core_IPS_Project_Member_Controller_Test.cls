@isTest
public class Core_IPS_Project_Member_Controller_Test{
   
   
   static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
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
        ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
    }
    
     static testmethod void ProjectMethod_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
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
        //added by naresh related to the Userstory US48513 on 8/31/16
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS External Customer');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> ListOfExternalUsers = TestUtilities.getListOfUser(1);
        ListOfExternalUsers.get(0).ProfileID =  profiles.get('IPS External Customer');
        ListOfExternalUsers.get(0).isActive=true;
        ListOfExternalUsers.get(0).contactId=ListOfContacts[0].id;
        ListOfExternalUsers.get(0).Email ='newusers123@intel.com';
        ListOfExternalUsers.get(0).LastName='Testinguser123';
        ListOfExternalUsers.get(0).UserName ='newusertest123@intel.com';
        insert ListOfExternalUsers;
        System.assert(ListOfExternalUsers[0].Id != null, 'Record not created');
        //end
        
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
      
        Core_IPS_Project_Member_Controller projectCntrl1 = new Core_IPS_Project_Member_Controller();
        
        Core_IPS_Project_Member_Controller.getlstProjectMemberWrapperInfo();
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
         
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
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
      
        Core_IPS_Project_Member_Controller projectCntrl1 = new Core_IPS_Project_Member_Controller();
        Core_IPS_Project_Member_Controller.getlstProjectMemberWrapperInfo();
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
         
        // Create Ips Labels
        List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c IL: IPSLabels){
            if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
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
        ListOfIpsProjects_Test.get(0).Core_Status__c = 'Draft';
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects_Test;
        ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
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
        
        
        
        list<Core_IPS_Project_Member__c> lstCoreIpsProjectMembers =   new list<Core_IPS_Project_Member__c>();
        lstCoreIpsProjectMembers.add(PM);
        //PM.Core_User__c = CommunityUser.id;
         System.runAs(ListOfUser.get(0)){
            //insert PM;
        
        PageReference PageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(PageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects_Test[0].id);        
      
        Core_IPS_Project_Member_Controller objNew  = new Core_IPS_Project_Member_Controller();
        Core_IPS_Project_Member_Controller.getlstProjectMemberWrapperInfo();
        
         Core_IPS_Project_Member_Controller.succuessProjectMembers(lstCoreIpsProjectMembers);
        Core_IPS_Project_Member_Controller.succuessProjectMembers(null);
        Core_IPS_Project_Member_Controller.getlstExistingProjectMembers();
        
        Core_IPS_Project_Member_Controller.IPSMemberWrapper  objIpsMemberInfo = new Core_IPS_Project_Member_Controller.IPSMemberWrapper();
        objIpsMemberInfo.compareTo(null);
        
       }
        
        Test.stopTest();
    }
       
}