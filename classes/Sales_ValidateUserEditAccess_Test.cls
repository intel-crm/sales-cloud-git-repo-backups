@isTest
public class Sales_ValidateUserEditAccess_Test {
/*
    @isTest 
    public static void validateUserEditTest(){
        String errMsg='';
        Account partnerAccount ;
        Contact partnerContact ;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        Contact partnerContact4;
        User u1 ;
        User u2 ;
        User u3 ;
        List<User> users ;
        Product2 prod1;
        Pricebookentry pbEntry ;
        Order ord ;
        User u4 = createUserWithProfile(); 
        insert u4;
        System.runAs(u4){
            TriggerHandler.bypass('Core_AccountHandler');
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
            partnerContact4 = createContactWithDetails(partnerAccount.Id, 'partne4','addhos4','shivamx.vishwakarma35@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
            u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
            users = new List<User>{u1,u2,u3};
                prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            insert users;
            Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
            testLicense.Sales_License_Web_Display_Flag__c = true;
            testLicense.Sales_License_Product__c=prod1.id;
            insert testLicense;
            Sales_ValidateUserEditAccess.Input Input  = new  Sales_ValidateUserEditAccess.Input();
            Input.userID=u4.id;
            Input.recordId=testLicense.id;
            List<Sales_ValidateUserEditAccess.Output> result = new List<Sales_ValidateUserEditAccess.Output>();
            try{
                result=Sales_ValidateUserEditAccess.validateUserAccessFromFlow(new List<Sales_ValidateUserEditAccess.Input>{Input});
                Sales_ValidateUserEditAccess.validateUserAccess(u4.id,testLicense.id);
            }catch(Exception e){
                errMsg=e.getMessage();
            } 
        }
        System.assert(errMsg=='', errMsg);
    } 
    public static User createUserWithProfile() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                             UserName=uniqueUserName, EmailEncodingKey='UTF-8'   );
        return user;
    }
    public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@intel.com';   
        User currentUser = [Select id FROM User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
        }
        Profile specificProfile = [SELECT Id FROM Profile WHERE Name=:profileName];  
        User userTest;
        if(profileName == 'Partner'){
            UserRole userRole = [SELECT Id from UserRole where PortalType = 'Partner' Limit 1] ;       
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
        acc.Core_PSG_Account__c=true;   
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
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = fName;
        con.LastName = lName;
        con.Email = emailId;
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        insert con;
        return con;
    }
*/
}