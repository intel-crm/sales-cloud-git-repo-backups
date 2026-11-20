public class ReportsandDashboards {
@AuraEnabled(cacheable=true)
public static List<Reports__c> getReports() {
 List <Reports__c> listReportsMappings = Reports__c.getAll().values();
  // List<Report> listReportsMappings = [SELECT id,Name, Format, LastRunDate, LastViewedDate, LastModifiedDate, CreatedDate FROM Report limit 0];
   system.debug('Line 6'+listReportsMappings);
    return listReportsMappings;
 }

}