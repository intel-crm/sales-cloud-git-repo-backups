/***************************************************************************************************************************************
Apex Class Name     : PRM_Partner_Assist_Utility_Test
Version             : 1.0
Created Date        : July 2020
Function            : 
Maximum Batch Size  : 
Modification Log    :
* Developer                         Date                           Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Ankit                        11th-July-2020                     
*************************************************************************************************************************************/
@isTest
public class PRM_Partner_Assist_Utility_Test {
    
    @testSetup static void setup(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        //List<Account> lstAccts = new List<Account>();
        Account partAcc1 = new Account(Name ='partAcc1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'PRC Sales Group',
                                       Industry='Agriculture',RecordTypeId=OpidAccRecordTypeId, BillingCity='Eau Claire',BillingCountry='India',BillingStreet='1385  Mercer Street',
                                       ShippingCity='delhi',ShippingCountry='India',ShippingStreet='1453  Grant Street',Core_Intel_Partner_Alliance_PartnerGroup__c=True,
                                       Core_IPA_One_Partner_Id__c='12345',Core_IPA_Partner_Role__c='Distributor');
        insert partAcc1;
        
        List<Account> acc = new List<Account>();
        Account intelAccount = new Account();//Account
        intelAccount.RecordTypeId = recordTypeIdAccount;
        intelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        intelAccount.Name='intelAcc1';
        intelAccount.BillingCity='City';
        intelAccount.BillingStreet='Street';
        intelAccount.BillingCountry='India';
        intelAccount.BillingPostalCode='Postal code';
        intelAccount.Core_IPA_Partner_Role__c = 'Distributor';
        intelAccount.Core_CNDA_Number__c='';
        intelAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        intelAccount.Core_Account_Country__c = 'India';
        intelAccount.Core_Geo__c = 'APJ';
        intelAccount.Core_Sub_Geo__c = 'ANZ';
        insert intelAccount;
        
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c =partAcc1.Id;
        accGroupMem.Core_Intel_Account_Id__c =intelAccount.Id;
        Database.insert(accGroupMem);
        
        
        //contact for Intel Account
        List<Contact> lstContact = new List<Contact>();
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        
        Contact con = new Contact();
        con.FirstName='Boyle';
        con.LastName='Mendez';
        con.Email='boyleMendez@mailinator.com';
        con.MailingCountry='USA';
        con.AccountId=intelAccount.Id;
        con.RecordTypeId=IntelContRecTypeId;
        con.Core_IPA_PartnerRole__c='Builder';
        con.Core_Preferred_Language__c='ENG';
        lstContact.add(con);
        
        Database.insert(lstContact);
        
        //profile
        Profile partnerCommunityProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        
        List<User> lstUser = new List<User>();
        //user
        User partnerUser = new User(FirstName='Partner',LastName='User',alias='testusr',Email='testusercon@test.com',UserName='testusercon@test.com', ContactId=con.Id,ProfileId=partnerCommunityProfile.Id,
                                     emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');
        lstUser.add(partnerUser); 
        
        Database.insert(lstUser);
        
        //List Partner Consent Distributor
        List<PRM_Partner_Consent_Distributor__c> lstPartConsentDistributor = new  List<PRM_Partner_Consent_Distributor__c>();
        PRM_Partner_Consent_Distributor__c partConsentDistr1 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistr1.PRM_Distributor_Name_Txt__c= 'Test Distributor1';
        partConsentDistr1.PRM_Account_Id__c=intelAccount.Id;
        lstPartConsentDistributor.add( partConsentDistr1);
        
        PRM_Partner_Consent_Distributor__c partConsentDistr2 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistr2.PRM_Distributor_Name_Txt__c= 'Test Distributor1';
        partConsentDistr2.PRM_Account_Id__c=intelAccount.Id;
        lstPartConsentDistributor.add(partConsentDistr2);
        
        PRM_Partner_Consent_Distributor__c partConsentDistr3 = new PRM_Partner_Consent_Distributor__c();
        partConsentDistr3.PRM_Distributor_Name_Txt__c= 'Test Distributor2';
        partConsentDistr3.PRM_Account_Id__c=intelAccount.Id;
        lstPartConsentDistributor.add(partConsentDistr3);
        
        Database.insert( lstPartConsentDistributor);
       
        //Creating Partner Assist Consent Record
        PRM_Partner_Assist_Consent__c partAssistConsent = new PRM_Partner_Assist_Consent__c();
        partAssistConsent.PRM_Account_Id__c = intelAccount.Id;
        partAssistConsent.PRM_Consent_Provided_Ind__c =True;
        partAssistConsent.PRM_Consent_Provided_By_Id__c = con.Id;
        partAssistConsent.PRM_Distributor_Id__c = partConsentDistr1.Id;
        insert partAssistConsent;
        
         //Creating Partner Terms and Conditions
        List<PRM_Partner_Terms_and_Conditions__c> lstPtcObj = new List<PRM_Partner_Terms_and_Conditions__c>();
        PRM_Partner_Terms_and_Conditions__c ptcObj = new  PRM_Partner_Terms_and_Conditions__c();
        ptcObj.PRM_InActive_Ind__c = False;
        ptcObj.PRM_Content_Language_Nm__c = con.Core_Preferred_Language__c;
        ptcObj.PRM_Content_Code_Txt__c = 'PA1';
        ptcObj.PRM_Terms_and_Conditions_Type_Nm__c = 'Consent';
        ptcObj.PRM_Content_Message_Txt__c = 'UpperText';
        lstPtcObj.add(ptcObj);
        
        PRM_Partner_Terms_and_Conditions__c ptcObj2 = new  PRM_Partner_Terms_and_Conditions__c();
        ptcObj2.PRM_InActive_Ind__c = False;
        ptcObj2.PRM_Content_Language_Nm__c = con.Core_Preferred_Language__c;
        ptcObj2.PRM_Content_Code_Txt__c = 'PA2';
        ptcObj2.PRM_Terms_and_Conditions_Type_Nm__c =  'Consent';
        ptcObj2.PRM_Content_Message_Txt__c = 'LowerText';
        lstPtcObj.add(ptcObj2);
        
        Database.insert(lstPtcObj);
        
        PRM_Partner_Consent_Distributor__c partConsentDistributor = new PRM_Partner_Consent_Distributor__c();
        partConsentDistributor.PRM_Country_Name__c = 'INDIA';
        partConsentDistributor.PRM_Geo_Nm__c = 'APJ';
        partConsentDistributor.PRM_Sub_Region_Nm__c = 'ANZ';
        partConsentDistributor.PRM_Distributor_Name_Txt__c =  'TestDistributor';
        insert partConsentDistributor;
        
        //Entitlements
        Core_ERPM_Engagement__c erpmEngagement = new Core_ERPM_Engagement__c();
        erpmEngagement.Name = 'Intel Partner Alliance';
        erpmEngagement.Core_IsActive__c = True;
        erpmEngagement.Core_Engagement_Type__c = 'SEC';
        erpmEngagement.Core_Technical_DeDup_Number__c = 'DEDUPGPIPA';
        insert erpmEngagement;
        
        
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Core_ERPM_Engagement_Id__c = erpmEngagement.Id;
        ent.Core_IsActive__c = True;
        ent.Core_Display_Name__c = 'Partner Admin';
        ent.Name='Partner Admin';
        insert ent;
        List<Core_Contact_Entitlement__c> lstConEnt = new  List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contEnt = new Core_Contact_Entitlement__c();
        contEnt.Core_Contact_Id__c = con.Id;
        contEnt.Core_Entitlement_Id__c = ent.Id;
        contEnt.Core_Unique_Id__c = 'Partner Admin';
        contEnt.Core_Status__c='Complete';
        contEnt.Core_Selected__c=true;
        lstConEnt.add(contEnt);
        
        Database.insert(lstConEnt);
    }        
    @isTest
    public static void testFetchFormText(){
        List<PRM_Partner_Assist_Consent__c> lstOfPartnerAssitConsent = new List<PRM_Partner_Assist_Consent__c>();
        List<user> testUser = [SELECT Id, AccountId FROM User WHERE Email='testusercon@test.com' LIMIT 1];
        System.runAs(testUser[0]){
            lstOfPartnerAssitConsent =  [select id,PRM_Account_Id__c,PRM_Consent_Provided_Ind__c from PRM_Partner_Assist_Consent__c where PRM_Account_Id__c =:testUser[0].AccountId AND PRM_Consent_Provided_Ind__c =True];
            Test.startTest();   
            PRM_Partner_Assist_Utility.fetchFormText();  
            Test.stopTest();
        }
        System.assertEquals(1,testUser.size(),'Value does not match');
    }
    
    @isTest
    public static void testgetDistributorList(){
        List<user> testUser = [SELECT Id, AccountId FROM User WHERE Email='testusercon@test.com' LIMIT 1];
        System.runAs(testUser[0]){ 
            Test.startTest(); 
            PRM_Partner_Assist_Utility.getDistributorList();        
            Test.stopTest();
        } 
        System.assertEquals(1,testUser.size(),'Value does not match');
    } 
    @isTest
    public static void testinsertPartnerConsentRecs(){
        Account intelAccount = [SELECT Id, Name FROM Account WHERE Name='intelAcc1' LIMIT 1];
        List<PRM_Partner_Consent_Distributor__c> lstpPartConsentDistr = [SELECT Id FROM PRM_Partner_Consent_Distributor__c WHERE PRM_Account_Id__c =: intelAccount.Id LIMIT 2];
        List<user> testUser = [SELECT Id, AccountId FROM User WHERE Email='testusercon@test.com' LIMIT 1];
        System.runAs(testUser[0]){ 
            Test.startTest(); 
            PRM_Partner_Assist_Utility.insertPartnerConsentRecs( lstpPartConsentDistr[0].Id, lstpPartConsentDistr[1].Id,False);        
            Test.stopTest();
        } 
        System.assertEquals(1,testUser.size(),'Value does not match');
    }
    @isTest
    public static void testUpdatePartnerAssistConsent(){
     Account intelAccount = [SELECT Id, Name FROM Account WHERE Name='intelAcc1' LIMIT 1];
     List<PRM_Partner_Assist_Consent__c> partAssistConsent = [select id,PRM_Account_Id__c,PRM_Consent_Provided_Ind__c,PRM_Distributor_Id__c from PRM_Partner_Assist_Consent__c where PRM_Account_Id__c =:intelAccount.Id AND PRM_Consent_Provided_Ind__c =True AND PRM_Distributor_Id__r.PRM_Distributor_Name_Txt__c='Test Distributor1' limit 1];
     PRM_Partner_Consent_Distributor__c partDist=[SELECT Id,PRM_Distributor_Name_Txt__c FROM PRM_Partner_Consent_Distributor__c WHERE PRM_Account_Id__c =: intelAccount.Id AND PRM_Distributor_Name_Txt__c='Test Distributor2'];
     Test.startTest();
     
     partAssistConsent[0].PRM_Distributor_Id__c=partDist.Id;
     update partAssistConsent;
     Test.stopTest();
     System.assertEquals(partDist.Id,partAssistConsent[0].PRM_Distributor_Id__c,'Updated Distributor value should match');
    }
}