import { LightningElement, track } from 'lwc';
import INTEL_LOGO from '@salesforce/resourceUrl/intelFooterLogo';
import redirectAutomate from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.redirectAutomate';
import FacebookIcon from '@salesforce/label/c.Core_IPS_FacebookIcon_LWC';
import InstagramIcon from '@salesforce/label/c.Core_IPS_InstagramIcon_LWC';
import IntelCookies from '@salesforce/label/c.Core_IPS_IntelCookies_LWC';
import IntelPrivacy from '@salesforce/label/c.Core_IPS_IntelPrivacy_LWC';
import IntelSiteMap from '@salesforce/label/c.Core_IPS_IntelSiteMap_LWC';
import IntelSupplyChainTransparency from '@salesforce/label/c.Core_IPS_IntelSupplyChainTransparency_LWC';
import IntelTermsofUse from '@salesforce/label/c.Core_IPS_IntelTermsofUse_LWC';
import IntelTrademarks from '@salesforce/label/c.Core_IPS_IntelTrademarks_LWC';
import LinkdinIcon from '@salesforce/label/c.Core_IPS_LinkdinIcon_LWC';
import TwitterIcon from '@salesforce/label/c.Core_IPS_TwitterIcon_LWC';
import YoutubeIcon from '@salesforce/label/c.Core_IPS_YoutubeIcon_LWC';
import FooterCommunities from '@salesforce/label/c.Core_IPS_FooterCommunities_LWC';
import FooterCompanyInfo from '@salesforce/label/c.Core_IPS_FooterCompanyInfo_LWC';
import FooterOurCommitment from '@salesforce/label/c.Core_IPS_FooterOurCommitment_LWC';
import IntelDiversity from '@salesforce/label/c.Core_IPS_IntelDiversity_LWC';
import IntelContactUs from '@salesforce/label/c.Core_IPS_IntelContactUs_LWC';
import IntelInvestorRelations from '@salesforce/label/c.Core_IPS_IntelInvestorRelations_LWC';
import IntelJobs from '@salesforce/label/c.Core_IPS_IntelJobs_LWC';
import IntelNewsRoom from '@salesforce/label/c.Core_IPS_IntelNewsRoom_LWC';
import getLoggedInPermissonSet from '@salesforce/apex/core_IPS_getPermssionSetName_Ctrl.getLoggedInPermissonSets';
export default class Core_IPS_Footer_LWC extends LightningElement {
    intelLogoUrl = INTEL_LOGO;
    label = {
        FacebookIcon,
        InstagramIcon,
        IntelCookies,
        IntelPrivacy,
        IntelSiteMap,
        IntelSupplyChainTransparency,
        IntelTermsofUse,
        IntelTrademarks,
        LinkdinIcon,
        TwitterIcon,
        YoutubeIcon,
        FooterCommunities,
        FooterCompanyInfo,
        FooterOurCommitment,
        IntelDiversity,
        IntelContactUs,
        IntelInvestorRelations,
        IntelJobs,
        IntelNewsRoom
    };
    @track isActive;
    onlyDdrUser = false;
    async connectedCallback() {
        await this.getLoggedInPermissonSetOfUser();
        let perSet = this.permissionSetNames;
        if (perSet.includes('DDR Permission Set')) {
            if (!perSet.includes('IPS Permission Set') && !perSet.includes('IPS Partner FAE Permission Set')) {
                this.onlyDdrUser = true;
                location.href = 'https://partners.intel.com/DDR';
                return;
            }
        }
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
                console.log('error in redirectAutomate'+JSON.stringify(error));
            });
    }
    permissionSetNames;
    async getLoggedInPermissonSetOfUser() {
        await getLoggedInPermissonSet()
            .then(res => {
                this.permissionSetNames = res.map(rec => {
                    return rec.PermissionSet.Label
                });
            })
            .catch(err => {
                console.log('error in getLoggedInPermissonSetOfUser'+JSON.stringify(err));
            })
    }

}