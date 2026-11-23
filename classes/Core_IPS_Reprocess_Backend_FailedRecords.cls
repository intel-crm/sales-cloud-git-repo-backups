/**************************************************************************************
Apex Class Name:  Core_IPS_Reprocess_Backend_FailedRecords
Version     : 1.0 
Created Date: 18 08 2015
Function    : Handler Class for trigger on Case object
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* IPS Cloud Rel1   Sushma Hamom          18/08/2015              Original Version
*
*************************************************************************************/

global class Core_IPS_Reprocess_Backend_FailedRecords
{

webservice static String reProcessRecords(Id[] logEntries) {
// List Variables to store Log Ids 
       List<Core_Log_Entry__c> logIds = new List<Core_Log_Entry__c>();

// if no record is selected from Log Entries List View, get the list of log entries referring from date to to-date from custom settings
// custom setting 'IPSBackendPromoteProcessing' has the config required to evalue fromdate and todate with the group name as 'MANUALPROCESSING' 
       if(logEntries==null || logEntries.isEmpty())
       {
            System.Debug('Selected list is empty');   
            logIds = getLogEntries();             
       }
       
// Records are selected from Log Entries List view       
       else
       {
          logIds = [Select id, name, Core_Origin__c, Core_sObjectType__c, Core_sObjectId__c , Core_severity__c from Core_Log_Entry__c WHERE id IN :logEntries AND Core_Project__c = 'IPS Cloud' AND Core_sObjectType__c IN ('sf:Case', 'sf:Core_IPS_Case_Comments__c', 'sf:Core_IPS_Case_Attachments__c') AND Core_Severity__c = 'error'];
          System.debug('No of records'+ logIds.size() );                
       }
       
// Call the method "Core_CasePromotionHandler.reProcessFailedPromoteRecords"
// which takes care of the below logic:
      if(logIds <> null && logIds.size()>0)
      {
          reProcessFailedPromoteRecords(logIds);
      } 
       return 'Processing Completed';       
    }
  
  
 public Static void reProcessFailedPromoteRecords(List<Core_Log_Entry__c> listLogEntries) {
// List Variables to store Log Ids  
       List<Core_Log_Entry__c> caseLogIds = new List<Core_Log_Entry__c>();
       List<Core_Log_Entry__c> caseUpdLogIds = new List<Core_Log_Entry__c>();
       List<Core_Log_Entry__c> caseCommentLogIds = new List<Core_Log_Entry__c>();
       List<Core_Log_Entry__c> caseAttLogIds = new List<Core_Log_Entry__c>();  
  
// Map Varaibles to store the Map Ids for the objects (Case, Attachments, Comments, Customsettings)       
       Map<Id, Case> mapCaseIds = new Map<Id, Case>();
       Map<Id, Case> mapCaseUpdIds = new Map<Id, Case>();
       Map<Id, Core_IPS_Case_Comments__c> mapCaseCommIds = new Map<Id, Core_IPS_Case_Comments__c>();
       Map<Id, Core_IPS_Case_Attachments__c> mapCaseAttIds = new Map<Id, Core_IPS_Case_Attachments__c>();
       Map<Id, Core_IPSBackendPromoteReprocesing__c> mapConfigIds = new Map<Id, Core_IPSBackendPromoteReprocesing__c>();

//List Variable to store the individual object Ids (Case, CaseComment, Attachments)       
       List<Core_IPS_Case_Comments__c> caseCommentIds = new List<Core_IPS_Case_Comments__c>();
       List<Core_IPS_Case_Attachments__c> caseAttIds = new List<Core_IPS_Case_Attachments__c>();
       List<Case> caseList = new List<Case>();
// Object Variable to store individual object       
       Case caseobj;
       Core_IPS_Case_Comments__c casecommentobj;
       Core_IPS_Case_Attachments__c caseattobj;  
 
       try
       {
          if(listLogEntries== null)
          {
             System.debug('Log entries size:' + listLogEntries.size());
             return;
          }   
          for(Core_Log_Entry__c logEntry:listLogEntries)
          { 
             System.Debug('Selected records for loop started'+logEntry.Core_sObjectType__c);
             if (logEntry.Core_sObjectType__c == 'sf:Case')
             {
                System.Debug('Case Record');
                caseobj = new Case();
                caseobj.id = logEntry.Core_sObjectId__c;
                logEntry.Core_severity__c = 'Processed';
                if(logEntry.Core_Origin__c !=null && logEntry.Core_Origin__c == 'PromoteCase')
                {  
                    mapCaseIds.put(caseobj.id, caseobj); 
                    caseLogIds.add(logEntry);
                }
                else 
                { 
                    mapCaseUpdIds.put(caseobj.id, caseobj);
                    caseUpdLogIds.add(logEntry);
                }
             }
             else if (logEntry.Core_sObjectType__c == 'sf:Core_IPS_Case_Attachments__c')
             {
                System.Debug('Case Attachment Record');
                caseattobj = new Core_IPS_Case_Attachments__c();
                caseattobj.id=logEntry.Core_sObjectId__c;
                mapCaseAttIds.put(caseattobj.id, caseattobj);
                logEntry.Core_severity__c = 'Processed';
                caseAttLogIds.add(logEntry);
             } 
             else if (logEntry.Core_sObjectType__c == 'sf:Core_IPS_Case_Comments__c')
             {
                casecommentobj = new Core_IPS_Case_Comments__c();
                caseCommentobj.id=logEntry.Core_sObjectId__c;
                mapCaseCommIds.put(casecommentobj.id, casecommentobj);
                logEntry.Core_severity__c = 'Processed';
                caseCommentLogIds.add(logEntry);
             }         
             System.debug('Log Entry' + logEntry.Core_sObjectType__c + logEntry.name);                              
         }
// Check if there are any Log Ids selected for Case Object Type for Pormote Failure. If yes, call the reprocessing method       
         if(!mapCaseIds.isEmpty())
         {
             System.debug('inside case object list' + mapCaseIds.size());
             reProcessCase(mapCaseIds, caseLogIds);
         }
    
// Check if there are any Log Ids selected for Case Object Type for case object update. If yes, call the reprocessing method       
         if(!mapCaseUpdIds.isEmpty())
         {
             System.debug('inside case object list' + mapCaseUpdIds.size());
             reProcessCaseUpdate(mapCaseUpdIds, caseUpdLogIds);
         }
               
// Check if there are any Log Ids selected for CaseComment Object Type. If yes, call the reprocessing method       
         if(!mapCaseCommIds.isEmpty())
         {  reProcessIPSCaseComments(mapCaseCommIds, caseCommentLogIds); }
       
// Check if there are any Log Ids selected for Case Attachments Object Type. If yes, call the reprocessing method       
         if(!mapCaseAttIds.isEmpty())
         {  reProcessCaseAttachments(mapCaseAttIds, caseAttLogIds); }    
     
     } catch(Exception e){ 
         System.debug('exception ocurred'+e); 
     }
  } // End of Method "void reProcessFailedPromoteRecords(List<Core_Log_Entry__c> listLogEntries)"

  public static List<Core_Log_entry__c> getLogEntries()
  { 
// DateTime Variable to derive Fromdate and Todate range for the Log Entries record selection       
     dateTime fromDate;
     dateTime toDate;
     String fromDateStr;
     String toDateStr;
     String override_flag;  
  
     List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();
     try
     {
         List<Core_IPSBackendPromoteReprocesing__c> configIds = Core_IPSBackendPromoteReprocesing__c.getAll().values(); 
         for(Core_IPSBackendPromoteReprocesing__c configId: configIds)
         {
             if (configId.Core_Group_Lookup_Name__c == 'MANUALPROCESSING')
             {                  
                if(configId.name == 'OVERRIDE' && configId.Core_Translate_value__c <> null && configId.Core_Translate_value__c == 'X' )
                { override_flag = 'X'; }                 
                if(configId.name == 'FROMDATE' && configId.Core_Translate_value__c <> null)
                {
                   fromDateStr = configId.Core_Translate_value__c;
                   fromDate = datetime.valueOf(fromDateStr);
                }  
                if(configId.name == 'TODATE' && configId.Core_Translate_value__c <> null)
                {
                   toDateStr = configId.Core_Translate_value__c;
                   toDate = datetime.valueOf(toDateStr);
                }                             
             }         
         }         
         System.debug('Override Test' + 'From Date:' + fromDateStr + ',' + fromdate + 'To Date: ' + toDateStr + ' ,' +  todate  );
         if ((toDate == null || fromDate == null) && override_flag == null)
         {
             toDate = System.now();
             fromDate = toDate - 1;
             System.debug('Current Date Test' + 'To date: ' + todate + ', From Date: ' + fromdate);            
         }          
         if(toDate <> null && fromDate <> null)
         {         
             listLogEntries = [Select id, Core_sObjectType__c, Core_sObjectId__c , Core_severity__c from Core_Log_Entry__c WHERE Core_When__c >= :fromDate AND Core_When__c <= :toDate AND Core_Project__c = 'IPS Cloud' AND Core_sObjectType__c IN ('sf:Case', 'sf:Core_IPS_Case_Comments__c', 'sf:Core_IPS_Case_Attachments__c') AND Core_Severity__c = 'error' limit 10];
             System.debug('No of records'+ listLogEntries.size() ); 
         }         
      }
      catch(Exception e)
      {  System.debug('Exception occurred in getLogEntries' + e.getmessage()); }      
      return listLogEntries;
   } //End of method: "List<Core_Log_entry__c> getLogEntries()"

//This method reprocesses the case objects which are promote failed. it accepts unique Case IDs with the corresponding Case object 
// with expected status data field change  
// It also marks all the Log Ids corresponding to the case objects as "Processed"
   public static void reProcessCase(Map<Id, Case> i_mapCaseIds, List<Core_Log_Entry__c> i_caseLogIds) // you can pass parameters
   { 
      Map<Id,Case> updateCaseMapIds = new Map<Id, Case>();   
      try
      {    
         System.debug('Update Case Promote Status');
         // Check all the case are in Inprogress and Failed Status and backend system ID is not null and Backend ID is null
         Set <Id> caseIds = i_mapCaseIds.keySet();        
         System.debug('Set List' + CaseIDs.size()); 
         List<Case> csIds = [SELECT id, Core_Promote_Status__c from Case WHERE ID IN :caseIDs AND Core_IPS_Backend_System__c <> null AND Core_IPS_Backend_ID__c = null];  
         //for(ID caseId:caseIDs)  
         for(Case cs:csIds)
         {            
            cs.Core_Promote_Status__c = 'Promote';
            updateCaseMapIDs.put(cs.Id, cs);       
         }
         if(!updateCaseMapIDs.isEmpty())
         {
            System.debug('Last update list' + updateCaseMapIDs.size());
            update updateCaseMapIds.values();
         }
         System.debug('Case Logs:' + i_caseLogIds.size());
         database.update(i_caseLogIds);  
      }
      catch(Exception e){
            System.debug('Exception occurred in reProcessCase' + e.getmessage()); 
      }          
   } //End of Method: "void reProcessCase(Map<Id, Case> i_mapCaseIds, List<Core_Log_Entry__c> i_caseLogIds)"


//This method reprocesses the case objects which are field updates failed. it accepts unique Case IDs with the corresponding Case object 
// with expected timestamp field changed 
// It also marks all the Log Ids corresponding to the case objects as "Processed"
   public static void reProcessCaseUpdate(Map<Id, Case> i_mapCaseIds, List<Core_Log_Entry__c> i_caseLogIds) // you can pass parameters
   { 
/*       Map<Id,Case> updateCaseMapIds = new Map<Id, Case>();   
       try
       {    
           System.debug('Update Case Field Update timestamp');
// Check all the case are in Inprogress and Failed Status and backend system ID is not null and Backend ID is null
           Set <Id> caseIds = i_mapCaseIds.keySet();        
           System.debug('Set List' + CaseIDs.size()); 
           List<Case> csIds = [SELECT id, Core_IPS_BK_Flds_UpdatedAt__c from Case WHERE ID IN :caseIDs AND Core_IPS_Backend_System__c <> null AND Core_IPS_Backend_ID__c <> null];  
           for(Case cs:csIds)
           {
              Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
              cs.Core_IPS_BK_Flds_UpdatedAt__c = DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now())); 
              updateCaseMapIDs.put(cs.Id, cs);       
           }
           if(!updateCaseMapIDs.isEmpty())
           {
              System.debug('Last update list' + updateCaseMapIDs.size());
              update updateCaseMapIds.values();
           }
           System.debug('Case Logs:' + i_caseLogIds.size());
           database.update(i_caseLogIds);  
       }
       catch(Exception e)
       {  System.debug('Exception occurred in reProcessCase' + e.getmessage()); }         */ 
   } //End of Method: "void reProcessCase(Map<Id, Case> i_mapCaseIds, List<Core_Log_Entry__c> i_caseLogIds)"

//This method reprocesses the case comment objects which are promote failed. it accepts unique Case comment IDs 
// with the corresponding Case comment object with expected status data field change  
// It also marks all the Log Ids corresponding to the case comment objects as "Processed"   
   public static void reProcessIPSCaseComments(Map<Id, Core_IPS_Case_Comments__c> i_mapCaseCommentIds, List<Core_Log_Entry__c> i_caseCommentLogIds) // you can pass parameters
   { 
       Map<Id,Core_IPS_Case_Comments__c> updateCaseCommMapIds = new Map<Id, Core_IPS_Case_Comments__c>();       
       System.debug('Update Case Comments Promote Status');
       try
       {
        // get the unique attachments object IDs
        //Check all the attachemnt object IDs are in Failed status. Should consider only the ones in Failed Status
          Set <Id> caseCommIds = i_mapCaseCommentIds.keySet();         
          List<Core_IPS_Case_Comments__c> csCommIds = [SELECT id, Core_Promote_Status__c from Core_IPS_Case_Comments__c WHERE ID IN :caseCommIDs AND Core_Promote_Status__c = 'Failed'];  

        //Filter out the Case comment objects which are not valid and update the status for only valid ones. Update the log entries for the attachment proomote failure       
          for(Core_IPS_Case_Comments__c csComm:csCommIds)
          {
              csComm.Core_Promote_Status__c = 'In Progress';
              updateCaseCommMapIDs.put(csComm.Id, csComm);       
          }
          if(!updateCaseCommMapIDs.isEmpty()){ 
              update updateCaseCommMapIds.values();  
          }
          database.update(i_caseCommentLogIds);  
       }
       catch(Exception e)
       { System.debug('Exception occurred in reProcessIPSCaseComments' + e.getmessage()); }          
    } //End of Method: "void reProcessCaseComments(Map<Id, CaseComment> mapCaseCommentIds, List<Core_Log_Entry__c> i_caseCommentLogIds")
    
//This method reprocesses the case attachments objects which are promote failed. it accepts unique Case attachments IDs 
// with the corresponding Case attachments object with expected status data field change  
// It also marks all the Log Ids corresponding to the case attachment objects as "Processed"    
    public static void reProcessCaseAttachments(Map<Id, Core_IPS_Case_Attachments__c> i_mapCaseAttIds, List<Core_Log_Entry__c> caseAttLogIds) // you can pass parameters
    {          
       Map<Id,Core_IPS_Case_Attachments__c> updateCaseAttMapIds = new Map<Id, Core_IPS_Case_Attachments__c>();       
       System.debug('Update Case Promote Status');
       try
       {
// get the unique attachments object IDs
//Check all the attachemnt object IDs are in Failed status. Should consider only the ones in Failed Status
           Set <Id> caseAttIds = i_mapCaseAttIds.keySet();         
           List<Core_IPS_Case_Attachments__c> csAttIds = [SELECT id, Core_Promote_Status__c from Core_IPS_Case_Attachments__c WHERE ID IN :caseAttIDs AND Core_Promote_Status__c = 'Failed'];  
//Filter out the Att objects which are not valid and update the status for only valid ones. Update the log entries for the attachment proomote failure       
           for(Core_IPS_Case_Attachments__c csAtt:csAttIds)
           {
               csAtt.Core_Promote_Status__c = 'In Progress';
//               database.update(csAtt);
               updateCaseAttMapIDs.put(csAtt.Id, csAtt); 
      
           }
           if(!updateCaseAttMapIDs.isEmpty())
           { update updateCaseAttMapIds.values(); }
           database.update(caseAttLogIds);  
       }
       catch(Exception e)
       { System.debug('Exception occurred in reProcessCaseAttachments' + e.getmessage()); }          
    } //End of method: "void reProcessCaseAttachments(Map<Id, Core_IPS_Case_Attachments__c> i_mapCaseAttIds, List<Core_Log_Entry__c> caseAttLogIds)"  
  
  
  
  /*Start--8th Feb 2016--Added method for reprocessing --This Method reprocess related case which are promoted to not done  */
  /** Updated on 4th April 2016 -- tanvix.chauhan **/
  webservice static String reProcessRecordsFromBackSystem(Id backEndSystemId){
        List<Case> listOfCase=new List<Case>();
        system.debug('Back End System Id**'+backEndSystemId);
        try {
            if(backEndSystemId != null ){
                //Get the list of cases valid for update
                listOfCase=[SELECT Id, Core_IPS_Backend_System__c, Core_IPS_Backend_ID__c, Core_Promote_Status__c FROM Case WHERE Core_IPS_Backend_System__c=: backEndSystemId AND (Core_Promote_Status__c != 'Done' AND Core_Promote_Status__c != 'Not Yet Promoted') LIMIT 10];
              
                if(listOfCase!=null && !listOfCase.isEmpty()){
                    System.debug('***Case List to be updated: '+ listOfCase.size() + listOfCase);
                    updateCase(listOfCase);
                } 
              }
        } Catch(Exception e){
            System.debug('Exception occurred in reProcessIPSCase/CaseComments/Case attachment' + e.getmessage());
        }
        return 'Processing completed'; 
    }/*End--8th Feb 2016--*/  

  
  /** Added new method to update the list of Cases 04052016**/
  webservice static void updateCase(List<Case> casesToBeUpdated){
        List<Case> finalCsList = new List<Case>();
        //start--Case promote status updation
        System.debug('***Inside updateCase()' + casesToBeUpdated.size());
        try{
            for(Case caseRecord: casesToBeUpdated){
             caseRecord.Core_Promote_Status__c = 'Promote';
             finalCsList.add(caseRecord); 
             //Database.update(caseRecord);
            }
        if(!finalCsList.isEmpty()){
             Database.update(finalCsList); 
             System.debug('***After update'+ finalCsList);
            }
        }catch(Exception e){
            System.debug('***An exception have occurred while updating Case list' + e.getmessage());
        }
     }//End of method updateCase
    
} //End of class