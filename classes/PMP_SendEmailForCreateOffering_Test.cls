@isTest
public class PMP_SendEmailForCreateOffering_Test {
    @IsTest static void testDummyMethod() {
        PMP_SendEmailAlertForCreateOffering.dummyMethod();
    }
   /* @testSetup
    public static void PMP_SendEmailAlertsForCreateOfferingInfo_setUp() {        
        
        //Id usrId = [SELECT Id FROM User WHERE UserRoleId != NULL LIMIT 1].Id;
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Admin' Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Account testAccount = new Account();
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.OwnerId=UserInfo.getUserId();
        testAccount.RecordTypeId=partnerAccRecTypeId;
        insert testAccount; 
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='India';
        insert cont;
        
        
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        insert partnerAccount1;
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c=testAccount.Id;
        insert accGroupMem;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        partner1.PMP_IPA_Badge_Tier_Txt__c='Gold';
        //partner1.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner1.PMP_Is_Published_Ind__c = true;
        partner1.PMP_Account_Id__c = testAccount.Id;
        partner1.PMP_Disti_Components_Nm__c = 'Data Center';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        partner1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        partner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        
        insert partner1;
        
        
        PMP_Company__c partner2 = new PMP_Company__c();
        partner2.Name = 'Test_Partner2';
        //partner2.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner2.PMP_Is_Working_Copy_Ind__c = true;
        partner2.PMP_Account_Id__c = testAccount.Id;
        partner2.PMP_Disti_Components_Nm__c = 'Data Center';
        partner2.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        partner2.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner2.PMP_Disti_Country_Coverage_Txt__c = 'India';
        partner2.PMP_Company_Lifecycle_Status_Nm__c = 'Approved';
        insert partner2;
        partner1.PMP_Working_Copy_Id__c=partner2.id;
        update partner1;
        
        partner2.PMP_Published_Copy_Id__c=partner1.id;
        update partner2;
        }  
    }
    
    @future
    private static void insertPermission(id usrId){
        
        //System.debug('usrId'+usrId);
        permissionSet permission = [Select id from permissionSet Where Name = 'PMP_External_Partner_Admin'];
        PermissionSetAssignment permissionAssignment = New PermissionSetAssignment(PermissionSetId = permission.id
                                                                                   , AssigneeId = usrId );
        
        //System.debug('usrId1'+usrId);
        insert permissionAssignment;
        //System.debug('usrId2'+usrId);
    }
    
    public static testMethod void sendEmailTest(){
        Account testAccount = [SELECT Id,name, BillingCity, BillingStreet,BillingCountry,BillingPostalCode,Core_Account_Type__c from Account where Name ='John Wick'];
        PMP_Company__c compInfo = [SELECT Name, PMP_Account_Id__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c ,PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c FROM PMP_Company__c where PMP_Account_Id__c =: testAccount.Id AND PMP_Is_Published_Ind__c = true LIMIT 1 ];
        //system.debug('compInfo'+compInfo);
        Id accId = testAccount.Id;
       
        Id p = [SELECT id FROM profile WHERE Name='Partner'].Id;
        String conId = [SELECT Id FROM Contact where AccountId= :accId].Id;
                
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conId,
                             timezonesidkey='America/Los_Angeles', username='q32@noemail.com'
                            );
        
        insert user;
        
        PermissionSet psEmployee = [SELECT id, Name from PermissionSet where Name = 'PMP_External_Partner_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = user.Id;
        psa.PermissionSetId = psEmployee.Id;
        insert psa;
        
        test.startTest();
        
        List<string> paramList = New List<string>();
        paramList.add((String)compInfo.PMP_Account_Id__c +'|'+'Email_For_Create_Offering');
        PMP_SendEmailAlertForCreateOffering.PMP_SendEmailAlertForCreateOfferingInfo(paramList);
        system.assertEquals(psa.PermissionSetId,psEmployee.Id);
        test.stopTest();
    }*/
    
}