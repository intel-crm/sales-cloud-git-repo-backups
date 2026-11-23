public class PRMRegistrationSyncJob implements Queueable, Database.AllowsCallouts {
    private List<Id> ids;
    public PRMRegistrationSyncJob(List<Id> ids) { this.ids = ids.clone(); }

    // Adjust if your names differ
    private static final String NAMED_CREDENTIAL = 'AzureAPI';
    private static final String ENDPOINT_PATH    = '/cosmos/prm-registration';
    private static final String AI_LOOKUP_FIELD  = 'PRM_Registration_Request__c'; // on PRM_Registration_AI_Agent_Info__c

    public void execute(QueueableContext qc) {
        // 1) Load parents
        List<PRM_Registration_Request__c> parents = [
            SELECT Id, Name, PRM_Account_Name__c
            FROM PRM_Registration_Request__c
            WHERE Id IN :ids
        ];
        if (parents.isEmpty()) return;

        // 2) Build payload
        List<Map<String, Object>> payload = new List<Map<String, Object>>();
        for (PRM_Registration_Request__c p : parents) {
            payload.add(new Map<String, Object>{
                'recordId'    => p.Id,
                'accountName' => p.PRM_Account_Name__c
            });
        }

        // 3) Call Azure (Cosmos write happens there)
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CREDENTIAL + ENDPOINT_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));

        HttpResponse res = new Http().send(req);
        // Expect: [{ "recordId":"a0D...","company":"Acme, Inc." }, ...]
        Map<Id, String> companyById = new Map<Id, String>();
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            List<Object> rows = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for (Object row : rows) {
                Map<String,Object> m = (Map<String,Object>) row;
                if (m.containsKey('recordId') && m.containsKey('company')) {
                    companyById.put((Id)(String)m.get('recordId'), (String)m.get('company'));
                }
            }
        }

        // 4) Upsert AI records (set PRM_AI_Response__c = company)
        Set<Id> parentIds = new Map<Id, PRM_Registration_Request__c>(parents).keySet();
        Map<Id, PRM_Registration_AI_Agent_Info__c> existingByParent = new Map<Id, PRM_Registration_AI_Agent_Info__c>(
            [SELECT Id, PRM_Registration_Request__c
               FROM PRM_Registration_AI_Agent_Info__c
              WHERE PRM_Registration_Request__c IN :parentIds]
        );

        List<PRM_Registration_AI_Agent_Info__c> inserts = new List<PRM_Registration_AI_Agent_Info__c>();
        List<PRM_Registration_AI_Agent_Info__c> updates = new List<PRM_Registration_AI_Agent_Info__c>();

        for (PRM_Registration_Request__c p : parents) {
            String company = companyById.get(p.Id); // may be null if Azure failed or omitted
            PRM_Registration_AI_Agent_Info__c ai = existingByParent.get(p.Id);

            if (ai == null) {
                ai = new PRM_Registration_AI_Agent_Info__c();
                ai.put(AI_LOOKUP_FIELD, p.Id);            // lookup to the request
                ai.Name = 'AI Info for ' + p.Name;        // optional friendly name
                ai.PRM_AI_Evidence__c = company;
                inserts.add(ai);
            } else {
                ai.PRM_AI_Evidence__c = company;
                updates.add(ai);
            }
        }

        if (!inserts.isEmpty()) insert inserts;
        if (!updates.isEmpty()) update updates;
    }
}