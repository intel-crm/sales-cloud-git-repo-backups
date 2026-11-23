@isTest
public class PRM_ABA_Utility_Test {
    
    // public static Boolean ipaRefresh = boolean.valueOf(System.label.PRM_IPARefresh);

    @testSetup
    static void setup(){
        prm_skip_trigger__c sk = new prm_skip_trigger__c();
        sk.Name='ABA_Trigger';
        sk.inactive__c= false;
        insert sk;
    }
    
    @istest static void testRelatedABARecords(){
        list<account> testAccLst=new list<account>();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //sheetal changes start
        
        PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige;Partner';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        // testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.abc.com';  
        testAccLst.add(testAccount);
        // insert testAccount;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent1.website='www.abc.com';
        parent1.Core_User_Defined_Website__c='www.abc.com';
        testAccLst.add(parent1);
        // insert parent1;
        
        Account parent2 = new Account();
        parent2.RecordTypeId = OpidAccRecordTypeId;
        parent2.Name='Oswol Ltd';
        parent2.BillingCity='wills City';
        parent2.BillingStreet='wills Street';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='999998';
        parent2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent2.website='www.abc.com';
        parent2.Core_User_Defined_Website__c='www.abc.com';
        testAccLst.add(parent2);
        //insert parent2;
        
        insert testAccLst;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount.id;
        insert coreAccnt;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.MailingCountry='IND';
        insert cont;
        
        list<sObject> prmObjLst=new list<sObject>();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Select Benefits';  
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        prmObjLst.add(spec1);
        // insert spec1;
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Select Benefits';  
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        prmObjLst.add(spec2);
        // insert spec2;
        
        
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Sheetal Test1';
        bg1.PRM_InActive_Ind__c= false;
        prmObjLst.add(bg1);
        //  insert bg1;
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Sheetal Test2';
        bg2.PRM_InActive_Ind__c= false;
        prmObjLst.add(bg2);
        // insert bg2;
        insert  prmObjLst;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        ChannelProgramLevel cplTest1= new ChannelProgramLevel(); //Channel Program Level
        cplTest1.Name='Partner';
        cplTest1.ProgramId=cpTest.Id;
        insert cplTest1;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Points Redemption to Check';
        pbTest.PRM_Benefit_Cd__c = 'BFTP';
        pbTest.PRM_InActive_Ind__c = false;
        pbTest.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest);
        
        PRM_PartnerBenefit__c pbTest1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest1.Name = 'Points Redemption Check';
        pbTest1.PRM_Benefit_Cd__c = 'STRES';
        pbTest1.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest1.PRM_InActive_Ind__c = false;
        pbTest1.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest1);
        
        PRM_PartnerBenefit__c pbTest2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest2.Name = 'Solution Marketplace Basic Access';
        pbTest2.PRM_Benefit_Cd__c = 'BNFTSMBA';
        pbTest2.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest2.PRM_InActive_Ind__c = false;
        pbTest2.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest2);
        
        PRM_PartnerBenefit__c pbTest3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest3.Name = 'Solutions Marketplace Basic Profile';
        pbTest3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTest3.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest3.PRM_InActive_Ind__c = false;
        pbTest3.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest3);
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        insert pbList;
        
        List<PRM_Specialty_Benefit_Group_Association__c> lstOfSbga = new List<PRM_Specialty_Benefit_Group_Association__c>();
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec1.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        lstOfSbga.add(testSBGA1);
        // insert testSBGA1;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=spec1.id;
        testSBGA2.PRM_InActive_Ind__c= false;
        lstOfSbga.add(testSBGA2);
        //insert testSBGA2;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA3 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA3.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA3.PRM_Specialty_Id__c=spec2.id;
        testSBGA3.PRM_InActive_Ind__c= false;
        lstOfSbga.add(testSBGA3);
        insert lstOfSbga;
        
        List<PRM_Benefit_Group_Benefit_Association__c> lstOfBgba = new List<PRM_Benefit_Group_Benefit_Association__c>();
        PRM_Benefit_Group_Benefit_Association__c bGBA1 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA1.PRM_Benefit_Id__c = pbTest.id;
        bGBA1.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA1.PRM_Start_Date_Dt__c = date.today();
        bGBA1.PRM_Status_Nm__c ='Live';
        lstOfBgba.add(bGBA1);
        //insert bGBA1;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA2 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA2.PRM_Benefit_Id__c = pbTest1.id;
        bGBA2.PRM_Benefit_Group_Id__c = bg1.id;
        bGBA2.PRM_Start_Date_Dt__c = date.today();
        bGBA2.PRM_Status_Nm__c ='Live';
        lstOfBgba.add(bGBA2);
        // insert bGBA2;
        
        PRM_Benefit_Group_Benefit_Association__c bGBA3 = new PRM_Benefit_Group_Benefit_Association__c();
        bGBA3.PRM_Benefit_Id__c = pbTest1.id;
        bGBA3.PRM_Benefit_Group_Id__c = bg2.id;
        bGBA3.PRM_Start_Date_Dt__c = date.today();
        bGBA3.PRM_Status_Nm__c ='Live';
        lstOfBgba.add(bGBA3);
        insert lstOfBgba;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest1);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent2.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cpTest.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
        List<PRM_VXBnftMatrix__c> lstOfBnftMatrix = new List<PRM_VXBnftMatrix__c>();
        
        PRM_VXBnftMatrix__c bmTest = new PRM_VXBnftMatrix__c();
        bmTest.PRM_Partner_Benefit_Id__c = pbTest1.Id;
        bmTest.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest.PRM_Covered_Account_Ind__c = true;
        bmTest.PRM_IsActive_Ind__c = true;
        bmTest.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest);
        // insert bmTest;
        
        PRM_VXBnftMatrix__c bmTest1 = new PRM_VXBnftMatrix__c();
        bmTest1.PRM_Partner_Benefit_Id__c = pbTest3.Id;
        bmTest1.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest1.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest1.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest1.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest1.PRM_Covered_Account_Ind__c = true;
        bmTest1.PRM_IsActive_Ind__c = true;
        bmTest1.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest1);
        //insert bmTest1;
        
        
        PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest2.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest2);
        //insert bmTest2;
        
        PRM_VXBnftMatrix__c bmTest3 = new PRM_VXBnftMatrix__c();
        bmTest3.PRM_Partner_Benefit_Id__c = pbTest2.Id;
        bmTest3.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest3.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest3.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest3.PRM_Covered_Account_Ind__c = true;
        bmTest3.PRM_IsActive_Ind__c = true;
        bmTest3.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest3);
        insert lstOfBnftMatrix;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'IPA';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee; 
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Sales PRM - Partner Points Viewer';
        ed.Core_Display_Name__c='Sales PRM - Partner Points Viewer';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest1.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Distributor';
        // em.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        insert em;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= testaccount.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;
        // test.stopTest();
        // Test.startTest();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Reason_Txt__c = 'For test class';
        insert acctContRel;
        
        test.startTest();
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
        be.PRM_Contact_Id__c = cce.Id;
        be.PRM_Entitlement_Id__c = cce.Core_Entitlement_Id__c;
        be.PRM_Status_Nm__c = 'New';
        be.PRM_Status_Reason_Txt__c = 'Test';
        be.PRM_IsRemove_Ind__c = true;
       
        Map<Id,PRM_AccountBenefitAssociation__c> abaMap=new Map<Id,PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> abaListnew = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abassociationTest = new PRM_AccountBenefitAssociation__c();
        abassociationTest.PRM_Account_Id__c = testAccount.id;
        abassociationTest.PRM_Partner_Benefit_Id__c = pbTest1.id;
        abassociationTest.PRM_Status_Nm__c = 'Active';
        abassociationTest.PRM_Status_Reason_Txt__c = 'Test';
        abaList.add(abassociationTest);
        
        PRM_AccountBenefitAssociation__c abassociationTest1 = new PRM_AccountBenefitAssociation__c();
        abassociationTest1.PRM_Account_Id__c = parent1.id;
        abassociationTest1.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest1.PRM_Status_Nm__c = 'Active';
        abassociationTest1.PRM_Status_Reason_Txt__c = 'Test';
        abaListnew.add(abassociationTest1);
        
        //    test.startTest();        
        PRM_AccountBenefitAssociation__c abassociationTest12 = new PRM_AccountBenefitAssociation__c();
        abassociationTest12.PRM_Account_Id__c = parent2.id;
        abassociationTest12.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest12.PRM_Status_Nm__c = 'Active';
        abassociationTest12.PRM_Status_Reason_Txt__c = 'Test';
        abaListnew.add(abassociationTest12);
        abaMap.put(parent2.id,abassociationTest12);
        insert abaListnew;
        
        
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = parent2.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abassociationTest2.PRM_Status_Reason_Txt__c = 'Test';
        abaList.add(abassociationTest2);
        
        PRM_AccountBenefitAssociation__c abassociationTest3 = new PRM_AccountBenefitAssociation__c();
        abassociationTest3.PRM_Account_Id__c = testAccount.id;
        abassociationTest3.PRM_Partner_Benefit_Id__c = pbTest2.id;
        abassociationTest3.PRM_Status_Nm__c = 'Inactive';
        abassociationTest3.PRM_Status_Reason_Txt__c='Testing';
        abaList.add(abassociationTest3);
        
        PRM_AccountBenefitAssociation__c abassociationTest4 = new PRM_AccountBenefitAssociation__c();
        abassociationTest4.PRM_Account_Id__c = parent1.id;
        abassociationTest4.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest4.PRM_Status_Nm__c = 'Active';
        abassociationTest4.PRM_Status_Reason_Txt__c = 'Test';
        abaList.add(abassociationTest4);
        insert abaList;
        
        
        abassociationTest3.PRM_Status_Nm__c='Active';
        abassociationTest3.PRM_Status_Reason_Txt__c='Testing';
        
        update abassociationTest3; 
        PRM_accBenefitAssociationUtility.onStatusInactive(abaList);
        PRM_accBenefitAssociationUtility.onStatusInactiveParent(abaList,abaMap);
        PRM_accBenefitAssociationUtility.duplicateRecordCheck(abaList);
        
        System.assertEquals('Testing',abassociationTest3.PRM_Status_Reason_Txt__c,'Value does not match');
        Test.stopTest();
        
    }
    
    @isTest static void opidBenefitInactivationTest(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId(); 
        List<Account> lstOfAcc = new List<Account>(); 
        Map<Id,PRM_AccountBenefitAssociation__c> abaMap = new Map<Id,PRM_AccountBenefitAssociation__c>();
        //PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige;Partner';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solution Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Benzopid';
        parent1.BillingCity='New Town';
        parent1.BillingStreet='Street Major';
        parent1.BillingCountry='France';
        parent1.BillingPostalCode='9999991';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        parent1.website='www.abc.com';
        parent1.Core_User_Defined_Website__c='www.abc.com';
        lstOfAcc.add(parent1);
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='Benzeid';
        testAccount.BillingCity='City Cross Site';
        testAccount.BillingStreet='Street alphano';
        testAccount.BillingCountry='Canada';
        testAccount.BillingPostalCode='Postal code1';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.abc.com';
        lstOfAcc.add(testAccount);

        insert lstOfAcc;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='IND';
        insert cont;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Reason_Txt__c = 'For test class';
        insert acctContRel;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'IPA';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Sales PRM - Partner Points Viewer';
        ed.Core_Display_Name__c='Sales PRM - Partner Points Viewer';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount.id;

        insert coreAccnt;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest1);
        
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest);
        insert acmList;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest2.Name = 'Solution Marketplace Basic Access';
        pbTest2.PRM_Benefit_Cd__c = 'BNFTSMBA';
        pbTest2.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest2.PRM_InActive_Ind__c = false;
        pbTest2.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest2);
        
        PRM_PartnerBenefit__c pbTest3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest3.Name = 'Solution Marketplace Basic Profile';
        pbTest3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTest3.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest3.PRM_InActive_Ind__c = false;
        pbTest3.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest3);
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solution Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        insert pbList;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest2.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Manual';
       // em.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        insert em;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        List<PRM_VXBnftMatrix__c> lstOfBnftMatrix = new List<PRM_VXBnftMatrix__c>();  
        PRM_VXBnftMatrix__c bmTest1 = new PRM_VXBnftMatrix__c();
        bmTest1.PRM_Partner_Benefit_Id__c = pbTest3.Id;
        bmTest1.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest1.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        //bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest1.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest1.PRM_Covered_Account_Ind__c = true;
        bmTest1.PRM_IsActive_Ind__c = true;
        bmTest1.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest1);
        
        PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        //bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest2);
        
        PRM_VXBnftMatrix__c bmTest3 = new PRM_VXBnftMatrix__c();
        bmTest3.PRM_Partner_Benefit_Id__c = pbTest2.Id;
        bmTest3.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest3.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        //bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest3.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest3.PRM_Covered_Account_Ind__c = true;
        bmTest3.PRM_IsActive_Ind__c = true;
        bmTest3.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest3); 
        insert lstOfBnftMatrix;
        
        // Test Data for Message
        
        /* Id eventRecordTypeId = Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Event').getRecordTypeId(); 

list<PRM_Message__c> lstOfMssg = new list<PRM_Message__c>(); 
PRM_Message__c msg1= new PRM_Message__c();
msg1.PRM_Title_Txt__c='Setup your store front';
msg1.PRM_Message_Cd__c = 'MSGSTRFRNT';
msg1.RecordTypeId = eventRecordTypeId;
lstOfMssg.add(msg1);
//insert msg1;      

PRM_Message__c msg2= new PRM_Message__c();
msg2.PRM_Title_Txt__c='Complete your profile for visibility in Marketplace by clicking “Manage profile” ';
msg2.PRM_Message_Cd__c = 'MSGMRKT';
msg2.RecordTypeId = eventRecordTypeId;
lstOfMssg.add(msg2); 
insert lstOfMssg;  */
        
        Test.startTest();
        
        PRM_AccountBenefitAssociation__c abassociationTest = new PRM_AccountBenefitAssociation__c();
        abassociationTest.PRM_Account_Id__c = testAccount.id;
        abassociationTest.PRM_Partner_Benefit_Id__c = pbTest2.id;
        abassociationTest.PRM_Status_Nm__c = 'Active';
        abassociationTest.PRM_Status_Reason_Txt__c = 'Test';
        insert abassociationTest;
        
        List<PRM_AccountBenefitAssociation__c> lstOfAba = new List<PRM_AccountBenefitAssociation__c>(); 
        PRM_AccountBenefitAssociation__c abassociationTest1 = new PRM_AccountBenefitAssociation__c();
        abassociationTest1.PRM_Account_Id__c = parent1.id;
        abassociationTest1.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest1.PRM_Status_Nm__c = 'Active';
        abassociationTest1.PRM_Status_Reason_Txt__c = 'Test';
        lstOfAba.add(abassociationTest1);
        
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = parent1.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abassociationTest2.PRM_Status_Reason_Txt__c = 'Test';
        lstOfAba.add(abassociationTest2);    
        abaMap.put(parent1.id,abassociationTest2);
        insert lstOfAba;
        
        PRM_AccountBenefitAssociation__c abassociationTest4 = new PRM_AccountBenefitAssociation__c();
        abassociationTest4.PRM_Account_Id__c = parent1.id;
        abassociationTest4.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest4.PRM_Status_Nm__c = 'Active';
        abassociationTest4.PRM_Status_Reason_Txt__c = 'Test';
        abaMap.put(abassociationTest4.Id,abassociationTest4);
        
        abassociationTest.PRM_Status_Nm__c = 'Inactive';
        abassociationTest.PRM_Status_Reason_Txt__c='Testing';
        update abassociationTest;
        
        PRM_accBenefitAssociationUtility.onOPIDBenefitStatusInactive(lstOfAba,abaMap);
        PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Partner');//Gold
        PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Partner');//Member
        PRM_accBenefitAssociationUtility.opidBenefitInactivation(lstOfAba,abaMap);
        System.assertEquals('Active',abassociationTest2.PRM_Status_Nm__c,'Value does not match');
        test.stopTest();
    }
    
    
    
    // TO Increase Test Coverage
    @istest static void testAbaUtility(){
        list<account> testAccLst=new list<account>();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //sheetal changes start
        
        PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige;Partner';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.website='www.abc.com';
        // testAccount.website='www.abc.com';
        testAccount.Core_User_Defined_Website__c='www.abc.com';  
        testAccLst.add(testAccount);
        
        Account testAccount1 = new Account();
        testAccount1.RecordTypeId = recordTypeIdAccount;
        testAccount1.Name='Benzeid1';
        testAccount1.BillingCity='City Cross Site';
        testAccount1.BillingStreet='Street alphano';
        testAccount1.BillingCountry='Canada';
        testAccount1.BillingPostalCode='Postal code1';
        testAccount1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount1.website='www.abc1.com';
        testAccount1.Core_User_Defined_Website__c='www.abc1.com';
        testAccLst.add(testAccount1);
        
        
        // insert testAccount;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent1.website='www.abc.com';
        parent1.Core_User_Defined_Website__c='www.abc.com';
        testAccLst.add(parent1);
        // insert parent1;
        
        Account parent2 = new Account();
        parent2.RecordTypeId = OpidAccRecordTypeId;
        parent2.Name='Oswol Ltd';
        parent2.BillingCity='wills City';
        parent2.BillingStreet='wills Street';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='999998';
        parent2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent2.website='www.abc.com';
        parent2.Core_User_Defined_Website__c='www.abc.com';
        testAccLst.add(parent2);
        //insert parent2;
        
        insert testAccLst;
        
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parent1.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount.id;
        coreAccnt.Core_Inactive_Ind__c = false;

        insert coreAccnt;
        /*List<Contact>contactList=new List<Contact>();
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=testAccount.Id;
        cont1.lastName='Grill';
        cont1.FirstName='Adam';
        cont1.email='AdamGrill@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c='Distributor';
        cont1.MailingCountry='IND';
        contactList.add(cont1);*/
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Gill';
        cont.FirstName='Aam';
        cont.email='AdamGrl@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.MailingCountry='IND';
        //contactList.add(cont);
        insert cont;
        //insert contactList;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        List<ChannelProgramLevel>  prgmList  = new  List<ChannelProgramLevel>();
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpTest.Id;
        prgmList.add(cplTest);    
        
        ChannelProgramLevel cplTest1= new ChannelProgramLevel(); //Channel Program Level
        cplTest1.Name='Partner';
        cplTest1.ProgramId=cpTest.Id;
        prgmList.add(cplTest1);    
        
        insert prgmList;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Points Redemption to Check';
        pbTest.PRM_Benefit_Cd__c = 'BFTP';
        pbTest.PRM_InActive_Ind__c = false;
        pbTest.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest);
        
        PRM_PartnerBenefit__c pbTest1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest1.Name = 'Points Redemption';
        pbTest1.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pbTest1.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest1.PRM_InActive_Ind__c = false;
        pbTest1.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest1);
        
        PRM_PartnerBenefit__c pbTest2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest2.Name = 'Solution Marketplace Basic Access';
        pbTest2.PRM_Benefit_Cd__c = 'BNFTSMBA';
        pbTest2.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest2.PRM_InActive_Ind__c = false;
        pbTest2.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest2);
        
        PRM_PartnerBenefit__c pbTest3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest3.Name = 'Solutions Marketplace Basic Profile';
        pbTest3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTest3.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest3.PRM_InActive_Ind__c = false;
        pbTest3.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest3);
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        insert pbList;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest1);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent2.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest2.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cpTest.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
        List<PRM_VXBnftMatrix__c> lstOfBnftMatrix = new List<PRM_VXBnftMatrix__c>();
        
        PRM_VXBnftMatrix__c bmTest = new PRM_VXBnftMatrix__c();
        bmTest.PRM_Partner_Benefit_Id__c = pbTest1.Id;
        bmTest.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest.PRM_Covered_Account_Ind__c = true;
        bmTest.PRM_IsActive_Ind__c = true;
        bmTest.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest);
        // insert bmTest;
        
        PRM_VXBnftMatrix__c bmTest1 = new PRM_VXBnftMatrix__c();
        bmTest1.PRM_Partner_Benefit_Id__c = pbTest3.Id;
        bmTest1.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest1.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest1.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest1.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest1.PRM_Covered_Account_Ind__c = true;
        bmTest1.PRM_IsActive_Ind__c = true;
        bmTest1.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest1);
        //insert bmTest1;
        
        
        PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest2.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest2);
        //insert bmTest2;
        
        PRM_VXBnftMatrix__c bmTest3 = new PRM_VXBnftMatrix__c();
        bmTest3.PRM_Partner_Benefit_Id__c = pbTest2.Id;
        bmTest3.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest3.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest3.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest3.PRM_Covered_Account_Ind__c = true;
        bmTest3.PRM_IsActive_Ind__c = true;
        bmTest3.PRM_Partner_Role_Nm__c='Service Provider';
        lstOfBnftMatrix.add(bmTest3);
        insert lstOfBnftMatrix;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'IPA';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee; 
        
        List<Core_Entitlement__c> coreEntList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c= 'Points Manager';
        coreEntList.add(ed);
        
        Core_Entitlement__c ed1 =new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View' ;
        ed1.Core_Display_Name__c= 'Points View';
        coreEntList.add(ed1);
        
        insert coreEntList;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest1.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Distributor';
        // em.PRM_IPARefreshCheck__c = ipaRefresh?true:false;
        insert em;
        
        set<id> idAcr = new set<id>();
        List<PRM_Account_Contact_Relationship__c> listAcr = new List<PRM_Account_Contact_Relationship__c>() ;
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Nm__c = 'Complete';
        acctContRel.PRM_Status_Reason_Txt__c = 'For test class';
        idAcr.add(acctContRel.PRM_Account_Id__c);
        
        insert acctContRel;
        
        acctContRel.PRM_Status_Nm__c = 'Complete'; 
        update acctContRel;
        
          
         PRM_Account_Contact_Relationship__c acr ;
        if(!idAcr.IsEmpty()){
            acr = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :idAcr ];
            
            //AND PRM_InActive_Ind__c!= true AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status
                
        }
        
        test.startTest();
        
        Map<Id,PRM_AccountBenefitAssociation__c> oldAbaMap=new Map<Id,PRM_AccountBenefitAssociation__c>(); 
        List<PRM_AccountBenefitAssociation__c> lstOfAba = new List<PRM_AccountBenefitAssociation__c>(); 
        PRM_AccountBenefitAssociation__c abassociationTest1 = new PRM_AccountBenefitAssociation__c();
        abassociationTest1.PRM_Account_Id__c = parent1.id;
        abassociationTest1.PRM_Partner_Benefit_Id__c = pbTest1.id;
        abassociationTest1.PRM_Status_Nm__c = 'Active';
        abassociationTest1.PRM_Status_Reason_Txt__c = 'Test';
        abassociationTest1.PRM_Suppress_Email__c = true;
        lstOfAba.add(abassociationTest1);
        oldAbaMap.put(abassociationTest1.id,abassociationTest1);
        
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = parent1.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abassociationTest2.PRM_Status_Reason_Txt__c = 'Test';
        lstOfAba.add(abassociationTest2);  
        oldAbaMap.put(abassociationTest2.id,abassociationTest2);

        
        PRM_AccountBenefitAssociation__c abassociationTest3 = new PRM_AccountBenefitAssociation__c();
        abassociationTest3.PRM_Account_Id__c = testAccount.id;
        abassociationTest3.PRM_Partner_Benefit_Id__c = pbTest2.id;
        abassociationTest3.PRM_Status_Nm__c = 'Active';
        abassociationTest3.PRM_Status_Reason_Txt__c = 'Test';
        lstOfAba.add(abassociationTest3);
        oldAbaMap.put(abassociationTest3.id,abassociationTest3);
        
        PRM_AccountBenefitAssociation__c abassociationTest4 = new PRM_AccountBenefitAssociation__c();
        abassociationTest4.PRM_Account_Id__c = parent1.id;
        abassociationTest4.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest4.PRM_Status_Nm__c = 'Active';
        abassociationTest4.PRM_Status_Reason_Txt__c = 'Test';
        lstOfAba.add(abassociationTest4);  
        oldAbaMap.put(abassociationTest4.id,abassociationTest4);
                
        insert lstOfAba;
        
        List<PRM_AccountBenefitAssociation__c> oldAbaList = new List<PRM_AccountBenefitAssociation__c>();        
        abassociationTest1.PRM_Status_Nm__c = 'Inactive';
        abassociationTest1.PRM_Status_Reason_Txt__c='Testing';
        oldAbaList.add(abassociationTest1);
        update abassociationTest1;

        list<Core_Contact_Entitlement__c> entitlementList = new list<Core_Contact_Entitlement__c>();       
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        entitlementList.add(cce);
        
        Core_Contact_Entitlement__c ccf=new Core_Contact_Entitlement__c();
        ccf.Core_Contact_Id__c=cont.Id;
        ccf.Core_Status__c='Complete';
        ccf.Core_Entitlement_Id__c=ed1.Id;
        ccf.Core_Selected__c = false ;
        entitlementList.add(ccf);


        insert entitlementList;
        
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
        be.PRM_Contact_Id__c = cce.Id;
        be.PRM_Entitlement_Id__c = cce.Core_Entitlement_Id__c;
        be.PRM_Status_Nm__c = 'New';
        be.PRM_Status_Reason_Txt__c = 'Test';
        be.PRM_IsRemove_Ind__c = true;
        
        Map<Id,PRM_AccountBenefitAssociation__c> abaMap=new Map<Id,PRM_AccountBenefitAssociation__c>(); 
        //Set<Id> contactsList = new Set<Id>{contactList[0].Id, contactList[1].Id};
        //Set<Id> entitlementsList = new Set<Id>{entitlementList[0].Id, entitlementList[1].Id};
        
        abaMap.put(oldAbaList[0].id,oldAbaList[0]);
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> abaListnew = new List<PRM_AccountBenefitAssociation__c>();
          
        abaList.add(abassociationTest1);
        
        abaList[0].PRM_Status_Nm__c = 'Active';
        abaList[0].PRM_Status_Reason_Txt__c='Testing'; 
        
        PRM_accBenefitAssociationUtility.onStatusInactive(abaList);

        PRM_accBenefitAssociationUtility.onStatusInactiveParent(abaList,abaMap);
        PRM_accBenefitAssociationUtility.duplicateRecordCheck(abaList);
        PRM_accBenefitAssociationUtility.updateSuppressEmail(abaList,abaMap);
        PRM_accBenefitAssociationUtility.opidBenefitInactivation(lstOfAba,oldAbaMap);
        PRM_accBenefitAssociationUtility.onManualBenefitInsert(lstOfAba,oldAbaMap,false); 
        //PRM_accBenefitAssociationUtility.getActvieBatchEntitlement(entitlementsList, contactsList);
        
        Test.stopTest();   
    }
    
   /* @isTest
    static void testGetActvieBatchEntitlement() {
        
    }*/
}