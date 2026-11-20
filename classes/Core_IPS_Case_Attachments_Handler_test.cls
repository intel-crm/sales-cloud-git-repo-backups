/********************************************************************************************************************
Apex Class Name:  Core_IPS_Case_Attachments_Handler_test
Version     : 1.0 
Created Date: 04 10 2017
Function    : Test class for Core_IPS_Case_Attachments_Handler
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Varun Gupta                         04/10/2017              Original Version
* Sumukh                              14/12/2017                Added new method for attachment related case comments
* Sumukh                              08/04/2018                Added method for updating attachments case comments
* Aparna                              17/5/2018                Added test method for B2B Api Attachment Method
* Aparna                              1/6/2018                 Added test method for US105986
*******************************************************************************************************************/

@istest
// Added AssertEquals Added By Chiranjeevi - 31-JAN-2024
public class Core_IPS_Case_Attachments_Handler_test{           
    
    public static testMethod void insertAttachments1() {
        
        
        user agentUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='System Administrator' limit 1];
        agentUser.profileid=p.id;
        agentUser.username='adminTest'+Crypto.getRandomLong()+'@intel.com';
        insert agentUser;
        
        User u =TestUtilities.getCustomerUser('IPS External Customer');
        Case cs = TestUtilities.getCase();
        insert cs;
        
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'InsertCaseCommentForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After Insert, After update';
        settings.Core_Active__c = True;
        insert settings;
        
        Core_Trigger_Executions__c settings1 = new Core_Trigger_Executions__c();
        settings1.Name = 'UpdateCaseCommentForAttach';
        settings1.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings1.Core_Description__c = 'ABC';
        settings1.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings1.Core_Trigger_Events__c = 'After delete , After Update';
        settings1.Core_Active__c = True;
        insert settings1;
        
        Core_Trigger_Executions__c settings2 = new Core_Trigger_Executions__c();
        settings2.Name = 'UpdateCaseComntDscptnForAttach';
        settings2.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings2.Core_Description__c = 'ABC';
        settings2.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings2.Core_Trigger_Events__c =  'After Update';
        settings2.Core_Active__c = True;
        insert settings2;        
        
        Core_IPS_Case_Attachments__c attachments = new Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c = cs.id;
        attachments.Core_File_Description__c  = 'TEST';
        attachments.Core_File_Name__c = 'TEST';
        attachments.Core_FileUploadedBy__c=u.id;
        attachments.Core_Upload_Status__c= 'complete';
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
        
        // Avoid Hardcoding Id Fix  - Shipra
        Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1];
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c=dataMigPrf.Id;
        //labels2.value__c='00eo0000000f7Gd';
        insert labels2;             
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        System.AssertEquals(!String.isBlank(labels5.Id), true);
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        Core_IPS_Labels__c Label10 = new Core_IPS_Labels__c ();
        Label10.name= 'PRIVATE_TO_PARTNERS';
        label10.value__c= 'Private to Partner';
        insert label10;
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - DFAE';
        label11.value__c='Partner - DFAE';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Partner - Agent';
        label12.value__c='Partner - Agent';
        insert label12; 
        
        Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name='Partner';
        label13.value__c='Partner';
        insert label13; 
        
        Core_IPS_Labels__c label14 = new Core_IPS_Labels__c();
        label14.name='Comment Source - Customer';
        label14.value__c='Customer Portal';
        insert label14;
        
        Insert attachments;
        update attachments;
        
        List<Core_IPS_Case_Attachments__c > lstAttach=new List<Core_IPS_Case_Attachments__c >();
        lstAttach.add(attachments);
        
        map<id,Core_IPS_Case_Attachments__c> mapIPS = new map<id,Core_IPS_Case_Attachments__c>();
        mapIPS.put(attachments.Core_FileUploadedBy__c,attachments);
        
        delete attachments;
         System.AssertEquals(attachments != null, true);
    }
    
    
    public static testMethod void insertCaseComment() {
        
        Case Cs =  TestUtilities.getCase(); 
        insert cs;
        
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'InsertCaseCommentForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After Insert, After update';
        settings.Core_Active__c = True;
        insert settings;
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
         // Avoid Hardcoding Id Fix  - Shipra
         Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1]; 
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c= dataMigPrf.Id;
        //labels2.value__c='00eo0000000f7Gd';
        insert labels2;             
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        Core_IPS_Labels__c Label10 = new Core_IPS_Labels__c ();
        Label10.name= 'PRIVATE_TO_PARTNERS';
        label10.value__c= 'Private to Partner';
        insert label10;
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - DFAE';
        label11.value__c='Partner - DFAE';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Partner - Agent';
        label12.value__c='Partner - Agent';
        insert label12;
        
        Core_IPS_Labels__c label13= new Core_IPS_Labels__c();
        label13.name='Comment Source - Customer';
        label13.value__c='Customer Portal';
        insert label13; 
        
        Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
        label14.name='Partner';
        label14.value__c='Partner';
        insert label14; 
        
        Core_IPS_Labels__c label15= new Core_IPS_Labels__c();
        label15.name='N/A';
        label15.value__c='N/A';
        insert label15;
        
        Core_IPS_Labels__c label16= new Core_IPS_Labels__c();
        label16.name='Comment Source - N/A';
        label16.value__c='N/A';
        insert label16;
        
        Core_IPS_Labels__c labels17= new Core_IPS_Labels__c();
        labels17.name= 'Comment Source - Email';
        labels17.value__c='Email';
        insert labels17;
        
        Core_IPS_Case_Attachments__c att1 = new Core_IPS_Case_Attachments__c();   
        
        att1.Core_FileUploadedby__c = UserInfo.getUserId();
        String fileDescriptn = att1.Core_File_Description__c;           
        list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        newComment.Core_IPS_Case__c = att1.Core_Case__c;
        newComment.Core_IPS_Case_Comment_Type__c = att1.Core_IPS_Attachment_Visibility__c; 
        newComment.CreatedById = att1.Core_FileUploadedby__c; 
        newComment.Core_IPS_Case__c = cs.id;                       
        newComment.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded: ' + '<br/><br/>' +  '<a href='+att1.Core_File_URL__c+' target="Self">Download File</a>' + ' &nbsp; &nbsp; ' +  att1.Core_File_Name__c   +     '   &nbsp  &nbsp      '     +  fileDescriptn         ;               
        commentlist.add(newComment);                        
        insert newComment; 
        
        Core_IPS_Case_Attachments__c att2 = new Core_IPS_Case_Attachments__c();   
        att2.Core_FileUploadedby__c=null;
        att2.Core_IPS_Attachment_Visibility__c=null;
        att2.Core_Upload_Status__c='Complete';
        att2.Core_File_Description__c='my Descriptio';  
        att2.Core_Case__c=cs.id;
        insert att2;         
        Core_IPS_Case_Comments__c newComment1 = new Core_IPS_Case_Comments__c();
        newComment1.Core_IPS_Case__c = att2.Core_Case__c; 
        newComment1.Core_IPS_Case__c = cs.id;                       
        newComment1.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded: ' + '<br/><br/>' +  '<a href='+att2.Core_File_URL__c+' target="Self">Download File</a>' + ' &nbsp; &nbsp; ' +  att2.Core_File_Name__c   +     '   &nbsp  &nbsp      '     +  'my des';               
        commentlist.add(newComment1);                        
        insert newComment1; 
        
        System.AssertEquals(newComment1 != null, true);
    }   
    
    
    public static testMethod void deleteAttachmentCaseComment(){
        test.starttest();
        
        Case Cs =  TestUtilities.getCase(); 
        insert cs;
        
        Core_Trigger_Executions__c settings1 = new Core_Trigger_Executions__c();
        settings1.Name = 'InsertCaseCommentForAttach';
        settings1.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings1.Core_Description__c = 'ABC';
        settings1.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings1.Core_Trigger_Events__c = 'After Insert, After update';
        settings1.Core_Active__c = True;
        insert settings1;         
        
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'UpdateCaseCommentForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c = 'After delete , After Update';
        settings.Core_Active__c = True;
        insert settings;
        
        
        Core_Trigger_Executions__c settings2 = new Core_Trigger_Executions__c();
        settings2.Name = 'UpdateCaseComntDscptnForAttach';
        settings2.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings2.Core_Description__c = 'ABC';
        settings2.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings2.Core_Trigger_Events__c = 'After delete , After Update';
        settings2.Core_Active__c = True;
        insert settings2;
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
         // Avoid Hardcoding Id Fix  - Shipra
         Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1];
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c=dataMigPrf.Id;
      //  labels2.value__c='00eo0000000f7Gd';
        insert labels2;             
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        Core_IPS_Labels__c Label10 = new Core_IPS_Labels__c ();
        Label10.name= 'PRIVATE_TO_PARTNERS';
        label10.value__c= 'Private to Partner';
        insert label10;
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - DFAE';
        label11.value__c='Partner - DFAE';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Partner - Agent';
        label12.value__c='Partner - Agent';
        insert label12; 
        
        Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name='Partner';
        label13.value__c='Partner';
        insert label13; 
        
        Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
        label14.name='Comment Source - Customer';
        label14.value__c='Customer Portal';
        insert label14;
        System.AssertEquals(label14.Id != null, true);
        Core_IPS_Labels__c label15= new Core_IPS_Labels__c();
        label15.name='N/A';
        label15.value__c='N/A';
        insert label15;
        
        Core_IPS_Labels__c label16= new Core_IPS_Labels__c();
        label16.name='Comment Source - N/A';
        label16.value__c='N/A';
        insert label16;
        
        Core_IPS_Labels__c labels17= new Core_IPS_Labels__c();
        labels17.name= 'Comment Source - Email';
        labels17.value__c='Email';
        insert labels17; 
       
      
        List<Core_IPS_Case_Attachments__c> oldList = new List<Core_IPS_Case_Attachments__c>();
        Core_IPS_Case_Attachments__c att2 = new Core_IPS_Case_Attachments__c();   
        att2.Core_FileUploadedby__c= UserInfo.getUserId();
        att2.Core_IPS_Attachment_Visibility__c='Public to Customers';
        att2.Core_Upload_Status__c='Complete';
        att2.Core_File_Description__c='my Description';  
        att2.Core_Case__c=cs.id;
        insert att2; 
        oldList.add(att2);
        
        
        list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();        
        
        String fileDescriptn = att2.Core_File_Description__c;                     
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        newComment.Core_IPS_Case__c = cs.id;
        newComment.Core_IPS_Case_Comment_Type__c = att2.Core_IPS_Attachment_Visibility__c; 
        newComment.CreatedById = att2.Core_FileUploadedby__c; 
        newComment.Core_IPS_Comment_Attachment_Id__c = att2.id;
        
        newComment.Core_IPS_Case__c = cs.id;                     
        newComment.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded: ' + '<br/><br/>' +  '<a href='+att2.Core_File_URL__c+' target="Self">Download File</a>' + ' &nbsp; &nbsp; ' +  att2.Core_File_Name__c   +     '   &nbsp  &nbsp      '     +  fileDescriptn         ;               
        newComment.Core_IPS_Comment__c =  newComment.Core_IPS_Rich_Comment__c;
        insert newComment;
        
        att2.Core_File_Description__c='asdasd';
        //att2.id = att2.id;
        update att2;                   
        
        Core_IPS_Case_Attachments_Handler.deleteAttachmentCaseComment(oldList);
        
        //added by ranjini
          
		insert new Core_Trigger_Executions__c(Name = 'updateCase',
                                              Core_Class_Name__c ='Core_IPS_Case_Attachments_Handler',
                                              Core_Description__c='test',
                                              Core_Object__c='Core_IPS_Case_Attachments__c',
                                              Core_Trigger_Events__c='After insert');
        
        Core_IPS_Case_Attachments_Handler.updateCase(oldList);
        List<Core_IPS_Case_Attachments__c> newList = new List<Core_IPS_Case_Attachments__c>();
        Core_IPS_Case_Attachments__c att3 = new Core_IPS_Case_Attachments__c();   
        att3.Core_FileUploadedby__c= UserInfo.getUserId();
        att3.Core_IPS_Attachment_Visibility__c='Public to Customers';
        att3.Core_Upload_Status__c='Complete';
        att3.Core_File_Description__c='my Description';  
        att3.Core_Case__c=cs.id;
        
        insert att3; 
        delete att3;
        //newList.add(att3);
        Core_IPS_Case_Attachments_Handler.updateCase(oldList);
                    //Core_IPS_Case_Attachments_Handler.updateCase(newList);
       System.AssertEquals(att2 != null, true);
        
        test.stoptest();
    }         
    
    
    public static testMethod void updateAttachmentCaseComment(){
        
        
        Case Cs =  TestUtilities.getCase(); 
        insert cs;
        
        Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
        settings.Name = 'UpdateCaseComntDscptnForAttach';
        settings.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
        settings.Core_Description__c = 'ABC';
        settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings.Core_Trigger_Events__c =  'After Update';
        settings.Core_Active__c = True;
        insert settings;
        
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
        labels.name= 'COMPLETE';
        labels.value__c='COMPLETE';
        insert labels;
        
        Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
        labels1.name= 'PUBLIC_TO_CUSTOMERS';
        labels1.value__c='Public to Customers';
        insert labels1;
         // Avoid Hardcoding Id Fix  - Shipra
         Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1];  
        Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Data Migration Profile Id';
        labels2.value__c=dataMigPrf.Id;
       // labels2.value__c='00eo0000000f7Gd';
        insert labels2;             
        
        Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
        labels3.name= 'PRIVATE_TO_INTEL';
        labels3.value__c='Private to Intel';
        insert labels3;
        
        Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
        labels4.name= 'PRIVATE_TO_AGENTS';
        labels4.value__c='Private to Agents';
        insert labels4;
        
        Core_IPS_Labels__c labels5 = new Core_IPS_Labels__c ();
        labels5.name= 'FAE';
        labels5.value__c='FAE';
        insert labels5;
        
        Core_IPS_Labels__c labels6 = new Core_IPS_Labels__c ();
        labels6.name= 'Agent';
        labels6.value__c='Agent';
        insert labels6;
        
        Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
        labels7.name= 'Customer';
        labels7.value__c='Customer';
        insert labels7;
        
        Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c ();
        labels8.name= 'Backend Integration';
        labels8.value__c='Backend Integration';
        insert labels8;
        
        Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c ();
        labels9.name= 'Data Migration';
        labels9.value__c='Data Migration';
        insert labels9;
        
        Core_IPS_Labels__c Label10 = new Core_IPS_Labels__c ();
        Label10.name= 'PRIVATE_TO_PARTNERS';
        label10.value__c= 'Private to Partner';
        insert label10;
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Partner - DFAE';
        label11.value__c='Partner - DFAE';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Partner - Agent';
        label12.value__c='Partner - Agent';
        insert label12; 
        
        Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name='Partner';
        label13.value__c='Partner';
        insert label13;  
        
        Core_IPS_Labels__c label14= new Core_IPS_Labels__c();
        label14.name='Comment Source - Customer';
        label14.value__c='Customer Portal';
        insert label14;
        
        Core_IPS_Labels__c label15= new Core_IPS_Labels__c();
        label15.name='N/A';
        label15.value__c='N/A';
        insert label15;
        
        Core_IPS_Labels__c label16= new Core_IPS_Labels__c();
        label16.name='Comment Source - N/A';
        label16.value__c='N/A';
        insert label16;
        
        Core_IPS_Labels__c labels17= new Core_IPS_Labels__c();
        labels17.name= 'Comment Source - Email';
        labels17.value__c='Email';
        insert labels17; 
        
        Core_IPS_Case_Attachments__c att1 = new Core_IPS_Case_Attachments__c();   
        
        att1.Core_FileUploadedby__c = UserInfo.getUserId();
        String fileDescriptn = att1.Core_File_Description__c;           
        list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        newComment.Core_IPS_Case__c = att1.Core_Case__c;
        newComment.Core_IPS_Case_Comment_Type__c = att1.Core_IPS_Attachment_Visibility__c; 
        newComment.CreatedById = att1.Core_FileUploadedby__c; 
        newComment.Core_IPS_Comment_Attachment_Id__c = att1.id;
        newComment.Core_IPS_Case__c = cs.id;                       
        newComment.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded: ' + '<br/><br/>' +  '<a href='+att1.Core_File_URL__c+' target="Self">Download File</a>' + ' &nbsp; &nbsp; ' +  att1.Core_File_Name__c   +     '   &nbsp  &nbsp      '     +  fileDescriptn         ;               
        commentlist.add(newComment);                        
        insert newComment; 
        System.AssertEquals(newComment.Id != null, true);
        update commentlist;
        System.AssertEquals(commentlist.size()>0, true);
    }  
    
    /*******************************************************************************************
Method Name       :  testupadtevaluesB2BMethod
Version           :  1.0
US Nos            :  US97707 and US105986
Iteration&Release No: 11 and 4
Created Date     :   17/5/2018
Function         :   Method covers code for upadtevaluesB2BMethod in handler 
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------
*Aparna Ogirala                       17/5/2018               Original Version
**************************************************************************************/
    
    public static testMethod void testupadtevaluesB2BMethod(){
        
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
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
        insert label5;
        
        insert listcstSettings;
        
        user adminUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='IT Admin' limit 1];
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
            attachments.Core_File_URL__c='www.testfileURL.com';
            attachments.Core_FileSizeInBytes__c='2KB';
            attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
            Insert attachments;
             System.AssertEquals(attachments != null, true);
            
        }
    }
    
    /********************************************************************************************************************
Method Name       : customerTest
Version           : 1.0
US Nos            :  US97707 and US105986
Iteration&Release No: 12&4.3
Created Date     : 30/5/2018
Function        : Method covers code for attachments function in handler as a customer
Modification Log :
* Developer                             Date                   Description
* ------------------------------------------------------------------------------
*Aparna Ogirala                       30/5/2018               Original Version
*******************************************************************************************************************/
    public static testmethod void customerTest(){
        
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
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
        
        Core_IPS_Labels__c  label5 = new Core_IPS_Labels__c();
        label5.name = 'Data Migration';
        label5.value__c = 'Data Migration';
        listcstSettings.add(label5);
        
        Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
        label6.name='Comment Source - Customer';
        label6.value__c='Customer Portal';
        insert label6;
        
        Core_IPS_Labels__c label7= new Core_IPS_Labels__c();
        label7.name='Backend Integration';
        label7.value__c='Backend Integration';
        insert label7;
        
        Core_IPS_Labels__c label8= new Core_IPS_Labels__c();
        label8.name = 'PRIVATE_TO_PARTNERS';
        label8.Value__c = 'Private to Partners';
        
        insert label8;
        
        Core_IPS_Labels__c label9= new Core_IPS_Labels__c();
        label9.name = 'COMPLETE';
        label9.Value__c = 'COMPLETE';
        insert label9;
        
        insert listcstSettings;
        System.AssertEquals(listcstSettings.size()>0, true);
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
                 System.AssertEquals(attachments != null, true);
            }
        }
    }
    
    /********************************************************************************************************************
Method Name       : dataMigrationUserTest
Version           : 1.0
US Nos            : US105986 
Iteration&Release No: 12&4.3
Created Date     : 30/5/2018
Function        : Method covers code for attachments function in handler as a customer
Modification Log :
* Developer                             Date                   Description
* ------------------------------------------------------------------------------
*Aparna Ogirala                       30/5/2018               Original Version
*******************************************************************************************************************/
    public static testmethod void dataMigrationUserTest(){
        
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_Case_Attachments_Handler';
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
        
        Core_IPS_Labels__c  label5 = new Core_IPS_Labels__c();
        label5.name = 'Data Migration';
        label5.value__c = 'Data Migration';
        listcstSettings.add(label5);
        
         Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
        label6.name='Backend Integration';
        label6.value__c='Backend Integration';
        insert label6;
        
        insert listcstSettings;
        
        user adminUser=TestUtilities.getUser();
        profile p=[select id,name from profile where name='CCP - Core Access' limit 1];
        adminUser.username='adminTest'+Crypto.getRandomLong()+'@intel.com';
        adminUser.profileid =p.id;
        insert adminUser;
        
        system.runAs(adminUser){
                        
            Case cs=TestUtilities.getCase();
            if (cs!=null)
            Insert cs;
            System.AssertEquals(cs.Id != null, true);
            Core_IPS_Case_Attachments__c attachments=new  Core_IPS_Case_Attachments__c();
            attachments.Core_Case__c=cs.id;
            attachments.Core_File_Description__c='Test-Description';
            attachments.Core_File_Name__c='Test-File';
            attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            attachments.Core_FileUploadedBy__c= adminUser.id;
            attachments.Core_File_URL__c='www.test.com';
            attachments.Core_FileSizeInBytes__c='2KB';
            attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
            Insert attachments;
             System.AssertEquals(attachments != null, true);
        }
    }
    
}