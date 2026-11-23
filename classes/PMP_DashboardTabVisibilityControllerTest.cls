@isTest
public class PMP_DashboardTabVisibilityControllerTest extends PMP_SearchWrapperStore {
   
    @testSetup static void setup(){
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_BASIC_PROFILE';
        st.PMP_Value__c = 'BFTMKTPLBC';
        stList.add(st);
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        insert stList;
        
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
     
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account6',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        
       
        
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='TestUtility', Contact = conObj);
        insert testUser;
        

      }
    
   @isTest static void getTabs_Test()
    {
        User user = [SELECT id,AccountId from User where FirstName='TestUtility'];
        system.runAs(user)
        {
            
            
            Test.startTest();
            
             /*ChannelProgram cc=new ChannelProgram();
        cc.Name='Intel Partner Alliance';
        insert cc;
        
        PRM_PartnerBenefit__c pb=new PRM_PartnerBenefit__c();
        pb.Name='Basic';
        //pb.PRM_Active_Ind__c=true;
        pb.PRM_Benefit_Cd__c='BFTMKTPLBC';
        pb.PRM_Channel_Program_Id__c=cc.Id;
        insert pb;*/
        
        Id master_Partner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAcc = PMP_TestDataUtility.createIntelAccount('Test Intel Account', master_Partner, true);
      
            
            PermissionSet ps = [SELECT id, Name from PermissionSet where Name =:PMP_StaticConstants_Partner.INTEL_ADMIN];
            
            PermissionSetAssignment perm = new PermissionSetAssignment();
            perm.AssigneeId = user.Id;
            perm.PermissionSetId = ps.Id;
            insert perm;
            
            PMP_DashboardTabVisibilityController.isMPAdmin();
            PMP_DashboardTabVisibilityController.isBasicProfileBenefit();
            PMP_DashboardTabVisibilityController.isEmployee();
            PMP_DashboardTabVisibilityController.isLeadTabforAdminsAndLDR();
            Test.stopTest();
            
            
        }
    }
    @isTest static void getTabs1_Test() {
    
        Test.startTest();
       PMP_DashboardTabVisibilityController.isMPAdmin();
        PMP_DashboardTabVisibilityController.isBasicProfileBenefit();
        PMP_DashboardTabVisibilityController.isEmployee();
        PMP_DashboardTabVisibilityController.isLeadTabforAdminsAndLDR();
        Test.stopTest();
    } 
    
    @isTest static void testMethod1() {
        
      //Id p = [select id from profile where name='Partner Community User'].Id;
     //User u = [SELECT Id FROM User WHERE isActive = TRUE AND ProfileId = :p LIMIT 1];
          
       
        
        //Create portal account owner
 User thisUser = [ select Id from User where Id =:UserInfo.getUserId()];
//UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
UserRole portalRole = new UserRole(DeveloperName ='MyCustomRole',Name = 'My Role',PortalType='None');
insert portalRole;
Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
User portalAccountOwner1 = new User(
	UserRoleId = portalRole.Id,
	ProfileId = profile1.Id,
	Username = System.now().millisecond() + 'test2@test.com',
   	Alias = 'batman',
	Email='bruce.wayne1@intel.com',
	EmailEncodingKey='UTF-8',
	Firstname='Bruce1',
	Lastname='Wayne1',
	LanguageLocaleKey='en_US',
	LocaleSidKey='en_US',
	TimeZoneSidKey='America/Chicago'
);
insert portalAccountOwner1;



Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj1 = new Account();
        Contact conObj1 =null;
        User user1 =null;
         System.runAs(portalAccountOwner1)
        {
accObj1.Name='test';
 accObj1.BillingStreet='1417 R Street';
 accObj1.BillingCity='Apple Valley';
    accObj1.BillingCountry='USA';    
          
accObj1.BillingState='MN';
            accObj1.OwnerId=portalAccountOwner1.Id;
            accObj1.BillingPostalCode='55124';
            insert accObj1;        
            
conObj1 = PMP_TestDataUtility.createContact(accObj1.id,true);
            conObj1.AccountId=accObj1.Id;
            update conObj1;
           
        
    	
//Create user
Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='Partner' Limit 1];
       user1 = new User(
	Username = System.now().millisecond() + 'test12345@test.com',
	ContactId = conObj1.Id,
   // UserRoleId = portalRole.Id,
	ProfileId = portalProfile.Id,
	Alias = 'test123',
	Email = 'test123456@intel.com',
	EmailEncodingKey = 'UTF-8',
	LastName = 'McTesty',
	CommunityNickname = 'MP_Solutions'+Date.today().day()+Datetime.now().second(),
	TimeZoneSidKey = 'America/Los_Angeles',
	LocaleSidKey = 'en_US',
	LanguageLocaleKey = 'en_US'
);
       
            insert user1;
        

        }
     
        
        
       PermissionSet psEmployee = [SELECT id, Name from PermissionSet where Name =:PMP_StaticConstants_Partner.EMPLOYEE];
        PermissionSetAssignment permEmployee = new PermissionSetAssignment();
        permEmployee.AssigneeId = user1.Id;
        permEmployee.PermissionSetId = psEmployee.Id;
        insert permEmployee;
        
       system.runAs(user1) {
        
        Test.startTest();
       
        //string dashTab1;   
        //List<PMP_Dashboard_Tab__mdt> dashTab;
        //dashTab=[Select Id,PMP_Is_Active_Ind__c,PMP_Permission_Set_Name_Txt__c from PMP_Dashboard_Tab__mdt where PMP_Is_Active_Ind__c=True];
  
        PMP_DashboardTabVisibilityController.isMPAdmin();
        PMP_DashboardTabVisibilityController.isEmployee();
        PMP_DashboardTabVisibilityController.isLeadTabforAdminsAndLDR();
        Test.stopTest();
        }
    } 
    
    
}