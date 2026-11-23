@isTest
public class Core_IPS_BES_CasePromotion_Handler_Test {
    private class RoutingTestData {
        Core_IPS_Product_Organization__c supportOrg;
        Core_IPS_Supported_Product__c supportedProduct;
        Core_IPS_Question__c question;
    }

    private static void ensureHandlerExecutionEnabled() {
        if ([SELECT COUNT() FROM Core_Trigger_Executions__c WHERE Name = 'enableIPSCaseBackendRouting'] == 0) {
            insert new Core_Trigger_Executions__c(
                Name = 'enableIPSCaseBackendRouting',
                Core_Active__c = true,
                Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler',
                Core_Object__c = 'Case',
                Core_Trigger_Events__c = 'Core_Trigger_Events__c',
                Core_Description__c = 'test desc'
            );
        }
    }

    private static Core_IPS_Backend_System2__c createBackendSystem(String name, Boolean supportsEdq) {
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c(
            Name = name,
            Core_IPS_Target_System__c = 'hsdes:fpga:bug',
            Support_Environment_Detail_Criteria__c = supportsEdq
        );
        insert backendSystem;
        return backendSystem;
    }

    private static RoutingTestData createRoutingTestData(String suffix) {
        Product2 productRecord = Core_IPS_Backend_TestClass_Utility.getProduct();
        productRecord.Name = 'Skylake ' + suffix;
        productRecord.Core_Product_Org__c = 'IPS';
        insert productRecord;

        Core_IPS_Product_Organization__c supportOrg = new Core_IPS_Product_Organization__c(
            Core_IPS_Support_Org_Name__c = 'ORG ' + suffix,
            Core_Organization_Description__c = 'Org Description ' + suffix
        );
        insert supportOrg;

        Core_IPS_Supported_Product__c supportedProduct = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
        supportedProduct.Core_Product__c = productRecord.Id;
        supportedProduct.Core_Product_Organization__c = supportOrg.Id;
        supportedProduct.Core_Supported_Product_Name__c = 'Supported ' + suffix;
        insert supportedProduct;

        Id questionRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        Core_IPS_Question__c question = new Core_IPS_Question__c(
            RecordTypeId = questionRecordTypeId,
            Core_IPS_Datatype__c = 'Text',
            Core_IPS_Product_Organization__c = supportOrg.Id,
            Core_IPS_Question__c = 'operating system ' + suffix
        );
        insert question;

        RoutingTestData data = new RoutingTestData();
        data.supportOrg = supportOrg;
        data.supportedProduct = [SELECT Id, Name, Core_Supported_Product_Name__c FROM Core_IPS_Supported_Product__c WHERE Id = :supportedProduct.Id];
        data.question = [SELECT Id, Name FROM Core_IPS_Question__c WHERE Id = :question.Id];
        return data;
    }

    private static Case createCaseRecord(Id supportedProductId) {
        Case caseRecord = new Case();
        caseRecord.AccountId = TestUtilities.getAccount().Id;
        caseRecord.ContactId = TestUtilities.getContact().Id;
        caseRecord.Core_IPS_Product_Org1__c = TestUtilities.getProduct().Id;
        caseRecord.Core_Case_Issue_Category__c = TestUtilities.getCaseCategories().Id;
        caseRecord.Core_Issue_Description__c = 'test';
        caseRecord.Subject = 'TestSubject ' + String.valueOf(Crypto.getRandomInteger());
        caseRecord.Core_CaseType__c = 'Issue';
        caseRecord.Core_IPS_Issue_source__c = 'n/a';
        caseRecord.Core_IPS_Supported_Product__c = supportedProductId;
        caseRecord.core_ips_project_case__c = TestUtilities.getProduct().Id;
        caseRecord.Core_Environment_Details__c = '<table border="1" width="100%" style="whiteSpace:pre-line;"><tr><th>Question</th><th>Response</th></tr';
        caseRecord.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IPS_Case_Create' LIMIT 1].Id;
        caseRecord.Core_IPS_Partner_Sup_Owner__c = UserInfo.getUserId();
        insert caseRecord;
        return caseRecord;
    }

    @future
    private static void invokeFutureRouting(Id caseId) {
        Case routedCase = [SELECT Id, Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c FROM Case WHERE Id = :caseId];
        Core_IPS_BES_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(
            new List<Case>{ routedCase },
            new List<Case>{ routedCase },
            new Map<Id, Case>{ routedCase.Id => routedCase },
            new Map<Id, Case>{ routedCase.Id => routedCase }
        );
    }

    public static TestMethod void testMethod1(){
        ensureHandlerExecutionEnabled();
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

    public static testMethod void testExecuteBackendRoutingBranches() {
        ensureHandlerExecutionEnabled();

        Core_IPS_Backend_System2__c backendSystem = createBackendSystem('BES Future Skip', false);
        Case storedCase = createCaseRecord(null);

        Case oldCase = storedCase.clone(true, false, false, false);
        oldCase.Core_IPS_New_Backend_System__c = null;
        Case newCase = storedCase.clone(true, false, false, false);
        newCase.Core_IPS_New_Backend_System__c = backendSystem.Id;
        newCase.Core_IPS_BackendID__c = '';
        newCase.Core_IPS_BES_Promote_Status__c = 'Not Yet Promoted';

        Test.startTest();
        Core_IPS_BES_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(
            new List<Case>{ oldCase },
            new List<Case>{ newCase },
            new Map<Id, Case>{ oldCase.Id => oldCase },
            new Map<Id, Case>{ newCase.Id => newCase }
        );
        Core_IPS_BES_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(
            new List<Case>{ newCase },
            new List<Case>{ newCase },
            new Map<Id, Case>(),
            new Map<Id, Case>{ newCase.Id => newCase }
        );
        invokeFutureRouting(storedCase.Id);
        Test.stopTest();

        System.assertEquals(backendSystem.Id, newCase.Core_IPS_New_Backend_System__c);
    }

    public static testMethod void testExecuteMainRoutingBranches() {
        Case caseToPromote = createCaseRecord(null);
        caseToPromote.Core_IPS_BES_Promote_Status__c = 'Promote';

        Core_IPS_BES_CasePromotion_Handler.executeMainRouting(
            new List<Case>{ caseToPromote },
            new Map<Id, Case>{ caseToPromote.Id => new Case(Id = caseToPromote.Id) },
            'Attachment'
        );

        Case updatedCase = [SELECT Id, Core_IPS_BES_Promote_Status__c FROM Case WHERE Id = :caseToPromote.Id];
        System.assertEquals('In Progress', updatedCase.Core_IPS_BES_Promote_Status__c);

        Core_IPS_BES_CasePromotion_Handler.executeMainRouting(
            new List<Case>{ updatedCase },
            new Map<Id, Case>(),
            'Case'
        );
    }

    public static testMethod void testGetBackendIdBranches() {
        Core_IPS_BES_CasePromotion_Handler.initCheck = true;

        Core_IPS_Backend_System2__c queueBackend = createBackendSystem('Queue Backend', false);
        Core_IPS_Backend_System2__c edqBackend = createBackendSystem('EDQ Backend', true);
        RoutingTestData routingData = createRoutingTestData('BES');

        insert new Core_IPS_Backend_Routing__c(
            Core_IPS_Backend_Routing_Order__c = 1,
            Core_IPS_Queue__c = 'QUEUE_ONLY',
            Core_IPS_Auto_Promote__c = false,
            Core_IPS_New_Backend_System__c = queueBackend.Id
        );

        insert new List<Core_IPS_Backend_Routing__c>{
            new Core_IPS_Backend_Routing__c(
                Core_IPS_Backend_Routing_Order__c = 2,
                Core_IPS_Queue__c = 'EDQ_QUEUE',
                Core_IPS_Auto_Promote__c = true,
                Core_IPS_New_Backend_System__c = edqBackend.Id,
                Core_IPS_Supported_Product__c = routingData.supportedProduct.Id,
                Environment_Detail_Question__c = routingData.question.Id,
                Environment_Question_Answer__c = 'linux'
            ),
            new Core_IPS_Backend_Routing__c(
                Core_IPS_Backend_Routing_Order__c = 3,
                Core_IPS_Queue__c = 'EDQ_QUEUE',
                Core_IPS_Auto_Promote__c = true,
                Core_IPS_New_Backend_System__c = edqBackend.Id,
                Core_IPS_Supported_Product__c = routingData.supportedProduct.Id,
                Environment_Detail_Question__c = routingData.question.Id,
                Environment_Question_Answer__c = 'windows'
            )
        };

        Case queueCase = createCaseRecord(null);
        queueCase.Core_IPS_Assigned_Queue__c = 'QUEUE_ONLY';
        queueCase.Core_CaseType__c = null;

        Core_IPS_BES_CasePromotion_Handler.getBackendID(
            new List<Case>{ queueCase },
            new Map<Id, Case>{ queueCase.Id => queueCase },
            'Case'
        );

        System.assertEquals(queueBackend.Id, queueCase.Core_IPS_New_Backend_System__c);
        System.assertEquals('Not Yet Promoted', queueCase.Core_IPS_BES_Promote_Status__c);

        Case existingBackendCase = createCaseRecord(null);
        existingBackendCase.Core_IPS_New_Backend_System__c = queueBackend.Id;
        existingBackendCase.Core_IPS_BES_Promote_Status__c = 'Failed';

        Core_IPS_BES_CasePromotion_Handler.getBackendID(
            new List<Case>{ new Case(), existingBackendCase },
            new Map<Id, Case>{ existingBackendCase.Id => existingBackendCase },
            'Attachment'
        );

        Case edqCase = [
            SELECT Id, Core_IPS_Ext_Supported_Product__c, Core_IPS_Assigned_Queue__c, Core_CaseType__c,
                   Core_IPS_New_Backend_System__c, Core_IPS_BES_Promote_Status__c
            FROM Case
            WHERE Id = :createCaseRecord(routingData.supportedProduct.Id).Id
        ];
        edqCase.Core_IPS_Assigned_Queue__c = 'EDQ_QUEUE';
        edqCase.Core_CaseType__c = null;

        Core_IPS_BES_CasePromotion_Handler.getBackendID(
            new List<Case>{ edqCase },
            new Map<Id, Case>{ edqCase.Id => edqCase },
            'Case'
        );

        System.assertEquals(null, edqCase.Core_IPS_New_Backend_System__c);
    }

    public static testMethod void testHelperMethodsAndEdqFilter() {
        List<String> keys = Core_IPS_BES_CasePromotion_Handler.getAllPosibleKeys('Q', 'P', 'O', 'T');
        System.assertEquals(15, keys.size());
        System.assert(keys.contains('QPOT'));
        System.assert(keys.contains('Q'));
        System.assert(keys.contains('T'));

        Core_IPS_Backend_System2__c backendSystem = createBackendSystem('Stamp Backend', true);
        Case routeCase = createCaseRecord(null);

        Core_IPS_Backend_Routing__c autoPromoteRoute = new Core_IPS_Backend_Routing__c(
            Core_IPS_New_Backend_System__c = backendSystem.Id,
            Core_IPS_Auto_Promote__c = true
        );
        Map<Id, Case> stampedCaseMap = Core_IPS_BES_CasePromotion_Handler.stampBackendID(autoPromoteRoute, routeCase);
        System.assertEquals(routeCase.Id, stampedCaseMap.keySet().iterator().next());
        System.assertEquals('In Progress', routeCase.Core_IPS_BES_Promote_Status__c);

        Case manualRouteCase = createCaseRecord(null);
        Core_IPS_Backend_Routing__c manualRoute = new Core_IPS_Backend_Routing__c(
            Core_IPS_New_Backend_System__c = backendSystem.Id,
            Core_IPS_Auto_Promote__c = false
        );
        Core_IPS_BES_CasePromotion_Handler.stampBackendID(manualRoute, manualRouteCase);
        System.assertEquals('Not Yet Promoted', manualRouteCase.Core_IPS_BES_Promote_Status__c);

        Map<Id, Case> emptyStampedMap = Core_IPS_BES_CasePromotion_Handler.stampBackendID(new Core_IPS_Backend_Routing__c(), manualRouteCase);
        System.assertEquals(0, emptyStampedMap.size());
        Core_IPS_BES_CasePromotion_Handler.stampBackendID(null, manualRouteCase);

        RoutingTestData routingData = createRoutingTestData('EDQ Filter');
        Core_IPS_Answer__c answer = new Core_IPS_Answer__c(
            Core_IPS_Answer__c = 'linux',
            Core_IPS_Question__c = routingData.question.Id,
            Core_IPS_Status__c = 'Active'
        );
        insert answer;

        Case responseCase = createCaseRecord(routingData.supportedProduct.Id);
        Core_IPS_Response__c response = new Core_IPS_Response__c(
            Core_IPS_Case__c = responseCase.Id,
            Core_IPS_Question_Master__c = routingData.question.Id,
            Core_IPS_Answer_Master__c = answer.Id,
            Core_IPS_Answer__c = 'linux'
        );
        insert response;

        Core_IPS_Backend_Routing__c matchingRoute = new Core_IPS_Backend_Routing__c(
            Core_IPS_Backend_Routing_Order__c = 10,
            Core_IPS_Queue__c = 'FILTER_QUEUE',
            Core_IPS_Auto_Promote__c = true,
            Core_IPS_New_Backend_System__c = backendSystem.Id,
            Core_IPS_Supported_Product__c = routingData.supportedProduct.Id,
            Environment_Detail_Question__c = routingData.question.Id,
            Environment_Question_Answer__c = 'linux,windows'
        );
        insert matchingRoute;

        Core_IPS_Backend_Routing__c mismatchingRoute = new Core_IPS_Backend_Routing__c(
            Core_IPS_Backend_Routing_Order__c = 11,
            Core_IPS_Queue__c = 'FILTER_QUEUE',
            Core_IPS_Auto_Promote__c = true,
            Core_IPS_New_Backend_System__c = backendSystem.Id,
            Core_IPS_Supported_Product__c = routingData.supportedProduct.Id,
            Environment_Detail_Question__c = routingData.question.Id,
            Environment_Question_Answer__c = 'windows'
        );
        insert mismatchingRoute;

        List<Core_IPS_Response__c> queriedResponses = [
            SELECT Id, Core_IPS_Answer__c, Core_IPS_Question_Master__r.Name
            FROM Core_IPS_Response__c
            WHERE Id = :response.Id
        ];
        Core_IPS_Backend_Routing__c queriedMatchingRoute = [
            SELECT Id, Core_IPS_Supported_Product__c, Environment_Detail_Question__r.Name, Environment_Question_Answer__c
            FROM Core_IPS_Backend_Routing__c
            WHERE Id = :matchingRoute.Id
        ];
        Core_IPS_Backend_Routing__c queriedMismatchingRoute = [
            SELECT Id, Core_IPS_Supported_Product__c, Environment_Detail_Question__r.Name, Environment_Question_Answer__c
            FROM Core_IPS_Backend_Routing__c
            WHERE Id = :mismatchingRoute.Id
        ];

        System.assertEquals(
            true,
            Core_IPS_BES_CasePromotion_Handler.checkEDQFilterCriteria(
                queriedMatchingRoute,
                queriedResponses,
                new Map<Id, List<Core_IPS_Backend_Routing__c>>{
                    routingData.supportedProduct.Id => new List<Core_IPS_Backend_Routing__c>{ queriedMatchingRoute }
                }
            )
        );
        System.assertEquals(
            false,
            Core_IPS_BES_CasePromotion_Handler.checkEDQFilterCriteria(
                queriedMismatchingRoute,
                queriedResponses,
                new Map<Id, List<Core_IPS_Backend_Routing__c>>{
                    routingData.supportedProduct.Id => new List<Core_IPS_Backend_Routing__c>{ queriedMismatchingRoute }
                }
            )
        );
    }
    
}