import { LightningElement,api,track } from 'lwc';
import getIntelSupportOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.getIntelSupportOwner';
import getPartnerSupportOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.getPartnerSupportOwner';
import updateSupportOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.updateSupportOwner';
import hasProjectEditAccess from '@salesforce/apex/Core_IPS_ProjectController_Lex.hasProjectEditAccess';
import detailPage from '@salesforce/label/c.Core_IPS_Project_Detail_Page';
import errorMsg from '@salesforce/label/c.Core_IPS_Project_Access_Error';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    { label: 'FirstName', fieldName: 'FirstName', type: 'text' },
    { label: 'LastName', fieldName: 'LastName', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'UserId', fieldName: 'UserId', type: 'email' },
];
export default class Core_IPS_AddProjSupportOwner_Lex extends LightningElement {

    intelSupportOwner = [];
    partnerSupportOwner = [];
    intelOwnerData = [];
    partnerOwnerData = [];
    selectedIntelOwner=[];
    selectedPartnerOwner=[];
    searchKeyISO = '';
    searchKeyPSO = '';
    updateProj;
    spinner=true;
    projDetailPage = detailPage;
    projAccessError = errorMsg;
    columns = columns.filter(col =>col.label !== 'UserId');
    @api recordId;
    dataValue = {'FirstName' : 'Blank'};

    connectedCallback() {
        this.RefreshValues();
    }
    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 500));
        this.hasProjectEditAccess();
        this.getIntelSupportOwner1();
        this.getPartnerSupportOwner1();
    }
    hasProjectEditAccess(){
        return hasProjectEditAccess({
            projectId: this.recordId
        })
        .then(data=>{
            if(data==true)
            this.updateProj = true;
            else
            this.updateProj = false;
            this.spinner = false;
            
        })
        .catch(error=>{
            console.log('error :'+error);
        })
    }
    getIntelSupportOwner1(){
        return getIntelSupportOwner({
            projectId: this.recordId
        })
        .then(data=>{
            for (let i = 0; i < data.length; i++) {
                let obj = {
                    'FirstName' : data[i].Core_IPS_User__r.FirstName,
                    'LastName' : data[i].Core_IPS_User__r.LastName,
                    'Email' : data[i].Core_IPS_User__r.Email,
                    'UserId' : data[i].Core_IPS_User__c,
                };
                this.intelSupportOwner = [...this.intelSupportOwner, obj];
            } 
            this.intelSupportOwner = [...this.intelSupportOwner, this.dataValue];
            this.intelOwnerData = this.intelSupportOwner;
        })
        .catch(error=>{
            this.intelSupportOwner = [...this.intelSupportOwner, this.dataValue];
            this.intelOwnerData = this.intelSupportOwner;
        })
    }
    getPartnerSupportOwner1(){
        return getPartnerSupportOwner({
            projectId : this.recordId
        })
        .then(data=>{
            for (let i = 0; i < data.length; i++) {
                let obj = {
                    'FirstName' : data[i].Core_User__r.FirstName,
                    'LastName' : data[i].Core_User__r.LastName,
                    'Email' : data[i].Core_User__r.Email,
                    'UserId' : data[i].Core_User__c,
                };
                this.partnerSupportOwner = [...this.partnerSupportOwner, obj];
            }  
            this.partnerSupportOwner = [...this.partnerSupportOwner, this.dataValue];
            this.partnerOwnerData = this.partnerSupportOwner;
        })
        .catch(error=>{
            this.partnerSupportOwner = [...this.partnerSupportOwner, this.dataValue];
            this.partnerOwnerData = this.partnerSupportOwner;
        })
    }
    handleSearchKeyISO(event){
        this.searchKeyISO = event.target.value;      
    }
    handleSearchISO(){
        try{
            let intelOwner = [];
            if(this.searchKeyISO) {
                this.intelSupportOwner.forEach(ISO =>{
                    if(ISO.FirstName != undefined && ISO.FirstName.toLowerCase().indexOf(this.searchKeyISO.toString().toLowerCase()) !== -1){
                        intelOwner.push(ISO);
                    } else if(ISO.LastName != undefined && ISO.LastName.toLowerCase().indexOf(this.searchKeyISO.toString().toLowerCase()) !== -1){
                        intelOwner.push(ISO);
                    } else if(ISO.Email != undefined && ISO.Email.toLowerCase().indexOf(this.searchKeyISO.toString().toLowerCase()) !== -1){
                        intelOwner.push(ISO);
                    } 
                });
                intelOwner = [...intelOwner, this.dataValue];
                this.intelOwnerData = intelOwner;
            } else {
                this.intelOwnerData = this.intelSupportOwner;
            }
        } catch(error){
            console.log('error in search handler ');
        }

    }
    handleResetISO(){
        this.template.querySelector('lightning-input[data-name="searchTextISO"]').value = null;
        this.intelOwnerData = this.intelSupportOwner;
    }

    handleSearchKeyPSO(event){
        this.searchKeyPSO = event.target.value;      
    }
    handleSearchPSO(){
        try{
            let partnerOwner = [];
            if(this.searchKeyPSO) {
                this.partnerSupportOwner.forEach(PSO =>{
                    if(PSO.FirstName != undefined && PSO.FirstName.toLowerCase().indexOf(this.searchKeyPSO.toString().toLowerCase()) !== -1){
                        partnerOwner.push(PSO);
                    } else if(PSO.LastName != undefined && PSO.LastName.toLowerCase().indexOf(this.searchKeyPSO.toString().toLowerCase()) !== -1){
                        partnerOwner.push(PSO);
                    } else if(PSO.Email != undefined && PSO.Email.toLowerCase().indexOf(this.searchKeyPSO.toString().toLowerCase()) !== -1){
                        partnerOwner.push(PSO);
                    } 
                });
                partnerOwner = [...partnerOwner, this.dataValue];
                this.partnerOwnerData = partnerOwner;
            } else {
                this.partnerOwnerData = this.partnerSupportOwner;
            }
        } catch(error){
            console.log('error in search handler ');
        }

    }
    handleResetPSO(){
        this.template.querySelector('lightning-input[data-name="searchTextPSO"]').value = null;
        this.partnerOwnerData = this.partnerSupportOwner;
    }
    getSelectedIntelOwner(event){
        this.selectedIntelOwner = event.detail.selectedRows;
    }
    getSelectedPartnerOwner(event){
        this.selectedPartnerOwner = event.detail.selectedRows;
    }
    handleSave(){

        let selectedIntel=null, selectedPartner=null;
        if(this.selectedIntelOwner.length>0 && this.selectedPartnerOwner.length>0){ 
            if(this.selectedIntelOwner[0].FirstName=='Blank') selectedIntel = 'none';
            if(this.selectedPartnerOwner[0].FirstName=='Blank') selectedPartner = 'none';
            if(this.selectedIntelOwner[0].FirstName!='Blank') selectedIntel = this.selectedIntelOwner[0].UserId;
            if(this.selectedPartnerOwner[0].FirstName!='Blank') selectedPartner = this.selectedPartnerOwner[0].UserId;
         } 
        else{
            if(this.selectedIntelOwner.length>0 && this.selectedIntelOwner[0].FirstName!='Blank') {selectedIntel = this.selectedIntelOwner[0].UserId}
            if(this.selectedPartnerOwner.length>0 && this.selectedPartnerOwner[0].FirstName!='Blank') {selectedPartner = this.selectedPartnerOwner[0].UserId}
            if(this.selectedIntelOwner.length>0 && this.selectedIntelOwner[0].FirstName=='Blank') {selectedIntel = 'none'}
            if(this.selectedPartnerOwner.length>0 && this.selectedPartnerOwner[0].FirstName=='Blank') {selectedPartner = 'none'}
        }
        if(this.selectedIntelOwner.length>0 || this.selectedPartnerOwner.length>0){
        updateSupportOwner({projectId : this.recordId,supportOwner : selectedIntel,partnerOwner : selectedPartner})
            .then(result=>{
                if(result=='Success'){ 
                    window.location.href = this.projDetailPage +this.recordId + '/view'
                    const event = new ShowToastEvent({
                        message: 'Updated Successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                }
                else if(result=='failed'){ 
                    const event = new ShowToastEvent({
                        message: 'Unable to Update Owners',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(error=>{
                console.log("Error in updating Support Owners");
            })
        }
        else  
            this.dispatchEvent(new CloseActionScreenEvent());  
    }
    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }  
}