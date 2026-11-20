/** Link
 * a Link out to a page used whenever a link is needed on the data. This directly maps to the ipaLink component for external and internal links
 * @typedef Link
 * @property {string} label the label of the link
 * @property {string} externalUrl the url of the link
 * @property {string} communityPage <b>required if community page</b> - community page <b>API Name</b> - (ie. 'Some_Page__c')
 * @property {string} objectPage <b>required if object page or record page</b> - Salesforce object API name
 * @property {string} recordId <b>required if record page</b> - Salesforce record ID
 */


import helpers from './helpers/index';
 const linkSample = (index) => {
    let mockLinks = [
        'Submit MDF Campaign',
        'Submit MDF Claim',
        'MDF tool',
        'Learn more about points',
        'View account',
        'Earn points',
        'Points matrix',
        'Distributor inventory',
        'View activity',
        'Find help and training',
        'View results',
        'Track my learning',
        'Partner University Pathways', //IPA 2.0
        'My competencies',
        'Browse webinars',
        'All training',
        'View activity',
        'Manage Storefront',
        //'Create new offering',//IPA2.0:US-4497-1631_OfferingEOL
        'View results',
        'Marketing asset library',
        'View my campaigns',
        'View all support tickets',
        'Check warranty coverage'
    ];

    let tempValue =  index>-1  && mockLinks.length > index ? mockLinks[index] : helpers.sample(mockLinks);

    return {
        label: tempValue,
        externalUrl: '#',
        communityPage: '',
        objectPage: '',
        recordId: ''
    };
}


export const mockLinks = (index) => {

    let result = [];

    if (Array.isArray(index)){
        for (let value of index){
            result.push(linkSample(value));
        }
    } else if (Number.isInteger(index)) {
        while (result.length < index) {
            result.push(linkSample());
        }
    } else {
        result.push(linkSample())
    }


    return result
}