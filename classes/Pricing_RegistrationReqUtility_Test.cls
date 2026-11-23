@isTest
public class Pricing_RegistrationReqUtility_Test {
    
    @testSetup    
    static void setupDataCreation()
    {
        Account acc = PRM_TestUtility.getAccount();
        acc.Name = 'Dell US';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);  
        
        Core_Account_Whitelisted_Domains__c accWhitelist = new Core_Account_Whitelisted_Domains__c();
        accWhitelist.Name = 'mailinator.com';
        accWhitelist.Account__c = acc.Id;
        accWhitelist.Inactive_Indicator__c = false;
        insert accWhiteList;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='New Partner Program';
        cprogram.PRM_programCode__c='NPP';
        insert(cprogram);
        
        ChannelProgram iqrProgram = new ChannelProgram();
        iqrProgram.Name='Intel Quote Request';
        iqrProgram.PRM_programCode__c='IQR';
        insert iqrProgram;
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
        PRM_PartnerAgreement__c pa = PRM_TestUtility.getPartnerAgreement();
        pa.PRM_Channel_Program_Id__c = cp.Id;
        insert pa;
        
        PRM_PartnerAgreement__c pa1 = PRM_TestUtility.getPartnerAgreement();
        pa1.PRM_Channel_Program_Id__c = cp.Id;
        pa1.Name='IQR Terms & Condition';
        pa1.PRM_Language_Codes__c='';
        pa1.PRM_Agreement_Cd__c='IQR_TANDC';
        // pa1.PRM_Partner_Role__c = 'Service Provider';
        insert pa1;
        
        PRM_PartnerAgreement__c pa2 = PRM_TestUtility.getPartnerAgreement();
        pa2.PRM_Channel_Program_Id__c = cp.Id;
        pa2.Name='PA2';
        pa2.PRM_Language_Codes__c='';
        pa2.PRM_Agreement_Cd__c='PA2';
        insert pa2;
        
        PRM_AccountChannelMembership__c membership = new PRM_AccountChannelMembership__c();
        membership.PRM_Channel_Program_Id__c=cprogram.Id;
        membership.PRM_Account_Id__c=acc.Id;
        membership.PRM_Status_Nm__c = 'Approved';
        membership.PRM_Partner_Role__c='Seller';
        insert(membership);  
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=acc.Id;
        membership1.PRM_Status_Nm__c = 'Pending';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        insert(membership1);
        
        PRM_AccountChannelMembership__c membership2 = new PRM_AccountChannelMembership__c();
        membership2.PRM_Account_Id__c=acc.Id;
        membership2.PRM_Status_Nm__c = 'Pending';
        membership2.PRM_Channel_Program_Id__c=cp.Id;
        membership2.PRM_Partner_Role__c='FPGA Designer';
        insert(membership2);
        
        
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
        bm.Name='BatchFieldValues';
        bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
        bm.PRM_SchedulingHour__c=6;
        bm.PRM_NoOfRecords__c=300;
        bm.PRM_PartnerRole__c = 'Service Provider';
        insert bm;
        
         
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        
        Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
        objAGSRole.Name= 'Test_AGS_Role_02';
        objAGSRole.Core_Technical_Name__c = 'Test_AGSRole_02_TechName';
        objAGSRole.Core_IsActive__c = true;
        insert objAGSRole;
        
        
        /*List<PRM_Registration_Request__c> regRequests = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testuser@dell.com';
        newRequest.PRM_Channel_Program__c = iqrProgram.Id;
        newRequest.PRM_Legal_Agreements__c = 'IQR_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        newRequest.PRM_Preferred_Language__c = 'ENG';
        newRequest.PRM_Contact_Country__c = 'US';
        //newRequest.PRM_Matching_Contact__c = con.Id;
        newRequest.PRM_Partner_Type__c = 'Original Equipment Manufacturer (OEM)';
        newRequest.PRM_Salesforce_ID__c = acc.Id;
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        insert newRequest;*/
        
        system.debug('Queries 111===>'+Limits.getQueries());
        test.startTest();
         system.debug('Queries 222===>'+Limits.getQueries());
        List<Core_Entitlement__c> entlmnts = new List<Core_Entitlement__c>();
        Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
        objEntitlement.Name = 'IQR Quote Request User';
        objEntitlement.Core_Display_Name__c = 'IQR Quote Request User';
        objEntitlement.Core_IsActive__c = true;
        objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement.Core_Category__c = '';
        objEntitlement.Core_Sub_Category__c = '';       
        objEntitlement.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        objEntitlement.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entlmnts.add(objEntitlement);
        
        Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
        objEntitlement1.Name = 'IQR Quote Request Customer Drafter Access';
        objEntitlement1.Core_Display_Name__c = 'IQR Quote Request Customer Drafter Access';
        objEntitlement1.Core_IsActive__c = true;
        objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement1.Core_Category__c = '';
        objEntitlement1.Core_Sub_Category__c = '';       
        objEntitlement1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        objEntitlement1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entlmnts.add(objEntitlement1);
        
        Core_Entitlement__c objEntitlement2 = new Core_Entitlement__c();
        objEntitlement2.Name = 'Partner Portal';
        objEntitlement2.Core_Display_Name__c = 'Partner Portal';
        objEntitlement2.Core_IsActive__c = true;
        objEntitlement2.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement2.Core_Category__c = '';
        objEntitlement2.Core_Sub_Category__c = '';       
        //objEntitlement2.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        //objEntitlement2.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entlmnts.add(objEntitlement2);       
        //insert entlmnts;
        
        system.debug('Queries 333===>'+Limits.getQueries());
        Test.stopTest();
        system.debug('Queries 444===>'+Limits.getQueries());
    }
    
    private static testMethod void updateRegRequest(){
        system.debug('Queries 555===>'+Limits.getQueries());
        test.startTest();
        system.debug('Queries 666===>'+Limits.getQueries());
        //List<PRM_Registration_Request__c>  regReq = [SELECT id,Name,RecordTypeId,PRM_Salesforce_ID__c FROM PRM_Registration_Request__c LIMIT 1];
        List<Account> acc = [SELECT id FROM Account LIMIT 1];
        List<ChannelProgram> pgm = [SELECT id FROM ChannelProgram WHERE PRM_programCode__c='IQR'];
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        
        List<PRM_Registration_Request__c> regRequests = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c newRequest1 = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest1.PRM_CIM_ID__c='';
        newRequest1.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest1.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest1.PRM_Email_ID__c = 'testuser@dell.com';
        newRequest1.PRM_Channel_Program__c = pgm[0].Id;
        newRequest1.PRM_Legal_Agreements__c = 'IQR_TANDC';
        newRequest1.PRM_Partner_Relationship__c = '';
        newRequest1.PRM_Preferred_Language__c = 'ENG';
        newRequest1.PRM_Contact_Country__c = 'US';
        //newRequest.PRM_Matching_Contact__c = con.Id;
        newRequest1.PRM_Partner_Type__c = 'Original Equipment Manufacturer (OEM)';
        newRequest1.PRM_Salesforce_ID__c = acc[0].Id;
        newRequest1.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest1.RecordTypeId = accCreateRequestId;
        insert newRequest1;
        
        //regReq[0].RecordTypeId = accCreateRequestId;
        //regReq[0].PRM_Salesforce_ID__c = acc[0].Id;
        //regReq[0].PRM_EmailVerifiedDateTime__c = system.now();
        //update regReq[0];
        
        List<Contact> conts = [SELECT id,Name,AccountId FROM Contact LIMIT 1];
        List<PRM_AccountLegalAgreemntAssociation__c> legalAgrmntAssocs = [SELECT id FROM PRM_AccountLegalAgreemntAssociation__c];
        system.debug('legalAgrmntAssocs==>'+legalAgrmntAssocs.size());
        system.assert(conts.size() > 0);
        
        Pricing_RegistrationReqUtility.sendWelcomeEmail(new List<Id>{conts[0].Id});
        
        
        List<ChannelProgram> iqrPrograms = [SELECT id FROM ChannelProgram WHERE PRM_programCode__c='IQR'];
        PRM_Registration_Request__c newRequest = PRM_TestUtility.getPRMRegistrationRequest();
        newRequest.PRM_CIM_ID__c='';
        newRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        newRequest.PRM_EV_Token__c = 'gwiur#@98321327';
        newRequest.PRM_Email_ID__c = 'testiqr@dell.com';
        newRequest.PRM_Channel_Program__c = iqrPrograms[0].Id;
        newRequest.PRM_Legal_Agreements__c = 'IQR_TANDC';
        newRequest.PRM_Partner_Relationship__c = '';
        //newRequest.PRM_Preferred_Language__c = 'ENG';
        //newRequest.PRM_Matching_Contact__c = con.Id;
        newRequest.PRM_Partner_Type__c = 'Original Equipment Manufacturer (OEM)';
        newRequest.PRM_Salesforce_ID__c = conts[0].AccountId;
        newRequest.PRM_Contact_Salesforce_Id__c = conts[0].Id;
        newRequest.PRM_ProcessInstanceWorkItem_Id__c = '';
        newRequest.PRM_Contact_Country__c = 'US';
        newRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        insert newRequest;
        
        system.debug('Queries 777===>'+Limits.getQueries());
        
        newRequest.RecordTypeId = accCreateRequestId;
        newRequest.PRM_Salesforce_ID__c = conts[0].AccountId;
        newRequest.PRM_Contact_Salesforce_Id__c = conts[0].Id;
        newRequest.PRM_EmailVerifiedDateTime__c = system.now();
        update newRequest;
        system.debug('Queries 888===>'+Limits.getQueries());
        test.stopTest();
        
    }
}