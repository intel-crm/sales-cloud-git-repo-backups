import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/PMP_TopicsImageUpload.uploadFile'
export default class IpaTopicsImageUpload extends LightningElement {
    //IPA2.0:TWC729-8114 Topics Removal/Event Removal
    @api recordId;
    /*fileData
    preview
    openfileUpload(event) {
        //preview = document.querySelector('img');
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.preview = reader.result;
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        if (file) {
            reader.readAsDataURL(file)
        }
    }
    
    handleClick(){
        const {base64, filename, recordId} = this.fileData
        uploadFile({ base64, filename, recordId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }*/
}