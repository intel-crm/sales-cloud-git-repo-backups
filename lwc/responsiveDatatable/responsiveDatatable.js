import { LightningElement, api, track } from "lwc";
import PRM_You from "@salesforce/label/c.PRM_You";
import PRM_Pending_Action_Icon from "@salesforce/label/c.PRM_Pending_Action_Icon";
import PRM_Approve from "@salesforce/label/c.PRM_Approve";
import PRM_Reject from "@salesforce/label/c.PRM_Reject";
import PRM_LA_No_Data from "@salesforce/label/c.PRM_LA_No_Data";
export default class ResponsiveDatatable extends LightningElement {
	@api columnConfig;
	@api pkField;
	@track rows;
	showNorecord = true;
	_selectedRow;
	direction = "";
	arrowSelection = true;
	formLabels = { PRM_You, PRM_Pending_Action_Icon, PRM_Approve, PRM_Reject, PRM_LA_No_Data };
	reformatRows = function (rowData) {
		let colItems = this.columnConfig;
		let reformattedRows = [];

		for (let i = 0; i < rowData.length; i++) {
			let rowDataItems = [];
			for (let j = 0; j < colItems.length; j++) {
				let colClass = "";
				if (colItems[j].hiddenOnMobile) {
					colClass = "hiddenOnMobile";
				}
				rowDataItems.push({
					value: rowData[i][colItems[j].fieldName],
					label: colItems[j].label,
					type: colItems[j].type,
					class: colClass,
					columnId: "col" + j + "-" + rowData[i][this.pkField],
					isPhone: colItems[j].type === "phone",
					isEmail: colItems[j].type === "email",
					isOther: colItems[j].type !== "phone" && colItems[j].type !== "email" && colItems[j].type !== "button" && colItems[j].type !== "date",
					showHelpText: rowData[i][colItems[j].fieldName] === "Pending Action",
					isButton: colItems[j].type === "button",
					isDate: colItems[j].type === "date",
					isApproveDisabled: colItems[j].type === "button" && rowData[i][colItems[j - 1].fieldName] === null,
					isCurrentUser: rowData[i][colItems[j].fieldName] != null ? rowData[i][colItems[j].fieldName].includes("(" + this.formLabels.PRM_You + ")") : false
				});
			}
			reformattedRows.push({
				data: rowDataItems,
				pk: rowData[i][this.pkField],
				addCurrentUserCss: rowDataItems[0].isCurrentUser ? "addCurrentUserCss" : "customWrap"
			});
		}
		return reformattedRows;
	};
	@api setSelectedRecord(recordId) {
		let mySelector = `tr[data-pk='${recordId}']`;
		let selectedRow = this.template.querySelector(mySelector);
		if (selectedRow) {
			this.highlightSelectedRow(selectedRow);
		}
	}

	onRowClick(event) {
		let target = event.currentTarget;
		this.highlightSelectedRow(target);
	}
	onHeaderClick(event) {
		let target = event.currentTarget;
		if (this.direction === "") {
			this.direction = "asc";
			this.arrowSelection = true;
		} else if (this.direction === "asc") {
			this.direction = "desc";
			this.arrowSelection = false;
		} else {
			this.direction = "asc";
			this.arrowSelection = true;
		}
		const evt = new CustomEvent("headerclick", {
			detail: {
				fieldName: target.getAttribute("data-header"),
				sortDirection: this.direction
			}
		});
		this.dispatchEvent(evt);
	}
	highlightSelectedRow(target) {
		if (this._selectedRow) {
			this._selectedRow.classList.remove("slds-is-selected");
		}
		target.classList.add("slds-is-selected");
		this._selectedRow = target;
	}

	approveHandler(event) {
		let target = event.currentTarget;
		const evt = new CustomEvent("approve", {
			detail: {
				recordId: target.getAttribute("data-reqid"),
				name: "approve"
			}
		});
		this.dispatchEvent(evt);
	}

	rejectHandler(event) {
		let target = event.currentTarget;
		const evt = new CustomEvent("reject", {
			detail: {
				recordId: target.getAttribute("data-reqid"),
				name: "reject",
				reqObj: {
					RecordId: target.getAttribute("data-reqid"),
					Name: target.getAttribute("data-name")
				}
			}
		});
		this.dispatchEvent(evt);
	}

	@api
	get rowData() {
		return this.rows;
	}
	set rowData(value) {
		if (typeof value !== "undefined") {
			this.rows = this.reformatRows(value);
			if (this.rows.length <= 0) this.showNorecord = false;
			else this.showNorecord = true;
		}
	}
}