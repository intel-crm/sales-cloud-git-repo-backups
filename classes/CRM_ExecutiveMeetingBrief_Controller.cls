public class CRM_ExecutiveMeetingBrief_Controller {
    @AuraEnabled	
     public static Id createMeetingBrief(Map<String, Object> meetingBriefData) {      
		Executive_Meeting_Brief__c meetingBrief = new Executive_Meeting_Brief__c();       
        
        meetingBrief.CRM_EMB_isOldOrNew__c = true;
        //EVENT Details
        meetingBrief.Core_Executive_Meeting_Brief_Name__c = (String) meetingBriefData.get('Core_Executive_Meeting_Brief_Name__c');
        meetingBrief.CRM_Scheduled_Start_Time__c = parseDate((String) meetingBriefData.get('CRM_Scheduled_Start_Time__c'));
        meetingBrief.CRM_Scheduled_End_Time__c = parseDate((String) meetingBriefData.get('CRM_Scheduled_End_Time__c'));
        meetingBrief.Account__c = (String) meetingBriefData.get('Account__c');
        system.debug('account ID '+meetingBrief.Account__c);

        try {
            insert meetingBrief;
            system.debug('INSIDE APEX Meeting Brief inserted'+meetingBrief.Id);
            return meetingBrief.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error saving meeting brief: ' + e.getMessage());
        }
    }
   
    
    private static Date parseDate(String dateStr) {
        if (String.isNotBlank(dateStr)) {
            try {
                return Date.valueOf(dateStr);
            } catch (Exception e) {
                System.debug('Error parsing date: ' + e.getMessage());
            }
        }
        return null;
    }

}