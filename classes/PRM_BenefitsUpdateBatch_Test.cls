/*********************************************************************************************************************
Class Name    : PRM_BenefitsUpdateBatch_Test
Version       : 1.0
Created Date  : Feb 2019
Function      : Test Class for 'PRM_BenefitsUpdateBatch '

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  Feb,2019              Test Class for 'PRM_BenefitsUpdateBatch'
*********************************************************************************************************************/

@isTest
public class PRM_BenefitsUpdateBatch_Test {
    // public static Boolean ipaRefresh = boolean.valueOf(System.label.PRM_IPARefresh);

    static testMethod void entitlementWithBenefit() 
    {   
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        String origin  = 'PRM_BenefitUtility';
        String severity  = 'Critical';
        String project  = 'IPA';
        String errorMessage  = 'Too many DML rows';
        boolean sourceCheck;
        
        List<PRM_Specialty__c> listSpciality = new List<PRM_Specialty__c>();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Select Benefits';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c= 'Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        listSpciality.add(spec1);
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Select Benefits';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c= 'Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        listSpciality.add(spec2);

        insert listSpciality; 
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
        
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Industry = 'Agriculture';
        newAccount.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Joshy Rick1';
        newAccount1.BillingCity='Cityu';
        newAccount1.BillingStreet='Streete';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount1.Industry = 'Agriculture';
        newAccount1.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount1);
        
        if(acc != null){
            insert acc;
        }
        List<Core_Account_Group_Member__c> listAccountgroup = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        listAccountgroup.add(coreAccnt) ;
        
        Core_Account_Group_Member__c coreAccnt1 = new Core_Account_Group_Member__c();
        coreAccnt1.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt1.Core_Intel_Account_Id__c = newAccount1.id;
        listAccountgroup.add(coreAccnt1) ;

        insert listAccountgroup;
        List<Contact> listcon = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Status__c='Active';
    cont.MailingCountry='India';
        listcon.add(cont);
        
        //system.debug('cont'+cont);
        //system.debug('contId'+cont.Id);
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount1.Id;
        cont1.lastName='Grilladm';
        cont1.FirstName='Adamgril';
        cont1.email='AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Status__c='Active';
    cont1.MailingCountry='India';
        listcon.add(cont1);
        insert listcon;
        
        //system.debug('cont1'+cont1);
        //system.debug('cont1Id'+cont1.Id);
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Prestige';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        //Test.startTest();
        List<PRM_PartnerBenefit__c> listPB = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redeem';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb1);

        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Technology Sandbox';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'BFTSNDBX';
        pb2.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb2);

        
        PRM_PartnerBenefit__c pb3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb3.Name = 'Solutions Marketplace Basic Profile';
        pb3.PRM_Channel_Program_Id__c = cp.id;
        pb3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb3.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb3);

        
        PRM_PartnerBenefit__c pb4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb4.Name = 'Solutions Marketplace Enhanced';
        pb4.PRM_Channel_Program_Id__c = cp.id;
        pb4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb4.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb4);

        insert listPB;
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount1.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm1;
        
        List<PRM_AccountChannelMembership__c> acmrecords = new List<PRM_AccountChannelMembership__c>();
        Datetime lastModifyDate;
        String lastModifiedBy;
        acmrecords= [select LastModifiedById,Name,PRM_Status_Change_Dt__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c='Approved' limit 1];
        //system.debug('acmrecords --->'+acmrecords);
        lastModifyDate = acmrecords[0].PRM_Status_Change_Dt__c;
        lastModifiedBy = acmrecords[0].LastModifiedById;
        //system.debug('LM Date is ' +lastModifyDate);
        //system.debug('LM Id is ' +lastModifiedBy);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        Test.startTest();
        List<PRM_VXBnftMatrix__c> listVXB = new List<PRM_VXBnftMatrix__c>();
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        listVXB.add(bem);
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        listVXB.add(bem1);

        
        PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem2.PRM_Approval_Type_Nm__c='Automatic';
        bem2.PRM_Channel_Program_Id__c=cp.Id;
        bem2.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem2.PRM_Covered_Account_Ind__c=True;
        bem2.PRM_IsActive_Ind__c=True;
        bem2.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem2.PRM_Partner_Type_Id__c=pt.Id;
        bem2.PRM_Partner_Role_Nm__c='Service Provider';
        listVXB.add(bem2);
        insert listVXB;
        
        List<PRM_Benefit_Group__c> listBenefitGoup = new List<PRM_Benefit_Group__c>();
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Speciality Benefit Group 1';
        bg1.PRM_InActive_Ind__c= false;
        listBenefitGoup.add(bg1);
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Speciality Benefit Group 2';
        bg2.PRM_InActive_Ind__c= false;
        listBenefitGoup.add(bg2);
        insert listBenefitGoup;
        //Test.startTest();
        List<PRM_Specialty_Benefit_Group_Association__c> listSBGA = new List<PRM_Specialty_Benefit_Group_Association__c>();
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec2.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        listSBGA.add(testSBGA1);
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=spec2.id;
        testSBGA2.PRM_InActive_Ind__c= false;
        listSBGA.add(testSBGA2);
        insert listSBGA;
        
        List<PRM_Benefit_Group_Benefit_Association__c> listBGBA = new List<PRM_Benefit_Group_Benefit_Association__c>();
        PRM_Benefit_Group_Benefit_Association__c bgba1 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba1.PRM_Benefit_Id__c = pb3.id;
        bgba1.PRM_Benefit_Group_Id__c = bg1.id;
        bgba1.PRM_Start_Date_Dt__c = date.today();
        bgba1.PRM_Status_Nm__c ='Live';
        listBGBA.add(bgba1);

        //nj
        PRM_Benefit_Group_Benefit_Association__c bgba3 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba3.PRM_Benefit_Id__c = pb3.id;
        bgba3.PRM_Benefit_Group_Id__c = bg1.id;
        bgba3.PRM_Start_Date_Dt__c = date.today();
        bgba3.PRM_Status_Nm__c ='Live';
        listBGBA.add(bgba3);
        
        PRM_Benefit_Group_Benefit_Association__c bgba2 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba2.PRM_Benefit_Id__c = pb4.id;
        bgba2.PRM_Benefit_Group_Id__c = bg2.id;
        bgba2.PRM_Start_Date_Dt__c = date.today();
        bgba2.PRM_Status_Nm__c ='Live';
        listBGBA.add(bgba2);
        insert listBGBA;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount1.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'Not interested';
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba1.PRM_Account_Id__c = newAccount1.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb2.id;
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c = 'Not interested';
        
        
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba2.PRM_Account_Id__c = newAccount1.Id;
        aba2.PRM_Partner_Benefit_Id__c = pb1.id;
        aba2.PRM_Status_Nm__c = '';
        aba2.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountBenefitAssociation__c aba3 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba3.PRM_Account_Id__c = newAccount1.Id;
        aba3.PRM_Partner_Benefit_Id__c = pb.id;
        aba3.PRM_Status_Nm__c = 'Active';
        aba3.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountBenefitAssociation__c aba4 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba4.PRM_Account_Id__c = newAccount1.Id;
        aba4.PRM_Partner_Benefit_Id__c = pb1.id;
        aba4.PRM_Status_Nm__c = 'Active';
        aba4.PRM_Status_Reason_Txt__c = 'Test class';
        
        //abaList.add(aba);
        //abaList.add(aba1);
        //abaList.add(aba2);
        abaList.add(aba3);
        abaList.add(aba4);
        
        insert abaList;

        //Test.stopTest();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount1.Id;
        acctContRel1.PRM_Contact_Id__c=cont1.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_Status_Nm__c =System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Status_Nm__c='Complete';
        acctContRel1.PRM_Status_Reason_Txt__c = 'Test class';
        Triggerhandler.bypass('PRM_AcctContRel_TriggerHandler');
        insert acctContRel1;
        Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandler');
        //system.debug('acctContRel1-->'+acctContRel1);
        
        //acctContRel1.PRM_Status_Nm__c='Complete';
        //update acctContRel1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        //Test.startTest();
        List<Core_Entitlement__c> listEnt = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Sales PRM- Partner Points Redemption User';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View';
        ed1.Core_Display_Name__c='Sales PRM - Partner University User';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed1);

        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Technology Sandbox';
        ed2.Core_Display_Name__c='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed2);
        insert listEnt;
        
        List<PRM_VXEnttlmntMatrix__c> listEntMatrix = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
       // em.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listEntMatrix.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb1.id;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Contact_Relationship_Id__c = contRelation.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em1.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listEntMatrix.add(em1);

        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Partner_Benefit_Id__c = pb2.id;
        em2.PRM_Entitlement_Id__c = ed2.id;
        em2.PRM_Contact_Relationship_Id__c = contRelation.id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        //em2.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listEntMatrix.add(em2);
        insert listEntMatrix;
      
        
        List<PRM_Account_Specialty_Association__c> listASA = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount1.id;
        asa.PRM_Specialty_Id__c= spec2.id;
        asa.PRM_Partner_Role__c='Service Provider';
        listASA.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount1.id;
        asa1.PRM_Specialty_Id__c= spec1.id;
        asa1.PRM_Partner_Role__c='Service Provider';
        listASA.add(asa1);
        insert listASA;
        //Test.stopTest();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont1.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        ceList.add(cce);
        
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=cont1.Id;
        cce1.Core_Entitlement_Id__c = ed1.Id;
        cce1.Core_Status__c='Pending';
        cce1.Core_From_Source__c = true;
        cce1.Core_Source__c = '';
        ceList.add(cce1);

        Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce2.Core_Contact_Id__c=cont1.Id;
        cce2.Core_Entitlement_Id__c = ed2.Id;
        cce2.Core_Status__c='Pending';
        cce2.Core_From_Source__c = true;
        cce2.Core_Selected__c =true;
        ceList.add(cce2);

        Triggerhandler.bypass('Core_Contact_EntitlementTriggerHandler');
        insert ceList;
        Triggerhandler.clearbypass('Core_Contact_EntitlementTriggerHandler');
    
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont1.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
        be.PRM_Status_Reason_Txt__c = 'Test class';
        be.PRM_IsRemove_Ind__c = false;
        beList.add(be);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =cont1.Id;
        be1.PRM_Entitlement_Id__c =ed1.Id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_Status_Reason_Txt__c = 'Test class';
        beList.add(be1);
        
        PRM_Batch_Entitlement__c be2 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be2.PRM_Contact_Id__c =cont1.Id;
        be2.PRM_Entitlement_Id__c =ed2.Id;
        be2.PRM_Status_Nm__c = 'New';
        be2.PRM_Status_Reason_Txt__c = 'Test class';
        be2.PRM_IsRemove_Ind__c = true;
        beList.add(be2);

         Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
        List<PRM_IPAMembership_Attributes__c> ipaMemList = new List<PRM_IPAMembership_Attributes__c>();
        PRM_IPAMembership_Attributes__c ipaMem = new PRM_IPAMembership_Attributes__c();
        ipaMem.PRM_Account_Id__c = opidAcc.Id;
        ipaMem.RecordTypeId = opidIpaMemAttrRecordId;
        ipaMem.PRM_Registration_Source_Txt__c = 'Web';
        ipaMem.PRM_Points_Opt_in_Ind__c =true;
        ipaMem.PRM_Points_Opt_in_Dt__c = System.today();
        ipaMem.PRM_Point_Status_Txt__c = 'Active';
        ipaMem.PRM_Point_Status_Dt__c = System.today();
        insert ipaMem;
        
        PRM_IPAMembership_Attributes__c ipaMemOpid = new PRM_IPAMembership_Attributes__c();
        ipaMemOpid.PRM_Account_Id__c = newAccount.id;
        ipaMemOpid.RecordTypeId = inteIpaMemAttrRecordId;
        ipaMemOpid.PRM_Registration_Source_Txt__c = 'Web';
        ipaMemOpid.PRM_Points_Not_Eligible_Ind__c =true ;
        ipaMemOpid.PRM_Points_Not_Eligible_Dt__c = System.today();
        ipaMemOpid.PRM_Point_Status_Txt__c = 'Not Eligible';
        ipaMemOpid.PRM_Point_Status_Dt__c = System.today();
        ipaMemList.add(ipaMemOpid);
        Insert ipaMemList;
        
        //try{ 
            //Test.startTest();           
            insert beList;
        //}
       // catch(Exception ce){
            //system.debug('Exception Occured');
        //}
            PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,true,false,true );
          PRM_BenefitsUpdateBatch obj = new PRM_BenefitsUpdateBatch();
            Id batchprocessid =DataBase.executeBatch(obj);
        
        //PRM_EntitlementUtility.assignContactEntitlements(beList);
        Test.stopTest();
        PRM_Contact_Entitlements_Insert_batch ce = new PRM_Contact_Entitlements_Insert_batch();
        Id bpid =DataBase.executeBatch(ce);
        PRM_EntitlementDQBatch ce1 = new PRM_EntitlementDQBatch();
        Id DQbpid =DataBase.executeBatch(ce1);
        PRM_DQBatchForContactWithoutEntitlement ce2 = new PRM_DQBatchForContactWithoutEntitlement();
        Id DQid =DataBase.executeBatch(ce2);        
        PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,false,true,true);
        be2.PRM_IsRemove_Ind__c = true;
        PRM_EntitlementUtility.assignContactEntitlements(new List<PRM_Batch_Entitlement__c>{be2});
        //PRM_EntitlementDQUtility.assignContactEntitlements(new List<PRM_Batch_Entitlement__c>{be1});
        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob];
        //aba.PRM_Status_Nm__c = 'Active';
        //update aba;
        
        
        System.assertEquals(acctContRel1.PRM_Account_Id__c,newAccount1.Id,'Value does not match'); 
    }
    static testMethod void entitlementWithoutBenefit() 
    {
        //Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        boolean sourceCheck;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Industry = 'Agriculture';
        newAccount.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount);
        
        if(acc != null){
            insert acc;
        }
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Status__c='Active';
    cont.MailingCountry='India';
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='Ceaser 99';
        cont1.FirstName='Julius';
        cont1.email='JuliusCeaser979@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Status__c='Active';
    cont1.MailingCountry='India';
        insert cont1;
        List<Id> conlst = new List<Id>();
        conlst.add(cont1.Id);
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Inactive';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm1;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Select Benefits';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;

        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        //Test.startTest();
        List<PRM_PartnerBenefit__c> listPartnerbenefits = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        listPartnerbenefits.add(pb);
        
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Points Redemption to Check';
        pbTest.PRM_Benefit_Cd__c = 'BFTP';
        pbTest.PRM_InActive_Ind__c = false;
        pbTest.PRM_Account_Type_Nm__c='Mastered_Account';
        listPartnerbenefits.add(pbTest);
        insert listPartnerbenefits;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec1.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        insert testSBGA1;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        //Test.startTest();
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA1 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA1.PRM_Benefit_Id__c = pbTest.id;
        bGBA1.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA1.PRM_Start_Date_Dt__c = date.today();
        bGBA1.PRM_Status_Nm__c ='Live';
        insert bGBA1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c='Service Provider';
        //insert asa;
        
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c = 'Not interested';
        insert aba;

        //nj
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c();
        aba2.PRM_Account_Id__c = newAccount.Id;
        aba2.PRM_Partner_Benefit_Id__c = pb.id;
        aba2.PRM_Status_Nm__c = 'Inactive';
        aba2.PRM_Status_Reason_Txt__c = 'Not interested';
        insert aba2;
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pbTest.id;
        aba1.PRM_Status_Nm__c = 'Active';
        aba1.PRM_Status_Reason_Txt__c = 'Test class';
        //insert aba1;
        
        aba.PRM_Status_Nm__c = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'Test class';
        update aba;
        //Test.stopTest();
        
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Nm__c =System.Label.PRM_ACR_Status;
        acctContRel.PRM_Status_Nm__c ='Complete';
        acctContRel.PRM_Status_Reason_Txt__c = 'Test class';
        Triggerhandler.bypass('PRM_AcctContRel_TriggerHandler');
        insert acctContRel;
        acctContRel.PRM_Status_Nm__c ='Complete';
        acctContRel.PRM_Status_Reason_Txt__c = 'Test class';
        update acctContRel;
        Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandler');

        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        /*Core_Entitlement__c entitlement = new Core_Entitlement__c();
        entitlement.Name = 'Intel Premier Support';
        entitlement.Core_Display_Name__c  = 'Intel Premier Support';
        
        insert entitlement;*/
        
        
        
        
        List<Core_Entitlement__c> listents = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='CIP VIP View';
        ed.Core_Display_Name__c='CIP VIP View';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        listents.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View';
        ed1.Core_Display_Name__c='Sales PRM - Partner University User';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        listents.add(ed1);
        
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Intel Premier Support';
        ed2.Core_Display_Name__c='Intel Premier Support';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        listents.add(ed2);
        insert listents;
        List<Id> entlst = new List<Id>();
        entlst.add(ed2.Id);
        
        List<PRM_VXEnttlmntMatrix__c> listentMat = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
       // em.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listentMat.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Partner_Benefit_Id__c = pb.id;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Contact_Relationship_Id__c = contRelation.id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em1.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listentMat.add(em1);
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.RecordTypeId = recordTypeIdEM;
        em2.PRM_Partner_Benefit_Id__c = pb.id;
        em2.PRM_Entitlement_Id__c = ed2.id;
        em2.PRM_Contact_Relationship_Id__c = contRelation.id;
        em2.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em1.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listentMat.add(em2);
        insert listentMat;
        
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        List<PRM_Batch_Entitlement__c> beList1 = new List<PRM_Batch_Entitlement__c>();
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
        be.PRM_Status_Reason_Txt__c = 'Test class';
        beList.add(be);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =cont.Id;
        be1.PRM_Entitlement_Id__c =ed1.Id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_Batch_Entitlement__c be2 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be2.PRM_Contact_Id__c =cont1.Id;
        be2.PRM_Entitlement_Id__c =ed2.Id;
        be2.PRM_Status_Nm__c = 'In Progress';
        be2.PRM_Status_Reason_Txt__c = 'Test class';
        beList1.add(be2);
        
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        cce.Core_Selected__c = true;
        cce.Core_Data_Loaded__c = true;
        cce.Core_DontNotify__c = true;
        cce.Core_From_Source__c = true;
        cce.Core_Source__c = '';
        ceList.add(cce);
        
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=cont.Id;
        cce1.Core_Entitlement_Id__c = ed2.Id;
        cce1.Core_Status__c='Pending';
        cce1.Core_Selected__c = true;
        cce1.Core_Data_Loaded__c = true;
        cce1.Core_DontNotify__c = true;
        cce1.Core_From_Source__c = true;
        cce1.Core_Source__c = '';
        ceList.add(cce1);
        
        
        
        //try{
            if(beList != null && !beList.IsEmpty()){
                Test.startTest();
                insert beList;
                insert beList1;
                //Test.startTest();
                insert ceList;
                aba.PRM_Status_Nm__c = 'Inactive';
                aba.PRM_Status_Reason_Txt__c = 'Test class';
                update aba;
                aba.PRM_Status_Nm__c = 'Active';
                aba.PRM_Status_Reason_Txt__c = 'Test class';
                update aba;
                
            }
        //}
        //catch(Exception ce){
            //system.debug('Exception Occured');
        //}
        Boolean t = true;
        String tier = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers(acm.PRM_Channel_Program_Level_Id__r.Name);         
        //PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,true,true,false);
        PRM_BenefitsUpdateBatch obj = new PRM_BenefitsUpdateBatch();
        Id batchprocessid =DataBase.executeBatch(obj); 
        //Test.stopTest();
        PRM_EntitlementUtility.assignContactEntitlements(beList);
        PRM_EntitlementDQUtility.assignContactEntitlements(beList1);
        PRM_EntitlementDQUtility.updateBatchEntitelmentStatus(beList1);
        PRM_EntitlementDQUtility.getExistingEntitelments(conlst,entlst);
        PRM_Contact_Entitlements_Insert_batch ce = new PRM_Contact_Entitlements_Insert_batch();
        Id bpid =DataBase.executeBatch(ce);
        PRM_EntitlementDQBatch ce1 = new PRM_EntitlementDQBatch();
        Id DQbpid =DataBase.executeBatch(ce1);
        PRM_DQBatchForContactWithoutEntitlement ce2 = new PRM_DQBatchForContactWithoutEntitlement();
        Id DQid =DataBase.executeBatch(ce2);
        Test.stopTest();
        //PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,false,true,true);
        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob];
        
        System.assertEquals(acctContRel.PRM_Account_Id__c,newAccount.Id,'Value does not match');
        try {
            PRM_EntitlementUtility.createLogEntry(new List<String>{'Test error'}, 0, ceList, beList);
        } catch (Exception ex) {
            
        }
    }
    testMethod static void testRemoveVXData(){
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id upgRecTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('Upgrade/Downgrade').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Pawan Kalyan';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Industry='Agriculture';
        accList.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Rohit Sharma';
        newAccount1.BillingCity='Cityu';
        newAccount1.BillingStreet='Streete';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount1.Industry='Agriculture';
        accList.add(newAccount1);
        
        insert accList;
        
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
        insert opidAcc;
        
        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.Id;
        
        update newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Kohli';
        cont.FirstName='Virat';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
    cont.MailingCountry='India';
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount1.Id;
        cont1.lastName='Pandya';
        cont1.FirstName='Hardik';
        cont1.email='AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Enterprise_Id__c ='12334';
    cont1.MailingCountry='India';
        insert cont1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();//mp
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm);//mp
        
        insert acm;
        
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Inactive';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Distributor';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm1);//mp

        insert acm1;  
        
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        //vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = newAccount.id;
        vxData1.PRM_One_Partner_Id__c = opidAcc.id;
        vxData1.PRM_Tier_Id__c = cpl.Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData1.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
        insert vxData1;
        
        PRM_Value_Exchange_Data__c vxData2 = new PRM_Value_Exchange_Data__c();
        //vxData2.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData2.PRM_Account_Id__c = newAccount1.id;
        vxData2.PRM_One_Partner_Id__c = opidAcc.id;
        vxData2.PRM_Tier_Id__c = cpl.Id;
        vxData2.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData2.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData2.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData2.PRM_Change_Date_Dt__c = System.today();
        vxData2.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData2.PRM_To_Dt__c =Date.Today();
        insert vxData2;
        
        PRM_Execution_Controls__c settings = PRM_Execution_Controls__c.getOrgDefaults();
        settings.PRM_Skip_VR_for_OPID_Batch_Ind__c =true;
        insert settings;
        
        List<PRM_Value_Exchange_Recommendation__c> vxRecList = new List<PRM_Value_Exchange_Recommendation__c>();
        PRM_Value_Exchange_Recommendation__c vxrec = new PRM_Value_Exchange_Recommendation__c();
        vxrec.RecordTypeId = upgRecTypeId;
        vxrec.PRM_Account_Id__c = newAccount.id;
        vxrec.PRM_One_Partner_Id__c = opidAcc.Id;
        vxrec.PRM_Partner_Role_Nm__c = 'Distributor';
        vxrec.PRM_Tier_Id__c = cpl.Id;
        vxrec.PRM_Market_Type_Nm__c = 'NA';
        vxrec.PRM_Recommendation_Type_Nm__c = 'Upgrade';
        vxrec.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecList.add(vxrec);
        
        PRM_Value_Exchange_Recommendation__c vxrec1 = new PRM_Value_Exchange_Recommendation__c();
        vxrec1.RecordTypeId = upgRecTypeId;
        vxrec1.PRM_Account_Id__c = newAccount1.id;
        vxrec1.PRM_One_Partner_Id__c = opidAcc.Id;
        vxrec1.PRM_Partner_Role_Nm__c = 'Distributor';
        vxrec1.PRM_Tier_Id__c = cpl.Id;
        vxrec1.PRM_Market_Type_Nm__c = 'NA';
        vxrec1.PRM_Recommendation_Type_Nm__c = 'Upgrade';
        vxrec1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecList.add(vxrec1);
        
        insert vxRecList;  //TWC729-6800 EOL activities
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
            bm.Name='BatchFieldValues';
            bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
            bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
            bm.PRM_SchedulingHour__c=6;
            bm.PRM_NoOfRecords__c=300;
            bm.PRM_NoOfBatchEntRecords__c=10;
            bm.PRM_PartnerRole__c ='Service Provider';
            bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
            bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
            insert bm;

       /* acm1.PRM_Status_Nm__c = 'Inactive';
        
        try{
            update acm1;
        }
        catch(Exception e){
            //system.debug('Test class Exception: '+e.getMessage());
        }*/
        
        PRM_BenefitUtility.assignBenefitsAndEntitlements(accList,true,false,true);
        
        PRM_BenefitUtility.removeVXDataRecords(acmList);//mp
       
        PRM_BenefitsUpdateBatch obj1 = new PRM_BenefitsUpdateBatch();
        Id batchprocessid =DataBase.executeBatch(obj1); 
        Integer actualCount= [Select Count() from PRM_Value_Exchange_Data__c];
      //  system.assertEquals(2,actualCount);
    }
    
     static testMethod void entitlementWithBenefitVXRecommendation() 
    {   
        
        
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();

        String origin  = 'PRM_BenefitUtility';
        String severity  = 'Critical';
        String project  = 'IPA';
        String errorMessage  = 'Too many DML rows';
        boolean sourceCheck;
        
        List<PRM_Specialty__c> listSpciality = new List<PRM_Specialty__c>();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Select Benefits';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        listSpciality.add(spec1);
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Select Benefits';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        listSpciality.add(spec2);

        insert listSpciality; 
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
        
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Industry = 'Agriculture';
        newAccount.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Joshy Rick1';
        newAccount1.BillingCity='Cityu';
        newAccount1.BillingStreet='Streete';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount1.Industry = 'Agriculture';
        newAccount1.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount1);
        
        if(acc != null){
            insert acc;
        }
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.RecordTypeId = recordTypeIdOPIDRec;
        vxRecommnedation1.PRM_Account_Id__c = newAccount.Id;
        vxRecommnedation1.PRM_Tier_Id__c = cpl.Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c = 'Mature';
        vxRecommnedation1.PRM_Grouping_Method_Nm__c = 'CTRY';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c = 'OPID';
        insert vxRecommnedation1;
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation2 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation2.RecordTypeId = recordTypeIdOPIDRec;
        vxRecommnedation2.PRM_Account_Id__c = newAccount1.Id;
        vxRecommnedation2.PRM_Tier_Id__c = cpl.Id;
        vxRecommnedation2.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation2.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxRecommnedation2.PRM_Market_Type_Nm__c = 'Mature';
        vxRecommnedation2.PRM_Grouping_Method_Nm__c = 'CTRY';
        vxRecommnedation2.PRM_Recommendation_Type_Nm__c = 'OPID';
        insert vxRecommnedation2;
        
       

        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        newAccount1.Core_IPA_One_Partner_Id__c = opidAcc.id;
        
        update newAccount;
        update newAccount1;
        
     
            
        List<Core_Account_Group_Member__c> listAccountgroup = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        listAccountgroup.add(coreAccnt) ;
        
        Core_Account_Group_Member__c coreAccnt1 = new Core_Account_Group_Member__c();
        coreAccnt1.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt1.Core_Intel_Account_Id__c = newAccount1.id;
    
        listAccountgroup.add(coreAccnt1) ;

        insert listAccountgroup;
        List<Contact> listcon = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Status__c='Active';
    cont.MailingCountry='India';
        listcon.add(cont);
        
        //system.debug('cont'+cont);
        //system.debug('contId'+cont.Id);
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount1.Id;
        cont1.lastName='Grilladm';
        cont1.FirstName='Adamgril';
        cont1.email='AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Status__c='Active';
    cont1.MailingCountry='India';
        listcon.add(cont1);
        insert listcon;
        
      
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Prestige';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        //Test.startTest();
        List<PRM_PartnerBenefit__c> listPB = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redeem';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb1);

        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Technology Sandbox';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'BFTSNDBX';
        pb2.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb2);

        
        PRM_PartnerBenefit__c pb3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb3.Name = 'Solutions Marketplace Basic Profile';
        pb3.PRM_Channel_Program_Id__c = cp.id;
        pb3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb3.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb3);

        
        PRM_PartnerBenefit__c pb4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb4.Name = 'Solutions Marketplace Enhanced';
        pb4.PRM_Channel_Program_Id__c = cp.id;
        pb4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb4.PRM_Account_Type_Nm__c='Mastered_Account';
        listPB.add(pb4);

        insert listPB;
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount1.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm1;
        
        List<PRM_AccountChannelMembership__c> acmrecords = new List<PRM_AccountChannelMembership__c>();
        Datetime lastModifyDate;
        String lastModifiedBy; 
        acmrecords= [select LastModifiedById,Name,PRM_Status_Change_Dt__c,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c='Approved' limit 1];

         //nj
         PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
         //vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
         vxData1.PRM_Account_Id__c = newAccount.id;
         vxData1.PRM_One_Partner_Id__c = opidAcc.id;
         vxData1.PRM_Tier_Id__c = cpl1.Id;
         vxData1.PRM_Partner_Role_Nm__c =  'Service Provider';
         vxData1.PRM_Country_Market_Type_Nm__c = 'NA';
         vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
         vxData1.PRM_Change_Date_Dt__c = System.today();
         vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
         vxData1.PRM_To_Dt__c =Date.Today();
         insert vxData1;
        //system.debug('acmrecords --->'+acmrecords);
        lastModifyDate = acmrecords[0].PRM_Status_Change_Dt__c;
        lastModifiedBy = acmrecords[0].LastModifiedById;
        //system.debug('LM Date is ' +lastModifyDate);
        //system.debug('LM Id is ' +lastModifiedBy);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        Test.startTest();
        List<PRM_VXBnftMatrix__c> listVXB = new List<PRM_VXBnftMatrix__c>();
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        listVXB.add(bem);
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        listVXB.add(bem1);

        
        PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem2.PRM_Approval_Type_Nm__c='Automatic';
        bem2.PRM_Channel_Program_Id__c=cp.Id;
        bem2.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem2.PRM_Covered_Account_Ind__c=True;
        bem2.PRM_IsActive_Ind__c=True;
        bem2.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem2.PRM_Partner_Type_Id__c=pt.Id;
        bem2.PRM_Partner_Role_Nm__c='Service Provider';
        listVXB.add(bem2);
        insert listVXB;
        
        List<PRM_Benefit_Group__c> listBenefitGoup = new List<PRM_Benefit_Group__c>();
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Speciality Benefit Group 1';
        bg1.PRM_InActive_Ind__c= false;
        listBenefitGoup.add(bg1);
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Speciality Benefit Group 2';
        bg2.PRM_InActive_Ind__c= false;
        listBenefitGoup.add(bg2);
        insert listBenefitGoup;
        //Test.startTest();
        List<PRM_Specialty_Benefit_Group_Association__c> listSBGA = new List<PRM_Specialty_Benefit_Group_Association__c>();
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec2.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        listSBGA.add(testSBGA1);
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=spec2.id;
        testSBGA2.PRM_InActive_Ind__c= false;
        listSBGA.add(testSBGA2);
        insert listSBGA;
        
        List<PRM_Benefit_Group_Benefit_Association__c> listBGBA = new List<PRM_Benefit_Group_Benefit_Association__c>();
        PRM_Benefit_Group_Benefit_Association__c bgba1 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba1.PRM_Benefit_Id__c = pb3.id;
        bgba1.PRM_Benefit_Group_Id__c = bg1.id;
        bgba1.PRM_Start_Date_Dt__c = date.today();
        bgba1.PRM_Status_Nm__c ='Live';
        listBGBA.add(bgba1);
        
        PRM_Benefit_Group_Benefit_Association__c bgba2 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba2.PRM_Benefit_Id__c = pb4.id;
        bgba2.PRM_Benefit_Group_Id__c = bg2.id;
        bgba2.PRM_Start_Date_Dt__c = date.today();
        bgba2.PRM_Status_Nm__c ='Live';
        listBGBA.add(bgba2);
        insert listBGBA;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>(); // Account Benefit Association
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount1.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'Not interested';
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba1.PRM_Account_Id__c = newAccount1.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb2.id;
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c = 'Not interested';
        
        
        PRM_AccountBenefitAssociation__c aba2 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba2.PRM_Account_Id__c = newAccount1.Id;
        aba2.PRM_Partner_Benefit_Id__c = pb1.id;
        aba2.PRM_Status_Nm__c = '';
        aba2.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountBenefitAssociation__c aba3 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba3.PRM_Account_Id__c = newAccount1.Id;
        aba3.PRM_Partner_Benefit_Id__c = pb.id;
        aba3.PRM_Status_Nm__c = 'Active';
        aba3.PRM_Status_Reason_Txt__c = 'Test class';
        
        PRM_AccountBenefitAssociation__c aba4 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba4.PRM_Account_Id__c = newAccount1.Id;
        aba4.PRM_Partner_Benefit_Id__c = pb1.id;
        aba4.PRM_Status_Nm__c = 'Active';
        aba4.PRM_Status_Reason_Txt__c = 'Test class';
        
        //abaList.add(aba);
        //abaList.add(aba1);
        //abaList.add(aba2);
        abaList.add(aba3);
        abaList.add(aba4);
        
        insert abaList;

        //Test.stopTest();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount1.Id;
        acctContRel1.PRM_Contact_Id__c=cont1.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_Status_Nm__c =System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Status_Nm__c='Complete';
        acctContRel1.PRM_Status_Reason_Txt__c = 'Test class';
        Triggerhandler.bypass('PRM_AcctContRel_TriggerHandler');
        insert acctContRel1;
        Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandler');
        //system.debug('acctContRel1-->'+acctContRel1);
        
        //acctContRel1.PRM_Status_Nm__c='Complete';
        //update acctContRel1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        //Test.startTest();
        List<Core_Entitlement__c> listEnt = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Sales PRM- Partner Points Redemption User';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View';
        ed1.Core_Display_Name__c='Sales PRM - Partner University User';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed1);

        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Technology Sandbox';
        ed2.Core_Display_Name__c='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed2);
        
        Core_Entitlement__c ed3=new Core_Entitlement__c(); //Entitlement
        ed3.Name='Intel Premier Support';
        ed3.Core_Display_Name__c='Intel Premier Support';
        ed3.Core_ERPM_Engagement_Id__c=ee.id;
        listEnt.add(ed3);
        insert listEnt;
        
        List<PRM_VXEnttlmntMatrix__c> listEntMatrix = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listEntMatrix.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb1.id;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Contact_Relationship_Id__c = contRelation.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em1.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listEntMatrix.add(em1);

        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Partner_Benefit_Id__c = pb2.id;
        em2.PRM_Entitlement_Id__c = ed2.id;
        em2.PRM_Contact_Relationship_Id__c = contRelation.id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em2.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        listEntMatrix.add(em2);
        insert listEntMatrix;
      
        
        List<PRM_Account_Specialty_Association__c> listASA = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount1.id;
        asa.PRM_Specialty_Id__c= spec2.id;
        asa.PRM_Partner_Role__c='Service Provider';
        listASA.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount1.id;
        asa1.PRM_Specialty_Id__c= spec1.id;
        asa1.PRM_Partner_Role__c='Service Provider';
        listASA.add(asa1);
        insert listASA;
        //Test.stopTest();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont1.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        ceList.add(cce);
        
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=cont1.Id;
        cce1.Core_Entitlement_Id__c = ed1.Id;
        cce1.Core_Status__c='Pending';
        cce1.Core_From_Source__c = true;
        cce1.Core_Source__c = '';
        ceList.add(cce1);

        Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce2.Core_Contact_Id__c=cont1.Id;
        cce2.Core_Entitlement_Id__c = ed2.Id;
        cce2.Core_Status__c='Pending';
        cce2.Core_From_Source__c = true;
        cce2.Core_Selected__c =true;
        
        Core_Contact_Entitlement__c cce3=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce3.Core_Contact_Id__c=cont1.Id;
        cce3.Core_Entitlement_Id__c = ed3.Id;
        cce3.Core_Status__c='Pending';
        cce3.Core_From_Source__c = true;
        cce3.Core_Selected__c =true;
        ceList.add(cce3);

        Triggerhandler.bypass('Core_Contact_EntitlementTriggerHandler');
        insert ceList;
        Triggerhandler.clearbypass('Core_Contact_EntitlementTriggerHandler');
    
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont1.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
        be.PRM_Status_Reason_Txt__c = 'Test class';
        be.PRM_IsRemove_Ind__c = false;
        beList.add(be);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =cont1.Id;
        be1.PRM_Entitlement_Id__c =ed1.Id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_Status_Reason_Txt__c = 'Test class';
        beList.add(be1);
        
        PRM_Batch_Entitlement__c be2 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be2.PRM_Contact_Id__c =cont1.Id;
        be2.PRM_Entitlement_Id__c =ed2.Id;
        be2.PRM_Status_Nm__c = 'New';
        be2.PRM_Status_Reason_Txt__c = 'Test class';
        be2.PRM_IsRemove_Ind__c = true;
        
        PRM_Batch_Entitlement__c be3 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be3.PRM_Contact_Id__c =cont1.Id;
        be3.PRM_Entitlement_Id__c =ed3.Id;
        be3.PRM_Status_Nm__c = 'New';
        be3.PRM_Status_Reason_Txt__c = 'Test class';
        be3.PRM_IsRemove_Ind__c = true;
        beList.add(be2);
        
        try{ 
            //Test.startTest();           
            insert beList;
            PRM_EntitlementUtility.assignContactEntitlements(null);
            //PRM_EntitlementDQUtility.assignContactEntitlements(null);
        }
        catch(Exception ce){
            //system.debug('Exception Occured');
        }
        
        
        PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,true,false,true );
        PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,false,true,true);
        PRM_BenefitsUpdateBatch obj = new PRM_BenefitsUpdateBatch();
        Id batchprocessid =DataBase.executeBatch(obj);
        //PRM_EntitlementUtility.assignContactEntitlements(beList);
        Test.stopTest();
       // PRM_Contact_Entitlements_Insert_batch ce = new PRM_Contact_Entitlements_Insert_batch();
        //Id bpid =DataBase.executeBatch(ce);     
        
        be2.PRM_IsRemove_Ind__c = true;
        PRM_EntitlementUtility.assignContactEntitlements(new List<PRM_Batch_Entitlement__c>{be2});
        //PRM_EntitlementDQUtility.assignContactEntitlements(new List<PRM_Batch_Entitlement__c>{be3});
        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob];
        PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm2.PRM_Account_Id__c=newAccount1.id;
        acm2.PRM_Status_Nm__c='Inactive';
        acm2.PRM_Status_Reason_Txt__c = 'Test class';
        acm2.PRM_Channel_Program_Id__c=cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm2;
        
        List<PRM_AccountChannelMembership__c> acmrecords1= [select LastModifiedById,PRM_Account_Id__c,PRM_Channel_Program_Id__c,Name,PRM_Status_Change_Dt__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c='Inactive' limit 1];
        PRM_BenefitUtility.removeVXDataRecords(acmrecords1);
        System.assertEquals(acctContRel1.PRM_Account_Id__c,newAccount1.Id,'Value does not match'); 
    }
}