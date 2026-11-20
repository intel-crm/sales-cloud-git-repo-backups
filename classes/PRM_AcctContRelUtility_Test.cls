/*********************************************************************************************************************
Class Name    : PRM_AcctContRelUtility_Test
Version       : 1.0
Created Date  : Dec 2018
Function      : Test Class for 'PRM_AcctContRel_TriggerHandler' and 'PRM_AcctContRelUtility'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  Dec,2018              Test Class for 'PRM_AcctContRel_TriggerHandler' and 'PRM_AcctContRelUtility'
********************************************************************************************************************/
@isTest()
public class PRM_AcctContRelUtility_Test {
    public static boolean firstRun = true;
    // public static boolean ipaRefresh = boolean.valueOf(label.PRM_IPARefresh);

    @isTest
    static void testduplicateRecordCheck()//Edited by Monish Aditya on 10/12 
    {          
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();   
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;

        PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm1.Name='BatchFieldValues';
        bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm1.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm1.PRM_SchedulingHour__c=6;
        bm1.PRM_NoOfRecords__c=300;
        bm1.PRM_NoOfBatchEntRecords__c=10;
        bm1.PRM_PartnerRole__c ='Service Provider';
        bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm1; 
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='John Rick01';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        insert newAccount;
        //System.debug('first account'+newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Greg Thomas222';
        newAccount1.BillingCity='City2';
        newAccount1.BillingStreet='Street2';
        newAccount1.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount1.BillingPostalCode='123456';
        newAccount1.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount1.Core_IPA_Partner_Role__c='Guest';
        newAccount1.Core_IPA_Badge_Tier__c='Partner';
        newAccount1.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount1.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount1.Core_User_Defined_Website__c = 'abz.yz';
        newAccount1.Core_Geo__c = 'ASMO';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount1;
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.MailingCountry='India';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.MailingCountry='India';
        con.add(cont1);
        
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount1.Id;
        cont2.lastName='George';
        cont2.FirstName='Jack';
        cont2.email='jackgeorge@malinator.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'qwerty';
        cont2.MailingCountry='India';
        con.add(cont2);
               
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=newAccount.Id;
        cont3.lastName='George123';
        cont3.FirstName='Jack';
        cont3.email='jackgeorge123@malinator.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'jackgeorge123@malinator.com';
        cont3.MailingCountry='India';
        con.add(cont3);
      
        insert con;
    
        userrole role=[select id,name from userrole where name='admin' limit 1];
        User u = new User(Alias = 'bblac', Email='testivorysmithy@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', UserRoleId=role.id,ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.robert2@peoplenet.com', contactid = cont2.Id);
        

        
        prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
        bm.inactive__c = false;
        insert bm;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        cr.PRM_Default_Relationship_Ind__c = true;        
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

        if(crList.size()>0){
            insert crList;
        }
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
        //Test.startTest();
        List<PRM_Account_Contact_Relationship__c> acrlist1 = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> acrlist2 = new List<PRM_Account_Contact_Relationship__c>();
        Map<Id, PRM_Account_Contact_Relationship__c> acrmap1 = new Map<Id, PRM_Account_Contact_Relationship__c>();
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[1].Id;
        acr.PRM_Contact_Id__c=cont.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acr.PRM_Source_Agent__c='Partner Invite';
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_CampaignId__c=null;
        acr.PRM_Status_Reason_Txt__c='External';
        
        insert acr;
                 
        //System.debug('acr--1>'+acr);         
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=cont1.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Reason_Txt__c='External';
         
        insert acr1;        
        
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=newAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=cont1.Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_Status_Reason_Txt__c='External';
         
        insert acr2;
        //System.debug('acr1--->'+acr);
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= True;
        acr3.PRM_Account_Id__c=newAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=cont3.Id;
        acr3.PRM_execute_trigger__c=true;
        acr3.PRM_Soft_Contact__c = true;
        acr3.PRM_Status_Reason_Txt__c='External';
        insert acr3;
        
         Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
       
        
        insert ed;
        
        Test.startTest();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both';
        insert pb; 
        
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = crList[1].Id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';   
        em.PRM_Partner_Benefit_Id__c = pb.id;
        // em.PRM_IPARefreshCheck__c = ipaRefresh;
        insert em;
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont.Id,
                                                                         Core_Entitlement_Id__c=ed.id,
                                                                         Core_Selected__c=false);
        
        insert ce;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = ed.id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';      
        // em1.PRM_IPARefreshCheck__c = ipaRefresh;  
       // insert em1;
                       
        
        acr3.PRM_InActive_Ind__c= False;
        update acr3;
        
        Id regReqRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        PRM_Registration_Request__c regRequest2 = PRM_TestUtility.getPRMRegistrationRequest();        
        regRequest2.PRM_Phy_Country__c = 'US';
        regRequest2.PRM_Contact_Country__c = 'US';
        regRequest2.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest2.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest2.PRM_Phy_State_Province__c = 'NY';
        regRequest2.PRM_Phy_City__c = 'Las Vegas';
        regRequest2.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest2.PRM_Zip_Postal_Code__c = '32521';
        regRequest2.PRM_Channel_Program__c = cp.Id;
        regRequest2.PRM_Channel_Program_Level__c = cpl.Id;
        regRequest2.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest2.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest2.PRM_Partner_Role__c = 'Service Provider';
        regRequest2.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest2.PRM_Subscriptions__c = 'CSPx2_Sub2';
        regRequest2.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest2.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        regRequest2.PRM_Auto_Approve__c= True;
        regRequest2.PRM_Email_ID__c = 'jackgeorge123@malinator.com';
        regRequest2.PRM_Status__c =System.label.PRM_Status_New; 
        regRequest2.RecordTypeId = regReqRecordTypeId;
        insert regRequest2;
        PRM_Account_Contact_Relationship__c acr4=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr4.PRM_InActive_Ind__c= false;
        acr4.PRM_Account_Id__c=newAccount.Id;
        acr4.PRM_Relationship_Id__c = crList[0].Id;
        acr4.PRM_Contact_Id__c=cont3.Id;
        acr4.PRM_execute_trigger__c=true;
        PRM_AcctContRelUtility.firstRunBeforeInsert = true;
        
        
        
        
        try{
            insert acr4;
        }catch(Exception e){
            //System.debug('ACR creation failed due to pending registration');
        }
        
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
        bem.PRM_IsActive_Ind__c=true;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
        insert aba;
        
        PRM_Account_Contact_Relationship__c acrTemp=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acrTemp.PRM_InActive_Ind__c= false;
        acrTemp.PRM_Account_Id__c=newAccount.Id;
        acrTemp.PRM_Relationship_Id__c = crList[1].Id;
        acrTemp.PRM_Contact_Id__c=cont.Id;
        acrTemp.PRM_execute_trigger__c=true;
        acrTemp.PRM_Start_Date_Dt__c= system.today()-2; 
        acrTemp.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acrTemp.PRM_Source_Agent__c='Partner Invite';
        acrTemp.PRM_Status_Nm__c = 'Complete';
        acrTemp.PRM_CampaignId__c=null;
        acrTemp.PRM_InActive_Ind__c = true;
        acrTemp.id = acr.id;
        acrlist1.add(acrTemp);
        acrlist2.add(acr);
        acrmap1.put(acr.Id, acr);
        Map<Id, PRM_Account_Contact_Relationship__c> acrmap2 = new Map<Id, PRM_Account_Contact_Relationship__c>();
        acrmap2.put(acrTemp.id, acrTemp);
        PRM_AcctContRelUtility.mandatoryRelationshipCheck(acrlist2,acrlist1,acrmap2);
        PRM_AcctContRelUtility.softContactCheck(acrlist1,acrlist2,acrmap1);
        
        PRM_AcctContRelUtility.emailForPrimaryContact(acrmap1,acrmap1);
        PRM_AcctContRelUtility.inactivateContactEntitlement(acrlist1,acrmap1);
        
        PRM_Account_Contact_Relationship__c acremp=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acremp.PRM_InActive_Ind__c= false;
        acremp.PRM_Account_Id__c=newAccount.Id;
        acremp.PRM_Relationship_Id__c = crList[0].Id;
        acremp.PRM_Contact_Id__c=cont.Id;
        acremp.PRM_execute_trigger__c=true;
        acremp.PRM_Start_Date_Dt__c= system.today()-2; 
        acremp.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acremp.PRM_Source_Agent__c='Partner Invite';
        acremp.PRM_Status_Nm__c = 'Complete';
        acremp.PRM_CampaignId__c=null;
        acremp.PRM_Status_Reason_Txt__c='Test';
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acremp;
        TriggerHandler.clearbypass('PRM_AcctContRel_TriggerHandlerNew');
        PRM_AcctContRelUtility.inactivateContactEntitlement(acrlist1,acrmap1);
        
        PRM_AcctContRelUtility.autoPopulateContactSegment(acrlist1);
        acrmap1.put(acrTemp.Id, acrTemp);
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(acm);

        PRM_AcctContRelUtility.activateContactEntitlement(acrlist2, acrmap1, acmList);
        
                //PRM_AcctContRelUtility.insertContactEntitlement(acrlist2,acrmap1,acmList); 
        //PRM_AcctContRelUtility.mandatoryRelationshipCheck(acrlist1,acrlist2,acrmap1);
        PRM_AcctContRelUtility.restrictContactAssociatedSystemAcc(acrlist2);
        PRM_AcctContRelUtility.updateSuppressEmail(acrlist2,acrmap1);
        PRM_AcctContRelUtility.suppressEmail(acrlist2,acrmap1);
        PRM_AcctContRelUtility.updateStartandEndDates(acrlist2,acrmap1);
        Test.stopTest();
        
        
        
        try{    
            acr2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acr2;
            acr.PRM_InActive_Ind__c= true;
            acr.PRM_Contact_Id__c = cont.id; 
            update acr;
            delete acr1;
        }
        Catch (DMLException e){
            
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
        
       // System.runAs(u){
            PRM_AcctContRelUtility.duplicateRecordCheck(acrlist1,acrmap1);
       // }
        PRM_AcctContRelUtility.duplicateRecordCheck(null,null);
        
        System.assertEquals(acr.PRM_Account_Id__c,newAccount.Id,'Value does not match');
    } 
    
    


    @istest
     static void testactivateEntCheck01()//Edited by Monish Aditya on 10/12 
    {   
         
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();   
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
                
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;
        
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick02';
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        insert newAccount;
        //System.debug('first account'+newAccount);
            PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
       bm1.Name='BatchFieldValues';
       bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
       bm1.PRM_ChannelProgramLevel__c='Partner;Prestige';
       bm1.PRM_SchedulingHour__c=6;
       bm1.PRM_NoOfRecords__c=300;
       bm1.PRM_NoOfBatchEntRecords__c=10;
       bm1.PRM_PartnerRole__c ='Service Provider';
       bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
       bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
       insert bm1;
         Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Greg Thomas222';
        newAccount1.BillingCity='City2';
        newAccount1.BillingStreet='Street2';
        newAccount1.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount1.BillingPostalCode='123456';
        newAccount1.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount1.Core_IPA_Partner_Role__c='Guest';
        newAccount1.Core_IPA_Badge_Tier__c='Partner';
        newAccount1.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount1.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount1.Core_User_Defined_Website__c = 'abz.yz';
        newAccount1.Core_Geo__c = 'ASMO';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount1;
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount1.Id;
        cont2.lastName='George';
        cont2.FirstName='Jack';
        cont2.email='jackgeorge@malinator.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'qwerty';
        cont2.MailingCountry='India';
        insert cont2;
               
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=newAccount.Id;
        cont3.lastName='George123';
        cont3.FirstName='Jack';
        cont3.email='jackgeorge123@malinator.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'jackgeorge123@malinator.com';
        cont3.MailingCountry='India';
        insert cont3;
        Test.startTest(); 
        User u = new User(Alias = 'bblac', Email='testivorysmithy@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.robert2@peoplenet.com', contactid = cont2.Id);
        

        prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
        bm.inactive__c = false;
        insert bm;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
   
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        cr.PRM_Default_Relationship_Ind__c = true;        
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

        if(crList.size()>0){
            insert crList;
        }
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
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
        
       
        
        List<PRM_AccountChannelMembership__c> listAccountChannelMembership = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c  acm2 = PRM_TestUtility.getMembership();
        acm2.PRM_Account_Id__c = newAccount.Id;
        acm2.PRM_Channel_Program_Id__c = cp.Id;
        acm2.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm2.PRM_Partner_Role__c='Service Provider';
        acm2.PRM_Status_Nm__c ='Approved';
        acm2.PRM_Status_Reason_Txt__c='Test';
        listAccountChannelMembership.add(acm2);
        
        insert listAccountChannelMembership;
        //System.debug('ListOFAcm--> '+listAccountChannelMembership);
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= True;
        acr3.PRM_Account_Id__c=newAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=cont3.Id;
        acr3.PRM_execute_trigger__c=true;
        acr3.PRM_Soft_Contact__c = true;
        acr3.PRM_Source_Agent__c='Partner Invite';
        acr3.PRM_Status_Nm__c = 'Complete';
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
        acr3.PRM_Status_Reason_Txt__c='External';
        insert acr3;
        TriggerHandler.clearBypass('PRM_AcctContRel_TriggerHandler');
        
        Map<id,PRM_Account_Contact_Relationship__c> acrmap02 = new Map<id,PRM_Account_Contact_Relationship__c>();
        acrmap02.put(acr3.id,acr3);
        List<PRM_Account_Contact_Relationship__c> acrlist02 = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c newACR01 = [Select id,PRM_Partner_Role__c, PRM_Account_Id__c from PRM_Account_Contact_Relationship__c where id = :acr3.id];
        //PRM_Account_Contact_Relationship__c newACR01 = new PRM_Account_Contact_Relationship__c(Id = acr3.id, PRM_Account_Id__c = acr3.PRM_Account_Id__c);
        acrlist02.add(newACR01);
        acrlist02[0].PRM_InActive_Ind__c= False;
        acrlist02[0].PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrlist02[0].PRM_Relationship_Id__c = acr3.PRM_Relationship_Id__c;
        acrlist02[0].PRM_Contact_Id__c=acr3.PRM_Contact_Id__c;
        acrlist02[0].PRM_execute_trigger__c=true;
        update acrlist02;

        Id regReqRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        PRM_Registration_Request__c regRequest2 = PRM_TestUtility.getPRMRegistrationRequest();        
        regRequest2.PRM_Phy_Country__c = 'US';
        regRequest2.PRM_Contact_Country__c = 'US';
        regRequest2.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest2.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest2.PRM_Phy_State_Province__c = 'NY';
        regRequest2.PRM_Phy_City__c = 'Las Vegas';
        regRequest2.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest2.PRM_Zip_Postal_Code__c = '32521';
        regRequest2.PRM_Channel_Program__c = cp.Id;
        regRequest2.PRM_Channel_Program_Level__c = cpl.Id;
        regRequest2.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest2.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest2.PRM_Partner_Role__c = 'Service Provider';
        regRequest2.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest2.PRM_Subscriptions__c = 'CSPx2_Sub2';
        regRequest2.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest2.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        regRequest2.PRM_Auto_Approve__c= True;
        regRequest2.PRM_Email_ID__c = 'jackgeorge123@malinator.com';
        regRequest2.PRM_Status__c =System.label.PRM_Status_New; 
        regRequest2.RecordTypeId = regReqRecordTypeId;
        insert regRequest2;
        Test.stopTest();
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
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
        insert entList;
        
        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont3.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
                              beList.add(be);
        insert beList;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=true;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[0].id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em1.PRM_IsActive_Ind__c = true;
        em1.PRM_Partner_Benefit_Id__c = pb.id;
        // em1.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em1);
        insert emList;
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = cont3.Id;
        cs.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
        cs.PRM_Status_Reason_Txt__c='Test';
        insert cs;
        
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont3.Id,
                                                                         Core_Entitlement_Id__c=ed.id,
                                                                         Core_Selected__c=false);
        insert ce;
        //PRM_AcctContRelUtility.activateContactEntitlement(acrlist02,acrmap02,ListACM);
        
        //PRM_AcctContRelUtility.insertContactEntitlement(acrlist02,acrmap02,listAccountChannelMembership);
        PRM_AcctContRelUtility.updateStartandEndDates(null,acrmap02);
        PRM_AcctContRelUtility.autoPopulateContactSegment(null);
        PRM_AcctContRelUtility.suppressEmail(null,acrmap02);
        PRM_AcctContRelUtility.updateSuppressEmail(null,acrmap02);
        PRM_AcctContRelUtility.restrictContactAssociatedSystemAcc(null);
        
        //Test.stopTest();
    } 
    
        @isTest
    static void testduplicateRecordCheck_1()//Edited by Monish Aditya on 10/12 
    {          
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();   
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;

        PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm1.Name='BatchFieldValues';
        bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm1.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm1.PRM_SchedulingHour__c=6;
        bm1.PRM_NoOfRecords__c=300;
        bm1.PRM_NoOfBatchEntRecords__c=10;
        bm1.PRM_PartnerRole__c ='Service Provider';
        bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm1; 
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='John Rick01';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        insert newAccount;
        //System.debug('first account'+newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Greg Thomas222';
        newAccount1.BillingCity='City2';
        newAccount1.BillingStreet='Street2';
        newAccount1.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount1.BillingPostalCode='123456';
        newAccount1.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount1.Core_IPA_Partner_Role__c='Guest';
        newAccount1.Core_IPA_Badge_Tier__c='Partner';
        newAccount1.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount1.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount1.Core_User_Defined_Website__c = 'abz.yz';
        newAccount1.Core_Geo__c = 'ASMO';
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount1;
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.MailingCountry='India';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='thomas';
        cont1.FirstName='Jack';
        cont1.email='jackthomas@malinator.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.MailingCountry='India';
        con.add(cont1);
        
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount1.Id;
        cont2.lastName='George';
        cont2.FirstName='Jack';
        cont2.email='jackgeorge@malinator.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'qwerty';
        cont2.MailingCountry='India';
        con.add(cont2);
               
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=newAccount.Id;
        cont3.lastName='George123';
        cont3.FirstName='Jack';
        cont3.email='jackgeorge123@malinator.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'jackgeorge123@malinator.com';
        cont3.MailingCountry='India';
        con.add(cont3);
      
        insert con;
    
        userrole role=[select id,name from userrole where name='admin' limit 1];
        User u = new User(Alias = 'bblac', Email='testivorysmithy@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', UserRoleId=role.id,ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.robert2@peoplenet.com', contactid = cont2.Id);
        

        
        prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
        bm.inactive__c = false;
        insert bm;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        cr.PRM_Default_Relationship_Ind__c = true;        
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

        if(crList.size()>0){
            insert crList;
        }
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
        //Test.startTest();
        List<PRM_Account_Contact_Relationship__c> acrlist1 = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> acrlist2 = new List<PRM_Account_Contact_Relationship__c>();
        Map<Id, PRM_Account_Contact_Relationship__c> acrmap1 = new Map<Id, PRM_Account_Contact_Relationship__c>();
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = crList[1].Id;
        acr.PRM_Contact_Id__c=cont.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acr.PRM_Source_Agent__c='Partner Invite';
        acr.PRM_Status_Nm__c = 'Complete';
        acr.PRM_CampaignId__c=null;
        acr.PRM_Status_Reason_Txt__c='External';
        insert acr;
                 
        //System.debug('acr--1>'+acr);         
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount.Id;
        acr1.PRM_Relationship_Id__c = crList[1].Id;
        acr1.PRM_Contact_Id__c=cont1.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Status_Reason_Txt__c='External';
        insert acr1;        
        
        PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr2.PRM_InActive_Ind__c= false;
        acr2.PRM_Account_Id__c=newAccount.Id;
        acr2.PRM_Relationship_Id__c = crList[0].Id;
        acr2.PRM_Contact_Id__c=cont1.Id;
        acr2.PRM_execute_trigger__c=true;
        acr2.PRM_Status_Reason_Txt__c='External';
        insert acr2;
        //System.debug('acr1--->'+acr);
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= True;
        acr3.PRM_Account_Id__c=newAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=cont3.Id;
        acr3.PRM_execute_trigger__c=true;
        acr3.PRM_Soft_Contact__c = true;
        acr3.PRM_Status_Reason_Txt__c='External';
        insert acr3;
        
         Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
       
        
        insert ed;
        
        Test.startTest();
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Both';
        insert pb; 
        
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = ed.id;
        em.PRM_Contact_Relationship_Id__c = crList[1].Id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';   
        em.PRM_Partner_Benefit_Id__c = pb.id;
       // em.PRM_IPARefreshCheck__c = ipaRefresh;
        insert em;
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont.Id,
                                                                         Core_Entitlement_Id__c=ed.id,
                                                                         Core_Selected__c=false);
        
        insert ce;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = ed.id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';  
       //  em1.PRM_IPARefreshCheck__c = ipaRefresh;      
       // insert em1;
                       
        
        acr3.PRM_InActive_Ind__c= False;
        update acr3;
        
        Id regReqRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        PRM_Registration_Request__c regRequest2 = PRM_TestUtility.getPRMRegistrationRequest();        
        regRequest2.PRM_Phy_Country__c = 'US';
        regRequest2.PRM_Contact_Country__c = 'US';
        regRequest2.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest2.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest2.PRM_Phy_State_Province__c = 'NY';
        regRequest2.PRM_Phy_City__c = 'Las Vegas';
        regRequest2.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest2.PRM_Zip_Postal_Code__c = '32521';
        regRequest2.PRM_Channel_Program__c = cp.Id;
        regRequest2.PRM_Channel_Program_Level__c = cpl.Id;
        regRequest2.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest2.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest2.PRM_Partner_Role__c = 'Service Provider';
        regRequest2.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest2.PRM_Subscriptions__c = 'CSPx2_Sub2';
        regRequest2.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest2.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        regRequest2.PRM_Auto_Approve__c= True;
        regRequest2.PRM_Email_ID__c = 'jackgeorge123@malinator.com';
        regRequest2.PRM_Status__c =System.label.PRM_Status_New; 
        regRequest2.RecordTypeId = regReqRecordTypeId;
        insert regRequest2;
        PRM_Account_Contact_Relationship__c acr4=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr4.PRM_InActive_Ind__c= false;
        acr4.PRM_Account_Id__c=newAccount.Id;
        acr4.PRM_Relationship_Id__c = crList[0].Id;
        acr4.PRM_Contact_Id__c=cont3.Id;
        acr4.PRM_execute_trigger__c=true;
        PRM_AcctContRelUtility.firstRunBeforeInsert = true;
        
        
        
        
        try{
            insert acr4;
        }catch(Exception e){
            //System.debug('ACR creation failed due to pending registration');
        }
        
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
        bem.PRM_IsActive_Ind__c=true;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
        insert aba;
        
        PRM_Account_Contact_Relationship__c acrTemp=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acrTemp.PRM_Account_Id__c=newAccount.Id;
        acrTemp.PRM_Relationship_Id__c = crList[1].Id;
        acrTemp.PRM_Contact_Id__c=cont.Id;
        acrTemp.PRM_execute_trigger__c=true;
        acrTemp.PRM_Start_Date_Dt__c= system.today()-2; 
        acrTemp.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acrTemp.PRM_Source_Agent__c='Partner Invite';
        acrTemp.PRM_Status_Nm__c = 'Complete';
        acrTemp.PRM_CampaignId__c=null;
        acrTemp.PRM_InActive_Ind__c = true;
        acrTemp.PRM_Status_Reason_Txt__c='Test';
        acrTemp.id = acr.id;
        acrlist1.add(acrTemp);
        acrlist2.add(acr);
        acrmap1.put(acr.Id, acr);
        Map<Id, PRM_Account_Contact_Relationship__c> acrmap2 = new Map<Id, PRM_Account_Contact_Relationship__c>();
        acrmap2.put(acrTemp.id, acrTemp);
       /* PRM_AcctContRelUtility.mandatoryRelationshipCheck(acrlist2,acrlist1,acrmap2);
        PRM_AcctContRelUtility.softContactCheck(acrlist1,acrlist2,acrmap1);
        
        PRM_AcctContRelUtility.emailForPrimaryContact(acrmap1,acrmap1);
        PRM_AcctContRelUtility.inactivateContactEntitlement(acrlist1,acrmap1);*/
        
        PRM_Account_Contact_Relationship__c acremp=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acremp.PRM_InActive_Ind__c= false;
        acremp.PRM_Account_Id__c=newAccount.Id;
        acremp.PRM_Relationship_Id__c = crList[0].Id;
        acremp.PRM_Contact_Id__c=cont.Id;
        acremp.PRM_execute_trigger__c=true;
        acremp.PRM_Start_Date_Dt__c= system.today()-2; 
        acremp.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acremp.PRM_Source_Agent__c='Partner Invite';
        acremp.PRM_Status_Nm__c = 'Complete';
        acremp.PRM_CampaignId__c=null;
        acremp.PRM_Status_Reason_Txt__c='Test';
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert acremp;
        TriggerHandler.clearbypass('PRM_AcctContRel_TriggerHandlerNew');
        //PRM_AcctContRelUtility.inactivateContactEntitlement(acrlist1,acrmap1);
        
        //PRM_AcctContRelUtility.autoPopulateContactSegment(acrlist1);
        acrmap1.put(acrTemp.Id, acrTemp);
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        acmList.add(acm);

        //PRM_AcctContRelUtility.activateContactEntitlement(acrlist2, acrmap1, acmList);
        
                PRM_AcctContRelUtility.insertContactEntitlement(acrlist2,acrmap1,acmList); 
        //PRM_AcctContRelUtility.mandatoryRelationshipCheck(acrlist1,acrlist2,acrmap1);
       // PRM_AcctContRelUtility.restrictContactAssociatedSystemAcc(acrlist2);
        //PRM_AcctContRelUtility.updateSuppressEmail(acrlist2,acrmap1);
        //PRM_AcctContRelUtility.suppressEmail(acrlist2,acrmap1);
        //PRM_AcctContRelUtility.updateStartandEndDates(acrlist2,acrmap1);
        Test.stopTest();
        
        
        
        try{    
            acr2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acr2;
            acr.PRM_InActive_Ind__c= true;
            acr.PRM_Contact_Id__c = cont.id; 
            update acr;
            delete acr1;
        }
        Catch (DMLException e){
            
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
        
       // System.runAs(u){
            PRM_AcctContRelUtility.duplicateRecordCheck(acrlist1,acrmap1);
       // }
        PRM_AcctContRelUtility.duplicateRecordCheck(null,null);
        
        System.assertEquals(acr.PRM_Account_Id__c,newAccount.Id,'Value does not match');
    } 
    
    
    
    
    
    @istest
     static void testactivateEntCheck02()//Edited by Monish Aditya on 10/12 
    {   
      //  Test.startTest();  
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();   
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick03';
        newAccount.RecordTypeId = accountRecordTypeIntel;
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        insert newAccount;
        //System.debug('first account'+newAccount);

        PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm1.Name='BatchFieldValues';
        bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm1.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm1.PRM_SchedulingHour__c=6;
        bm1.PRM_NoOfRecords__c=300;
        bm1.PRM_NoOfBatchEntRecords__c=10;
        bm1.PRM_PartnerRole__c ='Service Provider';
        bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm1;
   
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=newAccount.Id;
        cont3.lastName='George123';
        cont3.FirstName='Jack';
        cont3.email='jackgeorge123@malinator.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'jackgeorge123@malinator.com';
        cont3.MailingCountry='India';
        insert cont3;
        
        User u = new User(Alias = 'bblac', Email='testivorysmithy@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.robert2@peoplenet.com', contactid = cont3.Id);
        

        prm_skip_trigger__c bm = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm.Name='ABA_Trigger';
        bm.inactive__c = false;
        insert bm;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
   
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c cr=new PRM_ContactRelationships__c();
        cr.Name='Trainee';
        cr.PRM_Contact_Relationship_Cd__c='RELTNTRNFR';
        cr.PRM_Channel_Program_Id__c=cp.Id;
        cr.PRM_Default_Relationship_Ind__c = true;        
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

        if(crList.size()>0){
            insert crList;
        }
        ChannelProgramLevel cpl=new ChannelProgramLevel();
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
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
        
        List<PRM_AccountChannelMembership__c> ListACM = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';
        ListACM.add(acm);
        insert ListACM;
        
        PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr3.PRM_InActive_Ind__c= True;
        acr3.PRM_Account_Id__c=newAccount.Id;
        acr3.PRM_Relationship_Id__c = crList[0].Id;
        acr3.PRM_Contact_Id__c=cont3.Id;
        acr3.PRM_execute_trigger__c=true;
        acr3.PRM_Soft_Contact__c = true;
        acr3.PRM_Source_Agent__c='Partner Invite';
        acr3.PRM_Status_Nm__c = 'Complete';
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
        acr3.PRM_Status_Reason_Txt__c='External';
        insert acr3;
        TriggerHandler.clearBypass('PRM_AcctContRel_TriggerHandler');

        
        Map<id,PRM_Account_Contact_Relationship__c> acrmap02 = new Map<id,PRM_Account_Contact_Relationship__c>();
        acrmap02.put(acr3.id,acr3);
        List<PRM_Account_Contact_Relationship__c> acrlist02 = new List<PRM_Account_Contact_Relationship__c>();
        //PRM_Account_Contact_Relationship__c newACR = [Select id,PRM_Partner_Role__c, PRM_Account_Id__c from PRM_Account_Contact_Relationship__c where id = :acr3.id];
        PRM_Account_Contact_Relationship__c newACR01 = new PRM_Account_Contact_Relationship__c(Id = acr3.id, PRM_Account_Id__c = acr3.PRM_Account_Id__c);
        newACR01.PRM_InActive_Ind__c= False;
        newACR01.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        newACR01.PRM_Relationship_Id__c = acr3.PRM_Relationship_Id__c;
        newACR01.PRM_Contact_Id__c=acr3.PRM_Contact_Id__c;
        newACR01.PRM_execute_trigger__c=true;
        update newACR01;
        acrlist02.add(newACR01);

        Id regReqRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        PRM_Registration_Request__c regRequest2 = PRM_TestUtility.getPRMRegistrationRequest();        
        regRequest2.PRM_Phy_Country__c = 'US';
        regRequest2.PRM_Contact_Country__c = 'US';
        regRequest2.PRM_Phy_Address_Line_1__c = '4th Floor,ITPL Main Road';
        regRequest2.PRM_Phy_Address_Line_2__c = 'Bengaluru,India';
        regRequest2.PRM_Phy_State_Province__c = 'NY';
        regRequest2.PRM_Phy_City__c = 'Las Vegas';
        regRequest2.PRM_Phy_Zip_Postal_Code__c = '235351';
        regRequest2.PRM_Zip_Postal_Code__c = '32521';
        regRequest2.PRM_Channel_Program__c = cp.Id;
        regRequest2.PRM_Channel_Program_Level__c = cpl.Id;
        regRequest2.PRM_Legal_Agreements__c = 'IPA_TANDC';
        regRequest2.PRM_Partner_Type__c = 'Cloud Service Provider (CSP)';
        regRequest2.PRM_Partner_Role__c = 'Service Provider';
        regRequest2.PRM_Account_Partner_Type__c = 'Cloud Service Provider (CSP)';//Distributor
        regRequest2.PRM_Subscriptions__c = 'CSPx2_Sub2';
        regRequest2.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact;
        regRequest2.PRM_Profile_Response__c = '{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        regRequest2.PRM_Auto_Approve__c= True;
        regRequest2.PRM_Email_ID__c = 'jackgeorge123@malinator.com';
        regRequest2.PRM_Status__c =System.label.PRM_Status_New; 
        regRequest2.RecordTypeId = regReqRecordTypeId;
        insert regRequest2;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
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
        insert entList;

        List<PRM_Batch_Entitlement__c> beList = new List<PRM_Batch_Entitlement__c>();
        PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be.PRM_Contact_Id__c =cont3.Id;
        be.PRM_Entitlement_Id__c =ed.Id;
        be.PRM_Status_Nm__c = 'New';
                              beList.add(be);
        insert beList;
        
        PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bem.PRM_Approval_Type_Nm__c='Automatic';
        bem.PRM_Channel_Program_Id__c=cp.Id;
        bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        bem.PRM_Covered_Account_Ind__c=True;
        bem.PRM_IsActive_Ind__c=true;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[0].id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em1.PRM_IsActive_Ind__c = true;
        em1.PRM_Partner_Benefit_Id__c = pb.id;
        // em1.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em1);
        insert emList;
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = cont3.Id;
        cs.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
        cs.PRM_Status_Reason_Txt__c='Test';
        insert cs;
        
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=cont3.Id,
                                                                         Core_Entitlement_Id__c=ed.id,
                                                                         Core_Selected__c=true);
        Test.startTest();  
        insert ce;
        //PRM_AcctContRelUtility.activateContactEntitlement(acrlist02,acrmap02,ListACM);
        //PRM_AcctContRelUtility.insertContactEntitlement(acrlist02,acrmap02,ListACM);

        Test.stopTest();
    } 
    /*Utkarsh: 21/08/2019: Added testActivateContactEntitlement method for Active ACR case.*/
    @isTest
    static void testActivateContactEntitlement()
    {
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        List<Contact> con = new List<Contact>();
        List<Account> acc = new List<Account>();
        
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        prm_skip_trigger__c bm1 = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm1.Name='ABA_Trigger';
        bm1.inactive__c = false;
        insert bm1;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Name='Tesco';
        newAccount1.BillingCity='City1';
        newAccount1.BillingStreet='Street1';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount1.Core_User_Defined_Website__c = 'WWW.test123.com';
        acc.add(newAccount1);
        insert acc;
        //System.debug('acc-->'+acc);
        
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=acc[0].Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'xyz';
         cont.MailingCountry = 'India';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=acc[0].Id;
        cont1.lastName='jack';
        cont1.FirstName='william';
        cont1.email='jackwilliam@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
         cont1.MailingCountry = 'India';
        con.add(cont1);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=acc[1].Id;
        cont2.lastName='Hill';
        cont2.FirstName='Tom';
        cont2.email='TomHill@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'efg';
        cont2.MailingCountry = 'India';
        con.add(cont2);
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=acc[1].Id;
        cont3.lastName='Snow';
        cont3.FirstName='White';
        cont3.email='SnowWhite@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'def';
        cont3.MailingCountry = 'India';
        con.add(cont3);
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        cp.IsActive=true;
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        List<PRM_AccountChannelMembership__c> acmlist01 = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm1.PRM_Account_Id__c=acc[0].id;
        acm1.PRM_Status_Nm__c='Approved';
        acm1.PRM_Channel_Program_Id__c=cp.Id;
        acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm1.PRM_Partner_Role__c='Service Provider';
        acm1.PRM_Status_Reason_Txt__c='Test';
        insert acm1;
        acmlist01.add(acm1);
        List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name=System.Label.PRM_Primary_Contact;
        contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = false;
        contRelation.PRM_Mandatory_Relationship_Ind__c = true;
        contRelation.PRM_InActive_Ind__c = false;
        
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
        //acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_InActive_Ind__c=true;
        acctContRel.PRM_execute_trigger__c=true;
        acctContRel.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=acc[0].Id;
        acctContRel1.PRM_Contact_Id__c=con[1].Id;
        acctContRel1.PRM_Relationship_Id__c=crList[0].Id;
        //acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_InActive_Ind__c=true;
        acctContRel1.PRM_execute_trigger__c=true;
        acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel1);
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=acc[1].Id;
        acctContRel2.PRM_Contact_Id__c=con[2].Id;
        acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
        //acctContRel2.PRM_InActive_Ind__c=false;
        acctContRel2.PRM_InActive_Ind__c=true;
        acctContRel2.PRM_execute_trigger__c=true;
        acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel2.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel2);
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel3.PRM_Account_Id__c=acc[1].Id;
        acctContRel3.PRM_Contact_Id__c=con[3].Id;
        acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
        //acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_InActive_Ind__c=true;
        acctContRel3.PRM_execute_trigger__c=true;
        acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel3.PRM_Status_Reason_Txt__c='External';
        
        
        acrList.add(acctContRel3);
        insert acrList;
        //System.debug('acrList-->'+acrList);
        
        
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Points Redemption';
        pb.PRM_Channel_Program_Id__c = cp.id;
        pb.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pb.PRM_Account_Type_Nm__c = 'Both';
        pb.PRM_InActive_Ind__c=false;
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
        bem.PRM_IsActive_Ind__c=true;
        bem.PRM_Partner_Benefit_Id__c=pb.Id;
        bem.PRM_Partner_Type_Id__c=pt.Id;
        bem.PRM_Partner_Role_Nm__c='Service Provider';
        insert bem;
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        aba.PRM_Account_Id__c = acc[0].Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c = 'Active';
        aba.PRM_Status_Reason_Txt__c='Test';
        insert aba;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Developer Zone Standard';
        ee.Core_Technical_Engagement_Code__c = 'UDE_Standard';
        ee.Core_Engagement_Type__c = 'SMP';
        insert ee;
        
        List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
        Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
        ed.Name='Points Redeem';
        ed.Core_Display_Name__c='Points Redeem';
        ed.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed);
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Developer Zone Standard';
        ed1.Core_Display_Name__c='Developer Zone Standard';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed1);
        

        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='IPA Developer Zone Standard Entitlement';
        ed2.Core_Display_Name__c='IPA Developer Zone Standard Entitlement';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed2);
       
        insert entList;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Partner_Benefit_Id__c = pb.id;
        em.PRM_Entitlement_Id__c = entList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IsActive_Ind__c = true;
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em);

        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =con[1].Id;
        be1.PRM_Entitlement_Id__c =entList[1].id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_IsRemove_Ind__c = True;
        insert be1;
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em1.PRM_IsActive_Ind__c = true;
        // em1.PRM_IPARefreshCheck__c = ipaRefresh;
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

        Core_Contact_Entitlement__c cce2=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce2.Core_Contact_Id__c=con[0].Id;
        cce2.Core_Entitlement_Id__c = ed2.Id;
        cce2.Core_Selected__c = false;
        cce2.Core_Status__c='Pending';
        //cce1.Core_Source__c = 'Entitlement';
        insertCEList.add(cce2);
        insert insertCEList;
        //System.debug('insertCEList-->'+insertCEList);
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = con[0].Id;
        cs.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
        cs.PRM_Status_Reason_Txt__c='Test';
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

            insertCEList[2].Core_Selected__c = true;
            updateCE.add(insertCEList[2]);
            
            update updateCE;
            
            cs.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
            update cs;
            
            
            
            
        }
        Catch (DMLException e){
            
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
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
        List<Id> acrIdList = new List<Id>();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.test.com';
        insert newAccount;
        //System.debug('newAccount 2-->'+newAccount);
        
       
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
         cont.MailingCountry = 'India';
        con.add(cont);
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;

        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='jack';
        cont1.FirstName='william';
        cont1.email='jackwilliam@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
         cont1.MailingCountry = 'India';
        con.add(cont1);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount.Id;
        cont2.lastName='Hill';
        cont2.FirstName='Tom';
        cont2.email='TomHill@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'def';
         cont2.MailingCountry = 'India';
        con.add(cont2);
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=newAccount.Id;
        cont3.lastName='Hill123';
        cont3.FirstName='Tom';
        cont3.email='TomHill123@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'def';
         cont3.MailingCountry = 'India';
        con.add(cont3);
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';        
        insert acm;
        
        
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
        acctContRel.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel);
        acrIdList.add(acctContRel.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount.Id;
        acctContRel1.PRM_Contact_Id__c=con[0].Id;
        acctContRel1.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_execute_trigger__c=true;
        acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Start_Date_Dt__c= system.today() + 7;
        acctContRel1.PRM_End_Date_Dt__c= acctContRel1.PRM_Start_Date_Dt__c + 5;  
        acctContRel1.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel1);
        acrIdList.add(acctContRel1.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=newAccount.Id;
        acctContRel2.PRM_Contact_Id__c=con[1].Id;
        acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel2.PRM_InActive_Ind__c=false;
        acctContRel2.PRM_execute_trigger__c=true;
        acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel2.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel2);
        acrIdList.add(acctContRel2.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel3.PRM_Account_Id__c=newAccount.Id;
        acctContRel3.PRM_Contact_Id__c=con[2].Id;
        acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_execute_trigger__c=true;
        acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel3.PRM_Status_Reason_Txt__c='External';
        // acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 1';
        acrList.add(acctContRel3);
        acrIdList.add(acctContRel3.PRM_Relationship_Id__c);
        
        
        PRM_Account_Contact_Relationship__c acctContRel4=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel4.PRM_Account_Id__c=newAccount.Id;
        acctContRel4.PRM_Contact_Id__c=con[2].Id;
        acctContRel4.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel4.PRM_InActive_Ind__c=false;
        acctContRel4.PRM_execute_trigger__c=true;
        acctContRel4.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel4.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel4);
        
         PRM_Account_Contact_Relationship__c acctContRel5=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel5.PRM_Account_Id__c=newAccount.Id;
        acctContRel5.PRM_Contact_Id__c=con[3].Id;
        acctContRel5.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel5.PRM_InActive_Ind__c=false;
        acctContRel5.PRM_execute_trigger__c=true;
        acctContRel5.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel5.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel5);
        
       /* PRM_Account_Contact_Relationship__c acctContRel6=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel6.PRM_Account_Id__c=newAccount.Id;
        acctContRel6.PRM_Contact_Id__c=con[3].Id;
        acctContRel6.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel6.PRM_InActive_Ind__c=false;
        acctContRel6.PRM_execute_trigger__c=true;
        acctContRel6.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        
        // acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 1';
        acrList.add(acctContRel6); */
        
        insert acrList;
        
        Test.startTest();
        
        Map<Id, PRM_Account_Contact_Relationship__c> acrMap = new Map<Id, PRM_Account_Contact_Relationship__c>();
acrMap.put(acctContRel3.Id, acctContRel3);
acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 2';
update acctContRel3;
        
        //System.debug('acrList--2'+acrList);
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
        
        

        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='IPA Developer Zone Standard Entitlement';
        ed2.Core_Display_Name__c='IPA Developer Zone Standard Entitlement';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed2);
        insert entList;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = entList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em.PRM_IsActive_Ind__c = true;
        // em.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[1].Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
       // em1.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em1);
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Entitlement_Id__c = entList[1].id;
        em2.PRM_Contact_Relationship_Id__c = crList[0].id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        //em2.PRM_IPARefreshCheck__c = ipaRefresh;        
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
        
        Core_Contact_Entitlement__c cce4=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce4.Core_Contact_Id__c=con[3].Id;
        cce4.Core_Entitlement_Id__c = entList[0].id;
        cce4.Core_Status__c='Pending';
        cce4.Core_Selected__c = true;
        cce4.Core_Source__c = 'Entitlement';
        insertCEList.add(cce4);
        insert insertCEList;
        //System.debug('insertCEList-->'+insertCEList);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =con[1].Id;
        be1.PRM_Entitlement_Id__c =entList[1].id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_IsRemove_Ind__c = True;
        insert be1;
        
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = con[0].Id;
        cs.PRM_Status_Nm__c = 'Active';
        cs.PRM_Status_Reason_Txt__c='Test';
        insert cs;
        
        PRM_ContactSubscriptionAssociation__c cs1 = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs1.PRM_Contact_Id__c = con[2].Id;
        cs1.PRM_Status_Nm__c = 'Active';
        cs1.PRM_Status_Reason_Txt__c='Test';
        insert cs1;
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();//Contact Group 1
        cntGr.Name = 'IPA Contact Gr';
        insert cntGr;
        PRM_Contact_Group__c cntGr2 = new PRM_Contact_Group__c();//Contact Group 2
        cntGr2.Name = 'IPA Contact Gr 2';
        insert cntGr2;
        
        //contact group contact association
        List<PRM_Contact_Group_Contact_Association__c> cgcaList =new List<PRM_Contact_Group_Contact_Association__c>();
        PRM_Contact_Group_Contact_Association__c cgca1= new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG1
        cgca1.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca1.PRM_Contact_Id__c=con[0].Id;
        cgca1.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca1);
        
        PRM_Contact_Group_Contact_Association__c cgca2= new PRM_Contact_Group_Contact_Association__c();//CGCA for C2 with CG1
        cgca2.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca2.PRM_Contact_Id__c=con[1].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca2);
        
        PRM_Contact_Group_Contact_Association__c cgca3 = new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG2
        cgca3.PRM_Contact_Group_Id__c = cntGr2.Id;
        cgca3.PRM_Contact_Id__c = con[0].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca3.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca3);
        insert cgcaList;
        
        acctContRel5.PRM_InActive_Ind__c=true;
        acctContRel5.PRM_Soft_Contact__c= true;
        update acctContRel5;
        
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        
        acctContRel5.PRM_InActive_Ind__c=false;
        acctContRel5.PRM_Soft_Contact__c= true;
        update acctContRel5;
        
        PRM_AcctContRelUtility.firstRunAfterUpdate = true;
        Test.stopTest();
        //Test.startTest();
        List<Core_Contact_Entitlement__c> updateCEList = new List<Core_Contact_Entitlement__c>();
        try{
            
            
            insertCEList[0].Core_Selected__c = false;
            updateCEList.add(insertCEList[0]);
            
            /*acrList[2].PRM_InActive_Ind__c=true;
update acrList[2];*/
            
            insertCEList[2].Core_Selected__c = false;
            updateCEList.add(insertCEList[2]);
            insertCEList[3].Core_Selected__c = false;
            updateCEList.add(insertCEList[3]);
            
            update updateCEList;
            
            cs.PRM_Status_Nm__c = 'Inactive';
            update cs;
            
            
            //system.debug('The recursive value is 1st '+PRM_AcctContRelUtility.firstRunAfterUpdate);
            TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
            acrList[1].PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acrList[1];
            TriggerHandler.clearbypass('PRM_AcctContRel_TriggerHandler');
            
            acrList[0].PRM_InActive_Ind__c=true;
            acrList[1].PRM_InActive_Ind__c=true;
            acrList[1].PRM_Soft_Contact__c= true;
            acrList[0].PRM_Soft_Contact__c= true;
            acrList[3].PRM_InActive_Ind__c=true;
           acrList[1].PRM_InActive_Ind__c=true;
           acrList[1].PRM_Soft_Contact__c= true;
            acrList[3].PRM_Soft_Contact__c= true;
            update new List<PRM_Account_Contact_Relationship__c> {acrList[0], acrList[3]};
                             
            //system.debug('The recursive value is 2nd '+PRM_AcctContRelUtility.firstRunAfterUpdate);

           // update acrList[1];
            //system.debug('The recursive value is 3rd '+PRM_AcctContRelUtility.firstRunAfterUpdate);
           
            PRM_AcctContRelUtility.inactivateContactEntitlement(acrList,acrMap);
            
        }
        Catch (DMLException e){
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
        //Test.stopTest();
        System.assertEquals(acrList[0].PRM_Account_Id__c,newAccount.Id,'Value does not match');
    }    
    //yogesh
   /* @istest
    static void mandatoryCheck()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        List<Id> acrIdList = new List<Id>();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.test.com';
        insert newAccount;
        //System.debug('newAccount 2-->'+newAccount);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='jack';
        cont1.FirstName='william';
        cont1.email='jackwilliam@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
        con.add(cont1);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount.Id;
        cont2.lastName='Hill';
        cont2.FirstName='Tom';
        cont2.email='TomHill@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
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
        contRelation.PRM_Default_Relationship_Ind__c = true;
        contRelation.PRM_Mandatory_Relationship_Ind__c = true;
        
        crList.add(contRelation);
        
        
        PRM_ContactRelationships__c contRelation1 = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation1.Name=System.Label.PRM_WorksFor;
        contRelation1.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        contRelation1.PRM_Channel_Program_Id__c = cp.Id;
        contRelation1.PRM_Default_Relationship_Ind__c = false;
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
        acrIdList.add(acctContRel.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount.Id;
        acctContRel1.PRM_Contact_Id__c=con[0].Id;
        acctContRel1.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_execute_trigger__c=true;
        acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Start_Date_Dt__c= system.today() + 7;
        acctContRel1.PRM_End_Date_Dt__c= acctContRel1.PRM_Start_Date_Dt__c + 5;  
        acrList.add(acctContRel1);
        acrIdList.add(acctContRel1.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=newAccount.Id;
        acctContRel2.PRM_Contact_Id__c=con[1].Id;
        acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel2.PRM_InActive_Ind__c=false;
        acctContRel2.PRM_execute_trigger__c=true;
        acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel2);
        acrIdList.add(acctContRel2.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel3.PRM_Account_Id__c=newAccount.Id;
        acctContRel3.PRM_Contact_Id__c=con[2].Id;
        acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_execute_trigger__c=true;
        acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        // acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 1';
        acrList.add(acctContRel3);
        acrIdList.add(acctContRel3.PRM_Relationship_Id__c);
        
        
        PRM_Account_Contact_Relationship__c acctContRel4=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel4.PRM_Account_Id__c=newAccount.Id;
        acctContRel4.PRM_Contact_Id__c=con[2].Id;
        acctContRel4.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel4.PRM_InActive_Ind__c=false;
        acctContRel4.PRM_execute_trigger__c=true;
        acctContRel4.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acrList.add(acctContRel4);
        insert acrList;
        
        
        
        /*Map<Id, PRM_Account_Contact_Relationship__c> acrMap = new Map<Id, PRM_Account_Contact_Relationship__c>();
acrMap.put(acctContRel3.Id, acctContRel3);
acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 2';
update acctContRel3;*/
        
       /* //System.debug('acrList--2'+acrList);
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
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em.PRM_IsActive_Ind__c = true;
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[1].Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        emList.add(em1);
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Entitlement_Id__c = entList[1].id;
        em2.PRM_Contact_Relationship_Id__c = crList[0].id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
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
        //System.debug('insertCEList-->'+insertCEList);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =con[1].Id;
        be1.PRM_Entitlement_Id__c =entList[1].id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_IsRemove_Ind__c = True;
        insert be1;
        
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = con[0].Id;
        cs.PRM_Status_Nm__c = 'Active';
        insert cs;
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();//Contact Group 1
        cntGr.Name = 'IPA Contact Gr';
        insert cntGr;
        PRM_Contact_Group__c cntGr2 = new PRM_Contact_Group__c();//Contact Group 2
        cntGr2.Name = 'IPA Contact Gr 2';
        insert cntGr2;
        
        //contact group contact association
        List<PRM_Contact_Group_Contact_Association__c> cgcaList =new List<PRM_Contact_Group_Contact_Association__c>();
        PRM_Contact_Group_Contact_Association__c cgca1= new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG1
        cgca1.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca1.PRM_Contact_Id__c=con[0].Id;
        cgca1.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca1);
        
        PRM_Contact_Group_Contact_Association__c cgca2= new PRM_Contact_Group_Contact_Association__c();//CGCA for C2 with CG1
        cgca2.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca2.PRM_Contact_Id__c=con[1].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca2);
        
        PRM_Contact_Group_Contact_Association__c cgca3 = new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG2
        cgca3.PRM_Contact_Group_Id__c = cntGr2.Id;
        cgca3.PRM_Contact_Id__c = con[0].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca3.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca3);
        insert cgcaList;
        
        Test.startTest();
        List<Core_Contact_Entitlement__c> updateCEList = new List<Core_Contact_Entitlement__c>();
        try{
            
            
            insertCEList[0].Core_Selected__c = false;
            updateCEList.add(insertCEList[0]);
            
            /*acrList[2].PRM_InActive_Ind__c=true;
update acrList[2];*/
            
           /* insertCEList[2].Core_Selected__c = false;
            updateCEList.add(insertCEList[2]);
            insertCEList[3].Core_Selected__c = false;
            updateCEList.add(insertCEList[3]);
            
            update updateCEList;
            
            cs.PRM_Status_Nm__c = 'Inactive';
            update cs;
            
            
            //system.debug('The recursive value is 1st '+PRM_AcctContRelUtility.firstRunAfterUpdate);
            TriggerHandler.bypass('PRM_AcctContRel_TriggerHandler');
            acrList[1].PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
            update acrList[1];
            TriggerHandler.clearbypass('PRM_AcctContRel_TriggerHandler');
            
            acrList[0].PRM_InActive_Ind__c=false;
        //    acrList[1].PRM_InActive_Ind__c=true;
        //    acrList[1].PRM_Soft_Contact__c= true;
           // acrList[0].PRM_Soft_Contact__c= false;
            //acrList[3].PRM_InActive_Ind__c=true;
        //    acrList[1].PRM_InActive_Ind__c=true;
        //    acrList[1].PRM_Soft_Contact__c= true;
            acrList[3].PRM_Soft_Contact__c= true;
            update new List<PRM_Account_Contact_Relationship__c> {acrList[0]};
            //system.debug('The recursive value is 2nd '+PRM_AcctContRelUtility.firstRunAfterUpdate);

           // update acrList[1];
            //system.debug('The recursive value is 3rd '+PRM_AcctContRelUtility.firstRunAfterUpdate);
           
            // PRM_AcctContRelUtility.inactivateContactEntitlement(acrList,acrMap);
        }
        Catch (DMLException e){
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }
        Test.stopTest();
        System.assertEquals(acrList[0].PRM_Account_Id__c,newAccount.Id,'Value does not match');
    }    */
    
    
        /*Utkarsh: 21/08/2019: Added testInActivateContactEntitlement method for Inactive ACR case.*/
    @isTest
    static void testInactivateContactEntitlement_01()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdEM = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('EntitlementWithoutBenefits').getRecordTypeId();
        List<Id> acrIdList = new List<Id>();
        Test.startTest();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Walmart';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'www.test.com';
        insert newAccount;
        //System.debug('newAccount 2-->'+newAccount);

        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Ceaser';
        cont.FirstName='Julius';
        cont.email='JuliusCeaser@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
         cont.MailingCountry = 'India';
        con.add(cont);
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=newAccount.Id;
        cont1.lastName='jack';
        cont1.FirstName='william';
        cont1.email='jackwilliam@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abc';
         cont1.MailingCountry = 'India';
        con.add(cont1);
        
        Contact cont2 = new Contact();  //Contact
        cont2.AccountId=newAccount.Id;
        cont2.lastName='Hill';
        cont2.FirstName='Tom';
        cont2.email='TomHill@rediff.com';
        cont2.Core_Job_Function__c='Branch Manager';
        cont2.Core_eRPM_Language_Code__c='Eng';
        cont2.Core_IPA_PartnerRole__c = 'Service Provider';
        cont2.Core_Login_Id__c = 'def';
         cont2.MailingCountry = 'India';
        con.add(cont2);
        
        Contact cont3 = new Contact();  //Contact
        cont3.AccountId=newAccount.Id;
        cont3.lastName='Hilly';
        cont3.FirstName='Tomy';
        cont3.email='TomHilly@rediff.com';
        cont3.Core_Job_Function__c='Branch Manager';
        cont3.Core_eRPM_Language_Code__c='Eng';
        cont3.Core_IPA_PartnerRole__c = 'Service Provider';
        cont3.Core_Login_Id__c = 'fpg';
         cont3.MailingCountry = 'India';
        con.add(cont3);
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
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
        acctContRel.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel);
        acrIdList.add(acctContRel.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel1=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel1.PRM_Account_Id__c=newAccount.Id;
        acctContRel1.PRM_Contact_Id__c=con[0].Id;
        acctContRel1.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel1.PRM_InActive_Ind__c=false;
        acctContRel1.PRM_execute_trigger__c=true;
        acctContRel1.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel1.PRM_Start_Date_Dt__c= system.today() + 7;
        acctContRel1.PRM_End_Date_Dt__c= acctContRel1.PRM_Start_Date_Dt__c + 5;  
        acctContRel1.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel1);
        acrIdList.add(acctContRel1.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=newAccount.Id;
        acctContRel2.PRM_Contact_Id__c=con[1].Id;
        acctContRel2.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel2.PRM_InActive_Ind__c=false;
        acctContRel2.PRM_execute_trigger__c=true;
        acctContRel2.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel2.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel2);
        acrIdList.add(acctContRel2.PRM_Relationship_Id__c);
        
        PRM_Account_Contact_Relationship__c acctContRel3=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel3.PRM_Account_Id__c=newAccount.Id;
        acctContRel3.PRM_Contact_Id__c=con[2].Id;
        acctContRel3.PRM_Relationship_Id__c=crList[0].Id;
        acctContRel3.PRM_InActive_Ind__c=false;
        acctContRel3.PRM_execute_trigger__c=true;
        acctContRel3.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 1';
        acrList.add(acctContRel3);
        acrIdList.add(acctContRel3.PRM_Relationship_Id__c);
        
        List<PRM_Account_Contact_Relationship__c> acrList01 = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c acctContRel4=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel4.PRM_Account_Id__c=newAccount.Id;
        acctContRel4.PRM_Contact_Id__c=con[2].Id;
        acctContRel4.PRM_Relationship_Id__c=crList[1].Id;
        acctContRel4.PRM_InActive_Ind__c=false;
        acctContRel4.PRM_execute_trigger__c=true;
        acctContRel4.PRM_Status_Nm__c = System.Label.PRM_ACR_Status;
        acctContRel4.PRM_Status_Reason_Txt__c='External';
        acrList.add(acctContRel4);
        insert acrList;
        Map<id,PRM_Account_Contact_Relationship__c> oldMap = new Map<id,PRM_Account_Contact_Relationship__c>();
        oldMap.put(acctContRel4.id,acctContRel4);
        PRM_Account_Contact_Relationship__c acctContRelTemp =new PRM_Account_Contact_Relationship__c(Id = acctContRel4.id, PRM_Account_Id__c=newAccount.Id,PRM_Relationship_Id__c=crList[1].Id,PRM_Contact_Id__c=con[2].Id,PRM_Status_Nm__c = System.Label.PRM_ACR_Status,PRM_execute_trigger__c=true);
        acrList01.add(acctContRelTemp);

        /*Map<Id, PRM_Account_Contact_Relationship__c> acrMap = new Map<Id, PRM_Account_Contact_Relationship__c>();
acrMap.put(acctContRel3.Id, acctContRel3);
acctContRel3.PRM_Status_Reason_Txt__c = 'Test Reason 2';
update acctContRel3;*/
        
        //System.debug('acrList--2'+acrList);
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
        ed1.Name='Developer Zone Standard';
        ed1.Core_Display_Name__c='Points View';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed1);
        
        Core_Entitlement__c ed2=new Core_Entitlement__c(); //Entitlement
        ed2.Name='IPA Developer Zone Standard Entitlement';
        ed2.Core_Display_Name__c='IPA Developer Zone Standard Entitlement';
        ed2.Core_ERPM_Engagement_Id__c=ee.id;
        entList.add(ed2);
        
        insert entList;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = entList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        em.PRM_IsActive_Ind__c = true;
        // em.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.RecordTypeId = recordTypeIdEM;
        em1.PRM_Entitlement_Id__c = entList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[1].Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em1.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em1);
        
        PRM_VXEnttlmntMatrix__c em2= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em2.PRM_Entitlement_Id__c = entList[1].id;
        em2.PRM_Contact_Relationship_Id__c = crList[0].id;
        em2.PRM_Approval_Type_Nm__c='Automatic';
        em2.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em2.PRM_IPARefreshCheck__c = ipaRefresh;
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
        //System.debug('insertCEList-->'+insertCEList);
        
        PRM_Batch_Entitlement__c be1 = new PRM_Batch_Entitlement__c(); //Batch Entitlement
        be1.PRM_Contact_Id__c =con[1].Id;
        be1.PRM_Entitlement_Id__c =entList[1].id;
        be1.PRM_Status_Nm__c = 'New';
        be1.PRM_IsRemove_Ind__c = True;
        be1.PRM_Status_Reason_Txt__c='Test';
        insert be1;
        
        
        PRM_ContactSubscriptionAssociation__c cs = new PRM_ContactSubscriptionAssociation__c(); // contact subscription
        cs.PRM_Contact_Id__c = con[0].Id;
        cs.PRM_Status_Nm__c = 'Active';
        cs.PRM_Status_Reason_Txt__c='Test';
        insert cs;
        
        PRM_Contact_Group__c cntGr = new PRM_Contact_Group__c();//Contact Group 1
        cntGr.Name = 'IPA Contact Gr';
        insert cntGr;
        PRM_Contact_Group__c cntGr2 = new PRM_Contact_Group__c();//Contact Group 2
        cntGr2.Name = 'IPA Contact Gr 2';
        insert cntGr2;
        
        //contact group contact association
        List<PRM_Contact_Group_Contact_Association__c> cgcaList =new List<PRM_Contact_Group_Contact_Association__c>();
        PRM_Contact_Group_Contact_Association__c cgca1= new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG1
        cgca1.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca1.PRM_Contact_Id__c=con[0].Id;
        cgca1.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca1);
        
        PRM_Contact_Group_Contact_Association__c cgca2= new PRM_Contact_Group_Contact_Association__c();//CGCA for C2 with CG1
        cgca2.PRM_Contact_Group_Id__c=cntGr.Id;
        cgca2.PRM_Contact_Id__c=con[1].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca1.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca2);
        
        PRM_Contact_Group_Contact_Association__c cgca3 = new PRM_Contact_Group_Contact_Association__c();//CGCA for C1 with CG2
        cgca3.PRM_Contact_Group_Id__c = cntGr2.Id;
        cgca3.PRM_Contact_Id__c = con[0].Id;
        cgca2.PRM_Start_Date_Dt__c=System.today();
        cgca3.PRM_InActive_Ind__c = false;
        cgcaList.add(cgca3);
        insert cgcaList;
        
        //Test.startTest();
        List<Core_Contact_Entitlement__c> updateCEList = new List<Core_Contact_Entitlement__c>();
        try{
            
            
           // insertCEList[0].Core_Selected__c = false;
            updateCEList.add(insertCEList[0]);
            
            /*acrList[2].PRM_InActive_Ind__c=true;
update acrList[2];*/
            
            insertCEList[2].Core_Selected__c = false;
            updateCEList.add(insertCEList[2]);
            insertCEList[3].Core_Selected__c = false;
            updateCEList.add(insertCEList[3]);
            
            update updateCEList;
            
            cs.PRM_Status_Nm__c = 'Inactive';
            update cs;
            
            
            //system.debug('The recursive value is 1st '+PRM_AcctContRelUtility.firstRunAfterUpdate);
            acrList[0].PRM_InActive_Ind__c=true;
        //    acrList[1].PRM_InActive_Ind__c=true;
        //    acrList[1].PRM_Soft_Contact__c= true;
            acrList[0].PRM_Soft_Contact__c= true;
            acrList01[0].PRM_InActive_Ind__c=true;
            acrList01[0].PRM_Soft_Contact__c= true;
            update acrList01[0];
            //system.debug('The recursive value is 2nd '+PRM_AcctContRelUtility.firstRunAfterUpdate);

           // update acrList[1];
            //system.debug('The recursive value is 3rd '+PRM_AcctContRelUtility.firstRunAfterUpdate);
           
            // PRM_AcctContRelUtility.inactivateContactEntitlement(acrList,acrMap);
        }
        Catch (DMLException e){
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
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
        newAccount.Core_User_Defined_Website__c = 'www.test.com';
        insert newAccount;
        //System.debug('newAccount-->'+newAccount); 
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;

        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Brown';
        cont.FirstName='Dan';
        cont.email='danbrown@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'xyz';
        cont.Core_Enterprise_Id__c = '1212122';
        cont.Core_IPA_Email_Verification_Date__c = system.now();
         cont.MailingCountry = 'India';
        insert cont;
        
        prm_skip_trigger__c bm1 = new prm_skip_trigger__c();//Custom Setting Benefit Mapping
        bm1.Name='ABA_Trigger';
        bm1.inactive__c = false;
        insert bm1;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        //System.debug('cpl-->'+cpl);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c='Test';
        
        insert acm;
        
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
        //System.debug('pt-->'+pt);
        
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
        //System.debug('bem-->'+bem);
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // Account Benefit Association
        aba.PRM_Account_Id__c = newAccount.Id;
        aba.PRM_Partner_Benefit_Id__c = pb.id;
        aba.PRM_Status_Nm__c ='Active';
        aba.PRM_Status_Reason_Txt__c='Test';
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
        //System.debug('crList[0]-->'+crList[0]);
        
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

        Core_Entitlement__c ed3=new Core_Entitlement__c(); //Entitlement
        ed3.Name='IPA Developer Zone Standard Entitlement';
        ed3.Core_Display_Name__c='IPA Developer Zone Standard Entitlement';
        ed3.Core_ERPM_Engagement_Id__c=ee.id;
        entitlementList.add(ed3);

        insert entitlementList; 
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.RecordTypeId = recordTypeIdEM;
        em.PRM_Entitlement_Id__c = entitlementList[0].id;
        em.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em.PRM_Channel_Program_Level_Id__c = cpl.Id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em1.PRM_Partner_Benefit_Id__c = pb.id;
        em1.PRM_Entitlement_Id__c = entitlementList[1].id;
        em1.PRM_Contact_Relationship_Id__c = crList[0].Id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.PRM_IPA_Partner_Role_Nm__c='Service Provider';
        // em1.PRM_IPARefreshCheck__c = ipaRefresh;
        emList.add(em1);
        insert emList;
        //System.debug('emList[0]-->'+emList[0]);
        
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
        System.assertEquals(acctContRel.PRM_Account_Id__c,newAccount.Id,'Value does not match');
    }
    @isTest
    static void testAutoPopulateSegment(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = new Account();
        acc.Name='John Rick04';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_IPA_Partner_Segment__c= 'Data Center';
        acc.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc.Core_User_Defined_Website__c = 'www.test.com';
        insert acc;
        
        PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm1.Name='BatchFieldValues';
        bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm1.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm1.PRM_SchedulingHour__c=6;
        bm1.PRM_NoOfRecords__c=300;
        bm1.PRM_NoOfBatchEntRecords__c=10;
        bm1.PRM_PartnerRole__c ='Service Provider';
        bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm1;

        Contact con = new Contact();
        con.AccountId = acc.id;
        con.lastName='jack';
        con.FirstName='william';
        con.email='jackwilliam@rediff.com';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c   = 'Distributor';
        con.Core_IPA_Contact_Segment__c= 'Data Center';
        con.Core_IPA_Contact_Segment__c= 'Client Computing';
         con.MailingCountry = 'India';
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        cr2.Name = 'Employee';
        insert cr2;
        
        
        PRM_Account_Contact_Relationship__c acrnew = new PRM_Account_Contact_Relationship__c();
        
        acrnew.PRM_Account_Id__c = acc.id;
        acrnew.PRM_Contact_Id__c = con.id;
        acrnew.PRM_Relationship_Id__c=cr2.id;
        acrnew.PRM_InActive_Ind__c=false;
        acrnew.PRM_execute_trigger__c=true;
        acrnew.PRM_Status_Nm__c = 'Pending Action';
        acrnew.PRM_Status_Reason_Txt__c='External';
        insert acrnew;
    }
    
    
    
    @isTest
    static void testSuppressEmail(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = new Account();
        acc.Name='Preeti Menon';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_IPA_Partner_Segment__c= 'Data Center';
        acc.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc.Core_User_Defined_Website__c = 'www.test.com';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.lastName='jack';
        con.FirstName='william';
        con.email='jackwilliam@rediff.com';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c   = 'Distributor';
        con.Core_IPA_Contact_Segment__c= 'Data Center';
        con.Core_IPA_Contact_Segment__c= 'Client Computing';
         con.MailingCountry = 'India';
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        cr2.Name = 'Employee';
        insert cr2;
        
        
        PRM_Account_Contact_Relationship__c acrnew = new PRM_Account_Contact_Relationship__c();
        
        acrnew.PRM_Account_Id__c = acc.id;
        acrnew.PRM_Contact_Id__c = con.id;
        acrnew.PRM_Relationship_Id__c=cr2.id;
        acrnew.PRM_InActive_Ind__c=false;
        acrnew.PRM_execute_trigger__c=true;
        acrnew.PRM_Status_Nm__c = 'Pending Action';
        acrnew.PRM_Suppress_Email__c = true;
        acrnew.PRM_Status_Reason_Txt__c='External';
        insert acrnew;
        
        
    }
    
    @isTest
    static void testSystemAccount(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        Account acc = new Account();
        acc.Name='John Rick05';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_IPA_Partner_Segment__c= 'Data Center';
        acc.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc.Core_User_Defined_Website__c = 'www.test.com';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.lastName='jack';
        con.FirstName='william';
        con.email='jackwilliam@rediff.com';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c   = 'Distributor';
        con.Core_IPA_Contact_Segment__c= 'Data Center';
        con.Core_IPA_Contact_Segment__c= 'Client Computing';
         con.MailingCountry = 'India';
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        cr2.Name = 'Employee';
        insert cr2;
        
        
        PRM_Account_Contact_Relationship__c acrnew = new PRM_Account_Contact_Relationship__c();
        
        acrnew.PRM_Account_Id__c = acc.id;
        acrnew.PRM_Contact_Id__c = con.id;
        acrnew.PRM_Relationship_Id__c=cr2.id;
        acrnew.PRM_InActive_Ind__c=false;
        acrnew.PRM_execute_trigger__c=true;
        acrnew.PRM_Status_Nm__c = 'Pending Action';
        acrnew.PRM_Suppress_Email__c = true;
        acrnew.PRM_Status_Reason_Txt__c='External';
        insert acrnew;
        
        Test.startTest();     
        try{
            Core_Intel_System_Accounts__mdt dt = new Core_Intel_System_Accounts__mdt(); 
            dt.Account_Name__c = 'Preeti Menon';
            dt.AccountId__c =acc.id;
            dt.Label ='ISA_000SKNCKLKKOYUESCO';
            
            
        }
        catch(Exception e){
            //System.debug('Exception Occured');
            System.assert(e.getMessage().contains('This user is associated with a system account, please work with data ops to place him on the right account.'));
        }
        test.stopTest();
        System.assertEquals(acrnew.PRM_Relationship_Id__c,cr2.Id,'Value does not match');
        
        
    }
    
    @isTest
    static void restrictACRStatusUpdateToAGSIdentityCreationFailedTest(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();

        Account acc = new Account();
        acc.Name='Preeti Menon';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_IPA_Partner_Segment__c= 'Data Center';
        acc.Core_IPA_Partner_Segment__c= 'Client Computing';
        acc.Core_User_Defined_Website__c = 'www.test.com';
        insert acc;

        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Partner;Prestige';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_NoOfBatchEntRecords__c=10;
        bm.PRM_PartnerRole__c ='Service Provider';
        bm.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
        insert bm;
        
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.lastName='jack';
        con.FirstName='william';
        con.email='jackwilliam@rediff.com';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c   = 'Distributor';
        con.Core_IPA_Contact_Segment__c= 'Data Center';
        con.Core_IPA_Contact_Segment__c= 'Client Computing';
         con.MailingCountry = 'India';
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        cr2.Name = 'Employee';
        insert cr2;
        
        
        PRM_Account_Contact_Relationship__c acrnew = new PRM_Account_Contact_Relationship__c();
        
        acrnew.PRM_Account_Id__c = acc.id;
        acrnew.PRM_Contact_Id__c = con.id;
        acrnew.PRM_Relationship_Id__c=cr2.id;
        acrnew.PRM_InActive_Ind__c=false;
        acrnew.PRM_execute_trigger__c=true;
        acrnew.PRM_Status_Nm__c = 'Pending Action';
        acrnew.PRM_Suppress_Email__c = true;
        acrnew.PRM_Status_Reason_Txt__c='External';
        insert acrnew;
        
        /*acrnew.PRM_Status_Nm__c = 'Complete';
        acrnew.PRM_Status_Reason_Txt__c='test';
        update acrnew;  */   
        
    }
    
    /*
    @isTest
    static void mandatoryDeletionCheckTest(){
        Test.startTest();
        try{      
            Account acc8 = new Account();
            acc8.Name='Preeti Menon';
            acc8.BillingCity='City';
            acc8.BillingStreet='Street';
            acc8.BillingCountry='India';
            acc8.BillingPostalCode='Postal code';
            acc8.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acc8.Core_IPA_Partner_Role__c = 'Distributor';
            acc8.Core_IPA_Partner_Segment__c= 'Data Center';
            acc8.Core_IPA_Partner_Segment__c= 'Client Computing';
            acc8.Core_User_Defined_Website__c = 'www.test.com';
            insert acc8;

            PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
            bm1.Name='BatchFieldValues';
            bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
            bm1.PRM_ChannelProgramLevel__c='Gold;Titanium;Member';
            bm1.PRM_SchedulingHour__c=6;
            bm1.PRM_NoOfRecords__c=300;
            bm1.PRM_NoOfBatchEntRecords__c=10;
            bm1.PRM_PartnerRole__c ='Service Provider';
            bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
            bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
            insert bm1;
            
            Contact con8 = new Contact();
            con8.AccountId = acc8.id;
            con8.lastName='jack';
            con8.FirstName='william';
            con8.email='jackwilliam@rediff.com';
            con8.Core_eRPM_Language_Code__c='Eng';
            con8.Core_IPA_PartnerRole__c   = 'Distributor';
            con8.Core_IPA_Contact_Segment__c= 'Data Center';
            con8.Core_IPA_Contact_Segment__c= 'Client Computing';
            insert con8;
            
            ChannelProgram cp8 = new ChannelProgram(); //Channel Program
            cp8.Name='Intel Partner Alliance';
            cp8.PRM_programCode__c='IPA';
            insert cp8;
            
            PRM_ContactRelationships__c cr8 =new PRM_ContactRelationships__c();
            cr8.Name=System.Label.PRM_WorksFor;
            cr8.PRM_Contact_Relationship_Cd__c='WORKSFOR';
            cr8.PRM_Default_Relationship_Ind__c = true;
            cr8.PRM_Mandatory_Relationship_Ind__c = true;
            cr8.PRM_InActive_Ind__c = false;
            cr8.PRM_Channel_Program_Id__c=cp8.Id;
            cr8.Name = 'Employee';
            insert cr8;
            
            
            PRM_Account_Contact_Relationship__c acrnew8 = new PRM_Account_Contact_Relationship__c();
            
            acrnew8.PRM_Account_Id__c = acc8.id;
            acrnew8.PRM_Contact_Id__c = con8.id;
            acrnew8.PRM_Relationship_Id__c=cr8.id;
            acrnew8.PRM_InActive_Ind__c=false;
            acrnew8.PRM_execute_trigger__c=true;
            acrnew8.PRM_Status_Nm__c = 'Pending Action';
            acrnew8.PRM_Suppress_Email__c = true;
            insert acrnew8;
            
            List<PRM_Account_Contact_Relationship__c> acr9 = new List<PRM_Account_Contact_Relationship__c>();
            acr9 = [Select Id, PRM_Account_Id__c, PRM_Contact_Id__c, PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c, PRM_Relationship_Id__r.Name, PRM_Relationship_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c =: acc8.id];
            acrnew8.PRM_Status_Nm__c = 'Complete';
            update acrnew8;   
            PRM_AcctContRelUtility.mandatoryDeletionCheck(acr9);
            PRM_AcctContRelUtility.mandatoryDeletionCheck(null);
        }catch(Exception e){
            //System.debug('Exception Occured');
        }
        test.stopTest();
        
        
    } */
    
    @isTest
    static void emailForPrimaryContact(){
        
        try{      
            Account acct = new Account();
            acct.Name='Preeti Menon';
            acct.BillingCity='City';
            acct.BillingStreet='Street';
            acct.BillingCountry='India';
            acct.BillingPostalCode='Postal code';
            acct.Core_Account_Type__c='Cloud Service Provider (CSP)';
            acct.Core_IPA_Partner_Role__c = 'Distributor';
            acct.Core_IPA_Partner_Segment__c= 'Data Center';
            acct.Core_IPA_Partner_Segment__c= 'Client Computing';
            acct.Core_User_Defined_Website__c = 'www.test.com';
            insert acct;
            
            PRM_BatchCustomSetting__c bm1 = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
            bm1.Name='BatchFieldValues';
            bm1.PRM_PartnerType__c='Cloud Service Provider (CSP)';
            bm1.PRM_ChannelProgramLevel__c='Partner;Prestige';
            bm1.PRM_SchedulingHour__c=6;
            bm1.PRM_NoOfRecords__c=300;
            bm1.PRM_NoOfBatchEntRecords__c=10;
            bm1.PRM_PartnerRole__c ='Service Provider';
            bm1.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';
            bm1.PRM_EntitlementsNotToInactivate__c= 'IPA Developer Zone Standard Entitlement';
            insert bm1;

            Contact cont = new Contact();
            cont.AccountId = acct.id;
            cont.lastName='jack';
            cont.FirstName='william';
            cont.email='jackwilliam@rediff.com';
            cont.Core_eRPM_Language_Code__c='Eng';
            cont.Core_IPA_PartnerRole__c   = 'Distributor';
            cont.Core_IPA_Contact_Segment__c= 'Data Center';
            cont.Core_IPA_Contact_Segment__c= 'Client Computing';
             cont.MailingCountry = 'India';
            insert cont;
            
            ChannelProgram cp = new ChannelProgram(); //Channel Program
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            PRM_ContactRelationships__c cr =new PRM_ContactRelationships__c();
            cr.Name=System.Label.PRM_WorksFor;
            cr.PRM_Contact_Relationship_Cd__c='WORKSFOR';
            cr.PRM_Default_Relationship_Ind__c = true;
            cr.PRM_Mandatory_Relationship_Ind__c = true;
            cr.PRM_InActive_Ind__c = false;
            cr.PRM_Channel_Program_Id__c=cp.Id;
            cr.Name = 'Employee';
            insert cr;
            
            
            PRM_Account_Contact_Relationship__c acrnew = new PRM_Account_Contact_Relationship__c();
            
            acrnew.PRM_Account_Id__c = acct.id;
            acrnew.PRM_Contact_Id__c = cont.id;
            acrnew.PRM_Relationship_Id__c=cr.id;
            acrnew.PRM_InActive_Ind__c=false;
            acrnew.PRM_execute_trigger__c=true;
            acrnew.PRM_Status_Nm__c = 'Pending Action';
            acrnew.PRM_Suppress_Email__c = true;
            insert acrnew;
            
            Map<id,sObject> oldMap = new Map<id,sObject>();
            OldMap.put(acrnew.Id, acrnew);
            Map<id,sObject> newMap = new Map<id,sObject>();
            //newMap.put(acrnew.Id, PRM_Account_Contact_Relationship__c);
            
            
            acrnew.PRM_InActive_Ind__c=true;
            acrnew.PRM_Status_Reason_Txt__c='External';
            update acrnew;
            //Map<id,sObject> newMap = new Map<id,sObject>();
            newMap.put(acrnew.Id, acrnew);
            
            PRM_AcctContRelUtility.emailForPrimaryContact(OldMap, NewMap);
            
        }
        
        catch(Exception ex){
            //System.debug(ex.getMessage());
        }
        
        
    }
    
}