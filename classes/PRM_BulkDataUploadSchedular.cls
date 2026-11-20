/******************************************************************************************************************************
Apex Class Name:  PRM_BulkDataUploadSchedular
Version     : 1.0 
Created Date: 01 OCT 2021
Function    : Schedule Class for Bulk Upload Batch  

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/10/2021           Schedule Class for Bulk Upload Batch
****************************************************************************************************************************************/
global class PRM_BulkDataUploadSchedular implements Schedulable{
    global void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new PRM_BulkDataUpload_Batch(),1);
    }
}