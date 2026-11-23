/**************************************************************************************************************
Apex Class Name:  ER_RetriggerEVMail
Version     : 1.0 
Created Date: 08 March 2022
Function    : Custom REST service for retriggering email verification mail for all Programs
Modification Log :
* Developer             		Date              Description
* ----------------------------------------------------------------------------                 
* Manjunatha Hegde	         03/08/2022      	Initial version
***************************************************************************************************************/
@RestResource(urlMapping='/RegistrationRequest/V2/RetriggerEV')
global class ER_RetriggerEVMail {
    //For Input Requests
    static final String EMAILID = 'EmailId';
    static final String LOGINID = 'LoginId';
    static final String IsProgramBased='IsProgramBased';
    static final String Name='Name';
    
    //For Loggin
    public static final String LOG_ENTRY_ORIGIN   = 'SFDC';
    public static final String LOG_ENTRY_PROJECT  = 'RetriggerEV API';
    public static final String LOG_ENTRY_SCOPE    = 'ER_RetriggerEVMail';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    
    @HttpPost
    global static ER_RetriggerEVMail_Model.ER_RetriggerEV_Response RetriggerEV()
    {
        RestResponse res = RestContext.response;
        ER_RetriggerEVMail_Model.ER_RetriggerEV_Response response =new ER_RetriggerEVMail_Model.ER_RetriggerEV_Response();
        ER_RetriggerEVMail_Model.ER_RetriggerEVMail_Input evRetModel= new ER_RetriggerEVMail_Model.ER_RetriggerEVMail_Input();
        
        try{
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );
            //Map the Input to corresponding string
            Map<String, Object> KeyInput = (Map<String, Object>)params.get('KeyInput');
            String LgnId = (KeyInput.containsKey(LOGINID))?((!String.isEmpty((String) KeyInput.get(LOGINID)))? String.escapeSingleQuotes(((String) KeyInput.get(LOGINID))).trim():null):null;
            String EmailAddress = (KeyInput.containsKey(EMAILID))?((!String.isEmpty((String) KeyInput.get(EMAILID)))? String.escapeSingleQuotes(((String) KeyInput.get(EMAILID))).trim():null):null;
            String IsPgmBased= (KeyInput.containsKey(IsProgramBased))?((!String.isEmpty((String) KeyInput.get(IsProgramBased)))? String.escapeSingleQuotes(((String) KeyInput.get(IsProgramBased))).trim():'false'):'false';
            String PgmName=(KeyInput.containsKey(Name))?((!String.isEmpty((String) KeyInput.get(Name)))? String.escapeSingleQuotes(((String) KeyInput.get(Name))).trim():null):null;
            
            response= ER_RetriggerEVMail_Utility.ValidateInput(LgnId,EmailAddress,IsPgmBased,PgmName);
            if(!response.IsSuccess){
                return response;
            }
            else{
                evRetModel.LoginID=LgnId;
                evRetModel.Email=EmailAddress;
                evRetModel.IsProgramBased= Boolean.valueOf(IsPgmBased);
                evRetModel.Name=PgmName;
            }
            response=ER_RetriggerEVMail_Utility.retrigger_EV(evRetModel);                             
        }catch(Exception ex){
            CustomException custEx = new CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();
            createLogEntry('Error in RetriggerEV API', custEx, LOG_ENTRY_ERROR, RestContext.request.requestBody.toString());  
            return ER_RetriggerEVMail_Utility.generateException(ex.getMessage());
        }
        return response;
    }
    
    //Method to create log
    private static void createLogEntry(String Msg, CustomException ex, String Severity, String params){
        try{         
            String strDetailsAndEx = '';
            Id recordId = null;
            
            if( ex != null ) {
                strDetailsAndEx += 'Message: ' + ex.Message + '\n';
                strDetailsAndEx += 'Cause: ' + ex.Cause + '\n';
                strDetailsAndEx += 'Line Number: ' + ex.LineNumber + '\n';
                strDetailsAndEx += 'Stack Trace: ' + ex.StackTraceString + '\n';
                strDetailsAndEx += 'Type Name: ' + ex.TypeName + '\n';
            }
            Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
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
        
    }
    
    //Capturing exception
    private class CustomException extends Exception {
        public String message {set;get;}
        public Exception cause {set;get;}
        public Integer lineNumber {set;get;}
        public String stackTraceString {set;get;}
        public String typeName {set;get;}
    }
}