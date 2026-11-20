global class Core_Schedule_Batch_Delete_BES_Logs implements Schedulable {
    global String ObjectName = '';
    global Boolean isSingleObject = false;
    global Core_Schedule_Batch_Delete_BES_Logs(){
        this.isSingleObject = false;
    }
    global Core_Schedule_Batch_Delete_BES_Logs(String ObjectName){
        this.ObjectName = ObjectName;
        this.isSingleObject = true;
    } 
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_IPS_BES_Delete_All_Old_Logs_Batch(ObjectName,isSingleObject));
    }
}