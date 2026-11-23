import { LightningElement, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import profileAdmin from './profileAdmin.html';
import profileMarketingSpecialist from './profileMarketingSpecialist.html';
import upgradePartnerAdmin from './upgradePartnerAdmin.html';

import welcomeHeadingPA from '@salesforce/label/c.PMP_Storefront_Profile_Heading';
import highlightCompany from '@salesforce/label/c.PMP_Storefront_Welcome_Highlight';
import setupProfile from '@salesforce/label/c.PMP_Storefront_Profile_Button';
import didYouKnow from '@salesforce/label/c.PMP_Storefront_ProfilePopUp_Footer';
import intelUrl from '@salesforce/label/c.PMP_Intel_Profile_Url';
import welcomeHeadingMS from '@salesforce/label/c.PMP_Storefront_Welcome_Title_MS';
import getStarted from '@salesforce/label/c.PMP_Storefront_Welcome_Get_Started';
import highlightCompanyEnhanced from '@salesforce/label/c.PMP_Storefront_Welcome_Highlight_Enhanced';
import popUpFooterLink from '@salesforce/label/c.PMP_Storefront_ProfilePopUp_FooterLink';
import welcomeHeadingEnhanced from '@salesforce/label/c.PMP_Storefront_Welcome_Title_Enhanced';
import footerText from '@salesforce/label/c.PMP_Storefront_FooterIntelLink';
import MsfooterText from '@salesforce/label/c.PMP_MSStorefront_FooterLink';
import PafooterText from '@salesforce/label/c.PMP_PAStorefront_FooterLink';

export default class PsMpStartModal extends NavigationMixin(LightningElement) {
    @api isProfileAdmin;
    @api isProfileMarketingSpecialist;
    @api isUpgradedPartnerAdmin;
    @api buttonEventParams;
    @api isOpen;
    @api isPartner;//added by shahrukh to show footer message
    // get hasHeader() {
    //   if (this.isProfileAdmin) {
    //     return true;
    //   }
    //   return true;
    // }
    label = {
      welcomeHeadingPA,
      highlightCompany,
      setupProfile,
      didYouKnow,
      intelUrl,
      welcomeHeadingMS,
      getStarted,
      highlightCompanyEnhanced,
      popUpFooterLink,
      welcomeHeadingEnhanced,
      footerText,
      MsfooterText,
      PafooterText
  };
    render() {
      console.log('renderisprofileadmin', this.isProfileAdmin);
      if (this.isProfileAdmin) return profileAdmin;
      if (this.isProfileMarketingSpecialist) return profileMarketingSpecialist;
      if (this.isUpgradedPartnerAdmin) return upgradePartnerAdmin;
      throw new TypeError('Modal template missing.');
    }

    connectedCallback() {
      //this.isProfileMarketingSpecialist = true;
      console.log(this.isProfileAdmin);
      
    }

    openCreateProfileModal() {
      console.log('CLICK');
        const buttonClick = new CustomEvent("clickbutton", {
            detail: {
              params: this.buttonEventParams
            }
          });
          this.dispatchEvent(buttonClick);

          this.isOpen = false;
          console.log('Typeof isopen', typeof(this.isOpen));
          //TODO Check if EditStorefront Modal isOpen then Close the Start Modal
    }

  navigateToCreateOffering() {
    const buttonClick = new CustomEvent("clickbutton", {
      detail: {
        params: this.buttonEventParams
      }
    });
    this.dispatchEvent(buttonClick);
    /*  
    this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'PMP_Partner_Offering__c',
            actionName: 'home'
        },
        state: {
            filterName: 'Default'
        }
    });*/
  }

get buttonCustomVariant() {
        return ['button', 'button-secondary',
            this.theme === 'light' ? '' : 'button-inverse'
        ].join(' ');
    }

}