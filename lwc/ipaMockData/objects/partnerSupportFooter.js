/** Benefit Support Footer
 * Data used to represent a blade in the partner benefits page
 * @typedef PartnerSupportFooter
 * @memberof ipaBenefitService
 * @property {string} title the title of the support section
 * @property {ipaBenefitService.SupportCard[]} cards support card data
 */

/** Benefit Support Card
 * Data used to represent a blade in the partner benefits page
 * @typedef SupportCard
 * @memberof ipaBenefitService
 * @property {string} id the id of the benefit
 * @property {string} title the title of the benefit
 * @property {string} faIcon the font awesome icon name
 * @property {Content[]} content the content details for the support card
 */

import helpers from './helpers/index';
import {mockContentType} from './content';


const supportCard = (index) => {
    let supportSample =  [
        {
            title: "Find Answers",
            faIcon: "fa-question-circle-o",
            content: [mockContentType(2,3)]
        },
        {
            title: "Request Support",
            faIcon: "fa-mail",
            content: [
                mockContentType(0),
                mockContentType(2, 1)
            ]
        },
        {
            title: "Online Chat",
            faIcon: "fa-chat-o",
            content: [
                mockContentType(0),
                mockContentType(2, 1)
            ]
        },
        {
            faIcon: "fa-phone-r-o",
            title: "Call Us",
            content: [
                mockContentType(1),
                mockContentType(2, 1)
            ]
        }
    ];

    return  index>-1  && supportSample.length > index ? supportSample[index] : helpers.sample(supportSample);

}

export const mockSupportCard = (index) => {
    return supportCard(index);
}

export const mockPartnerSupportFooter = () => {
    return { title: "Intel Partner Alliance Support",
       cards: [
            mockSupportCard(0),
            mockSupportCard(1),
            mockSupportCard(2),
            mockSupportCard(3)
        ]
    }
}