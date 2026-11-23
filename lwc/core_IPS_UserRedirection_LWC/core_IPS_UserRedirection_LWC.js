import { LightningElement, track } from 'lwc';
import pageNotFound from '@salesforce/resourceUrl/pageNotFound';
import { NavigationMixin } from 'lightning/navigation';

import getLoggedInPermissonSet from '@salesforce/apex/core_IPS_getPermssionSetName_Ctrl.getLoggedInPermissonSets';

export default class Core_IPS_UserRedirection_LWC extends NavigationMixin(LightningElement) {
    pageNotFoundImage = pageNotFound;
    permissionSetNames = [];
    @track isLoggedIn;
    @track isDdrUser = false;

    async connectedCallback() {
        await this.getLoggedInPermissonSetOfUser();
        console.log('Names of permisson sets', this.permissionSetNames)
        console.log('name assign', this.assigneName);
        console.log('isDDRuser', this.isDdrUser);
        if (this.assigneName.includes('Site Guest User')) {
            console.log('this is not logged in account');
            this.isLoggedIn = false;
        }
        else {
            console.log('this is logged in');
            this.isLoggedIn = true;
        }
    }

    async getLoggedInPermissonSetOfUser() {
        await getLoggedInPermissonSet()
            .then(res => {
                console.log('permisson set sucess', res);
                console.log('user profile', res[0]?.Assignee?.Name);
                this.assigneName = res[0]?.Assignee?.Name;
                this.permissionSetNames = res.map(rec => {
                    console.log('rec UserRedirection class', rec.PermissionSet.Label);
                    if (rec.PermissionSet.Label.includes('DDR Permission Set')) {
                        console.log('is ddr permisson available');
                        this.navigateToHome();
                        this.isDdrUser = true; 
                    }
                    return rec.PermissionSet.Label
                });
            })
            .catch(err => {
                console.log('error permisson set', err);
            })
    }

    navigateToHome() {
        // this[NavigationMixin.Navigate]({
        //     type: 'comm__namedPage',
        //     attributes: {
        //         pageName: 'home'
        //     },
        // });
        location.href = location.origin + '/IPS/Partnercenter/s/'
    }


}