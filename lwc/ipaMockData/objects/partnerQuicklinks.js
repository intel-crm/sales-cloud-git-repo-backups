/** PartnerQuicklinks
 * Data used to represent a the Quicklinks Blade that has a simple card list rendering
 * @typedef PartnerQuicklinks
 * @memberof ipaBenefitService
 * @property {string} title the title of the Quicklinks Component
 * @property {SimpleCard[]} cards simple card for quick links
 */

import {mockSimpleCard} from './simpleCard';


export const mockPartnerQuickLinks = () => {
    return {
        title: "Quick Links",
        cards: [
            mockSimpleCard(),
            mockSimpleCard(),
            mockSimpleCard(),
            mockSimpleCard(),
            mockSimpleCard(),
            mockSimpleCard()
        ]
    }
}