/**
 * @description REST API controller for PartnerFundRequest picklist operations
 */
@RestResource(urlMapping='/api/partnerfundrequest/picklists/*')
global with sharing class PartnerFundRequestPicklistAPI {
    
    @HttpGet
    global static void getPicklists() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        
        try {
            RestRequest request = RestContext.request;
            String fieldName = request.params.get('field');
            String action = request.params.get('action');
            
            String jsonResponse = '';
            
            if (String.isNotBlank(fieldName)) {
                jsonResponse = getFieldPicklistJSON(fieldName, action);
            } else {
                jsonResponse = getAllPicklistsJSON(action);
            }
            
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(jsonResponse);
            
        } catch (Exception e) {
            String errorType = 'SYSTEM_ERROR';
            Integer statusCode = 500;
            
            // Check if it's a known picklist error
            if (e.getMessage().contains('PartnerFundRequestPicklistUtility Error') || 
                e.getMessage().contains('does not exist') || 
                e.getMessage().contains('not a picklist field')) {
                errorType = 'PICKLIST_ERROR';
                statusCode = 400;
            }
            
            String errorJson = JSON.serialize(new Map<String, Object>{
                'success' => false,
                'error' => e.getMessage(),
                'errorCode' => errorType,
                'timestamp' => System.now()
            });
            
            response.statusCode = statusCode;
            response.responseBody = Blob.valueOf(errorJson);
        }
    }
    
    private static String getFieldPicklistJSON(String fieldName, String action) {
        Map<String, Object> result = new Map<String, Object>{
            'success' => true,
            'timestamp' => System.now()
        };
        
        if (action == 'options') {
            result.put('data', new Map<String, Object>{
                'objectType' => 'PartnerFundRequest',
                'fieldName' => fieldName,
                'options' => PartnerFundRequestPicklistUtility.getPicklistOptionsWithLabels(fieldName)
            });
        } else if (action == 'validate') {
            result.put('data', new Map<String, Object>{
                'objectType' => 'PartnerFundRequest',
                'fieldName' => fieldName,
                'isPicklist' => PartnerFundRequestPicklistUtility.isPicklistField(fieldName)
            });
        } else if (action == 'info') {
            result.put('data', new Map<String, Object>{
                'objectType' => 'PartnerFundRequest',
                'fieldName' => fieldName,
                'fieldInfo' => PartnerFundRequestPicklistUtility.getPicklistFieldInfo(fieldName)
            });
        } else {
            result.put('data', new Map<String, Object>{
                'objectType' => 'PartnerFundRequest',
                'fieldName' => fieldName,
                'values' => PartnerFundRequestPicklistUtility.getPicklistValues(fieldName),
                'defaultValue' => PartnerFundRequestPicklistUtility.getPicklistDefaultValue(fieldName)
            });
        }
        
        return JSON.serialize(result);
    }
    
    private static String getAllPicklistsJSON(String action) {
        Map<String, Object> result = new Map<String, Object>{
            'success' => true,
            'timestamp' => System.now()
        };
        
        if (action == 'metadata') {
            result.put('data', new Map<String, Object>{
                'objectType' => 'PartnerFundRequest',
                'metadata' => PartnerFundRequestPicklistUtility.getPicklistFieldsMetadata()
            });
        } else {
            Map<String, List<String>> allPicklists = PartnerFundRequestPicklistUtility.getAllPicklistValues();
            result.put('data', new Map<String, Object>{
                'objectType' => 'PartnerFundRequest',
                'allPicklists' => allPicklists,
                'summary' => new Map<String, Object>{
                    'totalFields' => allPicklists.size(),
                    'timestamp' => System.now()
                }
            });
        }
        
        return JSON.serialize(result);
    }
}