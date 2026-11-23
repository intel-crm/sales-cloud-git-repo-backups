@isTest
public class PRM_ACM_Utility_Test   {
    public static List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
    public static List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
    public static  boolean firstRun = true;
    public static  boolean mPFirstRun =true;
    
    @testSetup
    static void setup(){
        prm_skip_trigger__c sk = new prm_skip_trigger__c();
        sk.Name='ABA_Trigger';
        sk.inactive__c= false;
        insert sk;
    }
    
    static testmethod void testRelatedRecordInactiveCheck(){
        List<account> acclist1  = new List<account>();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Triggerhandler.bypass('PRM_VXRecommendation_Handler');
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        acclist1.add(opidAcc) ;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        newAccount.Core_CIM_ID__c = '9456456' ; //TWC729-1292
        
        acclist1.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='James Henry';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_User_Defined_Website__c='www.sample.com';
        newAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount1.Core_CIM_ID__c = '15875245' ; 
        acclist1.add(newAccount1);
        insert acclist1;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c ='Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry ='USA';
        cont.MailingCity ='Mississippi';
        cont.MailingPostalCode='421910';
        cont.MailingState ='AK';
        cont.MailingStreet ='BandraStreet';
        insert cont;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> channelProgs = new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        channelProgs.add(cpl);
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        channelProgs.add(cpl1);
        
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Partner';
        cpl2.ProgramId=cp.Id;
        channelProgs.add(cpl2);
        
        insert channelProgs;
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Reason_Txt__c = 'Testclass run';
        insert acctContRel;
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        
        List<PRM_AccountChannelMembership__c> AcmListforInsert = new List<PRM_AccountChannelMembership__c>(); //TWC729-1292        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm;
        
        PRM_AccountChannelMembership__c opidacm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm.PRM_Account_Id__c=opidAcc.id;
        opidacm.PRM_Status_Nm__c='Approved';
        opidacm.PRM_Channel_Program_Id__c=cp.Id;
        opidacm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm.PRM_Partner_Role__c='Service Provider';
        opidacm.PRM_Status_Reason_Txt__c = 'Test class';
        insert opidacm;
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        
        //insert AcmListforInsert;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb;
        
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
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bem;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');

        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        bcs.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bCs;

        //End : Custom setting record creation added by Krishn Ch
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c = 'Testclass run';
        //insert aba;
        
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
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Contact_Id__c = cont.Id;
        csa.PRM_Status_Nm__c = 'Inactive';
        csa.PRM_Status_Reason_Txt__c = 'Test class';
        insert csa;
        Test.startTest();
        try{
            //PRM_ACM_Utility.firstRun = true;
            TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
            Map<id, PRM_AccountChannelMembership__c> oldMap = new Map<Id, PRM_AccountChannelMembership__c>();
            oldMap.put(acm.id, acm);
            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;
            acm.PRM_Channel_Program_Level_Id__c = cpl2.id;
            update acm;
            TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
            List<PRM_AccountChannelMembership__c> newList = new List<PRM_AccountChannelMembership__c>();
            newList.add(acm);
            PRM_ACMTriggerHandlerNew.createTrackerMilestonesForMembershipUpdate(newList,oldMap);
            PRM_ACM_Utility.UpsertOPIDACM(newList,oldMap);

            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;
            acm.PRM_Status_Nm__c='Inactive';
            update acm;
            /*//PRM_ACM_Utility.firstRun = true;
            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;                
            acm.PRM_Status_Nm__c='Approved';
            System.debug('updating acm 200');
            update acm;
            TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
            Map<id, PRM_AccountChannelMembership__c> oldMap = new Map<Id, PRM_AccountChannelMembership__c>();
            oldMap.put(acm.id, acm);
            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;
            acm.PRM_Channel_Program_Level_Id__c = cpl2.id;
            update acm;
            TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
            List<PRM_AccountChannelMembership__c> newList = new List<PRM_AccountChannelMembership__c>();
            newList.add(acm);
            PRM_ACMTriggerHandlerNew.createTrackerMilestonesForMembershipUpdate(newList,oldMap);*/
        }catch(Exception e){
            
        }
        
        try{
            //PRM_ACM_Utility.firstRun = true;
            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;
            opidacm.PRM_Status_Nm__c='Inactive';
            update opidacm;
            Test.stopTest();
            Triggerhandler.bypass('PRM_aba_TriggerHandler');
            aba.PRM_Status_Nm__c = 'Inactive';
            aba.PRM_Status_Reason_Txt__c = 'Customer is no longer associated with the program';
            
            update aba;
            TriggerHandler.clearbypass('PRM_aba_TriggerHandler');   
            csa.PRM_Status_Nm__c = 'Inactive';
            update csa;
            Triggerhandler.clearbypass('PRM_VXRecommendation_Handler');

        }catch(Exception e){
        }
        //PRM_ACM_Utility.checkPendingMembership(null);  
        //System.assertEquals(acm.PRM_Status_Nm__c,'Inactive','Value does not match');
    }   
    
    static testmethod void testDuplicateCheck(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account newAccount = new Account();//Account       
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount.RecordTypeId = recordTypeIdAccount;
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry ='USA';
        cont.MailingCity ='Mississippi';
        cont.MailingPostalCode='421910';
        cont.MailingState ='AK';
        cont.MailingStreet ='BandraStreet';
        insert cont;
        System.debug('ContPartnerRole, DoNoContact----> ' +cont.Core_IPA_PartnerRole__c + cont.Core_Do_Not_Contact__c);
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;       
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Partner';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        bcs.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        
        insert bCs;
        //End : Custom setting record creation added by Krishn Ch
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c();
        pb.Name = 'Points Accruals – View';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        pb.PRM_Account_Type_Nm__c = 'Mastered_Account'; 
        insert pb;
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_channelprogram__c = cp.id;
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        insert pt;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c();
        bm.PRM_Partner_Benefit_Id__c = pb.Id;
        bm.PRM_Channel_Program_Id__c = cp.Id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        bm.PRM_Partner_Type_Id__c = pt.Id;
        bm.PRM_Approval_Type_Nm__c = 'Automatic';
        bm.PRM_Covered_Account_Ind__c = true;
        bm.PRM_IsActive_Ind__c = true;
        bm.PRM_Partner_Role_Nm__c='Service Provider';
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bm;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c();
        bm1.PRM_Partner_Benefit_Id__c = pb.Id;
        bm1.PRM_Channel_Program_Id__c = cp.Id;
        bm1.PRM_Channel_Program_Level_Id__c = cpl2.Id;
        bm1.PRM_Partner_Type_Id__c = pt.Id;
        bm1.PRM_Approval_Type_Nm__c = 'Automatic';
        bm1.PRM_Covered_Account_Ind__c = true;
        bm1.PRM_IsActive_Ind__c = true;
        bm1.PRM_Partner_Role_Nm__c='Service Provider';
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bm1;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Manual';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        insert bem1;
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.id;
        insert cr1;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm.PRM_Suppress_Email__c = true;
        insert acm;
        acm.PRM_Channel_Program_Level_Id__c=cpl2.Id;
        update acm;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Solution Integrator';
        acm1.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm1.PRM_Suppress_Email__c = true;
        acm1.PRM_Status_Reason_Txt__c = 'Test Insert';
        insert acm1;  
        
        PRM_AccountChannelMembership__c acm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm2.PRM_Account_Id__c=newAccount.id;
        acm2.PRM_Status_Nm__c='Approved';
        acm2.PRM_Channel_Program_Id__c=cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm2.PRM_Partner_Role__c='Solution Integrator';
        acm2.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm2.PRM_Suppress_Email__c = true;
        acm2.PRM_Status_Reason_Txt__c = 'Test Insert';
        insert acm2;  
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount.Id;
        acr1.PRM_Relationship_Id__c = cr1.Id;
        acr1.PRM_Status_Reason_Txt__c = 'Testclass run';
        acr1.PRM_Contact_Id__c=cont.Id;
        acr1.PRM_Status_Nm__c = 'Complete';
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acr1;
        acr1.PRM_Status_Nm__c = 'Complete';
        update acr1;
        TriggerHandler.clearbypass('PRM_AcctContRel_TriggerHandlerNew');
        System.debug('ACR1----> ' +acr1);
        
        PRM_AccountBenefitAssociation__c abassociation = new PRM_AccountBenefitAssociation__c();
        abassociation.PRM_Account_Id__c = newAccount.id;
        abassociation.PRM_Partner_Benefit_Id__c = pb.id;
        abassociation.PRM_Status_Nm__c = 'Active';
        abassociation.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        abassociation.PRM_Source__c ='Tier';

        insert abassociation;
        
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
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = cr1.id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        PRM_ContactSubscriptionAssociation__c csa= new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Contact_Id__c=cont.id;
        csa.PRM_Status_Nm__c='Active';
        csa.PRM_Status_Reason_Txt__c='Inactive';
        insert csa;
        
        Test.startTest();
        try{
            acm.PRM_Partner_Role__c='Solution Integrator';
            update acm;
            PRM_ACMTriggerHandlerNew.ACMUtilityfirstRun = true;
            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;
            acm.PRM_Status_Nm__c='Inactive';
            update acm;
            PRM_ACMTriggerHandlerNew.ACMUtilityfirstRun = true;
            PRM_ACMTriggerHandlerNew.firstRunBeforeUpdate = true;
            acm2.PRM_Status_Nm__c='Inactive';
            update acm2;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('This program is already assigned to the account') ? true : false;
        }
        Test.stopTest();
        System.assertEquals(acm.PRM_Status_Nm__c,'Inactive','Value does not match');    
    }
    static testmethod void testupgradeTier(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';
        cust.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';      
        insert cust;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Tesco';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Adams';
        cont.FirstName='Tony';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        //   cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c ='Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry ='USA';
        cont.MailingCity ='Mississippi';
        cont.MailingPostalCode='421910';
        cont.MailingState ='AK';
        cont.MailingStreet ='BandraStreet';
        insert cont;
        System.debug('ContPartnerRole, DoNoContact----> ' +cont.Core_IPA_PartnerRole__c + cont.Core_Do_Not_Contact__c);
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Prestige';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm.PRM_Suppress_Email__c = true;
        acm.PRM_Status_Reason_Txt__c = 'Test Insert';
        insert acm;
        
        PRM_IPA_Membership__c ipaMem1 = new PRM_IPA_Membership__c();
        ipaMem1.PRM_Account_Channel_Membership__c = acm.Id;
        ipaMem1.PRM_Old_Partner_Role__c='Service Provider';
        ipaMem1.PRM_Old_Partner_Tier__c=cpl.name;
        ipaMem1.PRM_Partner_Role__c = 'Solution Integrator';
        ipaMem1.PRM_Partner_Tier__c = cpl1.Id;
        ipaMem1.PRM_Status__c ='Pending';
        
        insert ipaMem1;
        
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Nm__c = 'Complete';
        insert acctContRel;
        System.debug('ACR2----> ' +acctContRel);
        
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
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = contRelation.id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        insert em;
        System.debug('em-->'+em);
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        
        Test.startTest();
        try{
            insert cce;
            acm.PRM_Status_Nm__c = 'Inactive';
            update acm;
        }
        catch(Exception e){
        }
        Test.stopTest();
        System.assertEquals(acm.PRM_Status_Nm__c,'Inactive','Value does not match');
    } 
    
    static testmethod void createOrUpdateACM(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id upgradeDowngradeRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_Upgrade_Downgrade).getRecordTypeId();
        
        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        parentAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        insert parentAccount;
        
        Account childAccount = new Account();//Account
        childAccount.RecordTypeId = recordTypeIdAccount;
        childAccount.Name='Amazon';
        childAccount.BillingCity='City';
        childAccount.BillingStreet='Street';
        childAccount.BillingCountry='India';
        childAccount.BillingPostalCode='Postal code';
        childAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount.Core_IPA_Partner_Role__c='Solution Integrator';
        childAccount.Core_User_Defined_Website__c='www.sample.com';
        childAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        //   childAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert childAccount;

        Account parentAccount1 = new Account();//Account
        parentAccount1.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount1.Name='Tesco1';
        parentAccount1.BillingCity='City';
        parentAccount1.BillingStreet='Street';
        parentAccount1.BillingCountry='India';
        parentAccount1.BillingPostalCode='Postal code';
        parentAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount1.Core_IPA_Partner_Role__c = 'Solution Integrator';
        parentAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        insert parentAccount1;
        
        Account childAccount1 = new Account();//Account
        childAccount1.RecordTypeId = recordTypeIdAccount;
        childAccount1.Name='Amazon1';
        childAccount1.BillingCity='City';
        childAccount1.BillingStreet='Street';
        childAccount1.BillingCountry='India';
        childAccount1.BillingPostalCode='Postal code';
        childAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        childAccount1.Core_IPA_Partner_Role__c='Solution Integrator';
        childAccount1.Core_User_Defined_Website__c='www.sample.com';
        childAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        //   childAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert childAccount1;
        
        /*   Core_Account_Group_Member__c agm = new    Core_Account_Group_Member__c();
//agm.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
agm.Core_Partner_Account_Id__c = parentAccount.Id;
agm.Core_Intel_Account_Id__c = childAccount.Id;
insert agm; */
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=childAccount.Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.Core_Do_Not_Contact__c = false;
        cont1.MailingCountry ='USA';
        cont1.MailingCity ='Mississippi';
        cont1.MailingPostalCode='421910';
        cont1.MailingState ='AK';
        cont1.MailingStreet ='BandraStreet';
        insert cont1;

        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=childAccount1.Id;
        cont2.lastName='thomas';
        cont2.FirstName='Jack';
        cont2.email='jackthomas123@malinator.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Solution Integrator';
        cont2.Core_Login_Id__c = 'xyz';
        cont2.Core_Do_Not_Contact__c = false;
        cont2.MailingCountry ='USA';
        cont2.MailingCity ='Mississippi';
        cont2.MailingPostalCode='421910';
        cont2.MailingState ='AK';
        cont2.MailingStreet ='BandraStreet';
        insert cont2;
        System.debug('ContPartnerRole, DoNoContact----> ' +cont1.Core_IPA_PartnerRole__c + cont1.Core_Do_Not_Contact__c);
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        insert cr1;
        
        List<PRM_Account_Contact_Relationship__c> acrlist = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=childAccount.Id;
        acr.PRM_Relationship_Id__c = cr1.Id;
        acr.PRM_Contact_Id__c=cont1.Id;
        //acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        //acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        acrlist.add(acr);
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=childAccount1.Id;
        acr1.PRM_Relationship_Id__c = cr1.Id;
        acr1.PRM_Contact_Id__c=cont2.Id;
        //acr.PRM_execute_trigger__c=true;
        acr1.PRM_Start_Date_Dt__c= system.today()-2; 
        acrlist.add(acr1);
        Triggerhandler.bypass('PRM_AcctContRel_TriggerHandler');
        insert acrlist;
        acr.PRM_Status_Nm__c = 'Complete';
        acr1.PRM_Status_Nm__c = 'Complete';
        update acr;
        update acr1;
        Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandler');
        System.debug('acr3-->'+acr);
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Prestige';
        level2.ProgramId = cp.Id;
        insert level2;
        
        Map<String,String> mapOFTierAndBusinessEvent = new Map<String,String>();

        PRM_AccountChannelMembership__c pagAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        pagAccntACM.PRM_Account_Id__c= parentAccount.id;
        pagAccntACM.PRM_Status_Nm__c='Approved';
        pagAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        pagAccntACM.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        pagAccntACM.PRM_Partner_Role__c='Solution Integrator';
        pagAccntACM.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        pagAccntACM.PRM_Suppress_Email__c = true;
        insert pagAccntACM;
        
        PRM_AccountChannelMembership__c childAccntACM = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccntACM.PRM_Account_Id__c= childAccount.id;
        childAccntACM.PRM_Status_Nm__c='Approved';
        childAccntACM.PRM_Channel_Program_Id__c=cp.Id;
        childAccntACM.PRM_Channel_Program_Level_Id__c=cpl.Id;
        childAccntACM.PRM_Partner_Role__c='Solution Integrator';
        childAccntACM.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        childAccntACM.PRM_Suppress_Email__c = true;
        insert childAccntACM;

        PRM_AccountChannelMembership__c pagAccntACM1 = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        pagAccntACM1.PRM_Account_Id__c= parentAccount1.id;
        pagAccntACM1.PRM_Status_Nm__c='Approved';
        pagAccntACM1.PRM_Channel_Program_Id__c=cp.Id;
        pagAccntACM1.PRM_Channel_Program_Level_Id__c=level2.Id;
        pagAccntACM1.PRM_Partner_Role__c='Solution Integrator';
        pagAccntACM1.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        pagAccntACM1.PRM_Suppress_Email__c = true;
        insert pagAccntACM1;
        
        PRM_AccountChannelMembership__c childAccntACM1 = new PRM_AccountChannelMembership__c(); //Account Channel Membership
        childAccntACM1.PRM_Account_Id__c= childAccount1.id;
        childAccntACM1.PRM_Status_Nm__c='Approved';
        childAccntACM1.PRM_Channel_Program_Id__c=cp.Id;
        childAccntACM1.PRM_Channel_Program_Level_Id__c=level2.Id;
        childAccntACM1.PRM_Partner_Role__c='Solution Integrator';
        childAccntACM1.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        childAccntACM1.PRM_Suppress_Email__c = true;
        insert childAccntACM1;

        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parentAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = childAccount.id;
        cagList.add(coreAccnt);
        Core_Account_Group_Member__c coreAccnt1 = new Core_Account_Group_Member__c();
        coreAccnt1.Core_Partner_Account_Id__c = parentAccount1.id;
        coreAccnt1.Core_Intel_Account_Id__c = childAccount1.id;
        cagList.add(coreAccnt1);
        TriggerHandler.bypass('Core_Acct_Grp_Mbr_TriggerHandler');
        insert cagList;
        TriggerHandler.clearbypass('Core_Acct_Grp_Mbr_TriggerHandler');
        
        /*  Core_Account_Group_Member__c agm2 = new     Core_Account_Group_Member__c();
//agm.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
agm.Core_Partner_Account_Id__c = pagAccntACM.Id;
agm.Core_Intel_Account_Id__c = childAccntACM.Id;
insert agm2;*/
        
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> updatedACMList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(pagAccntACM);
        acmList.add(childAccntACM1);
        
        PRM_Execution_Controls__c settings = PRM_Execution_Controls__c.getOrgDefaults();
        settings.PRM_Skip_VR_for_OPID_Batch_Ind__c =true;
        insert settings;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c();
        pb.Name = 'Points Accruals – View';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        pb.PRM_Account_Type_Nm__c = 'Mastered_Account'; 
        insert pb;
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_channelprogram__c = cp.id;
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        insert pt;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c();
        bm.PRM_Partner_Benefit_Id__c = pb.Id;
        bm.PRM_Channel_Program_Id__c = cp.Id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.Id;
        bm.PRM_Partner_Type_Id__c = pt.Id;
        bm.PRM_Approval_Type_Nm__c = 'Automatic';
        bm.PRM_Covered_Account_Ind__c = true;
        bm.PRM_IsActive_Ind__c = true;
        bm.PRM_Partner_Role_Nm__c='Service Provider';
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bm;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c();
        bm1.PRM_Partner_Benefit_Id__c = pb.Id;
        bm1.PRM_Channel_Program_Id__c = cp.Id;
        bm1.PRM_Channel_Program_Level_Id__c = level2.Id;
        bm1.PRM_Partner_Type_Id__c = pt.Id;
        bm1.PRM_Approval_Type_Nm__c = 'Automatic';
        bm1.PRM_Covered_Account_Ind__c = true;
        bm1.PRM_IsActive_Ind__c = true;
        bm1.PRM_Partner_Role_Nm__c='Service Provider';
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bm1;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem1.PRM_Approval_Type_Nm__c='Manual';
        bem1.PRM_Channel_Program_Id__c=cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        bem1.PRM_Covered_Account_Ind__c=True;
        bem1.PRM_IsActive_Ind__c=True;
        bem1.PRM_Partner_Benefit_Id__c=pb.Id;
        bem1.PRM_Partner_Type_Id__c=pt.Id;
        bem1.PRM_Partner_Role_Nm__c='Service Provider';
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bem1;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = childAccount.Id;
        aba.PRM_Status_Reason_Txt__c = 'Testclass run';
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c ='Active';  
        TriggerHandler.bypass('PRM_aba_TriggerHandler');
        insert aba;
        

        Test.startTest();
        PRM_Value_Exchange_Recommendation__c opidRec = new PRM_Value_Exchange_Recommendation__c();
        opidRec.RecordTypeId=upgradeDowngradeRecordType;
        opidRec.PRM_Account_Id__c=childAccount.Id;
        opidRec.PRM_One_Partner_Id__c = parentAccount.Id;
        opidRec.PRM_Tier_Id__c=cpl.Id;
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        opidRec.PRM_Partner_Role_Nm__c='Solution Integrator';
        opidRec.PRM_Market_Type_Nm__c='Mature';
        opidRec.PRM_Recommendation_Type_Nm__c='UPGRADE';
        //opidRec.PRM_Grouping_Method_Nm__c='CTRY';
        opidRec.PRM_Eligibility_Tier__c =cpl1.Id;
        Triggerhandler.bypass('PRM_VXRecommendation_Handler');
        insert opidRec;
        
        opidRec.PRM_Recommendation_Status_Nm__c = 'Processed';
        update opidRec;
        
        opidRec.PRM_Recommendation_Status_Nm__c = 'In Process';
        update opidRec;
        TriggerHandler.clearbypass('PRM_VXRecommendation_Handler');   
        
        
        for(PRM_AccountChannelMembership__c eachACM :acmList){
            eachACM.PRM_Channel_Program_Level_Id__c = cpl1.Id;
            updatedACMList.add(eachACM);
        }
        pagAccntACM1.PRM_Partner_Role__c = 'Distributor';
        updatedACMList.add(pagAccntACM1);
        try{
            update updatedACMList;
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        
        PRM_EmailQueue__c emqu = new PRM_EmailQueue__c();
        emqu.PRM_Business_Event__c = 'OPID_Upgrade_Gold';
        emqu.PRM_Email_Content__c = '';
        emqu.PRM_Contact__c = cont1.Id;
        emqu.PRM_Status__c = 'PENDING';
        emqu.PRM_Tier__c = 'Partner';
        emqu.PRM_PartnerRole__c = 'Solution Integrator';
        emqu.PRM_Priority__c = 1;
        insert emqu;
        
        opidRec.PRM_Recommendation_Status_Nm__c = 'Processed';
        update opidRec;
        Test.stopTest();
        
        PRM_AccountChannelMembership__c acm = [Select Id,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where Id= :pagAccntACM.Id];
        system.assertEquals('Solution Integrator',acm.PRM_Partner_Role__c,'Value should not be updated');
    }
    
    static testmethod void testUpdateBageTierOnInactivatingACM(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Id specid = Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefit').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        //intel Account
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Core_IPA_Badge_Tier__c = '';
        accIntel.Core_IPA_Partner_Segment__c = 'Client Computing';
        //accIntel.Core_IPA_Partner_Segment__c='';
        accList.add(accIntel);                                
        
        /*
//PAG Account
Account accPAG = new Account();
accPAG.RecordTypeId = accountRecordTypePAG;
accPAG.Name = 'Crosswealth123';
accPAG.Core_OPID__c = '2001';
accPAG.Core_OPID_Name__c = 'Crosswealth123';
accPAG.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
accList.add(accPAG);  */ 
        insert accList; 
        
        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        parentAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        insert parentAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parentAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accIntel.id;
        insert coreAccnt;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.IsActive = true;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        ChannelProgramLevel level1 = new ChannelProgramLevel();   //Channel Program Level
        level1.Name='Partner';
        level1.ProgramId = cprogram.Id;
        insert level1;
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Prestige';
        level2.ProgramId = cprogram.Id;
        insert level2;
        
        List<PRM_AccountChannelMembership__c> acmist = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntel.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Nm__c ='Approved';
        acm1.PRM_Channel_Program_Level_Id__c = level2.id;
        acm1.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm1.PRM_Suppress_Email__c = true;
        acmist.add(acm1);
        
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = accIntel.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Distributor';
        acm2.PRM_Status_Nm__c ='Approved';
        acm2.PRM_Channel_Program_Level_Id__c = level.id;
        acm2.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm2.PRM_Suppress_Email__c = true;
        acmist.add(acm2);

        PRM_AccountChannelMembership__c  acm3 = PRM_TestUtility.getMembership();
        acm3.PRM_Account_Id__c = parentAccount.Id;
        acm3.PRM_Channel_Program_Id__c = cprogram.Id;
        acm3.PRM_Partner_Role__c='Distributor';
        acm3.PRM_Status_Nm__c ='Inactive';
        acm3.PRM_Channel_Program_Level_Id__c = level1.id;
        acm3.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm3.PRM_Suppress_Email__c = true;
        acmist.add(acm3);
        
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.recordtypeId = selectBenefitId;
        spec1.name='Select Benefits';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        insert spec1;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= accIntel.id;
        asa.PRM_Specialty_Id__c= spec1.id;
        asa.PRM_InActive_Ind__c= false;
        Insert asa;
        /*  
PRM_AccountChannelMembership__c  acm3 = PRM_TestUtility.getMembership();
acm3.PRM_Account_Id__c = accPAG.Id;
acm3.PRM_Channel_Program_Id__c = cprogram.Id;
acm3.PRM_Partner_Role__c='Service Provider';
acm3.PRM_Status_Nm__c ='Approved';
acm3.PRM_Channel_Program_Level_Id__c = level.id;
acmist.add(acm3); */
        
        
        
        /*
//CAG
Core_Account_Group_Member__c cag = new Core_Account_Group_Member__c();
cag.Core_Intel_Account_Id__c = accIntel.Id;
cag.Core_Partner_Account_Id__c = accPAG.id;
insert cag;                
*/
        Test.startTest();
        insert acmist;
        acm1.PRM_Status_Nm__c ='Inactive';
        
        update acm1;
        
        System.assertEquals('Distributor',acm2.PRM_Partner_Role__c,'Value does not match');
        
        Test.stopTest();
        
    }
    static testmethod void testUpdateactivatingACM(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        List<Account> accList = new List<Account>();
        //intel Account
        Account accIntel = new Account();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.Name='John Wick';
        accIntel.BillingCity='City';
        accIntel.BillingStreet='Street';
        accIntel.BillingCountry='India';
        accIntel.BillingPostalCode='Postal code';
        accIntel.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry='Construction';
        accIntel.Core_User_Defined_Website__c= 'www.abc.com';
        accIntel.OwnerId = UserInfo.getUserId();
        accIntel.Core_Geo__c = 'ASMO';
        accList.add(accIntel);                                 
        insert accList; 
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.IsActive = true;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        ChannelProgramLevel level1 = new ChannelProgramLevel();   //Channel Program Level
        level1.Name='Partner';
        level1.ProgramId = cprogram.Id;
        insert level1;
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Prestige';
        level2.ProgramId = cprogram.Id;
        insert level2;
        
        List<PRM_AccountChannelMembership__c> acmist = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntel.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Nm__c ='Pending';
        acm1.PRM_Channel_Program_Level_Id__c = level2.id;
        acm1.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm1.PRM_Suppress_Email__c = true;
        acmist.add(acm1);
        
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = accIntel.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Distributor';
        acm2.PRM_Status_Nm__c ='Inactive';
        acm2.PRM_Channel_Program_Level_Id__c = level.id;
        acm2.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm2.PRM_Suppress_Email__c = true;
        acmist.add(acm2);
        insert acmist;
        
        
        
        
        Test.startTest();
        
        acm1.PRM_Status_Nm__c ='Approved';
        
        update acm1;
        
        System.assertEquals('Service Provider',acm1.PRM_Partner_Role__c,'Value does not match');
        Test.stopTest();
        
    }
    
    static testmethod void test_ACM_Update(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id selectBenefitId=Schema.SObjectType.PRM_Specialty__c.getRecordTypeInfosByName().get('Select Benefits').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<Account> accList = new List<Account>();
        //intel Account
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Core_IPA_Badge_Tier__c = '';
        accIntel.Core_IPA_Partner_Segment__c = 'Client Computing';
        //accIntel.Core_IPA_Partner_Segment__c='';
        accList.add(accIntel);                                
        
        insert accList; 
        
        Account parentAccount = new Account();//Account
        parentAccount.RecordTypeId = recordTypeIdPAGAccount;
        parentAccount.Name='Tesco';
        parentAccount.BillingCity='City';
        parentAccount.BillingStreet='Street';
        parentAccount.BillingCountry='India';
        parentAccount.BillingPostalCode='Postal code';
        parentAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        parentAccount.Core_IPA_Partner_Role__c = 'Solution Integrator';
        parentAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        insert parentAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = parentAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accIntel.id;
        insert coreAccnt;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.IsActive = true;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        ChannelProgramLevel level1 = new ChannelProgramLevel();   //Channel Program Level
        level1.Name='Partner';
        level1.ProgramId = cprogram.Id;
        insert level1;
        ChannelProgramLevel level2 = new ChannelProgramLevel();   //Channel Program Level
        level2.Name='Prestige';
        level2.ProgramId = cprogram.Id;
        insert level2;
        
        List<PRM_AccountChannelMembership__c> acmist = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c  acm1 = PRM_TestUtility.getMembership();
        acm1.PRM_Account_Id__c = accIntel.Id;
        acm1.PRM_Channel_Program_Id__c = cprogram.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Nm__c ='Approved';
        acm1.PRM_Channel_Program_Level_Id__c = level2.id;
        acm1.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm1.PRM_Suppress_Email__c = true;
        acmist.add(acm1);
        
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = accIntel.Id;
        acm2.PRM_Channel_Program_Id__c = cprogram.Id;
        acm2.PRM_Partner_Role__c='Distributor';
        acm2.PRM_Status_Nm__c ='Approved';
        acm2.PRM_Channel_Program_Level_Id__c = level.id;
        acm2.PRM_Status_Reason_Txt__c = 'Auto Approved by system';
        acm2.PRM_Suppress_Email__c = true;
        acmist.add(acm2);
        
        insert acmist;
        
        Test.startTest();
        
        
        acm1.PRM_Status_Nm__c ='Inactive';
        
        update acm1;
        
        PRM_AccountChannelMembership__c oldAcm = acm1.clone(true, false, true, true);
        oldAcm.id = acm1.id;
    PRM_AccountChannelMembership__c oldAcm2 = acm2.clone(true, false, true, true);
        oldAcm2.id = acm2.id;        
        Map<Id, PRM_AccountChannelMembership__c> oldACMMap = new Map<Id, PRM_AccountChannelMembership__c>();
        oldACMMap.put(oldAcm.id, oldAcm);  
        oldACMMap.put(oldAcm2.id, oldAcm2);  
        PRM_ACM_Utility.UpsertOPIDACM(acmist,oldACMMap);
        acmist[0].PRM_Status_Nm__c ='Approved';
        acmist[0].PRM_Partner_Role__c='Distributor';
        PRM_ACM_Utility.AfterOperationsOnACM(acmist,oldACMMap);
        
        
        System.assertEquals('Distributor',acm2.PRM_Partner_Role__c,'Value does not match');
        
        Test.stopTest();
        
    }
    static testmethod void test_CreateOPIDRecomndtn(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        List<account> acclist1  = new List<account>();
        acclist1.add(opidAcc);
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount.Core_CIM_ID__c = '9456456' ; //TWC729-1292
        acclist1.add(newAccount);
         //insert acclist1;
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Greg Greg';
        newAccount1.BillingCity='Greg';
        newAccount1.BillingStreet='Greg';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_User_Defined_Website__c='www.Greg.com';
        newAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount1.Core_CIM_ID__c = null ; //TWC729-1292
         acclist1.add(newAccount1);
   TriggerHandler.bypass('Core_AccountTriggerHandler');
        insert acclist1;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        //cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c ='Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountry ='USA';
        cont.MailingCity ='Mississippi';
        cont.MailingPostalCode='421910';
        cont.MailingState ='AK';
        cont.MailingStreet ='BandraStreet';
  TriggerHandler.bypass('Core_ContactHandler');
        insert cont;
        
        
        
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Partner';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
         PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both'; 
        insert pb;
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_channelprogram__c = cp.id;
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
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
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bem;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        /*PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Nm__c =System.Label.PRM_ACR_Status;
        insert acctContRel;
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=opidAcc.Id;
        acctContRel1.PRM_Contact_Id__c=cont.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_Status_Nm__c =System.Label.PRM_ACR_Status;
        insert acctContRel1;*/
        
        List<PRM_Account_Contact_Relationship__c> acctContRelList=new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c();
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_Status_Nm__c='Complete';
        acctContRel.PRM_isActive__c=true;
        acctContRel.PRM_Status_Reason_Txt__c = 'Testclass run';
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRel);
        
     /*   PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c();
        acctContRel1.PRM_Account_Id__c=opidAcc.Id;
        acctContRel1.PRM_Contact_Id__c=cont.Id;
        acctContRel1.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel1.PRM_Status_Nm__c='Complete';
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRelList.add(acctContRel1); */
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acctContRelList;
        List<PRM_AccountChannelMembership__c> AcmList1 = new List<PRM_AccountChannelMembership__c>(); //TWC729-1292        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        //acm.PRM_Account_RT__c = 'Core_Partner_Account_Group';
        AcmList1.add(acm);
        
        /*PRM_AccountChannelMembership__c opidacm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
opidacm.PRM_Account_Id__c=opidAcc.id;
opidacm.PRM_Status_Nm__c='Approved';
opidacm.PRM_Channel_Program_Id__c=cp.Id;
opidacm.PRM_Channel_Program_Level_Id__c=cpl.Id;
opidacm.PRM_Partner_Role__c='Service Provider';
AcmList1.add(opidacm);*/
        insert AcmList1;
  TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');

    PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
    aba.PRM_Account_Id__c = newAccount.Id;
    aba.PRM_Partner_Benefit_Id__c = pb.id;
    aba.PRM_Status_Reason_Txt__c = 'Testclass run';
    aba.PRM_Status_Nm__c ='Active';  
    TriggerHandler.bypass('PRM_aba_TriggerHandler');
    insert aba;
  Test.startTest();
        ///PRM_ACM_Utility.CreateOPIDRecomndtn(AcmList1,null); 
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        coreAccnt.Core_Inactive_Ind__c = false;
        insert coreAccnt;

        
                
        PRM_ACM_Utility.UpsertOPIDACM(AcmList1,null);
        List<PRM_AccountChannelMembership__c> AcmList2 = new List<PRM_AccountChannelMembership__c>();       
        PRM_AccountChannelMembership__c intelacm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        intelacm1.PRM_Account_Id__c=newAccount1.id;
        intelacm1.PRM_Status_Nm__c='Approved';
        intelacm1.PRM_Channel_Program_Id__c=cp.Id;
        intelacm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        intelacm1.PRM_Partner_Role__c='Service Provider';
        intelacm1.PRM_Status_Reason_Txt__c = 'Test class';
        AcmList2.add(intelacm1);
        
        PRM_AccountChannelMembership__c opidacm2= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm2.PRM_Account_Id__c=opidAcc.id;
        opidacm2.PRM_Status_Nm__c='Approved';
        opidacm2.PRM_Channel_Program_Id__c=cp.Id;
        opidacm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm2.PRM_Partner_Role__c='Service Provider';
        opidacm2.PRM_Status_Reason_Txt__c = 'Test class';
        AcmList2.add(opidacm2);
        insert AcmList2;
        
        PRM_AccountChannelMembership__c oldAcm = acm.clone(true, false, true, true);
        oldAcm.id = acm.id;
        oldAcm.PRM_Status_Nm__c='Inactive';
        oldAcm.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        oldAcm.PRM_Status_Reason_Txt__c = 'Test class';
        Map<Id, PRM_AccountChannelMembership__c> oldACMMap = new Map<Id, PRM_AccountChannelMembership__c>();
        oldACMMap.put(oldAcm.id, oldAcm);
        
        Map<Id, PRM_AccountChannelMembership__c> oldACMMap2 = new Map<Id, PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c oldopidAcm = opidacm2.clone(true, false, true, true);
        oldopidAcm.id = opidacm2.id;   
        AcmList2[0].PRM_Channel_Program_Level_Id__c = cpl2.id;
        oldACMMap2.put(oldopidAcm.id, oldopidAcm);
        PRM_ACM_Utility.UpdateLocationAccACM(AcmList2,oldACMMap2);
        
        PRM_ACM_Utility.duplicateRecordCheck(AcmList1,oldACMMap.values()); 
        PRM_ACM_Utility.duplicateRecordCheck(AcmList1,null); 
        PRM_ACM_Utility.UpsertOPIDACM(AcmList1,oldACMMap);
        //PRM_ACM_Utility.CreateOPIDRecomndtn(AcmList2,oldACMMap); 
        AcmList2[0].PRM_Channel_Program_Level_Id__c = cpl2.id; 
        
        PRM_ACM_Utility.AfterOperationsOnACM(AcmList1,oldACMMap);
        oldACMMap.values()[0].PRM_Status_Nm__c='Approved';
        AcmList1[0].PRM_Status_Nm__c='Inactive';
        PRM_ACM_Utility.AfterOperationsOnACM(AcmList1,oldACMMap);         
        
        acm.PRM_Suppress_Email__c = true;
        PRM_ACM_Utility.suppressEmail(AcmList1);
        PRM_ACM_Utility.updateSuppressEmail(AcmList1, oldACMMap);
        oldAcm.PRM_Status_Nm__c='Inactive';
        
        PRM_ACM_Utility.updateACMStatusChangeDate(AcmList1, oldACMMap);
       // PRM_ACM_Utility.AfterOperationsOnACM(AcmList1,oldACMMap);
        oldAcm.PRM_Status_Nm__c='Approved';
        oldAcm.PRM_Partner_Role__c='Distributor';
        PRM_ACM_Utility.createTrackerMilestonesForMembershipUpdate(AcmList1, oldACMMap);              
        oldopidAcm.PRM_Partner_Role__c='Distributor';       
        List<PRM_AccountChannelMembership__c> opidACMList = new List<PRM_AccountChannelMembership__c>();
        opidACMList.add(opidacm2);
        PRM_ACM_Utility.createTrackerMilestonesForMembershipUpdate(opidACMList, oldACMMap2);
        Test.stopTest();
    }
    
    @isTest static void updateTierOnMPITest(){
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';
        cust.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;
        
        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Prestige';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account testAccount = new Account();
        testAccount.RecordTypeId = devRecordTypeId;
        testAccount.Name = 'Test Account OPID MPI';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;     
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=testAccount.Name;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=true;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = testAccount.id; 
        insert coreAccnt;
        
        List<PMP_OPID_MPI_Rel__c> junctions = new List<PMP_OPID_MPI_Rel__c>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true; 
        junctions.add(jun);
        insert junctions;
        
        String ids = [SELECT Id FROM Account WHERE Name = 'Greg Thomas'].id;
        Set<Id> id = new Set<Id>();
        id.add(ids);
        
        Set<id> accountIdsMPI = new Set<Id>();
        accountIdsMPI.add(testAccount.id);
        accountIdsMPI.add(newPagAccount.id);
        List<PMP_OPID_MPI_Rel__c> junctionObjectsRelatedToAccounts = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIdsMPI);
        Set<Id> allMpiIdRelatedToAccounts = PMP_Utility.getAllMpiIds(junctionObjectsRelatedToAccounts); 
        List<PMP_OPID_MPI_Rel__c> junctionObjectsRelatedToMpi = PMP_Utility.getJunctionAccountToMpiByCompanyId(allMpiIdRelatedToAccounts);
        Map<Id,Set<Id>> mapMpiToListAccountActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjectsRelatedToMpi);//MPI Object
        for(Id mpi : mapMpiToListAccountActive.keySet()){
            accountIdsMPI.addAll(mapMpiToListAccountActive.get(mpi));
        }
        List<Account> accountList = New List<Account>();
        accountList.add(testAccount);
        PRM_ACMTriggerHandlerNew.updateTierOnMPI(allMpiIdRelatedToAccounts, mapMpiToListAccountActive, accountList);
        
    }
    @isTest
    public static void InboundCreationTest(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRecordTypePAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        
        List<Account> accountList = new List<Account>();

        OPID_Number__c maxopidNum = new OPID_Number__c();
        maxopidNum.Name ='OPID Number';
        maxopidNum.Max_OPID_Number__c='99999999';
        insert maxopidNum;
        
        ChannelProgram cp= new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.Category ='Reseller';
        cp.Core_MDF_Channel_Program_Unique_Id_nm__c = 'IntelPartnerAllianceIntelPartnerAlliance';
        cp.Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance';
        cp.Description ='Unified Partner Program which will cater to all the different types of customers targetted through individual programs today';
        cp.PRM_programCode__c ='IPA';
        insert cp;
        
        ChannelProgramLevel cpLevelGold = new ChannelProgramLevel();
        cpLevelGold.name ='Partner';
        cpLevelGold.ProgramId = cp.id;
        cpLevelGold.PRM_programlevelcode__c = 'PARTNER';
        insert cpLevelGold;
        
        ChannelProgramLevel cpLevelTitanium = new ChannelProgramLevel();
        cpLevelTitanium.name ='Prestige';
        cpLevelTitanium.ProgramId = cp.id;
        cpLevelTitanium.PRM_programlevelcode__c = 'PRESTIGE';
        insert cpLevelTitanium;
        
        ChannelProgramLevel cpLevel = new ChannelProgramLevel();
        cpLevel.name ='Partner';
        cpLevel.ProgramId = cp.id;
        cpLevel.PRM_programlevelcode__c = 'PARTNER';
        insert cpLevel;
        
        //scenario 3
        Account acc1= new Account();
        acc1.Name ='Test Account1';
        acc1.RecordTypeId = accountRecordTypeIntel;
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc1.Core_Business_Party_Id__c = '1012456';
        acc1.Core_Unified_Global_Customer_BP_Id__c = '1012456';
        acc1.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc1.BillingCity='Alaska';
        acc1.BillingCountry ='GBR';
        acc1.BillingState='ENG';
        acc1.BillingPostalCode = '421911';
        acc1.BillingStreet= 'BandraWest Street';
        accountList.add(acc1);
        
        //sceanrio 2
        Account acc2 = new Account();
        acc2.Name ='Test Account2';
        acc2.RecordTypeId = accountRecordTypeIntel;
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc2.Core_Business_Party_Id__c = '1012459';
        acc2.Core_Unified_Global_Customer_BP_Id__c = '1012459';
        acc2.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc2.BillingCity='Alaska';
        acc2.BillingCountry ='GBR';
        acc2.BillingState='ENG';
        acc2.BillingPostalCode = '421911';
        acc2.BillingStreet= 'BandraWes Street';
        accountList.add(acc2);
        
        Account acc3= new Account();
        acc3.Name ='Test Account3';
        acc3.RecordTypeId = accountRecordTypeIntel;
        acc3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc3.Core_Business_Party_Id__c = '1012458';
        acc3.Core_Parent_Business_Party_Id__c = '1012459';
        acc3.Core_Unified_Global_Customer_BP_Id__c = '1012459';
        acc3.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc3.BillingCity='Mississippi';
        acc3.BillingCountry ='GBR';
        acc3.BillingState='ENG';
        acc3.BillingPostalCode = '421910';
        acc3.BillingStreet= 'BandraStreet';
        accountList.add(acc3);

        Account opidAcc1 = new Account();
        opidAcc1.RecordTypeId = accountRecordTypePAG;
        opidAcc1.Name ='opid account2';                    
        opidAcc1.Core_OnePartnerID__c = '123456999';
        opidAcc1.Core_PAG_Grouping_Method__c = 'GLBL';
        accountList.add(opidAcc1);
        
        //scenario 1
        Account acc4 = new Account();
        acc4.Name ='Test Account4';
        acc4.RecordTypeId = accountRecordTypeIntel;
        acc4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc4.Core_Business_Party_Id__c = '1013333';
        acc4.Core_Unified_Global_Customer_BP_Id__c = '1013333';
        //acc4.Core_Unified_Intermediate_Customer_BP_Id__c = '1013333';
        acc4.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc4.BillingCity='Mississippi';
        acc4.BillingCountry ='GBR';
        acc4.BillingState='ENG';
        acc4.BillingPostalCode = '421910';
        acc4.BillingStreet= 'BandraStreet';
        accountList.add(acc4);
        
        Account acc6 = new Account();
        acc6.Name ='Test Account4';
        acc6.RecordTypeId = accountRecordTypeIntel;
        acc6.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc6.Core_Business_Party_Id__c = '1013333';
        acc6.Core_Unified_Intermediate_Customer_BP_Id__c = '1013333';
        acc6.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc6.BillingCity='Mississippi';
        acc6.BillingCountry ='GBR';
        acc6.BillingState='ENG';
        acc6.BillingPostalCode = '421910';
        acc6.BillingStreet= 'BandraStreet';
        //acc6.ParentId = '1013333';
        accountList.add(acc6);

        Account acc5= new Account();
        acc5.Name ='Test Account5';
        acc5.RecordTypeId = accountRecordTypeIntel;
        acc5.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acc5.Core_Business_Party_Id__c = '1013337';
        acc5.Core_Unified_Global_Customer_BP_Id__c = '1013333';
        acc5.Core_Parent_Business_Party_Id__c = '1013333';
        
        acc5.Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        acc5.BillingCity='Mississippi';
        acc5.BillingCountry ='GBR';
        acc5.BillingState='ENG';
        acc5.BillingPostalCode = '421910';
        acc5.BillingStreet= 'BandraStreet';
        accountList.add(acc5);
        
        insert accountList;
        
        PRM_AccountChannelMembership__c acmacc2 = new PRM_AccountChannelMembership__c();
        acmacc2.PRM_Account_Id__c = acc2.id;
        acmacc2.PRM_Channel_Program_Level_Id__c = cpLevelTitanium.id;
        acmacc2.PRM_Channel_Program_Id__c = cp.id;
        acmacc2.PRM_Partner_Role__c = 'Distributor';
        acmacc2.PRM_Status_Nm__c = 'Approved';
        acmacc2.PRM_Status_Reason_Txt__c = 'Test class';
        insert acmacc2;
        
        PRM_AccountChannelMembership__c opidacm = new PRM_AccountChannelMembership__c();
        opidacm.PRM_Account_Id__c = opidAcc1.id;
        opidacm.PRM_Channel_Program_Level_Id__c = cpLevelTitanium.id;
        opidacm.PRM_Channel_Program_Id__c = cp.id;
        opidacm.PRM_Partner_Role__c = 'Distributor';
        opidacm.PRM_Status_Nm__c = 'Approved';
        opidacm.PRM_Status_Reason_Txt__c = 'Test class';
        insert opidacm;
        
        Core_Account_Group_Member__c cag1= new Core_Account_Group_Member__c();
        cag1.Core_Partner_Account_Id__c = opidAcc1.id;
        cag1.Core_Intel_Account_Id__c =acc2.id ;
        cag1.Core_Inactive_Ind__c=false; 
        insert cag1;
        
        List<PRM_AccountChannelMembership__c> acmList = new list<PRM_AccountChannelMembership__c>();
         //sceanrio 3
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c=acc1.id;
        acm1.PRM_Channel_Program_Level_Id__c = cpLevel.id;
        acm1.PRM_Channel_Program_Id__c = cp.id;
        acm1.PRM_Partner_Role__c ='Distributor';
        acm1.PRM_Status_Nm__c = 'Approved';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm1);

        //scenario 2
        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c=acc3.id;
        acm2.PRM_Channel_Program_Level_Id__c = cpLevelGold.id;
        acm2.PRM_Channel_Program_Id__c = cp.id;
        acm2.PRM_Partner_Role__c = 'Distributor';
        acm2.PRM_Status_Nm__c = 'Approved';
        acm2.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm2);
        
        //scenario 1
        PRM_AccountChannelMembership__c acm3 = new PRM_AccountChannelMembership__c();
        acm3.PRM_Account_Id__c=acc5.id;
        acm3.PRM_Channel_Program_Level_Id__c = cpLevel.id;
        acm3.PRM_Channel_Program_Id__c = cp.id;
        acm3.PRM_Partner_Role__c = 'Distributor';
        acm3.PRM_Status_Nm__c = 'Approved'; 
        acm3.PRM_Status_Reason_Txt__c = 'Test class';
        acmList.add(acm3);
        
        Map<String,account> ucdNonGlblAccMap = new Map<String,account>();
        ucdNonGlblAccMap.put(acc1.Core_Business_Party_Id__c,acc1);
        //ucdNonGlblAccMap.put(acc3.Core_Business_Party_Id__c,acc3);
        ucdNonGlblAccMap.put(acc5.Core_Business_Party_Id__c,acc5);
        list<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner =  new list<Core_OnePartner_Inbound_Message__c> () ;
        Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap = new Map<Id,PRM_AccountChannelMembership__c>();
        AcmWithOPIDCheckMap.put(acc1.id,acm1);
        //AcmWithOPIDCheckMap.put(acm2.id,acm2);
        AcmWithOPIDCheckMap.put(acc3.id,acm3);
        //Core_Account_Group_Member__c cag =[Select id,Core_Business_Party_Id__c from Core_Account_Group_Member__c where id= cag1.id];
        Map<String,Core_Account_Group_Member__c> parentCagRec = new Map<String,Core_Account_Group_Member__c>();
        //parentCagRec.put(cag.Core_Business_Party_Id__c,cag);
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(acmList, false);
        acm3.PRM_Channel_Program_Level_Id__c = cpLevelGold.id;
        update acm3;
        Set<String> noIpaAccountIds = new Set<String>();
        PRM_ACMTriggerHandlerNew.CreateInboundRecord(parentCagRec,ucdNonGlblAccMap,listOfInboundOnePartner,AcmWithOPIDCheckMap,noIpaAccountIds);
        uCDPartnerGrouping.createInboundRecords(acc4.id,'Test Account4','Global','Global Account');
        uCDPartnerGrouping.createInboundRecords(acc4.id,'Test Account4','Line of Business','OPID Account');
        uCDPartnerGrouping.createInboundRecords(acc6.id,'Test Account6','Line of Business','OPID Account');
        uCDPartnerGrouping.getAccountHierarchy(acc1.id,'Global',false);
        uCDPartnerGrouping.getAccountHierarchy(acc1.id,'Global',true);
        uCDPartnerGrouping.getAccountHierarchy(acc5.id,'Line of Business',true);
        uCDPartnerGrouping.getAccountHierarchy(acc5.id,'Line of Business',false);
        uCDPartnerGrouping.getAccountHierarchy(acc4.id,'Global',false);
        uCDPartnerGrouping.getAccountHierarchy(acc4.id,'Global',true);
        uCDPartnerGrouping.getAccountHierarchy(acc1.id,'Line of Business',true);
        uCDPartnerGrouping.getAccountHierarchy(acc1.id,'Line of Business',false);
        uCDPartnerGrouping.getAccountHierarchy(acc6.id,'Line of Business',true);
        uCDPartnerGrouping.getAccountHierarchy(acc6.id,'Line of Business',false);
        uCDPartnerGrouping.getPicklistValues('Account','Core_Customer_Aggregation_Type__c');
        Test.stopTest();
    }

    
    /*@isTest 
    static void UpdateEntOnRollDown_synchronous() {
        Account acct = [SELECT Id FROM Account WHERE Name='Greg Thomas' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acct.Id LIMIT 1];

        Map<Id,String> accChMem = new Map<Id,String>{ acct.Id => 'Service Provider' };
        Map<Id,String> actIdRoleTierMap = new Map<Id,String>{ acct.Id => 'Service Provider-prestige' };
        Map<Id,String> tierMap = new Map<Id,String>{ acct.Id => 'prestige' };

        Test.startTest();
            // Direct synchronous call
            PRM_ACMTriggerHandlerNew.UpdateEntitlementOnRollDown(accChMem, actIdRoleTierMap, tierMap);
        Test.stopTest();

        // Assert that Core_Contact_Entitlement__c were inserted/updated
        Integer cnt = [SELECT count() FROM Core_Contact_Entitlement__c WHERE Core_Status__c = 'Complete'];
        System.assert(cnt > 0, 'Expected entitlement records to be created synchronously.');
    }*/
}