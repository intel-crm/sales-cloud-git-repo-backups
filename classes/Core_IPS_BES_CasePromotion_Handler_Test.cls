@isTest
public class Core_IPS_BES_CasePromotion_Handler_Test {
    public static TestMethod void testMethod1(){
         Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(Name= 'enableIPSCaseBackendRouting', Core_Active__c = true,
                                                                                     Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler', Core_Object__c = 'Case',
                                                                                    Core_Trigger_Events__c = 'Core_Trigger_Events__c', Core_Description__c = 'test desc');
        insert triggerExecution;
         List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        Map<String,String> profiles = new Map<String, String>();
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';
        backendSystem.Support_Environment_Detail_Criteria__c = true;
        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        backendSystem.Support_Environment_Detail_Criteria__c = true;
        insert backendSystem;
         List<User> ListOfUser = TestUtilities.getListOfUser(1);
         ListOfUser[0].ProfileId = profiles.get('System Administrator');
         insert ListOfUser;
        List<Product2> prodlist = new List<Product2>();
            Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
            prod.Core_Product_Org__c='IPS'; 
           
            prodList.add(prod);
            system.runas(ListOfUser[0])
            {
                insert prodList;
            }
        Core_IPS_Product_Organization__c supportOrg = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics2', Core_Organization_Description__c = 'Intel customer Support2');
        insert supportOrg;
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd.Core_Product__c=prod.id;
            suppProd.Core_Product_Organization__c=supportOrg.id;
            suppProdList.add(suppProd);
        insert suppProdList;
        
        Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        
         Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = supportOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
        insert envQuest;
        
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c = envQuest.id;
            answers1.Core_IPS_Status__c = 'Active';
        insert answers1;
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        backendRoutingRule.Core_IPS_Supported_Product__c = suppProdList[0].Id;
        backendRoutingRule.Environment_Detail_Question__c= envQuest.Id;
        backendRoutingRule.Environment_Question_Answer__c = 'test';
        insert backendRoutingRule; 
        Case CaseRecord = new Case();
        CaseRecord.AccountId= TestUtilities.getAccount().Id;
        CaseRecord.ContactId=TestUtilities.getContact().Id;  
        CaseRecord.Core_IPS_Product_Org1__c= TestUtilities.getProduct().Id;
        CaseRecord.Core_Case_Issue_Category__c = TestUtilities.getCaseCategories().Id;

        CaseRecord.Core_Issue_Description__c = 'test';

        CaseRecord.Subject='TestSubject';
        CaseRecord.Core_CaseType__c='Issue';
        CaseRecord.Core_IPS_Issue_source__c='n/a';
        caseRecord.Core_IPS_Supported_Product__c = suppProdList[0].Id;
        CaseRecord.core_ips_project_case__c= TestUtilities.getProduct().Id;
        CaseRecord.Core_Environment_Details__c = '<table border="1" width="100%" style="whiteSpace:pre-line;"><tr><th>Question</th><th>Response</th></tr';
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        CaseRecord.recordTypeId = RT.Id;
        CaseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        RecordType RT2 = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        
        Test.startTest();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            CaseRecord.setOptions(dmo);
            insert CaseRecord;
            List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
            insert outboundObject;
            
            if(outboundObject.size()>0){
                outboundObject[0].core_IPS_Outbound_Message_ID__c = '123';
                outboundObject[0].Core_IPS_Case_ID__c = CaseRecord.Id; 
                outboundObject[0].Status__c = 'Apigee Success';
                update outboundObject;
              //  Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id});
            }
            CaseRecord.Subject='TestSubject';
            CaseRecord.Core_IPS_BackendID__c = '1212121111';
            update CaseRecord;
            CaseRecord.core_IPS_BES_promote_status__c = 'Failed';
            CaseRecord.Core_IPS_BackendID__c = '';
            update CaseRecord; 

          
            CaseRecord.Core_IPS_New_Backend_System__c = null;
            CaseRecord.core_IPS_BES_promote_status__c = 'Promote';
            CaseRecord.Core_IPS_BackendID__c = '';
            update CaseRecord;
            CaseRecord.Core_IPS_gec_flag__c = true;
            CaseRecord.Core_IPS_gec_status__C = 'Approved';
            update CaseRecord;
        //21/11/2023
        	Map<String,String> caseRec = new Map<String,String>();
        	caseRec.put(CaseRecord.Id,'1212121111;'+ backendSystem.Id);
        	Core_IPS_BES_OutboundMessage.createPlatformEventHSD(caseRec);
        Case updatedCase = [SELECT Id, core_IPS_BES_promote_status__c FROM Case WHERE Id = :CaseRecord.Id];
        System.assertEquals('In Progress', updatedCase.core_IPS_BES_promote_status__c, 'Status should be approved');
        	//21/11/2023
        Test.stopTest();
    }
    
}