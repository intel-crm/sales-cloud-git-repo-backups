@isTest
public class core_IPS_PortalEdqController_test { 
    /*
public static testmethod void SubmitCaseRecordtest(){

Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
User usr = new User(LastName = 'LIVESTON1',
FirstName='JASON1',
Alias = 'jliv1',
Email = 'jason1.livesto@example.com',
Username = 'jason1.liveston@asdf.com',
ProfileId = profileId.id,
TimeZoneSidKey = 'GMT',
LanguageLocaleKey = 'en_US',
EmailEncodingKey = 'UTF-8',
LocaleSidKey = 'en_US'
);
insert usr;
Account newAccount = new Account (
name='XYZ',
Phone = '+49-12345',
BillingStreet = 'Am Tierpark 16',
BillingCity = 'Fremont',
BillingPostalCode = '54321',
BillingState = 'CA',
BillingCountry = 'USA'
);

insert newAccount;        
String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';

Contact cc = new Contact(  

FirstName='Joe',
LastName='Schmoe',
Email='Joe.Schmoe@test.de',
AccountId=newAccount.id,
MailingStreet=newAccount.BillingStreet,
//Core_IPS_Active__c=true,
Core_IPS_Email_Opt_Out__c=false,
MailingState = newAccount.BillingState,
MailingCity=newAccount.BillingCity,
Core_Country_Region__c='',
MailingPostalCode=newAccount.BillingPostalCode,
MailingCountry = newAccount.BillingCountry,
Phone=newAccount.Phone);
insert cc;

Core_IPS_Project__c pr = new Core_IPS_Project__c();
pr.name = 'test';
pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
pr.Core_IPS_EnableMemberasInterestedParties__c =True;
insert pr;   

Core_IPS_Intel_Support_Team__c steam = new Core_IPS_Intel_Support_Team__c();
steam.Core_IPS_Project__c = pr.id;   
steam.Status__c='Active';
steam.Core_IPS_User__c=usr.id;           
insert steam;

Map<Id,Core_IPS_Intel_Support_Team__c> mapTeam = new Map<Id,Core_IPS_Intel_Support_Team__c>();
// mapTeam.put(id,pr.id);  

List<Case> caselst = new List<Case>();

//Case cas = new Case();          
//cas.Core_IPS_Project_Case__c = pr.id;
//cas.status = 'open';   
//cas.AccountId=newAccount.Id;
//cas.Core_IPS_Country_Region__c='United States';
//cas.Core_Issue_Description__c='Hi Hello';
//caselst.add(cas);

case CaseRecord = TestUtilities.getCase();
CaseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
//CaseRecord.Core_IPS_Supported_Product__c = ListOfSupportedProduct[0].id;
//CaseRecord.AssetId = ListOfAssets[0].id ;
CaseRecord.status = 'open';  
CaseRecord.Core_IPS_Country_Region__c='United States'; 
CaseRecord.Core_Issue_Description__c='Hi Hello';
RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
CaseRecord.RecordTypeid = RT2.id ;
insert CaseRecord;

//insert cas;
PermissionSetAssignment Psa=new PermissionSetAssignment();
Test.startTest(); 
core_IPS_PortalEdqController.SubmitCaseRecord(CaseRecord , cc, edqData);
core_IPS_PortalEdqController.getcurrentuserprofile();
Test.StopTest();
}
*/    
    public static testmethod void getcurrentuserprofileTest1(){
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA'
        );
        insert newAccount;
        System.assert(newAccount.Id != null, 'Record not created');
        
        Contact cc = new contact();
        try{
            cc = new Contact(  
            FirstName='Joe',
            LastName='Schmoe',
            Email='Joe.Schmoe@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            //Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            Core_Country_Region__c='',
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
          insert cc;
          System.assert(cc.Id != null, 'Record not created');
        
        } catch(Exception e){}
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            contactId = cc.Id
                           );
        insert usr;
        System.assert(usr.Id != null, 'Record not created');
        
        String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
        
        
        
        Core_IPS_Project__c pr = new Core_IPS_Project__c();
        pr.name = 'test';
        pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
        pr.Core_IPS_EnableMemberasInterestedParties__c =True;
        insert pr;   
        System.assert(pr.Id != null, 'Record not created');
        
        Core_IPS_Intel_Support_Team__c steam = new Core_IPS_Intel_Support_Team__c();
        steam.Core_IPS_Project__c = pr.id;   
        steam.Status__c='Active';
        steam.Core_IPS_User__c=usr.id;           
        insert steam;
        System.assert(steam.Id != null, 'Record not created');
        
        Map<Id,Core_IPS_Intel_Support_Team__c> mapTeam = new Map<Id,Core_IPS_Intel_Support_Team__c>();
        // mapTeam.put(id,pr.id);  
        
        List<Case> caselst = new List<Case>();
        
        Case cas = new Case();          
        cas.Core_IPS_Project_Case__c = pr.id;
        cas.status = 'open';   
        cas.AccountId=newAccount.Id;
               cas.Core_IPS_Country_Region__c='United States';
        cas.Core_Issue_Description__c='Hi Hello';
        caselst.add(cas);
        PermissionSetAssignment Psa=new PermissionSetAssignment();
        //Test.startTest(); 
        //core_IPS_PortalEdqController.SubmitCaseRecord(cas, cc, edqData);
        system.runAs(usr) {
            core_IPS_PortalEdqController.getcurrentuserprofile();
        }
        //Test.StopTest();
    }
    
    public static testmethod void getcurrentuserprofileTest2(){
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA'
        );
        insert newAccount;  
        System.assert(newAccount.Id != null, 'Record not created');
        
        Contact cc = new contact();
        try{
            cc = new Contact( 
            FirstName='Joe',
            LastName='Schmoe',
            Email='Joe.Schmoe@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
            //Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            Core_Country_Region__c='',
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
          insert cc;
          System.assert(cc.Id != null, 'Record not created');
        
        } catch(Exception e){}
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS Agent-Partner' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston'+Crypto.getRandomLong()+'@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            contactId = cc.Id
                           );
        insert usr;
        System.assert(usr.Id != null, 'Record not created');
        
        String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
        
        
        
        Core_IPS_Project__c pr = new Core_IPS_Project__c();
        pr.name = 'test';
        pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
        pr.Core_IPS_EnableMemberasInterestedParties__c =True;
        insert pr;   
        System.assert(pr.Id != null, 'Record not created');
        
        Core_IPS_Intel_Support_Team__c steam = new Core_IPS_Intel_Support_Team__c();
        steam.Core_IPS_Project__c = pr.id;   
        steam.Status__c='Active';
        steam.Core_IPS_User__c=usr.id;           
        insert steam;
        System.assert(steam.Id != null, 'Record not created');
        
        Map<Id,Core_IPS_Intel_Support_Team__c> mapTeam = new Map<Id,Core_IPS_Intel_Support_Team__c>();
        // mapTeam.put(id,pr.id);  
        
        List<Case> caselst = new List<Case>();
        
        Case cas = new Case();          
        cas.Core_IPS_Project_Case__c = pr.id;
        cas.status = 'open';   
        cas.AccountId=newAccount.Id;
        cas.Core_IPS_Country_Region__c='United States';
        cas.Core_Issue_Description__c='Hi Hello';
        caselst.add(cas);
        PermissionSetAssignment Psa=new PermissionSetAssignment();
        //Test.startTest(); 
        //core_IPS_PortalEdqController.SubmitCaseRecord(cas, cc, edqData);
        system.runAs(usr) {
            core_IPS_PortalEdqController.getcurrentuserprofile();
        }
        //Test.StopTest();
    }
    
    @isTest
    private static void displayProductVariant() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));  
        System.runAs(ListOfUser.get(0)){
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            Core_IPS_CaseCreateLWCController.getProjectList(ListOfContacts[0].Id);
            Core_IPS_CaseCreateLWCController.getProjectList(UserInfo.getUserId());
            
            List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(1);
            ListOfFlatProductHierarchy[0].Core_Unique_ID__c  =';75025;128758;123707;123704;94489';
            insert ListOfFlatProductHierarchy;
            System.assert(ListOfFlatProductHierarchy[0].Id != null, 'Record not created');
        
            list<Asset> AssetList = TestUtilities.getAssets(ListOfAccounts, 1);
            list<Core_IPS_Supported_Product__c> sps = new list<Core_IPS_Supported_Product__c>();    
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                //asst.Core_Product_EPM_ID__c = '75025';
                sps.add(new  Core_IPS_Supported_Product__c(id=Asst.core_supported_product__c, Core_IPS_Is_Show_Variant__c = true, Core_Product_EPM_ID__c = '75025'));
                // Asst.Core_Product_EPM_ID__c = ListOfFlatProductHierarchy[0].Core_Unique_ID__c;
            }
            update  sps;  
            update AssetList;    
            //update AssetList;
            Test.startTest();
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
        
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            System.assert(org.Id != null, 'Record not created');
        
            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text Area';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            System.assert(lstparQues[0].Id != null, 'Record not created');
            
            List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
            question.isVisible=false;
            question.type='Text';
            question.questionId=parQues1.id;
            question.sPlaceHolder=null;
            question.required=true;
            question.selectedValue='test';
            
            Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
            question4.type='Text';
            question4.questionId=parQues1.id;
            question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
            
            
            Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
            question1.type='Text Area';
            question1.questionId=parQues1.id;
            question1.tPlaceHolder='';
            question4.required=true;
            
            Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
            question5.type='Text Area';
            question5.questionId=parQues1.id;
            question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
            
            
            Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
            question2.type='Picklist';
            question2.questionId=parQues1.id;
            question2.sPlaceHolder=null;
            
            Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
            question3.type='Multiselect Picklist';
            question3.questionId=parQues1.id;
            question3.sPlaceHolder=null;
            
            lstquestion.add(question);
            lstquestion.add(question1);
            lstquestion.add(question2);
            lstquestion.add(question3);
            lstquestion.add(question4);
            lstquestion.add(question5);
            //Insert lstquestion;
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Sales_Visible_Flag__c = False;
            ListOfProducts.get(0).Core_Hierarchy_ID__c = '59';
            ListOfProducts.get(0).Core_Unique_ID__c = 'L5 Id '+1;
            insert ListOfProducts;
            System.assert(ListOfProducts[0].Id != null, 'Record not created');
            
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg[0].Id != null, 'Record not created');
            
            List<Core_Flat_Product_Hierarchy__c> flh = TestUtilities.getListOfFlatProductHierarchy(1);
            insert flh;
            System.assert(flh[0].Id != null, 'Record not created');
            List<Core_IPS_Supported_Product__c>ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
            ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].Id != null, 'Record not created');
            
            List<asset> ListOfAssets = TestUtilities.getAssetList(1);
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
            insert ListOfAssets;
            System.assert(ListOfAssets[0].Id != null, 'Record not created');
            
            case CaseRecord = TestUtilities.getCase();
            CaseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
            CaseRecord.Core_IPS_Supported_Product__c = ListOfSupportedProduct[0].id;
            CaseRecord.AssetId = ListOfAssets[0].id ;
            CaseRecord.Core_IPS_Country_Region__c='Iran';
            CaseRecord.Core_Issue_Description__c='Hi Hello';
            CaseRecord.Status = 'open';
           	RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            CaseRecord.RecordTypeid = RT2.id ;
             //Added by Sowmya - Start - 24/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        	CaseRecord.ContactId = ListOfContacts[0].Id;
            //Sowmya - End - 24/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        	
            insert CaseRecord;
			System.assert(CaseRecord.Id != null, 'Record not created');  
            
            Core_IPS_Question__c csa = TestUtilities.getCoreQuestion();
            csa.Core_IPS_Datatype__c = 'Text Area';
            insert csa;
            System.assert(csa.Id != null, 'Record not created');  

            Core_IPS_Question__c csa1 = TestUtilities.getCoreQuestion();
            csa1.Core_IPS_Datatype__c = 'PickList';
            insert csa1;
            System.assert(csa1.Id != null, 'Record not created');  

            Core_IPS_Question__c csa2 = TestUtilities.getCoreQuestion();
            csa2.Core_IPS_Parent_Question__c = csa1.Id;
            insert csa2;
            System.assert(csa2.Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars.get(0).Core_IPS_Question__c = csa.Id;
            insert envVars;
            System.assert(envVars[0].Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars2 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars2.get(0).Core_IPS_Question__c = csa1.Id;
            insert envVars2;
            System.assert(envVars2[0].Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars3 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars3.get(0).Core_IPS_Question__c = csa2.Id;
            insert envVars3;
            System.assert(envVars3[0].Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_Text',Value__c='Text');
            insert ipsLabel1;
            System.assert(ipsLabel1.Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Core_IPS_Picklist',Value__c='PickList');
            insert ipsLabel2;
            System.assert(ipsLabel2.Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_TextArea',Value__c='Text Area');
            insert ipsLabel3;
            System.assert(ipsLabel3.Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Core_IPS_Multi_Select',Value__c='Multiselect Picklist');
            insert ipsLabel4;
            System.assert(ipsLabel4.Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars1 = [Select Id,Core_IPS_Question__r.Core_IPS_Parent_Question__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__c,Core_required__c,Core_Agent_Only__c,Core_IPS_Question__r.Core_IPS_Datatype__c From Core_IPS_Assigned_Environment_Variables__c];
            String chlidId = csa2.Id;
            String edq = JSON.serialize(lstquestion);
            List<Core_IPS_Answer__c> answer = TestUtilities.getCoreAnswers(1);
            answer.get(0).Core_IPS_Question__c = csa.Id;
            insert answer;
            System.assert(answer[0].Id != null, 'Record not created');  

            List<Core_IPS_Response__c> res = TestUtilities.getCoreResponseRecords(1);
            res.get(0).Core_IPS_Question_Master__c = csa.Id;
            res.get(0).Core_IPS_Answer_Master__c = answer.get(0).Id;
            res.get(0).Core_IPS_Case__c = CaseRecord.Id;
            insert res;
            System.assert(res[0].Id != null, 'Record not created');  

            List<Core_IPS_Master_Issue_Category__c> master = TestUtilities.getListOfCoreMastIssCategory(1);
            master.get(0).Core_Type__c = 'Case Category';
            insert master;
            System.assert(master[0].Id != null, 'Record not created');  

            Core_IPS_Product_Issue_Category__c cat = TestUtilities.getCaseCategories();
            insert cat;
            System.assert(cat.Id != null, 'Record not created');  

            Core_IPS_Product_Issue_Category__c cat1 = TestUtilities.getCaseCategories(); 
            cat1.Core_Product_Issue_Category__c = cat.Id;
            cat1.Core_Issue_Sub_Category_Name__c = master.get(0).Id; 
            insert cat1;
            System.assert(cat1.Id != null, 'Record not created');  

            String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
            try{
                Core_IPS_PortalEdqController.SubmitCaseRecord(CaseRecord,ListOfContacts.get(0),edqData);
            }catch(Exception e ){
            }
            Test.stopTest();
        }
    }
    
    /* Name: Shobhit Srivastav
     * Last Modified date: 23/01/2023
     * Changes: Added Method to cover embargoed country with state logic.
     */
    
    @isTest
    private static void displayProductVariant2() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));  
        System.runAs(ListOfUser.get(0)){
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');  

            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');  

            Core_IPS_CaseCreateLWCController.getProjectList(ListOfContacts[0].Id);
            Core_IPS_CaseCreateLWCController.getProjectList(UserInfo.getUserId());
            
            List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(1);
            ListOfFlatProductHierarchy[0].Core_Unique_ID__c  =';75025;128758;123707;123704;94489';
            insert ListOfFlatProductHierarchy;
            System.assert(ListOfFlatProductHierarchy[0].Id != null, 'Record not created');  

            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssets(ListOfAccounts, 1);
            list<Core_IPS_Supported_Product__c> sps = new list<Core_IPS_Supported_Product__c>();    
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                //asst.Core_Product_EPM_ID__c = '75025';
                sps.add(new  Core_IPS_Supported_Product__c(id=Asst.core_supported_product__c, Core_IPS_Is_Show_Variant__c = true, Core_Product_EPM_ID__c = '75025'));
                // Asst.Core_Product_EPM_ID__c = ListOfFlatProductHierarchy[0].Core_Unique_ID__c;
            }
            update  sps;  
            update AssetList;    
            //update AssetList;
            Test.startTest();
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');  

            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            System.assert(org.Id != null, 'Record not created');  

            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text Area';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            System.assert(lstparQues[0].Id != null, 'Record not created');  

            List<Core_IPS_EnvironmentDetailQuestion> lstquestion = new List<Core_IPS_EnvironmentDetailQuestion>();
            Core_IPS_EnvironmentDetailQuestion question = new Core_IPS_EnvironmentDetailQuestion();
            question.isVisible=false;
            question.type='Text';
            question.questionId=parQues1.id;
            question.sPlaceHolder=null;
            question.required=true;
            question.selectedValue='test';
            
            Core_IPS_EnvironmentDetailQuestion question4 = new Core_IPS_EnvironmentDetailQuestion();
            question4.type='Text';
            question4.questionId=parQues1.id;
            question4.sPlaceHolder='Testinggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
            
            
            Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
            question1.type='Text Area';
            question1.questionId=parQues1.id;
            question1.tPlaceHolder='';
            question4.required=true;
            
            Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
            question5.type='Text Area';
            question5.questionId=parQues1.id;
            question5.tPlaceHolder='Testingggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg';
            
            
            Core_IPS_EnvironmentDetailQuestion question2 = new Core_IPS_EnvironmentDetailQuestion();
            question2.type='Picklist';
            question2.questionId=parQues1.id;
            question2.sPlaceHolder=null;
            
            Core_IPS_EnvironmentDetailQuestion question3 = new Core_IPS_EnvironmentDetailQuestion();
            question3.type='Multiselect Picklist';
            question3.questionId=parQues1.id;
            question3.sPlaceHolder=null;
            
            lstquestion.add(question);
            lstquestion.add(question1);
            lstquestion.add(question2);
            lstquestion.add(question3);
            lstquestion.add(question4);
            lstquestion.add(question5);
            //Insert lstquestion;
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
            ListOfProducts.get(0).Core_Sales_Visible_Flag__c = False;
            ListOfProducts.get(0).Core_Hierarchy_ID__c = '59';
            ListOfProducts.get(0).Core_Unique_ID__c = 'L5 Id '+1;
            insert ListOfProducts;
            System.assert(ListOfProducts[0].Id != null, 'Record not created');  

            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg[0].Id != null, 'Record not created');  

            List<Core_Flat_Product_Hierarchy__c> flh = TestUtilities.getListOfFlatProductHierarchy(1);
            insert flh;
            System.assert(flh[0].Id != null, 'Record not created');  

            List<Core_IPS_Supported_Product__c>ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
            ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].Id != null, 'Record not created');  

            List<asset> ListOfAssets = TestUtilities.getAssetList(1);
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
            insert ListOfAssets;
            System.assert(ListOfAssets[0].Id != null, 'Record not created');  

            case CaseRecord = TestUtilities.getCase();
            CaseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
            CaseRecord.Core_IPS_Supported_Product__c = ListOfSupportedProduct[0].id;
            CaseRecord.AssetId = ListOfAssets[0].id ;
            CaseRecord.Core_IPS_Country_Region__c='Ukraine';
            CaseRecord.Core_IPS_Embargoed_State__c = 'Crimea';
            CaseRecord.Core_Issue_Description__c='Hi Hello';
            CaseRecord.Status = 'open';
            RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            CaseRecord.RecordTypeid = RT2.id ;
            insert CaseRecord;
            System.assert(CaseRecord.Id != null, 'Record not created');  

            Core_IPS_Question__c csa = TestUtilities.getCoreQuestion();
            csa.Core_IPS_Datatype__c = 'Text Area';
            insert csa;
            System.assert(csa.Id != null, 'Record not created');  

            Core_IPS_Question__c csa1 = TestUtilities.getCoreQuestion();
            csa1.Core_IPS_Datatype__c = 'PickList';
            insert csa1;
            System.assert(csa1.Id != null, 'Record not created');  

            Core_IPS_Question__c csa2 = TestUtilities.getCoreQuestion();
            csa2.Core_IPS_Parent_Question__c = csa1.Id;
            insert csa2;
            System.assert(csa2.Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars.get(0).Core_IPS_Question__c = csa.Id;
            insert envVars;
            System.assert(envVars[0].Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars2 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars2.get(0).Core_IPS_Question__c = csa1.Id;
            insert envVars2;
            System.assert(envVars2[0].Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars3 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars3.get(0).Core_IPS_Question__c = csa2.Id;
            insert envVars3;
            System.assert(envVars3[0].Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_Text',Value__c='Text');
            insert ipsLabel1;
            System.assert(ipsLabel1.Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Core_IPS_Picklist',Value__c='PickList');
            insert ipsLabel2;
            System.assert(ipsLabel2.Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_TextArea',Value__c='Text Area');
            insert ipsLabel3;
            System.assert(ipsLabel3.Id != null, 'Record not created');  

            Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Core_IPS_Multi_Select',Value__c='Multiselect Picklist');
            insert ipsLabel4;
            System.assert(ipsLabel4.Id != null, 'Record not created');  

            List<Core_IPS_Assigned_Environment_Variables__c> envVars1 = [Select Id,Core_IPS_Question__r.Core_IPS_Parent_Question__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__c,Core_required__c,Core_Agent_Only__c,Core_IPS_Question__r.Core_IPS_Datatype__c From Core_IPS_Assigned_Environment_Variables__c];
            String chlidId = csa2.Id;
            String edq = JSON.serialize(lstquestion);
            List<Core_IPS_Answer__c> answer = TestUtilities.getCoreAnswers(1);
            answer.get(0).Core_IPS_Question__c = csa.Id;
            insert answer;
            System.assert(answer[0].Id != null, 'Record not created');  

            List<Core_IPS_Response__c> res = TestUtilities.getCoreResponseRecords(1);
            res.get(0).Core_IPS_Question_Master__c = csa.Id;
            res.get(0).Core_IPS_Answer_Master__c = answer.get(0).Id;
            res.get(0).Core_IPS_Case__c = CaseRecord.Id;
            insert res;
            System.assert(res[0].Id != null, 'Record not created');  

            
            List<Core_IPS_Master_Issue_Category__c> master = TestUtilities.getListOfCoreMastIssCategory(1);
            master.get(0).Core_Type__c = 'Case Category';
            insert master;
            System.assert(master[0].Id != null, 'Record not created');  

            Core_IPS_Product_Issue_Category__c cat = TestUtilities.getCaseCategories();
            insert cat;
            System.assert(cat.Id != null, 'Record not created');  

            Core_IPS_Product_Issue_Category__c cat1 = TestUtilities.getCaseCategories(); 
            cat1.Core_Product_Issue_Category__c = cat.Id;
            cat1.Core_Issue_Sub_Category_Name__c = master.get(0).Id; 
            insert cat1;
            System.assert(cat1.Id != null, 'Record not created');  

            String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
            try{
                Core_IPS_PortalEdqController.SubmitCaseRecord(CaseRecord,ListOfContacts.get(0),edqData);
            }catch(Exception e ){
            }
            Test.stopTest();
        }
    }
    
    
}