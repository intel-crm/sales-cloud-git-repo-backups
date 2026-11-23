/**************************************************************************************
Apex Class Name:  Core_ActivityHandler
Version     : 1.0 
Created Date: 30 SEP 2014
Function    : Handler Class for trigger on Activity ( Task & Event ) object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             30/09/2014              Original Version
*************************************************************************************/
public class Core_ActivityHandler 
{
	//Ensures that the trigger will run once for "lastActivityDateUpdate ( for insert/update)" 
    public static boolean blastActivityDateUpdateOnUpsert  = true;
    
    //Ensures that the trigger will run once for "lastActivityDateUpdateonDelete ( for Delete)" 
    public static boolean bLastActivityDateUpdateOnDelete  = true;
	
    // String to hold the prefix of lead, which can be used to identify whether sObject is related to activity is lead or not
    private static String sLeadPrefix = Lead.sObjectType.getDescribe().getKeyPrefix();
    
    // List of lead records which needs to be updated
    private static List<Lead> lstLeadUpdate = new List<Lead>();
    
    // Map of leadId,sObjectId ( Task & Event )
    private static Map<Id,Id> mapLeadIdSobjectId = new Map<Id,Id>();
    
    // list of lead records
    private static Set<Id> setLeadIds = new Set<Id>();
    
    /*
    * Method name  : lastActivityDateUpdate
    * Description  : Method to update the Last Activity Date field on related lead record on creation/updation of task/event related to a lead. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */
    public static void lastActivityDateUpdate(Map<Id,sObject> mapIdOldSobject,Map<Id,sObject> mapIdNewSobject)
    {
    	if(islastActivityDateUpdateOnUpsert()){
    		
	    	Map<Id,List<sObject>> mapLeadIdSobjectIds = new Map<Id,List<sObject>>();
	        
	        try
	        {
	            for(sObject sObjectInstance : mapIdNewSobject.values())
	            {
	                 // Checking whether the task is related to 
	                 if(String.valueOf(sObjectInstance.get('whoId'))!= NULL && String.valueOf(sObjectInstance.get('whoId')).startsWith(sLeadPrefix))
	                 {
	                     if(mapLeadIdSobjectIds.containsKey((Id)sObjectInstance.get('whoId')))
	                         mapLeadIdSobjectIds.get((Id)sObjectInstance.get('whoId')).add(sObjectInstance);
	                         
	                     else
	                         mapLeadIdSobjectIds.put((Id)sObjectInstance.get('whoId'),new List<sObject>{sObjectInstance});
	                     
	                     
	                         lstLeadUpdate.add(new Lead(Id=((Id)sObjectInstance.get('whoId')),
	                                                     Core_Last_Activity_Date__c = (DateTime)sObjectInstance.get('LastModifiedDate')));
	                     
	                 }   
	             }
	             
	             // Update the lead records related to task/event records inserted/updated 
	             if(!lstLeadUpdate.isEmpty())
	             {
	                 Map<Id,Lead> mapLeadIdLead = new Map<Id,Lead>();
	                 
	                 for(Lead leadInstance : lstLeadUpdate)
	                 {
	                     mapLeadIdLead.put(leadInstance.Id,leadInstance);
	                 }
	                 
	                 lstLeadUpdate.clear();
	                 
	                 lstLeadUpdate.addAll(mapLeadIdLead.values());
	                 
	                 Database.SaveResult[] srList = Database.update(lstLeadUpdate, false);
	                 Integer databaseUpdateIndex = 0;
	                 // Capturing the logs for error records
	                 for (Database.SaveResult sr : srList) 
	                 {
	                    
	                    if (!sr.isSuccess()) 
	                    {
	                        List<sObject> lstErrorRecords;
	                        for(Database.Error err : sr.getErrors()) 
	                        {
	                            lstErrorRecords = mapLeadIdSobjectIds.get(lstLeadUpdate.get(databaseUpdateIndex).Id);
	                            
	                            if(!lstErrorRecords.isEmpty())
	                            {
	                                for(sObject sObjInstance : lstErrorRecords)
	                                {
	                                    sObjInstance.addError(System.Label.Core_Exception + err.getMessage());
	                                    System.debug('The following error has occurred.');                    
	                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                                    System.debug('Lead fields that affected this error: ' + err.getFields());
	                                }
	                            }
	                         }
	                    }
	                    databaseUpdateIndex++;
	                 }
	             }
	                
	         }
	         catch(Exception err)
	         {
	             for(sObject sObjectInstance : mapIdNewSobject.values())
	             {
	                 sObjectInstance.addError(System.Label.Core_Exception + err.getMessage());
	            
	             }
	         }
    	}
    }
    
    
    /*
    * Method name  : lastActivityDateUpdateonDelete
    * Description  : Method to update the Last Activity Date field on related lead record on deletion of task/event related to a lead. 
    * Return Type  : VOID
    * Parameter    : List Trigger.new, MAP Trigger.newmap
    */
    public static void lastActivityDateUpdateonDelete(Map<Id,sObject> mapIdOldSobject)
    {
         if(islastActivityDateUpdateOnDelete()) {
     	
	     	    for(sObject sObjectInstance : mapIdOldSobject.values())
	             {
	                 if(String.valueOf(sObjectInstance.get('whoId'))!= NULL && String.valueOf(sObjectInstance.get('whoId')).startsWith(sLeadPrefix))
	                 {
	                     setLeadIds.add((Id)sObjectInstance.get('whoId'));  
	                     mapLeadIdSobjectId.put((Id)sObjectInstance.get('whoId'),sObjectInstance.Id);
	                 }   
	             }
	             
	             // Update the lead records related to task/event records deleted 
	             if(!setLeadIds.isEmpty())
	             {
	                 List<task> lstLeadRelatedTasks = new List<task>();
	                 List<Event> lstLeadRelatedEvents = new List<Event>();
	                 
	                 
	                 lstLeadUpdate =[SELECT Id,Core_Last_Activity_Date__c,Core_Having_Tasks__c,(SELECT Id,LastModifiedDate FROM Tasks ORDER BY LastModifiedDate DESC),
	                                 (SELECT Id,LastModifiedDate FROM Events ORDER BY LastModifiedDate DESC) From Lead Where Id IN :setLeadIds];
	                 
	                 for(Lead leadInstance : lstLeadUpdate)
	                 {
	                     lstLeadRelatedTasks = leadInstance.tasks;
	                     lstLeadRelatedEvents = leadInstance.events;
	                     
	                     if(!lstLeadRelatedTasks.isEmpty() && !lstLeadRelatedEvents.isEmpty())
	                         leadInstance.Core_Last_Activity_Date__c = ((lstLeadRelatedTasks.get(0).LastModifiedDate > lstLeadRelatedEvents.get(0).LastModifiedDate)?
	                                                                     lstLeadRelatedTasks.get(0).LastModifiedDate : lstLeadRelatedEvents.get(0).LastModifiedDate);
	                     
	                     else if(!lstLeadRelatedTasks.isEmpty())
	                         leadInstance.Core_Last_Activity_Date__c = lstLeadRelatedTasks.get(0).LastModifiedDate;
	                     
	                     else if(!lstLeadRelatedEvents.isEmpty())
	                         leadInstance.Core_Last_Activity_Date__c = lstLeadRelatedEvents.get(0).LastModifiedDate;   
	                     
	                     else
	                         leadInstance.Core_Last_Activity_Date__c = NULL;
	                 }
	                 
	                 
	                 
	                 Database.SaveResult[] srList = Database.update(lstLeadUpdate, false);
	                 Integer databaseUpdateIndex = 0; 
	                 // Capturing the logs for error records
	                 for (Database.SaveResult sr : srList) 
	                 {
	                    
	                    if (!sr.isSuccess()) 
	                    {
	                        for(Database.Error err : sr.getErrors()) 
	                        {
	                            lstLeadUpdate.get(databaseUpdateIndex).addError(err.getMessage());
	                            
	                            System.debug('The following error has occurred.');                    
	                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                            System.debug('Lead fields that affected this error: ' + err.getFields());
	                        }
	                    }
	                    databaseUpdateIndex++;
	                 }
	             }
         	}
         }
         
         
	    /*
	     * Method name  : islastActivityDateUpdateOnUpsert
	     * Description  : Ensures that the trigger will run once for "Last Activity Date Update ( for insert/update)"
	     * Return Type  : boolean
	     * Parameter    : NONE
	     */
	    public static boolean islastActivityDateUpdateOnUpsert() {
	        // Set the bolean to TRUE once the trigger is RUN
	        if (blastActivityDateUpdateOnUpsert) {
	            blastActivityDateUpdateOnUpsert = false;
	            return true;
	        } else {
	            return blastActivityDateUpdateOnUpsert;
	        }
	    }
	    
	    /*
	     * Method name  : islastActivityDateUpdateOnUpsert
	     * Description  : Ensures that the trigger will run once for "lastActivityDateUpdateonDelete ( for Delete)"
	     * Return Type  : boolean
	     * Parameter    : NONE
	     */
	    public static boolean islastActivityDateUpdateOnDelete() {
	        // Set the bolean to TRUE once the trigger is RUN
	        if (bLastActivityDateUpdateOnDelete) {
	            bLastActivityDateUpdateOnDelete = false;
	            return true;
	        } else {
	            return bLastActivityDateUpdateOnDelete;
	        }
	    }

         
    }