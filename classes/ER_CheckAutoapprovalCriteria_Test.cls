@isTest
public class ER_CheckAutoapprovalCriteria_Test 
{
    
    @testSetup
    static void setupTestData() {
        
        Test.startTest();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        //newAccount.Core_Account_Type__c='Distributor';// BizOrgType code removal
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        newAccount.Core_CIM_ID__c = '563210';
        newAccount.Core_CNDA_Number__c = '987631';
        newAccount.RecordTypeId = recordTypeIdAccount;
        insert newAccount;
        
        Account newAccount1 = new Account();//Account
        newAccount1.Name='John Rick Acc';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
       // newAccount1.Core_Account_Type__c='Distributor';// BizOrgType code removal
        newAccount1.Core_User_Defined_Website__c = 'www.test.com';
        newAccount1.Core_CIM_ID__c = '563211';
        newAccount1.Core_CNDA_Number__c = '987632';
        newAccount1.RecordTypeId = recordTypeIdAccount;
        insert newAccount1;
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount1.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Solution Integrator';
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
        cont1.Core_IPA_PartnerRole__c = 'Independent Software Vendor';
        cont1.Core_Login_Id__c = 'xyz';
        cont1.MailingCountry='India';
        con.add(cont1);
        insert con;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1;
        
        PRM_PartnerAgreement__c pa1 = new PRM_PartnerAgreement__c();
        pa1.PRM_Channel_Program_Id__c = cp.Id;
        pa1.Name='Intel Partner Alliance Terms & Conditions';
        pa1.PRM_Agreement_Cd__c='IPA_TANDC';
        insert pa1;
        
        PRM_AccountLegalAgreemntAssociation__c ala = new PRM_AccountLegalAgreemntAssociation__c();
        ala.PRM_Account_Id__c = newAccount.Id;
        ala.PRM_Partner_Agreement_Id__c = pa1.Id;
        ala.PRM_Agreement_Sign_Dt__c = system.today();
        ala.PRM_Contact__c = con[1].Id;
        insert ala;
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cp.Id;
        membership.PRM_Account_Id__c=newAccount.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Distributor';
        membership.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        membership.PRM_Status_Reason_Txt__c = 'test';
        insert membership;
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Account_Id__c=newAccount1.Id;
        membership1.PRM_Status_Nm__c = 'Approved';
        membership1.PRM_Partner_Role__c='Solution Integrator';
        membership1.PRM_Status_Reason_Txt__c = 'test';
        //membership.PRM_Channel_Program_Level_Id__c = cpl1.Id;
        insert membership1;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='EMPLOYEE';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c = false;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        insert cr2;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=newAccount.Id;
        acr.PRM_Relationship_Id__c = cr2.Id;
        acr.PRM_Contact_Id__c=con[1].Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr;
        
        PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=newAccount1.Id;
        acr1.PRM_Relationship_Id__c = cr2.Id;
        acr1.PRM_Contact_Id__c=con[0].Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Start_Date_Dt__c= system.today()-2; 
        acr1.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
        insert acr1;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        insert ee;
        
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'Developer Zone Premier';
        bt.Business_Type_Code__c = 'DZP';
        bt.Is_Active__c = true;
        insert bt;
        
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        PRM_VXEnttlmntMatrix__c em = new PRM_VXEnttlmntMatrix__c();
        em.Business_Types__c = bt.Id;
        em.PRM_IsActive_Ind__c = true;
        em.PRM_Entitlement_Id__c = ee.Id;
        em.RecordTypeId = eBREnttRecTypeId;
        em.PRM_Approval_Type_Nm__c = 'Manual';
        insert em;
        
        
        
        Test.stopTest();
    } 
    
    @isTest static void CheckABTandCBT()
    {
        Account acc = [Select Id from Account where Core_CIM_ID__c = '563210'];
        Contact cont1 = [Select Id from Contact where Email ='jackthomas@malinator.com'];
        Business_Types__c bt = [Select Id from Business_Types__c where Name = 'Developer Zone Premier'];
        Core_Entitlement__c ee = [select Id from Core_Entitlement__c where Name ='Resource & Design Center for Secure Content'];
        
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'jack';
        regRequest.PRM_Last_Name__c = 'thomas';
        regRequest.PRM_Email_ID__c = 'jackthomas@malinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = cont1.Id;
        regRequest.PRM_Salesforce_ID__c = acc.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;
        
        
        List<PRM_Registration_Request__c> regreq = [select Id from PRM_Registration_Request__c where PRM_Email_ID__c = 'jackthomas@malinator.com'];
        List<Id> lstReq = new List<Id>();
        for(PRM_Registration_Request__c req : regreq)
        {
            lstReq.add(req.Id);
        }
        
        Test.startTest();
        ER_CheckAutoapprovalCriteria.CheckAutoApprovalCriteria(lstReq);
        
        
        List<Account_Business_Types__c> abt = [SELECT Id,Account__c from Account_Business_Types__c where Account__c =: acc.Id and Business_Types__c =: bt.Id and Status__c = 'Approved'];
        //System.assertEquals(1, abt.size());
		List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'jackthomas@malinator.com'];
 		System.assertEquals(regreq1[0].Current_Status__c, 'Auto-Approval Pending');
        Test.stopTest();
       
    }
    
    @isTest static void CheckCriteriaMismatch()
    {
        
        Account acc = [Select Id from Account where Core_CIM_ID__c = '563211'];
        Contact cont = [Select Id from Contact where Email ='adamgrill@rediff.com'];
        Business_Types__c bt = [Select Id from Business_Types__c where Name = 'Developer Zone Premier'];
        Core_Entitlement__c ee = [select Id from Core_Entitlement__c where Name ='Resource & Design Center for Secure Content'];
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest1 = new PRM_Registration_Request__c();
        regRequest1.Name = 'RR1';
        regRequest1.PRM_First_Name__c = 'Adam';
        regRequest1.PRM_Last_Name__c = 'Grill';
        regRequest1.PRM_Email_ID__c = 'adamgrill@rediff.com';
        regRequest1.PRM_Preferred_Language__c='ENG';
        regRequest1.Entitlement_Details__c = ee.Id;
        regRequest1.PRM_Contact_Salesforce_Id__c = cont.Id;
        regRequest1.PRM_Salesforce_ID__c = acc.Id;
        regRequest1.Current_Status__c = 'Open';
        regRequest1.PRM_Status__c = 'New';
        regRequest1.RecordTypeId = accCreateRequestId;
        insert regRequest1;
        
        
        List<PRM_Registration_Request__c> regreq = [select Id from PRM_Registration_Request__c where PRM_Email_ID__c = 'adamgrill@rediff.com'];
        List<Id> lstReq = new List<Id>();
        for(PRM_Registration_Request__c req : regreq)
        {
            lstReq.add(req.Id);
        }
        
        Test.startTest();
        ER_CheckAutoapprovalCriteria.CheckAutoApprovalCriteria(lstReq);
        
        
        List<Account_Business_Types__c> abt = [SELECT Id,Account__c from Account_Business_Types__c where Account__c =: acc.Id and Business_Types__c =: bt.Id and Status__c = 'Approved'];
        //System.assertEquals(0,abt.size());
        
        List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'adamgrill@rediff.com'];
        System.assertEquals(regreq1[0].Current_Status__c, 'Open');
        
        Test.stopTest();
       
    }
    
    @isTest static void CheckAutoApprovalException()
    {
        Account acc = [Select Id from Account where Core_CIM_ID__c = '563210'];
        Contact cont1 = [Select Id from Contact where Email ='jackthomas@malinator.com'];
        Business_Types__c bt = [Select Id from Business_Types__c where Name = 'Developer Zone Premier'];
        Core_Entitlement__c ee = [select Id from Core_Entitlement__c where Name ='Resource & Design Center for Secure Content'];
        
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'jack';
        regRequest.PRM_Last_Name__c = 'thomas';
        regRequest.PRM_Email_ID__c = 'exception@exception.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = cont1.Id;
        regRequest.PRM_Salesforce_ID__c = acc.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;
        
        
        List<PRM_Registration_Request__c> regreq = [select Id from PRM_Registration_Request__c where PRM_Email_ID__c = 'jackthomas@malinator.com'];
        List<Id> lstReq = new List<Id>();
        for(PRM_Registration_Request__c req : regreq)
        {
            lstReq.add(req.Id);
        }
        
        Test.startTest();
        ER_CheckAutoapprovalCriteria.CheckAutoApprovalCriteria(lstReq);
        
        
        List<Account_Business_Types__c> abt = [SELECT Id,Account__c from Account_Business_Types__c where Account__c =: acc.Id and Business_Types__c =: bt.Id and Status__c = 'Approved'];
        //System.assertEquals(1, abt.size());
        
        List<PRM_Registration_Request__c> regreq1 = [select Id,Current_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c = 'exception@exception.com'];
        System.assertEquals(regreq1[0].Current_Status__c, 'Open');
        Test.stopTest();
       
    }
}