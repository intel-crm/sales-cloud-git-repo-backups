@IsTest
private class PartnerReportControllerTest {
  private class FakeExecutor extends PartnerReportController.ReportExecutor {
    public override String start(Id reportId) {
      Assert.areEqual(
        '00O000000000001',
        String.valueOf(reportId).substring(0, 15)
      );
      return '00O000000000002';
    }

    public override String read(Id reportId, Id instanceId) {
      Assert.areEqual(
        '00O000000000001',
        String.valueOf(reportId).substring(0, 15)
      );
      Assert.areEqual(
        '00O000000000002',
        String.valueOf(instanceId).substring(0, 15)
      );
      return '{"status":"Running","result":null}';
    }
  }

  private class FailingExecutor extends PartnerReportController.ReportExecutor {
    public override String start(Id reportId) {
      throw new ReportTestException('Private service failure');
    }

    public override String read(Id reportId, Id instanceId) {
      throw new ReportTestException('Private service failure');
    }
  }

  private class ReportTestException extends Exception {
  }

  private static final String ACCOUNT_COLUMN = 'PartnerFundClaim.Request.ChannelPartner.Core_MDF_Parent_Fund_Account__c.Name';
  private static final String STATUS_COLUMN = 'PartnerFundClaim.Core_MDF_Status__c';

  private class ChartExecutor extends PartnerReportController.ReportExecutor {
    Reports.ReportMetadata submitted;
    Boolean details;
    PartnerReportController.ChartSnapshot chart;

    public override Reports.ReportMetadata describe(Id reportId) {
      return sampleMetadata();
    }

    public override String launch(
      Id reportId,
      Reports.ReportMetadata metadata,
      Boolean includeDetails
    ) {
      submitted = metadata;
      details = includeDetails;
      return '00O000000000002';
    }

    public override PartnerReportController.ChartSnapshot completedChart(
      Id reportId,
      Id instanceId
    ) {
      return chart;
    }
  }

  private static Reports.ReportMetadata sampleMetadata() {
    return (Reports.ReportMetadata) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'reportFormat' => 'TABULAR',
          'detailColumns' => new List<String>{
            ACCOUNT_COLUMN,
            'Account.Name',
            STATUS_COLUMN,
            'PartnerFundClaim.Amount'
          },
          'reportFilters' => new List<Object>{
            new Map<String, Object>{
              'column' => STATUS_COLUMN,
              'operator' => 'notEqual',
              'value' => 'Rejected'
            },
            new Map<String, Object>{
              'column' => 'Account.Name',
              'operator' => 'notEqual',
              'value' => ''
            }
          },
          'reportBooleanFilter' => '1 OR 2'
        }
      ),
      Reports.ReportMetadata.class
    );
  }

  private static PartnerReportController.ChartSnapshot sampleChart(
    Boolean complete,
    String barKey
  ) {
    Reports.ReportMetadata metadata = sampleMetadata();
    PartnerReportController.configureChart(metadata);
    PartnerReportController.ChartSnapshot chart = new PartnerReportController.ChartSnapshot();
    chart.metadata = metadata;
    chart.allData = complete;
    chart.selections.add(
      new PartnerReportController.ChartSelection(barKey, 'Approved')
    );
    return chart;
  }

  @IsTest
  static void startsRuntimeSummaryWithoutChangingSavedFilters() {
    ChartExecutor fake = new ChartExecutor();
    PartnerReportController.executor = fake;
    Assert.areEqual(
      '00O000000000002',
      PartnerReportController.startChart('00O000000000001')
    );
    Assert.areEqual(false, fake.details);
    Assert.areEqual(
      Reports.ReportFormat.SUMMARY,
      fake.submitted.getReportFormat()
    );
    Assert.areEqual(1, fake.submitted.getGroupingsDown().size());
    Assert.areEqual(
      STATUS_COLUMN,
      fake.submitted.getGroupingsDown()[0].getName()
    );
    Assert.areEqual(
      new List<String>{ 's!PartnerFundClaim.Amount', 'RowCount' },
      fake.submitted.getAggregates()
    );
    Assert.isTrue(fake.submitted.getDetailColumns().contains(ACCOUNT_COLUMN));
    Assert.isFalse(fake.submitted.getDetailColumns().contains(STATUS_COLUMN));
    Assert.areEqual('1 OR 2', fake.submitted.getReportBooleanFilter());
    Assert.areEqual(2, fake.submitted.getReportFilters().size());
  }

  @IsTest
  static void drilldownPreservesSavedLogicAndAddsExactServerSideGroupValues() {
    ChartExecutor fake = new ChartExecutor();
    fake.chart = sampleChart(true, '0_0');
    PartnerReportController.executor = fake;
    Assert.areEqual(
      '00O000000000002',
      PartnerReportController.startDrilldown(
        '00O000000000001',
        '00O000000000002',
        '0_0'
      )
    );
    Assert.areEqual(true, fake.details);
    Assert.areEqual(
      Reports.ReportFormat.TABULAR,
      fake.submitted.getReportFormat()
    );
    Assert.areEqual(0, fake.submitted.getGroupingsDown().size());
    Assert.areEqual(
      sampleMetadata().getDetailColumns(),
      fake.submitted.getDetailColumns()
    );
    Assert.areEqual('(1 OR 2) AND 3', fake.submitted.getReportBooleanFilter());
    Assert.areEqual(3, fake.submitted.getReportFilters().size());
    Assert.areEqual(
      'Approved',
      fake.submitted.getReportFilters()[2].getValue()
    );
  }

  @IsTest
  static void rejectsIncompleteOrUnknownChartSelections() {
    ChartExecutor fake = new ChartExecutor();
    PartnerReportController.executor = fake;
    for (Boolean complete : new List<Boolean>{ true, false }) {
      fake.chart = sampleChart(complete, '0_0');
      try {
        PartnerReportController.startDrilldown(
          '00O000000000001',
          '00O000000000002',
          'missing'
        );
        Assert.fail('Invalid chart selection must fail');
      } catch (AuraHandledException ex) {
        Assert.isTrue(
          ex.getMessage()
            .contains(
              complete ? 'does not exist' : 'not a complete partner chart'
            )
        );
      }
    }
    try {
      PartnerReportController.startDrilldown(
        '00O000000000001',
        '00O000000000002',
        ''
      );
      Assert.fail('Blank selection must fail');
    } catch (AuraHandledException ex) {
      Assert.isTrue(ex.getMessage().contains('Select a chart bar'));
    }
  }

  @IsTest
  static void handlesDefaultLogicBlankGroupsAndLiteralCommaValues() {
    Reports.ReportMetadata metadata = sampleMetadata();
    metadata.setReportBooleanFilter('');
    PartnerReportController.addDrilldownFilters(metadata, 'Review, pending');
    Assert.areEqual('(1 AND 2) AND 3', metadata.getReportBooleanFilter());
    Assert.areEqual(
      '"Review, pending"',
      metadata.getReportFilters()[2].getValue()
    );
    metadata.setReportFilters(new List<Reports.ReportFilter>());
    metadata.setReportBooleanFilter('');
    PartnerReportController.addDrilldownFilters(metadata, null);
    Assert.areEqual('1', metadata.getReportBooleanFilter());
    Assert.areEqual('', metadata.getReportFilters()[0].getValue());
  }

  @IsTest
  static void rejectsChartWithoutRequiredColumns() {
    Reports.ReportMetadata metadata = sampleMetadata();
    metadata.setDetailColumns(new List<String>{ 'Account.Name' });
    try {
      PartnerReportController.configureChart(metadata);
      Assert.fail('Missing chart columns must fail');
    } catch (Exception ex) {
      Assert.isTrue(ex.getMessage().contains('must include'));
    }
  }

  @IsTest
  static void chartDoesNotRequireAccountColumn() {
    ChartExecutor fake = new ChartExecutor();
    Reports.ReportMetadata metadata = sampleMetadata();
    metadata.setDetailColumns(
      new List<String>{ STATUS_COLUMN, 'PartnerFundClaim.Amount' }
    );
    PartnerReportController.configureChart(metadata);
    Assert.areEqual(1, metadata.getGroupingsDown().size());
    Assert.areEqual(STATUS_COLUMN, metadata.getGroupingsDown()[0].getName());
  }

  @IsTest
  static void rejectsInvalidIdentifiers() {
    for (
      String value : new List<String>{
        null,
        '',
        'not-a-report',
        '001000000000001'
      }
    ) {
      try {
        PartnerReportController.startReport(value);
        Assert.fail('Invalid report ID must fail');
      } catch (AuraHandledException ex) {
        Assert.areEqual(
          'Configure a valid Salesforce report ID.',
          ex.getMessage()
        );
      }
    }
  }

  @IsTest
  static void returnsExecutorResults() {
    PartnerReportController.executor = new FakeExecutor();
    Assert.areEqual(
      '00O000000000002',
      PartnerReportController.startReport('00O000000000001')
    );
    Assert.areEqual(
      '{"status":"Running","result":null}',
      PartnerReportController.getReportResults(
        '00O000000000001',
        '00O000000000002'
      )
    );
  }

  @IsTest
  static void rejectsInvalidInstanceIdentifiers() {
    for (String value : new List<String>{ null, '', 'not-an-instance' }) {
      try {
        PartnerReportController.getReportResults('00O000000000001', value);
        Assert.fail('Invalid instance ID must fail');
      } catch (AuraHandledException ex) {
        Assert.isTrue(
          ex.getMessage().contains('report run identifier is invalid')
        );
      }
    }
  }

  @IsTest
  static void surfacesExecutionFailureWithoutPrivateDetails() {
    PartnerReportController.executor = new FailingExecutor();
    try {
      PartnerReportController.startReport('00O000000000001');
      Assert.fail('Report execution must fail');
    } catch (AuraHandledException ex) {
      Assert.isTrue(ex.getMessage().contains('Unable to run this report.'));
      Assert.isFalse(ex.getMessage().contains('Private service failure'));
    }
    try {
      PartnerReportController.getReportResults(
        '00O000000000001',
        '00O000000000002'
      );
      Assert.fail('Result retrieval must fail');
    } catch (AuraHandledException ex) {
      Assert.isTrue(ex.getMessage().contains('Unable to run this report.'));
    }
  }

  @IsTest
  static void rejectsUnavailableRealInstance() {
    try {
      PartnerReportController.getReportResults(
        '00O000000000001',
        '00O000000000002'
      );
      Assert.fail('A nonexistent instance must not return results');
    } catch (AuraHandledException ex) {
      Assert.isTrue(ex.getMessage().contains('Unable to run this report.'));
    }
  }
}