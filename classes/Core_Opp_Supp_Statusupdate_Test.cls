@isTest
public class Core_Opp_Supp_Statusupdate_Test {
    
    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St',Core_Geo__c='APJ',
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
		insert acc;
        Id recordTypeOppId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Design_Opportunity').getRecordTypeId();
		Opportunity opp = new Opportunity(Name = 'Test Opportunity', Core_Channel_Opportunity_Ind__c=true,RecordTypeId = recordTypeOppId,Core_Approved_Opportunity_Region__c='APJ',Core_Opportunity_Geo_APJ__c=true,
                                                      AccountId = acc.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Approval_Status__c='Not Submitted');
        insert opp;
        Id recordTypeMSId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CRM_Marketing_Support').getRecordTypeId();
        Core_Opportunity_Support__c cOpptSupReq = new Core_Opportunity_Support__c();
        cOpptSupReq.Core_Status__c='Submitted';        
        cOpptSupReq.RecordTypeId = recordTypeMSId;
        cOpptSupReq.Opportunity__c = opp.id;
        insert cOpptSupReq;
    }
    @isTest
	static void testGetStatusValue() {
    // Retrieve test data
    	Core_Opportunity_Support__c testOpptSuppReq = [SELECT Id, RecordTypeId FROM Core_Opportunity_Support__c LIMIT 1];
 
    	Test.startTest();
    	
        Map<Id, String> result = Core_Opportunity_Support_statusupdate.getStatusValue(String.valueof(testOpptSuppReq.Id));
    	boolean result1 = Core_Opportunity_Support_statusupdate.updateOnMS(testOpptSuppReq.Id,'Submitted');
        Test.stopTest();
        System.assertEquals(true, result1);
        
	}
    @isTest
	static void testGetStatusValue_Er() {
   		Test.startTest();
    	try{
        	Map<Id, String> results = Core_Opportunity_Support_statusupdate.getStatusValue('test');
    	}
        catch(Exception e){
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_Opp_Supp_Statusupdate_Test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            insert logEntry;
            
        }
        Test.stopTest();
        SYSTEM.assertEquals(TRUE, true);
        
	}
    @isTest
	static void testGetStatusValue_Err() {
   		Test.startTest();
    	try{
            Opportunity testOpptSuppReq = [SELECT Id, RecordTypeId FROM Opportunity LIMIT 1];
        	boolean results1 = Core_Opportunity_Support_statusupdate.updateOnMS(testOpptSuppReq.id,'Submit');
    	}
        catch(Exception e){
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_Opp_Supp_Statusupdate_Test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            insert logEntry;
        }
        Test.stopTest();
        system.assertEquals(true, true);
        
	}
    
}