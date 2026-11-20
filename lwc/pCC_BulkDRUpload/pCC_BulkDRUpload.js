import { LightningElement, track, api } from 'lwc';
import saveFile from '@salesforce/apex/PCC_CreateBulkDRRecords.saveFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
console.log('js file called');


const columns = [

   { label: 'Group ID', fieldName: 'Core_Group_Id__c', type: 'Text'},
   { label: 'Header/Product', fieldName: 'Core_Header_Or_Product_Ind__c', type: 'Text'},
   { label: 'Design Registration Line ID', fieldName: 'Core_Design_Registration_Line_Id__c', type: 'Text'},
   { label: 'Product', fieldName: 'Core_Product_Id__c', type: 'Text'},
   { label: 'Quantity (Full Production Year)', fieldName: 'Core_Full_Year_Qty__c', type: 'Text' },
   { label: 'Target Resale Price', fieldName: 'Core_Target_Resale_Amt__c', type: 'Text' },
   { label: 'Partner Tracking Number', fieldName: 'Core_Partner_Tracking_Cd__c', type: 'Text' },
   { label: 'Cancelled (Y)', fieldName: 'Core_Cancelled_Ind__c', type: 'Text' },
   { label: 'Product Comments', fieldName: 'Core_Comment_Txt__c', type: 'Text' },
   { label: 'Registration Number', fieldName: 'Core_Registration_Number_Id__c', type: 'Text' },
   { label: 'Owner (Email)', fieldName: 'Core_Owner_Txt__c', type: 'Text'},
   { label: 'Product Group', fieldName: 'Core_Product_Group_Nm__c', type: 'Text'},
   { label: 'Design Registration Name', fieldName: 'Core_Design_Registration_Nm__c', type: 'Text'},
   { label: 'Description', fieldName: 'Core_Design_Registration_Dsc__c', type: 'Text'},
   { label: 'Opportunity Volume', fieldName: 'Core_Opportunity_Volume_Cnt__c', type: 'Text' },
   { label: 'Partner FAE', fieldName: 'Core_Partner_FAE_Nm__c', type: 'Text' },
   { label: 'Partner FSR', fieldName: 'Core_Partner_FSR_Nm__c', type: 'Text' },
   { label: 'End Customer Name', fieldName: 'Core_End_Customer_Nm__c', type: 'Text' },
   { label: 'End Customer Address1', fieldName: 'Core_End_Customer_Street_Addr_Line1_Txt__c', type: 'Text' },
   { label: 'End Customer Address2', fieldName: 'Core_End_Customer_Street_Addr_Line2_Txt__c', type: 'Text' },
   { label: 'End Customer City', fieldName: 'Core_End_Customer_City_Nm__c', type: 'Text'},
   { label: 'End Customer State', fieldName: 'Core_End_Customer_Country_Subdivision_Nm__c', type: 'Text'},
   { label: 'End Customer Zip/Postal Code', fieldName: 'Core_End_Customer_Postal_Cd__c', type: 'Text'},
   { label: 'End Customer Country', fieldName: 'PCC_End_Customer_Country__c', type: 'Picklist'},
   { label: 'Contact Title', fieldName: 'Core_End_Customer_Contact_Title_Txt__c', type: 'Text' },
   { label: 'Contact Name', fieldName: 'Core_End_Customer_Contact_Nm__c', type: 'Text' },
   { label: 'Contact Email', fieldName: 'Core_End_Customer_Contact_Email_Txt__c', type: 'Text' },
   { label: 'Contact Phone', fieldName: 'Core_End_Customer_Contact_Phone_Txt__c', type: 'Text' },
   { label: 'Are Intel items used for MINDS?', fieldName: 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c', type: 'Text' },
   { label: 'Decision Date', fieldName: 'Core_Opportunity_Decision_Dt__c', type: 'Text' },
   { label: 'First Customer Ship Date', fieldName: 'Core_First_Customer_Ship_Dt__c', type: 'Text' },
   { label: 'Production End Date', fieldName: 'Core_Production_End_Dt__c', type: 'Text'},
   { label: 'Vertical Market', fieldName: 'Core_Vertical_Market_Nm__c', type: 'Text'},
   { label: 'Intel Platform', fieldName: 'Core_Intel_Platform_Nm__c', type: 'Text'},
   { label: 'Product Segment', fieldName: 'Core_Product_Segment_Nm__c', type: 'Text'},
   { label: 'Product Application', fieldName: 'Core_Product_Application_Nm__c', type: 'Text' },
   { label: 'Manufacturing Region', fieldName: 'Core_Manufacturing_Region_Cd__c', type: 'Text' },
   { label: 'End Customer URL', fieldName: 'Core_End_Customer_URL__c', type: 'Text' },
   { label: 'Partner FAE Email', fieldName: 'DDR_Partner_FAE_Email__c', type: 'Text' }
   
   //{ label: 'Account Source', fieldName: 'AccountSource' }

];
export default class LwcCSVUploader extends LightningElement {

    @api recordid;
	@track columns = columns;
	@track data;
	@track fileName = '';
	@track UploadFile = 'Upload CSV File';
	@track showLoadingSpinner = false;
	@track isTrue = false;
	@api csvFileName = '';
	selectedRecords;
	filesUploaded = [];
	file;
	fileContents;
	fileReader;
	content;
	MAX_FILE_SIZE = 1500000;
	

	handleFilesChange(event) {
		console.log('csvFileName ====> ', event.target.files[0].name);
		this.csvFileName = event.target.files[0].name;
        if(event.target.files.length > 0) {
			this.filesUploaded = event.target.files;
			this.fileName = event.target.files[0].name;
		}
	}
	handleSave() {
		if(this.filesUploaded.length > 0) {
			this.uploadHelper();
		}
		else {
			this.fileName = 'Please select a CSV file to upload!!';
		}

    }
	uploadHelper() {
		this.file = this.filesUploaded[0];
		if (this.file.size > this.MAX_FILE_SIZE) {
			window.console.log('File Size is to long');
			return ;
		}
		this.showLoadingSpinner = true;
		this.fileReader= new FileReader();
		this.fileReader.onloadend = (() => {
		this.fileContents = this.fileReader.result;
		this.saveToFile();
		});
		this.fileReader.readAsText(this.file);
	}
	saveToFile() {
		console.log('csvFileName here ====> ', this.csvFileName);
		saveFile({base64Data: JSON.stringify(this.fileContents), cdbId: this.recordid, csvFileName: this.csvFileName})
		.then(result => {
			console.log('result ====> ', result);
			this.data = result;
			this.fileName = this.fileName + ' - Uploaded Successfully';
			this.isTrue = false;
			this.showLoadingSpinner = false;
				this.dispatchEvent(
					new ShowToastEvent({
					title: 'Success!!',
					message: this.file.name + ' - Uploaded Successfully!!!',
					variant: 'success',
					}),
				);
		})
		.catch(error => {
			console.log("error -->", error);
			const errorTitle = error.body.message ?? 'Error while uploading File';// Utkarsh - TWC727-1237 - Changes done to through error messages.
			this.dispatchEvent(
				new ShowToastEvent({
				title: errorTitle,
				message: error.message,
				variant: 'error',
				}),
			);
		});
	}
}