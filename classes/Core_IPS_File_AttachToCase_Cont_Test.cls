@isTest
private class Core_IPS_File_AttachToCase_Cont_Test
{
    /***************************************************************************************************
    Method Name:  testAttachment
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Description:   
    Scenario Type: Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              11/07/2015              Created
    ****************************************************************************************************/
    static testMethod void testAttachment() {
        Case c=new Case();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        Core_IPS_File_AttachToCase_Controller testAccPlan = new Core_IPS_File_AttachToCase_Controller(sc);
        
        PageReference pref = Page.Core_IPS_File_AttachToCase;
        Test.setCurrentPage(pref);
        
        Core_IPS_File_AttachToCase_Controller  cpfa=new Core_IPS_File_AttachToCase_Controller ();
        
        Test.startTest();
        pref = cpfa.saveAndReturn();
        Test.stopTest(); 

    }
    
    /***************************************************************************************************
    Method Name:  testAttachment1
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 07 Nov 2015
    Description:   
    Scenario Type: Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Vaibhav Dubey              11/07/2015              Created
    ****************************************************************************************************/
    static testMethod void testAttachment1() {
        
        Case c= TestUtilities.getcase();
        insert c;
                
        PageReference pref = Page.Core_IPS_File_AttachToCase;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('Id',c.id);
        
        Core_IPS_File_AttachToCase_Controller  cpfa=new Core_IPS_File_AttachToCase_Controller ();
        
        Test.startTest();
        pref = cpfa.saveAndReturn();
        Test.stopTest(); 

    }
 
/***************************************************************************************************
    Method Name        :  testAttachment2
    Method Type        : Test Method
    Version            : 1.0 
    Created Date       : 5/12/2017 
    Feature No         :  F5427
    US No              :  US79603
    Iteration&Release No: 3 & 2
    Description        :  Covers code for attachment visibility function if public/private in Apex Class Core_IPS_File_AttachToCase_Controller  
    Scenario Type      : Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    *Aparna                     5/12/2017                   Created
 ****************************************************************************************************/
 
    static testMethod void testAttachment2() {
        
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_File_AttachToCase_Controller';
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
        
        Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
        label6.name='Comment Source - Email';
        label6.value__c='Email';
        listcstSettings.add(label6);
        
        Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
         label7.name='Data Migration';
         label7.value__c='Data Migration';
        listcstSettings.add(label7);
        
        Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
         label8.name='FAE';
         label8.value__c='FAE';
        listcstSettings.add(label8);
        
         Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
         label9.name='Partner - Agent';
         label9.value__c='Partner - Agent';
         listcstSettings.add(label9);   
        
        Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
         label10.name='Customer';
         label10.value__c='Customer';
         listcstSettings.add(label10);
        
         Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
         label11.name='Comment Source - N/A';
         label11.value__c='n/a';
         listcstSettings.add(label11);
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
         label12.name='Partner - DFAE';
         label12.value__c='Partner - DFAE';
         listcstSettings.add(label12);
                
         insert listcstSettings;
        
          user agentUser=TestUtilities.getUser();
          profile p=[select id,name from profile where name='IT Admin' limit 1];
          agentUser.profileid =p.id;
          agentUser.Username +=string.valueOf(dateTime.now().getTime());
          insert agentUser;
          
          system.runAs(agentUser){
          User u = [select Id from User where profile.Name = 'IT Admin' and userRoleId != null AND ISActive=true Limit 1];
        
        Case c= TestUtilities.getcase();
        insert c;
        
        Core_IPS_Case_Attachments__c attachments = new Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c = c.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        attachments.Core_FileUploadedBy__c=userInfo.getUserID();
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        Insert attachments;
        
        Core_IPS_Case_Comments__c cmt = new Core_IPS_Case_Comments__c();
        cmt.Core_IPS_Case__c=c.id;
        cmt.Core_IPS_Comment__c='Test Comment';
        cmt.Core_IPS_Comment_Author_Type__c='';
        insert cmt;
               
        PageReference pref = Page.Core_IPS_File_AttachToCase;
        Test.setCurrentPage(pref);
       
        ApexPages.currentPage().getParameters().put('id',c.id);
        ApexPages.currentPage().getParameters().put('Type','Public to Customers');
        Apexpages.StandardController ap = new apexpages.StandardController(attachments);
        Core_IPS_File_AttachToCase_Controller cpfa=new Core_IPS_File_AttachToCase_Controller (ap);
        system.debug('@@@@'+cpfa.mapJsonList.get('visibility'));
        system.assertEquals(cpfa.mapJsonList.get('visibility'),'Public to Customers');
        }
    }
    
    /***************************************************************************************************
    Method Name        : testAttachment3
    Method Type        : Test Method
    Version            : 1.0 
    Created Date       :  5/12/2017 
    Feature No         :  F5427
    US No              :  US79603
    Iteration&Release No: 3 & 2
    Description        :  Covers code for attachment visibility function if public/private in Apex Class Core_IPS_File_AttachToCase_Controller  
    Scenario Type      : Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    *Aparna                     5/12/2017                   Created
 ****************************************************************************************************/
 static testMethod void testAttachment3() {
        
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_File_AttachToCase_Controller';
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
        
        Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
        label6.name='Comment Source - Email';
        label6.value__c='Email';
        listcstSettings.add(label6);
        
        Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
         label7.name='Data Migration';
         label7.value__c='Data Migration';
        listcstSettings.add(label7);
        
        Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
         label8.name='FAE';
         label8.value__c='FAE';
        listcstSettings.add(label8);
        
         Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
         label9.name='Partner - Agent';
         label9.value__c='Partner - Agent';
         listcstSettings.add(label9);   
        
        Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
         label10.name='Customer';
         label10.value__c='Customer';
         listcstSettings.add(label10);
        
        Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
         label11.name='Comment Source - N/A';
         label11.value__c='n/a';
         listcstSettings.add(label11);
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
         label12.name='Partner - DFAE';
         label12.value__c='Partner - DFAE';
         listcstSettings.add(label12);
     
         insert listcstSettings;
        
          user agentUser=TestUtilities.getUser();
          profile p=[select id,name from profile where name='IT Admin' limit 1];
          agentUser.profileid =p.id;
          agentUser.Username +=string.valueOf(dateTime.now().getTime());
          insert agentUser;
          
          system.runAs(agentUser){
          User u = [select Id from User where profile.Name = 'IT Admin' and userRoleId != null AND ISActive=true Limit 1];
        
        Case c= TestUtilities.getcase();
        insert c;
        
        Core_IPS_Case_Attachments__c attachments = new Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c = c.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        attachments.Core_FileUploadedBy__c=userInfo.getUserID();
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        Insert attachments;
        
        Core_IPS_Case_Comments__c cmt = new Core_IPS_Case_Comments__c();
        cmt.Core_IPS_Case__c=c.id;
        cmt.Core_IPS_Comment__c='Test Comment';
        cmt.Core_IPS_Comment_Author_Type__c='';
        insert cmt;
               
        PageReference pref = Page.Core_IPS_File_AttachToCase;
        Test.setCurrentPage(pref);
       
        ApexPages.currentPage().getParameters().put('id',c.id);
        ApexPages.currentPage().getParameters().put('Type','Private to Intel');
        Apexpages.StandardController ap = new apexpages.StandardController(attachments);
        Core_IPS_File_AttachToCase_Controller cpfa=new Core_IPS_File_AttachToCase_Controller (ap);
        system.debug('@@@@'+cpfa.mapJsonList.get('visibility'));
        system.assertEquals(cpfa.mapJsonList.get('visibility'),'Private to Intel');
        }
    }    
 /***************************************************************************************************
    Method Name        : testAttachment4
    Method Type        : Test Method
    Version            : 1.0 
    Created Date       : 30/4/2018 
    US No              :  US104151
    Iteration&Release No: i10 and R4.2
    Description        :  Covers code for attachment visibility function if public/private/partner in Apex Class Core_IPS_File_AttachToCase_Controller  
    Scenario Type      : Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    *Aparna                     30/4/2018                    Created
 ****************************************************************************************************/
 static testMethod void testAttachment4() {
        
        Core_Trigger_Executions__c customsett = new Core_Trigger_Executions__c();
        customsett.name = 'InsertCaseCommentForAttach';
        customsett.Core_Active__c = true;
        customsett.Core_Trigger_Events__c = 'After Insert,After Update';
        customsett.Core_Class_Name__c = 'Core_IPS_File_AttachToCase_Controller';
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
        
          user agentUser=TestUtilities.getUser();
          profile p=[select id,name from profile where name='IT Admin' limit 1];
          agentUser.profileid =p.id;
          agentUser.Username +=string.valueOf(dateTime.now().getTime());
          insert agentUser;
          
          system.runAs(agentUser){
          User u = [select Id from User where profile.Name = 'IT Admin' and userRoleId != null AND ISActive=true Limit 1];
        
        Case c= TestUtilities.getcase();
        insert c;
        
        Core_IPS_Case_Attachments__c attachments = new Core_IPS_Case_Attachments__c();
        attachments.Core_Case__c = c.id;
        attachments.Core_File_Description__c='Test-Description';
        attachments.Core_File_Name__c='Test-File';
        attachments.Core_IPS_Attachment_Visibility__c= Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
        attachments.Core_FileUploadedBy__c=userInfo.getUserID();
        attachments.Core_File_URL__c='www.test.com';
        attachments.Core_FileSizeInBytes__c='2KB';
        attachments.Core_Upload_Status__c=Core_IPS_Labels__c.getValues('COMPLETE').value__c;
        Insert attachments;
                              
        PageReference pref = Page.Core_IPS_File_AttachToCase;
        Test.setCurrentPage(pref);
       
        ApexPages.currentPage().getParameters().put('id',c.id);
        ApexPages.currentPage().getParameters().put('Type','Private to Partner');
        Apexpages.StandardController ap = new apexpages.StandardController(attachments);
        Core_IPS_File_AttachToCase_Controller cpfa=new Core_IPS_File_AttachToCase_Controller (ap);
        system.debug('@@@@'+cpfa.mapJsonList.get('visibility'));
        system.assertEquals(cpfa.mapJsonList.get('visibility'),'Private to Partner');
        }
    } 
}