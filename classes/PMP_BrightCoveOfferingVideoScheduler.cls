/*********************************************************************************************************************
Apex Class Name  : PMP_BrightCoveOfferingVideoScheduler
Version          : 1.0
Created Date     : 10/05/2022

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal        10/05/2022            This class exposes custom api to Mulesoft System to call the PMP_BrightCoveOfferingVideoUploadBatch job 
                                                 for BrightCove Video Integration
*********************************************************************************************************************/
// Custom API  /services/apexrest/BrightCoveVideoJob/
//@RestResource(urlMapping='/BrightCoveVideoJob/')
global with sharing class PMP_BrightCoveOfferingVideoScheduler { 
	public static Boolean isWorking() {
        return true;
    }

//IPA2.0 - As part of TWC729-7977 commented the entire class
 /*   
    @HttpPost 
    global static String invokeBrightCoveVideoBatchJob(){    
        PMP_BrightCoveOfferingVideoUploadBatch objScheduler = new PMP_BrightCoveOfferingVideoUploadBatch();
        Database.executebatch(objScheduler,1);
        Datetime todayDate = System.now();
        String dayOfWeek = todayDate.format('EEEE');
        if(dayOfWeek=='Saturday')
        {
            System.enqueueJob(new PMP_BrightCoveDeleteVideosQueueable());
        }
        return 'PMP_BrightCoveOfferingVideoUploadBatch Job ran successfully';
    }
*/
}