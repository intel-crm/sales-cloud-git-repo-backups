import {
		LightningElement,
		api,
		track,
		wire
} from 'lwc';
import {
		getRecord
} from 'lightning/uiRecordApi';


import getLicenseParameter from "@salesforce/apex/Sales_UpdateLicenseRenewalRecords.getLicenseParameter";
const columns = [{
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
	label: 'Order Product',
	fieldName: 'OrdprodUrl',
	type: 'url',
	typeAttributes: {
			label: {
					fieldName: 'OrderProduct'
			},
			target: '_blank'
	},
	sortable: true},
	{
		label: 'Product Name',
		fieldName: 'ProdnameUrl',
		type: 'url',
		typeAttributes: {
				label: {
						fieldName: 'ProductName'
				},
				target: '_blank'
		},
		sortable: true},
	


{
	label: 'Status',
	fieldName: 'Sales_License_Status__c',
	type: 'string',
	sortable: true
},	
	{
	label: 'Type',
	fieldName: 'Sales_License_Type__c',
	type: 'string',
	sortable: true
},		
	{
	label: 'Available quantity',
	fieldName: 'Sales_License_Avbl_Qty_Nbr__c',
	type: 'string',
	sortable: true
},
{
	label: 'OPN',
	fieldName: 'Sales_License_Product_OPN__c',
	type: 'string',
	sortable: true
},		
	{
	label: 'License Admin',
	fieldName: 'Sales_License_Primary_Admin_Contact_Txt__c',
	type: 'string',
	sortable: true
},


{
	label: 'Maintenance Expiration',
	fieldName: 'Sales_License_Maintenance_Exp_Dt__c',
	type: 'date-local',
	sortable: true
},		
	{
	label: '# of seats',
	fieldName: 'Sales_License_Quantity__c',
	type: 'number',
	sortable: true
},

];


							
const FIELDS = ['Sales_License__c.Sales_License_Type__c'];

export default class Sales_LicenserecordUpdates extends LightningElement {

		@api recordId;
		@api tablename;
		@track data;
		olumnsList = columns;
		/*@wire(getRecord, {
		recordId: '$recordId',
		fields: FIELDS
	})
	license;*/
		connectedCallback() {
				//console.log('license'+JSON.stringify(this.license));
				this.tablename = 'Related licenses';
				getLicenseParameter({
						recordId: this.recordId/*,
				licType: this.license.fields.Sales_License__c.Sales_License_Type__c.value*/
				})
						.then(result => {
						let licenseResult = [];
						result.forEach(element => {
								let preparedLicense = {
										...element
								};
								if (element.Id) {
										preparedLicense.LicenseName = element.Name;
										preparedLicense.LicenseUrl = '/lightning/r/Sales_License__c/' + element.Id + '/view';
								}
								if(element.Sales_License_Order_Product__c)
								{	preparedLicense.OrderProduct = element.Sales_License_Order_Product__r.OrderItemNumber;
									preparedLicense.OrdprodUrl = '/lightning/r/OrderItem/' + element.Sales_License_Order_Product__c + '/view';
							

								}
								if(element.	Sales_License_Product__c)
								{	preparedLicense.ProductName  = element.Sales_License_Product__r.Name;
									preparedLicense.ProdnameUrl = '/lightning/r/Product2/' + element.Sales_License_Product__c + '/view';
							

								}
						
								       preparedLicense.Sales_License_Status__c=element.Sales_License_Status__c;
										preparedLicense.Sales_License_Type__c = element.Sales_License_Type__c;
										preparedLicense.Sales_License_Maintenance_Exp_Dt__c=element.Sales_License_Maintenance_Exp_Dt__c;
										
										preparedLicense.Sales_License_Avbl_Qty_Nbr__c = element.Sales_License_Avbl_Qty_Nbr__c;






								console.log('@@'+JSON.stringify(preparedLicense))
								licenseResult.push(preparedLicense);
						});
						this.data = licenseResult;
						this.error = undefined;
						console.log('Result-->from licenserecordUpdatemethod' + JSON.stringify(result));
						console.log('this.data-->from licenserecordUpdatemethod' + JSON.stringify(this.data));
				})
						.catch(error => {
						this.error = error;
						this.data = undefined;
				})
		}
}