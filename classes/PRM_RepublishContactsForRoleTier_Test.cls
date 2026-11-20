@isTest
public class PRM_RepublishContactsForRoleTier_Test {
  @isTest
    private static void dataSetUp(){
         List<Account> accList = new List<Account>();
         List<Id> conList = new List<Id>();
         List<Contact> conList1 = new List<Contact>();
        List<Contact> conListToInsert= new List<Contact>();
         Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
          Account a = PRM_TestUtility.getAccount();
           a.AccountNumber = '435766';
           a.RecordTypeId = accountRecordTypeIntel;
           a.Name='New Account';
           a.Core_Account_Type__c ='Distributor';
           a.Industry='Agriculture';
           a.BillingCity='New Delhi';
           a.BillingCountryCode='IND';
           a.BillingStreet='4th Floor,New Road';
           a.BillingPostalCode='110037';
           a.BillingStateCode='KA';
           a.Core_IPA_Partner_Role__c = 'Service Provider';
           accList.add(a);
           
           insert accList;
        
           Contact c = PRM_TestUtility.getContact();
           c.AccountId = a.Id;
           c.Email='john.harrison@maildrop.cc';
           c.Core_Preferred_Language__c = 'ENG';
           c.Core_eRPM_Language_Code__c = 'ENG';
           c.RecordTypeId = contactRecordType;
           c.Core_ERPM_Integration_Queue_txt__c='Empty';
           c.Core_Republish_OBM_s__c=false;
           c.Core_Do_Not_Contact__c = False;
           // c.Core_IPA_Partner_Role__c = 'Service Provider';
           c.Core_IPA_PartnerRole__c = 'Service Provider';
           c.MailingCountry='USA';
           c.MailingCountryCode = 'USA';
           conListToInsert.add(c);
           insert conListToInsert;
           
           for(contact c2:conListToInsert){
            conList.add(c2.id);
        }
        contact c1=[select Core_ERPM_Integration_Queue_txt__c,id,Core_Republish_OBM_s__c from contact where Id in: conList];
        contact repCon = new contact();
        repCon.Id = c1.Id;
        repCon.Core_Republish_OBM_s__c = true;
        conList1.add(repCon);
        
        Update conList1;          
        test.startTest();
        PRM_RepublishContactsForRoleTier.UpdateRepublishOnContact(conList);
        test.stopTest();
        
        System.assert(conList1.size() > 0);
    }
}