/***************************************************************************************************
Apex Class Name:  Core_IPS_CaseComment_EmailHandler_Test
Version     : 1.0 
Created Date: 30 Oct 2017
Function    : Email Handler test class for Case Comment creation through email 
Used By     : Core_IPS_AddCaseComment email service
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Gourav Anand                 10/11/2017              Created
* Karthick                     05/02/2018              Modified  
* Amritesh                     03/08/2017              Modified
* Karthick                     03/28/2017              Modified
****************************************************************************************************/

@isTest(seeAllData=false)
public class Core_IPS_CaseComment_EmailHandler_Test {
    
    @TestSetup
    static void SetupTestData() {
        
        List<Core_IPS_Feature_Toggle__c> lstFeatureToggle = new List<Core_IPS_Feature_Toggle__c>();
        
        Core_IPS_Feature_Toggle__c skyHighEOL =  new Core_IPS_Feature_Toggle__c();
        skyHighEOL.name= 'SkyHighEOL- RTF update for DM';
        skyHighEOL.Core_Category__c= 'Case and Case comment';
        skyHighEOL.Core_Feature_Enabled__c  = false;
        lstFeatureToggle.add(skyHighEOL);
        
        skyHighEOL =  new Core_IPS_Feature_Toggle__c();
        skyHighEOL.name= 'SkyHighEOL- RTF update for Integ User';
        skyHighEOL.Core_Category__c= 'Case and Case comment';
        skyHighEOL.Core_Feature_Enabled__c = false;
        lstFeatureToggle.add(skyHighEOL);
        
        skyHighEOL =  new Core_IPS_Feature_Toggle__c();
        skyHighEOL.name= 'LastCommentToCase';
        skyHighEOL.Core_Category__c= 'Case Comments';
        skyHighEOL.Core_Feature_Enabled__c = true;
        lstFeatureToggle.add(skyHighEOL);
                
        skyHighEOL =  new Core_IPS_Feature_Toggle__c();
        skyHighEOL.name= 'SkyHighCommentEncryption';
        skyHighEOL.Core_Category__c= 'CaseComment Encryption';
        skyHighEOL.Core_Feature_Enabled__c = true;
        lstFeatureToggle.add(skyHighEOL);
        
        insert lstFeatureToggle;
        
        List<Core_IPS_Labels__c> lstIPSLabel = new List<Core_IPS_Labels__c>();
        
        Core_IPS_Labels__c objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'PUBLIC_TO_CUSTOMERS';
        objlabel.value__c ='Public to Customers';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'PRIVATE_TO_AGENTS';
        objlabel.value__c ='Private to Agents';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'PRIVATE_TO_INTEL';
        objlabel.value__c ='Private to Intel';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'PRIVATE_TO_PARTNERS';
        objlabel.value__c ='Private to Partner';
        lstIPSLabel.add(objlabel); 
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'FAE';
        objlabel.value__c ='FAE';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'Agent';
        objlabel.value__c ='Agent';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'Customer';
        objlabel.value__c ='Customer';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'Partner';
        objlabel.value__c ='Partner';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'NO_PROCESSING';
        objlabel.value__c ='No Processing';
        lstIPSLabel.add(objlabel); 
        
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name='Backend Integration';
        objlabel.value__c='Backend Integration';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Data Migration';
        objlabel.value__c='Data Migration';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Partner - Agent';
        objlabel.value__c='Partner - Agent';
        lstIPSLabel.add(objlabel);
        
        //added by Sugandha
        objlabel = new Core_IPS_Labels__c ();
        objlabel.name = 'Partner - DFAE';
        objlabel.value__c ='Partner - DFAE';
        lstIPSLabel.add(objlabel);
        //end
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - B2B API';
        objlabel.value__c='B2B API';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - Backend System';
        objlabel.value__c='Backend System';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - Customer';
        objlabel.value__c='Customer Portal';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - Data Migration';
        objlabel.value__c='Data Migration';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - Email';
        objlabel.value__c='Email';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - Internal';
        objlabel.value__c='Internal Portal';
        lstIPSLabel.add(objlabel);
        
        objlabel = new Core_IPS_Labels__c();
        objlabel.name='Comment Source - N/A';
        objlabel.value__c=' N/A';
        lstIPSLabel.add(objlabel);
        
        insert lstIPSLabel;
        
        //added by Aayushi US198844
        List<Core_IPS_SkipEmail_Keywords__c> skipKeywordList = new List<Core_IPS_SkipEmail_Keywords__c>();
        
        Core_IPS_SkipEmail_Keywords__c skipKeyword1=new Core_IPS_SkipEmail_Keywords__c();
        skipKeyword1.name='Auto reply';
        skipKeyword1.Value__c='Auto reply';
        skipKeywordList.add(skipKeyword1); 
        
        Core_IPS_SkipEmail_Keywords__c skipKeyword2=new Core_IPS_SkipEmail_Keywords__c();
        skipKeyword2.name='Automatic reply:';
        skipKeyword2.Value__c='Automatic reply:';
        skipKeywordList.add(skipKeyword2); 
        
        insert skipKeywordList;
    }

    
    static User getExtCustomerUser(){
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        
        //User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User newUser;
         
        Map<String,ID> profiles = new Map<String,ID>();
        List<User> ListOfUser = new List<User>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB-Dual IPS')];
        
        UserRole usrRole = [select id from UserRole where name ='Admin'];
        System.debug('---User Role ::'+usrRole);
        
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(1);        
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');        
        insert ListOfUser; 
        
        System.runAs ( ListOfUser[0] ) {
            UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
            Profile p = [select Id,name from Profile where UserType in :customerUserTypes and Name= 'IPS External Customer' limit 1];
            
             // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            
             // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = ListOfUser.get(0).id;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
            } 
            insert ListOfContacts;
                        
            newUser = new User(
            
            profileId = p.id,
            username = 'XynewUser@yahoo.com',
            email = 'XynewUser@yahoo.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = ListOfContacts[0].id
            
              
            );
            insert newUser;  
        }
        return newUser;
    }

    
    static testMethod void testEmailServiceByExtUser() {
        test.startTest();
                        
        Map<String, Core_IPS_Feature_Toggle__c> mapFeatureEnabled = new Map<String, Core_IPS_Feature_Toggle__c>();
        mapFeatureEnabled = Core_IPS_Feature_Toggle__c.getAll();                
        System.debug('-----------#02 mapFeatureEnabled: ' +  mapFeatureEnabled);
              
        
        Map<String,ID> profiles = new Map<String,ID>();
        Profile userProfile = [select id, name from Profile where name ='IPS External Customer'];

        User usr = getExtCustomerUser();
        System.debug('--------------->test user:'+usr);

        List<case> caseList = new List<case>();
        caseList =  TestUtilities.getListOfCases(1); 
        caseList[0].OwnerId =usr.id;
        insert caseList;
        
        System.debug('-----case ::'+caseList[0]);
        System.debug('-----case record type ::'+caseList[0].recordTypeId);

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Case ca =  [select Id, status from Case limit 1];    

        String body = 'Hello , <br>';
        body += 'testing One of the following: <p>';
        body += '&emsp; 1.Email must be directed to only the IPS System email address.<br>';
        body += '&emsp; 2.Email replies involving Cases that are \\n closed will not be accepted.<br><br>';
        body += 'Thanks ';   
        //body += 'refId: '+ca.Id+' : Type-Pbl:ref';   
        // setup the data for the email
        email.subject = 'Case Created #00912834 Test Demo Account  -  test ['+caseList[0].Id+'x0]';
        email.fromname = usr.Alias;
        email.fromAddress = usr.Email;
        email.htmlBody = body;
        email.plainTextBody= body;
        email.toAddresses = new List<String>{'intel.premier.support@intel.com'};

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment');
        attachment.fileName = 'testImage007.jpg';
        attachment.mimeTypeSubType = 'image/jpeg';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        attachment.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<image testImage007.jpg@01D35F27.4FCFFB70>';
        attachment.headers[0]=header;    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        // call the email service class and test it with the data in the testMethod
        system.debug('--------------------------Usr:'+usr+':-:'+usr.Alias+';'+usr.IsActive);
        System.runAs(usr){ 
            Core_IPS_CaseComment_EmailHandler emailHandler = new Core_IPS_CaseComment_EmailHandler();
            emailHandler.handleInboundEmail(email, env);
        }
        
        test.stopTest();
    }
    
    
    
    static testMethod void testExceptionEmail() {
        test.startTest();
        
        
        Map<String, Core_IPS_Feature_Toggle__c> mapFeatureEnabled = new Map<String, Core_IPS_Feature_Toggle__c>();
        mapFeatureEnabled = Core_IPS_Feature_Toggle__c.getAll();                
        System.debug('-----------#02 mapFeatureEnabled: ' +  mapFeatureEnabled);
        
       
        Map<String,ID> profiles = new Map<String,ID>();
        List<User> ListOfUser = new List<User>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB-Dual IPS')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(2);
       
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        ListOfUser[1].ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
        
        insert ListOfUser;
        System.debug('-----list of test users'+ListOfUser);

        List<case> caseList = new List<case>();
        caseList =  TestUtilities.getListOfCases(1); 
        caseList[0].OwnerId = ListOfUser.get(1).Id;
        insert caseList;
        
        System.debug('-----case ::'+caseList[0]);
        System.debug('-----case record type ::'+caseList[0].recordTypeId);
        
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Case ca =  [select Id, status from Case limit 1];
        User usr = ListOfUser.get(0);    

        String body = 'Hello , <br>';
        body += 'testing One of the following: <p>';
        body += '&emsp; 1.Email must be directed to only the IPS System email address.<br>';
        body += '&emsp; 2.Email replies involving Cases that are \\n closed will not be accepted.<br><br>';
        body += 'Thanks ';   
        //body += 'refId: '+ca.Id+' : Type-Pbl:ref';   
        // setup the data for the email
        email.subject = 'Case Created #00912834 Test Demo Account  -  test ['+caseList[0].Id+'x0]';
        email.fromname = usr.Alias;
        email.fromAddress = usr.Email;
        email.htmlBody = body;
        email.plainTextBody= body;
        email.toAddresses = new List<String>{'intel.premier.support@intel.com'};

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment');
        attachment.fileName = 'testImage007.jpg';
        attachment.mimeTypeSubType = 'image/jpeg';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        attachment.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<image testImage007.jpg@01D35F27.4FCFFB70>';
        attachment.headers[0]=header;    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        // call the email service class and test it with the data in the testMethod
        system.debug('--------------------------Usr:'+usr+':-:'+usr.Alias+';'+usr.IsActive);
        System.runAs(usr){ 
            Core_IPS_CaseComment_EmailHandler emailHandler = new Core_IPS_CaseComment_EmailHandler();
            emailHandler.handleInboundEmail(email, env);
        }
        
        test.stopTest();
  
    }
    
    static testMethod void testByAgent() {
       test.startTest();
               
        Map<String, Core_IPS_Feature_Toggle__c> mapFeatureEnabled = new Map<String, Core_IPS_Feature_Toggle__c>();
        mapFeatureEnabled = Core_IPS_Feature_Toggle__c.getAll();                
        System.debug('-----------#02 mapFeatureEnabled: ' +  mapFeatureEnabled);
        
       
        Map<String,ID> profiles = new Map<String,ID>();
        List<User> ListOfUser = new List<User>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','IPS Agent')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        ListOfUser[1].ProfileID =  profiles.get('IPS Agent');
        
        insert ListOfUser;
        System.debug('-----list of test users'+ListOfUser);
        List<case> caseList = new List<case>();
        caseList =  TestUtilities.getListOfCases(1); 
        caseList[0].OwnerId = ListOfUser.get(1).Id;
        insert caseList;
        
        System.debug('-----case ::'+caseList[0]);
        System.debug('-----case record type ::'+caseList[0].recordTypeId);
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Case ca =  [select Id, status from Case limit 1];
        User usr = ListOfUser.get(1);    

        String body = 'Hello , <br>';
        body += 'testing One of the following: <p>';
        body += '&emsp; 1.Email must be directed to only the IPS System email address.<br>';
        body += '&emsp; 2.Email replies involving Cases that are \\n closed will not be accepted.<br><br>';
        body += 'Thanks ';   
        //body += 'refId: '+ca.Id+' : Type-Pbl:ref';   
        // setup the data for the email
        email.subject = 'Case Created #00912834 Test Demo Account  -  test ['+caseList[0].Id+'x0]';
        email.fromname = usr.Alias;
        email.fromAddress = usr.Email;
        email.htmlBody = body;
        email.plainTextBody= body;
        email.toAddresses = new List<String>{'intel.premier.support@intel.com'};

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment');
        attachment.fileName = 'testImage007.jpg';
        attachment.mimeTypeSubType = 'image/jpeg';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        attachment.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<image testImage007.jpg@01D35F27.4FCFFB70>';
        attachment.headers[0]=header;    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        // call the email service class and test it with the data in the testMethod
        system.debug('--------------------------Usr:'+usr+':-:'+usr.Alias+';'+usr.IsActive);
        System.runAs(usr){ 
            Core_IPS_CaseComment_EmailHandler emailHandler = new Core_IPS_CaseComment_EmailHandler();
            emailHandler.handleInboundEmail(email, env);
        }
        
        test.stopTest();
  
    }
    
    static testMethod void testByFAE() {
        test.startTest();
        //emailSetupData();
        
        Map<String, Core_IPS_Feature_Toggle__c> mapFeatureEnabled = new Map<String, Core_IPS_Feature_Toggle__c>();
        mapFeatureEnabled = Core_IPS_Feature_Toggle__c.getAll();                
        System.debug('-----------#02 mapFeatureEnabled: ' +  mapFeatureEnabled);
        
       
        Map<String,ID> profiles = new Map<String,ID>();
        List<User> ListOfUser = new List<User>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        ListOfUser[1].ProfileID =  profiles.get('Sales Rep-BB');
        
        insert ListOfUser;
        System.debug('-----list of test users'+ListOfUser);

        List<case> caseList = new List<case>();
        caseList =  TestUtilities.getListOfCases(1); 
        caseList[0].OwnerId = ListOfUser.get(1).Id;
        insert caseList;
        
        System.debug('-----case ::'+caseList[0]);
        System.debug('-----case record type ::'+caseList[0].recordTypeId);
        

        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Case ca =  [select Id, status from Case limit 1];
        User usr = ListOfUser.get(1);    

        String body = 'Hello , <br>';
        body += 'testing One of the following: <p>';
        body += '&emsp; 1.Email must be directed to only the IPS System email address.<br>';
        body += '&emsp; From: 2.Email replies involving Cases that are \\n closed will not be accepted.<br><br>';
        body += 'Thanks ';   
        //body += 'refId: '+ca.Id+' : Type-Pbl:ref';   
        // setup the data for the email
        email.subject = 'Case Created #00912834 Test Demo Account  -  test ['+caseList[0].Id+'x0]';
        email.fromname = usr.Alias;
        email.fromAddress = usr.Email;
        email.ccAddresses = new List<String>{usr.Email};
        //email.htmlBody = body;
        email.plainTextBody= body;
        email.toAddresses = new List<String>{'intel.premier.support@intel.com'};

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment');
        attachment.fileName = 'testImage007.jpg';
        attachment.mimeTypeSubType = 'image/jpeg';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        attachment.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<image testImage007.jpg@01D35F27.4FCFFB70>';
        attachment.headers[0]=header;    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        // call the email service class and test it with the data in the testMethod
        system.debug('--------------------------Usr:'+usr+':-:'+usr.Alias+';'+usr.IsActive);
        System.runAs(usr){ 
            Core_IPS_CaseComment_EmailHandler emailHandler = new Core_IPS_CaseComment_EmailHandler();
            emailHandler.handleInboundEmail(email, env);
        }
        
        test.stopTest();
  
    }
    
    static testMethod void testNoProcessing() {
        test.startTest();
        //emailSetupData();
        
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<User> ListOfUser = new List<User>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB-Dual IPS')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(2);
        //for(User Usr : ListOfUser){
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        ListOfUser[1].ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
        // }
        insert ListOfUser;
        System.debug('-----list of test users'+ListOfUser);

        List<case> caseList = new List<case>();
        caseList =  TestUtilities.getListOfCases(1); 
        caseList[0].OwnerId = ListOfUser.get(1).Id;
        insert caseList;
        
        System.debug('-----case ::'+caseList[0]);
        System.debug('-----case record type ::'+caseList[0].recordTypeId);
        

        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Case ca =  [select Id, status from Case limit 1];
        User usr = ListOfUser.get(0);    

        String body = 'Hello , <br>';
        body += 'testing One of the following: <p>';
        body += '&emsp; 1.Email must be directed to only the IPS System email address.<br>';
        body += '&emsp; 2.Email replies involving Cases that are \\n closed will not be accepted.<br><br>';
        body += 'Thanks ';   
        //body += 'refId: '+ca.Id+' : Type-Pbl:ref';   
        // setup the data for the email
        email.subject = 'Case Created #00912834 Test Demo Account  -  test ['+caseList[0].Id+'xx]';
        email.fromname = usr.Alias;
        email.fromAddress = usr.Email;
        email.htmlBody = body;
        email.plainTextBody= body;
        email.toAddresses = new List<String>{'intel.premier.support@intel.com','test@intel.com'};
        
        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment');
        attachment.fileName = 'testImage007.jpg';
        attachment.mimeTypeSubType = 'image/jpeg';
        Messaging.InboundEmail.Header header= new Messaging.InboundEmail.Header();
        attachment.headers=new Messaging.InboundEmail.Header[1];
        header.name='Content-ID'; header.value='<imagetestImage007.jpg@01D35F27.4FCFFB70>';
        attachment.headers[0]=header;    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        // call the email service class and test it with the data in the testMethod
        system.debug('--------------------------Usr:'+usr+':-:'+usr.Alias+';'+usr.IsActive);
        System.runAs(usr){ 
            Core_IPS_CaseComment_EmailHandler emailHandler = new Core_IPS_CaseComment_EmailHandler();
            emailHandler.handleInboundEmail(email, env);
        }
        
        test.stopTest();
  
    }
    
    static testMethod void testSkipEmail() {
        test.startTest();        
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<User> ListOfUser = new List<User>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB-Dual IPS')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        Map<String,ID> profileMap = new Map<String,ID>();
        List<Profile> proList = [select id, name from Profile where name='Partner' OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops' OR name='Partner' OR name='IPS Agent-Partner'];
        for(Profile prf : proList){
        profileMap.put(prf.name, prf.id);
        }
        system.debug('---profileMap ::'+ profileMap);
        
        ListOfUser = TestUtilities.getListOfUser(2);
        //for(User Usr : ListOfUser){
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        ListOfUser[1].ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
        // }
        insert ListOfUser;

        List<case> caseList = new List<case>();
        caseList =  TestUtilities.getListOfCases(1); 
        caseList[0].OwnerId = ListOfUser.get(1).Id;
        insert caseList;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        //Case ca =  [select Id, status from Case limit 1];
        User usr = ListOfUser.get(0);    

        String body = 'Hello , <br>';
        body += 'testing One of the following: <p>';
        body += '&emsp; 1.Email must be directed to only the IPS System email address.<br>';
        body += '&emsp; 2.Email replies involving Cases that are \\n closed will not be accepted.<br><br>';
        body += 'Thanks ';   
        //body += 'refId: '+ca.Id+' : Type-Pbl:ref';   
        // setup the data for the email
        email.subject = 'Automatic reply: Case Created #00912834 Test Demo Account  -  test ['+caseList[0].Id+'xx]';
        email.fromname = usr.Alias;
        email.fromAddress = usr.Email;
        email.htmlBody = body;
        email.plainTextBody= body;
        email.toAddresses = new List<String>{'intel.premier.support@intel.com'};
        
        // call the email service class and test it with the data in the testMethod
        system.debug('--------------------------Usr:'+usr+':-:'+usr.Alias+';'+usr.IsActive);
        System.runAs(usr) { 
            Core_IPS_CaseComment_EmailHandler emailHandler = new Core_IPS_CaseComment_EmailHandler();
            emailHandler.handleInboundEmail(email, env);
            Core_IPS_CaseComment_EmailHandler.getAuthr(profileMap.get('Partner'),usr.id);
            Core_IPS_CaseComment_EmailHandler.getAuthr(profileMap.get('Data Ops'),usr.id);         
            Core_IPS_CaseComment_EmailHandler.getAuthr(profileMap.get('IPS Data Migration'),usr.id); 
            Core_IPS_CaseComment_EmailHandler.getAuthr(profileMap.get('Integration'),usr.id);
            Core_IPS_CaseComment_EmailHandler.getAuthr(profileMap.get('Partner'),usr.id);
            Core_IPS_CaseComment_EmailHandler.getAuthr(profileMap.get('IPS Agent-Partner'),usr.id);
        }
        test.stopTest();  
    }
}