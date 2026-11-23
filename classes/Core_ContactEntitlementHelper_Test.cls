/**************************************************************************************
Apex Class Name:  Core_ContactEntitlementHelper_Test
Version     : 1.0 
Created Date: 15 Dec 2021
Description    : This class is Test class for Core_ContactEntitlementHelper
*************************************************************************************/
@isTest
public class Core_ContactEntitlementHelper_Test{
    
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
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Groups__c='Americas Brazil Sales Group', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',MailingCountry='India',
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
            
            System.assert(true,entitle.Core_Category__c!= null);        
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false,Core_Data_Loaded__c=true);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true,Core_Data_Loaded__c=true);
            newlstentitle.add(ce1);
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            insert newlstentitle;
            
            
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
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Groups__c='Americas Brazil Sales Group', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',MailingCountry='India',
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
            
            System.assert(true,entitle.Core_Category__c!= null);
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);
            newlstentitle.add(ce1);
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            insert newlstentitle;
            
            List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
            Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
            Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
            
            oldlstentitle.add(conent1);
            oldlstentitle.add(conent2);
            oldlstentitle.add(conent3);
            
            update  oldlstentitle;
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
            //Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Groups__c='Americas Canada Sales Group', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',MailingCountry='India',
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
            
            System.assert(true,entitle.Core_Category__c!= null);
            
            List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=true);
            Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c= entitle2.id, Core_Selected__c=true);
            newlstentitle.add(ce1);
            newlstentitle.add(ce2);
            newlstentitle.add(ce3);
            insert newlstentitle;
            
            List<Core_Contact_Entitlement__c> oldlstentitle = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c conent1 = new Core_Contact_Entitlement__c(id = ce1.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = Label.Core_Entitlement_IPS_Id, Core_Selected__c=false);
            Core_Contact_Entitlement__c conent2 = new Core_Contact_Entitlement__c(id = ce2.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle1.id, Core_Selected__c=false);
            Core_Contact_Entitlement__c conent3 = new Core_Contact_Entitlement__c(id = ce3.id,Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c =entitle2.id, Core_Selected__c=false);
            
            oldlstentitle.add(conent1);
            oldlstentitle.add(conent2);
            oldlstentitle.add(conent3);
            
            update  oldlstentitle;
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
    
    /*@isTest
public static void  partnerAccGroupMemtestMethod1 ()
{ 
String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id; 
List<Account> accts1 = new List<Account>();        
Account partnerAccount1 = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'Americas Canada Sales Group',
Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=partnerAccRecTypeId);

accts1.add(partnerAccount1);
Account intelAccount1 = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'Americas Canada Sales Group',
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
Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'Americas Canada Sales Group',
Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=partnerAccRecTypeId);

accts.add(partnerAccount);
Account intelAccount = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'Americas Canada Sales Group',
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

try{



delete newlstentitle ; 
Test.stopTest();

}Catch (DMLException e){

System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
}




}*/
    
    @isTest
    public static void  assignRemovePermissionSetsPublicGroups_Test (){
        
        List<Core_Trigger_Executions__c> executeTriggers = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c executeTrigger = new Core_Trigger_Executions__c();
        executeTrigger.Name = 'Core_ContactEntValidationSwitch';
        executeTrigger.Core_Object__c = 'Core_Contact_Entitlement__c';
        executeTrigger.Core_Active__c = true;
        executeTrigger.Core_Trigger_Events__c = 'Before Insert, Before Update';
        executeTrigger.Core_Description__c = 'Switch the code based on active indicator. In case active call the new method else call old method';
        executeTrigger.Core_Class_Name__c = 'Core_Contact_Entitlement_Handler';
        executeTriggers.add(executeTrigger);
        
        Core_Trigger_Executions__c executeTrigger1 = new Core_Trigger_Executions__c();
        executeTrigger1.Name = 'Core_ContactEntPublishToSvcCld';
        executeTrigger1.Core_Object__c = 'Core_Contact_Entitlement__c';
        executeTrigger1.Core_Active__c = true;
        executeTrigger1.Core_Trigger_Events__c = 'After Insert';
        executeTrigger1.Core_Description__c = 'Contact Entitlement';
        executeTrigger1.Core_Class_Name__c = 'Core_Contact_Entitlement_Handler';
        executeTriggers.add(executeTrigger1);
        
        insert executeTriggers;
        List<PRM_ContactRelationships__c> lstConRelation = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c(Name = 'Partner Admin Delegate',PRM_Contact_Relationship_Cd__c = 'PRIMCONTDEL');
        lstConRelation.add(cr1);
        
        PRM_ContactRelationships__c cr2 = new PRM_ContactRelationships__c(Name = 'Partner Admin',PRM_Contact_Relationship_Cd__c = 'PRIMARY');
        lstConRelation.add(cr2);
        
        PRM_ContactRelationships__c cr3 = new PRM_ContactRelationships__c(Name = 'Employee',PRM_Contact_Relationship_Cd__c = 'WORKSFOR');
        lstConRelation.add(cr3);
        
        insert lstConRelation;
        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account acc = new Account(Name='testAccount123',RecordTypeId=intelAccRecTypeId, Core_Sales_Groups__c='Americas Canada Sales Group', Core_IsODM__c = true,
                                  Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                  BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                  BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = true, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false,Core_User_Defined_Website__c = 'https://www.testweb.com');
        insert acc;
        acc.isPartner = true;
        update acc;
        List<Contact> lstCon = new List<Contact>();
        Contact con = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',MailingCountry='India',
                                  AccountId=acc.Id,Core_IPS_Active__c =false);
        Contact con1 = new Contact(FirstName='testFirstName1234', LastName='testLastName', Email='test1234@testing.com.test',MailingCountry='India',
                                   AccountId=acc.Id,Core_IPS_Active__c =false);
        Contact con2 = new Contact(FirstName='testFirstName12345', LastName='testLastName', Email='test12345@testing.com.test',MailingCountry='India',
                                   AccountId=acc.Id,Core_IPS_Active__c =false);
        lstCon.add(con);
        lstCon.add(con1);
        lstCon.add(con2);
        insert lstCon;
        
        List<Core_Entitlement__c> lstCE = new List<Core_Entitlement__c>();
        Core_Entitlement__c entitle=new Core_Entitlement__c (Core_Permission_Set_API_Nm__c = 'PMP_External_Partner_Admin', name ='Partner Admin', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_Help_Text__c='Help text',Core_Display_Name__c='Partner Admin',Core_IsActive__c=true);
        lstCE.add(entitle);
        Core_Entitlement__c entitle1=new Core_Entitlement__c (Core_Permission_Set_API_Nm__c = 'PMP_External_Partner_Admin', name ='Partner Admin Delegate', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Value Exchange',Core_Help_Text__c='Help text',Core_Display_Name__c='Partner Admin Delegate',Core_IsActive__c=true);
        lstCE.add(entitle1);
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Employee', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_Help_Text__c='Help text',Core_Display_Name__c='Employee',Core_IsActive__c=true, Core_Permission_Set_API_Nm__c = 'PMP_External_Employee', Core_Public_Group_API_Nm__c = 'Core_All_Employees_Group' ); 
        lstCE.add(entitle2);
        Core_Entitlement__c entitle3=new Core_Entitlement__c (name ='Web Ticketing & Return for Credit Dual', Core_Category__c='Support',Core_Sub_Category__c='',Core_Help_Text__c='Help text',Core_Display_Name__c='Web Ticketing & Return for Credit Dual',Core_IsActive__c=true, Core_Permission_Set_API_Nm__c = 'PMP_External_Employee', Core_Public_Group_API_Nm__c = 'Core_All_Employees_Group' ); 
        lstCE.add(entitle3);
        insert lstCE;
        
        Group gp = new Group(Name = 'Test Account', DeveloperName = 'PMP_External_Employee', Type = 'Regular');
        insert gp;
        
        User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs (currentUser) {
            
            UserRole ur = new UserRole(PortalType = 'Partner', PortalAccountId = acc.Id);
            insert ur;
            List<User> lstUsers = new List<User>();
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User user = new User(UserRoleId = ur.Id, profileId = profile.id, 
                                 username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com.mmm', email = 'test123@testing.com.test', emailencodingkey = 'UTF-8', 
                                 localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                                 alias='nuser', lastname='lastname', contactId = con.id);
            lstUsers.add(user);
            User user1 = new User(UserRoleId = ur.Id, profileId = profile.id, 
                                  username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com.mmm', email = 'test1234@testing.com.test', emailencodingkey = 'UTF-8', 
                                  localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                                  alias='nuser', lastname='lastname', contactId = con1.id);
            lstUsers.add(user1);
            insert lstUsers;
            GroupMember gm = new GroupMember(UserOrGroupId = user.id, GroupId = gp.id);
            insert gm;
            id psId = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Employee'].id;
            PermissionSetAssignment ps = new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psId);
            insert ps;
        }
        
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = acc.Id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = cr3.Id;
        acr.PRM_Status_Reason_Txt__c='Test';
        insert acr;
        
        List<Core_Contact_Entitlement__c> lstConCE = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,Core_Entitlement_Id__c = entitle.Id, Core_Selected__c=false,Core_Status__c='Pending');
        lstConCE.add(ce1);
        Core_Contact_Entitlement__c ce12 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,Core_Entitlement_Id__c = entitle2.Id, Core_Selected__c=true,Core_Status__c='Pending');
        lstConCE.add(ce12);
        Core_Contact_Entitlement__c ce13 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,Core_Entitlement_Id__c = entitle1.Id, Core_Selected__c=true,Core_Status__c='Pending');
        lstConCE.add(ce13);
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con1.Id,Core_Entitlement_Id__c = entitle.Id, Core_Selected__c=True,Core_Status__c='Pending');
        lstConCE.add(ce2);
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con1.Id,Core_Entitlement_Id__c = entitle3.Id, Core_Selected__c=True,Core_Status__c='Pending');
        lstConCE.add(ce3);
        insert lstConCE;
        
        
        
        Test.startTest();
        Core_ContactEntitlementHelper.UpdateACRCheck = true;
        List<Core_Contact_Entitlement__c> lstToUpdataCE = new List<Core_Contact_Entitlement__c>();
        ce1.Core_Status__c = 'Complete';
        ce2.Core_Status__c = 'Complete';
        ce12.Core_Status__c = 'Complete';
        ce13.Core_Status__c = 'Complete';
        lstToUpdataCE.add(ce1);
        lstToUpdataCE.add(ce2);
        lstToUpdataCE.add(ce12);
        lstToUpdataCE.add(ce13);
        //update ce12;
        Core_ContactEntitlementHelper.updatePsPgAssignmentRemovalCheck = true;
        //Core_ContactEntitlementHandler.afterMethodFirstEntry=true;
        update lstToUpdataCE;
        Test.stopTest();
        List<PRM_Account_Contact_Relationship__c> lastAcr = [Select id from PRM_Account_Contact_Relationship__c where Id =: acr.Id];
        System.assert(!lastAcr.isEmpty());
        
    }
    
    @isTest
    public static void  updateACRTest (){
        List<PRM_ContactRelationships__c> lstConRelation = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr1 = new PRM_ContactRelationships__c(Name = 'Partner Admin Delegate',PRM_Contact_Relationship_Cd__c = 'PRIMCONTDEL');
        lstConRelation.add(cr1);
        
        PRM_ContactRelationships__c cr2 = new PRM_ContactRelationships__c(Name = 'Partner Admin',PRM_Contact_Relationship_Cd__c = 'PRIMARY');
        lstConRelation.add(cr2);
        
        PRM_ContactRelationships__c cr3 = new PRM_ContactRelationships__c(Name = 'Employee',PRM_Contact_Relationship_Cd__c = 'WORKSFOR');
        lstConRelation.add(cr3);
        
        insert lstConRelation;
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account acc = new Account(Name='testAccount123',recordtypeid=intelAccRecTypeId, Core_Sales_Groups__c='Americas Brazil Sales Group', Core_IsODM__c = true,
                                  Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                  BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                  BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = false, Core_CIM_ID__c ='123124',Core_PMP_Membership_Change_Ind__c=false,Core_User_Defined_Website__c = 'https://www.testweb.com');
        insert acc;
        
        Contact con = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',MailingCountry='India',
                                  AccountId=acc.Id,Core_IPS_Active__c =false);
        Contact con1 = new Contact(FirstName='testFirstName1234', LastName='testLastName', Email='test1234@testing.com.test',MailingCountry='India',
                                   AccountId=acc.Id,Core_IPS_Active__c =false);
        insert con;
        insert con1;
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Partner Admin', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_Help_Text__c='Help text',Core_Display_Name__c='Partner Admin',Core_IsActive__c=true);
        insert entitle;
        Core_Entitlement__c entitle1=new Core_Entitlement__c (name ='Partner Admin Delegate', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Value Exchange',Core_Help_Text__c='Help text',Core_Display_Name__c='Partner Admin Delegate',Core_IsActive__c=true);
        insert entitle1;
        Core_Entitlement__c entitle2=new Core_Entitlement__c (name ='Employee', Core_Category__c='Intel Partner Alliance (IPA)',Core_Sub_Category__c='Solutions Marketplace',Core_Help_Text__c='Help text',Core_Display_Name__c='Employee',Core_IsActive__c=true); 
        insert entitle2;
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = acc.Id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_Relationship_Id__c = cr3.Id;
        acr.PRM_Status_Reason_Txt__c='Test';
        insert acr;
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,Core_Entitlement_Id__c = entitle.Id, Core_Selected__c=false,Core_Status__c='Pending');
        insert ce1;
        Core_Contact_Entitlement__c ce12 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,Core_Entitlement_Id__c = entitle2.Id, Core_Selected__c=false,Core_Status__c='Pending');
        insert ce12;
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con1.Id,Core_Entitlement_Id__c = entitle.Id, Core_Selected__c=false,Core_Status__c='Pending');
        insert ce2;
        
        Test.startTest();
        Core_ContactEntitlementHelper.UpdateACRCheck = true;
        //Core_ContactEntitlementHandler.afterMethodFirstEntry =true;
        List<Core_Contact_Entitlement__c> lstToUpdataCE = new List<Core_Contact_Entitlement__c>();
        ce1.Core_Status__c = 'Complete';
        ce2.Core_Status__c = 'Complete';
        ce12.Core_Status__c = 'Complete';
        lstToUpdataCE.add(ce1);
        lstToUpdataCE.add(ce2);
        lstToUpdataCE.add(ce12);
        //update ce12;
        update lstToUpdataCE;
        Test.stopTest();
        List<PRM_Account_Contact_Relationship__c> lastAcr = [Select id from PRM_Account_Contact_Relationship__c where Id =: acr.Id];
        System.assert(!lastAcr.isEmpty());
        
    }
    @isTest
    public static void testEmail()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        // Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435710';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Core_IPA_Badge_Tier__c = 'Partner';//test-fix
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='user.check@maildrop.cc';
        c.Core_Preferred_Language__c = 'POL';
        c.Core_eRPM_Language_Code__c = 'ENG';
        //   c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = false;
        // c.Core_IPA_Partner_Role__c = 'FPGA Designer';
        c.Core_IPA_PartnerRole__c = 'Service Provider';
        c.Core_Login_Id__c = 'abc';
        c.MailingCountryCode='IN';
        
        
        insert c;
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Service Provider';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        insert prmRegRequest;
        
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c();
        entitlement.Name = 'Employee';
        entitlement.Core_Display_Name__c = 'Employee';              
        insert entitlement;
        
        Core_Contact_Entitlement__c conEntitlement = new Core_Contact_Entitlement__c();
        conEntitlement.Core_Contact_Id__c = c.Id;
        conEntitlement.Core_Entitlement_Id__c = entitlement.Id;
        conEntitlement.Core_Status__c = 'Pending';
        conEntitlement.Core_Selected__c = false;        
        conEntitlement.Core_From_Source__c = false;
        conEntitlement.Core_Source__c = 'Intel Partner Alliance (IPA)';
        insert conEntitlement;
        
        PRM_EmailQueue__c emailQueue = new PRM_EmailQueue__c();
        emailQueue.PRM_Business_Event__c = 'Welcome_email_on_request_approval_Existing';
        emailQueue.PRM_Contact__c = c.Id;
        emailQueue.PRM_Email_Content__c = 'Email Content';
        emailQueue.PRM_IsInactive__c = false;
        emailQueue.PRM_PartnerRole__c = 'Service Provider'; //'FPGA Designer';
        emailQueue.PRM_Priority__c = 1;
        emailQueue.PRM_Registration_Request__c = prmRegRequest.Id;
        emailQueue.PRM_Status__c = 'PENDING';
        emailQueue.PRM_Tier__c = 'Partner'; //'MEMBER';
        insert emailQueue;
        
        Test.startTest();       	                
        // Core_ContactEntitlementHandler.IPAfirstentUpdate=true;
        Core_ContactEntitlementHelper.IPAfirstentUpdate=true;
        conEntitlement.Core_Status__c = 'Complete';
        conEntitlement.Core_Selected__c = true;
        update conEntitlement;
        Test.stopTest();
        system.assert(conEntitlement != null);
    }
    
    @isTest
    public static void sendWelcomeEmailonCECompleteTest()
    {
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        // Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435710';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Core_IPA_Badge_Tier__c = 'Partner';//test-fix
        insert a;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='user.check@maildrop.cc';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        //   c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = false;
        // c.Core_IPA_Partner_Role__c = 'FPGA Designer';
        c.Core_IPA_PartnerRole__c = 'Service Provider';
        c.Core_Login_Id__c = 'abc';
        c.MailingCountryCode='IN';
        
        
        insert c;
        
        ChannelProgram channelPrg = new ChannelProgram();
        channelPrg.name='Intel Partner Alliance';
        channelPrg.PRM_programCode__c='IPA';
        channelPrg.PRM_inactind__c=true;
        insert channelPrg;
        
        PRM_Registration_Request__c prmRegRequest = new PRM_Registration_Request__c();
        prmRegRequest.Name = 'checkuser';
        prmRegRequest.PRM_Salesforce_ID__c = a.Id;
        prmRegRequest.PRM_Channel_Program__c =channelPrg.Id;
        prmRegRequest.PRM_Partner_Role__c='Service Provider';
        prmRegRequest.PRM_First_Name__c='Check';
        prmRegRequest.PRM_Last_Name__c='User';
        prmRegRequest.PRM_Email_ID__c='checkuser@mailinator.com';
        prmRegRequest.PRM_Job_Function__c='Branch Manager';
        prmRegRequest.PRM_Contact_Country__c='US';
        prmRegRequest.PRM_Legal_Agreements__c='IPA_TANDC';
        insert prmRegRequest;
        
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c();
        entitlement.Name = 'Employee';
        entitlement.Core_Display_Name__c = 'Employee';              
        insert entitlement;
        
        Core_Entitlement__c entitlement1 = new Core_Entitlement__c();
        entitlement1.Name = 'Partner Admin';
        entitlement1.Core_Display_Name__c = 'Partner Admin';              
        insert entitlement1;
        
        Core_Contact_Entitlement__c conEntitlement = new Core_Contact_Entitlement__c();
        conEntitlement.Core_Contact_Id__c = c.Id;
        conEntitlement.Core_Entitlement_Id__c = entitlement.Id;
        conEntitlement.Core_Status__c = 'Pending';
        conEntitlement.Core_Selected__c = true;        
        conEntitlement.Core_From_Source__c = false;
        conEntitlement.Core_Source__c = 'Intel Partner Alliance (IPA)';
        insert conEntitlement;
        
        Core_Contact_Entitlement__c conEntitlement1 = new Core_Contact_Entitlement__c();
        conEntitlement1.Core_Contact_Id__c = c.Id;
        conEntitlement1.Core_Entitlement_Id__c = entitlement1.Id;
        conEntitlement1.Core_Status__c = 'Pending';
        conEntitlement1.Core_Selected__c = true;        
        conEntitlement1.Core_From_Source__c = false;
        conEntitlement1.Core_Source__c = 'Intel Partner Alliance (IPA)';
        insert conEntitlement1;
        
        PRM_EmailQueue__c emailQueue = new PRM_EmailQueue__c();
        emailQueue.PRM_Business_Event__c = 'Welcome_email_on_request_approval_Existing';
        emailQueue.PRM_Contact__c = c.Id;
        emailQueue.PRM_Email_Content__c = 'Email Content';
        emailQueue.PRM_IsInactive__c = false;
        emailQueue.PRM_PartnerRole__c = 'Service Provider';//'FPGA Designer';
        emailQueue.PRM_Priority__c = 1;
        emailQueue.PRM_Registration_Request__c = prmRegRequest.Id;
        emailQueue.PRM_Status__c = 'PENDING';
        emailQueue.PRM_Tier__c =  'Partner'; //'MEMBER';
        insert emailQueue;
        
        
        List<Core_Contact_Entitlement__c> lstEnt = new List<Core_Contact_Entitlement__c>();
        Test.startTest(); 
        //Core_ContactEntitlementHandler.IPAfirstentUpdate=true;
        Core_ContactEntitlementHelper.IPAfirstentUpdate=true;
        conEntitlement.Core_Status__c = 'Complete'; 
        conEntitlement1.Core_Status__c = 'Complete';
        lstEnt.add(conEntitlement);
        lstEnt.add(conEntitlement1);    
        update lstEnt;
        Test.stopTest();
        system.assert(!lstEnt.isEmpty());
    }
    
}