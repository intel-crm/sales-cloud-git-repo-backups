/** ipa Benfit Service Alert
 * ipa Benfit Service Alert for the benefit card
 * @typedef Alert
 * @memberof ipaBenefitService
 * @property {string} label the label of the alert
 */


import helpers from './helpers/index';

export const mockAlert = () => {
    let mockAlerts = ['Your MDF was Approved', 'Issue processing MDF payment', 'Neque porro quisquam est qui'];
    return {
        label: helpers.sample(mockAlerts)
    }
}