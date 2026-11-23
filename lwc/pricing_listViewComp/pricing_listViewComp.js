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

                if (this.getCookie() == null || this.getCookie() == '' || this.getCookie() == undefined) {
        
                    this.currentFilter = this.listViewOptions[0].label;
                    this.currentFilterValue = this.listViewOptions[0].value;
                    this.currentFilterId = this.listViewOptions[0].Id;                    
                    this.createCookie(this.itemTitle, this.currentFilterValue, 365);
                }
                else {

                    this.currentFilterValue = this.getCookie();
                    this.listViewOptions.forEach(e => {
                        if (e.value == this.currentFilterValue) {
                            this.currentFilter = e.label;
                            this.currentFilterId = e.Id;
                        }
                    });
                }

                this.mainListView = window.location.origin + '/lightning/o/' + this.objectAPI + '/list?filterName=' + this.currentFilterId;

                this.isLoading = false;
                this.loadTable = true;
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    createCookie(name, value, days) {
        var expires;

        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toGMTString();
        } else {
            expires = "";
        }

        document.cookie = name + "=" + value + expires + "; path=/";
    }

    getCookie() {
        var cookieVal = this.retriveCookie();
        var listViewItemName;
        if (cookieVal != '') {
            for(let i=0; i< cookieVal.length; i++)
            {
                if(cookieVal[i].includes(this.itemTitle))
                {
                    let value = cookieVal[i].split('=');
                    listViewItemName = value[1];
                }
            }
        } else {
            listViewItemName = '';
        }

        return listViewItemName;
    }

    retriveCookie() {
    
        var cookieString = decodeURIComponent(document.cookie);
        var cookieStrArray = cookieString.split("; ");
        return cookieStrArray;
    }

    handleFilterChangeButton(event) {

        this.loadTable = false;
        this.isLoading = true;

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

            this.createCookie(this.itemTitle, this.currentFilterValue, 365);
            this.mainListView = window.location.origin + '/lightning/o/' + this.objectAPI + '/list?filterName=' + this.currentFilterId;
        }
        
        this.loadTable = true;
        this.isLoading = false;
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