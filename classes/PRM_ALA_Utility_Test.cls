@isTest
public class PRM_ALA_Utility_Test {
    
          
     static testMethod void PopulateLegalAgreeOnOPID(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = accountRTPartnerAccountGroup;
        acc.Name='Partner Account';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        insert acc;
        
         Account acc1 = new Account();
         acc1.RecordTypeId = accountRecordTypeIntel;
        acc1.Name='Intel Account';
        acc1.Core_Account_Type__c ='Distributor';
        acc1.Industry='Agriculture';
        acc1.BillingCity='New Delhi';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,New Road';
        acc1.BillingPostalCode='110037';
        acc1.BillingStateCode='KA';
        insert acc1;
        
        Contact con = new Contact();
        con.firstname='Partner';
        con.lastname='Contact1';
        con.AccountId=acc.Id;
        con.Email='dellco1234@dell.com';
        con.MailingCountry ='USA';
        con.MailingCity ='Mississippi';
        con.MailingPostalCode='421910';
        con.MailingState ='AK';
        con.MailingStreet ='BandraStreet';
        insert con;
        
        List<Account> accts1 = new List<Account>();        
       /* Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=accountRTPartnerAccountGroup);
        System.debug('partnerAccount ='+partnerAccount1.IsPartner);
        accts1.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts1.add(intelAccount1);
        Insert accts1 ;*/
		
        PRM_PartnerAgreement__c p=new PRM_PartnerAgreement__c();
        p.Name='Intel Partner Alliance Terms & Condition';
        p.PRM_InActive_Ind__c=false;
        p.PRM_Agreement_Cd__c='IPA_TANDC';
        insert p;
        
         Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = acc.Id;
        agm.Core_Intel_Account_Id__c = acc1.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        insert agm;
         
        PRM_AccountLegalAgreemntAssociation__c alaa = new PRM_AccountLegalAgreemntAssociation__c();
        alaa.PRM_Account_Id__c = acc1.Id;
        alaa.PRM_Partner_Agreement_Id__c = p.Id;
        alaa.PRM_Signed_By_Email__c = con.Email;
        alaa.PRM_Signed_By_Name__c = con.FirstName + ' ' + con.LastName;
        alaa.PRM_Agreement_Sign_Dt__c=system.now();
        insert alaa;
        
        alaa.PRM_Notes_Txt__c= 'Testing';
        update alaa; 
         List<PRM_AccountLegalAgreemntAssociation__c> alaList = new List<PRM_AccountLegalAgreemntAssociation__c>();
         alaList.add(alaa);
         PRM_ALA_Utility.PopulateLegalAgreeOnOPID(alaList); 



         //For delete

         Account acc2 = new Account();
        acc2.RecordTypeId = accountRTPartnerAccountGroup;
        acc2.Name='Test Partner Account';
        acc2.Core_Account_Type__c ='Distributor';
        acc2.Industry='Agriculture';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='BTM 2nd stage';
        acc2.BillingPostalCode='560076';
        acc2.BillingStateCode='KA';
        insert acc2;
        
         Account acc3 = new Account();
         acc3.RecordTypeId = accountRecordTypeIntel;
        acc3.Name='Test intel account';
        acc3.Core_Account_Type__c ='Distributor';
        acc3.Industry='Agriculture';
        acc3.BillingCity='Bengaluru';
        acc3.BillingCountryCode='IND';
        acc3.BillingStreet='BTM 2nd stage';
        acc3.BillingPostalCode='560076';
        acc3.BillingStateCode='KA';
        insert acc3;
        
        Contact con2 = new Contact();
        con2.firstname='Partner';
        con2.lastname='Contact1';
        con2.AccountId=acc2.Id;
        con2.Email='delltestingco1234@dell.com';
        con2.MailingCountry ='USA';
        con2.MailingCity ='Mississippi';
        con2.MailingPostalCode='421910';
        con2.MailingState ='AK';
        con2.MailingStreet ='BandraStreet';
        insert con2;
        
        List<Account> accts2 = new List<Account>();        
      
        
         Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = acc2.Id;
        agm2.Core_Intel_Account_Id__c = acc3.Id;
        agm2.Core_MDA_Ind__c = true;
        agm2.Core_Inactive_Ind__c = false;
        insert agm2;
         
        PRM_AccountLegalAgreemntAssociation__c alaa2 = new PRM_AccountLegalAgreemntAssociation__c();
        alaa2.PRM_Account_Id__c = acc3.Id;
        alaa2.PRM_Partner_Agreement_Id__c = p.Id;
        alaa2.PRM_Signed_By_Email__c = con2.Email;
        alaa2.PRM_Signed_By_Name__c = con2.FirstName + ' ' + con2.LastName;
        alaa2.PRM_Agreement_Sign_Dt__c=system.now();
        insert alaa2;

        delete alaa2;
        
        
        Test.stopTest();
    }
}