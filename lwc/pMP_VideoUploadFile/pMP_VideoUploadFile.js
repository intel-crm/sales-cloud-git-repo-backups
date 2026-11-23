/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';    
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import UploadDocToS3Server from '@salesforce/apex/S3Controller.UploadDocToS3Server';

export default class PMP_VideoUploadFile extends LightningElement {
    @api recordId; //get the recordId for which files will be attached.
    selectedFilesToUpload = []; //store selected files
    @track showSpinner = false; //used for when to show spinner
    @track fileName; //to display the selected file name
    file; //holding file instance
    myFile;    
    fileType;//holding file type
    

    //get the file name from user's selection
  handleSelectedFiles(event) {
    if (event.target.files.length > 0) {
      this.selectedFilesToUpload = event.target.files[0];
      this.fileName = event.target.files[0].name;
      this.fileType = event.target.files[0].type;
      console.log("fileName ====> " + this.fileName);
      console.log("fileName ===type=> " + event.target.files[0].type);
      console.log("id ====> " + event.target.files[0].id);    }
  }
    
  uploadToAWS(){
      const recID = '0698A000001M6gk';
    UploadDocToS3Server({recordId:recID}).then(response => {
        this.response = response;
        if(this.response){
          const evt = new ShowToastEvent({
            title: 'Success!',
            message: 'Uploaded to AWS successfully.',
            variant: 'success',
            mode: 'dismissable',
            duration:'5000',
            key: 'info_alt'
            });
         this.dispatchEvent(evt);
        }
    }).catch(error=>{
      const evt = new ShowToastEvent({
        title: 'Error!',
        message: 'Didnt upload to AWS.',
        variant: 'error',
        mode: 'dismissable',
        duration:'5000',
        key: 'info_alt'
        });
     this.dispatchEvent(evt);
    });

  }
}