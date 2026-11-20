/** Benefit
 * Data used to represent a blade in the partner benefits page
 * @typedef BenefitProfile
 * @memberof ipaBenefitService
 * @property {string} companyProfileId the id of the company
 * @property {string} marqueeTitle the title of the marquee partner
 * @property {Link} dashboardLink the dashboard link used in the marquee partner
 * @property {Link} companyProfileLink the link of the benefit
 * @property {Link} myProfileLink the link used in the marquee partner
 * @property {string} name the name of the profile
 * @property {string} title the title of the profile
 * @property {string} responsibility the responsibility of the profile
 * @property {string} phone the phone of the profile
 * @property {string} email the email of the profile
 * @property {string} faIcon the font awesome icon of the profile
 * @property {string} iconUrl the image icon of the profile
 * @property {string} tier the tier level for the profile
 * @property {string} benefitDescription rich text description added to the manage benefit
  */

import helpers from './helpers/index';

export const mockBenefitProfile = () => {

    let name = helpers.sample(['Alexandra', 'Julia', 'Marcus']);
    let title = helpers.sample(['Marketing Manager']);
    let responsibility = helpers.sample(['Primary Contact']);

    return {
        companyProfileId: '555',
        marqueeTitle: 'Partner Benefits',
        companyProfileLink: {
            "label": "Company Profile-service",
            "externalUrl": "https://www.intel.com/#companyprofile",
            "communityPage": "",
            "objectPage": "",
            "recordId": ""
        },
        dashboardLink: {
            "label": "Dashboard-service",
            "externalUrl": "https://www.intel.com/#dashboard",
            "communityPage": "",
            "objectPage": "",
            "recordId": ""
        },
        myProfileLink: {
            "label": "My Profile Link-service",
            "externalUrl": "https://www.intel.com/#myprofilelink",
            "communityPage": "",
            "objectPage": "",
            "recordId": ""
        },
       
        name: name,
        title: title,
        responsibility: responsibility,
        phone: '(555) 555-5555',
        email: 'miriamluxumburg@amaxcorp.com',
        faIcon: 'fa-intel-user-o',
        tier: 'Titanium Tier',
        benefitDescription: 'The following snapshot is based on your Titanium Tier status and <a target="_blank" href="555">Primary Contact</a> role.'
    }
}