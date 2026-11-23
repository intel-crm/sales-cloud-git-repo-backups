public class PRM_Reminder_Email_TriggerHandler extends TriggerHandler{
 public static boolean firstRun = true;   
 public override void beforeInsert(){
     if(firstRun){
     PRM_ReminderEmail_Utility.updateTemplateName(trigger.new,null);
     }
 }
 
 public override void afterUpdate()
 {
     if(firstRun){
     PRM_ReminderEmail_Utility.updateTemplateName(trigger.new,(Map<Id,PRM_Reminder_Email__c>)trigger.oldMap);
     }
 }
    
    
}