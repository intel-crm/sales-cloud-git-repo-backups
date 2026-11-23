import { LightningElement, track, api } from 'lwc';
import getURL from '@salesforce/apex/Core_IPS_File_AttachToCase_Controller.prepareUrl';

 

export default class CaseAttachmentUpload extends LightningElement {
    @api recordId = '';
    @track scfturl;
    @track visibilityValue = 'Public to Customer';

    get options() {
        return [
            { label: 'Public to Customer', value: 'Public to Customers' },
            { label: 'Private to Intel', value: 'Private to Intel' },
            { label: 'Private to Partner', value: 'Private to Partner' }
        ];
    }
    handleChange(event) {
        this.visibilityValue = event.detail.value;
        console.log(event.detail.value);
        console.log(this.visibilityValue);
      // this.scfturl = 'https://ips-scft-tst-v2.intel.com/ips/upload?caseId='+'5004F000009KdibQAC'
      //  +'&amp;extended={"visibility":"'+ this.visibilityValue +'"}'; 

        getURL({caseId : this.recordId, typeoffile : this.visibilityValue })
            .then(data => {

                if (data) {
                    this.scfturl = data;
                    this.errors = undefined;
                }
                console.log(this.scfturl);
            })
            .catch(error => {
                console.error('caseAttachmentUpload::: Error in getting URL. Error : ', JSON.stringify(error));
                this.response = undefined;
                    this.errors = error;
            })
  
        
    }
    connectedCallback() {
        console.log('CaseAttachmentUpload ::: connectedCalback called');
       // this.scfturl = 'https://ips-scft-tst-v2.intel.com/ips/upload?caseId='+'5004F000009KdibQAC'
       // +'&amp;extended={"visibility":"'+ this.visibilityValue +'"}';

       
       getURL({caseId : '5004F000009KdibQAC', typeoffile : this.visibilityValue })
       .then(data => {

           if (data) {
               this.scfturl = data;
               this.errors = undefined;
           }
           console.log(this.scfturl);
       })
       .catch(error => {
           console.error('caseAttachmentUpload::: Error in getting URL. Error : ', JSON.stringify(error));
           this.response = undefined;
               this.errors = error;
       })

    }
    

}