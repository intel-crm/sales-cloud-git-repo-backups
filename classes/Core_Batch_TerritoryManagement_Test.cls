/**************************************************************************************
Apex Class Name:  Core_Batch_TerritoryManagement_Test
Version     : 1.0 
Created Date: 08 Nov 2016
Description    : This class is Test class for Core_Batch_TerritoryManagement
*************************************************************************************/
@isTest
public class Core_Batch_TerritoryManagement_Test{
static testMethod void testTerritoryManage(){
            Integer count = 0 ;
            //Creation of custom setting
            Core_AccountCoverage_Profiles__c coverageprofiles = new Core_AccountCoverage_Profiles__c(Name = 'Sales Rep-BB',Core_Profiles__c = 'Sales Rep-BB');
            insert coverageprofiles;
            //Create User with IsActive flag = true
           Core_ACM_Control_Execution__c executeTrigger = new Core_ACM_Control_Execution__c();
        executeTrigger.Name = 'AccountCoverageBatchHandler';
        executeTrigger.IsActive__c = TRUE;
        executeTrigger.ProcessName__c = 'AccountCoverageBatchHandler';
        insert executeTrigger;
        System.assert(executeTrigger.id != null, 'triggerExecution inserted'); 
         Core_ACM_Control_Execution__c executeTrigger1 = new Core_ACM_Control_Execution__c();
        executeTrigger1.Name = 'AccountCoverageExportUtil';
        executeTrigger1.IsActive__c = TRUE;
        executeTrigger1.ProcessName__c = 'AccountCoverageExportUtil';
        insert executeTrigger1;
        System.assert(executeTrigger1.id != null, 'triggerExecution inserted');  
            Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
            Profile salesRepPrf = [select id, name from Profile where name = 'Sales Rep-BB' Limit 1];
            User adminUser = new User(Alias = 'admin', 
                                  Email='adminTest@intel.com', 
                                  EmailEncodingKey='UTF-8',
                                  LastName='UnitTestAdmin',
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = prf.Id, 
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName='adminTest123@intel.com');
            insert adminUser;
            
            Set<Id> tstRoleIds = new Set<Id>();
            System.RunAs(adminUser){
            Test.startTest();
            //Insert Roles
            UserRole usrCEO = null, usrExec = null, usrMgr = null, usr = null;
            //System.debug([Select Id, Name from UserRole]);
            usrCEO = new UserRole(Name = 'UnitTest-CEO');
            insert usrCEO;     
            tstRoleIds.add(usrCEO.Id);
            
            usrExec = new UserRole(Name = 'UnitTest-Executive', ParentRoleId = usrCEO.Id);
            insert usrExec;    
            tstRoleIds.add(usrExec.Id);
            
            
            usrMgr = new UserRole(Name = 'UnitTest-CustomerManager', ParentRoleId = usrExec.Id);
            insert usrMgr;
            tstRoleIds.add(usrMgr.Id);
            
            usr = new UserRole(Name = 'UnitTest-Customer-User', ParentRoleId = usrMgr.Id);
            insert usr;
            tstRoleIds.add(usr.Id);
            
            
            //Create Users 
            List<User> createUsers =  TestUtilities.getListOfUser(4);
            
            System.debug(' >> Creating Users  '+createUsers.size());
            User u = createUsers.get(0);
            u.UserRoleId = usrCEO.Id;
            u.ProfileId = salesRepPrf.Id;
            
            u = createUsers.get(1);
            u.UserRoleId = usrExec.Id;
            u.ProfileId = salesRepPrf.Id;
            
            u = createUsers.get(2);
            u.UserRoleId = usrMgr.Id;
            u.ProfileId = salesRepPrf.Id;
            
            for(Integer i = 3; i<createUsers.size();i++){
                u = createUsers.get(i);
                u.UserRoleId = usr.Id;
                u.ProfileId = salesRepPrf.Id;
            }
            System.debug(' >> Inserting Users  '+createUsers.size());
            insert createUsers;
            System.debug('===createUsers====>'+createUsers);
            
            List<Account> createAccts =  TestUtilities.getListOfAccounts(10);
            Map<String, Id> mapUsers = new Map<String, Id>();
            for(User us : [Select Id, UserRoleId, UserRole.Name, Profile.Name From User where UserRoleId IN : tstRoleIds]){
                System.debug(' us '+us);
                mapUsers.put(us.UserRole.Name, us.Id);
            }
            System.debug(' mapUsers   '+mapUsers);
            
            for(Integer i=0; i< createAccts.size();i++){
                Account a = createAccts.get(i);
                if(i < 4){
                    a.OwnerId = mapUsers.get('UnitTest-Customer-User');
                }else if(i < 6){
                    a.OwnerId = mapUsers.get('UnitTest-CustomerManager');
                }else if(i < 8){
                    a.OwnerId = mapUsers.get('UnitTest-Executive');
                }else{
                    a.OwnerId = mapUsers.get('UnitTest-CEO');
                }
                
            }
            insert createAccts;
            //Create a new Account
            Account acc = new Account();
            acc.Name = 'test';
            acc.Core_Account_Type__c = 'Distributor';
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
            
            //Create a Territorymodel
            list<Territory2Type> terriType   = [SELECT id,
                                            DeveloperName 
                                            from Territory2Type 
                                            where  DeveloperName = 'Business_Unit'];
            /*List<Territory2Model> terrModel   = [SELECT id,
                                             DeveloperName
                                             from Territory2Model where state = 'Active' limit 1];*/
            Territory2Model terrModel = new Territory2Model();
            terrModel .DeveloperName='ModelName'; // required field
            terrModel.Name = 'Name';
            insert terrModel ;        
            System.debug('==terriType=='+terriType);
            System.debug('==terrModel=='+terrModel);
            
            //Create Territory with AccountAccessLevel = Edit
            Territory2 objTerr = new Territory2();
            objTerr.AccountAccessLevel = 'Edit';
            objTerr.DeveloperName = 'territorymanager';
            objTerr.Name = 'APJ E-Touch ANZ';
            objTerr.Territory2ModelId = terrModel.id;
            objTerr.Territory2TypeId = terriType[0].id;
            insert objTerr;
            System.debug('==objTerr=='+objTerr.id);
            
            Set<ID> userIds=new Set<ID>();
            System.debug('==createUsers[0].id==>'+createUsers[0].id);
            //Creation of UserTerritory2Association Object
            List<UserTerritory2Association> lstuserassociation = new List<UserTerritory2Association>();
            UserTerritory2Association userassociation = new UserTerritory2Association();
            userassociation.Territory2Id = objTerr.id;
            userassociation.UserId = createUsers[3].id;
            insert userassociation;
            System.debug('===userassociation===>'+userassociation);
            lstuserassociation.add(userassociation);
            
            ObjectTerritory2Association ObjectAssociation = new ObjectTerritory2Association();
            ObjectAssociation.Territory2Id = userassociation.Territory2Id;
            ObjectAssociation.AssociationCause = 'Territory2Manual';
            ObjectAssociation.ObjectId = acc.id;
            insert ObjectAssociation;
            System.debug('==ObjectAssociation=='+ObjectAssociation.id);
            
            //Custom object creation
            List<Core_AccountCoverage_Export__c> lstace = new List<Core_AccountCoverage_Export__c>();
            Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
            ace.Core_Account_CIMID__c = '123';
            ace.Core_Account_Geo__c = 'lar';
            ace.Core_Account_Id__c = acc.id;
            ace.Core_Ext_Id__c = '456';
            ace.Core_User_Email__c = 'test@gmail.com';
            ace.Core_User_Id__c = usr.id;
            ace.Core_User_WWID__c = '789';
            insert ace;
            lstace.add(ace);
            
            Core_AccountCoverage_Batch_Status__c acbatchstatus = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_TerritoryManagement',Core_Batch_Status__c = 'Completed');
            insert acbatchstatus;
            
            Core_AccountCoverage_Batch_Status__c acbatchstatus1 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_RoleHierarchy',Core_Batch_Status__c = 'Completed');
            insert acbatchstatus1;
            
            Core_AccountCoverage_Batch_Status__c acbatchstatus2 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountShare',Core_Batch_Status__c = 'Completed');
            insert acbatchstatus2;
            
            System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_TerritoryManagement'));
            System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_RoleHierarchy'));
            System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_AccountShare'));
          
            //Create a Custom Setting
            Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType1',Core_LoadType__c = 'DELTA');
            insert loadtype;
                
            System.assertEquals('LoadType1' , loadtype.Name);
            Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c='');
    
            //Core_AccountCoverage_Mule_Service__c customSetting2 = new Core_AccountCoverage_Mule_Service__c();
            //customSetting2.Core_Url__c = 'https://proxydefault:WJ$K1ZmrZug7@eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-account-coverage/run';
            //customSetting2.Name='URL';
            
            Core_System_Credentials__c sObjRecSystemCred = new Core_System_Credentials__c();
            sObjRecSystemCred.Name = 'Core AC Mule Service';
            sObjRecSystemCred.Core_End_Point_URL__c = 'https://proxydefault:WJ$K1ZmrZug7@eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-account-coverage/run';
            sObjRecSystemCred.Core_UserName__c = 'proxydefault'; 
            sObjRecSystemCred.Core_Password__c = 'test'; 
                
                
            insert customSetting;
            //insert customSetting2;
            insert sObjRecSystemCred;    
         
            
            
                
            Core_AccountCoverageExportUtil util = new Core_AccountCoverageExportUtil();
            Core_AccountCoverageExportUtil.areAllAccountCoverageBatchesCompleted();
            Core_Batch_TerritoryManagement territorybatch = new  Core_Batch_TerritoryManagement();
            Database.executeBatch(territorybatch,200);
            Core_Batch_TerritoryManagement territorybatch1 = new  Core_Batch_TerritoryManagement(usr.id);
            Test.stopTest();
        
       
    }
    }
        
      static testMethod  void testBatchJob_error(){
        Core_Batch_TerritoryManagement tm = new Core_Batch_TerritoryManagement();   
        try { tm .execute(null, null); }catch(Exception e){}
        
    }
    }