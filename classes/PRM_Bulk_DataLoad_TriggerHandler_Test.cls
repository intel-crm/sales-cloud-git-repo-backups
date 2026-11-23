@isTest()
public class PRM_Bulk_DataLoad_TriggerHandler_Test {
    @testSetup
    //test data creation
    static void setupDataCreation(){  
        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        List<Account> lstAccs = new List<Account>();
        Account acc = new Account();
        acc.RecordTypeId=intelAccRecTypeId;
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
        lstAccs.add(acc);

        Account acc1 = new Account();
        acc1.Name ='Intel acc';
        acc1.Core_Account_Type__c ='Distributor';
        acc1.Industry ='Agriculture';
        acc1.Core_IPA_Partner_Role__c = 'Service Provider';
        acc1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc1.BillingCity='Bengaluru';
        acc1.BillingCountry='India';
        acc1.BillingStreet=' rookfield';
        acc1.BillingPostalCode='5698037';
        acc1.Core_User_Defined_Website__c = 'xyz.com';
        acc1.Core_Deactivated__c = true;
        acc1.Core_Deactivation_Reason__c = 'Company no longer exists';
        lstAccs.add(acc1);

        Account acc2 = new Account();
        acc2.Name ='account Intel';
        acc2.Core_Account_Type__c ='Distributor';
        acc2.Industry ='Agriculture';
        acc2.Core_IPA_Partner_Role__c = 'Service Provider';
        acc2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc2.BillingCity='Bengaluru';
        acc2.BillingCountry='India';
        acc2.BillingStreet='Floor';
        acc2.BillingPostalCode='37798';
        acc2.Core_User_Defined_Website__c = 'tuv.com';
        lstAccs.add(acc2);
        if(lstAccs.size()>0){
            insert lstAccs;
        }
        
        
        Contact con = new Contact();
        con.FirstName='Matt';
        con.LastName='Smith';
        con.Email='testrequest@mailinator.com';
        con.Phone='9999779791';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';        
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        con.MailingCountryCode = 'USA';
        insert con;
        
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
                con1.MailingCountryCode = 'USA';
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName='Ivory';
        con2.LastName='Smithy';
        con2.Email='testivorysmithy@mailinator.com';
        con2.Phone='9999779791';
        con2.AccountId = acc.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_Login_Id__c = 'tuv';
        con2.MailingCountryCode = 'USA';
        insert con2;

        Contact con3 = new Contact();
        con3.FirstName='Ivory';
        con3.LastName='Smithy';
        con3.Email='testivorysmithy03@mailinator.com';
        con3.Phone='9999779791';
        con3.AccountId = acc.Id;
        con3.Core_Job_Function__c='Branch Manager';
        con3.Core_eRPM_Language_Code__c='Eng';        
        con3.Core_Login_Id__c = 'tuv';
        con3.MailingCountryCode = 'USA';
        insert con3;

        Contact con4 = new Contact();
        con4.FirstName='Ivory';
        con4.LastName='Smithy';
        con4.Email='testivorysmithy01@mailinator.com';
        con4.Phone='9999779791';
        con4.AccountId = acc.Id;
        con4.Core_Job_Function__c='Branch Manager';
        con4.Core_eRPM_Language_Code__c='Eng';        
        con4.Core_Login_Id__c = 'tuv';
        con4.Core_IPA_PartnerRole__c = 'Distributor';
        con4.MailingCountryCode = 'USA';
        insert con4;
        
        ChannelProgram cp = PRM_TestUtility.getChannelPrograms();
        insert cp;
        
        ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
        cpl1.Name='Member';
        cpl1.ProgramId=cp.Id;
        insert cpl1; 
        List<PRM_AccountChannelMembership__c> lstchannelmemberships = new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c membership1 = new PRM_AccountChannelMembership__c();
        membership1.PRM_Account_Id__c=acc.Id;
        membership1.PRM_Status_Nm__c = 'Approved';
        membership1.PRM_Channel_Program_Id__c=cp.Id;
        membership1.PRM_Partner_Role__c='Service Provider';
        membership1.PRM_Status_Reason_Txt__c='Test';
        lstchannelmemberships.add(membership1);

        PRM_AccountChannelMembership__c membership2 = new PRM_AccountChannelMembership__c();
        membership2.PRM_Account_Id__c=acc.Id;
        membership2.PRM_Status_Nm__c = 'Inactive';
        membership2.PRM_Channel_Program_Id__c=cp.Id;
        membership2.PRM_Partner_Role__c='Service Provider';
        membership2.PRM_Status_Reason_Txt__c='Test';
        lstchannelmemberships.add(membership2);

        PRM_AccountChannelMembership__c membership3 = new PRM_AccountChannelMembership__c();
        membership3.PRM_Account_Id__c=acc.Id;
        membership3.PRM_Status_Nm__c = 'Inactive';
        membership3.PRM_Channel_Program_Id__c=cp.Id;
        membership3.PRM_Partner_Role__c='Service Provider';
        membership3.PRM_Status_Reason_Txt__c='Test';
        lstchannelmemberships.add(membership3);

        if(lstchannelmemberships.size()>0){
            insert lstchannelmemberships;
        }

        
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

        List<PRM_Account_Contact_Relationship__c> lstACRs = new List<PRM_Account_Contact_Relationship__c>();
        
        PRM_Account_Contact_Relationship__c acr = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Relationship_Id__c = admin.Id;
        acr.PRM_Account_Id__c = acc.Id;
        acr.PRM_Contact_Id__c = con.Id;
        acr.PRM_InActive_Ind__c= true;
        acr.PRM_Status_Reason_Txt__c='Test';
        lstACRs.add(acr);
        
        PRM_Account_Contact_Relationship__c acrEmp = new PRM_Account_Contact_Relationship__c();
        acrEmp.PRM_Relationship_Id__c = employee.Id;
        acrEmp.PRM_Account_Id__c = acc.Id;
        acrEmp.PRM_Contact_Id__c = con2.Id;
        acrEmp.PRM_InActive_Ind__c= true;
        acrEmp.PRM_Status_Reason_Txt__c='Test';
        lstACRs.add(acrEmp);
        
        PRM_Account_Contact_Relationship__c acrEmp1 = new PRM_Account_Contact_Relationship__c();
        acrEmp1.PRM_Relationship_Id__c = employee.Id;
        acrEmp1.PRM_Account_Id__c = acc.Id;
        acrEmp1.PRM_Contact_Id__c = con1.Id;
        acrEmp1.PRM_InActive_Ind__c= true;
        acrEmp1.PRM_Status_Nm__c = 'Pending Action';
        acrEmp1.PRM_Status_Reason_Txt__c='Test';
        lstACRs.add(acrEmp1);

        PRM_Account_Contact_Relationship__c acrEmp2 = new PRM_Account_Contact_Relationship__c();
        acrEmp2.PRM_Relationship_Id__c = employee.Id;
        acrEmp2.PRM_Account_Id__c = acc.Id;
        acrEmp2.PRM_Contact_Id__c = con3.Id;
        acrEmp2.PRM_InActive_Ind__c= false;
        acrEmp2.PRM_Status_Nm__c = 'Pending Action';
        acrEmp2.PRM_Status_Reason_Txt__c='Test';
        lstACRs.add(acrEmp2);

        PRM_Account_Contact_Relationship__c acrEmp3 = new PRM_Account_Contact_Relationship__c();
        acrEmp3.PRM_Relationship_Id__c = employee.Id;
        acrEmp3.PRM_Account_Id__c = acc.Id;
        acrEmp3.PRM_Contact_Id__c = con4.Id;
        acrEmp3.PRM_InActive_Ind__c= false;
        acrEmp3.PRM_Status_Nm__c = 'Complete';
        acrEmp3.PRM_Status_Reason_Txt__c='Test';
        lstACRs.add(acrEmp3);

        if(lstACRs.size()>0){
            insert lstACRs;
        }        
    }
    
    static testMethod void insertBulkLogRecord(){
        Account acc = [Select Id from Account where Name = 'Intel'];
        PRM_Bulk_Data_Upload__c bulkRecord = new PRM_Bulk_Data_Upload__c();
        bulkRecord.PRM_Object__c='Contact';
        bulkRecord.PRM_AccountId__c =acc.Id;
        bulkRecord.PRM_ContactEmail__c ='testdesigner123455673@mailinator.com';
        bulkRecord.PRM_First_Name__c ='test';
        bulkRecord.PRM_Last_Name__c='designer';
        bulkRecord.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord.PRM_Partner_Program__c='IPA';
        bulkRecord.PRM_Suppress_Email__c=true;
        bulkRecord.PRM_Partner_Relationship__c='Employee';
        Database.insert(bulkRecord,false);
        
        PRM_Bulk_Data_Upload__c bulkRecord001 = new PRM_Bulk_Data_Upload__c();
        bulkRecord001.PRM_Object__c='Contact';
        bulkRecord001.PRM_AccountId__c =acc.Id;
        bulkRecord001.PRM_ContactEmail__c ='testdesigner1234@mailinator.com';
        bulkRecord001.PRM_OperationType__c='Insert';
    bulkRecord001.PRM_First_Name__c ='test';
        bulkRecord001.PRM_Last_Name__c='designer';
        //bulkRecord001.PRM_IPA_Partner_Role__c='Distributor';
        bulkRecord001.PRM_Partner_Program__c='IPA';
        //bulkRecord001.PRM_Suppress_Email__c=true;
        //bulkRecord001.PRM_Partner_Relationship__c='Employee';
        Database.insert(bulkRecord001,false);
        
        PRM_Bulk_Data_Upload__c bulkRecord002 = new PRM_Bulk_Data_Upload__c();
        bulkRecord002.PRM_Object__c='Contact';
        bulkRecord002.PRM_AccountId__c =acc.Id;
        bulkRecord002.PRM_ContactEmail__c ='testdesigprofession@mailinator.com';
        bulkRecord002.PRM_OperationType__c='Insert';
    bulkRecord002.PRM_First_Name__c ='test';
        bulkRecord002.PRM_Status__c = 'New';
        bulkRecord002.PRM_Last_Name__c='designprofession';
        //bulkRecord001.PRM_IPA_Partner_Role__c='Distributor';
        bulkRecord002.PRM_Partner_Program__c='IPA';
        //bulkRecord001.PRM_Suppress_Email__c=true;
        bulkRecord002.PRM_Partner_Relationship__c='Partner Admin';
        Database.insert(bulkRecord002,false);
        
        PRM_Bulk_Data_Upload__c bulkRecording = new PRM_Bulk_Data_Upload__c();
        bulkRecording.PRM_Object__c='Contact';
        bulkRecording.PRM_AccountId__c =acc.Id;
        bulkRecording.PRM_ContactEmail__c ='testdesigprofession@mailinator.com';
        bulkRecording.PRM_First_Name__c ='test';
        bulkRecording.PRM_Last_Name__c='designprofession';
        bulkRecording.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecording.PRM_Partner_Program__c='IPA';
        //bulkRecording.PRM_Suppress_Email__c=true;
        bulkRecording.PRM_Partner_Relationship__c='Partner Admin';
        //bulkRecs.add(bulkRecording);
        try{
            Database.insert(bulkRecording,false); 
         }
         catch(Exception e){
             System.debug('Exception'+e);
         } 
             
        
        Contact con = [Select Id from Contact where Email = 'testrequest@mailinator.com'];
        PRM_Bulk_Data_Upload__c bulkRecord1 = new PRM_Bulk_Data_Upload__c();
        bulkRecord1.PRM_Object__c='Contact';
        //bulkRecord1.PRM_Contact_Id__c =con.Id;
        bulkRecord1.PRM_ContactEmail__c ='testrequest@mailinator.com';
        bulkRecord1.PRM_First_Name__c ='test';
        bulkRecord1.PRM_Last_Name__c='designer';
        //bulkRecord1.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord1.PRM_Partner_Program__c='IPA';
        bulkRecord1.PRM_Suppress_Email__c=true;
        bulkRecord1.PRM_Partner_Relationship__c='Partner Admin;Employee';
        Database.insert(bulkRecord1,false); 
        
        Contact con1 = [Select Id from Contact where Email = 'testmathewsmithy@mailinator.com'];
        PRM_Bulk_Data_Upload__c bulkRecord2 = new PRM_Bulk_Data_Upload__c();
        bulkRecord2.PRM_Object__c='Contact';
        //bulkRecord1.PRM_Contact_Id__c =con.Id;
        bulkRecord2.PRM_ContactEmail__c ='testmathewsmithy@mailinator.com';
        bulkRecord2.PRM_First_Name__c ='mathew';
        bulkRecord2.PRM_Last_Name__c='smithy';
        //bulkRecord1.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord2.PRM_Partner_Program__c='IPA';
        bulkRecord2.PRM_Suppress_Email__c=true;
        //bulkRecord2.PRM_Partner_Relationship__c='Partner Admin';
        Database.insert(bulkRecord2,false); 
        
        
        /*Contact cont = [Select Id from Contact where Email = 'testivorysmithy@mailinator.com'];
        PRM_Bulk_Data_Upload__c bulkRecord09 = new PRM_Bulk_Data_Upload__c();
        bulkRecord09.PRM_Object__c='Contact';
        //bulkRecord1.PRM_Contact_Id__c =con.Id;
        bulkRecord09.PRM_ContactEmail__c ='testivorysmithy@mailinator.com';
        bulkRecord09.PRM_First_Name__c ='ivory';
        bulkRecord09.PRM_Last_Name__c='smithy';
        //bulkRecord1.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord09.PRM_Partner_Program__c='IPA';
        bulkRecord09.PRM_Suppress_Email__c=true;
        bulkRecord2.PRM_Partner_Relationship__c='Partner Admin';
        insert bulkRecord09;*/

        }
  
    static testMethod void validateErrorChecks(){
        List<PRM_Bulk_Data_Upload__c> bulkRecs = new List<PRM_Bulk_Data_Upload__c>();
        List<Core_Intel_System_Accounts__mdt> listsystemacc = [select AccountId__c from Core_Intel_System_Accounts__mdt limit 1];

        Account acc = [Select Id from Account where Name = 'Intel'];
        PRM_Bulk_Data_Upload__c bulkRecord = new PRM_Bulk_Data_Upload__c();
        bulkRecord.PRM_Object__c='Contact';
        bulkRecord.PRM_AccountId__c =acc.Id;
        bulkRecord.PRM_ContactEmail__c ='testdesigner1234@mailinator.com';
        bulkRecord.PRM_First_Name__c ='test';
        bulkRecord.PRM_Status__c = 'New';
        bulkRecord.PRM_Last_Name__c='designer';
        bulkRecord.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord.PRM_Partner_Program__c='IPA';
        bulkRecord.PRM_Suppress_Email__c=true;
        bulkRecord.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord);
        
        PRM_Bulk_Data_Upload__c bulkRecord001 = new PRM_Bulk_Data_Upload__c();
        bulkRecord001.PRM_Object__c='Contact';
        bulkRecord001.PRM_AccountId__c =acc.Id;
        bulkRecord001.PRM_ContactEmail__c ='testdesigner1234@mailinator.com';
        bulkRecord001.PRM_OperationType__c='Insert';
    bulkRecord001.PRM_First_Name__c ='test';
        bulkRecord001.PRM_Last_Name__c='designer';
        //bulkRecord001.PRM_IPA_Partner_Role__c='Distributor';
        bulkRecord001.PRM_Partner_Program__c='IPA';
        //bulkRecord001.PRM_Suppress_Email__c=true;
        //bulkRecord001.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord001);

        PRM_Bulk_Data_Upload__c bulkRecord002 = new PRM_Bulk_Data_Upload__c();
        bulkRecord002.PRM_Object__c='Contact';
        bulkRecord002.PRM_AccountId__c =listsystemacc[0].AccountId__c;
        bulkRecord002.PRM_ContactEmail__c ='testdesignertan@mailinator.com';
    bulkRecord002.PRM_First_Name__c ='test';
        bulkRecord002.PRM_Last_Name__c='designer';
        bulkRecord002.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord002.PRM_Partner_Program__c='IPA';
        bulkRecord002.PRM_Suppress_Email__c=true;
        bulkRecord002.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord002);

        Account acc2 = [Select Id from Account where Name = 'Intel acc'];
        PRM_Bulk_Data_Upload__c bulkRecord003 = new PRM_Bulk_Data_Upload__c();
        bulkRecord003.PRM_Object__c='Contact';
        bulkRecord003.PRM_AccountId__c =acc2.Id;
        bulkRecord003.PRM_ContactEmail__c ='testdesigner12@mailinator.com';
    bulkRecord003.PRM_First_Name__c ='test';
        bulkRecord003.PRM_Last_Name__c='designer';
        bulkRecord003.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord003.PRM_Partner_Program__c='IPA';
        bulkRecord003.PRM_Suppress_Email__c=true;
        bulkRecord003.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord003);

        Account acc3 = [Select Id from Account where Name = 'account Intel'];
        PRM_Bulk_Data_Upload__c bulkRecord004 = new PRM_Bulk_Data_Upload__c();
        bulkRecord004.PRM_Object__c='Contact';
        bulkRecord004.PRM_AccountId__c =acc3.Id;
        bulkRecord004.PRM_ContactEmail__c ='testdesigner1@mailinator.com';
    bulkRecord004.PRM_First_Name__c ='test';
        bulkRecord004.PRM_Last_Name__c='designer';
        bulkRecord004.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord004.PRM_Partner_Program__c='IPA';
        bulkRecord004.PRM_Suppress_Email__c=true;
        bulkRecord004.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord004);
        
        PRM_Bulk_Data_Upload__c bulkRecordnew1 = new PRM_Bulk_Data_Upload__c();
        bulkRecordnew1.PRM_Object__c='Contact';
        bulkRecordnew1.PRM_AccountId__c =acc3.Id;
        bulkRecordnew1.PRM_ContactEmail__c ='testdesigner1we2@mailinator.com';
    bulkRecordnew1.PRM_First_Name__c ='test';
        bulkRecordnew1.PRM_Last_Name__c='designer';
        bulkRecordnew1.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecordnew1.PRM_Partner_Program__c='IPA';
        bulkRecordnew1.PRM_Suppress_Email__c=true;
        bulkRecordnew1.PRM_Partner_Relationship__c='Partner Admin';
        bulkRecs.add(bulkRecordnew1);

        Contact conac = [Select Id from Contact where Email = 'testivorysmithy03@mailinator.com'];
        Contact conac4 = [Select Id from Contact where Email = 'testivorysmithy01@mailinator.com'];

        PRM_Bulk_Data_Upload__c bulkRecord005 = new PRM_Bulk_Data_Upload__c();
        bulkRecord005.PRM_Object__c='Contact';
        bulkRecord005.PRM_AccountId__c =acc.Id;
        bulkRecord005.PRM_ContactEmail__c ='testivorysmithy01@mailinator.com';
    bulkRecord005.PRM_First_Name__c ='test';
        bulkRecord005.PRM_Last_Name__c='designer';
        bulkRecord005.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord005.PRM_Partner_Program__c='IPA';
        bulkRecord005.PRM_Suppress_Email__c=true;
        bulkRecord005.PRM_Partner_Relationship__c='Employee;Partner Admin';
        bulkRecs.add(bulkRecord005);

        PRM_Bulk_Data_Upload__c bulkRecord006 = new PRM_Bulk_Data_Upload__c();
        bulkRecord006.PRM_Object__c='Contact';
        bulkRecord006.PRM_AccountId__c =acc.Id;
        bulkRecord006.PRM_ContactEmail__c ='testivorysmithy03@mailinator.com';
    bulkRecord006.PRM_First_Name__c ='test';
        bulkRecord006.PRM_Last_Name__c='designer';
        bulkRecord006.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord006.PRM_Partner_Program__c='IPA';
        bulkRecord006.PRM_Suppress_Email__c=true;
        bulkRecord006.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord006);

        PRM_Bulk_Data_Upload__c bulkRecord007 = new PRM_Bulk_Data_Upload__c();
        bulkRecord007.PRM_Object__c='Contact';
        bulkRecord007.PRM_AccountId__c ='0018A000000000pQAL';
        bulkRecord007.PRM_ContactEmail__c ='testivorysmithy03@mailinator.com';
    bulkRecord007.PRM_First_Name__c ='test';
        bulkRecord007.PRM_Last_Name__c='designer';
        bulkRecord007.PRM_IPA_Partner_Role__c='Service Provider';
        bulkRecord007.PRM_Partner_Program__c='IPA';
        bulkRecord007.PRM_Suppress_Email__c=true;
        bulkRecord007.PRM_Partner_Relationship__c='Employee';
        bulkRecs.add(bulkRecord007);


        if(bulkRecs.size()>0){
            try{
               Database.insert(bulkRecs,false); 
            }
            catch(Exception e){
                System.debug('Exception'+e);
            }  
        }
        
    }
}