import { LightningElement, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getMyCompanySecondaryContacts from "@salesforce/apex/EPUM_SearchContact.getMyCompanySecContForEPUM";
import updateFlag from "@salesforce/apex/PRM_CompanyProfileController.updateFlag";
//import CustomLabel from "c/customLabel";
//
import PRM_Grid_Header_Name from "@salesforce/label/c.PRM_Grid_Header_Name";
import PRM_Grid_Header_Email from "@salesforce/label/c.PRM_Grid_Header_Email";
import PRM_Grid_Header_EV_Date from "@salesforce/label/c.PRM_Grid_Header_EV_Date";
import PRM_Grid_Header_ApproveReject from "@salesforce/label/c.PRM_Grid_Header_ApproveReject";
import PRM_Contacts_Awaiting_Approval from "@salesforce/label/c.PRM_Contacts_Awaiting_Approval";
import PRM_Registration_Req_Approved from "@salesforce/label/c.PRM_Registration_Req_Approved";
import PRM_Req_Success from "@salesforce/label/c.PRM_Req_Success";
import PRM_Req_Failure from "@salesforce/label/c.PRM_Req_Failure";
import PRM_Reject_Message_Fail from "@salesforce/label/c.PRM_Reject_Message_Fail";
import PRM_Reg_Request_Reject_Message from "@salesforce/label/c.PRM_Reg_Request_Reject_Message";
import PRM_Reg_Reject_Message_Fail from "@salesforce/label/c.PRM_Reg_Reject_Message_Fail";
import PRM_SearchNameEmail from "@salesforce/label/c.PRM_SearchNameEmail";
//
export default class CompanyProfileDataGridEpum extends LightningElement {
	ldtData;
	rowCount;
	companyContactCount;
	error;
	@track isLoading = true;
	@track sortBy;
	@track sortDirection;
	@track openmodel;
	@track registrationObj = {};
	@track pageSize;
	@track searchText;
	@track formLabels = {
		PRM_Grid_Header_Name,
		PRM_Grid_Header_Email,
		PRM_Grid_Header_EV_Date,
		PRM_Grid_Header_ApproveReject,
		PRM_Contacts_Awaiting_Approval,
		PRM_Registration_Req_Approved,
		PRM_Req_Success,
		PRM_Req_Failure,
		PRM_Reg_Request_Reject_Message,
		PRM_Reg_Reject_Message_Fail,
		PRM_Reject_Message_Fail,
		PRM_SearchNameEmail
	};
	//-Pagintation
	@track showTable = false; //Used to render table after we get the data from apex controller
	@track recordsToDisplay = []; //Records to be displayed on the page
	@track rowNumberOffset; //Row number

	columns = [
		{ label: this.formLabels.PRM_Grid_Header_Name, fieldName: "Name", type: "text", sortable: "true" },
		{ label: this.formLabels.PRM_Grid_Header_Email, fieldName: "Email", type: "text", sortable: "true" },
		{
			label: this.formLabels.PRM_Grid_Header_EV_Date,
			fieldName: "EVVerificationDateTime",
			type: "date",
			class: "slds-border_right"
		},
		{
			type: "button",
			label: this.formLabels.PRM_Grid_Header_ApproveReject,
			fieldName: "ApproveReject"
		}
	];
	datafromAPI;
	dataParse;
	@wire(getMyCompanySecondaryContacts)
	myCompanySecondaryContacts(result) {
		this.datafromAPI = result;
		if (result.data) {
			this.dataParse = JSON.parse(result.data);
			this.sortData("Name", "asc");
			this.rowCount = Object.keys(this.ldtData).length > 0 ? true : false;
			this.companyContactCount = Object.keys(this.ldtData).length;
			this.isLoading = false;
			//For pagination
			this.showTable = true;
		} else if (result.error) {
			this.error = error;
			console.log("error - " + error);
		}
	}
	approveHandler(event) {
		//alert(event.detail.action.name);
		console.log("1- " + event.target.value);
		//console.log('1- '+event.detail.action.value);
		const id = event.target.value;
		alert(id);
	}

	doSorting(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData(this.sortBy, this.sortDirection);
	}
	sortData(fieldname, direction) {
		let parseData = JSON.parse(JSON.stringify(this.dataParse));
		// Return the value stored in the field
		let keyValue = (a) => {
			return a[fieldname];
		};
		// cheking reverse direction
		let isReverse = direction === "asc" ? 1 : -1;
		// sorting data
		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : ""; // handling null values
			y = keyValue(y) ? keyValue(y) : "";
			// sorting values based on direction
			return isReverse * ((x.toLowerCase() > y.toLowerCase()) - (y.toLowerCase() > x.toLowerCase()));
		});
		this.ldtData = parseData;
		let paginator = this.template.querySelector("c-pagination-grid-footer");
		if (paginator) {
			paginator.setRecordData(parseData, this.searchText, this.pageSize);
		}
	}
	handleRowAction(event) {
		let recordId = event.detail.recordId;
		let eventName = event.detail.name;
		if (eventName === "approve") {
			this.isLoading = true;
			updateFlag({
				recordId: recordId,
				flag: "Approve"
			})
				.then((result) => {
					this.showToast(this.formLabels.PRM_Req_Success, this.formLabels.PRM_Registration_Req_Approved, "success");
					const updateResponsibility = new CustomEvent("updateresponsibility");
					// Dispatches the event.
					this.dispatchEvent(updateResponsibility);
					return refreshApex(this.datafromAPI);
				})
				.catch((error) => {
					this.isLoading = false;
					console.log("error: " + error);
					this.showToast(this.formLabels.PRM_Req_Failure, this.formLabels.PRM_Reject_Message_Fail, "error");
				});
		} else if (eventName === "reject") {
			this.openmodel = true;
			this.registrationObj = event.detail.reqObj;
			console.log("openmodel", this.openmodel);
		}
	}

	onRejectHandler(event) {
		this.openmodel = false;
		this.isLoading = true;
		updateFlag({
			recordId: event.detail,
			flag: "Reject"
		})
			.then((result) => {
				this.showToast(this.formLabels.PRM_Req_Success, this.formLabels.PRM_Reg_Request_Reject_Message, "success");
				return refreshApex(this.datafromAPI);
			})
			.catch((error) => {
				console.log("THis is the error: " + error);
				this.isLoading = false;
				this.showToast(this.formLabels.PRM_Req_Failure, this, this.formLabels.PRM_Reg_Reject_Message_Fail, "error");
			});
	}
	onCancelHandler(event) {
		this.openmodel = event.detail;
	}
	showToast = (title, message, variant) => {
		const evt = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: "dismissible"
		});
		this.dispatchEvent(evt);
	};
	get displayScrollBar() {
		return this.companyContactCount >= 5 ? "slds-scrollable_y" : "";
	}
	//Pagination
	//Capture the event fired from the paginator component
	handlePaginatorChange(event) {
		let paginatorFooter = this.template.querySelector("c-pagination-grid-footer");
		this.pageSize = event.detail.pageSize;
		this.searchText = event.detail.search;
		if (paginatorFooter) {
			paginatorFooter.setRecordData(this.dataParse, event.detail.search, this.pageSize);
		}
	}

	handlePaginatorChangeFooter(event) {
		this.recordsToDisplay = event.detail.rec;
		if (event.detail.rec.length > 0) {
			this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
		}
	}
}