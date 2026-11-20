import LightningDatatable from 'lightning/datatable';
import accountNumber from './accountNumber.html';

export default class PRM_PartnerSearchCustomTypes extends LightningDatatable {
    static customTypes = {
        customLink: {
            template: accountNumber,
            standardCellLayout: true,
            typeAttributes: ['accountNumber','accountId']
        }
    }
}