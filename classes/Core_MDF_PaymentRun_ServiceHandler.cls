/******************************************************************************************************
* Class Name  : Core_MDF_PaymentRun_ServiceHandler 
* Version     : 1.0 
* Created Date: 01-22-2019 
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AD      01/22/2019          It is a trigger handler class                                   
*******************************************************************************************************/
public without sharing class Core_MDF_PaymentRun_ServiceHandler {

    /****************************************************************************************************** 
    Method Name:        schedulePaymentRun
    @return  :          void
    @parameters:        List of payment run
    Description:        This method is used to schedule batch while create
    Added By:           Accenture - AD - 01/22/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void schedulePaymentRun(List<Core_MDF_Payment_Run__c> paymentRunList)
    {
        //Hold payment run records which need to be processed
        List<Core_MDF_Payment_Run__c> paymentRunToBeProcessed = new List<Core_MDF_Payment_Run__c>();
        //CRON expression - hold schedule time to run batch
        String timeOfExecution;
        //hold payment job name format
        String paymentJobName;
        //hold program name - CCF/DCF
        String programName;
        //Map of existing channel programs
        Map<ID, ChannelProgram> channelProgramMap = new Map<ID, ChannelProgram>([SELECT Id,Core_MDF_Technical_Program_Name__c FROM ChannelProgram]);
        //Map of channel program meta data
        Map<String,String> mapOfProgramMetadata = new Map<String,String>();
        //Existing channel program meta data
        List<Core_MDF_ChannelProgram__mdt> existingProgramMetadata = [SELECT Core_MDF_Program_Name__c,Core_MDF_Technical_Program_Name__c FROM Core_MDF_ChannelProgram__mdt];
        for(Core_MDF_ChannelProgram__mdt cp : existingProgramMetadata){
            mapOfProgramMetadata.put(cp.Core_MDF_Technical_Program_Name__c,cp.Core_MDF_Program_Name__c);
        }
        
        for(Core_MDF_Payment_Run__c paymentRun : paymentRunList)
        {
            //Null check for channel program map
            if(channelProgramMap != NULL && channelProgramMap.size() > 0 && channelProgramMap.containsKey(paymentRun.Core_MDF_Program_Id__c)){
                //To hold technical channel program name
                String technicalProgramName = channelProgramMap.get(paymentRun.Core_MDF_Program_Id__c).Core_MDF_Technical_Program_Name__c;
                //Null check for channel program metadata map
                if(mapOfProgramMetadata!= NULL && mapOfProgramMetadata.size() > 0 && mapOfProgramMetadata.containsKey(technicalProgramName)){
                    programName = mapOfProgramMetadata.get(technicalProgramName);
                }
            }
            
            // CCF_ASMO_00118
            paymentJobName = programName+Core_MDF_PaymentUtility.underscore+paymentRun.Core_MDF_Geo_Txt__c+Core_MDF_PaymentUtility.underscore+paymentRun.Name;
            
            //Seconds	Minutes	Hours	Day Of Month	Month	Day Of Week	 Year
            // 0           31   23          2            FEB        ?        2019

            timeOfExecution = 0+' '+paymentRun.Core_MDF_ScheduleRun_Dtm__c.minute()+' '+paymentRun.Core_MDF_ScheduleRun_Dtm__c.hour()+' '+paymentRun.Core_MDF_ScheduleRun_Dtm__c.day()+'-'+paymentRun.Core_MDF_ScheduleRun_Dtm__c.day()+' '+paymentRun.Core_MDF_ScheduleRun_Dtm__c.month()+'  ? '+paymentRun.Core_MDF_ScheduleRun_Dtm__c.year();
            //Schedule job
            string jobId = System.schedule(paymentJobName, timeOfExecution, new Core_MDF_Schedule_PaymentRun(paymentRun));
            //New payment run object to update job id
            Core_MDF_Payment_Run__c paymentRunRecord = new Core_MDF_Payment_Run__c(Id=paymentRun.Id);
            if(!String.isBlank(jobId)){
                //Updating job Id
                paymentRunRecord.Core_MDF_PaymentJob_Id__c = jobId;
            }
            paymentRunToBeProcessed.add(paymentRunRecord);
        }
        if(paymentRunToBeProcessed!=null && paymentRunToBeProcessed.size()>0){
            //Update processed paynent run records
            Database.update(paymentRunToBeProcessed);
        }
    }

    /****************************************************************************************************** 
    Method Name:        schedulePaymentRunOnUpdate
    @return  :          void
    @parameters:        List of payment run and map of old record
    Description:        This method is used to schedule batch while update
    Added By:           Accenture - AD - 01/22/2019
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void schedulePaymentRunOnUpdate(List<Core_MDF_Payment_Run__c> paymentRunList,Map<Id,Core_MDF_Payment_Run__c> oldPaymentRunMap){
        //Hold payment run records which need to be processed
        List<Core_MDF_Payment_Run__c> paymentRunToBeProcessed = new List<Core_MDF_Payment_Run__c>();
        for(Core_MDF_Payment_Run__c newPayRunRecord : paymentRunList){
            if(oldPaymentRunMap!=null 
                && 
                (newPayRunRecord.Core_MDF_ScheduleRun_Dtm__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_ScheduleRun_Dtm__c
                 || newPayRunRecord.Core_MDF_Program_Id__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_Program_Id__c
                 || newPayRunRecord.Core_MDF_Geo_Txt__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_Geo_Txt__c
                )
              ){
                if(newPayRunRecord.Core_MDF_PaymentJob_Id__c!=null){
                    //Abort previous scheduled job
                    system.abortJob(newPayRunRecord.Core_MDF_PaymentJob_Id__c);
                }
                paymentRunToBeProcessed.add(newPayRunRecord);
            } 
        }
        if(paymentRunToBeProcessed!=null && paymentRunToBeProcessed.size()>0){
            schedulePaymentRun(paymentRunToBeProcessed);
        }
    }

    /****************************************************************************************************** 
    Method Name:        abortPaymentJobOnDelete
    @return  :          void
    @parameters:        List of payment run
    Description:        This method is used to delete previous scheduled batch
    Added By:           Accenture - AD - 01/22/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    public static void abortPaymentJobOnDelete(List<Core_MDF_Payment_Run__c> paymentRunList){
        for(Core_MDF_Payment_Run__c newPayRunRecord : paymentRunList){
            if(newPayRunRecord.Core_MDF_PaymentJob_Id__c!=null){
                //Abort previous scheduled job
                system.abortJob(newPayRunRecord.Core_MDF_PaymentJob_Id__c);
            }
        }
    }
}