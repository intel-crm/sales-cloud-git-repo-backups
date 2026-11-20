/**************************************************************************************************************
Apex Class Name:  PRM_ProcessInboundOPIDLogEntriesUtility
Version     : 1.0 
Created Date: 11 November 2020
Function    : This utility class will create log in log Entry object for each time batch class run PRM_ProcessInboundOPIDzRecords. 
Modification Log : 
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Srishty Sharma       11/11/2020      US835505:This utility class will capture all the failed transaction in batch class.   
***************************************************************************************************************/
public with sharing class PRM_ProcessInboundOPIDLogEntriesUtility {
    public List<String> logEntryList {get; private set;}
    public PRM_ProcessInboundOPIDLogEntriesUtility() {
        this.logEntryList = new List<String>();
    }
    //This Method will return error log Message for failed Database.SaveResult.
    public static String processDatabaseSaveResult(List<Sobject> recordList,List<Database.SaveResult> saveResultList, String sObjectType){
        integer index = 0;
        String logEntryMsg='';
        List<Sobject> inboundRecList = new List<Sobject>();//TWC729-6801 OPID Tracker
        for(Database.SaveResult result: saveResultList)
        {//loop start
            if(!result.isSuccess())
            {
                Id sId = recordList[index].Id;
                Database.Error error = result.getErrors().get(0);
                String failedMessage = error.getMessage();
                Sobject recordFromList=recordList.get(index);
                 //TWC729-6801 OPID Tracker Start
                if(sObjectType=='Core_OnePartner_Inbound_Message__c' ){ 
                    inboundRecList.add(recordFromList);
                }
                 //TWC729-6801 OPID Tracker End
                if(sId != null)
                {
                    sObjectType = sId.getSObjectType().getDescribe().getName();
                    logEntryMsg+='\n *******Failed Record Details ******** \nObject Name: '+sObjectType+' Record Id: '+sId+' Error Message: '+failedMessage+' \nRecord Details which failed during insertion : '+recordFromList;
                    logEntryMsg+='\n*******Failed Record Details end ********';
                }
                else{
                    logEntryMsg+='\n *******Failed Record Details ******** \nObject Name: '+sObjectType+' -New Record Insertion Failed with Message: '+failedMessage+' \nRecord Details which failed during update : '+recordFromList;
                    logEntryMsg+='\n*******Failed Record Details end ********';
                }
            }//for successfull records status 
            else
            {
                Id sId = result.getId();
                Sobject recordFromList=recordList.get(index);
                //TWC729-6801 OPID Tracker Start
                if(sObjectType=='Core_OnePartner_Inbound_Message__c' ){ 
                    inboundRecList.add(recordFromList);
                }
                //TWC729-6801 OPID Tracker End
                if(sId != null)
                {
                    sObjectType = sId.getSObjectType().getDescribe().getName();
                    logEntryMsg+='\n *******Successful Record Details ******** \nObject Name: '+sObjectType+' Record Id: '+sId+'\nRecord details of sucessfully inserted/updated record  : '+recordFromList;
                    logEntryMsg+='\n*******Successful Record Details end ********';
                }
                
            }
            index++;
        }//loop ends here..
        //TWC729-6801 OPID Tracker Start
        
            if(inboundRecList!=null){
                logEntryMsg+=updateLocTracker(inboundRecList,logEntryMsg);
            }
        //TWC729-6801 OPID Tracker Start
        return logEntryMsg;
    }
    //This Method will return log message for failed Database.UpsertResult 
    public static String processDatabaseUpsertResult(List<Sobject> recordList,List<Database.UpsertResult> upsertResultList, String sObjectType){
        integer index = 0;
        String logEntryMsg='';
        List<Sobject> inboundRecList = new List<Sobject>();//TWC729-6801 OPID Tracker
        for(Database.UpsertResult result: upsertResultList)
        {//loop start
            if(!result.isSuccess())
            {
                Id sId = recordList[index].Id;
                Database.Error error = result.getErrors().get(0);
                String failedMessage = error.getMessage();
                Sobject recordFromList=recordList.get(index);
                //TWC729-6801 OPID Tracker Start
                if(sObjectType=='Core_OnePartner_Inbound_Message__c'){ 
                    inboundRecList.add(recordFromList);
                }
                //TWC729-6801 OPID Tracker End
                if(sId != null)
                {
                    sObjectType = sId.getSObjectType().getDescribe().getName();
                    logEntryMsg+='\n *******Failed Record Details ********\nObject Name: '+sObjectType+' Record Id: '+sId+' Message: '+failedMessage+' Details of record which failed during update: '+recordFromList;
                    logEntryMsg+='\n*******Failed Record Details end ********';
                }
                else{
                    logEntryMsg+='\n *******Failed Record Details ********\nObject Name: '+sObjectType+' -New Record Insertion Failed with Message: '+failedMessage+' Details of record which failed during insert : '+recordFromList;
                    logEntryMsg+='\n*******Failed Record Details end ********';
                }
            }
            else
            {
                Id sId = result.getId();
                Sobject recordFromList=recordList.get(index);
                //TWC729-6801 OPID Tracker Start
                if(sObjectType=='Core_OnePartner_Inbound_Message__c'){ 
                    inboundRecList.add(recordFromList);
                }
                //TWC729-6801 OPID Tracker End
                if(sId != null)
                {
                    sObjectType = sId.getSObjectType().getDescribe().getName();
                    logEntryMsg+='\n *******Successful Record Details ******** \nObject Name: '+sObjectType+' Record Id: '+sId+'\nRecord details of sucessfully inserted/updated record  : '+recordFromList;
                    logEntryMsg+='\n*******Successful Record Details end ********';
                }
                
            }
            index++;
        }//loop ends here..
         //TWC729-6801 OPID Tracker Start
         
            if(inboundRecList!=null){
                logEntryMsg+=updateLocTracker(inboundRecList,logEntryMsg);
            }

         //TWC729-6801 OPID Tracker Start
        return logEntryMsg;
    }
    //This method will return error log message captured from catch block exception.
    public static String processException(Exception ex){
        String logEntryMsg='';
        logEntryMsg+='\n******Exception Occured********'+ex.getMessage() + ': ' + ex.getStackTraceString();
        logEntryMsg+='\n******Exception Block Ends********';
        return logEntryMsg;
    }
    
    public void addLogEntry(String logEntryMsg, Integer fieldLength) {
        doAddLogEntry(logEntryMsg,fieldLength);
    }
    //this method created to check String length against field length limit.If string length greater than set limit of field it will split string in two to create as two records.
    private void doAddLogEntry(String logEntryMsg, Integer fieldLength) {
        if(logEntryMsg.length()>fieldLength){
            Integer lastIndex=fieldLength-20;
            String logEntryMsgFirst = logEntryMsg.substring(0, lastIndex);
            logEntryMsgFirst+='..To be continued';
            logEntryList.add(logEntryMsgFirst);
            String newLogString = logEntryMsg.substring(lastIndex);
            if(Limits.getHeapSize()<10000){
            doAddLogEntry(newLogString,fieldLength);
            }
            else{
                String logEntryHeapMsg = '...Heap size limit reached';
                logEntryList.add(logEntryHeapMsg);
            }
        }
        else{
            logEntryList.add(logEntryMsg);
        }
    }

    //TWC729-6801 OPID Tracker Start
    public static String updateLocTracker(List<Core_OnePartner_Inbound_Message__c> inboundRecList, String logEntryMsg){
        List<PRM_Tracker__c> trackerList= new List<PRM_Tracker__c>();
        try{
            logEntryMsg+='***updateLocTracker***';
            for(Core_OnePartner_Inbound_Message__c inbound: inboundRecList){
                if(inbound.Core_SalesCloud_AccountID__c!=null && inbound.Core_Status__c!=System.Label.PRM_INBOUNDMSG_PROCESSED && inbound.Core_Status__c!=System.Label.PRM_INBOUNDMSG_LOAD_COMPLETE && inbound.Core_status__c!=System.Label.PRM_POST_PROCESSING_FAILED){
                    PRM_Tracker__c tracker = new PRM_Tracker__c();
                    if((inbound.Core_Effective_End_Date_Time__c != null && inbound.Core_Effective_End_Date_Time__c.date() <= Date.Today()) || inbound.Core_Status_Effective_End_Date_Time__c != null){
                        tracker.PRM_Type__c = 'OPID Updates';
                        tracker.PRM_Milestone__c = 'DLK_INBND_FLD';
                        tracker.PRM_Location_Account__c = inbound.Core_SalesCloud_AccountID__c;
                        tracker.PRM_Milestone_Display_Name__c ='OPID Delink Request Failed';
                        tracker.PRM_Completed__c = false;
                        trackerList.add(tracker);
                    }else{
                        tracker.PRM_Type__c = 'OPID Updates';
                        tracker.PRM_Milestone__c = 'INBND_FLD';
                        tracker.PRM_Location_Account__c = inbound.Core_SalesCloud_AccountID__c;
                        tracker.PRM_Milestone_Display_Name__c ='OPID Creation/Association Failed';
                        tracker.PRM_Completed__c = false;
                        trackerList.add(tracker);
                    }
                }
            }
            if (!trackerList.isEmpty()) {
                //insert trackerList;
                logEntryMsg+='\ntrackerList'+trackerList;
                List<Database.SaveResult> insertTrackerResult = new List<Database.SaveResult>();
                insertTrackerResult = Database.insert(trackerList,false);
                logEntryMsg+=processDatabaseSaveResult(trackerList, insertTrackerResult, 'PRM_Tracker__c');//TWC729-6988 Exception Handling
            }
            
        }catch(Exception ex){
            logEntryMsg+=ex.getMessage();
        } 
        return logEntryMsg;     
    }
     //TWC729-6801 OPID Tracker End
}