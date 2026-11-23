public with sharing class PartnerReportController {
  private static final String STATUS_COLUMN = 'PartnerFundClaim.Core_MDF_Status__c';
  private static final String AMOUNT_AGGREGATE = 's!PartnerFundClaim.Amount';
  @TestVisible
  private static ReportExecutor executor = new ReportExecutor();

  @AuraEnabled
  public static String startReport(String reportId) {
    Id parsedId = requireReportId(reportId);
    try {
      return executor.start(parsedId);
    } catch (Exception ex) {
      throw reportError(ex);
    }
  }

  @AuraEnabled
  public static String startChart(String reportId) {
    Id parsedId = requireReportId(reportId);
    try {
      return executor.startChart(parsedId);
    } catch (Exception ex) {
      throw reportError(ex);
    }
  }

  @AuraEnabled
  public static String startDrilldown(
    String reportId,
    String chartInstanceId,
    String groupKey
  ) {
    Id parsedId = requireReportId(reportId);
    Id parsedInstanceId = requireInstanceId(chartInstanceId);
    if (String.isBlank(groupKey)) {
      throw clientError('Select a chart bar before loading its details.');
    }
    try {
      return executor.startDrilldown(parsedId, parsedInstanceId, groupKey);
    } catch (Exception ex) {
      throw reportError(ex);
    }
  }

  @AuraEnabled
  public static String getReportResults(String reportId, String instanceId) {
    Id parsedReportId = requireReportId(reportId);
    Id parsedInstanceId = requireInstanceId(instanceId);
    try {
      return executor.read(parsedReportId, parsedInstanceId);
    } catch (Exception ex) {
      throw reportError(ex);
    }
  }

  private static Id requireInstanceId(String instanceId) {
    Id parsedInstanceId;
    try {
      parsedInstanceId = Id.valueOf(instanceId);
    } catch (Exception ex) {
      throw clientError(
        'The report run identifier is invalid. Refresh the report.'
      );
    }
    if (parsedInstanceId == null) {
      throw clientError(
        'The report run identifier is invalid. Refresh the report.'
      );
    }
    return parsedInstanceId;
  }

  private static Id requireReportId(String reportId) {
    Id parsedId;
    try {
      parsedId = Id.valueOf(reportId);
    } catch (Exception ex) {
      throw clientError('Configure a valid Salesforce report ID.');
    }
    if (parsedId == null || parsedId.getSObjectType() != Report.SObjectType) {
      throw clientError('Configure a valid Salesforce report ID.');
    }

    return parsedId;
  }

  private static AuraHandledException reportError(Exception ex) {
    System.debug(
      LoggingLevel.ERROR,
      'Partner report failed: ' + ex.getTypeName() + ': ' + ex.getMessage()
    );
    if (ex instanceof ReportAccessException) {
      return clientError(ex.getMessage());
    }
    return clientError(
      'Unable to run this report. Check your report-folder access, Run Reports permission, and underlying data access. If the problem persists, contact your Salesforce administrator.'
    );
  }

  private static AuraHandledException clientError(String message) {
    AuraHandledException error = new AuraHandledException(message);
    error.setMessage(message);
    return error;
  }

  public virtual class ReportExecutor {
    public virtual String start(Id reportId) {
      return launch(reportId, null, true);
    }

    public virtual String read(Id reportId, Id instanceId) {
      Reports.ReportInstance instance = ownedInstance(reportId, instanceId);
      String status = instance.getStatus();
      return JSON.serialize(
        new Map<String, Object>{
          'status' => status,
          'result' => status == 'Success' ? instance.getReportResults() : null
        }
      );
    }

    public virtual String startChart(Id reportId) {
      Reports.ReportMetadata metadata = describe(reportId);
      configureChart(metadata);
      return launch(reportId, metadata, false);
    }

    public virtual String startDrilldown(
      Id reportId,
      Id instanceId,
      String groupKey
    ) {
      ChartSnapshot chart = completedChart(reportId, instanceId);
      List<Reports.GroupingInfo> grouping = chart.metadata.getGroupingsDown();
      if (
        chart.allData != true ||
        grouping.size() != 1 ||
        grouping[0].getName() != STATUS_COLUMN
      ) {
        throw new ReportAccessException(
          'The report instance is not a complete partner chart.'
        );
      }
      for (ChartSelection selection : chart.selections) {
        if (selection.key == groupKey) {
          // Use the chart snapshot, so saved report edits cannot change drilldown filters.
          Reports.ReportMetadata metadata = chart.metadata;
          metadata.setReportFormat(Reports.ReportFormat.TABULAR);
          metadata.setGroupingsDown(new List<Reports.GroupingInfo>());
          metadata.setGroupingsAcross(new List<Reports.GroupingInfo>());
          metadata.setDetailColumns(describe(reportId).getDetailColumns());
          addDrilldownFilters(metadata, selection.status);
          return launch(reportId, metadata, true);
        }
      }
      throw new ReportAccessException('The selected chart bar does not exist.');
    }

    public virtual Reports.ReportMetadata describe(Id reportId) {
      return Reports.ReportManager.describeReport(reportId).getReportMetadata();
    }

    public virtual String launch(
      Id reportId,
      Reports.ReportMetadata metadata,
      Boolean includeDetails
    ) {
      Reports.ReportInstance instance = metadata == null
        ? Reports.ReportManager.runAsyncReport(reportId, includeDetails)
        : Reports.ReportManager.runAsyncReport(
            reportId,
            metadata,
            includeDetails
          );
      return String.valueOf(instance.getId());
    }

    public virtual ChartSnapshot completedChart(Id reportId, Id instanceId) {
      Reports.ReportInstance instance = ownedInstance(reportId, instanceId);
      if (instance.getStatus() != 'Success') {
        throw new ReportAccessException('The chart has not finished running.');
      }
      Reports.ReportResults result = instance.getReportResults();
      ChartSnapshot snapshot = new ChartSnapshot();
      snapshot.metadata = result.getReportMetadata();
      snapshot.allData = result.getAllData();
      for (
        Reports.GroupingValue status : result.getGroupingsDown().getGroupings()
      ) {
        snapshot.selections.add(
          new ChartSelection(status.getKey(), status.getValue())
        );
      }
      return snapshot;
    }
  }

  public class ChartSnapshot {
    public Reports.ReportMetadata metadata;
    public Boolean allData;
    public List<ChartSelection> selections = new List<ChartSelection>();
  }

  public class ChartSelection {
    public String key;
    public Object status;

    public ChartSelection(String key, Object status) {
      this.key = key;
      this.status = status;
    }
  }

  private static Reports.ReportInstance ownedInstance(
    Id reportId,
    Id instanceId
  ) {
    Reports.ReportInstance instance = Reports.ReportManager.getReportInstance(
      instanceId
    );
    if (
      instance.getOwnerId() != UserInfo.getUserId() ||
      instance.getReportId() != reportId
    ) {
      throw new ReportAccessException(
        'Report instance does not belong to this user and report.'
      );
    }
    return instance;
  }

  @TestVisible
  private static void configureChart(Reports.ReportMetadata metadata) {
    List<String> details = metadata.getDetailColumns();
    if (
      !details.contains(STATUS_COLUMN) ||
      !details.contains('PartnerFundClaim.Amount')
    ) {
      throw new ReportAccessException(
        'The report must include Claim Status and Reimbursement Amount.'
      );
    }
    // GroupingInfo has no public setters; deserialize only these fixed, trusted definitions.
    metadata.setGroupingsDown(
      (List<Reports.GroupingInfo>) JSON.deserialize(
        JSON.serialize(
          new List<Object>{
            new Map<String, Object>{
              'name' => STATUS_COLUMN,
              'sortOrder' => 'ASCENDING'
            }
          }
        ),
        List<Reports.GroupingInfo>.class
      )
    );
    metadata.setGroupingsAcross(new List<Reports.GroupingInfo>());
    for (Integer i = details.size() - 1; i >= 0; i--) {
      if (details[i] == STATUS_COLUMN) {
        details.remove(i);
      }
    }
    metadata.setDetailColumns(details);
    metadata.setSortBy(new List<Reports.SortColumn>());
    metadata.setReportFormat(Reports.ReportFormat.SUMMARY);
    metadata.setAggregates(new List<String>{ AMOUNT_AGGREGATE, 'RowCount' });
  }

  @TestVisible
  private static void addDrilldownFilters(
    Reports.ReportMetadata metadata,
    Object status
  ) {
    List<Reports.ReportFilter> filters = metadata.getReportFilters();
    if (filters == null) {
      filters = new List<Reports.ReportFilter>();
    }
    String originalLogic = metadata.getReportBooleanFilter();
    if (String.isBlank(originalLogic)) {
      List<String> clauses = new List<String>();
      for (Integer i = 1; i <= filters.size(); i++) {
        clauses.add(String.valueOf(i));
      }
      originalLogic = String.join(clauses, ' AND ');
    }
    Integer statusIndex = filters.size() + 1;
    filters.add(
      new Reports.ReportFilter(STATUS_COLUMN, 'equals', filterValue(status))
    );
    metadata.setReportFilters(filters);
    String selectionLogic = String.valueOf(statusIndex);
    metadata.setReportBooleanFilter(
      String.isBlank(originalLogic)
        ? selectionLogic
        : '(' + originalLogic + ') AND ' + selectionLogic
    );
  }

  private static String filterValue(Object value) {
    if (value == null) {
      return '';
    }
    String text = String.valueOf(value);
    return text.contains(',') || text.contains('"')
      ? '"' + text.replace('"', '""') + '"'
      : text;
  }

  private class ReportAccessException extends Exception {
  }
}