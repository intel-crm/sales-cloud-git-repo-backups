/**************************************************************************************
Apex Class Name:  Core_PartnerLeadHandlerTest
Version     : 1.0 
Created Date: 06 August 2019
Function    : Test Class for the Core_PartnerLead_ClaimReject_Ctrl class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda             06/08/2019              Original Version
*************************************************************************************/

@isTest 
public class Core_PartnerLead_ClaimReject_Ctrl_Test {
    
    
    static testMethod void BulkClaimTest() {
        //test
        String leadRecType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        List<Lead> lstLead = new List<Lead>();
        lead sobjLead = new lead();
        sobjLead.FirstName = 'Team';
        sobjLead.lastName = 'Bulk Email Testing';
        sobjLead.Company = 'Hangout Notictaion Email Test';
        sobjLead.email = 'tes65sjjjss78t@hh.com';
        sobjLead.CountryCode = 'USA';
        sobjLead.StateCode = 'AL';
        sobjLead.City = 'Alabama';
        sobjLead.Street = 'test';
        sobjLead.leadSource = 'Email';  
        sobjLead.PostalCode = '57s710';
        sobjLead.Title = 'He8lo';
        sobjLead.Core_Current_Architecture__c='Test';
        sobjLead.Phone='97788788';
        sobjLead.Core_Product_Interest__c='10';
        sobjLead.Core_Project_Phase__c='testing';
        sobjLead.Core_Project_Size__c='4';
        sobjLead.Core_Project_Timeframe__c='12-24 Months';
        sobjLead.recordtypeId = leadRecType;
        sobjLead.Status = 'PRL';
        sobjLead.Core_Lead_Status__c = 'New';
        sobjLead.Core_Geo__c = '';
        sobjLead.Core_Sub_Geo__c = '';
        sobjLead.Phone = '(555) 555-5555';
        sobjLead.Title = '(555) 555-5555';
        sobjLead.Core_Current_Architecture__c = '(555) 555-5555';
        sobjLead.Core_Job_Function__c = '(555) 555-5555';
        sobjLead.Core_Product_Interest__c = '(555) 555-5555';
        sobjLead.Core_Project_Phase__c = '(555) 555-5555';
        sobjLead.Core_Project_Size__c = '555';
        sobjLead.Core_Project_Timeframe__c = '555';
        sobjLead.PostalCode = '560035';
        sobjLead.LeadSource = 'Website';
        // sobjLead.PMP_Offering_Id__c='a6Y2D000000CaVsUAK';
        lstLead.add(sobjLead);
        
        
        lead sobjLead1 = new lead(); 
        sobjLead1.FirstName = 'Team'; 
        sobjLead1.lastName = 'Bulk Testwww123';
        sobjLead1.Company = 'Tea shop Notication2';
        sobjLead1.email = 'tes6wssw578t@hh.com';
        sobjLead1.CountryCode = 'USA';
        sobjLead1.StateCode = 'AL';
        sobjLead1.City = 'Alabama';
        sobjLead1.Street = 'test';
        sobjLead1.leadSource = 'Email'; 
        sobjLead1.PostalCode = '577310';
        sobjLead1.Title = 'He8lo';
        sobjLead1.Core_Current_Architecture__c='Test';
        sobjLead1.Phone='97788788';
        sobjLead1.Core_Product_Interest__c='10';
        sobjLead1.Core_Project_Phase__c='testing';
        sobjLead1.Core_Project_Size__c='4';
        sobjLead1.Core_Project_Timeframe__c='12-24 Months';
        sobjLead1.recordtypeId = leadRecType;
        sobjLead1.Status = 'PRL';
        sobjLead1.Core_Lead_Status__c = 'New';
        sobjLead1.Core_Geo__c = '';
        sobjLead1.Core_Sub_Geo__c = '';
        sobjLead1.Phone = '(555) 555-5555';
        sobjLead1.Title = '(555) 555-5555';
        sobjLead1.Core_Current_Architecture__c = '(555) 555-5555';
        sobjLead1.Core_Job_Function__c = '(555) 555-5555';
        sobjLead1.Core_Product_Interest__c = '(555) 555-5555';
        sobjLead1.Core_Project_Phase__c = '(555) 555-5555';
        sobjLead1.Core_Project_Size__c = '555';
        sobjLead1.Core_Project_Timeframe__c = '555';
        sobjLead1.PostalCode = '560035';
        sobjLead1.LeadSource = 'Website';
        //sobjLead1.PMP_Offering_Id__c='a6Y2D000000CaVJUA0';
        lstLead.add(sobjLead1);
        insert lstLead;
        
        
        Test.startTest();
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstLead);
        stdSetController.setSelected(lstLead);
        Core_PartnerLead_ClaimReject_Ctrl le= new Core_PartnerLead_ClaimReject_Ctrl(stdSetController);
        le.ClaimLeads();
        Test.stopTest();
    }
}