import { LightningElement } from 'lwc';

// custom labels
import ipaCompanyURLSuffix from '@salesforce/label/c.PRM_Company_URL';
import ipaHomePageURLSuffix from '@salesforce/label/c.EPUM_IPAUrl';
import mpHomePageURLSuffix from '@salesforce/label/c.PSS_Solution_URL';


export default class PssAccessDenied extends LightningElement { 

  /**
   * variable to open popup after wire method load
   *
   * @type {String}
   * @private
   */
   mpHomePageURL;
     /**
   * variable to open popup after wire method load
   *
   * @type {String}
   * @private
   */
      ipaHomePageURL;
        /**
   * variable to open popup after wire method load
   *
   * @type {String}
   * @private
   */
   ipaCompanyProfileURL;

    /**
   * retrieves the recordId retrieved from the current page
   * calls the imperative method to get all the IPA contacts for this solution record.
   * OR to get all the shared contacts for emails.
   *
   * @private
   */
  connectedCallback() {
    var baseUrl=window.location.origin;
    this.mpHomePageURL = baseUrl+mpHomePageURLSuffix;
    this.ipaCompanyProfileURL = baseUrl+ipaCompanyURLSuffix;
    this.ipaHomePageURL = baseUrl+ipaHomePageURLSuffix;
  }
}