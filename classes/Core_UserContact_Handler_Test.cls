/**************************************************************************************
Apex Class Name:  Core_UserContact_Handler_Test
Version     : 1.0 
Created Date: 20 June 2020
Function    : Test Class for Core_UserContact_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree H R            06/20/2020              Original Version
*************************************************************************************/
@istest
public class Core_UserContact_Handler_Test{
    private static Account accountInstance {
        get;
        set;
    }
    private static Contact contactInstance {
        get;
        set;
    } 
        
    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data 
     * Return Type  : None
     * Parameter    : None
     */
    static void setupData() {                    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        List<User> userList = new List<User>();
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@intel.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = p.Id, 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        userList.add(userWithRole);
        User userWithRole1 = new User(alias = 'hasrole1', email='userwithrole1@intel.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = p.Id, 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole1@testorg.com');
        userList.add(userWithRole1);                        
        insert userList;
                
        accountInstance = new Account();
        accountInstance.name = 'Test0';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.Core_Sales_Groups__c='PRC Sales Group';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';
        accountInstance.BillingPostalCode = '577100';
        accountInstance.Core_Sales_Groups__c='US Sales Group';
        accountInstance.Name = 'Deloitte0';
                       
        contactInstance = new Contact();
        contactInstance = new Contact();
        contactInstance.FirstName = 'test';
        contactInstance.LastName =  '0';
        contactInstance.email = 'test@test0.com';
        
        //Insert Account and Contact records                 
        System.runAs(userWithRole){
            insert accountInstance;                              
            contactInstance.AccountId = accountInstance.Id;
            contactInstance.Email = 'tet77st0@tes.com';        
            insert contactInstance;
        }                     
            
        System.runAs(userWithRole1){
            List <Core_Trigger_Executions__c> custTriggerExec = new List <Core_Trigger_Executions__c>();
            custTriggerExec = Core_Test_Utility.Core_TriggerExecution(7);
            custTriggerExec[0].name ='userGeoUpdate';
            custTriggerExec[1].name ='assignLanguage';
            custTriggerExec[2].name ='userFreezeUnfreeze';
            custTriggerExec[3].name ='createFeed';
            custTriggerExec[4].name ='userEmployeeTypeGroupAssignment';
            custTriggerExec[5].name ='userProfileGroupAssignment';
            custTriggerExec[6].name ='updateAGSInactiveOnUserDeactivation';
            insert custTriggerExec;
        }                          
    }
    
    /*
     * Method name  : testupdateAGSInactiveFieldTrue
     * Description  : Method to test updateAGSInactiveField
     * Return Type  : None
     * Parameter    : None
     */
    static testMethod void testupdateAGSInactiveFieldTrue(){      
        setupData();
        Profile p1 = [select id from profile where Name = 'Partner' limit 1];  
        User pu = new User(profileId = p1.id, username = 'puser000@intel.com', email = 'puser000@intel.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = contactInstance.Id);            
        Test.startTest();
            insert pu;
            pu.IsActive = false;             
            update pu; 
        Test.stopTest();       
    }
    
    /*
     * Method name  : testupdateAGSInactiveFieldFalse
     * Description  : Method to test updateAGSInactiveField
     * Return Type  : None
     * Parameter    : None
     */
    static testMethod void testupdateAGSInactiveFieldFalse(){
        setupData();
        Test.startTest();
        
        Profile p1 = [select id from profile where Name = 'Partner' limit 1];  
        User pu = new User(profileId = p1.id, username = 'puser000@intel.com', email = 'puser000@intel.com',
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = contactInstance.Id, IsActive= false);            
        
            insert pu;
            pu.IsActive = true;             
            update pu;
        Test.stopTest();       
    }
}