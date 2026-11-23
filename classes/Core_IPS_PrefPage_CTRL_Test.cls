@isTest
public class Core_IPS_PrefPage_CTRL_Test {
  
    @isTest
    static void SubmitChoice_Test(){
        
        Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        account accountRecord=new account();
        accountRecord.Name='test';
        accountRecord.BillingCity='new york';
        accountRecord.BillingCountry='united states';
        accountRecord.BillingCountryCode='';
        accountRecord.BillingStreet='st 124563 louis street';
		accountRecord.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        insert accountRecord;
        System.assert(accountRecord.Id != null, 'Record not created');

         Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=accountRecord.Id;
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        con.MailingCountry = 'India';
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');

        
        User userAccount=new User();
        userAccount.Username='Genjiuser@apttus.com';
        userAccount.FirstName='Testing';
        userAccount.LastName='user';
        userAccount.ContactId=con.Id;
        userAccount.Email='genjitesting@apttus.com';
        userAccount.Alias='Testuser';
        userAccount.EmailEncodingKey='ISO-8859-1';
        userAccount.LanguageLocaleKey = 'en_US';
        userAccount.TimeZoneSidKey='America/New_York';
        userAccount.ProfileId= pf.Id;
        userAccount.LocaleSidKey='en_US';
        insert userAccount;
        System.assert(userAccount.Id != null, 'Record not created');

        System.runAs(userAccount){
         Core_IPS_PrefPage_CTRL.SubmitChoice('India',false,false,'America/New_York');
            }
    }
    
    @isTest static void getAccounts_Method(){ 
          Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        account accountRecord=new account();
        accountRecord.Name='test';
        accountRecord.BillingCity='new york';
        accountRecord.BillingCountry='united states';
        accountRecord.BillingCountryCode='';
        accountRecord.BillingStreet='st 124563 louis street';
		accountRecord.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        insert accountRecord;
        System.assert(accountRecord.Id != null, 'Record not created');

         Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=accountRecord.Id;
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        con.MailingCountry = 'India';
       
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');

        User userAccount=new User();
        userAccount.Username='Genjiuser@apttus.com';
        userAccount.FirstName='Testing';
        userAccount.LastName='user';
        userAccount.ContactId=con.Id;
        userAccount.Email='genjitesting@apttus.com';
        userAccount.Alias='Testuser';
        userAccount.EmailEncodingKey='ISO-8859-1';
        userAccount.LanguageLocaleKey = 'en_US';
        userAccount.TimeZoneSidKey='America/New_York';
        userAccount.ProfileId= pf.Id;
        userAccount.LocaleSidKey='en_US';
        insert userAccount;
        System.assert(userAccount.Id != null, 'Record not created');

        System.runAs(userAccount){
       Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController();
            Core_IPS_PrefPage_CTRL.gettimezone();
       }
       
    }  
     @isTest static void getAccounts_Method1(){ 
          Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        account accountRecord=new account();
        accountRecord.Name='test';
        accountRecord.BillingCity='new york';
        accountRecord.BillingCountry='united states';
        accountRecord.BillingCountryCode='';
        accountRecord.BillingStreet='st 124563 louis street';
		accountRecord.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        insert accountRecord;
		System.assert(accountRecord.Id != null, 'Record not created');
        
         Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=accountRecord.Id;
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = true;
        con.MailingCountry = 'India';
       
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');

        User userAccount=new User();
        userAccount.Username='Genjiuser@apttus.com';
        userAccount.FirstName='Testing';
        userAccount.LastName='user';
        userAccount.ContactId=con.Id;
        userAccount.Email='genjitesting@apttus.com';
        userAccount.Alias='Testuser';
        userAccount.EmailEncodingKey='ISO-8859-1';
        userAccount.LanguageLocaleKey = 'en_US';
        userAccount.TimeZoneSidKey='America/New_York';
        userAccount.ProfileId= pf.Id;
        userAccount.LocaleSidKey='en_US';
        insert userAccount;
        
        System.runAs(userAccount){
       Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController();
            Core_IPS_PrefPage_CTRL.gettimezone();
       }
       
    }  
}