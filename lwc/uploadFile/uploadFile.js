import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class UploadFile extends LightningElement 
{
    @api recordId;
    get acceptedFormats()
    {
        return ['pdf', '.png', 'jpg', 'jpeg','.zip','doc', '.xlsx']
    }
    handleUploadFinished(Event)
    {
        const uploadFiles = Event.detail.files;
        let uploadFilesNames = '';
        for(let i = 0; i < uploadedFiles.length; i++)
        {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
    }
}