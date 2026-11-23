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
/*    @isTest static void getUserDetails_AdminTest(){
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
/*    @isTest static void checkLicesnseExpirationDate_Test()
    {
        String errMsg='';
        Map<String,String> host1 = new Map<String,String>();
        host1.put('Name',generateRandomString());
        host1.put('Sales_License_Type__c','FLOAT');
        host1.put('Sales_Computer_Type__c','HOST ID');
        host1.put('Sales_Computer_Name_Txt__c',generateRandomString());
        host1.put('Sales_isActiveHost__c','true');
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(host1);
        System.debug('hostRec1 - '+hostRec1);
        
        Map<String,String> host2 = new Map<String,String>();
        
        host2.put('Name',generateRandomString());
        host2.put('Sales_License_Type__c','FLOAT');
        host2.put('Sales_Computer_Type__c','HOST ID');
        host2.put('Sales_Computer_Name_Txt__c',generateRandomString());
        host2.put('Sales_isActiveHost__c','true');
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(host2);
        System.debug('hostRec2 - '+hostRec2);
        
        Map<String,String> host3 = new Map<String,String>();
        
        host3.put('Name',generateRandomString());
        host3.put('Sales_License_Type__c','FLOAT');
        host3.put('Sales_Computer_Type__c','HOST ID');
        host3.put('Sales_Computer_Name_Txt__c',generateRandomString());
        host3.put('Sales_isActiveHost__c','true');
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(host3);
        System.debug('hostRec3 - '+hostRec3);
        
       // Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
       // Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord();
       // Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord();
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
/*     @isTest static void checkHostActivationStatus_Test()
     {
        String errMsg='';
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        insert hostRec1;
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord();
        hostRec2.Sales_isActiveHost__C = false;
        hostRec2.Name='DDCD1234EF30';
        hostRec2.Sales_Computer_Name_Txt__c = 'TestClass Computer2';
        insert hostRec2;
          
        System.Test.startTest();
        try{
            Sales_SetupHostComputerController.checkHostActivationStatus(hostRec1.Id);
            Sales_SetupHostComputerController.checkHostActivationStatus(hostRec2.Id);
            Account accObj = Sales_TestFactory_Utility.createAccount(); 
            Contact con = createContactWithDetails(accObj.id, 'test', 'abc', 'abc@intel.com');
            Sales_SetupHostComputerController.getDelegateContactIds(con.Id);
            
        }catch(Exception e){
            errMsg=e.getMessage();
        }	
        System.Test.stopTest();
        System.assertEquals(errMsg, '');
     }
    
    
    /*Input Parameters for createUser_WithSpecificProfile()
    String userNameIntial --> Username (before @ symbol)
    String userAlias --> An Alias for User
    String profileName --> Profile Name
    String emailId --> Email Id to be associated to User.
    Id partnerContactId --> if Profile is Partner, a Contact has to be associated to this User, provide a Contact Id.
    Boolean activeCheck --> Is user Active or not? if active, this is true, else false.
    */
    /*public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@testorg.com';   // Create a unique UserName
        Profile specificProfile = [SELECT Id FROM Profile WHERE Name=:profileName];  
        User userTest;
        if(profileName == 'Partner'){
            userTest = new User(Alias=userAlias, Email=emailId, ContactId=partnerContactId, IsActive=activeCheck,
                                EmailEncodingKey='UTF-8', LastName=userNameIntial+'Test', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = specificProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        }else{
            userTest = new User(Alias=userAlias, Email=emailId, IsActive=activeCheck,
                                EmailEncodingKey='UTF-8', LastName=userNameIntial+'Test', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = specificProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        }
        
        return userTest;
    }
    
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   // PSG Downstream true
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'CCG Sales Group';       
        insert acc;
        return acc;
    } */
    
/*    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
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
/*
    @isTest static void getUserDetails_AdminTest(){
        try{              
            User u = createUser_WithSpecificProfile('sysadmaddhost','syadt','System Administrator','shivamx.vishwakarma@intel.com', null, true);                
            User userObjReceived;
            System.runAs(u) {
                test.startTest();
                userObjReceived = Sales_SetupHostComputerController.getUserDetails(userInfo.getUserId());
                test.stopTest();
            }
            Boolean listHasIdsCheck = (userObjReceived != null && userObjReceived.Contact == null ) ? true : false;
            System.assert(listHasIdsCheck,'Something wrong happened for Profile, received this:'+userObjReceived);
        }catch(Exception e){
            System.assert(false,e.getMessage());
        }
    }
    
    @isTest static void getUserDetails_PartnerTest(){
        try{                              
            Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            User u = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            User userObjReceived;
            System.runAs(u) {
                test.startTest();
                userObjReceived = Sales_SetupHostComputerController.getUserDetails(userInfo.getUserId());
                test.stopTest();
            }
            Boolean listHasIdsCheck = (userObjReceived != null && userObjReceived.Contact != null ) ? true : false;
            System.assert(listHasIdsCheck,'Could not retrieve users - Contact and associated Account Id, received this:'+userObjReceived);
        }catch(Exception e){
            System.assert(false,e.getMessage());
        }
    }

    @isTest static void getUserDetails_InActive_PartnerTest(){
        try{                              
            Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            User u = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, false);
            insert u;
            User userObjReceived;
            //NOTE: System.runAs can only be used with an active user, hence not using in this case
            test.startTest();
            userObjReceived = Sales_SetupHostComputerController.getUserDetails(u.Id);
            test.stopTest();
           
            Boolean listHasIdsCheck = (userObjReceived == null) ? true : false;
            System.assert(listHasIdsCheck,'User should have been Inactive, something went wrong, received this:'+userObjReceived);
        }catch(Exception e){
            System.assert(false,e.getMessage());
        }
    }
    
*/

/*    public static String generateRandomString(){        
        String itr = String.valueOf(Math.round((Math.random() * (90000000) + 10000000)));        
        return itr;
    }
*/    
    
} // End of Class