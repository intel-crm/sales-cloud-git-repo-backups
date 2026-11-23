public with sharing class ACM_CNDA_Map_To_Salesforce {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getContracts() {
        // Sample JSON data
        String jsonData = '{"success": true, "message": "", "result": [' +
                          '{"counterparty_country": "China", "intel_contact_name": "Karen Delgado Navarro", "counterparty_name": "Frangle Labs Inc.", "contract_type0": "NDA", "contract_subtype": "CNDA", "counterparty_state_province": "Beijing Shi", "counterparty_address_line_2": "No. 2, FuXingMenWai Avenue", "contract_number": "cnda000001", "counterparty_city": "Beijing", "counterparty_address_line_1": "No. 2, FuXingMenWai Avenue"},' +
                          '{"counterparty_country": "China", "intel_contact_name": "Karen Delgado Navarro", "counterparty_name": "Frangle Labs Inc.", "contract_type0": "NDA", "contract_subtype": "CNDA", "counterparty_state_province": "Beijing Shi", "contract_number": "cnda000024", "counterparty_city": "Beijing", "counterparty_address_line_1": "No. 2, FuXingMenWai Avenue"}' +
                          ']}';

        // Deserialize the JSON data into a Map
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        
        // Get the 'result' part and ensure it's a List<Object>
        Object resultObj = responseData.get('result'); 

        List<Map<String, Object>> contracts = new List<Map<String, Object>>();

        // Check if resultObj is a List and cast accordingly
        if (resultObj instanceof List<Object>) {
            List<Object> resultList = (List<Object>) resultObj;

            for (Object obj : resultList) {
                if (obj instanceof Map<String, Object>) {
                    contracts.add((Map<String, Object>) obj);
                }
            }
        }
system.debug('check contract'+contracts);
        return contracts;
    }
}