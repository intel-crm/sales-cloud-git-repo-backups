import { LightningElement, track, wire } from 'lwc';
import getEmailPrefer from '@salesforce/apex/Pricing_ManageEmailPreference.getEmailPreference';
import savePreference from '@salesforce/apex/Pricing_ManageEmailPreference.savePreferences';
import getUserPemissionSet from '@salesforce/apex/Pricing_ManageEmailPreference.getUserPemissionSets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';

export default class Pricing_ManageEmailPreference extends LightningElement {
    @track notificationOptMap = [];
    @track isTender;
    @track isSpinner = true;

    @wire(getEmailPrefer)
    wiredPrefer({ error, data }) {
        if (data) {
            if (data.length > 0) {
                for (let i = 0; i < data.length; i++) {
                    this.notificationOptMap.push({ notificationName: data[i].notificationName, optInOut: data[i].optInOut, errorMsg: data[i].errorMsg });
                }
            }
            console.log('notification map-->' + JSON.stringify(this.notificationOptMap));
        } else if (error) {
            console.log('error-->' + JSON.stringify(error));
        }
    }


    onOptinToggle(event) {
        console.log(event.target.name);
        const notifyName = event.target.name;
        for (let i = 0; i < this.notificationOptMap.length; i++) {
            if (this.notificationOptMap[i].notificationName === notifyName) {
                this.notificationOptMap[i].optInOut = !this.notificationOptMap[i].optInOut;
            }
        }
    }

    handleSave() {
        console.log(JSON.stringify(this.notificationOptMap));
        savePreference({ jsonMap: JSON.stringify(this.notificationOptMap) })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Saved Successfully',
                        variant: 'success',
                    }),
                );
            })
            .catch((error) => {
                console.log('Error=>', JSON.stringify(error));
            });
    }

    connectedCallback() {
        console.log('inside connected call back ' + userId);
        this.getUserPermissionSets(userId);
    }

    getUserPermissionSets(userId) {
        getUserPemissionSet({ userId: userId })
            .then(result => {
                console.log("PermissionSets:" + JSON.stringify(result));
                if (result === true) {
                    this.isTender = true;
                    this.isSpinner = false;
                } else if (result === false) {
                    this.isTender = false;
                    this.isSpinner = false;
                }
                console.log("is tender user:", this.isTender);
            })
            .catch(error => {
                console.log('Error Updating Records', JSON.stringify(error), 'error');
            })
    }
}