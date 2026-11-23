import { LightningElement, track, wire } from "lwc";
import uploadFileOrFail from '@salesforce/apex/AttachmentUploadController.uploadFileOrFail';       
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import { loadScript } from "lightning/platformResourceLoader";

export default class Video_FileUpload_To_AWSS3 extends LightningElement {
    myFile;
    base64FileData;
    handleSelectedFile(event) {
    if(event.target.files.length !== 1) {
		    return;
    }
    this.handleFileUpload(event.target.files[0]);
}
handleFileUpload(file) {
    console.log('***********file****'+file);
    let fileReaderObj = new FileReader();
    fileReaderObj.onloadend = (() => {
        let fileContents = fileReaderObj.result;
        //console.log('***********fileContents****'+fileContents);
        fileContents = fileContents.substr(fileContents.indexOf(',')+1)
         //console.log('***********fileContents**after**'+fileContents);
        
        //let sliceSize = 1024;
        let byteCharacters = atob(fileContents);
        let bytesLength = byteCharacters.length;
        let slicesCount = Math.ceil(bytesLength / 1024);                
        let byteArrays = new Array(slicesCount);
        for (let sliceIndex = 0; sliceIndex < slicesCount; ++sliceIndex) {
            let begin = sliceIndex * 1024;
            let end = Math.min(begin + 1024, bytesLength);                    
            let bytes = new Array(end - begin);
            for (let offset = begin, i = 0 ; offset < end; ++i, ++offset) {
                bytes[i] = byteCharacters[offset].charCodeAt(0);                        
            }
            byteArrays[sliceIndex] = new Uint8Array(bytes);                    
        }
        
        //from arraybuffer create a File instance
        this.myFile =  new File(byteArrays, this.fileName, { type: this.fileType });
        //console.log('***********myFile****'+this.myFile);
    
        let reader = new FileReader();
        reader.onloadend = (async () => {
                // Call to our APEX function
	        await uploadFileOrFail({
                    parentId: this.recordId,
		    filename: file.name,
		    fileContent: encodeURIComponent(reader.result.substr(reader.result.indexOf(',')+1))
		});
	     
        });

        reader.readAsDataURL(this.myFile);                                 
    });

    fileReaderObj.readAsDataURL(file);
}

}