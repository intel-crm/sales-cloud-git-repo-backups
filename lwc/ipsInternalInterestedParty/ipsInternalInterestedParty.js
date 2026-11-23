/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

const columns = [


    { label: 'FirstName', fieldName: 'FirstName' },
    { label: 'LastName', fieldName: 'LastName' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                {
                    label: 'Add Interested Party',
                    name: 'Add Interested Party'
                }
            ]
        }
    }
];

import getSearchRecords from "@salesforce/apex/ipsInternalCaseCreateLWCController.getUserDetailsBasedOnSearch";
import saveRecordhandle from "@salesforce/apex/ipsInternalCaseCreateLWCController.saveInternalInterestedParty";





export default class ipsInternalInterestedParty extends NavigationMixin(LightningElement) {


    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        console.log('data => ', JSON.stringify(pageRef));
    }
    @track columns = columns;
    @api searchResult = [];
    @track searchvalue;
    @track showsearchresult;
    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 20;
    heightInRem = 14;

    @api selectedRecords = [];
    @track showwrapperresult = true;
    @track firstname;
    @track lastname;
    @track email;
    @track userid;
    @api recorddataId;


    @api isLoaded;
    @track lookupIconNameProject = "standard:Account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track lookupCountQueryString;
    @track isLookupQueryPresentProject = false;

    @api
    message;
    @track
    title;
    @api
    type;
    @track url;

    connectedCallback() {
        if (this.recorddataId) {

            this.relationshipRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recorddataId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            };
            this[NavigationMixin.GenerateUrl](this.relationshipRef)
                .then((url) => {
                    this.url = url;
                });

            console.log('this.recorddataId' + this.recorddataId);
            console.log('url' + this.url);
        }
    }

    renderedCallback() {

        this.lookupQueryStringProject = 'select Id, Name, FirstName, LastName, Email from user where ((FirstName like :key OR LastName like :key OR Email like :key)  AND (IsActive = true)) limit 999';
        this.lookupCountQueryString = 'select count() from user where ((FirstName like :key OR LastName like :key OR Email like :key)  AND (IsActive = true)) ';
        this.isLookupQueryPresentProject = true;

    }
    handleChangeUser(event) {
        console.log('anish' + JSON.stringify(event.detail.recordId));
        console.log('anish' + JSON.stringify(event.detail.record));
        if (event.detail.record === undefined || event.detail.recordId === undefined) {
            //  this.firstname = event.detail.record.FirstName;
        }
        else {

            //  this.lastname = event.detail.record.LastName;
            //  this.email = event.detail.record.Email;
            this.userid = event.detail.record.Id;

        }



    }

    /* searchHandler(event) {
         var inp
         console.log('seach' + event.target.value);
     
     
         inp = this.template.querySelector("lightning-input");
         this.searchvalue = inp.value;
         console.log(inp.value);
         console.log('seach' + this.searchvalue);
     
     
     
         getSearchRecords({
     
             searchValueUser: this.searchvalue
     
         })
             .then(result => {
     
                 if (result !== undefined || result !== null) {
     
     
                     this.searchResult = result;
                     console.log('result' + JSON.stringify(this.searchResult));
                     if (this.searchResult.length > 0) {
                         this.showsearchresult = true;
     
                     }
     
                 }
             })
             .catch(error => {
     
                 if (error !== undefined) {
                     //this.showToast('ERROR', error1.body.message, 'error');
                     console.log("this.edq" + JSON.stringify(error));
                 }
     
             });
     
     
     } */

    /*  handleRowActions(event) {
          console.log(' event.detail.actionName;' + event.detail.actionName);
          console.log(' event.detail.row;' + JSON.stringify(event.detail.row));
     
          const actionName = event.detail.actionName;
          const row = event.detail.row;
          switch (actionName) {
              case 'Add Interested Party':
                  this.addtoselected(row);
                  break;
     
              default:
          }
      }
     
      addtoselected(row) {
          console.log('ans' + row.FirstName);
     
     
     
     
      }
      getSelectedRecords(event) {
     
          var dat = { "selected": event.detail.selectedRows };
          //event.stopPropagation();
     
          console.log('alo' + JSON.stringify(dat));
          console.log('alo2' + JSON.stringify(event.detail.record));
          this.selectedRecords.push(dat);
          console.log('Selected>>' + JSON.stringify(this.selectedRecords));
      }
    */
    saveHandler() {
        var ext, nw;
        console.log('test' + this.recorddataId);
        this.isLoaded = true;
        console.log('userid2' + this.userid);

        if (this.userid !== null || this.userid !== '' || this.userid.length > 0) {

            console.log('userid' + this.userid);
            if (this.userid === undefined) {
                this.isLoaded = false;

                this.show('Please select user', 'error');

            }
            else {

                saveRecordhandle({


                    caseId: this.recorddataId,
                    userID: this.userid,
                    contactID: null

                })
                    .then(result => {

                        if (result !== undefined || result !== null || result !== '') {
                            console.log("result" + JSON.stringify(result));
                            this.isLoaded = false;
                            console.log('nich');
                            this.navigateToViewCase();
                            this.showToast('Success', JSON.stringify(result), 'Success');
                            let msg = JSON.stringify(result);
                            let re = msg.replace(/"/g, '');// remove doubles quotes to using localecompare below

                            ext = "existinguser";

                            nw = "newuser";

                            let ans = re.localeCompare(ext.toString());

                            let ans1 = re.localeCompare(nw.toString());

                            if (ans === 0) {
                                this.show('User is already present in Internal Interested Party', 'error');

                            } if (ans1 === 0) {
                                console.log('succe');
                                this.show('User added in Internal Interested Party', 'success');
                                window.open('/lightning/r/Case/' + this.recorddataId + '/view', '_top');
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

        // event.preventDefault();
        // event.stopPropagation();
        //  this[NavigationMixin.Navigate](this.navigationLinkRef);
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
        console.log('navi');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recorddataId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });

    }
    navigateToViewCase2() {
        console.log('navi2');
        window.open('/lightning/r/Case/' + this.recorddataId + '/view', '_top');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/Case/' + this.recorddataId + '/view'
            }
        },
            true // Replaces the current page in your browser history with the URL
        )
            .then(generatedUrl => {
                window.open('/lightning/r/Case/' + this.recorddataId + '/view');
            });

    }

    //custom toast
    get notifyClasses() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
    get iconName() {
        return 'utility:' + this.type;
    }

    @api
    show(message, type) {
        this.title = 'error';
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