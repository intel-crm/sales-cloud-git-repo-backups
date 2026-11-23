import LightningDatatable from 'lightning/datatable';
import accountNumber from './accountNumber.html';
//import PRM_PartnerSearch_Style from '@salesforce/resourceUrl/PRM_PartnerSearch_Style'

export default class PRM_PartnerSearchCustomTypes extends LightningDatatable {
    

    static customTypes = {
        customLink: {
            template: accountNumber,
            standardCellLayout: true,
            typeAttributes: ['accountNumber','accountId']
        }
    }
}