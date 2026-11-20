/*
 * Class Name    : PMP_BaseErrorHandler 
 * Description   : class created to send error information if any exception has occured.
*/

public class PMP_BaseErrorHandler {
    
    /********************************************************************************************
    METHOD NAME    : formatException
    DESCRIPTION    : Method to format the exception
    RETURN TYPE    : Map<String, Object>
    PARAMETER      : Exception
    ********************************************************************************************/
    // public static Map<String, Object> formatException(String sClass, String sSeverity, Exception e)    {
    //     Map<String, Object> mapErrorInfo = new Map<String, Object>{};
    //     mapErrorInfo.put('Class Name', sClass);
    //     mapErrorInfo.put('Severity', sSeverity);
    //     mapErrorInfo.put('User Info', UserInfo.getUserId());
    //     mapErrorInfo.put('Error Message', e.getTypeName() + ' >>> ' + e.getMessage());
    //     mapErrorInfo.put('Stack Trace', e.getStackTraceString());
    //     mapErrorInfo.put('Error Cause', e.getCause());
    //     List<String> aDMLFieldNames = new List<String>();
    //     List<String> aDMLRecordIds = new List<String>();
    //     List<String> aDMLMessages = new List<String>();
    //     if(e.getTypeName() == 'System.DmlException')    {
    //         for(Integer i=0; i<e.getNumDml(); i++)  {
    //             aDMLFieldNames.add(JSON.serialize(e.getDmlFieldNames(i)));
    //             aDMLRecordIds.add(e.getDmlId(i));
    //             aDMLMessages.add(e.getDmlMessage(i));
    //         }
    //     }
    //     mapErrorInfo.put('DML Field Names', aDMLFieldNames);
    //     mapErrorInfo.put('DML Record Ids', aDMLRecordIds);
    //     mapErrorInfo.put('DML Messages', aDMLMessages);
    //     return mapErrorInfo;
    // }
    public PMP_BaseErrorHandler(){
        
    }
}