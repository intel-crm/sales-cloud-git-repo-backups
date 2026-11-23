@isTest
public class Core_Sales_Assist_Stageing_Handler_Test {
    
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u = new User(Alias = 'standt', Email='abcdtest1234@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName='abcdtest1234@gmail.com');
        insert u;
    }
    
    static TestMethod void addingSalesAssistAccounts_Test(){
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        
        Account lstAccount = new Account();
        lstAccount.Name='newtestaccount';
        lstAccount.BillingCountryCode = 'USA';
        lstAccount.BIllingStateCode = 'AL';
        lstAccount.BillingCity = 'Alabama';
        lstAccount.BillingStreet = 'test';
        lstAccount.Core_CIM_ID__c='12345';
        insert lstAccount;
        
        Account lstAccount1 = new Account();
        lstAccount1.Name='newtestaccount1';
        lstAccount1.BillingCountryCode = 'USA';
        lstAccount1.BIllingStateCode = 'AL';
        lstAccount1.BillingCity = 'Alabama';
        lstAccount1.BillingStreet = 'test';
        lstAccount1.Core_CIM_ID__c='12345';
        insert lstAccount1;
        
        list<Core_Sales_Assist_Staging__c> salAssistList=new list<Core_Sales_Assist_Staging__c>();
        
        set<string> cimIDs=new set<string>();
        
        
        Core_Sales_Assist_Staging__c csAs=new Core_Sales_Assist_Staging__c();
        csAs.Core_SA_Is_Active_Ind__c=true;
        csAs.Core_CIM_Id__c='12345';
        csAs.Core_Sales_Assist_Value__c='NewSalesAssist';
        salAssistList.add(csAs);
        cimIDs.add(csAs.Core_CIM_Id__c);
        insert salAssistList;
        
        Account acc = new Account();
        acc.id=lstAccount.id;
        acc.Core_Sales_Assist_Staging__c=salAssistList[0].id;
        update acc;
        
        
        
        system.runAs(us[0]){
            Core_Sales_Assist_Stageing_ServieHandler.addingSalesAssistAccounts(salAssistList);
            //Core_Sales_Assist_Stageing_ServieHandler.removingSalesAssistAccounts(inActiveSalAstList);
        }
        
    }
    static TestMethod void removingSalesAssistAccounts_Test(){
        
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        
        list<Core_Sales_Assist_Staging__c> salAssistList=new list<Core_Sales_Assist_Staging__c>();
        set<string> cimIDs=new set<string>();
        Core_Sales_Assist_Staging__c csAs=new Core_Sales_Assist_Staging__c();
        csAs.Core_SA_Is_Active_Ind__c=true;
        csAs.Core_CIM_Id__c='12345';
        csAs.Core_Sales_Assist_Value__c='NewSalesAssist';
        salAssistList.add(csAs);
        cimIDs.add(csAs.Core_CIM_Id__c);
        insert salAssistList;
        
        Account lstAccount1 = new Account();
        lstAccount1.Name='newtestaccount1';
        lstAccount1.BillingCountryCode = 'USA';
        lstAccount1.BIllingStateCode = 'AL';
        lstAccount1.BillingCity = 'Alabama';
        lstAccount1.BillingStreet = 'test';
        lstAccount1.Core_CIM_ID__c='12345';
        lstAccount1.Core_Sales_Assist_Staging__c=salAssistList[0].id;
        insert lstAccount1;
        
        list<Core_Sales_Assist_Staging__c> inActiveSalAstList=new list<Core_Sales_Assist_Staging__c>();
        
        Core_Sales_Assist_Staging__c cs=new Core_Sales_Assist_Staging__c();
        cs.Core_SA_Is_Active_Ind__c=false;
        cs.id=salAssistList[0].id;
        inActiveSalAstList.add(cs);
        update inActiveSalAstList;
        
        Account acc = new Account();
        acc.id=lstAccount1.id;
        acc.Core_Sales_Assist_Staging__c=NULL;
        update acc;
        system.runAs(us[0]){
            Core_Sales_Assist_Stageing_ServieHandler.removingSalesAssistAccounts(inActiveSalAstList);
        }
        
        
    }
    
}