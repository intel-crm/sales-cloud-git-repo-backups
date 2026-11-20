/****************************************************************************************************************************************
* Class Name  : Core_MDF_FrequencyJobScheduler
* Version     : 1.0 
* Created Date: 10-Jun-2021
* Modification Log :
* Developer                  Date                          Description
*****************************************************************************************************************************************/
public class Core_MDF_FrequencyJobScheduler {
    
    /***************************************************************************************************** 
    Method Name   :        getNextScheduleddate
    @return       :        DateTime
    @parameters   :        JobFrequency, XMinutes,XHours,atTime,DaysOfWeek 
    Description   :        To perform various calls to method based on various jobFrequency values.
    Added By      :        Accenture - RG - 11/06/2021
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/  
    public static dateTime getNextScheduleddate(Core_MDF_Batch_Scheduler__c batchScheduler,Datetime currentTime) {
		//To Store NextScheduledTime
        Datetime nextScheduledTime;
        Switch on batchScheduler.Core_MDF_Job_Frequency__c{
            when 'Every X Minute' {
                if(batchScheduler.Core_MDF_Line_Items_Count_Nbr__c==0)
                {
                    nextScheduledTime = currentTime;
                }
        		else if(batchScheduler.Core_MDF_Every_X_Minute_Nbr__c != Null && batchScheduler.Core_MDF_Every_X_Minute_Nbr__c != ''){
                    nextScheduledTime = getRunTimeMinutes(currentTime,batchScheduler.Core_MDF_Every_X_Minute_Nbr__c);
                }
            }
            when 'Every X Hour'{
                if(batchScheduler.Core_MDF_Line_Items_Count_Nbr__c==0)
                {
                    nextScheduledTime = currentTime;
                }
                else if(batchScheduler.Core_MDF_Every_X_Hour_Nbr__c != Null && batchScheduler.Core_MDF_Every_X_Hour_Nbr__c != ''){
                	nextScheduledTime = getRunTimeHours(currentTime,batchScheduler.Core_MDF_Every_X_Hour_Nbr__c);
                }
            }
            when 'Daily'{
                if(batchScheduler.Core_MDF_GMT_Time__c != Null ){
                nextScheduledTime = getRuntimeDaily(currentTime,batchScheduler.Core_MDF_GMT_Time__c);
                }
            }
            when 'Days of Week'{
                if(batchScheduler.Core_MDF_GMT_Time__c != Null){
                nextScheduledTime = getRunTimeDaysWeek(batchScheduler.Core_MDF_Days_of_Week__c,currentTime,batchScheduler.Core_MDF_GMT_Time__c);
                }
            }
        }
        return nextScheduledTime;
    }

    /***************************************************************************************************** 
    Method Name   :        getRunTimeMinutes
    @return       :        DateTime
    @parameters   :        CurrentTime,XMinutes(Minutes Frequency)
    Description   :        Method to calculate NextRunTime of the Scheduled Jobs when Frequency selected as "Every X Minute"
    Added By      :        Accenture - RG - 11/06/2021
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/    
    public Static dateTime getRunTimeMinutes(Datetime currentTime,String XMinutes){
        Datetime nextScheduledTime;
           nextScheduledTime = currentTime.addMinutes(Integer.valueOf(XMinutes));
        return nextScheduledTime;
    }

    /***************************************************************************************************** 
    Method Name   :        getRunTimeHours
    @return       :        DateTime
    @parameters   :        Datetime currentTime,String Xhours (Hours Frequency) 
    Description   :        Method to calculate NextRunTime of the Scheduled Jobs when Frequency selected as "Every X Hour"
    Added By      :        Accenture - RG - 11/06/2021
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/    
    public Static dateTime getRunTimeHours(Datetime currentTime,String Xhours){
        Datetime nextScheduledTime;
           nextScheduledTime = currentTime.addHours(Integer.valueOf(Xhours));
        return nextScheduledTime;
    }
    
    /***************************************************************************************************** 
    Method Name   :        getRuntimeDaily
    @return       :        DateTime
    @parameters   :        Datetime currentTime,Time atTime (The Time When job should run daily) 
    Description   :        Method to calculate NextRunTime of the Scheduled Jobs when Frequency selected as "Daily"
    Added By      :        Accenture - RG - 11/06/2021
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/
    public Static dateTime getRuntimeDaily(Datetime currentTime,Time gmtTime){
        // new instance of current gmt time
        DateTime currentTimeGMT = DateTime.newInstanceGmt(currentTime.dateGmt(), currentTime.timeGmt());
        // new instance for next schedule time with gmt time 
        Datetime nextScheduledTimeGMT = DateTime.newInstanceGmt(currentTimeGMT.dateGmt(),gmtTime);
       	// scheduling job for next day if time is past for today
        if(currentTimeGMT > nextScheduledTimeGMT){
            nextScheduledTimeGMT = nextScheduledTimeGMT.addDays(1);
        }
        return nextScheduledTimeGMT;
    }
    
    /***************************************************************************************************** 
    Method Name   :        getRunTimeDaysWeek
    @return       :        DateTime
    @parameters   :        string DaysofWeek(List of days on which Scheduled job should run),Datetime currentTime,Time atTime (Job run time) 
    Description   :        Method to calculate NextRunTime of the Scheduled Jobs when Frequency selected as "Days of Week"
    Added By      :        Accenture - RG - 11/06/2021
    Modified By   :        Date:       		Changes: 
    ******************************************************************************************************/
    public Static dateTime getRunTimeDaysWeek(string DaysofWeek,Datetime currentTime,Time gmtTime){
        DateTime nextScheduledTime;
        // new instance for current gmt time
        DateTime currentTimeGMT = DateTime.newInstanceGmt(currentTime.dateGmt(), currentTime.timeGmt());
        //Check next 7 days scheduled times and return Scheduled time when early scheduled time found
        for(integer index=0;index<=7;index++){
			 DateTime Nextday = currentTimeGMT.addDays(index);
            //fetching day of week
             String day = Nextday.format('EEEE');
            //new instance for next schedule time with gmt time
             DateTime dayTimeGMT = DateTime.newInstanceGmt(Nextday.date(),gmtTime);
            //checking if day is in selected days of week 
            //Checking Currenttime is less than the calculated scheduled time in 2nd condition
            if(DaysofWeek.containsIgnoreCase(day) && currentTimeGMT <= dayTimeGMT){  
                nextScheduledTime = dayTimeGMT;
                break;
            }
        }
        return nextScheduledTime;
     } 
}