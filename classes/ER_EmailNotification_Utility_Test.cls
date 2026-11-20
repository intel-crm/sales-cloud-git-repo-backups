@isTest
public class ER_EmailNotification_Utility_Test 
{
    public static boolean IsErrorTest = false;
    
    @testSetup
    static void DataSetup() {
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'Developer Zone Premier';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'DZP';
        insert bt;
        
         Core_ERPM_Engagement__c engg = new Core_ERPM_Engagement__c();
        engg.Name = 'Resource & Design Center';
        engg.Core_IsActive__c = true;
        engg.Core_Technical_Engagement_Code__c = 'IRDC_Priv';
        engg.Core_Technical_DeDup_Number__c = 'B2B';
        engg.Core_Engagement_Type__c = 'SEC';
        insert engg;
        
        Core_AGS_Role__c role = new Core_AGS_Role__c();
        role.Core_Technical_Name__c = 'RDC Privileged User';
        role.Core_IsActive__c = true;
        role.Name = 'Resource & Design Center for Secure content';
        insert role;
        
         Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'Secure Content (CNDA required)';
        ent.Core_ERPM_Engagement_Id__c = [SELECT Id FROM Core_ERPM_Engagement__c WHERE Core_Technical_Engagement_Code__c = 'IRDC_Priv' LIMIT 1].Id;
        ent.Core_AGS_Role_Id__c = [SELECT Id FROM Core_AGS_Role__c WHERE Core_Technical_Name__c = 'RDC Privileged User' LIMIT 1].Id;
        ent.Core_IsActive__c = true;
        insert ent; 
        
        Core_Entitlement__c ento = new Core_Entitlement__c();
        ento.Name = 'OLO Label Orderer';
        ento.Core_Display_Name__c = 'OLO Label Orderer';
        ento.Core_IsActive__c = true;
        insert ento;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); 
        em.PRM_Entitlement_Id__c = ent.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.Business_Types__c = bt.Id;
        emList.add(em);
        insert emList;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc = PRM_TestUtility.getAccount();
        acc.RecordTypeId = recordTypeIdAccount;
        acc.Name = 'Dell US';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);  
        
        Contact cont= PRM_TestUtility.getContact();
        cont.AccountId=acc.Id;
        cont.MailingCountry='India';
        insert(cont);
     
        Core_Contact_Entitlement__c ceOld1=new Core_Contact_Entitlement__c();
        ceOld1.Core_Contact_Id__c=cont.Id;
        ceOld1.Core_Entitlement_Id__c=ent.Id;
        ceOld1.Core_Selected__c=false;
        ceOld1.Core_Status__c='Pending';
        ceOld1.Core_Email_Pending_To_Requester_Ind__c=true;
        insert ceOld1;
        
        Core_Contact_Entitlement__c ceOld2=new Core_Contact_Entitlement__c();
        ceOld2.Core_Contact_Id__c=cont.Id;
        ceOld2.Core_Entitlement_Id__c=ento.Id;
        ceOld2.Core_Selected__c=false;
        ceOld2.Core_Status__c='Pending';
        ceOld2.Core_Email_Pending_To_Requester_Ind__c=true;
        insert ceOld2;
    }
  	@isTest 
    public static void updateEntitlmentToComplete(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_IPA_Email_Verification_Date__c=Datetime.now();
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
            
        update ce;
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        
        System.assertEquals(ceUpd.Core_Email_Pending_To_Requester_Ind__c,true,'Change in  Value on WlcmEmail is sent out!! ');
        
    }      
    @isTest 
    public static void updateEntitlmentToCompleteJapan(){
        Test.startTest();
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
		List<ER_EmailNotification_Utility.EmailNotification> objEmailNotifList= new List<ER_EmailNotification_Utility.EmailNotification>();
        ER_EmailNotification_Utility.EmailNotification objEmailNotif = new ER_EmailNotification_Utility.EmailNotification();  
        objEmailNotif.Entitlements='OLO Label Orderer';
        objEmailNotif.BusinessType = null;
        objEmailNotif.EmailID= 'testrequest@mailinator.com' ;
        objEmailNotif.Language = 'JPN';
        objEmailNotif.Country='US';
        objEmailNotif.geo='jp';
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('EV_Contact_ID',testcont.Id);
        objEmailNotif.InputParameters=paramMap;     
        objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New';
        ER_EmailNotification_Utility.EmailNotification objEmailNotif1 = new ER_EmailNotification_Utility.EmailNotification();
        List<ER_Email_Configuration__mdt> mdtList = new list<ER_Email_Configuration__mdt>();
        ER_EmailNotification_Utility.GetEmailConfigurationMetadata(objEmailNotif1,mdtList);
        List<String> templateEmptylist = New List<String>();
        ER_EmailNotification_Utility.sendEmail(objEmailNotifList,templateEmptylist);
        
        List<PRM_EmailLog__c> eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c = 'testrequest@mailinator.com' LIMIT 1];
        System.assertEquals(eLog.size() > 0,false,'Email is sent not out!! ');
        Test.stopTest(); 
        List<string> toaddess = new List<string>();
        for(integer i=0; i < 14; i++){
           toaddess.add(i+'toaddess@bingtoadd.com');
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toaddess);
        mail.setTargetObjectId(testcont.Id);
    }
    @isTest
    public static void sendAckEmail(){
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id accountApprovalRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c req = new PRM_Registration_Request__c();
        req.RecordTypeId=accountApprovalRT;
        req.Name= 'RDCAck1';
        req.PRM_First_Name__c= 'RDCAck1';
        req.PRM_Last_Name__c= 'RDCAck1';
        req.PRM_Contact_Country__c= 'USA';
        req.PRM_Contact_Login_ID__c= 'test_rdcuser1@mailinator.com';
        req.PRM_Email_ID__c= 'test_rdcuser1@mailinator.com';
        req.PRM_Enterprise_ID__c= '3000002446643';
        req.Entitlement_Details__c= entt.Id;
        req.PRM_EV_Token__c= 'EAAAAFEKpZnzESjs92XoY55f4ngu9BUyuOIraFcrFXziDwRdlXdOuIOyDgk3K+dJD7x3mZ83lu3LT3yn9PHHd7Z2q0CXeXQOFnEV2oKB/DivrTpg+TYum1pfXY2/Yq5Vin+38436zR3W4Z7zO9albgNnAljH0lj7JnfGAu90Z8Ju9K4oa1uzPqUoRXcacHaLGediMDSAhLcrvxqNwgthOeJ0loAbLMZYnQQ+3a6YOWAiyAsvUsGEXKfV1M2KNSbYeos8lA==';
        req.PRM_Person_Phone_Number__c= '3232';
        req.PRM_Preferred_Language__c= 'ENG';
        req.PRM_Account_Name__c= 'Apple; Inc.';
        req.PRM_Address_Line_1__c= '470 Potrero Ave';
        req.PRM_City__c= 'Sunnyvale';
        req.PRM_Country__c= 'USA';
        req.PRM_State_Province__c= 'CA';
        req.PRM_Zip_Postal_Code__c= '94085-4117';
        req.PRM_Account_URL__c= 'www.rdc.com';
        req.PRM_Account_Phone__c  = '9891744632' ;
        req.PRM_Company_Size__c  = '10000+' ;      
        req.PRM_Company_Email_Domain__c  = null;
        req.PRM_EV_flag__c  = false ;                            
        req.PRM_EmailVerifiedDateTime__c  = DateTime.now() ;
        req.PRM_Legal_Agreements__c  = 'DZP_TANDC' ;
        req.PRM_Status__c  = 'New' ;  
        req.PRM_Status_Reason__c  = null;   
        
        Test.startTest();
        insert req;
        Test.stopTest();
        PRM_EmailLog__c eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c];
        System.assertEquals(eLog.PRM_EmailDeliverabilityStatus__c,true,'Email is sent out!! ');
    
    }
}