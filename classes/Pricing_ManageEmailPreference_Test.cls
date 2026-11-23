@isTest
public class Pricing_ManageEmailPreference_Test {
    
    //Method to setup Test data
    @testSetup
    public static void setUpData(){
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
        List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
        // insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template')); 
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        List<User> primaryContacts = new List<User>();
		System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);           
         }
        System.runAs(salesRepUserList[0])
        {
            Test.startTest();
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            
            Pricing_IQR_Email_Preferences__c iqrEmailPreferences1=new Pricing_IQR_Email_Preferences__c
                (Pricing_Notification_Name_Nm__c='Won/Loss Notification',Pricing_Opt_In_Ind__c=true,Pricing_User__c=salesRepUserList[0].id);
            
            insert iqrEmailPreferences1;
            Pricing_IQR_Email_Preferences__c iqrEmailPreferences2=new Pricing_IQR_Email_Preferences__c
                (Pricing_Notification_Name_Nm__c='Quote Team Notification',Pricing_Opt_In_Ind__c=true,Pricing_User__c=salesRepUserList[0].id);
            insert iqrEmailPreferences2;
            
           
            //List<Pricing_IQR_Email_Preferences__c> lstEmailPreferences=new List<Pricing_IQR_Email_Preferences__c>();
            //lstEmailPreferences.add(iqrEmailPreferences1);
            //lstEmailPreferences.add(iqrEmailPreferences2);
            Test.stopTest();
        }
        
    }
    @isTest
    static void getEmailPreference_SalesRep_Test()
    {
        List<User> salesRepUserList = [SELECT id FROM User WHERE Email= 'firstNameSalesRep@intel.com' Limit 1];
        System.runAs(salesRepUserList[0])
        {
            List<Pricing_IQR_Email_Preferences__c> lstEmailPreference=[SELECT Id,Pricing_Opt_In_Ind__c,Pricing_Notification_Name_Nm__c FROM Pricing_IQR_Email_Preferences__c];    
            Test.startTest();
            Pricing_ManageEmailPreference.getEmailPreference();
            Test.stopTest();
        }
        
    }
    @isTest
    static void getEmailPreference_ExtUser_WithEmailPref_Test()
    {
        List<Contact> cont = [SELECT id FROM Contact LIMIT 1];
        List<User> primaryContacts = [SELECT id FROM User WHERE ContactId= : cont[0].Id];
        Pricing_IQR_Email_Preferences__c iqrEmailPreferences3=new Pricing_IQR_Email_Preferences__c
                (Pricing_Notification_Name_Nm__c='Quote Team Notification',Pricing_Template_API_Name_Nm__c='Quote_Team_Notification', Pricing_Opt_In_Ind__c=true,Pricing_User__c=primaryContacts[0].id);
            insert iqrEmailPreferences3;
        System.runAs(primaryContacts[0])
        {            
            Test.startTest();
            Pricing_ManageEmailPreference.getEmailPreference();
            Test.stopTest();
        }
        
    }
    @isTest
    static void getEmailPreference_ExtUser_WithOut_EmailPref_Test()
    {
        List<Contact> cont = [SELECT id FROM Contact LIMIT 1];
        List<User> primaryContacts = [SELECT id FROM User WHERE ContactId= : cont[0].Id];
         Pricing_IQR_Email_Preferences__c iqrEmailPreferences3=new Pricing_IQR_Email_Preferences__c
                (Pricing_Notification_Name_Nm__c='Quote Team Notification',Pricing_Template_API_Name_Nm__c='Quote_Team_Notification', Pricing_Opt_In_Ind__c=true,Pricing_User__c=primaryContacts[0].id);
        insert iqrEmailPreferences3;
        System.runAs(primaryContacts[0])
        {
            List<Pricing_IQR_Email_Preferences__c> lstEmailPreference=[SELECT Id,Pricing_Opt_In_Ind__c,Pricing_Notification_Name_Nm__c FROM Pricing_IQR_Email_Preferences__c];    
            Test.startTest();
            Pricing_ManageEmailPreference.getEmailPreference();
            Test.stopTest();
        }
        
    }
    @isTest
    static void getEmailPreference_CurrentUser_Test()
    {         
        List<Pricing_IQR_Email_Preferences__c> lstEmailPreference=[SELECT Id,Pricing_Opt_In_Ind__c,Pricing_Notification_Name_Nm__c FROM Pricing_IQR_Email_Preferences__c];   
        Test.startTest();
        Pricing_ManageEmailPreference.getEmailPreference();
        Test.stopTest();       
    }
    @isTest
    static void savePreference_SalesRep_Test()
    {
        List<User> salesRepUserList = [SELECT id FROM User WHERE Email= 'firstNameSalesRep@intel.com' Limit 1];
        System.runAs(salesRepUserList[0])
        {
            List<Pricing_IQR_Email_Preferences__c> lstEmailPreference=[SELECT Id,Pricing_Opt_In_Ind__c,Pricing_Notification_Name_Nm__c FROM Pricing_IQR_Email_Preferences__c];    
            Test.startTest();
            String jsonMap = '[{"optInOut" : true,"notificationName" : "Won/Loss Notification"},{"optInOut" : false,"notificationName" : "QuoteTeam Notification"}]';
            Pricing_ManageEmailPreference.savePreferences(jsonMap);
            Pricing_ManageEmailPreference.getEmailPreference();
            Boolean loggedInUser = Pricing_ManageEmailPreference.getUserPemissionSets(salesRepUserList[0].Id);
            Test.stopTest();
        }
        
    }    
    @isTest
    static void savePreference_CurrentUser_Test()
    {         
        Test.startTest();
        String jsonMap = '[{"optInOut" : true,"notificationName" : "Won/Loss Notification"},{"optInOut" : false,"notificationName" : "QuoteTeam Notification"}]';
        Pricing_ManageEmailPreference.savePreferences(jsonMap);
        //Pricing_ManageEmailPreference.dummyMethod();
        Test.stopTest();       
    }
    
}