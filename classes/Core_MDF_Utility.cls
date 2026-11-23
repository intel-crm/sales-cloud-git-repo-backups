/******************************************
 @Author: Core_MDF_Utility
 @Version: <V.1.0>
 @CreatedDate: 21-Sept-2021
 @Description: Utility class for by passing the unwanted SOQL queries execution in Test Classes
**********************************************/
public class Core_MDF_Utility{
    public class CustomException extends Exception {}
    public static Boolean byPassFeature(String functionalityKey){
        Boolean isByPass = false;
		//Fetch Custom Setting record associated with functionalityKey  
        if(functionalityKey!= null) {   
            if(Core_Trigger_Executions__c.getInstance(functionalityKey)!= NULL && Core_Trigger_Executions__c.getInstance(functionalityKey).Core_Active__c){  
                isByPass = true;
            }
        }
        return isByPass;
    }
/****************************************************************************************************** 
Method Name:        getPeriodforDate
@return  :          period record
@parameters:        current date
Description:        This method is used to get Period data for the given date.
Added By:           Accenture - 10/March/2022
Modified By:        Date:       Changes: 

*******************************************************************************************************/ 

public static period getPeriodforDate(Date qtrDate){
		List<Period> periods = [Select number,startdate,enddate From Period Where type = 'Quarter' and StartDate<=:qtrDate AND enddate>=:qtrDate Limit 1];
		if(!periods.isEmpty()){
            system.debug('perioddata'+periods[0]);
			return periods[0];
            
		}
		throw new CustomException('Fiscal Period for given date not found.');
		}
}