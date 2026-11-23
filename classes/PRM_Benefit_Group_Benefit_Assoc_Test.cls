/****************************************************************************************************************************
Apex Class Name     : PRM_Benefit_Group_Benefit_Assoc_Test 
Version             : 1.0
Created Date        : Dec 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      3-Dec-2019                   Added a new method testduplicateRecordCheck, to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
@isTest()
public class PRM_Benefit_Group_Benefit_Assoc_Test {
    
    static testmethod void testduplicateRecordCheck(){
        
        Test.startTest();
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        insert bg;
        //system.debug('bg========>'+bg);
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //system.debug('cp-->'+cp);
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        insert pb;
        //system.debug('pb========>'+pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Accruals – View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        insert pb1;
        
        PRM_Benefit_Group_Benefit_Association__c bgba = new PRM_Benefit_Group_Benefit_Association__c();
        bgba.PRM_Benefit_Id__c = pb.id;
        bgba.PRM_Benefit_Group_Id__c= bg.id;
        bgba.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba;
        Test.stopTest(); 
        PRM_Benefit_Group_Benefit_Association__c bgba2 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba2.PRM_Benefit_Id__c = pb.id;
        bgba2.PRM_Benefit_Group_Id__c= bg.id;
        bgba2.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba2.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
       
        try{ 
            insert bgba2;
        }
        catch(exception e){
            //system.debug('Exception occured' +e.getMessage());
        }
        
        
        System.assertEquals(bg.id,bgba2.PRM_Benefit_Group_Id__c,'BGBA record should be inserted');
        
    }    
    
    static testmethod void updatetestduplicateRecordCheck(){
        
        test.startTest();
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //system.debug('cp-->'+cp);
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        insert pb;
        //system.debug('pb========>'+pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Accruals – View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        insert pb1;
        
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test3';
        insert bg;
        //system.debug('bg========>'+bg);
        
        PRM_Benefit_Group_Benefit_Association__c bgba = new PRM_Benefit_Group_Benefit_Association__c();
        bgba.PRM_Benefit_Id__c = pb.id;
        bgba.PRM_Benefit_Group_Id__c= bg.id;
        bgba.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba;
        
        PRM_Benefit_Group_Benefit_Association__c bgba2 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba2.PRM_Benefit_Id__c = pb1.id;
        bgba2.PRM_Benefit_Group_Id__c= bg.id;
        bgba2.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba2.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba2;
        
        try{
            bgba2.PRM_Benefit_Id__c=pb.id;
            update bgba2;
        }
        Catch(exception e){
            //system.debug('Exception occured' +e.getMessage());
        }
        test.stopTest();
        
        System.assertEquals(pb.id,bgba2.PRM_Benefit_Id__c,'BGBA should be updated with a benefit');
    } 
    
    @isTest static void updateBenefitOnAccount(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount;
        
        List<PRM_Specialty__c> specList = new List<PRM_Specialty__c>();
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Select Benefits';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Partner';//'Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        //insert spec1;
        specList.add(spec1);
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Select Benefits';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Partner';//'Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        //insert spec2;
        specList.add(spec2);
        insert specList;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c='Test';
        //acctChnlMemTest.PRM_IsActive_Ind__c = True;
        insert acctChnlMemTest;
        
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Partner University';
        pbTest.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pbTest.PRM_InActive_Ind__c = false;
        pbTest.PRM_Channel_Program_Id__c= cpTest.Id;
       	pbTest.PRM_Account_Type_Nm__c='Both';
        insert pbTest;
        
        PRM_PartnerBenefit__c pbTest1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest1.Name = 'Marketing Studio';
        pbTest1.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pbTest1.PRM_InActive_Ind__c = false;
        pbTest1.PRM_Channel_Program_Id__c= cpTest.Id;
        pbTest1.PRM_Account_Type_Nm__c = 'Both';
        insert pbTest1;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cpTest.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
        PRM_VXBnftMatrix__c bmTest = new PRM_VXBnftMatrix__c();
        bmTest.PRM_Partner_Benefit_Id__c = pbTest.Id;
        bmTest.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest.PRM_Covered_Account_Ind__c = true;
        bmTest.PRM_IsActive_Ind__c = true;
        bmTest.PRM_Partner_Role_Nm__c='Service Provider';
        insert bmTest;
       
        PRM_AccountBenefitAssociation__c abassociationTest = new PRM_AccountBenefitAssociation__c();
        abassociationTest.PRM_Account_Id__c = testAccount.id;
        abassociationTest.PRM_Partner_Benefit_Id__c = pbTest.id;
        abassociationTest.PRM_Status_Nm__c = 'Active';
        abassociationTest.PRM_Status_Reason_Txt__c='Test';
        insert abassociationTest;
        
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Sheetal Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Sheetal Test2';
        bg2.PRM_InActive_Ind__c= false;
        insert bg2;
        
        Test.startTest();
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=specList[0].id;
        testSBGA1.PRM_InActive_Ind__c= false;
        insert testSBGA1;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=specList[0].id;
        testSBGA2.PRM_InActive_Ind__c= false;
        insert testSBGA2;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA3 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA3.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA3.PRM_Specialty_Id__c=specList[1].id;
        testSBGA3.PRM_InActive_Ind__c= false;
        insert testSBGA3;
        
        List<PRM_Account_Specialty_Association__c> specialityList = new List<PRM_Account_Specialty_Association__c>();
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= testAccount.id;
        asa.PRM_Specialty_Id__c= specList[0].id;
        asa.PRM_InActive_Ind__c= false;
        specialityList.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= testAccount.id;
        asa1.PRM_Specialty_Id__c= specList[0].id;
        asa1.PRM_InActive_Ind__c= false;
        specialityList.add(asa1);
        
        insert specialityList;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA1 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA1.PRM_Benefit_Id__c = pbTest.id;
        bGBA1.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA1.PRM_Start_Date_Dt__c = date.today();
        bGBA1.PRM_Status_Nm__c ='Live';
        insert bGBA1;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA2 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA2.PRM_Benefit_Id__c = pbTest1.id;
        bGBA2.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA2.PRM_Start_Date_Dt__c = date.today();
        bGBA2.PRM_Status_Nm__c ='Live';
        insert bGBA2;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA3 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA3.PRM_Benefit_Id__c = pbTest1.id;
        bGBA3.PRM_Benefit_Group_Id__c = bg2.id;
        bGBA3.PRM_Start_Date_Dt__c = date.today();
        bGBA3.PRM_Status_Nm__c ='Live';
        insert bGBA3;
        
        
        
        List<PRM_Benefit_Group_Benefit_Association__c> lstOfBgba = new List<PRM_Benefit_Group_Benefit_Association__c>(); 
        BGBA1.PRM_InActive_Ind__c =True;
        lstOfBgba.add(BGBA1);
        BGBA2.PRM_InActive_Ind__c =True;
        lstOfBgba.add(BGBA2);
        BGBA3.PRM_InActive_Ind__c =True;
        lstOfBgba.add(BGBA3);
        
        update (lstOfBgba);
        Test.stopTest();
        System.assertNotEquals(Null,lstOfBgba,'List of BGBA should contain records');
    }
        static testmethod void memberBenefitAssign(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
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
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount1);
        
        if(acc != null){
            insert acc;
        }
        //Entitlment flow Start
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry = 'USA';
        
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='Grilladm';
        cont1.FirstName='Adamgril';
        cont1.email='AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.MailingCountry = 'USA';
        insert cont1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
         
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Reason_Txt__c='Test';
        insert acm1;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Solution Marketplace Basic Access';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
        //pb.PRM_Account_Type_Nm__c='Both';
        insert pb;
        //system.debug('pb========>'+pb);
        
        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb1.Name = 'Points Accruals – View';
        pb1.PRM_Channel_Program_Id__c = cp.id;
        pb1.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        //pb1.PRM_Account_Type_Nm__c='Both';
        insert pb1;
        
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
        insert bm;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount.Id;
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
            
        Core_Entitlement__c ed4=new Core_Entitlement__c(); //Entitlement
        ed4.Name='CIP VIP View';
        ed4.Core_Display_Name__c='CIP VIP View';
        ed4.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed4;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em.PRM_IsActive_Ind__c= true;
        insert em;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb1.id;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em1.PRM_Contact_Relationship_Id__c = contRelation.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
            em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em1.PRM_IsActive_Ind__c = true;
        insert em1;
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Partner_Benefit_Id__c = pb1.id;
        em2.PRM_Entitlement_Id__c = ed2.id;
        em2.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em2.PRM_Contact_Relationship_Id__c = contRelation.id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em2.PRM_IsActive_Ind__c = true;
        insert em2;
        
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
        be1.PRM_IsRemove_Ind__c = True;
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
        
         Core_ERPM_Engagement__c ee1 = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee1.Name = 'Intel Partner Alliance';
        ee1.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee1.Core_Engagement_Type__c = 'SEC';
        insert ee1;
        // this is throwing error of duplicate records-
        /*Core_Entitlement__c ed3 = new Core_Entitlement__c(); //Entitlement
        ed3.Name='CIP VIP View';
        ed3.Core_Display_Name__c='CIP VIP View';
        ed3.Core_ERPM_Engagement_Id__c=ee1.id;
        insert ed3; */
        
        PRM_VXEnttlmntMatrix__c em3 = new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix withou benefit
        em3.RecordTypeId = recordTypeIdEM;
        em3.PRM_Entitlement_Id__c = ed4.id;
        em3.PRM_Contact_Relationship_Id__c = contRelation.id;
        em3.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em3.PRM_Approval_Type_Nm__c='Automatic';
        em3.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em3.PRM_IsActive_Ind__c= true;
        insert em3;
        
        //List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        
        PRM_Batch_Entitlement__c be3 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be3.PRM_Contact_Id__c =cont.Id;
        be3.PRM_Entitlement_Id__c =ed.Id;
        be3.PRM_Status_Nm__c = 'New';
        beList.add(be3);
        
       // List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=cont.Id;
        cce1.Core_Entitlement_Id__c = ed.Id;
        cce1.Core_Status__c='Pending';
        cce1.Core_Selected__c = true;
        cce1.Core_Data_Loaded__c = true;
        cce1.Core_DontNotify__c = true;
        cce1.Core_From_Source__c = false;
        ceList.add(cce1);
        
        Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce2.Core_Contact_Id__c=cont.Id;
        cce2.Core_Entitlement_Id__c = ed1.Id;
        cce2.Core_Status__c='Pending';
        cce2.Core_Selected__c = false;
        cce2.Core_Data_Loaded__c = true;
        cce2.Core_DontNotify__c = true;
        cce2.Core_From_Source__c = false;
        ceList.add(cce2);
        Test.startTest();              
         if(beList != null && !beList.IsEmpty()){
                insert beList;
                insert ceList;
            }
            
           
            //entitlment flow end
        
        // Speciality to benefit flow Start
        
        PRM_Specialty__c spec = new PRM_Specialty__c(); //speciality
        spec.name='Select Benefits';
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider;Distributor';
        spec.PRM_Tier_Nm__c='Partner';//'Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c(); //speciality
        spec1.name='Addition Select Benefit';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Partner';//'Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Sheetal Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Sheetal Test2';
        bg2.PRM_InActive_Ind__c= false;
        insert bg2;
        
           
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        insert testSBGA1;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=spec1.id;
        testSBGA2.PRM_InActive_Ind__c= false;
        insert testSBGA2;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA3 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA3.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA3.PRM_Specialty_Id__c=spec1.id;
        testSBGA3.PRM_InActive_Ind__c= false;
        insert testSBGA3; 
        
        
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        insert bg;
        //system.debug('bg========>'+bg);
        
        PRM_Specialty_Benefit_Group_Association__c sbga = new PRM_Specialty_Benefit_Group_Association__c();
        sbga.PRM_Benefit_Group_Id__c=bg.id;
        sbga.PRM_Specialty_Id__c=spec.id;
        sbga.PRM_Start_Date_Dt__c= system.today() + 5;
        sbga.PRM_End_Date_Dt__c= sbga.PRM_Start_Date_Dt__c + 7;
        insert sbga;
        
               //Insertion of ASA
        List<PRM_Account_Specialty_Association__c> lstOfAsa = new List<PRM_Account_Specialty_Association__c>();
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        asa.PRM_InActive_Ind__c = FALSE;
        lstOfAsa.add(asa);
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= newAccount.id;
        asa1.PRM_Specialty_Id__c= spec1.id;
        asa1.PRM_InActive_Ind__c = FALSE;
        lstOfAsa.add(asa1);
        
       /*  PRM_Account_Specialty_Association__c asa2 = new PRM_Account_Specialty_Association__c();
        asa2.PRM_Account_Id__c= newAccount1.id;
        asa2.PRM_Specialty_Id__c= spec.id;
        asa2.PRM_InActive_Ind__c = FALSE;
        lstOfAsa.add(asa2);*/
         
        if(lstOfAsa != null && !lstOfAsa.isEmpty()){
            insert lstOfAsa;
        }
        
       
      
        PRM_Benefit_Group_Benefit_Association__c bgba = new PRM_Benefit_Group_Benefit_Association__c();
        bgba.PRM_Benefit_Id__c = pb.id;
        bgba.PRM_Benefit_Group_Id__c= bg.id;
        bgba.PRM_Status_Nm__c = 'Live';
        bgba.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba;
        
        PRM_Benefit_Group_Benefit_Association__c bgba1 = new PRM_Benefit_Group_Benefit_Association__c();
        bgba1.PRM_Benefit_Id__c = pb1.id;
        bgba1.PRM_Benefit_Group_Id__c= bg.id;
        bgba1.PRM_Status_Nm__c = 'Live';
        bgba1.PRM_Start_Date_Dt__c= system.today() + 5;
        bgba1.PRM_End_Date_Dt__c= bgba.PRM_Start_Date_Dt__c + 7;
        insert bgba1;
        
       System.assertEquals('Live',bgba1.PRM_Status_Nm__c,'Value Should Match');
        Test.stopTest(); 
        
            
    }
        
}