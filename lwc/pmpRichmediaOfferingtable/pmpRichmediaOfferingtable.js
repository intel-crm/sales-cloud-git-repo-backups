import {
  LightningElement, track, api, wire,
} from 'lwc';
import getOfferingsonPartners from '@salesforce/apex/PMP_RichMediaAssetController.getOfferingsonPartners';
import assetSaveOperation from '@salesforce/apex/PMP_RichMediaAssetController.assetSaveOperation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLS = [
  {
    label: 'Name',
    fieldName: 'linkName',
    wrapText: true,
    initialWidth: 150,
    type: 'url',
    typeAttributes: { label: { fieldName: 'PMP_Partner_Offering_Nm__c' }, target: '_blank' },
  },
  {
    label: 'Company', fieldName: 'compLink', wrapText: true, initialWidth: 150, type: 'text',
  },
  {
    label: 'Tag line', fieldName: 'PMP_Partner_Offering_Tag_Line_Txt__c', wrapText: true, initialWidth: 150, type: 'text',
  },
  {
    label: 'Description', fieldName: 'PMP_Partner_Offering_Dsc__c', wrapText: true, initialWidth: 500, type: 'text',
  },
  {
    label: 'Life Cycle Status', fieldName: 'PMP_Partner_Offering_Lifecycle_Status_Nm__c', wrapText: true, type: 'text', sortable: true,
  },
  {
    label: 'Start Date', fieldName: 'PMP_Partner_Offering_Start_Dt__c', wrapText: true, type: 'date', sortable: true,
  },
  {
    label: 'End Date', fieldName: 'PMP_Partner_Offering_End_Dt__c', wrapText: true, type: 'date', sortable: true,
  },
];

/**
 *
 */
export default class PmpRichmediaOfferingtable extends LightningElement {
  title = 'Asset Save on Offerings';

  message = 'The new resource file is successfully attached to the offerings selected.';

  variant = 'success';

  cols=COLS;

  /*
  Declaring recordId to get the rich media asset record id
  */
  @api recordId;

  @track offeringdata;

  @track showSpinner;

  /*
  Declaring api variable and passing the value from parent to child
  */
  @api partnerIds;

  /**
   * Wire method for getting the offering results based on the partner id selected
   *
   * @param {Array} result - Returns an Array
   */
  @wire(getOfferingsonPartners, { ids: '$partnerIds' })wireddata(result) {
    if (result.data) {
      const tempOppList = [];
      for (let i = 0; i < result.data.length; i += 1) {
        const tempRecord = { ...result.data[i] }; // cloning object
        tempRecord.linkName = `/${tempRecord.Id}`;
        tempRecord.compLink = tempRecord.PMP_Company_Id__r.Name;
        tempOppList.push(tempRecord);
      }
      this.offeringdata = tempOppList;
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.offeringdata = undefined;
      const evt = new ShowToastEvent({
        title: 'Offering table',
        message: 'No Records Found for the selected partner(s)',
        variant: 'Info',
      });
      this.dispatchEvent(evt);
    }
  }

  /**
   * Handles the save operation when offering records are selected
   *
   */
  handleSave() {
    this.showSpinner = true;
    const selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
    if (selectedRecords.length > 0) {
      assetSaveOperation({ recordid: this.recordId, selectedRecords })
        .then(() => {
          this.showSpinner = false;
          const evt = new ShowToastEvent({
            title: this.title,
            message: this.message,
            variant: this.variant,
          });
          this.dispatchEvent(evt);
        })
        .catch((error) => {
          this.showSpinner = false;
          const evt = new ShowToastEvent({
            title: 'Asset Save Failed',
            message: JSON.stringify(error.body.fieldErrors.LinkedEntityId[0].message),
            variant: 'error',
          });
          this.dispatchEvent(evt);
        });
    } else {
      const evt = new ShowToastEvent({
        title: 'Please Select Offerings',
        message: 'No Offering(s) have been selected',
        variant: 'info',
      });
      this.dispatchEvent(evt);
      this.showSpinner = false;
    }
  }
}