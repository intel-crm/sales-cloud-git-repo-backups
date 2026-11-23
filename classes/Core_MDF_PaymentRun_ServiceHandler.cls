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
        Map<ID, ChannelProgram> channelProgramMap = new Map<ID, ChannelProgram>([SELECT Id,Core_MDF_Technical_Program_Name__c FROM ChannelProgram LIMIT 100]);
        //Map of channel program meta data
        Map<String,String> mapOfProgramMetadata = new Map<String,String>();
        //Existing channel program meta data
        List<Core_MDF_Payment_Run__c> lstPymtRunUpdRec = new List<Core_MDF_Payment_Run__c>();
        Map<Id,BatchWrapper> mapBatchWrap = new Map<Id,BatchWrapper>();
        Map<Id,Core_MDF_Batch_Scheduler__c> mapIdBatchSch = new Map<Id,Core_MDF_Batch_Scheduler__c>();
        List<Core_MDF_ChannelProgram__mdt> existingProgramMetadata = [SELECT Core_MDF_Program_Name__c,Core_MDF_Technical_Program_Name__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000];
        for(Core_MDF_ChannelProgram__mdt cp : existingProgramMetadata){
            mapOfProgramMetadata.put(cp.Core_MDF_Technical_Program_Name__c,cp.Core_MDF_Program_Name__c);
        }
        
        for(Core_MDF_Payment_Run__c paymentRun : paymentRunList)
        {
            //To hold technical programe name
            String technicalProgramName = '';
            //Null check for channel program map
            if(channelProgramMap != NULL && channelProgramMap.size() > 0 && channelProgramMap.containsKey(paymentRun.Core_MDF_Program_Id__c)){
                //To hold technical channel program name
                technicalProgramName = channelProgramMap.get(paymentRun.Core_MDF_Program_Id__c).Core_MDF_Technical_Program_Name__c;
                //Null check for channel program metadata map
                if(mapOfProgramMetadata!= NULL && mapOfProgramMetadata.size() > 0 && mapOfProgramMetadata.containsKey(technicalProgramName)){
                    programName = mapOfProgramMetadata.get(technicalProgramName);
                }
            }
            
            // CCF_ASMO_00118
            paymentJobName = programName+Core_MDF_PaymentUtility.underscore+paymentRun.Core_MDF_Geo_Txt__c+Core_MDF_PaymentUtility.underscore+paymentRun.Name;
            
            //Seconds   Minutes Hours   Day Of Month    Month   Day Of Week  Year
            // 0           31   23          2            FEB        ?        2019
            
            //If retail program is selected and straight to payment flag is checked
            //payment run will be scheduled in next 1 minute 
         
			Core_MDF_Batch_PaymentFileGenerator batchClassInstance = new Core_MDF_Batch_PaymentFileGenerator(paymentRun);
            
            DateTime dt;
            if(paymentRun.Core_MDF_Run_Now_Ind__c){
            	dt = system.now().addMinutes(1);
            }else{
                dt = paymentRun.Core_MDF_ScheduleRun_Dtm__c; 
            }
            //Enter batch class name & instance into Batch Scheduler 
            BatchWrapper btchWrap = new BatchWrapper();
            btchWrap.batchInstance = batchClassInstance;
            btchWrap.scopeSize = 200;
            btchWrap.runTime = dt;            
            mapBatchWrap.put(paymentRun.Id,btchWrap);                              
        }
        
		//Invoke method to insert Batch Scheduler records        
        mapIdBatchSch = insertBatchSchedulerLst(mapBatchWrap);
        
        try{
            //method to update Batch Scheduler Id into Payment Record
        	if(mapIdBatchSch!=null && paymentRunList!=null && paymentRunList.size()>0){
            	lstPymtRunUpdRec = mapPymtRunBatchSchRecords(paymentRunList,mapIdBatchSch);
        	}        
            if(lstPymtRunUpdRec!=null && lstPymtRunUpdRec.size()>0){
                //Update processed payment run records
                Database.update(lstPymtRunUpdRec); 
            }   
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);Throw e;}
        
        
       /* for(Core_MDF_Payment_Run__c paymentRun : paymentRunList)
        {
            //To hold technical programe name
            String technicalProgramName = '';
            //Null check for channel program map
            if(channelProgramMap != NULL && channelProgramMap.size() > 0 && channelProgramMap.containsKey(paymentRun.Core_MDF_Program_Id__c)){
                //To hold technical channel program name
                technicalProgramName = channelProgramMap.get(paymentRun.Core_MDF_Program_Id__c).Core_MDF_Technical_Program_Name__c;
                //Null check for channel program metadata map
                if(mapOfProgramMetadata!= NULL && mapOfProgramMetadata.size() > 0 && mapOfProgramMetadata.containsKey(technicalProgramName)){
                    programName = mapOfProgramMetadata.get(technicalProgramName);
                }
            }
            
            // CCF_ASMO_00118
            paymentJobName = programName+Core_MDF_PaymentUtility.underscore+paymentRun.Core_MDF_Geo_Txt__c+Core_MDF_PaymentUtility.underscore+paymentRun.Name;
            
            //Seconds   Minutes Hours   Day Of Month    Month   Day Of Week  Year
            // 0           31   23          2            FEB        ?        2019
            
            //If retail program is selected and straight to payment flag is checked
            //payment run will be scheduled in next 1 minute 
         
      Core_MDF_Recovery_Batch RecoveryBatchClassInstance = new Core_MDF_Recovery_Batch('','','');
            
            DateTime dt;
            Integer hr;
            //[scheduledRun_Dtm - system.now() ]-> this should be (>24)
            //Double kla = paymentRun.Core_MDF_ScheduleRun_Dtm__c - system.now();
            if(paymentRun.Core_MDF_Run_Now_Ind__c){
              dt = system.now().addMinutes(1);
            }else{
                dt = paymentRun.Core_MDF_ScheduleRun_Dtm__c.addHours(-24);
                hr = paymentRun.Core_MDF_ScheduleRun_Dtm__c.hour();
            }
            //Enter batch class name & instance into Batch Scheduler 
            BatchWrapper btchWrap = new BatchWrapper();
            btchWrap.batchInstance = RecoveryBatchClassInstance;
            btchWrap.scopeSize = 200;
            btchWrap.runTime = dt;            
            mapBatchWrap.put(paymentRun.Id,btchWrap);                              
        }*/
        
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
        Map<Id,Core_MDF_Payment_Run__c> paymentRunToBeProcessed = new Map<Id,Core_MDF_Payment_Run__c>();
        for(Core_MDF_Payment_Run__c newPayRunRecord : paymentRunList){
            if(oldPaymentRunMap!=null 
                && 
                (newPayRunRecord.Core_MDF_ScheduleRun_Dtm__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_ScheduleRun_Dtm__c
                 || newPayRunRecord.Core_MDF_Program_Id__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_Program_Id__c
                 || newPayRunRecord.Core_MDF_Geo_Txt__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_Geo_Txt__c
                 || newPayRunRecord.Core_MDF_Start_Dt__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_Start_Dt__c 
                 || newPayRunRecord.Core_MDF_End_Dt__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_End_Dt__c
                 || newPayRunRecord.Core_MDF_Run_Now_Ind__c != oldPaymentRunMap.get(newPayRunRecord.ID).Core_MDF_Run_Now_Ind__c
                )
              ){
                paymentRunToBeProcessed.put(newPayRunRecord.Core_MDF_PaymentJob_Id__c,newPayRunRecord);
            } 
        }
        if(paymentRunToBeProcessed!=null && paymentRunToBeProcessed.size()>0){
            cancelScheduledJob(paymentRunToBeProcessed);
            schedulePaymentRun(paymentRunToBeProcessed.values());                        
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
        Map<Id,Core_MDF_Payment_Run__c> schedulerToPaymentRunMap = new Map<Id,Core_MDF_Payment_Run__c> ();
        for(Core_MDF_Payment_Run__c newPayRunRecord : paymentRunList){            
        	if(newPayRunRecord.Core_MDF_Status_Txt__c!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PaymentRunStatus_Scheduled')) 
        	{
               newPayRunRecord.addError(system.Label.Core_MDF_PaymentRun_CannotBeDeletedIntheCurrentStatus);
            }
            schedulerToPaymentRunMap.put(newPayRunRecord.Core_MDF_PaymentJob_Id__c,newPayRunRecord);
        }
        
        cancelScheduledJob(schedulerToPaymentRunMap);                    
    } 
    /****************************************************************************************************** 
    Method Name:        ifVATClaimExists
    @return  :          void
    @parameters:        List of payment run
    Description:        This method is used to check if VAT Claim Exists in a Payment Run
    Added By:           Accenture - AD - 01/22/2019
    Modified By:        Date:       Changes:  
    *******************************************************************************************************/    
    /*public static void vatClaimsExist(List<Core_MDF_Payment_Run__c> paymentRunList){
        
        List<Boolean> vatClaimsExists = new List<Boolean>();
        
        if(paymentRunList!=null && paymentRunList.size()>0){
            vatClaimsExists = Core_MDF_VatUtility.chkCountOfVatClaims(paymentRunList);
        }
        
        if(vatClaimsExists!=null && vatClaimsExists.size()>0){
            for(Core_MDF_Payment_Run__c newPayRunRecord : paymentRunList){
                newPayRunRecord.Core_MDF_VAT_Claims_Exist_Ind__c = vatClaimsExists[0];
            } 
        }
    } -- Commented as this is no more used*/
        
    //Method to insert record into Custom Batch Scheduler object
    public static Map<Id,Core_MDF_Batch_Scheduler__c> insertBatchSchedulerLst(Map<Id,BatchWrapper> mapBatchWrapper){  
        
        List<Core_MDF_Batch_Scheduler__c> lstBatchInsert = new List<Core_MDF_Batch_Scheduler__c>();
        Map<Id,Core_MDF_Batch_Scheduler__c> mapPymtIdBatchSch = new Map<Id,Core_MDF_Batch_Scheduler__c>();
        Set<id> batchSchId = new Set<id>();
        
        if(mapBatchWrapper!=null && mapBatchWrapper.size()>0){
            for(Id key:mapBatchWrapper.keySet()){
                Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
                String serializedInstance = JSON.serialize(mapBatchWrapper.get(key).batchInstance); 
                customSch.Core_MDF_Object_JSON_Txt__c = serializedInstance;
                customSch.Core_MDF_Batch_Size_Nbr__c = mapBatchWrapper.get(key).scopeSize;
                customSch.Core_MDF_Effective_Start_Time_Dt__c = mapBatchWrapper.get(key).runTime;
                customSch.Scheduled_Time_Dt__c = mapBatchWrapper.get(key).runTime;
                customSch.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(mapBatchWrapper.get(key).batchInstance).split(':')[0];
                //customSch.Core_MDF_Status_Txt__c = 'Scheduled';
                customSch.Core_MDF_Job_Frequency__c = 'Once';
                customSch.Core_MDF_Priority__c = 'High';
                customSch.Core_MDF_Program_Txt__c = 'CCP';
                mapPymtIdBatchSch.put(key,customSch);
                lstBatchInsert.add(customSch);
            }
        }
        
        try{
            Database.insert(lstBatchInsert);
        }catch(exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;} 
       
        
        return mapPymtIdBatchSch;
       
    }
    
    //Method to Map Payment records with relevant Batch Scheduler Ids
    public static List<Core_MDF_Payment_Run__c> mapPymtRunBatchSchRecords(List<Core_MDF_Payment_Run__c> paymentRunList,Map<Id,Core_MDF_Batch_Scheduler__c> mapBatchSch){
        
    	List<Core_MDF_Batch_Scheduler__c> lstBatchSch = new List<Core_MDF_Batch_Scheduler__c>();
        List<Core_MDF_Payment_Run__c> pymRunUpdRecord = new List<Core_MDF_Payment_Run__c>();
        Map<string,Id> mapBtchSchKey = new Map<string,Id>();
        List<string> lstPymtRecKey = new List<string>();
        
        if(paymentRunList!=null && paymentRunList.size()>0 && mapBatchSch!=null){
            for(Core_MDF_Payment_Run__c pymtRunRec:paymentRunList){
                if(mapBatchSch.containsKey(pymtRunRec.id)){
                    Core_MDF_Payment_Run__c updRec = new Core_MDF_Payment_Run__c(Id = pymtRunRec.Id);
                    updRec.Core_MDF_PaymentJob_Id__c = mapBatchSch.get(pymtRunRec.id).Id;
                    pymRunUpdRecord.add(updRec);
                }
            }    
        }        
          
        return pymRunUpdRecord;
    }    
    
    //Method to cancel Batch Scheduler record if it's in Scheduled state
    public static void cancelScheduledJob(Map<Id,Core_MDF_Payment_Run__c> paymentRunList){ 
       
       Set<Id> SchId = new Set<Id>();
        schId = paymentRunList.keySet();
        //string errorMessage = '';
        List<Core_MDF_Batch_Scheduler__c> lstBatchSch = new List<Core_MDF_Batch_Scheduler__c>();
        
       
        // inactivates the batch scheduler record if its in Scheduled status       
        for(Core_MDF_Batch_Scheduler__c obj:[select id,Core_MDF_Inactive__c,Core_MDF_Scheduler_Status_Txt__c from Core_MDF_Batch_Scheduler__c where Id IN:SchId]){
            if(obj.Core_MDF_Scheduler_Status_Txt__c == 'Scheduled'){
            obj.Core_MDF_Inactive__c = true;
            lstBatchSch.add(obj);
            }
            else{
                Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('PAYMENT_RUN_CANCELLATION_ERROR');
                paymentRunList.get(obj.Id).addError(config.Core_MDF_Value__c);
            }
        }
                
        try{
              Database.update(lstBatchSch); 
        }catch(exception e){
            Core_MDF_CCP_UtilityClass.logError(e); 
            Throw e;
        }    
                    
   }
    
    //Batch Scheduler data Wrapper
    public class BatchWrapper{
        public Object batchInstance;
        public Integer scopeSize;
        public Datetime runTime;
    }        
               
}