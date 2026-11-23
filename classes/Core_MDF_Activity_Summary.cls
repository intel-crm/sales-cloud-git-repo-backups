public without sharing class Core_MDF_Activity_Summary {
    
    @AuraEnabled(cacheable=true)
    public static PartnerFundRequest getActivityDetails(String recordId){
        return [SELECT Id,Campaign.Name, Core_MDF_Program__c, Core_MDF_Budget_Amount_Local_amt__c,Title, Description, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, ChannelPartner.Name, Core_MDF_Focus_Area_nm__c, Core_MDF_TargetAudience__c, Core_MDF_TargetAudience_nm__c, Core_MDF_Region_nm__c, Core_MDF_Country_nm__c FROM PartnerFundRequest WHERE Id =: recordId LIMIT 1];
    }

    public static String findMinAndMaxDates(List<DateTime> dateList){
        DateTime minDate;
        DateTime maxDate;
        if(!dateList.isEmpty()){
            minDate = dateList[0];
            maxDate = dateList[0];

            for(DateTime currentDate : dateList) {
                if(currentDate < minDate) {
                    minDate = currentDate;
                }
                if(currentDate > maxDate) {
                    maxDate = currentDate;
                }
            }
            return String.valueOf(minDate) + ' - ' + String.valueOf(maxDate);
        }
        return '';
    }
}