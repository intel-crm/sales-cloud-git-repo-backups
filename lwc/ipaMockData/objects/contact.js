/** Contacts
 * Data used to display the optional contacts part of the benefit
 * @typedef Contacts
 * @memberof ipaBenefitService
 * @property {string} label the title of the contact set
 * @property {Contact[]} contacts contacts for the metric
 */

/** Contact
 * Contact entry used in benefit contact
 * @typedef Contact
 * @property {string} id unique contact id
 * @property {string} name the name of the contact
 * @property {string} title the title of the contact
 * @property {string} role the role of the contact
 * @property {string} phone the phone of the contact
 * @property {string} email the email of the contact
 * @property {string} faIcon the font awesome icon of the contact
 * @property {string} iconUrl the image icon of the contact
 */

import helpers from './helpers/index';

const contactSample = (index) => {
    let mockContacts = [
        {
            name: 'Miriam Luxumburg',
            title: 'Senior Lorem Ipsum',
            role: 'Account Admin',
            phone: '(555) 555-5555',
            email: 'miriamluxumburg@amaxcorp.com',
            faIcon: 'fa-intel-user-o'
        },
        {
            name: 'Roger Simpson',
            title: 'Senior Ipsum Dolor',
            role: 'Named Account Coverage',
            phone: '(555) 555-5555',
            email: 'rogersimpson@intel.com',
            iconUrl: 'https://www.intel.com/content/dam/logos/intel-footer-logo.svg'
        }
    ]
    return  index>-1  && mockContacts.length > index ? mockContacts[index] : helpers.sample(mockContacts);
}

export const mockContact = (index) => (
    contactSample(index)
);



export const mockContacts = () => {
    return {
      label: "Account Team",
      contacts:  [mockContact(0), mockContact(1)]
    }
}