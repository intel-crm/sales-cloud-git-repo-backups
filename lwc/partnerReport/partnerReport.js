import { LightningElement, api } from "lwc";
import startReport from "@salesforce/apex/PartnerReportController.startReport";
import getReportResults from "@salesforce/apex/PartnerReportController.getReportResults";
import startChart from "@salesforce/apex/PartnerReportController.startChart";
import startDrilldown from "@salesforce/apex/PartnerReportController.startDrilldown";

const PAGE_SIZE = 25;
const AMOUNT_AGGREGATE = "s!PartnerFundClaim.Amount";
export default class PartnerReport extends LightningElement {
  configuredReportId = "";
  requestVersion = 0;
  columns = [];
  rows = [];
  reportName = "Salesforce report";
  errorMessage = "";
  isLoading = false;
  isTruncated = false;
  page = 1;
  pollTimer;
  pollResolve;
  chartBars = [];
  axisMaximum = 0;
  axisMinimum = 0;
  totalAmount = 0;
  totalRows = 0;
  chartInstanceId = "";
  selectedKey = "";
  detailHeading = "";
  showGrid = false;

  @api
  get reportId() {
    return this.configuredReportId;
  }

  set reportId(value) {
    this.configuredReportId = (value || "").trim();
    if (this.isConnected) {
      this.loadReport();
    }
  }

  connectedCallback() {
    this.loadReport();
  }

  disconnectedCallback() {
    this.requestVersion += 1;
    this.cancelPolling();
  }

  cancelPolling() {
    clearTimeout(this.pollTimer);
    this.pollResolve?.();
    this.pollResolve = undefined;
    this.pollTimer = undefined;
  }

  waitForReport() {
    return new Promise((resolve) => {
      this.pollResolve = resolve;
      // eslint-disable-next-line @lwc/lwc/no-async-operation -- Poll the asynchronous report at a bounded interval.
      this.pollTimer = setTimeout(() => {
        this.pollResolve = undefined;
        this.pollTimer = undefined;
        resolve();
      }, 2000);
    });
  }

  async loadReport(mode = "chart", selection) {
    const version = ++this.requestVersion;
    this.cancelPolling();
    this.rows = [];
    this.columns = [];
    this.page = 1;
    this.isTruncated = false;
    this.errorMessage = "";
    this.showGrid = false;
    if (mode === "chart") {
      this.chartBars = [];
      this.chartInstanceId = "";
      this.selectedKey = "";
      this.detailHeading = "";
      this.reportName = "Salesforce report";
    }
    this.isLoading = false;
    if (!/^00O[a-zA-Z0-9]{12}([a-zA-Z0-9]{3})?$/.test(this.reportId)) {
      this.errorMessage = "Set a valid report ID in Experience Builder.";
      return;
    }
    this.isLoading = true;
    try {
      const reportId = this.reportId;
      let instanceId;
      if (mode === "chart") {
        instanceId = await startChart({ reportId });
      } else if (mode === "drilldown") {
        instanceId = await startDrilldown({
          reportId,
          chartInstanceId: this.chartInstanceId,
          groupKey: selection.key
        });
      } else {
        instanceId = await startReport({ reportId });
      }
      if (version !== this.requestVersion) {
        return;
      }
      let result;
      for (let attempt = 0; attempt < 30; attempt += 1) {
        const response = JSON.parse(
          // eslint-disable-next-line no-await-in-loop -- Report status requests must be sequential.
          await getReportResults({ reportId, instanceId })
        );
        if (version !== this.requestVersion) {
          return;
        }
        if (response.status === "Success") {
          result = response.result;
          break;
        }
        if (!["New", "Running"].includes(response.status)) {
          throw new Error(
            "Salesforce could not complete the report. Check your access and try again."
          );
        }
        // eslint-disable-next-line no-await-in-loop -- Delay between status requests to avoid API flooding.
        await this.waitForReport();
        if (version !== this.requestVersion) {
          return;
        }
      }
      if (!result) {
        throw new Error(
          "The report is taking longer than one minute. Try refreshing later or refine the saved report filters."
        );
      }
      if (mode === "chart") {
        this.setChart(result);
        this.chartInstanceId = instanceId;
        return;
      }
      if (result?.reportMetadata?.reportFormat !== "TABULAR") {
        throw new Error("This viewer supports tabular reports only.");
      }
      const columnIds = result.reportMetadata.detailColumns;
      const columnInfo = result.reportExtendedMetadata?.detailColumnInfo;
      const detailRows = result.factMap?.["T!T"]?.rows;
      if (
        !Array.isArray(columnIds) ||
        !columnIds.length ||
        !columnInfo ||
        !Array.isArray(detailRows)
      ) {
        throw new Error(
          "The report did not return the expected detail columns and rows."
        );
      }
      const columns = columnIds.map((id, index) => {
        if (!columnInfo[id]?.label) {
          throw new Error("The report returned an invalid column definition.");
        }
        return { key: `column-${index}`, label: columnInfo[id].label };
      });
      const rows = detailRows.map((row, rowIndex) => {
        if (
          !Array.isArray(row.dataCells) ||
          row.dataCells.length !== columns.length
        ) {
          throw new Error("The report returned an invalid detail row.");
        }
        return {
          key: `row-${rowIndex}`,
          cells: row.dataCells.map((cell, index) => ({
            key: `cell-${index}`,
            label: cell.label ?? ""
          }))
        };
      });
      this.columns = columns;
      this.rows = rows;
      this.reportName = result.reportMetadata.name || "Salesforce report";
      this.isTruncated = result.allData === false;
      this.showGrid = true;
    } catch (error) {
      if (version === this.requestVersion) {
        this.errorMessage =
          error.body?.message ||
          error.message ||
          "Unable to load the report. Contact your Salesforce administrator.";
      }
    } finally {
      if (version === this.requestVersion) {
        this.isLoading = false;
      }
    }
  }

  setChart(result) {
    const metadata = result?.reportMetadata;
    const statuses = result?.groupingsDown?.groupings;
    const aggregateIndex = metadata?.aggregates?.indexOf(AMOUNT_AGGREGATE);
    if (
      metadata?.reportFormat !== "SUMMARY" ||
      !Array.isArray(statuses) ||
      !(aggregateIndex >= 0) ||
      result.allData !== true
    ) {
      throw new Error(
        "Salesforce did not return a complete reimbursement summary. Refine the saved report filters or contact your administrator; partial totals will not be charted."
      );
    }
    let maximum = 0;
    let minimum = 0;
    const countIndex = metadata.aggregates.indexOf("RowCount");
    const bars = statuses.map((status) => {
      if (
        status.groupings != null &&
        (!Array.isArray(status.groupings) || status.groupings.length > 0)
      ) {
        throw new Error("The report must group by Claim Status only.");
      }
      const aggregate =
        result.factMap?.[`${status.key}!T`]?.aggregates?.[aggregateIndex];
      if (
        typeof aggregate?.value !== "number" ||
        !Number.isFinite(aggregate.value)
      ) {
        throw new Error("The report returned an invalid reimbursement total.");
      }
      const count =
        result.factMap?.[`${status.key}!T`]?.aggregates?.[countIndex]?.value;
      if (!Number.isSafeInteger(count) || count < 0) {
        throw new Error("The report returned an invalid row count.");
      }
      maximum = Math.max(maximum, aggregate.value);
      minimum = Math.min(minimum, aggregate.value);
      const label = status.label || "(No Claim Status)";
      return {
        key: status.key,
        status: label,
        value: aggregate.value,
        amount: aggregate.label || String(aggregate.value),
        count,
        negative: aggregate.value < 0,
        ariaLabel: `${label}: ${aggregate.label || aggregate.value}. Show matching report rows across all accounts.`
      };
    });
    const magnitude = Math.max(maximum, Math.abs(minimum));
    const step = magnitude ? 10 ** Math.floor(Math.log10(magnitude)) : 1;
    this.axisMaximum =
      maximum > 0 ? Math.ceil(maximum / step) * step : minimum < 0 ? 0 : 1;
    this.axisMinimum =
      minimum < 0 ? -Math.ceil(Math.abs(minimum) / step) * step : 0;
    const range = this.axisMaximum - this.axisMinimum;
    const zero = (-this.axisMinimum / range) * 100;
    this.totalAmount = bars.reduce((sum, bar) => sum + bar.value, 0);
    this.totalRows = bars.reduce((sum, bar) => sum + bar.count, 0);
    this.chartBars = bars.map((bar) => ({
      ...bar,
      style: `bottom: ${bar.negative ? ((bar.value - this.axisMinimum) / range) * 100 : zero}%; height: ${(Math.abs(bar.value) / range) * 100}%;`,
      labelStyle: `bottom: ${((bar.value - this.axisMinimum) / range) * 100}%;`,
      labelClass: bar.negative ? "amount-label negative-label" : "amount-label"
    }));
    this.reportName = metadata.name || "Salesforce report";
  }

  handleBarClick(event) {
    const key = event.currentTarget.dataset.key;
    const selection = this.chartBars.find((bar) => bar.key === key);
    if (!selection) {
      this.errorMessage =
        "The selected bar is no longer available. Refresh the chart.";
      return;
    }
    this.selectedKey = key;
    this.detailHeading = `${selection.status} / All accounts`;
    this.loadReport("drilldown", selection);
  }

  handleAllRows() {
    this.selectedKey = "";
    this.detailHeading = "All report rows";
    this.loadReport("all");
  }

  get chartDisplayBars() {
    return this.chartBars.map((bar) => ({
      ...bar,
      selected: bar.key === this.selectedKey
    }));
  }

  get axisMinimumLabel() {
    return this.axisMinimum.toLocaleString();
  }

  get axisMaximumLabel() {
    return this.axisMaximum.toLocaleString();
  }

  get axisTicks() {
    const range = this.axisMaximum - this.axisMinimum;
    return Array.from({ length: 5 }, (_, index) => {
      const value = this.axisMinimum + (range * index) / 4;
      return {
        key: `tick-${index}`,
        label: this.formatAmount(value),
        style: `bottom: ${index * 25}%;`
      };
    });
  }

  get zeroLineStyle() {
    return `bottom: ${(-this.axisMinimum / (this.axisMaximum - this.axisMinimum)) * 100}%;`;
  }

  formatAmount(value) {
    return value.toLocaleString(undefined, {
      notation: "compact",
      maximumFractionDigits: 2
    });
  }

  get totalAmountLabel() {
    return this.formatAmount(this.totalAmount);
  }

  get totalRowsLabel() {
    return this.totalRows.toLocaleString();
  }

  get hasChart() {
    return this.chartBars.length > 0;
  }

  handleRefresh() {
    this.loadReport();
  }

  handlePrevious() {
    this.page = Math.max(1, this.page - 1);
  }

  handleNext() {
    this.page = Math.min(this.pageCount, this.page + 1);
  }

  get visibleRows() {
    return this.rows.slice((this.page - 1) * PAGE_SIZE, this.page * PAGE_SIZE);
  }

  get hasRows() {
    return this.rows.length > 0;
  }

  get pageCount() {
    return Math.max(1, Math.ceil(this.rows.length / PAGE_SIZE));
  }

  get previousDisabled() {
    return this.page <= 1;
  }

  get nextDisabled() {
    return this.page >= this.pageCount;
  }

  get pageSummary() {
    return `Page ${this.page} of ${this.pageCount} (${this.rows.length} returned rows)`;
  }
}