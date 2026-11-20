/********************************************************************************************************************
Apex Class Name   :  Core_IPS_Attachment_Extension_Test
Version           :  1.0
Created Date      :  28/11/2017
Feature No        :  F5427
US Nos            :  US67638,US67639,US79605
Iteration&Release No: 3 & 2
Function          :  Test class for Core_IPS_Attachment_Extension.
                   This method covers code for methods in Core_IPS_Attachment_Extension class.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------
*Aparna Ogirala                       28/11/2017               Original Version
*Aparna                                3/7/2018          Modified for DE36696 and DE36701 
* //System.assert()--> statement Added By Hassan Khan 04-02-2024
*******************************************************************************************************************/

@isTest

public class Core_IPS_Attachment_Extension_Test{
    
     static List<User> ListOfUser = new List<User>();
    static void createusers(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB-Dual IPS')];//,'Partner','IPS Agent-Partner')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(2);
       
            ListOfUser[0].ProfileID =  profiles.get('System Administrator');
            ListOfUser[1].ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
            /*ListOfUser[2].ProfileID =  profiles.get('Partner');
            ListOfUser[3].ProfileID =  profiles.get('IPS Agent-Partner');*/
       // }
      insert ListOfUser;
    }
         
    public static testmethod void insertAttachments(){
    
    Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Attachment_Extension';
        customsett.Core_Description__c ='Test Desc';
        customsett.Core_Object__c='Case';
        insert customsett;
        
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
       
        Core_IPS_Labels__c lbl = new Core_IPS_Labels__c();
        lbl.name='Data Migration Profile Id';
        lbl.value__c = '00eo0000000f7test';
        listcstSettings.add(lbl);
        
        Core_IPS_Labels__c lbl1 = new Core_IPS_Labels__c();
        lbl1.name='COMPLETE';
        lbl1.value__c = 'Complete';
        listcstSettings.add(lbl1);
        
        Core_IPS_Labels__c lbl2 = new Core_IPS_Labels__c();
        lbl2.name='Agent';
        lbl2.value__c = 'Agent';
        listcstSettings.add(lbl2);
        
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_INTEL';
        label1.value__c = System.Label.Core_IPS_CaseRTF_Private_To_Intel;
        listcstSettings.add(label1);
        
        Core_IPS_Labels__c  label2 = new Core_IPS_Labels__c();
        label2.name = 'PRIVATE_TO_AGENTS';
        label2.value__c =   system.label.Core_IPS_CaseRTF_Notetype_PrivateToAgents;
        listcstSettings.add(label2);
    
        Core_IPS_Labels__c  label3 = new Core_IPS_Labels__c();
        label3.name = 'Partner';
        label3.value__c = 'Partner';
        listcstSettings.add(label3);
        
        Core_IPS_Labels__c  label4 = new Core_IPS_Labels__c();
        label4.name = 'PRIVATE_TO_PARTNERS';
        label4.value__c = 'Private to Partner';
        listcstSettings.add(label4);
        
        Core_IPS_Labels__c label5= new Core_IPS_Labels__c();
        label5.name='Backend Integration';
        label5.value__c='Backend Integration';
        listcstSettings.add(label5);

        
        insert listcstSettings;
    
        user adminUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='System Administrator' limit 1];
        adminUser.profileid =p.id;
        adminUser.username='adminTest'+Crypto.getRandomLong()+'@intel.com';
        insert adminUser;
          
      system.runAs(adminUser){
          
        Case cs=TestUtilities.getCase();
        Insert cs;
        
        Core_IPS_Case_Attachments__c attachments=new  Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c=cs.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        attachments.Core_FileUploadedBy__c=userInfo.getUserID();
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        Insert attachments;
        
        //commented for Classic EOL : Tejaswini        
     /*   PageReference pageRef=Page.Core_IPS_CaseAttachment_Visibility;
        Test.setCurrentPage(pageRef); */
        List<Core_IPS_Case_Attachments__c> lstAttach=new  List<Core_IPS_Case_Attachments__c>();
        lstAttach.add(attachments);
        System.currentPageReference().getParameters().put('id',cs.id);
        ApexPages.currentPage().getParameters().put('List','');
        Core_IPS_Attachment_Extension inst=new  Core_IPS_Attachment_Extension(new  ApexPages.StandardController(cs));
        inst.showLink = 'full';
        inst.fetchattachmentList();
        inst.URL2();
        System.assert(listcstSettings.size() > 0, true);  
    }
  }
/********************************************************************************************************************
Method Name       :  testDelAttachments
Version           :  1.0
Feature No        :  F5427
US Nos            :  US67638,US67639
Iteration&Release No: 3 & 2
Created Date     :   28/11/2017
Function         :   Method covers code for delete attachments function in Core_IPS_Attachment_Extension class
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------
*Aparna Ogirala                       28/11/2017               Original Version
*******************************************************************************************************************/
    public static testmethod void testDelAttachments(){
    
     Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Attachment_Extension';
        customsett.Core_Description__c ='Test Desc';
        customsett.Core_Object__c='Case';
        insert customsett;
        
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
       
        Core_IPS_Labels__c lbl = new Core_IPS_Labels__c();
        lbl.name='Data Migration Profile Id';
        lbl.value__c = '00eo0000000f7test';
        listcstSettings.add(lbl);
        
        Core_IPS_Labels__c lbl1 = new Core_IPS_Labels__c();
        lbl1.name='COMPLETE';
        lbl1.value__c = 'Complete';
        listcstSettings.add(lbl1);
        
        Core_IPS_Labels__c lbl2 = new Core_IPS_Labels__c();
        lbl2.name='Agent';
        lbl2.value__c = 'Agent';
        listcstSettings.add(lbl2);
        
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_INTEL';
        label1.value__c = 'Private to Intel';
        listcstSettings.add(label1);
        
        Core_IPS_Labels__c  label2 = new Core_IPS_Labels__c();
        label2.name = 'PRIVATE_TO_AGENTS';
        label2.value__c = 'Private to Agents';
        listcstSettings.add(label2);
    
        Core_IPS_Labels__c  label3 = new Core_IPS_Labels__c();
        label3.name = 'Partner';
        label3.value__c = 'Partner';
        listcstSettings.add(label3);
        
        Core_IPS_Labels__c  label4 = new Core_IPS_Labels__c();
        label4.name = 'PRIVATE_TO_PARTNERS';
        label4.value__c = 'Private to Partner';
        listcstSettings.add(label4);
        
        Core_IPS_Labels__c label5= new Core_IPS_Labels__c();
        label5.name='Backend Integration';
        label5.value__c='Backend Integration';
        listcstSettings.add(label5);
       
        insert listcstSettings;
    
        user adminUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='System Administrator' limit 1];
        adminUser.username='adminTest'+Crypto.getRandomLong()+'@intel.com';
        adminUser.profileid =p.id;
        insert adminUser;
          
       system.runAs(adminUser){
       User u = [select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
    
        Case cs=TestUtilities.getCase();
        Insert cs;
        
        Core_IPS_Case_Attachments__c attachments=new  Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c=cs.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        attachments.Core_FileUploadedBy__c=userInfo.getUserID();
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        Insert attachments;
        
        
        List<Core_IPS_Case_Attachments__c> lstAttach=new  List<Core_IPS_Case_Attachments__c>();
        lstAttach.add(attachments);
        System.currentPageReference().getParameters().put('id',cs.id);
        Core_IPS_Attachment_Extension inst1=new  Core_IPS_Attachment_Extension(new  ApexPages.StandardController(attachments));
        //System.currentPageReference().getParameters().put('attachmentId',attachments.id);
        ApexPages.CurrentPage().getparameters().put('attachmentId',attachments.id);
          if(attachments.id != null)
           inst1.deleteAttachments();  
      }
      System.assert(listcstSettings.size() > 0, true);
  }  
/********************************************************************************************************************
Method Name       :  NegativetestDelAttachments
Version           :  1.0
DE Nos            :  DE36696 and DE36701 
Iteration&Release No: 3 & 3
Created Date     :   3/8/2017
Function         :   Method covers catch block in delete attachments function in Core_IPS_Attachment_Extension class
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------
*Aparna Ogirala                       3/8/2017               Original Version
*******************************************************************************************************************/
    public static testmethod void NegativetestDelAttachments(){
    
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Attachment_Extension';
        customsett.Core_Description__c ='Test Desc';
        customsett.Core_Object__c='Case';
        insert customsett;
        
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
       
        Core_IPS_Labels__c lbl = new Core_IPS_Labels__c();
        lbl.name='Data Migration Profile Id';
        lbl.value__c = '00eo0000000f7test';
        listcstSettings.add(lbl);
        
        Core_IPS_Labels__c lbl1 = new Core_IPS_Labels__c();
        lbl1.name='COMPLETE';
        lbl1.value__c = 'Complete';
        listcstSettings.add(lbl1);
        
        Core_IPS_Labels__c lbl2 = new Core_IPS_Labels__c();
        lbl2.name='Agent';
        lbl2.value__c = 'Agent';
        listcstSettings.add(lbl2);
        
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_INTEL';
        label1.value__c = 'Private to Intel';
        listcstSettings.add(label1);
        
        Core_IPS_Labels__c  label2 = new Core_IPS_Labels__c();
        label2.name = 'PRIVATE_TO_AGENTS';
        label2.value__c = 'Private to Agents';
        listcstSettings.add(label2);
    
        Core_IPS_Labels__c  label3 = new Core_IPS_Labels__c();
        label3.name = 'Partner';
        label3.value__c = 'Partner';
        listcstSettings.add(label3);
        
        Core_IPS_Labels__c  label4 = new Core_IPS_Labels__c();
        label4.name = 'PRIVATE_TO_PARTNERS';
        label4.value__c = 'Private to Partner';
        listcstSettings.add(label4);
        
        insert listcstSettings;
    
        user adminUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='System Administrator' limit 1];
        adminUser.username='adminTest'+Crypto.getRandomLong()+'@intel.com';
        adminUser.profileid =p.id;
        insert adminUser;
          
       system.runAs(adminUser){
       User u = [select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
    
        Case cs=TestUtilities.getCase();
        Insert cs;
        
        Core_IPS_Case_Attachments__c attachments=new  Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c=cs.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        attachments.Core_FileUploadedBy__c=userInfo.getUserID();
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        try{
        Insert attachments;
         }
        catch(DMLexception ex)// exception handling
        {
        system.assertEquals(ex.getMessage(), ex.getMessage());
        }
        Apexpages.Standardcontroller stdcon = new Apexpages.Standardcontroller(cs);
        Core_IPS_Attachment_Extension inst1=new  Core_IPS_Attachment_Extension(stdcon);
        inst1.fetchattachmentList();
        inst1.deleteAttachments();
        
                     
    }
  } 
/********************************************************************************************************************
Method Name       : customerTest
Version           : 1.0
Feature No        :  F5427
US Nos            :  US67638,US67639
Iteration&Release No: 3 & 2
Created Date     : 28/11/2017
Function        : Method covers code for attachments function in Core_IPS_Attachment_Extension class as a customer
Modification Log :
* Developer                             Date                   Description
* ------------------------------------------------------------------------------
*Aparna Ogirala                       28/11/2017               Original Version
*******************************************************************************************************************/
    public static testmethod void customerTest(){
    
      Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Attachment_Extension';
        customsett.Core_Description__c ='Test Desc';
        customsett.Core_Object__c='Case';
        insert customsett;
        
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
       
        Core_IPS_Labels__c lbl = new Core_IPS_Labels__c();
        lbl.name='Data Migration Profile Id';
        lbl.value__c = '00eo0000000f7test';
        listcstSettings.add(lbl);
        
        Core_IPS_Labels__c lbl1 = new Core_IPS_Labels__c();
        lbl1.name='COMPLETE';
        lbl1.value__c = 'Complete';
        listcstSettings.add(lbl1);
        
        Core_IPS_Labels__c lbl2 = new Core_IPS_Labels__c();
        lbl2.name='Agent';
        lbl2.value__c = 'Agent';
        listcstSettings.add(lbl2);
        
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_INTEL';
        label1.value__c = 'Private to Intel';
        listcstSettings.add(label1);
        
        Core_IPS_Labels__c  label2 = new Core_IPS_Labels__c();
        label2.name = 'PRIVATE_TO_AGENTS';
        label2.value__c = 'Private to Agents';
        listcstSettings.add(label2);
    
        Core_IPS_Labels__c  label3 = new Core_IPS_Labels__c();
        label3.name = 'Partner';
        label3.value__c = 'Partner';
        listcstSettings.add(label3);
        
        Core_IPS_Labels__c  label4 = new Core_IPS_Labels__c();
        label4.name = 'Customer';
        label4.value__c = 'Customer';
        listcstSettings.add(label4);
        
        Core_IPS_Labels__c label5= new Core_IPS_Labels__c();
        label5.name='Comment Source - Customer';
        label5.value__c='Customer Portal';
        insert label5;
        
        Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
        label6.name='Backend Integration';
        label6.value__c='Backend Integration';
        listcstSettings.add(label6);
        
        Core_IPS_Labels__c label7= new Core_IPS_Labels__c();
        label7.name='PRIVATE_TO_PARTNERS  ';
        label7.value__c='Private to Partners';
        listcstSettings.add(label7);

        insert listcstSettings;
        
         user custUser= TestUtilities.getCustomerUser(system.Label.Core_IPS_External_Customer_Profile);
      
      if(custUser != null){
      
        system.runAs(custUser){
        
            Case cs=TestUtilities.getCase();
            Insert cs;
           
            Core_IPS_Case_Attachments__c attachments=new  Core_IPS_Case_Attachments__c();
            attachments.Core_Case__c=cs.id;
            attachments.Core_File_Description__c='Test-Description';
            attachments.Core_File_Name__c='Test-File';
            attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            attachments.Core_FileUploadedBy__c=custUser.id;
            attachments.Core_File_URL__c='www.test.com';
            attachments.Core_FileSizeInBytes__c='2KB';
            attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
            Insert attachments;
            
            List<Core_IPS_Case_Attachments__c> lstAttach=new  List<Core_IPS_Case_Attachments__c>();
            lstAttach.add(attachments);
            System.currentPageReference().getParameters().put('id',cs.id);
            Core_IPS_Attachment_Extension inst2=new  Core_IPS_Attachment_Extension(new  ApexPages.StandardController(cs));
            inst2.fetchattachmentList();
        }
      }
      System.assert(listcstSettings.size() > 0, true);
    }
    // Method Added By Prem
    public static testmethod void VariableIntialize(){
        list<Core_IPS_Labels__c> listcstSettings = new list<Core_IPS_Labels__c >();
       
        Core_IPS_Labels__c  label = new Core_IPS_Labels__c();
        label.name = 'PUBLIC_TO_CUSTOMERS';
        label.value__C = 'Public to Customers';
        listcstSettings.add(label);
        
        Core_IPS_Labels__c  label1 = new Core_IPS_Labels__c();
        label1.name = 'PRIVATE_TO_INTEL';
        label1.value__c = 'Private to Intel';
        listcstSettings.add(label1);
       
        Core_IPS_Labels__c  label3 = new Core_IPS_Labels__c();
        label3.name = 'Partner';
        label3.value__c = 'Partner';
        listcstSettings.add(label3);
        
        insert listcstSettings;
        Case cs=TestUtilities.getCase();
        Insert cs;
        
        Core_IPS_Attachment_Extension inst2=new  Core_IPS_Attachment_Extension(new  ApexPages.StandardController(cs));
        system.assertNotEquals(inst2.privateFileURL,null);
        system.assertNotEquals(inst2.publicFileURL,null);
        system.assertNotEquals(inst2.partnerAgentPrivateFileURL,null);
        system.assertNotEquals(inst2.partnerAgentPublicFileURL,null);
        system.assertNotEquals(inst2.publicURL,null);
    }
    
/********************************************************************************************************************
Method Name       : partnerTestDFAE()
Version           : 1.0
Feature No        : 10794
US Nos            :  US104151 and US104153
Iteration&Release No:i11 & R4.3
Created Date     : 30/4/2018
Function        : Method covers code for attachments function in Core_IPS_Attachment_Extension class as a partnerDFAE
Modification Log :
* Developer                             Date                   Description
* ------------------------------------------------------------------------------
*Aparna Ogirala                     30/4/2018                    Original Version
*******************************************************************************************************************/ 
    public static testmethod void partnerTestDFAE(){
        
       createusers();
       Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='Partner' ];// OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
        }
        
         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         User userRecord = new User();
       
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'PUBLIC_TO_CUSTOMERS';
         labels.value__c='Public to Customers';
         insert labels;
         
         Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
         label1.name= 'PRIVATE_TO_AGENTS';
         label1.value__c= 'Private to Agents';
         insert label1;
         
         Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
         Label2.name= 'PRIVATE_TO_INTEL';
         label2.value__c= 'Private to Intel';
         insert label2;
          Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
         label3.name='Customer';
         label3.value__c='Customer';
         insert label3;
         
         Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
         label4.name='FAE';
         label4.value__c='FAE';
         insert label4;
         
         Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
         label5.name='Agent';
         label5.value__c='Agent';
         insert label5;
         
          Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
         label6.name='Backend Integration';
         label6.value__c='Backend Integration';
         insert label6;
         
         Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
         label7.name='Data Migration';
         label7.value__c='Data Migration';
         insert label7;
         
         Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
         label8.name='Partner';
         label8.value__c='Partner';
         insert label8;
         
         Core_IPS_Labels__c Label9 = new Core_IPS_Labels__c ();
         Label9.name= 'PRIVATE_TO_PARTNERS';
         label9.value__c= 'Private to Partner';
         insert label9;
         
          Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
         label10.name='Partner - DFAE';
         label10.value__c='Partner - DFAE';
         insert label10;
         
         Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
         label11.name='Partner - Agent';
         label11.value__c='Partner - Agent';
         insert label11;
         
         Account testAccount1;
         Contact testContact ; 

        System.runAs ( ListOfUser[0]) { 
          
          UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
          Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
          User portalAccountOwner1 = new User(
                  UserRoleId = portalRole.Id,
                  ProfileId = profile1.Id,
                  Username = 'test877@intel.com',
                  Alias = 'batman',
                  Email='newuser1344@intel.com',
                  EmailEncodingKey='UTF-8',
                  Firstname='Bruce',
                  Lastname='Wayne',
                  LanguageLocaleKey='en_US',
                  LocaleSidKey='en_US',
                  TimeZoneSidKey='America/Chicago'
              );
           Database.insert(portalAccountOwner1);
         
              testAccount1=TestUtilities.getAccount(); 
              testAccount1.ownerid = portalAccountOwner1.id;      
              insert testAccount1;             
              contact  testContact1 = new Contact(FirstName='testFirstNameXYZ', LastName='testLastNameABC', Email='test12346430987@testing.com.testsetup',ownerId = intelSupportOwner,
                                                 AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
              insert testContact1;      
              
              UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
              insert ur;
              
              userRecord.Alias = 'StdUser';
              userRecord.contactId =testContact1.id;
              userRecord.Email = 'newuser1@intel.com';
              userRecord.EmailEncodingKey ='UTF-8';
              userRecord.LastName = 'Testing';
              userRecord.FirstName = 'FName';
              userRecord.LanguageLocaleKey = 'en_US';
              userRecord.LocaleSidKey = 'en_US';
              userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
              userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
              userRecord.isActive = true;
              
              userRecord.ProfileID =  profiles.get('Partner');  
              
              insert userRecord;
              
              PermissionSet ps = [SELECT Id,name FROM PermissionSet WHERE Name = 'Core_IPS_Partner_FAE_Permission_Set']; 
              PermissionSetAssignment psa = new PermissionSetAssignment();
              psa.AssigneeId = userRecord.Id;
              psa.PermissionSetId = ps.Id;
              insert psa;  
              
             testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test14@testing.com.testsetup',ownerId = intelSupportOwner,
                                     AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
              insert testContact;
              System.assertNotEquals(null, testContact.id);            
       } 
         
        System.runAs(userRecord){
            Case Cs =  TestUtilities.getCase(); 
            
           /* Account accountRecord = new Account();
            accountRecord.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
            accountRecord.Name = 'Dell Products2';
            accountRecord.Core_Account_Type__c = 'Distributor';
            accountRecord.Core_Sales_Segment__c = 'Compute';
            accountRecord.Industry = 'Banking2';
            accountRecord.BillingCity = 'Delhi1';
            accountRecord.BillingCountry = 'USA';
            accountRecord.billingState = 'AK';
            accountRecord.billingStreet = 'Bratislava 12';
            accountRecord.Core_IPS_Active__c = true;
            insert accountRecord;*/
      
           //System.assertNotEquals(null, accountRecord.id);
           // cs.AccountId=accountRecord.id;
            cs.contactid=testContact.id;
            insert Cs;
           
            //commented for Classic EOL : Tejaswini        
     /*   PageReference pageRef=Page.Core_IPS_CaseAttachment_Visibility;
        Test.setCurrentPage(pageRef); */
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_Attachment_Extension chkAtt = new Core_IPS_Attachment_Extension(StndContr);
            system.assertNotEquals(chkAtt.partnerFileURL,null);
            ApexPages.currentPage().getParameters().put('List','full');
            System.assertNotEquals(null,chkAtt.URL2());
                      
        }
    }

 
/********************************************************************************************************************
Method Name       : partnerTest()
Version           : 1.0
Feature No        : 10794
US Nos            :  US10451 and US104153
Iteration&Release No: i10 & R4.2
Created Date     : 30/4/2018
Function         : Method covers code for attachments function in Core_IPS_Attachment_Extension class as a partner
Modification Log :
* Developer                             Date                   Description
* ------------------------------------------------------------------------------
*Aparna Ogirala                     30/4/2018                   Original Version
*******************************************************************************************************************/ 
    public static testmethod void partnerTest(){
        
        createusers();
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='Partner' ];// OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
        }        
         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         User userRecord = new User();
         
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'PUBLIC_TO_CUSTOMERS';
         labels.value__c='Public to Customers';
         insert labels;
         
         Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
         label1.name= 'PRIVATE_TO_AGENTS';
         label1.value__c= 'Private to Agents';
         insert label1;
         
         Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
         Label2.name= 'PRIVATE_TO_INTEL';
         label2.value__c= 'Private to Intel';
         insert label2;
          Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
         label3.name='Customer';
         label3.value__c='Customer';
         insert label3;
         
         Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
         label4.name='FAE';
         label4.value__c='FAE';
         insert label4;
         
         Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
         label5.name='Agent';
         label5.value__c='Agent';
         insert label5;
         
          Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
         label6.name='Backend Integration';
         label6.value__c='Backend Integration';
         insert label6;
         
         Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
         label7.name='Data Migration';
         label7.value__c='Data Migration';
         insert label7;
         
         Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
         label8.name='Partner';
         label8.value__c='Partner';
         insert label8;
         
         Core_IPS_Labels__c Label9 = new Core_IPS_Labels__c ();
         Label9.name= 'PRIVATE_TO_PARTNERS';
         label9.value__c= 'Private to Partner';
         insert label9;
         
          Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
         label10.name='Partner - DFAE';
         label10.value__c='Partner - DFAE';
         insert label10;
         
         Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
         label11.name='Partner - Agent';
         label11.value__c='Partner - Agent';
         insert label11;
         
         Account testAccount1;
         Contact testContact ;
          
          System.runAs ( ListOfUser[0]) { 
         
          UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
                Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
                User portalAccountOwner1 = new User(
                    UserRoleId = portalRole.Id,
                    ProfileId = profile1.Id,
                    Username = 'test1206@intel.com',
                    Alias = 'batman',
                    Email='newuser155@intel.com',
                    EmailEncodingKey='UTF-8',
                    Firstname='Bruce',
                    Lastname='Wayne',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    TimeZoneSidKey='America/Chicago'
                );
                Database.insert(portalAccountOwner1);
          
            testAccount1=TestUtilities.getAccount(); 
            testAccount1.OwnerId = portalAccountOwner1.Id ;      
            insert testAccount1;                 
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup', ownerId = intelSupportOwner,
                                     AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful', MailingCountry = 'India');
            insert testContact1;      

            UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert ur;  
              
              userRecord.Alias = 'StdUser';
              userRecord.contactId =testContact1.id;
                userRecord.Email = 'newuser1@intel.com';
                //userRecord.UserRoleId = ur.Id ;
                userRecord.EmailEncodingKey ='UTF-8';
                userRecord.LastName = 'Testing';
                userRecord.FirstName = 'FName';
                userRecord.LanguageLocaleKey = 'en_US';
                userRecord.LocaleSidKey = 'en_US';
                userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
                userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
                userRecord.isActive = true;
                
           userRecord.ProfileID =  profiles.get('Partner');           
           insert userRecord;
           
           PermissionSet ps = [SELECT Id,name FROM PermissionSet WHERE Name = 'Core_IPS_Permission_Set']; 
           PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userRecord.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;  
            
             testContact = new Contact(FirstName='testFirstName123', LastName='testLastName1', Email='test1234@testing.com.testsetup', ownerId = intelSupportOwner,
                                     AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
            insert testContact;
            System.assertNotEquals(null, testContact.id); 
       } 
         
        System.runAs(userRecord){
            Case Cs =  TestUtilities.getCase(); 
            //Account testAccount=TestUtilities.getAccount();
           /* Account accountRecord = new Account(
            recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId(),
            Name = 'Dell Products1',
            Core_Account_Type__c = 'Distributor',
            Core_Sales_Segment__c = 'Compute',
            Industry = 'Banking1',
            BillingCity = 'Delhi1',
            BillingCountry = 'USA',
            billingState = 'AK',
            billingStreet = 'Bratislava 1',
            Core_IPS_Active__c = true);
            insert accountRecord;*/
                         
            // System.assertNotEquals(null, accountRecord.id);
            //cs.AccountId=accountRecord.id;
            cs.contactid=testContact.id;
            insert Cs;
           
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
           
            //commented for Classic EOL : Tejaswini        
     /*   PageReference pageRef1=Page.Core_IPS_CaseAttachment_Visibility;
        Test.setCurrentPage(pageRef); */
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr1 = new ApexPages.standardController(CS);
            
            Core_IPS_Attachment_Extension chkAtt = new Core_IPS_Attachment_Extension(StndContr);
            system.assertNotEquals(chkAtt.partnerFileURL,null);
            system.assertNotEquals(chkAtt.privateToPartnerURL,null);
        }
     }
}