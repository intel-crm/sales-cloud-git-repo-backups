import { LightningElement } from 'lwc';
/*import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingLicenseList from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.getExistingLicenseList';
import processDistributionAction from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.processDistributionAction';
import createLicensedForRenewalFixed from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.createLicensedForRenewalFixed';
import restrictProcess from '@salesforce/label/c.Sales_DistyAction_RestrictProcessMsg';
import mismatchRowMsg from '@salesforce/label/c.Sales_DistyAction_MismatchRowMsg';
import invalidQty from '@salesforce/label/c.Sales_DistyAction_InvalidQtyMsg';
import noOfRowMsg from '@salesforce/label/c.Sales_DistyAction_NoOfSelectionMsg';
import processedMsg from '@salesforce/label/c.Sales_DistyAction_ProcessedMsg';
import salesLicErrHTML from '@salesforce/label/c.Sales_LicErr_HTML';
import salesRenewLicErr from '@salesforce/label/c.Sales_RenewLicErr';
import salesActiveMaintenanceErr from '@salesforce/label/c.Sales_ActiveMaintenanceErr';
import salesBaseLicErrMsg from '@salesforce/label/c.Sales_BaseLicErrMsg';
import { refreshApex } from '@salesforce/apex';
import Status from '@salesforce/schema/Case.Status';

const columns = [
	{
		label: 'License',
		fieldName: 'LicenseUrl',
		type: 'url',
		typeAttributes: {
			label: {
				fieldName: 'LicenseName'
			},
			target: '_blank'
		},
		sortable: true
	},
	{
		label: 'Product',
		fieldName: 'ProductUrl',
		type: 'url',
		typeAttributes: {
			label: {
				fieldName: 'ProductName'
			},
			target: '_blank'
		},
		sortable: true
	},
	{
		label: 'Maintenance Expiration',
		fieldName: 'Sales_License_Maintenance_Exp_Dt__c',
		type: 'date-local',
		sortable: true
	},
	{
		label: 'License Expiration',
		fieldName: 'Sales_License_Expiration_Date_Dt__c',
		type: 'date-local',
		sortable: true
	},
	{
		label: 'Primary Admin Contact',
		fieldName: 'PrimaryContactNameUrl',
		type: 'url',
		typeAttributes: {
			label: {
				fieldName: 'PrimaryContactName'
			},
			target: '_blank'
		},
		sortable: true
	},
	{
		label: '# Of Seats',
		fieldName: 'Sales_License_Quantity__c',
		type: 'number',
		sortable: true
	},
	{
		label: 'Available Quantity',
		fieldName: 'Sales_License_Avbl_Qty_Nbr__c',
		type: 'number',
		sortable: true
	},
	{
		label: 'License Activation Code',
		fieldName: 'Sales_License_Activation_Code__c',
		type: 'string',
		sortable: true
	},
	{
		label: 'Primary Computer Id',
		fieldName: 'HostUrl',
		type: 'url',
		typeAttributes: {
			label: {
				fieldName: 'HostName'
			},
			target: '_blank'
		},
		sortable: true
	},
	{
		label: 'License Type',
		fieldName: 'Sales_License_Type__c',
		type: 'string',
		sortable: true
	},
	{
		label: 'Web Display Flag',
		fieldName: 'Sales_License_Web_Display_Flag__c',
		type: 'boolean',
		sortable: true
	},
	{
		label: 'Processed',
		fieldName: 'Status',
		type: 'string',
		sortable: true,
		cellAttributes: {
			class: 'datatable-orange',
			iconName: { fieldName: 'iconName' }, iconPosition: 'right'
		},
	}
];*/

export default class Sales_ExistingFoundationLicenseView extends LightningElement {
	/*@track error;
	@api orderItemId;
	@api availableQuantityOfRenewal;
	@api licenseRowFromParent = {};
	@track distributedQuantity;
	@api toolLicenseType;
	@api result;
	@track data;
	@track licenseRow = {};
	@track modalContainer = false;
	@track rowsSelected = 0;
	@track totalAvailableQuantityOfOriginal = 0;
	@track preSelectedRows = [];
	@track allLicenseIds = [];
	@track processedLicIdList = [];
	@api isCorporate = false;
	@track showWarningMessage = false;
	@track showValidationMessage = false;
	@track validationMessage = '';
	@track showValidationForLessQuantity = false;
	@track showValidationForExpiredMessage = false;
	@track isLoaded = false;
	@track tempData = [];
	@track sortBy
	@track sortDirection

	licenses;
	columnsList = columns;
	label = {
		salesLicErrHTML,
		salesRenewLicErr,
		salesActiveMaintenanceErr,
		salesBaseLicErrMsg
	};
	connectedCallback() {
		if (this.licenseRowFromParent.availableQuanity < 0) {
			this.showWarningMessage = true;
		}
		this.distributedQuantity = this.availableQuantityOfRenewal;
	}

	@wire(getExistingLicenseList, {
		orderItemId: '$orderItemId',
		licenseType: '$licenseRowFromParent.licenseType'
	})
	wiredLicense(result) {
		console.log('Hii' + JSON.stringify(result));
		if (result.data) {
			this.licenses = result.data.licenseList;
			const isAddSeat = result.data.addSeatOrder;
			if (this.licenses.length == 0) {
				const selectEvent = new CustomEvent("hidebutton");
				this.dispatchEvent(selectEvent);
				if (isAddSeat != true) {
					console.log('Not In add seat');
					this.showValidationMessage = true;
					this.validationMessage = this.label.salesRenewLicErr;
				}
				else if (isAddSeat == true) {
					console.log('In add seat')
					this.showValidationForExpiredMessage = true;
					this.validationMessage = this.label.salesActiveMaintenanceErr;
				}
			}
			console.log('processed' + JSON.stringify(result.data.processedLicIdList));
			if (result.data.processedLicIdList) {
				this.processedLicIdList = result.data.processedLicIdList;
			}
			console.log('this.processedLicIdList' + this.processedLicIdList);
			let licList = [];
			this.licenses.forEach(row => {
				if (this.isCorporate) {
					if (row.Sales_License_Product__c != this.licenseRowFromParent.productId) {
						return;
					}
				}
				this.allLicenseIds.push(row.Id);
				let licenseObj = {
					...row
				};
				if (row.Sales_License_Product__c) {
					licenseObj.ProductName = row.Sales_License_Product__r.Name;
					licenseObj.ProductUrl = '/lightning/r/Product2/' + row.Sales_License_Product__c + '/view';
				}
				if (row.Id) {
					licenseObj.LicenseName = row.Name;
					licenseObj.LicenseUrl = '/lightning/r/Sales_License__c/' + row.Id + '/view';
				}
				if (row.Sales_License_Host_Node_Id__c) {
					licenseObj.HostName = row.Sales_License_Host_Node_Id__r.Name;
					licenseObj.HostUrl = '/lightning/r/Sales_Host__c/' + row.Sales_License_Host_Node_Id__c + '/view';
				}
				if (row.Sales_License_Primary_Admin_Contact__c) {
					licenseObj.PrimaryContactName = row.Sales_License_Primary_Admin_Contact__r.Name;
					licenseObj.PrimaryContactNameUrl = '/lightning/r/Contact/' + row.Sales_License_Primary_Admin_Contact__c + '/view';
				}
				if (!this.processedLicIdList.includes(row.Id)) {
					this.totalAvailableQuantityOfOriginal = this.totalAvailableQuantityOfOriginal + row.Sales_License_Quantity__c;
				}
				if (this.processedLicIdList.includes(row.Id)) {
					licenseObj.iconName = 'action:approval';
				}
				licList.push(licenseObj);
			})
			console.log('this.totalAvailableQuantityOfOriginal' + this.totalAvailableQuantityOfOriginal);
			console.log('this.availableQuantityOfRenewal' + this.availableQuantityOfRenewal);

			if (!this.showValidationMessage && !this.showValidationForExpiredMessage && !this.isCorporate && (this.totalAvailableQuantityOfOriginal < this.availableQuantityOfRenewal)) {
				this.showValidationForLessQuantity = true;
				this.validationMessage = this.label.salesBaseLicErrMsg;
			}

			console.log('this.toolLicenseType' + this.toolLicenseType);
			if ((/*this.toolLicenseType=='FIXED' && *//*this.totalAvailableQuantityOfOriginal < this.availableQuantityOfRenewal)) {
				console.log('this.allLicenseIds' + this.allLicenseIds);
				const toRemove = new Set([...this.processedLicIdList]);
				const difference = this.allLicenseIds.filter(x => !toRemove.has(x));
				console.log('difference' + difference);
				this.preSelectedRows = difference;


				if (this.toolLicenseType == 'FIXED') {
					const selectedEvent = new CustomEvent("showcreatelicense");
					this.dispatchEvent(selectedEvent);
				}

			}
			/*else if(this.toolLicenseType!='FIXED'){
					this.preSelectedRows=this.allLicenseIds;
			}*/
			/*this.data = licList;
			this.isLoaded = true;
			const selectedEvent = new CustomEvent("loadedevent");
			this.dispatchEvent(selectedEvent);
			this.error = undefined;
		} else if (result.error) {
			this.error = result.error;
			this.isLoaded = true;
			const selectedEvent = new CustomEvent("loadedevent");
			this.dispatchEvent(selectedEvent);
			this.data = undefined;
		}
		/*else{	
				console.log('inside this');
				const selectEvent = new CustomEvent("hidebutton");
				this.dispatchEvent(selectEvent);
				this.showValidationMessage=true;
		}*/
	/*}


	@api processLicense() {
		console.log('@@@' + this.isCorporate);
		if (!this.distributedQuantity) {
			return;
		}
		if (this.distributedQuantity < 1 || this.distributedQuantity > this.availableQuantityOfRenewal) {
			console.log('There');
			this.showNotification('Error', invalidQty, 'warning');
			return;
		}
		//if(this.isCorporate==true && (this.toolLicenseType=='FLOAT' || this.toolLicenseType=='NA' || this.toolLicenseType=='NEUTRAL') && (this.licenseRowFromParent.licenseType=='Renewal' || this.licenseRowFromParent.licenseType=='Amend')){
		if ((this.toolLicenseType == 'FLOAT' || this.toolLicenseType == 'NA' || this.toolLicenseType == 'NEUTRAL') && (this.licenseRowFromParent.licenseType == 'Renewal' || this.licenseRowFromParent.licenseType == 'Add Seat'
			|| this.licenseRowFromParent.licenseType == 'Amend Contract - Qty Decrease' || this.licenseRowFromParent.licenseType == 'Renew Contract - Qty Decrease')) {
			console.log('Inside this condition');
			let totalQuantityOfSelectedRows = 0;
			this.template.querySelector('lightning-datatable').getSelectedRows().forEach(row => {
				totalQuantityOfSelectedRows = totalQuantityOfSelectedRows + row.Sales_License_Quantity__c;
			})
			console.log('totalQuantityOfSelectedRows' + totalQuantityOfSelectedRows);
			if (totalQuantityOfSelectedRows != this.distributedQuantity) {
				console.log('Inside restriction');
				this.showNotification('Error', restrictProcess, 'warning');
				return;
			}

		}

		if (this.toolLicenseType == 'FIXED') {
			if (this.rowsSelected != this.distributedQuantity) {
				console.log('Here');
				this.showNotification('Error', mismatchRowMsg, 'warning');
				return;
			}
		}


		processDistributionAction({ distyQty: this.distributedQuantity, orderItemId: this.orderItemId, oldLicList: this.template.querySelector('lightning-datatable').getSelectedRows(), renewalLicId: this.licenseRowFromParent.licenseId })
			.then(result => {

				console.log('getselected row>>>' + this.template.querySelector('lightning-datatable').getSelectedRows());
				console.log('processedLicIdList>>>' + this.processedLicIdList);
				console.log('lic list>>>' + this.licenseRowFromParent.licenseId);
				this.showNotification('Success', processedMsg, 'success');

				const closeModalEvent = new CustomEvent("closemodalevent");
				this.dispatchEvent(closeModalEvent);
				return refreshApex(this.licenseRowFromParent);

			})
			.catch(error => {
				console.log('Error Occured:- ' + error);
			});
		console.log("Child LWC Component method invoked");
	}

	@api generateAndProcessLicense() {
		if (!this.distributedQuantity) {
			console.log('here');
			return;
		}
		if (this.distributedQuantity < 1 || this.distributedQuantity > this.availableQuantityOfRenewal) {
			this.showNotification('Error', invalidQty, 'warning');
			return;
		}
		createLicensedForRenewalFixed({ distyQty: this.distributedQuantity, orderItemId: this.orderItemId, oldLicList: this.template.querySelector('lightning-datatable').getSelectedRows(), renewalLicId: this.licenseRowFromParent.licenseId, quantityRollup: this.totalAvailableQuantityOfOriginal })
			.then(result => {
				this.showNotification('Success', processedMsg, 'success');
				const closeModalEvent = new CustomEvent("closemodalevent");
				this.dispatchEvent(closeModalEvent);
			})
			.catch(error => {
				console.log('Error Occured:- ' + error.body.message);
			});
		console.log("Child LWC Component method invoked");
	}

	quantityChange(event) {
		console.log('Quantity changed ' + event.target.value);
		this.distributedQuantity = event.target.value;
	}


	handleRowSelection = event => {

		if ((/*this.toolLicenseType==='FIXED' &&*/ /*this.totalAvailableQuantityOfOriginal < this.availableQuantityOfRenewal)) {
			console.log('1st');
			console.log('1st' + this.totalAvailableQuantityOfOriginal);
			console.log('1st' + this.availableQuantityOfRenewal);
			const selectedRowsByUser = this.template.querySelector('lightning-datatable').getSelectedRows();
			let selectedRowByUserIds = [];
			selectedRowsByUser.forEach(function (obj) { selectedRowByUserIds.push(obj.Id); });
			const toRemove = new Set([...this.processedLicIdList]);
			const difference = selectedRowByUserIds.filter(x => !toRemove.has(x));
			this.preSelectedRows = JSON.parse(JSON.stringify(difference));

			/*const tempPreselectedRows = this.preSelectedRows;
			this.preSelectedRows=JSON.parse(JSON.stringify(tempPreselectedRows));*/
		/*}
		if ((/*this.toolLicenseType==='FIXED' && *//*this.totalAvailableQuantityOfOriginal >= this.availableQuantityOfRenewal)) {
			console.log('2nd');
			const selectedRowsDetails = event.detail.selectedRows;
			let selectedRowIds = [];
			selectedRowsDetails.forEach(function (obj) { selectedRowIds.push(obj.Id); });
			const toRemove = new Set([...this.processedLicIdList]);
			const difference = selectedRowIds.filter(x => !toRemove.has(x));
			this.preSelectedRows = JSON.parse(JSON.stringify(difference));
		}
		else if (this.toolLicenseType !== 'FIXED' && this.allLicenseIds.length == 1) {
			console.log('3rd');
			this.preSelectedRows = JSON.parse(JSON.stringify(this.allLicenseIds));
		}

		let selectedRows = event.detail.selectedRows;
		this.rowsSelected = selectedRows.length;
		if (this.toolLicenseType === 'FIXED') {
			if (selectedRows.length > this.distributedQuantity) {
				let el = this.template.querySelector('lightning-datatable');
				//selectedRows=el.selectedRows=el.selectedRows.slice(this.distributedQuantity);
				this.showNotification('Error', noOfRowMsg, 'warning');
				event.preventDefault();
			}
		}

	}
	@api showNotification(title, msg, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
			mode: 'pester'
		});
		this.dispatchEvent(event);
	}

	handleSortData(event) {
		var fieldName = event.detail.Status;
    var sortDirection = event.detail.sortDirection;
    // assign the latest attribute with the sorted column fieldName and sorted direction
    this.sortedBy = fieldName;
    this.sortedDirection = sortDirection;
		console.log(event);
		this.sortData(event.detail.fieldName, event.detail.sortDirection);

	};
	sortData(fieldName, direction) {
		let parseData = JSON.parse(JSON.stringify(this.data));
		console.log(`parse data = ${parseData}`);
		let keyvalue = (a) => {
			return a[fieldName];
		};
		let isReverse = direction === 'asc' ? 1 : -1;
		//sort data
		parseData.sort((x, y) => {
			x = keyvalue(x) ? keyvalue(x) : '';
			y = keyvalue(y) ? keyvalue(y) : '';

			return isReverse * ((x > y) - (y > x));
		});
		this.data = parseData;

	}

	onchangeHandle(event) {
		//this.finaldata=this.data;
		if (
			this.tempData == null ||
			this.tempData == undefined ||
			(this.tempData != null && this.tempData.length == 0)
		) {
			this.tempData = this.data;
			this.final = this.data;

		}
		this.dataReturn = [];
		this.selectedValue = event.target.value;
		console.log('textboxvalue' + this.selectedValue);
		let currentList = this.tempData;
		let currentList1 = this.tempData;
		if (
			this.selectedValue.length > 0 &&
			this.selectedValue !== undefined &&
			this.selectedValue !== null
		) {
			let concat = "";
			let concat1 = "";
			let cnt = 0;
			for (let index = 0; index < currentList.length; index++) {
				if (currentList[index].Name != null) {

					concat += currentList[index].Name;
					//console.log('concatenated String :'+concat);
					if (concat != null && concat != "" && concat != undefined) {
						concat = concat.toString().toLowerCase() + "" + index;
					}
					console.log("onchangeHandle 2 " + concat);
					console.log("onchangeHandle 4 " + this.selectedValue.toLowerCase());
					console.log(concat);
					if (concat.includes(this.selectedValue.toLowerCase())) {
						//this.isDataAvailable = true;
						console.log("found :" + index);
						this.dataReturn.push(currentList[index]);
						//  cnt++;
					}
				}
				concat = null;
			}
			
			if (this.dataReturn.length <= 0) {
				//this.isDataAvailable = false;
			}
		}/*else
                {
                        this.loadTableRecords();
                }*/
		/*if (this.selectedValue.length === 0) {
			//this.loadTableRecords();
			//this.isDataAvailable = true;
			this.data = this.final;
			console.log(
				"final array " +
				JSON.stringify(this.data)
			);
			//this.loadTableRecords();
		}
		else {
			this.data = this.dataReturn;
		}
	}*/
}