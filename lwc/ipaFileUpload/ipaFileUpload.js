import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/IPA_FileUpload.uploadFile';

export default class IpaFileUpload extends LightningElement {
    @api recordId;
    fileData;

    openfileUpload(event){
        console.log('INSIDE OPENFILEUPLOAD');
        const file = event.target.files[0];
        var reader = new FileReader();
        console.log('INSIDE OPENFILEUPLOAD FILE'+file);
        reader.onload = () =>{
            var base64 = reader.result.split(',')[1];
            this.fileData ={
                'filename': file.name,
                'base64': base64,
                'recordId' : this.recordId
            }
            console.log('INSIDE FILEDATA IS:'+this.fileData);
            
        }
        reader.readAsDataURL(file);
    }

    handleClick(){
        const {base64, filename, recordId} = this.fileData
        uploadFile({ base64, filename, recordId }).then(result=>{
            this.fileData = null;
            let title = `${filename} uploaded successfully!!`;
            this.toast(title);
        })
    }

    toast(title){
         const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }


}