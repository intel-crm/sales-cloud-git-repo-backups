/**************************************************************************************
Apex Class Name:  Core_AccountCoverageExportUtil_Test
Version     : 1.0 
Created Date: 08 Nov 2016
Description    : This class is Test class for Core_AccountCoverageExportUtil
*************************************************************************************/
@isTest public Class Core_AccountCoverageExportUtil_Test {
            
      @isTest Public static void testExportUtilMethod(){
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-BB'];
            User usr = new User(Alias = 'std455',
                                Email = 'mohanx.mallampati@intel.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'Testing', 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US',
                                ProfileId = p.Id,
                                TimeZoneSidKey = 'America/Los_Angeles',
                                UserName = 'standard123@testorg.com');
                                
            test.starttest();
            Core_AccountCoverageExportUtil util = new Core_AccountCoverageExportUtil();
            Core_AccountCoverageExportUtil.getUsers();
            Core_AccountCoverageExportUtil.setCustomSettings('All','Completed');
            Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_RoleHierarchy');
            
            List<String> toEmail=new List<String>();
            toEmail.add('test@intel.com');
            Core_AccountCoverageExportUtil.sendEmail(usr.id,toEmail,'login problem','test');
            test.stoptest();
            
            }
            
        @isTest Public static void testCustomSettingMethod(){
            
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-BB'];
            User usr = new User(Alias = 'std455',
                                Email = 'mohanx.mallampati@intel.com',
                                EmailEncodingKey = 'UTF-8',
                                LastName = 'Testing', 
                                LanguageLocaleKey = 'en_US', 
                                LocaleSidKey = 'en_US',
                                ProfileId = p.Id,
                                TimeZoneSidKey = 'America/Los_Angeles',
                                UserName = 'standard123@testorg.com');
            insert usr;
            System.assert(true,usr.Email!=null);
            
            Core_AccountCoverage_Batch_Status__c acbatchstatus = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_TerritoryManagement',Core_Batch_Status__c = 'Completed');
            insert acbatchstatus;
            Core_AccountCoverage_Batch_Status__c acbatchstatus1 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_RoleHierarchy',Core_Batch_Status__c = 'Completed');
            insert acbatchstatus1;
            System.assertEquals('Core_Batch_TerritoryManagement',acbatchstatus.Name);
            
            Core_AccountCoverage_Batch_Status__c acbatchstatus2 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountShare',Core_Batch_Status__c = 'Completed');
            insert acbatchstatus2;
            
            //Create a sample Account Coverage Exports Record
            Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
            ace.Core_Account_CIMID__c = '123';
            ace.Core_Account_Geo__c = 'lar';
            ace.Core_Account_Id__c = '765';
            ace.Core_Ext_Id__c = '765876';
            ace.Core_User_Email__c = 'test@gmail.com';
            ace.Core_Operation__c = 'Processed';
            ace.Core_Status__c = 'Processed';
            ace.Core_User_Id__c = '876';
            ace.Core_User_WWID__c = '789';
            insert ace;
            System.assert(true,ace.id!=null);
            
            //Create a sample 'Account' record
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
            acc.BillingStreet = '13254 E vookbrrok dfdsf';
            insert acc;
            System.assertEquals(acc.Name,'test');
            
            Test.setMock(HttpCalloutMock.class, new Core_AccountCoverageMockHttpResponse());
            
            Test.starttest();
            //Create a record of Core_AccountCoverage_Batch_Status Custom Setting
            Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c='Completed');
            insert customSetting;
            
            //Create a record of Core_AccountCoverage_Mule_Service Custom Setting
            Core_AccountCoverage_Exclude_Roles__c excluderoles = new Core_AccountCoverage_Exclude_Roles__c(Name = 'Admin');
            insert excluderoles;
            
            //Create a Record of Core_AccountCoverage_LoadType Custom Setting
            Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType',Core_LoadType__c = 'FULL');
            insert loadtype;
            
            Core_AccountCoverageExportUtil util = new Core_AccountCoverageExportUtil();
            Core_AccountCoverageExportUtil.setCustomSettings('Core_Batch_TerritoryManagement','Completed');
            Core_AccountCoverageExportUtil.areAllAccountCoverageBatchesCompleted();
            Core_AccountCoverageExportUtil.populateAccountCoverage(ace,acc,usr);
            Core_AccountCoverageExportUtil.getNonAdminUsers();
            
            //For sending notification we are using AccountCoverage Summary Batch
            Core_Batch_AccountCoverage_Summary summary = new Core_Batch_AccountCoverage_Summary();
            Database.executeBatch(summary);
            
            test.stoptest();
            
            }
        @isTest public static void exportDeleteMethod(){
            
            Test.setMock(HttpCalloutMock.class, new Core_AccountCoverageMockHttpResponse_Failed());
            //Create a Custom Setting
            Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType',Core_LoadType__c = 'FULL');
            insert loadtype;
            System.assertEquals(loadtype.Name,'LoadType');
            
            //Create a sample  Account Coverage Exports record with status as Processed
            Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
            ace.Core_Account_CIMID__c = '123';
            ace.Core_Account_Geo__c = 'lar';
            ace.Core_Account_Id__c = '765';
            ace.Core_Ext_Id__c = '876765Test0';
            ace.Core_User_Email__c = 'test@gmail.com';
            ace.Core_Status__c = 'Processed';
            ace.Core_User_Id__c = '876';
            ace.Core_User_WWID__c = '789';
            insert ace;
            System.assert(true, ace.id != null);
            
            //Create a sample  Account Coverage Exports record with status as New
            Core_AccountCoverage_Export__c ace1 = new Core_AccountCoverage_Export__c();
            ace1.Core_Account_CIMID__c = '123';
            ace1.Core_Account_Geo__c = 'lar';
            ace1.Core_Account_Id__c = '765';
            ace1.Core_Ext_Id__c = '876765Test1';
            ace1.Core_User_Email__c = 'test@gmail.com';
            ace1.Core_Status__c = 'New';
            ace1.Core_User_Id__c = '876';
            ace1.Core_User_WWID__c = '789';
            insert ace1;
            System.assert(true,ace1.id!=null);
            
            Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c='');
            insert customSetting;
             //Create a System Credentials record 
            Core_System_Credentials__c credentials = new Core_System_Credentials__c(Name='Core AC Mule Service',Core_End_Point_URL__c='https://eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-account-coverage/ACSTART',Core_Password__c='WJ$K1ZmrZug7',Core_UserName__c='proxydefault');
            insert credentials ;
            
            test.starttest();
            Core_Batch_AccountCoverage_Summary summary = new Core_Batch_AccountCoverage_Summary();
            Database.executeBatch(summary);
            test.stoptest();
            }
            @isTest public static void exportDeleteMethodDup(){
            
            Test.setMock(HttpCalloutMock.class, new Core_AccountCoverageMockHttpResponse());
            
            //Create a Custom Setting of Core_AccountCoverage_LoadType
            Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType',Core_LoadType__c = 'FULL');
            insert loadtype;
            System.assertEquals(loadtype.Name,'LoadType');
            
            //Create a sample  Account Coverage Exports record with status as Processed
            Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
            ace.Core_Account_CIMID__c = '123';
            ace.Core_Account_Geo__c = 'lar';
            ace.Core_Account_Id__c = '765';
            ace.Core_Ext_Id__c = '876765Test0';
            ace.Core_User_Email__c = 'test@gmail.com';
            ace.Core_Status__c = 'Processed';
            ace.Core_User_Id__c = '876';
            ace.Core_User_WWID__c = '789';
            insert ace;
            System.assert(true, ace.id != null);
            
            //Create a sample  Account Coverage Exports record with status as New
            Core_AccountCoverage_Export__c ace1 = new Core_AccountCoverage_Export__c();
            ace1.Core_Account_CIMID__c = '123';
            ace1.Core_Account_Geo__c = 'lar';
            ace1.Core_Account_Id__c = '765';
            ace1.Core_Ext_Id__c = '876765Test1';
            ace1.Core_User_Email__c = 'test@gmail.com';
            ace1.Core_Status__c = 'New';
            ace1.Core_User_Id__c = '876';
            ace1.Core_User_WWID__c = '789';
            insert ace1;
            System.assert(true,ace1.id!=null);
            
            Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c='Completed');
            insert customSetting;
           
            Core_System_Credentials__c credentials = new Core_System_Credentials__c(Name='Core AC Mule Service',Core_End_Point_URL__c='https://eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-account-coverage/ACSTART',Core_Password__c='WJ$K1ZmrZug7',Core_UserName__c='proxydefault');
            insert credentials ;
            
            test.starttest();
            Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_RoleHierarchy');
            Core_Batch_AccountCoverage_Summary summary = new Core_Batch_AccountCoverage_Summary();
            Database.executeBatch(summary);
            test.stoptest();
            System.assertNotEquals('', Core_AccountCoverageExportUtil.trim(null, 10));
            }
            
            public class Core_AccountCoverageMockHttpResponse_Failed implements HttpCalloutMock{
            public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response for fail condition
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('-1,called service');
            return res;
            }
            }
}