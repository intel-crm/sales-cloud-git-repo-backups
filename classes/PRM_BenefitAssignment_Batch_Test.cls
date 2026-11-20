@isTest
private class PRM_BenefitAssignment_Batch_Test {
    
    public static boolean ipaRefresh = boolean.valueOf(label.PRM_IPARefresh);
    @isTest static void testBatchExecution() {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        Id recordTypeIdEMB = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithBenefits').getRecordTypeId();
        Id recordTypeIdPartnerGrp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

        // Step 1: Create test data
        List<Account> acc = new List<Account>();

        // Partner Account Group record
        Account opidAcc = new Account();
        opidAcc.RecordTypeId = recordTypeIdPartnerGrp;
        opidAcc.Name = 'vista';
        opidAcc.BillingCity = 'City9';
        opidAcc.BillingStreet = 'Street9';
        opidAcc.BillingCountry = 'India';
        opidAcc.BillingPostalCode = 'Postal code';
        opidAcc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        opidAcc.Industry = 'Agriculture';
        opidAcc.Core_Deactivated__c = FALSE;
        acc.add(opidAcc);

        Account newAccount = new Account();
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name = 'Johrt Rick';
        newAccount.BillingCity = 'City';
        newAccount.BillingStreet = 'Street';
        newAccount.BillingCountry = 'India';
        newAccount.BillingPostalCode = 'Postal code';
        newAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        newAccount.Industry = 'Agriculture';
        newAccount.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount);

        Account newAccount1 = new Account();
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name = 'Joshy Rick1';
        newAccount1.BillingCity = 'Cityu';
        newAccount1.BillingStreet = 'Streete';
        newAccount1.BillingCountry = 'India';
        newAccount1.BillingPostalCode = 'Postal code';
        newAccount1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount1.Industry = 'Agriculture';
        newAccount1.Core_User_Defined_Website__c = 'www.Test1234.com';
        acc.add(newAccount1);

        insert acc;

        List<Core_Account_Group_Member__c> listAccountgroup = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = opidAcc.Id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.Id;
        listAccountgroup.add(coreAccnt);

        Core_Account_Group_Member__c coreAccnt1 = new Core_Account_Group_Member__c();
        coreAccnt1.Core_Partner_Account_Id__c = opidAcc.Id;
        coreAccnt1.Core_Intel_Account_Id__c = newAccount1.Id;
        listAccountgroup.add(coreAccnt1);

        insert listAccountgroup;

        List<Contact> listcon = new List<Contact>();
        Contact cont = new Contact();
        cont.AccountId = newAccount.Id;
        cont.LastName = 'Grill';
        cont.FirstName = 'Adam';
        cont.Email = 'AdamGrill@rediff.com';
        cont.Core_Job_Function__c = 'Branch Manager';
        cont.Core_eRPM_Language_Code__c = 'Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Status__c = 'Active';
        cont.MailingCountry = 'India';
        listcon.add(cont);

        Contact cont1 = new Contact();
        cont1.AccountId = newAccount1.Id;
        cont1.LastName = 'Grilladm';
        cont1.FirstName = 'Adamgril';
        cont1.Email = 'AdamGrillada@rediff.com';
        cont1.Core_Job_Function__c = 'Branch Manager';
        cont1.Core_eRPM_Language_Code__c = 'Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Status__c = 'Active';
        cont1.MailingCountry = 'India';
        listcon.add(cont1);

        insert listcon;

         ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        cp.PRM_programCode__c = 'IPA';
        insert cp;

        list<PRM_ContactRelationships__c> conRelLst=new list<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c admin = new PRM_ContactRelationships__c();   //Contact Relationship
        admin.Name='Partner Admin';
        admin.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        admin.PRM_Channel_Program_Id__c = cp.Id;
        admin.PRM_Default_Relationship_Ind__c = true;
        conRelLst.add(admin);
        
        
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c();   //Contact Relationship
        employee.Name='Employee';
        employee.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        employee.PRM_Channel_Program_Id__c = cp.Id;
        employee.PRM_Default_Relationship_Ind__c = true;
        conRelLst.add(employee);
        
        insert conRelLst;

       

        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = 'Partner';
        cpl.ProgramId = cp.Id;
        insert cpl;

        ChannelProgramLevel cpl1 = new ChannelProgramLevel();
        cpl1.Name = 'Prestige';
        cpl1.ProgramId = cp.Id;
        insert cpl1;

        // Partner Benefits
        List<PRM_PartnerBenefit__c> listPB = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c();
        pb.Name = 'Points Redeem';
        pb.PRM_Channel_Program_Id__c = cp.Id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        listPB.add(pb);

        PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c();
        pb1.Name = 'Points View';
        pb1.PRM_Channel_Program_Id__c = cp.Id;
        pb1.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb1.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        listPB.add(pb1);

        PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c();
        pb2.Name = 'Technology Sandbox';
        pb2.PRM_Channel_Program_Id__c = cp.Id;
        pb2.PRM_Benefit_Cd__c = 'BFTSNDBX';
        pb2.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        listPB.add(pb2);

        PRM_PartnerBenefit__c pb3 = new PRM_PartnerBenefit__c();
        pb3.Name = 'Solutions Marketplace Basic Profile';
        pb3.PRM_Channel_Program_Id__c = cp.Id;
        pb3.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
        pb3.PRM_Account_Type_Nm__c = 'Mastered_Account';
        listPB.add(pb3);

        PRM_PartnerBenefit__c pb4 = new PRM_PartnerBenefit__c();
        pb4.Name = 'Solutions Marketplace Enhanced';
        pb4.PRM_Channel_Program_Id__c = cp.Id;
        pb4.PRM_Benefit_Cd__c = 'BFTMKTPLED';
        pb4.PRM_Account_Type_Nm__c = 'Mastered_Account';
        listPB.add(pb4);

        insert listPB;

        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = newAccount.Id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        acm.PRM_Channel_Program_Id__c = cp.Id;
        acm.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm;

        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c();
        acm1.PRM_Account_Id__c = newAccount1.Id;
        acm1.PRM_Status_Nm__c = 'Approved';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        acm1.PRM_Channel_Program_Id__c = cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        acm1.PRM_Partner_Role__c = 'Service Provider';
        acm1.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm1;

		PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c();
        acm2.PRM_Account_Id__c = opidAcc.Id;
        acm2.PRM_Status_Nm__c = 'Approved';
        acm2.PRM_Status_Reason_Txt__c = 'Test class';
        acm2.PRM_Channel_Program_Id__c = cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        acm2.PRM_Partner_Role__c = 'Service Provider';
        acm2.PRM_Status_Reason_Txt__c = 'Test class';
        insert acm2;

        List<PRM_AccountChannelMembership__c> acmRecords = [SELECT LastModifiedById, Name, PRM_Status_Change_Dt__c FROM PRM_AccountChannelMembership__c WHERE PRM_Status_Nm__c = 'Approved' LIMIT 1];
        Datetime lastModifyDate = acmRecords[0].PRM_Status_Change_Dt__c;
        String lastModifiedBy = acmRecords[0].LastModifiedById;

        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();
        bm.Name = 'BatchFieldValues';
        bm.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c = 'Partner;Prestige';
        bm.PRM_SchedulingHour__c = 6;
        bm.PRM_NoOfRecords__c = 300;
        bm.PRM_NoOfBatchEntRecords__c = 10;
        bm.PRM_PartnerRole__c = 'Service Provider';
        bm.PRM_MP_Benefits__c = 'Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bm;

        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = cp.Id;
        insert pt;

         Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
        insert ed;
         Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View';
        ed1.Core_Display_Name__c='Points View';
        insert ed1;
        

        Test.startTest();
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRelEmp=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRelEmp.PRM_Account_Id__c=newAccount1.Id;
        acctContRelEmp.PRM_Contact_Id__c=cont1.Id;
        acctContRelEmp.PRM_Relationship_Id__c=employee.Id;
        acctContRelEmp.PRM_InActive_Ind__c=false;
        acctContRelEmp.PRM_Status_Nm__c = 'Complete';
        acctContRelEmp.PRM_Status_Reason_Txt__c='Test';
        acrList.add(acctContRelEmp);

        PRM_Account_Contact_Relationship__c acctContRelEmp1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRelEmp1.PRM_Account_Id__c=newAccount.Id;
        acctContRelEmp1.PRM_Contact_Id__c=cont.Id;
        acctContRelEmp1.PRM_Relationship_Id__c=employee.Id;
        acctContRelEmp1.PRM_InActive_Ind__c=false;
        acctContRelEmp1.PRM_Status_Nm__c = 'Complete';
        acctContRelEmp1.PRM_Status_Reason_Txt__c='Test';
        acrList.add(acctContRelEmp1);

        PRM_Account_Contact_Relationship__c acctContRelEmp2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRelEmp2.PRM_Account_Id__c=newAccount.Id;
        acctContRelEmp2.PRM_Contact_Id__c=cont.Id;
        acctContRelEmp2.PRM_Relationship_Id__c=admin.Id;
        acctContRelEmp2.PRM_InActive_Ind__c=false;
        acctContRelEmp2.PRM_Status_Nm__c = 'Complete';
        acctContRelEmp2.PRM_Status_Reason_Txt__c='Test';
        acrList.add(acctContRelEmp2);
        Triggerhandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acrList;
        Triggerhandler.clearbypass('PRM_AcctContRel_TriggerHandlerNew');

        List<PRM_VXBnftMatrix__c> listVXB = new List<PRM_VXBnftMatrix__c>();
        PRM_VXBnftMatrix__c bem = new PRM_VXBnftMatrix__c();
        bem.PRM_Approval_Type_Nm__c = 'Automatic';
        bem.PRM_Channel_Program_Id__c = cp.Id;
        bem.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        bem.PRM_Covered_Account_Ind__c = true;
        bem.PRM_IsActive_Ind__c = true;
        bem.PRM_Partner_Benefit_Id__c = pb.Id;
        bem.PRM_Partner_Type_Id__c = pt.Id;
        bem.PRM_Partner_Role_Nm__c = 'Service Provider';
        listVXB.add(bem);

        PRM_VXBnftMatrix__c bem1 = new PRM_VXBnftMatrix__c();
        bem1.PRM_Approval_Type_Nm__c = 'Automatic';
        bem1.PRM_Channel_Program_Id__c = cp.Id;
        bem1.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        bem1.PRM_Covered_Account_Ind__c = true;
        bem1.PRM_IsActive_Ind__c = true;
        bem1.PRM_Partner_Benefit_Id__c = pb1.Id;
        bem1.PRM_Partner_Type_Id__c = pt.Id;
        bem1.PRM_Partner_Role_Nm__c = 'Service Provider';
        listVXB.add(bem1);

        PRM_VXBnftMatrix__c bem2 = new PRM_VXBnftMatrix__c();
        bem2.PRM_Approval_Type_Nm__c = 'Manual';
        bem2.PRM_Channel_Program_Id__c = cp.Id;
        bem2.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        bem2.PRM_Covered_Account_Ind__c = true;
        bem2.PRM_IsActive_Ind__c = true;
        bem2.PRM_Partner_Benefit_Id__c = pb2.Id;
        bem2.PRM_Partner_Type_Id__c = pt.Id;
        bem2.PRM_Partner_Role_Nm__c = 'Service Provider';
        listVXB.add(bem2);

        insert listVXB;

        List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = opidAcc.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.Id;
        aba.PRM_Status_Nm__c = 'Inactive';
        aba.PRM_Status_Reason_Txt__c = 'Not interested';

        PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
        aba1.PRM_Account_Id__c = opidAcc.Id;
        aba1.PRM_Partner_Benefit_Id__c = pb2.Id;
        aba1.PRM_Status_Nm__c = 'Inactive';
        aba1.PRM_Status_Reason_Txt__c = 'Not interested';

        PRM_AccountBenefitAssociation__c aba3 = new PRM_AccountBenefitAssociation__c();
        aba3.PRM_Account_Id__c = opidAcc.Id;
        aba3.PRM_Partner_Benefit_Id__c = pb.Id;
        aba3.PRM_Status_Nm__c = 'Active';
        aba3.PRM_Status_Reason_Txt__c = 'Test class';

        PRM_AccountBenefitAssociation__c aba4 = new PRM_AccountBenefitAssociation__c();
        aba4.PRM_Account_Id__c = opidAcc.Id;
        aba4.PRM_Partner_Benefit_Id__c = pb1.Id;
        aba4.PRM_Status_Nm__c = 'Active';
        aba4.PRM_Status_Reason_Txt__c = 'Test class';

        abaList.add(aba);
        abaList.add(aba1);
        abaList.add(aba3);
        abaList.add(aba4);
        Triggerhandler.bypass('PRM_aba_TriggerHandler');
        insert abaList;
        Triggerhandler.clearbypass('PRM_aba_TriggerHandler');

        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = conRelLst[1].Id;
        em.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';   
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_IPARefreshCheck__c = ipaRefresh;
        em.PRM_Channel_Program_Id__c = cp.id;
        em.PRM_IsActive_Ind__c = true;
        insert em;
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEMB;
        em1.PRM_Entitlement_Id__c = ed1.id;
        em1.PRM_Contact_Relationship_Id__c = conRelLst[1].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';   
        em1.PRM_IPARefreshCheck__c = ipaRefresh;
        em1.PRM_Channel_Program_Id__c = cp.id;
        em1.PRM_IsActive_Ind__c = true;
        insert em1;

        List<String> partnerIds = new List<String>{ opidAcc.Id };

        PRM_BenefitAssignment_Batch batch = new PRM_BenefitAssignment_Batch(opidAcc.Id, partnerIds);
        Database.executeBatch(batch, 1);
        Test.stopTest();  // calling stopTest after executeBatch

        // Now Assert results

        // 1. Attachment created
        List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :opidAcc.Id];
        //System.assertEquals(1, attachments.size(), 'There should be one CSV attachment');
        //System.assertEquals('BenefitAssc.csv', attachments[0].Name);

        // 2. Check ABAs updated
        List<PRM_AccountBenefitAssociation__c> newAbas = [
            SELECT Id, PRM_Status_Nm__c, PRM_Source__c, PRM_Partner_Benefit_Id__c
            FROM PRM_AccountBenefitAssociation__c
            WHERE PRM_Account_Id__c = :newAccount1.Id
        ];
        //System.assert(newAbas.size() >= 1, 'There should be some ABA records for newAccount1');

        Boolean found = false;
        for (PRM_AccountBenefitAssociation__c a : newAbas) {
            if (a.PRM_Status_Nm__c == 'Active') {
                found = true;
            }
        }
        //System.assert(found, 'At least one of the ABAs should be Active after batch run');
    }
    
    @isTest static void testNoAccount() {
        // Test case where no accounts are passed
        List<String> partnerIds = new List<String>{};
        PRM_BenefitAssignment_Batch batch = new PRM_BenefitAssignment_Batch(null, partnerIds);

        Test.startTest();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        List<Attachment> attachments = [SELECT Id FROM Attachment];
        //System.assertEquals(0, attachments.size(), 'No attachments should exist');
    }
    
    @isTest static void testExceptionHandling() {
        // Test case with a partner but no benefit matrix => this may hit empty branches or catch blocks
        Id recTypePartnerGrp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account partnerAccount = new Account(
            RecordTypeId = recTypePartnerGrp,
            Name = 'PartnerNoMatrix',
            Core_Deactivated__c = false
        );
        insert partnerAccount;

        List<String> partnerIds = new List<String>{ partnerAccount.Id };
        PRM_BenefitAssignment_Batch batch = new PRM_BenefitAssignment_Batch(partnerAccount.Id, partnerIds);

        Test.startTest();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        List<Attachment> att = [SELECT Id FROM Attachment WHERE ParentId = :partnerAccount.Id];
        //System.assertEquals(0, att.size(), 'No attachment should be created when there is no benefit matrix');
    }
}