/**************************************************************************************
Apex Class Name : PMP_OPID_MPI_Rel_TriggerHandler_Test
Version     : 1.0 
Created Date: 20th Oct, 2021
Description : Test class for PMP_OPID_MPI_Rel_TriggerHandler
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* ONYX                 20/10/2021               Original Version
*************************************************************************************/

@isTest
public class PMP_OPID_MPI_Rel_TriggerHandler_Test {

    @isTest
    public static void  insertUtility() 
    {
    Test.startTest();
    Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update,before delete',
                                                                        Core_Description__c = 'Create and update MPI & OPID Relationships.');
    insert cs;
        
        
    
       
        
        Core_Trigger_Executions__c cs4 = new Core_Trigger_Executions__c (Name = 'PMP_Companyinfosharing_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update,before delete',
                                                                        Core_Description__c = 'Create and update MPI & OPID Relationships.');
    insert cs4;
       
       
    Core_Trigger_Executions__c csleadrouting = new Core_Trigger_Executions__c (Name = 'reprocessLeadSharing',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'reprocessLeadSharing');
    insert csleadrouting;
    
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    
    Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;

    Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;

    
    Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
    
    List<PMP_Company__c> cmpList = new List<PMP_Company__c>();
    Map<id,PMP_Company__c>  comMap =new Map<id,PMP_Company__c>(); 
        
    PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Partner_Country_Txt__c = 'India';
        company.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        company.PMP_Is_Published_Ind__c = true;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        insert company;
                
    PMP_OPID_MPI_Rel__c NewOpid = new PMP_OPID_MPI_Rel__c();
        NewOpid.PMP_Marketing_Profile_Id__c = company.id;
        NewOpid.PMP_One_Partner_ID__c = newPagAccount.id;
        NewOpid.Is_Active__c = true;
        insert NewOpid;
        
        

    Test.stopTest();
    
    }
    

    
    @isTest
    public static void afterUpdateOpidTest(){
        
        Core_Trigger_Executions__c csleadrouting = new Core_Trigger_Executions__c (Name = 'reprocessLeadSharing',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'reprocessLeadSharing');
        insert csleadrouting;
        
         Core_Trigger_Executions__c cs5 = new Core_Trigger_Executions__c (Name = 'OPID_MPI_Validation_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,Before Update,before delete',
                                                                        Core_Description__c = 'Create and update MPI & OPID Relationships.');
    insert cs5;
        
        Core_Trigger_Executions__c cs1 = new Core_Trigger_Executions__c (Name = 'OPID_MPI_Junction_Status_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update,before delete',
                                                                        Core_Description__c = 'Create and update MPI & OPID Relationships.');
    insert cs1;
        
         Core_Trigger_Executions__c cs2 = new Core_Trigger_Executions__c (Name = 'PMP_OPID_MPI_OfferingSharing_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update,before delete',
                                                                        Core_Description__c = 'Create and update MPI & OPID Relationships.');
    insert cs2;
        
        Core_Trigger_Executions__c cs3 = new Core_Trigger_Executions__c (Name = 'PSS_OPIDMPI_Rel__c',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_OPID_MPI_Rel_TriggerHandler',
                                                                        Core_Object__c = 'PMP_OPID_MPI_Rel__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update,before delete',
                                                                        Core_Description__c = 'Create and update MPI & OPID Relationships.');
    insert cs3;
        
        Id recordTypeIdPagAccount1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();

        //Create new pag account
        
        Account newPagAccount22 = new Account();//Account
        newPagAccount22.RecordTypeId = recordTypeIdPagAccount1;
        newPagAccount22.Name='Greg Thomas1';
        newPagAccount22.BillingCity='City1';
        newPagAccount22.BillingStreet='Street1';
        newPagAccount22.BillingCountry='India';
        newPagAccount22.BillingPostalCode='Postal code1';
        newPagAccount22.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount22;
        
        //Create new pag account
        
        Account newPagAccount33 = new Account();//Account
        newPagAccount33.RecordTypeId = recordTypeIdPagAccount1;
        newPagAccount33.Name='Greg Thomas2';
        newPagAccount33.BillingCity='City2';
        newPagAccount33.BillingStreet='Street2';
        newPagAccount33.BillingCountry='India';
        newPagAccount33.BillingPostalCode='Postal code2';
        newPagAccount33.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount33;
        
        //Create new pag account
        
        Account newPagAccount44 = new Account();//Account
        newPagAccount44.RecordTypeId = recordTypeIdPagAccount1;
        newPagAccount44.Name='Greg Thomas3';
        newPagAccount44.BillingCity='City3';
        newPagAccount44.BillingStreet='Street3';
        newPagAccount44.BillingCountry='India';
        newPagAccount44.BillingPostalCode='Postal code3';
        newPagAccount44.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount44;

        //Create new PMP_Company__c published copy

        PMP_Company__c company22 = new PMP_Company__c();
        company22.Name='company22';
        company22.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company22.PMP_Partner_Country_Txt__c = 'India';
        company22.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        company22.PMP_Is_Published_Ind__c = true;
        company22.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        insert company22;
        
        //Create new PMP_Company__c working copy

        PMP_Company__c company221 = new PMP_Company__c();
        company221.Name='company221';
        company221.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company221.PMP_Partner_Country_Txt__c = 'India';
        company221.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        company221.PMP_Is_Published_Ind__c = false;
        company221.PMP_Is_Working_Copy_Ind__c = true;
        insert company221;
        
        // Update PMP_company working copy and published copy ids
        company22.PMP_Working_Copy_Id__c = company221.Id;
        update company22;
        company221.PMP_Published_Copy_Id__c = company22.id;
        update company221;
        
        
        
        //Create new PMP_OPID_MPI_Rel__c record for newPagAccount22
                
        PMP_OPID_MPI_Rel__c NewOpid22 = new PMP_OPID_MPI_Rel__c();
        NewOpid22.PMP_Marketing_Profile_Id__c = company22.id;
        NewOpid22.PMP_One_Partner_ID__c = newPagAccount22.id;
        NewOpid22.Is_Active__c = true;
        insert NewOpid22;
        
        //Create new PMP_OPID_MPI_Rel__c record for newPagAccount33
                
        PMP_OPID_MPI_Rel__c NewOpid33 = new PMP_OPID_MPI_Rel__c();
        NewOpid33.PMP_Marketing_Profile_Id__c = company22.id;
        NewOpid33.PMP_One_Partner_ID__c = newPagAccount33.id;
        NewOpid33.Is_Active__c = true;
        insert NewOpid33;
        //Create new PMP_OPID_MPI_Rel__c record
                
        PMP_OPID_MPI_Rel__c NewOpid44 = new PMP_OPID_MPI_Rel__c();
        NewOpid44.PMP_Marketing_Profile_Id__c = company22.id;
        NewOpid44.PMP_One_Partner_ID__c = newPagAccount44.id;
        NewOpid44.Is_Active__c = true;
        insert NewOpid44;
        
        Lead l = new lead();
        l.RecordTypeId =recordTypeIdLead;
        l.lastname = 'test';
        l.company = 'abc';
        l.country = 'USA';
        l.CountryCode = 'USA';
        l.LeadSource = 'Event';
        l.Core_Lead_Status__c = 'New';
        l.Status = 'PRL';
        l.Core_Lead_State__c = 'Unclaimed';
        //l.Core_Partner_Lead_Owner__c = '';
        l.Core_MPI_Id__c = NewOpid44.PMP_Marketing_Profile_Id__c;
       // insert l;
        
    List<PMP_OPID_MPI_Rel__c> inActivatedJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
    List<PMP_OPID_MPI_Rel__c> ActivatedJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
    

    
    Test.startTest();
        NewOpid22.Is_Active__c = false;
        update NewOpid22;
        System.assertEquals(false, NewOpid22.Is_Active__c);
                
        inActivatedJunctionRecords.add(NewOpid22);
        ActivatedJunctionRecords.add(NewOpid44);
        ActivatedJunctionRecords.add(NewOpid33);
        PMP_OPID_MPI_Rel_TriggerHandler.updatePublicGroupSharingInactive(inActivatedJunctionRecords);
        PMP_OPID_MPI_Rel_TriggerHandler.shareBasedOnJunctionObjectInfoAccount(inActivatedJunctionRecords);
    Test.stopTest();
    
    }
    
    
    
    @isTest
    public static void DeletejunctionrecordTest(){
        {
         Test.startTest();
            Id recordTypeIdPagAccount2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

        //Create new pag account
        
        Account newPagAccount31 = new Account();//Account
        newPagAccount31.RecordTypeId = recordTypeIdPagAccount2;
        newPagAccount31.Name='Greg Thomas1';
        newPagAccount31.BillingCity='City1';
        newPagAccount31.BillingStreet='Street1';
        newPagAccount31.BillingCountry='India';
        newPagAccount31.BillingPostalCode='Postal code1';
        newPagAccount31.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount31;
            
        //Create new PMP_Company__c

        PMP_Company__c company32 = new PMP_Company__c();
        company32.Name='company32';
        company32.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company32.PMP_Partner_Country_Txt__c = 'India';
        company32.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        company32.PMP_Is_Published_Ind__c = true;
        company32.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        insert company32;
            
        //Create new PMP_OPID_MPI_Rel__c record for newPagAccount31
                
        PMP_OPID_MPI_Rel__c NewOpid30 = new PMP_OPID_MPI_Rel__c();
        NewOpid30.PMP_Marketing_Profile_Id__c = company32.id;
        NewOpid30.PMP_One_Partner_ID__c = newPagAccount31.id;
        NewOpid30.Is_Active__c = true;
        insert NewOpid30;
            
            try
            {
                Delete  NewOpid30;
            }
              catch(Exception e) 
           {
                System.assert(e.getMessage().contains('Junction record is active'), 'Junction record is active');
            }
        Test.stopTest(); 
    }
}
    
    @isTest
    public static void createSharingRecordsTest(){
        
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        PMP_Static_Constants__c p = new PMP_Static_Constants__c();
		p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
		p.PMP_Value__c = 'BNFTSMBA';
		insert p;

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
                
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
         Set<PMP_Company__c> Com = new Set<PMP_Company__c>();
        PMP_Company__c partner_wc = new PMP_Company__c(Name='workingPartner', 
                                                       PMP_Is_Working_Copy_Ind__c = true,
                                                       PMP_Is_Enabled_Lead_Gen_Nm__c = 'true',
                                                       PMP_Is_Lead_Gen_Limited_Nm__c = 'true',
                                                       PMP_Company_Lead_Gen_Language_Nm__c = 'English',
                                                       PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review);
        insert partner_wc;
         Com.add(partner_wc);
        
        PMP_Company__c Partner_pc = new PMP_Company__c(Name='pubPartner', 
                                                       PMP_Is_Published_Ind__c=true, 
                                                       PMP_Working_Copy_Id__c=partner_wc.Id,
                                                       PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Approved,
                                                       PMP_Is_Working_Copy_Ind__c = false);
        insert Partner_pc;
		partner_wc.PMP_Published_Copy_Id__c = Partner_pc.Id;
        update partner_wc;
        
        
        
       
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        company.PMP_Published_Copy_Id__c=Partner_pc.Id;
        company.PMP_Working_Copy_Id__c=partner_wc.Id;
        insert company;
        System.assertNotEquals(company, Null);

        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
       
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords = new Map<Id, Set<PMP_Company__c>>{company.Id=>Com};
        
        PMP_OPID_MPI_Rel_TriggerHandler.createSharingRecords(groupIdToCompanyInfoRecords);
    }
    
    @isTest
    public static void deleteSharingRecordsTest(){
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        //createUserRole();
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
     
        System.runAs(adminUser) {
        
          /**** Fetching Record TypeId from custom label******/
            String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> accts = new List<Account>();   
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'PMP_Companyinfosharing_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Partners');
        insert cs;
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                      Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        accts.add(partnerAccount1);
        Account partnerAccount2 = new Account(Name ='PartnerAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                      Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        accts.add(partnerAccount2);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Distributor',
                                            Core_Sales_Group_New__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',
                                            BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount1);
        Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount2);
        Database.insert(accts);
               
        List<Account> intelAccId1 = [SELECT ID,Name FROM Account where Name ='IntelAccount1'];
        List<Account> intelAccId2 = [SELECT ID,Name FROM Account where Name ='IntelAccount2'];
        List<Account> partnerAccountIdVar1 = [SELECT ID,Name FROM Account where Name ='PartnerAccount1'];
        List<Account> partnerAccountIdVar2 = [SELECT ID,Name FROM Account where Name ='PartnerAccount2'];
        
        List<Account>accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
        Database.update(accToUpdate);
        // System.debug('accToUpdate ='+accToUpdate);
    
        List<Core_Account_Group_Member__c>accGrpMembers = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
        accGroupMem1.Core_Partner_Account_Id__c =partnerAccountIdVar1[0].Id;
        accGroupMem1.Core_Intel_Account_Id__c =intelAccId1[0].Id;
        accGrpMembers.add(accGroupMem1);
    
        Core_Account_Group_Member__c accGroupMem2 = new Core_Account_Group_Member__c();
        accGroupMem2.Core_Partner_Account_Id__c =partnerAccountIdVar2[0].Id;
        accGroupMem2.Core_Intel_Account_Id__c =intelAccId2[0].Id;
        accGrpMembers.add(accGroupMem2);
        
        Database.insert(accGrpMembers);
       
        List<Contact> contacts = new List<Contact>();
        Contact contact1 = new Contact(firstname='Partner', MailingCountry='BRB',
                lastname='Contact1', accountId=intelAccId1[0].id,Email='dellco12341@dell.com');
        contacts.add(contact1);
        Contact contact2 = new Contact(firstname='Partner', MailingCountry='BRB',
                lastname='Contact2', accountId=intelAccId2[0].id,Email='dellco12342@dell.com');
        contacts.add(contact2); 
        Contact contact3 = new Contact(firstname='Partner',MailingCountry='BRB', 
                lastname='Contact3', accountId=intelAccId1[0].id,Email='dellco123421`@dell.com');
        contacts.add(contact3);     
        Database.insert(contacts);
    List<User> userList = new List<User>();
  
            UserRole userRole = [Select Id, PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            // system.debug('userRole ' + userRole);
            
            
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            
            User newUser1 = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser1'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb1@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact1.id
            );
            User newUser2 = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser2'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb2@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact2.id
            );
            
             User newUser3 = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser1'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb1@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact3.id
            );
            userList.add(newUser1);
            userList.add(newUser2);
            userList.add(newUser3);
            Database.insert(userList);
            List<Group> lstGrps = new List<Group>();
            
             Group grp1 = new Group(Name ='PMP_001',DeveloperName='PMP_001');
             Group grp2 = new Group(Name ='PMP_00112',DeveloperName='PMP_00112');
             lstGrps.add(grp1);
             lstGrps.add(grp2);
             Database.insert(lstGrps);
            
            List<GroupMember> lstGrpMem = new List<GroupMember>();
            GroupMember grpMem = new GroupMember();
            grpMem.UserOrGroupId = newUser1.Id;
            grpMem.GroupId =grp1.Id;     //pmpGroup.Id;
            lstGrpMem.add(grpMem);
            // System.debug('newUser1.Id ='+newUser1.Id);
            GroupMember grpMem2 = new GroupMember();
            grpMem2.UserOrGroupId = newUser3.Id;
            grpMem2.GroupId =grp1.Id;     //pmpGroup.Id;
            lstGrpMem.add(grpMem2);
            // System.debug('newUser3.Id ='+newUser1.Id);
            
            List<GroupMember> listGm = [Select Id,GroupId from GroupMember where GroupId=:grp1.Id];
            // System.debug('listGm ='+listGm);
            
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = newUser2.Id;
            grpMem1.GroupId =grp2.Id;     //pmpGroup.Id;
            lstGrpMem.add(grpMem1);
            Database.insert(lstGrpMem);
            // System.debug('userList = '+ userList);
    
            List<PMP_Company__c> compinfo= new List<PMP_Company__c>(); 
            
             PMP_Company__c newcompany1 = new PMP_Company__c(OwnerId=newUser1.Id, Name='companyinformationtest1',
                                                           PMP_Account_Industry__c='Agriculture',PMP_Is_Published_Ind__c=true,PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile);
            
            
            
            
             PMP_Company__c newcompany = new PMP_Company__c(Name='companyinformationtest',
                                                           PMP_Account_Industry__c='Agriculture',PMP_Is_Working_Copy_Ind__c=true,PMP_Is_Published_Ind__c=true);
            
            
            
             PMP_Company__c newcompany2 = new PMP_Company__c(Name='companyinformationtest2',
                                                           PMP_Account_Industry__c='Agriculture',PMP_Working_Copy_Id__c=newcompany.Id,PMP_Is_Published_Ind__c=true,PMP_Is_Working_Copy_Ind__c=true);
           
            
            compinfo.add(newcompany);
            compinfo.add(newcompany1);
            compinfo.add(newcompany2);
            Database.insert(compinfo);
            
            
            
            
            PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
            jun1.PMP_One_Partner_ID__c= partnerAccountIdVar1[0].Id;
            jun1.PMP_Marketing_Profile_Id__c= newcompany1.Id;
            jun1.Is_Active__c=true;     
            insert jun1;
            
           /* PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
            jun.PMP_One_Partner_ID__c= partnerAccountIdVar2[0].Id;
            jun.PMP_Marketing_Profile_Id__c= newcompany.Id;
            jun.Is_Active__c=true;     
            insert jun;
            
            PMP_OPID_MPI_Rel__c jun2= new PMP_OPID_MPI_Rel__c();
            jun2.PMP_One_Partner_ID__c= partnerAccountIdVar1[0].Id;
            jun2.PMP_Marketing_Profile_Id__c= newcompany2.Id;
            jun2.Is_Active__c=true;     
            insert jun2;
            */
            List<PMP_Company__Share> partCompanyInfoShareList = new List<PMP_Company__Share>();
            PMP_Company__Share partCompanyInfoShare = new PMP_Company__Share();
                        partCompanyInfoShare.AccessLevel  = 'Edit';
                        partCompanyInfoShare.UserOrGroupId  = grp1.Id;
                        partCompanyInfoShare.ParentId = newcompany.Id;
                        partCompanyInfoShareList.add(partCompanyInfoShare);
            
            PMP_Company__Share partCompanyInfoShare1 = new PMP_Company__Share();
                        partCompanyInfoShare1.AccessLevel  = 'Read';
                        partCompanyInfoShare1.UserOrGroupId  = grp1.Id;
                        partCompanyInfoShare1.ParentId = newcompany2.Id;
                        partCompanyInfoShareList.add(partCompanyInfoShare1);
            Database.insert(partCompanyInfoShareList);

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Partner_Admin'];
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = newUser3.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            //Updating Account on the Company Info
            newcompany1.OwnerId = newUser3.Id;//newUser2.Id
            
            Test.startTest();
            Database.update(newcompany1);
            Test.stopTest();
            
            Map<Id, List<PMP_Company__c>> groupIdToCompanyInfoRecords = new Map<Id, List<PMP_Company__c>>{newcompany2.Id=>compinfo};
            
           PMP_OPID_MPI_Rel_TriggerHandler.deleteSharingRecords(groupIdToCompanyInfoRecords);
            
        }
        
    }
    
    
   
}