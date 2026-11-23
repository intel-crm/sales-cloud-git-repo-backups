import { LightningElement, track, api } from 'lwc';
import uId from '@salesforce/user/Id';
import getUserRecord from '@salesforce/apex/Core_IPS_UserInfoCtrl.fetchUser';
import getFormatedLabel from '@salesforce/apex/Core_IPS_UserInfoCtrl.formatLabels';
import getCustomSetting from '@salesforce/apex/Core_IPS_UserInfoCtrl.fetchCustomSetting';
import fetchCustomSettingHierarchy from '@salesforce/apex/Core_IPS_UserInfoCtrl.fetchCustomSettingHierarchy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import getLoggedInPermissonSet from '@salesforce/apex/core_IPS_getPermssionSetName_Ctrl.getLoggedInPermissonSets';
export default class Core_IPS_GlobalSearch_LWC extends NavigationMixin(LightningElement) {
    //Current UserId
    userId = uId;
    @track UserName;
    @track userRecord;
    @track userFirstName;
    @track userWelcomMsg;
    @track error;
    @track customSettingData;
    @track bannerMsgOne;
    @track bannerMsgTwo;
    @track bannerMsgThree;
    booleanOne = false;
    booleanTwo = false;
    booleanThree = false;
    booleanNull = false;
    bannerList;
    constructor() {
        super();
        this.getUserData();
        this.getFormatedData();
    }
    getUserData() {
        getUserRecord()
            .then(result => {
                this.userRecord = result;
                this.userFirstName = result.FirstName;
                this.UserName = result.Name;
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting UserInfo',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.userRecord = undefined;

            });
    }
    getFormatedData() {
        getFormatedLabel()
            .then(result => {
                this.userWelcomMsg = result;
            })
            .catch(error => {
                this.error = error;
            });
    }
    @api searchValue;
    @api casedatainfo;
    renderedCallback() {
    }
    // // update searchValue var when input field value change
    //Added by chetan as part of slow execution
    delayTimeout
    searchKeyword(event) {
        //Added by chetan as part of slow execution
        this.searchValue = event.target.value;
        if(this.searchValue.length > 3){
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
           this.handlesubject(event);
        }, 300);}
        
        //this.handlesubject(event);
    }
    
    // Creates the event with the data.
    handlesubject(event) {
        console.log('CK>> 1 sent2');
        const selectedEvent = new CustomEvent("searchvaluechange", {
            detail: this.searchValue,
        });
        // // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    AdvhandleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'advance-search'
            },
        });
    }
    @track isDddAvailable = false;
    permissionSetNames;
    async getLoggedInPermissonSetOfUser() {
        await getLoggedInPermissonSet()
            .then(res => {
                console.log('inside then getloggedinpermissonset');
                this.permissionSetNames = res.map(rec => {
                    if (rec.PermissionSet.Label.includes('DDR Permission Set')) {
                        console.log('inside if ddr available true');
                        this.isDddAvailable = true;
                    }
                    return rec.PermissionSet.Label
                });
            })
            .catch(err => {
                console.error(err);
            })
    }
    ddrBannerActive = false;
    onLoad() {
        fetchCustomSettingHierarchy()
        .then(async (result) => {
            console.log('OUTPUT : result fetchCustomSettingHierarchy',result);
        }).catch(err=>{
             console.log('OUTPUT : error fetchCustomSettingHierarchy',result);
        })
        getCustomSetting()
            .then(async (result) => {
                console.log('OUTPUT : result',result);
                result = await result.filter(element => {
                    if (element.Core_Ips_BannerMessage_Text_LWC__c.includes('partners.intel.com/DDR/') == true && this.isDddAvailable == false) {
                        return false;
                    } else {
                        return true;
                    }
                })
                if (result.length == 3) {
                    this.bannerMsgOne = result[0].Core_Ips_BannerMessage_Text_LWC__c;
                    this.bannerMsgTwo = result[1].Core_Ips_BannerMessage_Text_LWC__c;
                    this.bannerMsgThree = result[2].Core_Ips_BannerMessage_Text_LWC__c;
                    this.booleanThree = true;
                }
                if (result.length == 2) {
                    this.bannerMsgOne = result[0].Core_Ips_BannerMessage_Text_LWC__c;
                    this.bannerMsgTwo = result[1].Core_Ips_BannerMessage_Text_LWC__c;
                    this.booleanTwo = true;
                }
                if (result.length == 1) {
                    this.bannerMsgOne = result[0].Core_Ips_BannerMessage_Text_LWC__c;
                    this.booleanOne = true;
                }
                if (result.length == 0) {
                    this.booleanNull = true;
                }
            });
    }
    async connectedCallback() {
        await this.getLoggedInPermissonSetOfUser();
        this.onLoad();
    }
}