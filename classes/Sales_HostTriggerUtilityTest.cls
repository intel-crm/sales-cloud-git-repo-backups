/*********************************************************************************************************************
Class Name    : Sales_HostTriggerUtilityTest
Version       : 1.0
Created Date  : May 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma           31-May-2021           Test Class for Host Information Trigger Utility
* *********************************************************************************************************************/
@isTest
public class Sales_HostTriggerUtilityTest {
    @isTest 
    static void shareRecordTest1(){
        String errMsg='';
        Account partnerAccount; 
        Contact partnerContact ;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        User u1; 
        User u2 ;     
        User u3 ;
        List<User> users ;
        try{
            Test.startTest(); 
            User u4 = createUserWithProfile(); 
            insert u4;
            System.runAs(u4)
            {    
                partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
                partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
                partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
                partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partner3','addhos3','mohammadx.dilshad@mailinator.com');
                u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
                u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
                u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);
                users = new List<User>{u1,u2,u3};
                    insert users ;            
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                String companionServerId='132456789014';
                String companionServerId2='162456789014';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                hostRecord.Sales_Contact__c = partnerContact3.Id;
                update hostRecord;
            }
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assertEquals(errMsg,'');
    }
    @isTest 
    static void shareRecordTest3(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partner3','addhos3','mohammadx.dilshad@mailinator.com');
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);
        try{
            Test.startTest(); 
            User currentUser = [Select id FROM User WHERE Id=:UserInfo.getUserId()];
            system.runAs(currentUser){           
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
                Sales_License_Admin_Delegate__c licdlg3 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact.Id);         
                String companionServerId='132456789014';
                String companionServerId2='162456789014';
                Sales_Host__c hostRecord1 = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                hostRecord.Sales_Contact__c = partnerContact3.Id;
                update hostRecord;
            }
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
    }
    @isTest 
    static void shareRecordTest2(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partne3','addhos3','shivamx.vishwakarma2@mailinator.com');
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);
        try{
            Test.startTest();
            User currentUser = [Select id FROM User WHERE Id=:UserInfo.getUserId()];
            system.runAs(currentUser){           
                String companionServerId='122456789014';
                String companionServerId2='192456789014';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                Test.stopTest();  
            }           
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assertEquals(errMsg,'');
    }
    @isTest 
    static void validateHostTest(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('FIXED',null);
        try{
            Test.startTest();
            User currentUser = [Select id FROM User WHERE Id=:UserInfo.getUserId()];
            system.runAs(currentUser){           
                String companionServerId='142456789014';
                String companionServerId2 = '152456789015';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord();
                lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
                lic.Sales_License_Host_Node_Id__c = hostRecord.id;
                lic.Sales_License_Product__c = prod1.Id;
                lic.Sales_License_Status__c = 'Unlicensed';
                lic.Sales_License_Type__c = 'Original';
                insert lic;
                hostRecord.Name = '186253490832';
                hostRecord.Sales_Contact__c =  partnerContact2.Id;
                update hostRecord;
                Test.stopTest();   
                Map<Id, List<Id>>  GrantLicenseAccessForUsersMap = new Map<Id, List<Id>>();
                if(GrantLicenseAccessForUsersMap.containsKey(hostRecord.Id)) {
                    List<Id> usersId = GrantLicenseAccessForUsersMap.get(hostRecord.Id);
                    usersId.add(hostRecord.Id);
                    GrantLicenseAccessForUsersMap.put(hostRecord.Id,usersId);
                } else {
                    GrantLicenseAccessForUsersMap.put(hostRecord.Id, new List<Id> { hostRecord.Id });
                }
                Sales_HostTriggerUtility.revokeSharedEditAccessOnHosts(GrantLicenseAccessForUsersMap);
            }
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assertEquals(errMsg,'');
    }
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1,String compServ2, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID')
            h.Name='AAA36AAA';
        else if(compType=='NIC ID')
            h.Name='176253490832';  
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Companion_Server2_Txt__c = compServ2;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        h.Sales_Host_Is_Created_From_Custom_Page__c = true;
        insert h;
        return h;
    }
    @isTest 
    static void shareRecordTest5(){
        String errMsg='';
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        Contact partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partner3','addhos3','mohammadx.dilshad@mailinator.com');
        User u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
        User u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
        User u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);
        try{
            Test.startTest(); 
            User currentUser = [Select id FROM User WHERE Id=:UserInfo.getUserId()];
            system.runAs(currentUser){           
                Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
                Sales_License_Admin_Delegate__c licdlg2 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact3.Id);
                Sales_License_Admin_Delegate__c licdlg3 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact.Id);         
                String companionServerId='132456789014';
                String companionServerId2='162456789014';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                hostRecord.Sales_Contact__c = partnerContact3.Id;
                update hostRecord;
                Map<Id, List<Id>>  GrantLicenseAccessForUsersMap = new Map<Id, List<Id>>();
                if(GrantLicenseAccessForUsersMap.containsKey(hostRecord.Id)) {
                    List<Id> usersId = GrantLicenseAccessForUsersMap.get(hostRecord.Id);
                    usersId.add(hostRecord.Id);
                    GrantLicenseAccessForUsersMap.put(hostRecord.Id,usersId);
                } else {
                    GrantLicenseAccessForUsersMap.put(hostRecord.Id, new List<Id> { hostRecord.Id });
                }
                Sales_HostTriggerUtility.manualShareEditAccessOnHosts(GrantLicenseAccessForUsersMap);
            }
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
        System.assertEquals(errMsg,'');
    }
    @isTest 
    static void shareRecordTest8(){
        String errMsg='';
        Account partnerAccount; 
        Contact partnerContact ;
        Contact partnerContact2 ;
        Contact partnerContact3 ;
        User u1; 
        User u2 ;     
        User u3 ;
        List<User> users ;
        Product2 prod1 ;
        Pricebookentry pbEntry ;
        Order ord;
        try{
            Test.startTest(); 
            User u4 = createUserWithProfile(); 
            insert u4;
            System.runAs(u4)
            {    
                partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
                partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
                partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
                partnerContact3 = createContactWithDetails(partnerAccount.Id, 'partner3','addhos3','mohammadx.dilshad@mailinator.com');
                u1 = createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', partnerContact.Id, true);
                u2 = createUser_WithSpecificProfile('partneraddhos2','part2','Partner','shivamx.vishwakarma@mailinator.com', partnerContact2.Id, true);       
                u3 = createUser_WithSpecificProfile('partneraddhos3','part3','Partner','shivamx.vishwakarma2@mailinator.com', partnerContact3.Id, true);
                users = new List<User>{u1,u2,u3};
                    insert users ;            
                Sales_License_Admin_Delegate__c licdlg3 = createPriAdmDlgAdmRecord(partnerContact3.Id, partnerContact.Id);         
                String companionServerId='132456789014';
                String companionServerId2='162456789014';
                Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',partnerContact.Id,companionServerId,companionServerId2,null,null);
                prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
                pbEntry = new Pricebookentry();
                pbEntry.UnitPrice = 240;
                pbEntry.Pricebook2Id = Test.getStandardPricebookId();
                pbEntry.Product2Id = prod1.Id;
                insert pbEntry;
                ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order'); 
                Sales_License__c lic = new Sales_License__c();
                lic.Sales_License_Order__c = ord.Id;
                lic.Sales_License_Primary_Admin_Contact__c = partnerContact3.Id;
                lic.Sales_License_Product__c = prod1.Id;
                lic.Sales_License_Host_Node_Id__c = hostRecord.id;
                insert lic;
                hostRecord.Sales_Contact__c = partnerContact2.Id;
                Update hostRecord;
            }
            Test.stopTest();            
        }catch(Exception e){
            errMsg=e.getMessage();
        } 
    }
    public static Sales_License_Admin_Delegate__c createPriAdmDlgAdmRecord(Id primAdmContactId, Id dlgAdmContactId){
        Sales_License_Admin_Delegate__c licAdmDlg1 = new Sales_License_Admin_Delegate__c();
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = primAdmContactId;
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = dlgAdmContactId;
        insert licAdmDlg1;
        return licAdmDlg1;
    }
    public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@testorg.com';   
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
    public static User createUserWithProfile() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                             UserName=uniqueUserName, EmailEncodingKey='UTF-8'   );
        return user;
    }
    public static  List<Sales_License__c> fetchLicensesFromHosttest(id hostid){
        List<Sales_License__c> listlic = [select Name,Sales_License_Primary_Admin_Contact__r.Name, Sales_License_Activation_Code__c, Sales_License_Product__r.Name, Sales_License_Type__c, Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c ,Sales_License_Avbl_Qty_Nbr__c, Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Expiration_Date_Dt__c, Sales_License_Maintenance_Exp_Dt__c ,Sales_Lic_User_Contact_Txt__c, Sales_License_Quantity__c from Sales_License__c where Sales_License_Type__c !='Optional' and Sales_License_Web_Display_Flag__c =true and Sales_License_Host_Node_Id__c=:hostid];
        return listlic;
    }
}