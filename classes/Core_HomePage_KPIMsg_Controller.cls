public with sharing class Core_HomePage_KPIMsg_Controller {
    
    public static DateTime lastRunPSTTime{get;set;}
    public static string lastRunPSTTimeString{get;set;}
    
    public void getPSTformattedKPITime(){
        Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
        String cronName = 'KPI_DeltaLoad_Everyday%';
        DateTime LastExecution = Datetime.newInstance(1600, 1, 1);
        List<Core_KPI_Refresh_Message__c> kpCsiList=[SELECT ID,Name,Core_LastModifiedDate__c FROM Core_KPI_Refresh_Message__c];
        if(kpCsiList.size() >0 && ! kpCsiList.isEmpty()){
            for(Core_KPI_Refresh_Message__c kpiMsg : kpCsiList){
                
                lastRunPSTTime = kpiMsg.Core_LastModifiedDate__c;
            }
            
            
        }
        //lastRunPSTTimeString=String.Valueof(lastRunPSTTime);
        if(lastRunPSTTime != NULL){ 
            lastRunPSTTimeString = lastRunPSTTime.format('MM/dd/yyyy HH:mm:ss','America/Los_Angeles');
            
            lastRunPSTTime = DateTime.newInstance(lastRunPSTTime.getTime() + tz.getOffset(System.Now()));
        }   
        /*      List<CronTrigger> ct = [SELECT Id, CronExpression, CronJobDetail.Name, NextFireTime, OwnerId, PreviousFireTime
FROM CronTrigger WHERE CronJobDetail.Name LIKE :cronName];


for(CronTrigger con : ct){
if(con.PreviousFireTime >= LastExecution){
LastExecution = con.PreviousFireTime;
}
}
System.debug('***GMT TIME = '+LastExecution);
lastRunPSTTimeString = LastExecution.format('MM/dd/yyyy HH:mm:ss','America/Los_Angeles');
lastRunPSTTime = DateTime.newInstance(LastExecution.getTime() + tz.getOffset(System.Now()));  
system.debug('***PST TIME - '+lastRunPSTTime);
system.debug('***PST TIME STRING - '+lastRunPSTTimeString);*/
    }
}