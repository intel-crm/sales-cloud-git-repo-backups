import LightningDatatable from 'lightning/datatable';
import customActions from './sales_licenseCustomActions';
export default class Sales_licenseCustomDatatableComp extends LightningDatatable  {
		static customTypes = {
				customActions: {
						template: customActions,
						typeAttributes: ['selectedRow']
				}
		};
}