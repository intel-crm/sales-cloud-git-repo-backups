/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for the Core Marquee Component
 * <br>
 * <h2>Core Marquee</h2>
 * This is a generic marquee component.
 * <br>
 * <h4>Slots</h4>
 * <ul>
 * <li><b>subtitle</b> - for content underneath the main marquee title</li>
 * <li><b>right</b> - for content on the right side of the marquee (underneath in mobile)</li>
 * </ul>
 * <h4>Advanced Marquees</h4>
 * <ul>
 * <li>{@link ipaMarqueePartner Benefits Partner Marquee (ipaMarqueePartner)}</li>
 * <li>{@link ipaMarquee L0, L1, and L2 Marquee (ipaMarquee)}</li>
 * </ul>
 * @namespace coreIntcMarquee
 * @property {string} title Set the Title for the Marquee
 * @property {string} alignment='left' can be 'left' or 'center'
 * @author Fawn Stevens
*/

import { LightningElement, api } from 'lwc';

export default class CoreIntcMarquee extends LightningElement {

    @api alignment = 'left';
    @api title = 'Marquee Title';

}