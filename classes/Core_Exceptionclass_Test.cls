/***************************************************************************************************
Class Name:  Core_Exceptionclass_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 10 Feb 2016
Function    : This class contains test coverage for Core_Exceptionclass class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_Exceptionclass class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya            10/02/2016                Created
****************************************************************************************************/   
@isTest
public class Core_Exceptionclass_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            10/02/2016                Created
    ****************************************************************************************************/
    static void getRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    /***************************************************************************************************
    Method Name:  InsertException_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 10 Feb 2016
    Description:  Testing InsertException_PositiveTest() utility method.
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya            10/02/2016                Created
    ****************************************************************************************************/
    static testmethod void InsertException_PositiveTest(){
        getRecords();
        System.runAs(ListOfUser.get(0)){
            Test.startTest();
            Core_Exceptionclass obj = new Core_Exceptionclass();
            try{
                Exception excep;
                integer i = 1/0;
                string str = obj.InsertException('test','test','test','test','test',excep);
            }catch(exception e){
                string str = obj.InsertException('test','test','test','test','test',e);
            }            
            Test.stopTest();
        }
    }
}