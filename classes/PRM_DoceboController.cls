/*************************************************************************************************************************************************************************
* Class Name  : PRM_DoceboController 
* Version     : 1.0 
* Created Date: sept 2026
* Modification Log :
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Nitesh            M-01    : Original version   14/09/2026                                class for handling the docebo callout through middleware.
* Manasa            M-01    : Original version   14/10/2026                                changes in callout-removal of hardcodings and APIGEE Usage.
**************************************************************************************************************************************************************************/

public without sharing class PRM_DoceboController {
    
    private static final String LOG_ENTRY_ORIGIN   = 'PRM_DoceboController';
    //private static final String LOG_ENTRY_PROJECT  = 'Docebo Integration';
    private static final String LOG_ENTRY_PROJECT  = 'IPA';
    private static final String LOG_ENTRY_SCOPE    = 'Docebo Callout';
    private static final String LOG_ENTRY_SEVERITY = 'Critical';
    private static final String DOCEBO_DOMAIN = string.valueof(system.label.PRM_DOCEBO_DOMAIN);
    private static final Integer CALLOUT_TIMEOUT = Integer.valueOf(System.Label.PRM_Docebo_Timeout);
    //private static final String USERNAME = 'test.endpoints1@test.test';
    //Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
    /*private static final Map<String, String> SF_TO_DOCEBO_LANG_MAP = new Map<String, String>{
    'en_US' => 'en',
    'en_GB' => 'en-gb',

    'de'    => 'de',
    'es'    => 'es',
    'es_MX' => 'es-419',

    'fr'    => 'fr',

    'it'    => 'it',
    'ja'    => 'ja',
    'ko'    => 'ko',
    'sv'    => 'sv',

    'zh_CN' => 'zh',
    'zh_TW' => 'zh-hant',

    'pt_BR' => 'pt-br',

    'nl_NL' => 'nl',
    'da'    => 'da',
    'th'    => 'th',
    'fi'    => 'fi',
    'ru'    => 'ru',
    'no'    => 'no',
    'pl'    => 'pl',
    'tr'    => 'tr',

    'in'    => 'id',    // Salesforce uses in, Docebo uses id

    'vi'    => 'vi'
};*/
    @AuraEnabled(cacheable=false)
    public static DoceboResponse getChannelAssets() {
        
        Datetime reqTime = System.now();
        Id cpId;
        Integer responseCodeForLog = 200;
        String responseMessageForLog = 'Successful response';
      
        try {
            cpId = [SELECT Id FROM ChannelProgram WHERE prm_programCode__c = :System.Label.PRM_IPAEngagement LIMIT 1].Id;
        } catch (Exception e) {
            cpId = null;
        }
        
        try {
            User currentUser = [Select id, email,username,LanguageLocaleKey from User where Id =: UserInfo.getUserId() limit 1]; 
            String USERNAME = currentUser.email;
            string userLanguage = currentUser.LanguageLocaleKey;
            String doceboLanguageCodeForLoggedInUser = getDoceboLanguageCode(userLanguage);
            Map<String,String> authPayload = new Map<String,String>{'username' => USERNAME};
                
                String authRequest = JSON.serialize(authPayload);
            
            HttpRequest doceboReq = new HttpRequest();
            doceboReq.setEndpoint('callout:PRM_IPA_Docebo');
            doceboReq.setMethod('POST');
            doceboReq.setHeader('Content-Type','application/json');
            doceboReq.setHeader('Accept','application/json');
            doceboReq.setBody(authRequest);
            doceboReq.setTimeout(CALLOUT_TIMEOUT);
            
            HttpResponse doceboRes;
            
            try {
                doceboRes = new Http().send(doceboReq);
            }
            catch(Exception ex) {
                responseCodeForLog = 500;
                responseMessageForLog = ex.getMessage();               
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY,'','','','PRM_DoceboController.getChannelAssets','',ex);                
                return buildErrorResponse(500,'Internal Server Error');
            }
            
            Integer authStatusCode = doceboRes.getStatusCode();
            
            if(authStatusCode == 204){
                responseCodeForLog = 204;
                responseMessageForLog = doceboRes.getBody();              
                DoceboResponse response = new DoceboResponse();
                response.userExists = false;
                response.courses = new List<CourseWrapper>();
                response.status = '204 - No results were returned';                
                return response;
            }
            else if(authStatusCode == 400){
                responseCodeForLog = 400;
                responseMessageForLog = doceboRes.getBody();
                
                return handleError(400,'Bad Request','Auth API - Bad Request',doceboRes.getBody());
            }
            else if(authStatusCode == 401){
                responseCodeForLog = 401;
                responseMessageForLog = doceboRes.getBody();
                
                return handleError(401,'Authentication Failed','Auth API - Authentication Failed',doceboRes.getBody());
            }
            else if(authStatusCode == 403){
                responseCodeForLog = 403;
                responseMessageForLog = doceboRes.getBody();
                
                return handleError(403,'Insufficient Permissions','Auth API - Forbidden',doceboRes.getBody());
            }
            else if(authStatusCode == 404){
                responseCodeForLog = 404;
                responseMessageForLog = doceboRes.getBody();
                
                return handleError(404,'Not Found','Auth API - Not Found',doceboRes.getBody());
            }
            else if(authStatusCode == 500){
                responseCodeForLog = 500;
                responseMessageForLog = doceboRes.getBody();
                
                return handleError(500,'Internal Server Error','Auth API - Internal Server Error',doceboRes.getBody());
            }
            else if(authStatusCode != 200 && authStatusCode != 201){
                responseCodeForLog = authStatusCode;
                responseMessageForLog = doceboRes.getBody();
                
                return handleError(authStatusCode,'Unexpected Response','Auth API - Unexpected Response',doceboRes.getBody());
            }
            
            Map<String,Object> authResponse = (Map<String,Object>)JSON.deserializeUntyped(doceboRes.getBody());
            
            String accessToken = String.valueOf(authResponse.get('access_token'));
            
            if(String.isBlank(accessToken)) {
                
                responseCodeForLog = 401;
                responseMessageForLog = 'Access token not returned';
                
                return handleError(
                    401,
                    'Authentication Failed',
                    'Auth API - Access Token Missing',
                    'Access token not returned'
                );
            }
            
            HttpRequest channelReq = new HttpRequest();
            channelReq.setEndpoint('callout:PRM_DOCEBO_ChannelEndpoint');
            channelReq.setMethod('GET');
            channelReq.setHeader('Authorization','Bearer ' + accessToken);
            channelReq.setHeader('token', accessToken);
            channelReq.setHeader('Accept', 'application/json');
            channelReq.setTimeout(CALLOUT_TIMEOUT);
            
            HttpResponse channelRes;
            
            try {
                channelRes = new Http().send(channelReq);
            }
            catch(Exception ex) {
                responseCodeForLog = 500;
                responseMessageForLog = ex.getMessage();               
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,'Channel API Callout Failed',LOG_ENTRY_SEVERITY,'','','','PRM_DoceboController.getChannelAssets','',ex);                
                return buildErrorResponse(500,'Internal Server Error');
            }
            
            
            Integer channelStatusCode = channelRes.getStatusCode();
            
            if(channelStatusCode == 204){
                responseCodeForLog = 204;
                responseMessageForLog = channelRes.getBody();
                
                DoceboResponse response = new DoceboResponse();
                response.userExists = true;
                response.courses = new List<CourseWrapper>();
                response.status = '204 - No results were returned';
                
                return response;
            }
            else if(channelStatusCode == 400){
                responseCodeForLog = 400;
                responseMessageForLog = channelRes.getBody();
                
                return handleError(400,'Bad Request','Channel API - Bad Request',channelRes.getBody());
            }
            else if(channelStatusCode == 401){
                responseCodeForLog = 401;
                responseMessageForLog = channelRes.getBody();
                
                return handleError(401,'Authentication Failed','Channel API - Authentication Failed',channelRes.getBody());
            }
            else if(channelStatusCode == 403){
                responseCodeForLog = 403;
                responseMessageForLog = channelRes.getBody();
                
                return handleError(403,'Insufficient Permissions','Channel API - Forbidden',channelRes.getBody());
            }
            else if(channelStatusCode == 404){
                responseCodeForLog = 404;
                responseMessageForLog = channelRes.getBody();
                
                return handleError(404,'Not Found','Channel API - Not Found',channelRes.getBody());
            }
            else if(channelStatusCode == 500){
                responseCodeForLog = 500;
                responseMessageForLog = channelRes.getBody();                
                return handleError(500,'Internal Server Error','Channel API - Internal Server Error',channelRes.getBody());
            }
            else if(channelStatusCode != 200 && channelStatusCode != 201){
                responseCodeForLog = channelStatusCode;
                responseMessageForLog = channelRes.getBody();                
                return handleError(channelStatusCode,'Unexpected Response','Channel API - Unexpected Response',channelRes.getBody());
            }
            
            Map<String,Object> responseData;
            
            try {
                responseCodeForLog = channelStatusCode;
responseMessageForLog = channelRes.getBody();
                responseData = (Map<String,Object>)JSON.deserializeUntyped(channelRes.getBody());
                responseCodeForLog = channelRes.getStatusCode();
responseMessageForLog = channelRes.getBody();
            } catch(Exception ex) {
                responseCodeForLog = 500;
                responseMessageForLog = ex.getMessage();               
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,'Response Parsing Failed',LOG_ENTRY_SEVERITY,'','','','PRM_DoceboController.getChannelAssets','',ex);                
                return buildErrorResponse(500,'Internal Server Error');
            }
            
            Map<String,Object> data = (Map<String,Object>)responseData.get('data');
            
            List<Object> items = (List<Object>)data.get('items');
            system.debug('items--'+items);
            List<CourseWrapper> courses = new List<CourseWrapper>();
            
            for(Object itemObj : items){
                
                Map<String,Object> item = (Map<String,Object>)itemObj;
                
                CourseWrapper course = new CourseWrapper();
                
                course.id = toInteger(item.get('id'));
                course.title = toStringValue(item.get('title'));
                course.typeId = toStringValue(item.get('type_id'));
                course.ratingOption = toStringValue(item.get('rating_option'));
                course.rating = toDecimal(item.get('rating'));
                course.created = toStringValue(item.get('created'));
                course.isNew = toBoolean(item.get('is_new'));
                course.duration = toInteger(item.get('duration'));
                course.languageLabel = toStringValue(item.get('language_label'));
                //if(languageLabel!=)
                course.hidden = toBoolean(item.get('hidden'));
                course.contentType = toStringValue(item.get('content_type'));
                course.imageUrl = toStringValue(item.get('image_url'));
                course.showWaiting = toBoolean(item.get('show_waiting'));
                course.uri = toStringValue(item.get('uri'));
                
                Map<String,Object> otherFields = (Map<String,Object>)item.get('other_fields');
                
                if(otherFields != null){
                    course.type = toStringValue(otherFields.get('type'));
                    course.views = toInteger(otherFields.get('views'));
                    course.isWatched = toStringValue(otherFields.get('is_watched'));
                    course.statusId = toStringValue(otherFields.get('status_id'));
                    
                    if(course.statusId != null && course.statusId.toLowerCase() == 'completed'){
                        continue;
                    }
                    
                    course.statusLabel = toStringValue(otherFields.get('status_label'));
                    course.canEnter = toBoolean(otherFields.get('can_enter'));
                    course.canEnterReason = toStringValue(otherFields.get('can_enter_reason'));
                    course.expirationDate = toStringValue(otherFields.get('expiration_date'));
                    course.level = toStringValue(otherFields.get('level'));
                    course.language = toStringValue(otherFields.get('language'));
                    course.languageCode = toStringValue(otherFields.get('language_code'));
                    system.debug('course.languageCode--'+course.languageCode);
                    system.debug('doceboLanguageCodeForLoggedInUser'+doceboLanguageCodeForLoggedInUser);
                    if(course.languageCode!=null && !((course.languageCode).equalsIgnoreCase(doceboLanguageCodeForLoggedInUser))){
                        continue;
                    }
                    course.quickCourseLaunch = toBoolean(otherFields.get('quick_course_launch'));
                }
                
                if(!String.isBlank(course.uri)){
                    course.fullUrl = DOCEBO_DOMAIN + course.uri;
                }
                
                courses.add(course);
            }
            
            DoceboResponse response = new DoceboResponse();
            response.userExists = true;
            response.courses = courses;
            
            if(courses.isEmpty()){
                response.status = '204 - No results were returned';
            }
            else{
                response.status = '200 - Successful response';
            }
            
            return response;
        }
        catch(Exception ex){
            
            responseCodeForLog = 500;
            responseMessageForLog = ex.getMessage();
            
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN,LOG_ENTRY_PROJECT,'Docebo Callout',LOG_ENTRY_SEVERITY,'','','','PRM_DoceboController.getChannelAssets','',ex);
            
            return buildErrorResponse(500,'Internal Server Error');
        }
        finally{
            
            PRM_IPA_Utility.createPCCIntegrationLog('',PCC_Constants.CALLOUT_TYPE_OUTBOUND,'DOCEBO_FINAL','',
                                                    responseMessageForLog,
                                                    responseCodeForLog,
                                                    'Docebo Callout',
                                                    'PRM_DoceboController.getChannelAssets',
                                                    reqTime,
                                                    System.now(),
                                                    true,
                                                    cpId,
                                                    'FINAL_RESPONSE'
                                                   );
        }
    }
    
   private static DoceboResponse buildErrorResponse(Integer errorCode,String message){
    DoceboResponse response = new DoceboResponse();
    response.userExists = false;
    response.courses = new List<CourseWrapper>();
    response.status = errorCode + ' - ' + message;
    return response;
}
    private static DoceboResponse handleError(Integer errorCode,String errorMessage,String scope,String responseBody){

    Core_Log_Entry.logEntryWithDetails(
        LOG_ENTRY_ORIGIN,
        LOG_ENTRY_PROJECT,
        LOG_ENTRY_SCOPE,
        LOG_ENTRY_SEVERITY,
        '',
        scope,
        '',
        'PRM_DoceboController.getChannelAssets',
        ''
    );

    return buildErrorResponse(errorCode,errorMessage);
}
    // HELPER METHODS
    
    private static String toStringValue(Object value) {
        if (value == null) {
            return null;
        }
        return String.valueOf(value);
    }
    
    private static Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }
    
    private static Decimal toDecimal(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return Decimal.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }
    
    private static Boolean toBoolean(Object value) {
        if (value == null) {
            return null;
        }
        return Boolean.valueOf(String.valueOf(value));
    }
    
    // WRAPPER
    public class DoceboResponse {
        
        @AuraEnabled
        public Boolean userExists;
        
        @AuraEnabled
        public List<CourseWrapper> courses;
        
        @AuraEnabled
        public String status;
    }
    public class CourseWrapper {
        
        @AuraEnabled public Integer id;
        @AuraEnabled public String title;
        @AuraEnabled public String typeId;
        @AuraEnabled public String ratingOption;
        @AuraEnabled public Decimal rating;
        @AuraEnabled public String created;
        @AuraEnabled public Boolean isNew;
        @AuraEnabled public Integer duration;
        @AuraEnabled public String languageLabel;
        @AuraEnabled public Boolean hidden;
        @AuraEnabled public String contentType;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public Boolean showWaiting;
        @AuraEnabled public String uri;
        @AuraEnabled public String fullUrl;
        @AuraEnabled public String type;
        @AuraEnabled public Integer views;
        @AuraEnabled public String isWatched;
        @AuraEnabled public String statusId;
        @AuraEnabled public String statusLabel;
        @AuraEnabled public Boolean canEnter;
        @AuraEnabled public String canEnterReason;
        @AuraEnabled public String expirationDate;
        @AuraEnabled public String level;
        @AuraEnabled public String language;
        @AuraEnabled public String languageCode;
        @AuraEnabled public Boolean quickCourseLaunch;
        @AuraEnabled public Integer totalUsers;
        @AuraEnabled public Boolean alreadyMarked;
        @AuraEnabled public Boolean hasActions;
    }
   public static String getDoceboLanguageCode(String sfLanguageCode) {

    Core_CustomMetadataObjectController customMetadataController =
        new Core_CustomMetadataObjectController('docebo_mdt');

    Map<String, Map<String, Object>> languageMappings =
        customMetadataController.getAll();

    if(languageMappings.containsKey(sfLanguageCode)) {
        return String.valueOf(
            languageMappings.get(sfLanguageCode).get('Docebo_Code')
        );
    }

    return null;
}
}