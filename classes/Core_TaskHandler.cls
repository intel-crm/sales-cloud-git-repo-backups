/**************************************************************************************
Apex Class Name:  Core_TaskHandler
Version     : 1.0 
Created Date: 30 SEP 2014
Function    : Handler Class for trigger on Task object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             30/09/2014              Original Version
* Mahesh Manikonda         4/11/2018               Created new methods UpdateTaskFlag,UpdateTaskFlagOnUpdate for US153250
*************************************************************************************/
public without sharing class Core_TaskHandler
{
    /*
    * Method name  : lastActivityDateHandler
    * Description  : Method to call the activity handler to update the Last Activity Date field on related lead record on creation/updation of task. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */
    public static void tasklastActivityUpdateOnLeadUpsert(Map<Id,sObject> mapIdOldSobject,Map<Id,sObject> mapIdNewSobject)
    {
        Core_ActivityHandler.lastActivityDateUpdate(mapIdOldSobject,mapIdNewSobject);
    }
    
    /*
    * Method name  : lastActivityDateHandler
    * Description  : Method to call the activity handler to update the Last Activity Date field on related lead record on deletion of task. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */
    public static void tasklastActivityUpdateOnLeadDelete(Map<Id,sObject> mapIdOldSobject)
    {
        Core_ActivityHandler.lastActivityDateUpdateOnDelete(mapIdOldSobject);
    }
    
    /*
    * Method name  : Checkleadsource
    * Description  : Displaying error message to update the Lead Source on Lead before Creating the Task
    * Return Type  : VOID
    * Parameter    : List Trigger.new
    */
    public static String Checkleadsource(List<Task> newlist)
    {
        String message = 'Ok';
        String LeadSourceMsg = Label.Core_LeadSource_on_Task;
        Set<Id> leadIdsforLeadsource = new Set<Id>();
        String SalesleadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();

        for(Task t : newlist)
        {
            if(t.whoId != null && String.valueOf(t.whoId).startsWith('00Q') == TRUE)
            {
                leadIdsforLeadsource.add(t.whoId);
            }
        }

        List<Lead> leadlstLeadSource = [SELECT id, LeadSource, RecordTypeId FROM Lead WHERE id IN :leadIdsforLeadsource];  
        for(Lead l : leadlstLeadSource)
        {
            if(l.RecordTypeId == SalesleadRectypeId && l.LeadSource == null)
            {
                message = 'Not Ok';
                addLeadSourceError(newlist, l.Id, LeadSourceMsg);
            }
        }
        
        return message; 
    }
    
    /*
    * Method name  : addLeadSourceError
    * Description  : Helper method to add errors to tasks
    * Return Type  : VOID
    */
    private static void addLeadSourceError(List<Task> newlist, Id leadId, String LeadSourceMsg)
    {
        for(Task t : newlist)
        {
            if(t.whoId == leadId)
            {
                t.addError(LeadSourceMsg);
            }
        }
    }

    /*
    * Method name  : UpdateTaskflag
    * Description  : Method to check if any tasks is created on Lead  and update a flag  on Lead for new lead process for US153250 
    * Return Type  : VOID
    * Parameter    : List Trigger.new
    */
    public static void UpdateTaskflag(List<Task> newlist) 
    {
        String message = Checkleadsource(newlist);
        if(message == 'Ok')
        {
            Set<Id> leadIds = new Set<Id>();
            Set<Id> queryLeadId = new Set<Id>();
            
            processTaskSubjects(newlist, leadIds, queryLeadId);
            
            List<Lead> leadList = [SELECT Id, Status, Core_Having_Tasks__c, Core_Meeting_Due_Date__c FROM Lead WHERE Id IN :queryLeadId];
            
            if(leadList.size() > 0)
            {
                updateLeadTaskFlags(newlist, leadList, leadIds);
            }
        }
    }
    
    /*
    * Method name  : processTaskSubjects
    * Description  : Helper method to process task subjects
    * Return Type  : VOID
    */    
    private static void processTaskSubjects(List<Task> newlist, Set<Id> leadIds, Set<Id> queryLeadId)
    {
        for(Task t : newlist)
        {
            if(t.whoId != null && String.valueOf(t.whoId).startsWith('00Q') == TRUE)
            {
                if(t.Subject == 'Phone' || t.Subject == 'Email' || t.Subject == 'Meeting')
                {
                    leadIds.add(t.whoId);
                }
                queryLeadId.add(t.whoId);
            }
        }
    }
    
    /*
    * Method name  : updateLeadTaskFlags
    * Description  : Helper method to update lead task flags
    * Return Type  : VOID
    */  
    private static void updateLeadTaskFlags(List<Task> newlist, List<Lead> leadList, Set<Id> leadIds)
     {
    Map<Id, Lead> leadMap = new Map<Id, Lead>(leadList);

    for (Lead le : leadList)
     {
        le.Core_Having_Tasks__c = ((leadIds.contains(le.Id) && (le.Status == 'Marketing Qualified Lead')) || (leadIds.contains(le.Id) && le.Status == 'Sales Generated Lead')|| (leadIds.contains(le.Id) && le.Status == 'Sales Accepted Lead')) ? true :
                                  ( le.Status == 'Sales Qualified Lead') ? false : le.Core_Having_Tasks__c;
        
      }
    update leadList;
    }

    /*
    * Method name  : UpdateTaskflagOnUpdate
    * Description  : Method to check if any tasks is created on Lead  and update a flag on Lead for new lead process for US153250
    * Return Type  : VOID
    * Parameter    : List Trigger.new, Trigger.Old
    */
    public static void UpdateTaskflagOnUpdate(List<Task> oldList, List<Task> newList)
    {
        Set<Id> leadIds = new Set<Id>();
        Set<Id> leadIdsnew = new Set<Id>();
        Set<Id> queryLeadId = new Set<Id>();
        
        processUpdateTaskSubjects(oldList, newList, leadIds, leadIdsnew, queryLeadId);
        
        List<Lead> leadlst = [SELECT id, Status, Core_Having_Tasks__c, Core_Meeting_Due_Date__c FROM Lead WHERE id IN :queryLeadId];
        
        if(leadlst.size() > 0)
        {
            updateLeadTaskFlags(newList, leadlst, leadIds);
        }
    }
    /*
    * Method name  : processUpdateTaskSubjects
    * Description  : Helper method to process task subjects on update
    * Return Type  : VOID
    */
    private static void processUpdateTaskSubjects(List<Task> oldList, List<Task> newList, Set<Id> leadIds, Set<Id> leadIdsnew,Set<Id> queryLeadId)
    {
        for (Task t : oldList)
        {
            if (t.whoId != null && String.valueOf(t.whoId).startsWith('00Q') == TRUE)
            {
                for (Task tnew : newList)
                {
                    addTaskLeadIds(tnew, leadIds, leadIdsnew);
                    queryLeadId.add(t.whoId);
                }
            }        
        }
    }
    /*
    * Method name  : addTaskLeadIds
    * Description  : Helper method to add task lead IDs based on subject
    * Return Type  : VOID
    */ 
    private static void addTaskLeadIds(Task tnew, Set<Id> leadIds, Set<Id> leadIdsnew)
    {
        if(tnew.Subject == 'Phone' || tnew.Subject =='Email' || tnew.Subject == 'Meeting'){
                        leadIds.add(tnew.whoId); 
                    }else{
                        leadIdsnew.add(tnew.whoId); 
                    }
    }

}