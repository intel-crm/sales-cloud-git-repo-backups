public without sharing class Core_MDF_Create_CCP_Cases_Schedulable implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        Trigger_Execution__mdt switchOnOrOff = Trigger_Execution__mdt.getInstance('Core_MDF_Create_CCP_Cases_Switch');

        if (switchOnOrOff.Active__c) {

            // If today's date meets the criteria, run the batch
            if (shouldExecuteBatchJob(System.today())) {
                Core_MDF_Create_CCP_Cases_Batch batchRec = new Core_MDF_Create_CCP_Cases_Batch();
                Database.executeBatch(batchRec,Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_BatchSizeForCaseShare'));
            } else {
                // Running batch directly for Claims where Core_MDF_Audit_Hold__c is true but no Case record record is created
                // Running 4 times a day
                // Collecting claims where Core_MDF_Audit_Hold__c is true but no Case record is created
                List<PartnerFundClaim> pfcListForRetryCaseCreation = [SELECT Id, Core_MDF_Document_Submission_Missed_Ind__c, Core_MDF_Audit_Hold__c, Core_MDF_PIC_Review_Completed__c, Core_MDF_BackendReviewSelection_Ind__c 
                                                                        FROM PartnerFundClaim WHERE Core_MDF_Claim_Review_Case__c = NULL AND Core_MDF_Audit_Hold__c = true AND Core_MDF_Status__c != 'Cancelled' 
                                                                        AND Core_MDF_PIC_Review_Completed__c = true];
                
                if (!pfcListForRetryCaseCreation.isEmpty()) {
                    Id batchInstanceId = Database.executeBatch(new Core_MDF_ClaimReviewCaseProcessHelper(pfcListForRetryCaseCreation, 'CreateCases'), 50);
                }
            }   
        }
    }

    /****************************************************************************************************** 
    Method Name:        shouldExecuteBatchJob
    @return  :          Boolean
    @parameters:        currentDate
    Description:        This method will check if the batch should run based on the current date
    Criteria:		    Criteria for the batch job to be executed:
    			        2nd Monday of the month (following Intel quarter)
     			        4th Monday of the month (following Intel quarter)
     			        Last day of the 3rd month in the quarter (following standard quarter)
    Added By:           Roshan - 19-02-2025
    Modified By:        Date:       Changes:
    *******************************************************************************************************/ 
    public static Boolean shouldExecuteBatchJob(Date currentDate) {
        try {
            List<Period> currentFiscalQuarterDetails = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(currentDate);

            //Exit from the execution if the size is not 13(4,4,5)
            if (currentFiscalQuarterDetails.size() != 13) {
                return false;
            }

            List<Core_MDF_Custom_Label_Configration__mdt> params = [SELECT Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE Label = 'Core_MDF_WeeksForAuditFlaggingBatch' LIMIT 1];
            
            Integer daysToAdjust = Integer.valueOf(params[0].Core_MDF_Value2_Txt__c);  // For Monday: 1

            List<Integer> allowedWeekNumbers = new List<Integer>();
            for (String weekStr : params[0].Core_MDF_Value_Txt__c.split(';')) {
                allowedWeekNumbers.add(Integer.valueOf(weekStr.trim()));  // Allowed weeks for the batch to run in a quarter: 2, 4, 6, 8, 10, 12
            }

            for (Period week : currentFiscalQuarterDetails) {
                Integer adjustedWeekNumber = Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(week.Number);
                Date mondayInWeek = week.StartDate.addDays(daysToAdjust);

                // Break early if currentDate is lesser than the next Monday
                if (mondayInWeek > currentDate) {
                    break;
                }
                
                if (allowedWeekNumbers.contains(adjustedWeekNumber) && mondayInWeek == currentDate) {
                    return true;
                }
            }
    
            // Getting last day of the current quarter according to the Standard Calendar
            Date lastDayOfStandardQuarter = Core_MDF_Calendar_Utility.getStandardQuarterEndDate(currentDate);
            if (currentDate == lastDayOfStandardQuarter) {
                return true;
            }
            
            return false;
        }catch (Exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);return false;}
    }

}