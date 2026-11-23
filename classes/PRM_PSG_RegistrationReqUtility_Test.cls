/*********************************************************************************************************************
Apex Class Name  : PRM_PSG_RegistrationReqUtility_Test 
Version       : 1.0
Created Date  : JULY 2021
Function      : Test Class for PRM_PSG_RegistrationReqUtility

Modification Log :
* Developer                                Date               Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
* Mansi Mundhra/Gopikrishna Vankadari                  22/07/2021         Test Class for PRM_PSG_RegistrationReqUtility
************************************************************************************************************************************************/
@isTest
public class PRM_PSG_RegistrationReqUtility_Test { 
    /*
    @testSetup    
    static void setupDataCreation()
    {
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount); 
        acc.Name = 'Dell US';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);  
        
        Contact con = PRM_TestUtility.getContact();
        con.Email='testrequest1@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';  
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        //con.Core_Login_Id__c = 'abcd';
        con.MailingCountry='USA';
        insert con;
        
        ChannelProgram psgProg = new ChannelProgram();
        psgProg.Name='PSG';
        psgProg.PRM_programCode__c='PSG';
        insert psgProg;
        
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); 
        cpl1.Name='Partner';
        cpl1.ProgramId=psgProg.Id;
        insert cpl1; 
       
        PRM_PartnerAgreement__c pa2 = new PRM_PartnerAgreement__c();
        pa2.PRM_Channel_Program_Id__c = psgProg.Id;
        pa2.Name='PSG Terms And Conditions';
        pa2.PRM_Language_Codes__c='';
        pa2.PRM_Agreement_Cd__c='PSG_TANDC';
        insert pa2;
        
        Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
        objAGSRole.Name= 'Test_AGS_Role_02';
        objAGSRole.Core_Technical_Name__c = 'Test_AGSRole_02_TechName';
        objAGSRole.Core_IsActive__c = true;
        insert objAGSRole;
        
        List<PRM_Registration_Request__c> regRequests = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testrequest1@mailinator.com';
        newRequest.PRM_Channel_Program__c = psgProg.Id;
        newRequest.PRM_Legal_Agreements__c = 'PSG_TANDC';
        newRequest.PRM_Preferred_Language__c = 'ENG';
        newRequest.PRM_Contact_Country__c = 'US';
        newRequest.PRM_Salesforce_ID__c = acc.Id;
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert newRequest;
        
        
        
        test.startTest();
        
        String PSGEntitelmentName =System.Label.PRM_PSG_Entitlement_Name;
        List<Core_Entitlement__c> entlmnts = new List<Core_Entitlement__c>();
        Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
        objEntitlement.Name = PSGEntitelmentName;
        objEntitlement.Core_Display_Name__c = 'PSG Licensing User';
        objEntitlement.Core_IsActive__c = true;
        objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement.Core_Category__c = '';
        objEntitlement.Core_Sub_Category__c = '';     
        entlmnts.add(objEntitlement);
        
        insert entlmnts;
        
        Core_Contact_Entitlement__c ent= new Core_Contact_Entitlement__c();
        ent.Core_Contact_Id__c=con.id;
        ent.Core_Entitlement_Id__c=entlmnts[0].id;
        ent.Core_Status__c='Complete';
        ent.Core_Selected__c = false;
        insert ent;
        
        Test.stopTest();
        
    }
    
    private static testMethod void updateRegRequest(){
        
        test.startTest();
        List<PRM_Registration_Request__c>  regReq = [SELECT id,Name,RecordTypeId,PRM_Salesforce_ID__c FROM PRM_Registration_Request__c LIMIT 1];
        List<Account> acc = [SELECT id FROM Account LIMIT 1];
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        regReq[0].RecordTypeId = accCreateRequestId;
        regReq[0].PRM_Salesforce_ID__c = acc[0].Id;
        regReq[0].PRM_EmailVerifiedDateTime__c = system.now();
        update regReq[0];
        
        List<Contact> conts = [SELECT id,Name,AccountId FROM Contact LIMIT 1];
        List<PRM_AccountLegalAgreemntAssociation__c> legalAgrmntAssocs = [SELECT id FROM PRM_AccountLegalAgreemntAssociation__c];
        
        system.assert(conts.size() > 0);
        
      //  PRM_PSG_RegistrationReqUtility.sendWelcomeEmailForPSG(new List<Id>{conts[0].Id});
        
        
        List<ChannelProgram> psgPrograms = [SELECT id FROM ChannelProgram WHERE PRM_programCode__c='PSG'];
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testrequest11@mailinator.com';
        newRequest.PRM_Channel_Program__c = psgPrograms[0].Id;
        newRequest.PRM_Legal_Agreements__c = 'IQR_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Partner_Type__c = 'Original Equipment Manufacturer (OEM)';
        newRequest.PRM_Salesforce_ID__c = conts[0].AccountId;
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.PRM_Contact_Country__c = 'US';
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert newRequest;
        
        
        
        newRequest.RecordTypeId = accCreateRequestId;
        newRequest.PRM_Salesforce_ID__c = conts[0].AccountId;
        newRequest.PRM_EmailVerifiedDateTime__c = system.now();
        update newRequest;
        
        test.stopTest();
        
    }
    
    private static testMethod void psgEntitlements(){
        
        Test.startTest();
        List<Contact> conList = [Select Id,Email,AccountId from Contact];
        List<PRM_Registration_Request__c>  regReq = [SELECT id,Name,RecordTypeId,PRM_Salesforce_ID__c FROM PRM_Registration_Request__c LIMIT 1];
        regReq[0].PRM_Email_ID__c = 'abc@email.com';
        regReq[0].PRM_Legal_Agreements__c='IPA_TANDC';
        regReq[0].PRM_Contact_Salesforce_Id__c = conList[0].Id;
        update regReq[0];
        Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
        objAGSRole.Name= 'Test_AGS_Role_02';
        objAGSRole.Core_Technical_Name__c = 'Test_AGSRole_02_TechName';
        objAGSRole.Core_IsActive__c = true;
        insert objAGSRole;
        String PSGEntitelmentName =System.Label.PRM_PSG_Entitlement_Name;
        List<ChannelProgram> psgPrograms = [select id, Name, PRM_programCode__c from ChannelProgram where Name = 'PSG'];
        List<ChannelProgramLevel> psgProgramLvl = [select id, Name, ProgramId, Program.Name from ChannelProgramLevel where Program.Name = 'PSG'];   
        List<Core_Entitlement__c> objEnt =[select id, Name from Core_Entitlement__c where Name =: PSGEntitelmentName];
        
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        
        em.PRM_Entitlement_Id__c = objEnt[0].id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.PRM_Channel_Program_Id__c=psgPrograms[0].Id;
        em.PRM_Channel_Program_Level_Id__c=psgProgramLvl[0].Id;
        insert em;
        
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        conMap.put(conList[0].id,conList[0]);
        Map<Id,Contact> conMap2 = new Map<Id,Contact>();
      //  PRM_PSG_RegistrationReqUtility.assignPSGEntitlements(conMap);
      //  PRM_PSG_RegistrationReqUtility.createContactforPSG(regReq[0],conMap2);
        // regReq[0].PRM_Contact_Salesforce_Id__c=Null;
        // regReq[0].PRM_First_Name__c='test name';
        // regReq[0].PRM_Last_Name__c='test';
        // regReq[0].PRM_Email_ID__c='test@email.com';
        // regReq[0].PRM_Profession__c='Student';
        // regReq[0].PRM_Contact_Login_ID__c=Null;
        // regReq[0].PRM_Preferred_Language__c=Null;
        // regReq[0].PRM_Enterprise_ID__c = Null;
        // regReq[0].PRM_Person_Phone_Number__c = Null;
        

        // PRM_PSG_RegistrationReqUtility.createContactforPSG(regReq[0],conMap2);
        Test.stopTest();
    }    
    
    */
}