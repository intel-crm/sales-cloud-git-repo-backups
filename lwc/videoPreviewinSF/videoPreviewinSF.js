import { LightningElement, wire, track} from 'lwc';
import getAccounts from '@salesforce/apex/videoPreviewinSFController.getAccounts';

export default class videoPreviewinSF extends LightningElement {
         //Method 2
         @track videoURL;

     @wire (getAccounts) wiredAccounts({data,error}){
          if (data) {
                    this.data = data[0];
                    this.videoURL = data[0].PMP_Brightcove_VideoPreviewURL__c;
          console.log('Data--->'+data); 
          console.log('URL--->'+data[0].PMP_Brightcove_VideoPreviewURL__c ); 

          } else if (error) {
          console.log(error);
          }
     }

      
}