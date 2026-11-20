/***************************************************************************************************
Class Name:  Core_IPS_CustomAccountTeam_Handler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 21 Jan 2016
Function    : This class contains test coverage for Core_IPS_CustomAccountTeam_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_CustomAccountTeam_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya              01/21/2016              Created
****************************************************************************************************/   
@isTest
public class Core_IPS_CustomAccountTeam_Handler_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static UserRole portalRole = new UserRole();
    /***************************************************************************************************
    Method Name:  getRecords()
    Method Type: void
    Version     : 1.0 
    Created Date: 05 Nov 2015
    Description:  Common Test data used for all test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Syed Moosa Nazir TN       11/05/2015              Created
    ****************************************************************************************************/
    static void getRecords (){
    
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        // Custom Setting - Ips Lables
        
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser[0]){
            insert ListofIpsLables;
            insert ListofIpsErrorCodes;
        }
        //portalRole =TestUtilities.getCustomerUserRole();
        System.Assert(ListofIpsLables[0].Id != null, 'Records not created');
        //Custom Setting - Ips Error Codes
        
        
        System.Assert(ListofIpsErrorCodes[0].Id != null, 'Records not created');
    }



    /***************************************************************************************************
    Method Name:  manageSharingForEdit_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Brian Matthews              04/29/2016             Created - Duplicated code procedurized
    ****************************************************************************************************/
    static void createTriggerExecutionCustomSettings() {        
        //Create Custom Settings
        List<Core_Trigger_Executions__c> triggerExecutionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name                   = 'ManageCustomAccountTeam';
        triggerExecution.Core_Active__c         = true;
        triggerExecution.Core_Class_Name__c     = 'Core_IPS_CustomAccountTeam_Handler';
        triggerExecution.Core_Description__c    = 'MethodDescription';
        triggerExecution.Core_Object__c         = 'Core_Account_Team__c';
        triggerExecution.Core_Trigger_Events__c = 'after insert, after update, after delete';
        triggerExecutionList.add(TriggerExecution);
        
        triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name                   = 'GrantCustomAccountTeam';
        triggerExecution.Core_Active__c         = true;
        triggerExecution.Core_Class_Name__c     ='Core_IPS_CustomAccountTeam_Handler';
        triggerExecution.Core_Description__c    = 'MethodDescription';
        triggerExecution.Core_Object__c         = 'Core_Account_Team__c';
        triggerExecution.Core_Trigger_Events__c = 'after insert, after update, after delete';
        triggerExecutionList.add(TriggerExecution);
        
        triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.Name                   = 'RevokeCustomAccountTeam';
        triggerExecution.Core_Active__c         = true;
        triggerExecution.Core_Class_Name__c     = 'Core_IPS_CustomAccountTeam_Handler';
        triggerExecution.Core_Description__c    = 'MethodDescription';
        triggerExecution.Core_Object__c         = 'Core_Account_Team__c';
        triggerExecution.Core_Trigger_Events__c = 'after insert, after update, after delete';
        triggerExecutionList.add(TriggerExecution);

        triggerExecution = new Core_Trigger_Executions__c();
        triggerExecution.name                   = 'deleteStandardAccountTeam';
        triggerExecution.Core_Object__c         = 'Core_Account_Team__c';
        triggerExecution.Core_Class_Name__c     = 'Core_IPS_CustomAccountTeam_Handler';
        TriggerExecution.Core_Description__c    = 'MethodDescription';
        triggerExecution.Core_Trigger_Events__c = 'after delete';
        triggerExecution.Core_Active__c         = true;        
        triggerExecutionList.add(triggerExecution);        

        System.runAs(ListOfUser.get(0)){
            insert TriggerExecutionList;
        } 
        System.assert(TriggerExecutionList[0].id!= null, 'Record not created');
    }



    /***************************************************************************************************
    Method Name:  manageSharingForEdit_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForEdit_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
         for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Account Based Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }                
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }     
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }        
           
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }

        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getEditableCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForRead_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForRead_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getReadCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
        ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
        insert ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    

    /***************************************************************************************************
    Method Name:  manageSharingForPrivate_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForPrivate_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getPrivateCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForMassEdit_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForMassEdit_PositiveTest(){
        getRecords();
        Integer sizeCheck = 2;
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        acctIdList.add(listofaccounts[1].id);
        System.assertEquals(ListOfAccounts.size(), sizeCheck);
        //Create Account Based Asset
        List<Asset> astList = TestUtilities.getAssetList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                astList[i].AccountId = ListOfAccounts[i].Id;
            }
            insert astList;
        }                
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(2);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(2);
        System.runAs(listofuser[0]){
            for(Integer i=0;i<2;i++){
                ListOfIPSAccount[i].Core_Account__c = ListOfAccounts[i].Id;
                ListOfIPSAccount[i].Core_IPS_Project__c = ListOfprojects[i].Id;
            }
            insert ListOfIPSAccount;
        }     
        //Create Project Based Asset
        List<Asset> ast1 = TestUtilities.getAssetList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                ast1[i].Core_IPS_Project__c = ListOfprojects[i].Id;
            }
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        List<Core_IPS_MAP_PAR__c> par = TestUtilities.getMapParList(2);
        System.runAs(listofuser[0]){
            for(Core_IPS_MAP_PAR__c parObj:par){
                parObj.RecordTypeId = MapRecordtype.get('PAR');
            }
            insert par;
        }
        //Create Core_IPS_MAP_Account__c
        List<Core_IPS_MAP_Account__c> ipsmapAcc = TestUtilities.getIPSMAPAccountList(2);
        System.runAs(listofuser[0]){
            for(Integer i=0;i<2;i++){
                ipsmapAcc[i].Core_MAP_PAR__c = par[i].Id;
                ipsmapAcc[i].Core_Account__c = ListOfAccounts[i].Id;
            }
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getEditableCustomAccountTeamList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                ListOfAccountTeam[i].Core_Account__c = ListOfAccounts[i].Id;
            }
            insert ListOfAccountTeam;
        }
        System.assertEquals(ListOfAccountTeam.size(),sizeCheck);        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForMassRead_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForMassRead_PositiveTest(){
        getRecords();
        Integer sizeCheck = 2;
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(listofuser[0]){
         for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        acctIdList.add(listofaccounts[1].id);
        System.assertEquals(ListOfAccounts.size(), sizeCheck);
        //Create Account Based Asset
        List<Asset> astList = TestUtilities.getAssetList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                astList[i].AccountId = ListOfAccounts[i].Id;
            }
            insert astList;
        }                
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(2);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(2);
        System.runAs(listofuser[0]){
            for(Integer i=0;i<2;i++){
                ListOfIPSAccount[i].Core_Account__c = ListOfAccounts[i].Id;
                ListOfIPSAccount[i].Core_IPS_Project__c = ListOfprojects[i].Id;
            }
            insert ListOfIPSAccount;
        }     
        //Create Project Based Asset
        List<Asset> ast1 = TestUtilities.getAssetList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                ast1[i].Core_IPS_Project__c = ListOfprojects[i].Id;
            }
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        List<Core_IPS_MAP_PAR__c> par = TestUtilities.getMapParList(2);
        System.runAs(listofuser[0]){
            for(Core_IPS_MAP_PAR__c parObj:par){
                parObj.RecordTypeId = MapRecordtype.get('PAR');
            }
            insert par;
        }
           
        //Create Core_IPS_MAP_Account__c
        List<Core_IPS_MAP_Account__c> ipsmapAcc = TestUtilities.getIPSMAPAccountList(2);
        System.runAs(listofuser[0]){
            for(Integer i=0;i<2;i++){
                ipsmapAcc[i].Core_MAP_PAR__c = par[i].Id;
                ipsmapAcc[i].Core_Account__c = ListOfAccounts[i].Id;
            }
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getReadCustomAccountTeamList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                ListOfAccountTeam[i].Core_Account__c = ListOfAccounts[i].Id;
            }
            insert ListOfAccountTeam;
        }
        System.assertEquals(ListOfAccountTeam.size(),sizeCheck);        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForMassPrivate_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForMassPrivate_PositiveTest(){
        getRecords();
        Integer sizeCheck = 2;
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(2);
        System.runAs(listofuser[0]){
         for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        acctIdList.add(listofaccounts[1].id);
        System.assertEquals(ListOfAccounts.size(), sizeCheck);
        //Create Account Based Asset
        List<Asset> astList = TestUtilities.getAssetList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                astList[i].AccountId = ListOfAccounts[i].Id;
            }
            insert astList;
        }                
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(2);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(2);
        System.runAs(listofuser[0]){
            for(Integer i=0;i<2;i++){
                ListOfIPSAccount[i].Core_Account__c = ListOfAccounts[i].Id;
                ListOfIPSAccount[i].Core_IPS_Project__c = ListOfprojects[i].Id;
            }
            insert ListOfIPSAccount;
        }     
        //Create Project Based Asset
        List<Asset> ast1 = TestUtilities.getAssetList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                ast1[i].Core_IPS_Project__c = ListOfprojects[i].Id;
            }
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        List<Core_IPS_MAP_PAR__c> par = TestUtilities.getMapParList(2);
        System.runAs(listofuser[0]){
            for(Core_IPS_MAP_PAR__c parObj:par){
                parObj.RecordTypeId = MapRecordtype.get('PAR');
            }
            insert par;
        }
        //Create Core_IPS_MAP_Account__c
        List<Core_IPS_MAP_Account__c> ipsmapAcc = TestUtilities.getIPSMAPAccountList(2);
        System.runAs(listofuser[0]){
            for(Integer i=0;i<2;i++){
                ipsmapAcc[i].Core_MAP_PAR__c = par[i].Id;
                ipsmapAcc[i].Core_Account__c = ListOfAccounts[i].Id;
            }
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getPrivateCustomAccountTeamList(2);
        system.runAs(ListofUser[0]){
            for(Integer i=0;i<2;i++){
                ListOfAccountTeam[i].Core_Account__c = ListOfAccounts[i].Id;
            }
            insert ListOfAccountTeam;
        }
        System.assertEquals(ListOfAccountTeam.size(),sizeCheck);        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForEditUpdate_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForEditUpdate_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Account Based Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }                
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }     
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }   
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getEditableCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;
            ListOfAccountTeam[0].Core_Case_Access__c = 'Read';
            update ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForReadUpdate_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForReadUpdate_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }   
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getReadCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;            
            ListOfAccountTeam[0].Core_Case_Access__c = 'None';
            update ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForPrivateUpdate_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForPrivateUpdate_PositiveTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }   
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team        
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getPrivateCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;           
            ListOfAccountTeam[0].Core_Case_Access__c = 'Edit';
            update ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForEditDelete_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForEditDelete_NegativeTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Account Based Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }                
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }     
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }   
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getEditableCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;
            delete ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForReadDelete_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForReadDelete_NegativeTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }   
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getReadCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;
            delete ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
    
    /***************************************************************************************************
    Method Name:  manageSharingForPrivateDelete_NegativeTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Jan 2016
    Description:  
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya             01/21/2016                Created
    ****************************************************************************************************/
    static testmethod void manageSharingForPrivateDelete_NegativeTest(){
        getRecords();
        // Create Accounts
        List<Account>  ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(listofuser[0]){
        for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
        insert ListOfAccounts;
        }
        List<id> acctIdlist = new List<Id>();
        acctIdList.add(listofaccounts[0].id);
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        //Create Asset
        Asset ast = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast.AccountId = ListOfAccounts[0].Id;
            insert ast;
        }
        //Create Project
        List<Core_IPS_Project__c>  ListOfprojects = TestUtilities.getListOfIpsProjects(1);
        System.runAs(listofuser[0]){
            insert ListOfprojects;
        }
        //Create IPS Account
        List<Core_IPS_Account__c>  ListOfIPSAccount = TestUtilities.getListOfIpsAccounts(1);
        System.runAs(listofuser[0]){
            ListOfIPSAccount[0].Core_Account__c = ListOfAccounts[0].Id;
            ListOfIPSAccount[0].Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ListOfIPSAccount;
        }
        //Create Project Based Asset
        Asset ast1 = TestUtilities.getAsset();
        system.runAs(ListofUser[0]){
            ast1.Core_IPS_Project__c = ListOfprojects[0].Id;
            insert ast1;
        }
        Map<string,ID> MapRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
        {  
              MapRecordtype.put(Rt.Name,Rt.ID);
        }        
        //Create PAR
        Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
        System.runAs(listofuser[0]){
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
        }
        //Create Core_IPS_MAP_Account__c
        Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
        System.runAs(listofuser[0]){
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            insert ipsmapAcc;
        }
        
        createTriggerExecutionCustomSettings();        
        
        // Create Account Team
        List<Core_Account_Team__c> ListOfAccountTeam = TestUtilities.getPrivateCustomAccountTeamList(1);
        system.runAs(ListofUser[0]){
            ListOfAccountTeam[0].Core_Account__c = ListOfAccounts[0].Id;
            insert ListOfAccountTeam;
            delete ListOfAccountTeam;
        }
        System.assert(ListOfAccountTeam[0].Id != null, 'Record not created');        
    }
}