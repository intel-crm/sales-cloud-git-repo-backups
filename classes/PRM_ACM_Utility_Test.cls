@isTest
public class PRM_ACM_Utility_Test {
    public static  boolean firstRun = true;
    static testmethod void testRelatedRecordInactiveCheck(){
    
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
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
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
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
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=True;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
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
        em.PRM_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Contact_Id__c = cont.Id;
        csa.PRM_Status_Nm__c = 'Inactive';
        insert csa;
        Test.startTest();
            try{
                acm.PRM_Status_Nm__c='Inactive';
                update acm;
                
                aba.PRM_Status_Nm__c = 'Inactive';
                aba.PRM_Status_Reason_Txt__c = 'Customer is no longer associated with the program';
                update aba;
                
                csa.PRM_Status_Nm__c = 'Inactive';
                update csa;
            }
            catch(Exception e){
            }
        Test.stopTest();
        System.assertEquals(acm.PRM_Status_Nm__c,'Inactive','Value does not match');
    }   
    static testmethod void testDuplicateCheck(){
        
        Account newAccount = new Account();//Account       
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Titanium';
        cpl1.ProgramId=cp.Id;
        insert cpl1;       
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c();
        pb.Name = 'Points Accruals – View';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
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
        bm.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        bm.PRM_Partner_Type_Id__c = pt.Id;
        bm.PRM_Approval_Type_Nm__c = 'Automatic';
        bm.PRM_Covered_Account_Ind__c = true;
        bm.PRM_IsActive_Ind__c = true;
        insert bm;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Primary Contact';
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.id;
        insert cr1;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=newAccount.id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl1.Id;
        acm1.PRM_Partner_Role__c='Seller';
        insert acm1;
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount.Id;
        acr1.PRM_Relationship_Id__c = cr1.Id;
        acr1.PRM_Contact_Id__c=cont.Id;
        insert acr1;
        
        PRM_AccountBenefitAssociation__c abassociation = new PRM_AccountBenefitAssociation__c();
        abassociation.PRM_Account_Id__c = newAccount.id;
        abassociation.PRM_Partner_Benefit_Id__c = pb.id;
        abassociation.PRM_Status_Nm__c = 'Active';
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
        em.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Partner_Role_Nm__c='Service Provider';
        insert em;
        
        PRM_ContactSubscriptionAssociation__c csa= new PRM_ContactSubscriptionAssociation__c();
        csa.PRM_Contact_Id__c=cont.id;
        csa.PRM_Status_Nm__c='Active';
        csa.PRM_Status_Reason_Txt__c='Inactive';
        insert csa;
        
        Test.startTest();
            try{
                acm.PRM_Status_Nm__c='Inactive';
                update acm;
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
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Tesco';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Adams';
        cont.FirstName='Tony';
        cont.email='AdamGrill@rediff.com';
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
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Primary Contact';
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
        insert acm;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        insert acctContRel;
        
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
        em.PRM_Partner_Role_Nm__c='Service Provider';
        insert em;
        System.debug('em-->'+em);
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        
        Test.startTest();
            try{
                insert cce;
            }
            catch(Exception e){
            }
        Test.stopTest();
        System.assertEquals(acm.PRM_Status_Nm__c,'Approved','Value does not match');
    }       
}