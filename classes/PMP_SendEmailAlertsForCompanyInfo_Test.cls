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
    public static void PMP_SendEmailAlertsForCompanyInfo_setUp() {
        Id intel_Core_Partner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId(); 
        Id master_Partner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
       
        
        Id pagRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();   
        List<Account> accList = New List<Account>();
        Account intelCorePartnerAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',intel_Core_Partner, false);
        Account intelAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',master_Partner, false);
        intelCorePartnerAcc1.RecordtypeId = pagRecordTypeId ;
        Account intelAcc2 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',master_Partner, false);
        //intelAcc2.RecordtypeId = pagRecordTypeId ;
        accList.add(intelCorePartnerAcc1);
        accList.add(intelAcc1);
        accList.add(intelAcc2);
        insert accList;
        
        ChannelProgram cProg = new ChannelProgram(Name = 'Intel Partner Alliance');
        Database.insert(cProg);
        PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(Name =System.Label.PMP_Offering_Benefit,
                                                                                PRM_Benefit_Cd__c = 'SMEN',
                                                                                PRM_Channel_Program_Id__c = cProg.Id);
        Database.insert(prmPartnerBenefit);
            
        PRM_AccountBenefitAssociation__c prmAccBenefitAssoc = new PRM_AccountBenefitAssociation__c(
            PRM_Account_Id__c = intelAcc1.Id,
            PRM_Partner_Benefit_Id__c= prmPartnerBenefit.Id,
            PRM_Status_Nm__c = 'Active');
      //  Database.insert(prmAccBenefitAssoc);

        List<Contact> contList = New List<Contact>();
        Contact cont1 = PMP_TestDataUtility.createContact(intelAcc1.id,false);
        contList.add(cont1);
        Contact cont2 = PMP_TestDataUtility.createContact(intelAcc2.id,false);
        contList.add(cont2);
        insert contList;

        User administrator = PMP_TestDataUtility.createUser(true);
        createUserRole();
        assignRole(administrator.id);
        
        System.runAs(administrator) {

            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner'];
            User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = partnerProfile.id,
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com'
                                     ,FirstName='Test',ContactId = cont1.id);
                                     
            
    
            
            insert testUser;
            insertPermission(testUser.id);
            
            List<Core_Account_Group_Member__c> pagList = New List<Core_Account_Group_Member__c>();
            Core_Account_Group_Member__c pag1 = New Core_Account_Group_Member__c(Core_MDA_Ind__c = True,
                                                Core_Partner_Account_Id__c = intelCorePartnerAcc1.id,
                                                Core_Intel_Account_Id__c = intelAcc1.id);
            Core_Account_Group_Member__c pag2 = New Core_Account_Group_Member__c(Core_MDA_Ind__c = True,
                                                Core_Partner_Account_Id__c = intelCorePartnerAcc1.id,
                                                Core_Intel_Account_Id__c = intelAcc2.id);                                    
            pagList.add(pag1);
            pagList.add(pag2);        
            insert(pagList);
            PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('Test', intelAcc1.id,true);
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
    private static void assignRole(id userId){
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        user usr = [Select id, UserRoleId from user where id =: userId];
        usr.UserRoleId = role.id;
        update usr; 
    }
    
    
    

   public static testMethod void sendEmailTest(){
    PMP_Company__c compInfo = [Select Name, PMP_Account_Id__c from PMP_Company__c limit 1 ];
    //compInfo.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
    test.startTest();
    List<string> paramList = New List<string>();
    paramList.add(compInfo.id+'|'+'No_update_for_six_months');
    PMP_SendEmailAlertsForCompanyInfo.PMP_SendEmailAlertsForCompanyInfo(paramList);
    test.stopTest();
   }

}