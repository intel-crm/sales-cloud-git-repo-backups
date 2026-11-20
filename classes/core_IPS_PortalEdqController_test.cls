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
            BillingCountry = 'USA',
            recordtypeid = [select id,name from recordtype where name = 'Intel Account' limit 1][0].id
        );
        insert newAccount;  
        
       Contact cc = new Contact(  
            FirstName='Joe',
            LastName='Schmoe',
            Email='Joe.Schmoe@test.de',
            AccountId=newAccount.id,
            MailingStreet=newAccount.BillingStreet,
           // Core_IPS_Active__c=true,
            Core_IPS_Email_Opt_Out__c=false,
            MailingState = newAccount.BillingState,
            MailingCity=newAccount.BillingCity,
            Core_Country_Region__c='',
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        system.runas([Select id from user where Id =: userInfo.getUserId()][0]){
        insert cc;
        }
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS External Customer' LIMIT 1];
        
        /*User usr = new User(LastName = 'LIVESTON1',
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
        insert usr;*/
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
      List<user> listOfUser = TestUtilities.getListOfUser(2);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insert listOfUser;
        user usr = listOfUser[0];
        String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
        
        
        
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
            recordtypeid = [select id,name from recordtype where name = 'Intel Account' limit 1][0].id,
            BillingCountry = 'USA'
        );
        insert newAccount;  
        
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
        system.runas([select id from user where Id =: userInfo.getUserId()][0]){
        insert cc;
        }
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IPS Agent-Partner' LIMIT 1];
        
       /* User usr = new User(LastName = 'LIVESTON1',
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
        insert usr;*/
         Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        List<user> listOfUser = TestUtilities.getListOfUser(2);
        for(User usr : listOfUser){
            usr.ProfileID =  profiles.get('System Administrator');
        }
        insert listOfUser;
        user usr = listOfUser[0];
        
        String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
        
        
        
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
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            
            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text Area';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            
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
            question4.sPlaceHolder='Testing';
            
            
            Core_IPS_EnvironmentDetailQuestion question1 = new Core_IPS_EnvironmentDetailQuestion();
            question1.type='Text Area';
            question1.questionId=parQues1.id;
            question1.tPlaceHolder='';
            question4.required=true;
            
            Core_IPS_EnvironmentDetailQuestion question5 = new Core_IPS_EnvironmentDetailQuestion();
            question5.type='Text Area';
            question5.questionId=parQues1.id;
            question5.tPlaceHolder='Testing';
            
            
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
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert ListOfSupportOrg;
            List<Core_Flat_Product_Hierarchy__c> flh = TestUtilities.getListOfFlatProductHierarchy(1);
            insert flh;
            List<Core_IPS_Supported_Product__c>ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
            ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            insert ListOfSupportedProduct;
            
            List<asset> ListOfAssets = TestUtilities.getAssetList(1);
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
            insert ListOfAssets;
            
            case CaseRecord = TestUtilities.getCase();
            CaseRecord.Core_IPS_Partner_Sup_Owner__c =  UserInfo.getUserId();
            CaseRecord.Core_IPS_Supported_Product__c = ListOfSupportedProduct[0].id;
            CaseRecord.AssetId = ListOfAssets[0].id ;
            CaseRecord.Core_IPS_Country_Region__c='Iran';
            CaseRecord.Core_Issue_Description__c='Hi Hello';
            CaseRecord.Status = 'open';
            RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
            CaseRecord.RecordTypeid = RT2.id ;
            insert CaseRecord;
            
            Core_IPS_Question__c csa = TestUtilities.getCoreQuestion();
            csa.Core_IPS_Datatype__c = 'Text Area';
            insert csa;
            Core_IPS_Question__c csa1 = TestUtilities.getCoreQuestion();
            csa1.Core_IPS_Datatype__c = 'PickList';
            insert csa1;
            Core_IPS_Question__c csa2 = TestUtilities.getCoreQuestion();
            csa2.Core_IPS_Parent_Question__c = csa1.Id;
            insert csa2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars.get(0).Core_IPS_Question__c = csa.Id;
            insert envVars;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars2 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars2.get(0).Core_IPS_Question__c = csa1.Id;
            insert envVars2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars3 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars3.get(0).Core_IPS_Question__c = csa2.Id;
            insert envVars3;
            Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_Text',Value__c='Text');
            insert ipsLabel1;
            Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Core_IPS_Picklist',Value__c='PickList');
            insert ipsLabel2;
            Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_TextArea',Value__c='Text Area');
            insert ipsLabel3;
            Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Core_IPS_Multi_Select',Value__c='Multiselect Picklist');
            insert ipsLabel4;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars1 = [Select Id,Core_IPS_Question__r.Core_IPS_Parent_Question__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__c,Core_required__c,Core_Agent_Only__c,Core_IPS_Question__r.Core_IPS_Datatype__c From Core_IPS_Assigned_Environment_Variables__c];
            String chlidId = csa2.Id;
            String edq = JSON.serialize(lstquestion);
            List<Core_IPS_Answer__c> answer = TestUtilities.getCoreAnswers(1);
            answer.get(0).Core_IPS_Question__c = csa.Id;
            insert answer;
            List<Core_IPS_Response__c> res = TestUtilities.getCoreResponseRecords(1);
            res.get(0).Core_IPS_Question_Master__c = csa.Id;
            res.get(0).Core_IPS_Answer_Master__c = answer.get(0).Id;
            res.get(0).Core_IPS_Case__c = CaseRecord.Id;
            insert res;
            
            List<Core_IPS_Master_Issue_Category__c> master = TestUtilities.getListOfCoreMastIssCategory(1);
            master.get(0).Core_Type__c = 'Case Category';
            insert master;
            Core_IPS_Product_Issue_Category__c cat = TestUtilities.getCaseCategories();
            insert cat;
            Core_IPS_Product_Issue_Category__c cat1 = TestUtilities.getCaseCategories(); 
            cat1.Core_Product_Issue_Category__c = cat.Id;
            cat1.Core_Issue_Sub_Category_Name__c = master.get(0).Id; 
            insert cat1;
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
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c ='test';
            org.Core_Organization_Description__c ='test';
            insert org;
            
            List<Core_IPS_Question__c> lstparQues = new List<Core_IPS_Question__c>(); 
            Core_IPS_Question__c parQues1 = new Core_IPS_Question__c();       
            //parQues.recordtypeid = edqRecordTypeId;
            parQues1.Core_IPS_Question__c = 'Test Parent Question';
            parQues1.Core_IPS_Datatype__c = 'Text Area';
            parQues1.Core_IPS_Status__c = 'Active';
            parQues1.Core_IPS_Product_Organization__c = Org.id;
            lstparQues.add(parQues1);
            insert lstparQues;
            
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
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
            insert ListOfSupportOrg;
            List<Core_Flat_Product_Hierarchy__c> flh = TestUtilities.getListOfFlatProductHierarchy(1);
            insert flh;
            List<Core_IPS_Supported_Product__c>ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
            ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            insert ListOfSupportedProduct;
            
            List<asset> ListOfAssets = TestUtilities.getAssetList(1);
            //ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
            insert ListOfAssets;
            
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
            
            Core_IPS_Question__c csa = TestUtilities.getCoreQuestion();
            csa.Core_IPS_Datatype__c = 'Text Area';
            insert csa;
            Core_IPS_Question__c csa1 = TestUtilities.getCoreQuestion();
            csa1.Core_IPS_Datatype__c = 'PickList';
            insert csa1;
            Core_IPS_Question__c csa2 = TestUtilities.getCoreQuestion();
            csa2.Core_IPS_Parent_Question__c = csa1.Id;
            insert csa2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars.get(0).Core_IPS_Question__c = csa.Id;
            insert envVars;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars2 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars2.get(0).Core_IPS_Question__c = csa1.Id;
            insert envVars2;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars3 = TestUtilities.getListOfEnvDetailsOperational(1);
            envVars3.get(0).Core_IPS_Question__c = csa2.Id;
            insert envVars3;
            Core_IPS_Labels__c ipsLabel1 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_Text',Value__c='Text');
            insert ipsLabel1;
            Core_IPS_Labels__c ipsLabel2 = new Core_IPS_Labels__c(Name='Core_IPS_Picklist',Value__c='PickList');
            insert ipsLabel2;
            Core_IPS_Labels__c ipsLabel3 = new Core_IPS_Labels__c(Name='Core_IPS_Datatype_TextArea',Value__c='Text Area');
            insert ipsLabel3;
            Core_IPS_Labels__c ipsLabel4 = new Core_IPS_Labels__c(Name='Core_IPS_Multi_Select',Value__c='Multiselect Picklist');
            insert ipsLabel4;
            List<Core_IPS_Assigned_Environment_Variables__c> envVars1 = [Select Id,Core_IPS_Question__r.Core_IPS_Parent_Question__c,Core_IPS_Question__r.Core_IPS_Question__c,Core_IPS_Question__c,Core_required__c,Core_Agent_Only__c,Core_IPS_Question__r.Core_IPS_Datatype__c From Core_IPS_Assigned_Environment_Variables__c];
            String chlidId = csa2.Id;
            String edq = JSON.serialize(lstquestion);
            List<Core_IPS_Answer__c> answer = TestUtilities.getCoreAnswers(1);
            answer.get(0).Core_IPS_Question__c = csa.Id;
            insert answer;
            List<Core_IPS_Response__c> res = TestUtilities.getCoreResponseRecords(1);
            res.get(0).Core_IPS_Question_Master__c = csa.Id;
            res.get(0).Core_IPS_Answer_Master__c = answer.get(0).Id;
            res.get(0).Core_IPS_Case__c = CaseRecord.Id;
            insert res;
            
            List<Core_IPS_Master_Issue_Category__c> master = TestUtilities.getListOfCoreMastIssCategory(1);
            master.get(0).Core_Type__c = 'Case Category';
            insert master;
            Core_IPS_Product_Issue_Category__c cat = TestUtilities.getCaseCategories();
            insert cat;
            Core_IPS_Product_Issue_Category__c cat1 = TestUtilities.getCaseCategories(); 
            cat1.Core_Product_Issue_Category__c = cat.Id;
            cat1.Core_Issue_Sub_Category_Name__c = master.get(0).Id; 
            insert cat1;
            String edqData = '[{"edq":[{"qquestion":"a2x3F0000008linQAA","llabel":"Review Test","vvalue":"test","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000009Kg1QAE","llabel":"Which is working system?","vvalue":"Window System","rrequired":false,"ttype":"Text","val":true}]},{"edq":[{"qquestion":"a2x3F0000003ZcVQAU","llabel":"Type long text area question for Inv Engine","vvalue":"Long text answer I Eng","rrequired":false,"ttype":"Text Area","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfrQAE","llabel":"What is picklist IEng?","vvalue":"a2w3F0000000r3UQAQ","rrequired":false,"ttype":"Picklist","val":true}]},{"edq":[{"qquestion":"a2x3F0000009KfmQAE","llabel":"What are multiselect processors IE?","vvalue":"a2w3F0000000r3oQAA","rrequired":false,"ttype":"Multiselect Picklist","val":true}]}]';
            try{
                Core_IPS_PortalEdqController.SubmitCaseRecord(CaseRecord,ListOfContacts.get(0),edqData);
            }catch(Exception e ){
            }
            Test.stopTest();
        }
    }
    
    
}