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
public without sharing class Core_UtilityControllerTest {
    public static final String PMP_INTERNAL_ADMIN_STR = 'PMP_Internal_Intel_Admin';
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
        System.runAs (currentUser) {
        Database.insert(newPermissioSet);
        }
        
        Core_UtilityController.fetchPermissionSetName();
        
        Core_IPS_Error_Code__c newCustomSetting = new Core_IPS_Error_Code__c();
        newCustomSetting.Name= 'G115';
        newCustomSetting.Language__c='English';
        newCustomSetting.Core_Locale__c='EN';
        newCustomSetting.Core_Error_Message__c='You have insufficient privilege for this action.';
       
       // newCustomSetting.Error Message='You have insufficient privilege for this action'.
            insert(newCustomSetting); 
        //UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
        Profile profile = [select Id,name from Profile where Name ='Partner'];
        List<User> userList = new List<User>();
        Account intelAccount1 = new Account(Name ='IntelAccount1',
                                            Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',
                                            BillingStreet='cbc chowk delhi',Core_Account_Type__c='Original Design Manufacturer (ODM)');
        Database.insert(intelAccount1);
        System.debug('intelAccount1 inserted = '+ intelAccount1);
        
        Contact contact1 = new Contact(firstname='Intel', 
                    lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com');
        Database.insert(contact1);
        
                
        User newUser = new User(
            // UserRoleId = userRole.Id,
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
        Database.insert(newUser);
        
        
          
    	//System.runAs (newUser) {
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
            Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                                  Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            
            Database.insert(partnerAccount1);
            
            Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
            accGroupMem1.Core_Partner_Account_Id__c = partnerAccount1.Id;
            accGroupMem1.Core_Intel_Account_Id__c = intelAccount1.Id;
            accGroupMem1.Core_MDA_Ind__c = true;
            accGroupMem1.Core_Inactive_Ind__c = false;
            
            Database.insert(accGroupMem1);

            ChannelProgram cProg = new ChannelProgram(Name = 'Intel Partner Alliance');
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
            insert acctMembership;
            
            
            PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(Name =System.Label.PMP_Offering_Benefit,
                                                                                PRM_Benefit_Cd__c = 'SMEN',
                                                                                PRM_Channel_Program_Id__c = cProg.Id);
            Database.insert(prmPartnerBenefit);
            
            PRM_AccountBenefitAssociation__c prmAccBenefitAssoc = new PRM_AccountBenefitAssociation__c(
                PRM_Account_Id__c = intelAccount1.Id,
                PRM_Partner_Benefit_Id__c= prmPartnerBenefit.Id,
                PRM_Status_Nm__c = 'Active');
            Database.insert(prmAccBenefitAssoc);
            //Core_UtilityController.checkBenefitLevel();
        //}
		System.runAs (newUser) {
            Test.startTest();
        	 Core_UtilityController.checkForCustomPermission();
             Core_UtilityController.checkBenefitLevel();
            Core_UtilityController.getCompanyId();
            Test.stopTest();
        }
        
    }// end of test method

}