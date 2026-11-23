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
    static testMethod void entitlementWithBenefit() 
    {   
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        String origin  = 'PRM_BenefitUtility';
        String severity  = 'Critical';
        String project  = 'IPA';
        String errorMessage  = 'Too many DML rows';
        boolean sourceCheck;
        
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Video Specialty';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Cloud Data Center Specialist';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        insert spec2;
        
        
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Joshy Rick1';
        newAccount1.BillingCity='Cityu';
        newAccount1.BillingStreet='Streete';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_IPA_Partner_Speciality__c='Video Specialty;Cloud Data Center Specialist';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc.add(newAccount1);
        
        if(acc != null){
            insert acc;
        }
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_Partner_Role__c = 'Service Provider';
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount1.Id;
        cont1.lastName='Grilladm';
        cont1.FirstName='Adamgril';
        cont1.email='AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_Partner_Role__c = 'Service Provider';
        insert cont1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Titanium';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        //pb.PRM_Account_Type_Nm__c='Both';
        insert pb;
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Partner University';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        //pb1.PRM_Account_Type_Nm__c='Both';
        insert pb1;
        
        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb2.Name = 'Technology Sandbox';
        pb2.PRM_Channel_Program_Id__c = cp.id;
        pb2.PRM_Benefit_Cd__c = 'BFTSNDBX';
        //pb2.PRM_Account_Type_Nm__c='Both';
        insert pb2;
        
        PRM_PartnerBenefit__c pb3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb3.Name = 'Solutions Marketplace Basic Profile';
        pb3.PRM_Channel_Program_Id__c = cp.id;
        pb3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        //pb3.PRM_Account_Type_Nm__c='Both';
        insert pb3;
        
        PRM_PartnerBenefit__c pb4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb4.Name = 'Solutions Marketplace Enhanced';
        pb4.PRM_Channel_Program_Id__c = cp.id;
        pb4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        //pb4.PRM_Account_Type_Nm__c='Both';
        insert pb4;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount1.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        insert acm1;
        
        List<PRM_AccountChannelMembership__c> acmrecords = new List<PRM_AccountChannelMembership__c>();
        Datetime lastModifyDate;
        String lastModifiedBy;
        acmrecords= [select LastModifiedById,Name,PRM_Status_Change_Dt__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c='Approved' limit 1];
        System.debug('acmrecords --->'+acmrecords);
        lastModifyDate = acmrecords[0].PRM_Status_Change_Dt__c;
        lastModifiedBy = acmrecords[0].LastModifiedById;
        System.debug('LM Date is ' +lastModifyDate);
        System.debug('LM Id is ' +lastModifiedBy);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium;Member';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider'; 
        insert bm;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Automatic';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb1.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem1;
        
        PRM_VXBnftMatrix__c bem2=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem2.PRM_Approval_Type_Nm__c='Automatic';
        bem2.PRM_Channel_Program_Id__c=cp.Id;
        bem2.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem2.PRM_Covered_Account_Ind__c=True;
        bem2.PRM_IsActive_Ind__c=True;
        bem2.PRM_Partner_Benefit_Id__c=pb2.Id;
        bem2.PRM_Partner_Type_Id__c=pt.Id;
        bem2.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem2;
        
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Speciality Benefit Group 1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Speciality Benefit Group 2';
        bg2.PRM_InActive_Ind__c= false;
        insert bg2;
        
        List<PRM_Specialty_Benefit_Group_Association__c> lstOfSbga = new List<PRM_Specialty_Benefit_Group_Association__c>();
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec1.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        lstOfSbga.add(testSBGA1);
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=spec2.id;
        testSBGA2.PRM_InActive_Ind__c= false;
        lstOfSbga.add(testSBGA2);
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA3 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA3.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA3.PRM_Specialty_Id__c=spec1.id;
        testSBGA3.PRM_InActive_Ind__c= false;
        lstOfSbga.add(testSBGA3);
        
        insert lstOfSbga;
        
        List<PRM_Benefit_Group_Benefit_Association__c> listOfBgba = new List<PRM_Benefit_Group_Benefit_Association__c>();
        PRM_Benefit_Group_Benefit_Association__c bgba1 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba1.PRM_Benefit_Id__c = pb3.id;
        bgba1.PRM_Benefit_Group_Id__c = bg1.id;
        bgba1.PRM_Start_Date_Dt__c = date.today();
        bgba1.PRM_Status_Nm__c ='Live';
        listOfBgba.add(bgba1);
        
        PRM_Benefit_Group_Benefit_Association__c bgba2 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba2.PRM_Benefit_Id__c = pb4.id;
        bgba2.PRM_Benefit_Group_Id__c = bg2.id;
        bgba2.PRM_Start_Date_Dt__c = date.today();
        bgba2.PRM_Status_Nm__c ='Live';
        listOfBgba.add(bgba2);
        
        PRM_Benefit_Group_Benefit_Association__c bgba3 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba3.PRM_Benefit_Id__c = pb3.id;
        bgba3.PRM_Benefit_Group_Id__c = bg2.id;
        bgba3.PRM_Start_Date_Dt__c = date.today();
        bgba3.PRM_Status_Nm__c ='Live';
        listOfBgba.add(bgba3);
        
        insert listOfBgba;
        
        List<PRM_Account_Specialty_Association__c> lstOfAsa = new List<PRM_Account_Specialty_Association__c>();
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount1.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c='Service Provider';
        lstOfAsa.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount1.id;
        asa1.PRM_Specialty_Id__c= spec2.id;
        asa1.PRM_Partner_Role__c='Service Provider';
        lstOfAsa.add(asa1);
        
        PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
        asa2.PRM_Account_Id__c= newAccount.id;
        asa2.PRM_Specialty_Id__c= spec2.id;
        asa2.PRM_Partner_Role__c='Service Provider';
        lstOfAsa.add(asa2);
        
        insert lstOfAsa;
        
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
        
        PRM_AccountBenefitAssociation__c aba3 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba3.PRM_Account_Id__c = newAccount1.Id;
        aba3.PRM_Partner_Benefit_Id__c = pb3.id;
        aba3.PRM_Status_Nm__c = 'Active';
        
        PRM_AccountBenefitAssociation__c aba4 = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba4.PRM_Account_Id__c = newAccount1.Id;
        aba4.PRM_Partner_Benefit_Id__c = pb4.id;
        aba4.PRM_Status_Nm__c = 'Active';
        
        abaList.add(aba);
        abaList.add(aba1);
        abaList.add(aba2);
        abaList.add(aba3);
        abaList.add(aba4);
        
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
        insert acctContRel1;
        
        acctContRel1.PRM_Status_Nm__c='Complete';
        update acctContRel1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
         
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Sales PRM- Partner Points Redemption User';
        ed.Core_Display_Name__c='Sales PRM- Partner Points Redemption User';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Sales PRM - Partner University User';
        ed1.Core_Display_Name__c='Sales PRM - Partner University User';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed1;
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_Display_Name__c='Sales PRM- Partner Technology Sandbox User';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed2;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb1.id;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Contact_Relationship_Id__c = contRelation.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_Partner_Role_Nm__c='Service Provider';
        insert em1;
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Partner_Benefit_Id__c = pb2.id;
        em2.PRM_Entitlement_Id__c = ed2.id;
        em2.PRM_Contact_Relationship_Id__c = contRelation.id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_Partner_Role_Nm__c='Service Provider';
        insert em2;
        
         Test.startTest();
        
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont1.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
        beList.add(be);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =cont1.Id;
        be1.PRM_Entitlement_Id__c =ed1.Id;
        be1.PRM_Status_Nm__c = 'New';
        beList.add(be1);
        
        PRM_Batch_Entitlement__c be2 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be2.PRM_Contact_Id__c =cont1.Id;
        be2.PRM_Entitlement_Id__c =ed2.Id;
        be2.PRM_Status_Nm__c = 'New';
        beList.add(be2);
        
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont1.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        ceList.add(cce);
        
        try{
            if(beList != null && !beList.IsEmpty()){
                insert beList;
                insert ceList;
            }
        }
        catch(Exception ce){
            System.debug('Exception Occured');
        }
        PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,true,false,true);
        PRM_BenefitsUpdateBatch obj = new PRM_BenefitsUpdateBatch();
        Id batchprocessid =DataBase.executeBatch(obj);
        PRM_EntitlementUtility.assignContactEntitlements(beList);
        PRM_Contact_Entitlements_Insert_batch ce = new PRM_Contact_Entitlements_Insert_batch();
        Id bpid =DataBase.executeBatch(ce);     
        PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,false,true,true);
        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob];
        //aba.PRM_Status_Nm__c = 'Active';
        //update aba;
        test.stopTest();
        
        System.assertEquals(acctContRel1.PRM_Account_Id__c,newAccount1.Id,'Value does not match'); 
    }
    static testMethod void entitlementWithoutBenefit() 
    {
        //Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        boolean sourceCheck;
        
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_IPA_Partner_Speciality__c='Video Specialty;Cloud Data Center Specialist';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
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
        cont.Core_IPA_Partner_Role__c = 'Service Provider';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Video Specialty';
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
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        //pb.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pb;
        
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Points Redemption to Check';
        pbTest.PRM_Benefit_Cd__c = 'BFTP';
        pbTest.PRM_InActive_Ind__c = false;
        //pbTest.PRM_Account_Type_Nm__c='Mastered_Account';
        insert pbTest;
        
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
        
        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = newAccount.Id;
        aba1.PRM_Partner_Benefit_Id__c = pbTest.id;
        aba1.PRM_Status_Nm__c = 'Active';
        //insert aba1;
        
        aba.PRM_Status_Nm__c = 'Inactive';
        update aba;
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium;Member';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider'; 
        insert bm;
        
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
        insert acctContRel;
        
        acctContRel.PRM_Status_Nm__c ='Complete';
        update acctContRel;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='CIP VIP View';
        ed.Core_Display_Name__c='CIP VIP View';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
        beList.add(be);
        
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        cce.Core_Selected__c = true;
        cce.Core_Data_Loaded__c = true;
        cce.Core_DontNotify__c = true;
        cce.Core_From_Source__c = false;
        ceList.add(cce);
        
        Test.startTest();
        
        try{
            if(beList != null && !beList.IsEmpty()){
                insert beList;
                insert ceList;
                aba.PRM_Status_Nm__c = 'Inactive';
                update aba;
                aba.PRM_Status_Nm__c = 'Active';
                update aba;
            }
        }
        catch(Exception ce){
            System.debug('Exception Occured');
        }
        Test.stopTest();
        
        PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,true,false,true);
        PRM_BenefitsUpdateBatch obj = new PRM_BenefitsUpdateBatch();
        Id batchprocessid =DataBase.executeBatch(obj); 
        PRM_EntitlementUtility.assignContactEntitlements(beList);
        PRM_Contact_Entitlements_Insert_batch ce = new PRM_Contact_Entitlements_Insert_batch();
        Id bpid =DataBase.executeBatch(ce);
        //PRM_BenefitUtility.assignBenefitsAndEntitlements(acc,false,true,true);
        List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob];
        
        System.assertEquals(acctContRel.PRM_Account_Id__c,newAccount.Id,'Value does not match');
    }
}