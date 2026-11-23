@isTest
public class ER_EmailNotificationUtility_Test {

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
        //ento.Core_ERPM_Engagement_Id__c = [SELECT Id FROM Core_ERPM_Engagement__c WHERE Core_Technical_Engagement_Code__c = 'IRDC_Priv' LIMIT 1].Id;
        //ento.Core_AGS_Role_Id__c = [SELECT Id FROM Core_AGS_Role__c WHERE Core_Technical_Name__c = 'RDC Privileged User' LIMIT 1].Id;
        ento.Core_IsActive__c = true;
        insert ento;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = ent.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.Business_Types__c = bt.Id;
        emList.add(em);
        insert emList;
        
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
    public static void testSendEmailwithRegistrationRequest()
    {               
        List<Core_Entitlement__c> ent = [SELECT Id from  Core_Entitlement__c WHERE Name = 'Resource & Design Center for Secure Content'];   
                
        Test.startTest();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_First_Name__c = 'RDC_Emma';
        regRequest.PRM_Last_Name__c = 'RDC_Watson';
        regRequest.PRM_Contact_Country__c = 'US';
        regRequest.PRM_Account_Name__c  = '';
        regRequest.PRM_Contact_Login_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Email_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.Entitlement_Details__c = ent[0].Id;    
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_Preferred_Language__c  = 'ENG';
        regRequest.PRM_Person_Phone_Number__c  = '9891744631';
        insert regRequest;                         
        
        Test.stopTest();
        PRM_Registration_Request__c updatedReq = [Select Id,PRM_Email_Log__c,PRM_Legal_Agreements__c from PRM_Registration_Request__c 
                                                  where PRM_Contact_Login_ID__c='RDC_emmawatson@mailinator.com']; 
      //  System.assert(updatedReq.PRM_Email_Log__c!=null); 
        //System.assertEquals(updatedReq.PRM_Legal_Agreements__c,'IPA_TANDC','Value does not match');
    }
    
    @isTest
    public static void testSendEmailwithRegistrationRequestDiffLang()
    {        
        List<Core_Entitlement__c> ent = [SELECT Id from  Core_Entitlement__c WHERE Name = 'Resource & Design Center for Secure Content'];
        Test.startTest();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_First_Name__c = 'RDC_Emma';
		regRequest.PRM_Last_Name__c = 'RDC_Watson';
		regRequest.PRM_Contact_Country__c = 'US';
        regRequest.PRM_Account_Name__c  = '';
        regRequest.PRM_Contact_Login_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Email_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.Entitlement_Details__c = ent[0].Id;       
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_Preferred_Language__c  = 'ZHO';
        regRequest.PRM_Person_Phone_Number__c  = '9891744631';
        insert regRequest;                         
        
        Test.stopTest();
        PRM_Registration_Request__c updatedReq = [Select Id,PRM_Email_Log__c,PRM_Legal_Agreements__c from PRM_Registration_Request__c 
                                                  where PRM_Contact_Login_ID__c='RDC_emmawatson@mailinator.com']; 
       // System.assert(updatedReq.PRM_Email_Log__c!=null); 
        //System.assertEquals(updatedReq.PRM_Legal_Agreements__c,'IPA_TANDC','Value does not match');
    }
    
    @isTest
    public static void testSendEmail()
    {
        List<Core_Entitlement__c> ent = [SELECT Id from  Core_Entitlement__c WHERE Name = 'Resource & Design Center for Secure Content'];
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_First_Name__c = 'RDC_Emma';
		regRequest.PRM_Last_Name__c = 'RDC_Watson';
		regRequest.PRM_Contact_Country__c = 'US';
        regRequest.PRM_Account_Name__c  = '';
        regRequest.PRM_Contact_Login_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Email_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.Entitlement_Details__c = ent[0].Id;       
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_Preferred_Language__c  = 'ENG';
        regRequest.PRM_Person_Phone_Number__c  = '9891744631';
        insert regRequest;
        
        ER_EmailNotificationUtility.EmailNotification objEmailNotif = new ER_EmailNotificationUtility.EmailNotification();
        //PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
        objEmailNotif.EmailID= regRequest.PRM_Email_ID__c ;
        System.debug('req.PRM_Preferred_Language__c : '+regRequest.PRM_Preferred_Language__c);
        objEmailNotif.Language = regRequest.PRM_Preferred_Language__c ;
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('Registration_Request_ID',regRequest.id);             
        /*if(langCultureForEmail != null){
            paramMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
        }*/
        objEmailNotif.InputParameters=paramMap;                
        objEmailNotif.BusinessEvent='Registration_request_for_new_User_EV1';        
        objEmailNotif.Entitlements= 'Resource & Design Center for Secure Content'; //Temparorily hardcoded to RDC 
        objEmailNotif.BusinessType = 'Developer Zone Premier';
        system.debug('objEmailNotif - '+objEmailNotif);
        Test.startTest();
        System.debug('Here');
        //ER_EmailNotificationUtility.sendEmail(objEmailNotif,null);
        List<PRM_EmailLog__c> updatedReq = [SELECT Id,PRM_ToEmailID__c,PRM_Email_API_Response__c from PRM_EmailLog__c
                                                  where PRM_ToEmailID__c='RDC_emmawatson@mailinator.com']; 
        for(PRM_EmailLog__c req : updatedReq)
        {
            if(req.PRM_Email_API_Response__c.Contains('Template Does not exist for this combination'))
            {
                System.assert(req.PRM_Email_API_Response__c.Contains('Template Does not exist for this combination')); 
            }
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testSendEmailError()
    {              
        Test.startTest();
        List<Core_Entitlement__c> ent = [SELECT Id from  Core_Entitlement__c WHERE Name = 'Resource & Design Center for Secure Content'];
        IsErrorTest = true;
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.PRM_First_Name__c = 'RDC_Emma';
		regRequest.PRM_Last_Name__c = 'RDC_Watson';
		regRequest.PRM_Contact_Country__c = 'US';
        regRequest.PRM_Account_Name__c  = '';
        regRequest.PRM_Contact_Login_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Email_ID__c  = 'RDC_emmawatson@mailinator.com';
        regRequest.PRM_Enterprise_ID__c  = '300002199713' ;
        regRequest.Entitlement_Details__c = ent[0].Id;       
        regRequest.PRM_EV_Token__c  = 'kfi59#%jfd' ;         
        regRequest.PRM_Preferred_Language__c  = 'ZHO';
        regRequest.PRM_Person_Phone_Number__c  = '9891744631';
        insert regRequest;                         
        
        Test.stopTest();
               
        PRM_Registration_Request__c updatedReq = [Select Id,PRM_Email_Log__c,PRM_Legal_Agreements__c from PRM_Registration_Request__c 
                                                  where PRM_Contact_Login_ID__c='RDC_emmawatson@mailinator.com']; 
      //  System.assert(updatedReq.PRM_Email_Log__c!=null); 
        //System.assertEquals(updatedReq.PRM_Legal_Agreements__c,'IPA_TANDC','Value does not match');
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
        system.debug('EVdatetime is not null'+ ce);        
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

        ER_EmailNotificationUtility.EmailNotification objEmailNotif = new ER_EmailNotificationUtility.EmailNotification();  
        objEmailNotif.Entitlements='OLO Label Orderer';
        objEmailNotif.BusinessType = null;
        objEmailNotif.EmailID= 'testrequest@mailinator.com' ;
        objEmailNotif.Language = 'JPN';
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('EV_Contact_ID',testcont.Id);
        objEmailNotif.InputParameters=paramMap;
        //List<PRM_Language_Culture_Mapping__mdt> lngCultureMdt = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt WHERE MasterLabel = :contMap.get(enttl.Core_Contact_Id__c).Core_Preferred_Language__c ];
        //String culture = lngCultureMdt.size() > 0 ? lngCultureMdt[0].PRM_Culture__c : 'en';       
        objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New'; 
        System.debug('objEmailNotif'+objEmailNotif);
        ER_EmailNotificationUtility.sendEmail(objEmailNotif);
        
        PRM_EmailLog__c eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c = 'testrequest@mailinator.com' LIMIT 1];
        System.assertEquals(eLog.PRM_EmailDeliverabilityStatus__c,true,'Email is sent out!! ');
        Test.stopTest();      
    }
    
    @isTest 
    public static void sendEmailError(){
        Test.startTest();
        IsErrorTest = true;
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];

        ER_EmailNotificationUtility.EmailNotification objEmailNotif = new ER_EmailNotificationUtility.EmailNotification();  
        objEmailNotif.Entitlements='OLO Label Orderer';
        objEmailNotif.BusinessType = null;
        objEmailNotif.EmailID= 'testrequest@mailinator.com' ;
        objEmailNotif.Language = 'JPN';
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('EV_Contact_ID',testcont.Id);
        objEmailNotif.InputParameters=paramMap;      
        objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New'; 
        System.debug('objEmailNotif'+objEmailNotif);
        ER_EmailNotificationUtility.sendEmail(objEmailNotif);
        
        PRM_EmailLog__c eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c = 'testrequest@mailinator.com' LIMIT 1];
        System.assertEquals(eLog.PRM_EmailDeliverabilityStatus__c,false,'Email is sent out!! ');
        Test.stopTest();      
    }

}