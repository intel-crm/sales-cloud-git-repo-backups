public class Core_MDF_FiscalYearController {
    @AuraEnabled
    public static List<FiscalYearWrapper> getFiscalYearDetails(){
        String yr =String.valueOf(System.today().year());
        List<FiscalYearWrapper> fiscalyearWrapperList = new List<FiscalYearWrapper>();               
        for(Period period:[SELECT FiscalYearSettings.Name,Number,StartDate,EndDate 
                        FROM Period 
                        WHERE FiscalYearSettings.YearType='Custom' and Type = 'Quarter'
                             and FiscalYearSettings.Name=:yr  
                     order by Number asc LIMIT 4]){
                    // String year = yr.right(2);
                    String startDate =getMonth(period.StartDate) +' '+ (period.StartDate).Day() + getDayOfMonthSuffix((period.StartDate).Day());
                    String endDate = getMonth(period.EndDate) + ' ' + (period.EndDate).Day() + getDayOfMonthSuffix((period.EndDate).Day());
                   //fiscalyearWrapper fiscalYrWrapper= new FiscalYearWrapper('Q'+period.Number,yr.right(2),String.valueOf(period.StartDate),String.valueOf(period.EndDate));
                    fiscalyearWrapper fiscalYrWrapper= new FiscalYearWrapper('Q'+period.Number,yr.right(2),startDate,endDate);

                         fiscalyearWrapperList.add(fiscalYrWrapper);
        }
        System.debug('<<fiscalyearWrapper>>'+fiscalyearWrapperList);    
        return fiscalyearWrapperList;
    }
   public class FiscalYearWrapper{
    @AuraEnabled public string quarter;
    @AuraEnabled public string year;
    @AuraEnabled public string startDate;
    @AuraEnabled public string endDate;
    
     public FiscalYearWrapper(string quarter,String year, String startDate, String  endDate){
        this.quarter = quarter;
        this.year = year;
        this.startDate = startDate;
        this.endDate = endDate;
     }
   }
     public static String getDayOfMonthSuffix(Integer day) {
         if (day == null) {
             return '';
         }
        Integer modResult = Math.mod(day, 10);        
        if (modResult == 1) { 
            return 'st'; 
        } else if (modResult == 2) { 
            return 'nd'; 
        } else if (modResult == 3) { 
            return 'rd'; 
        } else { 
            return 'th';
        }
    }
    public static String getMonth(Date dt) {
     return DateTime.newInstanceGMT(Date.newInstance(dt.year(), dt.month(), dt.day()), Time.newInstance(0, 0, 0, 0)).formatGMT('MMM');
    }
     
}