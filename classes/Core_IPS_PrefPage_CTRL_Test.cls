@isTest
public class Core_IPS_PrefPage_CTRL_Test {
  
    @isTest
    static void SubmitChoice_Test(){
        
        Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
        System.assert(Acc.Id != null, 'Record not created');

         Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        con.MailingCountry = 'India';
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');

        
        User UserAcc=new User();
        UserAcc.Username='Genjiuser@apttus.com';
        UserAcc.FirstName='Testing';
        UserAcc.LastName='user';
        UserAcc.ContactId=con.Id;
        UserAcc.Email='genjitesting@apttus.com';
        UserAcc.Alias='Testuser';
        UserAcc.EmailEncodingKey='ISO-8859-1';
        UserAcc.LanguageLocaleKey = 'en_US';
        UserAcc.TimeZoneSidKey='America/New_York';
        UserAcc.ProfileId= pf.Id;
        UserAcc.LocaleSidKey='en_US';
        insert UserAcc;
        System.assert(UserAcc.Id != null, 'Record not created');

        System.runAs(UserAcc){
         Core_IPS_PrefPage_CTRL.SubmitChoice('India',false,false,'America/New_York');
            }
    }
    
    @isTest static void getAccounts_Method(){ 
          Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
        System.assert(Acc.Id != null, 'Record not created');

         Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = false;
        con.MailingCountry = 'India';
       
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');

        User UserAcc=new User();
        UserAcc.Username='Genjiuser@apttus.com';
        UserAcc.FirstName='Testing';
        UserAcc.LastName='user';
        UserAcc.ContactId=con.Id;
        UserAcc.Email='genjitesting@apttus.com';
        UserAcc.Alias='Testuser';
        UserAcc.EmailEncodingKey='ISO-8859-1';
        UserAcc.LanguageLocaleKey = 'en_US';
        UserAcc.TimeZoneSidKey='America/New_York';
        UserAcc.ProfileId= pf.Id;
        UserAcc.LocaleSidKey='en_US';
        insert UserAcc;
        System.assert(UserAcc.Id != null, 'Record not created');

        System.runAs(UserAcc){
       Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController();
            Core_IPS_PrefPage_CTRL.gettimezone();
       }
       
    }  
     @isTest static void getAccounts_Method1(){ 
          Profile pf= [Select Id from profile where Name='IPS External Customer'];
        
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
		System.assert(Acc.Id != null, 'Record not created');
        
         Contact con=new Contact();
        con.Firstname='test';
        con.lastname='test contact';
        con.Email='test@gmail.com';
        con.AccountId=Acc.Id;
        con.Core_MINDS__c = false;
        con.Core_Country_Region__c = 'India';
        con.Core_IPS_Email_Opt_Out__c = true;
        con.MailingCountry = 'India';
       
        List<Contact> conLst = new List<Contact>();
        conLst.add(con);
        insert conLst;
        System.assert(conLst[0].Id != null, 'Record not created');

        User UserAcc=new User();
        UserAcc.Username='Genjiuser@apttus.com';
        UserAcc.FirstName='Testing';
        UserAcc.LastName='user';
        UserAcc.ContactId=con.Id;
        UserAcc.Email='genjitesting@apttus.com';
        UserAcc.Alias='Testuser';
        UserAcc.EmailEncodingKey='ISO-8859-1';
        UserAcc.LanguageLocaleKey = 'en_US';
        UserAcc.TimeZoneSidKey='America/New_York';
        UserAcc.ProfileId= pf.Id;
        UserAcc.LocaleSidKey='en_US';
        insert UserAcc;
        
        System.runAs(UserAcc){
       Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController();
            Core_IPS_PrefPage_CTRL.gettimezone();
       }
       
    }  
}