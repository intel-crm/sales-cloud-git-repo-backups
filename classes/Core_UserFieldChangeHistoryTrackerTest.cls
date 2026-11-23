/***************************************************************************************************** 
Class Name :    Core_UserFieldChangeHistoryTrackerTest
Description:    This is the test class for Core_UserFieldChangeHistoryTracker class
Added By   :    Accenture - Raushan Singh 
Modified By:                      Date:29/01/2019                     Changes:None  
*****************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_UserFieldChangeHistoryTrackerTest {
            final static string PROFILE_NAME = 'System Administrator';
            final static string USERROLE_NAME = 'A&E Users'; 

    //Test Setup data 
    @testSetup 
    static void setup() {
        
       //Custom setting data creation for createFeed
       List<User> testUsers = new List<User>();
       List<Core_Trigger_Executions__c> allCustomSettings = new List<Core_Trigger_Executions__c>();
       Core_Trigger_Executions__c newCustomSetting = new Core_Trigger_Executions__c();
       newCustomSetting.Core_Active__c =true;newCustomSetting.Name = 'createFeed';
       newCustomSetting.Core_Class_Name__c = 'Core_UserFieldChangeHistoryTracker';
       newCustomSetting.Core_Description__c ='To track user field change';           
       newCustomSetting.Core_Object__c ='User';
       newCustomSetting.Core_Trigger_Events__c = 'After update';
       allCustomSettings.add(newCustomSetting);
        
       //Custom setting data creation for assignLanguage 
       Core_Trigger_Executions__c newCustomSetting1 = new Core_Trigger_Executions__c();
       newCustomSetting1.Core_Active__c =true;newCustomSetting1.Name = 'assignLanguage';
       newCustomSetting1.Core_Class_Name__c = 'Core_UserHandler';
       newCustomSetting1.Core_Description__c ='Used to check whether the Language Update can be done for Non IPS Users';           
       newCustomSetting1.Core_Object__c ='User';
       newCustomSetting1.Core_Trigger_Events__c = 'Before Insert';
       allCustomSettings.add(newCustomSetting1);
        
       //Custom setting data creation for userGeoUpdate
       Core_Trigger_Executions__c newCustomSetting2 = new Core_Trigger_Executions__c();
       newCustomSetting2.Core_Active__c =true;newCustomSetting2.Name = 'userGeoUpdate';
       newCustomSetting2.Core_Class_Name__c = 'Core_UserHandler';
       newCustomSetting2.Core_Description__c ='populates Geo based on User Country Code using the Country State Reference object';           
       newCustomSetting2.Core_Object__c ='User';
       newCustomSetting2.Core_Trigger_Events__c = 'before insert, before update';
       allCustomSettings.add(newCustomSetting2);
        
       //Custom setting data creation for userFreezeUnfreeze
       Core_Trigger_Executions__c newCustomSetting3 = new Core_Trigger_Executions__c();
       newCustomSetting3.Core_Active__c =true;newCustomSetting3.Name = 'userFreezeUnfreeze';
       newCustomSetting3.Core_Class_Name__c = 'Core_UserHandler';
       newCustomSetting3.Core_Description__c ='Intercepts update statements that would deactivate or reactivate standard users, and instead freezes/unfreezes them, so they dont lose team access';           
       newCustomSetting3.Core_Object__c ='User';
       newCustomSetting3.Core_Trigger_Events__c = 'before update';
       allCustomSettings.add(newCustomSetting3);
       
       //Custom setting data creation for userProfileGroupAssignment
       Core_Trigger_Executions__c newCustomSetting4 = new Core_Trigger_Executions__c();
       newCustomSetting4.Core_Active__c =true;newCustomSetting4.Name = 'userProfileGroupAssignment';
       newCustomSetting4.Core_Class_Name__c = 'Core_UserHandler';
       newCustomSetting4.Core_Description__c ='profile assignment';           
       newCustomSetting4.Core_Object__c ='User';
       newCustomSetting4.Core_Trigger_Events__c = 'After Insert,After Update';
       allCustomSettings.add(newCustomSetting4);
        
       //Custom setting data creation for userEmployeeTypeGroupAssignment
       Core_Trigger_Executions__c newCustomSetting5 = new Core_Trigger_Executions__c();
       newCustomSetting5.Core_Active__c =true;newCustomSetting5.Name = 'userEmployeeTypeGroupAssignment';
       newCustomSetting5.Core_Class_Name__c = 'Core_UserHandler';
       newCustomSetting5.Core_Description__c ='Adds user to group based on their profile.';           
       newCustomSetting5.Core_Object__c ='User';
       newCustomSetting5.Core_Trigger_Events__c = 'After Insert,After Update';
       allCustomSettings.add(newCustomSetting5);
        
       //Inserting custom setting 
       Database.insert(allCustomSettings);
        
       //Getting the current user information 
       User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
       //Instantiating UserRole 
       UserRole userRole = new UserRole();
       UserRole userRole2 = new UserRole();
        
       //Instantiating Profile
       Profile sysAdminProfile = new Profile();
        
       //Instantiating User 
       User managerName = new User();
       User delegatedApprover = new User();
        
        System.runAs(currentUser){
            
            sysAdminProfile = [SELECT Id FROM Profile WHERE Name=:PROFILE_NAME];
            userRole = [SELECT Id FROM UserRole WHERE Name=:USERROLE_NAME]; // A&E Users
            userRole2 = [Select Id FROM UserRole WHERE Name = 'Admin'];// Admin
            
            //Creating Test User records
            for(Integer countOfUsers=0; countOfUsers < 1; countOfUsers++ ){ 
                
                User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUserrr3'+'@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,UserRoleId =userRole.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+ countOfUsers +'@dell.com',FirstName='Test');
            
           
                
                testUsers.add(testUser);
            }
             
            User testUser2 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUserrr1'+'@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='Usermmm', LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,UserRoleId =userRole.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMD.com',FirstName='Test');
			testUsers.add(testUser2);
            User testUser3 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUserrr2'+'@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,UserRoleId =userRole2.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test');
            
            testUsers.add(testUser3);
            //Inserting test users   
            Database.insert(testUsers);
           
        }
    } 
   static testmethod void test(){
       //start test
        Test.startTest();
           Profile itAdmin = [SELECT ID FROM Profile WHERE Name='IT Admin'];
           UserRole adminUserRole = [Select ID FROM UserRole WHERE Name ='Admin'];
           User newManager = [Select ID,Name FROM User WHERE Email = 'testUserrr3@intel.com'];
       	   User newDelegatedApprover = [SELECT ID,Name FROM User WHERE Email = 'testUserrr2@intel.com']; 
		   List <User> userList = [Select Id,Name,FirstName,Alias,Email,ProfileId from User where UserName like '%@CoreMD.com%'];
           List<User> tobeUpdatedUsers = new List<User>();
       
       //Updating User
           for(User createdUser : userList){
               createdUser.FirstName = 'Track1';
               createdUser.ProfileId = itAdmin.Id;
               createdUser.UserRoleId = adminUserRole.Id;
               createdUser.ManagerId = newManager.Id;
               createdUser.DelegatedApproverId = newDelegatedApprover.Id;
               tobeUpdatedUsers.add(createdUser);
            }
           update(tobeUpdatedUsers);
       //Stop Test
       Test.stopTest();
        }  
    }