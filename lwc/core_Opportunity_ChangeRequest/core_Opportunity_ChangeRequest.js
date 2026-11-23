import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQpptyLines from '@salesforce/apex/Core_Oppty_CRController.getQpptyLines';

export default class Core_Opportunity_ChangeRequest extends LightningElement {
  @track isLoading = false;
  @api recordId = '0062D00000JMrxwQAD';
  
  @track hasCreateAccess;
  //@track recId = '0062D00000JMrxwQAD';
  records;
  error;
  dataFromApex;
  selectedItemValue;
  fieldEdit = true;
  /*connectedCallback(){
    this.fetchProductDetails();
}

fetchProductDetails(){
    let recId = '0062D00000JMrxwQAD';

    getQpptyLines({oppId:recId})
    .then(data => {
        let objData={
            records:'',
            
        };

        this.records = data.records;

        this.records.forEach(doDetail =>{
            for(let i = 0; i < records.doLineItems.length; i++){
            this.keyDoNbr = doDetail.doLineItems[i].doNbr;
            this.doLineItems = doDetail.doLineItems;
            }
        })    

    }).catch(error => {
        window.console.log('callout error ', JSON.stringify(error));

    })
}*/
  @wire(getQpptyLines, {oppId: '$recordId'})
  
  wiredResult(result){ 
    const { data, error } = result;
    this.dataFromApex = result;
    console.log('@@RecId=='+JSON.stringify(this.recordId));
    console.log('@@result=='+JSON.stringify(result));
    if(data){ 
        this.records = data;
            this.error = undefined;
        }
        console.log('@@Lines=='+JSON.stringify(this.records));
    }
    


  /*connectedCallback() {
    console.log("Rec=="+this.recordId);
    getQpptyLines({oppId: this.recordId})
        .then((result) => {
            this.records = result;
            this.error = undefined;
            console.log('@@Lines=='+JSON.stringify(this.records));
        })
        .catch((error) => {
            this.error = error;
            this.records = undefined;
        });
    }
renderedCallback() {
    this.template.
        querySelector(".sobjlv__backgrounddiv").
        style.setProperty("--background-colour", this.backgroundColour);
}    */
  //Menu selection
  handleOnselect(event) {
    this.selectedItemValue = event.detail.value;
    console.log('@@value=='+this.selectedItemValue);
    console.log('@BeforeEdit=='+this.fieldEdit)
    if(this.selectedItemValue == 'Edit'){
      this.fieldEdit = false;
    }
    console.log('@@fieldEdit=='+this.fieldEdit)
  }
  // Handles loading event
  handleLoading(){
    this.isLoading = true;
  }

  // Handles done loading event
  handleDoneLoading() {
    this.isLoading = false;
  }

  // createNewQuoteLine() {
  //   this.createNewQL = true;
  // }
}