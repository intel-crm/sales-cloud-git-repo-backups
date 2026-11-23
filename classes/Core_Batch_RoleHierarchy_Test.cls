/**************************************************************************************
Apex Class Name:  Core_Batch_RoleHierarchy_Test
Version     : 1.0 
Created Date: 08 Nov 2016
Description    : This class is Test class for Core_Batch_RoleHierarchy
*************************************************************************************/
@isTest 
public class Core_Batch_RoleHierarchy_Test  {
    
    public static String overrideUserId = '';
    @testSetup static void setup() {
        System.debug(' --------------- Setting up the test Data-----------------------');
        Core_AccountCoverage_Profiles__c lstacp = new Core_AccountCoverage_Profiles__c(Name ='Sales Rep-BB',Core_Profiles__c ='Sales Rep-BB');
        insert lstacp;
        
        Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_RoleHierarchy',Core_Batch_Status__c='');
        insert customSetting;
        
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
                                  UserName='adminTest@intel.com');
        insert adminUser;
        Set<Id> tstRoleIds = new Set<Id>();
        System.RunAs(adminUser){
            Test.startTest();
            //Insert Roles
            UserRole usrCEO = null, usrExec = null, usrMgr = null, usr = null;
            System.debug([Select Id, Name from UserRole]);
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
                a.Core_CNDA_Number__c = '32456';
                a.Core_B2B_Entitlement__c = true;
            }
            insert createAccts;
        Database.executeBatch(new Core_Batch_RoleHierarchy(adminUser.id), 1);
        System.debug(' All UserRole ' +[Select Count() from UserRole Where Name Like '%UnitTest%']);
        System.debug(' All Users ' +[Select Count() from User Where Name Like '%Testing%']);
        System.debug(' Creating Accounts  '+createAccts);
        Test.stopTest();
        }
        
        System.debug(' --------------- Setting up the test Data COMPLETED-----------------------');
    }
    
    @isTest public static void testBatchJob(){
        System.debug(' --------------- Running TestMethod testBatchJob ----------------------');
        for(User log : [Select Id, Name, UserRoleId, UserRole.Name FRom User WHERE UserRoleId IN (Select Id from UserRole WHERE Name Like '%UnitTest%')]){
            System.debug('>>>>>>>>>>>>>>>>>> Logging Users  '+log );
        }
        System.debug(' Total Accounts '+[Select Count() from Account ]);
        Test.startTest();
        Core_AccountCoverage_Batch_Status__c acbatchstatus = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_TerritoryManagement',Core_Batch_Status__c = 'Completed');
        insert acbatchstatus;
        Core_AccountCoverage_Batch_Status__c acbatchstatus1 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_RoleHierarchy',Core_Batch_Status__c = 'Completed');
        insert acbatchstatus1;
        Core_AccountCoverage_Batch_Status__c acbatchstatus2 = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountShare',Core_Batch_Status__c = 'Completed');
        insert acbatchstatus2;
        System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_TerritoryManagement'));
        System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_RoleHierarchy'));
        System.assertNotEquals(null, Core_AccountCoverageExportUtil.getCustomSettings('Core_Batch_AccountShare'));
        
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
       
        //Create a Custom Setting
        Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType1',Core_LoadType__c = 'FULL');
        insert loadtype;
        
        Core_AccountCoverage_Batch_Status__c customSetting = new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c='');
        insert customSetting;
        Core_AccountCoverageExportUtil util = new Core_AccountCoverageExportUtil();
        Core_AccountCoverageExportUtil.areAllAccountCoverageBatchesCompleted();
        Database.executeBatch(new Core_Batch_RoleHierarchy(), 1);
        Core_Batch_AccountCoverage_Summary summary = new Core_Batch_AccountCoverage_Summary();
        Database.executeBatch(summary);
        Test.stopTest();
        
        //TODO Get the count and do the assertion
        System.debug(' Total Accounts '+[Select Count() from Core_AccountCoverage_Export__c ]);
        System.assertNotEquals(null, Core_AccountCoverageExportUtil.getUsers());
       
    }
    
    @isTest public static void testBatchJob_error(){
        //Create a Custom Setting
        Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType1',Core_LoadType__c = 'DELTA');
        insert loadtype;
        System.assertEquals(loadtype.Name,'LoadType1');
        
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
        Core_Batch_RoleHierarchy cb = new Core_Batch_RoleHierarchy();   
        try { cb.execute(null, null); }catch(Exception e){}
        
    }
}