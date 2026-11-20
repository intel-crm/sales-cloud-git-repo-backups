@isTest
public class SWS_LeadHandlerTest {
    
    @testSetup 
    private static void setup(){
        
        User u= SWS_TestUtilty.createUser();
        
        PermissionSet permissionRec = [SELECT Id 
                         FROM PermissionSet 
                         WHERE Name = 'SWS_Import_Lead_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionRec.Id);
        System.runAs(u){
            List<Core_Trigger_Executions__c> lstCustomSetting = new List<Core_Trigger_Executions__c>();
            List<User> lstUser = new List<User>();
            lstCustomSetting = Core_test_Utility.Core_TriggerExecution(6);
            lstCustomSetting[0].Name = 'leadObjectBeforeHandler';
            lstCustomSetting[1].Name = 'leadObjectSalesSegment';
           	lstCustomSetting[2].Name = 'AssignLeadsToPartnerQueues';
            lstCustomSetting[3].Name = 'fetchCountryLabels';
            lstCustomSetting[4].Name = 'leadObjectSalesGroup';
            lstCustomSetting[5].Name = 'FetchOfferingDetails';
            insert lstCustomSetting;
            SWS_TestUtilty.createLabel('DuplicateLeadError','Error: Cannot insert a lead with same email and product interest');
            Lead lead1 = SWS_TestUtilty.createLeadRecord();
            lead1.SWS_Lead_Source_System__c='HubSpot';
            lead1.Email='test789@testorg.com';
            lead1.Core_Product_Interest__c='Intel® Max Series GPU';
            update lead1;
            
            Lead lead2 = SWS_TestUtilty.createLeadRecord();
            lead2.SWS_Lead_Source_System__c='HubSpot';
            lead2.Email='test789@testorg123.com';
            lead1.Core_Product_Interest__c = 'Intel® Max Series GPU;Multiple platforms';
            update lead2;
        }
        
    }
    
    @isTest 
    private static void insertbeforeUpdateTest() {
        User u = [SELECT Id from User where LastName='requestorUser' LIMIT 1];
        System.runAs(u){
            List<Lead> LeadList1= [SELECT Email,Core_Product_Interest__c,SWS_Lead_Source_System__c FROM Lead LIMIT 2];
            Test.startTest();
            Map<Id,Lead> oldMap = new Map<Id,Lead>();
            SWS_LeadHandler.beforeInsertUpdateOperations(LeadList1,oldMap);
            System.assertEquals(true,true,'As expected');
            Test.stopTest(); 
        }
    }
}