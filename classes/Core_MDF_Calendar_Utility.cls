/******************************************************************************************************
* Class Name  : Core_MDF_Calendar_Utility 
* Test Class  : Core_MDF_Calendar_Utility_Test
* Version     : 1.0 
* Created By  : Roshan - 19-02-2025
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------

*******************************************************************************************************/
public without sharing class Core_MDF_Calendar_Utility {

	
    /****************************************************************************************************** 
    Method Name:        getFiscalQuarterWeekPeriods
    @return  :          List
    @parameters:        inputDate
    Description:        Returns a list of weeks in the current quarter
    Added By:           Roshan - 19-02-2025
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static List<Period> getFiscalQuarterWeekPeriods(Date inputDate) {
        Date quarterStartDate;
        Date quarterEndDate;
        for(Period currentYearDetail : [SELECT FiscalYearSettings.Name, Type,Number,StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType='Custom' AND StartDate <=: inputDate and EndDate >=: inputDate ORDER BY Type, Number DESC]){
            if(currentYearDetail.Type == 'Quarter'){//To Find Quarter Start and End date
                quarterStartDate = currentYearDetail.startDate;
                quarterEndDate = currentYearDetail.EndDate;
            }
        }

        List<Period> currentFiscalQuarterDetails = [SELECT FiscalYearSettings.Name, type,Number,StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType='Custom' AND StartDate >=: quarterStartDate AND EndDate <=: quarterEndDate AND Type ='Week' ORDER By Number];
        return currentFiscalQuarterDetails;
    }

    /****************************************************************************************************** 
    Method Name:        getFiscalQuarterWeekPeriods
    @return  :          List
    @parameters:        currentFiscalQuarterDetails
    Description:        Returns a map of Period records with Month and WorkWeek as a key and the Period record
    Added By:           Roshan - 19-02-2025
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static Map<String, Period> mapMonthAndWeekPeriods(List<Period> currentFiscalQuarterDetails) {
        Map<String, Period> monthNumberToQuarterPeriodsMap = new Map<String, Period>();
        Integer monthNumber;
        Integer weekNumber;
        Integer weekCount = 1;

        for(Period currWeekPeriod : currentFiscalQuarterDetails){// Quarter Weeks: 4,4,5
            if(weekCount <= 4){
                if(weekCount == 1){
                    monthNumber = 1;
                    weekNumber = 1;
                }
                
            }else if(weekCount >= 5 && weekCount <= 8){
                if(weekCount == 5){
                    monthNumber = 2;
                    weekNumber = 1;
                }
            }else{
                if(weekCount == 9){
                    monthNumber = 3;
                    weekNumber = 1;
                }
            }

            monthNumberToQuarterPeriodsMap.put(('M' + String.valueOf(monthNumber) + 'WW' + String.valueOf(weekNumber)),  currWeekPeriod);
            weekNumber += 1;
            weekCount += 1;
        }
        return monthNumberToQuarterPeriodsMap;
    }

    /****************************************************************************************************** 
    Method Name:        getWeekNumberOfQuarter
    @return  :          Integer
    @parameters:        weekNumber
    Description:        Returns the week number of the given date in the range of 1 to 13
    Added By:           Roshan - 19-02-2025
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
	public static Integer getWeekNumberOfQuarter(Integer weekNumber) {
    	if (weekNumber > 13) {
        	return Math.mod(weekNumber - 1, 13) + 1;
    	}
    	return weekNumber;
	}

    /****************************************************************************************************** 
    Method Name:        getWeekNumberOfQuarter
    @return  :          Date
    @parameters:        currentDate
    Description:        Returns the end date of the quarter according to the Standard calendar
    Added By:           Roshan - 19-02-2025
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static Date getStandardQuarterEndDate(Date currentDate) {
        Integer year = currentDate.year();
        Integer quarter = (currentDate.month() - 1) / 3 + 1; // Determine the quarter (1 to 4)
    
        Integer lastMonthOfQuarter = quarter * 3; // Last month of the quarter (3, 6, 9, 12)
        Integer lastDay = Date.daysInMonth(year, lastMonthOfQuarter); // Get last day dynamically

        return Date.newInstance(year, lastMonthOfQuarter, lastDay);
    }

}