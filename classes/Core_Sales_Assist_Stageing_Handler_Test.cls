@isTest
public class Core_Sales_Assist_Stageing_Handler_Test {
    
    @testSetup static void setup() {
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
        triggerSetting.name = 'updateSalesAssistStatus';
        triggerSetting.Core_Object__c = 'Core_Sales_Assist_Stageing ';
        triggerSetting.Core_Active__c = TRUE;
        triggerSetting.Core_Description__c = 'This is test description';
        triggerSetting.Core_Class_Name__c = 'Core_Sales_Assist_Stageing_ServieHandler   ';
        triggerSetting.Core_Trigger_Events__c = 'After Insert, After Update';
        triggerSettingList.add(triggerSetting);
        insert triggerSettingList;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u = new User(Alias = 'standt', Email='abcdtest1234@apttus.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',UserName='abcdtest1234@gmail.com');
        insert u;
    }
    
    static TestMethod void addingSalesAssistAccounts1_Test() { 
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        list<Core_Sales_Assist_Staging__c> salAssistIds=new list<Core_Sales_Assist_Staging__c>();
        Core_Sales_Assist_Staging__c csAs=new Core_Sales_Assist_Staging__c();
        csAs.Core_SA_Is_Active_Ind__c=true;
        csAs.Core_CIM_Id__c='12344';
        csAs.Core_Unified_Id__c='12344';
        csAs.Core_Sales_Assist_Value__c='5';
        system.runAs(us[0]) { 
            insert csAs;
        }
        salAssistIds.add(csAs);
        Core_Sales_Assist_Stageing_ServieHandler.addOrRemoveSalesAssistAccounts(salAssistIds);
        
        Account lstAccount = new Account();
        lstAccount.Name='newtestaccount';
        lstAccount.BillingCountryCode = 'USA';
        lstAccount.BIllingStateCode = 'AL';
        lstAccount.BillingCity = 'Alabama';
        lstAccount.BillingStreet = 'test';
        lstAccount.Core_Business_Party_Id__c='12345';
        insert lstAccount;
        
        Account lstAccount1 = new Account();
        lstAccount1.Name='newtestaccount1';
        lstAccount1.BillingCountryCode = 'USA';
        lstAccount1.BIllingStateCode = 'AL';
        lstAccount1.BillingCity = 'Alabamaa';
        lstAccount1.BillingStreet = 'testq';
        lstAccount1.Core_Business_Party_Id__c='12346';
        insert lstAccount1;
        
        list<Core_Sales_Assist_Staging__c> salAssistList=new list<Core_Sales_Assist_Staging__c>();
        
        //set<string> cimIDs=new set<string>();
        
        
        Core_Sales_Assist_Staging__c csAs1=new Core_Sales_Assist_Staging__c();
        csAs1.Core_SA_Is_Active_Ind__c=true;
        csAs1.Core_CIM_Id__c='12345';
        csAs1.Core_Unified_Id__c='12345';
        csAs1.Core_Sales_Assist_Value__c='6';
        salAssistList.add(csAs1);
        Core_Sales_Assist_Staging__c csAs2=new Core_Sales_Assist_Staging__c();
        csAs2.Core_SA_Is_Active_Ind__c=true;
        csAs2.Core_CIM_Id__c='12347';
        csAs2.Core_Unified_Id__c='12347';
        csAs2.Core_Sales_Assist_Value__c='9';
        salAssistList.add(csAs2);
        system.runAs(us[0]){
            insert salAssistList;
            Core_Sales_Assist_Stageing_ServieHandler.addOrRemoveSalesAssistAccounts(salAssistList);
        }       
        
        salAssistIds[0].Core_Sales_Assist_Value__c='0';
        update salAssistIds;
        Core_Sales_Assist_Stageing_ServieHandler.addOrRemoveSalesAssistAccounts(salAssistIds);
        
        salAssistList[0].Core_Sales_Assist_Value__c = '0';
        salAssistList[1].Core_Sales_Assist_Value__c = '0';
        update salAssistList;
        Core_Sales_Assist_Stageing_ServieHandler.addOrRemoveSalesAssistAccounts(salAssistList);
        
        System.assertEquals(0, integer.valueof(salAssistList[0].Core_Sales_Assist_Value__c), 'addingSalesAssistAccounts1_Test');
    }
    
    static TestMethod void addingSalesAssistAccounts2_Test() {
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        RecordType accRecType = [Select Id, DeveloperName FROM Recordtype WHERE DeveloperName='Mastered_Account' and SobjectType ='Account'];
        system.runAs(us[0]) {
            Account lstAccount = new Account();
            lstAccount.Name='newtestaccount';
            lstAccount.BillingCountryCode = 'USA';
            lstAccount.BIllingStateCode = 'AL';
            lstAccount.BillingCity = 'Alabama';
            lstAccount.BillingStreet = 'test';
            lstAccount.Core_Business_Party_Id__c='12345';
            //lstAccount.Core_Owner_Changed_From_Uncovered__c = true;
            //lstAccount.Industry = 'To Be Defined';
            lstAccount.RecordTypeId = accRecType.Id;
            insert lstAccount;
        }
        Account lstAccount1 = new Account();
        lstAccount1.Name='newtestaccount1';
        lstAccount1.BillingCountryCode = 'USA';
        lstAccount1.BIllingStateCode = 'AL';
        lstAccount1.BillingCity = 'Alabamaa';
        lstAccount1.BillingStreet = 'testq';
        lstAccount1.Core_Business_Party_Id__c='123456';
        insert lstAccount1;
        
        list<Core_Sales_Assist_Staging__c> salAssistList=new list<Core_Sales_Assist_Staging__c>();
        
        set<string> cimIDs=new set<string>();
        
        
        Core_Sales_Assist_Staging__c csAs=new Core_Sales_Assist_Staging__c();
        csAs.Core_SA_Is_Active_Ind__c=true;
        csAs.Core_CIM_Id__c='12345';
        csAs.Core_Unified_Id__c='12345';
        csAs.Core_Sales_Assist_Value__c='4';
        salAssistList.add(csAs);
        cimIDs.add(csAs.Core_CIM_Id__c);
        system.runAs(us[0]) {
            Test.startTest();
                insert salAssistList;
            Test.stopTest();    
        }       
        System.assertnotEquals(0, integer.valueof(salAssistList[0].Core_Sales_Assist_Value__c), 'addingSalesAssistAccounts2_Test');
    }
    static TestMethod void removingSalesAssistAccounts_Test() {
        
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        
        list<Core_Sales_Assist_Staging__c> salAssistList=new list<Core_Sales_Assist_Staging__c>();
        set<string> cimIDs=new set<string>();
        Core_Sales_Assist_Staging__c csAs=new Core_Sales_Assist_Staging__c();
        csAs.Core_SA_Is_Active_Ind__c=true;
        csAs.Core_CIM_Id__c='12345';
        csAs.Core_Unified_Id__c='12345';
        csAs.Core_Sales_Assist_Value__c='3';
        salAssistList.add(csAs);
        cimIDs.add(csAs.Core_CIM_Id__c);        
        insert salAssistList;
        
        Account lstAccount = new Account();
        lstAccount.Name='newtestaccount';
        lstAccount.BillingCountryCode = 'USA';
        lstAccount.BIllingStateCode = 'AL';
        lstAccount.BillingCity = 'Alabama';
        lstAccount.BillingStreet = 'test';
        lstAccount.Core_Business_Party_Id__c='12345';
        insert lstAccount;
        
        Account lstAccount1 = new Account();
        lstAccount1.Name='newtestaccount1';
        lstAccount1.BillingCountryCode = 'USA';
        lstAccount1.BIllingStateCode = 'AL';
        lstAccount1.BillingCity = 'Alabama';
        lstAccount1.BillingStreet = 'test';
        lstAccount1.Core_Business_Party_Id__c='12345';
        lstAccount1.Core_Sales_Assist_Staging__c=salAssistList[0].id;
        insert lstAccount1;
        
        list<Core_Sales_Assist_Staging__c> inActiveSalAstList=new list<Core_Sales_Assist_Staging__c>();
        
        Core_Sales_Assist_Staging__c cs=new Core_Sales_Assist_Staging__c();
        cs.Core_Sales_Assist_Value__c='0';
        cs.id=salAssistList[0].id;
        inActiveSalAstList.add(cs);
        system.runAs(us[0]) {
            Test.startTest();
                update inActiveSalAstList;
            Test.stopTest();
        }
                        
        System.assertEquals(0, integer.valueof(inActiveSalAstList[0].Core_Sales_Assist_Value__c), 'removingSalesAssistAccounts_Test');
    }
    
    static TestMethod void removingSalesAssistAccounts2_Test() {
        
        list<User> us=[select id,UserName from user where Email='abcdtest1234@apttus.com'];
        RecordType accRecType = [Select Id, DeveloperName FROM Recordtype WHERE DeveloperName='Mastered_Account' and SobjectType ='Account'];
        list<Core_Sales_Assist_Staging__c> salAssistList=new list<Core_Sales_Assist_Staging__c>();
        set<string> cimIDs=new set<string>();
        Core_Sales_Assist_Staging__c csAs=new Core_Sales_Assist_Staging__c();
        csAs.Core_SA_Is_Active_Ind__c=true;
        csAs.Core_CIM_Id__c='12345';
        csAs.Core_Unified_Id__c='12345';
        csAs.Core_Sales_Assist_Value__c='7';
        salAssistList.add(csAs);
        cimIDs.add(csAs.Core_CIM_Id__c);
        insert salAssistList;
        
        system.runAs(us[0]) {
            Account lstAccount = new Account();
            lstAccount.Name='newtestaccount';
            lstAccount.BillingCountryCode = 'USA';
            lstAccount.BIllingStateCode = 'AL';
            lstAccount.BillingCity = 'Alabama';
            lstAccount.BillingStreet = 'test';
            lstAccount.Core_Business_Party_Id__c='12345';
            //lstAccount.Core_Owner_Changed_From_Uncovered__c = true;
            //lstAccount.Industry = 'To Be Defined';
            lstAccount.RecordTypeId = accRecType.Id;
            insert lstAccount;
        }
        
        list<Core_Sales_Assist_Staging__c> inActiveSalAstList=new list<Core_Sales_Assist_Staging__c>();
        
        Core_Sales_Assist_Staging__c cs=new Core_Sales_Assist_Staging__c();
        cs.Core_Sales_Assist_Value__c='0';
        cs.id=salAssistList[0].id;
        inActiveSalAstList.add(cs);
        system.runAs(us[0]) {
            Test.startTest();
                update inActiveSalAstList;
            Test.stopTest();
        }
                        
        System.assertEquals(0, integer.valueof(inActiveSalAstList[0].Core_Sales_Assist_Value__c), 'removingSalesAssistAccounts2_Test');  
    }

    
}