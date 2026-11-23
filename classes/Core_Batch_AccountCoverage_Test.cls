@isTest public class Core_Batch_AccountCoverage_Test {
    
    @testSetup static void setup() {
        System.debug(' --------------- Core_Batch_AccountCoverage_Test Setting up the test Data-----------------------');
        // 1. Setup The Data for Role Hierarchy
        Core_AccountCoverage_Profiles__c lstacp = new Core_AccountCoverage_Profiles__c(Name ='Sales Rep-BB',Core_Profiles__c ='Sales Rep-BB');
        insert lstacp;
        
        List<sObject> cslist = new  List<sObject>();
        
        cslist.add(new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_RoleHierarchy',Core_Batch_Status__c=''));
        cslist.add(new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountShare',Core_Batch_Status__c=''));
        cslist.add(new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_TerritoryManagement',Core_Batch_Status__c=''));
        cslist.add(new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_MuleService',Core_Batch_Status__c=''));
        cslist.add(new Core_AccountCoverage_Batch_Status__c(Name = 'Core_Batch_AccountCoverage_Summary',Core_Batch_Status__c=''));
        
        cslist.add(new Core_AccountCoverage_LoadType__c (Name = 'LoadType',Core_LoadType__c ='DELTA'));
        //cslist.add(new Core_AccountCoverage_Mule_Service__c (Name = 'MuleServiceUrl',Core_Url__c='https://proxydefault:WJ$K1ZmrZug7@eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-account-coverage/run'));
        Core_System_Credentials__c sObjRecSystemCred = new Core_System_Credentials__c();
        sObjRecSystemCred.Name = 'Core AC Mule Service';
        sObjRecSystemCred.Core_End_Point_URL__c = 'https://proxydefault:WJ$K1ZmrZug7@eip-crm-proxy-dev.cloudhub.io/smit/api/eip-crm-sls-account-coverage/run';
        sObjRecSystemCred.Core_UserName__c = 'proxydefault'; 
        sObjRecSystemCred.Core_Password__c = 'test'; 
        insert sObjRecSystemCred;
        
        insert cslist;
        
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
            System.debug(' All UserRole ' +[Select Count() from UserRole Where Name Like '%UnitTest%']);
            System.debug(' All Users ' +[Select Count() from User Where Name Like '%Testing%']);
            System.debug(' Creating Accounts  '+createAccts);
            Test.stopTest();
        }
        
        // 2. Setup The Data for AccountShare
        
        
        
        // 3. Setup the Date for Territory Management
        //Pending
        
        
        
        System.debug(' --------------- Setting up the test Data COMPLETED-----------------------');
    }
    
    
    // This is just a Logging of records    
    public static String getAllSettings(){
        String str = '\n All Custom Settings  \n [ Core_AccountCoverage_Batch_Status__c. Name . Status ';
        for(Core_AccountCoverage_Batch_Status__c cb : [select Name, Core_Batch_Status__c  from Core_AccountCoverage_Batch_Status__c]){
            str = str +' \n '+cb.Name +' '+cb.Core_Batch_Status__c;
        }
        str = str + ' ] \n \n [ Core_AccountCoverage_LoadType__c. Name . Core_LoadType__c ';
        for(Core_AccountCoverage_LoadType__c cb : [select Name, Core_LoadType__c from Core_AccountCoverage_LoadType__c]){
            str = str +' \n '+cb.Name +' '+cb.Core_LoadType__c;
        }
        str = str + ' ] \n';
        
        return str;
    }
    
    public static String getAccountExport(){
        String str = '\n \n  [ Account Export Records \n';
        for(Core_AccountCoverage_Export__c ac :[Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c ]){
            str = str+' Operation:'+ac.Core_Operation__c+ ' Status :'+ac.Core_Status__c+' \n ';
        }
        return str;
    }
    
    @isTest public static void testLoadTypeDelta(){
        
        //Day 1 : Full Load
        //Integer count = [Select count() from AccountCoverage_Report__c];
        //System.assertEquals(0, count);
        System.debug('++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Test Method 1 ++++++++++++++++++++++++++');
        System.debug(' Intial Settings >> '+getAllSettings());
        System.debug(' Account Coverage before Batches '+getAccountExport());
        Test.startTest();
        Database.executeBatch(new Core_Batch_AccountCoverage_Delete());
        Test.stopTest();
        
        
        Core_Batch_TerritoryManagement tm = new Core_Batch_TerritoryManagement();
        Core_Batch_AccountCoverage_Summary sum = new Core_Batch_AccountCoverage_Summary();
        
        
        System.debug(' Day 1 Account Coverage before Summary '+getAccountExport());
        sum.execute(null, [Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c ]);
        System.debug(' Day 1 Account Coverage After Summary  '+getAccountExport());
        
        Database.executeBatch(new Core_Batch_AccountCoverage_Delete());
        /*
        List<Core_AccountCoverage_Export__c> cel = new List<Core_AccountCoverage_Export__c> ();
        for(Core_AccountCoverage_Export__c ac :[Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c ]){
            ac.Core_Status__c = 'New';
            cel.add(ac);
        } 
        
        System.debug(' Day 2 Before Batch '+getAccountExport());
        update cel;
        
        System.debug(' Count Of Jobs '+[SELECT count() FROM AsyncApexJob]);
        Integer jobCnt = 0;
        do{
            jobCnt = [SELECT Count() FROM AsyncApexJob WHERE Status = 'completed'];
        }while(count == 6);
        */
        
        System.debug(' Day 2 Account Coverage before Summary '+getAccountExport());
        sum.execute(null, [Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c ]);
        System.debug(' Day 2 Account Coverage After Summary  '+getAccountExport());

        
        
        System.debug(' Result '+[Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c ]);
        //Database.executeBatch(new Core_Batch_AccountCoverage_Summary());
        
    }
    
    /*
@isTest public static void testLoadTypeFull(){

//Day 1 : Full Load

Integer count = [Select count() from AccountCoverage_Report__c];
System.assertEquals(0, count);
System.debug('++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Test Method 1 ++++++++++++++++++++++++++');
System.debug(' Intial Settings >> '+getAllSettings());
Test.startTest();
Database.executeBatch(new Core_Batch_AccountCoverage_Delete());
Test.stopTest();
//Database.executeBatch(new Core_Batch_AccountCoverage_Summary());
} */
    
    
    
    
    
}