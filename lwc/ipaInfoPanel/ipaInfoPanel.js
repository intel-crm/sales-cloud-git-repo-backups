import { LightningElement, api, track } from 'lwc';
import baseUrl from '@salesforce/label/c.PMP_Marketplace_Community_URL';
import headline from '@salesforce/label/c.PMP_Discover_Offerings';
import InfoPanel1label from '@salesforce/label/c.PMP_Storefornt_InfoPanel1';
import InfoPanel2label from '@salesforce/label/c.PMP_Storefornt_InfoPanel2';
import InfoPanel3label from '@salesforce/label/c.PMP_Storefornt_InfoPanel3';
import InfoPanelDesciption1label from '@salesforce/label/c.PMP_Storefornt_InfoPanelDescription1';
import InfoPanelDesciption2label from '@salesforce/label/c.PMP_Storefornt_InfoPanelDescription2';
import InfoPanelDesciption3label from '@salesforce/label/c.PMP_Storefornt_InfoPanelDescription3';
import pmpStoreforntInfoPanelUrlLabel1 from '@salesforce/label/c.PMP_Storefornt_InfoPanelUrl1';
import pmpStoreforntInfoPanelUrlLabel2 from '@salesforce/label/c.PMP_Storefornt_InfoPanelUrl2';
import pmpStoreforntInfoPanelUrlLabel3 from '@salesforce/label/c.PMP_Storefornt_InfoPanelUrl3';
import myResource1 from '@salesforce/resourceUrl/PMP_InfoPanel_Logo_1';
import myResource2 from '@salesforce/resourceUrl/PMP_InfoPanel_Logo_2';
import myResource3 from '@salesforce/resourceUrl/PMP_InfoPanel_Logo_3';

/**
 * IPA Info Panel Component
 * This Component displays the Information Panel below the storefront
 * containing Explore Solutions, Explore Communities and Visit Intel Partner University links
 *
 * @property {boolean} showLogo to hide or show Logo
 * @augments LightningElement
 */
export default class IpaInfoPanel extends LightningElement {
  @api
  showLogo;

  /** Community URL
   *
   * @type {string}
   * @private
   */
  communityURL = baseUrl;

  /**
   * Custom Labels
   *
   * @type {object}
   * @private
   */
  labels = {
    headline,
  }

  /**
   * List of wrapper of label,description,url
   *
   * @type {object[]}
   * @private
   */
  @track
  ipaInfoShare=[];

  /**
   * connected callback to check Community URL end with backslash
   *
   * @private
   */
  connectedCallback() {
    if (!this.communityURL.endsWith('/')) {
      this.communityURL += '/';
    }
    this.ipaInfoShare = [
      {
        label: InfoPanel1label,
        description: InfoPanelDesciption1label,
        resource: myResource1,
        url: this.communityURL + pmpStoreforntInfoPanelUrlLabel1,
      },
      {
        label: InfoPanel2label,
        description: InfoPanelDesciption2label,
        resource: myResource2,
        url: this.communityURL + pmpStoreforntInfoPanelUrlLabel2,
      },
      {
        label: InfoPanel3label,
        description: InfoPanelDesciption3label,
        resource: myResource3,
        url: this.communityURL + pmpStoreforntInfoPanelUrlLabel3,
      },
    ];
  }
}