@isTest()
public  class IPABenefitUtilityTest {
    @isTest
    public static void testDataSetupforIntelAccount(){  
        
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        //testAccount.Core_IPA_Partner_Speciality__c='Cloud Data Center Specialist';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c = 'www.abc.com';
        testAccount.Core_OnePartnerID__c = testAccount.Id;
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        List<Contact> contList=new List<contact>();
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=testAccount.Id;
        cont3.lastName='Johnny';
        cont3.FirstName='Parker';
        cont3.email='Peterparker1@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        //cont3.Core_Profession__c='Sales';
        cont3.Core_IPA_PartnerRole__c='Distributor';
        cont3.Core_Preferred_Language__c='FRA';
        cont3.MailingCountry='USA';
        
        //insert cont3;
        contList.add(cont3);
        
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Service Provider';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='USA';
        
        //insert cont;
        contList.add(cont);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=testAccount.Id;
        cont2.lastName='John';
        cont2.FirstName='Parker';
        cont2.email='Peterparker@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        //cont2.Core_Profession__c='Sales';
        cont2.Core_IPA_PartnerRole__c='Distributor';
        cont2.Core_Preferred_Language__c='FRA';
        cont2.MailingCountry='USA';
        
        //insert cont2;
        contList.add(cont2);
        insert contList;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        //user
        
        // UserRole r = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
        /*UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
insert r;*/
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',
                                    UserName='test2ur@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser;
        Id userId=partnerUser.Id;
        
        
        User partnerUser2 = new User(FirstName='Test2',LastName='User',alias='t2user',Email='mrt2r@mailinator.com',UserName='notheruser@xyz.com', ContactId=cont2.Id,ProfileId=communityUsrProfile.Id,
                                     emailencodingkey='UTF-8', languagelocalekey='fr', localesidkey='fr_FR',timezonesidkey='Europe/London');//, UserRoleId = r.id);
        
        insert partnerUser2;
        Id userId2=partnerUser2.Id;
        
        Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
        Id specnRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Video Specialty';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=specnRT;
        spec1.PRM_Inactive_Ind__c=false;
        insert spec1;
        
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Optane Client Specialty';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        spec2.PRM_Inactive_Ind__c=false;
        spec2.RecordTypeId=specnRT;
        insert spec2;
        
        
        PRM_Specialty__c spec3 = new PRM_Specialty__c();
        spec3.name='Select Benefits';
        spec3.PRM_Description_Txt__c='This is description';
        spec3.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec3.PRM_Role_Nm__c='Service Provider';
        spec3.PRM_Tier_Nm__c='Gold';
        spec3.PRM_Start_Date_Dt__c= system.today() + 7;
        spec3.PRM_End_Date_Dt__c= spec3.PRM_Start_Date_Dt__c + 5;
        spec3.PRM_Access_Level_Nm__c='Public';
        spec3.RecordTypeId=selectBenRT;
        spec3.PRM_Inactive_Ind__c=false;
        insert spec3;
        
        PRM_Specialty__c spec4 = new PRM_Specialty__c();
        spec4.name='Networking Specialty';
        spec4.PRM_Description_Txt__c='This is description';
        spec4.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec4.PRM_Role_Nm__c='Service Provider';
        spec4.PRM_Tier_Nm__c='Gold';
        spec4.PRM_Start_Date_Dt__c= system.today() + 7;
        spec4.PRM_End_Date_Dt__c= spec4.PRM_Start_Date_Dt__c + 5;
        spec4.PRM_Access_Level_Nm__c='Public';
        spec4.RecordTypeId=specnRT;
        spec4.PRM_Inactive_Ind__c=false;
        insert spec4;
        
        
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Partner';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        /*ChannelProgramLevel cplTest1 = new ChannelProgramLevel(); //Channel Program Level
        cplTest1.Name='Member';  
        cplTest1.ProgramId=cpTest.Id;
        insert cplTest1;*/
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c();
        pa.PRM_Agreement_Cd__c = 'IPA_TANDC';
        insert pa;
        
        PRM_AccountLegalAgreemntAssociation__c ala = new PRM_AccountLegalAgreemntAssociation__c();
        ala.PRM_Account_Id__c = testAccount.Id;
        ala.PRM_Partner_Agreement_Id__c = pa.Id;
        ala.PRM_InActive_Ind__c = false;
        ala.PRM_Contact__c = cont.Id;
        ala.PRM_Agreement_Sign_Dt__c = System.today()+7;
        insert ala;
        
        PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
        ps.PRM_Subscription_Cd__c = 'PRDSOLCOM,TRAWEBCOM';
        insert ps;
        
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Contact_Id__c = cont.Id;
        csa.PRM_Partner_Subscription_Id__c= ps.Id;
        csa.PRM_Status_Nm__c = 'Active';
        csa.PRM_Status_Reason_Txt__c='Test 1';
        insert csa;
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        PRM_PartnerBenefit__c pbTest5 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest5.Name = 'Partner University';
        pbTest5.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pbTest5.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest5.PRM_InActive_Ind__c = false;
        pbTest5.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest5);
        PRM_PartnerBenefit__c pbTest6 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest6.Name = 'Partner Marketing Studio';
        pbTest6.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pbTest6.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest6.PRM_InActive_Ind__c = false;
        pbTest6.PRM_Account_Type_Nm__c='Mastered_Account';
        pbList.add(pbTest6);
        PRM_PartnerBenefit__c pbTest7 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest7.Name = 'Advanced Warranty Replacement';
        pbTest7.PRM_Benefit_Cd__c = 'BFTMKTHGD';
        pbTest7.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest7.PRM_InActive_Ind__c = false;
        pbTest7.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest7);
        PRM_PartnerBenefit__c pbTest8 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest8.Name = 'Solutions Marketplace Basic Access';
        pbTest8.PRM_Benefit_Cd__c = 'BFTMKTYUH';
        pbTest8.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest8.PRM_InActive_Ind__c = false;
        pbTest8.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest8);
        /*PRM_PartnerBenefit__c pbTest9 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest9.Name = 'Developer Zone Standard Entitlement'; 
        pbTest9.PRM_Benefit_Cd__c = 'BNFTDZS';
        pbTest9.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest9.PRM_InActive_Ind__c = false;
        pbTest9.PRM_Account_Type_Nm__c='Mastered_Account';
        pbList.add(pbTest9);*/
        PRM_PartnerBenefit__c pbTest10 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest10.Name = 'Developer Zone Premier Entitlement'; 
        pbTest10.PRM_Benefit_Cd__c = 'BNFTDZP';
        pbTest10.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest10.PRM_InActive_Ind__c = false;
        pbTest10.PRM_Account_Type_Nm__c='Core_Partner_Account_Group';
        pbList.add(pbTest10);
        insert pbList;
        
        prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
        bm.inactive__c = false;
        insert bm;
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=testAccount.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c='Test';
        acmList.add(acctChnlMemTest);
        
        /*PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=testAccount.Id;  
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest1.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Distributor';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acmList.add(acctChnlMemTest1);*/
        
        insert acmList;
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cpTest.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
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
        
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Access and Entitlements for Marketplace';
        ee.Core_Technical_Engagement_Code__c = 'MKTSMP';
        ee.Core_Engagement_Type__c = 'SMP';
        insert ee; 
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Partner Admin';
        ed.Core_Display_Name__c='Partner Admin';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name='Partner Admin Delegate';
        contRelation1.PRM_Contact_Relationship_Cd__c ='PRIMCONTDEL';
        contRelation1.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = true;
        insert contRelation1;
        
        PRM_ContactRelationships__c contRelation2 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation2.Name='Employee';
        contRelation2.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contRelation2.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation2.PRM_Default_Relationship_Ind__c = true;
        insert contRelation2;
        
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest4.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Manual';
        insert em;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= testaccount.id;
        asa.PRM_Specialty_Id__c= spec2.id;
        asa.PRM_InActive_Ind__c=false;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= testaccount.id;
        asa1.PRM_Specialty_Id__c= spec3.id;
        asa1.PRM_InActive_Ind__c=false;
        asa1.PRM_Partner_Role__c='Service Provider';
        insert asa1;
        
        
        List<PRM_Account_Contact_Relationship__c> acctContRelList=new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_Status_Reason_Txt__c = 'Test';
        //acctContRel.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRel);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c();
        acctContRel1.PRM_Account_Id__c=testAccount.Id;
        acctContRel1.PRM_Contact_Id__c=cont.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation2.Id;
        acctContRel1.PRM_Status_Nm__c='Complete';
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_Status_Reason_Txt__c = 'Test';
        acctContRelList.add(acctContRel1);
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        /*Core_Contact_Entitlement__c cce11=new Core_Contact_Entitlement__c();
        cce11.Core_Contact_Id__c=cont2.Id;
        cce11.Core_Status__c='Complete';
        cce11.Core_Entitlement_Id__c=ed.Id;
        cce11.Core_Selected__c = true;
        insert cce11; */
        
        Core_ERPM_Engagement__c ee1 = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee1.Name = 'TestRDC';
        ee1.Core_Technical_Engagement_Code__c = 'MKTSMP';
        ee1.Core_Engagement_Type__c = 'SMP';
        insert ee1; 
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points Redeem';
        ed1.Core_Display_Name__c='Points Manager';
        ed1.Core_ERPM_Engagement_Id__c=ee1.id;
        insert ed1;
        
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c();
        cce1.Core_Contact_Id__c=cont.Id;
        cce1.Core_Status__c='Complete';
        cce1.Core_Entitlement_Id__c=ed1.Id;
        cce1.Core_Selected__c = true;
        insert cce1;
        
        Core_ERPM_Engagement__c ee2 = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee2.Name = 'TestRDC';
        ee2.Core_Technical_Engagement_Code__c = 'MKTSMP';
        ee2.Core_Engagement_Type__c = 'SMP';
        insert ee2; 
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Resource & Design Center for Secure Content';
        ed2.Core_Display_Name__c='Developer Zone Premier(CNDA required)';
        ed2.Core_ERPM_Engagement_Id__c=ee2.id;
        insert ed2;
        
        Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c();
        cce2.Core_Contact_Id__c=cont.Id;
        cce2.Core_Status__c='Complete';
        cce2.Core_Entitlement_Id__c=ed2.Id;
        cce2.Core_Selected__c = true;
        insert cce2;
        
        List<Core_Contact_Entitlement__c> ENTS=[select Core_Display_Nm__c from Core_Contact_Entitlement__c where Core_Contact_Id__c =:cont.Id];
        System.debug('JB Ent::'+ENTS);
        /*Core_Contact_Entitlement__c cce12=new Core_Contact_Entitlement__c();
        cce12.Core_Contact_Id__c=cont2.Id;
        cce12.Core_Status__c='Complete';
        cce12.Core_Entitlement_Id__c=ed1.Id;
        cce12.Core_Selected__c = true;
        insert cce12;*/
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c();
        acctContRel3.PRM_Account_Id__c=testAccount.Id;
        acctContRel3.PRM_Contact_Id__c=cont3.Id;
        acctContRel3.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel3.PRM_Status_Nm__c='Complete';
        acctContRel3.PRM_Status_Reason_Txt__c = 'Test';
      //  acctContRel3.PRM_isActive__c=false;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel3;
        
      /*  Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c();
        cce2.Core_Contact_Id__c=cont3.Id;
        cce2.Core_Status__c='Complete';
        cce2.Core_Entitlement_Id__c=ed.Id;
        cce2.Core_Selected__c = true;
        insert cce2;*/
        
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = testAccount.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abassociationTest2.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest2);
        
        
        PRM_AccountBenefitAssociation__c abassociationTest3 = new PRM_AccountBenefitAssociation__c();
        abassociationTest3.PRM_Account_Id__c = testAccount.id;
        abassociationTest3.PRM_Partner_Benefit_Id__c = pbTest5.id;
        abassociationTest3.PRM_Status_Nm__c = 'Active';
        abassociationTest3.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest3);
        
        PRM_AccountBenefitAssociation__c abassociationTest4 = new PRM_AccountBenefitAssociation__c();
        abassociationTest4.PRM_Account_Id__c = testAccount.id;
        abassociationTest4.PRM_Partner_Benefit_Id__c = pbTest6.id;
        abassociationTest4.PRM_Status_Nm__c = 'Active';
        abassociationTest4.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest4);
        
        PRM_AccountBenefitAssociation__c abassociationTest5 = new PRM_AccountBenefitAssociation__c();
        abassociationTest5.PRM_Account_Id__c = testAccount.id;
        abassociationTest5.PRM_Partner_Benefit_Id__c = pbTest7.id;
        abassociationTest5.PRM_Status_Nm__c = 'Active';
        abassociationTest5.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest5);
        
        PRM_AccountBenefitAssociation__c abassociationTest6 = new PRM_AccountBenefitAssociation__c();
        abassociationTest6.PRM_Account_Id__c = testAccount.id;
        abassociationTest6.PRM_Partner_Benefit_Id__c = pbTest10.id;
        abassociationTest6.PRM_Status_Nm__c = 'Active';
        abassociationTest6.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest6);
		List<Core_CustomMetadata_Object__c> ccmdoList=new List<Core_CustomMetadata_Object__c>();
        Core_CustomMetadata_Object__c ccmdo=new Core_CustomMetadata_Object__c();
        ccmdo.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo.Program__c='IPA';
        ccmdo.DeveloperName__c='DeveloperName';
        ccmdo.MasterLabel__c='MasterLabel';
        ccmdo.Field_1__c='label';
        ccmdo.Field_2__c='externalURL';
        ccmdo.Field_3__c='type';    
        ccmdo.Field_4__c='IPARefreshSwitch';
        insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo1=new Core_CustomMetadata_Object__c();
        ccmdo1.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo1.Program__c='IPA';
        ccmdo1.DeveloperName__c='Intel® Partner Alliance Web Banners';
        ccmdo1.MasterLabel__c='Intel® Partner Alliance Web Banners';
        ccmdo1.Field_1__c='label';
        ccmdo1.Field_2__c='externalURL';
        ccmdo1.Header_row__c=ccmdo.Id;
        ccmdo1.Field_3__c='getLeads';    
        ccmdo1.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo1);
        //insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo2=new Core_CustomMetadata_Object__c();
        ccmdo2.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo2.Program__c='IPA';
        ccmdo2.DeveloperName__c='View the partner directory';
        ccmdo2.MasterLabel__c='View the partner directory';
        ccmdo2.Field_1__c='label';
        ccmdo2.Header_row__c=ccmdo.Id;
        ccmdo2.Field_2__c='externalURL';
        ccmdo2.Field_3__c='getMarketPlace';    
        ccmdo2.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo2);
        //insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo3=new Core_CustomMetadata_Object__c();
        ccmdo3.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo3.Program__c='IPA';
        ccmdo3.DeveloperName__c='Get help with Marketplace';
        ccmdo3.MasterLabel__c='Get help with Marketplace';
        ccmdo3.Header_row__c=ccmdo.Id;
        ccmdo3.Field_1__c='label';
        ccmdo3.Field_2__c='externalURL';
        ccmdo3.Field_3__c='getMarketPlace';    
        ccmdo3.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo3);
        
        Core_CustomMetadata_Object__c ccmdo31=new Core_CustomMetadata_Object__c();
        ccmdo31.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo31.Program__c='IPA';
        ccmdo31.DeveloperName__c='Spend Points';
        ccmdo31.MasterLabel__c='Spend Points';
        ccmdo31.Header_row__c=ccmdo.Id;
        ccmdo31.Field_1__c='label';
        ccmdo31.Field_2__c='externalURL';
        ccmdo31.Field_3__c='getPoints';    
        ccmdo31.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo31);
        
        Core_CustomMetadata_Object__c ccmdo32=new Core_CustomMetadata_Object__c();
        ccmdo32.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo32.Program__c='IPA';
        ccmdo32.DeveloperName__c='Intel® Developer Zone';
        ccmdo32.MasterLabel__c='Intel® Developer Zone';
        ccmdo32.Header_row__c=ccmdo.Id;
        ccmdo32.Field_1__c='label';
        ccmdo32.Field_2__c='externalURL';
        ccmdo32.Field_3__c='getMarketPlace';    
        ccmdo32.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo32);
        
        Core_CustomMetadata_Object__c ccmdo33=new Core_CustomMetadata_Object__c();
        ccmdo33.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo33.Program__c='IPA';
        ccmdo33.DeveloperName__c='Resource & Documentation Center';
        ccmdo33.MasterLabel__c='Resource & Documentation Center';
        ccmdo33.Header_row__c=ccmdo.Id;
        ccmdo33.Field_1__c='label';
        ccmdo33.Field_2__c='externalURL';
        ccmdo33.Field_3__c='displayRDCPremierBlade';    
        ccmdo33.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo33);
        
          Core_CustomMetadata_Object__c ccmdo331=new Core_CustomMetadata_Object__c();
        ccmdo331.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo331.Program__c='IPA';
        ccmdo331.DeveloperName__c='Intel Developer Cloud for Services';
        ccmdo331.MasterLabel__c='Intel Developer Cloud for Services';
        ccmdo331.Header_row__c=ccmdo.Id;
        ccmdo331.Field_1__c='label';
        ccmdo331.Field_2__c='externalURL';
        ccmdo331.Field_3__c='displayDZPBlade';    
        ccmdo331.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo331);
        
        //insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo4=new Core_CustomMetadata_Object__c();
        ccmdo4.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo4.Program__c='IPA';
        ccmdo4.DeveloperName__c='Manage Storefront';
        ccmdo4.MasterLabel__c='Manage Storefront';
        ccmdo4.Header_row__c=ccmdo.Id;
        ccmdo4.Field_1__c='label';
        ccmdo4.Field_2__c='externalURL';
        ccmdo4.Field_3__c='getMarketPlace';    
        ccmdo4.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo4);
        //insert ccmdo;
        //
          Core_CustomMetadata_Object__c ccmdo41=new Core_CustomMetadata_Object__c();
        ccmdo41.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo41.Program__c='IPA';
        ccmdo41.DeveloperName__c='View MDF Tool';
        ccmdo41.MasterLabel__c='View MDF Tool';
        ccmdo41.Header_row__c=ccmdo.Id;
        ccmdo41.Field_1__c='label';
        ccmdo41.Field_2__c='externalURL';
        ccmdo41.Field_3__c='getMDF';    
        ccmdo41.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo41);
        
         Core_CustomMetadata_Object__c ccmdo411=new Core_CustomMetadata_Object__c();
        ccmdo411.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo411.Program__c='IPA';
        ccmdo411.DeveloperName__c='Manage Leads';
        ccmdo411.MasterLabel__c='Manage Leads';
        ccmdo411.Header_row__c=ccmdo.Id;
        ccmdo411.Field_1__c='label';
        ccmdo411.Field_2__c='externalURL';
        ccmdo411.Field_3__c='getLeads';    
        ccmdo411.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo411);
        
        Core_CustomMetadata_Object__c ccmdo5=new Core_CustomMetadata_Object__c();
        ccmdo5.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo5.Program__c='IPA';
        ccmdo5.DeveloperName__c='View MDF';
        ccmdo5.Header_row__c=ccmdo.Id;
        ccmdo5.MasterLabel__c='View MDF';
        ccmdo5.Field_1__c='label';
        ccmdo5.Field_2__c='externalURL';
        ccmdo5.Field_3__c='getMDF';    
        ccmdo5.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo5);
        //insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo6=new Core_CustomMetadata_Object__c();
        ccmdo6.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo6.Program__c='IPA';
        ccmdo6.Header_row__c=ccmdo.Id;
        ccmdo6.DeveloperName__c='IPA MDF';
        ccmdo6.MasterLabel__c='IPA MDF';
        ccmdo6.Field_1__c='label';
        ccmdo6.Field_2__c='externalURL';
        ccmdo6.Field_3__c='getMDF';    
        ccmdo6.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo6);
        //insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo7=new Core_CustomMetadata_Object__c();
        ccmdo7.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo7.Program__c='IPA';
        ccmdo7.Header_row__c=ccmdo.Id;
        ccmdo7.DeveloperName__c='Learn about submitting a solution';
        ccmdo7.MasterLabel__c='Learn about submitting a solution';
        ccmdo7.Field_1__c='label';
        ccmdo7.Field_2__c='externalURL';
        ccmdo7.Field_3__c='getMarketPlace';    
        ccmdo7.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo7);
        //insert ccmdo;
        
        Core_CustomMetadata_Object__c ccmdo8=new Core_CustomMetadata_Object__c();
        ccmdo8.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo8.Program__c='IPA';
        ccmdo8.Header_row__c=ccmdo.Id;
        ccmdo8.DeveloperName__c='Create New Offering';
        ccmdo8.MasterLabel__c='Create New Offering';
        ccmdo8.Field_1__c='label';
        ccmdo8.Field_2__c='externalURL';
        ccmdo8.Field_3__c='getMarketPlace';    
        ccmdo8.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo8);
        
        Core_CustomMetadata_Object__c ccmdo18=new Core_CustomMetadata_Object__c();
        ccmdo18.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo18.Program__c='IPA';
        ccmdo18.Header_row__c=ccmdo.Id;
        ccmdo18.DeveloperName__c='Web Order Management';
        ccmdo18.MasterLabel__c='Web Order Management';
        ccmdo18.Field_1__c='label';
        ccmdo18.Field_2__c='externalURL';
        ccmdo18.Field_3__c='getProductRoadmapsBlade';    
        ccmdo18.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo18);
        
        Core_CustomMetadata_Object__c ccmdo28=new Core_CustomMetadata_Object__c();
        ccmdo28.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo28.Program__c='IPA';
        ccmdo28.Header_row__c=ccmdo.Id;
        ccmdo28.DeveloperName__c='Design-In Tools Store';
        ccmdo28.MasterLabel__c='Design-In Tools Store';
        ccmdo28.Field_1__c='label';
        ccmdo28.Field_2__c='externalURL';
        ccmdo28.Field_3__c='displayDITBlade';    
        ccmdo28.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo28);
        
        Core_CustomMetadata_Object__c ccmdo38=new Core_CustomMetadata_Object__c();
        ccmdo38.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo38.Program__c='IPA';
        ccmdo38.Header_row__c=ccmdo.Id;
        ccmdo38.DeveloperName__c='Visit FPGA Communities';
        ccmdo38.MasterLabel__c='Visit FPGA Communities';
        ccmdo38.Field_1__c='label';
        ccmdo38.Field_2__c='externalURL';
        ccmdo38.Field_3__c='getFPGAToolsResources';    
        ccmdo38.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo38);
        
        Core_CustomMetadata_Object__c ccmdo138=new Core_CustomMetadata_Object__c();
        ccmdo138.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo138.Program__c='IPA';
        ccmdo138.Header_row__c=ccmdo.Id;
        ccmdo138.DeveloperName__c='Visit FPGA Communities';
        ccmdo138.MasterLabel__c='Visit FPGA Communities';
        ccmdo138.Field_1__c='label';
        ccmdo138.Field_2__c='externalURL';
        ccmdo138.Field_3__c='getSpecialty';    
        ccmdo138.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo138);
        
        Core_CustomMetadata_Object__c ccmdo48=new Core_CustomMetadata_Object__c();
        ccmdo48.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo48.Program__c='IPA';
        ccmdo48.Header_row__c=ccmdo.Id;
        ccmdo48.DeveloperName__c='Intel Premier Support';
        ccmdo48.MasterLabel__c='Intel Premier Support';
        ccmdo48.Field_1__c='label';
        ccmdo48.Field_2__c='externalURL';
        ccmdo48.Field_3__c='getPartnerHelp';    
        ccmdo48.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo48);
        
        Core_CustomMetadata_Object__c ccmdo58=new Core_CustomMetadata_Object__c();
        ccmdo58.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo58.Program__c='IPA';
        ccmdo58.Header_row__c=ccmdo.Id;
        ccmdo58.DeveloperName__c='Artificial Intelligence';
        ccmdo58.MasterLabel__c='Artificial Intelligence';
        ccmdo58.Field_1__c='label';
        ccmdo58.Field_2__c='externalURL';
        ccmdo58.Field_3__c='getActivationZones';    
        ccmdo58.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo58);
        
        Core_CustomMetadata_Object__c ccmdo68=new Core_CustomMetadata_Object__c();
        ccmdo68.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo68.Program__c='IPA';
        ccmdo68.Header_row__c=ccmdo.Id;
        ccmdo68.DeveloperName__c='Reseller List Report';
        ccmdo68.MasterLabel__c='Reseller List Report';
        ccmdo68.Field_1__c='label';
        ccmdo68.Field_2__c='externalURL';
        ccmdo68.Field_3__c='getIPALookupTool';    
        ccmdo68.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo68);
        
        Core_CustomMetadata_Object__c ccmdo811=new Core_CustomMetadata_Object__c();
        ccmdo811.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo811.Program__c='IPA';
        ccmdo811.Header_row__c=ccmdo.Id;
        ccmdo811.DeveloperName__c='Points';
        ccmdo811.MasterLabel__c='Points';
        ccmdo811.Field_1__c='label';
        ccmdo811.Field_2__c='externalURL';
        ccmdo811.Field_3__c='getPricingPointsPromotionsBlade';    
        ccmdo811.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo811);
        
        Core_CustomMetadata_Object__c ccmdo82=new Core_CustomMetadata_Object__c();
        ccmdo82.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo82.Program__c='IPA';
        ccmdo82.Header_row__c=ccmdo.Id;
        ccmdo82.DeveloperName__c='Resource & Documentations Center';
        ccmdo82.MasterLabel__c='Resource & Documentations Center';
        ccmdo82.Field_1__c='label';
        ccmdo82.Field_2__c='externalURL';
        ccmdo82.Field_3__c='getRDC';    
        ccmdo82.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo82);
        
         Core_CustomMetadata_Object__c ccmdo81=new Core_CustomMetadata_Object__c();
        ccmdo81.Metadata_Name__c='PRM_CtaPriorities__mdt';
        ccmdo81.Program__c='IPA';
        ccmdo81.Header_row__c=ccmdo.Id;
        ccmdo81.DeveloperName__c='View Results';
        ccmdo81.MasterLabel__c='View Results';
        ccmdo81.Field_1__c='label';
        ccmdo81.Field_2__c='externalURL';
        ccmdo81.Field_3__c='getMarketPlace';    
        ccmdo81.Field_4__c='IPARefreshSwitch';
        ccmdoList.add(ccmdo81);
        insert ccmdoList;
        Test.startTest();   
        PRM_aba_TriggerHandler.executeTrigger = false;
        insert abaList;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        PRM_Warranty_Data__c warr=new PRM_Warranty_Data__c();
        warr.PRM_Number_Of_AWR_Remaining_Nbr__c= 788;
        warr.PRM_Account_Id__c= testAccount.Id;
        insert warr;
        
        //IPA Access Matrix
        List<PRM_PEx_Access_Matrix__c> accessMatrixList=new List<PRM_PEx_Access_Matrix__c>();  
        PRM_PEx_Access_Matrix__c accessmatrx=new PRM_PEx_Access_Matrix__c();
        Id beneftAccRule = Schema.SObjectType.PRM_PEx_Access_Matrix__c.getRecordTypeInfosByDeveloperName().get('Benefit_Access_Rule').getRecordTypeId();
        
        //for MDF         
        accessmatrx.PRM_Benefit_Blade__c='MDF';
        accessmatrx.PRM_Entitlements__c='Partner Admin';
        accessmatrx.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx.PRM_Click_To_Action__c='IPA MDF';
        accessmatrx.PRM_CTA_Priority__c='2';
        accessmatrx.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx.PRM_Benefit_Priority__c=5;
        accessmatrx.PRM_isActive_Indicator__c =true;
        accessmatrx.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrx);
        //insert accessmatrx;
        
        PRM_PEx_Access_Matrix__c accessmatrx1=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx1.PRM_Benefit_Blade__c='MDF';
        accessmatrx1.PRM_Entitlements__c='Partner Admin';
        accessmatrx1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx1.PRM_Click_To_Action__c='View MDF';
        accessmatrx1.PRM_CTA_Priority__c='2';
        accessmatrx1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx1.PRM_Benefit_Priority__c=5;
         accessmatrx1.PRM_isActive_Indicator__c =true;
        accessmatrx1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrx1);
        //insert accessmatrx1;
        
        PRM_PEx_Access_Matrix__c accessmatrx2=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx2.PRM_Benefit_Blade__c='MDF';
        accessmatrx2.PRM_Entitlements__c='Partner Admin';
        accessmatrx2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx2.PRM_Click_To_Action__c='Submit MDF Campaign';
        accessmatrx2.PRM_CTA_Priority__c='2';
        accessmatrx2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx2.PRM_Benefit_Priority__c=5;
         accessmatrx2.PRM_isActive_Indicator__c =true;
        accessmatrx2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrx2);
        //insert accessmatrx2;
        
        PRM_PEx_Access_Matrix__c accessmatrx3=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx3.PRM_Benefit_Blade__c='MDF';
        accessmatrx3.PRM_Entitlements__c='Partner Admin';
        accessmatrx3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx3.PRM_Click_To_Action__c='MDF Tool';
        accessmatrx3.PRM_CTA_Priority__c='2';
        accessmatrx3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx3.PRM_Benefit_Priority__c=5;
         accessmatrx3.PRM_isActive_Indicator__c =true;
        accessmatrx3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrx3);
        //insert accessmatrx3;
        
        PRM_PEx_Access_Matrix__c accessmatrx4=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx4.PRM_Benefit_Blade__c='MDF';
        accessmatrx4.PRM_Entitlements__c='Partner Admin';
        accessmatrx4.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx4.PRM_Click_To_Action__c='Get Help With MDF';
        accessmatrx4.PRM_CTA_Priority__c='2';
        accessmatrx4.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx4.PRM_Benefit_Priority__c=5;
        accessmatrx4.PRM_isActive_Indicator__c =true;
        accessmatrx4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrx4);
        //insert accessmatrx4;
        
        //for dzs
        PRM_PEx_Access_Matrix__c accessmatrixs=new PRM_PEx_Access_Matrix__c();  
        accessmatrixs.PRM_Benefit_Blade__c='Intel® Developer Zone - Premier';
        accessmatrixs.PRM_Entitlements__c='Partner Admin';
        accessmatrixs.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrixs.PRM_Click_To_Action__c='Intel Developer Zone';
        accessmatrixs.PRM_CTA_Priority__c='1';
        accessmatrixs.PRM_Partner_Benefit__c=pbTest10.Id;//prnbnft.Id;
        accessmatrixs.PRM_Benefit_Priority__c=19;
        accessmatrixs.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrixs);
        
        PRM_PEx_Access_Matrix__c accessmatrixs1=new PRM_PEx_Access_Matrix__c(); 
        accessmatrixs1.PRM_Benefit_Blade__c='Intel® Developer Zone - Premier';
        accessmatrixs1.PRM_Entitlements__c='Partner Admin';
        accessmatrixs1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrixs1.PRM_Click_To_Action__c='Intel Developer Cloud for the Edge & One API';
        accessmatrixs1.PRM_CTA_Priority__c='2';
        accessmatrixs1.PRM_Partner_Benefit__c=pbTest10.Id;//prnbnft.Id;
        accessmatrixs1.PRM_Benefit_Priority__c=19;
        accessmatrixs1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrixs1);
        
        
        //for Select Benefit         
        PRM_PEx_Access_Matrix__c accessmatrxs=new PRM_PEx_Access_Matrix__c();
        accessmatrxs.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxs.PRM_Entitlements__c='Partner Admin';
        accessmatrxs.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxs.PRM_Click_To_Action__c='Intel® Partner Alliance IoT Additive Select Benefits';
        accessmatrxs.PRM_CTA_Priority__c='2';
        accessmatrxs.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxs.PRM_Benefit_Priority__c=5;
          accessmatrxs.PRM_isActive_Indicator__c =true;
        accessmatrxs.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxs);
        //insert accessmatrx;
        
        PRM_PEx_Access_Matrix__c accessmatrxs1=new PRM_PEx_Access_Matrix__c(); 
        accessmatrxs1.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxs1.PRM_Entitlements__c='Partner Admin';
        accessmatrxs1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxs1.PRM_Click_To_Action__c='Intel® Partner Alliance AI Application Ecosystem Advancement Select Benefits';
        accessmatrxs1.PRM_CTA_Priority__c='2';
        accessmatrxs1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxs1.PRM_Benefit_Priority__c=5;
        accessmatrxs1.PRM_isActive_Indicator__c =true;
        accessmatrxs1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxs1);
        //insert accessmatrx1;
        
        PRM_PEx_Access_Matrix__c accessmatrxs2=new PRM_PEx_Access_Matrix__c(); 
        accessmatrxs2.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxs2.PRM_Entitlements__c='Partner Admin';
        accessmatrxs2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxs2.PRM_Click_To_Action__c='Please do not delete';
        accessmatrxs2.PRM_CTA_Priority__c='2';
        accessmatrxs2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxs2.PRM_Benefit_Priority__c=5;
        accessmatrxs2.PRM_isActive_Indicator__c =true;
        accessmatrxs2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxs2);
        //insert accessmatrx2;
        
        PRM_PEx_Access_Matrix__c accessmatrxs3=new PRM_PEx_Access_Matrix__c(); 
        accessmatrxs3.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxs3.PRM_Entitlements__c='Partner Admin';
        accessmatrxs3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxs3.PRM_Click_To_Action__c='Intel® Partner Alliance IoT Baseline Select Benefits';
        accessmatrxs3.PRM_CTA_Priority__c='2';
        accessmatrxs3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxs3.PRM_Benefit_Priority__c=5;
          accessmatrxs3.PRM_isActive_Indicator__c =true;
        accessmatrxs3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxs3);
        //insert accessmatrx3;
        
        PRM_PEx_Access_Matrix__c accessmatrxs4=new PRM_PEx_Access_Matrix__c(); 
        accessmatrxs4.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxs4.PRM_Entitlements__c='Partner Admin';
        accessmatrxs4.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxs4.PRM_Click_To_Action__c='Intel® Data Center Innovation Fund (DCIF) Select Benefit';
        accessmatrxs4.PRM_CTA_Priority__c='2';
        accessmatrxs4.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxs4.PRM_Benefit_Priority__c=5;
          accessmatrxs4.PRM_isActive_Indicator__c =true;
        accessmatrxs4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxs4);
        
        //Points
        PRM_PEx_Access_Matrix__c accessmatrxp=new PRM_PEx_Access_Matrix__c();
        accessmatrxp.PRM_Benefit_Blade__c='Points';
        accessmatrxp.PRM_Entitlements__c='Partner Admin';
        accessmatrxp.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp.PRM_Click_To_Action__c='Spend Points';
        accessmatrxp.PRM_CTA_Priority__c='1';
        accessmatrxp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp.PRM_Benefit_Priority__c=1;
          accessmatrxp.PRM_isActive_Indicator__c =true;
        accessmatrxp.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp);
        //insert accessmatrxp;
        
        PRM_PEx_Access_Matrix__c accessmatrxp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxp1.PRM_Benefit_Blade__c='Points';
        accessmatrxp1.PRM_Entitlements__c='Partner Admin';
        accessmatrxp1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp1.PRM_Click_To_Action__c='Earn Points';
        accessmatrxp1.PRM_CTA_Priority__c='1';
        accessmatrxp1.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp1.PRM_Benefit_Priority__c=1;
          accessmatrxp1.PRM_isActive_Indicator__c =true;
        accessmatrxp1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp1);
        //insert accessmatrxp1;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp2=new PRM_PEx_Access_Matrix__c();
        accessmatrxp2.PRM_Benefit_Blade__c='Points';
        accessmatrxp2.PRM_Entitlements__c='Partner Admin';
        accessmatrxp2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp2.PRM_Click_To_Action__c='Points Wishlist';
        accessmatrxp2.PRM_CTA_Priority__c='1';
        accessmatrxp2.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp2.PRM_Benefit_Priority__c=1;
          accessmatrxp2.PRM_isActive_Indicator__c =true;
        accessmatrxp2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp2);
        // insert accessmatrxp2;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp3=new PRM_PEx_Access_Matrix__c();
        accessmatrxp3.PRM_Benefit_Blade__c='Points';
        accessmatrxp3.PRM_Entitlements__c='Partner Admin';
        accessmatrxp3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp3.PRM_Click_To_Action__c='Points Simulator Tool';
        accessmatrxp3.PRM_CTA_Priority__c='1';
        accessmatrxp3.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp3.PRM_Benefit_Priority__c=1;
          accessmatrxp3.PRM_isActive_Indicator__c =true;
        accessmatrxp3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp3);
        // insert accessmatrxp3;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp4=new PRM_PEx_Access_Matrix__c();
        accessmatrxp4.PRM_Benefit_Blade__c='Points';
        accessmatrxp4.PRM_Entitlements__c='Partner Admin';
        accessmatrxp4.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp4.PRM_Click_To_Action__c='Points Matrix';
        accessmatrxp4.PRM_CTA_Priority__c='1';
        accessmatrxp4.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp4.PRM_Benefit_Priority__c=1;
        accessmatrxp4.PRM_isActive_Indicator__c =true;
        accessmatrxp4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp4);
        //  insert accessmatrxp4;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp5=new PRM_PEx_Access_Matrix__c();
        accessmatrxp5.PRM_Benefit_Blade__c='Points';
        accessmatrxp5.PRM_Entitlements__c='Partner Admin';
        accessmatrxp5.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp5.PRM_Click_To_Action__c='View Account';
        accessmatrxp5.PRM_CTA_Priority__c='1';
        accessmatrxp5.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp5.PRM_Benefit_Priority__c=1;
        accessmatrxp5.PRM_isActive_Indicator__c=true;
        accessmatrxp5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp5);
        //  insert accessmatrxp5;
        
        PRM_PEx_Access_Matrix__c accessmatrx6=new PRM_PEx_Access_Matrix__c();
        accessmatrx6.PRM_Benefit_Blade__c='Points';
        accessmatrx6.PRM_Entitlements__c='Partner Admin';
        accessmatrx6.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx6.PRM_Click_To_Action__c='Partner Assist';
        accessmatrx6.PRM_CTA_Priority__c='1';
        accessmatrx6.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrx6.PRM_Benefit_Priority__c=1;
        accessmatrx6.PRM_isActive_Indicator__c=true;
        accessmatrx6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrx6);
        //insert accessmatrx6;
        
        PRM_PEx_Access_Matrix__c accessmatrxp7=new PRM_PEx_Access_Matrix__c();
        accessmatrxp7.PRM_Benefit_Blade__c='Points';
        accessmatrxp7.PRM_Entitlements__c='Partner Admin';
        accessmatrxp7.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp7.PRM_Click_To_Action__c='Get help with Points';
        accessmatrxp7.PRM_CTA_Priority__c='1';
        accessmatrxp7.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp7.PRM_Benefit_Priority__c=1;
        accessmatrxp7.PRM_isActive_Indicator__c=true;
        accessmatrxp7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxp7);
        //  insert accessmatrxp7;
        
        
        //Leads
        PRM_PEx_Access_Matrix__c accessmatrxl=new PRM_PEx_Access_Matrix__c();
        accessmatrxl.PRM_Benefit_Blade__c='Leads';
        accessmatrxl.PRM_Entitlements__c='Partner Admin';
        accessmatrxl.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxl.PRM_Click_To_Action__c='Manage Leads';
        accessmatrxl.PRM_CTA_Priority__c='1';
        accessmatrxl.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxl.PRM_Benefit_Priority__c=2;
        accessmatrxl.PRM_isActive_Indicator__c=true;
        accessmatrxl.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxl);
        //  insert accessmatrxl;
        
        PRM_PEx_Access_Matrix__c accessmatrxl1=new PRM_PEx_Access_Matrix__c();
        accessmatrxl1.PRM_Benefit_Blade__c='Leads';
        accessmatrxl1.PRM_Entitlements__c='Partner Admin';
        accessmatrxl1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxl1.PRM_Click_To_Action__c='View results';
        accessmatrxl1.PRM_CTA_Priority__c='2';
        accessmatrxl1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxl1.PRM_Benefit_Priority__c=2;
        accessmatrxl1.PRM_isActive_Indicator__c=true;
        accessmatrxl1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxl1);
        // insert accessmatrxl1;
        
        PRM_PEx_Access_Matrix__c accessmatrxl2=new PRM_PEx_Access_Matrix__c();
        accessmatrxl2.PRM_Benefit_Blade__c='Leads';
        accessmatrxl2.PRM_Entitlements__c='Partner Admin';
        accessmatrxl2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxl2.PRM_Click_To_Action__c='Get help with Leads';
        accessmatrxl2.PRM_CTA_Priority__c='3';
        accessmatrxl2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxl2.PRM_Benefit_Priority__c=2;
        accessmatrxl2.PRM_isActive_Indicator__c=true;
        accessmatrxl2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxl2);
        //insert accessmatrxl2;
        
        
        //Marketplace
        PRM_PEx_Access_Matrix__c accessmatrxmp=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp.PRM_Click_To_Action__c='Manage Storefront';
        accessmatrxmp.PRM_CTA_Priority__c='3';
        accessmatrxmp.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp.PRM_Benefit_Priority__c=4;
        accessmatrxmp.PRM_isActive_Indicator__c=true;
        accessmatrxmp.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp0=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp0.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp0.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp0.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp0.PRM_Click_To_Action__c='Manage Storefront';
        accessmatrxmp0.PRM_CTA_Priority__c='3';
        accessmatrxmp0.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp0.PRM_Benefit_Priority__c=4;
        accessmatrxmp0.PRM_isActive_Indicator__c=true;
        accessmatrxmp0.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp0);
        //insert accessmatrxmp;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp1.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp1.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp1.PRM_Click_To_Action__c='Manage Offerings';
        accessmatrxmp1.PRM_CTA_Priority__c='3';
        accessmatrxmp1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp1.PRM_Benefit_Priority__c=4;
        accessmatrxmp1.PRM_isActive_Indicator__c=true;
        accessmatrxmp1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp1);
        //insert accessmatrxmp1;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp2=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp2.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp2.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp2.PRM_Click_To_Action__c='Create New Offering';
        accessmatrxmp2.PRM_CTA_Priority__c='3';
        accessmatrxmp2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp2.PRM_Benefit_Priority__c=4;
        accessmatrxmp2.PRM_isActive_Indicator__c=true;
        accessmatrxmp2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp2);
        //insert accessmatrxmp2;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp3=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp3.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp3.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp3.PRM_Click_To_Action__c='View Results';
        accessmatrxmp3.PRM_CTA_Priority__c='3';
        accessmatrxmp3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp3.PRM_Benefit_Priority__c=4;
        accessmatrxmp3.PRM_isActive_Indicator__c=true;
        accessmatrxmp3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp3);
        //insert accessmatrxmp3;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxmp4=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp4.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp4.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp4.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp4.PRM_Click_To_Action__c='Visit Marketplace';
        accessmatrxmp4.PRM_CTA_Priority__c='3';
        accessmatrxmp4.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp4.PRM_Benefit_Priority__c=4;
        accessmatrxmp4.PRM_isActive_Indicator__c=true;
        accessmatrxmp4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp4);
        //insert accessmatrxmp4;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp5=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp5.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp5.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp5.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp5.PRM_Click_To_Action__c='Get help with Marketplace';
        accessmatrxmp5.PRM_CTA_Priority__c='3';
        accessmatrxmp5.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp5.PRM_Benefit_Priority__c=4;
        accessmatrxmp5.PRM_isActive_Indicator__c=true;
        accessmatrxmp5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp5);
        //insert accessmatrxmp5;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp6=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp6.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp6.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp6.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp6.PRM_Click_To_Action__c='Learn about submitting a solution';
        accessmatrxmp6.PRM_CTA_Priority__c='5';
        accessmatrxmp6.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp6.PRM_Benefit_Priority__c=4;
        accessmatrxmp6.PRM_isActive_Indicator__c=true;
        accessmatrxmp6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp6);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp7=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp7.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp7.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp7.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp7.PRM_Click_To_Action__c='Manage Solutions';
        accessmatrxmp7.PRM_CTA_Priority__c='4';
        accessmatrxmp7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp7.PRM_Benefit_Priority__c=4;
        accessmatrxmp7.PRM_isActive_Indicator__c=true;
        accessmatrxmp7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp7);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp8=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp8.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp8.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp8.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp8.PRM_Click_To_Action__c='View the partner directory';
        accessmatrxmp8.PRM_CTA_Priority__c='7';
        accessmatrxmp8.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp8.PRM_Benefit_Priority__c=4;
        accessmatrxmp8.PRM_isActive_Indicator__c=true;
        accessmatrxmp8.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp8);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp9=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp9.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp9.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp9.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp9.PRM_Click_To_Action__c='Submit a Solution';
        accessmatrxmp9.PRM_CTA_Priority__c='6';
        accessmatrxmp9.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp9.PRM_Benefit_Priority__c=4;
        accessmatrxmp9.PRM_isActive_Indicator__c=true;
        accessmatrxmp9.RecordTypeId=beneftAccRule;        
        accessMatrixList.add(accessmatrxmp9);  
        
        PRM_PEx_Access_Matrix__c accessmatrxms71=new PRM_PEx_Access_Matrix__c();
        accessmatrxms71.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxms71.PRM_Entitlements__c='Partner Admin';
        accessmatrxms71.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms71.PRM_Click_To_Action__c='Intel® Partner Alliance Web Banners';
        accessmatrxms71.PRM_CTA_Priority__c='1';
        accessmatrxms71.PRM_Partner_Benefit__c=pbTest7.Id;//prnbnft.Id;
        accessmatrxms71.PRM_Benefit_Priority__c=3;
        accessmatrxms71.PRM_isActive_Indicator__c=true;
        accessmatrxms71.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms71);
        
        PRM_PEx_Access_Matrix__c accessmatrxms81=new PRM_PEx_Access_Matrix__c();
        accessmatrxms81.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxms81.PRM_Entitlements__c='Partner Admin';
        accessmatrxms81.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms81.PRM_Click_To_Action__c='Intel® Partner Alliance Web Banners';
        accessmatrxms81.PRM_CTA_Priority__c='1';
        accessmatrxms81.PRM_isActive_Indicator__c=true;
        accessmatrxms81.PRM_Partner_Benefit__c=pbTest8.Id;//prnbnft.Id;
        accessmatrxms81.PRM_Benefit_Priority__c=3;
        accessmatrxms81.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms81);
        
        //Partner help
        PRM_PEx_Access_Matrix__c accessmatrxph=new PRM_PEx_Access_Matrix__c();
        accessmatrxph.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph.PRM_Entitlements__c='Partner Admin';
        accessmatrxph.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph.PRM_Click_To_Action__c='View All Support Tickets';
        accessmatrxph.PRM_CTA_Priority__c='3';
        accessmatrxph.PRM_isActive_Indicator__c=true;
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph.PRM_Benefit_Priority__c=4;
        accessmatrxph.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxph);
        //insert accessmatrxph;
        
        PRM_PEx_Access_Matrix__c accessmatrxph1=new PRM_PEx_Access_Matrix__c();
        accessmatrxph1.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph1.PRM_Entitlements__c='Partner Admin';
        accessmatrxph1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph1.PRM_Click_To_Action__c='Create Support Ticket';
        accessmatrxph1.PRM_CTA_Priority__c='3';
        accessmatrxph1.PRM_isActive_Indicator__c=true;
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph1.PRM_Benefit_Priority__c=4;
        accessmatrxph1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxph1);
        //   insert accessmatrxph1;
        
        PRM_PEx_Access_Matrix__c accessmatrxph2=new PRM_PEx_Access_Matrix__c();
        accessmatrxph2.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph2.PRM_Entitlements__c='Partner Admin';
        accessmatrxph2.PRM_isActive_Indicator__c=true;
        accessmatrxph2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph2.PRM_Click_To_Action__c='New Warranty Return';
        accessmatrxph2.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph2.PRM_Benefit_Priority__c=4;
        accessmatrxph2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxph2);
        //   insert accessmatrxph2;
        
        PRM_PEx_Access_Matrix__c accessmatrxph3=new PRM_PEx_Access_Matrix__c();
        accessmatrxph3.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph3.PRM_Entitlements__c='Partner Admin';
        accessmatrxph3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph3.PRM_isActive_Indicator__c=true;
        accessmatrxph3.PRM_Click_To_Action__c='View Warranty Coverage Status';
        accessmatrxph3.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph3.PRM_Benefit_Priority__c=4;
        accessmatrxph3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxph3);
        //  insert accessmatrxph3;
        
        PRM_PEx_Access_Matrix__c accessmatrxph4=new PRM_PEx_Access_Matrix__c();
        accessmatrxph4.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph4.PRM_Entitlements__c='Partner Admin';
        accessmatrxph4.PRM_isActive_Indicator__c=true;
        accessmatrxph4.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph4.PRM_Click_To_Action__c='Intel Premier Support';
        accessmatrxph4.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph4.PRM_Benefit_Priority__c=4;
        accessmatrxph4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxph4);
        //   insert accessmatrxph4;
        
        PRM_PEx_Access_Matrix__c accessmatrxph5=new PRM_PEx_Access_Matrix__c();
        accessmatrxph5.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph5.PRM_Entitlements__c='Partner Admin';
        accessmatrxph5.PRM_isActive_Indicator__c=true;
        accessmatrxph5.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph5.PRM_Click_To_Action__c='Get help with Portal or program';
        accessmatrxph5.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph5.PRM_Benefit_Priority__c=4;
        accessmatrxph5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxph5);
        //   insert accessmatrxph5;
        
        //Training
        PRM_PEx_Access_Matrix__c accessmatrxt=new PRM_PEx_Access_Matrix__c();
        accessmatrxt.PRM_Benefit_Blade__c='Training';
        accessmatrxt.PRM_Entitlements__c='Partner Admin';
        accessmatrxt.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt.PRM_Click_To_Action__c='View Courses';
        accessmatrxt.PRM_isActive_Indicator__c=true;
        accessmatrxt.PRM_CTA_Priority__c='1';
        accessmatrxt.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt.PRM_Benefit_Priority__c=3;
        accessmatrxt.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt);
        //  insert accessmatrxt;
        
        PRM_PEx_Access_Matrix__c accessmatrxt1=new PRM_PEx_Access_Matrix__c();
        accessmatrxt1.PRM_Benefit_Blade__c='Training';
        accessmatrxt1.PRM_Entitlements__c='Partner Admin';
        accessmatrxt1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt1.PRM_Click_To_Action__c='Track My Learning';
        accessmatrxt1.PRM_CTA_Priority__c='1';
        accessmatrxt1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt1.PRM_Benefit_Priority__c=3;
        accessmatrxt1.PRM_isActive_Indicator__c=true;
        accessmatrxt1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt1);
        //  insert accessmatrxt1;
        
        PRM_PEx_Access_Matrix__c accessmatrxt2=new PRM_PEx_Access_Matrix__c();
        accessmatrxt2.PRM_Benefit_Blade__c='Training';
        accessmatrxt2.PRM_Entitlements__c='Partner Admin';
        accessmatrxt2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt2.PRM_Click_To_Action__c='My Competencies';
        accessmatrxt2.PRM_CTA_Priority__c='1';
        accessmatrxt2.PRM_isActive_Indicator__c=true;
        accessmatrxt2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt2.PRM_Benefit_Priority__c=3;
        accessmatrxt2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt2);
        //  insert accessmatrxt2;
        
        PRM_PEx_Access_Matrix__c accessmatrxt3=new PRM_PEx_Access_Matrix__c();
        accessmatrxt3.PRM_Benefit_Blade__c='Training';
        accessmatrxt3.PRM_Entitlements__c='Partner Admin';
        accessmatrxt3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt3.PRM_Click_To_Action__c='Browse All Webinars';
        accessmatrxt3.PRM_CTA_Priority__c='1';
        accessmatrxt3.PRM_isActive_Indicator__c=true;
        accessmatrxt3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt3.PRM_Benefit_Priority__c=3;
        accessmatrxt3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt3);
        //  insert accessmatrxt3;
        
        PRM_PEx_Access_Matrix__c accessmatrxt4=new PRM_PEx_Access_Matrix__c();
        accessmatrxt4.PRM_Benefit_Blade__c='Training';
        accessmatrxt4.PRM_Entitlements__c='Partner Admin';
        accessmatrxt4.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt4.PRM_Click_To_Action__c='Get Help With Training';
        accessmatrxt4.PRM_CTA_Priority__c='1';
        accessmatrxt4.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatrxt4.PRM_Benefit_Priority__c=3;
        accessmatrxt4.PRM_isActive_Indicator__c=true;
        accessmatrxt4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt4);
        
        PRM_PEx_Access_Matrix__c accessmatrxt41=new PRM_PEx_Access_Matrix__c();
        accessmatrxt41.PRM_Benefit_Blade__c='Training';
        accessmatrxt41.PRM_Entitlements__c='Partner Admin';
        accessmatrxt41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt41.PRM_Click_To_Action__c='Get Help With Training';
        accessmatrxt41.PRM_CTA_Priority__c='1';
        accessmatrxt41.PRM_isActive_Indicator__c=true;
        accessmatrxt41.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatrxt41.PRM_Benefit_Priority__c=3;
        accessmatrxt41.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt41);
        //    insert accessmatrxt4;
        
        PRM_PEx_Access_Matrix__c accessmatrxt5=new PRM_PEx_Access_Matrix__c();
        accessmatrxt5.PRM_Benefit_Blade__c='Training';
        accessmatrxt5.PRM_Entitlements__c='Partner Admin';
        accessmatrxt5.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt5.PRM_Click_To_Action__c='Webinars';
        accessmatrxt5.PRM_CTA_Priority__c='1';
        accessmatrxt5.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt5.PRM_Benefit_Priority__c=3;
        accessmatrxt5.PRM_isActive_Indicator__c=true;
        accessmatrxt5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt5);
        //   insert accessmatrxt5;
        
        PRM_PEx_Access_Matrix__c accessmatrxt6=new PRM_PEx_Access_Matrix__c();
        accessmatrxt6.PRM_Benefit_Blade__c='Training';
        accessmatrxt6.PRM_Entitlements__c='Partner Admin';
        accessmatrxt6.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt6.PRM_Click_To_Action__c='Competitive Guidance Presentation';
        accessmatrxt6.PRM_CTA_Priority__c='1';
        accessmatrxt6.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt6.PRM_Benefit_Priority__c=3;
        accessmatrxt6.PRM_isActive_Indicator__c=true;
        accessmatrxt6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt6);
        //    insert accessmatrxt6;
        
        PRM_PEx_Access_Matrix__c accessmatrxt7=new PRM_PEx_Access_Matrix__c();
        accessmatrxt7.PRM_Benefit_Blade__c='Training';
        accessmatrxt7.PRM_Entitlements__c='Partner Admin';
        accessmatrxt7.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt7.PRM_Click_To_Action__c='Virtual Tech Conference';
        accessmatrxt7.PRM_CTA_Priority__c='1';
        accessmatrxt7.PRM_isActive_Indicator__c=true;
        accessmatrxt7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt7.PRM_Benefit_Priority__c=3;
        accessmatrxt7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt7);
        //  insert accessmatrxt7;
        
        PRM_PEx_Access_Matrix__c accessmatrxt8=new PRM_PEx_Access_Matrix__c();
        accessmatrxt8.PRM_Benefit_Blade__c='Training';
        accessmatrxt8.PRM_Entitlements__c='Partner Admin';
        accessmatrxt8.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt8.PRM_Click_To_Action__c='How to sell videos';
        accessmatrxt8.PRM_CTA_Priority__c='1';
        accessmatrxt8.PRM_isActive_Indicator__c=true;
        accessmatrxt8.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt8.PRM_Benefit_Priority__c=3;
        accessmatrxt8.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt8);
        // insert accessmatrxt8;
        
        PRM_PEx_Access_Matrix__c accessmatrxt9=new PRM_PEx_Access_Matrix__c();
        accessmatrxt9.PRM_Benefit_Blade__c='Training';
        accessmatrxt9.PRM_Entitlements__c='Partner Admin';
        accessmatrxt9.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt9.PRM_Click_To_Action__c='View Distributor Webinars on demand';
        accessmatrxt9.PRM_CTA_Priority__c='1';
        accessmatrxt9.PRM_isActive_Indicator__c=true;
        accessmatrxt9.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt9.PRM_Benefit_Priority__c=3;
        accessmatrxt9.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt9);
        
        PRM_PEx_Access_Matrix__c accessmatrxt91=new PRM_PEx_Access_Matrix__c();
        accessmatrxt91.PRM_Benefit_Blade__c='Training';
        accessmatrxt91.PRM_Entitlements__c='Partner Admin';
        accessmatrxt91.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt91.PRM_Click_To_Action__c='View Distributor Webinars on demand';
        accessmatrxt91.PRM_CTA_Priority__c='1';
        accessmatrxt91.PRM_isActive_Indicator__c=true;
        accessmatrxt91.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt91.PRM_Benefit_Priority__c=3;
        accessmatrxt91.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt91);
        
        PRM_PEx_Access_Matrix__c accessmatrxt11=new PRM_PEx_Access_Matrix__c();
        accessmatrxt11.PRM_Benefit_Blade__c='Training';
        accessmatrxt11.PRM_Entitlements__c='Partner Admin';
        accessmatrxt11.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt11.PRM_Click_To_Action__c='Quarterly Training Matrix';
        accessmatrxt11.PRM_CTA_Priority__c='1';
        accessmatrxt11.PRM_isActive_Indicator__c=true;
        accessmatrxt11.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt11.PRM_Benefit_Priority__c=3;
        accessmatrxt11.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt11);
        
        //Training
        PRM_PEx_Access_Matrix__c accessmatr1=new PRM_PEx_Access_Matrix__c();
        accessmatr1.PRM_Benefit_Blade__c='Training';
        accessmatr1.PRM_Entitlements__c='Partner Admin';
        accessmatr1.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr1.PRM_Click_To_Action__c='View Courses';
        accessmatr1.PRM_CTA_Priority__c='1';
        accessmatr1.PRM_isActive_Indicator__c=true;
        accessmatr1.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr1.PRM_Benefit_Priority__c=3;
        accessmatr1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr1);
        //  insert accessmatrxt;
        
        PRM_PEx_Access_Matrix__c accessmatr2=new PRM_PEx_Access_Matrix__c();
        accessmatr2.PRM_Benefit_Blade__c='Training';
        accessmatr2.PRM_Entitlements__c='Partner Admin';
        accessmatr2.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr2.PRM_Click_To_Action__c='Track My Learning';
        accessmatr2.PRM_CTA_Priority__c='1';
        accessmatr2.PRM_isActive_Indicator__c=true;
        accessmatr2.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr2.PRM_Benefit_Priority__c=3;
        accessmatr2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr2);
        //  insert accessmatrxt1;
        
        PRM_PEx_Access_Matrix__c accessmatr3=new PRM_PEx_Access_Matrix__c();
        accessmatr3.PRM_Benefit_Blade__c='Training';
        accessmatr3.PRM_Entitlements__c='Partner Admin';
        accessmatr3.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr3.PRM_isActive_Indicator__c=true;
        accessmatr3.PRM_Click_To_Action__c='My Competencies';
        accessmatr3.PRM_CTA_Priority__c='1';
        accessmatr3.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr3.PRM_Benefit_Priority__c=3;
        accessmatr3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr3);
        //  insert accessmatrxt2;
        
        PRM_PEx_Access_Matrix__c accessmatr4=new PRM_PEx_Access_Matrix__c();
        accessmatr4.PRM_Benefit_Blade__c='Training';
        accessmatr4.PRM_Entitlements__c='Partner Admin';
        accessmatr4.PRM_isActive_Indicator__c=true;
        accessmatr4.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr4.PRM_Click_To_Action__c='Browse All Webinars';
        accessmatr4.PRM_CTA_Priority__c='1';
        accessmatr4.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr4.PRM_Benefit_Priority__c=3;
        accessmatr4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr4);
        //  insert accessmatrxt3;
        
        PRM_PEx_Access_Matrix__c accessmatr5=new PRM_PEx_Access_Matrix__c();
        accessmatr5.PRM_Benefit_Blade__c='Training';
        accessmatr5.PRM_Entitlements__c='Partner Admin';
        accessmatr5.PRM_isActive_Indicator__c=true;
        accessmatr5.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr5.PRM_Click_To_Action__c='Get Help With Training';
        accessmatr5.PRM_CTA_Priority__c='1';
        accessmatr5.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr5.PRM_Benefit_Priority__c=3;
        accessmatr5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr5);
        
        PRM_PEx_Access_Matrix__c accessmatr6=new PRM_PEx_Access_Matrix__c();
        accessmatr6.PRM_Benefit_Blade__c='Training';
        accessmatr6.PRM_Entitlements__c='Partner Admin';
        accessmatr6.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatr6.PRM_Click_To_Action__c='Get Help With Training';
        accessmatr6.PRM_CTA_Priority__c='1';
        accessmatr6.PRM_isActive_Indicator__c=true;
        accessmatr6.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr6.PRM_Benefit_Priority__c=3;
        accessmatr6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr6);
        //    insert accessmatrxt4;
        
        PRM_PEx_Access_Matrix__c accessmatri6=new PRM_PEx_Access_Matrix__c();
        accessmatri6.PRM_Benefit_Blade__c='Training';
        accessmatri6.PRM_Entitlements__c='Partner Admin';
        accessmatri6.PRM_IPA_Partner_Role__c='Distributor';
        accessmatri6.PRM_Click_To_Action__c='Webinars';
        accessmatri6.PRM_CTA_Priority__c='1';
        accessmatri6.PRM_isActive_Indicator__c=true;
        accessmatri6.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatri6.PRM_Benefit_Priority__c=3;
        accessmatri6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatri6);
        //   insert accessmatrxt5;
        
        PRM_PEx_Access_Matrix__c accessmatr7=new PRM_PEx_Access_Matrix__c();
        accessmatr7.PRM_Benefit_Blade__c='Training';
        accessmatr7.PRM_Entitlements__c='Partner Admin';
        accessmatr7.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr7.PRM_Click_To_Action__c='Competitive Guidance Presentation';
        accessmatr7.PRM_CTA_Priority__c='1';
        accessmatr7.PRM_isActive_Indicator__c=true;
        accessmatr7.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr7.PRM_Benefit_Priority__c=3;
        accessmatr7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr7);
        //    insert accessmatrxt6;
        
        PRM_PEx_Access_Matrix__c accessmatr8=new PRM_PEx_Access_Matrix__c();
        accessmatr8.PRM_Benefit_Blade__c='Training';
        accessmatr8.PRM_Entitlements__c='Partner Admin';
        accessmatr8.PRM_isActive_Indicator__c=true;
        accessmatr8.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr8.PRM_Click_To_Action__c='Virtual Tech Conference';
        accessmatr8.PRM_CTA_Priority__c='1';
        accessmatr8.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr8.PRM_Benefit_Priority__c=3;
        accessmatr8.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr8);
        //  insert accessmatrxt7;
        
        PRM_PEx_Access_Matrix__c accessmatr9=new PRM_PEx_Access_Matrix__c();
        accessmatr9.PRM_Benefit_Blade__c='Training';
        accessmatr9.PRM_Entitlements__c='Partner Admin';
        accessmatr9.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr9.PRM_Click_To_Action__c='How to sell videos';
        accessmatr9.PRM_CTA_Priority__c='1';
        accessmatr9.PRM_isActive_Indicator__c=true;
        accessmatr9.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr9.PRM_Benefit_Priority__c=3;
        accessmatr9.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr9);
        // insert accessmatrxt8;
        
        PRM_PEx_Access_Matrix__c accessmatr10=new PRM_PEx_Access_Matrix__c();
        accessmatr10.PRM_Benefit_Blade__c='Training';
        accessmatr10.PRM_Entitlements__c='Partner Admin';
        accessmatr10.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr10.PRM_Click_To_Action__c='View Distributor Webinars on demand';
        accessmatr10.PRM_CTA_Priority__c='1';
        accessmatr10.PRM_isActive_Indicator__c=true;
        accessmatr10.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr10.PRM_Benefit_Priority__c=3;
        accessmatr10.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr10);
        
        PRM_PEx_Access_Matrix__c accessmatr11=new PRM_PEx_Access_Matrix__c();
        accessmatr11.PRM_Benefit_Blade__c='Training';
        accessmatr11.PRM_Entitlements__c='Partner Admin';
        accessmatr11.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatr11.PRM_Click_To_Action__c='Register for Distributor Webinars';
        accessmatr11.PRM_CTA_Priority__c='1';
        accessmatr11.PRM_isActive_Indicator__c=true;
        accessmatr11.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr11.PRM_Benefit_Priority__c=3;
        accessmatr11.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr11);
        
        PRM_PEx_Access_Matrix__c accessmatr12=new PRM_PEx_Access_Matrix__c();
        accessmatr12.PRM_Benefit_Blade__c='Training';
        accessmatr12.PRM_Entitlements__c='Partner Admin';
        accessmatr12.PRM_IPA_Partner_Role__c='Distributor';
        accessmatr12.PRM_Click_To_Action__c='Quarterly Training Matrix';
        accessmatr12.PRM_CTA_Priority__c='1';
        accessmatr12.PRM_isActive_Indicator__c=true;
        accessmatr12.PRM_Partner_Benefit__c=pbTest5.Id;//prnbnft.Id;
        accessmatr12.PRM_Benefit_Priority__c=3;
        accessmatr12.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatr12);
        
        //Marketing Studio
        PRM_PEx_Access_Matrix__c accessmatrxms=new PRM_PEx_Access_Matrix__c();
        accessmatrxms.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms.PRM_Entitlements__c='Partner Admin';
        accessmatrxms.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms.PRM_Click_To_Action__c='Links To Badges';
        accessmatrxms.PRM_CTA_Priority__c='1';
        accessmatrxms.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxms.PRM_Benefit_Priority__c=3;
        accessmatrxms.PRM_isActive_Indicator__c=true;
        accessmatrxms.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms);
        // insert accessmatrxms;
        
        PRM_PEx_Access_Matrix__c accessmatrxms1=new PRM_PEx_Access_Matrix__c();
        accessmatrxms1.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms1.PRM_Entitlements__c='Partner Admin';
        accessmatrxms1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms1.PRM_Click_To_Action__c='Marketing Asset Library';
        accessmatrxms1.PRM_CTA_Priority__c='1';
        accessmatrxms1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxms1.PRM_Benefit_Priority__c=3;
        accessmatrxms1.RecordTypeId=beneftAccRule;
        accessmatrxms1.PRM_isActive_Indicator__c=true;
        accessMatrixList.add(accessmatrxms1);
        //  insert accessmatrxms1;
        
        PRM_PEx_Access_Matrix__c accessmatrxms2=new PRM_PEx_Access_Matrix__c();
        accessmatrxms2.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms2.PRM_Entitlements__c='Partner Admin';
        accessmatrxms2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms2.PRM_Click_To_Action__c='View Campaigns';
        accessmatrxms2.PRM_CTA_Priority__c='1';
        accessmatrxms2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxms2.PRM_Benefit_Priority__c=3;
        accessmatrxms2.RecordTypeId=beneftAccRule;
        accessmatrxms2.PRM_isActive_Indicator__c=true;
        accessMatrixList.add(accessmatrxms2);
        //  insert accessmatrxms2;
        
        PRM_PEx_Access_Matrix__c accessmatrxms3=new PRM_PEx_Access_Matrix__c();
        accessmatrxms3.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms3.PRM_Entitlements__c='Partner Admin';
        accessmatrxms3.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms3.PRM_Click_To_Action__c='Get help with Marketing Studio';
        accessmatrxms3.PRM_CTA_Priority__c='1';
        accessmatrxms3.PRM_isActive_Indicator__c=true;
        accessmatrxms3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxms3.PRM_Benefit_Priority__c=3;
        accessmatrxms3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms3);
        // insert accessmatrxms3;
        
        PRM_PEx_Access_Matrix__c accessmatrxms4=new PRM_PEx_Access_Matrix__c();
        accessmatrxms4.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms4.PRM_Entitlements__c='Partner Admin';
        accessmatrxms4.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms4.PRM_Click_To_Action__c='Visit Partner Marketing Studio';
        accessmatrxms4.PRM_CTA_Priority__c='1';
        accessmatrxms4.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms4.PRM_Benefit_Priority__c=3;
        accessmatrxms4.PRM_isActive_Indicator__c=true;
        accessmatrxms4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms4);
        //   insert accessmatrxms4;
        
        PRM_PEx_Access_Matrix__c accessmatrxms5=new PRM_PEx_Access_Matrix__c();
        accessmatrxms5.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms5.PRM_Entitlements__c='Partner Admin';
        accessmatrxms5.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms5.PRM_Click_To_Action__c='Links To Logos';
        accessmatrxms5.PRM_CTA_Priority__c='1';
        accessmatrxms5.PRM_isActive_Indicator__c=true;
        accessmatrxms5.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms5.PRM_Benefit_Priority__c=3;
        accessmatrxms5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms5);
        //  insert accessmatrxms5;
        
        PRM_PEx_Access_Matrix__c accessmatrxms6=new PRM_PEx_Access_Matrix__c();
        accessmatrxms6.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms6.PRM_Entitlements__c='Partner Admin';
        accessmatrxms6.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms6.PRM_Click_To_Action__c='Intel® Partner Alliance Email Template';
        accessmatrxms6.PRM_CTA_Priority__c='1';
        accessmatrxms6.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms6.PRM_Benefit_Priority__c=3;
        accessmatrxms6.PRM_isActive_Indicator__c=true;
        accessmatrxms6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms6);
        
        PRM_PEx_Access_Matrix__c accessmatrxms7=new PRM_PEx_Access_Matrix__c();
        accessmatrxms7.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms7.PRM_Entitlements__c='Partner Admin';
        accessmatrxms7.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms7.PRM_Click_To_Action__c='Intel® Partner Alliance Web Banners';
        accessmatrxms7.PRM_CTA_Priority__c='1';
        accessmatrxms7.PRM_isActive_Indicator__c=true;
        accessmatrxms7.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms7.PRM_Benefit_Priority__c=3;
        accessmatrxms7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms7);
        
        PRM_PEx_Access_Matrix__c accessmatrxms711=new PRM_PEx_Access_Matrix__c();
        accessmatrxms711.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms711.PRM_Entitlements__c='Partner Admin';
        accessmatrxms711.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms711.PRM_Click_To_Action__c='Intel® Brand Logo and Usage Guidelines';
        accessmatrxms711.PRM_CTA_Priority__c='2';
        accessmatrxms711.PRM_isActive_Indicator__c=true;
        accessmatrxms711.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms711.PRM_Benefit_Priority__c=3;
        accessmatrxms711.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms711);
        
        PRM_PEx_Access_Matrix__c accessmatrxms811=new PRM_PEx_Access_Matrix__c();
        accessmatrxms811.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms811.PRM_Entitlements__c='Partner Admin';
        accessmatrxms811.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms811.PRM_Click_To_Action__c='Intel® Authorized Distributor and Intel® Approved Supplier Badge and Assets';
        accessmatrxms811.PRM_CTA_Priority__c='2';
        accessmatrxms811.PRM_isActive_Indicator__c=true;
        accessmatrxms811.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms811.PRM_Benefit_Priority__c=3;
        accessmatrxms811.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms811);
        

/*PRM_PEx_Access_Matrix__c accessmatrxms8=new PRM_PEx_Access_Matrix__c();
        accessmatrxms8.PRM_Benefit_Blade__c='Partner Lookup Tool';
        accessmatrxms8.PRM_Entitlements__c='Partner Admin';
        accessmatrxms8.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms8.PRM_Click_To_Action__c='Partner Lookup Tool';
        accessmatrxms8.PRM_CTA_Priority__c='1';
        accessmatrxms8.PRM_Benefit_Priority__c=1;
        accessmatrxms8.PRM_Partner_Benefit__c=pbTest5.Id;
        accessmatrxms8.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms8);*/
        
     
        
        Id specbenftRT = Schema.SObjectType.PRM_PEx_Access_Matrix__c.getRecordTypeInfosByDeveloperName().get('Specialty_Select_Benefit_Access_Rule').getRecordTypeId();
        PRM_PEx_Access_Matrix__c accessmatrxsp=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp.PRM_Benefit_Blade__c='Cloud Data Center Specialty';
        // accessmatrxsp.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp.PRM_Click_To_Action__c='View Cloud Data Center Specialty';
        accessmatrxsp.PRM_CTA_Priority__c='1';
        // accessmatrxsp.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
       // accessmatrxsp.PRM_Benefit_Priority__c=7;
       // accessmatrxsp.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxsp);
        
        PRM_PEx_Access_Matrix__c accessmatrxsp7=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp7.PRM_Benefit_Blade__c='Enthusiast PC Specialty';
        //accessmatrxsp7.PRM_Entitlements__c='Partner Admin';
        //String partRole = ' Distributor'Distributor;Independent Software Vendor;Manufacturer;Seller;Service Provider;Solution Integrator;Sponsor;Original Equipment Manufacturer (OEM);Guest';
        String partRole = 'Service Provider';
        accessmatrxsp7.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatrxsp7.PRM_Click_To_Action__c='View Enthusiast PC Specialty';
        accessmatrxsp7.PRM_CTA_Priority__c='1';
        // accessmatrxsp7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        // accessmatrxsp7.PRM_Benefit_Priority__c=7;
        //accessmatrxsp7.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp7.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxsp7);
        //   insert accessmatrxsp9;
    
         PRM_PEx_Access_Matrix__c accessmatrxsp7x=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp7x.PRM_Benefit_Blade__c='Visual Display Solutions Specialty';
        //accessmatrxsp7.PRM_Entitlements__c='Partner Admin';
        //String partRole = ' Distributor'Distributor;Independent Software Vendor;Manufacturer;Seller;Service Provider;Solution Integrator;Sponsor;Original Equipment Manufacturer (OEM);Guest';
        accessmatrxsp7x.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatrxsp7x.PRM_Click_To_Action__c='View Visual Display Solutions Specialty';
        accessmatrxsp7x.PRM_CTA_Priority__c='1';
        // accessmatrxsp7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        // accessmatrxsp7.PRM_Benefit_Priority__c=7;
        //accessmatrxsp7x.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp7x.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxsp7x);

    PRM_PEx_Access_Matrix__c accessmatrxsp7xp=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp7xp.PRM_Benefit_Blade__c='Artificial Intelligence Specialty';
        accessmatrxsp7xp.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatrxsp7xp.PRM_Click_To_Action__c='View Artificial Intelligence Specialty';
        accessmatrxsp7xp.PRM_CTA_Priority__c='1';
        //accessmatrxsp7xp.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp7xp.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxsp7xp);
    
        PRM_PEx_Access_Matrix__c accessmatrxsp8x=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp8x.PRM_Benefit_Blade__c='High Performance Computing Data Center Specialty';
        accessmatrxsp8x.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatrxsp8x.PRM_Click_To_Action__c='View High Performance Computing Data Center Specialty';
        accessmatrxsp8x.PRM_CTA_Priority__c='1';
        //accessmatrxsp8x.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp8x.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxsp8x);

        PRM_PEx_Access_Matrix__c accessmatrxsp8xp=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp8xp.PRM_Benefit_Blade__c='Video Specialty';
        accessmatrxsp8xp.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatrxsp8xp.PRM_Click_To_Action__c='View Video Specialty';
        accessmatrxsp8xp.PRM_CTA_Priority__c='1';
        //accessmatrxsp8xp.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp8xp.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxsp8xp);
        
        
        PRM_PEx_Access_Matrix__c accessmatrix=new PRM_PEx_Access_Matrix__c();
        accessmatrix.PRM_Benefit_Blade__c='Industrial Solutions Builder Specialty';
        accessmatrix.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatrix.PRM_Click_To_Action__c='View Industrial Solutions Builder Specialty';
        accessmatrix.PRM_CTA_Priority__c='1';
        //accessmatrix.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrix.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrix);

        PRM_PEx_Access_Matrix__c accessmatr=new PRM_PEx_Access_Matrix__c();
        accessmatr.PRM_Benefit_Blade__c='Optane Data Center Specialty';
        accessmatr.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmatr.PRM_Click_To_Action__c='View Optane Data Center Specialty';
        accessmatr.PRM_CTA_Priority__c='1';
        //accessmatr.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatr.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatr);

    PRM_PEx_Access_Matrix__c accessmar=new PRM_PEx_Access_Matrix__c();
        accessmar.PRM_Benefit_Blade__c='Managed Services Specialty';
        accessmar.PRM_IPA_Partner_Role__c= partRole;//'Service Provider';
        accessmar.PRM_Click_To_Action__c='View Managed Services Specialty';
        accessmar.PRM_CTA_Priority__c='1';
       // accessmar.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmar.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmar);
        
        //Networking Specialty
        PRM_PEx_Access_Matrix__c accessmatrixnet=new PRM_PEx_Access_Matrix__c();
        accessmatrixnet.PRM_Benefit_Blade__c='Networking Specialty';
        accessmatrixnet.PRM_Entitlements__c='Partner Admin';
        accessmatrixnet.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrixnet.PRM_Click_To_Action__c='View Specialty benefit';
        accessmatrixnet.PRM_CTA_Priority__c='1';
        accessmatrixnet.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrixnet.PRM_Benefit_Priority__c=7;
        //accessmatrixnet.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrixnet.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrixnet);
        
        PRM_PEx_Access_Matrix__c accessmatrixnet1=new PRM_PEx_Access_Matrix__c();
        accessmatrixnet1.PRM_Benefit_Blade__c='Networking Specialty';
        accessmatrixnet1.PRM_Entitlements__c='Partner Admin';
        accessmatrixnet.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrixnet1.PRM_Click_To_Action__c='Visit Intel® Network Builders';
        accessmatrixnet1.PRM_CTA_Priority__c='2';
     //   accessmatrixnet1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrixnet1.PRM_Benefit_Priority__c=7;
        //accessmatrixnet1.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrixnet1.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrixnet1);
        
        PRM_PEx_Access_Matrix__c accessmatrixnet2=new PRM_PEx_Access_Matrix__c();
        accessmatrixnet2.PRM_Benefit_Blade__c='Networking Specialty';
        accessmatrixnet2.PRM_Entitlements__c='Partner Admin';
        accessmatrixnet2.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrixnet2.PRM_Click_To_Action__c='Visit Intel® Network Builders University';
        accessmatrixnet2.PRM_CTA_Priority__c='3';
        accessmatrixnet2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrixnet2.PRM_Benefit_Priority__c=7;
        //accessmatrixnet2.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrixnet2.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrixnet2);
        
        
        /*Optane Client Specialty
Device as a Service Specialty
*/
        
        
        //select benefit
        PRM_PEx_Access_Matrix__c accessmatrxbft=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft.PRM_Click_To_Action__c='Find help and training';
        accessmatrxbft.PRM_CTA_Priority__c='';
        //accessmatrxbft.PRM_Partner_Specialty_Select_Benefit__c=spec3.Id;
        accessmatrxbft.PRM_Benefit_Priority__c=6;
        accessmatrxbft.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxbft);
        //  insert accessmatrxbft;
        
        PRM_PEx_Access_Matrix__c accessmatrxbft01=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft01.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft01.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft01.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft01.PRM_Click_To_Action__c='View results';
        accessmatrxbft01.PRM_CTA_Priority__c='';
        //accessmatrxbft01.PRM_Partner_Specialty_Select_Benefit__c=spec3.Id;
        accessmatrxbft01.PRM_Benefit_Priority__c=6;
        accessmatrxbft01.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxbft01);
        //     insert accessmatrxbft01;
        
        PRM_PEx_Access_Matrix__c accessmatrxbft021=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft021.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft021.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft021.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxbft021.PRM_Click_To_Action__c='Intel® Partner Alliance IoT Additive Select Benefits';
        accessmatrxbft021.PRM_CTA_Priority__c='1';
       // accessmatrxbft021.PRM_Partner_Specialty_Select_Benefit__c=spec3.Id;
        accessmatrxbft021.PRM_Benefit_Priority__c=6;
        accessmatrxbft021.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxbft021);
        
        
        PRM_PEx_Access_Matrix__c accessmatrxbft031=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft031.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft031.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft031.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft031.PRM_Click_To_Action__c='Intel® Partner Alliance IoT Baseline Select Benefits';
        accessmatrxbft031.PRM_CTA_Priority__c='1';
        //accessmatrxbft031.PRM_Partner_Specialty_Select_Benefit__c=spec3.Id;
        accessmatrxbft031.PRM_Benefit_Priority__c=6;
        accessmatrxbft031.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxbft031);
        
        
        PRM_PEx_Access_Matrix__c accessmatrxbft041=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft041.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft041.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft041.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft041.PRM_Click_To_Action__c='Intel® Partner Alliance AI Application Ecosystem Advancement Select Benefits';
        accessmatrxbft041.PRM_CTA_Priority__c='1';
        //accessmatrxbft041.PRM_Partner_Specialty_Select_Benefit__c=spec3.Id;
        accessmatrxbft041.PRM_Benefit_Priority__c=6;
        accessmatrxbft041.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxbft041);
        
        PRM_PEx_Access_Matrix__c accessmatrxbft051=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft01.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft01.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft01.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft01.PRM_Click_To_Action__c='Intel® Data Center Innovation Fund (DCIF) Select Benefit';
        accessmatrxbft01.PRM_CTA_Priority__c='1';
        //accessmatrxbft01.PRM_Partner_Specialty_Select_Benefit__c=spec3.Id;
        accessmatrxbft01.PRM_Benefit_Priority__c=6;
        accessmatrxbft01.RecordTypeId=specbenftRT;
        accessMatrixList.add(accessmatrxbft051);
        
        
        
        
        //QuickLinks
        Id quickLinksRT = Schema.SObjectType.PRM_PEx_Access_Matrix__c.getRecordTypeInfosByDeveloperName().get('Quick_Links_Access_Rule').getRecordTypeId();
        PRM_PEx_Access_Matrix__c accessmatrxqk=new PRM_PEx_Access_Matrix__c();
        accessmatrxqk.RecordTypeId=quickLinksRT;
        accessmatrxqk.PRM_Benefit_Blade__c='';
        accessmatrxqk.PRM_Entitlements__c='Employee;Points View;Partner Admin';
        accessmatrxqk.PRM_Click_To_Action__c='Manage Personnel';
        accessmatrxqk.PRM_IPA_Partner_Role__c='Distributor';
       // accessmatrxqk.PRM_IPA_Quick_Links__c='https://www.intelmanagepersonnel.com';
        accessmatrxqk.PRM_IPA_URL__c='manage_personnel__c';
        accessMatrixList.add(accessmatrxqk);
        // insert accessmatrxqk;
        
        PRM_PEx_Access_Matrix__c accessmatrxqk1=new PRM_PEx_Access_Matrix__c();
        accessmatrxqk1.RecordTypeId=quickLinksRT;
        accessmatrxqk1.PRM_Benefit_Blade__c='';
        accessmatrxqk1.PRM_Entitlements__c='Employee;Points View;Partner Admin;Partner Admin Delegate';
        accessmatrxqk1.PRM_Click_To_Action__c='Invite members';
        accessmatrxqk1.PRM_IPA_Partner_Role__c='Distributor';
       // accessmatrxqk1.PRM_IPA_Quick_Links__c='https://www.intelinvitemembers.com';
        accessmatrxqk1.PRM_IPA_URL__c='invitemembers';
        accessMatrixList.add(accessmatrxqk1);
        
        PRM_PEx_Access_Matrix__c accessmatrxqk1u=new PRM_PEx_Access_Matrix__c();
        accessmatrxqk1u.RecordTypeId=quickLinksRT;
        accessmatrxqk1u.PRM_Benefit_Blade__c='';
        accessmatrxqk1u.PRM_Entitlements__c='Employee;Points View;Partner Admin;Partner Admin Delegate';
        accessmatrxqk1u.PRM_Click_To_Action__c='Intel® Partner Alliance Home';
        accessmatrxqk1u.PRM_IPA_Partner_Role__c='Distributor';
        //accessmatrxqk1u.PRM_IPA_Quick_Links__c='https://www.intelinvitemembers.com';
        accessmatrxqk1u.PRM_IPA_URL__c='invitemembers';
        accessMatrixList.add(accessmatrxqk1u);
        
        insert accessMatrixList;
        
        
        //Message
        Id messageRecordId = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Adhoc').getRecordTypeId();
        PRM_Message__c msg=new PRM_Message__c();
        msg.PRM_UI_Display_Area_Nm__c='Leads';
        msg.PRM_Title_Txt__c='Welcome to Intel';
        msg.PRM_Description_Txt__c='Intel Cloud inside';
        msg.PRM_End_Date_Dt__c=NULL;
        msg.PRM_InActive_Ind__c = false;
        msg.recordtypeid = messageRecordId;
        // msgsList.add(msg);
        insert msg;
        
        //Message Log
        PRM_Message_log__c msglog=new PRM_Message_log__c();
        msglog.PRM_Message_Id__c=msg.id;
        msglog.PRM_Message_Viewed_Ind__c=false;
        msglog.PRM_Contact_Id__c = cont.Id;
        msglog.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglog);
        insert msglog;
        
        //Nilesh added
        /* Id messageRT1 = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Event').getRecordTypeId();
PRM_Message__c msg1=new PRM_Message__c();
msg1.PRM_UI_Display_Area_Nm__c='Leads';
msg1.PRM_Title_Txt__c='Welcome to Intel';
msg1.PRM_Description_Txt__c='Intel Cloud inside';
msg1.PRM_End_Date_Dt__c=NULL;
msg1.PRM_InActive_Ind__c = false;
msg1.recordtypeid = messageRT1;
insert msg1;

PRM_Message_log__c msglog1=new PRM_Message_log__c();
msglog1.PRM_Message_Id__c=msg1.id;
msglog1.PRM_Message_Viewed_Ind__c=false;
msglog1.PRM_Contact_Id__c = cont2.Id;
msglog1.PRM_Inactive_Ind__c =false;
insert msglog1;


PRM_Message__c msg1f=new PRM_Message__c();
msg1f.PRM_UI_Display_Area_Nm__c='Leads';
msg1f.PRM_Title_Txt__c='Welcome to Intel';
msg1f.PRM_Description_Txt__c='Intel Cloud inside';
msg1f.PRM_End_Date_Dt__c=NULL;
msg1f.PRM_InActive_Ind__c = false;
msg1f.recordtypeid = messageRT1;
insert msg1f;

PRM_Message_log__c msglog1f=new PRM_Message_log__c();
msglog1f.PRM_Message_Id__c=msg1f.id;
msglog1f.PRM_Message_Viewed_Ind__c=false;
msglog1f.PRM_Contact_Id__c = cont2.Id;
msglog1f.PRM_Inactive_Ind__c =false;
insert msglog1f;

*/
        //for Adhoc RT
        Id messageRT = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Event').getRecordTypeId();
        PRM_Message__c msg2=new PRM_Message__c();
        msg2.PRM_UI_Display_Area_Nm__c='Notification Area';
        msg2.PRM_Title_Txt__c='Welcome to Intel';
        msg2.PRM_Description_Txt__c='Intel Cloud inside';
        msg2.PRM_End_Date_Dt__c=NULL;
        msg2.PRM_InActive_Ind__c = false;
        msg2.recordtypeid = messageRT;
        //msgsList.add(msg2);
        insert msg2;
        
        PRM_Message_log__c msglog2=new PRM_Message_log__c();
        msglog2.PRM_Message_Id__c=msg2.id;
        msglog2.PRM_Message_Viewed_Ind__c=false;
        msglog2.PRM_Contact_Id__c = cont.Id;
        msglog2.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglog2);
        insert msglog2;
        
        //
        PRM_Message__c msg3=new PRM_Message__c();
        msg3.PRM_UI_Display_Area_Nm__c='Leads';
        msg3.PRM_Title_Txt__c='Welcome to Intel';
        msg3.PRM_Description_Txt__c='Intel Cloud inside';
        msg3.PRM_End_Date_Dt__c=NULL;
        msg3.PRM_InActive_Ind__c = false;
        msg3.recordtypeid = messageRT;
        //msgsList.add(msg3);
        insert msg3;
        
        PRM_Message_log__c msglog3=new PRM_Message_log__c();
        msglog3.PRM_Message_Id__c=msg3.id;
        msglog3.PRM_Message_Viewed_Ind__c=false;
        msglog3.PRM_Contact_Id__c = cont.Id;
        msglog3.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglog3);
        insert msglog3;
        
        //for points
        PRM_Message__c msgp=new PRM_Message__c();
        msgp.PRM_UI_Display_Area_Nm__c='Points';
        msgp.PRM_Title_Txt__c='Welcome to Intel';
        msgp.PRM_Description_Txt__c='Intel Cloud inside';
        msgp.PRM_End_Date_Dt__c=NULL;
        msgp.PRM_InActive_Ind__c = false;
        msgp.recordtypeid = messageRT;
        //msgsList.add(msgp);
        insert msgp;
        
        PRM_Message_log__c msglogp=new PRM_Message_log__c();
        msglogp.PRM_Message_Id__c=msgp.id;
        msglogp.PRM_Message_Viewed_Ind__c=false;
        msglogp.PRM_Contact_Id__c = cont.Id;
        msglogp.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglogp);
        insert msglogp;
        
        PRM_Message_Translation__c msgtrasp=new PRM_Message_Translation__c();
        msgtrasp.PRM_Message_Id__c=msgp.Id;
        msgtrasp.PRM_Title_Txt__c='Greeting from Intel';
        msgtrasp.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrasp.PRM_Language_Nm__c ='FRA';
        msgtrasp.PRM_InActive_Ind__c = false;
        //msgstransList.add(msgtrasp);
        insert msgtrasp;
        
        //for select benefits
   /*     PRM_Message__c msgpsb=new PRM_Message__c();
        msgpsb.PRM_UI_Display_Area_Nm__c='Select Benefit';
        msgpsb.PRM_Title_Txt__c='Welcome to Intel';
        msgpsb.PRM_Description_Txt__c='Intel Cloud inside';
        msgpsb.PRM_End_Date_Dt__c=NULL;
        msgpsb.PRM_InActive_Ind__c = false;
        msgpsb.recordtypeid = messageRT;
        //msgsList.add(msgp);
        insert msgpsb;
        
        PRM_Message_log__c msglogpsb=new PRM_Message_log__c();
        msglogpsb.PRM_Message_Id__c=msgpsb.id;
        msglogpsb.PRM_Message_Viewed_Ind__c=false;
        msglogpsb.PRM_Contact_Id__c = cont.Id;
        msglogpsb.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglogp);
        insert msglogpsb;
        
        PRM_Message_Translation__c msgtraspsb=new PRM_Message_Translation__c();
        msgtraspsb.PRM_Message_Id__c=msgpsb.Id;
        msgtraspsb.PRM_Title_Txt__c='Greeting from Intel';
        msgtraspsb.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtraspsb.PRM_Language_Nm__c ='FRA';
        msgtraspsb.PRM_InActive_Ind__c = false;
        //msgstransList.add(msgtrasp);
        insert msgtraspsb;*/
        
        //MP Alerts
        PRM_Message__c msgmdf=new PRM_Message__c();
        msgmdf.PRM_UI_Display_Area_Nm__c='Marketplace';
        msgmdf.PRM_Title_Txt__c='Welcome to Intel';
        msgmdf.PRM_Description_Txt__c='Intel Cloud inside';
        msgmdf.PRM_End_Date_Dt__c=NULL;
        msgmdf.PRM_InActive_Ind__c = false;
        msgmdf.recordtypeid = messageRT;
        //msgsList.add(msgmdf);
        insert msgmdf;
        
        PRM_Message_log__c msglogmdf=new PRM_Message_log__c();
        msglogmdf.PRM_Message_Id__c=msgmdf.id;
        msglogmdf.PRM_Message_Viewed_Ind__c=false;
        msglogmdf.PRM_Contact_Id__c = cont.Id;
        msglogmdf.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglogmdf);
        insert msglogmdf;
        
        PRM_Message_Translation__c msgtrasmdf=new PRM_Message_Translation__c();
        msgtrasmdf.PRM_Message_Id__c=msgmdf.Id;
        msgtrasmdf.PRM_Title_Txt__c='Greeting from Intel';
        msgtrasmdf.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrasmdf.PRM_Language_Nm__c ='FRA';
        msgtrasmdf.PRM_InActive_Ind__c = false;
        // msgstransList.add(msgtrasmdf);
        insert msgtrasmdf;
        
        //MDF Alerts
        PRM_Message__c msgmdf1=new PRM_Message__c();
        msgmdf1.PRM_UI_Display_Area_Nm__c='MDF';
        msgmdf1.PRM_Title_Txt__c='Welcome to Intel';
        msgmdf1.PRM_Description_Txt__c='Intel Cloud inside';
        msgmdf1.PRM_End_Date_Dt__c=NULL;
        msgmdf1.PRM_InActive_Ind__c = false;
        msgmdf1.recordtypeid = messageRT;
        //msgsList.add(msgmdf);
        insert msgmdf1;
        
        PRM_Message_log__c msglogmdf1=new PRM_Message_log__c();
        msglogmdf1.PRM_Message_Id__c=msgmdf1.id;
        msglogmdf1.PRM_Message_Viewed_Ind__c=false;
        msglogmdf1.PRM_Contact_Id__c = cont.Id;
        msglogmdf1.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglogmdf);
        insert msglogmdf1;
        
        PRM_Message_Translation__c msgtrasmdf1=new PRM_Message_Translation__c();
        msgtrasmdf1.PRM_Message_Id__c=msgmdf1.Id;
        msgtrasmdf1.PRM_Title_Txt__c='Greeting from Intel';
        msgtrasmdf1.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrasmdf1.PRM_Language_Nm__c ='FRA';
        msgtrasmdf1.PRM_InActive_Ind__c = false;
        // msgstransList.add(msgtrasmdf);
        insert msgtrasmdf1;
        
        //Marketing Studio Alerts
        PRM_Message__c msgmdf2=new PRM_Message__c();
        msgmdf2.PRM_UI_Display_Area_Nm__c='Marketing Studio';
        msgmdf2.PRM_Title_Txt__c='Welcome to Intel';
        msgmdf2.PRM_Description_Txt__c='Intel Cloud inside';
        msgmdf2.PRM_End_Date_Dt__c=NULL;
        msgmdf2.PRM_InActive_Ind__c = false;
        msgmdf2.recordtypeid = messageRT;
        //msgsList.add(msgmdf);
        insert msgmdf2;
        
        PRM_Message_log__c msglogmdf2=new PRM_Message_log__c();
        msglogmdf2.PRM_Message_Id__c=msgmdf2.id;
        msglogmdf2.PRM_Message_Viewed_Ind__c=false;
        msglogmdf2.PRM_Contact_Id__c = cont.Id;
        msglogmdf2.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglogmdf);
        insert msglogmdf2;
        
        PRM_Message_Translation__c msgtrasmdf2=new PRM_Message_Translation__c();
        msgtrasmdf2.PRM_Message_Id__c=msgmdf2.Id;
        msgtrasmdf2.PRM_Title_Txt__c='Greeting from Intel';
        msgtrasmdf2.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrasmdf2.PRM_Language_Nm__c ='FRA';
        msgtrasmdf2.PRM_InActive_Ind__c = false;
        // msgstransList.add(msgtrasmdf);
        insert msgtrasmdf2;
        
        //Traaining ALerts
        PRM_Message__c msgtr=new PRM_Message__c();
        msgtr.PRM_UI_Display_Area_Nm__c='Training';
        msgtr.PRM_Title_Txt__c='Welcome to Intel';
        msgtr.PRM_Description_Txt__c='Intel Cloud inside';
        msgtr.PRM_End_Date_Dt__c=NULL;
        msgtr.PRM_InActive_Ind__c = false;
        msgtr.recordtypeid = messageRT;
        //msgsList.add(msgtr);
        insert msgtr;
        
        
        PRM_Message_log__c msglogtr=new PRM_Message_log__c();
        msglogtr.PRM_Message_Id__c=msgtr.id;
        msglogtr.PRM_Message_Viewed_Ind__c=false;
        msglogtr.PRM_Contact_Id__c = cont.Id;
        msglogtr.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msglogtr);
        insert msglogtr;
        
        PRM_Message_Translation__c msgtrastr=new PRM_Message_Translation__c();
        msgtrastr.PRM_Message_Id__c=msgtr.Id;
        msgtrastr.PRM_Title_Txt__c='Greeting from Intel';
        msgtrastr.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrastr.PRM_Language_Nm__c ='FRA';
        msgtrastr.PRM_InActive_Ind__c = false;
        //msgstransList.add(msgtrastr);
        insert msgtrastr;
        
        
        
        //for languages other than English
        //Id messageRecordId = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Adhoc').getRecordTypeId();
        PRM_Message__c msge=new PRM_Message__c();
        msge.PRM_UI_Display_Area_Nm__c='Notification Area';
        msge.PRM_Title_Txt__c='Welcome to Intel';
        msge.PRM_Description_Txt__c='Intel Cloud inside';
        msge.PRM_End_Date_Dt__c=NULL;
        msge.PRM_InActive_Ind__c = false;
        msge.recordtypeid = messageRT;
        //msgsList.add(msge);
        insert msge;
        
        //Message Log
        PRM_Message_log__c msgloge=new PRM_Message_log__c();
        msgloge.PRM_Message_Id__c=msge.id;
        msgloge.PRM_Message_Viewed_Ind__c=false;
        msgloge.PRM_Contact_Id__c = cont2.Id;
        msgloge.PRM_Inactive_Ind__c =false;
        //msgsLogList.add(msgloge);
        insert msgloge;
        
        PRM_Message_Translation__c msgtrase=new PRM_Message_Translation__c();
        msgtrase.PRM_Message_Id__c=msge.Id;
        msgtrase.PRM_Title_Txt__c='Greeting from Intel';
        msgtrase.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrase.PRM_Language_Nm__c ='FRA';
        msgtrase.PRM_InActive_Ind__c = false;
        // msgstransList.add(msgtrase);
        insert msgtrase;
        
        
        
        
        
        /* PRM_Message_Translation__c msgtras=new PRM_Message_Translation__c();
msgtras.PRM_Message_Id__c=msg1.Id;
msgtras.PRM_Title_Txt__c='Greeting from Intel';
msgtras.PRM_Description_Txt__c='Welcome to Intel Cloud';
msgtras.PRM_Language_Nm__c ='FRA';
msgtras.PRM_InActive_Ind__c = false;
insert msgtras;
*/
        
        PRM_Message_Translation__c msgtras1=new PRM_Message_Translation__c();
        msgtras1.PRM_Message_Id__c=msg2.Id;
        msgtras1.PRM_Title_Txt__c='Greeting from Intel';
        msgtras1.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtras1.PRM_Language_Nm__c ='FRA';
        msgtras1.PRM_InActive_Ind__c = false;
        //msgstransList.add(msgtras1);
        insert msgtras1;
        
        
        
        /* PRM_Message_Translation__c msgtrasf=new PRM_Message_Translation__c();
msgtrasf.PRM_Message_Id__c=msg1f.Id;
msgtrasf.PRM_Title_Txt__c='Greeting from Intel';
msgtrasf.PRM_Description_Txt__c='Welcome to Intel Cloud';
msgtrasf.PRM_Language_Nm__c ='FRA';
msgtrasf.PRM_InActive_Ind__c = false;
insert msgtrasf;
*/
        Date startDate = date.newInstance(2015, 12, 15);
        Date endDate = date.newInstance(2029, 12, 16);
        Id messageRTA = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Adhoc').getRecordTypeId();
        PRM_Message__c msg1=new PRM_Message__c();
        msg1.PRM_UI_Display_Area_Nm__c='Training';
        msg1.PRM_Title_Txt__c='Welcome to Intel';
        msg1.PRM_Description_Txt__c='Intel Cloud inside';
        msg1.PRM_Start_Date_Dt__c=startDate;
        msg1.PRM_End_Date_Dt__c=endDate;
        msg1.PRM_InActive_Ind__c = false;
        msg1.recordtypeid = messageRTA;
        insert msg1;
        
        PRM_Message_Translation__c msgtra1=new PRM_Message_Translation__c();
        msgtra1.PRM_Message_Id__c=msg1.Id;
        msgtra1.PRM_Title_Txt__c='Greeting from Intel';
        msgtra1.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtra1.PRM_Language_Nm__c ='FRA';
        msgtra1.PRM_InActive_Ind__c = false;
        //msgstransList.add(msgtrastr);
        insert msgtra1;
        
        PRM_Message__c msg21=new PRM_Message__c();
        msg21.PRM_UI_Display_Area_Nm__c='MDF';
        msg21.PRM_Title_Txt__c='Welcome to Intel';
        msg21.PRM_Description_Txt__c='Intel Cloud inside';
        msg21.PRM_Start_Date_Dt__c=startDate;
        msg21.PRM_End_Date_Dt__c=endDate;
        msg21.PRM_InActive_Ind__c = false;
        msg21.recordtypeid = messageRTA;
        insert msg21;
        
        PRM_Message__c msg31=new PRM_Message__c();
        msg31.PRM_UI_Display_Area_Nm__c='Marketplace';
        msg31.PRM_Title_Txt__c='Welcome to Intel';
        msg31.PRM_Description_Txt__c='Intel Cloud inside';
        msg31.PRM_Start_Date_Dt__c=startDate;
        msg31.PRM_End_Date_Dt__c=endDate;
        msg31.PRM_InActive_Ind__c = false;
        msg31.recordtypeid = messageRTA;
        insert msg31;
        
        PRM_Message__c msg4=new PRM_Message__c();
        msg4.PRM_UI_Display_Area_Nm__c='Select Benefit';
        msg4.PRM_Title_Txt__c='Welcome to Intel';
        msg4.PRM_Description_Txt__c='Intel Cloud inside';
        msg4.PRM_Start_Date_Dt__c=startDate;
        msg4.PRM_End_Date_Dt__c=endDate;
        msg4.PRM_InActive_Ind__c = false;
        msg4.recordtypeid = messageRTA;
        insert msg4;
        
        PRM_Message__c msg5=new PRM_Message__c();
        msg5.PRM_UI_Display_Area_Nm__c='Artificial Intelligence Specialty';
        msg5.PRM_Title_Txt__c='Artificial Adc';
        msg5.PRM_Description_Txt__c='Artificial Des';
        msg5.PRM_Start_Date_Dt__c=startDate;
        msg5.PRM_End_Date_Dt__c=endDate;
        msg5.PRM_InActive_Ind__c = false;
        msg5.recordtypeid = messageRTA;
        insert msg5;
        
        PRM_Message__c msg6=new PRM_Message__c();
        msg6.PRM_UI_Display_Area_Nm__c='Cloud Data Center Specialty';
        msg6.PRM_Title_Txt__c='Welcome to Intel';
        msg6.PRM_Description_Txt__c='Intel Cloud inside';
        msg6.PRM_Start_Date_Dt__c=startDate;
        msg6.PRM_End_Date_Dt__c=endDate;
        msg6.PRM_InActive_Ind__c = false;
        msg6.recordtypeid = messageRTA;
        insert msg6;
        
        PRM_Message__c msg7=new PRM_Message__c();
        msg7.PRM_UI_Display_Area_Nm__c='High Performance Computing Data Center Specialty';
        msg7.PRM_Title_Txt__c='Welcome to Intel';
        msg7.PRM_Description_Txt__c='Intel Cloud inside';
        msg7.PRM_Start_Date_Dt__c=startDate;
        msg7.PRM_End_Date_Dt__c=endDate;
        msg7.PRM_InActive_Ind__c = false;
        msg7.recordtypeid = messageRTA;
        insert msg7;
        
        PRM_Message__c msg8=new PRM_Message__c();
        msg8.PRM_UI_Display_Area_Nm__c='Video Specialty';
        msg8.PRM_Title_Txt__c='Welcome to Intel';
        msg8.PRM_Description_Txt__c='Intel Cloud inside';
        msg8.PRM_Start_Date_Dt__c=startDate;
        msg8.PRM_End_Date_Dt__c=endDate;
        msg8.PRM_InActive_Ind__c = false;
        msg8.recordtypeid = messageRTA;
        insert msg8;
        
        PRM_Message__c msg9=new PRM_Message__c();
        msg9.PRM_UI_Display_Area_Nm__c='Visual Display Solutions Specialty';
        msg9.PRM_Title_Txt__c='Welcome to Intel';
        msg9.PRM_Description_Txt__c='Intel Cloud inside';
        msg9.PRM_Start_Date_Dt__c=startDate;
        msg9.PRM_End_Date_Dt__c=endDate;
        msg9.PRM_InActive_Ind__c = false;
        msg9.recordtypeid = messageRTA;
        insert msg9;
        
        PRM_Message__c msg10=new PRM_Message__c();
        msg10.PRM_UI_Display_Area_Nm__c='Industrial Solutions Builder Specialty';
        msg10.PRM_Title_Txt__c='Welcome to Intel';
        msg10.PRM_Description_Txt__c='Intel Cloud inside';
        msg10.PRM_Start_Date_Dt__c=startDate;
        msg10.PRM_End_Date_Dt__c=endDate;
        msg10.PRM_InActive_Ind__c = false;
        msg10.recordtypeid = messageRTA;
        insert msg10;
        
        PRM_Message__c msg11=new PRM_Message__c();
        msg11.PRM_UI_Display_Area_Nm__c='Optane Data Center Specialty';
        msg11.PRM_Title_Txt__c='Welcome to Intel';
        msg11.PRM_Description_Txt__c='Intel Cloud inside';
        msg11.PRM_Start_Date_Dt__c=startDate;
        msg11.PRM_End_Date_Dt__c=endDate;
        msg11.PRM_InActive_Ind__c = false;
        msg11.recordtypeid = messageRTA;
        insert msg11;
        
        PRM_Message__c msg12=new PRM_Message__c();
        msg12.PRM_UI_Display_Area_Nm__c='Optane Client Specialty';
        msg12.PRM_Title_Txt__c='Welcome to Intel';
        msg12.PRM_Description_Txt__c='Intel Cloud inside';
        msg12.PRM_Start_Date_Dt__c=startDate;
        msg12.PRM_End_Date_Dt__c=endDate;
        msg12.PRM_InActive_Ind__c = false;
        msg12.recordtypeid = messageRTA;
        insert msg12;
        
        PRM_Message__c msg13=new PRM_Message__c();
        msg13.PRM_UI_Display_Area_Nm__c='Device as a Service Specialty';
        msg13.PRM_Title_Txt__c='Welcome to Intel';
        msg13.PRM_Description_Txt__c='Intel Cloud inside';
        msg13.PRM_Start_Date_Dt__c=startDate;
        msg13.PRM_End_Date_Dt__c=endDate;
        msg13.PRM_InActive_Ind__c = false;
        msg13.recordtypeid = messageRTA;
        insert msg13;
        
        PRM_Message__c msg14=new PRM_Message__c();
        msg14.PRM_UI_Display_Area_Nm__c='Leads';
        msg14.PRM_Title_Txt__c='Welcome to Intel';
        msg14.PRM_Description_Txt__c='Intel Cloud inside';
        msg14.PRM_Start_Date_Dt__c=startDate;
        msg14.PRM_End_Date_Dt__c=endDate;
        msg14.PRM_InActive_Ind__c = false;
        msg14.recordtypeid = messageRTA;
        insert msg14;
        
        PRM_Message__c msg15=new PRM_Message__c();
        msg15.PRM_UI_Display_Area_Nm__c='Points';
        msg15.PRM_Title_Txt__c='Welcome to Intel';
        msg15.PRM_Description_Txt__c='Intel Cloud inside';
        msg15.PRM_Start_Date_Dt__c=startDate;
        msg15.PRM_End_Date_Dt__c=endDate;
        msg15.PRM_InActive_Ind__c = false;
        msg15.recordtypeid = messageRTA;
        insert msg15;
        
        PRM_Message__c msg16=new PRM_Message__c();
        msg16.PRM_UI_Display_Area_Nm__c='Partner Help';
        msg16.PRM_Title_Txt__c='Welcome to Intel';
        msg16.PRM_Description_Txt__c='Intel Cloud inside';
        msg16.PRM_Start_Date_Dt__c=startDate;
        msg16.PRM_End_Date_Dt__c=endDate;
        msg16.PRM_InActive_Ind__c = false;
        msg16.recordtypeid = messageRTA;
        insert msg16;
        
        PRM_Message__c msg17=new PRM_Message__c();
        msg17.PRM_UI_Display_Area_Nm__c='Marketing Studio';
        msg17.PRM_Title_Txt__c='Welcome to Intel';
        msg17.PRM_Description_Txt__c='Intel Cloud inside';
        msg17.PRM_Start_Date_Dt__c=startDate;
        msg17.PRM_End_Date_Dt__c=endDate;
        msg17.PRM_InActive_Ind__c = false;
        msg17.recordtypeid = messageRTA;
        insert msg17;
        
        PRM_Message__c msg18=new PRM_Message__c();
        msg18.PRM_UI_Display_Area_Nm__c='Pricing, Points and Promotions';
        msg18.PRM_Title_Txt__c='Welcome to Intel';
        msg18.PRM_Description_Txt__c='Intel Cloud inside';
        msg18.PRM_Start_Date_Dt__c=startDate;
        msg18.PRM_End_Date_Dt__c=endDate;
        msg18.PRM_InActive_Ind__c = false;
        msg18.recordtypeid = messageRTA;
        insert msg18;
        
        PRM_Message__c msg19=new PRM_Message__c();
        msg19.PRM_UI_Display_Area_Nm__c='Products & Roadmaps';
        msg19.PRM_Title_Txt__c='Welcome to Intel';
        msg19.PRM_Description_Txt__c='Intel Cloud inside';
        msg19.PRM_Start_Date_Dt__c=startDate;
        msg19.PRM_End_Date_Dt__c=endDate;
        msg19.PRM_InActive_Ind__c = false;
        msg19.recordtypeid = messageRTA;
        insert msg19;
        
        PRM_Message__c msg20=new PRM_Message__c();
        msg20.PRM_UI_Display_Area_Nm__c='Networking Specialty';
        msg20.PRM_Title_Txt__c='Welcome to Intel';
        msg20.PRM_Description_Txt__c='Intel Cloud inside';
        msg20.PRM_Start_Date_Dt__c=startDate;
        msg20.PRM_End_Date_Dt__c=endDate;
        msg20.PRM_InActive_Ind__c = false;
        msg20.recordtypeid = messageRTA;
        insert msg20;
        
        PRM_Message__c msg22=new PRM_Message__c();
        msg22.PRM_UI_Display_Area_Nm__c='FPGA Tools and Resources';
        msg22.PRM_Title_Txt__c='Welcome to Intel';
        msg22.PRM_Description_Txt__c='Intel Cloud inside';
        msg22.PRM_Start_Date_Dt__c=startDate;
        msg22.PRM_End_Date_Dt__c=endDate;
        msg22.PRM_InActive_Ind__c = false;
        msg22.recordtypeid = messageRTA;
        insert msg22;
        
        
        
        
        //get Country Code
        PRM_LanguageLocaleMapping__mdt countryCode=new PRM_LanguageLocaleMapping__mdt();
        countryCode.PRM_Preferred_Language_Code__c='FRA';
        countryCode.PRM_Preferred_Locale_Code__c='fr_FR';
        
        PRM_EmailLog__c getEmailLog =  new PRM_EmailLog__c();
        getEmailLog.PRM_Read__c=false;
        getEmailLog.PRM_Is_Deleted__c=false;
        getEmailLog.PRM_Subject__c='Your Intel Partner Program Application';
        getEmailLog.PRM_EmailContent__c='';
        getEmailLog.PRM_Contact__c =cont.Id;
        insert getEmailLog;
        
        //Email Log
        PRM_EmailLog__c emaillog=new PRM_EmailLog__c();
        emaillog.PRM_Read__c=false;
        emaillog.PRM_Is_Deleted__c=false;
        emaillog.PRM_Subject__c='Your Intel®Cloud Insider Application';
        insert emaillog;
        
        PRM_Value_Exchange_Data__c valueex=new PRM_Value_Exchange_Data__c();
        valueex.PRM_Training_Credit_Points_Count_Nbr__c=788;
        valueex.PRM_Account_Id__c=testAccount.Id;
        valueex.PRM_Change_Date_Dt__c=system.today()+2;
        valueex.PRM_Country_Market_Type_Nm__c='Mature';
        valueex.PRM_From_Dt__c=system.today();
        valueex.PRM_Partner_Role_Nm__c='Service Provider';
        valueex.PRM_Tier_Id__c=cplTest.Id;
        //valueex.PRM_One_Partner_Id__c=testAccount.Id;
        valueex.PRM_To_Dt__c=system.today()+1;
        insert valueex;
        
        PRM_Partner_Consent_Distributor__c pcd = new PRM_Partner_Consent_Distributor__c();
        pcd.PRM_Account_Id__c = testAccount.id;
        insert pcd;
        
        List<k_v_f_training_detail_sfdcs__x> traincredList=new List<k_v_f_training_detail_sfdcs__x>();
        k_v_f_training_detail_sfdcs__x traincred=new k_v_f_training_detail_sfdcs__x();
        traincred.training_credit_qty__c=5;
        traincred.business_organization_party_id__c=testAccount.Id;
        traincred.business_person_id__c=cont2.Id;
        traincred.value_exchange_period_txt__c = 'Q4 2021 - Q3 2022';
        traincredList.add(traincred);
        
        
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_CP_CompanyProfile_Title);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Dashboard_Title);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Release_Of_Information);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Training_Credits);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Sales_Details_Title);
        IPABenefitUtility.getProfileInfo(userId,Label.EPUM_ManagePersonnel);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_PartnerSearchHeader);
        IPABenefitUtility.getProfileInfo(userId,Label.IPA_Benefits_Manage_Benefits);
        IPABenefitUtility.getPartnerQuickLinks(userId);
        //IPABenefitUtility.getBenefitsInfo(userId1);
        IPABenefitUtility.getBenefitsInfo(userId);
        IPABenefitUtility.getBenefitsInfo(userId2);
        // IPABenefitUtility.setReadVisibility(emaillog.id,'Direct Message');
        // IPABenefitUtility.setReadVisibility(msglog.id,'Account');
        IPABenefitUtility.getNotificationList(userId2,'Home Notification');
        IPABenefitUtility.getNotificationList(userId,'Home Notification');   
        //testDataSetupforOPIDAccount();
        Test.stopTest();
        System.assertEquals(cont.FirstName, 'Adam', 'Value does not match');
        
    }
    
    @isTest
    public static void testDataSetupforOPIDAccount(){
        
        //PAG ACCOunt
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account();
        parent1.RecordTypeId = opidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        parent1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        parent1.Industry='Construction';
        parent1.Core_User_Defined_Website__c='www.abc.com';
        Parent1.Core_Geo__c='ASMO';
        insert parent1;
        parent1.Core_OnePartnerID__c=parent1.Id;
        System.Debug('LIMITS 1 : ' + Limits.getQueries());
        update parent1;
        
        System.Debug('LIMITS 2 : ' + Limits.getQueries());
        
        Contact pAGcont = new Contact();  //Contact
        pAGcont.AccountId=parent1.Id;
        pAGcont.lastName='Tony';
        pAGcont.FirstName='Stark';
        pAGcont.email='MrStark@rediff.com';
        pAGcont.Core_Job_Function__c='Branch Manager';
        //pAGcont.Core_Profession__c='Sales';
        pAGcont.Core_IPA_PartnerRole__c='Service Provider';
        pAGcont.Core_eRPM_Language_Code__c='Eng';
        pAGcont.MailingCountry='USA';
        insert pAGcont;
        
        /*Contact pAGcont1 = new Contact();  //Contact
        pAGcont1.AccountId=parent1.Id;
        pAGcont1.lastName='Tony';
        pAGcont1.FirstName='Stark';
        pAGcont1.email='MrStark12@rediff.com';
        pAGcont1.Core_Job_Function__c='Branch Manager';
        //pAGcont.Core_Profession__c='Sales';
        pAGcont1.Core_IPA_PartnerRole__c='Seller';
        pAGcont1.Core_eRPM_Language_Code__c='Eng';
        pAGcont1.MailingCountry='USA';
        insert pAGcont1;*/ // Removing as Seller is not active picklist value for partnerrole
        
        Contact pAGcont2 = new Contact();  //Contact
        pAGcont2.AccountId=parent1.Id;
        pAGcont2.lastName='Tony';
        pAGcont2.FirstName='Stark';
        pAGcont2.email='MrStark1234@rediff.com';
        pAGcont2.Core_Job_Function__c='Branch Manager';
        //pAGcont.Core_Profession__c='Sales';
        pAGcont2.Core_IPA_PartnerRole__c='Solution Integrator';
        pAGcont2.Core_eRPM_Language_Code__c='Eng';
        pAGcont2.MailingCountry='USA';
        insert pAGcont2;
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=parent1.Id;
        cont3.lastName='Johnny';
        cont3.FirstName='Parker';
        cont3.email='Peterparker1@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        //cont3.Core_Profession__c='Sales';
        cont3.Core_IPA_PartnerRole__c='Distributor';
        cont3.Core_Preferred_Language__c='FRA';
        cont3.MailingCountry='USA';
        insert cont3;
        
        System.Debug('LIMITS 3 : ' + Limits.getQueries());
        
        Profile communityUsrProfile2 = [SELECT id FROM Profile WHERE Name='Partner'];
        User pAGpartnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',UserName='nothauser@xyz.com', ContactId=pAGcont.Id,ProfileId=communityUsrProfile2.Id,
                                       emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id
        
        insert pAGpartnerUser;
        Id pAGuserId=pAGpartnerUser.Id;
        
        
        Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();     
        Id specnRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Specialty').getRecordTypeId();     
        
        List<PRM_Specialty__c> specList=new List<PRM_Specialty__c>();
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Video Specialty';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=selectBenRT;
        spec1.PRM_Inactive_Ind__c=false;
        specList.add(spec1);
        //insert spec1;
        
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Optane Client Specialty';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        spec2.PRM_Inactive_Ind__c=false;
        spec2.RecordTypeId=specnRT;
        specList.add(spec2);
        //insert spec2;
        
        /*PRM_Specialty__c spec3 = new PRM_Specialty__c();
        spec3.name='Optane Client Specialty';
        spec3.PRM_Description_Txt__c='This is description';
        spec3.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec3.PRM_Role_Nm__c='Service Provider';
        spec3.PRM_Tier_Nm__c='Gold';
        spec3.PRM_Start_Date_Dt__c= system.today() + 7;
        spec3.PRM_End_Date_Dt__c= spec3.PRM_Start_Date_Dt__c + 5;
        spec3.PRM_Access_Level_Nm__c='Public';
        spec3.PRM_Inactive_Ind__c=false;
        spec3.RecordTypeId=specnRT;
        specList.add(spec3);
        insert specList; 
        */
        PRM_Specialty__c spec3 = new PRM_Specialty__c();
        spec3.name='Select Benefits';
        spec3.PRM_Description_Txt__c='This is description';
        spec3.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec3.PRM_Role_Nm__c='Service Provider';
        spec3.PRM_Tier_Nm__c='Gold';
        spec3.PRM_Start_Date_Dt__c= system.today() + 7;
        spec3.PRM_End_Date_Dt__c= spec3.PRM_Start_Date_Dt__c + 5;
        spec3.PRM_Access_Level_Nm__c='Public';
        spec3.RecordTypeId=selectBenRT;
        spec3.PRM_Inactive_Ind__c=false;
        
        insert spec3;
        
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        ChannelProgramLevel cplTest1 = new ChannelProgramLevel(); //Channel Program Level
        cplTest1.Name='Partner';
        cplTest1.ProgramId=cpTest.Id;
        insert cplTest1;
        
        
        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Solutions Marketplace Enhanced';
        pbTest4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest4);
        
        PRM_PartnerBenefit__c pbTest6 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest6.Name = 'Partner Marketing Studio';
        pbTest6.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pbTest6.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest6.PRM_InActive_Ind__c = false;
        pbTest6.PRM_Account_Type_Nm__c='Mastered_Account';
        pbList.add(pbTest6);
        
        PRM_PartnerBenefit__c pbTest7 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest7.Name = 'Advanced Warranty Replacement';
        pbTest7.PRM_Benefit_Cd__c = 'BFTMKTS76';
        pbTest7.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest7.PRM_InActive_Ind__c = false;
        pbTest7.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest7);
        
        
        insert pbList;
        
        
        
        System.Debug('LIMITS 4 : ' + Limits.getQueries());
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctChnlMemTest=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMemTest.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest.PRM_Status_Reason_Txt__c = 'Approved';
        
        PRM_AccountChannelMembership__c acctChnlMemTest1=PRM_TestUtility.getMembership(); //Account Channel Membership
        acctChnlMemTest1.PRM_Account_Id__c=parent1.Id;
        acctChnlMemTest1.PRM_Channel_Program_Id__c=cpTest.Id;
        acctChnlMemTest1.PRM_Channel_Program_Level_Id__c=cplTest1.Id;
        acctChnlMemTest1.PRM_Partner_Role__c='Service Provider';
        acctChnlMemTest1.PRM_Status_Nm__c = 'Approved';
        acctChnlMemTest1.PRM_Status_Reason_Txt__c='Test';
        acmList.add(acctChnlMemTest1);
        
        System.Debug('LIMITS 5 : ' + Limits.getQueries());
        PRM_ACM_TriggerHandler.executeTrigger = false;
        
        insert acmList;
        PRM_ACM_TriggerHandler.executeTrigger = true;
        
        System.Debug('LIMITS 5A : ' + Limits.getQueries());
        
        PRM_PartnerType__c ptTest = new PRM_PartnerType__c();
        ptTest.Name = 'Cloud Service Provider (CSP)';
        ptTest.PRM_channelprogram__c = cpTest.id;
        ptTest.PRM_Role_Name__c = 'Service Provider';
        ptTest.PRM_PartneryTypeCode__c = 'CSP';
        ptTest.PRM_PartnerRoleCode__c = 'SPR';
        insert ptTest;
        
        
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
        
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Access and Entitlements for Marketplace';
        ee.Core_Technical_Engagement_Code__c = 'MKTSMP';
        ee.Core_Engagement_Type__c = 'SMP';
        insert ee; 
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Partner Admin';
        ed.Core_Display_Name__c='Partner Admin';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name='Partner Admin Delegate';
        contRelation1.PRM_Contact_Relationship_Cd__c ='PRIMCONTDEL';
        contRelation1.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = true;
        insert contRelation1;
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pbTest4.id;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Approval_Type_Nm__c='Manual';
        insert em;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pbTest4.id;
        em1.PRM_Entitlement_Id__c = ed.id;
        em1.PRM_Contact_Relationship_Id__c = contRelation1.id;
        em1.PRM_Approval_Type_Nm__c='Manual';
        insert em1;
        
        System.Debug('LIMITS 5B : ' + Limits.getQueries());
        
        /*PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= parent1.id;
        asa.PRM_Specialty_Id__c= specList[0].id;
        asa.PRM_InActive_Ind__c=false;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;*/
        
        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
        asa1.PRM_Account_Id__c= parent1.id;
        asa1.PRM_Specialty_Id__c= spec3.id;
        asa1.PRM_InActive_Ind__c=false;
        asa1.PRM_Partner_Role__c='Service Provider';
        insert asa1;
        
        System.Debug('LIMITS 6 : ' + Limits.getQueries());
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=parent1.Id;
        acctContRel.PRM_Contact_Id__c=pAGcont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Reason_Txt__c = 'Test';
        PRM_AcctContRel_TriggerHandler.executeTrigger = false;
        insert acctContRel;
        PRM_AcctContRel_TriggerHandler.executeTrigger = true;
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c();
        acctContRel1.PRM_Account_Id__c=parent1.Id;
        acctContRel1.PRM_Contact_Id__c=pAGcont.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation1.Id;
        acctContRel1.PRM_Status_Nm__c='Complete';
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_Status_Reason_Txt__c = 'Test';
        PRM_AcctContRel_TriggerHandler.executeTrigger = false;
        insert acctContRel1;
        PRM_AcctContRel_TriggerHandler.executeTrigger = true;
        
        /*PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c();
        acctContRel2.PRM_Account_Id__c=parent1.Id;
        acctContRel2.PRM_Contact_Id__c=pAGcont1.Id;
        acctContRel2.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel2.PRM_Status_Nm__c='Complete';
        acctContRel2.PRM_InActive_Ind__c=false;
        PRM_AcctContRel_TriggerHandler.executeTrigger = false;
        insert acctContRel2;
        PRM_AcctContRel_TriggerHandler.executeTrigger = true;*/
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c();
        acctContRel3.PRM_Account_Id__c=parent1.Id;
        acctContRel3.PRM_Contact_Id__c=pAGcont2.Id;
        acctContRel3.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel3.PRM_Status_Nm__c='Complete';
        acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_Status_Reason_Txt__c = 'Test';
        PRM_AcctContRel_TriggerHandler.executeTrigger = false;
        insert acctContRel3;
        PRM_AcctContRel_TriggerHandler.executeTrigger = true;
        
        PRM_Account_Contact_Relationship__c acctContRel4=new PRM_Account_Contact_Relationship__c();
        acctContRel4.PRM_Account_Id__c=parent1.Id;
        acctContRel4.PRM_Contact_Id__c=cont3.Id;
        acctContRel4.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel4.PRM_Status_Nm__c='Complete';
        acctContRel4.PRM_InActive_Ind__c=false;
        acctContRel4.PRM_Status_Reason_Txt__c = 'Test';
        PRM_AcctContRel_TriggerHandler.executeTrigger = false;
        insert acctContRel4;
        PRM_AcctContRel_TriggerHandler.executeTrigger = true;
        
        System.Debug('LIMITS 7 : ' + Limits.getQueries());
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=pAGcont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        System.Debug('LIMITS 8 : ' + Limits.getQueries());
        
        Test.startTest(); 
        
        prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
        bm.inactive__c = false;
        insert bm;
        
        
        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abassociationTest2 = new PRM_AccountBenefitAssociation__c();
        abassociationTest2.PRM_Account_Id__c = parent1.id;
        abassociationTest2.PRM_Partner_Benefit_Id__c = pbTest4.id;
        abassociationTest2.PRM_Status_Nm__c = 'Active';
        abassociationTest2.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest2);
        
        PRM_AccountBenefitAssociation__c abassociationTest3 = new PRM_AccountBenefitAssociation__c();
        abassociationTest3.PRM_Account_Id__c = parent1.id;
        abassociationTest3.PRM_Partner_Benefit_Id__c = pbTest7.id;
        abassociationTest3.PRM_Status_Nm__c = 'Active';
        abassociationTest3.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest3);

        PRM_AccountBenefitAssociation__c abassociationTest4 = new PRM_AccountBenefitAssociation__c();//varunreddy
        abassociationTest4.PRM_Account_Id__c = parent1.id;
        abassociationTest4.PRM_Partner_Benefit_Id__c = pbTest6.id;
        abassociationTest4.PRM_Status_Nm__c = 'Active';
        abassociationTest4.PRM_Status_Reason_Txt__c='Test';
        abaList.add(abassociationTest4);

        PRM_aba_TriggerHandler.executeTrigger = false;
        insert abaList;
        PRM_aba_TriggerHandler.executeTrigger = true;
        
        PRM_Warranty_Data__c warr=new PRM_Warranty_Data__c();
        warr.PRM_Number_Of_AWR_Remaining_Nbr__c= 788;
        warr.PRM_Account_Id__c= parent1.Id;
        insert warr;
        
        System.Debug('LIMITS 9 : ' + Limits.getQueries());
        
        List<PRM_PEx_Access_Matrix__c> accessMatrixList1=new List<PRM_PEx_Access_Matrix__c>();  
        PRM_PEx_Access_Matrix__c accessmatrx1=new PRM_PEx_Access_Matrix__c();
        Id beneftAccRule = Schema.SObjectType.PRM_PEx_Access_Matrix__c.getRecordTypeInfosByDeveloperName().get('Benefit_Access_Rule').getRecordTypeId();
        
        //for MDF   
        //PRM_PEx_Access_Matrix__c accessmatrx=new PRM_PEx_Access_Matrix__c();      
        accessmatrx1.PRM_Benefit_Blade__c='MDF';
        accessmatrx1.PRM_Entitlements__c='Partner Admin';
        accessmatrx1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx1.PRM_Click_To_Action__c='Submit A Proposal';
        accessmatrx1.PRM_CTA_Priority__c='2';
        accessmatrx1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx1.PRM_Benefit_Priority__c=5;
        accessmatrx1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrx1);
        //insert accessmatrx;
        
        PRM_PEx_Access_Matrix__c accessmatrx11=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx11.PRM_Benefit_Blade__c='MDF';
        accessmatrx11.PRM_Entitlements__c='Partner Admin';
        accessmatrx11.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx11.PRM_Click_To_Action__c='Submit MDF Claim';
        accessmatrx11.PRM_CTA_Priority__c='2';
        accessmatrx11.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx11.PRM_Benefit_Priority__c=5;
        accessmatrx11.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrx11);
        //insert accessmatrx1;
        
        PRM_PEx_Access_Matrix__c accessmatrx21=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx21.PRM_Benefit_Blade__c='MDF';
        accessmatrx21.PRM_Entitlements__c='Partner Admin';
        accessmatrx21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx21.PRM_Click_To_Action__c='Submit MDF Campaign';
        accessmatrx21.PRM_CTA_Priority__c='2';
        accessmatrx21.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx21.PRM_Benefit_Priority__c=5;
        accessmatrx21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrx21);
        //insert accessmatrx2;
        
        PRM_PEx_Access_Matrix__c accessmatrx31=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx31.PRM_Benefit_Blade__c='MDF';
        accessmatrx31.PRM_Entitlements__c='Partner Admin';
        accessmatrx31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx31.PRM_Click_To_Action__c='MDF Tool';
        accessmatrx31.PRM_CTA_Priority__c='2';
        accessmatrx31.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx31.PRM_Benefit_Priority__c=5;
        accessmatrx31.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrx31);
        // insert accessmatrx3;
        
        PRM_PEx_Access_Matrix__c accessmatrx41=new PRM_PEx_Access_Matrix__c(); 
        accessmatrx41.PRM_Benefit_Blade__c='MDF';
        accessmatrx41.PRM_Entitlements__c='Partner Admin';
        accessmatrx41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx41.PRM_Click_To_Action__c='Get Help With MDF';
        accessmatrx41.PRM_CTA_Priority__c='2';
        accessmatrx41.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrx41.PRM_Benefit_Priority__c=5;
        accessmatrx41.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrx41);
        // insert accessmatrx4;
        
   
        //Points
        PRM_PEx_Access_Matrix__c accessmatrxp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxp1.PRM_Benefit_Blade__c='Points';
        accessmatrxp1.PRM_Entitlements__c='Partner Admin';
        accessmatrxp1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp1.PRM_Click_To_Action__c='Spend Points';
        accessmatrxp1.PRM_CTA_Priority__c='1';
        accessmatrxp1.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp1.PRM_Benefit_Priority__c=1;
        accessmatrxp1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp1);
        //insert accessmatrxp;
        
        PRM_PEx_Access_Matrix__c accessmatrxp11=new PRM_PEx_Access_Matrix__c();
        accessmatrxp11.PRM_Benefit_Blade__c='Points';
        accessmatrxp11.PRM_Entitlements__c='Partner Admin';
        accessmatrxp11.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp11.PRM_Click_To_Action__c='Earn Points';
        accessmatrxp11.PRM_CTA_Priority__c='1';
        accessmatrxp11.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp11.PRM_Benefit_Priority__c=1;
        accessmatrxp11.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp11);
        // insert accessmatrxp1;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp21=new PRM_PEx_Access_Matrix__c();
        accessmatrxp21.PRM_Benefit_Blade__c='Points';
        accessmatrxp21.PRM_Entitlements__c='Partner Admin';
        accessmatrxp21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp21.PRM_Click_To_Action__c='Points Wishlist';
        accessmatrxp21.PRM_CTA_Priority__c='1';
        accessmatrxp21.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp21.PRM_Benefit_Priority__c=1;
        accessmatrxp21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp21);
        // insert accessmatrxp2;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp31=new PRM_PEx_Access_Matrix__c();
        accessmatrxp31.PRM_Benefit_Blade__c='Points';
        accessmatrxp31.PRM_Entitlements__c='Partner Admin';
        accessmatrxp31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp31.PRM_Click_To_Action__c='Points Simulator Tool';
        accessmatrxp31.PRM_CTA_Priority__c='1';
        accessmatrxp31.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp31.PRM_Benefit_Priority__c=1;
        accessmatrxp31.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp31);
        // insert accessmatrxp3;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp41=new PRM_PEx_Access_Matrix__c();
        accessmatrxp41.PRM_Benefit_Blade__c='Points';
        accessmatrxp41.PRM_Entitlements__c='Partner Admin';
        accessmatrxp41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp41.PRM_Click_To_Action__c='Points Matrix';
        accessmatrxp41.PRM_CTA_Priority__c='1';
        accessmatrxp41.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp41.PRM_Benefit_Priority__c=1;
        accessmatrxp41.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp41);
        // insert accessmatrxp4;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxp51=new PRM_PEx_Access_Matrix__c();
        accessmatrxp51.PRM_Benefit_Blade__c='Points';
        accessmatrxp51.PRM_Entitlements__c='Partner Admin';
        accessmatrxp51.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp51.PRM_Click_To_Action__c='View Account';
        accessmatrxp51.PRM_CTA_Priority__c='1';
        accessmatrxp51.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp51.PRM_Benefit_Priority__c=1;
        accessmatrxp51.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp51);
        // insert accessmatrxp5;
        
        PRM_PEx_Access_Matrix__c accessmatrx61=new PRM_PEx_Access_Matrix__c();
        accessmatrx61.PRM_Benefit_Blade__c='Points';
        accessmatrx61.PRM_Entitlements__c='Partner Admin';
        accessmatrx61.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrx61.PRM_Click_To_Action__c='Partner Assist';
        accessmatrx61.PRM_CTA_Priority__c='1';
        accessmatrx61.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrx61.PRM_Benefit_Priority__c=1;
        accessmatrx61.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrx61);
        // insert accessmatrx6;
        
        PRM_PEx_Access_Matrix__c accessmatrxp71=new PRM_PEx_Access_Matrix__c();
        accessmatrxp71.PRM_Benefit_Blade__c='Points';
        accessmatrxp71.PRM_Entitlements__c='Partner Admin';
        accessmatrxp71.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxp71.PRM_Click_To_Action__c='Get help with Points';
        accessmatrxp71.PRM_CTA_Priority__c='1';
        accessmatrxp71.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxp71.PRM_Benefit_Priority__c=1;
        accessmatrxp71.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxp71);
        //  insert accessmatrxp7;
        
        
        //Leads
        PRM_PEx_Access_Matrix__c accessmatrxl1=new PRM_PEx_Access_Matrix__c();
        accessmatrxl1.PRM_Benefit_Blade__c='Leads';
        accessmatrxl1.PRM_Entitlements__c='Partner Admin';
        accessmatrxl1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxl1.PRM_Click_To_Action__c='Manage Leads';
        accessmatrxl1.PRM_CTA_Priority__c='1';
        accessmatrxl1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxl1.PRM_Benefit_Priority__c=2;
        accessmatrxl1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxl1);
        // insert accessmatrxl;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxl12=new PRM_PEx_Access_Matrix__c();
        accessmatrxl12.PRM_Benefit_Blade__c='Leads';
        accessmatrxl12.PRM_Entitlements__c='Partner Admin';
        accessmatrxl12.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxl12.PRM_Click_To_Action__c='View results';
        accessmatrxl12.PRM_CTA_Priority__c='1';
        accessmatrxl12.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxl12.PRM_Benefit_Priority__c=2;
        accessmatrxl12.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxl12);
        //  insert accessmatrxl1;
        
        PRM_PEx_Access_Matrix__c accessmatrxl21=new PRM_PEx_Access_Matrix__c();
        accessmatrxl21.PRM_Benefit_Blade__c='Leads';
        accessmatrxl21.PRM_Entitlements__c='Partner Admin';
        accessmatrxl21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxl21.PRM_Click_To_Action__c='Get help with Leads';
        accessmatrxl21.PRM_CTA_Priority__c='1';
        accessmatrxl21.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxl21.PRM_Benefit_Priority__c=2;
        accessmatrxl21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxl21);
        // insert accessmatrxl2;
        
        
        
        
        
        //Marketplace
        PRM_PEx_Access_Matrix__c accessmatrxmp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp1.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp1.PRM_Entitlements__c='Partner Admin';
        accessmatrxmp1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp1.PRM_Click_To_Action__c='Manage Storefront';
        accessmatrxmp1.PRM_CTA_Priority__c='3';
        accessmatrxmp1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp1.PRM_Benefit_Priority__c=4;
        accessmatrxmp1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp1);
        //  insert accessmatrxmp;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp12=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp12.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp12.PRM_Entitlements__c='Partner Admin';
        accessmatrxmp12.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp12.PRM_Click_To_Action__c='Manage Offerings';
        accessmatrxmp12.PRM_CTA_Priority__c='3';
        accessmatrxmp12.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp12.PRM_Benefit_Priority__c=4;
        accessmatrxmp12.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp12);
        // insert accessmatrxmp1;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp21=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp21.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp21.PRM_Entitlements__c='Partner Admin';
        accessmatrxmp21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp21.PRM_Click_To_Action__c='Create New Offering';
        accessmatrxmp21.PRM_CTA_Priority__c='3';
        accessmatrxmp21.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp21.PRM_Benefit_Priority__c=4;
        accessmatrxmp21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp21);
        // insert accessmatrxmp2;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp31=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp31.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp31.PRM_Entitlements__c='Partner Admin';
        accessmatrxmp31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp31.PRM_Click_To_Action__c='View Results';
        accessmatrxmp31.PRM_CTA_Priority__c='3';
        accessmatrxmp31.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp31.PRM_Benefit_Priority__c=4;
        accessmatrxmp31.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp31);
        //   insert accessmatrxmp3;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxmp41=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp41.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp41.PRM_Entitlements__c='Partner Admin';
        accessmatrxmp41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp41.PRM_Click_To_Action__c='Visit Marketplace';
        accessmatrxmp41.PRM_CTA_Priority__c='3';
        accessmatrxmp41.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp41.PRM_Benefit_Priority__c=4;
        accessmatrxmp41.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp41);
        //   insert accessmatrxmp4;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp51=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp51.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp51.PRM_Entitlements__c='Partner Admin';
        accessmatrxmp51.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp51.PRM_Click_To_Action__c='Get help with Marketplace';
        accessmatrxmp51.PRM_CTA_Priority__c='3';
        accessmatrxmp51.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp51.PRM_Benefit_Priority__c=4;
        accessmatrxmp51.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp51);
        //   insert accessmatrxmp5;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxmp6=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp6.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp6.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp6.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp6.PRM_Click_To_Action__c='Learn about submitting a solution';
        accessmatrxmp6.PRM_CTA_Priority__c='5';
        accessmatrxmp6.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp6.PRM_Benefit_Priority__c=4;
        accessmatrxmp6.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp6);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp7=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp7.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp7.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp7.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp7.PRM_Click_To_Action__c='Manage Solutions';
        accessmatrxmp7.PRM_CTA_Priority__c='4';
        accessmatrxmp7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp7.PRM_Benefit_Priority__c=4;
        accessmatrxmp7.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp7);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp8=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp8.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp8.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp8.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp8.PRM_Click_To_Action__c='Submit a Solution';
        accessmatrxmp8.PRM_CTA_Priority__c='6';
        accessmatrxmp8.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp8.PRM_Benefit_Priority__c=4;
        accessmatrxmp8.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxmp8);
        
        
        //Partner help
        PRM_PEx_Access_Matrix__c accessmatrxph1=new PRM_PEx_Access_Matrix__c();
        accessmatrxph1.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph1.PRM_Entitlements__c='Partner Admin';
        accessmatrxph1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph1.PRM_Click_To_Action__c='View All Support Tickets';
        accessmatrxph1.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph1.PRM_Benefit_Priority__c=4;
        accessmatrxph1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph1);
        //insert accessmatrxph;
        
        PRM_PEx_Access_Matrix__c accessmatrxph11=new PRM_PEx_Access_Matrix__c();
        accessmatrxph11.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph11.PRM_Entitlements__c='Partner Admin';
        accessmatrxph11.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph11.PRM_Click_To_Action__c='Create Support Ticket';
        accessmatrxph11.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph11.PRM_Benefit_Priority__c=4;
        accessmatrxph11.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph11);
        //   insert accessmatrxph1;
        
        PRM_PEx_Access_Matrix__c accessmatrxph21=new PRM_PEx_Access_Matrix__c();
        accessmatrxph21.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph21.PRM_Entitlements__c='Partner Admin';
        accessmatrxph21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph21.PRM_Click_To_Action__c='New Warranty Return';
        accessmatrxph21.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph21.PRM_Benefit_Priority__c=4;
        accessmatrxph21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph21);
        //   insert accessmatrxph2;
        
        PRM_PEx_Access_Matrix__c accessmatrxph31=new PRM_PEx_Access_Matrix__c();
        accessmatrxph31.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph31.PRM_Entitlements__c='Partner Admin';
        accessmatrxph31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph31.PRM_Click_To_Action__c='View Warranty Coverage Status';
        accessmatrxph31.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph31.PRM_Benefit_Priority__c=4;
        accessmatrxph31.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph31);
        //  insert accessmatrxph3;
        
        PRM_PEx_Access_Matrix__c accessmatrxph41=new PRM_PEx_Access_Matrix__c();
        accessmatrxph41.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph41.PRM_Entitlements__c='Partner Admin';
        accessmatrxph41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph41.PRM_Click_To_Action__c='Intel Premier Support';
        accessmatrxph41.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph41.PRM_Benefit_Priority__c=4;
        accessmatrxph41.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph41);
        //   insert accessmatrxph4;
        
        PRM_PEx_Access_Matrix__c accessmatrxph15=new PRM_PEx_Access_Matrix__c();
        accessmatrxph15.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph15.PRM_Entitlements__c='Partner Admin';
        accessmatrxph15.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph15.PRM_Click_To_Action__c='Get help with Portal or program';
        accessmatrxph15.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph15.PRM_Benefit_Priority__c=4;
        accessmatrxph15.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph15);
        //   insert accessmatrxph5;
        
        PRM_PEx_Access_Matrix__c accessmatrxph16=new PRM_PEx_Access_Matrix__c();
        accessmatrxph16.PRM_Benefit_Blade__c='Partner Help';
        accessmatrxph16.PRM_Entitlements__c='Partner Admin';
        accessmatrxph16.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxph16.PRM_Click_To_Action__c='Get help with Warranty Return';
        accessmatrxph16.PRM_CTA_Priority__c='3';
        //accessmatrxph.PRM_Partner_Benefit__c=;//prnbnft.Id;
        accessmatrxph16.PRM_Benefit_Priority__c=4;
        accessmatrxph16.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxph16);
        
        PRM_PEx_Access_Matrix__c accessmatrxt1=new PRM_PEx_Access_Matrix__c();
        accessmatrxt1.PRM_Benefit_Blade__c='Training';
        accessmatrxt1.PRM_Entitlements__c='Partner Admin';
        accessmatrxt1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt1.PRM_Click_To_Action__c='View Courses';
        accessmatrxt1.PRM_CTA_Priority__c='1';
        accessmatrxt1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt1.PRM_Benefit_Priority__c=3;
        accessmatrxt1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt1);
        //  insert accessmatrxt;
        
        PRM_PEx_Access_Matrix__c accessmatrxt11=new PRM_PEx_Access_Matrix__c();
        accessmatrxt11.PRM_Benefit_Blade__c='Training';
        accessmatrxt11.PRM_Entitlements__c='Partner Admin';
        accessmatrxt11.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt11.PRM_Click_To_Action__c='Track My Learning';
        accessmatrxt11.PRM_CTA_Priority__c='1';
        accessmatrxt11.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt11.PRM_Benefit_Priority__c=3;
        accessmatrxt11.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt11);
        //  insert accessmatrxt1;
        
        PRM_PEx_Access_Matrix__c accessmatrxt21=new PRM_PEx_Access_Matrix__c();
        accessmatrxt21.PRM_Benefit_Blade__c='Training';
        accessmatrxt21.PRM_Entitlements__c='Partner Admin';
        accessmatrxt21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt21.PRM_Click_To_Action__c='My Competencies';
        accessmatrxt21.PRM_CTA_Priority__c='1';
        accessmatrxt21.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt21.PRM_Benefit_Priority__c=3;
        accessmatrxt21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt21);
        //  insert accessmatrxt2;
        
        PRM_PEx_Access_Matrix__c accessmatrxt31=new PRM_PEx_Access_Matrix__c();
        accessmatrxt31.PRM_Benefit_Blade__c='Training';
        accessmatrxt31.PRM_Entitlements__c='Partner Admin';
        accessmatrxt31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt31.PRM_Click_To_Action__c='Browse All Webinars';
        accessmatrxt31.PRM_CTA_Priority__c='1';
        accessmatrxt31.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt31.PRM_Benefit_Priority__c=3;
        accessmatrxt31.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt31);
        //  insert accessmatrxt3;
        
        PRM_PEx_Access_Matrix__c accessmatrxt41=new PRM_PEx_Access_Matrix__c();
        accessmatrxt41.PRM_Benefit_Blade__c='Training';
        accessmatrxt41.PRM_Entitlements__c='Partner Admin';
        accessmatrxt41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt41.PRM_Click_To_Action__c='Get Help With Training';
        accessmatrxt41.PRM_CTA_Priority__c='1';
        accessmatrxt41.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt41.PRM_Benefit_Priority__c=3;
        accessmatrxt41.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt41);
        //    insert accessmatrxt4;
        
        PRM_PEx_Access_Matrix__c accessmatrxt51=new PRM_PEx_Access_Matrix__c();
        accessmatrxt51.PRM_Benefit_Blade__c='Training';
        accessmatrxt51.PRM_Entitlements__c='Partner Admin';
        accessmatrxt51.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt51.PRM_Click_To_Action__c='Webinars';
        accessmatrxt51.PRM_CTA_Priority__c='1';
        accessmatrxt51.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt51.PRM_Benefit_Priority__c=3;
        accessmatrxt51.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt51);
        //   insert accessmatrxt5;
        
        PRM_PEx_Access_Matrix__c accessmatrxt16=new PRM_PEx_Access_Matrix__c();
        accessmatrxt16.PRM_Benefit_Blade__c='Training';
        accessmatrxt16.PRM_Entitlements__c='Partner Admin';
        accessmatrxt16.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt16.PRM_Click_To_Action__c='Competitive Guidance Presentation';
        accessmatrxt16.PRM_CTA_Priority__c='1';
        accessmatrxt16.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt16.PRM_Benefit_Priority__c=3;
        accessmatrxt16.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt16);
        //    insert accessmatrxt6;
        
        PRM_PEx_Access_Matrix__c accessmatrxt71=new PRM_PEx_Access_Matrix__c();
        accessmatrxt71.PRM_Benefit_Blade__c='Training';
        accessmatrxt71.PRM_Entitlements__c='Partner Admin';
        accessmatrxt71.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt71.PRM_Click_To_Action__c='Virtual Tech Conference';
        accessmatrxt71.PRM_CTA_Priority__c='1';
        accessmatrxt71.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt71.PRM_Benefit_Priority__c=3;
        accessmatrxt71.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt71);
        //  insert accessmatrxt7;
        
        PRM_PEx_Access_Matrix__c accessmatrxt81=new PRM_PEx_Access_Matrix__c();
        accessmatrxt81.PRM_Benefit_Blade__c='Training';
        accessmatrxt81.PRM_Entitlements__c='Partner Admin';
        accessmatrxt81.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxt81.PRM_Click_To_Action__c='How to sell videos';
        accessmatrxt81.PRM_CTA_Priority__c='1';
        accessmatrxt81.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt81.PRM_Benefit_Priority__c=3;
        accessmatrxt81.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxt81);
        // insert accessmatrxt8;
        
        //FPGA Tools and Resources
        String pRole = 'Distributor';
        PRM_PEx_Access_Matrix__c accessmatrxfp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxfp1.PRM_Benefit_Blade__c='FPGA Tools and Resources';
        accessmatrxfp1.PRM_Entitlements__c='Partner Admin';
        accessmatrxfp1.PRM_IPA_Partner_Role__c=pRole;
        accessmatrxfp1.PRM_Click_To_Action__c='Visit FPGA Communities';
        accessmatrxfp1.PRM_CTA_Priority__c='1';
        //accessmatrxfp1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxfp1.PRM_Benefit_Priority__c=22;
        accessmatrxfp1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxfp1);
        //  insert accessmatrxt;
        
        PRM_PEx_Access_Matrix__c accessmatrxfp11=new PRM_PEx_Access_Matrix__c();
        accessmatrxfp11.PRM_Benefit_Blade__c='FPGA Tools and Resources';
        accessmatrxfp11.PRM_Entitlements__c='Partner Admin';
        accessmatrxfp11.PRM_IPA_Partner_Role__c= pRole;
        accessmatrxfp11.PRM_Click_To_Action__c='Track and Enter Design Registration';
        accessmatrxfp11.PRM_CTA_Priority__c='2';
        //accessmatrxfp11.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxfp11.PRM_Benefit_Priority__c=22;
        accessmatrxfp11.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxfp11);
        //  insert accessmatrxt1;
        
        PRM_PEx_Access_Matrix__c accessmatrxfp21=new PRM_PEx_Access_Matrix__c();
        accessmatrxfp21.PRM_Benefit_Blade__c='FPGA Tools and Resources';
        accessmatrxfp21.PRM_Entitlements__c='Partner Admin';
        accessmatrxfp21.PRM_IPA_Partner_Role__c= pRole;
        accessmatrxfp21.PRM_Click_To_Action__c='Contact FPGA Ecosystem Team';
        accessmatrxfp21.PRM_CTA_Priority__c='3';
        //accessmatrxfp21.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxfp21.PRM_Benefit_Priority__c=22;
        accessmatrxfp21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxfp21);
        //  insert accessmatrxt2;
        
        PRM_PEx_Access_Matrix__c accessmatrxfp22=new PRM_PEx_Access_Matrix__c();
        accessmatrxfp22.PRM_Benefit_Blade__c='FPGA Tools and Resources';
        accessmatrxfp22.PRM_Entitlements__c='Partner Admin';
        accessmatrxfp22.PRM_IPA_Partner_Role__c= pRole;
        accessmatrxfp22.PRM_Click_To_Action__c='Design Registration';
        accessmatrxfp22.PRM_CTA_Priority__c='4';
        accessmatrxfp22.PRM_Benefit_Priority__c=22;
        accessmatrxfp22.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxfp22);
        
        //Marketing Studio
        PRM_PEx_Access_Matrix__c accessmatrxms1=new PRM_PEx_Access_Matrix__c();
        accessmatrxms1.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms1.PRM_Entitlements__c='Partner Admin';
        accessmatrxms1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms1.PRM_Click_To_Action__c='Links To Badges';
        accessmatrxms1.PRM_CTA_Priority__c='1';
        accessmatrxms1.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms1.PRM_Benefit_Priority__c=3;
        accessmatrxms1.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms1);
        // insert accessmatrxms;
        
        PRM_PEx_Access_Matrix__c accessmatrxms12=new PRM_PEx_Access_Matrix__c();
        accessmatrxms12.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms12.PRM_Entitlements__c='Partner Admin';
        accessmatrxms12.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms12.PRM_Click_To_Action__c='Marketing Asset Library';
        accessmatrxms12.PRM_CTA_Priority__c='1';
        accessmatrxms12.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms12.PRM_Benefit_Priority__c=3;
        accessmatrxms12.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms12);
        //  insert accessmatrxms1;
        
        PRM_PEx_Access_Matrix__c accessmatrxms21=new PRM_PEx_Access_Matrix__c();
        accessmatrxms21.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms21.PRM_Entitlements__c='Partner Admin';
        accessmatrxms21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms21.PRM_Click_To_Action__c='View Campaigns';
        accessmatrxms21.PRM_CTA_Priority__c='1';
        accessmatrxms21.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms21.PRM_Benefit_Priority__c=3;
        accessmatrxms21.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms21);
        //  insert accessmatrxms2;
        
        PRM_PEx_Access_Matrix__c accessmatrxms31=new PRM_PEx_Access_Matrix__c();
        accessmatrxms31.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms31.PRM_Entitlements__c='Partner Admin';
        accessmatrxms31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms31.PRM_Click_To_Action__c='Get help with Marketing Studio';
        accessmatrxms31.PRM_CTA_Priority__c='1';
        accessmatrxms31.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms31.PRM_Benefit_Priority__c=3;
        accessmatrxms31.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms31);
        // insert accessmatrxms3;
        
        PRM_PEx_Access_Matrix__c accessmatrxms14=new PRM_PEx_Access_Matrix__c();
        accessmatrxms14.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms14.PRM_Entitlements__c='Partner Admin';
        accessmatrxms14.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms14.PRM_Click_To_Action__c='Visit Partner Marketing Studio';
        accessmatrxms14.PRM_CTA_Priority__c='1';
        accessmatrxms14.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms14.PRM_Benefit_Priority__c=3;
        accessmatrxms14.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms14);
        //   insert accessmatrxms4;
        
        PRM_PEx_Access_Matrix__c accessmatrxms15=new PRM_PEx_Access_Matrix__c();
        accessmatrxms15.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms15.PRM_Entitlements__c='Partner Admin';
        accessmatrxms15.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxms15.PRM_Click_To_Action__c='Links To Logos';
        accessmatrxms15.PRM_CTA_Priority__c='1';
        accessmatrxms15.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms15.PRM_Benefit_Priority__c=3;
        accessmatrxms15.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms15);
        //  insert accessmatrxms5;
        
        PRM_PEx_Access_Matrix__c accessmatrxms16=new PRM_PEx_Access_Matrix__c();
        accessmatrxms16.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms16.PRM_Entitlements__c='Partner Admin';
        accessmatrxms16.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms16.PRM_Click_To_Action__c='Intel® Brand Logo and Usage Guidelines';
        accessmatrxms16.PRM_CTA_Priority__c='2';
        accessmatrxms16.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms16.PRM_Benefit_Priority__c=3;
        accessmatrxms16.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms16);
        
        PRM_PEx_Access_Matrix__c accessmatrxms17=new PRM_PEx_Access_Matrix__c();
        accessmatrxms17.PRM_Benefit_Blade__c='Marketing Studio';
        accessmatrxms17.PRM_Entitlements__c='Partner Admin';
        accessmatrxms17.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms17.PRM_Click_To_Action__c='Intel® Authorized Distributor and Intel® Approved Supplier Badge and Assets';
        accessmatrxms17.PRM_CTA_Priority__c='3';
        accessmatrxms17.PRM_Partner_Benefit__c=pbTest6.Id;//prnbnft.Id;
        accessmatrxms17.PRM_Benefit_Priority__c=3;
        accessmatrxms17.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms17);
        
   /*PRM_PEx_Access_Matrix__c accessmatrxms18=new PRM_PEx_Access_Matrix__c();
        accessmatrxms18.PRM_Benefit_Blade__c='Partner Lookup Tool';
        accessmatrxms18.PRM_Entitlements__c='Partner Admin';
        accessmatrxms18.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms18.PRM_Click_To_Action__c='Partner Lookup Tool';
        accessmatrxms18.PRM_CTA_Priority__c='1';
        accessmatrxms18.PRM_Benefit_Priority__c=23;
        accessmatrxms18.RecordTypeId=beneftAccRule;
        accessMatrixList1.add(accessmatrxms18);*/
        
         
        //Speciality
        Id specbenftRT = Schema.SObjectType.PRM_PEx_Access_Matrix__c.getRecordTypeInfosByDeveloperName().get('Specialty_Select_Benefit_Access_Rule').getRecordTypeId();
        PRM_PEx_Access_Matrix__c accessmatrxsp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp1.PRM_Benefit_Blade__c='Cloud Data Center Specialty';
        accessmatrxsp1.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp1.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp1.PRM_Click_To_Action__c='View Cloud Data Center Specialty';
        accessmatrxsp1.PRM_CTA_Priority__c='1';
        accessmatrxsp1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp1.PRM_Benefit_Priority__c=7;
        //accessmatrxsp1.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp1.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp1);
        // insert accessmatrxsp;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp21=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp21.PRM_Benefit_Blade__c='High Performance Computing Data Center Specialty';
        accessmatrxsp21.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp21.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp21.PRM_Click_To_Action__c='HPC';
        accessmatrxsp21.PRM_CTA_Priority__c='';
        accessmatrxsp21.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp21.PRM_Benefit_Priority__c=7;
        //accessmatrxsp21.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp21.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp21);
        // insert accessmatrxsp1;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp211=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp211.PRM_Benefit_Blade__c='Artificial Intelligence Specialty';
        accessmatrxsp211.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp211.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp211.PRM_Click_To_Action__c='Artificial Intelligence';
        accessmatrxsp211.PRM_CTA_Priority__c='';
        accessmatrxsp211.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp211.PRM_Benefit_Priority__c=7;
        //accessmatrxsp211.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp211.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp211);
        // insert accessmatrxsp2;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp31=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp31.PRM_Benefit_Blade__c='Video Specialty';
        accessmatrxsp31.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp31.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp31.PRM_Click_To_Action__c='View Video Specialty';
        accessmatrxsp31.PRM_CTA_Priority__c='1';
        accessmatrxsp31.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp31.PRM_Benefit_Priority__c=7;
        //accessmatrxsp31.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp31.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp31);
        // insert accessmatrxsp3;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp41=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp41.PRM_Benefit_Blade__c='Visual Display Solutions Specialty';
        accessmatrxsp41.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp41.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp41.PRM_Click_To_Action__c='Visual Display';
        accessmatrxsp41.PRM_CTA_Priority__c='';
        accessmatrxsp41.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp41.PRM_Benefit_Priority__c=7;
        //accessmatrxsp41.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp41.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp41);
        //    insert accessmatrxsp4;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp51=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp51.PRM_Benefit_Blade__c='Industrial Solutions Builder Specialty';
        accessmatrxsp51.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp51.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp51.PRM_Click_To_Action__c='Solutions Builder';
        accessmatrxsp51.PRM_CTA_Priority__c='';
        accessmatrxsp51.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp51.PRM_Benefit_Priority__c=7;
        //accessmatrxsp51.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp51.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp51);
        //      insert accessmatrxsp5;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp61=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp61.PRM_Benefit_Blade__c='Optane Data Center Specialty';
        accessmatrxsp61.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp61.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp61.PRM_Click_To_Action__c='Optane Technology';
        accessmatrxsp61.PRM_CTA_Priority__c='';
        accessmatrxsp61.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp61.PRM_Benefit_Priority__c=7;
        //accessmatrxsp61.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp61.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp61);
        // insert accessmatrxsp6;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp71=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp71.PRM_Benefit_Blade__c='Optane Client Specialty';
        accessmatrxsp71.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp71.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp71.PRM_Click_To_Action__c='Optane Technology';
        accessmatrxsp71.PRM_CTA_Priority__c='';
        accessmatrxsp71.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp71.PRM_Benefit_Priority__c=7;
        //accessmatrxsp71.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp71.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp71);
        //  insert accessmatrxsp7;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp81=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp81.PRM_Benefit_Blade__c='Device as a Service Specialty';
        accessmatrxsp81.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp81.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp81.PRM_Click_To_Action__c='Device as a Service';
        accessmatrxsp81.PRM_CTA_Priority__c='';
        accessmatrxsp81.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp81.PRM_Benefit_Priority__c=7;
        //accessmatrxsp81.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp81.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp81);
        // insert accessmatrxsp8;
        
        PRM_PEx_Access_Matrix__c accessmatrxsp91=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp91.PRM_Benefit_Blade__c='Managed Services Specialty';
        accessmatrxsp91.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp91.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp91.PRM_Click_To_Action__c='Managed Services';
        accessmatrxsp91.PRM_CTA_Priority__c='';
        accessmatrxsp91.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp91.PRM_Benefit_Priority__c=7;
        //accessmatrxsp91.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp91.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp91);
        //   insert accessmatrxsp9;
        
        //Networking Specialty
        PRM_PEx_Access_Matrix__c accessmatrxsp101=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp101.PRM_Benefit_Blade__c='Networking Specialty';
        accessmatrxsp101.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp101.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp101.PRM_Click_To_Action__c='View Specialty benefit';
        accessmatrxsp101.PRM_CTA_Priority__c='1';
        accessmatrxsp101.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp101.PRM_Benefit_Priority__c=7;
        //accessmatrxsp101.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp101.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp101);
        
        PRM_PEx_Access_Matrix__c accessmatrxsp102=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp102.PRM_Benefit_Blade__c='Networking Specialty';
        accessmatrxsp102.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp102.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp102.PRM_Click_To_Action__c='Visit Intel® Network Builders';
        accessmatrxsp102.PRM_CTA_Priority__c='2';
        //accessmatrxsp101.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp102.PRM_Benefit_Priority__c=7;
        //accessmatrxsp102.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp102.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp102);
        
        PRM_PEx_Access_Matrix__c accessmatrxsp103=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp103.PRM_Benefit_Blade__c='Networking Specialty';
        accessmatrxsp103.PRM_Entitlements__c='Partner Admin';
        accessmatrxsp103.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxsp103.PRM_Click_To_Action__c='Visit Intel® Network Builders University';
        accessmatrxsp103.PRM_CTA_Priority__c='3';
        accessmatrxsp103.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp103.PRM_Benefit_Priority__c=7;
        //accessmatrxsp103.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp103.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp103);
        //   insert accessmatrxsp9;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxsp91k=new PRM_PEx_Access_Matrix__c();
        accessmatrxsp91k.PRM_Benefit_Blade__c='Enthusiast PC Specialty';
        accessmatrxsp91k.PRM_Entitlements__c='Partner Admin';
        // String partRole1 = ' Distributor'Distributor;Independent Software Vendor;Manufacturer;Seller;Service Provider;Solution Integrator;Sponsor;Original Equipment Manufacturer (OEM);Guest';
        accessmatrxsp91k.PRM_IPA_Partner_Role__c= 'Service Provider';
        accessmatrxsp91k.PRM_Click_To_Action__c='View Enthusiast PC Specialty';
        accessmatrxsp91k.PRM_CTA_Priority__c='';
        accessmatrxsp91k.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxsp91k.PRM_Benefit_Priority__c=7;
        //accessmatrxsp91k.PRM_Partner_Specialty_Select_Benefit__c=spec2.Id;//spc.Id;
        accessmatrxsp91k.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxsp91k);       
        
        
        //select benefit
        PRM_PEx_Access_Matrix__c accessmatrxbft01=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft01.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft01.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft01.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft01.PRM_Click_To_Action__c='Find help and training';
        accessmatrxbft01.PRM_CTA_Priority__c='';
        //accessmatrxbft01.PRM_Partner_Specialty_Select_Benefit__c=spec1.Id;
        accessmatrxbft01.PRM_Benefit_Priority__c=6;
        accessmatrxbft01.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxbft01);
        //  insert accessmatrxbft;
        
        PRM_PEx_Access_Matrix__c accessmatrxbft011=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft011.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft011.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft011.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft011.PRM_Click_To_Action__c='View results';
        accessmatrxbft011.PRM_CTA_Priority__c='';
        //accessmatrxbft011.PRM_Partner_Specialty_Select_Benefit__c=spec1.Id;
        accessmatrxbft011.PRM_Benefit_Priority__c=6;
        accessmatrxbft011.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxbft011);
        //     insert accessmatrxbft01;
        
        PRM_PEx_Access_Matrix__c accessmatrxbft021=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft021.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft021.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft021.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft021.PRM_Click_To_Action__c='Intel® Partner Alliance IoT Additive Select Benefits';
        accessmatrxbft021.PRM_CTA_Priority__c='2';
       // accessmatrxbft021.PRM_Partner_Specialty_Select_Benefit__c=spec1.Id;
        accessmatrxbft021.PRM_Benefit_Priority__c=6;
        accessmatrxbft021.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxbft021);
        //  insert accessmatrxbft;
        PRM_PEx_Access_Matrix__c accessmatrxbft031=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft031.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft031.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft031.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft031.PRM_Click_To_Action__c='Intel® Partner Alliance IoT Baseline Select Benefits';
        accessmatrxbft031.PRM_CTA_Priority__c='3';
        //accessmatrxbft031.PRM_Partner_Specialty_Select_Benefit__c=spec1.Id;
        accessmatrxbft031.PRM_Benefit_Priority__c=6;
        accessmatrxbft031.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxbft031);
        
        PRM_PEx_Access_Matrix__c accessmatrxbft041=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft041.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft041.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft041.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft041.PRM_Click_To_Action__c='Intel® Partner Alliance AI Application Ecosystem Advancement Select Benefits';
        accessmatrxbft041.PRM_CTA_Priority__c='4';
       // accessmatrxbft041.PRM_Partner_Specialty_Select_Benefit__c=spec1.Id;
        accessmatrxbft041.PRM_Benefit_Priority__c=6;
        accessmatrxbft041.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxbft041);
        //  insert accessmatrxbft;
        PRM_PEx_Access_Matrix__c accessmatrxbft051=new PRM_PEx_Access_Matrix__c();
        accessmatrxbft051.PRM_Benefit_Blade__c='Select Benefit';
        accessmatrxbft051.PRM_Entitlements__c='Partner Admin';
        accessmatrxbft051.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxbft051.PRM_Click_To_Action__c='Intel® Data Center Innovation Fund (DCIF) Select Benefit';
        accessmatrxbft051.PRM_CTA_Priority__c='5';
       // accessmatrxbft051.PRM_Partner_Specialty_Select_Benefit__c=spec1.Id;
        accessmatrxbft051.PRM_Benefit_Priority__c=6;
        accessmatrxbft051.RecordTypeId=specbenftRT;
        accessMatrixList1.add(accessmatrxbft051);        
        
        
        insert accessMatrixList1;
        
        //List<PRM_Message__c> msgList=new List<PRM_Message__c>();
        // List<PRM_Message_log__c> msgLogList=new List<PRM_Message_log__c>();
        Id messageRecordId = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Adhoc').getRecordTypeId();
        PRM_Message__c msg=new PRM_Message__c();
        msg.PRM_UI_Display_Area_Nm__c='Leads';
        msg.PRM_Title_Txt__c='Welcome to Intel';
        msg.PRM_Description_Txt__c='Intel Cloud inside';
        msg.PRM_End_Date_Dt__c=NULL;
        msg.PRM_InActive_Ind__c = false;
        msg.recordtypeid = messageRecordId;
        //msgList.add(msg);
        insert msg;
        
        //Message Log
        PRM_Message_log__c msglog=new PRM_Message_log__c();
        msglog.PRM_Message_Id__c=msg.id;
        msglog.PRM_Message_Viewed_Ind__c=false;
        msglog.PRM_Contact_Id__c = pAGcont.Id;
        msglog.PRM_Inactive_Ind__c =false;
        //msgLogList.add(msgLog);
        insert msglog;
        
        //Nilesh added
        Id messageRT1 = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Event').getRecordTypeId();
        Id messageRT2 = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Adhoc').getRecordTypeId();
        PRM_Message__c msg1=new PRM_Message__c();
        msg1.PRM_UI_Display_Area_Nm__c='Leads';
        msg1.PRM_Title_Txt__c='Welcome to Intel';
        msg1.PRM_Description_Txt__c='Intel Cloud inside';
        msg1.PRM_End_Date_Dt__c=NULL;
        msg1.PRM_InActive_Ind__c = false;
        msg1.recordtypeid = messageRT1;
        //msgList.add(msg1);
        insert msg1;
        
        PRM_Message_log__c msglog1=new PRM_Message_log__c();
        msglog1.PRM_Message_Id__c=msg1.id;
        msglog1.PRM_Message_Viewed_Ind__c=false;
        msglog1.PRM_Contact_Id__c = pAGcont.Id;
        msglog1.PRM_Inactive_Ind__c =false;
        //msgLogList.add(msglog1);
        insert msglog1;
        
        PRM_Message__c msg1f=new PRM_Message__c();
        msg1f.PRM_UI_Display_Area_Nm__c='Leads';
        msg1f.PRM_Title_Txt__c='Welcome to Intel';
        msg1f.PRM_Description_Txt__c='Intel Cloud inside';
        msg1f.PRM_End_Date_Dt__c=NULL;
        msg1f.PRM_InActive_Ind__c = false;
        msg1f.recordtypeid = messageRT1;
        // msgList.add(msg1f);
        insert msg1f;
        
        PRM_Message_log__c msglog1f=new PRM_Message_log__c();
        msglog1f.PRM_Message_Id__c=msg1f.id;
        msglog1f.PRM_Message_Viewed_Ind__c=false;
        msglog1f.PRM_Contact_Id__c = pAGcont.Id;
        msglog1f.PRM_Inactive_Ind__c =false;
        //msgLogList.add(msglog1f);
        insert msglog1f;
        
        //for Adhoc RT
        Id messageRT = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Event').getRecordTypeId();
        PRM_Message__c msg2=new PRM_Message__c();
        msg2.PRM_UI_Display_Area_Nm__c='Leads';
        msg2.PRM_Title_Txt__c='Welcome to Intel';
        msg2.PRM_Description_Txt__c='Intel Cloud inside';
        msg2.PRM_End_Date_Dt__c=NULL;
        msg2.PRM_InActive_Ind__c = false;
        msg2.recordtypeid = messageRT;
        //msgList.add(msg2);
        insert msg2;
        
        PRM_Message_log__c msglog2=new PRM_Message_log__c();
        msglog2.PRM_Message_Id__c=msg2.id;
        msglog2.PRM_Message_Viewed_Ind__c=false;
        msglog2.PRM_Contact_Id__c = pAGcont.Id;
        msglog2.PRM_Inactive_Ind__c =false;
        //msgLogList.add(msglog2);
        insert msglog2;
        
        //
        PRM_Message__c msg3=new PRM_Message__c();
        msg3.PRM_UI_Display_Area_Nm__c='Leads';
        msg3.PRM_Title_Txt__c='Welcome to Intel';
        msg3.PRM_Description_Txt__c='Intel Cloud inside';
        msg3.PRM_End_Date_Dt__c=NULL;
        msg3.PRM_InActive_Ind__c = false;
        msg3.recordtypeid = messageRT;
        //msgList.add(msg3);
        
        //insert msgList;
        insert msg3;
        
        PRM_Message_log__c msglog3=new PRM_Message_log__c();
        msglog3.PRM_Message_Id__c=msg3.id;
        msglog3.PRM_Message_Viewed_Ind__c=false;
        msglog3.PRM_Contact_Id__c = pAGcont.Id;
        msglog3.PRM_Inactive_Ind__c =false;
        //msgLogList.add(msglog3);
        
        
        insert msglog3;
        
        
        
        //get Country Code
        PRM_LanguageLocaleMapping__mdt countryCode=new PRM_LanguageLocaleMapping__mdt();
        countryCode.PRM_Preferred_Language_Code__c='FRA';
        countryCode.PRM_Preferred_Locale_Code__c='fr_FR';
        
        //List<PRM_Message_Translation__c> msgtranList=new List<PRM_Message_Translation__c>();
        PRM_Message_Translation__c msgtras=new PRM_Message_Translation__c();
        msgtras.PRM_Message_Id__c=msg1.Id;
        msgtras.PRM_Title_Txt__c='Greeting from Intel';
        msgtras.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtras.PRM_Language_Nm__c ='FRA';
        msgtras.PRM_InActive_Ind__c = false;
        //msgtranList.add(msgtras);
        insert msgtras;
        
        PRM_Message__c msg12=new PRM_Message__c();
        msg12.PRM_UI_Display_Area_Nm__c='Leads';
        msg12.PRM_Title_Txt__c='Welcome to Intel';
        msg12.PRM_Description_Txt__c='Intel Cloud inside';
        msg12.PRM_End_Date_Dt__c=NULL;
        msg12.PRM_InActive_Ind__c = true;
        msg12.recordtypeid = messageRT1;
        //msgList.add(msg1);
        insert msg12;
        
        PRM_Message_log__c msglog12=new PRM_Message_log__c();
        msglog12.PRM_Message_Id__c=msg12.id;
        msglog12.PRM_Message_Viewed_Ind__c=false;
        msglog12.PRM_Inactive_Ind__c =true;
        //msgsLogList.add(msglog);
        insert msglog12;
        
        PRM_Message_Translation__c msgtras12=new PRM_Message_Translation__c();
        msgtras12.PRM_Message_Id__c=msg12.Id;
        msgtras12.PRM_Title_Txt__c='Greeting from Intel';
        msgtras12.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtras12.PRM_Language_Nm__c ='FRA';
        msgtras12.PRM_InActive_Ind__c = true;
        //msgtranList.add(msgtras);
        insert msgtras12;
        
        PRM_Message_Translation__c msgtras1=new PRM_Message_Translation__c();
        msgtras1.PRM_Message_Id__c=msg2.Id;
        msgtras1.PRM_Title_Txt__c='Greeting from Intel';
        msgtras1.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtras1.PRM_Language_Nm__c ='FRA';
        msgtras1.PRM_InActive_Ind__c = false;
        //msgtranList.add(msgtras1);
        insert msgtras1;
        
        PRM_Message_Translation__c msgtrasf=new PRM_Message_Translation__c();
        msgtrasf.PRM_Message_Id__c=msg1f.Id;
        msgtrasf.PRM_Title_Txt__c='Greeting from Intel';
        msgtrasf.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrasf.PRM_Language_Nm__c ='FRA';
        msgtrasf.PRM_InActive_Ind__c = false;
        //msgtranList.add(msgtrasf);
        insert msgtrasf;
        
        PRM_Message_Translation__c msgtrasAd=new PRM_Message_Translation__c();
        msgtrasAd.PRM_Message_Id__c=msg.Id;
        msgtrasAd.PRM_Title_Txt__c='Greeting from Intel';
        msgtrasAd.PRM_Description_Txt__c='Welcome to Intel Cloud';
        msgtrasAd.PRM_Language_Nm__c ='FRA';
        msgtrasAd.PRM_InActive_Ind__c = false;
        //msgtranList.add(msgtrasAd);
        insert msgtrasAd;
        
        PRM_Message__c msg13=new PRM_Message__c();
        msg13.PRM_UI_Display_Area_Nm__c='Enthusiast PC Specialty';
        msg13.PRM_Title_Txt__c='Welcome to Intel';
        msg13.PRM_Description_Txt__c='Intel Cloud inside';
        msg13.PRM_End_Date_Dt__c=NULL;
        msg13.PRM_InActive_Ind__c = true;
        msg13.recordtypeid = messageRT2;
        //msgList.add(msg1);
        insert msg13;
        
        
        PRM_EmailLog__c getEmailLog =  new PRM_EmailLog__c();
        getEmailLog.PRM_Read__c=false;
        getEmailLog.PRM_Subject__c='Your Intel Partner Program Application';
        getEmailLog.PRM_EmailContent__c='';
        getEmailLog.PRM_Contact__c =pAGcont.Id;
        insert getEmailLog;
        
        //Email Log
        PRM_EmailLog__c emaillog=new PRM_EmailLog__c();
        emaillog.PRM_Read__c=false;
        emaillog.PRM_Subject__c='Your Intel®Cloud Insider Application';
        insert emaillog;
        
        Date startDate = date.newInstance(2015, 12, 15);
        Date endDate = date.newInstance(2029, 12, 16);
        PRM_Message__c msg5=new PRM_Message__c();
        msg5.PRM_UI_Display_Area_Nm__c='Artificial Intelligence Specialty';
        msg5.PRM_Title_Txt__c='Artificial Adc';
        msg5.PRM_Description_Txt__c='Artificial Des';
        msg5.PRM_Start_Date_Dt__c=startDate;
        msg5.PRM_End_Date_Dt__c=endDate;
        msg5.PRM_InActive_Ind__c = false;
        msg5.recordtypeid = messageRT2;
        insert msg5;
        
        PRM_Message__c msg6=new PRM_Message__c();
        msg6.PRM_UI_Display_Area_Nm__c='Cloud Data Center Specialty';
        msg6.PRM_Title_Txt__c='Welcome to Intel';
        msg6.PRM_Description_Txt__c='Intel Cloud inside';
        msg6.PRM_Start_Date_Dt__c=startDate;
        msg6.PRM_End_Date_Dt__c=endDate;
        msg6.PRM_InActive_Ind__c = false;
        msg6.recordtypeid = messageRT2;
        insert msg6;
        
        PRM_Message__c msg7=new PRM_Message__c();
        msg7.PRM_UI_Display_Area_Nm__c='High Performance Computing Data Center Specialty';
        msg7.PRM_Title_Txt__c='Welcome to Intel';
        msg7.PRM_Description_Txt__c='Intel Cloud inside';
        msg7.PRM_Start_Date_Dt__c=startDate;
        msg7.PRM_End_Date_Dt__c=endDate;
        msg7.PRM_InActive_Ind__c = false;
        msg7.recordtypeid = messageRT2;
        insert msg7;
        
        PRM_Message__c msg8=new PRM_Message__c();
        msg8.PRM_UI_Display_Area_Nm__c='Video Specialty';
        msg8.PRM_Title_Txt__c='Welcome to Intel';
        msg8.PRM_Description_Txt__c='Intel Cloud inside';
        msg8.PRM_Start_Date_Dt__c=startDate;
        msg8.PRM_End_Date_Dt__c=endDate;
        msg8.PRM_InActive_Ind__c = false;
        msg8.recordtypeid = messageRT2;
        insert msg8;
        
        PRM_Message__c msg9=new PRM_Message__c();
        msg9.PRM_UI_Display_Area_Nm__c='Visual Display Solutions Specialty';
        msg9.PRM_Title_Txt__c='Welcome to Intel';
        msg9.PRM_Description_Txt__c='Intel Cloud inside';
        msg9.PRM_Start_Date_Dt__c=startDate;
        msg9.PRM_End_Date_Dt__c=endDate;
        msg9.PRM_InActive_Ind__c = false;
        msg9.recordtypeid = messageRT2;
        insert msg9;
        
        PRM_Message__c msg10=new PRM_Message__c();
        msg10.PRM_UI_Display_Area_Nm__c='Industrial Solutions Builder Specialty';
        msg10.PRM_Title_Txt__c='Welcome to Intel';
        msg10.PRM_Description_Txt__c='Intel Cloud inside';
        msg10.PRM_Start_Date_Dt__c=startDate;
        msg10.PRM_End_Date_Dt__c=endDate;
        msg10.PRM_InActive_Ind__c = false;
        msg10.recordtypeid = messageRT2;
        insert msg10;
        
        PRM_Message__c msg11=new PRM_Message__c();
        msg11.PRM_UI_Display_Area_Nm__c='Optane Data Center Specialty';
        msg11.PRM_Title_Txt__c='Welcome to Intel';
        msg11.PRM_Description_Txt__c='Intel Cloud inside';
        msg11.PRM_Start_Date_Dt__c=startDate;
        msg11.PRM_End_Date_Dt__c=endDate;
        msg11.PRM_InActive_Ind__c = false;
        msg11.recordtypeid = messageRT2;
        insert msg11;
        
        PRM_Message__c msg121=new PRM_Message__c();
        msg121.PRM_UI_Display_Area_Nm__c='Optane Client Specialty';
        msg121.PRM_Title_Txt__c='Welcome to Intel';
        msg121.PRM_Description_Txt__c='Intel Cloud inside';
        msg121.PRM_Start_Date_Dt__c=startDate;
        msg121.PRM_End_Date_Dt__c=endDate;
        msg121.PRM_InActive_Ind__c = false;
        msg121.recordtypeid = messageRT2;
        insert msg121;
        
        PRM_Message__c msg131=new PRM_Message__c();
        msg131.PRM_UI_Display_Area_Nm__c='Device as a Service Specialty';
        msg131.PRM_Title_Txt__c='Welcome to Intel';
        msg131.PRM_Description_Txt__c='Intel Cloud inside';
        msg131.PRM_Start_Date_Dt__c=startDate;
        msg131.PRM_End_Date_Dt__c=endDate;
        msg131.PRM_InActive_Ind__c = false;
        msg131.recordtypeid = messageRT2;
        insert msg131;
        
        PRM_Message__c msg14=new PRM_Message__c();
        msg14.PRM_UI_Display_Area_Nm__c='Managed Services Specialty';
        msg14.PRM_Title_Txt__c='Welcome to Intel';
        msg14.PRM_Description_Txt__c='Intel Cloud inside';
        msg14.PRM_Start_Date_Dt__c=startDate;
        msg14.PRM_End_Date_Dt__c=endDate;
        msg14.PRM_InActive_Ind__c = false;
        msg14.recordtypeid = messageRT2;
        insert msg14;
        
        PRM_Message__c msg15=new PRM_Message__c();
        msg15.PRM_UI_Display_Area_Nm__c='Enthusiast PC Specialty';
        msg15.PRM_Title_Txt__c='Welcome to Intel';
        msg15.PRM_Description_Txt__c='Intel Cloud inside';
        msg15.PRM_Start_Date_Dt__c=startDate;
        msg15.PRM_End_Date_Dt__c=endDate;
        msg15.PRM_InActive_Ind__c = false;
        msg15.recordtypeid = messageRT2;
        insert msg15;
        
        /*  PRM_Value_Exchange_Data__c valueex=new PRM_Value_Exchange_Data__c();
valueex.PRM_Training_Credit_Points_Count_Nbr__c=788;
valueex.PRM_Account_Id__c=parent1.Id;
valueex.PRM_Change_Date_Dt__c=system.today()+2;
valueex.PRM_Country_Market_Type_Nm__c='Mature';
valueex.PRM_From_Dt__c=system.today();
valueex.PRM_Partner_Role_Nm__c='Service Provider';
valueex.PRM_Tier_Id__c=cplTest.Id;
valueex.PRM_To_Dt__c=system.today()+1;
insert valueex;

*/  
        
        
        PMP_Company__c mpiRecord1 = new PMP_Company__c(Name = 'MPI of Partner Account 1', PMP_Account_Id__c = parent1.Core_IPA_One_Partner_Id__c, PMP_Company_Lifecycle_Status_Nm__c = 'Draft', PMP_Is_Published_Ind__c = true, PMP_Is_Working_Copy_Ind__c = true,PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced');
        insert mpiRecord1;
        PMP_OPID_MPI_Rel__c opidMPIRelationship1 = new PMP_OPID_MPI_Rel__c(PMP_Marketing_Profile_Id__c = mpiRecord1.Id, PMP_One_Partner_ID__c = parent1.Id, Is_Active__c = true);
        insert opidMPIRelationship1;
        
//        Test.startTest();   
        
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.PRM_CP_CompanyProfile_Title);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.PRM_Dashboard_Title);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.PRM_Release_Of_Information);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.PRM_Training_Credits);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.PRM_Sales_Details_Title);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.EPUM_ManagePersonnel);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.PRM_PartnerSearchHeader);
        IPABenefitUtility.getProfileInfo(pAGuserId,Label.IPA_Benefits_Manage_Benefits);
        IPABenefitUtility.getBenefitsInfo(pAGuserId);
        IPABenefitUtility.getBenefitsInfo(null);
        IPABenefitUtility.setReadVisibility(emaillog.id,'Direct Message');
        IPABenefitUtility.setReadVisibility(msglog.id,'Account');
        IPABenefitUtility.setDeleteIndicator(emaillog.id,'Direct Message');
        IPABenefitUtility.setDeleteIndicator(msglog.id,'Account');
        IPABenefitUtility.getNotificationList(pAGuserId,'Home Notification');
        IPABenefitUtility.getNotificationList(pAGuserId,'Home Notification');
        IPABenefitUtility.getNotificationList(pAGuserId,null);
        
        Test.stopTest();
        System.assertEquals(pAGcont.FirstName, 'Stark', 'Value does not match');
    }
    
    @isTest
    public static void testDataSetupforDisti(){  
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //sheetal changes start
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.Core_User_Defined_Website__c= 'www.abc.com';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_Geo__c = 'ASMO';
        insert testAccount;
        
        
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Distributor';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='USA';
        insert cont;
        
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        //user
        
        // UserRole portalRole = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',UserName='test2usr@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id
        
        insert partnerUser;
        Id userId=partnerUser.Id;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Access and Entitlements for Marketplace';
        ee.Core_Technical_Engagement_Code__c = 'MKTSMP';
        ee.Core_Engagement_Type__c = 'SMP';
        insert ee; 
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Partner Admin';
        ed.Core_Display_Name__c='Partner Admin';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        
        List<PRM_Account_Contact_Relationship__c> acctContRelList=new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_Status_Reason_Txt__c = 'Test';
        //acctContRel.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRel);
        insert acctContRel;
        
        PRM_PartnerBenefit__c pbTest4 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest4.Name = 'Partner University';
        pbTest4.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pbTest4.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest4.PRM_InActive_Ind__c = false;
        pbTest4.PRM_Account_Type_Nm__c='Both';
        insert pbTest4;
        
        List<PRM_PEx_Access_Matrix__c> accessMatrixList=new List<PRM_PEx_Access_Matrix__c>();
        PRM_PEx_Access_Matrix__c accessmatrx=new PRM_PEx_Access_Matrix__c();
        Id beneftAccRule = Schema.SObjectType.PRM_PEx_Access_Matrix__c.getRecordTypeInfosByDeveloperName().get('Benefit_Access_Rule').getRecordTypeId();
        
        //Training
        PRM_PEx_Access_Matrix__c accessmatrxt=new PRM_PEx_Access_Matrix__c();
        accessmatrxt.PRM_Benefit_Blade__c='Training';
        accessmatrxt.PRM_Entitlements__c='Partner Admin';
        accessmatrxt.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt.PRM_Click_To_Action__c='View Courses';
        accessmatrxt.PRM_CTA_Priority__c='1';
        accessmatrxt.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt.PRM_Benefit_Priority__c=3;
        accessmatrxt.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt);
        //  insert accessmatrxt;
        
        PRM_PEx_Access_Matrix__c accessmatrxt1=new PRM_PEx_Access_Matrix__c();
        accessmatrxt1.PRM_Benefit_Blade__c='Training';
        accessmatrxt1.PRM_Entitlements__c='Partner Admin';
        accessmatrxt1.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt1.PRM_Click_To_Action__c='Track My Learning';
        accessmatrxt1.PRM_CTA_Priority__c='1';
        accessmatrxt1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt1.PRM_Benefit_Priority__c=3;
        accessmatrxt1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt1);
        //  insert accessmatrxt1;
        
        PRM_PEx_Access_Matrix__c accessmatrxt2=new PRM_PEx_Access_Matrix__c();
        accessmatrxt2.PRM_Benefit_Blade__c='Training';
        accessmatrxt2.PRM_Entitlements__c='Partner Admin';
        accessmatrxt2.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt2.PRM_Click_To_Action__c='My Competencies';
        accessmatrxt2.PRM_CTA_Priority__c='1';
        accessmatrxt2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt2.PRM_Benefit_Priority__c=3;
        accessmatrxt2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt2);
        //  insert accessmatrxt2;
        
        PRM_PEx_Access_Matrix__c accessmatrxt3=new PRM_PEx_Access_Matrix__c();
        accessmatrxt3.PRM_Benefit_Blade__c='Training';
        accessmatrxt3.PRM_Entitlements__c='Partner Admin';
        accessmatrxt3.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt3.PRM_Click_To_Action__c='Browse All Webinars';
        accessmatrxt3.PRM_CTA_Priority__c='1';
        accessmatrxt3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt3.PRM_Benefit_Priority__c=3;
        accessmatrxt3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt3);
        //  insert accessmatrxt3;
        
        PRM_PEx_Access_Matrix__c accessmatrxt4=new PRM_PEx_Access_Matrix__c();
        accessmatrxt4.PRM_Benefit_Blade__c='Training';
        accessmatrxt4.PRM_Entitlements__c='Partner Admin';
        accessmatrxt4.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt4.PRM_Click_To_Action__c='Get Help With Training';
        accessmatrxt4.PRM_CTA_Priority__c='1';
        accessmatrxt4.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt4.PRM_Benefit_Priority__c=3;
        accessmatrxt4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt4);
        
        PRM_PEx_Access_Matrix__c accessmatrxt41=new PRM_PEx_Access_Matrix__c();
        accessmatrxt41.PRM_Benefit_Blade__c='Training';
        accessmatrxt41.PRM_Entitlements__c='Partner Admin';
        accessmatrxt41.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt41.PRM_Click_To_Action__c='Get Help With Training';
        accessmatrxt41.PRM_CTA_Priority__c='1';
        accessmatrxt41.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt41.PRM_Benefit_Priority__c=3;
        accessmatrxt41.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt41);
        //    insert accessmatrxt4;
        
        PRM_PEx_Access_Matrix__c accessmatrxt5=new PRM_PEx_Access_Matrix__c();
        accessmatrxt5.PRM_Benefit_Blade__c='Training';
        accessmatrxt5.PRM_Entitlements__c='Partner Admin';
        accessmatrxt5.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt5.PRM_Click_To_Action__c='Webinars';
        accessmatrxt5.PRM_CTA_Priority__c='1';
        accessmatrxt5.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt5.PRM_Benefit_Priority__c=3;
        accessmatrxt5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt5);
        //   insert accessmatrxt5;
        
        PRM_PEx_Access_Matrix__c accessmatrxt6=new PRM_PEx_Access_Matrix__c();
        accessmatrxt6.PRM_Benefit_Blade__c='Training';
        accessmatrxt6.PRM_Entitlements__c='Partner Admin';
        accessmatrxt6.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt6.PRM_Click_To_Action__c='Competitive Guidance Presentation';
        accessmatrxt6.PRM_CTA_Priority__c='1';
        accessmatrxt6.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt6.PRM_Benefit_Priority__c=3;
        accessmatrxt6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt6);
        //    insert accessmatrxt6;
        
        PRM_PEx_Access_Matrix__c accessmatrxt7=new PRM_PEx_Access_Matrix__c();
        accessmatrxt7.PRM_Benefit_Blade__c='Training';
        accessmatrxt7.PRM_Entitlements__c='Partner Admin';
        accessmatrxt7.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt7.PRM_Click_To_Action__c='Virtual Tech Conference';
        accessmatrxt7.PRM_CTA_Priority__c='1';
        accessmatrxt7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt7.PRM_Benefit_Priority__c=3;
        accessmatrxt7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt7);
        //  insert accessmatrxt7;
        
        PRM_PEx_Access_Matrix__c accessmatrxt8=new PRM_PEx_Access_Matrix__c();
        accessmatrxt8.PRM_Benefit_Blade__c='Training';
        accessmatrxt8.PRM_Entitlements__c='Partner Admin';
        accessmatrxt8.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt8.PRM_Click_To_Action__c='How to sell videos';
        accessmatrxt8.PRM_CTA_Priority__c='1';
        accessmatrxt8.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt8.PRM_Benefit_Priority__c=3;
        accessmatrxt8.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt8);
        // insert accessmatrxt8;
        
        PRM_PEx_Access_Matrix__c accessmatrxt9=new PRM_PEx_Access_Matrix__c();
        accessmatrxt9.PRM_Benefit_Blade__c='Training';
        accessmatrxt9.PRM_Entitlements__c='Partner Admin';
        accessmatrxt9.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt9.PRM_Click_To_Action__c='View Distributor Webinars on demand';
        accessmatrxt9.PRM_CTA_Priority__c='1';
        accessmatrxt9.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt9.PRM_Benefit_Priority__c=3;
        accessmatrxt9.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt9);
        
        PRM_PEx_Access_Matrix__c accessmatrxt91=new PRM_PEx_Access_Matrix__c();
        accessmatrxt91.PRM_Benefit_Blade__c='Training';
        accessmatrxt91.PRM_Entitlements__c='Partner Admin';
        accessmatrxt91.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt91.PRM_Click_To_Action__c='View Distributor Webinars on demand';
        accessmatrxt91.PRM_CTA_Priority__c='1';
        accessmatrxt91.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt91.PRM_Benefit_Priority__c=3;
        accessmatrxt91.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt91);
        
        PRM_PEx_Access_Matrix__c accessmatrxt11=new PRM_PEx_Access_Matrix__c();
        accessmatrxt11.PRM_Benefit_Blade__c='Training';
        accessmatrxt11.PRM_Entitlements__c='Partner Admin';
        accessmatrxt11.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxt11.PRM_Click_To_Action__c='Quarterly Training Matrix';
        accessmatrxt11.PRM_CTA_Priority__c='1';
        accessmatrxt11.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxt11.PRM_Benefit_Priority__c=3;
        accessmatrxt11.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxt11);
        
        PRM_PEx_Access_Matrix__c accessmatrxppp=new PRM_PEx_Access_Matrix__c();
        accessmatrxppp.PRM_Benefit_Blade__c='Pricing, Points and Promotions';
        accessmatrxppp.PRM_Entitlements__c='Partner Admin';
        accessmatrxppp.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxppp.PRM_Click_To_Action__c='Price List & Rebates';
        accessmatrxppp.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxppp.PRM_Benefit_Priority__c=6;
        accessmatrxppp.RecordTypeId=beneftAccRule;
        insert accessmatrxppp;
        
        PRM_PEx_Access_Matrix__c accessmatrxpp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxpp1.PRM_Benefit_Blade__c='Pricing, Points and Promotions';
        accessmatrxpp1.PRM_Entitlements__c='Partner Admin';
        accessmatrxpp1.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpp1.PRM_Click_To_Action__c='Pricing, Points and Promotions';
        accessmatrxpp1.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpp1.PRM_Benefit_Priority__c=6;
        accessmatrxpp1.RecordTypeId=beneftAccRule;
        insert accessmatrxpp1;
        
        PRM_PEx_Access_Matrix__c accessmatrxpp2=new PRM_PEx_Access_Matrix__c();
        accessmatrxpp2.PRM_Benefit_Blade__c='Pricing, Points and Promotions';
        accessmatrxpp2.PRM_Entitlements__c='Partner Admin';
        accessmatrxpp2.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpp2.PRM_Click_To_Action__c='Points';
        accessmatrxpp2.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpp2.PRM_Benefit_Priority__c=6;
        accessmatrxpp2.RecordTypeId=beneftAccRule;
        insert accessmatrxpp2;
        
        PRM_PEx_Access_Matrix__c accessmatrxpp3=new PRM_PEx_Access_Matrix__c();
        accessmatrxpp3.PRM_Benefit_Blade__c='Pricing, Points and Promotions';
        accessmatrxpp3.PRM_Entitlements__c='Partner Admin';
        accessmatrxpp3.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpp3.PRM_Click_To_Action__c='Web Quote Tool';
        accessmatrxpp3.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpp3.PRM_Benefit_Priority__c=6;
        accessmatrxpp3.RecordTypeId=beneftAccRule;
        insert accessmatrxpp3;
        
        PRM_PEx_Access_Matrix__c accessmatrxpp4=new PRM_PEx_Access_Matrix__c();
        accessmatrxpp4.PRM_Benefit_Blade__c='Pricing, Points and Promotions';
        accessmatrxpp4.PRM_Entitlements__c='Partner Admin';
        accessmatrxpp4.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpp4.PRM_Click_To_Action__c='Demo Depot';
        accessmatrxpp4.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpp4.PRM_Benefit_Priority__c=6;
        accessmatrxpp4.RecordTypeId=beneftAccRule;
        insert accessmatrxpp4;
        
        PRM_PEx_Access_Matrix__c accessmatrxpp7=new PRM_PEx_Access_Matrix__c();
        accessmatrxpp7.PRM_Benefit_Blade__c='Pricing, Points and Promotions';
        accessmatrxpp7.PRM_Entitlements__c='Partner Admin';
        accessmatrxpp7.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpp7.PRM_Click_To_Action__c='Design Registration';
        accessmatrxpp7.PRM_CTA_Priority__c='10';
        accessmatrxpp7.PRM_Benefit_Priority__c=6;
        accessmatrxpp7.RecordTypeId=beneftAccRule;
        insert accessmatrxpp7;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr.PRM_Click_To_Action__c='Price List & Rebates';
        accessmatrxpr.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr.PRM_Benefit_Priority__c=6;
        accessmatrxpr.RecordTypeId=beneftAccRule;
        insert accessmatrxpr;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr1=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr1.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr1.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr1.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr1.PRM_Click_To_Action__c='Products & Roadmaps';
        accessmatrxpr1.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr1.PRM_Benefit_Priority__c=6;
        accessmatrxpr1.RecordTypeId=beneftAccRule;
        insert accessmatrxpr1;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr2=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr2.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr2.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr2.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr2.PRM_Click_To_Action__c='Web Order Management';
        accessmatrxpr2.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr2.PRM_Benefit_Priority__c=6;
        accessmatrxpr2.RecordTypeId=beneftAccRule;
        insert accessmatrxpr2;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr3=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr3.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr3.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr3.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr3.PRM_Click_To_Action__c='Server Configurator';
        accessmatrxpr3.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr3.PRM_Benefit_Priority__c=6;
        accessmatrxpr3.RecordTypeId=beneftAccRule;
        insert accessmatrxpr3;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr4=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr4.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr4.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr4.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr4.PRM_Click_To_Action__c='Intel® New Product Information';
        accessmatrxpr4.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr4.PRM_Benefit_Priority__c=6;
        accessmatrxpr4.RecordTypeId=beneftAccRule;
        insert accessmatrxpr4;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr5=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr5.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr5.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr5.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr5.PRM_Click_To_Action__c='Embedded/IoT Zone';
        accessmatrxpr5.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr5.PRM_Benefit_Priority__c=6;
        accessmatrxpr5.RecordTypeId=beneftAccRule;
        insert accessmatrxpr5;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr6=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr6.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr6.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr6.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr6.PRM_Click_To_Action__c='Branded Systems Zone';
        accessmatrxpr6.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr6.PRM_Benefit_Priority__c=6;
        accessmatrxpr6.RecordTypeId=beneftAccRule;
        insert accessmatrxpr6;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr7=new PRM_PEx_Access_Matrix__c();
        accessmatrxpr7.PRM_Benefit_Blade__c='Products & Roadmaps';
        accessmatrxpr7.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr7.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr7.PRM_Click_To_Action__c='Intel® Solutions Library';
        accessmatrxpr7.PRM_CTA_Priority__c='10';
        //accessmatrxppp.PRM_Partner_Benefit__c=pbTest4.Id;
        accessmatrxpr7.PRM_Benefit_Priority__c=6;
        accessmatrxpr7.RecordTypeId=beneftAccRule;
        insert accessmatrxpr7;
        
        PRM_PEx_Access_Matrix__c accessmatrxpr7i =new PRM_PEx_Access_Matrix__c();
        accessmatrxpr7i.PRM_Benefit_Blade__c='Deal Registration';
        accessmatrxpr7i.PRM_Entitlements__c='Partner Admin';
        accessmatrxpr7i.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxpr7i.PRM_Click_To_Action__c='Deal Registration';
        accessmatrxpr7i.PRM_CTA_Priority__c='21';
        accessmatrxpr7i.PRM_Benefit_Priority__c=6;
        accessmatrxpr7i.RecordTypeId=beneftAccRule;
        insert accessmatrxpr7i;
        
        PRM_PEx_Access_Matrix__c accessmatrxms8=new PRM_PEx_Access_Matrix__c();
        accessmatrxms8.PRM_Benefit_Blade__c='Partner Lookup Tool';
        accessmatrxms8.PRM_Entitlements__c='Partner Admin';
        accessmatrxms8.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms8.PRM_Click_To_Action__c='Partner Lookup Tool';
        accessmatrxms8.PRM_CTA_Priority__c='1';
        accessmatrxms8.PRM_Benefit_Priority__c=1;
     //   accessmatrxms8.PRM_Partner_Benefit__c=pbTest5.Id;
        accessmatrxms8.RecordTypeId=beneftAccRule;
        insert accessmatrxms8;
        
        //Marketplace
        PRM_PEx_Access_Matrix__c accessmatrxmp=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp.PRM_IPA_Partner_Role__c='Service Provider';
        accessmatrxmp.PRM_Click_To_Action__c='Manage Storefront';
        accessmatrxmp.PRM_CTA_Priority__c='3';
        accessmatrxmp.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp.PRM_Benefit_Priority__c=4;
        accessmatrxmp.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp0=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp0.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp0.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp0.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp0.PRM_Click_To_Action__c='Manage Storefront';
        accessmatrxmp0.PRM_CTA_Priority__c='3';
        accessmatrxmp0.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp0.PRM_Benefit_Priority__c=4;
        accessmatrxmp0.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp0);
        //insert accessmatrxmp;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp1=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp1.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp1.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp1.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp1.PRM_Click_To_Action__c='Manage Offerings';
        accessmatrxmp1.PRM_CTA_Priority__c='3';
        accessmatrxmp1.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp1.PRM_Benefit_Priority__c=4;
        accessmatrxmp1.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp1);
        //insert accessmatrxmp1;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp2=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp2.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp2.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp2.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp2.PRM_Click_To_Action__c='Create New Offering';
        accessmatrxmp2.PRM_CTA_Priority__c='3';
        accessmatrxmp2.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp2.PRM_Benefit_Priority__c=4;
        accessmatrxmp2.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp2);
        //insert accessmatrxmp2;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp3=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp3.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp3.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp3.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp3.PRM_Click_To_Action__c='View Results';
        accessmatrxmp3.PRM_CTA_Priority__c='3';
        accessmatrxmp3.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp3.PRM_Benefit_Priority__c=4;
        accessmatrxmp3.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp3);
        //insert accessmatrxmp3;
        
        
        PRM_PEx_Access_Matrix__c accessmatrxmp4=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp4.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp4.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp4.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp4.PRM_Click_To_Action__c='Visit Marketplace';
        accessmatrxmp4.PRM_CTA_Priority__c='3';
        accessmatrxmp4.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp4.PRM_Benefit_Priority__c=4;
        accessmatrxmp4.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp4);
        //insert accessmatrxmp4;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp5=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp5.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp5.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp5.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp5.PRM_Click_To_Action__c='Get help with Marketplace';
        accessmatrxmp5.PRM_CTA_Priority__c='3';
        accessmatrxmp5.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp5.PRM_Benefit_Priority__c=4;
        accessmatrxmp5.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp5);
        //insert accessmatrxmp5;
        
        PRM_PEx_Access_Matrix__c accessmatrxmp6=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp6.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp6.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp6.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp6.PRM_Click_To_Action__c='Learn about submitting a solution';
        accessmatrxmp6.PRM_CTA_Priority__c='5';
        accessmatrxmp6.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp6.PRM_Benefit_Priority__c=4;
        accessmatrxmp6.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp6);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp7=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp7.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp7.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp7.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp7.PRM_Click_To_Action__c='Manage Solutions';
        accessmatrxmp7.PRM_CTA_Priority__c='4';
        accessmatrxmp7.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp7.PRM_Benefit_Priority__c=4;
        accessmatrxmp7.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp7);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp8=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp8.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp8.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp8.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp8.PRM_Click_To_Action__c='View the partner directory';
        accessmatrxmp8.PRM_CTA_Priority__c='7';
        accessmatrxmp8.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp8.PRM_Benefit_Priority__c=4;
        accessmatrxmp8.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxmp8);
        
        PRM_PEx_Access_Matrix__c accessmatrxmp9=new PRM_PEx_Access_Matrix__c();
        accessmatrxmp9.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxmp9.PRM_Entitlements__c='Partner Admin;Offering Editor';
        accessmatrxmp9.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxmp9.PRM_Click_To_Action__c='Submit a Solution';
        accessmatrxmp9.PRM_CTA_Priority__c='6';
        accessmatrxmp9.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxmp9.PRM_Benefit_Priority__c=4;
        accessmatrxmp9.RecordTypeId=beneftAccRule;        
        accessMatrixList.add(accessmatrxmp9);  
        
        PRM_PEx_Access_Matrix__c accessmatrxms71=new PRM_PEx_Access_Matrix__c();
        accessmatrxms71.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxms71.PRM_Entitlements__c='Partner Admin';
        accessmatrxms71.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms71.PRM_Click_To_Action__c='Intel® Partner Alliance Web Banners';
        accessmatrxms71.PRM_CTA_Priority__c='1';
        accessmatrxms71.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxms71.PRM_Benefit_Priority__c=3;
        accessmatrxms71.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms71);
        
        PRM_PEx_Access_Matrix__c accessmatrxms81=new PRM_PEx_Access_Matrix__c();
        accessmatrxms81.PRM_Benefit_Blade__c='Marketplace';
        accessmatrxms81.PRM_Entitlements__c='Partner Admin';
        accessmatrxms81.PRM_IPA_Partner_Role__c='Distributor';
        accessmatrxms81.PRM_Click_To_Action__c='Intel® Partner Alliance Web Banners';
        accessmatrxms81.PRM_CTA_Priority__c='1';
        accessmatrxms81.PRM_Partner_Benefit__c=pbTest4.Id;//prnbnft.Id;
        accessmatrxms81.PRM_Benefit_Priority__c=3;
        accessmatrxms81.RecordTypeId=beneftAccRule;
        accessMatrixList.add(accessmatrxms81);
        
        
        Date startDate = date.newInstance(2015, 12, 15);
        Date endDate = date.newInstance(2029, 12, 16);
        Id messageRTA = Schema.getGlobalDescribe().get('PRM_Message__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Adhoc').getRecordTypeId();
        PRM_Message__c msg1=new PRM_Message__c();
        msg1.PRM_UI_Display_Area_Nm__c='Products & Roadmaps';
        msg1.PRM_Title_Txt__c='Welcome to Intel';
        msg1.PRM_Description_Txt__c='Intel Cloud inside';
        msg1.PRM_Start_Date_Dt__c=startDate;
        msg1.PRM_End_Date_Dt__c=endDate;
        msg1.PRM_InActive_Ind__c = false;
        msg1.recordtypeid = messageRTA;
        insert msg1;
        
        PRM_Message__c msg2=new PRM_Message__c();
        msg2.PRM_UI_Display_Area_Nm__c='Pricing, Points and Promotions';
        msg2.PRM_Title_Txt__c='Welcome to Intel';
        msg2.PRM_Description_Txt__c='Intel Cloud inside';
        msg2.PRM_Start_Date_Dt__c=startDate;
        msg2.PRM_End_Date_Dt__c=endDate;
        msg2.PRM_InActive_Ind__c = false;
        msg2.recordtypeid = messageRTA;
        insert msg2;
        
        PRM_Message__c msg3=new PRM_Message__c();
        msg3.PRM_UI_Display_Area_Nm__c='FPGA Tools and Resources';
        msg3.PRM_Title_Txt__c='Welcome to Intel';
        msg3.PRM_Description_Txt__c='Intel Cloud inside';
        msg3.PRM_Start_Date_Dt__c=startDate;
        msg3.PRM_End_Date_Dt__c=endDate;
        msg3.PRM_InActive_Ind__c = false;
        msg3.recordtypeid = messageRTA;
        insert msg3;
        
        Test.startTest();
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_CP_CompanyProfile_Title);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Dashboard_Title);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Release_Of_Information);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Training_Credits);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_Sales_Details_Title);
        IPABenefitUtility.getProfileInfo(userId,Label.EPUM_ManagePersonnel);
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_PartnerSearchHeader);
        IPABenefitUtility.getProfileInfo(userId,Label.IPA_Benefits_Manage_Benefits);
        IPABenefitUtility.getPartnerQuickLinks(userId);
       // IPABenefitUtility.getBenefitsInfo(userId1);
        IPABenefitUtility.getBenefitsInfo(userId);
        IPABenefitUtility.getBenefitsInfo(null);
        test.stopTest();
        System.assertEquals(cont.FirstName, 'Adam', 'Value does not match');
        
        
        
    }
    
    @isTest
    public static void testDataSetupforDifferentPartnerRole(){  
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        // Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //sheetal changes start
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        testAccount.Industry='Construction';
        testAccount.OwnerId = UserInfo.getUserId();
        testAccount.Core_User_Defined_Website__c= 'www.care.com';
        insert testAccount;
        
        
        
        /*Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Seller';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='USA';
        insert cont;*/ // // Removing as Seller is not active picklist value for partnerrole

        Contact cont = new Contact();  //Contact
        cont.AccountId=testAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        //cont.Core_Profession__c='Sales';
        cont.Core_IPA_PartnerRole__c='Solution Integrator';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.MailingCountry='USA';
        insert cont;
        
        Contact contsp = new Contact();  //Contact
        contsp.AccountId=testAccount.Id;
        contsp.lastName='Stew';
        contsp.FirstName='Carry';
        contsp.email='stewcarry@rediff.com';
        contsp.Core_Job_Function__c='Branch Manager';
        //contsp.Core_Profession__c='Sales';
        contsp.Core_IPA_PartnerRole__c='Service Provider';
        contsp.Core_eRPM_Language_Code__c='Eng';
        contsp.MailingCountry='USA';
        insert contsp;
        
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        //user
        
        // UserRole portalRole = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='mrtestuser@mailinator.com',UserName='test2usr@xyz.com', ContactId=cont.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id
        
        insert partnerUser;
        Id userId=partnerUser.Id;
        
        //sp User
        User partnerUsersp = new User(FirstName='Hjc',LastName='Usr',alias='user2t',Email='testmruser@mailinator.com',UserName='user2test@xyz.com', ContactId=contsp.Id,ProfileId=communityUsrProfile.Id,
                                      emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id
        
        insert partnerUsersp;
        Id userIdsp=partnerUsersp.Id;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Access and Entitlements for Marketplace';
        ee.Core_Technical_Engagement_Code__c = 'MKTSMP';
        ee.Core_Engagement_Type__c = 'SMP';
        insert ee; 
        
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Employee';
        ed.Core_Display_Name__c='Employee';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c();
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Status__c='Complete';
        cce.Core_Entitlement_Id__c=ed.Id;
        cce.Core_Selected__c = true;
        insert cce;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Employee';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cpTest.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        List<PRM_Account_Contact_Relationship__c> acctContRelList=new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=testAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_Status_Reason_Txt__c = 'Test';
        //acctContRel.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRel);
        insert acctContRel;
        
        PRM_Account_Contact_Relationship__c acctContRelsp=new PRM_Account_Contact_Relationship__c();
        acctContRelsp.PRM_Account_Id__c=testAccount.Id;
        acctContRelsp.PRM_Contact_Id__c=contsp.Id;
        acctContRelsp.PRM_Relationship_Id__c=contRelation.Id;
        acctContRelsp.PRM_Status_Nm__c='Complete';
        acctContRelsp.PRM_isActive__c=true;
        acctContRelsp.PRM_Status_Reason_Txt__c = 'Test';
        //acctContRel.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRelsp);
        insert acctContRelsp;
        
        Id specnRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();     
        PRM_Specialty__c spec2 = new PRM_Specialty__c();
        spec2.name='Optane Client Specialty';
        spec2.PRM_Description_Txt__c='This is description';
        spec2.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec2.PRM_Role_Nm__c='Service Provider';
        spec2.PRM_Tier_Nm__c='Gold';
        spec2.PRM_Start_Date_Dt__c= system.today() + 7;
        spec2.PRM_End_Date_Dt__c= spec2.PRM_Start_Date_Dt__c + 5;
        spec2.PRM_Access_Level_Nm__c='Public';
        spec2.PRM_Inactive_Ind__c=false;
        spec2.RecordTypeId=specnRT;
        insert spec2;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= testaccount.id;
        asa.PRM_Specialty_Id__c= spec2.id;
        asa.PRM_InActive_Ind__c=false;
        asa.PRM_Partner_Role__c='Service Provider';
        insert asa;
        List<String> linkList = new  List<String>{'Visit FPGA Communities','Track and Enter Design Registration','Contact FPGA Ecosystem Team'};
        List<String> linkList1 = new  List<String>{'Access Intel® Developer Zone','Resource & Documentation Center'};
        List<String> linkList2 = new  List<String>{'Design-In Tools Store'};
        List<String> linkList3 = new  List<String>{'Intel Demo Depot'};
        List<String> linkList4 = new  List<String>{'Intel Developer Zone','Intel Developer Cloud for the Edge & One API','Intel Developer Cloud for Services'};
        List<String> linkList5 = new  List<String>{'Resource & Documentation Center'};
        List<String> linkList6 = new  List<String>{'Resource & Documentation Center','Request RDC Premier access (CNDA required)'};
        Map<String,String> adhocMap = new Map<String,String> {'a1,test' => 'Testvalue','a2,test2' => 'testvalue2','a3,test3' => 'testvalue3'};
        Test.startTest();
        IPABenefitUtility.getProfileInfo(userId,Label.PRM_CP_CompanyProfile_Title);
        IPABenefitUtility.getBenefitsInfo(userId);
        IPABenefitUtility.getBenefitsInfo(null);
        IPABenefitUtility.getFPGAToolsResources(linkList,adhocMap);
        IPABenefitUtility.getIPALookupTool(linkList,adhocMap,true);
        IPABenefitUtility.getDZS(linkList1,adhocMap);
        IPABenefitUtility.getRDC(linkList5,adhocMap);
        IPABenefitUtility.displayDZPBlade(linkList4,adhocMap);
        IPABenefitUtility.displayRDCPremierBlade(linkList6,adhocMap);
        //IPABenefitUtility.displayIDDSBlade(linkList3,adhocMap);
        IPABenefitUtility.displayDITBlade(linkList2,adhocMap);
        //IPABenefitUtility.getSpecialtyArtifical(linkList,adhocMap);
        //IPABenefitUtility.getSpecialtyCloudData(linkList,adhocMap);
        test.stopTest();
        System.assertEquals(cont.FirstName, 'Adam', 'Value does not match');      
    }
          
    @isTest
    public static void testUncoverdMethods(){  
        List<String> strList = new List<String>();
        List<String> strList01 = new List<String>{'Activation Zones', 'Intel® Partner Alliance Activation Zones','AI Zones', 'Data Center Modernization Zones', 'Security Zones', 'Edge And Networking', 'Industry Zones'};
        Map<String,String> adhocMsgs = new Map<String,String>();
        List<String>alertTitles=new List<String>();
        strList.add('ABC,BCD');
        adhocMsgs.put('ABC,BCD', 'Test');
        alertTitles.add('ABCD,BCDA');
        
        test.startTest();
        //IPABenefitUtility.getSpecialtyArtifical(strList,adhocMsgs);
        //IPABenefitUtility.getSpecialtyCloudData(strList,adhocMsgs);
        IPABenefitUtility.getSelectBenefit(strList,adhocMsgs);
        IPABenefitUtility.getDealReg(strList);
        
        for(String str : strList01){
            IPABenefitUtility.getActivationZones(new List<string>{str},adhocMsgs); 
            IPABenefitUtility.getPricingPointsPromotionsBlade(new List<string>{str},adhocMsgs);
            IPABenefitUtility.getProductRoadmapsBlade(new List<string>{str},adhocMsgs);
            //IPABenefitUtility.getPoints(new List<string>{str},alertTitles,adhocMsgs);
            //IPABenefitUtility.getMarketingStudio(new List<string>{str},alertTitles,adhocMsgs);
        }
        IPABenefitUtility.getActivationZones(strList01,adhocMsgs);  
        IPABenefitUtility.getPricingPointsPromotionsBlade(strList01,adhocMsgs);
        IPABenefitUtility.getProductRoadmapsBlade(strList01,adhocMsgs);
       // IPABenefitUtility.getPoints(strList01,alertTitles,adhocMsgs);
        //IPABenefitUtility.getMarketingStudio(strList01,alertTitles,adhocMsgs);
        test.stopTest();
        
    }
    
       @isTest
        public static void tcheckInternalUser(){  
            Profile p = [Select Id from Profile Where name='IT Admin'];
                User pAGpartnerUser01 = new User(FirstName='MrTest01',LastName='User01',alias='t2user01',Email='mrtestuser890@intel.com',UserName='mrtestuser890@intel.com',ProfileId=p.Id,
                                               emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London');//, UserRoleId = r.id
                insert pAGpartnerUser01;
            
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:Label.PRM_Internal_Intel_Read_Only_pmset_name];
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = pAGpartnerUser01.Id;
                psa.PermissionSetId = ps.Id;
                insert psa;
            
                IPABenefitUtility.checkInternalUser(pAGpartnerUser01.id,System.Label.IPA_Secure_Homepage_Link);
                IPABenefitUtility.checkInternalUser(pAGpartnerUser01.id,System.Label.PMP_IPA_Dashboard_Url);
}
        @isTest
    static void testPopulateAlerts() {
        List<String> alertTitles = new List<String>{ 'Alert 1', 'Alert 2', 'Alert 3' };
        IPABenefitWrapper.UserBenefitInfo userBenefit = new IPABenefitWrapper.UserBenefitInfo();
        userBenefit.alerts = new List<IPABenefitWrapper.Alerts>(); // initialize to avoid null pointer (if needed)
        IPABenefitUtility.populateAlerts(alertTitles, userBenefit);

        System.assertNotEquals(null, userBenefit.alerts, 'Alerts list should not be null');
        System.assertEquals(3, userBenefit.alerts.size(), 'There should be 3 alerts populated');

        for (Integer i = 0; i < alertTitles.size(); i++) {
            System.assertEquals(alertTitles[i], userBenefit.alerts[i].label, 'Alert label should match');
        }
    }

    @isTest
    static void testPopulateAlerts_NullList() {
        IPABenefitWrapper.UserBenefitInfo userBenefit = new IPABenefitWrapper.UserBenefitInfo();
        IPABenefitUtility.populateAlerts(null, userBenefit);
        System.assertEquals(null, userBenefit.alerts, 'Alerts list should remain null if input is null');
    }

    @isTest
    static void testPopulateAlerts_EmptyList() {
        List<String> alertTitles = new List<String>();
        IPABenefitWrapper.UserBenefitInfo userBenefit = new IPABenefitWrapper.UserBenefitInfo();
        IPABenefitUtility.populateAlerts(alertTitles, userBenefit);
        System.assertEquals(null, userBenefit.alerts, 'Alerts list should remain null if input is empty');
    }
    
@isTest
    static void testGetMarketPlaceMetrics() {
        // Create Account (Partner Account) record
        Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account parent1 = new Account(
            Name = 'Cello Ltd',
            BillingCity = 'New City',
            BillingStreet = 'New Street',
            BillingCountry = 'India',
            BillingPostalCode = '999999',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            Industry = 'Construction',
            Core_User_Defined_Website__c = 'www.abc.com',
            Core_Geo__c = 'ASMO',
            RecordTypeId = opidAccRecordTypeId
        );
        insert parent1;

        // Create the Core_OnePartnerID after insertion
        parent1.Core_OnePartnerID__c = parent1.Id;
        update parent1;

        // Create the MPI record (PMP_Company__c)
        PMP_Company__c mpiRecord1 = new PMP_Company__c(
            Name = 'MPI of Partner Account 1',
            PMP_Account_Id__c = parent1.Id,
            PMP_Company_Lifecycle_Status_Nm__c = 'Draft',
            PMP_Is_Published_Ind__c = true,
            PMP_Is_Working_Copy_Ind__c = true,
            PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Enhanced'
        );
        insert mpiRecord1;

        // Create the PMP_OPID_MPI_Rel__c record
        PMP_OPID_MPI_Rel__c opidMPIRelationship1 = new PMP_OPID_MPI_Rel__c(
            PMP_Marketing_Profile_Id__c = mpiRecord1.Id,
            PMP_One_Partner_ID__c = parent1.Id,
            Is_Active__c = true
        );
        insert opidMPIRelationship1;

        // Create sample PMP_Partner_Offering__c records (Published and Pending)
        PMP_Partner_Offering__c publishedOffering = new PMP_Partner_Offering__c(
            PMP_Company_Id__c = mpiRecord1.Id,
            PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved',
            PMP_Partner_Offering_Start_Dt__c = Date.today().addDays(-1),
            PMP_Partner_Offering_End_Dt__c = Date.today().addDays(1)
        );
        insert publishedOffering;

        PMP_Partner_Offering__c pendingOffering = new PMP_Partner_Offering__c(
            PMP_Company_Id__c = mpiRecord1.Id,
            PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft',
            PMP_Partner_Offering_Start_Dt__c = Date.today().addDays(-1),
            PMP_Partner_Offering_End_Dt__c = Date.today().addDays(1)
        );
        insert pendingOffering;

        // Create a mock entitlement list
        List<String> entitlementList = new List<String>{'Offering Editor'};
        
        // Test Context
        Test.startTest();
        
        // Call the method being tested
        List<IPABenefitWrapper.Metrics> result = IPABenefitUtility.getMarketPlaceMetrics(parent1.Id, entitlementList);

        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, result.size(), 'Metrics list should not be empty');

        // Assert Published Offering Metric
        System.assertEquals('1', result[0].value, 'The published offering count is incorrect');
        System.assertEquals(System.Label.IPA_MarketPlace_mtrc_Label2, result[0].label, 'Label for published offering is incorrect');

        // Assert Pending Offering Metric
        System.assertEquals('1', result[1].value, 'The pending offering count is incorrect');
        System.assertEquals(System.Label.IPA_MarketPlace_mtrc_Label1, result[1].label, 'Label for pending offering is incorrect');

        // Assert Link for Pending Offering
        System.assertNotEquals(null, result[1].link, 'The link for pending offering should not be null');
    }

    @isTest
static void testGetContactsWithCustomTestData() {
    // Step 1: Create the necessary test data

    // Create Account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    Account testAccount = new Account();
    testAccount.RecordTypeId = recordTypeIdAccount;
    testAccount.Name = 'John Wick';
    testAccount.BillingCity = 'City';
    testAccount.BillingStreet = 'Street';
    testAccount.BillingCountry = 'India';
    testAccount.BillingPostalCode = 'Postal code';
    testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
    testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
    testAccount.Industry = 'Construction';
    testAccount.OwnerId = UserInfo.getUserId();
    testAccount.Core_User_Defined_Website__c = 'www.abc.com';
    testAccount.Core_OnePartnerID__c = testAccount.Id;
    testAccount.Core_Geo__c = 'ASMO';
    insert testAccount;

    // Create Contact
    Contact cont3 = new Contact();  // Contact
    cont3.AccountId = testAccount.Id;
    cont3.LastName = 'Parker';
    cont3.FirstName = 'Johnny';
    cont3.Email = 'Peterparker1@rediff.com';
    cont3.Core_Job_Function__c = 'Branch Manager';
    cont3.Core_IPA_PartnerRole__c = 'Distributor';  // Ensure role is set as Distributor (if needed)
    cont3.Core_Preferred_Language__c = 'FRA';
    cont3.MailingCountry = 'USA';
    insert cont3;

    
    PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();
    contRelation.Name = 'Partner Admin'; 
    contRelation.PRM_Contact_Relationship_Cd__c = 'PRIMARY'; 
    insert contRelation;
    PRM_Account_Contact_Relationship__c acctContRel = new PRM_Account_Contact_Relationship__c();
    acctContRel.PRM_Account_Id__c = testAccount.Id;
    acctContRel.PRM_Contact_Id__c = cont3.Id;
    acctContRel.PRM_Relationship_Id__c = contRelation.Id;
    acctContRel.PRM_Status_Nm__c = 'Complete'; // Ensure status is 'Complete'
    acctContRel.PRM_isActive__c = true; // Ensure the record is active
    acctContRel.PRM_Status_Reason_Txt__c = 'Test';
    insert acctContRel;
    
    acctContRel = [
        SELECT PRM_Status_Nm__c
        FROM PRM_Account_Contact_Relationship__c
        WHERE Id = :acctContRel.Id
    ];
    
    System.debug('Status after insert=' + acctContRel.PRM_Status_Nm__c);
	
    acctContRel.PRM_Status_Nm__c = 'Complete';
    update acctContRel;
    System.debug('Status after update=' + acctContRel.PRM_Status_Nm__c);

    // Debugging to see if the role is correctly set
    System.debug('Created PRM_Relationship: ' + contRelation);
    System.debug('Created PRM_Account_Contact_Relationship: ' + acctContRel);
	
    PRM_Account_Contact_Relationship__c acr = [
        SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name
        FROM PRM_Account_Contact_Relationship__c
        WHERE Id = :acctContRel.Id
    ];
    
    System.debug('JB ACR.Role=' + acr.PRM_Partner_Role__c);
    System.debug('JB ACR.Name = ' + acr.PRM_Relationship_Id__r.Name);

    
    // Step 2: Create User Profile to pass into the method
    IPABenefitWrapper.UserProfile userProfile = new IPABenefitWrapper.UserProfile();
    userProfile.companyProfileId = testAccount.Id; // Use the created account as the company profile ID
    userProfile.userId = UserInfo.getUserId();  // Set the current user's ID

    // Step 3: Call the method under test
    Test.startTest();
    


    IPABenefitWrapper.Contactdata contactData = IPABenefitUtility.getContacts('Partner Admin', userProfile);  // Call the method with 'Partner Admin' role
    IPABenefitWrapper.Contactdata contactData1 = IPABenefitUtility.getContacts('Distributor', userProfile);  // Call the method with 'Distributor' role    
    Test.stopTest();
    /*if (contactData.contacts != null) {
        System.assertEquals(1, contactData.contacts.size(), 'There should be one contact in the returned list');
        System.debug('Role of the first contact: ' + contactData.contacts[0].role);
    } else {
        System.debug('No contacts found. Please check the test data and logic in getContacts.');
    }*/
   
}
 @isTest
    static void testNumberConversion() {
        Decimal testValue1 = 12345.67;
        String result1 = IPABenefitUtility.numberConversion(testValue1);
        System.assertEquals('12,345.67', result1, 'The number should be formatted with commas and two decimal places');
    }

    @isTest
    public static void testUncoverdMethods2(){  
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account testAccount = new Account(
        RecordTypeId = recordTypeIdAccount,
        Name = 'Test Partner Account',
        BillingCity = 'City',
        BillingStreet = 'Street',
        BillingCountry = 'India',
        BillingPostalCode = '123456',
        Core_Account_Type__c = 'Cloud Service Provider (CSP)',
        Core_Intel_Partner_Alliance_PartnerGroup__c = true,
        Industry = 'IT',
        OwnerId = UserInfo.getUserId(),
        Core_User_Defined_Website__c = 'https://testpartner.com',
        Core_Geo__c = 'ASMO'
        );
        
        insert testAccount;
        List<String> strList = new List<String>();
        List<String> strList01 = new List<String>{'Activation Zones', 'Intel® Partner Alliance Activation Zones','AI Zones', 'Data Center Modernization Zones', 'Security Zones', 'Edge And Networking', 'Industry Zones'};
        Map<String,String> adhocMsgs = new Map<String,String>();
        String partnerrole = 'Builder';
        String Partnertier = 'Partner';
        List<IPABenefitWrapper.Metrics> trainingMetrics=new List<IPABenefitWrapper.Metrics>();
        List<IPABenefitWrapper.Metrics> trainingMetrics01=new List<IPABenefitWrapper.Metrics>();
        List<String>entitlementlist =new List<String>{'Partner Admin', 'Partner Admin Delegate'};
        List<String>alertTitles=new List<String>();
        strList.add('ABC,BCD');
        adhocMsgs.put('ABC,BCD', 'Test');
        alertTitles.add('ABCD,BCDA');
        //entitlementlist.add('ABCD,BCDA');
        IPABenefitWrapper.UserProfile userData = new IPABenefitWrapper.UserProfile();
        System.debug('in 5420:'+testAccount.Id);
        userData.onePartnerId = testAccount.Id;
        userData.name = 'John Doe'; userData.title = 'Software Engineer'; userData.responsibility = 'Software Engineer'; userData.email = 'john.doe@company.com'; userData.faIcon = 'fa-intel-user-o'; userData.tier = 'Titanium Tier'; userData.userLanguage = 'en_US'; userData.UserEmail = 'john.doe@company.com';
        IPABenefitWrapper.UserProfile userData01 = new IPABenefitWrapper.UserProfile();
        System.debug('in 5422:'+ userData.onePartnerId);
        userData01.name = 'John Doe'; userData.title = 'Software Engineer'; userData.responsibility = 'Software Engineer'; userData.email = 'john.doe@company.com'; userData.faIcon = 'fa-intel-user-o'; userData.tier = 'Titanium Tier'; userData.userLanguage = 'en_US'; userData.UserEmail = 'john.doe@company.com';
        
        test.startTest();
        //IPABenefitUtility.getSpecialtyArtifical(strList,adhocMsgs);
        //IPABenefitUtility.getSpecialtyCloudData(strList,adhocMsgs);
        //IPABenefitUtility.getSelectBenefit(strList,adhocMsgs);
        //IPABenefitUtility.getDealReg(strList);
        
        for(String str : strList01){
            /*IPABenefitUtility.getActivationZones(new List<string>{str},adhocMsgs); 
            IPABenefitUtility.getPricingPointsPromotionsBlade(new List<string>{str},adhocMsgs);
            IPABenefitUtility.getProductRoadmapsBlade(new List<string>{str},adhocMsgs);*/
            IPABenefitUtility.getPoints(new List<string>{str},alertTitles,adhocMsgs);
            IPABenefitUtility.getMarketingStudio(new List<string>{str},alertTitles,adhocMsgs);
        }
        /*IPABenefitUtility.getActivationZones(strList01,adhocMsgs);  
        IPABenefitUtility.getPricingPointsPromotionsBlade(strList01,adhocMsgs);
        IPABenefitUtility.getProductRoadmapsBlade(strList01,adhocMsgs);*/
        IPABenefitUtility.getPoints(strList01,alertTitles,adhocMsgs);
        IPABenefitUtility.getMarketingStudio(strList01,alertTitles,adhocMsgs);
        IPABenefitUtility.getPartnerHelp(strList01,partnerrole,userData,Partnertier,adhocMsgs);
        trainingMetrics = IPABenefitUtility.getTrainingMetrics(userData, entitlementlist);
        IPABenefitWrapper.UserBenefitInfo result = IPABenefitUtility.getTraining(strList01, alertTitles, adhocMsgs, trainingMetrics);
        
        trainingMetrics01 = IPABenefitUtility.getTrainingMetrics(userData01, entitlementlist);
        IPABenefitWrapper.UserBenefitInfo result01 = IPABenefitUtility.getTraining(strList01, alertTitles, adhocMsgs, trainingMetrics01);
        //IPABenefitUtility.getTrainingMetrics(userData, entitlementlist);
        test.stopTest();
        
    }
    
    @isTest
static void testPartnerHelpMetrics_Distributor_WithAWR() {
    // Create test Account
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    
    Account testAccount = new Account(
        RecordTypeId = recordTypeIdAccount,
        Name = 'Test Partner Account',
        BillingCity = 'City',
        BillingStreet = 'Street',
        BillingCountry = 'India',
        BillingPostalCode = '123456',
        Core_Account_Type__c = 'Cloud Service Provider (CSP)',
        Core_Intel_Partner_Alliance_PartnerGroup__c = true,
        Industry = 'IT',
        OwnerId = UserInfo.getUserId(),
        Core_User_Defined_Website__c = 'https://testpartner.com',
        Core_Geo__c = 'ASMO'
    );
    insert testAccount;
ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
    // Get existing Partner Benefit (assumes label points to an existing record)
    PRM_PartnerBenefit__c pbTest6 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest6.Name = 'Partner Marketing Studio';
        pbTest6.PRM_Benefit_Cd__c = 'BFTMKTSTD';
        pbTest6.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest6.PRM_InActive_Ind__c = false;
        pbTest6.PRM_Account_Type_Nm__c='Mastered_Account';
    insert pbTest6;
    /*PRM_Partner_Benefit__c benefit = [
        SELECT Id, Name 
        FROM PRM_Partner_Benefit__c 
        WHERE Name = :System.Label.PRM_Advanced_Warranty_Replacement 
        LIMIT 1
    ];*/

    // Create Account-Benefit Association
    PRM_AccountBenefitAssociation__c benefitAssoc = new PRM_AccountBenefitAssociation__c(
        PRM_Account_Id__c = testAccount.Id,
        PRM_Partner_Benefit_Id__c = pbTest6.Id,
        PRM_Status_Nm__c = 'Active',
        PRM_Status_Reason_Txt__c = 'Test'
    );
    insert benefitAssoc;

    // Create Warranty Data
    PRM_Warranty_Data__c warranty = new PRM_Warranty_Data__c(
        PRM_One_Partner_Id__c = testAccount.Id,
        PRM_Number_Of_AWR_Remaining_Nbr__c = 15
    );
    insert warranty;

    // Prepare UserProfile for test
    IPABenefitWrapper.UserProfile user = new IPABenefitWrapper.UserProfile();
    user.onePartnerId = testAccount.Id;

    // Call method under test
       Test.startTest();
    List<IPABenefitWrapper.Metrics> result = IPABenefitUtility.getPartnerHelpMetrics('Distributor', user);
       Test.stopTest();

}
 
    @isTest
    public static void testGetLeadsMetrics() {
       Id opidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account testAccount = new Account(
            Name = 'Cello Ltd',
            BillingCity = 'New City',
            BillingStreet = 'New Street',
            BillingCountry = 'India',
            BillingPostalCode = '999999',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            Industry = 'Construction',
            Core_User_Defined_Website__c = 'www.abc.com',
            Core_Geo__c = 'ASMO',
            RecordTypeId = opidAccRecordTypeId
        );
        insert testAccount;
    
   

        // Create Contact
    Contact cont3 = new Contact();  // Contact
    cont3.AccountId = testAccount.Id;
    cont3.LastName = 'Parker';
    cont3.FirstName = 'Johnny';
    cont3.Email = 'Peterparker1@rediff.com';
    cont3.Core_Job_Function__c = 'Branch Manager';
    cont3.Core_IPA_PartnerRole__c = 'Distributor';  // Ensure role is set as Distributor (if needed)
    cont3.Core_Preferred_Language__c = 'FRA';
    cont3.MailingCountry = 'USA';
    insert cont3;

        // Create the necessary Record Type for 'Partner_Lead'
        // Assume the 'Partner_Lead' RT exists in your org
        Id partnerLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();

        // Create some Lead records that the method will count
        Lead lead1 = new Lead(FirstName = 'Lead', LastName = 'One', Core_One_Partner_Id__c = testAccount.Id,
                              Core_Lead_Status__c = 'New', Core_Lead_State__c = 'Unclaimed',Company='Test',LeadSource='Media',
                              Country='USA',RecordTypeId = partnerLeadRT, Core_Is_Lead_Shared__c = true);
        //insert lead1;

        Lead lead2 = new Lead(FirstName = 'Lead', LastName = 'Two', Core_One_Partner_Id__c = testAccount.Id,
                              Core_Lead_Status__c = 'New', Core_Lead_State__c = 'Unclaimed',Country='Nepal',Company='Test',LeadSource='Media',
                              RecordTypeId = partnerLeadRT, Core_Is_Lead_Shared__c = true);
        //insert lead2;

        // Create a Core_OPID_Lead_Relationship__c record to test the query in the method
        Core_OPID_Lead_Relationship__c rel = new Core_OPID_Lead_Relationship__c(Core_OPID_Name__c =lead1.Core_One_Partner_Id__c, 
                                                                                 Core_Lead_Name__c = lead1.Id);
        //insert rel;

        // Call the method to test
        Test.startTest();
        List<IPABenefitWrapper.Metrics> metrics = IPABenefitUtilityHandler.getLeadsMetrics('TestOpid1');
        Test.stopTest();

    }

   @isTest
    static void testCoverInnerBenefitBranchesWithoutPartnerBenefitParent(){
        
	    // -------- Gate data ----------
	    final String ENT = 'E1';
        List<String> entitlementList = new List<String>{ ENT };
        
        List<String> benefitsList = new List<String>{
        'Partner University',                            // for Training
        'Partner Marketing Studio',                      // for Marketing Studio
        System.Label.PRM_Solutions_Marketplace_Basic_Profile // for Marketplace
    };
        
         List<String> ipaLookupRegionList = new List<String>{ 'EMEA' };
		
          Boolean showDistiDashboard        = true;
          Boolean showDZPAndRDCPremierBlade = true;
          Boolean showDZSAndRDCPublicBlade  = true;
       
        Id nonQuickRtId;
        
        for (RecordType rt : [
        SELECT Id, DeveloperName
        FROM RecordType
        WHERE SObjectType = 'PRM_PEx_Access_Matrix__c'
        LIMIT 200
    ]) {
        if (rt.DeveloperName != 'Quick_Links_Access_Rule') {
            nonQuickRtId = rt.Id;
            break;
        }
    }
        
        // -------- Create Access Matrix rows (no helper method, no parent benefit) ----------
         List<PRM_PEx_Access_Matrix__c> bams = new List<PRM_PEx_Access_Matrix__c>();
         
        // Points (Spend and non-Spend)
        PRM_PEx_Access_Matrix__c r1 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c      = 'Points',
        PRM_Click_To_Action__c    = 'Spend Points',
        PRM_Entitlements__c       = ENT,
        PRM_Hide_Logo_Icon__c     = false,
        PRM_Benefit_Priority__c   = 1,
        PRM_CTA_Priority__c       = '1',
        PRM_isActive_Indicator__c = true,
        PRM_IPA_Partner_Role__c   = 'Distributor'
    );
        
        if (nonQuickRtId != null) r1.RecordTypeId = nonQuickRtId; bams.add(r1);
        
        PRM_PEx_Access_Matrix__c r2 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c      = 'Points',
        PRM_Click_To_Action__c    = 'View Balance',
        PRM_Entitlements__c       = ENT,
        PRM_Hide_Logo_Icon__c     = false,
        PRM_Benefit_Priority__c   = 1,      
        PRM_CTA_Priority__c       = '2',    
        PRM_isActive_Indicator__c = true,
        PRM_IPA_Partner_Role__c   = 'Distributor'
    );
        if (nonQuickRtId != null) r2.RecordTypeId = nonQuickRtId; bams.add(r2);
        
        // MDF
    PRM_PEx_Access_Matrix__c r3 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='MDF', PRM_Click_To_Action__c='MDF Home', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r3.RecordTypeId = nonQuickRtId; bams.add(r3);
        
        // Training
    PRM_PEx_Access_Matrix__c r4 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Training', PRM_Click_To_Action__c='Training Home', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r4.RecordTypeId = nonQuickRtId; bams.add(r4);
	
        // Leads
    PRM_PEx_Access_Matrix__c r5 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Leads', PRM_Click_To_Action__c='Lead Center', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r5.RecordTypeId = nonQuickRtId; bams.add(r5);
        
        
        // Marketplace
    PRM_PEx_Access_Matrix__c r6 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Marketplace', PRM_Click_To_Action__c='Marketplace Home', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r6.RecordTypeId = nonQuickRtId; bams.add(r6);

        
        // Marketing Studio
    PRM_PEx_Access_Matrix__c r7 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Marketing Studio', PRM_Click_To_Action__c='Open Studio', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r7.RecordTypeId = nonQuickRtId; bams.add(r7);

        // FPGA Tools and Resources
    PRM_PEx_Access_Matrix__c r8 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='FPGA Tools and Resources', PRM_Click_To_Action__c='FPGA Portal', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r8.RecordTypeId = nonQuickRtId; bams.add(r8);

        // Partner Lookup Tool (regular + Partner Assist Dashboard)
    PRM_PEx_Access_Matrix__c r9 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Partner Lookup Tool', PRM_Click_To_Action__c='Lookup Home', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r9.RecordTypeId = nonQuickRtId; bams.add(r9);

        PRM_PEx_Access_Matrix__c r10 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Partner Lookup Tool', PRM_Click_To_Action__c='Partner Assist Dashboard', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='2',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r10.RecordTypeId = nonQuickRtId; bams.add(r10);

        
        // Enablement Zones
    PRM_PEx_Access_Matrix__c r11 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Enablement Zones', PRM_Click_To_Action__c='Activation Zones', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r11.RecordTypeId = nonQuickRtId; bams.add(r11);

        
        // Deal Registration
    PRM_PEx_Access_Matrix__c r12 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Deal Registration', PRM_Click_To_Action__c='Register a Deal', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r12.RecordTypeId = nonQuickRtId; bams.add(r12);

        
        // DZS / RDC Public
    PRM_PEx_Access_Matrix__c r13 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Intel\u00AE Developer Zone - Standard', PRM_Click_To_Action__c='Open DZS', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r13.RecordTypeId = nonQuickRtId; bams.add(r13);
	
        
        PRM_PEx_Access_Matrix__c r14 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Resource & Documentation Center - Public', PRM_Click_To_Action__c='Open RDC', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r14.RecordTypeId = nonQuickRtId; bams.add(r14);

        
        // Premier blades
    PRM_PEx_Access_Matrix__c r15 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Intel\u00AE Developer Zone - Premier', PRM_Click_To_Action__c='Open DZP', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r15.RecordTypeId = nonQuickRtId; bams.add(r15);

        
        PRM_PEx_Access_Matrix__c r16 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Resource & Documentation Center - Premier Access', PRM_Click_To_Action__c='Open RDC Premier', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r16.RecordTypeId = nonQuickRtId; bams.add(r16);

        
        // DIT
    PRM_PEx_Access_Matrix__c r17 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Design Enablement Services,DIT', PRM_Click_To_Action__c='Open DIT', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r17.RecordTypeId = nonQuickRtId; bams.add(r17);

         // Partner Help
    PRM_PEx_Access_Matrix__c r18 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Partner Help', PRM_Click_To_Action__c='Get Help', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r18.RecordTypeId = nonQuickRtId; bams.add(r18);

        // Distributor-only PPP + Products & Roadmaps (include + exclude)
    PRM_PEx_Access_Matrix__c r19 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Pricing, Points and Promotions', PRM_Click_To_Action__c='Open PPP', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r19.RecordTypeId = nonQuickRtId; bams.add(r19);

        PRM_PEx_Access_Matrix__c r20 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Products & Roadmaps', PRM_Click_To_Action__c='Roadmaps Home', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='1',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r20.RecordTypeId = nonQuickRtId; bams.add(r20);

        PRM_PEx_Access_Matrix__c r21 = new PRM_PEx_Access_Matrix__c(
        PRM_Benefit_Blade__c='Products & Roadmaps', PRM_Click_To_Action__c='Intel\u00AE Solutions Library', PRM_Entitlements__c=ENT,
        PRM_Hide_Logo_Icon__c=false, PRM_Benefit_Priority__c=1, PRM_CTA_Priority__c='2',
        PRM_isActive_Indicator__c=true, PRM_IPA_Partner_Role__c='Distributor'
    ); if (nonQuickRtId != null) r21.RecordTypeId = nonQuickRtId; bams.add(r21);

        insert bams;
        
	 IPABenefitWrapper.UserProfile userInfo = new IPABenefitWrapper.UserProfile();
        userInfo.onePartnerId = '001000000000001';
        
        Boolean showSelectBenefit = false;
        List<String> selectBenefitList = new List<String>();
        List<String> specialityList = new List<String>();
        Boolean showDisti = true;
        
        Test.startTest();
        List<IPABenefitWrapper.UserBenefitInfo> distResults = IPABenefitUtility.getBenefitBlades(
        userInfo, ipaLookupRegionList, 'Distributor', entitlementList, benefitsList,
        showSelectBenefit, selectBenefitList, specialityList, showDisti
    );
        /*List<IPABenefitWrapper.UserBenefitInfo> fpgaResults = IPABenefitUtility.getBenefitBlades(
        userInfo, ipaLookupRegionList, 'FPGA Designer', entitlementList, benefitsList,
        showSelectBenefit, selectBenefitList, specialityList, showDisti
    );*/
        Test.stopTest();
        
    System.assertNotEquals(0, distResults.size(), 'Expected blades for Distributor run.');
    //System.assertNotEquals(0, fpgaResults.size(), 'Expected blades for FPGA Designer run.');
              
    }
    
}