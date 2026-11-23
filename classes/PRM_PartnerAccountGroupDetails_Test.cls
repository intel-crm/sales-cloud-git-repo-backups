@isTest
public class PRM_PartnerAccountGroupDetails_Test {
   
      @testSetup
    static void SetupDataCreation(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
         Account a = new Account();
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
       // a.BillingCountry='India';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        insert a;
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='Walmart';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
       // acc.Core_Is_PAG_Member_Ind__c = false;
        insert acc;
        
        Account acct = PRM_TestUtility.getAccount();
        acct.RecordTypeId = accountRecordTypeIntel;
        acct.Name='Tesco';
        acct.Core_Account_Type__c ='Distributor';
        acct.Industry='Agriculture';
        acct.BillingCity='New Delhi';
        acct.BillingCountryCode='IND';
        acct.BillingStreet='4th Floor,New Road';
        acct.BillingPostalCode='110037';
        acct.BillingStateCode='KA';
        //acct.Core_Is_PAG_Member_Ind__c = false;
        insert acct;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = acc.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
       // agm.Core_Is_PAG_Member_Ind__c = true;
        insert agm;
        
         Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c();
        agm1.Core_Partner_Account_Id__c = a.Id;
        agm1.Core_Intel_Account_Id__c = acct.Id;
        agm1.Core_MDA_Ind__c = false;
        agm1.Core_Inactive_Ind__c = false;
       // agm1.Core_Is_PAG_Member_Ind__c = true;
        insert agm1;
        
        
         Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt1 = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=acc.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456');
        insert cnt1;
         
        Contact cnt2 = new Contact(FirstName='Test',LastName='Contact2',Email='testcontact2@mailinator.com',AccountId=acct.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456');
        insert cnt2;
         ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Service Provider',PRM_programCode__c='IPA',IsActive=True);
        insert cp;
         //Account Contact Relationship
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Works for';
        contRel.PRM_Contact_Relationship_Cd__c = 'CONTRELWORKSFOR';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = acc.Id;
        acr.PRM_Contact_Id__c = cnt1.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        
        PRM_Account_Contact_Relationship__c acr1  = new PRM_Account_Contact_Relationship__c();
        acr1.PRM_Account_Id__c = acct.Id;
        acr1.PRM_Contact_Id__c = cnt2.Id;
        acr1.PRM_isActive__c = True;
        acr1.PRM_Relationship_Id__c = contRel.Id;
        acr1.PRM_Status_Nm__c = 'Complete';
        insert acr1;
        
    }
          @isTest static void GetPAGDetailsTest() 
    {
        
        Test.startTest();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        String recordId=[select Id from Account where RecordTypeId=:accountRTPartnerAccountGroup].Id;
        
        PRM_PartnerAccountGroupDetails.GetPAGDetails(recordId);
        system.assert(recordId != null);
        Test.stopTest();
    }
    

}