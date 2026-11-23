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
public class PRM_ProcessInboundOPIDLogEntriesUtility {
    public List<String> logEntryList {get; private set;}
    
    public PRM_ProcessInboundOPIDLogEntriesUtility() {
        this.logEntryList = new List<String>();
    }
    //This Method will return error log Message for failed Database.SaveResult.
    public static String processDatabaseSaveResult(List<Sobject> recordList,List<Database.SaveResult> saveResultList, String sObjectType){
        integer index = 0;
        String logEntryMsg='';
        for(Database.SaveResult result: saveResultList)
        {//loop start
            if(!result.isSuccess())
            {
                Id sId = recordList[index].Id;
                Database.Error error = result.getErrors().get(0);
                String failedMessage = error.getMessage();
                Sobject recordFromList=recordList.get(index);
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
                if(sId != null)
                {
                    sObjectType = sId.getSObjectType().getDescribe().getName();
                    logEntryMsg+='\n *******Successful Record Details ******** \nObject Name: '+sObjectType+' Record Id: '+sId+'\nRecord details of sucessfully inserted/updated record  : '+recordFromList;
                    logEntryMsg+='\n*******Successful Record Details end ********';
                }
                
            }
            index++;
        }//loop ends here..
        return logEntryMsg;
    }
    //This Method will return log message for failed Database.UpsertResult 
    public static String processDatabaseUpsertResult(List<Sobject> recordList,List<Database.UpsertResult> upsertResultList, String sObjectType){
        integer index = 0;
        String logEntryMsg='';
        for(Database.UpsertResult result: upsertResultList)
        {//loop start
            if(!result.isSuccess())
            {
                Id sId = recordList[index].Id;
                Database.Error error = result.getErrors().get(0);
                String failedMessage = error.getMessage();
                Sobject recordFromList=recordList.get(index);
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
                if(sId != null)
                {
                    sObjectType = sId.getSObjectType().getDescribe().getName();
                    logEntryMsg+='\n *******Successful Record Details ******** \nObject Name: '+sObjectType+' Record Id: '+sId+'\nRecord details of sucessfully inserted/updated record  : '+recordFromList;
                    logEntryMsg+='\n*******Successful Record Details end ********';
                }
                
            }
            index++;
        }//loop ends here..
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
            doAddLogEntry(newLogString,fieldLength);
        }
        else{
            logEntryList.add(logEntryMsg);
        }
    }
}