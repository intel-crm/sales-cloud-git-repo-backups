/** Documentation for ipaPartnerWelcomeMat  Component
 * <br>To be used with the {@link ipaPartnerWelcomeTile ipaPartnerWelcomeTile} component.
 * <br>Contains mosltly renderinng and css, no logic included
 * @example
 * <c-ipa-partner-welcome-mat eyebrow="Eyebrow" title="Onboarding Title" description="Lorem Ipsum Dolor">
 *      <div slot="tiles">
 *          <c-ipa-partner-welcome-tile is-first="true" is-last="false"  title="title 1" description="description 1" type="completed"></c-ipa-partner-welcome-tile>
 *          <c-ipa-partner-welcome-tile is-first="false" is-last="false" title="title 2" description="description 2" type="active"></c-ipa-partner-welcome-tile>
 *          <c-ipa-partner-welcome-tile is-first="false" is-last="true"  title="title 3" description="description 3" type="inactive"></c-ipa-partner-welcome-tile>
 *      </div>
 * </c-ipa-partner-welcome-mat>
 * @namespace ipaPartnerWelcomeMat
 * @property {string} eyebrow the Eyebrow text for the Welcome Mat  see https://d.pr/i/Acj0Bf
 * @property {string} title the Title for the Welcome Mat  see https://d.pr/i/Acj0Bf
 * @property {string} description the Description for the Welcome Mat  see https://d.pr/i/Acj0Bf
 * @property {Slot} tiles slot for the tiles

 * @author Joshua Gonzalez
*/

import { LightningElement, api, track } from 'lwc';
import stepOneCompleted from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.isStepOneCompleted"; 
import IPASecureHomepageLink from '@salesforce/label/c.IPA_Secure_Homepage_Link';
import IPAPartnerHomeBtn from '@salesforce/label/c.IPA_Partner_Home_Btn';

export default class IpaPartnerWelcomeMat extends LightningElement {
    @api eyebrow;
    @api title;
    @api description;
    @api showpartnerbtn; 
    
    @track label = {
        IPASecureHomepageLink,
        IPAPartnerHomeBtn
    }
    //partnerHomePageUrl;

    renderedCallback() { 
        /* calling imperative apex class to check first step T&C is completed */      
        stepOneCompleted()
        .then(result => {
            this.showpartnerbtn = result;
        })
        .catch(error => {
            console.log('error message',error);
        });
    }
}