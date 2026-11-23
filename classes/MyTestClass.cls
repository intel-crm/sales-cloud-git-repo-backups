public class MyTestClass {
	//MyTestClass.CalculateDateExcludingWeekend();
    public static void CalculateDateExcludingWeekend(DateTime startDateTime, DateTime endDateTime){
        system.debug('Start Date===>'+startDateTime);
        system.debug('End Date===>'+endDateTime);
        Decimal oneDayinMilliSecs = (24*60*60*1000);
        Decimal timeDiff = endDateTime.getTime() - startDateTime.getTime();
        
        String startDay  = startDateTime.format('EEEE');
        String endDay  = endDateTime.format('EEEE');        
        
        Date startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
        Date endDate = date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day());
        
        system.debug('startDay '+ startDay);
        system.debug('endDay '+ endDay);
        
        startDate = startDate.toStartOfWeek();
        endDate = endDate.toStartOfWeek();
        
        DateTime newWeekStart = date.newinstance(startDate.year(), startDate.month(), startDate.day());
        
        integer dayss = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day()).
                    daysBetween(date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day()));
        
        system.debug('weekendsbetweenOld '+ dayss/7);
        
        integer weeksbetween = startDate.daysBetween(endDate)/7;
        
        system.debug('weeksbetween '+ weeksbetween);
        
        if(weeksbetween > 0){
            system.debug('BeforetimeDiff ==>'+(timeDiff).Divide((24*60*60*1000), 2));
            timeDiff = (timeDiff - (weeksbetween * 2 * oneDayinMilliSecs));
            System.debug('Deduct '+(weeksbetween * 2 * oneDayinMilliSecs).Divide((24*60*60*1000), 2));
            system.debug('AftertimeDiff ==>'+(timeDiff).Divide((24*60*60*1000), 2));
            
            if(startDay == 'Saturday') {
            	timeDiff = timeDiff + oneDayinMilliSecs;
            	system.debug('Start Date is Saturday adding 1 day');
        	}
            
            if(endDay == 'Sunday') {
                timeDiff = timeDiff + oneDayinMilliSecs;
                system.debug('End date is Sunday adding 1 day');
            }
        }	    
        Decimal days = (timeDiff).Divide((24*60*60*1000), 2);
       
        System.debug('actualdaysbetween ==> ' + dayss);
        system.debug('calcdaysbetween   ==> '+days);
        system.debug('===========================> '+days);
      }
}