import { LightningElement, wire,api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class Core_MDF_OutcomebasedCompactLayout extends NavigationMixin(LightningElement) {

    @api recordId;
    isFromParent = true;

    @api objAPIName;
    @api fieldAPIName;
    @api operator;
    @api fieldAPIoperator;
    @api isSectionVisible;
    @api isCompactLayout;
    @api recordTypeName;
    @api standardFieldAlign;
    @api hasToRetainDecimalValues;



    isCompactLayout=true;

    @wire(CurrentPageReference)
    getState(pageRef) {
        if (pageRef?.state?.c__recordId) {
            this.recordId = pageRef.state.c__recordId;
        }
    }

     

    connectedCallback() {
        this.isFromParent === true

        console.log('Record Id:', this.recordId);
                console.log('Is From Parent:', this.isFromParent);

    }


   
}