@isTest
public class PMP_SendEmailForCreateOffering_Test {
    @testSetup
    public static void PMP_SendEmailAlertsForCreateOfferingInfo_setUp() {        
        
        Id usrId = [SELECT Id FROM User WHERE UserRoleId != NULL LIMIT 1].Id;
        //sheetal changes start
        Account testAccount = new Account();
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_IPA_Partner_Speciality__c='Video Specialty;Cloud Data Center Specialist';
        testAccount.OwnerId=usrId;
        insert testAccount; 
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        insert cont;
       
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        insert partnerAccount1;
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c=testAccount.Id;
        insert accGroupMem;
       
        PMP_Company__c companyInfo = new PMP_Company__c();
        companyInfo.name = 'Test';
        companyInfo.PMP_Account_Id__c = testAccount.id;
        companyInfo.PMP_Is_Published_Ind__c = true;
        companyInfo.PMP_Account_Industry__c='Others';
        companyInfo.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        
        insert companyInfo;
    }
    
    @future
    private static void insertPermission(id usrId){
        
        System.debug('usrId'+usrId);
        permissionSet permission = [Select id from permissionSet Where Name = 'PMP_External_Partner_Admin'];
        PermissionSetAssignment permissionAssignment = New PermissionSetAssignment(PermissionSetId = permission.id
                                                                                   , AssigneeId = usrId );
        
        System.debug('usrId1'+usrId);
        insert permissionAssignment;
        System.debug('usrId2'+usrId);
    }
    
    public static testMethod void sendEmailTest(){
        PMP_Company__c compInfo = [SELECT Name, PMP_Account_Id__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c ,PMP_Company_Lifecycle_Status_Nm__c FROM PMP_Company__c LIMIT 1 ];
        system.debug('compInfo'+compInfo);
       
        Id p = [SELECT id FROM profile WHERE Name='Partner'].Id;
        String conId = [SELECT Id FROM Contact LIMIT 1].Id;
                
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
        paramList.add( compInfo.PMP_Account_Id__c +'|'+'Email_For_Create_Offering');
        PMP_SendEmailAlertForCreateOffering.PMP_SendEmailAlertForCreateOfferingInfo(paramList);
        
        test.stopTest();
    }
}