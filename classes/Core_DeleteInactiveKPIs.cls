/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_DeleteInactiveKPIs
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Utility methods to handle Full Load
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/

public without sharing class Core_DeleteInactiveKPIs  {
    /*
    * Method name  : handleFullLoad
    * Description  : 
    * Return Type  : VOID
    * Parameter    : null
    */
    @InvocableMethod
    public static void deleteKpi() {
        List<id> ids = new List<id>();
        List<id> kpis = new List<id>();
        List<id> kpid = new List<id>();
        Integer batchSize = Integer.valueOf(System.Label.Core_DelInactiveApi_Size);
        List<Core_Oppty_KPI_New__c> kpinew = new List<Core_Oppty_KPI_New__c>();
        try{
            //List<Core_Oppty_KPI_New__c> oppKpiList = [select id,Core_IsActive__c from Core_Oppty_KPI_New__c where Core_IsActive__c =false and createddate < LAST_N_DAYS:30 limit 1];
    
            //if(oppKpiList.size()>0){
                    database.executeBatch(new Core_Batch_DeleteInactiveKPIHistory(),batchSize);
            //}
        }
        catch(exception e){
            PMP_Utility.logError(e,'Core_DeleteInactiveKPIs.deleteKpi');
        }
    }

}