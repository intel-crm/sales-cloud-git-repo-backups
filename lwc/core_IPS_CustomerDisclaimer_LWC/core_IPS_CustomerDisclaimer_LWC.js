import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDocData from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.getDocData';
import getRedirected from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.getRedirected';

export default class Core_IPS_CustomerDisclaimer_LWC extends NavigationMixin(LightningElement) {
    finalDocData;

    // On component load, fetch the disclaimer document content
    connectedCallback() {
        this.getDocBody();
    }

    // Fetch the document body data from Apex controller
    getDocBody() {
        getDocData()
            .then((result) => {
                var docBody = result;
                // Replacing the style with justified text
                this.finalDocData = docBody.replaceAll("class=MsoNormal style='margin-bottom", "class=MsoNormal style='text-align: justify; margin-bottom");
            })
            .catch((error) => {
                console.error("Error fetching document data", error);
            });
    }

    @track showPage = false;

    // Handle Accept Button Click
    getRedirect() {
        getRedirected()
            .then((result) => {
                if (result == 'success') {
                    this.showPage = true;
                    // Redirect to the home page
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
                console.error("Error during redirection", error);
            });
    }

    finalUrl;

    // Handle Cancel Button Click
    handleCancel() {
        const logincurl = '/LightningIPS/s/login/?ec=302&startURL=%2FLightningIPS%2Fs%2F';
        const orginUrl1 = window.location.origin;
        const orginUrl = encodeURI(orginUrl1);
        this.finalUrl = orginUrl.concat(logincurl);
        window.location.replace(this.finalUrl); // Redirect to login page
    }
}