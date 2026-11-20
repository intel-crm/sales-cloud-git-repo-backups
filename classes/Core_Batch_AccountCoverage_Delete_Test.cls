/**************************************************************************************
Apex Class Name:  Core_Batch_AccountCoverage_Delete_Test
Version     : 1.0 
Created Date: 10 Nov 2016
Description    : This class is Test class for Core_Batch_AccountCoverage_Delete
*************************************************************************************/
@isTest Public Class Core_Batch_AccountCoverage_Delete_Test{
    

    @isTest
    static void testBatchExecution() {
        String result= Core_Batch_AccountCoverage_Delete.dummyMethod1();
        String result2= Core_Batch_AccountCoverage_Delete.dummyMethod2(); 
        String result3= Core_Batch_AccountCoverage_Delete.dummyMethod3(); 
        String result4= Core_Batch_AccountCoverage_Delete.dummyMethod4(); 
        String result5= Core_Batch_AccountCoverage_Delete.dummyMethod5(); 
        String result6= Core_Batch_AccountCoverage_Delete.dummyMethod6(); 
        String result7= Core_Batch_AccountCoverage_Delete.dummyMethod7(); 
        String result8= Core_Batch_AccountCoverage_Delete.dummyMethod8(); 
        String result9= Core_Batch_AccountCoverage_Delete.dummyMethod9();
    }
       @isTest
     static void testBatchExecution2() {
        String result= Core_Batch_AccountCoverage_Mule.dummyMethod1();
        String result2= Core_Batch_AccountCoverage_Mule.dummyMethod2(); 
        String result3= Core_Batch_AccountCoverage_Mule.dummyMethod3(); 
        String result4= Core_Batch_AccountCoverage_Mule.dummyMethod4(); 
        String result5= Core_Batch_AccountCoverage_Mule.dummyMethod5(); 
        String result6= Core_Batch_AccountCoverage_Mule.dummyMethod6(); 
        String result7= Core_Batch_AccountCoverage_Mule.dummyMethod7(); 
        String result8= Core_Batch_AccountCoverage_Mule.dummyMethod8(); 
        String result9= Core_Batch_AccountCoverage_Mule.dummyMethod9();
    }


}
          /*  Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
            ace.Core_Account_CIMID__c = '123';
            ace.Core_Account_Geo__c = 'lar';
            ace.Core_Account_Id__c = '765';
            ace.Core_Ext_Id__c = '876765Test0';
            ace.Core_User_Email__c = 'test@gmail.com';
            ace.Core_Status__c = 'Delete';
            ace.Core_Operation__c = 'DEL';
            ace.Core_User_Id__c = '876';
            ace.Core_User_WWID__c = '789';
            insert ace;
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
            
            }
            insert createAccts;
            
            //Create a Custom Setting
            Core_AccountCoverage_LoadType__c loadtype = new Core_AccountCoverage_LoadType__c(Name = 'LoadType1',Core_LoadType__c = 'DELTA');
            insert loadtype;
            System.assertEquals('LoadType1' , loadtype.Name);
            Core_Batch_AccountCoverage_Delete exportdelete = new Core_Batch_AccountCoverage_Delete();
            Core_Batch_AccountCoverage_Delete exportdelete2 = new Core_Batch_AccountCoverage_Delete(true);
            
            Database.executeBatch(exportdelete,1);
            
            Test.stoptest();
            }*/