/**************************************************************************************
Apex Class Name:  Core_SalesAssistRetryMechanism
Version     : 1.0 
Created Date: 12 JUNE 2020
Function    : Subscribe to the Platform Event.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree HR             06/12/2020              Original Version

*************************************************************************************/
public class Core_SalesAssistRetryMechanism {
    /*************
    * Method name  : retryFailedSalesAssit
    * Description  : This method reads the attachment body and passes it to the XMLParserHandler.
    * Return Type  : VOID
    * Parameter    : recordid
    *************/
    
    @InvocableMethod
    public static void retryFailedSalesAssit(List<id> recordId) {
        Core_Sales_Assist_Stageing_ServieHandler.salesAssistProcess(recordId);
    }
}