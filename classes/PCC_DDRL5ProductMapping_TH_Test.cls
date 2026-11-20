/***********************************************************************************************************************************************
Apex Class Name:  PCC_DDRL5ProductMapping_TH_Test
Created Date: 23 Aug 2023
Function    :  test class for PCC_DDRL5ProductMapping_Trigger and PCC_DDRL5ProductMapping_TriggerHandler
Developer   : Shraddha More
*************************************************************************************************************************************************/
@isTest
public class PCC_DDRL5ProductMapping_TH_Test {
    
    @isTest
    static void shareDLPM1(){
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert a2;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'test.diqhwqi@test.com';
        c1.MailingCountry='India';
        insert c1;
        
        Contact c2 = PRM_TestUtility.getContact();
        c2.AccountId = a2.Id;
        c2.Email='test.user11@intel.com';
        c2.Core_Preferred_Language__c = 'ENG';
        c2.Core_eRPM_Language_Code__c = 'ENG';
        c2.RecordTypeId = contactRecordType;
        c2.Core_IPA_Partner_Role__c = 'Service Provider';
        c2.MailingCountry='India';
        c2.Email = 'test.diqhwqi11@test.com';
        insert c2;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Employee';
        ed1.Core_Display_Name__c='Employee';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed1;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=c1.Id;
        cce.Core_Entitlement_Id__c = ed1.id;
        cce.Core_Status__c='Complete';
        cce.Core_Selected__c = true;
        cce.Core_Source__c = 'Entitlement';
        insert cce;
        
        Core_Contact_Entitlement__c cce1 =new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=c2.Id;
        cce1.Core_Entitlement_Id__c = ed1.id;
        cce1.Core_Status__c='Complete';
        cce1.Core_Selected__c = true;
        cce1.Core_Source__c = 'Entitlement';
        insert cce1;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='test.diqhwqi@test.com',
                                    UserName='test2udwvgsr@xyz.com', ContactId=c1.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser; 
        
        User partnerUser1 = new User(FirstName='MrTest1',LastName='User1',alias='t2user1',Email='test.diqhwqi11@test.com',
                                    UserName='test2udwvgsr11@xyz.com', ContactId=c2.Id, ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser1; 
        
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User user = new User(Alias = 'sysAdm', 
                             Email='sysAdmTest@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestsysAdm',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = sysAdminProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='adminTestoozzTestDDR@intel.com');
        insert user; 
        
        User user1 = new User(Alias = 'sysAdm2', 
                             Email='itadminTest111@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestItAdmin11',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = sysAdminProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='adminTestoozzTestDDR111@intel.com',Core_User_Geo__c='APJ');
         insert user1; 
        
        
        Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.PCC_End_Customer_Country__c ='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+19;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+21;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.OwnerId = partnerUser.Id;
        ddrRec.Core_Partner_Account_Region_Cd__c = 'APJ';
        insert ddrRec;     
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
       // System.debug('here=='+TestDDRupdate_Rej[0].Core_Design_Registration_Status_Nm__c);
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts;
        
        Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
        pmam.Ordering_Code__c = 'WX80660E52630V4';
        pmam.Name = '949344';
        pmam.L4_Product__c = pr1.Id;
        pmam.IsActive__c = true;
        insert pmam;
        
        PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
        dlpm.PCC_Design_Registration__c = ddrRec.id;
        dlpm.PCC_Design_Registration_Product__c = DRproducts.id;
        dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam.id;
        dlpm.PCC_MM_ID__c = pmam.Name;
        dlpm.PCC_Ordering_Cd__c = pmam.Ordering_Code__c;
        insert dlpm;
        
        Core_Design_Registration__Share dsShare = new Core_Design_Registration__Share();
        dsShare.ParentId = ddrRec.Id;
        dsShare.UserOrGroupId = partnerUser1.Id;
        dsShare.AccessLevel = 'Edit';
        dsShare.RowCause = 'Manual';
        Insert dsShare;
        
        ddrRec.OwnerId = user.Id;
        ddrRec.Core_Partner_Account_Region_Cd__c = 'EMEA';
        update ddrRec; 
        
        ddrRec.OwnerId = user1.Id;
        ddrRec.Core_Partner_Account_Region_Cd__c = 'ASMO';
        update ddrRec; 
        
        PCC_DDR_L5_Product_Mapping__Share dlpmShare = new PCC_DDR_L5_Product_Mapping__Share();
        dlpmShare.AccessLevel = 'Edit';
        dlpmShare.RowCause = 'Manual';
        dlpmShare.UserOrGroupId = partnerUser1.Id;
        dlpmShare.ParentId = dlpm.Id;
        insert dlpmShare;
            
        ddrRec.OwnerId = user.Id;
        ddrRec.Core_Partner_Account_Region_Cd__c = 'ASMO';
        update ddrRec;
        list<id> userList = new list<id>();
        userList.add(user1.id);
        PCC_DDRL5ProductMapping_TriggerHandler.checkDDRPS(userList);
        
        list<id> userids=new list<id>();
        userids.add(user1.id);
        PCC_DDRL5ProductMapping_TriggerHandler.checkDDRPS(userids);
        
    }

}