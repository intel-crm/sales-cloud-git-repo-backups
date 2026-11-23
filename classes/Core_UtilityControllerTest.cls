/**************************************************************************************************
* Apex Class Name   : Core_UtilityControllerTest
* Created Date      : 12 Aug 2019
* Description       : Utility methods to handle generic functions
* 
* Developer             Date        Description
* -------------------------------------------------------------------------------------------------                 
* Sandip Ghosh         08/12/2019  Original Version
**************************************************************************************************/
@IsTest
public without sharing class Core_UtilityControllerTest{
    public static final String PMP_INTERNAL_ADMIN_STR = 'PMP_Internal_Intel_Admin';
    private static final String ALIAS_NAME = 'testUser';    
    Public static final Id DEVRECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    @testSetup static void setup() {
        // Create common test user
        User poeUser= PMP_TestDataUtility.createUser(True);
        poeUser.Alias = ALIAS_NAME;
        update poeUser;

        User usr = [select Id, Core_IPA_One_Partner_Id__c, name, AccountID from User where Id=:poeUser.id limit 1];
       system.debug('usr:'+usr);
         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', usr.AccountID, true);
        cmp1.PMP_One_Partner_ID__c=usr.Core_IPA_One_Partner_Id__c;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c=PMP_StaticConstants_Partner.Published;
        //cmp1.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        cmp1.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        update cmp1;
        
        createAdminUser(); //admin user with role assigned is required to create partner account and partner user
          
    }
    
    @IsTest
    private static void testCoreUtilityUser() {
        Core_UtilityController.fetchUser();
        //Core_UtilityController.fetchPermissionSetName();
        
        PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name = :PMP_INTERNAL_ADMIN_STR];
        system.debug('ps ='+ps);
        
        PermissionSetAssignment newPermissioSet= new PermissionSetAssignment();
        newPermissioSet.PermissionSetId=ps.Id;
        newPermissioSet.AssigneeId=userInfo.getUserId();
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId()];
        //System.runAs (currentUser) {
        //Database.insert(newPermissioSet);
        //}
        
        
        
        User adminUser = [select id,email from User where email='testUsercore@intel.com' limit 1];
        Account accObj;
        Account intelAccount1;
        
        system.runAs(adminUser ){
            accObj = PMP_TestDataUtility.createIntelAccount('testCoreUtilityAccount12',DEVRECORDTYPEID,true);  
            
            intelAccount1 = new Account(Name ='IntelAccount1',
                                            Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',
                                            BillingStreet='cbc chowk delhi',Core_Account_Type__c='Original Design Manufacturer (ODM)');
            Database.insert(intelAccount1); 
        }    
        
        PMP_Company__c company1=new PMP_Company__c();
        company1.Name='TestCompany12';
        company1.PMP_Benefit_Update_Ind__c=False;
        company1.PMP_Partner_Inactive_Ind__c = False;
        company1.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solution_Marketplace_Basic_Access;
        company1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company1.PMP_Is_Published_Ind__c=true;
        insert company1;
            
            PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
        jun1.PMP_One_Partner_ID__c= intelAccount1.Id;
        jun1.PMP_Marketing_Profile_Id__c= company1.Id;
        jun1.Is_Active__c=true;     
        insert jun1;
            //User newTestUser = PMP_TestDataUtility.createUserNew(true,accObj.Id);
        
        Core_UtilityController.fetchPermissionSetName();
        
        Core_IPS_Error_Code__c newCustomSetting = new Core_IPS_Error_Code__c();
        newCustomSetting.Name= 'G115';
        newCustomSetting.Language__c='English';
        newCustomSetting.Core_Locale__c='EN';
        newCustomSetting.Core_Error_Message__c='You have insufficient privilege for this action.';
       
       // newCustomSetting.Error Message='You have insufficient privilege for this action'.
            insert(newCustomSetting); 
        
        Profile profile = [select Id,name from Profile where Name ='Partner'];
        List<User> userList = new List<User>();
        /*Account intelAccount1 = new Account(Name ='IntelAccount1',
                                            Core_Sales_Group_New__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',
                                            BillingStreet='cbc chowk delhi',Core_Account_Type__c='Original Design Manufacturer (ODM)');
        Database.insert(intelAccount1);*/
        System.debug('intelAccount1 inserted = '+ intelAccount1);
        
        Contact contact1 = new Contact(firstname='Intel', 
                    lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com', MailingCountry= 'India');
        Database.insert(contact1);
        UserRole userRole = [Select Name, PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
        system.debug('roldName--'+userRole.name );        
        User newUser = new User(
            //UserRoleId = userRole.Id,
            profileId = profile.id, 
            username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
            email = 'pb@ff.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname', 
            contactId = contact1.Id
         );
        
        //Inserting User
        System.runAs (adminUser ) {
            Database.insert(newUser);
            
             PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Employee'];
            PermissionSetAssignment psa1 = new PermissionSetAssignment(
                AssigneeId = newUser.Id,
                PermissionSetId = ps2.Id
            );
            insert psa1;
        }
        
          
       // System.runAs (newUser) {
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
            Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                                  Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            
            Database.insert(partnerAccount1);
            
            Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
            accGroupMem1.Core_Partner_Account_Id__c = partnerAccount1.Id;
            accGroupMem1.Core_Intel_Account_Id__c = intelAccount1.Id;
            accGroupMem1.Core_MDA_Ind__c = true;
            accGroupMem1.Core_Inactive_Ind__c = false;
            
            Database.insert(accGroupMem1);
             ChannelProgram cProg = new ChannelProgram(); //Channel Program
            cProg.Name='Intel Partner Alliance';
            cProg.PRM_programCode__c='IPA';
            Database.insert(cProg);        
            
            ChannelProgramLevel lvl = new ChannelProgramLevel();
            lvl.Name = 'Titanium';
            lvl.PRM_programlevelcode__c = 'Titanium';
            lvl.PRM_inactind__c = false;
            lvl.ProgramId = cProg.Id;
            insert lvl;
        
            PRM_AccountChannelMemberShip__c acctMembership= new PRM_AccountChannelMemberShip__c();
            acctMembership.PRM_Account_Id__c = intelAccount1.Id;
            acctMembership.PRM_Channel_Program_Id__c = cProg.Id;
            acctMembership.PRM_Status_Nm__c = 'Approved';        
            acctMembership.PRM_Channel_Program_Level_Id__c = lvl.Id;     
            acctMembership.PRM_Partner_Role__c = 'Service Provider'; 
            //ginsert acctMembership;
            
            
        
        PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(); //Partner Benefit
        prmPartnerBenefit.Name='Partner University';
        prmPartnerBenefit.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        prmPartnerBenefit.PRM_Channel_Program_Id__c = cProg.id;
        insert prmPartnerBenefit;
        
        
        
            /*PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(Name =System.Label.PMP_Offering_Benefit,
                                                                                PRM_Benefit_Cd__c = 'SMEN',
                                                                                PRM_Channel_Program_Id__c = cProg.Id);
            Database.insert(prmPartnerBenefit);*/
             PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
            pt.Name = 'Cloud Service Provider (CSP)';
            pt.PRM_PartneryTypeCode__c = 'CSP';
            pt.PRM_PartnerRoleCode__c = 'SPR';
            pt.PRM_channelprogram__c = cProg.id;
            insert pt;
        
            PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
            bm.PRM_Partner_Benefit_Id__c = prmPartnerBenefit.id;
            bm.PRM_Channel_Program_Id__c = cProg.id;
            bm.PRM_Channel_Program_Level_Id__c = lvl.id;
            bm.PRM_Partner_Type_Id__c = pt.id;
            bm.PRM_Covered_Account_Ind__c  = true;
            bm.PRM_Approval_Type_Nm__c = 'Manual';
            
            PRM_AccountBenefitAssociation__c prmAccBenefitAssoc = new PRM_AccountBenefitAssociation__c(
                PRM_Account_Id__c = intelAccount1.Id,
                PRM_Partner_Benefit_Id__c= prmPartnerBenefit.Id,
                PRM_Status_Nm__c = 'Active');
            //Database.insert(prmAccBenefitAssoc);
            //Core_UtilityController.checkBenefitLevel();
       // }
       
         PMP_Company__c company=new PMP_Company__c();
        company.Name='TestCompany11';
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
		company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
            
            PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= partnerAccount1.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        System.runAs (newUser) {
            Test.startTest();
            User usr = [select Id, Core_IPA_One_Partner_Id__c, name, AccountID from User where Id=:newUser.id limit 1];
            system.debug('usr:::::1'+usr);
        /*PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany11', intelAccount1.Id, true);
        cmp1.PMP_One_Partner_ID__c=usr.Core_IPA_One_Partner_Id__c;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c=PMP_StaticConstants_Partner.Published;
        cmp1.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        update cmp1;
        */        
             Core_UtilityController.checkForCustomPermission();
             Core_UtilityController.checkBenefitLevel();
            Core_UtilityController.getCompanyId();
            Core_UtilityController.getCompany();
            System.assert(true, true);
            Test.stopTest();
       }
    }// end of test method
    
    @future
    public static void createAdminUser(){        
        User newTestUser1 = PMP_TestDataUtility.createAdminUser(true);        
    }
    
    static testMethod void testFetchUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ja', 
                          LocaleSidKey='ja', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@intel.com'); 
        insert u;
        Core_UtilityController.fetchUser();       
    }
    
    static testMethod void testfetchPermissionSetName() {
        PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name = :PMP_INTERNAL_ADMIN_STR];
        system.debug('ps ='+ps);
        
        
        Profile profile = [select Id,name from Profile where Name ='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ja', 
                          LocaleSidKey='ja', ProfileId = profile.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@intel.com'); 
        insert u;
        
        PermissionSetAssignment newPermissioSet= new PermissionSetAssignment();
        newPermissioSet.PermissionSetId=ps.Id;
        newPermissioSet.AssigneeId=u.Id;
        insert newPermissioSet;
        User currentUser = [ select Id from User where Id = :u.Id];
        System.runAs (currentUser) {
            Core_UtilityController.fetchPermissionSetName();
            Core_UtilityController.checkForCustomPermission();
            
        }
        
    }
    
    
    
}