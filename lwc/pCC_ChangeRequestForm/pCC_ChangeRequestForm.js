import { LightningElement, track, api, wire } from 'lwc';
import opportunityDetails from '@salesforce/apex/PCC_ChangeRequest.getRecords';
import createCR from '@salesforce/apex/PCC_ChangeRequest.createChangeRequest';
import createCRLI from '@salesforce/apex/PCC_ChangeRequest.createChangeRequestLine';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getColumns from '@salesforce/apex/PCC_ChangeRequest.getColumns';
import { refreshApex } from '@salesforce/apex';
import LightningPrompt from 'lightning/prompt';
import getOpenChangeRequest from '@salesforce/apex/PCC_ChangeRequest.getExistingChangeRequest';
import { loadStyle } from 'lightning/platformResourceLoader'
import editableColumnsHighlighterCSS from '@salesforce/resourceUrl/PCC_ChangeRequestFormCSS';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import getProductsIds from '@salesforce/apex/PCC_ChangeRequest.getProductsIds';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DEAL_PRODUCT_OBJECT from "@salesforce/schema/Core_Design_Registration_Product__c";


export default class PCC_ChangeRequestForm extends NavigationMixin(LightningElement) {

	@api recordId;
	@track columns = [];
	@track data = [];
	@track opportunity = {};
	@track opportunitySelected = false;
	@track uploadedFiles = [];
	editProduct = {};
	@track rowErrorMessages = {};
	@track errors = {};
	@track createRecord = false;
	@track opportunityId;
	@track closeDate;
	@track changeRequest = {};
	@track productChanged = false;
	@track documentIdObj = [];
	@track customColumns = [];
	@track myRecordId = '';

	@track showForm = false;
	@track editModel = true;
	@track selectedProducts = [];
	@track selectedRows;
	@track loaded = false;

	hidecheckboxColumns = true;
	tableErrors = {};
	oldChangeRequestExists = false;

	cssLoaded = false;
	newlyAddedProducts = [];
	newProductScreenCols = [];
	index;
	isFirstLoaded = true;
	designRegId;
	@track errormessages = [];

	@track cancelProductBtnLabel = 'Cancel Products';
	@track changeBtnLable = 'Edit Products';

	@track ownerId;
	// DR and Deal Product, Competitor product Name

	get hideButtons() {
		return this.errormessages.length > 0 ? true : false;
	}

	drName;
	dealProductName;
	competitorProductName;

	@track disableActions = false;

	renderedCallback() {
		if (this.cssLoaded) return;
		this.cssLoaded = true;
		loadStyle(this, editableColumnsHighlighterCSS);
	}

	//add new product

	async handleNewProduct() {
		this.createRecord = true;
	}


	get showButtons() {
		console.log('Val -->', (this.editedProducts.length > 0 || this.newlyAddedProducts.length > 0));

		return (this.editedProducts.length > 0 || this.newlyAddedProducts.length > 0) ? true : false;
	}

	get getEditButtonValue() {
		return this.oldChangeRequestExists || this.errormessages.length > 0 ? true : this.data.length > 0 ? false : true;
	}


	get editProducts() {
		return (this.editedProducts.length > 0) ? true : false;
	}

	get previewScreenColumns() {
		return this.columns.filter(item => item.fieldName !== 'Cancel');
	}

	get getDataTableHeight() {
		if (this.data.length > 3) {
			return "readonlyMaxHeight slds-box";
		} else {
			return "readonlyAutoHeight slds-box";
		}
	}

	get getTableClass() {
		if (this.editedProducts.length > 3) {
			return "readonlyMaxHeight slds-box";
		} else {
			return "readonlyAutoHeight slds-box";
		}
	}

	get getNewlyAddedProducts() {
		return this.newlyAddedProducts;
	}

	closePopup() {
		// document.body.style.zoom = '80%'
		window.scrollTo(0, 0);
		this.showForm = false;
	}

	get enablePopUpSaveCancel() {
		console.log(this.data.filter(item => item.isChanged).length);
		return this.data.filter(item => item.isChanged && (item.CoreQLAdditionalCommentsTxt != null || item.CoreQLEndDt != null || item.CoreQLStartDt != null || item.Quantity > 0)).length > 0 ? false : true;
	}

	get editedProducts() {
		console.log(this.data.filter(item => item.isChanged));
		return this.data.filter(item => item.isChanged && (item.CoreQLAdditionalCommentsTxt != null || item.CoreQLEndDt != null || item.CoreQLStartDt != null || item.Quantity > 0));
	}

	get disableButtons() {
		// return !this.productChanged ? true : false;
		return (this.editedProducts.length > 0 || this.newlyAddedProducts.length > 0) && !this.disableActions ? false : true;
	}



	get acceptedFormats() {
		return ['.pdf', '.png'];
	}

	get newProducts() {
		return this.newlyAddedProducts.length > 0 ? true : false;
	}

	recordTypeId;
	@wire(getObjectInfo, { objectApiName: DEAL_PRODUCT_OBJECT })
	Function({ error, data }) {
		if (data) {
			let objArray = data.recordTypeInfos;
			for (let i in objArray) {
				if (objArray[i].name === "Deal Registration Product - Partner") {
					this.recordTypeId = objArray[i].recordTypeId;
					console.log('recordTypeId -->', this.recordTypeId);
				}

			}
		} else if (error) {
			console.log(JSON.stringify(error))
			// perform your logic related to error 
		}
	}

	// handle to update newly added products
	async handleNewProductRowAction(evt) {
		console.log('new prd event -->', evt.detail.row.id);
		if (evt.detail.action.name == 'edit') {
			console.log('Row Id ==>', this.newlyAddedProducts.indexOf(evt.detail.row));
			this.editProduct = evt.detail.row;
			this.index = this.newlyAddedProducts.indexOf(evt.detail.row);
			this.createRecord = true;


		} else {
			const result = await LightningConfirm.open({
				message: 'Once record is deleted cannot be recovered, please lick OK to confirm.',
				variant: 'warning',
				label: 'Warning!',
				// setting theme would have no effect
			});

			if (result) {
				this.newlyAddedProducts = this.newlyAddedProducts.filter((_, i) => i !== this.newlyAddedProducts.indexOf(evt.detail.row));
			} else {
				return;
			}
		}
		console.log('newlyAddedProducts -->', this.newlyAddedProducts);


	}

	// read record from child component
	handleIncomingRecord(event) {
		console.log('event.detail', event.detail);

		this.newProductScreenCols = event.detail.columns;
		let rowIndex = event.detail.index;
		this.drName = event.detail.drName;
		this.dealProductName = event.detail.productName;
		this.competitorProductName = event.detail.competitorProdName;
		if (rowIndex !== null && rowIndex !== undefined && rowIndex !== '' && rowIndex >= 0) {
			this.newlyAddedProducts[rowIndex] = event.detail.data;
			rowIndex = '';
			this.editProduct = {};
		} else {
			this.newlyAddedProducts.push(event.detail.data);
		}

		console.log('new -->', this.newlyAddedProducts);

	}

	// Get columns from custom setting
	@wire(getColumns, { url: JSON.stringify(window.location.origin) })
	wiredColumns({ data, error }) {
		if (data) {
			data.map(col => {
				if (col.Enable_on_Partner_Screen__c) {
					this.customColumns.push(this.createColumns(col));
				}
			});
			this.columns = this.customColumns;
			console.log('columns -->', this.columns);
		} else if (error) {
			console.error(error);
		}
	}

	fetchPendingChangeRequest() {
		getOpenChangeRequest({ opportunityId: this.recordId })
			.then(result => {
				if (result !== null && result !== undefined && result.length > 0) {
					console.log('result -->', result);

					this.oldChangeRequestExists = true;
					this.pendingChangeRequest = result[0].Name;
					if (this.oldChangeRequestExists) {
						this.errormessages.push(`A pending Change Request ${this.pendingChangeRequest} already exists. A new change request cannot be created until the pending request is approved or rejected`);
					}

				}
			})
			.catch(error => {
				console.log('Error -->', error);
			})
	}

	// Handles the saving of the form as a draft
	handleSaveasDraft() {
		this.showForm = false;
		this.hidecheckboxColumns = true;
		this.editedProducts = this.editedProducts.map(item => {

			item.change = false;
		})
		window.scrollTo(0, 0);
	}

	// Create columns dynamically based on custom setting
	createColumns(col) {
		// console.log('COlumns -->', col);
		return {
			label: col.Label__c,
			fieldName: col.WrapperFieldName__c,
			type: col.FieldType__c,
			//editable: col.UseFieldName__c ? { fieldName: col.EditColumn__c } : col.EditDefaultValue__c,
			editable: col.UseFieldName__c ? { fieldName: col.EditColumn__c } : col.EditDefaultValue__c,
			disabled: col.UseFieldName__c ? { fieldName: col.Disabled__c } : col.DisableDefaultValue__c,
			typeAttributes: col.typeAttributes__c != null ? JSON.parse(col.typeAttributes__c) : '',
			initialWidth: col.initialWidth__c,
			wrapText: col.wrapText__c,
			cellAttributes: col.cellAttributes__c != null ? JSON.parse(col.cellAttributes__c) : '',
		};
	}

	// Handles the change in date
	handleDateChange(evt) {
		this.changeRequest.PCC_Decision_Date__c = evt.target.value;
	}

	// Handles the selection of an opportunity
	handleOpportunitySelect(evt) {
		if (this.recordId == null) {
			evt.preventDefault();
			this.recordId = evt?.detail?.recordId;
		}
		if (this.recordId) {
			this.opportunityId = this.recordId;
			this.opportunity.Id = this.recordId;
			this.opportunitySelected = true;

			opportunityDetails({ OpportunityId: this.recordId, url: JSON.stringify(window.location.origin) })
				.then(res => {
					if (res != null) {
						this.opportunity.Name = res[0].Name;
						this.designRegId = res[0].DesignRegId;
						this.ownerId = res[0].OwnerId;
						this.data = res;
						const pendingreview = this.data.filter(item => item.QuoteLinestatus == 'Pending Further Intel Review');
						this.readonlycr = pendingreview.length > 0;
						if (this.readonlycr) {
							this.errormessages.push('The Change Request for this Opportunity cannot created as the associated Quote line item(s) are currently under review.')
						}

						if (res[0].StageName === 'Lost') {
							this.errormessages.push('The Change Request for this Opportunity cannot created as the Opportunity stage is Lost.')
						}

						if (res[0].StageName === 'Cancelled') {
							this.errormessages.push('The Change Request for this Opportunity cannot created as the Opportunity stage is Cancelled.')
						}

						if (res[0].ApprovalStatus === 'Submitted') {
							this.errormessages.push('The Change Request for this Opportunity cannot created as the Opportunity is sent for Approval.')
						}

						if (res[0].StageName === 'Design Win') {
							this.errormessages.push('The Change Request for this Opportunity cannot created as the Opportunity stage is Design Win.')
						}
						this.oldChangeRequestExists = this.oldChangeRequestExists || this.readonlycr;


						const approvedLines = this.data.filter(this.filterData);//item => item.QuoteLinestatus === 'Approved' && ((new Date() - new Date(item.ApprovedPricingEndDate)) / (1000 * 3600 * 24)) > 90);
						this.data = approvedLines;
						this.data.forEach(item => {
							// call edit method
							this.cellEditCss(item, 'editCell');
							item.cancelBtnVariant = 'neutral'
						});
					}
					this.loaded = true;
					console.log('cell data -->', this.data);
				})
				.catch(error => {
					this.loaded = true;
					console.log(error);

				});
		}
	}

	filterData(item) {
		console.log('Date difference -->', ((new Date() - new Date(item.ApprovedPricingEndDate)) / (1000 * 3600 * 24)) < 90);
		if (item.QuoteLinestatus === 'Approved' && ((new Date() - new Date(item.ApprovedPricingEndDate)) / (1000 * 3600 * 24)) < 90) {
			return item;
		}

		return null;

	}

	handleEditChangeRequest() {
		this.editModel = true;
		this.data.forEach(item => {
			if (item.isChanged && !item.CancelProduct) {
				this.cellEditCss(item, 'editCell');
				item.change = true;
			}
		});
	}
	handleOpenPrevieScreen() {
		this.editModel = false;
		this.data.forEach(item => {
			if (item.isChanged && !item.CancelProduct) {
				this.cellEditCss(item, 'readOnlyCell');
				item.change = false;
			}

		});
	}
	// Handles actions on each row (edit or cancel)
	handleRowAction(event) {
		const actionName = event.detail.action.name;
		console.log(actionName);

		const row = event.detail.row;

		if (row.cancel) {
			this.handleClear(event);
		} else {
			this.handleCancelProduct(event);
		}

	}

	handleClear(evt) {
		const row = evt.detail.row;
		console.log('row -->', row);

		this.data = this.data.map(item => {
			if (item.OpptyLineItemId === row.OpptyLineItemId) {
				console.log('you are inside', item);
				this.clearRow(item, 'editCell', '');
			}
			return item;
		});
		console.log('Data -->', this.data);
	}

	handleOnClose() {
		this.loaded = true;
		this.index = '';
		this.editProduct = {};
	}

	handleOnLoad() {
		this.loaded = false;
	}
	async connectedCallback() {

		console.log('Record Id : ', this.recordId);
		// if (!window.origin.includes('site')) {
		// 	this.recordId = '006Df00000KdeyFIAR';
		// 	await this.handleOpportunitySelect();
		// } else {
		await this.handleOpportunitySelect();
		// }
		this.fetchPendingChangeRequest();
	}

	// Updates product details based on the rows selected
	async updateProduct(rows, change, cancel, cellclass, evt) {
		console.log('evt detail -->', evt.detail.draftValues);
		const rowIds = new Set(rows.map(row => row.OpptyLineItemId));
		let comment = '';
		this.productChanged = cancel || change ? true : false;

		if (cancel) {

			const result = await LightningPrompt.open({
				message: 'Comments are mandatory. Please enter comment for cancellation',
				label: 'Cancellation Comment',
			});


			if (result !== null && result.trim().length > 0) {
				comment = result;

			}
			else {
				// add error on table
				return; // Early return to stop further execution

			}


		}

		// Update only the records present in the rowIds Set
		this.data = await this.data.map(item => {
			if (rowIds.has(item.OpptyLineItemId)) {

				item.CoreQLAdditionalCommentsTxt = comment.trim().length > 0 ? comment : item.CoreQLAdditionalCommentsTxt;

				if (cancel) {
					item.CoreQLStartDt = null;
					item.CoreQLEndDt = null;
					item.Quantity = null;
					item.cancelBtnVariant = 'destructive';
					item.cancelName = 'Cancel';
					item.cancelLabel = 'Undo';
					item.iconName = 'utility:undo';
					// from here call cellCancelCss 
					this.cellCancelCss(item, cellclass);
				} else {
					// from here call cellEditCss
					this.cellEditCss(this.data, cellclass);
				}
				return {
					...item,
					change: cancel ? false : true,
					cancel: cancel,
					CancelProduct: cancel ? true : false,
					isChanged: (change || cancel) ? true : false,

				};
			}
			return item;
		});
	}

	cellCancelCss(item, className) {
		item.ApprovedPricingStartDateClass = className;
		item.ApprovedPricingEndDateClass = className;
		item.RebatePerUnitClass = className;
		item.CoreQLAdditionalCommentsTxtClass = className;
		item.CoreQLEndDtClass = className;
		item.CoreQLStartDtClass = className;
		item.CoreApprovedQuantityClass = className;
		item.QuoteNumberClass = className;
		item.QuoteLineNumberClass = className;
		item.QuoteLinestatusClass = className;
		item.QuantityClass = className;
		item.ProductNameClass = className;

	}

	clearRow(item, className, clearClass) {
		item.ApprovedPricingStartDateClass = clearClass;
		item.ApprovedPricingEndDateClass = clearClass;
		item.RebatePerUnitClass = clearClass;
		item.CoreQLAdditionalCommentsTxtClass = className;
		item.CoreQLEndDtClass = className;
		item.CoreQLStartDtClass = className;
		item.CoreApprovedQuantityClass = clearClass;
		item.QuoteNumberClass = clearClass;
		item.QuoteLineNumberClass = clearClass;
		item.QuoteLinestatusClass = clearClass;
		item.QuantityClass = className;
		item.ProductNameClass = clearClass;
		item.cancelName = 'Cancel';
		item.cancelLabel = 'Cancel';
		item.cancelBtnVariant = 'neutral';
		item.iconName = 'action:remove';
		item.change = true;
		item.cancel = false;
		item.isChanged = false;
		item.CoreQLAdditionalCommentsTxt = '';

	}


	cellEditCss(item, className) {
		item.QuantityClass = className;
		item.CoreQLAdditionalCommentsTxtClass = className;
		item.CoreQLEndDtClass = className;
		item.CoreQLStartDtClass = className;
		item.change = true;
		item.cancelName = 'Cancel';
		item.cancelLabel = 'Cancel';
		item.cancelBtnVariant = 'neutral';
		item.iconName = 'action:remove';
	}


	// Handles the saving of changes made to the data
	handleSave(event) {
		this.tableErrors = [];
		const draftValuesList = event.detail.draftValues;
		// const today = this.getDate(new Date());
		let rowsError = {};


		draftValuesList.forEach((draft) => {
			draft.CancelProduct = false;
			let messages = [];
			let fieldNames = [];
			const rowIndex = draft.Id || draft.id;
			const rIndex = rowIndex.includes('-') ? rowIndex.split('-')[1] : rowIndex;

			// Validate CoreQLStartDt field
			const record = this.data[rIndex];

			draft.CoreQLAdditionalCommentsTxt = draft.CoreQLAdditionalCommentsTxt ? draft.CoreQLAdditionalCommentsTxt : record.CoreQLAdditionalCommentsTxt


			if (parseInt(draft.Quantity, 10) > 0 && new Date(record.ApprovedPricingEndDate) < new Date() && (draft.CoreQLEndDt === null || draft.CoreQLEndDt === undefined)) {
				messages.push('New Prining End date is mandatory');
				fieldNames.push('CoreQLEndDt');
			}

			if (parseInt(draft.Quantity, 10) === parseInt(draft.CoreApprovedQuantity, 10) || draft.CoreQLStartDt === record.ApprovedPricingStartDate || draft.CoreQLEndDt === record.ApprovedPricingEndDate) {
				if (parseInt(draft.Quantity, 10) === parseInt(draft.CoreApprovedQuantity, 10)) {
					messages.push('New Quantity should be different from Approved New Quantity');
					fieldNames.push('Quantity');
				}

				if (draft.CoreQLStartDt === record.ApprovedPricingStartDate) {
					messages.push('New Pricing Start Date should be different from Approved Pricing Start Date');
					fieldNames.push('CoreQLStartDt');
				}

				if (draft.CoreQLEndDt === record.ApprovedPricingEndDate) {
					messages.push('New Pricing End Date should be different from Approved Pricing End Date');
					fieldNames.push('CoreQLEndDt');
				}

			}
			if (draft.CoreQLStartDt <= record.ApprovedPricingStartDate) {
				messages.push('New Pricing Start Date should be different from/greatet than Approved Pricing Start Date');
				fieldNames.push('CoreQLStartDt');
			}

			if (draft.CoreQLEndDt <= record.ApprovedPricingEndDate) {
				messages.push('New Pricing End Date should be different from/greater than Approved Pricing End Date');
				fieldNames.push('CoreQLEndDt');
			}

			if (draft.CoreQLEndDt <= draft.CoreQLStartDt) {
				messages.push('New Pricing Start Date should not be greater than Approved Pricing End Date');
				fieldNames.push('CoreQLEndDt');
			}


			if (parseInt(draft.Quantity, 10) <= 0) {
				messages.push('New Quantity should be greatet than 0');
				fieldNames.push('Quantity');
			}

			if (draft.CoreQLEndDt !== null && draft.CoreQLEndDt <= record.ApprovedPricingEndDate) {
				messages.push('Quote Line Pricing End Date cannot be earlier than the Approved Pricing End Date');
				fieldNames.push('CoreQLEndDt');
			}


			if (draft.CoreQLEndDt !== null && draft.CoreQLEndDt !== undefined && draft.CoreQLStartDt !== undefined && draft.CoreQLStartDt !== null && (new Date(draft.CoreQLEndDt) < new Date() || (new Date(draft.CoreQLEndDt) <= new Date(draft.CoreQLStartDt)))) {
				messages.push('Please enter the Pricing end date greater than today or greater then Pricing start date');
				fieldNames.push('CoreQLEndDt');
			}
			if ((draft.CoreQLEndDt !== null || draft.CoreQLStartDt !== null || draft.Quantity !== null) && ((record.CoreQLAdditionalCommentsTxt === null && draft.CoreQLAdditionalCommentsTxt === null) || (record.CoreQLAdditionalCommentsTxt === undefined && draft.CoreQLAdditionalCommentsTxt === undefined))) {
				messages.push('Comments are mandatory');
				fieldNames.push('CoreQLAdditionalCommentsTxt');
			}


			// Populate errors
			if (messages.length > 0) {
				rowsError[rowIndex] = {
					title: `${messages.length} error(s) on this row`,
					messages: messages,
					fieldNames: fieldNames
				};


			} else {
				// Update the data array with the draft values if no errors

				console.log('index -->');
				this.cellEditCss(this.data, 'editRow');
				if (rIndex !== -1) {
					console.log('you are here');
					draft.isChanged = true;
					this.data[rIndex] = { ...this.data[rIndex], ...draft };
					console.log('data -->', this.data);
					messages = [];
					fieldNames = [];
					rowsError = {};
				}

			}
		});

		if (Object.keys(rowsError).length === 0) {
			this.draftValues = [];
			this.tableErrors = {};
		} else {

			this.tableErrors = {
				rows: rowsError,
				table: {
					title: 'Your entry cannot be saved. Fix the errors and try again.',
					messages: Object.keys(rowsError).length > 0 ? [`${Object.keys(rowsError).length} row/s has error(s). Navigate to the rows to see the issues.`] : []
				}
			};
		}
		console.log('rowsError', this.tableErrors);

		// Clear draft values after processing

	}


	closeCreateScreen(evt) {
		console.log('event received');
		this.createRecord = false;
		this.editProduct = {};
		this.index = '';
	}

	// Handles the cancellation of changes
	async handleCancel(evt) {
		if (this.productChanged) {
			this.createRecord = false;

			// Await the result of handleConfirm
			// const isConfirmed = await this.handleConfirm();

			// if (isConfirmed) {
			// this.deleteRecords(this.documentIdObj);
			await refreshApex(this.handleOpportunitySelect());
			this.selectedProducts = [];
			this.productChanged = false;
			this.showForm = false;
			this.editModel = false;
			// }
		} else {
			await refreshApex(this.handleOpportunitySelect());
			this.showForm = false;
			this.editModel = false;
		}
	}

	// Handles the submission of the change request
	handleSubmit(evt) {
		this.disableActions = true;
		if (!this.productChanged && !this.newlyAddedProducts) {
			this.dispatchEvent(new ShowToastEvent({ title: 'No Change Detected', message: 'No changes are requested, Please request for change or cancel to proceed!', variant: 'warning' }));
		} else {
			this.productChanged = false;
			this.createChangeRequest();
		}
	}

	// Creates a new change request
	createChangeRequest() {
		try {
			this.changeRequest.PCC_Opportunity__c = this.opportunityId;
			this.changeRequest.PCC_Approval_Status__c = 'Submitted';
			this.changeRequest.PCC_Change_Request_Approver__c = this.ownerId;
			this.loaded = false;
			createCR({ changeHeaderPayload: JSON.stringify(this.changeRequest) }) // fileIds: JSON.stringify(this.documentIdObj)
				.then(res => {
					if (res.Id !== null) {
						this.myRecordId = res.Id;

						this.createChangeRequestLineItem(res.Id);
					}
				})
				.catch(error => {
					this.disableActions = false;
					this.loaded = true;
					console.log('Error -->', error);

				});
		} catch (error) {
			this.disableActions = false;
			this.loaded = true;
			console.log('Error -->', error);
			this.dispatchEvent(new ShowToastEvent({ title: 'Error Occured!', message: 'You have encountered an Error, Please raise raise support request.', variant: 'error' }));
		}

	}

	mapOfIds = [];
	async getProductIds(ids) {
		try {
			const result = await getProductsIds({ ids: ids });
			this.mapOfIds = result;
			console.log('Product IDs successfully fetched:', this.mapOfIds);
		} catch (error) {
			console.error('Error fetching product IDs:', error);
			throw error; // Rethrow the error for the calling function to handle
		}
	}

	async createChangeRequestLineItem(recordId) {
		if (this.newlyAddedProducts !== null && this.newlyAddedProducts !== undefined) {
			const ids = this.newlyAddedProducts.map(item => item.PCC_Product_Additional_Attribute__c);

			try {
				await this.getProductIds(ids); // Fetch product IDs
			} catch (error) {
				console.error("Error fetching product IDs:", error);
				return; // Early return if there's an error fetching product IDs
			}
		}

		const changeRequestLineItem = this.data
			?.filter(item => item.isChanged)
			.map(item => ({
				PCC_Opportunity_Product_Id__c: item.OpptyLineItemId,
				PCC_Start_Date__c: item.CoreQLStartDt ? item.CoreQLStartDt : null,
				PCC_Approved_Pricing_Start_Date__c: item.ApprovedPricingStartDate,
				PCC_Approved_Pricing_End_Date__c: item.ApprovedPricingEndDate,
				PCC_End_Date__c: item.CoreQLEndDt ? item.CoreQLEndDt : null,
				PCC_Partner_Comment__c: item.CoreQLAdditionalCommentsTxt,
				PCC_Change_Request__c: recordId,
				PCC_Request_Type__c: item.CancelProduct ? 'Cancel' : 'Change',
				PCC_Quantity__c: item.Quantity,
				PCC_Product__c: item.Product2Id,
				PCC_Approved_Quantity__c: item.CoreApprovedQuantity,
				PCC_Approval_Status__c: 'Pending',
				PCC_Product_JSON__c: JSON.stringify(item),
				PCC_Change_Request_Quote_Line__c: item.QuoteLineId
			})) ?? [];

		const newlyAddedItems = this.newlyAddedProducts?.map(item => {
			const productId = this.mapOfIds[item.PCC_Product_Additional_Attribute__c];
			if (!productId) {
				console.error(`No product ID found for attribute ${item.PCC_Product_Additional_Attribute__c}`);
				return null;
			}
			return {
				PCC_Change_Request__c: recordId,
				PCC_Start_Date__c: item.PCC_Quote_Line_Pricing_Start_Date__c,
				PCC_End_Date__c: item.PCC_Quote_Line_Pricing_End_Date__c,
				PCC_Partner_Comment__c: item.PCC_Additional_Comments__c,
				PCC_Request_Type__c: 'Add',
				PCC_Quantity__c: item.Core_Full_Year_Qty__c,
				PCC_Approval_Status__c: 'Pending',
				PCC_Product_JSON__c: JSON.stringify(item),
				PCC_Deal_Product__c: item.PCC_Product_Additional_Attribute__c,
				PCC_Product__c: productId,
				PCC_Design_Deal_Registration_Product__c: this.getFormattedTable(item)
			};
		}).filter(item => item !== null) ?? [];

		changeRequestLineItem.push(...newlyAddedItems);

		console.log('changeRequestLineItem', changeRequestLineItem);

		if (changeRequestLineItem.length > 0) {
			await createCRLI({ changeLinePayload: JSON.stringify(changeRequestLineItem) })
				.then(result => {
					if (result) {
						this.dispatchEvent(new ShowToastEvent({
							title: 'Request Submitted',
							message: 'Change request is submitted successfully!',
							variant: 'success'
						}));
						this.showForm = false;
						this.loaded = true;
						setTimeout(() => {
							location.reload();
						}, 3000);
					}
				})
				.catch(error => {
					this.loaded = true;
					this.disableActions = false;
					console.error('Error creating change request line items:', error);
				});
		}
	}

	// creae dynamic table for DRP values

	getFormattedTable(item) {
		console.log('Item -->', item);

		// Extract headers and field names from the columns configuration
		const headers = this.newProductScreenCols
			.filter(column => column.label !== null && column.label !== undefined && column.label !== 'Actions')
			.map(column => column.label);
		console.log('Header -->', headers);


		const fieldNames = this.newProductScreenCols
			.filter(column => column.label !== null && column.label !== undefined && column.label !== 'Actions')
			.map(column => column.fieldName);
		console.log('fieldNames -->', fieldNames);


		// Create the table header row with labels
		const headerRow = headers.map(header => `
			<th style="border: 1px solid #ddd; padding: 8px; background-color: #f2f2f2;">
				${header}
			</th>
		`).join('');

		// Create the table data row with values from the item object using field names
		const dataRow = fieldNames.map(fieldName => {
			// Use fieldName to access the corresponding value in the item object

			let value;
			if ((fieldName == 'PCC_Product_Additional_Attribute__c' || fieldName == 'PCC_Competitor_Product__c' || fieldName == 'Core_Design_Registration_Id__c') && (item[fieldName] !== null && item[fieldName] !== undefined)) {
				console.log('FieldName -->', fieldName);

				if (fieldName == 'PCC_Product_Additional_Attribute__c') {
					value = this.dealProductName;//;item[fieldName].fields['Name'].value;
				}


				if (fieldName == 'PCC_Competitor_Product__c') {
					value = this.competitorProductName;//item[referenceFieldName].fields['Name'].value;
				}

				if (fieldName == 'Core_Design_Registration_Id__c') {
					value = this.drName;//item[referenceFieldName].fields['Name'].value;
				}
				console.log('value -->', value);
			} else if (item[fieldName] !== undefined && item[fieldName] !== null) {
				console.log('FieldName -->', fieldName);
				value = item[fieldName];
				console.log('value -->', value);
			} else {
				console.log('FieldName -->', fieldName);
				value = 'N/A';
				console.log('value -->', value);
			}
			return `
				<td style="border: 1px solid #ddd; padding: 8px;">
					${value}
				</td>
			`;
		}).join('');

		// Return the complete table HTML
		return `
			<table style="width:100%; border-collapse: collapse;">
				<tr>
					${headerRow}
				</tr>
				<tr>
					${dataRow}
				</tr>
			</table>
		`;
	}


	// Handles the selection of rows in the data table
	handleRowSelection(evt) {
		const selectedRows = evt.detail;
		this.selectedProducts = selectedRows;
	}

	// Handles the cancellation of selected products
	handleCancelProduct(evt) {
		console.log('Draft values ', evt.detail.draftValues);
		this.updateProduct([evt.detail.row], false, true, 'slds-text-color_destructive', evt);
	}


	// Initiates the creation of a new request
	handleCreateNewRequest() {
		// document.body.style.zoom = '70%';
		this.handleEditChangeRequest();
		this.tableErrors = [];
		this.showForm = true;
		this.editModel = true;
		this.hidecheckboxColumns = false;
	}

	// Converts a datetime to a date string in the format YYYY-MM-DD
	getDate(datetime) {
		const date = new Date(datetime);
		const year = date.getFullYear();
		const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based
		const day = String(date.getDate()).padStart(2, '0');

		return `${year}-${month}-${day}`;
	}
}