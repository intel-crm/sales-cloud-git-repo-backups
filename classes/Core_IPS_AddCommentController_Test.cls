/***************************************************************************************************
* Apex Class Name: Core_IPS_AddCommentController_Test
* Version     : 1.0 
* Function    : Test class for Core_IPS_AddCommentController
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                       02/11/2016                Created
****************************************************************************************************/
@isTest
public class Core_IPS_AddCommentController_Test{
    list<string> selectedVisibilityOption = new list<string>();
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
    public static testmethod void Core_IPS_AddCommentControllerTest(){
        createusers();
                  
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
             
        System.runAs(ListOfUser[0]){
            Test.startTest();
            Case CS =  TestUtilities.getCase(); 
            Account testAccount=TestUtilities.getAccount();
            insert testAccount;
             
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test12345@testing.com.testsetup',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact;
            System.assertNotEquals(null, testAccount.id);
            RecordType rtype =[Select Name, Id From RecordType where sObjectType='Case' and isActive=true and RecordType.developerName='IPS_GEC_ReadOnly'];
            cs.AccountId=testAccount.id;
            cs.contactid=testContact.id;
            cs.recordtypeid = rtype.id;
            insert CS;
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
            //addComment.selectedVisibilityOption.add('True');//Commented as per Sumukh this is not needed.
            // addComment.selectedNoteTypeOption.add('True');    
            Pagereference Pg = addComment.saveComment();
            //List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
            Test.stopTest();
        }
    }
    //Added by prem for US92252
   
     public static testmethod void Core_IPS_AddCommentControllerExternal(){
        
        createusers();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='Partner' OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
        }
        
        system.debug('profiles'+ profiles);
        
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
         
        System.runAs(ListOfUser[0]){
            Case Cs =  TestUtilities.getCase(); 
            Account testAccount=TestUtilities.getAccount();
            insert testAccount;
             
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact;
            System.assertNotEquals(null, testAccount.id);
            cs.AccountId=testAccount.id;
            cs.contactid=testContact.id;
            insert Cs;
            
           
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
           
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;           
             System.debug('loginuserprofilename'+addComment.loginuserprofilename);
            addComment.externalUser = true;
            addComment.getcaseComments();
            Pagereference Pg = addComment.saveComment();
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'),userinfo.getUserid());
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Data Ops'),userinfo.getUserid());         
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Data Migration'),userinfo.getUserid()); 
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Integration'),userinfo.getUserid());
            /*Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Agent-Partner'));*/
            
            
            List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
             boolean disablep=addComment.getdisableprevious();
               boolean disableN=addComment.getdisbaleNext();    
               integer i= addComment.getTotal_size();
               integer j= addComment.getPageNumber();
               integer k= addComment.getTotalPages();
               k=addComment.count;
               addComment.next();
               addComment.previous();
              // addComment.sendEMail();
        }
        
     }
     
     
      public static testmethod void Core_IPS_AddCommentControllerPartner(){
        
        createusers();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='Partner' ];// OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         User userRecord = new User();
         User userRecord1 = new User();
         
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
          //****************************************//
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
          //****************************************//
         
            testAccount1=TestUtilities.getAccount(); 
            testAccount1.OwnerId = portalAccountOwner1.Id ;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                     AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact1;      

         //   UserRole ur = [Select PortalType, PortalAccountId From UserRole WHERE NAME Like 'DAQRI Partner User' limit 1];
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
                   
            
            testContact = new Contact(FirstName='testFirstName123', LastName='testLastName1', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount1.Id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
                              
            insert testContact;
            System.assertNotEquals(null, testContact.id);            
       }        
         
       System.runAs(userRecord){
       
            Case Cs =  TestUtilities.getCase(); 
            //cs.AccountId=accountRecord.id;
            cs.contactid=testContact.id;
            insert Cs;
           
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
            addComment.partnerType ='Partner';
             System.debug('loginuserprofilename'+addComment.loginuserprofilename);
            addComment.externalUser = true;
             Pagereference Pg = addComment.saveComment();
            addComment.getcaseComments();            
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'),userinfo.getUserid());
            /*Core_IPS_AddCommentController.getAuthr(Profiles.get('Data Ops'));         
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Data Migration')); 
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Integration'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Agent-Partner'));*/
            
            
            List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
             boolean disablep=addComment.getdisableprevious();
               boolean disableN=addComment.getdisbaleNext();    
               integer i= addComment.getTotal_size();
               integer j= addComment.getPageNumber();
               integer k= addComment.getTotalPages();
               k=addComment.count;
               addComment.selectedRadioButton = 'Public to Customers'; 
               addComment.next();
               addComment.previous();
              // addComment.sendEMail();
        }
     }
     
     public static testmethod void Core_IPS_AddCommentControllerPartnerDFAE(){
        createusers();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='Partner' ];// OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         User userRecord = new User();
         User userRecord1 = new User();
       
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
          
          //****************************************//
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
          //****************************************//
                     
            testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = portalAccountOwner1.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                     AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact1;      

            // UserRole ur = [Select PortalType, PortalAccountId From UserRole WHERE NAME Like 'DAQRI Partner User' limit 1];
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
           
            
           
            PermissionSet ps = [SELECT Id,name FROM PermissionSet WHERE Name = 'Core_IPS_Partner_FAE_Permission_Set']; 
           PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userRecord.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            
            testContact = new Contact(FirstName='testFirstName1', LastName='testLastName12', Email='test14@testing.com.testsetup',
                                      AccountId=testAccount1.Id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');                             
            insert testContact;
            System.assertNotEquals(null, testContact.id);  
            
              
       } 
         
        System.runAs(userRecord){
            Case Cs =  TestUtilities.getCase(); 
            //cs.AccountId=accountRecord.id;
            cs.contactid=testContact.id;
            insert Cs;
           
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
             System.debug('loginuserprofilename'+addComment.loginuserprofilename);
            addComment.externalUser = true;
            Pagereference Pg = addComment.saveComment();
            addComment.getcaseComments();
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'),userinfo.getUserid());
            /*Core_IPS_AddCommentController.getAuthr(Profiles.get('Data Ops'));         
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Data Migration')); 
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Integration'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Agent-Partner'));*/
            
            
            List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
             boolean disablep=addComment.getdisableprevious();
               boolean disableN=addComment.getdisbaleNext();    
               integer i= addComment.getTotal_size();
               integer j= addComment.getPageNumber();
               integer k= addComment.getTotalPages();
               k=addComment.count;
               addComment.next();
               addComment.previous();
              // addComment.sendEMail();
        }
     }
     
    public static testmethod void Core_IPS_AddCommentControllerPartnerAgent(){
        createusers();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent-Partner' ];// OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : ProfileList){
        profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
         User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         User userRecord = new User();
         User userRecord1 = new User();
         
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
          
          //****************************************//
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
          //****************************************//
         
            testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = portalAccountOwner1.id;      
            insert testAccount1;             
            Contact testContact13 = new Contact(FirstName='testFirstName33123', LastName='testLastName123', Email='test124643@testing.com.testsetup',
                                     AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact13;      

            // UserRole ur = [Select PortalType, PortalAccountId From UserRole WHERE NAME Like 'DAQRI Partner User' limit 1];
             UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert ur;
              
              userRecord.Alias = 'StdUser';
              userRecord.contactId =testContact13.id;
                userRecord.Email = 'newuser21@intel.com';
                //userRecord.UserRoleId = ur.Id ;
                userRecord.EmailEncodingKey ='UTF-8';
                userRecord.LastName = 'Testing';
                userRecord.FirstName = 'FName';
                userRecord.LanguageLocaleKey = 'en_US';
                userRecord.LocaleSidKey = 'en_US';
                userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
                userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
                userRecord.isActive = true;
                
           userRecord.ProfileID =  profiles.get('IPS Agent-Partner');  
           
           insert userRecord;
           
           testContact = new Contact(FirstName='testFirstName12356', LastName='testLastName121', Email='test123454@testing.com.testsetup',
                                              AccountId=testAccount1.Id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');                              
            insert testContact;
            System.assertNotEquals(null, testContact.id); 
            
       } 
         
        System.runAs(userRecord){
            Case Cs =  TestUtilities.getCase(); 
            //cs.AccountId=accountRecord.id;
            cs.contactid=testContact.id;
            insert Cs;
           
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
             System.debug('loginuserprofilename'+addComment.loginuserprofilename);
            addComment.externalUser = true;
            Pagereference Pg = addComment.saveComment();
            addComment.getcaseComments();
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Agent-Partner'),userinfo.getUserid());
            /*Core_IPS_AddCommentController.getAuthr(Profiles.get('Data Ops'));         
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Data Migration')); 
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Integration'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('Partner'));
            Core_IPS_AddCommentController.getAuthr(Profiles.get('IPS Agent-Partner'));*/
            
            
            List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
             boolean disablep=addComment.getdisableprevious();
               boolean disableN=addComment.getdisbaleNext();    
               integer i= addComment.getTotal_size();
               integer j= addComment.getPageNumber();
               integer k= addComment.getTotalPages();
               k=addComment.count;
               addComment.next();
               addComment.previous();
              // addComment.sendEMail();
        }
     }
     
 //added by naresh related to the Test Coverage Story US41854 on 6/8/16
    public static testmethod void Core_IPS_AddCommentControllerTest6(){
      
        //create user record   
        //UserRole ur=[Select id,PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);  
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];  
        User portalAccountOwner1=new User(
        UserRoleId = portalRole.Id,
        username = 'newUser232323@yahoo.com',
        profileId =profile1.id,   
        email = 'ponneri1515@intel.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        Firstname='Bruce',   
        lastname='lastname1'
        );
        Database.insert(portalAccountOwner1);
        
        System.runAs ( portalAccountOwner1 ) {
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
         
          Core_IPS_Labels__c label13= new Core_IPS_Labels__c();
         label13.name='Comment Source - Customer';
         label13.value__c='Customer Portal';
         insert label13;
         
          Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
         label14.name='Comment Source - Email';
         label14.value__c='Email';
         insert label14;
        
         
            //Create account
            Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            OwnerId = portalAccountOwner1.Id    
            );
            Database.insert(portalAccount1);
            //Create contact
            Contact contact1 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia',
            LastName  = 'portalTestUser',
            Email='babux5x5@intel.com', 
            OwnerId = portalAccountOwner1.Id        
            );
            Database.insert(contact1);
            Profile p = [select id, name from Profile where name in ('IPS External Customer') limit 1]; 
            //create user record
            User user1=new User(
            //UserRoleId = portalRole.Id,
            username = 'newUser343434@yahoo.com',
            ContactId = contact1.Id,   
            profileId =p.id,   
            email = 'ponneri2525@intel.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            Firstname='BruceS',   
            lastname='lastname2'
            );
            Database.insert(user1);
            system.runAs(user1){
            Test.startTest();
            Case CS =  TestUtilities.getCase(); 
            insert CS;
            List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(1);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            casecomments.Core_IPS_Comment_Author_Type__c ='Customer';
            }
        insert lstcsecomment;
        
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.externalUser = true;
            addComment.showRecords();
            addComment.list_size=0;
            //addComment.selectedVisibilityOption.add('True');//commened as per sumukh suggestion.
            // addComment.selectedNoteTypeOption.add('True');
            Pagereference Pg = addComment.saveComment();
            //List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
            addComment.getcaseattDisable();
            addComment.getcaseintDisable();
            Test.stopTest();
            }
       }
    }
   //end 
   
    
/***************************************************************************************************
Method Name:  Core_IPS_getcaseComments_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5th June 2017
Description:  Testing with Case record for getcaseComments method with standard user
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput           05/06/2017                Created
****************************************************************************************************/
   
Public Static testmethod void Core_IPS_getcaseComments_Test() {
        createusers();
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
                   
         Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
         label12.name='Comment Source - Customer';
         label12.value__c='Customer Portal';
         insert label12;
         
        System.runAs(ListOfUser[0]){
        Case Cs =  TestUtilities.getCase(); 
         Account testAccount=TestUtilities.getAccount();
            insert testAccount;
             
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123456@testing.com.testsetup',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact;
            System.assertNotEquals(null, testAccount.id);
            cs.AccountId=testAccount.id;
            cs.contactid=testContact.id;
         
        insert Cs;
        // below line commented by Prem while inserting comment records system administrator while insert case with record type "CEP Case" and we didn't have picklist value expose for Core_Latest_Case_Comment_Type__c
        //INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, bad value for restricted picklist field: Private to Agents: [Core_Latest_Case_Comment_Type__c]
        /*List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            }
        insert lstcsecomment;*/
        
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
            List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
             boolean disablep=addComment.getdisableprevious();
               boolean disableN=addComment.getdisbaleNext();    
               integer i= addComment.getTotal_size();
               integer j= addComment.getPageNumber();
               integer k= addComment.getTotalPages();
               k=addComment.count;
               addComment.next();
               addComment.previous();
              // addComment.sendEMail();
             
        }
        
     }
     
/***************************************************************************************************
Method Name:  Core_IPS_getcaseComments_External_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 5th June 2017
Description:  Testing with Case record for getcaseComments method with IPS External Customer
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput           05/06/2017                Created
****************************************************************************************************/
     
    Public Static testmethod void Core_IPS_getcaseComments_External_Test() {
        user u1 = TestUtilities.getCustomerUser('IPS External Customer');
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
        
         Core_IPS_Labels__c label13= new Core_IPS_Labels__c();
         label13.name='Comment Source - Customer';
         label13.value__c='Customer Portal';
         insert label13;
         
          Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
         label14.name='Comment Source - Email';
         label14.value__c='Email';
         insert label14;
        
         
        system.runAs(u1){
        
        
        Case Cs =  TestUtilities.getCase(); 
        insert Cs;
        List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            casecomments.Core_IPS_Comment_Author_Type__c ='Customer';
            }
        insert lstcsecomment;
        
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
            List<Core_IPS_Case_Comments__c> commentsList  = addComment.getcaseComments();
            
            //Updated by Sandeep as per Sumukh 
            Core_IPS_AddCommentController addComment1 = new Core_IPS_AddCommentController(StndContr);
            addComment1.externalUser = true;
            addComment1.selectedVisibilityOption = new List<String>();
            addComment1.VisibilityOptions = new List<SelectOption>();
            addComment1.getexLoginedUser();
            List<Core_IPS_Case_Comments__c> commentsList1  = addComment1.getcaseComments();
            
            
            
        }
     }
     
/***************************************************************************************************
Method Name:  Core_IPS_AddCommentControllerTest1
Method Type: Test Method
Version     : 1.0 
Created Date: 4th April 2018
Description:  Testing with Case record for getcaseComments method 
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sugandha                   04/04/2018                Created
****************************************************************************************************/
    public static testmethod void Core_IPS_AddCommentControllerTest1(){
        createusers();
         
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
     
         System.runAs(ListOfUser[1]){
            Test.startTest();
            Case CS =  TestUtilities.getCase(); 
            Account testAccount=TestUtilities.getAccount();
            insert testAccount;
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test12345@testing.com.testsetup',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact;
            System.assertNotEquals(null, testAccount.id);
            cs.AccountId=testAccount.id;
            cs.contactid=testContact.id;
            cs.Core_IPS_Date_Time_Close_Pending__c = DateTime.Now();
            insert CS;
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController addComment = new Core_IPS_AddCommentController(StndContr);
            addComment.list_size=0;
            addComment.selectedRadioButton = 'Public to Customers'; 
            Pagereference Pg = addComment.saveComment();
            Test.stopTest();
        }
    }
    //end
    
/***************************************************************************************************
Method Name:  Core_IPS_AddCommentControllerTest2
Method Type: Test Method
Version     : 1.0 
Created Date: 5th April 2018
Description:  Method covers code for search and clearearch() methods in class
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aparna                   05/04/2018                Created
****************************************************************************************************/
    public static testmethod void Core_IPS_AddCommentControllerTest2(){
        createusers();
         
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
         
           Case CS =  TestUtilities.getCase(); 
            Account testAccount=TestUtilities.getAccount();
            insert testAccount;
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test12345@testing11.com.testsetup',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact;
             
            System.assertNotEquals(null, testAccount.id);
            cs.AccountId=testAccount.id;
            cs.contactid=testContact.id;
           
            insert CS;
           
     
         System.runAs(ListOfUser[0]){
            Test.startTest();
          
            //commented by sugandha
            /*List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            }
          insert lstcsecomment;*/
           
             
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',CS.id);
           
            ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
            
            Core_IPS_AddCommentController inst = new Core_IPS_AddCommentController(StndContr);
            inst.list_size=0;
            List<Core_IPS_Case_Comments__c> commentsList  = inst.getcaseComments();
            inst.searchText='TestString';
            inst.search();
            inst.clearSearch();
            
            Test.stopTest();
        }
    }
/***************************************************************************************************
Method Name:  Core_IPS_AddCommentControllerTest3
Method Type: Test Method
Version     : 1.0 
Created Date: 26th july 2018
Description:  Method covers code for search and clearearch() methods in class
Scenario for:  partner,customer
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Geetha Arkadu                   26/07/2018                Created
****************************************************************************************************/
    public static testmethod void Core_IPS_AddCommentControllerTest3(){
        createusers();
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
        
        Account portalAccount1;
        Contact contact1;
        Contact contact2;
        
        System.runAs(ListOfUser[0]) {           
        
            Database.insert(portalAccountOwner1);
            portalAccount1 = new Account(
                Name = 'newAcc2',
                BillingCity = 'folsom',
                BillingCountry = 'USA',
                BillingStreet = 'Creek Side Dr',
                OwnerId = portalAccountOwner1.Id 
            );       
            Database.insert(portalAccount1);
            //Create contact
            contact1 = new Contact(
                AccountId = portalAccount1.id,
                FirstName = 'portia',
                LastName  = 'portalTestUser',
                Email='babux5x5@intel.com'      
            );
            Database.insert(contact1);
            //Create contact 2
            contact2 = new Contact(
                AccountId = portalAccount1.id,
                FirstName = 'portia2',
                LastName  = 'portalTestUser2',
                Email='babux5x52@intel.com'      
            );
            Database.insert(contact2);
            
            Profile p = [select id, name from Profile where name in ('IPS External Customer') limit 1];
            //create user record
            User user1=new User(
                username = 'newUser343434@yahoo.com',
                ContactId = contact1.Id,   
                profileId =p.id,   
                email = 'ponneri2525@intel.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                Firstname='BruceS',   
                lastname='lastname2'
            );
            Database.insert(user1);
        
        }       
        
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
        Case CaseRecord=null;
        system.runAs(portalAccountOwner1){
            Test.startTest();
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_GEC_ReadOnly'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            
            CaseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject',
                Description = 'TestDescription'
            );
            Database.insert(CaseRecord);
            //Case CS =  TestUtilities.getCase();
            ApexPages.CurrentPage().getparameters().put('id',CaseRecord.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CaseRecord);
            Core_IPS_AddCommentController inst = new Core_IPS_AddCommentController(StndContr);
            inst.ExternalUser=true;
            inst.list_size=0;
            List<Core_IPS_Case_Comments__c> commentsList  = inst.getcaseComments();
            inst.searchText='TestString';
            inst.search();
            Test.stopTest();        
        }
        List<Profile> ProfileList = [select id, name from Profile where name = 'partner'];
        
        User userTest = new User(alias = 'test123', email='test123@inteltest.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',ProfileId=ProfileList[0].id,
                                 IsActive =true,
                                 ContactId = contact2.Id, username='tester@inteltest.com',PortalRole = 'Manager');
        insert userTest;
        System.runAs(userTest){
            PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
            insert new PermissionSetAssignment(AssigneeId = userTest.id, PermissionSetId = ps.Id );
            RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_GEC_ReadOnly'];
            ApexPages.currentPage().getParameters().put('rType',RT.Id);
            PageReference pageRef = Page.Core_IPS_AddComment;
            Test.setCurrentPage(pageRef);
            CaseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject1',
                Description = 'TestDescription1'     
            );
            Database.insert(CaseRecord);
            ApexPages.CurrentPage().getparameters().put('id',CaseRecord.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(CaseRecord);
            Core_IPS_AddCommentController inst = new Core_IPS_AddCommentController(StndContr);
            inst.ExternalUser=true;
            inst.list_size=0;
            inst.searchText='TestString';
            inst.search();
        }
        
    }
    
}