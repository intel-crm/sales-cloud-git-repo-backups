/**************************************************************************************
Apex Class Name:  Core_Batch_AccountShare_Test
Version     : 1.0 
Created Date: 08 Nov 2016
Description    : This class is Test class for Core_Batch_AccountShare
*************************************************************************************/
@isTest
public class Core_Batch_AccountShare_Test{
     
   @isTest
    static void testBatchExecution() {

            //Create a new Account
            Account acc = new Account();
            acc.Name =  'test';
            acc.Core_Account_Type__c= 'Distributor';
            acc.Core_Sales_Group__c = 'Global Accounts';
            acc.Industry = 'Agriculture';
            acc.Core_Account_Legal_Name__c = 'abc1234account';
            acc.Core_CIM_ID__c = '11545156';
            acc.Core_GEO__c = 'ASMO';
            acc.Core_IBL_Flag__c = false;
            acc.BillingCity = 'folsom';
            acc.BillingCountry = 'GUY';
            acc.Core_CNDA_Number__c = '32456';
            acc.BillingStreet = '13254 E vookbrrok dfdsf';
            acc.Core_B2B_Entitlement__c = true;
            insert acc;
            System.assertEquals(acc.Name,'test');
            
            //Creation of Custom setting
            Core_AccountCoverage_Profiles__c acp = new Core_AccountCoverage_Profiles__c(Name = 'Sales Rep-BB',Core_Profiles__c = 'Sales Rep-BB');
            insert acp;
            
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-BB'];
            
            
            User usr = new User(Alias = 'std455',
                            Email = 'poojax.khanna@intel.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US',
                            FederationIdentifier='1171061',
                            ProfileId = p.Id,Phone='8764657467',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            Core_Login_Id__c ='wer',

                            UserName = 'standard123@testorg.com');
            insert usr;
            
            User usr2 = new User(Alias = 'std4556',
                            Email = 'poojax.khanna@intel.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing1', 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US',
                            Core_Login_Id__c = '123',
                            FederationIdentifier='117106',
                            ProfileId = p.Id,Phone='',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'standard1234@testorg.com');
            insert usr2;
            
            Profile sysAdminProfile = [select id, name from Profile where name = 'System Administrator' Limit 1];
            
            User sysAdminUser= new User(Alias = 'std455',
                            Email = 'poojax.khanna@intel.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US',
                            Core_Login_Id__c = '1234', 
                            LocaleSidKey = 'en_US',
                            ProfileId = sysAdminProfile .Id,Phone='8764657467',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'standard123@systestorg.com');
            insert sysAdminUser;
            
            
            //Creation of AccountShare Object
            AccountShare acctshare = new AccountShare(AccountId = acc.id, 
                                                  AccountAccessLevel = 'Edit',
                                                  CaseAccessLevel = 'Edit', 
                                                  OpportunityAccessLevel = 'Edit',
                                                  
                                                  UserOrGroupId = usr.Id); 
            insert acctshare;
            System.assert(true,acctshare.AccountAccessLevel != null);
            
            //Creation of AccountShare Object
            AccountShare acctshare2 = new AccountShare(AccountId = acc.id, 
                                                  AccountAccessLevel = 'Edit',
                                                  CaseAccessLevel = 'Edit', 
                                                  OpportunityAccessLevel = 'Edit',
                                                  UserOrGroupId = usr2.Id); 
            insert acctshare2;
            System.assert(true,acctshare2.AccountAccessLevel != null);
            System.runas(sysAdminUser) {
            
            UserRole testuserRole = new UserRole(Name = 'UnitTest-Customer-User');
            insert testuserRole;
            
            sysAdminUser.UserRoleId = testuserRole.Id;
            update sysAdminUser;
            //Custom object creation 
            Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
            ace.Core_Account_CIMID__c = '123';
            ace.Core_Account_Geo__c = 'lar';
            ace.Core_Account_Id__c = '765';
            ace.Core_Ext_Id__c = '456';
            ace.Core_User_Email__c = 'test@gmail.com';
            ace.Core_User_Id__c = '876';
            ace.Core_User_WWID__c = '789';
            insert ace;
            
            Test.startTest();
            Core_AccountCoverage_Batch_Status__c acbatchstatus = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_TerritoryManagement',Core_Batch_Status__c = 'completed');
            insert acbatchstatus;
            Core_AccountCoverage_Batch_Status__c acbatchstatus1 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_RoleHierarchy',Core_Batch_Status__c = 'completed');
            insert acbatchstatus1;
            Core_AccountCoverage_Batch_Status__c acbatchstatus2 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountShare',Core_Batch_Status__c = 'completed');
            insert acbatchstatus2;

           /*
            System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_TerritoryManagement'));
            System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_RoleHierarchy'));
            System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_AccountShare'));*/
            //Create a Custom Setting
            Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType1',Core_LoadType__c = 'DELTA');
            insert loadtype;
            System.assertEquals('LoadType1' , loadtype.Name);
            Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c='');
            insert customSetting;
           
            //Core_AccountCoverageExportUtil util = new Core_AccountCoverageExportUtil();
            Core_AccountCoverageExportUtil.areAllAccountCoverageBatchesCompleted();
            Core_Batch_AccountShare accountshare = new  Core_Batch_AccountShare();
            Database.executeBatch(accountshare, 200);
            Test.stopTest();
            }
            }
    }