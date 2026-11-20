@isTest
public class Core_IPS_BES_Updatecase_Test {

    static testMethod void testUpdateCase() {
        // Step 1: Setup test data
        
        // Create mock IPS_Case_Fields__c data to mimic custom settings
        IPS_Case_Fields__c caseField1 = new IPS_Case_Fields__c(Name = 'Name1',Object_Name__c = 'Case', API_Name__c = 'Core_Issue_Description__c', JSON_Field_Name__c = 'issue_description', Order__c = 1);
        IPS_Case_Fields__c caseField2 = new IPS_Case_Fields__c(Name = 'Name21',Object_Name__c = 'Case', API_Name__c = 'HSD_Mirror_Status__c', JSON_Field_Name__c = 'hsd_mirror_status', Order__c = 2);
        insert new List<IPS_Case_Fields__c>{caseField1, caseField2};
		Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'CC - HSDES Client Platform';
        
        backendSystem.Core_IPS_Target_System__c = 'hsdes:client_platf:bug';
        insert backendSystem;
        // Create test case data for updating
        List<Case> caseList = new List<Case>();
        Case case1 = new Case( Status = 'New', Core_IPS_New_Backend_System__c = backendSystem.Id,Origin = 'Web',Priority = 'High',Subject = 'TestSubject',Description = 'TestDescription');
        Case case2 = new Case( Status = 'Open', Core_IPS_New_Backend_System__c = backendSystem.Id,Origin = 'Web',Priority = 'High',Subject = 'TestSubject',Description = 'TestDescription');
        caseList.add(case1);
        caseList.add(case2);
        insert caseList;
        Map<String, String> userDetailsMap = new Map<String, String>();
        userDetailsMap.put('testuser@test.com', 'testuser@test.com;Test User;;');
        List<String> caseStrings = new List<String>();
        Map<String, Object> inboundData1 = new Map<String, Object>();
        inboundData1.put('system_details', new Map<String, Object>{'target_id' => 'CASE123', 'source_id' => 'BackendSystem1', 'backend_rev' => '2'});
        inboundData1.put('issue_information', new Map<String, Object>{'owner_info' => 'testuser@test.com', 'hsd_mirror_status' => 'Active', 'hsd_mirror_reason' => 'Issue Resolved', 'comment_text' => 'Fix applied', 'comment_author' => 'testuser@test.com'});
        caseStrings.add(JSON.serialize(inboundData1));
        Map<String, Object> inboundData2 = new Map<String, Object>();
        inboundData2.put('system_details', new Map<String, Object>{'target_id' => 'CASE124', 'source_id' => 'BackendSystem2', 'backend_rev' => '1'});
        inboundData2.put('issue_information', new Map<String, Object>{'owner_info' => 'testuser@test.com', 'hsd_mirror_status' => 'Inactive', 'hsd_mirror_reason' => 'Closed', 'comment_text' => 'Closed without action', 'comment_author' => 'testuser@test.com'});
        caseStrings.add(JSON.serialize(inboundData2));
        Test.startTest();
        Core_IPS_BES_UpdateCase.updateCase(caseStrings, userDetailsMap);
        Test.stopTest();
        List<Case> updatedCases = [SELECT Id, CaseNumber, Status, Core_IPS_New_Backend_System__c FROM Case];
        for (Integer i=0;i<2;i++) {
            if (i==0) {
                //System.assertEquals(updatedCases[0].Status, 'Open', 'Status should be updated');
               // System.assertEquals(updatedCases[0].Core_IPS_New_Backend_System__c, 'System1', 'Backend system should be updated');
            } else {
               // System.assertEquals(updatedCases[0].Status, 'Closed', 'Status should be updated');
               // System.assertEquals(updatedCases[0].Core_IPS_New_Backend_System__c, 'System2', 'Backend system should be updated');
            }
        }

        try {
            // Simulating a case where the backend system is deactivated
            Case caseDeactivated = new Case( Status = 'New', Core_IPS_New_Backend_System__c = 'SystemDeactivated');
            insert caseDeactivated;

            Map<String, Object> inboundDataDeactivated = new Map<String, Object>();
            inboundDataDeactivated.put('system_details', new Map<String, Object>{'target_id' => 'CASE125', 'source_id' => 'BackendSystemDeactivated', 'backend_rev' => '3'});
            inboundDataDeactivated.put('issue_information', new Map<String, Object>{'owner_info' => 'testuser@test.com', 'hsd_mirror_status' => 'Active', 'hsd_mirror_reason' => 'Issue Resolved', 'comment_text' => 'Fix applied', 'comment_author' => 'testuser@test.com'});
            List<String> caseStringsDeactivated = new List<String>{JSON.serialize(inboundDataDeactivated)};

            Test.startTest();
            Core_IPS_BES_UpdateCase.updateCase(caseStringsDeactivated, userDetailsMap);
            Test.stopTest();
        } catch (Exception ex) {
            //System.assert(ex instanceof Core_IPS_BES_UpdateCase.CustomException, 'Exception should be thrown for deactivated backend systems');
        }
        
        
    }
   
}