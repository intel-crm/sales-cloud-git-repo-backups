import { LightningElement, track, api,wire } from "lwc";
//import CountryList from '@salesforce/label/c.CountryList';
import IPA_BulkInvite from '@salesforce/label/c.IPA_BulkInvite';
import PRM_Bulk_Clickhere from '@salesforce/label/c.PRM_Bulk_Clickhere';
import PMP_Okay from '@salesforce/label/c.PMP_Okay';
import PRM_Bulk_Header from '@salesforce/label/c.PRM_Bulk_Header';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
//import getCountries from '@salesforce/apex/PRM_BulkInviteApex.getCountries';
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import country_field from "@salesforce/schema/Account.BillingCountry";
// Import getRatingPicklistValues function from Apex controller
import getRatingPicklistValues from '@salesforce/apex/PRM_BulkInviteApex.getPicklistValues';
export default class PRM_DownloadBulkInviteTemplate extends LightningElement {
  @api downloadtemp;
  @track isShowCoutryPopUp= false;
  label={IPA_BulkInvite ,PRM_Bulk_Clickhere ,PMP_Okay ,PRM_Bulk_Header};
  @track CountryList=[];
  columnNames = ["ContactEmail", "FirstName", "LastName", "ContactCountry"];
  columnHeader = ['country' ];
@track ratingOptions;
  accountRecordTypeId;
  country;
  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  results({ error, data }) {
    if (data) {
      this.accountRecordTypeId = data.defaultRecordTypeId;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.accountRecordTypeId = undefined;
    }
  }
  @wire(getPicklistValues, { recordTypeId: "$accountRecordTypeId", fieldApiName: country_field })
  picklistResults({ error, data }) {
    if (data) {
     // this.CountryList= data.values;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.country = undefined;
    }
  }


  showPopUp(){
    this.isShowCoutryPopUp=true;
  }
  ///////c/accessLevelCheckLwcJS -
// Import getRatingPicklistValues function from Apex controller
// Wire getRatingPicklistValues function from Apex controller to the component
    @wire(getRatingPicklistValues, {})
    // Define a wired property for rating picklist values
    wiredRatingPicklistValues({ error, data }) {
        // If data is returned from the wire function
        if (data) {
            // Map the data to an array of options
            this.ratingOptions = data.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
            this.CountryList=json.stringify(this.ratingOptions);
        }
        // If there is an error
        else if (error) {
            // Log the error to the console
            console.error(error);
        }
    }

  downloadcountrylist(){
    let csvDoc = '"' + this.columnHeader + '"' ;

    // Add rows from ratingOptions
    this.ratingOptions.forEach(record => {
        // Ensure proper escaping for CSV values
        const row = [
            '"' + record.label + '",' // Assuming record has a 'value' field
        ]
        csvDoc += '\n' + row;
      });

      let universalBOM = '\uFEFF';	
      var element = "data:text/csv;charset=utf-8,"  + encodeURI(universalBOM + csvDoc); //+ encodeURIComponent(doc);
      let downloadElement = document.createElement("a");
      downloadElement.href = element;
      downloadElement.target = "_self";
  
      downloadElement.download = "CountryList.csv";
      document.body.appendChild(downloadElement);
      downloadElement.click();
  }
  // this method is used to download the template
  downloadBulkInviteTemplateFile() {
    let doc = "";
    this.columnNames.forEach((element) => {
      doc += element + ",";
    });

    let universalBOM = '\uFEFF';	
    var element = "data:text/csv;charset=utf-8,"  + encodeURI(universalBOM + doc); //+ encodeURIComponent(doc);
    let downloadElement = document.createElement("a");
    downloadElement.href = element;
    downloadElement.target = "_self";

    downloadElement.download = "Bulk Invite Template.csv";
    document.body.appendChild(downloadElement);
    downloadElement.click();
    this.isShowCoutryPopUp=false;
  }
  closeModal(){ 
    this.isShowCoutryPopUp=false;
    
  }
}