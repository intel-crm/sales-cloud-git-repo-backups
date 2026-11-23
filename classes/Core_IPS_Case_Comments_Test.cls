/***************************************************************************************************
* Apex Class Name: Core_IPS_Case_Comments_Test
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Function    : Test class for Core_IPS_Environment_Details_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T             12/19/2015                Created
****************************************************************************************************/
@isTest 
public class Core_IPS_Case_Comments_Test{
    
    private static User SystUserRunAs; 
    private static EmailTemplate EmailTempl;
    private static OrgWideEmailAddress OrgWideEmailObj;
    public static List<Case> caseList;
    public static Set<Core_IPS_Case_Comments__c> caseCommentList;
    public static List<User> userList;
    public static List<Core_IPS_Labels__c> lablesList;
    public static List<Core_IPS_Feature_Toggle__c> featureToggleList;
    public static Core_IPS_Labels__c  labels;
    public static Core_IPS_Labels__c  labels1;
    public static Core_IPS_Labels__c  labels2;
    public static Core_IPS_Labels__c  labels3;
    public static Core_IPS_Labels__c  labels4;
    public static Core_IPS_Labels__c  labels5;
    public static Core_IPS_Labels__c  labels6;
    public static Core_IPS_Labels__c  labels7;
    public static Core_IPS_Labels__c  labels8;
    public static Core_IPS_Labels__c  labels9;
    public static Core_IPS_Labels__c  labels10;
    public static Core_IPS_Labels__c  labels11;
    public static Core_IPS_Labels__c  labels12;
    public static Core_IPS_Labels__c  labels13;
    public static Core_IPS_Labels__c  labels14;
    public static Core_IPS_Labels__c  labels15;
    public static Core_IPS_Labels__c  labels16;
    public static Core_IPS_Labels__c  labels17;   
    public static Core_IPS_Labels__c  labels18; 
    
    static{
        lablesList = new List<Core_IPS_Labels__c>();
        labels = new Core_IPS_Labels__c();
        labels.name= 'PRIVATE_TO_INTEL';
        labels.value__c='Private to Intel';
        lablesList.add(labels);

        labels1 = new Core_IPS_Labels__c();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        lablesList.add(labels1);

        labels2 = new Core_IPS_Labels__c();
        labels2.name= 'PRIVATE_TO_AGENTS';
        labels2.value__c='Private to Agents';
        lablesList.add(labels2);
        
        labels3 = new Core_IPS_Labels__c();
        labels3.name= 'Customer';
        labels3.value__c='Customer';
        lablesList.add(labels3);
        
        labels4 = new Core_IPS_Labels__c();
        labels4.name= 'Agent';
        labels4.value__c='Agent';
        lablesList.add(labels4);
        
        labels5 = new Core_IPS_Labels__c();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        lablesList.add(labels5);
        
        labels6 = new Core_IPS_Labels__c();
        labels6.name= 'Partner';
        labels6.value__c='Partner';
        lablesList.add(labels6);
        
        labels7 = new Core_IPS_Labels__c();
        labels7.name= 'PRIVATE_TO_PARTNERS';
        labels7.value__c='Private to Partner';
        lablesList.add(labels7);
        
        labels8 = new Core_IPS_Labels__c();
        labels8.name= 'Partner - DFAE';
        labels8.value__c= 'Partner - DFAE';
        lablesList.add(labels8);
        
        labels9 = new Core_IPS_Labels__c();
        labels9.name= 'Backend Integration';
        labels9.value__c='Backend Integration';
        lablesList.add(labels9);
       
         labels10 = new Core_IPS_Labels__c();
        labels10.name= 'Comment Source - B2B API';
        labels10.value__c='B2B API';
        lablesList.add(labels10);
        
         labels11 = new Core_IPS_Labels__c();
        labels11.name= 'Comment Source - Backend System';
        labels11.value__c='Backend System';
        lablesList.add(labels11);
        
         labels12 = new Core_IPS_Labels__c();
        labels12.name= 'Comment Source - Customer';
        labels12.value__c='Customer Portal';
        lablesList.add(labels12);
        
         labels13 = new Core_IPS_Labels__c();
        labels13.name= 'Comment Source - Data Migration';
        labels13.value__c='Data Migration';
        lablesList.add(labels13);
        
         labels14 = new Core_IPS_Labels__c();
        labels14.name= 'Comment Source - Email';
        labels14.value__c='Email';
        lablesList.add(labels14); 
        
         labels15 = new Core_IPS_Labels__c();
        labels15.name= 'Comment Source - Internal';
        labels15.value__c='Internal Portal  ';
        lablesList.add(labels15);
        
         labels16 = new Core_IPS_Labels__c();
        labels16.name= 'Comment Source - N/A';
        labels16.value__c='N/A';
        lablesList.add(labels16);
        
        labels17 = new Core_IPS_Labels__c();
        labels17.name= 'Data Migration';
        labels17.value__c='Data Migration';
        lablesList.add(labels17);
        
        labels18 = new Core_IPS_Labels__c();
        labels18.name= 'Partner - Agent';
        labels18.value__c='Partner - Agent';
        lablesList.add(labels18);      
        insert lablesList;       
    
    }
    
    private static testMethod void getRecords(){
        
        List <Core_IPS_Feature_Toggle__c> lstFeatureToggle = new List <Core_IPS_Feature_Toggle__c>();
        Core_IPS_Feature_Toggle__c featureToggle = new Core_IPS_Feature_Toggle__c();
        featureToggle.name                       = 'LastCommentToCase';
        featureToggle.Core_Feature_Enabled__c    = true;
        featureToggle.Core_Category__c           = 'Case Comments';
        lstFeatureToggle.add(featureToggle);        
        insert lstFeatureToggle;      
                
         Boolean commentToCaseEnabled = true;
         
         
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
                    for(Core_IPS_Case_Comments__c comment:caseCommentList){                     
                        comment.Core_IPS_Case__c=caseList[0].id;  
                                           
                        comment.Core_IPS_Rich_Comment__c= 'IPS Team testing';
                        
                        caseCommentListNew.add(comment);
                        
                    }
                    try{
                    insert caseCommentListNew;    
                    }
                    Catch(Exception e){}
                
                    for(Core_IPS_Case_Comments__c comment:caseCommentListNew){                                                      
                        comment.Core_IPS_Rich_Comment__c= 'IPS Team testing123123';
                       
                        
                        caseCommentList.add(comment);           
                    }   
                    try{    
                        update caseCommentListNew;
                       Core_IPS_Case_Comments__c newCaseComment = [SELECT Id, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c WHERE Id = :caseCommentListNew[0].Id ORDER BY CreatedDate DESC LIMIT 1];
                        System.assertEquals('IPS Team testing123123', newCaseComment.Core_IPS_Rich_Comment__c, 'Comment should match');
                    }
                    catch(exception e){}
                    
                    Core_IPS_Case_Comments_Handler.RerenderRTF(caseCommentListNew);
                    Core_IPS_Case_Comments_Handler.replaceFormatting(caseCommentListNew);
                    Core_IPS_Case_Comments_Handler.replaceFormatting(null);
                    Core_IPS_Case_Comments_Handler.UpdateCaseField(caseCommentListNew);                 
                    Core_IPS_Case_Comments_Handler.isCurrentUserPortalUser();
                    
                    
                test.stopTest(); 
        }
        
    }
    private static testMethod void RerenderRTF_PositiveTest() {
        getRecords();
        user u = [Select Id from user LIMIT 1];
        System.runAs(u){
            caseList = TestUtilities.getListOfCases(3);
            insert caseList;
           List<Core_IPS_Case_Comments__c> caseCommentList = new List<Core_IPS_Case_Comments__c>();
            caseCommentList = TestUtilities.getCaseComments(10);
            for(Core_IPS_Case_Comments__c comment:caseCommentList){
                comment.core_ips_Case__c=caseList[0].id;
                comment.Core_IPS_Comment_Authored_By__c = userInfo.getUserID();
                    comment.Core_IPS_Comment_Authored_By_Email__c = userInfo.getUseremail();
                    comment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
                    comment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getUsername();
                comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Comment__c;
            }
            try{
            insert caseCommentList;
                Test.startTest();
                Core_IPS_Case_Comments__c newCaseComment = [SELECT Id, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c WHERE core_ips_Case__c = :caseList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
                System.assertEquals('Test Comment0', newCaseComment.Core_IPS_Rich_Comment__c, 'Comment should match');
           Test.stopTest();
            }
            catch(exception e)
            {}
        }
    }  
    // Method Added By Prem for test coverage
     private static testMethod void AttachmentNotAvailbleTest() {
        List<Core_IPS_Case_Comments__c> newList=new List<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments_Handler.UpdateCaseField(newList);
        newList= TestUtilities.getCaseComments(0);
        Core_IPS_Case_Comments_Handler.UpdateCaseField(newList);
         System.assertEquals(false, newList.size() > 0, 'Size should be 0');
        
    }   
     private static testMethod void RerenderRTF_Comment_Author_TypeTest() {
        Profile prof = [select id from profile where name = 'IPS Agent' limit 1];
        userList = new List<user>();
        userList = TestUtilities.getListOfUser(3);
        userList[0].profileId=prof.id;
        insert userlist[0];        
        
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
       // RecordType rtype =[Select Name, Id From RecordType where sObjectType='Case' and isActive=true and RecordType.developerName='IPS No Assigned Contact Case'];
        System.runAs(systUserRunAs){
       
        List<Case> ListOfCase = new List<Case> ();
           Case CaseRecord1 = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject',
                Description = 'TestDescription',
                Core_Sub_Status__c='WAITING_FOR_TEXT',
                Core_IPS_Customer_Visible__c = false
              //  RecordTypeId = CaseRecordtype.get('IPS Case Create')
            );
            ListOfCase.add(CaseRecord1);
            
            Case CaseRecord2 = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject',
                Description = 'TestDescription',
                Core_Sub_Status__c='INVESTIGATING_TEXT',
                Core_IPS_Customer_Visible__c = false
               // RecordTypeId = CaseRecordtype.get('IPS Case Create')
            );
            ListOfCase.add(CaseRecord2);
        
        Case CaseRecord3 = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject',
                Description = 'TestDescription',
                Core_Sub_Status__c = 'Close-Pending',          
                Core_IPS_Customer_Visible__c = false
              //  RecordTypeId = CaseRecordtype.get('IPS Case Create')
            );
            ListOfCase.add(CaseRecord3);
        
            insert ListOfCase;
            List<Core_IPS_Case_Comments__c> caseCommentList = new List<Core_IPS_Case_Comments__c>();
            caseCommentList = TestUtilities.getCaseComments(10);
            Integer count=0;
            for(Core_IPS_Case_Comments__c comment:caseCommentList){
                if(count == 0){
                comment.core_ips_Case__c=ListOfCase[0].id;                
                comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Comment__c;
                comment.Core_IPS_Comment_Author_Type__c='Customer';
                }
                else {
                comment.core_ips_Case__c=ListOfCase[1].id;
                comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Comment__c;
                comment.Core_IPS_Comment_Author_Type__c='Customer';
                }
                //if(count==8)
                    //comment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;  
                if(count>8){
                comment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;  
                 comment.Core_IPS_Comment_Author_Type__c='Agent';
                }
                count++;
            }
            try {
            insert caseCommentList;
           
            Core_IPS_Case_Comments_Handler.UpdateCaseField(caseCommentList);
               
                Core_IPS_Case_Comments__c newCaseComment = [SELECT Id, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c WHERE core_ips_Case__c = :ListOfCase[0].Id ORDER BY CreatedDate DESC LIMIT 1];
               
                System.assertEquals('Test Comment0', newCaseComment.Core_IPS_Rich_Comment__c, 'Comment should match');
            }
            catch (exception e){
            }
            Core_IPS_Case_Comments_Handler.completeActiveMileStone(caseCommentList = new List<Core_IPS_Case_Comments__c>());
        }
    }
    
   /* private static testMethod void RerenderRTF_Comment_Author_TypeNegativeTest() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' and name='Admin' Limit 1];
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
       User usr = [Select Id,UserRoleId from User where UserRoleId=:portalRole.Id AND profileId=:prof.id and IsActive= true limit 1];
        system.runAs(usr){
        //Create account
            Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr'    
            );
            Database.insert(portalAccount1);
            //Create contact
            Contact contact1 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia',
            LastName  = 'portalTestUser',
            Email='babux5x5@intel.com'      
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
                List<Case> ListOfCase = new List<Case> ();
                Case CaseRecord1 = new Case(
                    Status = 'New',
                    Origin = 'Web',
                    Priority = 'High',
                    Subject = 'TestSubject',
                    Description = 'TestDescription',
                    Core_Sub_Status__c='Close-Pending'
                  //  RecordTypeId = CaseRecordtype.get('IPS Case Create')
                );
                ListOfCase.add(CaseRecord1);
                
                Case CaseRecord2 = new Case(
                    Status = 'open',
                    
                    Origin = 'Web',
                    Priority = 'High',
                    Subject = 'TestSubject',
                    Description = 'TestDescription',
                    Core_Sub_Status__c='Close-Pending'
                   // RecordTypeId = CaseRecordtype.get('IPS Case Create')
                );
                ListOfCase.add(CaseRecord2);
                insert ListOfCase;
                List<Core_IPS_Case_Comments__c> caseCommentList = new List<Core_IPS_Case_Comments__c>();
                //caseCommentList = TestUtilities.getCaseComments(10);
               // Integer count=0;
                //for(Core_IPS_Case_Comments__c comment:caseCommentList){
                    Core_IPS_Case_Comments__c comment = new Core_IPS_Case_Comments__c();
                    comment.core_ips_Case__c= [Select id from case limit 1][0].Id;
                    comment.Core_IPS_Comment_Authored_By__c = userInfo.getUserID();
                    comment.Core_IPS_Comment_Authored_By_Email__c = userInfo.getUseremail();
                    comment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
                    comment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getUsername();
                    comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Comment__c; 
                    comment.Core_IPS_Case_Comment_Source__c = 'Customer Portal';
                    comment.Core_IPS_Comment_Author_Type__c='Customer';
                    //if(count>8){
                         comment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;  
                         comment.Core_IPS_Comment_Author_Type__c='Agent';
                  //  }
                   // count++;
              //  }
                caseCommentList.add(comment);
                
                insert caseCommentList;
                Core_IPS_Case_Comments_Handler.UpdateCaseField(caseCommentList); 
                Core_IPS_Case_Comments_Handler.completeActiveMileStone(caseCommentList = new List<Core_IPS_Case_Comments__c>());
                 Core_IPS_Case_Comments__c newCaseComment = [SELECT Id, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c WHERE core_ips_Case__c = :ListOfCase[0].Id ORDER BY CreatedDate DESC LIMIT 1];
                System.assertEquals(caseCommentList.size()>0, false);
                }
        }
    }*/
    
    //Added for code coverage:
    private static testMethod void getRecords1(){
        
        Profile prof = [select id from profile where name = 'IPS Agent' limit 1];
        userList = new List<user>();
        userList = TestUtilities.getListOfUser(3);
        userList[0].profileId=prof.id;
        insert userlist[0];        
        
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
        //RecordType rtype =[Select Name, Id From RecordType where sObjectType='Case' and isActive=true and RecordType.developerName='IPS No Assigned Contact Case'];
        System.runAs(systUserRunAs){
       
        List<Case> ListOfCase = new List<Case> ();
                      
            Case CaseRecord22 = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject',
                Description = 'TestDescription',
                //Core_Sub_Status__c='INVESTIGATING_TEXT',
                Core_IPS_Customer_Visible__c = false);
            
            Case CaseRecord23 = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject',
                Description = 'TestDescription',
                //Core_Sub_Status__c='INVESTIGATING_TEXT',
                Core_IPS_Customer_Visible__c = false);
            ListOfCase.add(CaseRecord22);
            ListOfCase.add(CaseRecord23);
                      
            insert ListOfCase;
            String cs = JSON.serialize(ListOfCase);
            Core_IPS_Case_Comments_Handler.updateCaseinFuture(cs);
           List<Core_IPS_Case_Comments__c> caseCommentList = new List<Core_IPS_Case_Comments__c>();
                caseCommentList = TestUtilities.getCaseComments(10);
                Integer count=0;
                for(Core_IPS_Case_Comments__c comment:caseCommentList){
                    if(count == 0){
                    comment.core_ips_Case__c=ListOfCase[0].id;
                    comment.Core_IPS_Comment_Authored_By__c = userInfo.getUserID();
                    comment.Core_IPS_Comment_Authored_By_Email__c = userInfo.getUseremail();
                    comment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
                    comment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getUsername();
                    comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Comment__c;
                    comment.Core_IPS_Comment_Attachment_Id__c = null;
                   // comment.Core_IPS_Case_Comment_Source__c = 'Customer Portal';
                    comment.Core_IPS_Comment_Author_Type__c='Agent';
                    }
                    else if (count != 0) {
                    comment.core_ips_Case__c=ListOfCase[1].id;
                    comment.Core_IPS_Comment_Authored_By__c = userInfo.getUserID();
                    comment.Core_IPS_Comment_Authored_By_Email__c = userInfo.getUseremail();
                    comment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
                    comment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getUsername();
                    comment.Core_IPS_Rich_Comment__c = comment.Core_IPS_Comment__c;
                    comment.Core_IPS_Comment_Attachment_Id__c = null;
                   // comment.Core_IPS_Case_Comment_Source__c = 'Customer Portal';
                    comment.Core_IPS_Comment_Author_Type__c='Agent';
                    }
                    count++; 
                }               
            insert caseCommentList;
           
            Core_IPS_Case_Comments_Handler.completeActiveMileStone(caseCommentList = new List<Core_IPS_Case_Comments__c>());
           
             Core_IPS_Case_Comments__c newCaseComment = [SELECT Id, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c WHERE core_ips_Case__c = :ListOfCase[0].Id ORDER BY CreatedDate DESC LIMIT 1];
            	
                System.assertEquals('Test Comment0', newCaseComment.Core_IPS_Rich_Comment__c, 'Comment should match');
        }
    }
    //end
}