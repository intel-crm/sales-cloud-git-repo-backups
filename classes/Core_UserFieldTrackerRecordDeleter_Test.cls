/***************************************************************************************************** 
Class Name :    Core_UserFieldTrackerRecordDeleter_Test
Description:    This is the test class for Core_UserFieldTrackerRecordDeleter class
Added By   :    Accenture - Raushan Singh 
Modified By:                      Date:30/01/2019                     Changes:None  
*****************************************************************************************************/
@isTest
public class Core_UserFieldTrackerRecordDeleter_Test {
    @testSetup 
    // Test setup method
    static void setup() {
        
        List<Core_User_Field_Change_History__c> testRecords = new List<Core_User_Field_Change_History__c>();
        Core_User_Field_Change_History__c testRecord = new Core_User_Field_Change_History__c(Name = 'TestUserTracking', Core_Current_Value__c = 'abc', Core_Previous_Value__c = 'bcd');
        testRecords.add(testRecord);
        Core_User_Field_Change_History__c testRecord1 = new Core_User_Field_Change_History__c(Core_Current_Value__c = 'ab', Core_Previous_Value__c = 'bc');
        testRecords.add(testRecord1);
        
        /**********Inserting Core_User_Field_Change_History__c Test records*******/ 
        Database.insert(testRecords);
        
        //Fetching the value of custom label
        String customLabelValue = System.Label.Core_User_Field_Change_History_Record_Deletion;
        Integer strtToIntvalue = Integer.valueOf(customLabelValue.trim());
        Datetime recordDeletionDate = Datetime.now()-strtToIntvalue;
        //Setting the record date to the recorddeltion date
		Test.setCreatedDate(testRecord.Id, recordDeletionDate); 
        Test.setCreatedDate(testRecord1.Id, recordDeletionDate);
    }
    static testmethod void test(){
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String chron = '0 0 * ? * * *' ;
        System.runAs(currentUser){
        //Start Test
        Test.startTest();
        Core_User_Field_Change_History__c deleteTestRecords = new Core_User_Field_Change_History__c();
        //Querying the record to deleted
        deleteTestRecords = [SELECT Id,Name FROM Core_User_Field_Change_History__c WHERE Name = 'TestUserTracking'];
        
        Core_UserFieldTrackerRecordDeleter deleterecords = new Core_UserFieldTrackerRecordDeleter();
        Id batchId = Database.executeBatch(deleterecords, 10);
        System.schedule('Record Deletion', chron, new Core_UserFieldTrackerRecordDeleter());
            
        //Stop Test
        Test.stopTest();
        Boolean errorThrown = false;
        	try{
             Database.delete(deleteTestRecords);
        		}
        	catch(Exception e){
            errorThrown = true;
        	}
            System.assertEquals(errorThrown,true);
    }
   }
    

}