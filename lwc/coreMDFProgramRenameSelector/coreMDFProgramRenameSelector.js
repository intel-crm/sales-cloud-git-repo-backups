import { LightningElement, api } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";

const MAX_SELECTION_COUNT = 45;

const PREVIEW_COLUMNS = [
  { label: "Metadata Type", fieldName: "metadataType", type: "text" },
  { label: "Component", fieldName: "fullName", type: "text", wrapText: true },
  { label: "Object", fieldName: "objectName", type: "text" },
  { label: "Replacement Count", fieldName: "replacementCount", type: "number" },
  {
    label: "Current Values",
    fieldName: "currentValue",
    type: "text",
    wrapText: true
  },
  {
    label: "Proposed Values",
    fieldName: "proposedValue",
    type: "text",
    wrapText: true
  }
];

const RESULT_COLUMNS = [
  ...PREVIEW_COLUMNS,
  { label: "Status", fieldName: "status", type: "text" },
  {
    label: "Result Details",
    fieldName: "message",
    type: "text",
    wrapText: true
  }
];

const OCCURRENCE_COLUMNS = [
  { label: "Metadata Type", fieldName: "metadataType", type: "text" },
  { label: "Component", fieldName: "fullName", type: "text", wrapText: true },
  { label: "Object", fieldName: "objectName", type: "text" },
  {
    label: "Metadata Path",
    fieldName: "metadataPath",
    type: "text",
    wrapText: true
  },
  { label: "Match Count", fieldName: "matchCount", type: "number" },
  {
    label: "Current Value",
    fieldName: "currentValue",
    type: "text",
    wrapText: true
  },
  {
    label: "Proposed Value",
    fieldName: "proposedValue",
    type: "text",
    wrapText: true
  }
];

const CSV_HEADERS = [
  "Current Program Name",
  "New Program Name",
  "Metadata Type",
  "Component",
  "Object",
  "Metadata Path",
  "Match Count",
  "Current Value",
  "Proposed Value"
];

const escapeCsvCell = (value) => {
  let cell = value === null || value === undefined ? "" : String(value);
  if (/^[\t\r\n ]*[=+\-@]/.test(cell)) {
    cell = `'${cell}`;
  }
  return `"${cell.replace(/"/g, '""')}"`;
};

export default class CoreMDFProgramRenameSelector extends LightningElement {
  _items = [];
  _selectedItems = [];
  _occurrences = [];
  _readOnly = false;
  validationMessage = "";

  @api errorMessage;

  @api
  get items() {
    return this._items;
  }

  set items(value) {
    this._items = Array.isArray(value) ? value : [];
  }

  @api
  get occurrences() {
    return this._occurrences;
  }

  set occurrences(value) {
    this._occurrences = Array.isArray(value) ? value : [];
  }

  @api
  get selectedItems() {
    return this._selectedItems;
  }

  set selectedItems(value) {
    this._selectedItems = Array.isArray(value) ? value : [];
  }

  @api
  get readOnly() {
    return this._readOnly;
  }

  set readOnly(value) {
    this._readOnly = value === true || value === "true";
  }

  get columns() {
    return this.readOnly ? RESULT_COLUMNS : PREVIEW_COLUMNS;
  }

  get hasItems() {
    return this.items.length > 0;
  }

  get title() {
    return this.readOnly ? "Update results" : "Matching metadata components";
  }

  get tableLabel() {
    return this.readOnly
      ? "Program rename update results"
      : "Select components to update";
  }

  get isSelectable() {
    return !this.readOnly;
  }

  get selectedCount() {
    return this._selectedItems.length;
  }

  get occurrenceColumns() {
    return OCCURRENCE_COLUMNS;
  }

  get isExportDisabled() {
    if (this._selectedItems.length === 0) {
      return true;
    }
    const selectedRecordIds = new Set(
      this._selectedItems.map((item) => item.recordId)
    );
    return !this._occurrences.some((occurrence) =>
      selectedRecordIds.has(occurrence.recordId)
    );
  }

  get maxRowSelection() {
    return MAX_SELECTION_COUNT;
  }

  get selectedRecordIds() {
    return this._selectedItems.map((item) => item.recordId);
  }

  handleRowSelection(event) {
    this._selectedItems = event.detail.selectedRows;
    this.validationMessage = "";
    this.dispatchEvent(
      new FlowAttributeChangeEvent("selectedItems", this._selectedItems)
    );
  }

  handleExport() {
    const selectedRecordIds = new Set(
      this._selectedItems.map((item) => item.recordId)
    );
    const selectedRows = this._occurrences.filter((occurrence) =>
      selectedRecordIds.has(occurrence.recordId)
    );
    const csvRows = [
      CSV_HEADERS,
      ...selectedRows.map((row) => [
        row.oldProgramName,
        row.newProgramName,
        row.metadataType,
        row.fullName,
        row.objectName,
        row.metadataPath,
        row.matchCount,
        row.currentValue,
        row.proposedValue
      ])
    ];
    const csv = csvRows
      .map((row) => row.map(escapeCsvCell).join(","))
      .join("\r\n");
    const downloadLink = this.template.querySelector(
      '[data-id="downloadLink"]'
    );
    downloadLink.href =
      "data:text/csv;charset=utf-8," +
      encodeURIComponent("\uFEFF" + csv);
    downloadLink.click();
  }

  @api
  validate() {
    if (!this.readOnly && this._selectedItems.length > MAX_SELECTION_COUNT) {
      return {
        isValid: false,
        errorMessage: `Select no more than ${MAX_SELECTION_COUNT} components per submission.`
      };
    }
    if (!this.readOnly && this._selectedItems.length === 0) {
      return {
        isValid: false,
        errorMessage: "Select at least one component before continuing."
      };
    }
    return { isValid: true };
  }

  @api
  setCustomValidity(message) {
    this.validationMessage = message || "";
  }

  @api
  reportValidity() {
    if (!this.readOnly && this._selectedItems.length > MAX_SELECTION_COUNT) {
      this.validationMessage = `Select no more than ${MAX_SELECTION_COUNT} components per submission.`;
    } else if (!this.readOnly && this._selectedItems.length === 0) {
      this.validationMessage =
        "Select at least one component before continuing.";
    }
  }
}