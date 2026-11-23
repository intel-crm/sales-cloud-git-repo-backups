@isTest
public class Core_ips_surveyrep_CTRL_Test {
      @testSetup 
    static void TestData() {
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.ProfileID =  sysAdminProfileID;  
        sysadmin.username='sysAdmin@intel.com.test.' + String.valueOf(System.Now().getTime());     
        sysadmin.Core_User_Country_Code__c ='DEU'; 
        insert sysadmin;
        System.assert(sysadmin.Id != null, 'Record not created');  

        System.runAs(sysadmin) {
            Case objCase = TestUtilities.getCase();
            String caseRecordType=Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
            objCase.RecordTypeId = caseRecordType;
            insert objCase;
            System.assert(objCase.Id != null, 'Record not created');  

            objCase.Status = 'Closed';
            objCase.Core_Sub_Status__c = 'Closed';
            update objCase;
             // added by amritesh - US103747
            
            Id surveyRecordTypeId = schema.sobjecttype.Core_IPS_Question__c.getRecordTypeInfosByName().get('Survey').getRecordTypeId();
       
            List<Core_IPS_Question__c> lstQues = new List<Core_IPS_Question__c>();
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=surveyRecordTypeId, Core_IPS_Order_No__c=1, Core_IPS_Question__c='Question 1', Core_IPS_DataType__c='Picklist', Core_IPS_Status__c = 'Active', Core_IPS_Survey_Type__c = 'Sales Rep', Core_IPS_Required__c=true));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=surveyRecordTypeId, Core_IPS_Order_No__c=2, Core_IPS_Question__c='Question 2', Core_IPS_DataType__c='Select Radio', Core_IPS_Status__c = 'Active', Core_IPS_Survey_Type__c = 'Sales Rep'));
            lstQues.add(new Core_IPS_Question__c( RecordTypeId=surveyRecordTypeId, Core_IPS_Order_No__c=3, Core_IPS_Question__c='Question 3', Core_IPS_DataType__c='Text Area', Core_IPS_Status__c = 'Active', Core_IPS_Survey_Type__c = 'Sales Rep'));
             
            insert lstQues;
            System.assert(lstQues[0].Id != null, 'Record not created');  

            
            List<Core_IPS_Answer__c> lstAns = new List<Core_IPS_Answer__c>();
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=1, Core_IPS_Answer__c='Yes', Core_IPS_Status__c = 'Active'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=2, Core_IPS_Answer__c='No', Core_IPS_Status__c = 'Active'));
            insert lstAns;
            System.assert(lstAns[0].Id != null, 'Record not created');  

              List<Core_IPS_Answer__c> lstAns1 = new List<Core_IPS_Answer__c>();
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=1, Core_IPS_Answer__c='Yes', Core_IPS_Status__c = 'Active'));
            lstAns.add(new Core_IPS_Answer__c(Core_IPS_Question__c=lstQues[0].Id, Core_IPS_Order_No__c=2, Core_IPS_Answer__c='No', Core_IPS_Status__c = 'Active'));
            insert lstAns1;
           

            
            Core_IPS_Survey_Settings__c surveySetting = new Core_IPS_Survey_Settings__c(Name='Customer');
            insert surveySetting;
			System.assert(surveySetting.Id != null, 'Record not created');  
          
            
        }
    }
    
    static testMethod void Core_IPS_Survey_Controller_test() {
        String salesRepBBId = [select Id, Name from Profile where name = 'Sales Rep-BB' Limit 1].ID;
        User salesRep = TestUtilities.getUser();
        salesRep.ProfileID =  salesRepBBId;  
        salesRep.username='salesrepbb@intel.com.test.' + String.valueOf(System.Now().getTime());     
        salesRep.Core_User_Country_Code__c ='IND'; 
        insert salesRep;
		System.assert(salesRep.Id != null, 'Record not created');  
        
        Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c(Name = 'IPS_SalesRep_ProfilesId', Value__c = salesRepBBId.substring(0, 15));
            insert ipsLabel;
        System.assert(ipsLabel.Id != null, 'Record not created');  

        
     System.runAs(salesRep) {
         Case objCase = TestUtilities.getCase();
            String caseRecordType=Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
            objCase.RecordTypeId = caseRecordType;
            insert objCase;
         	System.assert(objCase.Id != null, 'Record not created');  

            objCase.Status = 'Closed';
            objCase.Core_Sub_Status__c = 'Closed';
            update objCase;
        
        Test.startTest();
       Core_ips_surveyrep_CTRL.init(objCase.Id,'');
        Core_ips_surveyrep_CTRL.captureSurvey('{"a2x3F0000008Y7iQAE":"Yes","a2x3F0000008Y7jQAE":"1","a2x3F0000008Y7lQAE":"4","a2x3F000000CjoMQAS":"4","a2x3F000000yuy7QAA":"Strongly Agree","a2x3F0000008Y7pQAE":"tes"}',objCase.Id);
         Core_ips_surveyrep_CTRL.init(objCase.Id,'{"a2x3F0000008Y7iQAE":"Yes","a2x3F0000008Y7jQAE":"1","a2x3F0000008Y7lQAE":"4","a2x3F000000CjoMQAS":"4","a2x3F000000yuy7QAA":"Strongly Agree","a2x3F0000008Y7pQAE":"tes"}');
     //Core_ips_surveyrep_CTRL.getCustomSettings();
    //   Core_ips_surveyrep_CTRL.getProfilename();
          Core_ips_surveyrep_CTRL.caseOwnerRedirectPage(objCase.Id);
         Core_ips_surveyrep_CTRL.skipSurveyDisable(objCase.Id);
   
       Test.stopTest();
    }
    }
    
    static testMethod void Core_ips_surveyrep_CTRL_negative_test() {
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        Id caseId = objCase.Id;
        User sysAdmin = [SELECT Id FROM User WHERE Profile.Name='System Administrator' AND isActive=true LIMIT 1];      
        Test.startTest();
        Core_ips_surveyrep_CTRL.captureSurvey('{"a2x3F0000008Y7iQAE":"Yes","a2x3F0000008Y7jQAE":"1","a2x3F0000008Y7lQAE":"4","a2x3F000000CjoMQAS":"4","a2x3F000000yuy7QAA":"Strongly Agree","a2x3F0000008Y7pQAE":"tes"}',caseId);
        System.assert([SELECT COUNT() FROM Core_IPS_Response__c]==0);
       // Core_ips_surveyrep_CTRL.lstQuestions[0].isRequired = false;
        Core_ips_surveyrep_CTRL.captureSurvey('{"a2x3F0000008Y7iQAE":"Yes","a2x3F0000008Y7jQAE":"1","a2x3F0000008Y7lQAE":"4","a2x3F000000CjoMQAS":"4","a2x3F000000yuy7QAA":"Strongly Agree","a2x3F0000008Y7pQAE":"tes"}',caseId);
         Core_ips_surveyrep_CTRL.init(objCase.Id,'');
        Core_ips_surveyrep_CTRL.init('','');
       // Core_ips_surveyrep_CTRL.backfromWarning();
        Core_ips_surveyrep_CTRL.hasPermissionSet(new Set<String>{userinfo.getProfileId()});
        
    }
    
    
     static testMethod void caseOwnerRedirectPage_Test() {
        Test.startTest();        
      
           String salesRepBBId = [select Id, Name from Profile where name = 'Sales Rep-BB' Limit 1].ID;
        User salesRep = TestUtilities.getUser();
        salesRep.ProfileID =  salesRepBBId;  
        salesRep.username='salesrepbb@intel.com.test.' + String.valueOf(System.Now().getTime());     
        salesRep.Core_User_Country_Code__c ='IND'; 
        insert salesRep;
        System.assert(salesRep.Id != null, 'Record not created');  

        User salesRep1 = TestUtilities.getUser();
        salesRep1.ProfileID =  salesRepBBId;  
        salesRep1.username='salesrepbb@intel.com.test.' + String.valueOf(System.Now().getTime());     
        salesRep1.Core_User_Country_Code__c ='IND'; 
        insert salesRep1;
        System.assert(salesRep1.Id != null, 'Record not created');  
 
         
         Case objCase = [SELECT Id,Core_IPS_Survey_Captured__c,OwnerId FROM Case LIMIT 1];
        objCase.OwnerId=salesRep.id;
        update objCase;
        
        objCase.OwnerId=salesRep1.id;
        update objCase;
        
        CaseHistory objectHistory = new CaseHistory(CaseId = objCase.Id, Field = 'Owner');
        insert objectHistory;
        System.assert(objectHistory.Id != null, 'Record not created');  

        
   
        Core_ips_surveyrep_CTRL.caseOwnerRedirectPage(objCase.Id);
        Core_ips_surveyrep_CTRL.init(objCase.Id,'');
         
        //Added by Sowmya - Start - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        Core_IPS_Survey_Settings__c surveysetting = new Core_IPS_Survey_Settings__c();
        surveysetting.Name = 'Customer';
        surveysetting.Core_IPS_Footer_Label__c = 'Core_IPS_Survey_Footer';
        surveysetting.Core_IPS_Header_Label__c = 'Core_IPS_Survey_Header_2';
        surveysetting.Core_IPS_Image_Resource__c ='Core_IPS_New_Logo';
        Insert surveysetting;
        System.assert(surveysetting.Id != null, 'Record not created');  

        Core_ips_surveyrep_CTRL.fetchSurveySetting('Customer');
       	//Sowmya - end - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        
        Test.stopTest();       
     }

}