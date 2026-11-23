/***********************************************************************************************************************************************
Apex Class Name:  PRM_PointsRedeemBenAssignBatch_Test
Version     : 1.0 
Created Date: 12 July 2022
Function    : Test Class for PRM_PointsRedeemBenAssignBatch and PRM_PointsRedeemBenAssignUtility

Modification Log :
* Developer                     Date                Description                                             
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Tanya Rajesh                  12/07/2022           Test Class for PRM_PointsRedeemBenAssignBatch and PRM_PointsRedeemBenAssignUtility   
*************************************************************************************************************************************************/
@isTest
public class PRM_PointsRedeemBenAssignBatch_Test {
    @TestSetup
    //test data creation
    static void setupDataCreation(){

        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        insert bm;

        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<Account> acc = new List<Account>();
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        opidAcc.Industry = 'Agriculture';
        acc.add(opidAcc) ;

        Account opidAcc01 = new Account();//Account
        opidAcc01.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc01.Name='vistara';
        opidAcc01.BillingCity='City8';
        opidAcc01.BillingStreet='Street8';
        opidAcc01.BillingCountry='India';
        opidAcc01.BillingPostalCode='57689';
        opidAcc01.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc01.Core_IPA_Partner_Role__c = 'Service Provider';
        opidAcc01.Industry = 'Agriculture';
        acc.add(opidAcc01) ;

        Account opidAcc02 = new Account();//Account
        opidAcc02.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc02.Name='vistakiara';
        opidAcc02.BillingCity='City7';
        opidAcc02.BillingStreet='Street7';
        opidAcc02.BillingCountry='India';
        opidAcc02.BillingPostalCode='Postal';
        opidAcc02.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc02.Core_IPA_Partner_Role__c = 'Distributor';
        opidAcc02.Industry = 'Agriculture';
        acc.add(opidAcc02) ;

        Account opidAcc03 = new Account();//Account
        opidAcc03.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc03.Name='vistakiara';
        opidAcc03.BillingCity='City6';
        opidAcc03.BillingStreet='Street6';
        opidAcc03.BillingCountry='India';
        opidAcc03.BillingPostalCode='58798';
        opidAcc03.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc03.Core_IPA_Partner_Role__c = 'Distributor';
        opidAcc03.Industry = 'Agriculture';
        acc.add(opidAcc03) ;

        Account opidAcc04 = new Account();//Account
        opidAcc04.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc04.Name='vista';
        opidAcc04.BillingCity='City5';
        opidAcc04.BillingStreet='Street5';
        opidAcc04.BillingCountry='India';
        opidAcc04.BillingPostalCode='P17909';
        opidAcc04.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc04.Core_IPA_Partner_Role__c = 'Solution Integrator';
        opidAcc04.Industry = 'Agriculture';
        acc.add(opidAcc04);

        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeAccount;
        newAccount.Name='vistagun';
        newAccount.BillingCity='City4';
        newAccount.BillingStreet='Stre';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='P15299';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount.Industry = 'Agriculture';
        newAccount.Core_User_Defined_Website__c = 'www.testacc.com';
        acc.add(newAccount) ;

        Account newAccount01 = new Account();//Account
        newAccount01.RecordTypeId = recordTypeAccount;
        newAccount01.Name='locAcc';
        newAccount01.BillingCity='LocCity';
        newAccount01.BillingStreet='LocStreet';
        newAccount01.BillingCountry='India';
        newAccount01.BillingPostalCode='2485299';
        newAccount01.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount01.Core_IPA_Partner_Role__c = 'Distributor';
        newAccount01.Industry = 'Agriculture';
        newAccount01.Core_User_Defined_Website__c = 'www.locacc.com';
        acc.add(newAccount01) ;
        


        if(acc.size()>0){
            insert acc;
        }
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;

        List<PRM_AccountChannelMembership__c> listACMs = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=opidAcc.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Solution Integrator';
         acm1.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm1);

        PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm2.PRM_Account_Id__c=opidAcc01.id;
        acm2.PRM_Status_Nm__c='Approved';
        acm2.PRM_Channel_Program_Id__c=cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
         acm2.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm2);

        PRM_AccountChannelMembership__c acm3= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm3.PRM_Account_Id__c=opidAcc02.id;
        acm3.PRM_Status_Nm__c='Inactive';
        acm3.PRM_Channel_Program_Id__c=cp.Id;
        acm3.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm3.PRM_Partner_Role__c='Distributor';
         acm3.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm3);

        PRM_AccountChannelMembership__c acm4= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm4.PRM_Account_Id__c=opidAcc03.id;
        acm4.PRM_Status_Nm__c='Approved';
        acm4.PRM_Channel_Program_Id__c=cp.Id;
        acm4.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm4.PRM_Partner_Role__c='Distributor';
         acm4.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm4);

        PRM_AccountChannelMembership__c acm5= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm5.PRM_Account_Id__c=opidAcc04.id;
        acm5.PRM_Status_Nm__c='Approved';
        acm5.PRM_Channel_Program_Id__c=cp.Id;
        acm5.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm5.PRM_Partner_Role__c='Solution Integrator';
         acm5.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm5);

        PRM_AccountChannelMembership__c acm6= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm6.PRM_Account_Id__c=acc[5].id;
        acm6.PRM_Status_Nm__c='Approved';
        acm6.PRM_Channel_Program_Id__c=cp.Id;
        acm6.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm6.PRM_Partner_Role__c='Solution Integrator';
         acm6.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm6);

        PRM_AccountChannelMembership__c acm7= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm7.PRM_Account_Id__c=acc[6].id;
        acm7.PRM_Status_Nm__c='Approved';
        acm7.PRM_Channel_Program_Id__c=cp.Id;
        acm7.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm7.PRM_Partner_Role__c='Distributor';
        acm7.PRM_Status_Reason_Txt__c='test';
        listACMs.add(acm7);


        if(listACMs.size()>0){
            insert listACMs;  
        }

        List<Contact> listContacts = new List<Contact>();
        Contact con01 = new Contact();
        con01.AccountId=acc[5].Id;
        con01.lastName='test';
        con01.FirstName='con01';
        con01.email='testcon01@rediff.com';
        con01.Core_Job_Function__c='Branch Manager';
        con01.Core_eRPM_Language_Code__c='Eng';
        con01.Core_IPA_PartnerRole__c = 'Distributor';
        con01.Core_Login_Status__c='Active';
        con01.MailingCountryCode ='USA';
        con01.MailingCity ='Mississippi';
        con01.MailingPostalCode='421910';
        con01.MailingState ='AK';
        con01.MailingStreet ='BandraStreet';
        listContacts.add(con01);

        Contact con02 = new Contact();
        con02.AccountId=acc[5].Id;
        con02.lastName='test';
        con02.FirstName='con02';
        con02.email='testcon02@rediff.com';
        con02.Core_Job_Function__c='Branch Manager';
        con02.Core_eRPM_Language_Code__c='Eng';
        con02.Core_IPA_PartnerRole__c = 'Distributor';
        con02.Core_Login_Status__c='Active';
        con02.MailingCountryCode ='USA';
        con02.MailingCity ='Mississippi';
        con02.MailingPostalCode='421910';
        con02.MailingState ='AK';
        con02.MailingStreet ='BandraStreet';
        listContacts.add(con02);

        Contact con03 = new Contact();
        con03.AccountId=acc[5].Id;
        con03.lastName='test';
        con03.FirstName='con03';
        con03.email='testcon03@rediff.com';
        con03.Core_Job_Function__c='Branch Manager';
        con03.Core_eRPM_Language_Code__c='Eng';
        con03.Core_IPA_PartnerRole__c = 'Distributor';
        con03.Core_Login_Status__c='Active';
        con03.MailingCountryCode ='USA';
        con03.MailingCity ='Mississippi';
        con03.MailingPostalCode='421910';
        con03.MailingState ='AK';
        con03.MailingStreet ='BandraStreet';
        listContacts.add(con03);

        Contact con04 = new Contact();
        con04.AccountId=acc[5].Id;
        con04.lastName='test';
        con04.FirstName='con04';
        con04.email='testcon04@rediff.com';
        con04.Core_Job_Function__c='Branch Manager';
        con04.Core_eRPM_Language_Code__c='Eng';
        con04.Core_IPA_PartnerRole__c = 'Distributor';
        con04.Core_Login_Status__c='Active';
        con04.MailingCountryCode ='USA';
        con04.MailingCity ='Mississippi';
        con04.MailingPostalCode='421910';
        con04.MailingState ='AK';
        con04.MailingStreet ='BandraStreet';
        listContacts.add(con04);

        Contact con05 = new Contact();
        con05.AccountId=acc[5].Id;
        con05.lastName='test';
        con05.FirstName='con05';
        con05.email='testcon05@rediff.com';
        con05.Core_Job_Function__c='Branch Manager';
        con05.Core_eRPM_Language_Code__c='Eng';
        con05.Core_IPA_PartnerRole__c = 'Distributor';
        con05.Core_Login_Status__c='Active';
        con05.MailingCountryCode ='USA';
        con05.MailingCity ='Mississippi';
        con05.MailingPostalCode='421910';
        con05.MailingState ='AK';
        con05.MailingStreet ='BandraStreet';
        listContacts.add(con05);

        Contact con06 = new Contact();
        con06.AccountId=acc[5].Id;
        con06.lastName='test';
        con06.FirstName='con06';
        con06.email='testcon06@rediff.com';
        con06.Core_Job_Function__c='Branch Manager';
        con06.Core_eRPM_Language_Code__c='Eng';
        con06.Core_IPA_PartnerRole__c = 'Distributor';
        con06.Core_Login_Status__c='Active';
        con06.MailingCountryCode ='USA';
        con06.MailingCity ='Mississippi';
        con06.MailingPostalCode='421910';
        con06.MailingState ='AK';
        con06.MailingStreet ='BandraStreet';
        listContacts.add(con06);

        Contact con07 = new Contact();
        con07.AccountId=acc[6].Id;
        con07.lastName='test';
        con07.FirstName='con07';
        con07.email='testcon07@rediff.com';
        con07.Core_Job_Function__c='Branch Manager';
        con07.Core_eRPM_Language_Code__c='Eng';
        con07.Core_IPA_PartnerRole__c = 'Distributor';
        con07.Core_Login_Status__c='Active';
        con07.MailingCountryCode ='USA';
        con07.MailingCity ='Mississippi';
        con07.MailingPostalCode='421910';
        con07.MailingState ='AK';
        con07.MailingStreet ='BandraStreet';
        listContacts.add(con07);

        Contact con08 = new Contact();
        con08.AccountId=acc[6].Id;
        con08.lastName='test';
        con08.FirstName='con08';
        con08.email='testcon08@rediff.com';
        con08.Core_Job_Function__c='Branch Manager';
        con08.Core_eRPM_Language_Code__c='Eng';
        con08.Core_IPA_PartnerRole__c = 'Distributor';
        con08.Core_Login_Status__c='Active';
        con08.MailingCountryCode ='USA';
        con08.MailingCity ='Mississippi';
        con08.MailingPostalCode='421910';
        con08.MailingState ='AK';
        con08.MailingStreet ='BandraStreet';
        listContacts.add(con08);

        Contact con09 = new Contact();
        con09.AccountId=acc[6].Id;
        con09.lastName='test';
        con09.FirstName='con09';
        con09.email='testcon09@rediff.com';
        con09.Core_Job_Function__c='Branch Manager';
        con09.Core_eRPM_Language_Code__c='Eng';
        con09.Core_IPA_PartnerRole__c = 'Distributor';
        con09.Core_Login_Status__c='Active';
        con09.MailingCountryCode ='USA';
        con09.MailingCity ='Mississippi';
        con09.MailingPostalCode='421910';
        con09.MailingState ='AK';
        con09.MailingStreet ='BandraStreet';
        listContacts.add(con09);

        Contact con10 = new Contact();
        con10.AccountId=acc[6].Id;
        con10.lastName='test';
        con10.FirstName='con10';
        con10.email='testcon10@rediff.com';
        con10.Core_Job_Function__c='Branch Manager';
        con10.Core_eRPM_Language_Code__c='Eng';
        con10.Core_IPA_PartnerRole__c = 'Distributor';
        con10.Core_Login_Status__c='Active';
        con10.MailingCountryCode ='USA';
        con10.MailingCity ='Mississippi';
        con10.MailingPostalCode='421910';
        con10.MailingState ='AK';
        con10.MailingStreet ='BandraStreet';
        listContacts.add(con10);

        Contact con11 = new Contact();
        con11.AccountId=acc[6].Id;
        con11.lastName='test';
        con11.FirstName='con11';
        con11.email='testcon11@rediff.com';
        con11.Core_Job_Function__c='Branch Manager';
        con11.Core_eRPM_Language_Code__c='Eng';
        con11.Core_IPA_PartnerRole__c = 'Distributor';
        con11.Core_Login_Status__c='Active';
        con11.MailingCountryCode ='USA';
        con11.MailingCity ='Mississippi';
        con11.MailingPostalCode='421910';
        con11.MailingState ='AK';
        con11.MailingStreet ='BandraStreet';
        listContacts.add(con11);

        Contact con12 = new Contact();
        con12.AccountId=acc[6].Id;
        con12.lastName='test';
        con12.FirstName='con12';
        con12.email='testcon12@rediff.com';
        con12.Core_Job_Function__c='Branch Manager';
        con12.Core_eRPM_Language_Code__c='Eng';
        con12.Core_IPA_PartnerRole__c = 'Distributor';
        con12.Core_Login_Status__c='Active';
        con12.MailingCountryCode ='USA';
        con12.MailingCity ='Mississippi';
        con12.MailingPostalCode='421910';
        con12.MailingState ='AK';
        con12.MailingStreet ='BandraStreet';
        listContacts.add(con12);

        Contact con13 = new Contact();
        con13.AccountId=acc[6].Id;
        con13.lastName='test';
        con13.FirstName='con13';
        con13.email='testcon13@rediff.com';
        con13.Core_Job_Function__c='Branch Manager';
        con13.Core_eRPM_Language_Code__c='Eng';
        con13.Core_IPA_PartnerRole__c = 'Distributor';
        con13.Core_Login_Status__c='Active';
        con13.MailingCountryCode ='USA';
        con13.MailingCity ='Mississippi';
        con13.MailingPostalCode='421910';
        con13.MailingState ='AK';
        con13.MailingStreet ='BandraStreet';
        listContacts.add(con13);

        if(listContacts.size()>0){
            insert listContacts;
        }

        List<Core_Account_Group_Member__c> listAccountgroup = new List<Core_Account_Group_Member__c>();

        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = acc[5].id;
        coreAccnt.Core_Inactive_Ind__c = false;
        listAccountgroup.add(coreAccnt);

        Core_Account_Group_Member__c coreAccnt01 = new Core_Account_Group_Member__c();
        coreAccnt01.Core_Partner_Account_Id__c = opidAcc03.id;
        coreAccnt01.Core_Intel_Account_Id__c = acc[6].id;
        coreAccnt01.Core_Inactive_Ind__c = false;
        listAccountgroup.add(coreAccnt01);
        
        insert listAccountgroup;

        // PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        // contRelation.Name='Employee';
        // contRelation.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        // contRelation.PRM_Channel_Program_Id__c = cp.Id;
        // contRelation.PRM_Default_Relationship_Ind__c = false;
        // insert contRelation;

        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name='Partner Admin';
        contRelation1.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation1.PRM_Channel_Program_Id__c = cp.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = false;
        insert contRelation1;

        /*PRM_ContactRelationships__c contRelation2 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation2.Name='Partner Admin Delegate';
        contRelation2.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation2.PRM_Channel_Program_Id__c = cp.Id;
        contRelation2.PRM_Default_Relationship_Ind__c = false;
        insert contRelation2;*/

        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        insert pb;

        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;

        List<PRM_VXEnttlmntMatrix__c> listVXMatrix = new List<PRM_VXEnttlmntMatrix__c>();

        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.PRM_Contact_Relationship_Id__c = contRelation1.id;
        entMatrix.PRM_Partner_Benefit_Id__c = pb.id;
        entMatrix.PRM_IsActive_Ind__c = true;
        entMatrix.PRM_Entitlement_Id__c = ed.id;
        listVXMatrix.add(entMatrix);

        /*PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.PRM_Contact_Relationship_Id__c = contRelation2.id;
        entMatrix1.PRM_Partner_Benefit_Id__c = pb.id;
        entMatrix1.PRM_IsActive_Ind__c = true;
        entMatrix1.PRM_Entitlement_Id__c = ed.id;
        listVXMatrix.add(entMatrix1);*/

        insert listVXMatrix;
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel01=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel01.PRM_Account_Id__c=acc[5].Id;
        acctContRel01.PRM_Contact_Id__c=listContacts[0].Id;
        acctContRel01.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel01.PRM_InActive_Ind__c=false;
        acctContRel01.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel01);

        PRM_Account_Contact_Relationship__c acctContRel02=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel02.PRM_Account_Id__c=acc[5].Id;
        acctContRel02.PRM_Contact_Id__c=listContacts[1].Id;
        acctContRel02.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel02.PRM_InActive_Ind__c=false;
        acctContRel02.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel02);

        PRM_Account_Contact_Relationship__c acctContRel03=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel03.PRM_Account_Id__c=acc[5].Id;
        acctContRel03.PRM_Contact_Id__c=listContacts[2].Id;
        acctContRel03.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel03.PRM_InActive_Ind__c=false;
        acctContRel03.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel03);

        PRM_Account_Contact_Relationship__c acctContRel04=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel04.PRM_Account_Id__c=acc[5].Id;
        acctContRel04.PRM_Contact_Id__c=listContacts[3].Id;
        acctContRel04.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel04.PRM_InActive_Ind__c=false;
        acctContRel04.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel04);

        PRM_Account_Contact_Relationship__c acctContRel05=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel05.PRM_Account_Id__c=acc[5].Id;
        acctContRel05.PRM_Contact_Id__c=listContacts[4].Id;
        acctContRel05.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel05.PRM_InActive_Ind__c=false;
        acctContRel05.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel05);

        PRM_Account_Contact_Relationship__c acctContRel06=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel06.PRM_Account_Id__c=acc[5].Id;
        acctContRel06.PRM_Contact_Id__c=listContacts[5].Id;
        acctContRel06.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel06.PRM_InActive_Ind__c=false;
        acctContRel06.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel06);

        PRM_Account_Contact_Relationship__c acctContRel07=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel07.PRM_Account_Id__c=acc[6].Id;
        acctContRel07.PRM_Contact_Id__c=listContacts[6].Id;
        acctContRel07.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel07.PRM_InActive_Ind__c=false;
        acctContRel07.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel07);

        PRM_Account_Contact_Relationship__c acctContRel08=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel08.PRM_Account_Id__c=acc[6].Id;
        acctContRel08.PRM_Contact_Id__c=listContacts[7].Id;
        acctContRel08.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel08.PRM_InActive_Ind__c=false;
        acctContRel08.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel08);

        PRM_Account_Contact_Relationship__c acctContRel09=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel09.PRM_Account_Id__c=acc[6].Id;
        acctContRel09.PRM_Contact_Id__c=listContacts[8].Id;
        acctContRel09.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel09.PRM_InActive_Ind__c=false;
        acctContRel09.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel09);

        PRM_Account_Contact_Relationship__c acctContRel10=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel10.PRM_Account_Id__c=acc[6].Id;
        acctContRel10.PRM_Contact_Id__c=listContacts[9].Id;
        acctContRel10.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel10.PRM_InActive_Ind__c=false;
        acctContRel10.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel10);

        PRM_Account_Contact_Relationship__c acctContRel11=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel11.PRM_Account_Id__c=acc[6].Id;
        acctContRel11.PRM_Contact_Id__c=listContacts[10].Id;
        acctContRel11.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel11.PRM_InActive_Ind__c=false;
        acctContRel11.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel11);

        PRM_Account_Contact_Relationship__c acctContRel12=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel12.PRM_Account_Id__c=acc[6].Id;
        acctContRel12.PRM_Contact_Id__c=listContacts[11].Id;
        acctContRel12.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel12.PRM_InActive_Ind__c=false;
        acctContRel12.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel12);

        PRM_Account_Contact_Relationship__c acctContRel13=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel13.PRM_Account_Id__c=acc[6].Id;
        acctContRel13.PRM_Contact_Id__c=listContacts[12].Id;
        acctContRel13.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel13.PRM_InActive_Ind__c=false;
        acctContRel13.PRM_Status_Nm__c ='Complete';
        acrList.add(acctContRel13);
        if(acrList.size()>0){
            Triggerhandler.bypass('PRM_AcctContRel_TriggerHandler');
            insert acrList;
            acrList[0].PRM_Status_Nm__c ='Complete';
            acrList[1].PRM_Status_Nm__c ='Complete';
            acrList[2].PRM_Status_Nm__c ='Complete';
            acrList[3].PRM_Status_Nm__c ='Complete';
            acrList[4].PRM_Status_Nm__c ='Complete';
            acrList[5].PRM_Status_Nm__c ='Complete';
            acrList[6].PRM_Status_Nm__c ='Complete';
            acrList[7].PRM_Status_Nm__c ='Complete';
            acrList[8].PRM_Status_Nm__c ='Complete';
            acrList[9].PRM_Status_Nm__c ='Complete';
            acrList[10].PRM_Status_Nm__c ='Complete';
            acrList[11].PRM_Status_Nm__c ='Complete';
            acrList[12].PRM_Status_Nm__c ='Complete';
            update acrList;
            Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandler');
        }
        List<PRM_Account_Contact_Relationship__c> acrListAfterInsert = [select id,PRM_Relationship_Id__c,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Partner_Role__c,PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c =: acc[5].id];
        List<PRM_Account_Contact_Relationship__c> acrListAfterInsert01 = [SELECT 
                    id,PRM_Relationship_Id__c
                    FROM PRM_Account_Contact_Relationship__c
                    WHERE PRM_Account_Id__c =: acc[5].id
                    AND  PRM_InActive_Ind__c = false
                  AND PRM_Relationship_Id__c =: contRelation1.Id];
                    

        PRM_Profile_Questions__c question1 = new PRM_Profile_Questions__c();
        question1.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible';
        question1.PRM_Question_Display_Txt__c = 'Points Not eligible';
        question1.PRM_Question_Display_Type_Nm__c = 'INTERNAL';
        question1.PRM_InActive_Ind__c = false;
        insert question1;

        /*List<PRM_Profile_Answer__c> profAns = new List<PRM_Profile_Answer__c>();
        PRM_Profile_Answer__c prflAnsTrue = new PRM_Profile_Answer__c();
        prflAnsTrue.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        prflAnsTrue.PRM_Answer_Display_Txt__c = 'TRUE';
        prflAnsTrue.PRM_InActive_Ind__c = false;
        prflAnsTrue.PRM_Profile_Questions_Id__c = question1.id;
        profAns.add(prflAnsTrue);

        PRM_Profile_Answer__c prflAnsFalse = new PRM_Profile_Answer__c();
        prflAnsFalse.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_False';
        prflAnsFalse.PRM_Answer_Display_Txt__c = 'FALSE';
        prflAnsFalse.PRM_InActive_Ind__c = false;
        prflAnsFalse.PRM_Profile_Questions_Id__c = question1.id;
        profAns.add(prflAnsFalse);

        if(profAns.size()>0){
            insert profAns;
        }*/

        List<PRM_Profile_Responses__c> listProfResponses = new List<PRM_Profile_Responses__c>();
        PRM_Profile_Responses__c profRes1 = new PRM_Profile_Responses__c();
        profRes1.PRM_Account_Id__c = opidAcc.id;
        profRes1.PRM_Profile_Questions_Id__c = question1.id;
        profRes1.PRM_Response_Txt__c = 'false';
        //profRes1.PRM_Profile_Answer_Id__c = prflAnsFalse.id;
        listProfResponses.add(profRes1);

        PRM_Profile_Responses__c profRes2 = new PRM_Profile_Responses__c();
        profRes2.PRM_Account_Id__c = opidAcc01.id;
        profRes2.PRM_Profile_Questions_Id__c = question1.id;
        profRes2.PRM_Response_Txt__c = '29-01-2022';
        //profRes2.PRM_Profile_Answer_Id__c = prflAnsTrue.id;
        listProfResponses.add(profRes2);

        PRM_Profile_Responses__c profRes3 = new PRM_Profile_Responses__c();
        profRes3.PRM_Account_Id__c = opidAcc02.id;
        profRes3.PRM_Profile_Questions_Id__c = question1.id;
        profRes3.PRM_Response_Txt__c = '28-01-2022';
        //profRes3.PRM_Profile_Answer_Id__c = prflAnsTrue.id;
        listProfResponses.add(profRes3);

        /*PRM_Profile_Responses__c profRes4 = new PRM_Profile_Responses__c();
        profRes4.PRM_Account_Id__c = opidAcc03.id;
        profRes4.PRM_Profile_Questions_Id__c = question1.id;
        //profRes4.PRM_Response_Txt__c = 'false';
        //profRes4.PRM_Profile_Answer_Id__c = prflAnsFalse.id;
        listProfResponses.add(profRes4);*/

        PRM_Profile_Responses__c profRes5 = new PRM_Profile_Responses__c();
        profRes5.PRM_Account_Id__c = opidAcc04.id;
        profRes5.PRM_Profile_Questions_Id__c = question1.id;
        profRes5.PRM_Response_Txt__c = 'false';
        //profRes5.PRM_Profile_Answer_Id__c = prflAnsFalse.id;
        listProfResponses.add(profRes5);

        if(listProfResponses.size()>0){
            TriggerHandler.bypass('PRM_ProfileResponses_TriggerHandler');
            insert listProfResponses;
            TriggerHandler.clearbypass('PRM_ProfileResponses_TriggerHandler');
        }


        List<PRM_AccountBenefitAssociation__c> benList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c ben01 = new PRM_AccountBenefitAssociation__c();
        ben01.PRM_Partner_Benefit_Id__c = pb.id;
        ben01.PRM_Status_Nm__c = 'Inactive';
        ben01.PRM_Account_Id__c = opidAcc.id;
        ben01.PRM_Status_Reason_Txt__c = 'This Benifit is inactivated because the Benifit is inactivated at OPID Level';
        ben01.PRM_Source__c = System.Label.PRM_Source_BenefitMatrix;
        benList.add(ben01);

        PRM_AccountBenefitAssociation__c ben02 = new PRM_AccountBenefitAssociation__c();
        ben02.PRM_Partner_Benefit_Id__c = pb.id;
        ben02.PRM_Status_Nm__c = 'Active';
        ben02.PRM_Account_Id__c = opidAcc03.id;
        ben02.PRM_Status_Reason_Txt__c = 'This Benifit is inactivated because the Benifit is inactivated at OPID Level';
        ben02.PRM_Source__c = System.Label.PRM_Source_BenefitMatrix;
        benList.add(ben02);

        if(benList.size()>0){
            insert benList;
        }

        List<Core_Contact_Entitlement__c> entRecsList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c entrec01 = new Core_Contact_Entitlement__c();
        entrec01.Core_Contact_Id__c = listContacts[0].id;
        entrec01.Core_Entitlement_Id__c = ed.id;
        entrec01.Core_Selected__c = false;
        entRecsList.add(entrec01);

        Core_Contact_Entitlement__c entrec02 = new Core_Contact_Entitlement__c();
        entrec02.Core_Contact_Id__c = listContacts[1].id;
        entrec02.Core_Entitlement_Id__c = ed.id;
        entrec02.Core_Selected__c = false;
        entRecsList.add(entrec02);

        Core_Contact_Entitlement__c entrec03 = new Core_Contact_Entitlement__c();
        entrec03.Core_Contact_Id__c = listContacts[2].id;
        entrec03.Core_Entitlement_Id__c = ed.id;
        entrec03.Core_Selected__c = false;
        entRecsList.add(entrec03);

        Core_Contact_Entitlement__c entrec04 = new Core_Contact_Entitlement__c();
        entrec04.Core_Contact_Id__c = listContacts[6].id;
        entrec04.Core_Entitlement_Id__c = ed.id;
        entrec04.Core_Selected__c = true;
        entRecsList.add(entrec04);

        Core_Contact_Entitlement__c entrec05 = new Core_Contact_Entitlement__c();
        entrec05.Core_Contact_Id__c = listContacts[7].id;
        entrec05.Core_Entitlement_Id__c = ed.id;
        entrec05.Core_Selected__c = true;
        entRecsList.add(entrec05);

        Core_Contact_Entitlement__c entrec06 = new Core_Contact_Entitlement__c();
        entrec06.Core_Contact_Id__c = listContacts[8].id;
        entrec06.Core_Entitlement_Id__c = ed.id;
        entrec06.Core_Selected__c = true;
        entRecsList.add(entrec06);

        Core_Contact_Entitlement__c entrec07 = new Core_Contact_Entitlement__c();
        entrec07.Core_Contact_Id__c = listContacts[12].id;
        entrec07.Core_Entitlement_Id__c = ed.id;
        entrec07.Core_Selected__c = false;
        entRecsList.add(entrec07);

        if(entRecsList.size()>0){
            Triggerhandler.bypass('Core_Contact_Entitlement_Handler');
            Triggerhandler.bypass('Core_Contact_EntitlementTriggerHandler');
            insert entRecsList;
            Triggerhandler.clearbypass('Core_Contact_Entitlement_Handler');
            Triggerhandler.clearbypass('Core_Contact_EntitlementTriggerHandler');
        }
        
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();

        PRM_Value_Exchange_Recommendation__c valueExchange12 = new PRM_Value_Exchange_Recommendation__c();
        valueExchange12.RecordTypeId = opidRecommendationRecordType;
        valueExchange12.PRM_Tier_Id__c = cpl.Id;
        valueExchange12.PRM_Account_Id__c = opidAcc.Id;
        valueExchange12.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange12.PRM_Recommendation_Status_Nm__c = 'Waiting for CIM response' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange12.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange12.PRM_Partner_Role_Nm__c = 'Distributor';
        insert valueExchange12;
        
        PRM_Value_Exchange_Recommendation__c valueExchange11 = new PRM_Value_Exchange_Recommendation__c();
        valueExchange11.RecordTypeId = opidRecommendationRecordType;
        valueExchange11.PRM_Tier_Id__c = cpl.Id;
        valueExchange11.PRM_Account_Id__c = opidAcc03.Id;
        valueExchange11.PRM_Recommendation_Type_Nm__c = Label.PRM_VX_RecommendationType_OPID;
        valueExchange11.PRM_Recommendation_Status_Nm__c = 'Waiting for CIM response' ;//Label.PRM_VX_Status_OPIDInProcess
        valueExchange11.PRM_Grouping_Method_Nm__c = 'GEO';
        valueExchange11.PRM_Partner_Role_Nm__c = 'Distributor';
        insert valueExchange11;
        
        // List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
         
        // PRM_Tracker__c inprogressTracker  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation', 'IN_PRGS', opidAcc03.Id, ben02.PRM_Account_Id__c, null, null, null, true, null, null,null );    
        // trackerList.add(inprogressTracker); 
        // PRM_Tracker__c inprogressTracker01  = PRM_IPA_Utility.createTrackerInstance('OPID Recommendation', 'IN_PRGS', opidAcc03.Id, ben02.PRM_Account_Id__c, null, null, null, false, null, null,null );    
        // trackerList.add(inprogressTracker01); 
        // insert trackerList;

        List<PRM_Batch_Entitlement__c> batchEntList = new List<PRM_Batch_Entitlement__c>();
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
        be.PRM_Contact_Id__c = listContacts[1].id;
        be.PRM_Entitlement_Id__c = ed.id;
        be.PRM_Status_Nm__c = 'New';
        be.PRM_IsRemove_Ind__c = false;
        batchEntList.add(be);

        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c();
        be1.PRM_Contact_Id__c = listContacts[2].id;
        be1.PRM_Entitlement_Id__c = ed.id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_IsRemove_Ind__c = true;
        batchEntList.add(be1);

        PRM_Batch_Entitlement__c be2 = new PRM_Batch_Entitlement__c();
        be2.PRM_Contact_Id__c = listContacts[3].id;
        be2.PRM_Entitlement_Id__c = ed.id;
        be2.PRM_Status_Nm__c = 'New';
        be2.PRM_IsRemove_Ind__c = false;
        batchEntList.add(be2);

        PRM_Batch_Entitlement__c be3 = new PRM_Batch_Entitlement__c();
        be3.PRM_Contact_Id__c = listContacts[4].id;
        be3.PRM_Entitlement_Id__c = ed.id;
        be3.PRM_Status_Nm__c = 'New';
        be3.PRM_IsRemove_Ind__c = true;
        batchEntList.add(be3);

        PRM_Batch_Entitlement__c be4 = new PRM_Batch_Entitlement__c();
        be4.PRM_Contact_Id__c = listContacts[7].id;
        be4.PRM_Entitlement_Id__c = ed.id;
        be4.PRM_Status_Nm__c = 'New';
        be4.PRM_IsRemove_Ind__c = false;
        batchEntList.add(be4);

        PRM_Batch_Entitlement__c be5 = new PRM_Batch_Entitlement__c();
        be5.PRM_Contact_Id__c = listContacts[8].id;
        be5.PRM_Entitlement_Id__c = ed.id;
        be5.PRM_Status_Nm__c = 'New';
        be5.PRM_IsRemove_Ind__c = true;
        batchEntList.add(be5);

        PRM_Batch_Entitlement__c be6 = new PRM_Batch_Entitlement__c();
        be6.PRM_Contact_Id__c = listContacts[9].id;
        be6.PRM_Entitlement_Id__c = ed.id;
        be6.PRM_Status_Nm__c = 'New';
        be6.PRM_IsRemove_Ind__c = false;
        batchEntList.add(be6);

        PRM_Batch_Entitlement__c be7 = new PRM_Batch_Entitlement__c();
        be7.PRM_Contact_Id__c = listContacts[10].id;
        be7.PRM_Entitlement_Id__c = ed.id;
        be7.PRM_Status_Nm__c = 'New';
        be7.PRM_IsRemove_Ind__c = true;
        batchEntList.add(be7);

        PRM_Batch_Entitlement__c be8 = new PRM_Batch_Entitlement__c();
        be8.PRM_Contact_Id__c = listContacts[12].id;
        be8.PRM_Entitlement_Id__c = ed.id;
        be8.PRM_Status_Nm__c = 'New';
        be8.PRM_IsRemove_Ind__c = true;
        batchEntList.add(be8);

        insert batchEntList;
                List<PRM_AccountChannelMembership__c> ACM = [Select id, name from PRM_AccountChannelMembership__c where PRM_Account_Id__r.name = 'vistagun' limit 1];
    PRM_PointsRedeemBenAssignUtility.pointsBenefitEligibility(ACM);
        PRM_PointsRedeemBenAssignUtility.upsertData(batchEntList);
        Core_CustomMetadata_Object__c meta = new Core_CustomMetadata_Object__c();
        meta.Field_7__c ='PRM_Type__c';
        meta.DeveloperName__c = 'DeveloperName';
        meta.Field_1__c = 'PRM_Active__c';
        meta.Field_2__c = 'PRM_Conditional_Display__c';
        meta.Field_3__c ='PRM_Failed_Step__c';
        meta.Field_4__c ='PRM_Milestone_Display_Name__c';
        meta.Field_5__c ='PRM_Order__c';
        meta.Field_6__c ='PRM_Skippable_step__c';
        meta.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta.MasterLabel__c='MasterLabel';
        insert meta;
        Core_CustomMetadata_Object__c meta1 = new Core_CustomMetadata_Object__c();
        meta1.Field_7__c = 'OPID Recommendation';
        meta1.DeveloperName__c = 'BF_UPD';
        meta1.Field_1__c = 'TRUE';
        meta1.Field_2__c = 'FALSE';
        meta1.Field_3__c ='FASLE';
        meta1.Field_4__c ='In Progress';
        meta1.Field_5__c ='12';
        meta1.Field_6__c = 'FASLE';
        meta1.Metadata_Name__c ='PRM_Tracker_steps__mdt';
        meta1.Header_row__c = meta.id;
        insert meta1;
    }

    static testMethod void testschedule() {
    Test.StartTest();
    PRM_PointsRedeemBenAssignBatch_Schedular testsche = new PRM_PointsRedeemBenAssignBatch_Schedular();
    String sch = '0 0 12 * * ?';
    system.schedule('Test status Check', sch, testsche );
    Test.stopTest();
  }
}