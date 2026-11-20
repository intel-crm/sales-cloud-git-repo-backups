/****************************************************************************************************************************************
* Class Name  : PMP_SendEmailAlertsForCompanyInfo_Test 
* Version     : 1.0 
* Created Date: 03/19/2020
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Abhishek                                03/23/2020           This class is for sending Emails when company is created
*****************************************************************************************************************************************/

@isTest
public with sharing class PMP_SendEmailAlertsForCompanyInfo_Test {
    @testSetup
    public static void testDataSetUp() {
        
       
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        //createUserRole();
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
      //  assignRole(adminUser, role.id );
        
        //Need to run as admin with RoleId, to insert a partner User.
        System.runAs(adminUser) {
            
            Id intelCorePartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId(); 
            Id masterPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Id pagRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();   
            List<Account> accList = New List<Account>();
            
            //creating Partner Account
            Account intelCorePartnerAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',IntelCorePartner, false);
            intelCorePartnerAcc1.RecordtypeId = pagRecordTypeId ;
            //creating Intel accounts
            Account intelAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',masterPartner, false);
            Account intelAcc2 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount1',masterPartner, false);            
            
            //intelAcc2.RecordtypeId = pagRecordTypeId ;
            accList.add(intelCorePartnerAcc1);
            accList.add(intelAcc1);
            accList.add(intelAcc2);
            //inserting accounts
            insert accList;
            
            List<Contact> contList = New List<Contact>();
            Contact cont1 = PMP_TestDataUtility.createContact(intelAcc1.id,false);
            contList.add(cont1);
            Contact cont2 = PMP_TestDataUtility.createContact(intelAcc2.id,false);
            contList.add(cont2);
            insert contList;
            
            UserRole partnerRole = New UserRole(DeveloperName='TestPartner', name='Test');
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner'];
            /*User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = partnerProfile.id,
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com'
                                     ,FirstName='Test',ContactId = cont1.id); */
                                     
            User testUser = PMP_TestDataUtility.createUser(false);
            testUser.ProfileId = partnerProfile.id;
            testUser.ContactId = cont1.id;
            insert testUser;
            insertPermission(testUser.id);
            
            List<Core_Account_Group_Member__c> pagList = New List<Core_Account_Group_Member__c>();
            Core_Account_Group_Member__c pag1 = New Core_Account_Group_Member__c(/*Core_MDA_Ind__c = True,*/
                                                Core_Partner_Account_Id__c = intelCorePartnerAcc1.id,
                                                Core_Intel_Account_Id__c = intelAcc1.id);
            Core_Account_Group_Member__c pag2 = New Core_Account_Group_Member__c(/*Core_MDA_Ind__c = True,*/
                                                Core_Partner_Account_Id__c = intelCorePartnerAcc1.id,
                                                Core_Intel_Account_Id__c = intelAcc2.id);                                    
            pagList.add(pag1);
            pagList.add(pag2);        
            insert(pagList);
            PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('Test', intelCorePartnerAcc1.id,true);
            insertAxpeEmailRecord();
            
        }

        
    }
    @future
    private static void insertPermission(id usrId){
        

        permissionSet permission = [Select id from permissionSet Where Name = 'PMP_External_Partner_Admin'];
        PermissionSetAssignment permissionAssignment = New PermissionSetAssignment(PermissionSetId = permission.id
                                                        , AssigneeId = usrId);
        insert permissionAssignment;
    }
     @future
    private static void createUserRole(){
        UserRole role = new UserRole(DeveloperName = 'Admin', Name = 'Admin');
        //insert role;
    }
    @future 
    private static void assignRole(id userId, id roleId){
        
        user usr = [Select id, UserRoleId from user where id =: userId];
        usr.UserRoleId = roleId;
        update usr; 
    }
    
    @future
    private static void insertAxpeEmailRecord(){
        Core_Apex_EmailNotification__c record1 = New Core_Apex_EmailNotification__c(Name='New_CompanyInfo_CreationEmail_Profile', Core_Date_Reference_Txt__c =              'PMP_Company_Status_Update_Dt__c',
                                                Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin,PMP_External_Marketing_Specialist',
                                                Core_NumberOfDays_Nbr__c = 2, Core_Email_Template_Nm__c = 'PMP_CompanyInfo_nDaysInDraft_StoreFnt',
                                                Core_IsActive_Ind__c = true,Core_IsRecurring_Ind__c = false, Core_Query_String_Txt__c = 'PMP_Is_Published_Ind__c= false',
                                                Core_Object_Nm__c = 'PMP_Company__c');
        
            insert record1;
    }
    

   public static testMethod void sendEmailTest(){
    PMP_Company__c compInfo = [Select Name, PMP_Account_Id__c from PMP_Company__c limit 1 ];
    //compInfo.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    test.startTest();
    List<string> paramList = New List<string>();
    paramList.add(compInfo.id+'|'+'New_CompanyInfo_CreationEmail');
    Integer beforeInvocations = Limits.getEmailInvocations();
    System.assertEquals(0,beforeInvocations,'no email sent');
    PMP_SendEmailAlertsForCompanyInfo.PMP_SendEmailAlertsForCompanyInfo(paramList);
    compInfo.PMP_Suppress_Email_Ind__c=true;
    compInfo.PMP_Partner_Benefit_Type__c='Solutions Marketplace Basic Profile';
    update compInfo;
    PMP_SendEmailAlertsForCompanyInfo.PMP_SendEmailAlertsForCompanyInfo(paramList);
    test.stopTest();
   }

}