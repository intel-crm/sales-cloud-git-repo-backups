import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import apexMethod from '@salesforce/apex/Core_MDF_PartnerFundClaim.getDocumentData1';


// Define the fields you want to retrieve
const FIELDS = [
    'ContentVersion.Title',
    'ContentVersion.FileType',
    'ContentVersion.VersionNumber',
    'ContentVersion.VersionData',
    'ContentVersion.LastModifiedDate'
];


export default class Testcontentversion extends LightningElement {
    recordId = '068Dz000002OHFRIA4';//contentVersion Small: 068Dz000002OHFRIA4  Big: 068Dz000002OHebIAG
    isLoading = true;

    title;
    fileType;
    versionNumber;
    versionData;
    lastModifiedDate;

    //@wire(apexMethod, { docId : '$recordId' ,versionData : '$versionData' }) propertyOrFunction;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    contentVersionHandler({ error, data }) {
        if (data) {
            this.title = data.fields.Title.value;
            this.fileType = data.fields.FileType.value;
            this.versionNumber = data.fields.VersionNumber.value;
            this.versionData = data.fields.VersionData.value;
            this.lastModifiedDate = data.fields.LastModifiedDate.value;
            this.isLoading = false;
            this.callApexAfterRecordApi();
        } else if (error) {
            console.error('Error retrieving ContentVersion record:', error);
            this.isLoading = false;
        }
    }

    callApexAfterRecordApi() {
        apexMethod({ docId: this.recordId, versionData: this.versionData })
            .then(result => {
                console.log('Apex method result:', result);
                // Do something with the result
            })
            .catch(error => {
                console.error('Error calling Apex method:', error);
            });
    }
}