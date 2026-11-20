import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserRecord from '@salesforce/apex/Core_IPS_UserInfoCtrl.fetchUser';
import PortalSiteURL from '@salesforce/label/c.Core_IPS_PortalSiteURL_LWC';
import redirectAutomate from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.redirectAutomate';
export default class Core_IPS_Header_LWC extends NavigationMixin(LightningElement) {

    @track isActive;
    @track isMobileView = false;
    @track userName;
    @track userNameTooltip;
    @track error;
    constructor() {
        super();
        this.getUserData();
    }
    connectedCallback() {

        redirectAutomate()
            .then((result) => {
                if (result == 'success') {
                    this.isActive = true;
                }
                if (result == 'fail') {
                    this.isActive = false;
                }
            })
            .catch((error) => {

            });
    }
   //get the user data from server
    getUserData() {
        getUserRecord()
            .then(result => {
                this.userName = result.Name;
                this.userNameTooltip = result.Name;
                this.userName = this.text_truncate(result.Name, null, null);
            })
            .catch(error => {
                this.error = error;
                this.userRecord = undefined;
            });
    }

    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
        sessionStorage.removeItem('ProjectDetail');
        sessionStorage.removeItem('ProjectCase');
    }

    navigateToPreference() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'preferencepage'
            },
        });
    }
    DomainUrl;
    finalUrl;


    handleLogout() {
        const url = '/'+PortalSiteURL+'/secur/logout.jsp';
        const hostUrl1 = window.location.origin;
        const hostUrl = encodeURI(hostUrl1);
        this.DomainUrl = hostUrl.concat(url);
        window.location.replace(this.DomainUrl); //Added for Vulnerability issue


    }

    /* Page name from Url */
    currentPageReference = null;
    currentPageName = null;
    caseDetailPage = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentPageName = currentPageReference.attributes.name;
            if (this.currentPageName == 'Core_IPS_CaseDetail__c' ||
                this.currentPageName == 'project_detail__c' ||
                this.currentPageName == 'Core_IPS_NewProject__c' ||
                this.currentPageName == 'Core_IPS_NewCase__c' ||
                this.currentPageName == 'Core_IPS_ProductDetail__c' ||
                this.currentPageName == 'Core_IPS_CaseAdvanceSearch__c' ||
                this.currentPageName == 'Core_IPS_AttachmentUpload_LWC__c' ||
                this.currentPageName == 'Core_IPS_PreferencePage__c') {
                this.caseDetailPage = true;
            }
        }
    }
    text_truncate(str, length, ending) {
        if (length == null) {
            length = 15;
        }
        if (ending == null) {
            ending = '...';
        }
        if (str.length > length) {
            return str.substring(0, length - ending.length) + ending;
        } else {
            return str;
        }
    };
}