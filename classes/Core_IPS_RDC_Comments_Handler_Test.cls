/****************************************************************************************************************************************
* Class Name  : Core_IPS_RDC_Comments_Handler_Test
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019                 This class is for testing Core_IPS_RDC_Comments_Handler-US460268
****************************************************************************************************************************************/
@isTest
public class Core_IPS_RDC_Comments_Handler_Test {
    
    private static User adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
    private static Case objCase;
    private static Core_IPS_RDC_CommentsWrapper  objWrapper=null;
    private static final String MAX_LENGTH_EXCEEDED_9025 = '9025';
    private static List<Case> caseObj= null;
    //private static User commUser  = null;  
    static profile p =null;
    
    //Setup data
    @testSetup
    public static void setupData(){
        Test.startTest();
        //Core_RestAPI_TestUtilities.setupCustomSetting();
        System.debug('Test Setup entered');
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator','Sales Rep-BB-Dual IPS')];//,'Partner','IPS Agent-Partner')];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        List<User> ListOfUser = new List<User>();
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');
        ListOfUser[1].ProfileID =  profiles.get('Sales Rep-BB-Dual IPS');
        
        insert ListOfUser;
        Id intelSupportOwner = ListOfUser.get(0).id;
        
        TestUtilities.getCustomerUsersWithAccountsAndContacts('RestApiUnitTest', 1, 1,0,1,'IPS External Customer', 0);
        System.runAs(adminUser){
            System.debug('Test System.runAs Entered'+adminUser.id);
            List<RecordType> ObjRecordType = [Select Id from RecordType where name='IPS Case Create'];
            List<contact> objcon=[select id,email from contact where id!=null ];
            objCase=new Case();
            objCase.OwnerId = adminUser.Id;
            objCase.Status = 'New';
            objCase.contactId=objcon[0].id;
            objCase.Origin = 'Web';
            objCase.Priority = 'High';
            objCase.Subject = 'Post TestSubject';
            objCase.Description = 'Case Create';
            objCase.Status='Open'; 
            objCase.Core_Sub_Status__c='Close-Pending';
            
            objCase.RecordTypeId=ObjRecordType[0].Id;
            insert objCase;//inserting case  for admin user
            //inserting another case with record type Ips case close
            Case objCase1 =new Case();
            objCase1.OwnerId = adminUser.Id;
            objCase1.Status = 'New';
            objCase1.contactId=objcon[0].id;
            objCase1.Origin = 'Web';
            objCase1.Priority = 'High';
            objCase1.Subject = 'Post TestSubject';
            objCase1.Description = 'Case Create';
            objCase1.Status='Open'; 
            objCase1.Core_Sub_Status__c='Close-Pending';
            objCase1.Core_IPS_Customer_Visible__c = false;
            objCase1.RecordTypeId=ObjRecordType[0].Id;
            insert objCase1;
            
            Map<string,ID> CaseRecordtype = new Map<string,ID>();
            for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
            {  
                CaseRecordtype.put(Rt.Name,Rt.ID);
            }  
            
            case inserCase=[select id,casenumber,Subject,Description,Status,Priority,RecordTypeId from case where id=:objCase.id];
            List<RecordType> ObjRecordcaseType = [Select Id from RecordType where sObjectType='Case' AND name='IPS GEC ReadOnly'];
            Case caseObj=Core_RestAPI_TestUtilities.getCase(); 
            caseObj.contactId=objcon[0].id;//inserting case  for admin user
            caseObj.Core_Sub_Status__c='Investigating';
            caseObj.OwnerId = adminUser.Id;
            caseObj.RecordTypeId=CaseRecordtype.get('IPS Case Create');
            insert caseObj;
            System.debug(''+caseObj);
            case caseType=[select id,casenumber,Subject,Description,Status,Priority,RecordTypeId,Core_IPS_Customer_Visible__c from case where id=:caseObj.id];
        } 
        
        list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        Core_IPS_Labels__c lable = new Core_IPS_Labels__c();
        lable.name='Comment Source - Customer';
        lable.value__c='Customer Portal';
        lstCs.add(lable);
        
        Core_IPS_Labels__c label = new Core_IPS_Labels__c();
        label.name='Comment Source - Internal';
        label.value__c='Internal Portal';
        lstCs.add(label);
        
        Core_IPS_Labels__c label1 = new Core_IPS_Labels__c();
        label1.name='Comment Source - B2B API';
        label1.value__c='B2B API';
        lstCs.add(label1);
        
        Core_IPS_Labels__c label2 = new Core_IPS_Labels__c();
        label2.name='Partner - Agent';
        label2.value__c='Partner - Agent';
        lstCs.add(label2);
        
        Core_IPS_Labels__c label3 = new Core_IPS_Labels__c();
        label3.Name = 'IPS Standard Entitlement';
        label3.Value__c='IPS Standard Entitlement';
        lstCs.add(label3);
        
        Core_IPS_Labels__c label4 = new Core_IPS_Labels__c();
        label4.Name = 'PRIVATE_TO_INTEL';
        label4.Value__c = 'Private to Intel';
        lstCs.add(label4);
        
        Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
        label5.Name = 'Agent';
        label5.Value__c = 'Agent';
        lstCs.add(label5);
        
        Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
        label6.Name = 'PUBLIC_TO_CUSTOMERS';
        label6.Value__c = 'Public to Customers';
        lstCs.add(label6);
            
        Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
        label7.Name = 'Customer';
        label7.Value__c = 'Customer';
        lstCs.add(label7);
        
        Core_IPS_Labels__c  label8 = new Core_IPS_Labels__c();
        label8.name = 'Partner';
        label8.value__c = 'Partner';
 		lstCs.add(label8);
        
        Core_IPS_Labels__c label9 = new Core_IPS_Labels__c ();
         label9.name='FAE';
         label9.value__c='FAE';
		 lstCs.add(label9);
        
        Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
         label10.name='Backend Integration';
         label10.value__c='Backend Integration';
 			lstCs.add(label10);
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name= 'Partner - DFAE';
        label11.value__c= 'Partner - DFAE';
        lstCs.add(label11);
              
               
        Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name= 'Comment Source - Backend System';
        label13.value__c='Backend System';
        lstCs.add(label13);
        
        Core_IPS_Labels__c label14 = new Core_IPS_Labels__c();
        label14.name= 'Comment Source - Data Migration';
        label14.value__c='Data Migration';
        lstCs.add(label14);
        
        Core_IPS_Labels__c label15  = new Core_IPS_Labels__c();
        label15.name= 'Comment Source - Email';
        label15.value__c='Email';
        lstCs.add(label15); 
        
                 
        Core_IPS_Labels__c label16 = new Core_IPS_Labels__c();
        label16.name= 'Comment Source - N/A';
        label16.value__c='N/A';
        lstCs.add(label16);
        
        Core_IPS_Labels__c label17  = new Core_IPS_Labels__c();
        label17.name= 'Data Migration';
        label17.value__c='Data Migration';
        lstCs.add(label17);
                       
        insert lstCs;
        
        list<Core_RestAPI_Response_Codes__c> lstcs1= new list<Core_RestAPI_Response_Codes__c>();
        
        Core_RestAPI_Response_Codes__c v1 = new Core_RestAPI_Response_Codes__c();
        v1.name='ApexException';
        v1.Core_Message__c='Technical error, please contact Intel support with the traceId';
        lstcs1.add(v1);
        
        Core_RestAPI_Response_Codes__c v2 = new Core_RestAPI_Response_Codes__c();
        v2.name='InvalidContact';
        v2.Core_Message__c='Invalid Contact';
        lstcs1.add(v2);
        
        Core_RestAPI_Response_Codes__c v3 = new Core_RestAPI_Response_Codes__c();
        v3.name='ContactInActive';
        v3.Core_Message__c='Contact is Inactive';
        lstcs1.add(v3);
            
        Core_RestAPI_Response_Codes__c v4 = new Core_RestAPI_Response_Codes__c();
        v4.name='InvalidProfile';
        v4.Core_Message__c='Contact doesnt have permissions to add comments to the case';
        lstcs1.add(v4);
        
        Core_RestAPI_Response_Codes__c v5 = new Core_RestAPI_Response_Codes__c();
        v5.Name ='InactiveProjectMember';
        v5.Core_Message__c='Invalid Contact- not an active project member';
        lstcs1.add(v5);
        
        Core_RestAPI_Response_Codes__c v6 = new Core_RestAPI_Response_Codes__c();
        v6.Name ='InvalidURI';
        v6.Core_Message__c='Could not find a match for URL';
        lstcs1.add(v6);
        
        Core_RestAPI_Response_Codes__c v7 = new Core_RestAPI_Response_Codes__c();
        v7.Name ='InvalidInputField';
        v7.Core_Message__c='Invalid Input';
        lstcs1.add(v7);
        
        Core_RestAPI_Response_Codes__c v8 = new Core_RestAPI_Response_Codes__c();
        v8.Name ='RequiredFieldException';
        v8.Core_Message__c='Missing required field';
        lstcs1.add(v8);
        
        Core_RestAPI_Response_Codes__c v9 = new Core_RestAPI_Response_Codes__c();
        v9.Name ='UnAuthorizeCaseComment';
        v9.Core_Message__c='You are not Authorize to create Comment for Closed or GEC cases	';
        lstcs1.add(v9);
        
        Core_RestAPI_Response_Codes__c v10 = new Core_RestAPI_Response_Codes__c();
        v10.Name ='EnvDetMaxLengthExceeded';
        v10.Core_Message__c='Maximum Length exceeded';
        lstcs1.add(v10);
        
        insert lstcs1;
        
        //Map<string, Core_RestAPI_Response_Codes__c> mcs = Core_RestAPI_Response_Codes__c.getAll();
                
        list<user> u= [select id,ProfileId from user where isActive=true AND UserRoleId!=null and  profile.Name = 'System Administrator' LIMIT 10];
        UserRole ur= [select id from UserRole where portalType='none' limit 1]; 
        
        system.runas(u[0]){
         //Account Insertion
        Account acc = new Account ();
        acc.Name = 'newAcc1';
        acc.Core_Sales_Group__c='Global Accounts'; 
        acc.Core_IsODM__c = true;
        acc.Core_Account_Type__c='Other'; 
        acc.Industry='Others';
        acc.Core_CNDA_Number__c = '12345';
        acc.BillingStreet='1234 tester St'; 
        acc.BillingCity='testCity'; 
        acc.BillingState='OR';
        acc.BillingCountry='USA'; 
        acc.BillingPostalCode='12345';
        acc.Core_Export_Compliance_Block__c = false;
        acc.ownerid = u[0].Id;
        
        insert acc;
        
         //Contacts insertion
        Contact con = new Contact ();
        con.AccountId = acc.id;
        con.LastName = 'portalTestUser';
        con.FirstName='testFirstName123Q'; 
        con.Email='test123Q@testing.com.test';
        con.Core_IPS_Intel_Support_Owner__c=intelSupportOwner;
        con.Core_IPS_Active__c=true;
        insert con;
        
        Contact con1 = new Contact ();
        con1.AccountId = acc.id;
        con1.LastName = 'portalTestUserJack';
        con1.FirstName='testFirstName123QJack'; 
        con1.Email='Jacktest123Q@testing.com.test';
        con1.Core_IPS_Intel_Support_Owner__c=intelSupportOwner;
        con1.Core_IPS_Active__c=true;
        insert con1;
        
        Contact con2 = new Contact ();
        con2.AccountId = acc.id;
        con2.LastName = 'portalTestUserLast';
        con2.FirstName='testFirstName123QLast'; 
        con2.Email='Lasttest123Q@testing.com.test';
        con2.Core_IPS_Intel_Support_Owner__c=intelSupportOwner;
        con2.Core_IPS_Active__c=true;
        insert con2;
         
        //Users insertion
            User newUser = new User(
                //UserRoleId = ur.Id,
                profileId = [SELECT Id FROM Profile WHERE Name ='IPS External Customer' Limit 1].id,
                username = 'newUserwww545@yahoo.com',
                email = 'pb@intel.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id,
                isActive = true
            );
            insert newUser;
            
            User newUser1 = new User(
                //UserRoleId = ur.Id,
                profileId = [SELECT Id FROM Profile WHERE Name ='IPS Agent-Partner' Limit 1].id,
                username = 'qqtestjacktest@yahoo.com',
                email = 'pb@intel.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='jacklastname',
                contactId = con1.id,
                isActive = true
            );
            insert newUser1;
            
            UserRole ur1= [select id from UserRole where portalType='Partner' limit 1];      
            User newUser2 = new User(
                UserRoleId = ur1.Id,
                profileId = [SELECT Id FROM Profile WHERE Name ='Partner' Limit 1].id,
                username = 'xxyyzzTEST@yahoo.com',
                email = 'p123b@intel.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastnamejill',
                contactId = con2.id,
                isActive = true
            );
            insert newUser2; 
        }
        Test.stopTest();
    }
/****************************************************************************************************************************************
* Method Name  : test_CreateCaseComments
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019                Covers code for createCaseComments,insertCaseComment method in handler
****************************************************************************************************************************************/
       
    @isTest public static void test_CreateCaseComments(){
        
        List<Case> caseObj=[select casenumber,Subject,Core_IPS_Project_Case__c from Case where Subject='Post TestSubject' AND casenumber!= null ];  
        
        Account acc = [select id from account where name='newAcc1' limit 1];
        
        Contact con = [select id,email from contact where firstname='testFirstName123Q'];
        
        User newUser = [select id,name from user where lastname='lastname'];
        
        Core_IPS_RDC_CommentsWrapper objWrapper=new Core_IPS_RDC_CommentsWrapper();
        
        objWrapper.comments='do post comment';
        objWrapper.contactEmail = con.Email;
        objWrapper.caseNumber = caseObj[0].caseNumber;
        Core_IPS_RDC_Comments.doPost(objWrapper);
        Core_IPS_RDC_Comments_Handler objhandler = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper); 
        objhandler.createCaseComments(); 
        
        Core_IPS_Case_Comments__c objCmt=new Core_IPS_Case_Comments__c();
        objCmt.Core_IPS_Case__c=caseObj[0].id;
        objCmt.Core_IPS_Comment_Author_Type__c='Agent';
        objCmt.Core_IPS_Case_Comment_Type__c='Public to Customers'; 
        objCmt.Core_IPS_Rich_Comment__c=objWrapper.comments;
        insert objCmt;
        Core_IPS_RDC_Comments_Handler objhandler1 = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_RestAPI_CaseAttachmentsV1',objWrapper); 
        objhandler1.insertCaseComment(); 
        
    }     
    
/****************************************************************************************************************************************
* Method Name  : test_validateCaseNumber
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019                Covers code for validateCommentRequiredFields,validateEmail,validateNumbericCaseNumber
													validateCaseNumber methods in handler
****************************************************************************************************************************************/
    
    @isTest public static void test_validateCaseNumber(){
        
        List<Case> caseObj=[select casenumber,Subject,Core_IPS_Customer_Visible__c from Case where Subject='Post TestSubject' AND casenumber!= null ];
        objWrapper=new Core_IPS_RDC_CommentsWrapper();
        objWrapper.comments='';
        if(caseObj!=null){
            objWrapper.caseNumber = caseObj[0].casenumber;
        }
        objWrapper.contactEmail ='abzxc@test.billy.com';
        Core_IPS_RDC_Comments.doPost(objWrapper);
        Core_IPS_RDC_Comments_Handler objhandler = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper); 
        objhandler.validateCommentRequiredFields(); 
        objhandler.validateEmail();     
        
        Core_IPS_RDC_CommentsWrapper objWrapper1=new Core_IPS_RDC_CommentsWrapper();
        objWrapper1.comments='do post comment';
        objWrapper1.caseNumber= 'abcdefghijklmn';
        List<Case> caseObj1=[select id,casenumber,Subject,Core_IPS_Customer_Visible__c from Case where Subject='Post TestSubject' AND casenumber=:objWrapper1.caseNumber ];
        Core_IPS_RDC_Comments_Handler objhandler1 = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper); 
        objhandler1.validateNumbericCaseNumber();
                
        Core_IPS_RDC_CommentsWrapper objWrapper0=new Core_IPS_RDC_CommentsWrapper();
        List<Case> caseObjRec=[select id,casenumber,Subject,Core_IPS_Customer_Visible__c from Case where Subject='Post TestSubject' AND Core_IPS_Customer_Visible__c= false ];
        objWrapper0.comments = 'Testing Entry';
        objWrapper0.caseNumber = caseObjRec[0].caseNumber;
        objWrapper0.contactEmail= [select id,email from contact where firstName = 'testFirstName123Q'].Email;
        Core_IPS_RDC_Comments_Handler objhandler0 = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper0); 
        objhandler0.validateCaseVisibility();
        
        Core_IPS_RDC_CommentsWrapper objWrapper2=new Core_IPS_RDC_CommentsWrapper();
        Core_IPS_RDC_Comments_Handler objhandler2 = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper2); 
        objWrapper2.comments='do post comment';
        objWrapper2.caseNumber= 'abcdefghijklmn';
        objhandler2.validateNumbericCaseNumber(); 
        
        Core_IPS_RDC_CommentsWrapper objWrapper3=new Core_IPS_RDC_CommentsWrapper();
        Core_IPS_RDC_Comments_Handler objhandler3 = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper3); 
        objWrapper3.comments='do post comment';
        objWrapper3.caseNumber= '';
        objhandler3.validateCaseNumber();
        
    }
    
 /****************************************************************************************************************************************
* Method Name  : test_getAuthr
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019                Covers code for test_getAuthr method in handler
****************************************************************************************************************************************/
        @isTest  public static  void test_getAuthr(){
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='Partner' OR name='IPS Agent' OR name='IPS External Customer' OR name='Integration' OR name='IPS Data Migration'  OR name='Data Ops'  ];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);//mapping the fields profile name ,profile id
        }
        Core_RestAPI_TestUtilities.setupCustomSetting();
        Core_IPS_RDC_Comments_Handler.getAuthr(Profiles.get('Partner'));
        Core_IPS_RDC_Comments_Handler.getAuthr(Profiles.get('Data Ops'));         
        Core_IPS_RDC_Comments_Handler.getAuthr(Profiles.get('IPS Data Migration')); 
        Core_IPS_RDC_Comments_Handler.getAuthr(Profiles.get('Integration'));
        Core_IPS_RDC_Comments_Handler.getAuthr(Profiles.get('IPS External Customer'));
        System.assertNotEquals(null,  Core_IPS_RDC_Comments_Handler.getAuthr(Profiles.get('IPS External Customer')));
    }
    
 /****************************************************************************************************************************************
* Method Name  : test_validateLengthCaseComment
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019               This method is to validate Case comment field length greater than 92768 chars
****************************************************************************************************************************************/
    
    @isTest public static void test_validateLengthCaseComment(){
        
        List<Case> caseObj=[select casenumber,Subject from Case where Subject='Post TestSubject' AND casenumber!= null ];
        objWrapper=new Core_IPS_RDC_CommentsWrapper();
        //here passing comment  length as more than 92768
        objwrapper.comments='hduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyyguygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehduwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyygfuygfyueguyegeedededededdddddddedededehduehdueyhfyuwefgggggggggryyyyyyy';  
        Core_IPS_RDC_Comments_Handler handler = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper); 
        Boolean validateLengthCaseComment = handler.validateLengthCaseComment();
        System.assertEquals(false, validateLengthCaseComment);
        System.assertEquals(MAX_LENGTH_EXCEEDED_9025, '9025');
    }

 /****************************************************************************************************************************************
* Method Name  : test_ValidateURI
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019               covers code for validateURI method in handler
****************************************************************************************************************************************/ 
    @isTest public static void test_ValidateURI(){
        List<Case> caseObj=[select casenumber,Subject,Core_IPS_Project_Case__c from Case where Subject='Post TestSubject' AND casenumber!= null ];  
        List<contact> objcon=[select id,Core_IPS_Active__c,Email from contact where id!=null ];
        System.debug('Test class PostCase comments Entered');
        RestRequest  request = (RestRequest)System.jSON.deserialize(Core_RestAPI_TestUtilities.REQUEST_TEMPLATE, RestRequest.class);
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.resourcePath ='/services/apexrest/v1.0/IPS_RDC/v1.0/cases/comments'; 
        request.requestURI='/v1.0/cases/comments';
        Core_IPS_RDC_CommentsWrapper objWrapper=new Core_IPS_RDC_CommentsWrapper();
        
        objWrapper.comments='do post comment';
        objWrapper.contactEmail = objcon[0].Email; 
        Core_IPS_RDC_Comments.doPost(objWrapper);
        Core_IPS_RDC_Comments_Handler objhandler = new Core_IPS_RDC_Comments_Handler(System.now(), 'Core_IPS_RDC_Comments',objWrapper); 
        Core_RestAPI_Response response=objhandler.createCaseComments(); 
        objhandler.validateURI();
    }
    
 /****************************************************************************************************************************************
* Method Name  : inactiveContact_test
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019               covers code for validateContact method in handler
****************************************************************************************************************************************/    
    @isTest
    public static void inactiveContact_test() {
                
        Account acc = [select id from account where name='newAcc1'];
        
        Contact con = [select id,Email from contact where firstname='testFirstName123Q' limit 1];
        con.Core_IPS_Active__c=false;
        update con;
        
        user u  = [select id,profile.Name from user where  profile.Name = 'System Administrator' AND isActive=true limit 1];
        system.runas(u){
        User newUser = [select id from User where lastname='lastname'];
        newUser.isActive=false;
        update newUser; 
        }
        Core_IPS_RDC_CommentsWrapper objWrapper1=new Core_IPS_RDC_CommentsWrapper();
        objWrapper1.comments='Hello';
        objWrapper1.contactEmail=con.Email;
        Core_IPS_RDC_Comments_Handler test1 = new Core_IPS_RDC_Comments_Handler(system.now(), 'Case',objWrapper1); 
        test1.validateContact();
        
    }
    
 /****************************************************************************************************************************************
* Method Name  : invalidProfileTest
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019               covers code for validateContact method in handler
***********************************************************************************************************/
    static testmethod void invalidProfileTest(){
        
        Account acc = [select id from account where name='newAcc1'];
        
        Contact con = [select id,Email from contact where firstname='testFirstName123QJack'];
        
        user u  = [select id,profile.Name from user where  profile.Name = 'System Administrator' AND isActive=true limit 1];
        
        User newUser = [select id from User where lastname='jacklastname'];
        
        Core_IPS_RDC_CommentsWrapper objWrapper1=new Core_IPS_RDC_CommentsWrapper();
        objWrapper1.comments='Hello';
        objWrapper1.contactEmail=con.Email;
        Core_IPS_RDC_Comments_Handler test1 = new Core_IPS_RDC_Comments_Handler(system.now(), 'Case',objWrapper1);         
        test1.validateContact();
        
        
    }
    
 /****************************************************************************************************************************************
* Method Name  : validateContactCaseVisbility
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019               covers code for validateContact method in handler
***********************************************************************************************************/    
    
    static testmethod void validateContactCaseVisbility(){
        
        Account acc = [select id from account where name='newAcc1'];
        
        Contact con = [select id,email from contact where firstname='testFirstName123Q'];
        
        user u  = [select id,profile.Name from user where  profile.Name = 'System Administrator' AND isActive=true limit 1];
        
        User newUser = [select id from User where lastname='lastnamejill'];
        
        List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListOfIpsProjects;
        List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
        for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
            IpsAcc.Core_Account__c = acc.Id;
            IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        }
        insert ListOfIpsAccounts;
        
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
        for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
            ProjMem.Core_IPS_Contact__c  = con.Id;
            ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            ProjMem.Core_User__c = UserInfo.getUserId();
        }
        insert ListOfProjectMembers;
        
        Case caseObj=Core_RestAPI_TestUtilities.getCase(); 
        caseObj.Core_Sub_Status__c='Investigating';
        caseObj.OwnerId = adminUser.Id;
        caseObj.ContactId = con.id;
        caseObj.accountId = acc.Id;
        caseObj.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).Id;
        insert caseObj;
        
        Case c = [select Id,caseNumber,Core_IPS_Project_Case__c,accountId,ContactId from Case where id = : caseObj.id limit 1];
        
        Core_IPS_RDC_CommentsWrapper objWrapper1=new Core_IPS_RDC_CommentsWrapper();
        objWrapper1.comments='Hello';
        objWrapper1.contactEmail=con.Email;
        objWrapper1.caseNumber=c.CaseNumber;
        system.debug('-->objWrapper1'+objWrapper1);
        
        Core_IPS_RDC_Comments_Handler test1 = new Core_IPS_RDC_Comments_Handler(system.now(), 'Case',objWrapper1);
        test.starttest();
        test1.insertCaseComment();        
        test1.validateContact();
        test.stoptest();
        
    }

 /****************************************************************************************************************************************
* Method Name  : validateCaseTypeStatus
* Version     : 1.0 
* Created Date: 9/9/2019
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*IPS                        9/9/2019               covers code for validateCaseTypeStatus method in handler
***********************************************************************************************************/
    
    static testmethod void validateCaseTypeStatus(){
        
        Account acc = [select id from account where name='newAcc1'];
        
        Contact con = [select id,email from contact where firstname='testFirstName123Q'];
        
        user u  = [select id,profile.Name from user where  profile.Name = 'System Administrator' AND isActive=true limit 1];
        
        User newUser = [select id from User where lastname='lastnamejill'];
        
        List<RecordType> ObjRecordType = [Select Id from RecordType where name='IPS Closed Case'limit 1];
        
        Case caseObj1=Core_RestAPI_TestUtilities.getCase(); 
        caseObj1.Core_Sub_Status__c='Investigating';
        caseObj1.OwnerId = adminUser.Id;
        caseObj1.ContactId = con.id;
        caseObj1.accountId = acc.Id;
        caseObj1.RecordTypeID = ObjRecordType[0].id;
        insert caseObj1;
        
        Case c1 = [select Id,caseNumber,RecordTypeID,RecordType.Name,Core_IPS_Project_Case__c,accountId,ContactId from Case where id = : caseObj1.id limit 1];
        System.debug('-->c1'+c1);
        
        Core_IPS_RDC_CommentsWrapper objWrapper1=new Core_IPS_RDC_CommentsWrapper();
        objWrapper1.comments='Hello';
        objWrapper1.contactEmail=con.Email;
        objWrapper1.caseNumber=c1.CaseNumber;
        
        
        Core_IPS_RDC_Comments_Handler test1 = new Core_IPS_RDC_Comments_Handler(system.now(), 'Case',objWrapper1);
        test1.CreateCaseComments();
        test1.validateCaseTypeStatus();
        
    }
    
}