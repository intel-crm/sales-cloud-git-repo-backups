import { LightningElement,track, wire } from 'lwc';
import getCompanyList from '@salesforce/apex/PMP_OfferingResourceHelper.getCompanyList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class IpaFulfillmentChannelPartner extends LightningElement{
    @track copmanyList;
    @track regionList;
    @track error;
    @wire(getCompanyList)
    wiredCompany({ error, data }) {
        if (data) {
            this.copmanyList = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.copmanyList = undefined;
        }
    }
  /*  @wire(getRegionList)
    wiredRegion({ error, data }) {
        if (data) {
            this.regionList = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.regionList = undefined;
        }
    }
   */
    keyIndex = 0;
    @track itemList = [
        {
            id: 0
        }
    ];

    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        if(this.keyIndex <=2)
        {
            this.itemList = this.itemList.concat(newItem);
        }
        else
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Information',
                    message: 'Maximum 3 Rows can be added',
                    variant: 'Info',
                }),
            );
        }
        
    }
}