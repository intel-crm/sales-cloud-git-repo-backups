import {
    LightningElement,
    api,
    track
} from 'lwc';
/*import getLicenseListForAdmin from '@salesforce/apex/Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin';
import salesDistributeActionReqErr from '@salesforce/label/c.Sales_DistributeActionReq_Err';
import SalesCreatelicandProcess from '@salesforce/label/c.Sales_CreatelicandProcess';
import SalesProcessErrHTML from '@salesforce/label/c.Sales_Process_Err_HTML';
import SalesOrderClose from '@salesforce/label/c.Sales_OrderClose';
import SalesCreateoptnlicErr from '@salesforce/label/c.Sales_CreateoptnlicErr';
import SalesCreateLicHTML from '@salesforce/label/c.Sales_createLic_HTML';
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
        label: 'OPN',
        fieldName: 'Product_OPN',
        type: 'string',
        sortable: true
    },
		{
        label: 'Order Product Number',
        fieldName: 'OrderProductNumberUrl',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'OrderProductNumber'
            },
            target: '_blank'
        },
        sortable: true
    },
	{
        label: 'Primary Computer Id',
        fieldName: 'primaryComputerUrl',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'PrimaryComputerId'
            },
            target: '_blank'
        },
        sortable: true
    },
		{
        label: 'License Activation Code',
        fieldName: 'License_Activation_Code',
        type: 'string',
        sortable: true
    },
		{
        label: 'License Admin',
        fieldName: 'PrimaryContactNameUrl',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'PrimaryContactName'
            },
            target: '_blank'
        },
        sortable: false
    },
		{
        label: 'License User',
        fieldName: 'LicenseUserUrl',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'LicenseUserName'
            },
            target: '_blank'
        },
        sortable: false
    },
		
    {
        label: '# of Seats',
        fieldName: 'Quanity',
        type: 'number',
        sortable: false
    },
		{
        label: 'Available Quantity',
        fieldName: 'Available_Quanity',
        type: 'number',
        sortable: true
    },					 
    {
        label: 'Maintenance Expiration Date',
        fieldName: 'Maintenanace_Expiration',
        type: 'date-local',
        sortable: true
    },
    {
        label: 'License Expiration Date',
        fieldName: 'Sales_Expiration_Date',
        type: 'date-local',
        sortable: true
    },
		{
        label: 'Status',
        fieldName: 'License_Status',
        type: 'string',
        sortable: false
    },	
		{
        label: 'Type',
        fieldName: 'License_Type',
        type: 'string',
        sortable: false
    },		
		{
        label: 'Web Display Flag',
        fieldName: 'webDisplayFlag',
        type: 'boolean',
        sortable: false
    },	
	
	{
				label: "Action",
				fieldName: "action", 
				type: "customActions",
				typeAttributes: {
						selectedRow: { fieldName: 'rowDetails' }
				}
	}
];*/

export default class Sales_ExistingLicenseView extends LightningElement {

    /*@track error;
    @api recordId;
    @api result;
    @track data;
	@track spin=true;
		@track licenseRow={};
		@track processLicenses={};
		@track modalContainer = false;
		@track showLicenseCreateButton = false;
		@track licenseRowAvailableQuantityAbs = 0;
		@track isCorporateMap;
		@track isCorporate;
		@track isCreateLicense = false;
		//@track isBundleProductMap;
		@track hideProcessBtn=false;
		@track isNonCorporateMap;
		@track isLoading = false;
		@track parentLicenseIds;
		@track buttonClicked=false;

		licenses;
    columnsList = columns;
		
	label = {
		salesDistributeActionReqErr,
		SalesCreatelicandProcess,
		SalesProcessErrHTML,
		SalesOrderClose,
		SalesCreateoptnlicErr,
		SalesCreateLicHTML
	};

	
		connectedCallback(){
				getLicenseListForAdmin({recId: this.recordId})
						.then(result => {
						if (result) {
								//const quantityMap = result.prodQuantityMap;
								this.isCorporateMap = result.isCorporateMap;
								this.isNonCorporateMap = result.isNonCorporateMap;
								//this.isBundleProductMap = result.isBundleProductMap;
								this.parentLicenseIds=result.parentLicenseIds;
								const nonCorporateWithOriginalLicenseList=result.nonCorporateWithOriginalLicenseList;
								const productToFoundProdFinalMap = result.productToFoundProdFinalMap;
								console.log('@@@productToFoundProdFinalMap'+JSON.stringify(result.productToFoundProdFinalMap));
								let preparedLicenses = [];
								result.licenseJunctionWrapperList.forEach(license => {
									console.log('@@@qty'+JSON.stringify(license.quantity));
										/*if((license.licenseType==='Renewal'||license.licenseType==='Amend') && license.availableQuanity===0){
												return;
										}*/
										/*if(license.licenseType==='Optional'){
											return;
										}
										let preparedLicense = {
												...license
										};
										if (license.licenseId) {
												preparedLicense.LicenseName = license.licenseName;
												preparedLicense.LicenseUrl = '/lightning/r/Sales_License__c/' + license.licenseId + '/view';
										}
										if (license.productId) {
												preparedLicense.ProductName = license.productName;
												preparedLicense.ProductUrl = '/lightning/r/Product2/' + license.productId + '/view';
										}
										if (license.orderItemRecordId) {
												preparedLicense.OrderProductNumber = license.orderNumber;
												preparedLicense.OrderProductNumberUrl = '/lightning/r/OrderItem/' + license.orderItemRecordId + '/view';
										}
										if (license.primaryComputerId) {
											preparedLicense.PrimaryComputerId = license.primaryComputerName;
											preparedLicense.primaryComputerUrl = '/lightning/r/Sales_Host__c/' + license.primaryComputerId + '/view';
									}
										if (license.primaryContactId) {
												preparedLicense.PrimaryContactName = license.primaryContactName;
												preparedLicense.PrimaryContactNameUrl = '/lightning/r/Contact/' + license.primaryContactId + '/view';
										}
										if (license.licenseUserId) {
												preparedLicense.LicenseUserName = license.licenseUserName;
												preparedLicense.LicenseUserUrl = '/lightning/r/Contact/' + license.licenseUserId + '/view';
										}
										preparedLicense.License_Activation_Code = license.licenseActivationCode;
										preparedLicense.Product_OPN = license.productOPN;
										preparedLicense.Sales_Expiration_Date = license.salesExpirationDate;
										preparedLicense.Sales_License_SAPLine_Nbr__c = license.sapLine;
										preparedLicense.Maintenanace_Expiration = license.maintenanaceExpiration;
										console.log('@@@@license.maintenanaceExpiration'+license.maintenanaceExpiration);
										console.log('@@@@preparedLicense.Maintenanace_Expiration'+preparedLicense.Maintenanace_Expiration);
										preparedLicense.Available_Quanity = license.availableQuanity;
										preparedLicense.Quanity = license.quantity;//removed absolute function
										preparedLicense.License_Type = license.licenseType;
										preparedLicense.License_Status = license.licenseStatus;
										preparedLicense.webDisplayFlag = license.webDisplayFlag;
										console.log('license.licenseType'+license.licenseType);
										preparedLicense.actionTitle='Distribution Action';
										preparedLicense.actionValue='distributionAction';
										preparedLicense.iconName='utility:warning';
										preparedLicense.isDistributedDisabled=false;
										//console.log('nonCorporateWithOriginalLicenseList'+JSON.stringify(nonCorporateWithOriginalLicenseList));
										if(this.isNonCorporateMap[license.orderItemRecordId]==true && (license.licenseType!='Original' && license.licenseType!='Optional')){
												let showRed=true;
												console.log('line 254',+license.productId);
											
												productToFoundProdFinalMap[license.productId].forEach(childProduct => {
														console.log('@@license.contactFromOrderProduct'+license.contactFromOrderProduct);
														var key;
														if(license.contactFromOrderProduct==undefined){
																key=null+'-'+childProduct;
														}
														else{
																key=license.contactFromOrderProduct+'-'+childProduct;
														}
														console.log('Key'+key);
														if(nonCorporateWithOriginalLicenseList.includes(key)){
																console.log('license is present');
																console.log('nonCorporateWithOriginalLicenseList'+JSON.stringify(nonCorporateWithOriginalLicenseList));
																showRed=false;

														}
												})
											
												if(showRed == true){
														console.log('Making it Red');
														preparedLicense.isRed=true;
												}
										}
										
										//const key=license.contactFromOrderProduct+'-'+license.productId;
										/*if(this.isNonCorporateMap[license.orderItemRecordId]==true && !nonCorporateWithOriginalLicenseList.includes(key)){
											console.log('nonCorporateWithOriginalLicenseList'+JSON.stringify(nonCorporateWithOriginalLicenseList));
											preparedLicense.isRed=true;
										}*/
											//sahil removed license.licenseType!='Renewal' from below if condition to not show distribution action on it.
										/*if ((license.licenseType!='Add Seat' && license.licenseType!='Amend Contract - Qty Decrease'
										&& license.licenseType!='Renew Contract - Qty Decrease') || license.availableQuanity==0){
												preparedLicense.isDistributedDisabled=true;
										}
										/*console.log('isCorporateMap'+JSON.stringify(this.isCorporateMap));
										const isCorporate = this.isCorporateMap[license.orderItemRecordId];
										console.log('isCorporate'+isCorporate);*/
										/*if(isCorporate==true && license.licenseType!='Renewal' && license.licenseType!='Amend'){
												//preparedLicense.actionTitle='Process';
												//preparedLicense.actionValue='processAction';
												//preparedLicense.iconName='action:edit';
												preparedLicense.isDistributedDisabled=true;
												let key=`${license.primaryContactId}-${license.productId}`;
												console.log('key'+key);
												console.log('license.availableQuanity'+license.availableQuanity);
												console.log('quantityMap'+JSON.stringify(quantityMap));
												if(license.availableQuanity<quantityMap[key]){
														preparedLicense.isDistributedDisabled=false;
												}
										}*/
										/*const isProductOption = this.isBundleProductMap[license.productFromOrderProduct];
										if(isProductOption==true && license.parentLicense==undefined && !this.parentLicenseIds.includes(license.licenseId)&& license.isProductOptionAvailable){
												preparedLicense.isProductOption=true;
										}
										console.log('preparedLicense.isProductOption',preparedLicense.isProductOption);*/
										/*const rowData = preparedLicense;
										preparedLicense.rowDetails = JSON.stringify(rowData);
										preparedLicenses.push(preparedLicense);
								});

								this.data = preparedLicenses;
								this.error = undefined;
								if(this.data){
								this.spin=false;
								}
						}
				}).catch(error => {
						this.error = error;
						this.data = undefined;
				});
				
				
		}
		
		callRowAction(event) {
				this.licenseRow=event.detail.row;
				console.log('@@@'+JSON.stringify(event.detail.row));
				this.licenseRowAvailableQuantityAbs = Math.abs(this.licenseRow.Available_Quanity);
				this.isCorporate = this.isCorporateMap[this.licenseRow.orderItemRecordId];
				//this.modalContainer=true;
		}
		
		handleShowLicenseCreate(){
				console.log('This is it');
				this.showLicenseCreateButton=true;
				
		}

		handleHideProcessBtn(){
				console.log('@@@TestHideBtn');
				this.hideProcessBtn=true;
		}
		
		closeModalAction(){
				this.showLicenseCreateButton=false;
				this.modalContainer=false;
				this.hideProcessBtn=false;
		}
		
		closeProcessModalAction(){
				this.isCreateLicense=false;
		}
		
		closeModalAndRefreshAction(){
				this.closeModalAction();
				this.reload()
		}
		
		closeOptionModalAndRefreshAction(){
				this.closeProcessModalAction();
				this.reload()
		}
		reload(){
				setTimeout(function() {
						location.reload(true);
				}, 2000);
		}
		
		processLicense(){  
				this.template.querySelector("c-sales_-existing-foundation-license-view").processLicense();  
		}
		
		generateAndProcessLicense(){
				this.template.querySelector("c-sales_-existing-foundation-license-view").generateAndProcessLicense();  
		}
		
		fireDistribute(event){
				this.licenseRow=JSON.parse(event.detail.selectedRow);
				this.licenseRowAvailableQuantityAbs = Math.abs(this.licenseRow.Available_Quanity);
				this.isCorporate = this.isCorporateMap[this.licenseRow.orderItemRecordId];
				console.log('In fire distribute');
				this.isLoading = true;
				this.modalContainer=true;
		}
		openModal(event){
				console.log('Here in open modal');
				this.isLoading = false;
				this.modalContainer=true;
		}
		
		fireProcess(event){
				this.licenseRow=JSON.parse(event.detail.selectedRow);
				this.isCreateLicense=true;
		}
		
		generateOptionLicense(){
				this.buttonClicked = true;
				this.template.querySelector("c-sales_option-product-license-creation").generateOptionLicense();  
		}

		handleButtonClicked(event){
			const isButtonClicked = event.detail;
			this.buttonClicked = isButtonClicked;
		}
		
		showProcessOptionLicense(){
				this.licenseRow.hasOptionProduct=true;
		}*/		
}