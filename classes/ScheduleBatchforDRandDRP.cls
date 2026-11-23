global class ScheduleBatchforDRandDRP implements Schedulable {

    private final String JOBNAME = 'Schedule Batch for DR and DRP';
    private final Integer FIVEMINUTE =5;
    public void execute(SchedulableContext cont)
    {    
        System.debug('every 5 min');
     findAndAbortJob(cont);
     // Schedule BatchClassforDR
        BatchClassforDR batch1 = new BatchClassforDR();
        Database.executeBatch(batch1);

        // Schedule BatchClassforDRP
        BatchClassforDRP batch2 = new BatchClassforDRP();
        Database.executeBatch(batch2);
        
    }
    public void findAndAbortJob(SchedulableContext cont)
    {
        if (cont == null)
        {
            return;
        }
        
        List<CronJobDetail> cronDetail = [SELECT Id FROM CronJobDetail WHERE Name= :JOBNAME LIMIT 1];
        if (cronDetail.isEmpty())
        {
            return;
        }
        
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetailId = :cronDetail[0].Id];
        if(cronTriggers.isEmpty())
        {
            return;
        }
        try
        {
        
            System.abortJob(cronTriggers[0].Id);
            rescheduleJob();
        }
        catch (Exception e)
        {
            System.debug('This was the error : ' + e.getMessage());
        }
    }
    public  void rescheduleJob()
    {
        Datetime sysTime = System.now().addMinutes(FIVEMINUTE);
        String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule(JOBNAME, cronExpression, new ScheduleBatchforDRandDRP());
    }  
}