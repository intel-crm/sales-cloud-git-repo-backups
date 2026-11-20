/** Documentation for ipaPartnerWelcomeTile  Component
 * <br>Contains mosltly renderinng design, no logic included
 * @example
 * <c-ipa-partner-welcome-mat eyebrow="Eyebrow" title="Onboarding Title" description="Lorem Ipsum Dolor">
 *      <div slot="tiles">
 *          <c-ipa-partner-welcome-tile is-first="true" is-last="false"  title="title 1" description="description 1" type="completed"></c-ipa-partner-welcome-tile>
 *          <c-ipa-partner-welcome-tile is-first="false" is-last="false" title="title 2" description="description 2" type="active"></c-ipa-partner-welcome-tile>
 *          <c-ipa-partner-welcome-tile is-first="false" is-last="true"  title="title 3" description="description 3" type="inactive"></c-ipa-partner-welcome-tile>
 *      </div>
 * </c-ipa-partner-welcome-mat>
 * @namespace ipaPartnerWelcomeTile
 * @property {string} type the type [active,inactive,completed] this shows different left icons depending on type see https://d.pr/i/qm0aEB
 * @property {string} title the tile for the tile for the Welcome Tile  see https://d.pr/i/qm0aEB
 * @property {string} description the Description for the Welcome Tile see https://d.pr/i/qm0aEB
 * @property {boolean} isFirst is the first of the tiles renders the first tile differently
 * @property {boolean} isLast is the last of the tiles renders the last tile differently
 *
 *
 * @author Joshua Gonzalez
*/
import { LightningElement, api} from 'lwc';

export default class IpaPartnerWelcomeTile extends LightningElement {
    @api type; // active/inactive/completed
    @api title;
    @api description;
    @api isFirst;
    @api isLast;

    get classes() {
        return {
            containerClass: "container " + this.type + (this.isFirst ? ' is-first ': '') + (this.isLast ? ' is-last ': '')
        };
    }

    get ifs() {
        return {
            stepCompleted: this.type === 'completed'
        }
    }
}