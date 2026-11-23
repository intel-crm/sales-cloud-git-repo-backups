import { LightningElement, track, api, wire } from 'lwc';
import getQpptyLines from '@salesforce/apex/Core_Oppty_CRController.getQpptyLines';

export default class CoreChangeRequestOpportunity extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    opptyLineItems;
    options;
    value;
    quoteId;
    records;
    error;
    dataFromApex;
    selectedItemValue;
    @api recordId;// = 'a3DDf000000CPxbMAG';//= '006Df00000K2V6UIAV';//'0062D00000EVtUvQAL';//'0062D00000JMrxwQAD';

    @wire(getQpptyLines, {dealId: '$recordId'})
    wiredResult(result){ 
        const { data, error } = result;
        console.log('@@RecId=='+JSON.stringify(this.recordId));
        console.log('@@result=='+JSON.stringify(result));
        
        if(data){ 
            this.opptyLineItems = result.data;
            this.dataFromApex = result;
            try {
              this.options = data.map(d => {
                return { label: d.Name, value: d.Id };
              });
            } catch (error) {
              console.error(error);
            }
          } else if (error) {
            console.error(error);
        }
        console.log('@@opptyLineItems=='+JSON.stringify(this.options));
    }
    handleChange(event) {
        this.refreshValues();
        this.value = event.detail.value;
        console.log('@@Selected=='+JSON.stringify(this.value));
        console.log('@@First=='+JSON.stringify(this.opptyLineItems[0].Id));
        for(var i=0;i<this.opptyLineItems.length;i++){
            if(this.value === this.opptyLineItems[i].Id){
                console.log('It is matching=='+this.opptyLineItems[i].SBQQ__QuoteLine__c);
                if(this.opptyLineItems[i].SBQQ__QuoteLine__c){
                this.quoteId = this.opptyLineItems[i].SBQQ__QuoteLine__c;
                console.log('@@quoteId=='+JSON.stringify(this.quoteId));
                }
                this.records = this.opptyLineItems[i];
            }
        }
        //this.selectedItem = this.opptyLineItems.filter(lead => lead.Id === event.detail.value)[0];
      }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }

    refreshValues() {
      const inputFields = this.template.querySelectorAll('lightning-input-field');
      if (inputFields) {
          inputFields.forEach((field) => {
              field.reset();
          });
      }
  }
}