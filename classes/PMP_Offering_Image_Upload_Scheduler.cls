/****************************************************************************************************************************************
* Class Name        : PMP_Offering_Image_Upload
* Created Date      : 08-07-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Vivek       08-07-2019          Batch Scheduler class to invoke Image Upload batch.
*****************************************************************************************************************************************/


//Scheduler class for uploading Offering images
global class PMP_Offering_Image_Upload_Scheduler implements Schedulable 
{
    string btchType;
    
    global PMP_Offering_Image_Upload_Scheduler(string imgType)
    {
        btchType = imgType;        
    }
        
	global void execute(SchedulableContext sc) 
    {
        PMP_Offering_Image_Upload batch = new PMP_Offering_Image_Upload(btchType);
        //Database.executeBatch(batch);
        Integer batchSize = Integer.valueOf(PMP_Utility.getValue('Image_Upload_Batch_Size'));
        Database.executeBatch(batch, batchSize);//Batch size moved to metaData(value = 20)
        
    }
}