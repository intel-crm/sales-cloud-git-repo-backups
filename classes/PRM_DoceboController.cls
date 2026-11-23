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

	/*private static final String CLIENT_ID = '56048a48-2079-4134-b4e6-7f246e6c6667';
    private static final String CLIENT_SECRET = 'rqJ8Q~KGPhlPm6WjuZ4C25~44rML4-~u0BPzub_5';
    private static final String INTEL_TOKEN_ENDPOINT = 'https://apis-sandbox.intel.com/v1/auth/token';
    private static final String DOCEBO_AUTH_ENDPOINT = 'https://apis-sandbox.intel.com/m2r/docebo/auth';*/
   //private static final String CHANNEL_ENDPOINT = 'https://intelexternalsandbox.docebosaas.com/learn/v1/channels/265/assets?page_size=200&page=1';
   // private static final String DOCEBO_DOMAIN = 'https://apis.intel.com/m2r/docebo/usercall';
    //private static final String DOCEBO_DOMAIN = 'https://intelexternalsandbox.docebosaas.com';
    //private static final String CHANNEL_ENDPOINT ='https://apis.intel.com/m2r/docebo/usercall';
   // private static final String USERNAME = 'test.endpoints@test.test';
   private static final String DOCEBO_DOMAIN = string.valueof(system.label.PRM_DOCEBO_DOMAIN);//'https://partneruniversity-stg.intel.com';
     
   //public boolean is_user_in_docebo = false;

    @AuraEnabled(cacheable=false)
    public static DoceboResponse  getChannelAssets() {

       User currentUser = [Select id, email,username from User where Id =: UserInfo.getUserId() limit 1]; 
        System.debug('cureent user--'+currentUser);
        // use named credential and connect to  -- docebo thru intel api
        String USERNAME = currentUser.username;
        system.debug('usrname-'+USERNAME);
        HttpRequest doceboReq = new HttpRequest();
        doceboReq.setEndpoint('callout:PRM_IPA_Docebo');
        doceboReq.setMethod('POST');
        doceboReq.setHeader('Content-Type', 'application/json');
        doceboReq.setHeader('Accept', 'application/json');
        doceboReq.setBody(JSON.serialize(new Map<String, String>{'username' => USERNAME}));
        doceboReq.setTimeout(30000);

        HttpResponse doceboRes = (new Http()).send(doceboReq);

        System.debug('STEP 2 STATUS: ' + doceboRes.getStatusCode());

        if (doceboRes.getStatusCode() == 404) {

    DoceboResponse response = new DoceboResponse();

    response.userExists = false;
    response.courses = new List<CourseWrapper>();
    response.status = 'USER_NOT_FOUND';

    return response;
}

if (doceboRes.getStatusCode() < 200 ||
    doceboRes.getStatusCode() >= 300) {

    throw new AuraHandledException(
        'Docebo authentication failed: ' +
        doceboRes.getBody()
    );
}

        Map<String, Object> doceboData = (Map<String, Object>) JSON.deserializeUntyped(doceboRes.getBody());
system.debug(doceboData+'dddd-');
        String doceboToken = String.valueOf(doceboData.get('access_token'));

        if (String.isBlank(doceboToken)) {
            throw new AuraHandledException('Docebo access token was not returned.');
        }
        // STEP 3 - CHANNEL API
        boolean is_user_in_docebo= string.isnotblank(doceboToken);
        HttpRequest channelReq = new HttpRequest();
       // channelReq.setEndpoint(CHANNEL_ENDPOINT);
        channelReq.setEndpoint('callout:PRM_DOCEBO_ChannelEndpoint');
        channelReq.setMethod('GET');
       channelReq.setHeader('token', doceboToken);
       channelReq.setHeader('Authorization', 'Bearer ' + doceboToken);
        channelReq.setHeader('Accept', 'application/json');
        channelReq.setTimeout(30000);

        HttpResponse channelRes = (new Http()).send(channelReq);

        System.debug('STEP 3 STATUS: ' + channelRes.getStatusCode());

        if (channelRes.getStatusCode() < 200 || channelRes.getStatusCode() >= 300) {
            throw new AuraHandledException('Channel API failed: ' + channelRes.getBody());
        }

        // STEP 4 - PARSE JSON

        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(channelRes.getBody());

        Map<String, Object> data = (Map<String, Object>) responseData.get('data');

        List<Object> items = (List<Object>) data.get('items');

        List<CourseWrapper> courses = new List<CourseWrapper>();

        for (Object itemObject : items) {

            Map<String, Object> item = (Map<String, Object>) itemObject;

            CourseWrapper course = new CourseWrapper();

            // BASIC INFORMATION

            course.id = toInteger(item.get('id'));
            course.title = toStringValue(item.get('title'));
            course.typeId = toStringValue(item.get('type_id'));
            course.ratingOption = toStringValue(item.get('rating_option'));
            course.rating = toDecimal(item.get('rating'));
            course.created = toStringValue(item.get('created'));
            course.isNew = toBoolean(item.get('is_new'));
            course.duration = toInteger(item.get('duration'));
            course.languageLabel = toStringValue(item.get('language_label'));
            course.hidden = toBoolean(item.get('hidden'));
            course.contentType = toStringValue(item.get('content_type'));
            course.imageUrl = toStringValue(item.get('image_url'));
            course.showWaiting = toBoolean(item.get('show_waiting'));
            course.uri = toStringValue(item.get('uri'));

            // OTHER FIELDS

            Map<String, Object> otherFields = (Map<String, Object>) item.get('other_fields');

            if (otherFields != null) {

                course.type = toStringValue(otherFields.get('type'));
                course.views = toInteger(otherFields.get('views'));
                course.isWatched = toStringValue(otherFields.get('is_watched'));
                course.statusId = toStringValue(otherFields.get('status_id'));
                if (course.statusId.toLowerCase() == 'completed') {
                        continue;
                    }
                course.statusLabel = toStringValue(otherFields.get('status_label'));
                course.canEnter = toBoolean(otherFields.get('can_enter'));
                course.canEnterReason = toStringValue(otherFields.get('can_enter_reason'));
                course.expirationDate = toStringValue(otherFields.get('expiration_date'));
                course.level = toStringValue(otherFields.get('level'));
                course.language = toStringValue(otherFields.get('language'));
                course.languageCode = toStringValue(otherFields.get('language_code'));
                course.languageLabel = toStringValue(otherFields.get('language_label'));
                course.quickCourseLaunch = toBoolean(otherFields.get('quick_course_launch'));
            }

            // OUTDATED

            Map<String, Object> outdated = (Map<String, Object>) item.get('outdated');

            if (outdated != null) {
                course.totalUsers = toInteger(outdated.get('total_users'));
                course.alreadyMarked = toBoolean(outdated.get('already_marked'));
            }

            // ACTIONS

            List<Object> actions = (List<Object>) item.get('actions');

            if (actions != null) {
                course.hasActions = !actions.isEmpty();
            }

            // FULL URL

            if (!String.isBlank(course.uri)) {
                course.fullUrl = DOCEBO_DOMAIN + course.uri;
            }

            courses.add(course);
        }

       DoceboResponse response = new DoceboResponse();

response.userExists = true;
response.courses = courses;

if(courses.isEmpty()) {
    response.status = 'NO_COURSES';
}
else {
    response.status = 'SUCCESS';
}

return response;
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
}