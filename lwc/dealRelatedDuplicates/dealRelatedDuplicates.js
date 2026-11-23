import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getDRandDRP from '@salesforce/apex/PCC_Deal_FindRelatedDuplicateDeals.getDRandDRP';
import NAME_FIELD from "@salesforce/schema/Core_Design_Registration__c.Name";
export default class DealRelatedDuplicates extends LightningElement {

    @api recordId;
    @track data;
    @track parentRecord;
    @track breadCrumbsMap = new Map();
    @track myBreadcrumbs = [];
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] }) parentRecordDtials({ error, data }) {
        if (error) {
            console.log('Error ', error);
        }
        if (data) {
            console.log('Data ', data);
            this.parentRecord = data;
            this.myBreadcrumbs.push({ label: this.parentRecord?.fields?.Name?.value, name: this.parentRecord?.fields?.Name?.value, id: this.parentRecord?.id });
            this.breadCrumbsMap.set(this.parentRecord?.fields?.Name?.value, '/' + this.parentRecord?.id);
        }
    }

    @wire(getDRandDRP, { recordId: '$recordId' })
    getRecords({ error, data }) {
        if (error) {
            console.log('Error -->', error);
        }
        if (data) {
            console.log('Data -->', data);
            this.data = data;
            this.data.map(item => {
                this.myBreadcrumbs.push({ label: item?.Name, name: item?.Name, id: item?.Id });
                this.breadCrumbsMap.set(item?.Name, '/' + item?.Id);
            })


        }
    }

    connectedCallback() {
        console.log('Parent record -->', this.parentRecord);
        console.log('Data1 -->', this.data);

    }
    handleNavigateTo(event) {
        // prevent default navigation by href
        //event.preventDefault();

        const name = event.target.name;
        const val = this.breadCrumbsMap.get(name);
        if (val!=null && val!=undefined && val.length >0) {
            // window.location.assign(this.breadCrumbsMap.get(val));
            window.open(val, "_blank");
        }
    }

}