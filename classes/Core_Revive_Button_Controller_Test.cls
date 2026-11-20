/**************************************************************************************
Apex Class Name:  Core_Revive_Button_Controller_Test
Version     : 1.0 
Created Date: 27 Sep 2018
Function    : Test class for Core_Revive_Button_Controller
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Sathishkumar Chennaiyan             27/09/2018              Original Version
*************************************************************************************/
@isTest
public class Core_Revive_Button_Controller_Test {
    
    static testMethod void updateLeadTest(){ 
        List<Lead> LeadList = new List<Lead>();
        
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        Lead leadInstance = new Lead();
        leadInstance.FirstName = 'Test 123';
        
        leadInstance.lastName = 'CS';
        leadInstance.Company = 'XYZ';
        leadInstance.CountryCode = 'USA';
        leadInstance.StateCode = 'AL';
        leadInstance.City = 'Alabama';
        leadInstance.Street = 'test';
        leadInstance.status = 'Sales Generated Lead';
        leadInstance.leadSource = 'Email';
        leadInstance.email = 'test@infosys.com';
        leadInstance.Core_Last_Activity_Date__c = NULL;
        leadInstance.Core_Lead_Status__c='Accepted';
        leadInstance.PostalCode = '577101';
        leadInstance.Title = 'Hello';
        leadInstance.Core_Current_Architecture__c='Test';
        leadInstance.Phone='9777787888';
        leadInstance.Core_Product_Interest__c='10';
        leadInstance.Core_Project_Phase__c='testing';
        leadInstance.Core_Project_Size__c='4';
        leadInstance.Core_Project_Timeframe__c='12-24 Months';
        leadInstance.Core_Lead_State__c = 'In Pursuit';
        leadInstance.recordtypeid = RId ;  
        
        
        insert leadInstance;
        LeadList.add(leadInstance);
        
        system.debug('Lead '+LeadList);
        
        Test.startTest();
        
        String leadId = LeadList[0].id;
        String message = Core_Revive_Button_Controller.updateLead(leadId);
        System.assertEquals('Accepted', LeadList[0].Core_Lead_Status__c);
        
        Test.stopTest();
        
        
        
    }
  static testMethod void updateLeadTest1(){ 
        List<Lead> LeadList1 = new List<Lead>();
      
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        Lead leadInstance1 = new Lead();
        leadInstance1.FirstName = 'Test 123';
        leadInstance1.lastName = 'CS';
        leadInstance1.Company = 'XYZ';
        leadInstance1.CountryCode = 'USA';
        leadInstance1.StateCode = 'AL';
        leadInstance1.City = 'Alabama';
        leadInstance1.Street = 'test';
        leadInstance1.status = 'Sales Generated Lead';
        leadInstance1.leadSource = 'Email';
        leadInstance1.email = 'test@infosys.com';
        leadInstance1.Core_Last_Activity_Date__c = NULL;
        leadInstance1.Core_Lead_Status__c='Accepted';
        leadInstance1.Core_Lead_Sub_Status__c='Attempting Contact';
        leadInstance1.PostalCode = '577101';
        leadInstance1.Title = 'Hello';
        leadInstance1.Core_Current_Architecture__c='Test';
        leadInstance1.Phone='9777787888';
        leadInstance1.Core_Product_Interest__c='10';
        leadInstance1.Core_Project_Phase__c='testing';
        leadInstance1.Core_Project_Size__c='4';
        leadInstance1.Core_Project_Timeframe__c='12-24 Months';
        leadInstance1.Core_Lead_State__c = 'In Pursuit';
        leadInstance1.recordtypeid = RId ; 
        insert leadInstance1;
      	
        leadInstance1.Core_Lead_Status__c='Qualified';
        leadInstance1.status = 'Sales Accepted Lead';
        leadInstance1.Core_Lead_Sub_Status__c='In Contact';
        update leadInstance1;
        leadInstance1.Core_Lead_Status__c = 'Disqualified';
        leadInstance1.Core_Lead_Sub_Status__c = 'Already Engaged With Intel';
      update leadInstance1;
        LeadList1.add(leadInstance1);
        
        
        Test.startTest();
        String message=Core_Revive_Button_Controller.updateLead(LeadList1[0].id);
        System.assertEquals('Disqualified', LeadList1[0].Core_Lead_Status__c);
        Test.stopTest();
        
        
        
    }
  
    
        static testMethod void updateLeadTest2(){ 
    List<Lead> LeadList2 = new List<Lead>();
      
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        
        Lead leadInstance2 = new Lead();
        leadInstance2.FirstName = 'Test 223';
        leadInstance2.lastName = 'CS';
        leadInstance2.Company = 'XYZ';
        leadInstance2.CountryCode = 'USA';
        leadInstance2.StateCode = 'AL';
        leadInstance2.City = 'Alabama';
        leadInstance2.Street = 'test';
        leadInstance2.status = 'Sales Generated Lead';
        leadInstance2.leadSource = 'Email';
        leadInstance2.email = 'test@infosys.com';
        leadInstance2.Core_Last_Activity_Date__c = NULL;
        leadInstance2.Core_Lead_Status__c='Accepted';
        leadInstance2.PostalCode = '577202';
        leadInstance2.Title = 'Hello';
        leadInstance2.Core_Current_Architecture__c='Test';
        leadInstance2.Phone='9777787888';
        leadInstance2.Core_Product_Interest__c='20';
        leadInstance2.Core_Project_Phase__c='testing';
        leadInstance2.Core_Project_Size__c='4';
        leadInstance2.Core_Project_Timeframe__c='22-24 Months';
        leadInstance2.Core_Lead_State__c = 'In Pursuit';
        leadInstance2.recordtypeid = RId ; 
        
        
        insert leadInstance2;
        leadInstance2.Core_Lead_Status__c = 'Disqualified';
        leadInstance2.Core_Lead_Sub_Status__c = 'Unreachable';
        update leadInstance2;
        LeadList2.add(leadInstance2);
        
        Test.startTest();
        
        String message = Core_Revive_Button_Controller.updateLead(LeadList2[0].id);
        
        Test.stopTest();
        System.assertEquals('Disqualified', LeadList2[0].Core_Lead_Status__c);
  
    }
     static testMethod void updateLeadTest3(){ 
         List<User> leadUser = new List<User>();
         Profile p1 = [Select Id from Profile WHERE Name =: 'System Administrator'];
         leadUser = Core_Test_Utility.Core_User(1);
         leadUser[0].ProfileId = p1.Id;
         Insert leadUser;
         
         String leadRecordType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
         List<Lead> leadRec = new List<Lead>();
         //leadRec = Core_Test_Utility.createLead(2);
         	 Lead objLead = new Lead(); 
             objLead.recordtypeId = leadRecordType;
             objLead.FirstName = 'Test 223';
           	 objLead.lastName = 'CS';
        	 objLead.Company = 'XYZ';
        	 objLead.CountryCode = 'USA';
        	 objLead.StateCode = 'AL';
        	 objLead.City = 'Alabama';
        	 objLead.Street = 'test';
        	 objLead.status = 'Marketing Qualified Lead';
        	 objLead.leadSource = 'Email';
        	 objLead.email = 'test@infosys.com';
        	 objLead.Core_Last_Activity_Date__c = NULL;
        	 objLead.Core_Lead_Status__c='New';
        	 objLead.PostalCode = '577202';
        	 objLead.Title = 'Hello';
        	 objLead.Core_Current_Architecture__c='Test';
        	 objLead.Phone='9777787888';
        	 objLead.Core_Product_Interest__c='20';
        	 objLead.Core_Project_Phase__c='testing';
        	 objLead.Core_Project_Size__c='4';
        	 objLead.Core_Project_Timeframe__c='22-24 Months';
        	 objLead.Core_Lead_State__c = 'Unclaimed';
           
             leadRec.add(objLead);
       		 System.runAs(leadUser[0])
             {
         		leadRec[0].OwnerId = leadUser[0].Id;
                Insert leadRec[0];
                Core_Revive_Button_Controller.updateLead(leadRec[0].id);
                objLead.status = 'Marketing Qualified Lead';
                objLead.Core_Lead_Status__c='Disqualified';
                objLead.Core_Lead_State__c = 'Terminated';
                leadRec.add(objLead);
                Update leadRec[0];
                Core_Revive_Button_Controller.updateLead(leadRec[0].id);
                System.assertEquals('Disqualified', leadRec[0].Core_Lead_Status__c);
         }
     }
    static testMethod void updateLeadTest4(){ 
         List<User> leadUser = new List<User>();
         Profile p1 = [Select Id from Profile WHERE Name =: 'System Administrator'];
         leadUser = Core_Test_Utility.Core_User(1);
         leadUser[0].ProfileId = p1.Id;
         Insert leadUser;
         
         String leadRecordType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
         List<Lead> leadRec = new List<Lead>();
         //leadRec = Core_Test_Utility.createLead(2);
         	 Lead objLead1 = new Lead(); 
             objLead1.recordtypeId = leadRecordType;
             objLead1.FirstName = 'Test 223';
           	 objLead1.lastName = 'CS';
        	 objLead1.Company = 'XYZ';
        	 objLead1.CountryCode = 'USA';
        	 objLead1.StateCode = 'AL';
        	 objLead1.City = 'Alabama';
        	 objLead1.Street = 'test';
        	 objLead1.status = 'Marketing Qualified Lead';
        	 objLead1.leadSource = 'Email';
        	 objLead1.email = 'test@infosys.com';
        	 objLead1.Core_Last_Activity_Date__c = NULL;
        	 objLead1.Core_Lead_Status__c='New';
             //objLead1.Core_Lead_Sub_Status__c='In Contact';
        	 objLead1.PostalCode = '577202';
        	 objLead1.Title = 'Hello';
        	 objLead1.Core_Current_Architecture__c='Test';
        	 objLead1.Phone='9777787888';
        	 objLead1.Core_Product_Interest__c='20';
        	 objLead1.Core_Project_Phase__c='testing';
        	 objLead1.Core_Project_Size__c='4';
        	 objLead1.Core_Project_Timeframe__c='22-24 Months';
        	 objLead1.Core_Lead_State__c = 'Unclaimed';
           
             leadRec.add(objLead1);
       		 System.runAs(leadUser[0])
             {
         		leadRec[0].OwnerId = leadUser[0].Id;
                Insert leadRec[0];
                Core_Revive_Button_Controller.updateLead(leadRec[0].id);
                objLead1.Core_Lead_Status__c='Qualified';
                objLead1.Core_Lead_Sub_Status__c='In Contact';
                Update leadRec[0];
               	objLead1.status = 'Sales Accepted Lead';
                objLead1.Core_Lead_Status__c='Qualified';
                objLead1.Core_Lead_State__c = 'In Pursuit';
                leadRec.add(objLead1);
                Update leadRec[0];
                 
                objLead1.Core_Lead_Status__c='Disqualified';
                objLead1.Core_Lead_Sub_Status__c='Rep Inactivity';
                objLead1.Core_Lead_State__c = 'Terminated';
                 leadRec.add(objLead1);
                Update leadRec[0];
                Core_Revive_Button_Controller.updateLead(leadRec[0].id);
                System.assertEquals('Disqualified', leadRec[0].Core_Lead_Status__c);
         }
     }
}