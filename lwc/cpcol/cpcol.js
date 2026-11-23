import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Cpcol extends NavigationMixin(LightningElement) {
    @api recordId;
    @api cpNumber;
    handleClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            },
        });
    }
}