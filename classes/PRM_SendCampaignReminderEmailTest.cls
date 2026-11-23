@IsTest
public class PRM_SendCampaignReminderEmailTest {

    @TestSetup
    public static void createData()
    {
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
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert acc;
        
        Campaign testCampaign = new Campaign(Name='Test', Description='Test', Core_Activity_Types__c='Promotion',
                                             Status='Planned', EndDate=Date.today().addMonths(1));
        insert testCampaign;
        Campaign testCampaign1 = new Campaign(Name='Test1', Description='Tewst', Core_Activity_Types__c='Promotion',
                                             Status='Planned', EndDate=Date.today().addMonths(1));
        insert testCampaign1;
        
        Contact cont = new Contact();  //Contact
        cont.AccountId=acc.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Enterprise_Id__c = '23456';
        cont.Core_Preferred_Language__c = 'ENG';
        cont.Core_Do_Not_Contact__c = false;
        insert cont;
        
        Contact cont1 = new Contact();  //Contact
        cont1.AccountId=acc.Id;
        cont1.lastName='Grillbh';
        cont1.FirstName='Adam';
        cont1.email='gfgvss@rediff.com';
        cont1.Core_Job_Function__c='Branch Manager';
        cont1.Core_eRPM_Language_Code__c='Eng';
        cont1.Core_IPA_PartnerRole__c = 'Service Provider';
        cont1.Core_Login_Id__c = 'abcs';
        cont1.Core_Enterprise_Id__c = '234156';
        cont1.Core_Preferred_Language__c = 'ENG';
        cont1.Core_Do_Not_Contact__c = false;
        insert cont1; 
        
         PRM_Bulk_Data_Upload__c bulkRecord001 = new PRM_Bulk_Data_Upload__c();
        bulkRecord001.PRM_Object__c='Contact';
        bulkRecord001.PRM_AccountId__c =acc.Id;
        bulkRecord001.PRM_Contact_Id__c = cont.id;
        bulkRecord001.PRM_ContactEmail__c ='testdesigner1234@mailinator.com';
        bulkRecord001.PRM_OperationType__c='Insert';
        bulkRecord001.PRM_First_Name__c ='test';
        bulkRecord001.PRM_Last_Name__c='designer';
        bulkRecord001.PRM_IPA_Partner_Role__c='Distributor';
        bulkRecord001.PRM_Partner_Program__c='IPA';
        bulkRecord001.PRM_Suppress_Email__c=false;
        bulkRecord001.PRM_Partner_Relationship__c='Employee';
        bulkRecord001.PRM_BatchID__c = 'BB-1001';
        bulkRecord001.PRM_RegistrationType__c ='Admin Invite';
        bulkRecord001.PRM_Send_Reminders__c=true;
        bulkRecord001.PRM_CampaignId__c = testCampaign.id;
        Database.insert(bulkRecord001,false);
        
        PRM_Bulk_Data_Upload__c bulkRecord002 = new PRM_Bulk_Data_Upload__c();
        bulkRecord002.PRM_Object__c='Contact';
        bulkRecord002.PRM_AccountId__c =acc.Id;
        bulkRecord002.PRM_Contact_Id__c = cont1.id;
        bulkRecord002.PRM_ContactEmail__c ='testdesi234@mailinator.com';
        bulkRecord002.PRM_OperationType__c='Insert';
        bulkRecord002.PRM_First_Name__c ='test';
        bulkRecord002.PRM_Last_Name__c='designer';
        bulkRecord002.PRM_IPA_Partner_Role__c='Distributor';
        bulkRecord002.PRM_Partner_Program__c='IPA';
        bulkRecord002.PRM_Suppress_Email__c=false;
        bulkRecord002.PRM_Partner_Relationship__c='Employee';
        bulkRecord002.PRM_BatchID__c = 'BB-1002';
        bulkRecord002.PRM_RegistrationType__c ='Admin Invite';
        bulkRecord002.PRM_Send_Reminders__c=true;
        bulkRecord002.PRM_CampaignId__c=testCampaign.id;
        Database.insert(bulkRecord002,false);
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name=System.Label.PRM_Primary_Contact;
        cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_Channel_Program_Id__c=cp.Id;
        cr1.PRM_InActive_Ind__c = false;
        insert cr1;
        
         PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name=System.Label.PRM_WorksFor;
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = false;
        cr2.PRM_Mandatory_Relationship_Ind__c = true;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        cr2.PRM_InActive_Ind__c = false;
        insert cr2;
        
        PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr.PRM_InActive_Ind__c= false;
        acr.PRM_Account_Id__c=acc.Id;
        acr.PRM_Relationship_Id__c = cr1.Id;
        acr.PRM_Contact_Id__c=cont.Id;
        acr.PRM_execute_trigger__c=true;
        acr.PRM_Start_Date_Dt__c= system.today()-2; 
        acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1; 
        acr.PRM_Status_nm__c = 'Pending Action';
        acr.PRM_Suppress_Email__c = false;
        insert acr;
         PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
        acr1.PRM_InActive_Ind__c= false;
        acr1.PRM_Account_Id__c=acc.Id;
        acr1.PRM_Relationship_Id__c = cr2.Id;
        acr1.PRM_Contact_Id__c=cont1.Id;
        acr1.PRM_execute_trigger__c=true;
        acr1.PRM_Start_Date_Dt__c= system.today()-2; 
        acr1.PRM_End_Date_Dt__c= acr1.PRM_Start_Date_Dt__c+1; 
        acr1.PRM_Status_nm__c = 'Pending Action';
        acr1.PRM_Suppress_Email__c = false;
        insert acr1;
        
        
         
        PRM_Reminder_Email__c rem1 = new PRM_Reminder_Email__c();
        rem1.PRM_Campaign__c=testCampaign.id;
        rem1.PRM_Status__c='Scheduled';
        rem1.PRM_BatchID__c='BB-1001';
        rem1.PRM_Email_Template__c ='CampaignInviteForBulk_Rem_ENG';
        rem1.PRM_Reminder_Date__c = system.today();
        insert rem1;
        
        PRM_Reminder_Email__c rem2 = new PRM_Reminder_Email__c();
        rem2.PRM_Campaign__c=testCampaign1.id;
        rem2.PRM_Status__c='Scheduled';
        rem2.PRM_BatchID__c='BB-1002';
        rem2.PRM_Reminder_Date__c = system.today();
        insert rem2;
        
      
    }
    
    @istest
    public static void testBatch(){
          EmailTemplate EmailTempl = new EmailTemplate();
        EmailTempl.isActive = true;
        EmailTempl.Name = 'CampaignInviteForBulk_Rem_ENG';
        EmailTempl.DeveloperName = 'CampaignInviteForBulk_Rem_ENG';
        EmailTempl.TemplateType = 'text';
        EmailTempl.subject = 'Testing';
        EmailTempl.HtmlValue = '';
        EmailTempl.FolderId = UserInfo.getUserId();
        Database.insert(EmailTempl);
        test.startTest();
        database.executeBatch(new PRM_SendCampaignReminderEmail(),10);
        test.stopTest();
    }
}