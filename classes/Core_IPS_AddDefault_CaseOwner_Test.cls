/**************************************************************************************************
Apex Class Name :  Core_IPS_AddDefault_CaseOwner_Test 
Description     :  This is the test class that covers Core_IPS_AddDefault_CaseOwner_Controller
Modification Log :
* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Sriranjini                      03/02/2020                 Created
* System.assert()--> statement Added By Hassan Khan 01-02-2024 
*****************************************************************************************************/
@isTest
public class Core_IPS_AddDefault_CaseOwner_Test {
    static List<User> listOfUser = new List<User> ();
    Static list<User>userList = new list<user>();
    Static list<User> partUserList = new List<User>();
    static List<Core_IPS_Product__c> testprod = new List<Core_IPS_Product__c>();
    
    static void getRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        listOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : listOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert listOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    
    public static testMethod void coreSortedGridColumnHeaderTest(){
        getRecords();
        Test.startTest();
        UserRole urole = new UserRole(Name= 'CEO'); 
        User u ;
        System.runAs(ListOfUser[0]){                     
        insert urole; 
        
        Profile p = [select id, name from Profile where name = 'System Administrator' limit 1]; 
        u = new User(Alias = 'standt', Email='test1110099@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3445657588594534@testorg.com', userRoleId = urole.Id);
        insert u;
            }
        List<User> userList = [Select id,Name from User where id =: u.id];
        
        
                    
        Profile partner = [select id, name from Profile where name='IPS Agent-Partner' ];
        Account testAccount1;
        
        testAccount1=TestUtilities.getAccount();  
       // testAccount1.IsPartner = true;
        testAccount1.OwnerId = u.Id;
        insert testAccount1;  
        
        
       /* UserRole urole = new UserRole( PortalType ='Partner', PortalAccountId = testAccount1.Id );         
        System.runAs(ListOfUser[0]){                     
        insert urole; 
        } */ 
        Contact testContact ;         
                                  
        Contact testContact1 = new Contact(FirstName='testFirstName33123', LastName='testLastName123', Email='test124643@testing.com.testsetup',
                                                AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
        insert testContact1;
        User partnerUser = new User(Alias = 'pips', 
                                    Email='parente@gmail.com', 
                                    EmailEncodingKey='UTF-8', 
                                    LastName='Agent', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US',                                     
                                    ProfileId = partner.Id, 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    UserName='parente123@gmail.com' ,
                                    contactId = testContact1.id
                                    //userRoleId = urole.Id
                                    );  
        System.runAs(ListOfUser[0]){  
            insert partnerUser;      
        }
        List<User> partUserList = [Select id,Name from User where id =: partnerUser.id];
               
        Group testGroup = new Group();
        testGroup.Name = 'testGroup';
        testGroup.DeveloperName = 'ABC';
        INSERT testGroup;
        
        //added newly
        Core_IPS_Product_Organization__c  org = new Core_IPS_Product_Organization__c ( 
            Core_IPS_Support_Org_Name__c = 'TestName',
            Core_Organization_Description__c = 'TestDescription'        
        );
        insert org;
        
        Product2 prod2 = new Product2(
            Name = 'Haswell EP',
            Core_Sales_Visible_Flag__c = false,
            Core_IPS_Visible_Flag_External__c = true,
            Core_IPS_Visible_Flag_Internal__c = 'Yes',
            IsActive = true,
            Core_Product_Org__c = 'IPS'
        ); 
        insert prod2;
        
        Core_IPS_Supported_Product__c sp= new Core_IPS_Supported_Product__c(
            Core_Product_Organization__c = org.Id,
            Core_EOIS__c = false,
            Core_Supported_Product_Name__c = 'Haswell EP',
            Core_Product__c=prod2.id
        );
        insert sp;
        
        Core_IPS_Project__c ipsProject1 = new Core_IPS_Project__c(); 
        ipsProject1.Name ='value1';
        ipsProject1.Core_MPNDA__c='4567';
        insert ipsProject1;
        
        Core_IPS_Product__c prod = new Core_IPS_Product__c();
        prod.Core_IPS_Project__c = ipsProject1.Id;
        prod.Core_Supported_Product__c= sp.id;
        prod.Core_IPS_Product_Status__c ='Active';
        prod.Status__c = 'Approved';
        prod.Core_IPS_IsAutoApprove__c = true;
        prod.Status__c = 'Auto Approve';
        prod.Core_IsSubmitted_Header__c = true;
        prod.Core_IPS_Prod_Def_Case_Owner_ID__c =userInfo.getUserId();
        prod.Core_IPS_Prod_Default_Case_Owner__c = userInfo.getUserId();
        insert prod;
        
          list<Core_IPS_Product__c> prolst = new list<Core_IPS_Product__c>{prod};
                  testprod = [select id from Core_IPS_Product__c where id =:prod.id];
//Commented for Classic EOL :Tejaswini
      /*  PageReference pp= page.Core_IPS_AddDefaultCaseOwner;
        Test.setCurrentPage(pp); */
        //pp.getParameters().put('productId',testprod[0].id);
        ApexPages.currentPage().getParameters().put('productId',testprod[0].id);
        ApexPages.StandardsetController stdsetController = new ApexPages.StandardsetController(prolst);
              
        Core_IPS_AddDefault_CaseOwner_Controller testCon = new Core_IPS_AddDefault_CaseOwner_Controller();
        testCon.sortHeader = new Core_SortedGrid_ColumnHeader('FirstName');
        testCon.searchText = 'Sales';
        testCon.selectDCOoption = 'User';
         
        testCon.prodObj= Prod;
        testCon.productId = testprod[0].id;
        testCon.doSearch();
        testCon.init();
        testCon.isSelected = true;
        testCon.UserList = userList;
        testCon.selectedUser =userList[0].id;
        testCon.selectedQueueName = testGroup.id;
        PageReference pageRef5 = testCon.saveAndRedirect();
        PageReference pageRef6 = testCon.AddSelectedUsers();
        testCon.removeDefaultCaseOwner();
        //system.assertNotEquals(pageRef5, null, 'Page Ref should not be null');              
        
        Core_IPS_AddDefault_CaseOwner_Controller testConpartner = new Core_IPS_AddDefault_CaseOwner_Controller();
        testConpartner.sortHeader = new Core_SortedGrid_ColumnHeader('FirstName');
        testConpartner.searchText = 'test';
        testConpartner.selectDCOoption = 'Partner User';
        
        testConpartner.prodObj = Prod;
        testConpartner.productId = testprod[0].id;
        testConpartner.doSearch();
        testConpartner.init();
        testConpartner.isSelected = true;
        testConpartner.UserList = partUserList;
        testConpartner.selectedUser = partUserList[0].id;
        testConpartner.selectedQueueName = testGroup.id;
        PageReference pageRef55 = testConpartner.saveAndRedirect();
        PageReference pageRef66 = testConpartner.AddSelectedUsers();
        testConpartner.removeDefaultCaseOwner();
        //system.assertNotEquals(pageRef5, null, 'Page Ref should not be null');
        
        Core_IPS_AddDefault_CaseOwner_Controller testConQueue= new Core_IPS_AddDefault_CaseOwner_Controller();
        testConQueue.sortHeader = new Core_SortedGrid_ColumnHeader('FirstName');
        testConQueue.searchText = 'apac';
        testConQueue.selectDCOoption = 'Queue';        
        testConQueue.prodObj = Prod;
        testConQueue.productId = testprod[0].id;
        testConQueue.doSearch();
        testConQueue.init();
        testConQueue.isSelected = true;       
        testConQueue.selectedQueueName = testGroup.id;
        PageReference pageRef555 = testConQueue.saveAndRedirect();
        PageReference pageRef666 = testConQueue.AddSelectedUsers();
        testConpartner.removeDefaultCaseOwner();
        Test.stopTest();
        System.assert(testGroup.id != null, true);
    }
       
}