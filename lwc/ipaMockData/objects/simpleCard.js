/** SimpleCard
 * Data used to represent a blade in the partner benefits page
 * @typedef SimpleCard
 * @property {string} icon the font awesome icon of the Simple Card
 * @property {string} imageUrl the image url icon of the Simple Card
 * @property {string} svgIconUrl the svg url icon of the Simple Card
 * @property {string} sfIcon the salesforce icon name of the Simple Card
 * @property {Link} linkData the link data of the simple card
 * @property {string} title the title of the simplecard
 * @property {string} description the description of the simplecard, not used in quick links
 */

import helpers from './helpers/index';

const textSample = ( ) => {
    return helpers.sample(['Manage personnel', 'Enroll in more benefits', 'Invite members', 'The height of this two-line card is used for all', 'Content collections']);
}

export const mockSimpleCard = ()=> {
    let title = textSample();
    return {
        icon: 'fa-angle-double-right',
        imageUrl: '',
        svgIconUrl: '',
        sfIcon:'',
        title: title,
        description: '',
        linkData: {
            label: title,
            externalUrl: '#',
            communityPage: '',
            objectPage: '',
            recordId: ''
        }

    }

}