/*********************************************************************************************************************
Version       : 1.0
Created Date  : Apr 2021
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        24-Apr-2021             Sales_SetupHostComputerController Test class
* ---------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class Sales_SetupHostComputerController_Test {
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: getUserDetails_AdminTest - Test method for Apex Method -> getUserDetails
    * ****************************/
    @isTest static void getUserDetails_AdminTest(){
        try{              
            User u = Sales_TestDataFactory.createUserWithProfileRecord(new Map<String,String>{'Email'=>'shivamx.vishwakarma@intel.com'});
            User userObjReceived;
            System.runAs(u) {
                System.Test.startTest();
                userObjReceived = Sales_SetupHostComputerController.getUserDetails(userInfo.getUserId());
                System.Test.stopTest();
            }
            Boolean listHasIdsCheck = (userObjReceived != null ) ? true : false;
            System.assert(listHasIdsCheck,'Something wrong happened for Profile, received this:'+userObjReceived);
        }catch(Exception e){
            System.assert(false,e.getMessage());
        }
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: checkLicesnseExpirationDate_Test - Test method for Apex Method -> checkLicesnseExpirationDate
    * ****************************/
    @isTest static void checkLicesnseExpirationDate_Test()
    {
        String errMsg='';
        Map<String,String> host1 = new Map<String,String>();
        host1.put('Name',generateRandomString());
        host1.put('Sales_License_Type__c','FLOAT');
        host1.put('Sales_Computer_Type__c','HOST ID');
        host1.put('Sales_Computer_Name_Txt__c',generateRandomString());
        host1.put('Sales_isActiveHost__c','true');
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(host1);
        Map<String,String> host2 = new Map<String,String>();
        host2.put('Name',generateRandomString());
        host2.put('Sales_License_Type__c','FLOAT');
        host2.put('Sales_Computer_Type__c','HOST ID');
        host2.put('Sales_Computer_Name_Txt__c',generateRandomString());
        host2.put('Sales_isActiveHost__c','true');
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(host2);
        Map<String,String> host3 = new Map<String,String>();
        host3.put('Name',generateRandomString());
        host3.put('Sales_License_Type__c','FLOAT');
        host3.put('Sales_Computer_Type__c','HOST ID');
        host3.put('Sales_Computer_Name_Txt__c',generateRandomString());
        host3.put('Sales_isActiveHost__c','true');
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(host3);
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};    
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c' => hostRec1.Id});    
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Expiration_Date_Dt__c' => String.valueOf(Date.newInstance(2018, 2, 17))});      
        insert new List<Sales_License__c>{lic1,lic2};
            System.Test.startTest();
        try{
            Sales_SetupHostComputerController.checkLicesnseExpirationDate(hostRec1.Id);
            Sales_SetupHostComputerController.checkLicesnseExpirationDate(hostRec2.Id);
            Sales_SetupHostComputerController.checkLicesnseExpirationDate(hostRec3.Id);
        }catch(Exception e){
            errMsg=e.getMessage();
        }	
        System.Test.stopTest();
        System.assertEquals(errMsg, '');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: checkHostActivationStatus_Test - Test method for Apex Method -> checkHostActivationStatus
    * ****************************/
    @isTest static void checkHostActivationStatus_Test()
    {
        String errMsg='';
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        insert hostRec1;  
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord();//mar26
        hostRec2.Sales_isActiveHost__C = false;//mar26
        hostRec2.Name='DDCD1234EF30';//mar26
        hostRec2.Sales_Computer_Name_Txt__c = 'TestClass Computer2';//mar26
        insert hostRec2;//mar26
          
        System.Test.startTest();
        try{
            Sales_SetupHostComputerController.checkHostActivationStatus(hostRec1.Id);
            Sales_SetupHostComputerController.checkHostActivationStatus(hostRec2.Id);//mar26
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Contact con = createContactWithDetails(accObj.id, 'test', 'abc', 'abc@intel.com');
            Sales_SetupHostComputerController.getDelegateContactIds(con.Id);
            
        }catch(Exception e){
            errMsg=e.getMessage();
        }	
        System.Test.stopTest();
        System.assertEquals(errMsg, '');
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = fName;
        con.LastName = lName;
        con.Email = emailId;
        con.AccountId = accId;
        con.MailingCountry='USA';
        con.Core_Primary_Contact__c = true;
        insert con;
        return con;
    }
    public static String generateRandomString(){        
        String itr = String.valueOf(Math.round((Math.random() * (90000000) + 10000000)));        
        return itr;
    }

    
}