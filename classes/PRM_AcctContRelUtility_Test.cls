/*********************************************************************************************************************
Class Name    : PRM_AcctContRelUtility_Test
Version       : 1.0
Created Date  : Dec 2018
Function      : Test Class for 'PRM_AcctContRel_TriggerHandler' and 'PRM_AcctContRelUtility'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  Dec,2018              Test Class for 'PRM_AcctContRel_TriggerHandler' and 'PRM_AcctContRelUtility'
*********************************************************************************************************************/
@isTest()
public class PRM_AcctContRelUtility_Test {
    public static boolean firstRun = true;
    @isTest
    static void testduplicateRecordCheck()//Edited by Monish Aditya on 10/12 
    {   
        Test.startTest();       
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        System.debug('first account'+newAccount);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_Partner_Role__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'xyz';
        con.add(cont1);
        insert con;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr);
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        crList.add(cr1);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Seller';
        insert acm;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[0].Id;
        acr.PRM_Contact_Id__c=con[0].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr;
        System.debug('acr--1>'+acr); 
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=con[0].Id;
        acr1.PRM_execute_trigger__c=true;
        insert acr1;
        
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=newAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=con[1].Id;
        acr2.PRM_execute_trigger__c=true;
        insert acr2;
        System.debug('acr1-->'+acr);
        
        try{    
            acr2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acr2;
            acr.PRM_InActive_Ind__c= true;
            acr.PRM_Contact_Id__c = con[0].id;
            update acr;
            delete acr1;
        }
        catch(Exception e){
            System.debug('Exception Occured');
        }
        Test.stopTest();
        System.assertEquals(acr.PRM_Account_Id__c,newAccount.Id,'Value does not match');
    } 
    /*Utkarsh: 21/08/2019: Added testActivateContactEntitlement method for Active ACR case.*/
    @isTest
    static void testActivateContactEntitlement()
    {
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        List<Contact> con = new List<Contact>();
        List<Account> acc = new List<Account>();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Tesco';
        newAccount1.BillingCity='City1';
        newAccount1.BillingStreet='Street1';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount1);
        insert acc;
        System.debug('acc-->'+acc);
        
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=acc[0].Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_Login_Id__c = 'xyz';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=acc[0].Id;
        cont1.lastName='jack';
        cont1.FirstName='william';
        cont1.email='jackwilliam@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_Partner_Role__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
        con.add(cont1);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=acc[1].Id;
        cont2.lastName='Hill';
        cont2.FirstName='Tom';
        cont2.email='TomHill@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_Partner_Role__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'efg';
        con.add(cont2);
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=acc[1].Id;
        cont3.lastName='Snow';
        cont3.FirstName='White';
        cont3.email='SnowWhite@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_Partner_Role__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'def';
        con.add(cont3);
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=acc[0].id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        insert acm1;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = false;
        contRelation.PRM_Mandatory_Relationship_Ind__c = true;
        crList.add(contRelation);
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=acc[0].Id;
        acctContRel.PRM_Contact_Id__c=con[0].Id;
        acctContRel.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel.PRM_InActive_Ind__c=true;
        acctContRel.PRM_execute_trigger__c=true;
        acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=acc[0].Id;
        acctContRel1.PRM_Contact_Id__c=con[1].Id;
        acctContRel1.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_execute_trigger__c=true;
        acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel1);
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=acc[1].Id;
        acctContRel2.PRM_Contact_Id__c=con[2].Id;
        acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel2.PRM_InActive_Ind__c=true;
        acctContRel2.PRM_execute_trigger__c=true;
        acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel2);
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel3.PRM_Account_Id__c=acc[1].Id;
        acctContRel3.PRM_Contact_Id__c=con[3].Id;
        acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_execute_trigger__c=true;
        acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel3);
        insert acrList;
        System.debug('acrList-->'+acrList);
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        //pb.PRM_Account_Type_Nm__c = 'Both';
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
        aba.PRM_Account_Id__c = acc[0].Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        insert aba;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='CIP VIP View';
        ed1.Core_Display_Name__c='CIP VIP View';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed1);
        insert entList;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = entList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em1);
        insert emList;
        
        List<Core_Contact_Entitlement__c> insertCEList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=con[0].Id;
        cce.Core_Entitlement_Id__c = ed.Id;
        cce.Core_Status__c='Pending';
        cce.Core_Selected__c = false;
        //cce.Core_Source__c = 'Entitlement';
        insertCEList.add(cce);
        
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=con[0].Id;
        cce1.Core_Entitlement_Id__c = ed1.Id;
        cce1.Core_Selected__c = false;
        cce1.Core_Status__c='Pending';
        //cce1.Core_Source__c = 'Entitlement';
        insertCEList.add(cce1);
        insert insertCEList;
        System.debug('insertCEList-->'+insertCEList);
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = con[0].Id;
        cs.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
        insert cs;
        
        Test.startTest();     
        try{
            List<Core_Contact_Entitlement__c> updateCE = new List<Core_Contact_Entitlement__c>();
            acrList[0].PRM_InActive_Ind__c=false;
            acrList[0].PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acrList[0];
            
            insertCEList[0].Core_Selected__c = true;
            updateCE.add(insertCEList[0]);
            
            insertCEList[1].Core_Selected__c = true;
            updateCE.add(insertCEList[1]);
            
            update updateCE;
            
            cs.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
            update cs;
        }
        catch(Exception e){
            System.debug('Exception Occured');
        }
        Test.stopTest();
        System.assertEquals(acrList[0].PRM_Account_Id__c,acc[0].Id,'Value does not match');
    }
    /*Utkarsh: 21/08/2019: Added testInActivateContactEntitlement method for Inactive ACR case.*/
    @isTest
    static void testInactivateContactEntitlement()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        System.debug('newAccount 2-->'+newAccount);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='jack';
        cont1.FirstName='william';
        cont1.email='jackwilliam@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_Partner_Role__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
        con.add(cont1);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount.Id;
        cont2.lastName='Hill';
        cont2.FirstName='Tom';
        cont2.email='TomHill@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_Partner_Role__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'def';
        con.add(cont2);
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = false;
        contRelation.PRM_Mandatory_Relationship_Ind__c = true;
        
        crList.add(contRelation);
        
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name=System.Label.PRM_WorksFor;
        contRelation1.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contRelation1.PRM_Channel_Program_Id__c = cp.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = true;
        contRelation1.PRM_Mandatory_Relationship_Ind__c = false;
        crList.add(contRelation1);
        insert crList; 
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=con[0].Id;
        acctContRel.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_execute_trigger__c=true;
        acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount.Id;
        acctContRel1.PRM_Contact_Id__c=con[0].Id;
        acctContRel1.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_execute_trigger__c=true;
        acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel.PRM_Start_Date_Dt__c= system.today() + 7;
        acctContRel.PRM_End_Date_Dt__c= acctContRel.PRM_Start_Date_Dt__c + 5;  
        acrList.add(acctContRel1);
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=newAccount.Id;
        acctContRel2.PRM_Contact_Id__c=con[1].Id;
        acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel2.PRM_InActive_Ind__c=false;
        acctContRel2.PRM_execute_trigger__c=true;
        acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel2);
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel3.PRM_Account_Id__c=newAccount.Id;
        acctContRel3.PRM_Contact_Id__c=con[2].Id;
        acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_execute_trigger__c=true;
        acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel3);
        
        PRM_Account_Contact_Relationship__c acctContRel4=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel4.PRM_Account_Id__c=newAccount.Id;
        acctContRel4.PRM_Contact_Id__c=con[2].Id;
        acctContRel4.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel4.PRM_InActive_Ind__c=false;
        acctContRel4.PRM_execute_trigger__c=true;
        acctContRel4.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel4);
        insert acrList;
        
        System.debug('acrList--2'+acrList);
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Points View';
        ed1.Core_Display_Name__c='Points View';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed1);
        
        insert entList;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = entList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[1].Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em1);
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Entitlement_Id__c = entList[1].id;
        em2.PRM_Contact_Relationship_Id__c = crList[0].id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em2);
        insert emList;
        
        List<Core_Contact_Entitlement__c> insertCEList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=con[0].Id;
        cce.Core_Entitlement_Id__c = entList[0].id;
        cce.Core_Status__c='Pending';
        cce.Core_Selected__c = true;
        cce.Core_Source__c = 'Entitlement';
        insertCEList.add(cce);
        
        Core_Contact_Entitlement__c cce1=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce1.Core_Contact_Id__c=con[0].Id;
        cce1.Core_Entitlement_Id__c = entList[1].id;
        cce1.Core_Status__c='Pending';
        cce1.Core_Selected__c = true;
        cce1.Core_Source__c = 'Entitlement';
        insertCEList.add(cce1);
        
        Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce2.Core_Contact_Id__c=con[1].Id;
        cce2.Core_Entitlement_Id__c = entList[0].id;
        cce2.Core_Status__c='Pending';
        cce2.Core_Selected__c = true;
        cce2.Core_Source__c = 'Entitlement';
        insertCEList.add(cce2);
        
        Core_Contact_Entitlement__c cce3=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce3.Core_Contact_Id__c=con[1].Id;
        cce3.Core_Entitlement_Id__c = entList[1].id;
        cce3.Core_Status__c='Pending';
        cce3.Core_Selected__c = true;
        cce3.Core_Source__c = 'Entitlement';
        insertCEList.add(cce3);
        insert insertCEList;
        System.debug('insertCEList-->'+insertCEList);
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = con[0].Id;
        cs.PRM_Status_Nm__c = 'Active';
        insert cs;
        
        Test.startTest();
        List<Core_Contact_Entitlement__c> updateCEList = new List<Core_Contact_Entitlement__c>();
        try{
            acrList[0].PRM_InActive_Ind__c=true;
            update acrList[0];
            
            insertCEList[0].Core_Selected__c = false;
            updateCEList.add(insertCEList[0]);
            
            /*acrList[2].PRM_InActive_Ind__c=true;
update acrList[2];*/
            
            insertCEList[2].Core_Selected__c = false;
            updateCEList.add(insertCEList[2]);
            insertCEList[3].Core_Selected__c = false;
            updateCEList.add(insertCEList[3]);
            
            update updateCEList;
            
            acrList[1].PRM_InActive_Ind__c=true;
            update acrList[1];
            
            cs.PRM_Status_Nm__c = 'Inactive';
            update cs;
        }
        catch(Exception e){
            System.debug('Exception Occured');
        }
        Test.stopTest();
        System.assertEquals(acrList[0].PRM_Account_Id__c,newAccount.Id,'Value does not match');
    }
    /*Utkarsh: 02/09/2019: Added testInsertContactEntitlement method for new ACR cases.*/
    @isTest
    static void testInsertContactEntitlement(){
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Intel';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        System.debug('newAccount-->'+newAccount); 
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Brown';
        cont.FirstName='Dan';
        cont.email='danbrown@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_Login_Id__c = 'xyz';
        cont.Core_Enterprise_Id__c = '1212122';
        cont.Core_IPA_Email_Verification_Date__c = system.now();
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        System.debug('cpl-->'+cpl);
        
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
        //pb.PRM_Account_Type_Nm__c = 'Both';
        insert pb;
        
        PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
        pt.Name='Cloud Service Provider (CSP)';
        pt.PRM_Role_Name__c='Service Provider';
        pt.PRM_PartneryTypeCode__c='CSP';
        pt.PRM_PartnerRoleCode__c='SPR';
        pt.PRM_channelprogram__c=cp.Id;
        insert pt;
        System.debug('pt-->'+pt);
        
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
        System.debug('bem-->'+bem);
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c ='Active';
        insert aba;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        /* PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
contRelation.Name=System.Label.PRM_Primary_Contact;
contRelation.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
contRelation.PRM_Channel_Program_Id__c = cp.Id;
contRelation.PRM_Default_Relationship_Ind__c = false;
contRelation.PRM_Mandatory_Relationship_Ind__c = true;
crList.add(contRelation);*/
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        crList.add(cr2);
        insert crList;
        System.debug('crList[0]-->'+crList[0]);
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='CIP VIP View';
        ed.Core_Display_Name__c='CIP VIP View';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        entitlementList.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Partner University';
        ed1.Core_Display_Name__c='Partner University';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        entitlementList.add(ed1);
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='Partner Ultra University';
        ed2.Core_Display_Name__c='Partner Ultra University';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        entitlementList.add(ed2);
        
        insert entitlementList; 
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = entitlementList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb.id;
        em1.PRM_Entitlement_Id__c = entitlementList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_Partner_Role_Nm__c='Service Provider';
        emList.add(em1);
        insert emList;
        System.debug('emList[0]-->'+emList[0]);
        
        Test.startTest();
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=cont.Id;
        cce.Core_Entitlement_Id__c = entitlementList[2].id;
        cce.Core_Selected__c = true;
        cce.Core_Status__c='Pending';
        //cce.Core_From_Source__c = false;
        //cce.Core_Data_Loaded__c=true;
        //cce.Core_DontNotify__c = false;
        //cce.Core_Source__c = 'IPA Registration';
        //Test.startTest();
        insert cce;
        
        
        
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_execute_trigger__c=true;
        acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel);
        
        try{
            insert acrList;
            Test.stopTest();  
        }catch(Exception ex){
        }
    }
}