@isTest
public class PRM_SendRegistrationRequestInvite_Test {
	 @testSetup        
    static void setupDataCreation()
    {
        
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<PRM_Registration_Request__c> regReqInsertList = new List<PRM_Registration_Request__c>();
        Account acc = PRM_TestUtility.getAccount();
        acc.Name = 'Dell US';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);  
        
        Contact cont= PRM_TestUtility.getContact();
        cont.AccountId=acc.Id;
        insert(cont);
        
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        
        Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
        objAGSRole.Name= 'Test_AGS_Role_02';
        objAGSRole.Core_Technical_Name__c = 'Test_AGSRole_02_TechName';
        objAGSRole.Core_IsActive__c = true;
        insert objAGSRole;	
        
        Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
        objEntitlement1.Name = 'PSG Disti Quoting Access';
        objEntitlement1.Core_Display_Name__c = 'PSG Disti Quoting Access';
        objEntitlement1.Core_IsActive__c = true;
        objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement1.Core_Category__c = '';
        objEntitlement1.Core_Sub_Category__c = '';       
        objEntitlement1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        objEntitlement1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        insert objEntitlement1;
        
        Core_Contact_Entitlement__c ceOld=new Core_Contact_Entitlement__c();
        ceOld.Core_Contact_Id__c=cont.Id;
        ceOld.Core_Entitlement_Id__c=objEntitlement1.Id;
        ceOld.Core_Selected__c=false;
        ceOld.Core_Status__c='Pending';
        ceOld.Core_Email_Pending_To_Requester_Ind__c=true;
        insert ceOld;
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        insert cprogram;
        
        PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_First_Name__c = 'Test Request';
        rr.PRM_Last_Name__c = 'New';
        rr.PRM_Email_ID__c = 'testrequest@mailinator.com';
        rr.PRM_Preferred_Language__c='FRA';
        rr.PRM_Account_Name__c='Intel';
        rr.PRM_Company_Email_Domain__c='intel.com';
        rr.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        rr.PRM_Address_Line_2__c='Bengaluru,India'; 
        rr.PRM_City__c='Las Vegas';
        rr.PRM_State_Province__c='NY';
        rr.PRM_Country__c='USA';
        rr.PRM_Contact_Login_ID__c = 'user222@outlook.com';
        rr.PRM_Enterprise_ID__c = '76567';
        //rr.PRM_Job_Function__c = 'OPER';
        rr.PRM_Profession__c = 'PROFESSOR';
        rr.PRM_Person_Phone_Number__c = '9876846543';
        rr.PRM_Subscriptions__c = 'CSP_Sub';
        rr.PRM_Matching_Contact__c = cont.Id;
        rr.PRM_Salesforce_ID__c = acc.Id;
        rr.RecordTypeId = emailVerificationRT;
        rr.PRM_Partner_Type__c = 'Original Design Manufacturer (ODM)';
        rr.PRM_Account_Partner_Type__c = 'Original Design Manufacturer (ODM)';
        rr.PRM_Partner_Role__c = 'Manufacturer';
		rr.PRM_Channel_Program__c = cprogram.Id;
        rr.PRM_Contact_Country__c='fr';
        regReqInsertList.add(rr);
       insert regReqInsertList;
        
               
    }
    
    /*
    @isTest 
    public static void sendInviteEmail_Test(){
         PRM_Registration_Request__c rr = [Select Id,PRM_First_Name__c,PRM_Person_Phone_Number__c from PRM_Registration_Request__c
                                         where PRM_Person_Phone_Number__c = '9876846543'];
        List<PRM_Language_Culture_Mapping__mdt> lng  =  new List<PRM_Language_Culture_Mapping__mdt>();
        PRM_Language_Culture_Mapping__mdt lcm = new PRM_Language_Culture_Mapping__mdt();
        lcm.MasterLabel = 'ENG';
        lcm.PRM_Culture__c = 'en';
        lcm.PRM_Country__c = 'GBR';
        lcm.PRM_Country_Cd__c = 'us';
        lng.add(lcm);

        PRM_SendRegistrationRequestInvite.sendInviteEmail(rr.id);
    }
    */
}