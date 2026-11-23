/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for Marquee Marketplace Component
 * <br>
 * <h2>Marketplace Pages using ipaMarqueeMarketplace:</h2>
 * <h3>L0 - Home</h3><br>
 * <h3>L1 - Level One Pages (ie. Offering Categories, Partner Directory, ...)</h3><br>
 * <h3>L2 - Level Two Category Search Pages
 *
 * @namespace ipaMarqueeMarketplace
 * @property {boolean} dynamicMarquee=false Set to true to set Marquee data dynamically
 * @property {string} title Set the Title for the Marquee
 * @property {string} subtitle Set the Subtitle for the Marquee
 * @property {string} ctaLabel Set Label for Link
 * @property {string} ctaExternalUrl Set External URL - uses linkout icon
 * @property {string} ctaCommPage Set Community Page
 * @property {boolean} showCaret=false Show right arrow icon on link
 * @property {boolean} showSearch=false Show search box
 * @property {string} alignment=Left Set Left alignment or Center alignment

 * @author Fawn Stevens
*/
import { LightningElement, api } from 'lwc';

export default class IpaMarqueeMarketplaceFaq extends LightningElement {

    @api title;
    @api subtitle;
    @api ctaLabel;
    @api ctaExternalUrl;
    @api ctaCommPage;
    // @api ctaObjectPage;
    // @api ctaRecordId;
    @api showCaret;
    @api showSearch;
    @api alignment;
    @api dynamicMarquee;
    @api analyticsPageType;



}