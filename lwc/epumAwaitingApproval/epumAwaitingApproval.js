import { LightningElement, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
//import CustomLabel from "c/customLabel";
//
import EPUMRedirectLink from "@salesforce/label/c.PRM_EPUM_Redirect_Link";
import IPAEntitlementMap from "@salesforce/label/c.IPAEntitlementMap";
import PRM_ResponsibilityEntitlementMapping from "@salesforce/label/c.PRM_ResponsibilityEntitlementMapping";
import PRM_Responsibilities_Header from "@salesforce/label/c.PRM_Responsibilities_Header";
import PRM_You from "@salesforce/label/c.PRM_You";
import PRM_Manage_Personnel from "@salesforce/label/c.PRM_Manage_Personnel";
import PRM_Company_Personnel from "@salesforce/label/c.PRM_Company_Personnel";
import PRM_Grid_Header_Name from "@salesforce/label/c.PRM_Grid_Header_Name";
import PRM_Grid_Header_Email from "@salesforce/label/c.PRM_Grid_Header_Email";
import PRM_Grid_Header_Responsibility from "@salesforce/label/c.PRM_Grid_Header_Responsibility";
import PRM_Grid_Header_Status from "@salesforce/label/c.PRM_Grid_Header_Status";
import PRM_Pending_Action_Icon from "@salesforce/label/c.PRM_Pending_Action_Icon";
import PRM_SearchNameEmailStatus from "@salesforce/label/c.PRM_SearchNameEmailStatus";

//
import getMyCompanyContacts from "@salesforce/apex/PRM_CompanyProfileController.getMyCompanyContacts";
export default class EpumAwaitingApproval extends LightningElement {
	@track ldtData;
	error;
	rowCount;
	isLoading = false;
	sortBy;
	sortDirection;
	loggedInUserResp = [];
	isPrimary;
	@track pageSize;
	formLabels = {
		PRM_Responsibilities_Header,
		PRM_You,
		PRM_Manage_Personnel,
		PRM_Company_Personnel,
		PRM_Grid_Header_Name,
		PRM_Grid_Header_Email,
		PRM_Grid_Header_Responsibility,
		PRM_Grid_Header_Status,
		PRM_Pending_Action_Icon,
		EPUMRedirectLink,
		IPAEntitlementMap,
		PRM_ResponsibilityEntitlementMapping,
		PRM_SearchNameEmailStatus
	};

	columns = [
		{ label: this.formLabels.PRM_Grid_Header_Name, fieldName: "Name", type: "text", sortable: "true", cellAttributes: { class: "dataRowFont" } },
		{ label: this.formLabels.PRM_Grid_Header_Email, fieldName: "Email", type: "text" },
		{ label: this.formLabels.PRM_Grid_Header_Responsibility, fieldName: "Responsibilities", type: "text" },
		{ label: this.formLabels.PRM_Grid_Header_Status, fieldName: "Status", type: "helptext", sortable: "true" }
	];
	epumURL = this.formLabels.EPUMRedirectLink;

	//-Pagintation
	@track showTable = false; //Used to render table after we get the data from apex controller
	@track recordsToDisplay = []; //Records to be displayed on the page
	@track rowNumberOffset; //Row number
	dataParse = [];

	companyContactData;
	@wire(getMyCompanyContacts)
	myCompanyContacts(result) {
		this.companyContactData = result;
		if (result.data) {
			var response = JSON.parse(result.data);
			var loggedInUserData = response.filter((data) => {
				return data.isLoggedinUser == true;
			});
			if (!loggedInUserData[0].isPrimary) {
				this.dataParse = response.filter((data) => {
					return data.isLoggedinUser == true;
				});
				this.dataParse = formatDataforResponsibility(this.dataParse);
			}
			else{
				this.dataParse = formatDataforResponsibility(JSON.parse(result.data));
			}

			this.sortData("Status", "desc");
			
			
			this.loggedInUserResp = [];

			let res = [];
			if (loggedInUserData[0].Responsibilities !== undefined && loggedInUserData[0].Responsibilities !== null) {
				res = loggedInUserData[0].Responsibilities.split(", ");
			}
			if (res.length > 0) {
				getEntitlementforDisplay(getEntitlementObj(this.formLabels.IPAEntitlementMap), res).forEach((elem) => {
					this.loggedInUserResp.push(elem);
				});
			}
			this.isPrimary = loggedInUserData[0].isPrimary;
			

			this.companyContactCount = Object.keys(this.ldtData).length;
			this.isLoading = false;
			//For pagination
			this.showTable = true;
		} else if (result.error) {
			this.error = result.error;
			this.isLoading = false;
			console.log("error - " + JSON.stringify(result.error));
		}
	}

	doSorting(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		if (this.isPrimary) this.sortData(this.sortBy, this.sortDirection);
	}
	sortData(fieldname, direction) {
		let parseData = this.dataParse;
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
			paginator.setRecordData(parseData, null, this.pageSize);
		}
	}
	onRefreshResponsibilityData() {
		return refreshApex(this.companyContactData);
	}
	get displayScrollBar() {
		return this.companyContactCount >= 5 ? "slds-scrollable_y" : "";
	}
	navigateToEPUM() {
		window.open(this.epumURL, "_self");
	}
	//Pagination
	//Capture the event fired from the paginator component
	handlePaginatorChange(event) {
		let paginatorFooter = this.template.querySelector("c-pagination-grid-footer");
		this.pageSize = event.detail.pageSize;
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
function getEntitlementforDisplay(a, b) {
	var displayEntitlement = [];
	var datatoPush = [];
	a.forEach((elementMAp) => {
		b.forEach((element) => {
			if (elementMAp.Name == element) {
				var obj = {};
				obj.Rank = elementMAp.Rank;
				obj.Name = element;
				obj.Description = elementMAp.Description;
				displayEntitlement.push(obj);
			}
		});
	});
	displayEntitlement.sort(function (x, y) {
		return x["Rank"] - y["Rank"];
	});
	if (displayEntitlement.length >= 1) {
		displayEntitlement = [{ Rank: displayEntitlement[0].Rank, Name: displayEntitlement[0].Name, Description: displayEntitlement[0].Description }];
		return displayEntitlement;
	}else{
		return displayEntitlement;
	}
}
function getEntitlementObj(val) {
	let newJson = val.replace(/([a-zA-Z0-9]+?):/g, '"$1":');
	newJson = newJson.replace(/'/g, '"');
	return JSON.parse(newJson);
}

function formatDataforResponsibility(data) {
	data.forEach((element) => {
		if (element.Responsibilities) {
			element.Responsibilities = filterData(getEntitlementObj(PRM_ResponsibilityEntitlementMapping), element.Responsibilities.split(", "));
		}
	});
	return data;
}
function filterData(p, q) {
	const responsibility = [];
	const result = p.filter((m) => q.includes(m.Value));
	result.sort(function (x, y) {
		return x["Rank"] - y["Rank"];
	});
	result.forEach((el) => {
		responsibility.push(el.Value);
	});
	return responsibility.join(", ");
}