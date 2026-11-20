public with sharing class timeUtils {
   
    public static Integer diffMinutes(DateTime dt1, DateTime dt2) {
        Integer dt1_year_int = dt1.year(); 
        Integer dt1_day_int = dt1.dayOfYear(); 
        Integer dt1_hour_int = dt1.hour(); 
        Integer dt1_minute_int = dt1.minute(); 
        Integer dt1_second_int = dt1.second(); 
        Integer dt1_in_seconds = (dt1_year_int * 31556926) + (dt1_day_int * 86400) + (dt1_hour_int * 3600) + (dt1_minute_int * 60) + (dt1_second_int * 1); 
        
        Integer dt2_year_int = dt2.year(); 
        Integer dt2_day_int = dt2.dayOfYear(); 
        Integer dt2_hour_int = dt2.hour(); 
        Integer dt2_minute_int = dt2.minute(); 
        Integer dt2_second_int = dt2.second(); 
        Integer dt2_in_seconds = (dt2_year_int * 31556926) + (dt2_day_int * 86400) + (dt2_hour_int * 3600) + (dt2_minute_int * 60) + (dt2_second_int * 1); 
        Integer total_duration_in_seconds=0;
        if(dt2_in_seconds>dt1_in_seconds) total_duration_in_seconds = dt2_in_seconds - dt1_in_seconds; 
        else total_duration_in_seconds = dt1_in_seconds - dt2_in_seconds;
        return (total_duration_in_seconds/60) ;
    }
    
    public static Integer addMinutes(Datetime dt1, Integer mins){
        Integer dt1_year_int = dt1.year(); 
        Integer dt1_day_int = dt1.dayOfYear(); 
        Integer dt1_hour_int = dt1.hour(); 
        Integer dt1_minute_int = dt1.minute(); 
        Integer dt1_second_int = dt1.second(); 
        Integer dt1_in_seconds = (dt1_year_int * 31556926) + (dt1_day_int * 86400) + (dt1_hour_int * 3600) + (dt1_minute_int * 60) + (dt1_second_int * 1); 
        Integer dt1_in_minutes = dt1_in_seconds/60;
        return dt1_in_minutes+mins;
    }
}