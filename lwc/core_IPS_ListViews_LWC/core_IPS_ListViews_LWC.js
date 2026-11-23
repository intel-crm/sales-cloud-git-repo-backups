import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllContacts from '@salesforce/apex/Core_IPS_ListViewsCtrl_LWC.getAllContacts';
//import getContacts from '@salesforce/apex/Core_IPS_ListViewsCtrl_LWC.getContacts';


const contactColumns = [
    { label: 'Name', fieldName: 'Name', type: 'text', },
    { label: 'Account', fieldName: 'AccountName', type: 'text', },
    { label: 'Contact Owner Alias', fieldName: 'OwnerName', type: 'text', },
    { label: 'Email', fieldName: 'Email', type: 'text', },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'text', },
];

export default class Core_IPS_ListViews_LWC extends NavigationMixin(LightningElement) {

 //connectedCallback() {
//    this.RefreshValues();
 //}
    // async RefreshValues() {
    //     await new Promise(resolve => setTimeout(resolve, 1500));
    //     this.getContacts('Load Data');
    //     this.getContacts('All Data');
    // }

    //All Datatable Columns 
    @track contactColumns = contactColumns;

    // show & hide sections starts here
    @track selectedItem = 'allCases';
    cases = false;
    projects = false;
    products = false;
    contacts = false;

    isLoading=false;
    // show & hide sections ends here

    // SwitchViews Start
    switchContactView;
    // SwithcView Ends

    //Stores data from apex start
    @track caseRecords;
    initialRecords;
    @track projectRecords;
    projectInitialRecords;
    @track productRecords;
    productInitialRecords;
    @track contactRecords=[];
    contactInitialRecords;
    contactSearchRec;
    @track error;
    //Stores data from apex end

    //List views on each obj start
    @track casevalue = 'allCases';
    @track projectvalue = 'allProjects';
    @track productvalue = 'activeproducts';
    @track contactvalue = 'myContacts';
    //List views on each obj end

    //handle navigation selections
    handleSelect(event) {
        const selected = event.detail.name;
        this.currentContent = selected;
        if (selected == 'allCases') {
            this.cases = true;
        } else {
            this.cases = false;
        }
        if (selected == 'allProjects') {
            this.projects = true;
        } else {
            this.projects = false;
        }
        if (selected == 'intelProducts') {
            this.products = true;
        } else {
            this.products = false;
        }
        if (selected == 'allContacts') {
            this.contacts = true;
        } else {
            this.contacts = false;
        }

    }
    //all listview options
    get caseoptions() {
        return [
            { label: 'Sort Cases', value: 'sortCases' },
            { label: 'All Cases', value: 'allCases' },
            { label: 'My Open Cases', value: 'myOpenCases' },
            { label: 'My Closed Cases', value: 'myClosedCases' },
            { label: 'My Recently Created Cases', value: 'myRecentlyCreatedCases' },
            { label: 'My Recently Modified Cases', value: 'myRecentlyModifiedCases' },
            { label: 'My Recently Viewed Cases', value: 'myRecentlyViewedCases' },
            { label: 'My Recently Closed Cases', value: 'myRecentlyClosedCases' },
            { label: 'My Interested Party Cases', value: 'myInterestedPartyCases' },
        ];
    }
    get projectoptions() {
        return [
            { label: 'All Projects', value: 'allProjects' },

        ];
    }
    get productoptions() {
        return [
            { label: 'My Active Products', value: 'activeproducts' },
            { label: 'All Intel Products', value: 'allproducts' },
        ];
    }
    get contactoptions() {
        return [
            { label: 'My Contacts', value: 'myContacts' },
            { label: 'All Contacts', value: 'allcontacts' },
            { label: 'New This Week', value: 'newThisWeek' },
            { label: 'Recently Viewed Contacts', value: 'recentlyViewedContacts' },
        ];
    }
    //handle Listview selections
    handleCaseNavigation(event) {
        this.casevalue = event.detail.value;
        console.log('YOU CLICKED : ', this.casevalue);
        this.getCases();
    }
    handleProjectNavigation(event) {
        this.projectvalue = event.detail.value;
        console.log('YOU CLICKED : ', this.projectvalue);
    }
    handleProductNavigation(event) {
        this.productvalue = event.detail.value;
        console.log('YOU CLICKED : ', this.productvalue);
        this.getProducts();
    }
    handleContactNavigation(event) {
        this.contactvalue = event.detail.value;
        console.log('YOU CLICKED : ', this.contactvalue);
        this.getContacts('All Data');
    }

    //common search method for all tables
    handleKeyChange(event) {
        const searchKey = event.target.value.toLowerCase();
        const searchFieldName = event.target.className;
        if (searchFieldName.includes('contactSearch')) {
            this.searchContacts(searchKey, this.contactInitialRecords);
        }
    }

    rowLimitContact = 20;
    rowOffSetContact = 0;

    getContacts(message) {
        let type = message;
        console.log('MY ALL CONTACTS');
        return getAllContacts({
           contactlistValues: this.contactvalue,
            offset: this.rowOffSetContact,
            limitSize: this.rowLimitContact,
            fetchType: type
        })
        .then(result => {
           
                
                //let cData =JSON.stringify(result);
                // cData.forEach(function (item) {
                //     item.AccountName = item.Account != undefined ? item.Account.Name : '';
                //     item.OwnerName = item.Owner != undefined ? item.Owner.Alias : '';
                // });
                //console.log('cData',cData);
                let updatedRecords = [...this.contactRecords, ...result];
                this.contactRecords = updatedRecords;
                this.error = undefined;
            console.log('result',this.contactRecords);

                //this.contactRecords = cData;
                //this.contactInitialRecords = cData;
                this.switchContactView = true;

                
            
            console.log('CONTACT DATA', this.contactRecords);

                
            

        })
        .catch(error => {
            this.error = error;
            console.log('Contact Error ', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting Contacts',
                    message: error.message,
                    variant: 'error'
                }),
            );
            this.contactRecords = undefined;
        });
    }
    searchContacts(contactSearchStr, conData) {
        if (contactSearchStr) {
            this.contactRecords = conData;
            if (this.contactRecords) {
                let recs = [];
                for (let rec of this.contactRecords) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(contactSearchStr)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.contactSearchRec = recs;
                this.switchContactView = false;
            }
        } else {
            this.switchContactView = true;
            this.contactRecords = this.contactInitialRecords;
        }

    }


    handleLoadMoreContacts(event) {

        const currentRecord = this.contactRecords;
       const newData=currentRecord.concat(this.contactRecords);
         this.contactRecords=newData;

        const { target } = event;
        target.isLoading = true;
        this.isLoading=true;
        this.rowOffSetContact = this.rowOffSetContact + this.rowLimitContact;
        //const myTimeout = setTimeout(getContacts, 3000);
        //clearTimeout(myTimeout);


        this.getContacts(20)
            .then(() => {
                target.isLoading = false;
                this.isLoading=false;

            });
            

    }

}