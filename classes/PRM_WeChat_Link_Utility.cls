public without sharing class PRM_WeChat_Link_Utility {
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'LinkWeChat API';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_WeChat_Link';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static Long startTime;
    
    public static PRM_WeChat_Link_Model LinkWeChatUnionId(PRM_WeChat_Link_Model inputModel) {   
        String inputvalue = '';
        if(String.isNotBlank(inputModel.email)) {
            inputValue=inputModel.email;
        }else if(String.isNotBlank(inputModel.enterpriseId)) {
            inputValue=inputModel.enterpriseId;
        }else if(String.isNotBlank(inputModel.loginId)) {
            inputValue=inputModel.loginId;
        }
        List<Contact> cnts = [SELECT Id, Name, email, PRM_Wechat_Union_Id__c, Core_Enterprise_Id__c
                              FROM Contact WHERE Email= :inputValue OR Core_Enterprise_Id__c= :inputValue 
                              /*OR Core_Login_Id__c= :inputValue*/ LIMIT 1];   //IPA 2.0 - Removed login id reference- TWC-729-8150     
        if(!inputModel.unfollow && cnts.size() == 0) {
            return generateError('Failure', 'Contact not found for given EnterpriseId/LoginId/Email');
        }
       
        string weChatUnionid = EncryptDecryptHelper.DecryptData(EncodingUtil.urlEncode(inputModel.wechatUnionId,'UTF-8'));
        /*if(inputModel.unfollow == true && String.isNotBlank(cnts[0].PRM_Wechat_Union_Id__c)) {
          
            cnts[0].PRM_Wechat_Union_Id__c = inputModel.unfollow ? null : weChatUnionid;
            update cnts;
            RemoveWeChatUnionIdFromRequest(cnts[0].Email, weChatUnionid);
        }*/
        if(inputModel.unfollow == true) {
            if(cnts.size() > 0 && String.isNotBlank(cnts[0].PRM_Wechat_Union_Id__c) ){
                cnts[0].PRM_Wechat_Union_Id__c = inputModel.unfollow ? null : weChatUnionid;
                update cnts; 
            }            
            RemoveWeChatUnionIdFromRequest(/*cnts[0].Email,*/ inputModel, weChatUnionid);
        }
        else if(weChatUnionid != cnts[0].PRM_Wechat_Union_Id__c 
                && inputModel.unfollow == false) {      
                    cnts[0].PRM_Wechat_Union_Id__c = inputModel.unfollow ? null : weChatUnionid;
                    update cnts;           
                }
        inputModel.status = 'Success';        
        inputModel.responseTime = (system.now().getTime()-startTime) +'ms';
        return inputModel;
    }
    
    public static PRM_WeChat_Link_Model generateError(String status, String error) {
        PRM_WeChat_Link_Model errorModel = new PRM_WeChat_Link_Model();
        errorModel.status = status;
        errorModel.error = error;
        return errorModel;
    }
    
    private static void RemoveWeChatUnionIdFromRequest(/*string email,*/ PRM_WeChat_Link_Model inputModel, string weChatUnionId) {
        List<PRM_Registration_Request__c> requests = [SELECT Id, Name, PRM_Email_ID__c, PRM_Wechat_Union_Id__c 
                                                      FROM PRM_Registration_Request__c
                                                      WHERE /*PRM_Email_ID__c =: email AND*/ PRM_Wechat_Union_Id__c =: weChatUnionId];
                                                      //AND PRM_Status__c = 'Approved'
                                                           
        if(requests.size() == 0) {
            //return generateError('Failure', 'Registration request not found for given Email/WeChat UnionId');
            createLogEntryWrapper obj1=new createLogEntryWrapper();
            obj1.Msg='Registration request not found for given Email/Login/WeChat UnionId';
            obj1.ex=null;
            obj1.Severity=LOG_ENTRY_INFO;
            obj1.params= (String.isEmpty(inputModel.email)? inputModel.loginId:inputModel.email) +';'+weChatUnionId;
            createLogEntry(obj1);//JB
            //createLogEntry('Registration request not found for given Email/Login/WeChat UnionId', null, LOG_ENTRY_INFO, (String.isEmpty(inputModel.email)? inputModel.loginId:inputModel.email) +';'+weChatUnionId);
        }
        if(requests.size() != 0) { 
            createLogEntryWrapper obj2=new createLogEntryWrapper();
            obj2.Msg=requests.size()+'Registration request found for given Email/WeChat UnionId';
            obj2.ex=null;
            obj2.Severity=LOG_ENTRY_INFO;
            obj2.params= (String.isEmpty(inputModel.email)? inputModel.loginId:inputModel.email) +';'+weChatUnionId;
            createLogEntry(obj2);//JB
            //createLogEntry(requests.size()+' Registration requests found for given Email/WeChat UnionId', null, LOG_ENTRY_INFO, (String.isEmpty(inputModel.email)? inputModel.loginId:inputModel.email) +';'+weChatUnionId);
            for(PRM_Registration_Request__c req : requests) {
                req.PRM_Wechat_Union_Id__c = null;
            }           
            update requests;
        }      
    }
    
    /*public static void createLogEntry(String Msg, CustomException ex, String Severity, String params){
        try{         
            //String strTags = '';
            String strDetailsAndEx = '';
            //Id recordId = null;
            
            if( ex != null ) {
                strDetailsAndEx += 'Message: ' + ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                //Name = strLogEntryName, // From Service Cloud
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = Severity,
                Core_Message__c = Msg,
                Core_When__c = system.now(),
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = params
            );
            insert objCLE;
        }catch(Exception e){
            
        }
        
    }*/
    
    public class createLogEntryWrapper{
        public String Msg{get;set;}
        public CustomException ex{get;set;}
        public String Severity{get;set;}
        public String params{get;set;}
    }//JB
    
    public static void createLogEntry(createLogEntryWrapper att)
    {
        try{         
            //String strTags = '';
            String strDetailsAndEx = '';
            Id recordId = null;
            
            if( att.ex != null ) {
                strDetailsAndEx += 'Message: ' + att.ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + att.ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + att.ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + att.ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + att.ex.TypeName + '\n';
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                //Name = strLogEntryName, // From Service Cloud
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = att.Severity,
                Core_Message__c = att.Msg,
                Core_When__c = system.now(),
                Core_Details__c = strDetailsAndEx,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = att.params
            );
            insert objCLE;
        }catch(Exception e){
            //system.debug('Error Cause ==>Log Entry -->'+ e.getCause());
            system.debug('Error Message==>Log Entry -->'+ e.getMessage());
        }
        
    }
    
    public class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
}