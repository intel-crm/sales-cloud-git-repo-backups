public class Core_MDF_SchFrequency_ServiceHandler {
  /*  
    public static void schedulerFrequencyOnBeforeInsert(List<Core_MDF_Scheduler_Frequency__c> schFrequencyList){
    }
	public static void schedulerFrequencyOnAfterInsert(List<Core_MDF_Scheduler_Frequency__c> schFrequencyList){
        List<Core_MDF_Custom_Scheduler__c> customSchedulerList = new List<Core_MDF_Custom_Scheduler__c>();
        for(Core_MDF_Scheduler_Frequency__c sch: schFrequencyList){
            Core_MDF_Custom_Scheduler__c customSch = new Core_MDF_Custom_Scheduler__c();
            Object type = Type.forName(sch.Core_MDF_Class_Name__c).newInstance(); // change  field name
            String s = JSON.serialize(type);
            customSch.Core_MDF_Object_Instance__c = s;
            customSch.Core_MDF_Batch_Size__c = sch.Core_MDF_Batch_Size__c;
            customSch.Core_MDF_Scheduled_Time__c = sch.Core_MDF_Start_Time__c;
            customSch.Core_MDF_Class_Name__c = sch.Core_MDF_Class_Name__c;
            customSch.Core_MDF_Status__c = 'Scheduled';
            customSch.Core_MDF_Scheduler_Frequency__c = sch.Id;
            customSchedulerList.add(customSch);
        }
        database.insert(customSchedulerList);
    }   */
}