import { LightningElement } from 'lwc';
import getConfigShowMarquee from '@salesforce/apex/PCC_RebateClaimController.getConfigShowMarquee';

export default class Pcc_RebateClaimQLRemaining extends LightningElement {
    qlsWithoutRebate;
    showModal=false;
    showMarquee=false;
    isProcessing=false;

    connectedCallback(){
        this.configMarquee();
    }
    configMarquee(){
        this.isProcessing = true;
        getConfigShowMarquee()
                .then(result => {
                    this.showMarquee = result.showMarquee;
                    this.qlsWithoutRebate = result.qlList;
                    this.isProcessing = false;
                })
                .catch(error => {
                    this.isProcessing = false;
                });
    }

    handleClick(){
       this.showModal = true;    
    };
    
    get hasQLsWithoutRebate() {
        return this.qlsWithoutRebate && this.qlsWithoutRebate.length > 0;
    }

    get columns() {
        return [
            { label: 'Quote Line', fieldName: 'QuoteLine', type: 'text' },
            { label: 'Approved Quantity', fieldName: 'ApprovedQuantity', type: 'number', cellAttributes: { alignment: 'center' } },
            { label: 'Claimed Quantity', fieldName: 'ClaimedQuantity', type: 'number' , cellAttributes: { alignment: 'center' }},
            { label: 'Remaining Quantity', fieldName: 'RemainingQuantity', type: 'number' , cellAttributes: { alignment: 'center' }},
            { label: 'Due Date', fieldName: 'dueDate', type: 'date', cellAttributes: { alignment: 'center' },
            typeAttributes: {
                day: "numeric",
                month: "numeric",
                year: "numeric",
                timeZone: "UTC"
            }}
        ];
    }

    handleClose(){
        this.showModal = false;
    }
}