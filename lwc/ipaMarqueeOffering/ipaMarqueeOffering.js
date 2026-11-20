// import ByLabel from '@salesforce/label/c.PMP_L3_Marquee_By';
// import LastUpdatedLabel from '@salesforce/label/c.PMP_L3_Marquee_Last_Updated';
// import { getOfferingDetails } from 'c/ipaOfferingService';
import { api, LightningElement, track } from 'lwc';

/**
 * L3 Offering Marquee Component
 * This is used on the L3 Offering Detail Page
 * This component is exposed in the builder as IPA Marquee Offering
 *
 * @example
 * <!-- HTML component example -->
 * <c-ipa-marquee-offering record-id={recordId}></c-ipa-marquee-offering>
 *
 * @augments LightningElement
 * @property {string} recordId  Record Id that is exposed in the builder
 * @property {boolean} [previewMode] preview mode to disable links
 */
class IpaMarqueeOffering extends LightningElement {
    // ******* API variables - defined in class ********
     @api recordId;

    // @api previewMode;

    // ******* Global variables ********
    /**
     * Background variant
     *
     * @type {string}
     * @private
     */
    // backgroundVariant = 'mosaic-l2';

    /**
     * Setting for data
     *
     * @type {string}
     * @private
     */
    // partnerObjectAPI = 'PMP_Company__c';

    /**
     * Used for displaying labels
     *
     * @type {object}
     * @private
     */
    // label = {
    //   ByLabel,
    //   LastUpdatedLabel,
    // };

    // ******* Track variables ********
    /**
     * This is marquee data object
     *
     * @type {marqueeData}
     * @private
     */
    // @track marqueeData = {
    //   title: '',
    //   partnerName: '',
    //   publishedDate: '',
    //   tagline: '',
    //   partnerId: '',
    // }

    /**
     * This is compare product object
     *
     * @type {object}
     * @private
     */
    // @track compareProductData = {};

    // ******* Functions ********
    /**
     * Called when the element is inserted into the DOM. Used to call ipaOfferingService getOfferingDetails
     *
     * @private
     */
     connectedCallback() {
    //   getOfferingDetails({ offeringId: this.recordId })
    //     .then(({ marqueeData, compareProductData }) => {
    //       this.marqueeData = { ...marqueeData };
    //       this.compareProductData = { ...compareProductData };
    //     });
    }
 }
// export default IpaMarqueeOffering;

// ********* Type Definitions ************
/**
 * Represents the data used by the Offering Marquee component.
 *
 * @typedef marqueeData
 *
 * @property {string} title  The title of the marquee
 * @property {string} partnerName  The partner name of the offering
 * @property {string} partnerId  The partnerId to navigate to partner page
 * @property {string} publishedDate The last updated date
 * @property {string} tagline The tagline of the marquee
 */