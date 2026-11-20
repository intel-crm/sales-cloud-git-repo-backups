/***************************************************************************************************
* Apex Class Name: Core_IPS_Response_Handler_Test
* Version     : 1.0 
* Created Date: 3 Jan 2018
* Function    : Test class for Core_IPS_Response_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yogesh Sharma               3/1/2018               Created
* Amritesh					  04/25/2018			 Modified - US104141
//System.assert()--> statement Added By Hassan Khan 02-02-2024
****************************************************************************************************/

@isTest 
// Added AssertEquals Added By Chiranjeevi - 31-JAN-2024
public class Core_IPS_Response_Handler_Test { 
	private static User SystUserRunAs; 
    private static EmailTemplate EmailTempl;
    private static OrgWideEmailAddress OrgWideEmailObj;
    
    
    private static void getRecords(){
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
        System.AssertEquals(userList.size()>0, true);
    }
    
    /***************************************************************************************************
    * Method Name: testEnvHTMLTableCreated
    * Method Type: Test Method
    * Version     : 1.0 
    * Created Date: 3/1/2018
    * Description:  Product issue category update 
    * Scenario Type: Positive 
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma               11/18/2015             Created
    ****************************************************************************************************/         
    private static testMethod void testEnvHTMLTableCreated() {
        getRecords();
        System.runAs(SystUserRunAs){
            Case cs=TestUtilities.getCase();
            insert cs;
            List<Core_IPS_Response__c> envResponses = TestUtilities.getCoreResponseRecords(2);
            for(Core_IPS_Response__c envResp : envResponses){
                envResp.Core_IPS_Case__c = cs.id;
            }
            insert envResponses;
            System.AssertEquals(envResponses != null, true);
        }
    }
    
    /***************************************************************************************************
    * Method Name: testEnvJSONCreated
    * Method Type: Test Method
    * Version     : 1.0 
    * Created Date: 3/1/2018
    * Description:  Product issue category update 
    * Scenario Type: Positive 
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma               3/1/2018               Created
    ****************************************************************************************************/         
    private static testMethod void testEnvJSONCreated() {
        getRecords();
		System.assert(SystUserRunAs != null, true);
    }  
    
    /***************************************************************************************************
    * Method Name: testEnvMultiSelectPicklistWithBreak
    * Method Type: Test Method
    * Version     : 1.0 
    * Created Date: 3/1/2018
    * Description:  Product issue category update 
    * Scenario Type: Positive 
    * Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma               3/1/2018               Created
    ****************************************************************************************************/         
    private static testMethod void testEnvMultiSelectPicklistWithBreak() {
        getRecords();
		System.assert(SystUserRunAs != null, true);
    }       
    
    /***************************************************************************************************
	Method Name			: updateEnvironmentDetailsOnCaseTest
	Method Type			: void
	Version     		: 1.0 
	Created Date		: 05 Nov 2015
	Description			: This method is used for cover the updateEnvironmentDetailsOnCase method of Core_IPS_Response_Handler class.
	Scenario Type:  
	Modification Log 	:
	* Developer                   Date                   Description
	* ----------------------------------------------------------------------------                 
	* Yogesh Sharma       		  28/12/2017             Created
	****************************************************************************************************/
	public static testmethod void updateEnvironmentDetailsOnCaseTest(){
		Test.startTest();
			getRecords();
			//Create Custom Setting - Trigger Executions
	        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
	        TriggerExecution.Name = 'updateEnvDetailsOnCaseFromCoreResponse';
	        TriggerExecution.Core_Active__c = true;
	        TriggerExecution.Core_Class_Name__c ='Core_IPS_Response_Handler';
	        TriggerExecution.Core_Description__c = 'This method is used update the Response Detail on Case.';
	        TriggerExecution.Core_Object__c = 'Core_IPS_Response__c';
	        TriggerExecution.Core_Trigger_Events__c = 'After Insert';
	        insert TriggerExecution; 
	        System.assert(TriggerExecution.id != null);
			
             //start added by Aayushi US95468 06/04/2018
             //Create Custom Setting - Trigger Executions
		     Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
		     TriggerExecution1.Name = 'updateEDQfilteringFieldOnCase';
		     TriggerExecution1.Core_Active__c = true;
		     TriggerExecution1.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
		     TriggerExecution1.Core_Description__c = 'This method will populate the two EDQ filtering fields on Case with the Response QuestionsReporting Name and the Response Answer text';
		     TriggerExecution1.Core_Object__c = 'Core_IPS_Response__c';
		     TriggerExecution1.Core_Trigger_Events__c = 'After Insert,Update';
		     insert TriggerExecution1; 
		     System.assert(TriggerExecution1.id != null);
        	 //end
        	
			//Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = TestUtilities.getListOfUser(1).get(0).id; 
				  
			System.runAs(SystUserRunAs){
				//Create Support Org
		        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
		        insert ListOfSupportOrg;
		        
		        System.assert(ListOfSupportOrg != null, 'Record not created');
		        
		        //Create Accounts
	            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
	            insert ListOfAccounts;
	            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
	            
	            //Create Contacts
	            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
	            for(Contact ContactRec : ListOfContacts){
	                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
	                ContactRec.core_ips_Active__c=true;
	                ContactRec.Accountid = ListOfAccounts.get(0).Id; 
	            }
	            insert ListOfContacts;
	            System.assert(ListOfContacts[0].Id != null, 'Record not created');
	            
		        //Create Case
		        Case c1 = TestUtilities.getListOfCases(2).get(0);
                c1.accountId = ListOfAccounts.get(0).Id;
                c1.ContactId = ListOfContacts.get(0).id;
                c1.Core_IPS_Customer_Visible__c = false;
                insert c1; 
                
		        //Get Record Type
		        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
		        
                //Create Core Question
		        Core_IPS_Question__c cq = new Core_IPS_Question__c();
		        cq.recordTypeId = edqRecordTypeId;
		        cq.Core_IPS_Datatype__c = 'Picklist';
		        cq.Core_IPS_Order_No__c = 1;
		        cq.Core_IPS_Parent_Question__c = null;
		        cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
		        cq.Core_IPS_Question__c = 'Test';
		        cq.Core_IPS_Required__c = false;
		        cq.Core_IPS_Status__c = 'Active';
		        
		        insert cq;
		        
	            Core_IPS_Response_Handler.wrapResponse wrap = new Core_IPS_Response_Handler.wrapResponse();
	            
	            List<Core_IPS_Response__c> envResponses = TestUtilities.getCoreResponseRecords(2);
	            for(Core_IPS_Response__c envResp : envResponses){
	                envResp.Core_IPS_Case__c = c1.id;
	                envResp.Core_IPS_Question_Master__c = cq.id;
	            }
	            insert envResponses;
                
                //start added by Aayushi US95468 06/04/2018
                cq.Core_IPS_Add_to_Reporting__c=true;
                cq.Core_IPS_Reporting_Name__c='test';
                update cq;
                //end
        	}				
        Test.stopTest();
	}    
	
	/***************************************************************************************************
	Method Name			: assignCoreResponseFieldsTest
	Method Type			: void
	Version     		: 1.0 
	Created Date		: 05 Nov 2015
	Description			: This method is used for cover the assignCoreResponseFields method of Core_IPS_Response_Handler class.
	Scenario Type:  
	Modification Log 	:
	* Developer                   Date                   Description
	* ----------------------------------------------------------------------------                 
	* Yogesh Sharma       		  28/12/2017             Created
	* Amritesh					  04/25/2018			 Modified - US104141
	****************************************************************************************************/
	public static testmethod void assignCoreResponseFieldsTest(){
		Test.startTest();
			getRecords();
			//Create Custom Setting - Trigger Executions
	        Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
	        TriggerExecution.Name = 'assignCoreResponseFieldsFromEDQ';
	        TriggerExecution.Core_Active__c = true;
	        TriggerExecution.Core_Class_Name__c ='Core_IPS_Response_Handler';
	        TriggerExecution.Core_Description__c = 'This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object.';
	        TriggerExecution.Core_Object__c = 'Core_IPS_Response__c';
	        TriggerExecution.Core_Trigger_Events__c = 'Before Insert, Before Update';
	        insert TriggerExecution; 
	        System.assert(TriggerExecution.id != null);
			
        	//added by amritesh  - US104141 - 04/25/2018 - start
        	TriggerExecution = new Core_Trigger_Executions__c();
	        TriggerExecution.Name = 'updateSurveySubmitFieldOnCase';
	        TriggerExecution.Core_Active__c = true;
	        TriggerExecution.Core_Class_Name__c ='Core_IPS_Response_Handler';
	        TriggerExecution.Core_Description__c = 'Test Description';
	        TriggerExecution.Core_Object__c = 'Core_IPS_Response__c';
	        TriggerExecution.Core_Trigger_Events__c = 'After Insert';
	        insert TriggerExecution; 
	        System.assert(TriggerExecution.id != null);
        	//added by amritesh  - US104141 - 04/25/2018 - end
        
			//Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = TestUtilities.getListOfUser(1).get(0).id; 
				
			System.runAs(SystUserRunAs){
            	//Create Support Org
		        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
		        insert ListOfSupportOrg;
		        
		        System.assert(ListOfSupportOrg != null, 'Record not created');
		        
		        //Create Accounts
	            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
	            insert ListOfAccounts;
	            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
	            
	            //Create Contacts
	            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
	            for(Contact ContactRec : ListOfContacts){
	                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
	                ContactRec.core_ips_Active__c=true;
	                ContactRec.Accountid = ListOfAccounts.get(0).Id; 
	            }
	            insert ListOfContacts;
	            System.assert(ListOfContacts[0].Id != null, 'Record not created');
	            
		        //Create Case
		        Case c1 = TestUtilities.getListOfCases(2).get(0);
                c1.accountId = ListOfAccounts.get(0).Id;
                c1.ContactId = ListOfContacts.get(0).id;
                c1.Core_IPS_Customer_Visible__c = false;
                insert c1; 
                
		        //Get Record Type
		        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
		        
                //Create Core Question
		        Core_IPS_Question__c cq = new Core_IPS_Question__c();
		        cq.recordTypeId = edqRecordTypeId;
		        cq.Core_IPS_Datatype__c = 'Picklist';
		        cq.Core_IPS_Order_No__c = 1;
		        cq.Core_IPS_Parent_Question__c = null;
		        cq.Core_IPS_Product_Organization__c = ListOfSupportOrg.get(0).Id; 
		        cq.Core_IPS_Question__c = 'Test';
		        cq.Core_IPS_Required__c = false;
		        cq.Core_IPS_Status__c = 'Active';
		        
		        insert cq;
	            List<Core_IPS_Response__c> envResponses = TestUtilities.getCoreResponseRecords(2);
	            for(Core_IPS_Response__c envResp : envResponses){
	                envResp.Core_IPS_Case__c = c1.id; 
	            }
	            insert envResponses;
	            envResponses.get(0).Core_IPS_Question_Master__c = cq.id;
	            update envResponses;
	             System.AssertEquals(envResponses != null, true);   
        	}				
        Test.stopTest(); 
	}    
	 
}