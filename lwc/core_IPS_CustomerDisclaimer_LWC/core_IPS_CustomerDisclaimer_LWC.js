import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDocData from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.getDocData';
import getRedirected from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.getRedirected';
export default class Core_IPS_CustomerDisclaimer_LWC extends NavigationMixin(LightningElement) {
    finalDocData;
    connectedCallback() {
        this.getDocBody();
    }
    handleChange() { }
    getDocBody() {
        getDocData()
            .then((result) => {
                var docBody = result;
                this.finalDocData = docBody.replaceAll("class=MsoNormal style='margin-bottom", "class=MsoNormal style='text-align: justify; margin-bottom");
            })
            .catch((error) => {
            });
    }
    @track showPage = false;
    getRedirect() {
        getRedirected()
            .then((result) => {
                if (result == 'success') {
                    this.showPage = true;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'home'
                        },
                    });
                } else {
                    this.showPage = false;
                }
            })
            .catch((error) => {

            });
    }
    finalUrl;
    handleCancel() {
        const logincurl = '/LightningIPS/Partnercenter/s/login/?ec=302&startURL=%2FLightningIPS%2Fs%2F';
        const orginUrl1 = window.location.origin;
        const orginUrl = encodeURI(orginUrl1);
        this.finalUrl = orginUrl.concat(logincurl);
        window.location.replace(this.finalUrl); //Added for Vulnerability issue   
    }
}