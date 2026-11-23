/**************************************************************************************
Apex Class Name:  Core_Batch_AccountCoverage_Summary_Test
Version     : 1.0 
Created Date: 11 Nov 2016
Description    : This class is Test class for Core_Batch_AccountCoverage_Summary
*************************************************************************************/
@isTest Public Class Core_Batch_AccountCoverage_Summary_Test{       
    @isTest public static void exportDeleteMethod(){
        Test.setMock(HttpCalloutMock.class, new Core_AccountCoverageMockHttpResponse());
        //Create a Custom Setting
        Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType',Core_LoadType__c = 'FULL');
        insert loadtype;
        System.assertEquals(loadtype.Name,'LoadType');
        
        //Creation of Custom Object
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
        insert new Core_ACM_Control_Execution__c(Name='BatchAccountCoverageSummary',IsActive__c = true);
        test.starttest();
        Core_Batch_AccountCoverage_Summary summary = new Core_Batch_AccountCoverage_Summary();
        Database.executeBatch(summary);
        test.stoptest();
    }
    
    
    @isTest public static  void loadTypeDeltaMethod(){
    
        Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name='LoadType',Core_LoadType__c='DELTA');
        insert loadtype;
        System.assertEquals(loadtype.Name,'LoadType');
        
        Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
        ace.Core_Account_CIMID__c = '123';
        ace.Core_Account_Geo__c = 'lar';
        ace.Core_Account_Id__c = '765';
        ace.Core_Ext_Id__c = '876765Test2';
        ace.Core_User_Email__c = 'test@gmail.com';
        ace.Core_Status__c = 'Processed';
        ace.Core_User_Id__c = '876';
        ace.Core_User_WWID__c = '789';
        insert ace;
        System.assert(true, ace.id != null);
        
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
        insert new Core_ACM_Control_Execution__c(Name='BatchAccountCoverageSummary',IsActive__c = true);
        test.starttest();
        Core_Batch_AccountCoverage_Summary summary = new Core_Batch_AccountCoverage_Summary();
        Database.executeBatch(summary);
        test.stoptest();
    }
}