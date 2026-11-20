import { LightningElement, api, track} from 'lwc';
import getUploadedTermsnCondition from '@salesforce/apex/PRM_CompanyProfileController.getUploadedTermsnCondition';
import showUploadedDoc from '@salesforce/apex/PRM_CompanyProfileController.showUploadedDoc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import AttachTermsAndConditions from "@salesforce/label/c.PRM_Terms_and_Conditions";
import AttachDocuments from "@salesforce/label/c.PRM_Attach_Documents";
import Close from "@salesforce/label/c.PRM_Close";
import TypeofAttachment from "@salesforce/label/c.PRM_Type_of_Attachment";
import TermsAndConditions from "@salesforce/label/c.PRM_LA_Header";

export default class PRM_UploadDocuments extends NavigationMixin(LightningElement) {

    //@api recordId='0018A00000UcEYKPRODUCTION';
    @api recordId;
    @track AcceptedFormatsArr = [];
    showUploadLWC=false;
    showModal = false;
    showUploader = false;
    uploaderVisibility = false;
    docArray=[];
    docList=[];
    labels={
        AttachTermsAndConditions,
        AttachDocuments,
        Close,
        TypeofAttachment,
        TermsAndConditions
    }

    get acceptedFormats() {
        return ['.png', '.jpeg', '.jpg', '.doc', '.docx', '.pdf'];      
    }

    handleUploadFinished(event) {
        this.showUploader = false;
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let documentArray=[];
        //('No. of files uploaded : ' + JSON.stringify(uploadedFiles));
        if(uploadedFiles.length > 0){
            uploadedFiles.map(uploadedDoc => {
                documentArray.push({title: uploadedDoc.name, documentId:uploadedDoc.documentId})
            });
        }
        this.docArray = [...documentArray];
        if(this.docArray.length > 0){
            this.saveUploadedDoc(this.docArray)
        }
    }

    /**
     * 
     * @param {*} docArray 
     * to save uploaded documents
     */
    saveUploadedDoc(docArray){
        getUploadedTermsnCondition({docArray: docArray, accId :this.recordId}).then(response => {
            if(response){
                 this.displayShowToastMessage('Document uploaded successfully','DocumentUpload','success');
            }
        })       
        .catch(error => {
            console.log("Error in  saveUploadedDoc-->", error);
            this.displayShowToastMessage('Error occured','DocumentUpload','error');
        });
    }

    /**
     * to check if profile has access to upload documents
     */
    showDoc(){
        showUploadedDoc().then(response => {
            if(response){
                this.showUploadLWC = true;
            }})
            .catch(error =>{
                console.log('Error',error);
            });
    }
    
    showPopUp(){
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
    }

    handleClick(){
        this.showUploader = true;
        this.showModal = false;
    }

    closeUploader(){
        this.showUploader = false;
    }

    displayShowToastMessage(errorMessage, title, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: errorMessage,
            variant: variant,
        });

        this.dispatchEvent(toastEvent);

    }

    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
 
    connectedCallback(){
        this.showDoc();
        console.log('Account Id----->',this.recordId);
    }
}