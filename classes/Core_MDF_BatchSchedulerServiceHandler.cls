/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchSchedulerServiceHandler
* Version     : 1.0 
* Created Date: 8-Apr-2021
* Modification Log :
* Developer   Vivek                  Date                          Description
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BatchSchedulerServiceHandler {
   
    /***************************************************************************************************** 
Method Name   :        validateBatchClassNameOnSchedulerRecord
@return       :        void
@parameters   :        List of new Batch Scheduler records, old map of batch scheduler records 
Description   :        Validate the Batch Class name on Batch Scheduler record is valid ;If not then throw the error
Added By      :        Accenture - PS - 11/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    public static void validateBatchClassNameOnSchedulerRecord(List<Core_MDF_Batch_Scheduler__c> batchScheduleList){        
        // Type as batchable for comparing further if the apex classes are valid batch class or not
        Type batchableType = Type.forName('Database.Batchable');
        for(Core_MDF_Batch_Scheduler__c batchScheduler : batchScheduleList){
            // Type as class name
            Type className = Type.forName(batchScheduler.Core_MDF_Batch_Class_Name_Txt__c);
            // If the class is not batachable or it is not even valid apex class name - throw error on Ui
            if(className == NULL || !batchableType.isAssignableFrom(className)){
                Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('INVALID_BATCH_CLASS_ERROR');
                batchScheduler.addError(config.Core_MDF_Value__c);
            }
        }
    }
    /***************************************************************************************************** 
Method Name   :        batchScheduleProcessAfterInsert
@return       :        void
@parameters   :        List of new Batch Scheduler records 
Description   :        Inserts new batch scheduler line item record on new batch scheduler record insertion
Added By      :        Accenture - PS - 11/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    public static void batchScheduleProcessAfterInsert(List<Core_MDF_Batch_Scheduler__c> batchScheduleList){        
        createNextSchLineItem(batchScheduleList,True);
    } 
    
    //Update the Batch Scheduler Line Item(Child) status during Batch Scheduler(Parent) cancellation
    
    public static void batchScheduleProcessAfterUpdate(Map<Id,Core_MDF_Batch_Scheduler__c> newBatchSchMap,List<Core_MDF_Batch_Scheduler__c> oldBatchSchLst){
        List<Core_MDF_Batch_Scheduler_Line_Item__c> batchSchLine = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        List<Core_MDF_Batch_Scheduler_Line_Item__c> updateRecordLst = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();                        
        Set<Id> cstSchId = new Set<Id>();
        try{
            for(Core_MDF_Batch_Scheduler__c batchSch:oldBatchSchLst){
                if(newBatchSchMap!=null && (batchSch.Core_MDF_Scheduler_Status_Txt__c != newBatchSchMap.get(batchSch.Id).Core_MDF_Scheduler_Status_Txt__c)){                
                    cstSchId.add(batchSch.Id);    
                } 
            }
            
            batchSchLine = [select id,Core_MDF_Batch_Scheduler__c,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Inactive__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Scheduler_Status_Txt__c from Core_MDF_Batch_Scheduler_Line_Item__c where Core_MDF_Batch_Scheduler__c IN:cstSchId];
            if(batchSchLine!=null && batchSchLine.size()>0){
                for(Core_MDF_Batch_Scheduler_Line_Item__c obj:batchSchLine){
                    if(obj.Core_MDF_Batch_Scheduler__r.Core_MDF_Inactive__c == True && obj.Core_MDF_Status_Txt__c == 'Pending'){
                       Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('BATCH_SCHEDULER_CANCELLATION_ERROR');
                       newBatchSchMap.get(obj.Core_MDF_Batch_Scheduler__c).addError(config.Core_MDF_Value__c);                    
                    } 
                    else if(obj.Core_MDF_Batch_Scheduler__r.Core_MDF_Inactive__c == True && obj.Core_MDF_Status_Txt__c == 'Scheduled'){ 
                        obj.Core_MDF_Status_Txt__c = 'Cancelled';
                        updateRecordLst.add(obj);
                    }
                }    
            }
            
            update updateRecordLst;     
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);Throw e;}
    }     
    
           
    
/***************************************************************************************************** 
Method Name   :        batchSchLineProcessAfterUpdate
@return       :        void
@parameters   :        List of new Batch Scheduler line item records, old map of batch scheduler line item records
Description   :        Creates new line item when current line item status is updated to pending.
    				   Updates parent record status when status is updated to completed or failed for one time jobs.
Added By      :        Accenture - NK - 13/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    public static void batchSchLineProcessAfterUpdate(List<Core_MDF_Batch_Scheduler_Line_Item__c> newSchItemList, Map<Id,Core_MDF_Batch_Scheduler_Line_Item__c> oldSchItemMap){	
        List<Core_MDF_Batch_Scheduler__c> batchSchLst = new List<Core_MDF_Batch_Scheduler__c>();
        set<id> cstSchId = new set<id>();
        Set<Id> schIdSet = new Set<Id>();
        Map<id,string> mapIdStatus = new Map<id,string>();
        List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineItemList = new  List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        try{
            for(Core_MDF_Batch_Scheduler_Line_Item__c item:newSchItemList){ 
                if(oldSchItemMap.get(item.Id).Core_MDF_Status_Txt__c=='Scheduled' && (item.Core_MDF_Status_Txt__c == 'Pending' || item.Core_MDF_Status_Txt__c == 'Failed')){
                    schIdSet.add(item.Core_MDF_Batch_Scheduler__c);
                }
            }
            List<Core_MDF_Batch_Scheduler__c> schedulerList = [Select Id,Core_MDF_Scheduler_Status_Txt__c,Core_MDF_Inactive__c,Scheduled_Time_Dt__c,Core_MDF_Effective_Start_Time_Dt__c,Core_MDF_Effective_End_Time_Dt__c,Core_MDF_Job_Frequency__c,Core_MDF_Every_X_Minute_Nbr__c,Core_MDF_Every_X_Hour_Nbr__c,Core_MDF_Time__c,Core_MDF_Days_of_Week__c,Core_MDF_GMT_Time__c,Core_MDF_Line_Items_Count_Nbr__c from Core_MDF_Batch_Scheduler__c where Id IN: schIdSet ];
            createNextSchLineItem(schedulerList,False);
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);Throw e;} 	
    }
    
/***************************************************************************************************** 
Method Name   :        createNextSchLineItem
@return       :        void
@parameters   :        List of new Batch Scheduler records, boolean variable isInsert 
Description   :        Inserts new batch scheduler line item record 					   
Added By      :        Accenture - NK - 14/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    public static void createNextSchLineItem(List<Core_MDF_Batch_Scheduler__c> schList, Boolean isInsert){
        List<Core_MDF_Batch_Scheduler_Line_Item__c> batchSchedulerLineItemsList = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        try{
        for(Core_MDF_Batch_Scheduler__c sch:schList){
            //ATHR - Deeply Nested if 16209
            if(sch.Core_MDF_Inactive__c){
                continue;
            }
                // create a new instance of line item
                Core_MDF_Batch_Scheduler_Line_Item__c batchSchLine = new Core_MDF_Batch_Scheduler_Line_Item__c();
                // Populate the Batch scheduler lookup id
                batchSchLine.Core_MDF_Batch_Scheduler__c = sch.Id;
                // during insertion; status of the scheduler line item will be scheduled
                batchSchLine.Core_MDF_Status_Txt__c = 'Scheduled';
                // if job frequency is once then directly copy schedule datetime from parentbatch scheduler record in child line item
                // else get the next scheduled datetime from generic method and populate it on the child line item record
                if(sch.Core_MDF_Job_Frequency__c == 'Once' ){
                    if(!isInsert){continue;}
                    batchSchLine.Core_MDF_Scheduled_Time_Dt__c = sch.Scheduled_Time_Dt__c;
                    
                }
                else{
                    Datetime nextScheduledDtTime;
                    // fetching next job run time
                     Datetime currentTime;
                    If(sch.Core_MDF_Line_Items_Count_Nbr__c==0){
                        currentTime = sch.Core_MDF_Effective_Start_Time_Dt__c;
                    }
                    else{
                        currentTime = system.now();
                    }
                    nextScheduledDtTime = Core_MDF_FrequencyJobScheduler.getNextScheduleddate(sch,currentTime);
                    if(sch.Core_MDF_Line_Items_Count_Nbr__c==0 && sch.Core_MDF_Effective_End_Time_Dt__c < nextScheduledDtTime) {
                        Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('BATCH_SCHEDULER_DAYS_OF_WEEK_ERROR');
                        sch.Id.addError(config.Core_MDF_Value__c);
                    }
                    // checking if next job run time lies between effective start date and effective end date
                    if(sch.Core_MDF_Effective_Start_Time_Dt__c <= nextScheduledDtTime && sch.Core_MDF_Effective_End_Time_Dt__c >= nextScheduledDtTime){
                        batchSchLine.Core_MDF_Scheduled_Time_Dt__c = nextScheduledDtTime;
                    }
                    else{continue;}
                }
                batchSchedulerLineItemsList.add(batchSchLine);
        }
        if(batchSchedulerLineItemsList != Null && batchSchedulerLineItemsList.size()>0){
            Database.insert(batchSchedulerLineItemsList);
        } 
        }catch(exception exc){Core_MDF_CCP_UtilityClass.logError(exc);Throw exc;}
    }  
/***************************************************************************************************** 
Method Name   :        updateGMTTime
@return       :        void
@parameters   :        List of new Batch Scheduler records
Description   :        populates gmt time field on custom scheduler
Added By      :        Accenture - NK - 18/06/2021
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
     public static void updateGMTTime(List<Core_MDF_Batch_Scheduler__c> schList){
        for(Core_MDF_Batch_Scheduler__c sch : schList){
            if(sch.Core_MDF_Time__c != Null){
                // to create a new date time instance associating time with current date
            datetime sampleInstance = Datetime.newInstance(System.now().date(), sch.Core_MDF_Time__c );
                //to fetch gmt time
            sch.Core_MDF_GMT_Time__c = sampleInstance.timeGmt();
            }
        }  
    }   
}