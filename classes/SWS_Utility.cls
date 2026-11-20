/****************************************************************************************************
Apex Class Name : SWS_Utility
Version         : 1.0 
Test Class      : SWS_UtilityTest
Created Date    : 2024-03-28
Function        : This class is used to create utlity method and invoke in other class.
Modifications   :
*****************************************************************************************************/
public without sharing class SWS_Utility {

    public static SWS_Bypass_Validation_Rule__c mapBypassValidation;
    
    static{
         mapBypassValidation = SWS_Bypass_Validation_Rule__c.getOrgDefaults();
    }
    
    /************************************************************************************************************
    *Method Name : getErrorDetails
    *Created Date: 15/4/2024
    *Author: Bishal Singh
    *Description : Returns error details from the exception.
    ************************************************************************************************************/
    public static String getErrorDetails(Exception e){
        return 'Class & Method Name = ' + e.getStackTraceString().substringBefore(':') + ';\n' +
            'Exception Message = ' + e.getMessage() + ';\n' +
            'LineNumber = ' + String.valueOf(e.getLineNumber()) + ';\n' +
            'StackTrace = ' + e.getStackTraceString() + ';\n' +
            'Logged in user = ' + UserInfo.getName();        
    }

    /************************************************************************************************************
    *Method Name : getRecordDetails
    *Created Date: 12/6/2024
    *Author: Ajinkya
    *Description : Get Cloud Request record details.
    ************************************************************************************************************/
    public static SWS_Cloud_Credit_Request__c getRecordDetails(String recordId){
        return ([SELECT Id,SWS_Email__c,SWS_Submitter_Email__c,SWS_Submitter_Requster_Email__c,SWS_Coupon_Code__c,SWS_Last_redeemed_date__c,sws_start_date__c,sws_expiry_date__c,sws_is_standard__c,sws_no_of_user__c,sws_coupon_value__c,sws_full_name__c,SWS_Is_Submitted_For_Coupon__c,SWS_Coupon_Status__c,SWS_coupon_request__c,SWS_coupon_response__c,CreatedById,SWS_Request_Status__c FROM SWS_Cloud_Credit_Request__c WHERE Id=:recordId WITH SECURITY_ENFORCED]); 
    }

    /************************************************************************************************************
    *Method Name : updateRedemptionDetails
    *Created Date: 2024-06-12
    *Author      : Ajinkya
    *Description : Method to update redemption details on cloud credit request object.
    ************************************************************************************************************/ 
    public static Boolean updateRedemptionDetails(SWS_Cloud_Credit_Request__c credRequest,SWS_IDCIntegration.SWS_IDCResponseWrapper wrapper, Boolean isUpdate,HttpResponse response){
        Boolean isRecordUpdated = false;
        credRequest.SWS_Redemption_Response__c = response.getBody(); 
        credRequest.SWS_Number_of_Redemptions__c= wrapper == null ? 0 : wrapper.numRedeemed;  
        List<SWS_IDCIntegration.Redemptions> redemptions = wrapper == null ? new List<SWS_IDCIntegration.Redemptions>() : wrapper.redemptions;
        
        for(SWS_IDCIntegration.Redemptions red : redemptions){
            if(red.redeemed > credRequest.SWS_Last_redeemed_date__c || credRequest.SWS_Last_redeemed_date__c == null){ 
                credRequest.SWS_Last_redeemed_date__c=red.redeemed;
                isRecordUpdated = true;
            }
        }
        
        if(!isUpdate){
            credRequest.SWS_redeemed_expired__c = credRequest.SWS_Coupon_Status__c == 'Expired' ? true : false;
            credRequest.SWS_Response_Code__c = response.getStatusCode();
            credRequest.SWS_Last_Redeem_Run_Date__c = System.now();
            updateByPass();
            if(!credRequest.SWS_Totally_Redeemed__c){
                Database.SaveResult sr = Database.Update(credRequest,false); 
            }
            updateByPass();
        }        
        return isRecordUpdated;
    }

    /************************************************************************************************************
    *Method Name : createCoreLogEntry
    *Created Date: 15/4/2024
    *Author: Bishal Singh
    *Description : Create Log Entry with general details.
    ************************************************************************************************************/
    public static void createCoreLogEntry(String className,String methodName,String message,String details,Exception exceptionDetails,String sObjectName,String Severity,String sObjectId){
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c();
        String strDetails=details;
        if(exceptionDetails!=null){
            strDetails = getErrorDetails(exceptionDetails);
        }
        objCLE.Core_Origin__c=className;
        objCLE.Core_Project__c='Software Sales';
        objCLE.Core_Scope__c=methodName;
        objCLE.Core_Severity__c=Severity;
        objCLE.Core_sObjectType__c=sObjectName;
        objCLE.Core_Message__c=message;
        objCLE.Core_Details__c=strDetails;
        objCLE.Core_When__c=System.now();
        objCLE.Core_sObjectId__c=sObjectId;
        insert as system objCLE;
    }
    
    /************************************************************************************************************
    *Method Name : updateByPass
    *Created Date: 2024-05-20
    *Author      : Bishal Singh 
    *User Story  : TWC5945-307
    *Description : Method to bypass the validation.
    ************************************************************************************************************/    
    public static void updateByPass(){
        mapBypassValidation.Bypass__c = !mapBypassValidation.Bypass__c;
        upsert mapByPassValidation;
    }
    
    /************************************************************************************************************
    *Method Name : updateByPass
    *Created Date: 2024-10-25
    *Author      : Bishal Singh
    *Description : Method to get error as string
    ************************************************************************************************************/  
    public static String getErrorAsString(Database.Error[] errors,String className){
        Set<String> errorList=new Set<String>();
        for(Database.Error error:errors){
            if(error.getMessage()!=null){
                errorList.add(className==SWS_RetryOperationUtility.LOG_ENTRY_ORIGIN ? String.valueOf(error.getStatusCode()) : error.getMessage());
            }
        }
        return String.join(errorList, ';');
    }
}