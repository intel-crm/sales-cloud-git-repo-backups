/**************************************************************************************
Apex Class Name:  Core_ContactEntitlementHandler_Test
Version     : 1.0 
Created Date: 20 Jan 2017
Description    : This class is Test class for Core_ContactEntitlementHandler
*************************************************************************************/
@isTest
public class Core_ContactEntitlementHandler_Test{
    
    static testMethod void conEntitlements(){
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
     
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        
       
       system.runas(itAdminUser){
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id);
        insert testContact;
        Test.startTest();
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
       Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false,Core_Data_Loaded__c=true);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
        
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
        //Core_Contact_Entitlement__c conent4 = new Core_Contact_Entitlement__c(id = ce4.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Employee, Core_Selected__c=true);
        //Core_Contact_Entitlement__c conent5 = new Core_Contact_Entitlement__c(id = ce5.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Lead_Development_Representative, Core_Selected__c=true);
        //Core_Contact_Entitlement__c conent6 = new Core_Contact_Entitlement__c(id = ce6.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Marketing_specialist, Core_Selected__c=true);
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
        //oldlstentitle.add(conent4);
        //oldlstentitle.add(conent5);
        //oldlstentitle.add(conent6);
       
        update  oldlstentitle;
        
           Test.stopTest();
         system.debug('oldlstentitle==='+oldlstentitle);
        
    }
}

 static testMethod void testconEntitlements(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        
       
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.runas(itAdminUser){
       
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = true, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id);
        insert testContact;
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
       
        update  oldlstentitle;
         system.debug('oldlstentitle==='+oldlstentitle);
      }
    }
    
    static testMethod void conEntitlementsnegative(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
       
        
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
         system.runas(itAdminUser){
          
        Core_IPS_Labels__c cm  = new Core_IPS_Labels__c();
        cm.Name = 'IPS Standard Entitlement';
        cm.Value__c  = 'IPS Standard Entitlement';
        insert cm;
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= itAdminUser.Id);
        insert testContact;
        
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;   
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='ODM/Price Mask', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Price Masking dup',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Return Services Request', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Return Services Request',Core_IsActive__c=true); 
        insert entitle2;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        newlstentitle.add(ce2);
        newlstentitle.add(ce3);
        insert newlstentitle;
        system.debug('newlstentitle==='+newlstentitle);

        List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
        Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
        
        oldlstentitle.add(conent1);
        oldlstentitle.add(conent2);
        oldlstentitle.add(conent3);
       
        update  oldlstentitle;
         system.debug('oldlstentitle==='+oldlstentitle);
      }
    }
    
  /*  @isTest
    public static void validateLDRForPAGTest()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
         Account a = new Account();
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        insert a;
        
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='Walmart';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
       // acc.Core_Is_PAG_Member_Ind__c = false;
        insert acc;
        
        Account acct = PRM_TestUtility.getAccount();
        acct.RecordTypeId = accountRecordTypeIntel;
        acct.Name='Tesco';
        acct.Core_Account_Type__c ='Distributor';
        acct.Industry='Agriculture';
        acct.BillingCity='New Delhi';
        acct.BillingCountryCode='IND';
        acct.BillingStreet='4th Floor,New Road';
        acct.BillingPostalCode='110037';
        acct.BillingStateCode='KA';
        //acct.Core_Is_PAG_Member_Ind__c = false;
        insert acct;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = acc.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
       // agm.Core_Is_PAG_Member_Ind__c = true;
        insert agm;
        
         Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c();
        agm1.Core_Partner_Account_Id__c = a.Id;
        agm1.Core_Intel_Account_Id__c = acct.Id;
        agm1.Core_MDA_Ind__c = false;
        agm1.Core_Inactive_Ind__c = false;
       // agm1.Core_Is_PAG_Member_Ind__c = true;
        insert agm1;
        
        
         Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cnt1 = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=acc.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456');
        insert cnt1;
         
        Contact cnt2 = new Contact(FirstName='Test',LastName='Contact2',Email='testcontact2@mailinator.com',AccountId=acct.Id,RecordTypeId=IntelContRecTypeId,
                                 MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456');
        insert cnt2;
        
        List<Core_ERPM_Engagement__c> erp1 = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee11 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
       
         Insert ee11 ;
        
       // List<Core_Entitlement__c> ent1 = new List<Core_Entitlement__c>();
       // Core_Entitlement__c de11 = new Core_Entitlement__c(Name='Lead Development Representative',Core_Display_Name__c='Lead Development Representative',Core_ERPM_Engagement_Id__c=ee11.id);
         
         //Insert de11 ;
        
            
    
        Core_Contact_Entitlement__c ldrContactEntitlement = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cnt1.Id,Core_Entitlement_Id__c =Label.LDRRole, Core_Selected__c=true);
         
         Insert ldrContactEntitlement ;
        
       Test.startTest();
        List<Core_Contact_Entitlement__c> ldrunassignedentitlementList=[Select Core_Selected__c from  Core_Contact_Entitlement__c where Core_Contact_Id__c=:cnt1.Id];
         for(Core_Contact_Entitlement__c ldrunassignedentitlement:ldrunassignedentitlementList)
         {
        	ldrunassignedentitlement.Core_Selected__c=false;
         }
        update ldrunassignedentitlementList;
       Test.stopTest();
        
    } */
    
    @isTest
public static void  partnerAccGroupMemtestMethod1 ()
{ 
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id; 
        List<Account> accts1 = new List<Account>();        
        Account partnerAccount1 = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=partnerAccRecTypeId);
        System.debug('partnerAccount ='+partnerAccount1.IsPartner);
        accts1.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts1.add(intelAccount1);
        Insert accts1 ;
               
        List<Account> intelAccId1 = [SELECT ID,Name FROM Account where Name ='IntelAccount'];
        List<Account> partnerAccountIdVar1 = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
        List<Account>accToUpdate1 = new List<Account>();
        For(Account acc1:accts1){
            acc1.IsPartner = true;
            accToUpdate1.add(acc1);
        }
        Update accToUpdate1 ;
        System.debug('accToUpdate ='+accToUpdate1);
        List<Core_Account_Group_Member__c> accGroupMemlist1 = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c  accGroupMem1= new Core_Account_Group_Member__c(Core_Partner_Account_Id__c =partnerAccountIdVar1[0].Id,Core_Intel_Account_Id__c =intelAccId1[0].Id);
        accGroupMemlist1.add(accGroupMem1);
        Insert accGroupMemlist1 ;
        
        List<Core_Account_Group_Member__c> gupdate1=new List<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> gl1=[Select Core_MDA_Ind__c from Core_Account_Group_Member__c];
        For(Core_Account_Group_Member__c g1 : gl1)
        {
           g1.Core_MDA_Ind__c=False;
           gupdate1.add(g1);
           }
           
       
        Contact contact11 = new Contact(firstname='Partner', 
                lastname='Contact1', accountId=intelAccId1[0].id,Email='dellco1234@dell.com');
                //for update
                
               
       Insert contact11;
        
        
        //for update 
        List<Contact> ccupdate1=new List<Contact>();
        List<Contact> cl1=[Select firstname,lastname from Contact];
        For(Contact c1 : cl1)
        {
           c1.firstname='Partner1';
           ccupdate1.add(c1);
           }
           Update ccupdate1 ;
           
        Test.startTest();           
        List<Core_ERPM_Engagement__c> erp1 = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee11 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
       
         Insert ee11 ;
        
        List<Core_Entitlement__c> ent1 = new List<Core_Entitlement__c>();
        Core_Entitlement__c de11 = new Core_Entitlement__c(Name='Partner Admin',Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=ee11.id);
         
         Insert de11 ;
          
         List<Core_Entitlement__c> cnupdate1=new List<Core_Entitlement__c>();
         List<Core_Entitlement__c> cn1=[Select Core_Display_Name__c from  Core_Entitlement__c];
         for(Core_Entitlement__c cn11:cn1)
         {
           cn11.Core_Display_Name__c ='Employee';
           cnupdate1.add(cn11);
           }
           Update cnupdate1 ;
            
           
           
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact11.Id,Core_Entitlement_Id__c = de11.id, Core_Selected__c=true);
         newlstentitle.add(ce1);
         Insert newlstentitle ;
           
         
         List<Core_Contact_Entitlement__c> ccnupdate1=new List<Core_Contact_Entitlement__c>();
         List<Core_Contact_Entitlement__c> ccn1=[Select Core_Selected__c from  Core_Contact_Entitlement__c];
         for(Core_Contact_Entitlement__c ccn11:ccn1)
         {
           ccn11.Core_Selected__c =true;
           ccnupdate1.add(ccn11);
           }
          Update ccnupdate1 ;
         
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        System.debug('currentUser ='+currentUser);
        
        System.runAs (currentUser) {
            UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User newUser = new User(
                UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact11.id
            );
            userList.add(newUser);
             //insert userList ;
            
        }
        System.debug('userList ='+userList);
        
        try{
        
            Update gupdate1 ;
            
        Test.stopTest();
                      

        }Catch (DMLException e){

           System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
            

    

}
@isTest
public static void  partnerAccGroupMemtestMethod ()
{ 

    
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> accts = new List<Account>();        
        Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=partnerAccRecTypeId);
        System.debug('partnerAccount ='+partnerAccount.IsPartner);
        accts.add(partnerAccount);
        Account intelAccount = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount);
        Insert accts ;
               
        List<Account> intelAccId = [SELECT ID,Name FROM Account where Name ='IntelAccount'];
        List<Account> partnerAccountIdVar = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
        List<Account>accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
        Update accToUpdate ;
        System.debug('accToUpdate ='+accToUpdate);
        List<Core_Account_Group_Member__c> accGroupMemlist = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c  accGroupMem= new Core_Account_Group_Member__c(Core_Partner_Account_Id__c =partnerAccountIdVar[0].Id,Core_Intel_Account_Id__c =intelAccId[0].Id);
        accGroupMemlist.add(accGroupMem);
        Insert accGroupMemlist ;
        
        List<Core_Account_Group_Member__c> gupdate=new List<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> gl=[Select Core_MDA_Ind__c from Core_Account_Group_Member__c];
        For(Core_Account_Group_Member__c g : gl)
        {
           g.Core_MDA_Ind__c=False;
           gupdate.add(g);
           }
           
       Update gupdate ;
        Contact contact1 = new Contact(firstname='Partner', 
                lastname='Contact1', accountId=intelAccId[0].id,Email='dellco1234@dell.com');
                //for update
                
               
       Insert contact1;
        
        
        //for update 
        List<Contact> ccupdate=new List<Contact>();
        List<Contact> cl=[Select firstname,lastname from Contact];
        For(Contact c : cl)
        {
           c.firstname='Partner1';
           ccupdate.add(c);
           }
           Update ccupdate ;
           
          Test.startTest(); 
        List<Core_ERPM_Engagement__c> erp = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee1 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
       
         Insert ee1 ;
        
        List<Core_Entitlement__c> ent = new List<Core_Entitlement__c>();
        Core_Entitlement__c de1 = new Core_Entitlement__c(Name='Partner Admin',Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=ee1.id);
         
         Insert de1 ;
          
         List<Core_Entitlement__c> cnupdate=new List<Core_Entitlement__c>();
         List<Core_Entitlement__c> cn=[Select Core_Display_Name__c from  Core_Entitlement__c];
         for(Core_Entitlement__c cn1:cn)
         {
           cn1.Core_Display_Name__c ='Employee';
           cnupdate.add(cn1);
           }
           Update cnupdate ;
            
           
           
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact1.Id,Core_Entitlement_Id__c = de1.id, Core_Selected__c=true);
         newlstentitle.add(ce1);
         Insert newlstentitle ;
           
         
         List<Core_Contact_Entitlement__c> ccnupdate=new List<Core_Contact_Entitlement__c>();
         List<Core_Contact_Entitlement__c> ccn=[Select Core_Selected__c from  Core_Contact_Entitlement__c];
         for(Core_Contact_Entitlement__c ccn1:ccn)
         {
           ccn1.Core_Selected__c =true;
           ccnupdate.add(ccn1);
           }
          Update ccnupdate ;
           
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        System.debug('currentUser ='+currentUser);
        
        System.runAs (currentUser) {
            //UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Partner Partner User');
            insert ur;
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User newUser = new User(
                UserRoleId = ur.Id,
                profileId = profile.id, 
                username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact1.id
            );
            userList.add(newUser);
             //insert userList ;
            
        }
        System.debug('userList ='+userList);
        
        try{
        
            

            delete newlstentitle ; 
             Test.stopTest();

        }Catch (DMLException e){

           System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
            

    

}
}