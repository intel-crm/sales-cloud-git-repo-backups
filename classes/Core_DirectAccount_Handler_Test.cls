/**************************************************************************************
Apex Class Name:  Core_DirectAccount_Handler_Test
Version     : 1.0 
Created Date: 24 March 2021
Function    : Test Class for the Core_DirectAccount_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*  Mahesh                 24/03/2021              Original Version
*************************************************************************************/
@isTest
public class Core_DirectAccount_Handler_Test {
    public static String DirectRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Direct Account').getRecordTypeId();
    
    static testmethod void PrimaryAccCaluculation(){
        
        Core_Trigger_Executions__c Directacc = new Core_Trigger_Executions__c();
        Directacc.name = 'UpdatePrimaryDirectAccount';
        Directacc.Core_Object__c = 'Account';
        Directacc.Core_Trigger_Events__c = 'After Update';
        Directacc.Core_Active__c = TRUE;
        Directacc.Core_Description__c = 'This is test description';
        Directacc.Core_Class_Name__c = 'Core_DirectAccount_Handler';
        
        insert Directacc;
        
        List<Account> lstAccount = Core_Test_Utility.createAccount(1);
        
        insert lstAccount;
        
        Account Acc= new Account();
        Acc.RecordtypeId=DirectRecTypeId;
        Acc.Name='Sold To Test Acc_1';
        Acc.Core_Direct_Account_Type_Nm__c='Sold To';
        Acc.ParentId=lstAccount[0].id;
        Acc.BillingCountryCode='IND';
        Acc.BillingStateCode='KA';
        Acc.BillingCity='Bangalore';
        Acc.BillingStreet='Electronic city phase 1';
        Acc.BillingPostalCode='123456';
        Insert Acc;
        
        
        
    }
    
    
    static testmethod void PrimaryAccCaluculation2(){
        
        Core_Trigger_Executions__c Directacc = new Core_Trigger_Executions__c();
        Directacc.name = 'UpdatePrimaryDirectAccount';
        Directacc.Core_Object__c = 'Account';
        Directacc.Core_Trigger_Events__c = 'After Update';
        Directacc.Core_Active__c = TRUE;
        Directacc.Core_Description__c = 'This is test description';
        Directacc.Core_Class_Name__c = 'Core_DirectAccount_Handler';
        
        insert Directacc;
        
        List<Account> lstAccount = Core_Test_Utility.createAccount(1);
        
        insert lstAccount;
        Account Acc1= new Account();
        Acc1.RecordtypeId=DirectRecTypeId;
        Acc1.Name='Ship To Test Acc_1';
        Acc1.Core_Direct_Account_Type_Nm__c='Ship To';
        Acc1.ParentId=lstAccount[0].id;
        Acc1.BillingCountryCode='IND';
        Acc1.BillingStateCode='KA';
        Acc1.BillingCity='Bangalore';
        Acc1.BillingStreet='Electronic city phase 2';
        Acc1.BillingPostalCode='12356';
        Insert Acc1;
        
    }
    
    static testmethod void PrimaryAccCaluculation3(){
        
        Core_Trigger_Executions__c Directacc = new Core_Trigger_Executions__c();
        Directacc.name = 'UpdatePrimaryDirectAccount';
        Directacc.Core_Object__c = 'Account';
        Directacc.Core_Trigger_Events__c = 'After Update';
        Directacc.Core_Active__c = TRUE;
        Directacc.Core_Description__c = 'This is test description';
        Directacc.Core_Class_Name__c = 'Core_DirectAccount_Handler';
        
        insert Directacc;
        
        List<Account> lstAccount = Core_Test_Utility.createAccount(1);
        
        insert lstAccount;
        Account Acc1= new Account();
        Acc1.RecordtypeId=DirectRecTypeId;
        Acc1.Name='Ship To Test Acc_1';
        Acc1.Core_Direct_Account_Type_Nm__c='End Customer';
        Acc1.ParentId=lstAccount[0].id;
        Acc1.BillingCountryCode='IND';
        Acc1.BillingStateCode='KA';
        Acc1.BillingCity='Bangalore';
        Acc1.BillingStreet='Electronic city phase 2777';
        Acc1.BillingPostalCode='12356222';
        Insert Acc1;
        
    }
    
    static testmethod void PrimaryAccCaluculation4(){
        
        Core_Trigger_Executions__c Directacc = new Core_Trigger_Executions__c();
        Directacc.name = 'UpdatePrimaryDirectAccount';
        Directacc.Core_Object__c = 'Account';
        Directacc.Core_Trigger_Events__c = 'After Update';
        Directacc.Core_Active__c = TRUE;
        Directacc.Core_Description__c = 'This is test description';
        Directacc.Core_Class_Name__c = 'Core_DirectAccount_Handler';
        
        insert Directacc;
        
        List<Account> lstAccount = Core_Test_Utility.createAccount(2);
        
        insert lstAccount;
        Account Acc1= new Account();
        Acc1.RecordtypeId=DirectRecTypeId;
        Acc1.Name='ECP__Test__123';
        Acc1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        Acc1.ParentId=lstAccount[0].id;
        Acc1.BillingCountryCode='IND';
        Acc1.BillingStateCode='KA';
        Acc1.BillingCity='Bangalore';
        Acc1.BillingStreet='Electronic city phase 2223777';
        Acc1.BillingPostalCode='123562222';
        Insert Acc1;
        
        Acc1.Core_Direct_Account_Type_Nm__c='Sold To';
        update Acc1;
        
        Acc1.ParentId=lstAccount[1].id;
        update Acc1;
        
    }
    
}