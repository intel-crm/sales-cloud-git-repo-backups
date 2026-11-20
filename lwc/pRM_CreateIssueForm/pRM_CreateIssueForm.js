import { LightningElement, track, wire ,api} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import URGENCY_FIELD from '@salesforce/schema/ServiceNow_Case__c.Urgency__c';
import PROGRAM_FIELD from '@salesforce/schema/ServiceNow_Case__c.Program__c';
import saveRecord1 from '@salesforce/apex/PRM_CreateIssueController.saveCase'; 
import psAssignmentCheck from '@salesforce/apex/PRM_CreateIssueController.checkIfUserHasAssignedPermissionSet';
import { NavigationMixin ,CurrentPageReference} from 'lightning/navigation';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import recTypeId from '@salesforce/label/c.pRM_ServiceNowRectypeId';

 const MAX_FILE_SIZE = 30000000; //3mb  

 export default class NewRecordWithFileUpload extends NavigationMixin(LightningElement) {  
   @track title;
   @track descp;
   @track description;
   @track urgency;
   @track program;
   @track selectedValue;
   @api pageRecordId;
   @track uploadedFiles;
   @track fileName;
   @track files;
   @track prType;
   @track isLoadingSave = false;
   @track isLoading = true;
   parameters;
   params;
   desc;
   sfdcBaseURL;
   attachedFiles = [];
   showComponent = false;
   currentPageReference = null; 
   file; fileContents; fileReader; content;  

   renderedCallback() {
    psAssignmentCheck()
      .then(psAssigned => {
        this.isLoading = false;
        if (psAssigned) {
          this.showComponent = true;        
      }  
    }).catch(error => {  
      console.log('error ', error);  
    }); 
     this.prType = 'IPA';
  }


   @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          const regex = /"/g ;
          console.log('HERE',JSON.stringify(currentPageReference.attributes));
          this.pageRecordId = currentPageReference.attributes.recordId || null;
          this.parameters = JSON.stringify(currentPageReference.attributes);
          this.params = this.parameters.replace(regex,' ')+'\n';
       }
       this.sfdcBaseURL = window.location.origin;
       console.log('url'+ this.sfdcBaseURL);
       console.log('test new'+'\n'+'line');
    }
   onNameChange(event) {  
     this.title = event.detail.value;  
   }  
   onDescriptionChange(event) {  
     this.description = event.detail.value;  
   }

  @wire(getPicklistValues,
    {
        recordTypeId: recTypeId, //pass id dynamically
        fieldApiName: URGENCY_FIELD
    }
   
)
stageValues;

@wire(getPicklistValues,
  {
      recordTypeId: recTypeId, //pass id dynamically
      fieldApiName: PROGRAM_FIELD
  })
  programValues;

   handleChange(event) {
    this.urgency = event.detail.value;

}
    prgmHandleChange(event) {
    this.program = event.detail.value;
    }

    onFileUpload(event) {
      if (event.target.files.length > 0) {
        const newFiles = Array.from(event.target.files);
        if (this.uploadedFiles && this.uploadedFiles.length > 0) {
          this.uploadedFiles = [...this.uploadedFiles, ...newFiles];
        } else {
           this.uploadedFiles = newFiles;
        }
    
        for (let i = 0; i < this.uploadedFiles.length; i++) {
          this.attachedFiles = this.uploadedFiles.map(file => file.name);
        }
        // Update the display of file names
        this.fileName = this.attachedFiles.join(', ');
    
        // Assign uploaded files to the files variable
        this.files = Array.from(this.uploadedFiles);
      }
    }
    
    
    
   saveCase() { 
     console.log('submitted');
     this.isLoadingSave = true;
     if (this.uploadedFiles != null) {
       if (this.uploadedFiles.length > 0) {
         const filesData = [];
        
         for (let i = 0; i < this.uploadedFiles.length; i++) {
           const file = this.uploadedFiles[i];
           console.log('submitted1' + file);
  
           const fileReader = new FileReader();
           fileReader.onloadend = () => {
             const fileContents = fileReader.result;
             const base64 = 'base64,';
             const content = fileContents.indexOf(base64) + base64.length;
             const fileContent = fileContents.substring(content);
  
             const fileName = file.name;
  
             // Push the file data to the filesData array
             filesData.push({
               file: encodeURIComponent(fileContent),
               fileName: fileName
             });
  
             console.log('CAS', filesData);
             if (i === this.uploadedFiles.length - 1) {
               console.log('hereee');
               // This is the last file, call the saveRecord1 method with the filesData parameter
               this.saveRecord(filesData);
             }
           };
  
           fileReader.readAsDataURL(file);
         }
       }
     }
      else{
          this.saveRecord(null);  
      }     
     }  
   saveRecord(filesData) {
    console.log('saverecord');
    this.description =   (this.description == undefined)? this.params : this.description+'\n'+ ' '+this.params;
    if(this.pageRecordId!= null){
    this.description = (this.description == undefined)? his.sfdcBaseURL+'/'+this.pageRecordId :this.description +'\n'+this.sfdcBaseURL+'/'+this.pageRecordId;
    }
    console.log('desc'+this.description);
     var caseRec = {  
       'sobjectType': 'ServiceNow_Case__c',  
       'Title__c': this.title,  
       'Description__c': this.description,
       'Urgency__c':this.urgency,
       'Program__c':this.program
     }  
     console.log(caseRec);
     console.log(filesData);
     saveRecord1({  
       caseRecNew: caseRec,  
       filesData1: filesData
     })  
       .then(conId => { 
         this.isLoadingSave = false; 
         this.resetForm();
         const recordId = conId; // Assuming conId contains the ID of the created record
         if (conId) {
         
           this[NavigationMixin.GenerateUrl]({
             type: 'standard__recordPage',
             attributes: {
               recordId: recordId,
               actionName: 'view',
             },
           }).then((url) => {
             const event = new ShowToastEvent({
               title: 'Success!',
               variant: 'success',
               message: 'New Incident has been submitted! See it {1}!',
               messageData: [
                 'Salesforce',
                 {
                   url,
                   label: 'here',
                 },
               ],
             });
             this.dispatchEvent(event);
           });
         }
       
       }).catch(error => { 
        this.isLoadingSave = false;  
        this.dispatchEvent(  
          new ShowToastEvent({  
            title: 'Error',
            message: 'An error occurred. Please try again.',
            variant: 'error', 
          }),  
        ); 
       });  
   }  
   resetForm() {
     this.title = '';
     this.descp='';
     this.value = '';
     this.attachedFiles = [];
     
   }
 }