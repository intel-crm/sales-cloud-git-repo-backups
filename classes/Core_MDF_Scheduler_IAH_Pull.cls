/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Scheduler_IAH_Pull 
* Version     : 1.0 
* Created Date: 03-07-2022
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Navneet 		03-07-2022					  Scheduler class to invoke Core_MDF_Batch_IAH_Pull 
*********************************************************************************************************************************************************/
public without sharing class Core_MDF_Scheduler_IAH_Pull implements Schedulable {
	    public void execute(SchedulableContext sc)
        {	
            //check for bypass
            Trigger_Execution__mdt schedSwitch = Trigger_Execution__mdt.getInstance('Core_MDF_RUN_IAH_PULL_Switch');
        
        	if(schedSwitch.Active__c){
            	if (shouldRunIAHPull(System.today())) {
                	//add a check for batch size
					Database.executeBatch(new Core_MDF_Batch_IAH_Pull(), 50);
            	}
        	}
           // Core_MDF_Batch_IAH_Pull batch = new Core_MDF_Batch_IAH_Pull();
           // Database.executeBatch(batch);
           // system.debug('Scheduler class');
        }
    
		public static Boolean shouldRunIAHPull(Date currentDate) {
            
            try {
                // Get 13 fiscal weeks of the quarter (4-4-5)
                List<Period> currentFiscalQuarterDetails = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(currentDate);
                if (currentFiscalQuarterDetails.size() != 13) {
                    return false;
                }
                
                //List<Core_MDF_Custom_Label_Configration__mdt> params = [SELECT Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE Label = 'Core_MDF_WeekForIAHBatchRun' LIMIT 1];
                //rename - IAH
                Integer targetWeekOfQuarter = Integer.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_WeekForIAHBatchRun').Core_MDF_Value_Txt__c);
                Integer mondayOffset = Integer.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_WeekForIAHBatchRun').Core_MDF_Value2_Txt__c);

                //Integer mondayOffset = Integer.valueOf(params[0].Core_MDF_Value2_Txt__c);  // For Monday: 1

                for (Period week : currentFiscalQuarterDetails) {
                    Integer weekOfQuarter = Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(week.Number);

                    // check for week 2 of curr quarter
                    if (weekOfQuarter != targetWeekOfQuarter) continue;

                    // Monday of this week
                    Date mondayOfWeek = week.StartDate.addDays(mondayOffset);

                    // Return true if today matches
                    if (mondayOfWeek == currentDate) {
                        return true;
                    }
                }
        
                return false;
            }
            catch (Exception ex) {
                Core_MDF_CCP_UtilityClass.logError(ex);
                return false;
            }
        }
}