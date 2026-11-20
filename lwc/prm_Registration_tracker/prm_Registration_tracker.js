import { LightningElement, api, wire, track } from 'lwc';

import getTrackers from '@salesforce/apex/PRM_RegistrationTrackerUtility.getTrackers';
import isCidaas from '@salesforce/label/c.PRM_CiDaaS_Enabled';
export default class Prm_Registration_tracker extends LightningElement {
    @track searchKey = '';
    @api recordId;
    @track wrapper = '';
    @track cidaasenabled = false;
    @track hasData = false;



    // @wire(getTrackers, { regid: '$searchKey' })
    // trackers(result) {
    //     console.log('log -->', result.data);
    //     if (result.data) {
    //         this.wrapper = result.data;
    //         this.cidaasenabled = (isCidaas.toLowerCase() == 'true' || this.wrapper.admin) ? true : false;
    //         console.log(' Cidaas -->' + this.cidaasenabled);
    //     }
    //     if (result.error) {
    //         console.log('Error -->', result.error);
    //     }
    // }

    getTrackersRecords() {
        getTrackers({ regid: this.searchKey }).then(result => {
            if (result) {
                console.log('Result -->', result);
                this.wrapper = result;
                this.hasData = true;
                this.cidaasenabled = (isCidaas.toLowerCase() == 'true' || this.wrapper.admin) ? true : false;
                console.log(' Cidaas -->', this.cidaasenabled);
            }
        }).catch(error => {
            console.log('exception ->', error);
        })
    }

    connectedCallback() {
        this.searchKey = this.recordId;
        this.getTrackersRecords();
    }

}