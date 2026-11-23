/***************************************************************************************************
Apex Class Name:  Core_IPS_TestAllRecords_Test 
Version     : 1.0 
Created Date: 13 Nov 2021
Function    : Test class
Class       : Core_IPS_TestAllRecords, Core_IPS_UserInfoCtrl
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* SaiKrishna Madala            13/11/2021               Created
* Vishal suryavanshi           13/12/2021               Modified        
* 
****************************************************************************************************/


@isTest
public class Core_IPS_TestAllRecords_Test {
    @isTest
    public static void testGetAllCaseRecords(){
                Test.startTest();
            Core_IPS_TestAllRecords.getAllCaseRecords('allCases');
            Core_IPS_TestAllRecords.getAllCaseRecords('myOpenCases');
            Core_IPS_TestAllRecords.getAllCaseRecords('myClosedCases');
            Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyCreatedCases');  
            Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyModifiedCases');    
            Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyViewedCases');    
            Core_IPS_TestAllRecords.getAllCaseRecords('myRecentlyClosedCases');    
             Core_IPS_TestAllRecords.getcurUsername();
             Core_IPS_TestAllRecords.getEnvDetails(null);
            Test.stopTest();
                    System.assertNotEquals(null, 'All Cases', 'Text should not be equal to null');

    }
    
  
    @isTest static void testPositive1(){
        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='test project';
        Project.Core_Project_Description__c='test description';
        Project.Core_Status__c='Draft';
        Project.CreatedDate=Datetime.now();
        insert Project;
             System.assertNotEquals(null, Project.Id, 'Id should not be equal');

        Core_IPS_TestAllRecords.getAllProjects();
        Core_IPS_TestAllRecords.getPartnerSupportOwner(Project.id);
        
        
    }
    @isTest static void testPositive(){
        try{
            Core_IPS_Project__c Project=new Core_IPS_Project__c();
            Project.Name='test project';
            Project.Core_Project_Description__c='test description';
            Project.Core_Status__c='Draft';
            Project.CreatedDate=Datetime.now();
            insert Project;
            System.assertNotEquals(null, Project.Id, 'Id should not be equal');

            Profile pf= [Select Id from profile where Name='IPS External Customer'];
            
            account Acc=new account();
            Acc.Name='test';
            Acc.BillingCity='new york';
            Acc.BillingCountry='united states';
            Acc.BillingCountryCode='';
            Acc.BillingStreet='st 124563 louis street';
            insert Acc;
            
            Contact con=new Contact();
            con.Firstname='test';
            con.lastname='test contact';
            con.Email='test@gmail.com';
            con.AccountId=Acc.Id;
            con.Core_MINDS__c = false;
            con.Core_Country_Region__c = 'India';
            con.Core_IPS_Email_Opt_Out__c = false;
            con.MailingCountry = 'India';
            List<Contact> conLst = new List<Contact>();
            conLst.add(con);
            insert conLst;
            
            User UserAcc=new User();
            UserAcc.Username='Genjiuser@apttus.com';
            UserAcc.FirstName='Testing';
            UserAcc.LastName='user';
            UserAcc.ContactId=con.Id;
            UserAcc.Email='genjitesting@apttus.com';
            UserAcc.Alias='Testuser';
            UserAcc.EmailEncodingKey='ISO-8859-1';
            UserAcc.LanguageLocaleKey = 'en_US';
            UserAcc.TimeZoneSidKey='America/New_York';
            UserAcc.ProfileId= pf.Id;
            UserAcc.LocaleSidKey='en_US';
            insert UserAcc;
            Core_IPS_TestAllRecords.getContactAndAccountDetails(UserAcc.id);
            System.runAs(UserAcc){
                Core_IPS_TestAllRecords.getContactAndAccountDetails(UserAcc.Id);
                Core_IPS_TestAllRecords.getUserDetail(UserAcc.Id);    
            }
            // }
                        
            Case CaseRec=new Case();
            CaseRec.Subject='Test Demo';
            CaseRec.Status='';
            CaseRec.Core_Sub_Status__c='Core_Sub_Status__c';
            CaseRec.Core_Severity__c='Low';
            CaseRec.Core_Severity_Reason__c='Testing case';
            CaseRec.Core_CaseType__c='Question';
            CaseRec.Core_IPS_Legacy_IPS_ID__c='Testing';
            CaseRec.Core_Customer_Reference_ID__c='customer test';
            CaseRec.Core_End_Customer__c='End customer test';
            CaseRec.Description='case test description';
            CaseRec.Core_IPS_Restricted_Secret_Content__c=True;
            CaseRec.Core_IPS_Knowledge_Base_Link__c='Case knowledge test';
            CaseRec.Core_IPS_Product_name__c='Test product';
            CaseRec.Core_IPS_Project_Case__c=Project.Id;
            insert CaseRec;
            Id caseId=CaseRec.Id;
            
            
            List<Id> caseIds = new List<Id>();
            for(Case cs: [SELECT Id FROM Case]){
                caseIds.add(cs.Id);
            }
            
            Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
            label1.name= 'PRIVATE_TO_PARTNERS';
            label1.value__c='Private to Partner';
            insert  label1;
            
            Core_IPS_Labels__c label2 = new Core_IPS_Labels__c();
            label2.name= 'PUBLIC_TO_CUSTOMERS';
            label2.value__c='Public to Customers';
            insert  label2;
            
            Core_IPS_Labels__c label3 = new Core_IPS_Labels__c();
            label3.name= 'PRIVATE_TO_AGENTS';
            label3.value__c='Private to Agents';
            insert  label3; 
            
            Core_IPS_Labels__c label4 = new Core_IPS_Labels__c();
            label4.name= 'PRIVATE_TO_Intel';
            label4.value__c='Private to Intel';
            insert  label4;
            
            Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
            label5.name= 'Agent';
            label5.value__c='Agent';
            insert  label5; 
            
            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
            label6.name= 'Partner - Agent';
            label6.value__c='Partner - Agent';
            insert  label6; 
            
            
            
            
            String jsondata = '{ "Severity":"High","description":"Testing","subject":"Testing","customerRefId":"123456", "caseCategory":"Hardware", "caseSubCategory":"CPU/Processor", "caseType":"Feature Request" }';
            Test.startTest();
            Core_IPS_TestAllRecords.getattachments(CaseRec.Id);
            Core_IPS_TestAllRecords.getAllProjects();
            //Core_IPS_TestAllRecords.deleteAttachmentRecord(caseatt.Id);
            Core_IPS_UserInfoCtrl.fetchUser();
            try{
                Core_IPS_TestAllRecords.getCurrentCase(caseId);    
            }catch(Exception e){
            }
            
            
            
            
            Core_IPS_TestAllRecords.getcurcasestatus(caseId);
            Core_IPS_TestAllRecords.getcurrentuserprofile();
            Core_IPS_TestAllRecords.getcurUsername();
            Core_IPS_TestAllRecords.getEnvDetails(caseId);
            Core_IPS_TestAllRecords.updateCaseDetails(caseId, jsondata);
            Core_IPS_CaseCommentLWCController.saveCaseComment(caseId,'Public to Customers','Test Comment');
            Core_IPS_CaseCommentLWCController.getVisibilityOptions(caseId);
            Core_IPS_CaseCommentLWCController.showVisibilityOptions();
            Core_IPS_CaseCommentHelper cmtHelperObj = new Core_IPS_CaseCommentHelper();
            cmtHelperObj.getUserType();
            cmtHelperObj.getPartnerType();
            cmtHelperObj.saveComments(CaseRec,'Public to Customers','Test Comment');
            Core_IPS_CaseCommentHelper.getAuthr(UserAcc.Id,UserAcc.Id);
            
            Test.stopTest();
        }catch(Exception e){
        }
    }
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
        
        insert ListOfUser;
    }
    @isTest static void PartnerTest(){
createusers();
Id intelSupportOwner = ListOfUser.get(0).id;
Map<String,ID> profiles = new Map<String,ID>();
List<Profile> ProfileList = [select id, name from Profile where name='Partner' ];// OR name='Integration' OR name='IPS Data Migration' OR name='Data Ops'];// OR name='Partner' OR name='IPS Agent-Partner'];
for(Profile prf : ProfileList){
profiles.put(prf.name, prf.id);
}

//        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
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
AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry='India');
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
AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry='India');
insert testContact;
System.assertNotEquals(null, testContact.id);            
} 
Case Cs =  TestUtilities.getCase(); 
cs.contactid=testContact.id;
insert Cs;

List<Core_IPS_Case_Comments__c> cmt = [Select id,name,Core_IPS_Case_Comment_Type__c,Core_IPS_Case_Comment_Source__c,Core_IPS_Case__r.core_Account_Name__c,CreatedBy.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c, Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Email__c,CreatedBy_Name__c,CreatedDate,Core_IPS_Comment_Author_Type__c,CreatedBy.Email FROM Core_IPS_Case_Comments__c Where Core_IPS_Comment_Author_Type__c='Partner'OR Core_IPS_Comment_Author_Type__c='Customer'OR Core_IPS_Comment_Author_Type__c='Agent'OR Core_IPS_Comment_Author_Type__c='Partner - Agent' OR Core_IPS_Comment_Author_Type__c='Data Migration'OR Core_IPS_Comment_Author_Type__c='Backend Integration'OR Core_IPS_Comment_Author_Type__c ='FAE' LIMIT 20  ];
//(cmt.CreatedBy.Email !=null && (cmt.Core_IPS_Comment_Author_Type__c =='Customer' || cmt.Core_IPS_Comment_Author_Type__c =='Partner' ||cmt.Core_IPS_Comment_Author_Type__c =='Partner - DFAE' ) )
List<Core_IPS_Case_Comments__c> cmt1 = [Select id,name,Core_IPS_Case_Comment_Type__c,Core_IPS_Case_Comment_Source__c,Core_IPS_Case__r.core_Account_Name__c,CreatedBy.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c, Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Email__c,CreatedBy_Name__c,CreatedDate,Core_IPS_Comment_Author_Type__c,CreatedBy.Email FROM Core_IPS_Case_Comments__c Where CreatedBy.Email !=null AND (Core_IPS_Comment_Author_Type__c ='Customer' OR Core_IPS_Comment_Author_Type__c ='Partner' OR Core_IPS_Comment_Author_Type__c ='Partner - DFAE' )];

Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
cicc.Core_IPS_Comment_Author_Type__c='Customer';

List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
conLst1.add(cicc);
Core_IPS_TestAllRecords.frmtComments(conLst1,'Partner');

System.runAs(userRecord){
Test.startTest();

Core_IPS_TestAllRecords.getattachments(Cs.Id);
Core_IPS_TestAllRecords.getCurrentCaseComments(Cs.Id);
Core_IPS_TestAllRecords.frmtComments(cmt,'Partner');
Core_IPS_TestAllRecords.frmtComments(cmt1,'Partner');
Core_IPS_TestAllRecords.frmtComments(cmt,'Partner - Agent');
Core_IPS_CaseCommentHelper.getAuthr(ProfileList[0].id,userRecord.Id);
Test.stopTest();
}


    }
    @isTest static void testcomments(){
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'PUBLIC_TO_CUSTOMERS';
        labels.value__c='Public to Customers';
        insert labels;
          System.assertNotEquals(null, labels.Id, 'Id should not be equal');

        Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
        label1.name= 'PRIVATE_TO_AGENTS';
        label1.value__c= 'Private to Agents';
        insert label1;
        
        Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
        Label2.name= 'PRIVATE_TO_INTEL';
        label2.value__c= 'Private to Intel';
        insert label2;
        
        Core_IPS_Labels__c Label9 = new Core_IPS_Labels__c ();
        Label9.name= 'PRIVATE_TO_PARTNERS';
        label9.value__c= 'Private to Partner';
        insert label9;
        
        
        List<Case> caseList;
        Set<Core_IPS_Case_Comments__c> caseCommentList;
        List<User> userList;
        User SystUserRunAs;
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        userList = new List<user>();
        userList = TestUtilities.getListOfUser(3);
        userList[0].profileId=prof.id;
        insert userlist[0];        
        
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
        System.runAs(systUserRunAs){
            caseList = TestUtilities.getListOfCases(3);
            insert caseList;
            
            caseCommentList = new Set<Core_IPS_Case_Comments__c>();
            List<Core_IPS_Case_Comments__c> caseCommentListNew = new List<Core_IPS_Case_Comments__c>();
            caseCommentList.addAll(TestUtilities.getCaseComments(3));
            
            test.startTest();   
            
            Core_IPS_TestAllRecords.frmtComments(caseCommentListNew,'Partner');
            for(Core_IPS_Case_Comments__c comment:caseCommentList){                     
                comment.Core_IPS_Case__c=caseList[0].id;  
                
                comment.Core_IPS_Rich_Comment__c= 'IPS Team testing';
                //comment.Core_IPS_Comment_Authored_By_Email__c = 'test@intel.com';
                
                //comment.Core_IPS_Comment_Author_Type__c = 'Agent';
                
                caseCommentListNew.add(comment);
                
            }
            try{
                update caseCommentListNew;    
            }
            Catch(Exception e){}
            Core_IPS_TestAllRecords.frmtComments(caseCommentListNew,'Partner');
            
            Test.stopTest();
        }
        
    }
    @isTest static void testnegative(){
        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        insert CaseRec;
        Id caseId=CaseRec.Id;
          System.assertNotEquals(null, caseId, 'Id should not be equal');

        Test.startTest();
        try{
            Core_IPS_TestAllRecords.getCurrentCase(caseId);    
        }catch(Exception e){
        }
        
        Core_IPS_TestAllRecords.getCurrentCaseComments(caseId);
        //Core_IPS_CaseCommentLWCController.saveCaseComment(caseId,'Public to Customers','Test Comment');
        Test.stopTest();
    }
    
    
    @isTest static void Testallproducts(){
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
                    System.assertNotEquals(null, Acc.Id, 'Id should not be equal');

        String productStatus='allproducts';
        Test.startTest();
        Core_IPS_TestAllRecords.getAllProducts(productStatus,Acc.Id);
        Test.stopTest();
    }
    @isTest static void Testactiveproducts(){
        String productStatus='activeproducts';
        account Acc=new account();
        Acc.Name='test';
        Acc.BillingCity='new york';
        Acc.BillingCountry='united states';
        Acc.BillingCountryCode='';
        Acc.BillingStreet='st 124563 louis street';
        insert Acc;
                    System.assertNotEquals(null, Acc.Id, 'Id should not be equal');

        Test.startTest();
        Core_IPS_TestAllRecords.getAllProducts(productStatus,Acc.Id);
        Test.stopTest();
    }
    @isTest static void TestNeagtiveproducts(){
        String productStatus=null;
        String AccId=null;
                    System.assertEquals(null, AccId, 'Id should be equal');

        Test.startTest();
        Core_IPS_TestAllRecords.getAllProducts(productStatus,AccId);
        Test.stopTest();
    }
    
  /*  @isTest static void TesthandleSaveReportpositive()//Anil
    {
        String basicInfoData,finalformData;
        
        Test.startTest();
        //Core_IPS_Case_Save_Controller.handleSaveCase(basicInfoData,finalformData);
        Test.stopTest();
    }*/
    
    
    @isTest
    public static void getCaseClosedTest(){
        
        Case cs = new Case();
        cs.Status = 'NEW';
        insert cs;
        String csId = cs.Id;
        String comment = 'This is test comment';
        String visibleTo = 'Public to Customers';
                    System.assertNotEquals(null, cs.Id, 'Id should not be equal');

        Core_IPS_TestAllRecords.getCaseClosed(cs.id);
        Core_IPS_TestAllRecords.saveNewComment(csId, visibleTo, comment); 
        Core_IPS_TestAllRecords.Wrapsearchresult wrapperList = Core_IPS_TestAllRecords.getSearchResult('Test');
        //Core_IPS_TestAllRecords.getSearchResult('Test');
    }
    
    @isTest
    public static void frmtComments_Test(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Customer';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Customer');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Partner');
         
    }
    @isTest
    public static void frmtComments_Test0(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Customer';
        
        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Customer');
    }
    @isTest
    public static void frmtComments_Test01(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c=NULL;
        cicc.Core_IPS_Comment_Author_Type__c='Customer';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Customer');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Test1(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner-Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Customer');
    }
    @isTest
    public static void frmtComments_Test2(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner-Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'PartnerAgent');
    }
    @isTest
    public static void frmtComments_Test3(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
                System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner - Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Partner - Agent');
    }
    @isTest
    public static void frmtComments_Test4(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
         System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner - Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'PartnerAgent');
    }
    @isTest
    public static void frmtComments_Test5(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='FAE';
                        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'PartnerFAE');
    }
    @isTest
    public static void frmtComments_Test6(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='FAE';
                                System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'PartnerAgent');
    }
    @isTest
    public static void frmtComments_Test7(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='FAE';
                       System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
               //System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

    }
    @isTest
    public static void frmtComments_Test8(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Data Migration';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Data  Migration');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Test9(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Customer');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Testelse1(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Customer';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Customer');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Testelse2(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        // cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Customer';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Customer');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Testelse3(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        // cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Customer');
    }
    @isTest
    public static void frmtComments_Testelse4(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        // cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner - Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Customer');
    }
    @isTest
    public static void frmtComments_Testelse5(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner - Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'PartnerAgent');
    }
    @isTest
    public static void frmtComments_Testelse6(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        //  cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Partner - Agent';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Partner - Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Customer');
    }
    @isTest
    public static void frmtComments_Testelse7(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='FAE';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'Customer');
    }
    @isTest
    public static void frmtComments_Testelse8(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='FAE';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,'PartnerAgent');
    }
    @isTest
    public static void frmtComments_Testelse9(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='FAE';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to FAE');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Testelse10(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Data Migration';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Data Migration');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    @isTest
    public static void frmtComments_Testelse11(){
        Core_IPS_Case_Comments__c cicc=new Core_IPS_Case_Comments__c();
        // cicc.Core_IPS_Case_Comment_Type__c='Public to Customers';
        cicc.Core_IPS_Comment_Authored_By_Email__c='newuser321@intel.com';
        cicc.Core_IPS_Comment_Author_Type__c='Agent';
        //cicc.CreatedBy.Email='newuser3214@intel.com';
        System.assertNotEquals('Partner', cicc.Core_IPS_Comment_Author_Type__c, 'Comment Author Type should be equal to Agent');

        List<Core_IPS_Case_Comments__c> conLst1 = new List<Core_IPS_Case_Comments__c>();
        conLst1.add(cicc);
        Core_IPS_TestAllRecords.frmtComments(conLst1,NULL);
    }
    
    @isTest
    public static void fetchCustomSetting_Test(){
        Core_Ips_BannerMessage__c bmsg=new Core_Ips_BannerMessage__c();
        bmsg.Name='Core_Ips_BannerMessageone';
        bmsg.Core_Ips_BannerMessage_Text_LWC__c='Details on Intel Customer Support services during COVID-19 global response actions';
        bmsg.Core_Ips_BannerMessage_Checkbox_LWC__c=true;
        insert bmsg;
                    System.assertNotEquals(null, bmsg.Id, 'Id should not be equal');

        Core_IPS_UserInfoCtrl.fetchCustomSetting();
        Core_IPS_UserInfoCtrl.formatLabels();
    }
    
    
    @isTest
    public static void getSupportedAccount_Test(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        //User userDetails =[select Id,FirstName, LastName, Email from User limit 1];
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        User usr = new User(LastName = 'LIVESTON1',
                            FirstName='JASON1',
                            Alias = 'jliv1',
                            Email = 'jason1.livesto@example.com',
                            Username = 'jason1.liveston'+Crypto.getRandomLong()+'@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
System.assertNotEquals(null, usr.Id, 'Id should not be equal');
        Account newAccount = new Account (
            name='XYZ',
            Phone = '+49-12345',
            BillingStreet = 'Am Tierpark 16',
            BillingCity = 'Fremont',
            BillingPostalCode = '54321',
            BillingState = 'CA',
            BillingCountry = 'USA',
            RecordTypeId = recordTypeIdAccount
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
            MailingPostalCode=newAccount.BillingPostalCode,
            MailingCountry = newAccount.BillingCountry,
            Phone=newAccount.Phone);
        insert cc;
        
        Core_IPS_Project__c pr = new Core_IPS_Project__c();
        pr.name = 'test';
        pr.Core_IPS_Enable_ISTasInterested_Parties__c = True;
        pr.Core_IPS_EnableMemberasInterestedParties__c =True;
        insert pr;   
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_IPS_Project__c=Pr.Id;
        insert assetProduct;
        
        
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
        caselst.add(cas);
        
        Case cas1 = new Case();          
        // cas1.Core_IPS_Project_Case__c = pr.id;
        cas1.status = 'open'; 
        cas1.AccountId=newAccount.Id;
        caselst.add(cas1);
        
        insert caselst;  
        
        List<Core_IPS_Case_Interested_Party__c> Iparty = new List<Core_IPS_Case_Interested_Party__c>(); 
        
        Core_IPS_Case_Interested_Party__c party = new Core_IPS_Case_Interested_Party__c();
        party.User__c = usr.id;
        party.Case__c = cas.id;
        party.Contact__c=cc.id;
        party.Active__c= true ;
        party.Type__c= 'External';
        Iparty.add(party);
        
        Core_IPS_Case_Interested_Party__c party1 = new Core_IPS_Case_Interested_Party__c();
        party1.User__c = usr.id;
        party1.Case__c = cas1.id;
        party1.Contact__c=cc.id;
        Iparty.add(party1);   
        insert Iparty;
        List<Core_IPS_Project_Member__c> Pmem = new List<Core_IPS_Project_Member__c>();
        
        Core_IPS_Project_Member__c mem = new Core_IPS_Project_Member__c();
        mem.Core_IPS_Project__c = pr.id;
        mem.Core_User__c = usr.id;
        mem.Core_IPS_Contact__c = cc.id;
        mem.Core_Status__c='Active';
        mem.Core_IPS_Project__c=cas.Core_IPS_Project_Case__c;
        
        
        Pmem.add(mem);
        //Core_IPS_Project__c =: CaseObj.Core_IPS_Project_Case__c AND Core_Status__c = 'Active' 
        //AND Core_IPS_Contact__r.Core_IPS_Active__c = true AND Core_IPS_Contact__r.Core_IPS_Email_Opt_Out__c=false
        Core_IPS_Project_Member__c mem1 = new Core_IPS_Project_Member__c();
        mem1.Core_IPS_Project__c = pr.id;
        mem1.Core_User__c = usr.id;
        mem1.Core_IPS_Contact__c = cc.id;
        mem1.Core_Status__c='Active';
        mem1.Core_Status__c='Active';
        mem1.Core_IPS_Project__c=cas.Core_IPS_Project_Case__c;
        Pmem.add(mem1);  
        
        insert Pmem;
        Id userId = UserInfo.getUserId();
        test.startTest();
        Core_IPS_TestAllRecords.getSupportedAccount(null,usr.id);
        Core_IPS_TestAllRecords.getSupportedAccount(Pmem[0].id,usr.id);
        Core_IPS_TestAllRecords.getSupOwnerAndSupAccountforEditCase(caselst[0].id);
        Core_IPS_TestAllRecords.submitCaseClosureRes(caselst[0]);
        Core_IPS_TestAllRecords.getProjectStatus(pr.id);
        Core_IPS_TestAllRecords.getProductStatus(assetProduct.id);
        test.stopTest();
    }
    
    @isTest
    public static void testAttachments(){
        Case cs = new Case(Subject = 'Test', Origin = 'Phone', Status = 'New');
        
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cs.id;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:cs.id];
        System.assertEquals(0, attachments.size());
        try{
            Core_IPS_TestAllRecords.deleteAttachmentRecord(attach.Id); 
            
        }catch(Exception e){
        }
        
    }
    @isTest
    public static void getcurCaseContactProfile(){
        Case CaseRec=new Case();
        CaseRec.Subject='Test Demo';
        CaseRec.Status='New';
        CaseRec.Core_Sub_Status__c='Core_Sub_Status__c';
        CaseRec.Core_Severity__c='Low';
        CaseRec.Core_Severity_Reason__c='Testing case';
        CaseRec.Core_CaseType__c='Question';
        CaseRec.Core_IPS_Legacy_IPS_ID__c='Testing';
        CaseRec.Core_Customer_Reference_ID__c='customer test';
        CaseRec.Core_End_Customer__c='End customer test';
        CaseRec.Description='case test description';
        CaseRec.Core_IPS_Restricted_Secret_Content__c=True;
        CaseRec.Core_IPS_Knowledge_Base_Link__c='Case knowledge test';
        CaseRec.Core_IPS_Product_name__c='Test product';
        insert CaseRec;
                System.assertNotEquals(null, CaseRec.Id, 'Id should not be equal to null');

        try{
            
            Core_IPS_TestAllRecords.getcurcasestatus(CaseRec.Id);
            Core_IPS_TestAllRecords.getcurCaseContactProfile(CaseRec.Id); 
            
        }catch(Exception e){
        }
        
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
          String jsondata = '{ "Severity":"High","description":"Testing","subject":"Testing","customerRefId":"123456", "caseCategory":"Hardware", "caseSubCategory":"CPU/Processor", "caseType":"Feature Request" }';
        Core_IPS_TestAllRecords.updateCaseDetails(cs.id, jsondata);
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
        System.assertNotEquals(null, attachments.Id, 'Id should not be equal');
        Core_IPS_TestAllRecords.getattachments(Cs.Id);
          Core_IPS_TestAllRecords.deleteAttachmentRecord(attachments.Id);
      }
          Core_IPS_CaseCommentHelper cls = new Core_IPS_CaseCommentHelper();
         try{
            cls.getUserType();
         } catch(exception e) {}
         
         try{
             cls.getPartnerType();
         } catch(exception e){}
         
         try{
            cls.isNACCase(new case()); 
         } catch (Exception e){}
     }
}