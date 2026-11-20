/***************************************************************************************************** 
Class Name :    Core_PreventDelTrackingRecord_Test
Handler Class : Core_PreventDelTrackingRecordHandler
Description:    Preventing deletion of Core user field tracking records
Added By   :    Accenture - Raushan Singh 
Modified By:                      Date:25/03/2019                     Changes:None  
*****************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_PreventDelTrackingRecord_Test {
	@testSetup 
    /*
     	Setting up test data
    */
    static void setup() {
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Profile sysAdminProfile = new Profile();
        UserRole userRole = new UserRole();
        
        System.runAs(currentUser){
           sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            userRole = [SELECT Id FROM UserRole WHERE Name='A&E Users']; // A&E Users
            
            List<User> testUsers = new List<User>();
            User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser'+String.valueOf(Math.random())+'@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,UserRoleId =userRole.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test');
            
            User testUser2 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser'+String.valueOf(Math.random())+'@intel.com',
                                     EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,UserRoleId =userRole.Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test3');
            testUsers.add(testUser);
            testUsers.add(testUser2);
            
            //Inserting Test Users
            Database.insert(testUsers);
            
            List<User> userToBeUpdated = new List<User>();
            for(User userToBeEdited:testUsers){
                userToBeEdited.FirstName ='Test1';
                userToBeUpdated.add(userToBeEdited);
            }
           Database.update(userToBeUpdated);
            
            List<Core_User_Field_Change_History__c> fieldTrackingRecords = new List<Core_User_Field_Change_History__c>();
            Core_User_Field_Change_History__c newRecord = new Core_User_Field_Change_History__c(Name = 'TestUserTracking',Core_Current_Value__c 
                                                                                                = 'Test1',Core_Previous_Value__c = 'Test', Core_Modified_User_Field__c ='FirstName',
                                                                                               Core_Impacted_User__c =testUser.Id);
            
            fieldTrackingRecords.add(newRecord);
            Core_User_Field_Change_History__c newRecord1 = new Core_User_Field_Change_History__c(Name = 'TestUserTracking1',Core_Current_Value__c 
                                                                                                = 'Test1',Core_Previous_Value__c = 'Test3', Core_Modified_User_Field__c ='FirstName',
                                                                                               Core_Impacted_User__c =testUser2.Id);
            fieldTrackingRecords.add(newRecord1);
            
            //Inserting fieldTrackingRecords 
            Database.insert(fieldTrackingRecords);
            
            //Fetching custom label value
            String customLabelValue = System.Label.Core_User_Field_Change_History_Record_Deletion;
            Integer strtToIntvalue = Integer.valueOf(customLabelValue.trim());
            Datetime recordDeletionDate = Datetime.now()-strtToIntvalue;
			Test.setCreatedDate(newRecord.Id, recordDeletionDate);
        }
    }
    static testmethod void test(){
        //Start Test
        Test.startTest();
        Core_User_Field_Change_History__c deleteRecord = new Core_User_Field_Change_History__c();
        Core_User_Field_Change_History__c deleteRecord1 = new Core_User_Field_Change_History__c();
        List<Core_User_Field_Change_History__c> deleteRecords = new List<Core_User_Field_Change_History__c>();
        deleteRecord =[Select Id,Name from Core_User_Field_Change_History__c where Name = 'TestUserTracking'];
        deleteRecord1 =[Select Id,Name from Core_User_Field_Change_History__c where Name = 'TestUserTracking1'];
        deleteRecords.add(deleteRecord);
        deleteRecords.add(deleteRecord1);
        
        //Stop Test
        Test.stopTest();
        Boolean errorThrown = false;
        try{
             
             Database.delete(deleteRecords);
        }
        catch(Exception e){
            errorThrown = true;
        }
        System.assertEquals(errorThrown,true);
    }
    
}