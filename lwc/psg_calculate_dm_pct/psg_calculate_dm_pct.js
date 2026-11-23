import { LightningElement,api,wire} from 'lwc';
import {
    getFieldValue,
    getRecord
  } from 'lightning/uiRecordApi';
  import calculateDM from '@salesforce/apex/PSG_DPA_ALNLinesBusinessLogic.calculateDM';
  
  
export default class Psg_calculate_dm_pct extends LightningElement {
    @api recordId;
     isLoaded = false;
   
     CalculateDM(){
        this.isLoaded=true;
        calculateDM({LineID:'$recordId'})
        .then(result=>{ 
            this.isLoaded = false; 
            console.log('result '+JSON.stringify(result));
            }) 
            .catch(error=>{  
            this.showSpinner=false;
            this.showToast('Error while calculation',JSON.stringify(error),'error');
            }) 


     }
}