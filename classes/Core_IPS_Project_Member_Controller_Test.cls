@isTest
public class Core_IPS_Project_Member_Controller_Test{
   
   
    static List<User> listOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        listOfUser = TestUtilities.getListOfUser(1);
        listOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        insert listOfUser;
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('System Administrator'));
    }
    
     static testmethod void ProjectMethod_test(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = listOfUser.get(0).id;
        // Create Ips Labels
        List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipsLabel: ipsLabels){
            if(ipsLabel.name=='ProjectGroupPrefix'){
                ipsLabel.Value__c = 'IPS_Proj_';
            }
        }
        System.runAs(listOfUser.get(0)){
            Insert ipsLabels;
        }
        
        // Create Accounts
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listOfUser.get(0)){
            insert listOfAccounts;
        }
        System.assert(listOfAccounts[0].Id != null, 'Record not created');
        
        //Create Contact
        List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
        System.runAs(listOfUser.get(0)){
            listOfContacts[0].AccountId = listOfAccounts[0].Id;
            insert listOfContacts;
        }
        System.assert(listOfAccounts[0].Id != null, 'Record not created');
        //added by naresh related to the Userstory US48513 on 8/31/16
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS External Customer');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfExternalUsers = TestUtilities.getListOfUser(1);
        listOfExternalUsers.get(0).ProfileID =  profiles.get('IPS External Customer');
        listOfExternalUsers.get(0).isActive=true;
        listOfExternalUsers.get(0).contactId=listOfContacts[0].id;
        listOfExternalUsers.get(0).Email ='newusers123@intel.com';
        listOfExternalUsers.get(0).LastName='Testinguser123';
        listOfExternalUsers.get(0).UserName ='newusertest123@intel.com';
        insert listOfExternalUsers;
        System.assert(listOfExternalUsers[0].Id != null, 'Record not created');
        //end
        
        // Create Ips Project
        List<Core_IPS_Project__c> listOfIpsProjectsTest = TestUtilities.getListOfIpsProjects(1);
        listOfIpsProjectsTest.get(0).name='ipsProjectNameTest';
        Test.startTest();
        System.runAs(listOfUser.get(0)){
            insert listOfIpsProjectsTest;
        listOfIpsProjectsTest = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:listOfIpsProjectsTest[0].Id];
        }
        System.assert(listOfIpsProjectsTest[0].Id != null, 'Record not created');        
        
        Core_IPS_Account__c acc = new Core_IPS_Account__c();
        acc.Core_Account__c = listOfAccounts[0].Id;
        acc.Core_IPS_Project__c = listOfIpsProjectsTest[0].Id;
        System.runAs(listOfUser.get(0)){
            insert acc;
        }
        
        PageReference pageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', listOfIpsProjectsTest[0].id);        
      
        Core_IPS_Project_Member_Controller projectCntrl1 = new Core_IPS_Project_Member_Controller();
        
        Core_IPS_Project_Member_Controller.getlstProjectMemberWrapperInfo();
        Test.stopTest();
    }
    
    static testmethod void ProjectMethod_test1(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
          Id intelSupportOwner = listOfUser.get(0).id;
          User communityUser ;
          System.runAs(listOfUser.get(0)){
              communityUser = TestUtilities.getCustomerUser('IPS External Customer'); 
        }
         
        // Create Ips Labels
        List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipsLabel: ipsLabels){
            if(ipsLabel.name=='ProjectGroupPrefix'){
                ipsLabel.Value__c = 'IPS_Proj_';
            }
        }
        System.runAs(listOfUser.get(0)){
            Insert ipsLabels;
        }
        
        // Create Accounts
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listOfUser.get(0)){
            insert listOfAccounts;
        }
        System.assert(listOfAccounts[0].Id != null, 'Record not created');
        
        //Create Contact
        List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
        System.runAs(listOfUser.get(0)){
            listOfContacts[0].AccountId = listOfAccounts[0].Id;
            insert listOfContacts;
        }
        System.assert(listOfAccounts[0].Id != null, 'Record not created');
        //added by naresh related to the Test Coverage Story US41854 on 5/30/16
        // inserting Product Orgs
         List<Core_IPS_Product_Organization__c> prodOrgList = TestUtilities.getListOfSupportOrg(1);
        System.runAs(listOfUser.get(0)){
        insert prodOrgList;
        }
        //inserting products
        list<Product2> productList = TestUtilities.getListOfProduct(1);
        productList[0].Core_Code_Name_EPM_ID__c='L1 Id1';
        productList[0].Core_Hierarchy_ID__c='59';
        System.runAs(listOfUser.get(0)){
        insert productList;
        }
        //inserting supported products
        List<Core_IPS_Supported_Product__c> suppProductList=TestUtilities.getListOfSupportedProduct(1);
        suppProductList[0].Core_Product__c = productList.get(0).id;
        suppProductList[0].Core_Product_Organization__c = prodOrgList[0].id;
        suppProductList[0].Core_Product_EPM_ID__c = productList.get(0).id;
        suppProductList[0].core_EOIS__C = false;
        suppProductList[0].Core_Flag_Status__c='Auto Approve';
        System.runAs(listOfUser.get(0)){
        insert suppProductList;
        }
        //end
        // Create Ips Project
        List<Core_IPS_Project__c> listOfIpsProjectsTest = TestUtilities.getListOfIpsProjects(1);
        listOfIpsProjectsTest.get(0).name='ipsProjectNameTest';
        listOfIpsProjectsTest.get(0).Core_Status__c = 'Draft';
        
        Test.startTest();
        System.runAs(listOfUser.get(0)){
            insert listOfIpsProjectsTest;
            
        //added by naresh related to the Test Coverage Story US41854 on 5/30/16
        List<Core_IPS_Product__c> listProjectProduct = new List<Core_IPS_Product__c>();
        Core_IPS_Product__c projectProduct = new Core_IPS_Product__c();
        projectProduct.Core_IPS_Project__c = listOfIpsProjectsTest[0].Id;
        projectProduct.Core_Supported_Product__c = suppProductList[0].id;
        projectProduct.Core_IPS_IsAutoApprove__c=true;
        projectProduct.Status__c='Submitted Pending';
        projectProduct.Core_IsSubmitted_Header__c=true;
        //projectProduct.Core_Supported_Product__r.Core_Flag_Status__c=null;
        listProjectProduct.add(projectProduct); 
        insert listProjectProduct;
        //end
        //ListOfIpsProjects_Test = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:ListOfIpsProjects_Test[0].Id];
         listOfIpsProjectsTest = [select id, Name, core_status__c, Core_Number_of_Accounts__c, Core_Number_of_Products__c,Core_Number_of_Users__c,
                    (Select id,Status__c,Core_IPS_IsAutoApprove__c, Core_Supported_Product__c, Core_Supported_Product__r.Core_Flag_Status__c, Core_IPS_Project__c,Core_IsSubmitted_Header__c from IPS_Products__r) 
                    from core_ips_project__c where id=:listOfIpsProjectsTest[0].Id];           
        }
        System.assert(listOfIpsProjectsTest[0].Id != null, 'Record not created');  
    
        Core_IPS_Account__c acc = new Core_IPS_Account__c();
        acc.Core_Account__c = [select id,accountid from  user  where id=:communityUser.id].accountid;
        acc.Core_IPS_Project__c = listOfIpsProjectsTest[0].Id;
        System.runAs(listOfUser.get(0)){
            insert acc;
        }
        Core_IPS_Project_Member__c projectMember =  TestUtilities.getProjectMember();
        projectMember.Core_IPS_Contact__c = [select id,contactid from  user  where id=:communityUser.id].contactid;
        projectMember.Core_IPS_Project__c =  listOfIpsProjectsTest[0].Id;
        //PM.Core_User__c = CommunityUser.id;
         System.runAs(listOfUser.get(0)){
            //insert PM;
        
        PageReference pageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', listOfIpsProjectsTest[0].id);        
      
        Core_IPS_Project_Member_Controller projectCntrl1 = new Core_IPS_Project_Member_Controller();
        Core_IPS_Project_Member_Controller.getlstProjectMemberWrapperInfo();
        //end     
        }
        Test.stopTest();
    }
    static testmethod void ProjectMethod_test3(){
        getrecords();
        // Get intelSupportOwner Id (User Id)
          Id intelSupportOwner = listOfUser.get(0).id;
          User communityUser ;
          System.runAs(listOfUser.get(0)){
              communityUser = TestUtilities.getCustomerUser('IPS External Customer'); 
        }
         
        // Create Ips Labels
        List<Core_IPS_Labels__c> ipsLabels = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipsLabel: ipsLabels){
            if(ipsLabel.name=='ProjectGroupPrefix'){
                ipsLabel.Value__c = 'IPS_Proj_';
            }
        }
        System.runAs(listOfUser.get(0)){
            Insert ipsLabels;
        }
        
        // Create Accounts
        List<Account> listOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listOfUser.get(0)){
            insert listOfAccounts;
        }
        System.assert(listOfAccounts[0].Id != null, 'Record not created');
        
        //Create Contact
        List<Contact> listOfContacts = TestUtilities.getListOfContact(1);
        System.runAs(listOfUser.get(0)){
            listOfContacts[0].AccountId = listOfAccounts[0].Id;
            insert listOfContacts;
        }
        System.assert(listOfAccounts[0].Id != null, 'Record not created');
        
        // Create Ips Project
        List<Core_IPS_Project__c> listOfIpsProjectsTest = TestUtilities.getListOfIpsProjects(1);
        listOfIpsProjectsTest.get(0).name='ipsProjectNameTest';
        listOfIpsProjectsTest.get(0).Core_Status__c = 'Draft';
        Test.startTest();
        System.runAs(listOfUser.get(0)){
            insert listOfIpsProjectsTest;
        listOfIpsProjectsTest = [Select Id,Core_Number_of_Accounts__c from Core_IPS_Project__c where Id =:listOfIpsProjectsTest[0].Id];
        }
        System.assert(listOfIpsProjectsTest[0].Id != null, 'Record not created');        
        
        Core_IPS_Account__c acc = new Core_IPS_Account__c();
        acc.Core_Account__c = [select id,accountid from  user  where id=:communityUser.id].accountid;
        acc.Core_IPS_Project__c = listOfIpsProjectsTest[0].Id;
        System.runAs(listOfUser.get(0)){
            insert acc;
        }
        Core_IPS_Project_Member__c projectMember =  TestUtilities.getProjectMember();
        projectMember.Core_IPS_Contact__c = [select id,contactid from  user  where id=:communityUser.id].contactid;
        projectMember.Core_IPS_Project__c =  listOfIpsProjectsTest[0].Id;
        
        
        
        list<Core_IPS_Project_Member__c> lstCoreIpsProjectMembers =   new list<Core_IPS_Project_Member__c>();
        lstCoreIpsProjectMembers.add(projectMember);
        //PM.Core_User__c = CommunityUser.id;
         System.runAs(listOfUser.get(0)){
            //insert PM;
        
        PageReference pageRef = Page.Core_IPS_submitProject;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('Id', ListOfIpsProjects_Test[0].id);
        ApexPages.currentPage().getParameters().put('projectId', listOfIpsProjectsTest[0].id);        
      
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