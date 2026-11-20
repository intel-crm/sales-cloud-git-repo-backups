import { LightningElement, wire, api, track } from 'lwc';
import loginUserId from '@salesforce/user/Id';
import getListViewValues from '@salesforce/apex/pricing_HomePageController.getListViewValues';

export default class Pricing_listViewComp extends LightningElement {

    @api objectAPI;
    @api listOfItemTitle;

    @track userId = loginUserId;

    @track itemTitle;
    @track listViewOptions = [];
    @track currentFilter;
    @track currentFilterValue;
    @track currentFilterId;
    @track mainListView;

    @track isLoading = true;
    @track loadTable = false;
    @track isExpanded = false;

    connectedCallback() {

        this.itemTitle = this.listOfItemTitle.replace(/ /g, '_') + this.userId;

        getListViewValues({ objectApiName: this.objectAPI })
            .then(result => {

                this.listViewOptions = JSON.parse(JSON.stringify(result));
                this.listViewOptions.forEach(option => {

                    option['label'] = option['Name'];
                    option['value'] = option['DeveloperName'];
                    delete option.Name;
                    delete option.DeveloperName;
                });
                
                if (localStorage.getItem(this.itemTitle) == null || localStorage.getItem(this.itemTitle) == '' || localStorage.getItem(this.itemTitle) == undefined) {

                    this.currentFilter = this.listViewOptions[0].label;
                    this.currentFilterValue = this.listViewOptions[0].value;
                    this.currentFilterId = this.listViewOptions[0].Id;
                    localStorage.setItem(this.itemTitle, this.currentFilterValue);

                } else {
                    this.currentFilterValue = localStorage.getItem(this.itemTitle);
                    this.listViewOptions.forEach(e => {
                        if (e.value == this.currentFilterValue) {
                            this.currentFilter = e.label;
                            this.currentFilterId = e.Id;
                        }
                    });
                }

                this.mainListView = '/lightning/o/' + this.objectAPI + '/list?filterName=' + this.currentFilterId;

                this.isLoading = false;
                this.loadTable = true;
            })
            .catch(error => {
                console.log('Error:', error);
            });
    }

    handleFilterChangeButton(event) {

        this.loadTable = false;
        let filter = event.target.dataset.filter;
        this.isExpanded = !this.isExpanded;

        if (filter !== this.currentFilterValue) {

            this.currentFilterValue = event.target.dataset.filter;
            this.listViewOptions.forEach(e => {

                if (e.value == this.currentFilterValue) {

                    this.currentFilter = e.label;
                    this.currentFilterId = e.Id;
                }
            });

            localStorage.setItem(this.itemTitle, this.currentFilterValue);
            this.mainListView = '/lightning/o/' + this.objectAPI + '/list?filterName=' + this.currentFilterId;
            this.loadTable = true;

        } else {

            this.loadTable = false;
            this.loadTable = true;
        }
    }

    get dropdownTriggerClass() {
        if (this.isExpanded) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open'
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view'
        }
    }

    handleClickExtend() {
        this.isExpanded = !this.isExpanded;
    }
}