@isTest
public class Core_LeadHandlerforSLA_Test {
    
    static testMethod void CreateLeadtest() {
        
         
        String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c();
        triggerExec1.Name = 'leadObjectBeforeHandler';
        triggerExec1.Core_Class_Name__c = 'Core_LeadHandler';
        triggerExec1.Core_Object__c = 'Lead';
        triggerExec1.Core_Active__c = true;
        triggerExec1.Core_Description__c = 'Logic for populating geo and sub-geo values';
        triggerExec1.Core_Trigger_Events__c = 'before insert,before update';
        triggerExecList.add(triggerExec1);
        
        Core_Trigger_Executions__c triggerExec2 = new Core_Trigger_Executions__c();
        triggerExec2.Name = 'leadObjectSalesGroup';
        triggerExec2.Core_Class_Name__c = 'Core_LeadHandler';
        triggerExec2.Core_Object__c = 'Lead';
        triggerExec2.Core_Active__c = true;
        triggerExec2.Core_Description__c = 'Logic to copy the Lead Sales Group information to Account Sales Group, Opportunity Sales Group.';
        triggerExec2.Core_Trigger_Events__c = 'before insert,before update';
        triggerExecList.add(triggerExec2);
        
        Core_Trigger_Executions__c triggerExec3 = new Core_Trigger_Executions__c();
        triggerExec3.Name = 'leadConversionDeduplication';
        triggerExec3.Core_Class_Name__c = 'Core_LeadHandler';
        triggerExec3.Core_Object__c = 'Lead';
        triggerExec3.Core_Active__c = true;
        triggerExec3.Core_Description__c = 'Logic for Deduplication account and contact on lead conversion';
        triggerExec3.Core_Trigger_Events__c = 'After Update';
        triggerExecList.add(triggerExec3);
        
        Core_Trigger_Executions__c triggerExec4 = new Core_Trigger_Executions__c();
        triggerExec4.Name = 'AssignLeadsToPartnerQueues';
        triggerExec4.Core_Class_Name__c = 'Core_LeadHandler';
        triggerExec4.Core_Object__c = 'Lead';
        triggerExec4.Core_Active__c = true;
        triggerExec4.Core_Description__c = 'Assing Partner Leads to correct Partner Queues using the Partner Name';
        triggerExec4.Core_Trigger_Events__c = 'After Update';
        triggerExecList.add(triggerExec4);
       /* 
        Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c();
        triggerExec5.Name = 'BlockExistingOpponConversionLead';
        triggerExec5.Core_Class_Name__c = 'Core_LeadHandlerforSLA';
        triggerExec5.Core_Object__c = 'Lead';
        triggerExec5.Core_Active__c = true;
        triggerExec5.Core_Description__c = 'Block Opp';
        triggerExec5.Core_Trigger_Events__c = 'Before Update';
        triggerExecList.add(triggerExec5);*/
        
        insert triggerExecList;
        
        Core_SLA_Listed_Users__c users= new Core_SLA_Listed_Users__c();
        users.Core_WWID__c='345';
        users.Name='Test';
        insert users;
        Lead leadInstance = new Lead();
        leadInstance.FirstName = 'Test 123';
        leadInstance.Core_Job_Function__c = 'Branch Manager';
        leadInstance.lastName = 'CS';
        leadInstance.Company = 'XYZ';
        leadInstance.CountryCode = 'USA';
        leadInstance.StateCode = 'AL';
        leadInstance.City = 'Alabama';
        leadInstance.Street = 'test';
        //leadInstance.Core_User_WWID__c='345';
        //leadInstance.status = 'Tele Accepted Lead';
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
        leadInstance.Core_Sales_Group__c = 'GMP India Sales Group' ; 
        
        
        insert leadInstance;
         leadInstance.status = 'Tele Qualified Lead';
        update leadInstance;
        List<Lead>Listnew = new List<Lead>();
        Listnew.add(leadInstance);
       Core_LeadHandlerforSLA.BlockOppConvertforExitOpp(Listnew);
 
    }
    
    static testMethod void CreateLeadtest1() {
      List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        
      Core_Trigger_Executions__c triggerExec5 = new Core_Trigger_Executions__c();
        triggerExec5.Name = 'BlockExistingOpponConversionLead';
        triggerExec5.Core_Class_Name__c = 'Core_LeadHandlerforSLA';
        triggerExec5.Core_Object__c = 'Lead';
        triggerExec5.Core_Active__c = true;
        triggerExec5.Core_Description__c = 'Block Opp';
        triggerExec5.Core_Trigger_Events__c = 'After Update';
       // triggerExecList.add(triggerExec5);
        
        insert triggerExec5;
        
       String Rid = [Select id from Recordtype where Name = 'Sales Lead'].id;
       
        Lead leadInstance = new Lead();
        leadInstance.FirstName = 'Test 123 New';
        leadInstance.Core_Job_Function__c = 'Branch Manager';
        leadInstance.lastName = 'CS';
        leadInstance.Company = 'XYZ';
        leadInstance.CountryCode = 'USA';
        leadInstance.StateCode = 'AL';
        leadInstance.City = 'Alabama';
        leadInstance.Street = 'test';
        //leadInstance.Core_User_WWID__c='345';
        leadInstance.status = 'Tele Accepted Lead';
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
        leadInstance.Core_Sales_Group__c = 'GMP India Sales Group' ; 
        
        
        insert leadInstance;
         leadInstance.status = 'Sales Accepted Lead';
         leadInstance.Core_System_Account_Sales_Group__c = 'GMP India Sales Group' ; 
          leadInstance.Core_lead_id__c =leadInstance.id  ; 

        update leadInstance;
        
        List <Lead> Listnew = new List<Lead>();
        Listnew.add(leadInstance);
       //Core_LeadHandlerforSLA.BlockOppConvertforExitOpp(Listnew);

        test.startTest();
           Core_LeadHandlerforSLA.isExistingOpportunity=true;
           Database.LeadConvert lc = new database.LeadConvert();
          lc.setLeadId(leadInstance.Id);
          LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
          lc.setConvertedStatus(convertStatus.MasterLabel);
         // lc.setDoNotCreateOpportunity(TRUE);
                   
         Core_LeadHandlerforSLA.BlockOppConvertforExitOpp(Listnew);
         Database.LeadConvertResult lcr = Database.convertLead(lc);
        system.debug('******lcrStatus'+lcr.isSuccess());
         System.assert(lcr.isSuccess());
                   
                   
                   //Core_LeadHandlerforSLA.isExistingOpportunity=true;
                    

        test.stopTest();
        
    }
    
    

}