import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_MDF_ActivityCreation_Bulk extends LightningElement {
    fileTypes = ["application/vnd.ms-excel","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"];   //.csv,.xlsx(in same order) file types are allowed
    
    handleFileUpload(event){
        this.file = event.target.files;
        this.fileName = this.file[0].name;
        this.fileType = this.file[0].type;
        if(this.fileTypes.includes(this.fileType)){ // To check the file type
            let message = `${this.fileName} has been successfully uploaded.`;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Upload Success',
                message: message,
                variant: 'Success'
            }));
        }else{
            let message = `${this.fileName} upload unsuccessfull.`;
            this.file = ''
            this.dispatchEvent(new ShowToastEvent({
                title: 'Upload Failed',
                message: message,
                variant: 'Error'
            }));
        }

    }
}