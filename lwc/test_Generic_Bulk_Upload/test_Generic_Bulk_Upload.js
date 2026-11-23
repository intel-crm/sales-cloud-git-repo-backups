import { LightningElement, track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getColumnNames from '@salesforce/apex/Test_Generic_bulk_upload_class.getFieldLabels';
import saveFile from '@salesforce/apex/Test_Generic_bulk_upload_class.createRecordsfromCSV';

export default class Test_Generic_Bulk_Upload extends NavigationMixin(LightningElement){
 
 @track fileName;
 @track columns=[];
    
downloadModal = false;
 @api objectApiName;
 @api objectLabel;
isProcessing=false;

 filesUploaded = [];
    fileReader;
    fileContents;

     connectedCallback() {
    /* eslint-disable no-console*/
    
    console.log("LWC objectApiNameinput->" + this.objectApiName);   
    console.log("LWC objectLabelinput->" + this.objectLabel);   
  }


/*handleChange(event){
 this.value= event.detail.value;
 this.objLabel=event.target.options.find(opt => opt.value === event.detail.value).label;
}
get options(){
    return [
         { label: 'Rebate Claim Upload', value: 'Rebate Claim Upload' },
         { label: 'Object 2', value: 'Object 2' },
         { label: 'Object 3', value: 'Object 3' },
    ];
}*/
  handleClose() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: 'All' 
            }
        });
    }
    handleNextClick(){
        this.downloadModal=true;
    }

    downloadBulkuploadTemplateFile(){
        console.log('Objvalue>>' + this.objectApiName );
         getColumnNames({
              objectName : this.objectApiName
         })
        .then(result =>{
              this.columns = result['labels'];
              this.generateCSV();
         })
        .catch(error => {
            console.error(error);
            });
    } 
    generateCSV(){
        try{
            console.log('Objvalue>>' + this.objectLabel );
            let objName=this.objectLabel;
            let csvContent =  '\uFEFF';
            csvContent += this.columns.join(",")+ "\r\n";
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const reader = new FileReader();
             reader.readAsDataURL(blob); 

             reader.onload = function(event) {
             const dataUrl = event.target.result;
            const link = document.createElement("a");
           link.setAttribute("href", dataUrl);
           
            link.setAttribute("download",objName+" "+"Template.csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        };
        
        this.showToast('success', 'Template Downloaded', 'The Template file has been downloaded successfully.');
        }
        catch(error){
            this.showToast('error', 'Error', 'An error occurred while downloading the CSV file.');
        }
    }

     handleFilesChange(event) {
        
        if(event.target.files.length > 0) {
             this.filesUploaded = event.target.files;
             this.fileName = event.target.files[0].name;
           
         }
     }

    deleteFile(){
        this.fileName = '';
        this.filesUploaded = [];
    }
       handleSave() {
         if(this.filesUploaded.length > 0) {
            this.isProcessing=true;
             this.uploadFile();
         }
         else {
             this.fileName = 'Upload a duly filled Rebate Claim Template to proceed further';
         }
     }

        uploadFile() {
        
        const fileExtension = this.filesUploaded[0].name.split('.').pop();
        if (fileExtension !== 'csv') {
            this.isProcessing=false;
            this.showToast('error', 'Error', 'Template format is invalid.It should be .csv format');
        } 
        else {
            this.fileReader = new FileReader();
            this.fileReader.onloadend = () => {
                this.fileContents = this.fileReader.result;
                this.saveTheFile();
            };
            this.fileReader.readAsText(this.filesUploaded[0],'UTF-8');
        }
    }

     saveTheFile() {
    
        const lstFiles = this.fileContents.split('\r\n').filter(part => part !== '');;
        
        // Remove the last element if it is an empty string
        if (lstFiles[lstFiles.length - 1] === '' || lstFiles[lstFiles.length - 1].trim().split(',').every(value => value.trim() === '')) {
            lstFiles.pop();
        }
        if(lstFiles.length===1 || lstFiles.length===0){
            this.isProcessing=false;
            this.showToast('error','Error', 'No data entered in the Uploaded Template. Kindly fill the data for all columns');
        }
        else if(lstFiles.length>1){
            const allValuesEmpty = lstFiles.some(line => line.trim().split(',').every(value => value.trim() === ''));
            if(allValuesEmpty) {
                this.isProcessing = false;
                this.showToast('error', 'Error', 'One or more rows empty in Uploaded Template. Kindly fill the data for all rows');
            } else {
            saveFile({
                base64Data: JSON.stringify(lstFiles.join('\r\n')),
                objectName : this.objectApiName                  
            })
            .then(result => {
                if(result.status==='success'){
                    this.isProcessing=false;
                    //this.parentReference= result.message.split('#');
                   // this.isCreated=true;  
                   this.showToast('success','Success', result.message);                  
                }
                else if(result.status==='failed'){
                    this.isProcessing=false;
                    this.showToast('error','Error', result.message);
                }
            })
            .catch(error => {
                this.isProcessing=false;
                console.error(error);
               this.showToast('error','Error while uploading File!!', error.message);     
            });
        }
    }
        
    }

     showToast(variant, title, message,mode) {
        const event = new ShowToastEvent({
            mode:mode,
            variant: variant,
            title: title,
            message: message
        });
        this.dispatchEvent(event);
    }

}