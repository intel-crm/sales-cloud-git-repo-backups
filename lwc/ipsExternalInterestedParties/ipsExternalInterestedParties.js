/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecordhandle from "@salesforce/apex/ipsInternalCaseCreateLWCController.saveInternalInterestedParty";

export default class IpsExternalInterestedParties extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        console.log('data => ', JSON.stringify(pageRef));
    }

    @track isLookupQueryPresentProject = false;
    @track lookupIconNameProject = "standard:Account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track conId;
    @track lookupCountQueryString;

    @api
    message;
    @track
    title;
    @api
    type;
    @api isLoaded;
    @api recordId;
    @api recordDataId;
    connectedCallback() {

        //  this.getActiveConIds();
    }
    renderedCallback() {

        this.lookupQueryStringProject = 'select Id, firstName, LastName, Email, Name, AccountId, Account.Name  from Contact where ((Name like :key OR FirstName like :key OR LastName like :key OR Email like :key)  AND (Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false)) limit 999';
        this.lookupCountQueryString = 'select count() from from Contact where ((Name like :key OR FirstName like :key OR LastName like :key OR Email like :key)  AND (Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false)) ';
        this.isLookupQueryPresentProject = true;

    }
    handleChangeCon(event) {
        console.log('RecordIddd' + JSON.stringify(event.detail.recordId));
        console.log('Record Data' + JSON.stringify(event.detail.record));
        if (event.detail.record === undefined || event.detail.recordId === undefined) {
            //  this.firstname = event.detail.record.FirstName;
        }
        else {

            //  this.lastname = event.detail.record.LastName;
            //  this.email = event.detail.record.Email;
            this.conId = event.detail.record.Id;

        }
    }
    saveHandler() {
        var ext, nw;
        console.log('test' + this.recordDataId);
        this.isLoaded = true;
        console.log('conId' + this.conId);

        if (this.conId !== null || this.conId !== '' || this.conId.length > 0) {

            console.log('conId' + this.conId);
            if (this.conId === undefined) {
                this.isLoaded = false;

                this.show('Please select contact', 'error');

            }
            else {

                saveRecordhandle({


                    caseId: this.recordDataId,
                    userID: null,
                    contactID: this.conId

                })
                    .then(result => {

                        if (result !== undefined || result !== null || result !== '') {
                            console.log("result" + JSON.stringify(result));
                            this.isLoaded = false;
                            this.navigateToViewCase();
                            this.showToast('Success', JSON.stringify(result), 'Success');
                            let msg = JSON.stringify(result);
                            let re = msg.replace(/"/g, '');

                            ext = "existingcontact";

                            nw = "newcontact";

                            let ans = re.localeCompare(ext.toString());

                            let ans1 = re.localeCompare(nw.toString());

                            if (ans === 0) {
                                this.show('contact is already present in External Interested Party', 'success');

                            } if (ans1 === 0) {
                                console.log('succe');
                                this.show('contact added in External Interested Party', 'success');
                                window.open('/lightning/r/Case/' + this.recordDataId + '/view', '_top');
                            }

                        } else {

                            console.log("result" + JSON.stringify(result));
                        }
                    })
                    .catch(error => {
                        if (error !== undefined) {
                            //this.showToast('ERROR', error1.body.message, 'error');
                            console.log("this.edq" + JSON.stringify(error));
                            this.isLoaded = false;
                            //   this.template.query('c-customtoast').show(error.message || error.body.message, 'error')

                        }

                    });

            }

        }

    }
    cancelHandler(event) {
        this.navigateToViewCase2();
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    navigateToViewCase() {
        console.log('navi', this.recordDataId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordDataId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });

    }
    navigateToViewCase2() {
        console.log('navi2');
        window.open('/lightning/r/Case/' + this.recordDataId + '/view', '_top');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Case/' + this.recordDataId + '/view'
            }
        },
            true // Replaces the current page in your browser history with the URL
        )
            .then(generatedUrl => {
                window.open('/lightning/r/Case/' + this.recordDataId + '/view');
            });

    }
    get notifyClasses() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
    get iconName() {
        return 'utility:' + this.type;
    }
    @api
    show(message, type) {
        this.title = 'success';
        this.message = message;
        this.type = type || 'error';

        const toast = this.template.querySelector('.toast');
        toast.classList.toggle('toast_show');
        toast.classList.toggle('toast_hide');
        this.timer = setTimeout(() => {
            {
                toast.classList.toggle('toast_show');
                toast.classList.toggle('toast_hide');
            }
        }, 3000);
    }
}