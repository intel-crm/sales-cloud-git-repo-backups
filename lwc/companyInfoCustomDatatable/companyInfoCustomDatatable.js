import LightningDatatable from 'lightning/datatable';
import helpTextCustomComp from './helpTextCustomComponent.html'


export default class CompanyInfoCustomDatatable extends LightningDatatable {
    static customTypes = {
        helptext: {
            template: helpTextCustomComp
        }
    };
}