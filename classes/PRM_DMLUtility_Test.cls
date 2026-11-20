@istest
public class PRM_DMLUtility_Test {
    static testmethod void doinserttest(){   
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
        insert opidAcc;
        
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
        
        List<account> acclist1  = new List<account>();
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
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountryCode = 'USA';
        insert cont;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
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
        insert acctContRel;
        Triggerhandler.bypass('PRM_ACMTriggerHandlerNew');
        List<PRM_AccountChannelMembership__c> AcmList1 = new List<PRM_AccountChannelMembership__c>(); //TWC729-1292        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        AcmList1.add(acm);
        PRM_DMLUtility.doinsert(AcmList1, 'PRM_AccountChannelMembership__c', 'PRM_DMLUtility.doinsert');
        PRM_AccountChannelMembership__c opidacm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm.PRM_Account_Id__c=opidAcc.id;
        opidacm.PRM_Status_Nm__c='Approved';
        opidacm.PRM_Channel_Program_Id__c=cp.Id;
        opidacm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm.PRM_Partner_Role__c='Service Provider';
        insert opidacm;
        Triggerhandler.clearBypass('PRM_ACMTriggerHandlerNew');
        
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
        insert bem;
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;
       //End : Custom setting record creation added by Krishn Ch
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
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
        insert csa;
        Test.startTest();
        try{ 
            TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
            acm.PRM_Status_Nm__c='Inactive';
            update acm;
                           
            acm.PRM_Status_Nm__c='Approved';
            update acm;
            PRM_DMLUtility.doupdate(AcmList1, 'PRM_AccountChannelMembership__c', 'PRM_DMLUtility.doupdate');
            TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        }catch(Exception e){
            
        }
        
        try{
            
            opidacm.PRM_Status_Nm__c='Inactive';
            update opidacm;
            
            aba.PRM_Status_Nm__c = 'Inactive';
            aba.PRM_Status_Reason_Txt__c = 'Customer is no longer associated with the program';
            update aba;
            
            csa.PRM_Status_Nm__c = 'Inactive';
            update csa;
        }catch(Exception e){
        }
         
        Test.stopTest();
    }
    static testmethod void dodeletetest(){   
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
        insert opidAcc;
        
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
        
        List<account> acclist1  = new List<account>();
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
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Do_Not_Contact__c = false;
        cont.MailingCountryCode = 'USA';
        insert cont;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
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
        insert acctContRel;
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        List<PRM_AccountChannelMembership__c> AcmList1 = new List<PRM_AccountChannelMembership__c>(); //TWC729-1292        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        AcmList1.add(acm);
        PRM_DMLUtility.doinsert(AcmList1, 'PRM_AccountChannelMembership__c', 'PRM_DMLUtility.doinsert');
        acm.PRM_Status_Nm__c='Pending';
        upsert acm;
        PRM_DMLUtility.doupsert(AcmList1, 'PRM_AccountChannelMembership__c', 'PRM_DMLUtility.doupsert');
        
        PRM_AccountChannelMembership__c opidacm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        opidacm.PRM_Account_Id__c=opidAcc.id;
        opidacm.PRM_Status_Nm__c='Approved';
        opidacm.PRM_Channel_Program_Id__c=cp.Id;
        opidacm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        opidacm.PRM_Partner_Role__c='Service Provider';
        insert opidacm;
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
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
        insert bem;
        
        //Start : Custom setting record creation added by Krishn Ch
        PRM_BatchCustomSetting__c  bCs = new PRM_BatchCustomSetting__c ();
        bCs.PRM_MP_Benefits__c = 'Solution Marketplace Enhanced';
        bCs.Name ='BatchFieldValues';
        bCs.PRM_PartnerRole__c ='Service Provider';
        bCs.PRM_PartnerType__c ='Cloud Service Provider (CSP)';
        insert bCs;
       //End : Custom setting record creation added by Krishn Ch
        /*PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;*/
        
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
        insert csa;
        Test.startTest();
        try{ 
            TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
            acm.PRM_Status_Nm__c='Inactive';
            update acm;
                           
            acm.PRM_Status_Nm__c='Approved';
            update acm;
            PRM_DMLUtility.doupdate(AcmList1, 'PRM_AccountChannelMembership__c', 'PRM_DMLUtility.doupdate');
            
        }catch(Exception e){            
        }

        //PRM_DMLUtility.dodelete(AcmList1, 'PRM_AccountChannelMembership__c', 'PRM_DMLUtility.dodelete'); 
        TriggerHandler.clearbypass('PRM_ACMTriggerHandlerNew');
        Test.stopTest();
    }
    static testmethod void doinsert_exception(){   
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
        insert opidAcc;
        
        Account newAccount = new Account();//Account
        /*newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount.Core_CIM_ID__c = '9456456' ; //TWC729-1292*/
        
        List<account> acclist1  = new List<account>();
        //acclist1.add(newAccount);
        try{
        //PRM_DMLUtility.dodelete(acclist1,'Account','');
        }
        catch(Exception e){           
        }
        Account newAccount1 = new Account();//Account
        /*newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='James Henry';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_User_Defined_Website__c='www.sample.com';
        newAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount1.Core_CIM_ID__c = '15875245' ; */
        acclist1.add(newAccount1);
        //insert acclist1;
        try{
        PRM_DMLUtility.doupsert(acclist1,'Account','s.s');
        }
        catch(Exception e){           
        }
        Account newAccount2 = new Account();//Account
        /*newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='James Henry';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_User_Defined_Website__c='www.sample.com';
        newAccount1.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        newAccount1.Core_CIM_ID__c = '15875245' ; */
        acclist1.add(newAccount1);
        //insert acclist1;
        try{
        PRM_DMLUtility.doupdate(acclist1, 'Account','s.s');
        }
        catch(Exception e){           
        }
        
    }

}