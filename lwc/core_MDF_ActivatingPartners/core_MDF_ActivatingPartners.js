import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchCampToActPartnerData from '@salesforce/apex/Core_MDF_CampaignCreatePage.fetchCampToActPartnerData';
// import campaignId from '@salesforce/schema/Campaign.Id';


export default class Core_MDF_ActivatingPartners extends NavigationMixin(LightningElement)  {
    actPartnersData =[];
    @api recordId;
    campId = this.recordId;
    // campId = campaignId;

    connectedCallback() {
        this.fetchCampToActPartnerRecord(this.campId);
    }

    checkForUndefinedEmptyAndNull(input) {
        if (input !== undefined && input !== null && input !== "") {
            return true;
        } else {
            return false;
        }
    }

    fetchCampToActPartnerRecord(campId) {// Camp to ISV Mapping
        console
        fetchCampToActPartnerData({ campaignId: campId })
            .then(result => {
                console.log('Check', result);
                let campToActPartners = result;
                if (this.checkForUndefinedEmptyAndNull(campToActPartners) && campToActPartners !== {} && Object.keys(campToActPartners).length > 0) {
                    selectedISVAccounts;
                    campToActPartners.forEach(CampToActPart => {
                        selectedISVAccounts = {
                            accountId : CampToActPart.accountId,
                            accName : CampToActPart.accName,
                            url : this.navigateToAccountPage(CampToActPart.accountId)
                        }
                        this.actPartnersData.push(selectedISVAccounts);
                        console.log('selectedISVAccounts 30:',JSON.stringify(selectedISVAccounts));
                    });

                }
                console.log('this.actPartnersData 34:',JSON.stringify(this.actPartnersData));
            })
            .catch(error => {
                console.log('error in fetchCampToActPartnerData', error);
            })
    }
    onAccountClick(event){

    }
    navigateToAccountPage(accId) {
        let urlredirect;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        }).then(url => {
            urlredirect = url;
        });
        return urlredirect;
 }
}