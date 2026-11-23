/******************************************************************************************
* Class Name  : PMP_ScheduleThumbnailGenerator 
* Version     : 1.0 
* Created Date: 6th Sep,2019
* Description : Schedulable class to schedule thumbnail generator
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Raj Yadav           06/09/2019                   Scheduler to schedule thumbnail generator
* *************************************************************************************/

global class PMP_ScheduleThumbnailGenerator implements Schedulable {
    
     //For Testing purpose
    //Use below command in Anonymous Window
    
    global void execute(SchedulableContext sc) {
        PMP_GenerateThumbnailImages thumbnailGenerator = new PMP_GenerateThumbnailImages ();
        Final Integer batchSize = Integer.valueOf(PMP_Utility.getValue('Generate_Thumbnail_Batch_Size'));
        database.executebatch(thumbnailGenerator,batchSize);//batchSize moved to metaData(value = 1)
    }
}