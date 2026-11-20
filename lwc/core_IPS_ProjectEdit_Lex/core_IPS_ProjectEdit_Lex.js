import { LightningElement,track,api, wire } from 'lwc';
import {CurrentPageReference,NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USERPROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import NO_OF_ACCOUNTS from '@salesforce/schema/Core_IPS_Project__c.Core_Number_of_Accounts__c';
import NO_OF_MEMBERS from '@salesforce/schema/Core_IPS_Project__c.Core_Number_of_Users__c';
import NO_OF_PRODUCTS from '@salesforce/schema/Core_IPS_Project__c.Core_Number_of_Products__c';
import hasProjectEditAccess from '@salesforce/apex/Core_IPS_ProjectController_Lex.hasProjectEditAccess';
export default class Core_IPS_ProjectEdit_Lex extends NavigationMixin(LightningElement) {
    @api recordId;
    projectId;
    @track currentUserProfileName;
    @track showErrormessage;
    @track hasAccess = true;
    @track CurrentPageReference;
    editMode=false;
    saveAndNew=false;
    pageReload = false;
    //spinner = true;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if(this.pageReload==true){
            window.location.reload();
        }
    }
    connectedCallback() {
        if(this.pageReload==false){
            this.pageReload = true;
        }
        this.RefreshValues();
     }
     async RefreshValues() {
         await new Promise(resolve => setTimeout(resolve, 1500));
         if(this.recordId!=undefined){
            this.editMode = true;  
            this.handleEditProject();
               
         }    

     }
     @track projStatus;
     @track no_of_accounts;
     @track no_of_members;
     @track no_of_products;
    handleSubmit(event) {
        //if(this.editMode==false){
           event.preventDefault();  
           const fields = event.detail.fields;
           this.projStatus = fields.Core_Status__c;
           console.log('Handle Submit Project');
           console.log("Handle subm Proj"+ this.no_of_accounts);
            /*if((fields.Core_Status__c =='Active'||fields.Core_Status__c =='Inactive') && this.editMode==false){
                this.dispatchEvent(new ShowToastEvent({
                   message: 'Status must be set to Draft when creating a Project',
                   variant: 'error',
                }));
            }
            else if(fields.Core_Status__c =='Active' && this.editMode==true && (fields.Core_Number_of_Accounts__c < 1 || fields.Core_Number_of_Products__c < 1 || fields.Core_Number_of_Users__c < 1)){
                this.dispatchEvent(new ShowToastEvent({
                   message: 'Project cannot be made Active without atleast one Account and one Product and one Project Member',
                   variant: 'error',
                }));
            }
            else if(fields.Core_IPS_Private__c== true &&(fields.Core_Status__c =='Active'||fields.Core_Status__c =='Inactive') && this.currentUserProfileName!='IPS Data Migration'){
                this.dispatchEvent(new ShowToastEvent({
                   message: 'Premier Support Projects must be in the Draft state when being set to Private',
                   variant: 'error',
                }));
            }
            else{*/
               this.template.querySelector('lightning-record-edit-form').submit(fields);
            //}
        //}          
    }
    handleSuccess(event){
        this.projectId = event.detail.id;
        const fields = event.detail.fields;
        
            if(this.editMode==false){
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Project created successfully',
                    variant: 'success',
                }));
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Project updated successfully',
                    variant: 'success',
                }));
                if(this.saveAndNew==true){
                this.recordId=undefined;
                this.editMode=false;
                }
            }
            if(this.saveAndNew == false){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId : this.projectId,
                    objectApiName: 'Core_IPS_Project__c',
                    actionName: 'view'
                },
            });
            }
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.saveAndNew = false;
    }
    handleCancel(event){
        console.log('editMode-'+this.editMode);
        if(this.editMode==false){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Core_IPS_Project__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    else{
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId : this.recordId,
                objectApiName: 'Core_IPS_Project__c',
                actionName: 'view'
            },
        });
    }
    }
    handleError(event){
        console.log("Handle Error Proj"+ this.no_of_accounts);
        //const fields = event.detail.fields;
        /*if(this.projStatus =='Active' && this.editMode==true && (this.no_of_accounts < 1 || this.no_of_products < 1 || this.no_of_members < 1)){
            this.dispatchEvent(new ShowToastEvent({
               message: 'Project cannot be made Active without atleast one Account and one Product and one Project Member',
               variant: 'error',
            }));
        }
        else{
            this.dispatchEvent(new ShowToastEvent({
                message: 'Review all error messages below to correct your data.',
                variant: 'error',
            }));
        } */
        this.dispatchEvent(new ShowToastEvent({
            message: event.detail.detail,
            variant: 'error',
        }));
        console.log('ErrorHandle--'+JSON.stringify(event.detail.detail));          
        
    }
    handleSaveandNew(event){
        this.saveAndNew = true;
        console.log('savendnewM--'+this.saveAndNew);
    }

    @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_NAME]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserProfileName = data.fields.Profile.value.fields.Name.value; 
            if(this.currentUserProfileName === 'Sales Ops' && this.editMode == false && (this.recordId == null || this.recordId==undefined) ){
                this.hasAccess = false;
            }else{
                this.hasAccess = true;
            }
            console.log('PBS GET Proj--'+this.hasAccess);
        } else if (error) {
            this.showErrormessage = error ;
        }
    }
    handleEditProject(){
        hasProjectEditAccess({
            projectId: this.recordId
        })
        .then(data=>{
            if(data==true){
              this.hasAccess = true;
            }
            else{
              this.hasAccess = false;
            }
            console.log('PBS Edit Proj--'+this.hasAccess);
        })
        .catch(error=>{
            this.showErrormessage = error ;
        })
    }
    @wire(getRecord, 
        { recordId: '$recordId', fields: [NO_OF_ACCOUNTS,NO_OF_MEMBERS,NO_OF_PRODUCTS] })
    projectData ({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.no_of_accounts = getFieldValue(data,NO_OF_ACCOUNTS );
            this.no_of_members = getFieldValue(data,NO_OF_MEMBERS);
            this.no_of_products = getFieldValue(data,NO_OF_PRODUCTS);
            
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log('ProjectError'+JSON.stringify(this.error));
        }
       
    }

}