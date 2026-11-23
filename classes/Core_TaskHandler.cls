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
public class Core_TaskHandler
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
   
    Public Static string Checkleadsource(List<Task> newlist){
        String message='Ok';
        String LeadSourceMsg = Label.Core_LeadSource_on_Task;
        List<Id> leadIdsforLeadsource=new List<Id>();
        
        String SalesleadRectypeId = [Select id from Recordtype where Name = 'Sales Lead'].id;
        for(Task t:newlist){
         if(t.whoId!=null &&String.valueOf(t.whoId).startsWith('00Q')==TRUE){
           if(String.valueOf(t.whoId).startsWith('00Q')==TRUE){
                
                     if( !leadIdsforLeadsource.contains(t.whoid)){   
                         leadIdsforLeadsource.add(t.whoId);
                      }
            }
         }
        }
        List<Lead> leadlstLeadSource=[Select id,Status,Core_Having_Tasks__c,LeadSource,RecordTypeId from Lead where id in: leadIdsforLeadsource];  
        List<Task> LeadidswoLeadsourc= new List<Task>();
        For(Lead l:leadlstLeadSource){
            if(l.RecordTypeId==SalesleadRectypeId && l.LeadSource==null){
                    message='Not Ok';
                   
                for(task t:newlist){
                       t.addError(LeadSourceMsg);
                     }
            }
        }
        
       return message; 
    }
    
     /*
    * Method name  : updatetaskflag
    * Description  : Method to check if any tasks is created on Lead  and update a flag  on Lead for new lead prorcess for US153250 
    * Return Type  : VOID
    * Parameter    : List Trigger.new
    */
   public Static void UpdateTaskflag(List<Task> newlist){ 
       
       // To Check LeadSource is updated for Sales Lead Record
     String message=Checkleadsource(newlist);
       system.debug('message'+message);
       if(message=='OK'){
           List<Id> leadIds=new List<Id>();
	       List<Id> leadIdsMeeting=new List<Id>();
	       Map<Id,Date> taskdates= new Map<Id,Date>();
         for(Task t:newlist){
             if(t.whoId!=null &&String.valueOf(t.whoId).startsWith('00Q')==TRUE){
            if(String.valueOf(t.whoId).startsWith('00Q')==TRUE && (t.Subject == 'Phone' || t.Subject=='Email')){
                
                     if( !leadIds.contains(t.whoid)){           
                                 leadIds.add(t.whoId);
                      }
              }else if(String.valueOf(t.whoId).startsWith('00Q')==TRUE && (t.Subject == 'Meeting')){
				
				 if( !leadIdsMeeting.contains(t.whoid)){ 
                                 leadIdsMeeting.add(t.whoId);
								 taskdates.put(t.whoId,t.ActivityDate);
                      }
			  }
             }
           }
		
        List<Lead> leadlst=[Select id,Status,Core_Having_Tasks__c from Lead where id in: leadIds and Core_Having_Tasks__c=false];  
        List<Lead> leadlstmeeting=[Select id,Status,Core_Having_Tasks__c,Core_Meeting_Due_Date__c  from Lead where id in: leadIdsMeeting]; 
   
        if(leadIds.size()>0){
           for(lead le : leadlst){
            
            if(le.Status=='Marketing Qualified Lead' || le.Status=='Sales Qualified Lead'){
                le.Core_Having_Tasks__c=false;
              }
            else if(le.Status=='Tele Accepted Lead' || le.Status=='Sales Accepted Lead'){
                le.Core_Having_Tasks__c=True;
              }
             }
          }
	   if(leadIdsMeeting.size()>0){
          for(lead le : leadlstmeeting){
            
           if(le.Status=='Tele Qualified Lead'){
               le.Core_Having_Tasks_in_TQL__c=True;
           }else{
               le.Core_Having_Tasks_in_TQL__c=false;
           }
         }
        } 
         
       if(leadlstmeeting.size()>0){
		  for(Lead l: leadlstmeeting){
			  for(Task t:newlist){
			  l.Core_Meeting_Due_Date__c=t.ActivityDate;
			  }
		   } 
	     }
        update leadlstmeeting;
        Update leadlst;
      }  
    }
    
       /*
    * Method name  : updatetaskflagupdate
    * Description  : Method to check if any tasks is created on Lead  and update a flag on Lead for new lead prorcess for US153250
    * Return Type  : VOID
    * Parameter    : List Trigger.new,Trigger.Old
    */
public Static void UpdateTaskflagOnUpdate( List<Task> oldList , List<Task> newList){
    List<Id> leadIds=new List<Id>();
    List<Id> leadIdsnew=new List<Id>();
    List<Id> MeetingTaskLeadIds=new List<Id>();
    List<Id> NotMeetingTaskLeadIds=new List<Id>();
        
    for(Task t:oldList){
         if(t.whoId!=null &&String.valueOf(t.whoId).startsWith('00Q')==TRUE){
            if(String.valueOf(t.whoId).startsWith('00Q')==TRUE ){
                  for(Task tnew :newList){
                      if(tnew.Subject == 'Phone' || tnew.Subject =='Email'){
                             if( !leadIds.contains(t.whoid)){           
                                     leadIds.add(t.whoId); 
                               }
                    } else{
                        if( !leadIdsnew.contains(t.whoid)){           
                                 leadIdsnew.add(t.whoId); 
                       }   
                    } 
                 }        
            }
      }
    }
    for(Task t:oldList){
         if(t.whoId!=null &&String.valueOf(t.whoId).startsWith('00Q')==TRUE){
            if(String.valueOf(t.whoId).startsWith('00Q')==TRUE ){
                  for(Task tnew :newList){
                      if(tnew.Subject == 'Meeting'){
                        
                      if( !MeetingTaskLeadIds.contains(t.whoid)){           
                                 MeetingTaskLeadIds.add(t.whoId); 
                         }
                       } else{
                        
                         if( !NotMeetingTaskLeadIds.contains(t.whoid)){           
                                 NotMeetingTaskLeadIds.add(t.whoId); 
                     } 
                    }
                }      
            }
         }  
    }
   List<Lead> leadlst=[Select id,Status,Core_Having_Tasks__c from Lead where id in: leadIds ];
   List<Lead> leadlstnew=[Select id,Status,Core_Having_Tasks__c from Lead where id in: leadIdsnew];
   List<Lead> MeetingTaskLeadDetails=[Select id,Status,Core_Having_Tasks_in_TQL__c from Lead where id in: MeetingTaskLeadIds];
   List<Lead> NotMeetingTaskLeadDetails=[Select id,Status,Core_Having_Tasks_in_TQL__c from Lead where id in: NotMeetingTaskLeadIds];
   if(leadIds.size()>0){
       for(lead le : leadlst){
          if(le.Status=='Tele Accepted Lead' || le.Status=='Sales Accepted Lead'){
                le.Core_Having_Tasks__c=true;
           
            }else{
                  le.Core_Having_Tasks__c=false;
            }
       
      }
    Update leadlst;
     }  
   
   if(leadlstnew.size()>0){
       for(lead le : leadlstnew){
           if(le.Status=='Tele Accepted Lead' || le.Status=='Sales Accepted Lead'){
             le.Core_Having_Tasks__c=false;
            }else{
                //  le.Core_Having_Tasks__c=true;
            }
      }
    Update leadlstnew;
     }  
	  if(MeetingTaskLeadDetails.size()>0){
        for(lead le : MeetingTaskLeadDetails){
           if(le.Status=='Tele Qualified Lead'){
               le.Core_Having_Tasks_in_TQL__c=True;
            }else{
               le.Core_Having_Tasks_in_TQL__c=false;   
           }
      }
     } 
    if(NotMeetingTaskLeadDetails.size()>0){
       for(lead le : NotMeetingTaskLeadDetails){
		    if(le.Status=='Tele Qualified Lead'){
            le.Core_Having_Tasks_in_TQL__c=false;
           }else{
               system.debug('TQL true new');
              // le.Core_Having_Tasks_in_TQL__c=true;
               
           }
      }
   update NotMeetingTaskLeadDetails;
     }
   //due date update
    if(MeetingTaskLeadDetails.size()>0){
		  for(Lead l: MeetingTaskLeadDetails){
			  for(Task t:newlist){
			  l.Core_Meeting_Due_Date__c=t.ActivityDate;
			  }
		  }	  
	  }	 
	  Update MeetingTaskLeadDetails;
  }     
}