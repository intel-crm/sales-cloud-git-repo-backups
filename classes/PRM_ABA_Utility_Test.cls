@isTest
public class PRM_ABA_Utility_Test {
    @testSetup static void testRelatedABARecords(){
       Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
       Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //sheetal changes start
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_IPA_Partner_Speciality__c='Video Specialty;Cloud Data Center Specialist';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent1;
        
        Account parent2 = new Account();
        parent2.RecordTypeId = OpidAccRecordTypeId;
        parent2.Name='Oswol Ltd';
        parent2.BillingCity='wills City';
        parent2.BillingStreet='wills Street';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='999998';
        parent2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent2;
        
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
        insert cont;
        
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
        
        PRM_Benefit_Group__c bg1 = new PRM_Benefit_Group__c();
        bg1.Name='Sheetal Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Benefit_Group__c bg2 = new PRM_Benefit_Group__c();
        bg2.Name='Sheetal Test2';
        bg2.PRM_InActive_Ind__c= false;
        insert bg2;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Titanium';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        ChannelProgramLevel cplTest1= new ChannelProgramLevel(); //Channel Program Level
        cplTest1.Name='GOLD';
        cplTest1.ProgramId=cpTest.Id;
        insert cplTest1;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest.Name = 'Points Redemption to Check';
        pbTest.PRM_Benefit_Cd__c = 'BFTP';
        pbTest.PRM_InActive_Ind__c = false;
        //pbTest.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest);
        
        PRM_PartnerBenefit__c pbTest1 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest1.Name = 'Points Redemption Check';
        pbTest1.PRM_Benefit_Cd__c = 'STRES';
        pbTest1.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest1.PRM_InActive_Ind__c = false;
        //pbTest1.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest1);
        
        PRM_PartnerBenefit__c pbTest2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest2.Name = 'Solution Marketplace Basic Access';
        pbTest2.PRM_Benefit_Cd__c = 'BNFTSMBA';
        pbTest2.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest2.PRM_InActive_Ind__c = false;
        //pbTest2.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest2);
        
        PRM_PartnerBenefit__c pbTest3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest3.Name = 'Solutions Marketplace Basic Profile';
        pbTest3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pbTest3.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest3.PRM_InActive_Ind__c = false;
        //pbTest3.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest3);
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        //pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        insert pbList;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA1 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA1.PRM_Benefit_Group_Id__c=bg1.id;
        testSBGA1.PRM_Specialty_Id__c=spec1.id;
        testSBGA1.PRM_InActive_Ind__c= false;
        insert testSBGA1;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA2 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA2.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA2.PRM_Specialty_Id__c=spec1.id;
        testSBGA2.PRM_InActive_Ind__c= false;
        insert testSBGA2;
        
        PRM_Specialty_Benefit_Group_Association__c testSBGA3 = new PRM_Specialty_Benefit_Group_Association__c();
        testSBGA3.PRM_Benefit_Group_Id__c=bg2.id;
        testSBGA3.PRM_Specialty_Id__c=spec2.id;
        testSBGA3.PRM_InActive_Ind__c= false;
        insert testSBGA3;
        
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
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acmList.add(acctChnlMemTest);
        
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acmList.add(acctChnlMemTest1);
        
        PRM_AccountChannelMembership__c acctChnlMemTest2=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest2.PRM_Account_Id__c=parent2.Id;
        acctChnlMemTest2.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest2.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest2.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest2.PRM_Status_Nm__c = 'Approved';
        acmList.add(acctChnlMemTest2);
        insert acmList;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cpTest.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
        PRM_VXBnftMatrix__c bmTest = new PRM_VXBnftMatrix__c();
        bmTest.PRM_Partner_Benefit_Id__c = pbTest1.Id;
        bmTest.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest.PRM_Covered_Account_Ind__c = true;
        bmTest.PRM_IsActive_Ind__c = true;
        bmTest.PRM_Partner_Role_Nm__c='Service Provider';
        insert bmTest;
        
        PRM_VXBnftMatrix__c bmTest1 = new PRM_VXBnftMatrix__c();
        bmTest1.PRM_Partner_Benefit_Id__c = pbTest3.Id;
        bmTest1.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest1.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest1.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest1.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest1.PRM_Covered_Account_Ind__c = true;
        bmTest1.PRM_IsActive_Ind__c = true;
        bmTest1.PRM_Partner_Role_Nm__c='Service Provider';
        insert bmTest1;
        
        PRM_VXBnftMatrix__c bmTest2 = new PRM_VXBnftMatrix__c();
        bmTest2.PRM_Partner_Benefit_Id__c = pbTest4.Id;
        bmTest2.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest2.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest2.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest2.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest2.PRM_Covered_Account_Ind__c = true;
        bmTest2.PRM_IsActive_Ind__c = true;
        bmTest2.PRM_Partner_Role_Nm__c='Service Provider';
        insert bmTest2;
        
        PRM_VXBnftMatrix__c bmTest3 = new PRM_VXBnftMatrix__c();
        bmTest3.PRM_Partner_Benefit_Id__c = pbTest2.Id;
        bmTest3.PRM_Channel_Program_Id__c = cpTest.Id;
        bmTest3.PRM_Channel_Program_Level_Id__c = cplTest.Id;
        bmTest3.PRM_Partner_Type_Id__c = ptTest.Id;
        bmTest3.PRM_Approval_Type_Nm__c = 'Automatic';
        bmTest3.PRM_Covered_Account_Ind__c = true;
        bmTest3.PRM_IsActive_Ind__c = true;
        bmTest3.PRM_Partner_Role_Nm__c='Service Provider';
        insert bmTest3;
        
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
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest1.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Manual';
        insert em;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= testaccount.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;
        
        Test.startTest();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abassociationTest = new PRM_AccountBenefitAssociation__c();
        abassociationTest.PRM_Account_Id__c = testAccount.id;
        abassociationTest.PRM_Partner_Benefit_Id__c = pbTest1.id;
        abassociationTest.PRM_Status_Nm__c = 'Active';
        abaList.add(abassociationTest);
        
        PRM_AccountBenefitAssociation__c abassociationTest1 = new PRM_AccountBenefitAssociation__c();
        abassociationTest1.PRM_Account_Id__c = parent1.id;
        abassociationTest1.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest1.PRM_Status_Nm__c = 'Active';
        abaList.add(abassociationTest1);
        
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = parent2.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abaList.add(abassociationTest2);
        
        PRM_AccountBenefitAssociation__c abassociationTest3 = new PRM_AccountBenefitAssociation__c();
        abassociationTest3.PRM_Account_Id__c = testAccount.id;
        abassociationTest3.PRM_Partner_Benefit_Id__c = pbTest2.id;
        abassociationTest3.PRM_Status_Nm__c = 'Active';
        abaList.add(abassociationTest3);
        
        PRM_AccountBenefitAssociation__c abassociationTest4 = new PRM_AccountBenefitAssociation__c();
        abassociationTest4.PRM_Account_Id__c = parent1.id;
        abassociationTest4.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest4.PRM_Status_Nm__c = 'Active';
        abaList.add(abassociationTest4);
        insert abaList;

        try{
            PRM_AccountBenefitAssociation__c abassociationTest5 = new PRM_AccountBenefitAssociation__c();
            abassociationTest5.PRM_Account_Id__c = parent1.id;
            abassociationTest5.PRM_Partner_Benefit_Id__c = pbTest4.id;
            abassociationTest5.PRM_Status_Nm__c = 'Active';
            insert abassociationTest5;
          
         }catch(Exception e){
            System.debug('The benefit is already assigned to the account' +e.getMessage());
        }
        
        Test.stopTest();
        
    }
    static testmethod void updateABARecord(){
        Test.startTest();
            PRM_AccountBenefitAssociation__c abaRec = [Select Id,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__r.Name = 'John Wick' AND PRM_Status_Nm__c ='Active' LIMIT 1];
            abaRec.PRM_Status_Nm__c='Inactive';
            abaRec.PRM_Status_Reason_Txt__c='Testing';
            update abaRec;
        Test.stopTest();
    }
    
}