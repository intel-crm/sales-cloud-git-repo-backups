@RestResource(urlMapping='/contact/linkwechatdata/*')
global class PRM_WeChat_Link {
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'LinkWeChat API';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_WeChat_Link';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    @HttpPost
    global static PRM_WeChat_Link_Model LinkWeChatUnionId() {
        try {
            PRM_WeChat_Link_Utility.startTime = system.now().getTime();
            PRM_WeChat_Link_Model input = PRM_WeChat_Link_Model.parse(RestContext.request.requestBody.toString());
            if(String.isBlank(input.enterpriseId) && String.isBlank(input.loginId) && String.isBlank(input.email)) {
                return PRM_WeChat_Link_Utility.generateError('Failure','EnterpriseId/LoginId/Email is mandatory');
            }
            if(!input.unfollow && String.isBlank(input.wechatUnionId)) {
                return PRM_WeChat_Link_Utility.generateError('Failure','WeChat union Id must not be empty when unfollow is false');
            }
            return PRM_WeChat_Link_Utility.LinkWeChatUnionId(input);
        }
        catch(Exception ex) {
            PRM_WeChat_Link_Utility.CustomException custEx = new PRM_WeChat_Link_Utility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                 
            custEx.TypeName = ex.getTypeName();
            
            PRM_WeChat_Link_Utility.createLogEntryWrapper obj = new PRM_WeChat_Link_Utility.createLogEntryWrapper();
            obj.Msg = 'Error in Link WeChat API';
        	obj.ex = custEx;
        	obj.Severity = LOG_ENTRY_ERROR;
        	obj.params = RestContext.request.requestBody.toString();
            PRM_WeChat_Link_Utility.createLogEntry(obj); //Athr fixes
            //PRM_WeChat_Link_Utility.createLogEntry('Error in Link WeChat API', custEx, LOG_ENTRY_ERROR, RestContext.request.requestBody.toString()); 
            return PRM_WeChat_Link_Utility.generateError('Failure',ex.getMessage());
        }
    }
    
     

}