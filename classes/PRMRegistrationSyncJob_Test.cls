@IsTest
private class PRMRegistrationSyncJob_Test {
    // Mock Azure Function returning company per recordId
    private class MockAzure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Payload sent by the job
            List<Object> payload = (List<Object>) JSON.deserializeUntyped(req.getBody());

            // Build a response row for each input with a "company" value
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            for (Object o : payload) {
                Map<String,Object> row = (Map<String,Object>) o;
                String recId = (String) row.get('recordId');
                results.add(new Map<String,Object>{
                    'recordId' => recId,
                    'company'  => 'Acme via Azure' // what Cosmos/Azure would return
                });
            }

            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setBody(JSON.serialize(results));
            return r;
        }
    }

    @IsTest
    static void createsAIInfoAndSetsResponse() {
        // Seed a parent request
        PRM_Registration_Request__c parent = new PRM_Registration_Request__c(
            Name = 'Req A',
            PRM_Account_Name__c = 'Acme (original)',
            PRM_First_Name__c = 'Test',
            PRM_Last_Name__c = 'Testman',
            PRM_Email_ID__c = 'test@example.com',
            PRM_Account_URL__c = 'https://www.acme.com'
        );
        insert parent;

        // Ensure no existing AI info
        System.assertEquals(0, [
            SELECT COUNT() FROM PRM_Registration_AI_Agent_Info__c
            WHERE PRM_Registration_Request__c = :parent.Id
        ]);

        // Register HTTP mock and run the job
        Test.setMock(HttpCalloutMock.class, new MockAzure());
        Test.startTest();
        System.enqueueJob(new PRMRegistrationSyncJob(new List<Id>{ parent.Id }));
        Test.stopTest();

        // Verify AI info created and PRM_AI_Evidence__c set from Azure "company"
        PRM_Registration_AI_Agent_Info__c ai = [
            SELECT Id, PRM_Registration_Request__c, PRM_AI_Evidence__c
            FROM PRM_Registration_AI_Agent_Info__c
            WHERE PRM_Registration_Request__c = :parent.Id
            LIMIT 1
        ];
        System.assertEquals(parent.Id, ai.PRM_Registration_Request__c, 'Lookup should point to the parent request');
        System.assertEquals('Acme via Azure', ai.PRM_AI_Evidence__c, 'AI response should come from Azure result');
    }

    @IsTest
    static void updatesExistingAIInfo() {
        // Parent + pre-existing AI record
        PRM_Registration_Request__c parent = new PRM_Registration_Request__c(
            Name = 'Req B',
            PRM_Account_Name__c = 'BetaCo',
            PRM_First_Name__c = 'Test',
            PRM_Last_Name__c = 'Testman',
            PRM_Email_ID__c = 'test@example.com',
            PRM_Account_URL__c = 'https://www.betaco.com'
        );
        insert parent;

        PRM_Registration_AI_Agent_Info__c ai = new PRM_Registration_AI_Agent_Info__c();
        ai.put('PRM_Registration_Request__c', parent.Id); // use your actual lookup API name if different
        ai.PRM_AI_Evidence__c = 'stale';
        insert ai;

        // Run job -> should UPDATE the same AI record
        Test.setMock(HttpCalloutMock.class, new MockAzure());
        Test.startTest();
        System.enqueueJob(new PRMRegistrationSyncJob(new List<Id>{ parent.Id }));
        Test.stopTest();

        PRM_Registration_AI_Agent_Info__c aiAfter = [
            SELECT Id, PRM_Registration_Request__c, PRM_AI_Evidence__c
            FROM PRM_Registration_AI_Agent_Info__c
            WHERE PRM_Registration_Request__c = :parent.Id
            LIMIT 1
        ];
        System.assertEquals(ai.Id, aiAfter.Id, 'Should update existing AI record, not create a new one');
        System.assertEquals('Acme via Azure', aiAfter.PRM_AI_Evidence__c);
    }
}