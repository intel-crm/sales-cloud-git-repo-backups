import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
export default class Ignore_vamshiTimeZonecmp extends LightningElement {
    @track timeZoneName;
    @api objectApiName = 'User';
    @api recordId;
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Name', 'User.TimeZoneSidKey', 'User.Id'] })
    userData({ error, data }) {
        if (data) {
            console.log('In wire method for time zone');
            let objCurrentData = data.fields;
            this.timeZoneName = objCurrentData.TimeZoneSidKey.value;
            this.recordId = objCurrentData.Id.value;
            console.log("TimeZone we got " + this.timeZoneName);
            console.log("objCurrentData " + JSON.stringify(objCurrentData));
        } else if (error) {
            console.log('error ====> ' + JSON.stringify(error))
        }
    }
}