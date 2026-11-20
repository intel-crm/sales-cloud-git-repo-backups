@isTest
public class PRM_BulkDataUpload_Batch_Test {
    public static Id accountId;
 @testSetup 
    //test data creation
    static void setupDataCreation(){
        DateTime reqTime = System.now();
        List<IPA_Batch_Configurations__mdt> listBatchConfigItems = [select id, DeveloperName, Record_Limit__c, PRM_SchedulingTimeMins__c, PRM_StandardEmailBulk__c from IPA_Batch_Configurations__mdt where DeveloperName =: 'PRM_BulkBatchConfigurableItems' limit 1];
        Account acc = new Account();
        acc.Name ='Intel1223';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='Agriculture';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'abc.com';
        acc.AccountNumber = '5879807687';
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.RecordTypeId = accountRecordTypeIntel;
        insert(acc);
        
        accountId=acc.Id;
        system.debug('Account inserted is--'+acc);
        system.debug('Account inserted name is--'+acc.Name);
        system.debug('Account inserted id is--'+acc.Id);
        system.debug('Account inserted id in variable is--'+accountId);
        
        Contact con1 = new Contact();
        con1.FirstName='Mathew';
        con1.LastName='Smithy';
        con1.Email='testmathewsmithy@mailinator.com';
        con1.Phone='9999779791';
        con1.AccountId = acc.Id;
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';        
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'xyz';
        con1.Core_IPA_Email_Verification_Date__c = System.now();
        con1.Core_Enterprise_Id__c = '463179832';
        con1.MailingCountry='USA';
        insert con1;

        Contact con2 = new Contact();
        con2.FirstName='Mathewsam';
        con2.LastName='Smithyjon';
        con2.Email='testmathewsmithy767ahoo@mailinator.com';
        con2.Phone='9999779791';
        con2.AccountId = acc.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'xyz';
        con2.Core_Enterprise_Id__c = null;
        con2.MailingCountry='USA';
        insert con2;
        
        Contact con3 = new Contact();
        con3.FirstName='Mathewsam';
        con3.LastName='Smithyjon';
        con3.Email='testmathewsmithy767weewreahoo@mailinator.com';
        con3.Phone='9999779791';
        con3.AccountId = acc.Id;
        con3.Core_Job_Function__c='Branch Manager';
        con3.Core_eRPM_Language_Code__c='Eng';        
        con3.Core_IPA_PartnerRole__c = 'Service Provider';
        con3.Core_Login_Id__c = 'xyz';
        con3.Core_Enterprise_Id__c = null;
        con3.Core_IPA_Email_Verification_Date__c = System.now();
        con3.MailingCountry='USA';
        insert con3;
        
        Contact cont4 = new Contact();
        cont4.FirstName='Mathew';
        cont4.LastName='Smithy';
        cont4.Email='testmathewsmithy767yu@mailinator.com';
        cont4.Phone='9999779791';
        cont4.AccountId = acc.Id;
        cont4.Core_Job_Function__c='Branch Manager';
        cont4.Core_eRPM_Language_Code__c='Eng';        
        cont4.Core_IPA_PartnerRole__c = 'Service Provider';
        cont4.Core_Login_Id__c = 'xyz';
        cont4.Core_IPA_Email_Verification_Date__c = null;
        cont4.Core_Enterprise_Id__c = '77665544';
        cont4.MailingCountry='USA';
        insert cont4;
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Partner';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=acc.Id;
        membership1.PRM_Status_Nm__c = 'Approved';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        membership1.PRM_Status_Reason_Txt__c='Test class';
        insert(membership1);

        
       PRM_ContactRelationships__c admin = new PRM_ContactRelationships__c();   //Contact Relationship
        admin.Name='Partner Admin';
        admin.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        admin.PRM_Channel_Program_Id__c = cp.Id;
        admin.PRM_Default_Relationship_Ind__c = true;
        insert admin;
        
        PRM_ContactRelationships__c employee = new PRM_ContactRelationships__c();   //Contact Relationship
        employee.Name='Employee';
        employee.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
        employee.PRM_Channel_Program_Id__c = cp.Id;
        employee.PRM_Default_Relationship_Ind__c = true;
        insert employee;
        
        
        PRM_Contact_Relationship__c emp = new PRM_Contact_Relationship__c();
        emp.Name ='Employee';
        emp.PRM_Relationship_Name__c='Employee';
        emp.PRM_Relationship_Id__c=employee.Id;
        insert emp;
        
        PRM_Contact_Relationship__c adm = new PRM_Contact_Relationship__c();
        adm.Name ='Partner Admin';
        adm.PRM_Relationship_Name__c='Partner Admin';
        adm.PRM_Relationship_Id__c=admin.Id;
        insert adm;
        
        PRM_Account_Contact_Relationship__c acrEmpA = new PRM_Account_Contact_Relationship__c();
        acrEmpA.PRM_Relationship_Id__c = employee.Id;
        acrEmpA.PRM_Account_Id__c = acc.Id;
        acrEmpA.PRM_Contact_Id__c = cont4.Id;
        acrEmpA.PRM_InActive_Ind__c= false;
        acrEmpA.PRM_Status_Nm__c = 'Pending Action';
        acrEmpA.PRM_Source_Agent__c = 'Bulk Invite';
        acrEmpA.PRM_Status_Reason_Txt__c='Test acr4';
        insert acrEmpA;
        
        
        PRM_Account_Contact_Relationship__c acrEmp1 = new PRM_Account_Contact_Relationship__c();
        acrEmp1.PRM_Relationship_Id__c = employee.Id;
        acrEmp1.PRM_Account_Id__c = acc.Id;
        acrEmp1.PRM_Contact_Id__c = con1.Id;
        acrEmp1.PRM_InActive_Ind__c= true;
        acrEmp1.PRM_Status_Nm__c = 'Pending Action';
        acrEmp1.PRM_Status_Reason_Txt__c='Test acr1';
        insert acrEmp1;
        
        PRM_Account_Contact_Relationship__c acrEmp00 = new PRM_Account_Contact_Relationship__c();
        acrEmp00.PRM_Relationship_Id__c = employee.Id;
        acrEmp00.PRM_Account_Id__c = acc.Id;
        acrEmp00.PRM_Contact_Id__c = con2.Id;
        acrEmp00.PRM_InActive_Ind__c= true;
        acrEmp00.PRM_Status_Nm__c = 'Pending Action';
        acrEmp00.PRM_Status_Reason_Txt__c='Test acr2';
        insert acrEmp00;

        PRM_Account_Contact_Relationship__c acrEmpl = new PRM_Account_Contact_Relationship__c();
        acrEmpl.PRM_Relationship_Id__c = employee.Id;
        acrEmpl.PRM_Account_Id__c = acc.Id;
        acrEmpl.PRM_Contact_Id__c = con3.Id;
        acrEmpl.PRM_InActive_Ind__c= false;
        acrEmpl.PRM_Status_Nm__c = 'Pending Action';
        acrEmpl.PRM_Status_Reason_Txt__c='Test acr3';
        insert acrEmpl;
     
       
        
       
        
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        objCLE.Core_Origin__c = PRM_BulkDataUpload_Batch.LOG_ENTRY_ORIGIN;
        objCLE.Core_Project__c = PRM_BulkDataUpload_Batch.LOG_ENTRY_PROJECT;
        objCLE.Core_Scope__c = PRM_BulkDataUpload_Batch.LOG_ENTRY_SCOPE;
        objCLE.Core_Severity__c = PRM_BulkDataUpload_Batch.LOG_ENTRY_SEVERITY;
        objCLE.Core_Message__c =  'Test Message';
        objCLE.Core_When__c = system.now();
        objCLE.Core_Details__c = 'Test Details';
        objCLE.Core_sObjectId__c = con1.Id;
        objCLE.Core_sObjectType__c = 'Contact';
        objCLE.Core_Tags__c = 'Test Tags';
        insert objCLE;

        
        List<PRM_Bulk_Data_Upload__c> bulkrecs = new List<PRM_Bulk_Data_Upload__c>();
       
        PRM_Bulk_Data_Upload__c bulkRecord = new PRM_Bulk_Data_Upload__c();
        bulkRecord.PRM_Object__c='Contact';
        bulkRecord.PRM_OperationType__c='Insert';
        bulkRecord.PRM_AccountId__c =acc.Id;
        bulkRecord.PRM_Contact_Id__c =con3.Id;
        bulkRecord.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord.CreatedById = UserInfo.getUserId();
        bulkRecord.PRM_Comments__c = 'Created on Today';
        bulkRecord.PRM_ContactEmail__c ='testmathewsmithy767yu@mailinator.com';
    bulkRecord.PRM_First_Name__c ='testabcxyx';
        bulkRecord.PRM_Last_Name__c='designer123';
        bulkRecord.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord.PRM_Suppress_Email__c=false;
        bulkRecord.PRM_Partner_Relationship__c='Employee;Partner Admin';
        bulkRecord.PRM_Status__c='New';
        bulkRecord.PRM_Partner_Program__c='IPA';
        bulkRecord.PRM_Status_Reason__c='NA';
        bulkRecord.PRM_Preferred_Language__c = 'ENG';
        bulkRecord.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord.PRM_RegistrationType__c = 'Admin Invite';
        bulkrecs.add(bulkRecord);
        
        
                
       PRM_Bulk_Data_Upload__c bulkRecord1 = new PRM_Bulk_Data_Upload__c();
        bulkRecord1.PRM_Object__c='Contact';
        bulkRecord1.PRM_Contact_Id__c =con1.Id;
        bulkRecord1.PRM_OperationType__c='Update';
        bulkRecord1.PRM_AccountId__c = con1.AccountId;
        bulkRecord1.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord1.PRM_Suppress_Email__c = false;
        bulkRecord1.CreatedById = UserInfo.getUserId();
        bulkRecord1.PRM_Comments__c = 'Created on Today';
        bulkRecord1.PRM_ContactEmail__c ='testmathewsmithy@mailinator.com';  
        bulkRecord1.PRM_First_Name__c ='testcontact';
        bulkRecord1.PRM_Last_Name__c='designer1';
        bulkRecord1.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord1.PRM_Partner_Relationship__c='Employee';
        bulkRecord1.PRM_Status__c='New';
        bulkRecord1.PRM_Partner_Program__c='IPA';
        bulkrecord1.PRM_BatchID__c = 'BATCH002';
        bulkRecord1.PRM_Preferred_Language__c = 'ENG';
        bulkRecord1.PRM_Email_Template__c = 'CampaignInviteForBulk';
       // bulkRecord1.PRM_RegistrationType__c = 'Admin Invite';
        bulkrecs.add(bulkRecord1);
        
        PRM_Bulk_Data_Upload__c bulkRecord00 = new PRM_Bulk_Data_Upload__c();
        bulkRecord00.PRM_Object__c='Contact';
        bulkRecord00.PRM_Contact_Id__c =con2.Id;
        bulkRecord00.PRM_OperationType__c='Update';
        bulkRecord00.PRM_AccountId__c =con2.AccountId;
        bulkRecord00.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord00.PRM_Suppress_Email__c = false;
        bulkRecord00.CreatedById = UserInfo.getUserId();
        bulkRecord00.PRM_Comments__c = 'Created on Today';
        bulkRecord00.PRM_ContactEmail__c ='testmathewsmithy767ahoo@mailinator.com';  
        bulkRecord00.PRM_First_Name__c ='testcontact';
        bulkRecord00.PRM_Last_Name__c='designer1';
        bulkRecord00.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord00.PRM_Partner_Relationship__c='Employee';
        bulkRecord00.PRM_Status__c='New';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
       // bulkRecord00.PRM_RegistrationType__c = 'Admin Invite';
        bulkrecs.add(bulkRecord00);
          
        PRM_Bulk_Data_Upload__c bulkRecord3 = new PRM_Bulk_Data_Upload__c();
        bulkRecord3.PRM_Object__c='Contact';
        bulkRecord3.PRM_OperationType__c='Insert';
        bulkRecord3.PRM_Contact_Id__c =cont4.Id;
        bulkRecord3.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord3.CreatedById = UserInfo.getUserId();
        bulkRecord3.PRM_Suppress_Email__c = false;
        bulkRecord3.PRM_Comments__c = 'Created on Today';
        bulkRecord3.PRM_First_Name__c ='abcxyz';
        bulkRecord3.PRM_Last_Name__c='123xyasd';
        bulkRecord3.PRM_AccountId__c =acc.Id;
        bulkRecord3.PRM_ContactEmail__c ='testrequest1231000@mailinator.com';    
        bulkRecord3.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord3.PRM_Partner_Relationship__c='Partner Admin';
        bulkRecord3.PRM_Status__c='New';
        bulkRecord3.PRM_Partner_Program__c='IPA';
        bulkRecord3.PRM_Status_Reason__c='NA';
        bulkRecord3.PRM_Contact_Phone__c = '79872099327';
        bulkrecord3.PRM_BatchID__c = 'BATCH002';
        bulkRecord3.PRM_Preferred_Language__c = 'ENG';
        bulkRecord3.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord3.PRM_RegistrationType__c = 'Admin Invite';
        bulkrecs.add(bulkRecord3);
        
        
        for(integer i =0; i<= 4; i++){
            STring indexvalue = String.valueOf(i);
            String email = 'testrequest000'+indexvalue+'@mailinator.com';
            PRM_Bulk_Data_Upload__c bulkyrecord = new PRM_Bulk_Data_Upload__c();
            bulkyrecord.PRM_Object__c='Contact';
            bulkyrecord.PRM_OperationType__c='Insert';
            //bulkRecord3.PRM_Contact_Id__c =con1.Id;
            bulkyrecord.PRM_Upload_Type__c ='Bulk Invite';
            bulkyrecord.CreatedById = UserInfo.getUserId();
            bulkyrecord.PRM_Suppress_Email__c = false;
            bulkyrecord.PRM_Comments__c = 'Created on Today';
            bulkyrecord.PRM_First_Name__c ='abcxyz';
            bulkyrecord.PRM_Last_Name__c='123xyasd';
            bulkyrecord.PRM_AccountId__c =acc.Id;
            bulkyrecord.PRM_ContactEmail__c =email;    
            bulkyrecord.PRM_IPA_Partner_Role__c='Service Provider';
            bulkyrecord.PRM_Partner_Relationship__c='Partner Admin';
            bulkyrecord.PRM_Status__c='New';
            bulkyrecord.PRM_Partner_Program__c='IPA';
            bulkyrecord.PRM_Status_Reason__c='NA';
            bulkyrecord.PRM_BatchID__c = 'BATCH003';
            bulkyrecord.PRM_Upload_Type__c = 'Bulk Add';
            bulkyRecord.PRM_Preferred_Language__c = 'ENG';
            bulkyRecord.PRM_Email_Template__c = 'CampaignInviteForBulk';
          //  bulkyRecord.PRM_RegistrationType__c = 'Admin Invite';
            bulkrecs.add(bulkyrecord);
            
        }
        
        
        if(bulkrecs.size()>0)
        {
            Database.insert(bulkRecs, false); 
        } 
        
        String recordId = cont4.id;
        String callType= 'POST';
        String module = 'IPA';
        String reqPayload = 'Test';
        String respPayload = 'Test';
        Integer respCode =200;
        String systemName ='IPA';
        String className = 'PRM_BulkDataUpload_Batch';
        PRM_BulkDataUpload_Batch.createIntegrationLog(recordId, callType, module, reqPayload, respPayload, respCode, systemName, className);
    }
    @isTest
    static void bulkContacts(){
        system.debug('Method 1 called');
        test.startTest();
        List<IPA_Batch_Configurations__mdt> listBatchConfigItems =  [select id, DeveloperName, Record_Limit__c, PRM_SchedulingTimeMins__c, PRM_StandardEmailBulk__c from IPA_Batch_Configurations__mdt where DeveloperName =: 'PRM_BulkBatchConfigurableItems' limit 1];
       // Account acc = [select id, Name from Account where Name =: 'Intel1223'];
        //List<Account> acc = [select id, Name from Account where Name =: 'Intel1223'];
       // Account acc = [SELECT Id, Name FROM Account WHERE Id =: accountId LIMIT 1];
        
        Account acc = new Account();
        acc.Name ='Intel01082025';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='Agriculture';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'abc.com';
        acc.AccountNumber = '5879807688';
       
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.RecordTypeId = accountRecordTypeIntel;
        insert(acc);
        
        List<PRM_Bulk_Data_Upload__c> bulkrecs = new List<PRM_Bulk_Data_Upload__c>();
        for(integer i =0; i<= Integer.ValueOf(listBatchConfigItems[0].Record_Limit__c) + 5; i++){
            STring indexvalue = String.valueOf(i);
            String email = 'testrequest00'+indexvalue+'@mailinator.com';
            PRM_Bulk_Data_Upload__c bulkyrecord = new PRM_Bulk_Data_Upload__c();
            bulkyrecord.PRM_Object__c='Contact';
            bulkyrecord.PRM_OperationType__c='Insert';
            //bulkRecord3.PRM_Contact_Id__c =con1.Id;
            bulkyrecord.PRM_Upload_Type__c ='Bulk Invite';
            bulkyrecord.CreatedById = UserInfo.getUserId();
            bulkyrecord.PRM_Suppress_Email__c = false;
            bulkyrecord.PRM_Comments__c = 'Created on Today';
            bulkyrecord.PRM_First_Name__c ='abcxyz';
            bulkyrecord.PRM_Last_Name__c='123xyasd';
            bulkyrecord.PRM_AccountId__c =acc.Id;
            bulkyrecord.PRM_ContactEmail__c =email;    
            bulkyrecord.PRM_IPA_Partner_Role__c='Service Provider';
            bulkyrecord.PRM_Partner_Relationship__c='Partner Admin';
            bulkyrecord.PRM_Status__c='New';
            bulkyrecord.PRM_Partner_Program__c='IPA';
            bulkyrecord.PRM_Status_Reason__c='NA';
            bulkyrecord.PRM_BatchID__c = 'BATCH001';
            bulkyrecord.PRM_Preferred_Language__c = 'ENG';
            bulkyrecord.PRM_Email_Template__c = 'CampaignInviteForBulk';
           // bulkyRecord.PRM_RegistrationType__c = 'Admin Invite';
            bulkrecs.add(bulkyrecord);
            
        }
        if(bulkrecs.size()>0){
      Database.insert(bulkRecs, false);
        }
        //Database.executeBatch(new PRM_BulkDataUpload_Batch(),14);
        test.stopTest();         
    }
    
    static testMethod void bulkDataUploadBatch(){    
        Database.executeBatch(new PRM_BulkDataUpload_Batch(),14);  
    }
    
    
    
    @isTest
    static void sendEmailToContact(){
        
        test.startTest();
        Boolean isUpdateInvite = true;        
        //PRM_BulkDataUpload_Batch.IS_CIDAAS_ENABLED = false;
        String evToken ='WRET!@#$%RTREE$#@';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //Account acc = [Select Id from Account where Name = 'Intel1223'];
       // Contact con = [SELECT id,AccountId,Account.Name,Account.AccountNumber,FirstName, Account.BillingCountryCode,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Login_Id__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r) from Contact where Email = 'testmathewsmithy767yu@mailinator.com'];
        Account acc = new Account();
        acc.Name ='Intel08012025';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='Agriculture';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'abc.com';
        acc.AccountNumber = '5879807687';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.RecordTypeId = accountRecordTypeIntel;
        insert(acc);
        
        List<Contact> con = [SELECT id,AccountId,Account.Name,Account.AccountNumber,FirstName, Account.BillingCountryCode,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Login_Id__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r) from Contact limit 2];

        List<PRM_Language_Culture_Mapping__mdt> lng  =  new List<PRM_Language_Culture_Mapping__mdt>();
        PRM_Language_Culture_Mapping__mdt lcm = new PRM_Language_Culture_Mapping__mdt();
        lcm.MasterLabel = 'ENU';
        lcm.PRM_Culture__c = 'en';
        lcm.PRM_Country__c = 'GBR';
        lcm.PRM_Country_Cd__c = 'uk';
        lng.add(lcm);
        
        List<PRM_Language_Culture_Mapping__mdt> lng2 = [SELECT Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c 
                                                        FROM PRM_Language_Culture_Mapping__mdt LIMIT 3];
        OrgWideEmailAddress orgea = new OrgWideEmailAddress();
        orgea.Address = 'wsm-postmaster@intel.com';
        
        PRM_BulkDataUpload_Batch.getCountryCodeForUrl(con[0],lng);
        PRM_BulkDataUpload_Batch.getCountryCodeForUrl(con[0],lng2);
        PRM_BulkDataUpload_Batch.emailToContact(con[0], null, null);
        PRM_BulkDataUpload_Batch.emailToContact(con[0], evToken, null);
        PRM_BulkDataUpload_Batch.emailToContact(null, null, null);
        test.stopTest();
        Campaign testCampaign = new Campaign(Name='TEST_CAMPAIGN_NAME', Description='Test', Core_Activity_Types__c='Promotion',
                                             Status='Planned', EndDate=Date.today().addMonths(1), PRM_Bulk_Add_Invite_Email_Template__c = 'CampaignInviteForBulk');
        insert testCampaign;
        List<PRM_Bulk_Data_Upload__c>  blList = new List<PRM_Bulk_Data_Upload__c>();
        PRM_Bulk_Data_Upload__c bulkRecord00 = new PRM_Bulk_Data_Upload__c();
        bulkRecord00.PRM_Object__c='Contact';
        //bulkRecord00.PRM_Contact_Id__c =con.Id;
        bulkRecord00.PRM_OperationType__c='Insert';
        bulkRecord00.PRM_AccountId__c =con[0].AccountId;
        bulkRecord00.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord00.PRM_Suppress_Email__c = false;
        bulkRecord00.CreatedById = UserInfo.getUserId();
        bulkRecord00.PRM_Comments__c = 'Created on Today';
        bulkRecord00.PRM_ContactEmail__c = 'asfsdafasasdasdf@qwadsafa.asfdas';  
        bulkRecord00.PRM_First_Name__c ='testcontact';
        bulkRecord00.PRM_Last_Name__c='designer1';
        bulkRecord00.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord00.PRM_Partner_Relationship__c='Employee';
        bulkRecord00.PRM_Status__c='New';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord00.PRM_RegistrationType__c   = 'Admin Invite';
        blList.add(bulkRecord00);
        
        PRM_Bulk_Data_Upload__c bulkRecord01 = new PRM_Bulk_Data_Upload__c();
        bulkRecord01.PRM_Object__c='Contact';
        //bulkRecord01.PRM_Contact_Id__c =con.Id;
        bulkRecord01.PRM_OperationType__c='Insert';
        bulkRecord01.PRM_AccountId__c =con[0].AccountId;
        bulkRecord01.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord01.PRM_Suppress_Email__c = false;
        bulkRecord01.CreatedById = UserInfo.getUserId();
        bulkRecord01.PRM_Comments__c = 'Created on Today';
        bulkRecord01.PRM_ContactEmail__c = 'asfsdafasdfasda@qwadsafa.asfdas';  
        bulkRecord01.PRM_First_Name__c ='testcontact';
        bulkRecord01.PRM_Last_Name__c='designer1';
        bulkRecord01.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord01.PRM_Partner_Relationship__c='Employee';
        bulkRecord01.PRM_Status__c='New';
        bulkRecord01.PRM_Partner_Program__c='IPA';
        bulkRecord01.PRM_BatchID__c = 'BATCH002';
        bulkRecord01.PRM_CampaignId__c = testCampaign.id;
        bulkRecord01.PRM_Preferred_Language__c = 'ENG';
        bulkRecord01.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord01.PRM_RegistrationType__c   = 'Admin Invite';
        blList.add(bulkRecord01);
        
        PRM_Bulk_Data_Upload__c bulkRecord02 = new PRM_Bulk_Data_Upload__c(); 
        bulkRecord02.PRM_Object__c='Contact';
        //bulkRecord02.PRM_Contact_Id__c =con.Id;
        bulkRecord02.PRM_OperationType__c='Insert';
        bulkRecord02.PRM_AccountId__c =con[0].AccountId;
        bulkRecord02.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord02.PRM_Suppress_Email__c = false;
        bulkRecord02.CreatedById = UserInfo.getUserId();
        bulkRecord02.PRM_Comments__c = 'Created on Today';
        bulkRecord02.PRM_ContactEmail__c = 'asfsdafasdf@qwadsafa.asfdas';  
        bulkRecord02.PRM_First_Name__c ='testcontact';
        bulkRecord02.PRM_Last_Name__c='designer1';
        bulkRecord02.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord02.PRM_Partner_Relationship__c='Employee';
        bulkRecord02.PRM_Status__c='Failed';
        bulkRecord02.PRM_Partner_Program__c='IPA';
        bulkRecord02.PRM_BatchID__c = 'BATCH002';
        bulkRecord02.PRM_Email_Template__c = 'CampaignInviteForBulk';
        bulkRecord02.PRM_Preferred_Language__c = 'ENG';
  //  bulkRecord02.PRM_RegistrationType__c   = 'Admin Invite';
        blList.add(bulkRecord02);
        insert blList;                
        Database.executeBatch(new PRM_BulkDataUpload_Batch(),14);    
       
        Map<String, String> EmailIdandemailType = new Map<String, String>();
        PRM_BulkDataUpload_Batch objBulk = new PRM_BulkDataUpload_Batch();
        DataBase.executeBatch(objBulk); 
    //emailIdandemailType.put(bulkRecord00.PRM_ContactEmail__c, bulkRecord00.PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c);    
        //PRM_BulkDataUpload_Batch.sendEmailNotificationtoEndUserUpdate(emailIdandemailType);
        

        String newEVToken = PRM_RetriggerEV_Token_API.reTriggerEV('testmathewsmithy@mailinator.com');
    }
    
    @isTest
    static void sendEmailToContact1(){
        
       // test.startTest();
        Boolean isUpdateInvite = true;
        String evToken ='WRET!@#$%RTREE$#@';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //Account acc = [Select Id from Account where Name = 'Intel1223'];
       // Contact con = [SELECT id,AccountId,Account.Name,Account.AccountNumber,FirstName, Account.BillingCountryCode,MailingCountryCode,Core_IPA_PartnerRole__c,Core_Login_Id__c,Core_Do_Not_Contact__c,Core_Enterprise_Id__c,Core_Preferred_Language__c,Email,Core_IPA_Email_Verification_Date__c,(SELECT PRM_Partner_Role__c,PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r) from Contact where Email = 'testmathewsmithy767yu@mailinator.com'];
        Test.startTest();
        Account acc = new Account();
        acc.Name ='Intel01082k25';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='Agriculture';
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.Core_Geo__c = 'PRC';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        acc.Core_User_Defined_Website__c = 'abc.com';
        acc.AccountNumber = '5879807689';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        acc.RecordTypeId = intelAccRecTypeId;
        
        insert(acc);
        ChannelProgram cp1 = [select id from ChannelProgram limit 1];
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cp1.Id;
        insert cplTest;
        //system.debug('Account record type is--'+acc.RecordTypeId.);
         PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=acc.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cp1.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Solution Integrator';
        acctChnlMem.PRM_Status_Reason_Txt__c ='Approved';
        insert acctChnlMem;
        
         Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'test con bu';
        con.LastName = 'mop';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'testlogin@mailin.com';
        con.Core_Do_Not_Contact__c = false;
        con.Core_Enterprise_Id__c = '76551622';
        con.Core_Preferred_Language__c = 'ENG';
        con.Email = 'testswwweopy@lpaaty.con';
        con.Core_IPA_Email_Verification_Date__c = System.today(); 
        con.MailingCountryCode = 'GBR';
        insert con;

        List<PRM_Language_Culture_Mapping__mdt> lng  =  new List<PRM_Language_Culture_Mapping__mdt>();
        PRM_Language_Culture_Mapping__mdt lcm = new PRM_Language_Culture_Mapping__mdt();
        lcm.MasterLabel = 'ENU';
        lcm.PRM_Culture__c = 'en';
        lcm.PRM_Country__c = 'GBR';
        lcm.PRM_Country_Cd__c = 'uk';
        lng.add(lcm);
        
        
        
        List<PRM_Language_Culture_Mapping__mdt> lng2 = [SELECT Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c 
                                                        FROM PRM_Language_Culture_Mapping__mdt LIMIT 3];
        OrgWideEmailAddress orgea = new OrgWideEmailAddress();
        orgea.Address = 'wsm-postmaster@intel.com';
        
        
       
        Campaign testCampaign = new Campaign(Name='TEST_CAMPAIGN_NAME', Description='Test', Core_Activity_Types__c='Promotion',
                                             Status='Planned', EndDate=Date.today().addMonths(1), PRM_Bulk_Add_Invite_Email_Template__c = 'CampaignInviteForBulk');
        insert testCampaign;
        List<PRM_Bulk_Data_Upload__c>  blList = new List<PRM_Bulk_Data_Upload__c>();
        PRM_Bulk_Data_Upload__c bulkRecord00 = new PRM_Bulk_Data_Upload__c();
        bulkRecord00.PRM_Object__c='Contact';
        //bulkRecord00.PRM_Contact_Id__c =con.Id;
        bulkRecord00.PRM_OperationType__c='Insert';
        bulkRecord00.PRM_AccountId__c =acc.Id;
        bulkRecord00.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord00.PRM_Suppress_Email__c = false;
        bulkRecord00.CreatedById = UserInfo.getUserId();
        bulkRecord00.PRM_Comments__c = 'Created on Today';
        bulkRecord00.PRM_ContactEmail__c = 'testswwweopy@lpaaty.con';  
        bulkRecord00.PRM_First_Name__c ='testcontact';
        bulkRecord00.PRM_Last_Name__c='designer1';
        bulkRecord00.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord00.PRM_Partner_Relationship__c='Employee';
        bulkRecord00.PRM_Status__c='New';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_CampaignId__c = testCampaign.id;
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
        bulkRecord00.PRM_Mailing_Country__c = 'India';
        //insert bulkRecord00;
       // bulkRecord00.PRM_RegistrationType__c   = 'Admin Invite';
        blList.add(bulkRecord00);
        //insert bulkRecord00;
        
        PRM_Bulk_Data_Upload__c bulkRecordnew = new PRM_Bulk_Data_Upload__c();
        bulkRecordnew.PRM_Object__c='Contact';        
        bulkRecordnew.PRM_OperationType__c='Insert';
        bulkRecordnew.PRM_AccountId__c =acc.Id;
        bulkRecordnew.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecordnew.PRM_Suppress_Email__c = false;
        bulkRecordnew.CreatedById = UserInfo.getUserId();
        bulkRecordnew.PRM_Comments__c = 'Created on Today';
        bulkRecordnew.PRM_ContactEmail__c = 'testswwweopynew1@lpaaty.con';  
        bulkRecordnew.PRM_First_Name__c ='testcontact';
        bulkRecordnew.PRM_Last_Name__c='designer1';
        bulkRecordnew.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecordnew.PRM_Partner_Relationship__c='Employee';
        bulkRecordnew.PRM_Status__c='New';
        bulkRecordnew.PRM_Partner_Program__c='IPA';
        bulkRecordnew.PRM_BatchID__c = 'BATCH002';
        bulkRecordnew.PRM_Preferred_Language__c = 'ENG';
        bulkRecordnew.PRM_CampaignId__c = testCampaign.id;
        bulkRecordnew.PRM_Email_Template__c = 'CampaignInviteForBulk';
        bulkRecordnew.PRM_Mailing_Country__c = 'India';      
        //insert bulkRecordnew;
        blList.add(bulkRecordnew);
        
       // insert bulkRecordnew;
        
        PRM_Bulk_Data_Upload__c bulkRecord01 = new PRM_Bulk_Data_Upload__c();
        bulkRecord01.PRM_Object__c='Contact';
        //bulkRecord01.PRM_Contact_Id__c =con.Id;
        bulkRecord01.PRM_OperationType__c='Insert';
        bulkRecord01.PRM_AccountId__c =acc.Id;
        bulkRecord01.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord01.PRM_Suppress_Email__c = false;
        bulkRecord01.CreatedById = UserInfo.getUserId();
        bulkRecord01.PRM_Comments__c = 'Created on Today';
        bulkRecord01.PRM_ContactEmail__c = 'asfsdafasdfasda@qwadsafa.asfdas';  
        bulkRecord01.PRM_First_Name__c ='testcontact';
        bulkRecord01.PRM_Last_Name__c='designer1';
        bulkRecord01.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord01.PRM_Partner_Relationship__c='Employee';
        bulkRecord01.PRM_Status__c='New';
        bulkRecord01.PRM_Partner_Program__c='IPA';
        bulkRecord01.PRM_BatchID__c = 'BATCH002';
        bulkRecord01.PRM_CampaignId__c = testCampaign.id;
        bulkRecord01.PRM_Preferred_Language__c = 'ENG';
        bulkRecord01.PRM_Email_Template__c = 'CampaignInviteForBulk';
        //insert bulkRecord01;
       // bulkRecord01.PRM_RegistrationType__c   = 'Admin Invite';
        blList.add(bulkRecord01);
        
        PRM_Bulk_Data_Upload__c bulkRecord02 = new PRM_Bulk_Data_Upload__c(); 
        bulkRecord02.PRM_Object__c='Contact';
        //bulkRecord02.PRM_Contact_Id__c =con.Id;
        bulkRecord02.PRM_OperationType__c='Insert';
        bulkRecord02.PRM_AccountId__c =acc.Id;
        bulkRecord02.PRM_Upload_Type__c ='Bulk Invite';
        bulkRecord02.PRM_Suppress_Email__c = false;
        bulkRecord02.CreatedById = UserInfo.getUserId();
        bulkRecord02.PRM_Comments__c = 'Created on Today';
        bulkRecord02.PRM_ContactEmail__c = 'asfsdafasdf@qwadsafa.asfdas';  
        bulkRecord02.PRM_First_Name__c ='testcontact';
        bulkRecord02.PRM_Last_Name__c='designer1';
        bulkRecord02.PRM_IPA_Partner_Role__c='Service Provider';       
        bulkRecord02.PRM_Partner_Relationship__c='Employee';
        bulkRecord02.PRM_Status__c='Failed';
        bulkRecord02.PRM_Partner_Program__c='IPA';
        bulkRecord02.PRM_BatchID__c = 'BATCH002';
        bulkRecord02.PRM_Email_Template__c = 'CampaignInviteForBulk';
        bulkRecord02.PRM_Preferred_Language__c = 'ENG';
        insert bulkRecord02;
  //  bulkRecord02.PRM_RegistrationType__c   = 'Admin Invite';
        blList.add(bulkRecord02);
        //insert blList;   
        
        
        PRM_ContactRelationships__c employee1 = [select id from PRM_ContactRelationships__c limit 1];
        
        /*PRM_AccountChannelMembership__c acmRec = [select id, PRM_Status_Nm__c from PRM_AccountChannelMembership__c limit 1];
        acmRec.PRM_Status_Nm__c = 'Inactive';
        update acmRec;*/
        
         PRM_Account_Contact_Relationship__c acrEmpA = new PRM_Account_Contact_Relationship__c();
        acrEmpA.PRM_Relationship_Id__c = employee1.Id;
        acrEmpA.PRM_Account_Id__c = acc.Id;
        acrEmpA.PRM_Contact_Id__c = con.Id;
        acrEmpA.PRM_InActive_Ind__c= true;
        acrEmpA.PRM_Status_Nm__c = 'Pending Action';
        acrEmpA.PRM_Source_Agent__c = 'Bulk Invite';
        acrEmpA.PRM_Status_Reason_Txt__c = 'test comms';
        acrEmpA.PRM_Initiated_By__c = UserInfo.getUserId();
        acrEmpA.PRM_CampaignId__c =  testCampaign.id;
        acrEmpA.Bulk_Data_Upload__c = bulkRecord00.Id;
        acrEmpA.PRM_End_Date_Dt__c = null;
        insert acrEmpA;
        
        PRM_BulkDataUpload_Batch.getCountryCodeForUrl(con,lng);
        PRM_BulkDataUpload_Batch.getCountryCodeForUrl(con,lng2);
        PRM_BulkDataUpload_Batch.emailToContact(con, null, null);
        PRM_BulkDataUpload_Batch.emailToContact(con, evToken, null);
        PRM_BulkDataUpload_Batch.emailToContact(null, null, null);
        Database.executeBatch(new PRM_BulkDataUpload_Batch(),14);  
       
        Map<String, String> EmailIdandemailType = new Map<String, String>();
        PRM_BulkDataUpload_Batch objBulk = new PRM_BulkDataUpload_Batch();
        DataBase.executeBatch(objBulk); 
        Map<id, String> mapAccIDtoPartnerRole = new Map<id, String>();
      //  mapAccIDtoPartnerRole.put(bulkRecord00.PRM_AccountId__c, bulkRecord00.PRM_IPA_Partner_Role__c);
        Map<String,PRM_Bulk_Data_Upload__c> mapContactEmailToBDU =new Map<String,PRM_Bulk_Data_Upload__c>();
        mapContactEmailToBDU.put(bulkRecordnew.PRM_ContactEmail__c, bulkRecordnew);
        Core_Country_Code_Mapping__c countryIsoSetting = new Core_Country_Code_Mapping__c ();
        countryIsoSetting.Name='India';
        countryIsoSetting.ISO_Code__c='IND';
        countryIsoSetting.Country_Code__c='IN'; 
        insert countryIsoSetting;
        
       // PRM_Contact_Bulk_DataLoad_Utility.processContactRecords(mapContactEmailToBDU);
        //test.stopTest();
    //emailIdandemailType.put(bulkRecord00.PRM_ContactEmail__c, bulkRecord00.PRM_CampaignId__r.PRM_Bulk_Add_Invite_Email_Template__c);    
        //PRM_BulkDataUpload_Batch.sendEmailNotificationtoEndUserUpdate(emailIdandemailType);
       // EmailTemplate template1 = new EmailTemplate(DeveloperName='dev name', Body='body', Subject='subject'); //Description = 'there is rec success', Encoding = 'there is rec fail');
      
    
        EmailTemplate validEmailTemplate2 = new EmailTemplate();
        validEmailTemplate2.Subject= 'bulksbuject';
        validEmailTemplate2.isActive = true;
        validEmailTemplate2.Name = 'name';
        validEmailTemplate2.Body = 'test email body';
        validEmailTemplate2.DeveloperName = 'SolutionShared_Submitter';
        validEmailTemplate2.TemplateType = 'text';
        validEmailTemplate2.FolderId = UserInfo.getUserId();
      
       
       
         User usr = [Select id from User where Id = :UserInfo.getUserId()];

 

         System.RunAs(usr)
       
         {
             
          PRM_Contact_Bulk_DataLoad_Utility.processContactRecords(mapContactEmailToBDU);   
          insert validEmailTemplate2;
        string bulkRecStringForExcelSuccess = 'Record Success ContactEmail, LastName, FirstName, status \n';
        
        PRM_SendEmailToUsers.sendData(validEmailTemplate2.DeveloperName,bulkRecStringForExcelSuccess,'', validEmailTemplate2.body, validEmailTemplate2.Subject);
        
        string bulkRecStringForExcelFail = 'Record Fail ContactEmail, LastName, FirstName, status \n';
        
        PRM_SendEmailToUsers.sendData(validEmailTemplate2.DeveloperName,'',bulkRecStringForExcelFail,validEmailTemplate2.Body, validEmailTemplate2.Subject);

        String newEVToken = PRM_RetriggerEV_Token_API.reTriggerEV('testmathewsmithy@mailinator.com');
         test.stopTest();
        }
    }
    
    
   
}