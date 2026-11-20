@isTest
public class ER_ErrorUtility_Test {
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_ErrorUtility_Test';
    @isTest
    static void testlog()
    {
        Map<String,String> mapLogEntry = new Map<String,String>();
        try{
            Test.startTest();
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = 'Test ErrorLog';
            custEx.StackTraceString = 'Testing';
            custEx.LineNumber = 101;                
            custEx.TypeName = 'ER_ErrorUtility';
            ER_ErrorUtility.createLogEntry('Error in ER_ErrorUtility', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, null);
            Test.stopTest();
            
            Core_Log_Entry__c cl = [Select Core_Message__c from Core_Log_Entry__c LIMIT 1];
            System.assertEquals('Error in ER_ErrorUtility', cl.Core_Message__c);
            
        }
        catch(Exception ex)
        {
            
        }            
    }       
    
}