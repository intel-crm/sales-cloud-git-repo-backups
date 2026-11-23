public class PRM_ReminderEmail_Utility {

    public static void updateTemplateName(List<PRM_Reminder_Email__c> newReminderEmail,Map<Id,PRM_Reminder_Email__c> oldReminderEmail)
    {
        try{
        Map<ID,List<PRM_Reminder_Email__c>> reminderMap = new  Map<Id,List<PRM_Reminder_Email__c>>();
        List<PRM_Reminder_Email__c> remindersToUpdate = new List<PRM_Reminder_Email__c>();
        List<PRM_Reminder_Email__c> listOfReminders = new List<PRM_Reminder_Email__c>();
        Set<Id> campaignIds = new  Set<Id>();
        Set<Decimal> reminders = new Set<Decimal>();
        for(PRM_Reminder_Email__c remRec:newReminderEmail){
         campaignIds.add(remRec.PRM_Campaign__c);
         reminders.add(remRec.PRM_Reminder__c);
        }
        for(PRM_Reminder_Email__c remRec :[Select ID,PRM_Campaign__c,PRM_Email_Template__c, PRM_Reminder__c FROM PRM_Reminder_Email__c where PRM_Campaign__c in :campaignIds and PRM_Reminder__c in :reminders]){           
           if(!reminderMap.containskey(remRec.PRM_Campaign__c)){
                            listOfReminders = new List<PRM_Reminder_Email__c>();
                            listOfReminders.add(remRec);
                            reminderMap.put(remRec.PRM_Campaign__c,listOfReminders);
                        }else{
                            reminderMap.get(remRec.PRM_Campaign__c).add(remRec);
                        }
        }        
        for(PRM_Reminder_Email__c remRec : newReminderEmail){
            if((remRec.PRM_Email_Template__c != null && oldReminderEmail!=null && remRec.PRM_Email_Template__c != oldReminderEmail.get(remRec.id).PRM_Email_Template__c)){
               List<PRM_Reminder_Email__c> remList = reminderMap.get(remRec.PRM_Campaign__c);
                for(PRM_Reminder_Email__c reminder : remList){
                    if(remRec.PRM_Reminder__c == reminder.PRM_Reminder__c){
                        reminder.PRM_Email_Template__c = remRec.PRM_Email_Template__c;
                          // remindersToUpdate.add(remRec);
                        }
                        remindersToUpdate.add(reminder);
                    }
                }                
            
            if(oldReminderEmail == null){
                system.debug('before insert');
                List<PRM_Reminder_Email__c> remList = reminderMap.get(remRec.PRM_Campaign__c);
                for(PRM_Reminder_Email__c reminder : remList){
                 if(reminder.PRM_Email_Template__c != null){
                    if(remRec.PRM_Reminder__c == reminder.PRM_Reminder__c){
                        remRec.PRM_Email_Template__c = reminder.PRM_Email_Template__c;}
                 } 

            }
        }
        }
        
        if(remindersToUpdate!=null)
        {
            PRM_Reminder_Email_TriggerHandler.firstrun=false;
            database.upsert(remindersToUpdate,false);            
        }
        }catch(Exception e){
            System.debug('error');
        }
        
    }
}