@isTest
public class PRM_BulkInviteApexTest {
    
    @isTest
    static void testGetAccountId(){
        
        Account acc = new Account();
        acc.Name ='Intel';
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
        System.debug(con1);
        
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
        System.debug(cont4);
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', Contact = con1, ProfileId = profile1.Id);
        
        //User u = [select Id, username, /*Core_IPA_One_Partner_Id__c,*/ Core_IPS_AccountId__c,Email from User where email='testUsercoreMPM@intel.com' limit 1];
        Test.startTest();
        system.runAs(testUser){
            //isTandC= PRM_DashboardTabVisibilityController.isTAndCAccepted (cont.id);
            String accountId = PRM_BulkInviteApex.getAccounId();
            
        }
        Test.stopTest();
        
        
        
    }
    
    @isTest
    static void testcreateBulkRecords(){
        
        Account acc = new Account();
        acc.Name ='Intel';
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
        System.debug(con1);
        
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
        System.debug(cont4);
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', Contact = con1);
        
        
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
     //   bulkRecord1.PRM_RegistrationType__c = 'Admin Invite';
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
        bulkRecord00.PRM_Status__c='Failed';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
     //   bulkRecord00.PRM_RegistrationType__c = 'Admin Invite';
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
        
        if(bulkrecs.size()>0)
        {
            Database.insert(bulkrecs, false);
        }
        PRM_BulkInviteApex.getPicklistValues();
        string accId = bulkRecord1.PRM_AccountId__c; //acc.id;
        string rowData = '[{"ContactEmail": "AdamGrill@intel.com", "firstname": "John", "lastname": "Doe"}]';
        
        List<string> result = PRM_BulkInviteApex.createBulkRecords(accId, rowData);
        
        string accId1 = bulkRecord00.PRM_AccountId__c;
        
        List<string> result1 = PRM_BulkInviteApex.createBulkRecords(accId1, rowData);
        
        
        // Verify the result
        //System.assertEquals(1, result.size());
        //System.assertEquals('Records not inserted, please contact support team', result);
        //System.assertEquals('Records inserted successfully', result[1]);
        
    }      
    
    @isTest
    static void testgetstatus(){
        
        Account acc = new Account();
        acc.Name ='Intel';
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
        System.debug(con1);
        
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
        System.debug(cont4);
        
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
        con.MailingCountryCode = 'USA';
        con.MailingCountry='USA';
        insert con;
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', Contact = con1);
        
        
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
        bulkRecord.PRM_Status__c='Completed';
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
        bulkRecord1.PRM_Status__c='Failed';
        bulkRecord1.PRM_Partner_Program__c='IPA';
        bulkrecord1.PRM_BatchID__c = 'BATCH002';
        bulkRecord1.PRM_Preferred_Language__c = 'ENG';
        bulkRecord1.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord1.PRM_RegistrationType__c = 'Admin Invite';
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
        bulkRecord00.PRM_Status__c='Discarded';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord00.PRM_RegistrationType__c = 'Admin Invite';
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
       // bulkRecord3.PRM_RegistrationType__c = 'Admin Invite';
        bulkrecs.add(bulkRecord3);
        
        if(bulkrecs.size()>0)
        {
            Database.insert(bulkrecs, false);
        }
        
        String status = PRM_BulkInviteApex.getStatus();
        
        PRM_Bulk_Data_Upload__c bulkRecord01 = new PRM_Bulk_Data_Upload__c();
        bulkRecord01.PRM_Object__c='Contact';
        bulkRecord01.PRM_Contact_Id__c =con.Id;
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
        bulkRecord01.PRM_Status__c='Failed';
        bulkRecord01.PRM_Partner_Program__c='IPA';
        bulkRecord01.PRM_BatchID__c = 'BATCH002';
        //bulkRecord01.PRM_CampaignId__c = testCampaign.id;
        bulkRecord01.PRM_Preferred_Language__c = 'ENG';
        bulkRecord01.PRM_Email_Template__c = 'CampaignInviteForBulk';
       // bulkRecord01.PRM_RegistrationType__c   = 'Admin Invite';
        
        status = PRM_BulkInviteApex.getStatus();
        
        
        
        
        /*if(bulkrecs.size()>0)
{
Database.insert(bulkrecs, false);
}

String status = PRM_BulkInviteApex.getStatus();*/
        
        
        
        //System.assertEquals('Wait', status);
        
    }
    
    @isTest
    static void testgetUploadStatusInWaiting(){
        
        Account acc = new Account();
        acc.Name ='Intel';
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
        System.debug(con1);
        
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
        System.debug(cont4);
        
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
        con.MailingCountryCode = 'USA';
        con.MailingCountry='USA';
        insert con;
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', Contact = con1);
        
        
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
        bulkRecord.PRM_Status__c='Completed';
        bulkRecord.PRM_Partner_Program__c='IPA';
        bulkRecord.PRM_Status_Reason__c='NA';
        bulkRecord.PRM_Preferred_Language__c = 'ENG';
        bulkRecord.PRM_Email_Template__c = 'CampaignInviteForBulk';
       // bulkRecord.PRM_RegistrationType__c = 'Admin Invite';
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
        bulkRecord1.PRM_Status__c='Failed';
        bulkRecord1.PRM_Partner_Program__c='IPA';
        bulkrecord1.PRM_BatchID__c = 'BATCH002';
        bulkRecord1.PRM_Preferred_Language__c = 'ENG';
        bulkRecord1.PRM_Email_Template__c = 'CampaignInviteForBulk';
     //   bulkRecord1.PRM_RegistrationType__c = 'Admin Invite';
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
        bulkRecord00.PRM_Status__c='Discarded';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
     //   bulkRecord00.PRM_RegistrationType__c = 'Admin Invite';
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
        
        if(bulkrecs.size()>0)
        {
            Database.insert(bulkrecs, false);
        }
        string status = PRM_BulkInviteApex.getUploadStatusInWaiting();
        
        PRM_Bulk_Data_Upload__c bulkRecord01 = new PRM_Bulk_Data_Upload__c();
        bulkRecord01.PRM_Object__c='Contact';
        bulkRecord01.PRM_Contact_Id__c =con.Id;
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
        bulkRecord01.PRM_Status__c='hello';
        bulkRecord01.PRM_Partner_Program__c='IPA';
        bulkRecord01.PRM_BatchID__c = 'BATCH002';
        //bulkRecord01.PRM_CampaignId__c = testCampaign.id;
        bulkRecord01.PRM_Preferred_Language__c = 'ENG';
        bulkRecord01.PRM_Email_Template__c = 'CampaignInviteForBulk';
     //   bulkRecord01.PRM_RegistrationType__c   = 'Admin Invite';
        
        Database.insert(bulkRecord01, false);
        
        status = PRM_BulkInviteApex.getUploadStatusInWaiting();
        
        
        
        
        //System.assertEquals('Wait', status);
        //return status;
        
        
        
        
    }
    
    @isTest
    static void testretryStatusOver(){
        
        Account acc = new Account();
        acc.Name ='Intel';
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
        System.debug(con1);
        
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
        System.debug(cont4);
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', Contact = con1);
        
        
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
        bulkRecord.PRM_Status__c='Completed';
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
        bulkRecord1.PRM_Status__c='Failed';
        bulkRecord1.PRM_Partner_Program__c='IPA';
        bulkrecord1.PRM_BatchID__c = 'BATCH002';
        bulkRecord1.PRM_Preferred_Language__c = 'ENG';
        bulkRecord1.PRM_Email_Template__c = 'CampaignInviteForBulk';
     //   bulkRecord1.PRM_RegistrationType__c = 'Admin Invite';
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
        bulkRecord00.PRM_Status__c='Discarded';
        bulkRecord00.PRM_Partner_Program__c='IPA';
        bulkrecord00.PRM_BatchID__c = 'BATCH002';
        bulkRecord00.PRM_Preferred_Language__c = 'ENG';
        bulkRecord00.PRM_Email_Template__c = 'CampaignInviteForBulk';
      //  bulkRecord00.PRM_RegistrationType__c = 'Admin Invite';
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
        
        if(bulkrecs.size()>0)
        {
            Database.insert(bulkrecs, false);
        }
        
        String status = PRM_BulkInviteApex.retryStatusOver();
        
        //System.assertEquals('Discarded', status);
        //return status;
        
        
    }
    
}