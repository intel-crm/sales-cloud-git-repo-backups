/*********************************************************************************************************************
Class Name    : Sales_LicenseAdminDelegateTest
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma            28-May-2021         License Admin Delegate Test class  
* *********************************************************************************************************************/
@isTest
public class Sales_LicenseAdminDelegateTest {
    @isTest 
    public static void shareRecordWithPrimaryOnLicAdmDlgRecord(){
        String errMsg='';
        User u4 = createUserWithProfile();
        insert u4;
        Contact partnerContact;
        Contact partnerContact2;
        Contact partnerContact3;
        Account partnerAccount;
        system.runAs(u4){ 
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
        }
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
        List<User> users = new List<User>{u1,u2,u3};
            insert users;
        try{
            Test.startTest();
            system.runAs(u4){ 
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                licdlg1.Sales_License_PrimaryAdmin_Contact__c = partnerContact3.Id;
                update licdlg1;
            }
            Set<id> conSet=new set<id>();
            conSet.add(partnerContact.id);
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest 
    public static void shareRecordTest2(){
        String errMsg='';
        User u4 = createUserWithProfile();
        insert u4;
        Contact partnerContact;
        Contact partnerContact2;
        Contact partnerContact3;
        Account partnerAccount;
        system.runAs(u4){ 
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
        }
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
        List<User> users = new List<User>{u1,u2,u3};
            insert users;
        try{
            Test.startTest(); 
            system.runAs(u4){
                Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
                Pricebookentry pbEntry = new Pricebookentry();
                pbEntry.UnitPrice = 240;
                pbEntry.Pricebook2Id = Test.getStandardPricebookId();
                pbEntry.Product2Id = prod1.Id;
                insert pbEntry;
                Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
                OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
                String companionServerId='BBBBAAAACCCC';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
            }
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
    }   
    @isTest 
    public static void revokeAccessTest(){
        String errMsg='';
        Account partnerAccount ;
        Contact partnerContact ;
        Contact partnerContact2;
        User u1;
        User u2;
        List<User> users;
        User currentUser = createUserWithProfile();
        insert currentUser;
        system.runAs(currentUser){  
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
            u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
            users = new List<User>{u1,u2};
                insert users;
        }
        system.runAs(currentUser){  
            Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            Pricebookentry pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
            try{
                Test.startTest(); 
                OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
                Sales_License__c lic = [Select Id, Sales_License_Order_Product__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
                String companionServerId='BBBBAAAACCCC';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                delete licdlg1;
                Test.stopTest();            
            }catch(Exception e){
                errMsg=e.getMessage();
            } 
        }
        System.assert(errMsg=='', errMsg);
    }   
    @isTest 
    public static void shareRecordTest3(){
        String errMsg='';
        User u4 = createUserWithProfile();
        insert u4;
        Contact partnerContact;
        Contact partnerContact2;
        Contact partnerContact3;
        Account partnerAccount1;
        system.runAs(u4){ 
            partnerAccount1 = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount1.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount1.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount1.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
        }
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
        List<User> users = new List<User>{u1,u2,u3};
            insert users; 
        try{
            Test.startTest();  
            system.runAs(u4){          
                String companionServerId='BBBBAAAACCCC';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                licdlg1.Sales_License_DlgAdmin_Contact__c = partnerContact3.Id;
                update licdlg1;
            }
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest 
    public static void shareRecordTest4(){
        String errMsg='';
        User u4 = createUserWithProfile();
        insert u4;
        Contact partnerContact;
        Contact partnerContact2;
        Contact partnerContact3;
        Account partnerAccount;
        system.runAs(u4){ 
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
            partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
        }
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);        
        List<User> users = new List<User>{u1,u2,u3};
            insert users;
        try{
            system.runAs(u4){ 
                Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
                Pricebookentry pbEntry = new Pricebookentry();
                pbEntry.UnitPrice = 240;
                pbEntry.Pricebook2Id = Test.getStandardPricebookId();
                pbEntry.Product2Id = prod1.Id;
                insert pbEntry;
                Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');       
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                Test.startTest();
                OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);                      
                licdlg1.Sales_License_DlgAdmin_Contact__c = partnerContact3.Id;
                update licdlg1;
                Test.stopTest();
            }
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assert(errMsg=='', errMsg);
    }
    @isTest 
    public static void record_InActive_Active_Test(){
        String errMsg='';
        User u1 ;
        User u2 ;       
        List<User> users;
        User currentUser = createUserWithProfile();
        insert currentUser;
        Account partnerAccount ;
        Contact partnerContact ;
        Contact partnerContact2 ;
        system.runAs(currentUser){  
            partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
            partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
            partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        }
        u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
        users = new List<User>{u1,u2};
            insert users;
        system.runAs(currentUser){
            Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
            Pricebookentry pbEntry = new Pricebookentry();
            pbEntry.UnitPrice = 240;
            pbEntry.Pricebook2Id = Test.getStandardPricebookId();
            pbEntry.Product2Id = prod1.Id;
            insert pbEntry;
            Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
            try{
                Test.startTest(); 
                OrderItem ordItm1 = createOrderProductWithContact(ord.Id, prod1.id, pbEntry.id, partnerContact.Id);           
                Sales_License__c lic = [Select Id, Sales_License_Order_Product__c from Sales_License__c where Sales_License_Order_Product__c=:ordItm1.Id];
                String companionServerId='BBBBAAAACCCC';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,null,null);
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                licdlg1.Sales_License_isActive__c = false;
                update licdlg1;
                licdlg1.Sales_License_isActive__c = true;
                update licdlg1;
                Test.stopTest();            
            }catch(Exception e){
                errMsg=e.getMessage();
            } 
        }
        System.assert(errMsg=='', errMsg);
    }      
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID')
            h.Name='AAAAAABC';                  
        else if(compType=='NIC ID')
            h.Name='AAAAAABBBBEF';              
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        h.Sales_Host_Is_Created_From_Custom_Page__c=true;
        insert h;
        return h;
    }
    public static Sales_License_Admin_Delegate__c createPriAdmDlgAdmRecord(Id primAdmContactId, Id dlgAdmContactId){
        Sales_License_Admin_Delegate__c licAdmDlg1 = new Sales_License_Admin_Delegate__c();
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = primAdmContactId;
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = dlgAdmContactId;
        licAdmDlg1.Sales_License_isActive__c = true;
        insert licAdmDlg1;
        return licAdmDlg1;
    }
    public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@testorg.com';   
        Profile specificProfile = [SELECT Id FROM Profile WHERE Name=:profileName];  
        User userTest;
        if(profileName == 'Partner'){
            UserRole role = [SELECT Id from UserRole where Name = 'Test Partner1 Partner User' limit 1];
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
        con.MailingCountry = 'India';
        insert con;
        return con;
    }
    public static OrderItem createOrderProductWithContact(Id ordId, Id prodId, Id pbEntryId, Id ContactId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 1;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.SBQQ__Status__c='Draft';
        i.PricebookEntryId=pbEntryId;
        i.Sales_Contact__c = ContactId;
        insert i;
        return i;
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
}