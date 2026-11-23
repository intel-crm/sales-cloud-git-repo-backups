/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_PFC_APIService
 * Author          : <YourName>
 * Created Date    : May 21, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 21, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 21, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class Core_MDF_PFC_APIService {

	private static final String SUCCESS_CODE_200 = '200';
    private static final String PARTIAL_SUCCESS_CODE_206 = '206';
    private static final String ERROR_CODE_400 = '400';
    private static final String ERROR_CODE_500 = '500';
    private static final String MALFORMED_INPUT_9011 = '9011';
    private static final String PARTNER_FUND_CLAIMS_PAYLOAD_KEY = 'partnerfundclaims';
    private static final String CREATE_ACTION = 'create';
    private static final String UPDATE_ACTION = 'update';   
    
    public class BulkClaimException extends Exception {}
    
    /***************************************************************************************************** 
    Method Name:        processRequest
    @return  :          Core_MDF_PFC_APIResponse
    @parameters:        None
    Description:        This method validates the incoming bulk claim request, generates JWT access token,
                        extracts payload data, determines the requested action, and processes claims.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/
    public static Core_MDF_PFC_APIResponse processRequest() {
        Core_MDF_PFC_APIResponse response = new Core_MDF_PFC_APIResponse();
        
        try {
            // Step 1: Generate Access Token
            String accessToken = generateAccessToken();
			System.debug('accessToken===='+accessToken);
            if (String.isBlank(accessToken)) {
                return createErrorResponse(ERROR_CODE_400, 'Access Token generation failed');
            }
            
            // Step 2: Validate and Parse Request
            String requestBody = getRequestBody();
            if (String.isBlank(requestBody)) {
                return createErrorResponse(ERROR_CODE_400, 'Request Body is empty');
            }
            
            // Step 3: Extract Claims Payload
            List<Object> claimsPayload = extractClaimsPayload(requestBody);
            if (claimsPayload == null || claimsPayload.isEmpty()) {
                return createErrorResponse(ERROR_CODE_400, 'No claims found in payload');
            }
            
            // Step 4: Determine Action
            String actionName = resolveAction();
            if (String.isBlank(actionName)) {
                return createErrorResponse(ERROR_CODE_400, 'Action parameter is required');
            }
            
            // Step 5: Process Claims Based on Action
            //response = processClaimsByAction(actionName, claimsPayload, accessToken);
            
        } catch (Exception ex) {
            System.debug('Exception in processRequest: ' + ex.getMessage());
            response = createErrorResponse(ERROR_CODE_500, 'Internal server error: ' + ex.getMessage());
        }        
        return response;
    }   
    /***************************************************************************************************** 
    Method Name:        getRequestBody
    @return  :          String
    @parameters:        None
    Description:        This method retrieves the incoming REST API request body from RestContext.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/

    private static String getRequestBody() {
        RestRequest request = RestContext.request;
        return request?.requestBody?.toString();
    }

    /***************************************************************************************************** 
    Method Name:        extractClaimsPayload
    @return  :          List<Object>
    @parameters:        String requestBody
    Description:        This method parses the incoming JSON payload and extracts the
                        partnerfundclaims collection from the request body.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/
    private static List<Object> extractClaimsPayload(String requestBody) {
        try {
            Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);            
            if (!payloadMap.containsKey(PARTNER_FUND_CLAIMS_PAYLOAD_KEY)) {
                throw new BulkClaimException('partnerfundclaims key missing in payload');
            }            
            return (List<Object>) payloadMap.get(PARTNER_FUND_CLAIMS_PAYLOAD_KEY);            
        } catch (Exception ex) {
            System.debug('Error extracting claims payload: ' + ex.getMessage());
            throw new BulkClaimException('Invalid JSON payload: ' + ex.getMessage());
        }
    }
    /***************************************************************************************************** 
    Method Name:        resolveAction
    @return  :          String
    @parameters:        None
    Description:        This method retrieves and validates the action parameter from the REST request URL.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/
    private static String resolveAction() {
        String actionName = Core_MDF_PFC_APIUtil.getRequestParam('action');
        return String.isNotBlank(actionName) ? actionName.trim().toLowerCase() : null;
    }

    /***************************************************************************************************** 
    Method Name:        getIntegrationConfig
    @return  :          Core_MDF_PFC_API_Integration_Config__mdt
    @parameters:        None
    Description:        This method retrieves JWT and API endpoint configuration values
                        from Custom Metadata for authentication and integration processing.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/
    private static Core_MDF_PFC_API_Integration_Config__mdt getIntegrationConfig() {
        return [SELECT JWT_Issuer__c, JWT_Subject__c, JWT_Audience__c, JWT_Certificate__c, Token_Endpoint__c FROM Core_MDF_PFC_API_Integration_Config__mdt LIMIT 1];
    }
    
    /***************************************************************************************************** 
    Method Name:        generateAccessToken
    @return  :          String
    @parameters:        None
    Description:        This method generates a JWT token using configured certificate details
                        and exchanges it for a Salesforce OAuth access token.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/

    public static String generateAccessToken() {
        try {
            Core_MDF_PFC_API_Integration_Config__mdt config = getIntegrationConfig(); 
            // Create JWT
            Auth.JWT jwt = new Auth.JWT();
            jwt.setIss(config.JWT_Issuer__c);
            jwt.setSub(config.JWT_Subject__c);
            jwt.setAud(config.JWT_Audience__c);
            jwt.setValidityLength(300); // 5 minutes
            
            // Sign JWT
            Auth.JWS jws = new Auth.JWS(jwt, config.JWT_Certificate__c);
            String jwtToken = jws.getCompactSerialization();            
            System.debug('Generated JWT Token: ' + jwtToken);            
            // Exchange JWT for Access Token
            HttpRequest req = new HttpRequest();
            req.setEndpoint(config.Token_Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + EncodingUtil.urlEncode(jwtToken, 'UTF-8'));
            req.setTimeout(60000);            
            Http http = new Http();
            HttpResponse res = http.send(req);            
            System.debug('Token Response Code: ' + res.getStatusCode());
            System.debug('Token Response Body: ' + res.getBody());
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                return (String) responseMap.get('access_token');
            } else {
                throw new CalloutException('Token generation failed. Status: ' + res.getStatusCode() + ', Body: ' + res.getBody());
            }            
        } catch (Exception ex) {
            System.debug('Exception in generateAccessToken: ' + ex.getMessage());
            throw new CalloutException('Access token generation failed: ' + ex.getMessage());
        }
    }   
    /***************************************************************************************************** 
    Method Name:        createErrorResponse
    @return  :          Core_MDF_PFC_APIResponse
    @parameters:        String code, String message
    Description:        This method constructs and returns a standardized error response
                        object for API failure scenarios.
    Added By:           <YourName> - 05/21/2026
    Modified By:        Date:       Changes:
    *****************************************************************************************************/  
    private static Core_MDF_PFC_APIResponse createErrorResponse(String code, String message) {
        Core_MDF_PFC_APIResponse response = new Core_MDF_PFC_APIResponse();
        response.isSuccess = false;
        response.code = code;
        response.message = message;
        return response;
    }

}