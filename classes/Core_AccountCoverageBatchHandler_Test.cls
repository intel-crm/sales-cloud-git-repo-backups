/**************************************************************************************
Apex Class Name:  Core_AccountCoverageBatchHandler_Test
Version     : 1.0 
Created Date: 08 Nov 2016
Description    : This class is Test class for Core_AccountCoverageBatchHandler
*************************************************************************************/
@isTest public class Core_AccountCoverageBatchHandler_Test{
               //Method is used to get all Subordinate Users
                static testMethod void testGetAllSubordinateUsersByUser(){
                Core_AccountCoverageBatchHandler handler = new Core_AccountCoverageBatchHandler();
                Set<Id> setUserId = handler.getAllSubordinateUsersByUser(null);
                Map<String, String> maptostring=new Map<String, String> {'name'=>'test'};
                handler.convertMapToString(maptostring);
                system.assertNotEquals(null, setUserId);
                system.assertNotEquals(1, setUserId.size());
                }
                
                @isTest public static void batchHandlerMethod(){
                Profile prf = [select id, name from Profile where name = 'System Administrator' Limit 1];
                Profile salesRepPrf = [select id, name from Profile where name = 'Sales Rep-BB' Limit 1];
                User adminUser = new User(Alias = 'admin', 
                              Email='adminTest01@intel.com', 
                              EmailEncodingKey='UTF-8',
                              LastName='Testing01',
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              ProfileId = prf.Id, 
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='adminTest01@intel.com');
                insert adminUser;
               
                Id testUsrId = null;
                String usrExecId = null;
                System.RunAs(adminUser){
                //Create the hierarchy of UserRole Record
                UserRole usrCEO = new UserRole(Name = 'Test-CEO');
                insert usrCEO;
                
                UserRole usrExec = new UserRole(Name = 'Test-Executive', ParentRoleId = usrCEO.Id);
                insert usrExec;
                usrExecId = usrExec.Id;
                
                UserRole usrMgr = new UserRole(Name = 'Test-CustomerManager', ParentRoleId = usrExec.Id);
                insert usrMgr;
                
                UserRole usr = new UserRole(Name = 'Test-Customer-User', ParentRoleId = usrMgr.Id);
                insert usr;
                testUsrId = usr.Id;
                
                Map<String, Id> roleNameId = new Map<String, Id>();
                for(UserRole r : [Select Name, Id, ParentRoleId from UserRole Where Name IN ('Test-CEO','Test-Executive','Test-CustomerManager','Test-Customer-User')]){
                roleNameId.put(r.Name, r.Id);
                System.debug(' Role Name '+r.Name+' Role Id : '+r.Id+' Parent Role Id '+r.ParentRoleId);
                }
                //Create a list of user records
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
                insert createUsers;
                
                
                for(User log : [Select Id, Name, UserRoleId, UserRole.Name FRom User 
                        WHERE UserRoleId IN (Select Id from UserRole WHERE Name IN ('Test-CEO','Test-Executive','Test-CustomerManager','Test-Customer-User'))]){
                            System.debug('>>>>>>>>>>>>>>>>>> Logging Users  '+log );
                        }
                
                List<Account> createAccts =  TestUtilities.getListOfAccounts(4);
                insert createAccts;
                
                User testUser = [Select Id from User where UserRoleId =: testUsrId Limit 1 ];
                System.debug(' Seeing the ROld Id ' +[Select Id from UserRole Where Name = 'Test-Customer-User']);
                
                testUsrId = [Select Id, Name from User Where UserRoleId IN (Select Id from UserRole Where Name = 'Test-Customer-User')  Limit 1 ].Id;
                
                for(Account  a : createAccts){
                    a.OwnerId = testUser.Id;
                }
                System.debug(' Creating Accounts  '+createAccts);
                update createAccts;
                System.debug(testUsrId + ' Account '+[Select Id, Owner.Name, OwnerId from Account where OwnerId =: testUsrId ]);
                
                test.starttest();
                User currUser = [SELECT Id, Name, Core_WWID__c, Email, UserRoleId, UserRole.Name,  Profile.Name  FROM User Where UserRoleId  =: usrExecId  Limit 1];
                System.debug(' User '+currUser);
                System.debug(' Account '+[SELECT Id, Owner.Name, Name, Core_CIM_ID__c, Core_Geo__c, Core_Account_Legal_Name__c, Owner.Core_WWID__c, Owner.Email, OwnerId, Owner.UserRoleId  FROM Account LIMIT 10]);
                List<User> batchUserList =  [SELECT Id, Name, Core_WWID__c, Email, UserRoleId, UserRole.Name,  Profile.Name  FROM User  Where UserRoleId IN (Select Id from UserRole Where Name = 'Test-Executive') ]; 
                User batchUser = batchUserList.get(0);
                Core_AccountCoverageBatchHandler batchService = new Core_AccountCoverageBatchHandler ();
                batchService.getAllSubordinateUsersByUserRoleId(batchUser.UserRoleId);
                batchService.getAllSubordinateUsersByUser(batchUser.ID);
                System.debug(' Testing batch with User ' + batchUser);
                test.stoptest();
                }
                }
}