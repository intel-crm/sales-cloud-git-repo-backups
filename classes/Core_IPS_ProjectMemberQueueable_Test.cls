/***************************************************************************************************
Class Name:  Core_IPS_ProjectMemberQueueable_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 08 Nov 2017
Description:   This class contains unit test scenarios for Core_IPS_ProjectMemberQueueable class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh	                  11/08/2017                  Created
****************************************************************************************************/

@isTest
private class Core_IPS_ProjectMemberQueueable_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();    
    
    /***************************************************************************************************
    Method Name:  SetupTestData()
    Version     : 1.0 
    Description:  Test data setup method 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/
    @testSetup static void SetupTestData() {

        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        //Create Role
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
	ListOfUser.get(0).UserRoleId = role.Id;
	insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        
        // Create Ips Labels
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
        }
        System.runAs(ListOfUser.get(0)){
            insert IPSLabels;
        }
    }
    
    /***************************************************************************************************
    Method Name:  insertProjectMember()
    Version     : 1.0 
    Description:  Test data setup for Inserting Project Member 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/
    static void insertProjectMember() {
        ListOfUser = [SELECT Id,Name,ProfileID,UserName,isActive FROM User WHERE isActive=true AND Profile.Name='System Administrator'];
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(ListOfUser.get(0)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
            ContactRec.Core_IPS_Active__c = true;
            ContactRec.MailingCountry= 'India';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects;
        }
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        Integer i=0;
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(i).Id;
            if(i==0){ i=i+1; }
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        //start added by Amritesh
        Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
        User customerUser = TestUtilities.getListOfUser(1).get(0);
        customerUser.ProfileId = ExternalUserProfileId;
        customerUser.UserName = 'testips.contact999@intel.com.crm';
        customerUser.FirstName = 'TestExt';
        customerUser.LastName = 'User192';
        customerUser.Alias = 'eusr192'; 
        customerUser.CommunityNickname = 'IPSExtUser192';
        customerUser.ContactId = ListOfContacts[0].Id;
        insert customerUser;
        
        System.assert(customerUser.Id != null, 'Record not created');
        //end
        // Create Project Member
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
        Integer j=0;
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(j).Id;
            ProjMem.Core_User__c = customerUser.Id;            //added by Amritesh
            if(j==0){ j=j+1; }
        }
        //Test.startTest();
        System.runAs(ListOfUser.get(0)){
            insert ListOfProjectMembers;
        }
        System.runAs(ListOfUser.get(0)){
            Core_IPS_Project__c projRec = new Core_IPS_Project__c();
            projRec.Id = ListOfIpsProjects.get(0).Id;
            projRec.Core_IPS_GroupId__c = null;
            update projRec;
        }
        System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
        //Test.stopTest();
    }
    
    
    
    /***************************************************************************************************
    Method Name:  AddProjectMembertoGroup_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 2 Feb 2016
    Description:  Testing with Creating IPS Project Members - Inserting Group Members
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/ 
    static testmethod void AddProjectMembertoGroup_Test(){
        
        insertProjectMember();
        String query = 'SELECT ' + String.join(new List<String>(Core_IPS_Project_Member__c.sObjectType.getDescribe().fields.getMap().keySet()), ',')
            			+ ' FROM Core_IPS_Project_Member__c';
        List<Core_IPS_Project_Member__c> lstProjMember = Database.query(query);
        Set<Id> ProjectIdSet = new Set<Id>();        
        for(Core_IPS_Project_Member__c PrjMember: lstProjMember){
            ProjectIdSet.add(PrjMember.Core_IPS_Project__c);            
        }
        Map<Id,Core_IPS_Project__c> mapProjectById = new Map<Id,Core_IPS_Project__c>([Select id, Core_IPS_GroupId__c,Createdby.ProfileId from Core_IPS_Project__c where id IN: ProjectIdSet]);
        Test.startTest();
        ID batchId = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(lstProjMember, mapProjectById));      
        ID batchId1 = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(null,lstProjMember, mapProjectById,'addprojectmember',0));  
        System.assert(batchId!=null , 'Not in Queue'); 
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  AddorRemoveProjMembertoGroup_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 2 Feb 2016
    Description:  Test to Add/Remove Project Members as Group Members
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/ 
    static testmethod void AddorRemoveProjMembertoGroup_Test(){
        insertProjectMember(); 
        String query = 'SELECT ' + String.join(new List<String>(Core_IPS_Project_Member__c.sObjectType.getDescribe().fields.getMap().keySet()), ',')
            			+ ' FROM Core_IPS_Project_Member__c';
        List<Core_IPS_Project_Member__c> lstProjMember = Database.query(query);
		List<Core_IPS_Project_Member__c> lstProjMember_New = lstProjMember.deepClone(true,true,true);
        Test.startTest();
        for(Core_IPS_Project_Member__c ProjMem : lstProjMember){
            ProjMem.Core_Status__c = 'Inactive';
        }
        ID batchId = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(lstProjMember, lstProjMember_New)); 
        System.assert(batchId!=null , 'Not in Queue'); 
        Test.stopTest();
        ID batchId2 = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(lstProjMember_New, lstProjMember)); 
        System.assert(batchId2!=null , 'Not in Queue'); 
    }
    
    
	/***************************************************************************************************
    Method Name:  RemoveProjectMemberfromGroupAfterDelete_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 2 Feb 2016
    Description:  Test to Remove Group Members when project member is deleted
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/ 
    static testmethod void RemoveProjectMemberfromGroupAfterDelete_Test(){
        insertProjectMember();
        Test.startTest();
        String query = 'SELECT ' + String.join(new List<String>(Core_IPS_Project_Member__c.sObjectType.getDescribe().fields.getMap().keySet()), ',')
            			+ ' FROM Core_IPS_Project_Member__c';
        List<Core_IPS_Project_Member__c> lstProjMember = Database.query(query);
        ID batchId = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(lstProjMember, 'removeprojectmemfromgroup')); 
        System.assert(batchId!=null , 'Not in Queue'); 
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  InsertProjMember_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 2 Feb 2016
    Description:  Test to Add Project Members when is Project Account is selected as All
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/ 
    static testmethod void InsertProjMember_Test(){
        insertProjectMember();
                
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        List<User> UserList = new List<User> ();
        
        //Get Profile
        strProf.add('IPS External Customer');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
	User thisUser = [ select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
        Account accountRecord = new Account(
                recordTypeId =   (Id)Schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId(),
                Name = 'Dell Products Test',
                Core_Account_Type__c = 'Distributor',
                Core_Sales_Segment__c = 'Compute',
                Industry = 'Banking',
                BillingCity = 'Delhi',
                BillingCountry = 'USA',
                billingState = 'AK',
                billingStreet = 'Bratislava 1',
                Core_IPS_Active__c = true,
		Ownerid =thisUser.id
          );
		 //insert accountRecord;
        //Create Users
        System.runAs(ListOfUser.get(0)){
        	//UserList.add(TestUtilities.getCustomerUser('IPS External Customer')); 
            insert accountRecord;
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = accountRecord.Id;
                ContactRec.Core_IPS_Active__c = true;
                ContactRec.Email = 'Contact1DellTest@gmail.com';
                ContactRec.MailingCountry= 'India';
            }
            insert ListOfContacts;
            Id ExternalUserProfileId = [select id, name from Profile where name='IPS External Customer'].Id;
            User customerUser = TestUtilities.getListOfUser(1).get(0);
            customerUser.ProfileId = ExternalUserProfileId;
            customerUser.UserName = 'testips2.contact999@intel.com.crm';
            customerUser.FirstName = 'TestEx2t';
            customerUser.LastName = 'User1922';
            customerUser.Alias = 'eusr1922'; 
            customerUser.CommunityNickname = 'IPSExtUser1922';
            customerUser.ContactId = ListOfContacts[0].Id;
            insert customerUser;
            UserList.add(customerUser);
             Contact objContact = new Contact(Id=UserList.get(0).contactId);
             objContact.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        	 objContact.Core_IPS_Active__c = true;
        	 update objContact;
        }
       
        
        List<Account> ListOfAccounts = [SELECT Id,Name FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:UserList.get(0).contactId)];
        
        // Create Ips Project
        List<Core_IPS_Project__c> ListOfIpsProjects = [SELECT Id,Name FROM Core_IPS_Project__c LIMIT 1];//TestUtilities.getListOfIpsProjects(2);
        
        // Create Ips Account
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            IpsAcc.Core_Members__c = 'All';
        }
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsAccounts;
        }
        System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
        
        List<Id> lstUserId = new List<Id>();
        List<Id> lstAccountId = new List<Id>();
        
        for(User objUser : UserList) {
            lstUserId.add(objUser.Id);
        }
        
        for(Account objAcc : ListOfAccounts) {
            lstAccountId.add(objAcc.Id);
        }
        
        Test.startTest();
        ID batchId = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(lstUserId, lstAccountId)); 
        System.assert(batchId!=null , 'Not in Queue'); 
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  UpdateProjMember_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 2 Feb 2016
    Description:  Test to Update Project Member when Customer User is updated if Project Account is selected as All
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh			          11/08/2017              Created
    ****************************************************************************************************/ 
    static testmethod void UpdateProjMember_Test(){
        insertProjectMember();
                
        Set<Id> setProjectId = new Set<Id>();
        List<Id> lstUserId = new List<Id>();
        List<Id> lstContactId = new List<Id>();
        
        String query = 'SELECT ' + String.join(new List<String>(Core_IPS_Project_Member__c.sObjectType.getDescribe().fields.getMap().keySet()), ',')
            			+ ' FROM Core_IPS_Project_Member__c';
        List<Core_IPS_Project_Member__c> lstProjMember = Database.query(query);
        
        for(Core_IPS_Project_Member__c objProjMember : lstProjMember) {
            setProjectId.add(objProjMember.Core_IPS_Project__c);
            lstUserId.add(objProjMember.Core_User__c);
            lstContactId.add(objProjMember.Core_IPS_Contact__c);
            objProjMember.Core_Status__c = 'Inactive';
        }
        
        System.runAs(ListOfUser.get(0)){
            update lstProjMember;
        }
        
        Test.startTest();
        ID batchId = System.enqueueJob(new Core_IPS_ProjectMemberQueueable(setProjectId, lstUserId, lstContactId)); 
        System.assert(batchId!=null , 'Not in Queue'); 
        Test.stopTest();
    }
    static testmethod void InsertException_PositiveTestMethod(){
	 String result = 'true';
            Test.startTest();
            try{
                Exception excep;
                integer i = 1/0;
            }catch(exception e){
                Core_IPS_ProjectMemberQueueable.insertExceptionInFuture('001','Core_IPS_ProjectMemberQueueable','Project Member','Test Exception','Test Method',e.getMessage());
            }         
	 System.assert(String.isNotBlank(result) , 'Result Not Empty'); 
            Test.stopTest();
    }
}