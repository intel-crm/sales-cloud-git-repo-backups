import { LightningElement, wire, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jqueryjs from '@salesforce/resourceUrl/jquery_3_6_0';
import widget from '@salesforce/resourceUrl/widget';
import css from '@salesforce/resourceUrl/addOnCSS_ufwidget';
import getHubId from '@salesforce/apex/PMP_Utility.getValue';
import { CurrentPageReference } from 'lightning/navigation';
import { handleError } from 'c/ipaErrorServiceMarketplace';
/**
 * IPA UBERFLIP component
 * This Component displays the UberFlip/Insight Tech Articles
 *
 * @augments LightningElement
 */
export default class ipaUberflipWidget extends LightningElement {
    /**
     * Data - Get the URL Parameters
     *
     * @type {object}
     * @private
     */
    @track urlStateParameters;

    /**
     * Data - Holds the data for Uberflip Widget
     *
     * @type {object}
     * @private
     */
    @track hubId;

    /**
     * Data - holds the LanguageCode from current page
     * Refrence
     *
     * @type {string}
     * @private
     */
    key;

    /**
     * Data - Get CurrentPageReference from the URL Parameters
     *
     * @type {string}
     * @private
     */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
      if (currentPageReference) {
        this.urlStateParameters = currentPageReference.state;
      }
    }

    /**
     * Data - Fetch UberFlip Configration
     *
     * @type {string}
     * @private
     */
    @wire(getHubId, { key: '$key' }) gethubId({ error, data }) {
      if (data) {
        this.hubId = data;
        if (this.hubId) {
          const ufRecoEmbedViewerConfig = {
            base: 'https://flipbot.uberflip.com/',
            open_in: 'viewer',
            open_in_mobile: 'viewer',
            logo: '',
            embed_id: 'uberflip-tiles',
            cta_label: '',
            cta_url: '',
            max_per_row: 4,
            hub_id: this.hubId,
            auto_link: false,
            debug: true,
          };
          // eslint-disable-next-line no-undef
          ufRecoEmbedViewer.init(ufRecoEmbedViewerConfig);
        }
      }
      if (error) {
        handleError(error, 'IPA UBER FLIP');
      }
    }

    /**
     * connected callback
     * - gets data for Uberflip
     *
     * @private
     */
    connectedCallback() {
      let languageCode = this.urlStateParameters?.language ? this.urlStateParameters.language : 'en_US_hub';
      if (languageCode != null && languageCode.includes('ja')) {
        languageCode = 'ja_hub';
      } else if (languageCode != null && languageCode.includes('en_US')) {
        languageCode = 'en_US_hub';
      }
      this.key = languageCode;
      // creating div element
      const targetDiv = document.createElement('DIV');
      targetDiv.id = 'uberflip-tiles';
      targetDiv.name = 'ufTiles';
      this.template.host.appendChild(targetDiv);
      //
      Promise.all([
        loadScript(this, `${jqueryjs}/jquery-3.6.0.min.js`),
        loadScript(this, `${widget}/widget.js`),
        loadScript(this, `${widget}/uf-reco-embed-viewer.min.js`),
        loadStyle(this, `${css}/ufTilescss.css`),
      ]).then(() => {
      }).catch((error) => {
        handleError(error, 'IPA UBER FLIP');
      });
    }
}