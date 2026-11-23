import { LightningElement ,api,wire,track} from 'lwc';
import getField from "@salesforce/apex/Core_IPS_CaseDetailView_Controller.getFieldName";
import getStatus from "@salesforce/apex/Core_IPS_CaseDetailView_Controller.getStatus";
import getSubStatus from "@salesforce/apex/Core_IPS_CaseDetailView_Controller.getSubStatus";
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS from '@salesforce/schema/Case.Status';
import CASEID_FIELD from '@salesforce/schema/Case.Id';
import SUBSTATUS from '@salesforce/schema/Case.Core_Sub_Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Core_IPS_BES_Section_Name from '@salesforce/label/c.Core_IPS_BES_Section_Name';
const FIELDS = [STATUS,SUBSTATUS];
export default class Core_IPS_CaseDetailView_Lex extends LightningElement {
    @api recordId;
    objectApiName='Case';
    @track caseDetailsfields;
    @track subStatusOpt;
    @track lifeCyclefields;
    @track hotCasefields;
    @track systemfields;
    @track caseDescriptionfields;
    @track backendSystemfields;
    @track serviceLevelfields;
    @track additionalfields;
    @track showCaseDetailsfields = true;
    @track showLifeCyclefields = true;
    @track showHotCasefields = true;
    @track showSystemfields = true;
    @track showBackendSystemfields = true;
    @track showCaseDescriptionfields = false;
    @track showServiceLevelfields = true;
    @track showAdditionalfields = true;
    @track status;
    @track substatus;
    @track disableSubStatus = false;
    @track isShowModal = false;
    @track statusValue;
    @track substatusValue;
    @track spinner = false;
    @track options;
    @track tempSubStatus;
    @track hideSubStatus = true;
    @track hideStatus = true;
    @track label = 'Collapse All';
    activeSections = ['Case Description Information','Case Detail','Life Cycle Management','Hot Case Management','System/Integration Information',
    'New Backend System','Case Service Level','Additional Information'];
    Core_IPS_BES_Section_Name=Core_IPS_BES_Section_Name;

    @wire(getStatus, {caseId:'$recordId'})
    statusValues({error, data}){
      if(error){
            console.log('ShoError-->',error);
      } else if(data){
        this.options = data;
      }
    }

    @wire(getRecord, { recordId:'$recordId', fields: FIELDS})
    loadFields({error, data}){
        if(error){
            console.log('41--',error); 
        }else if(data){
            this.status = getFieldValue(data, STATUS);
            if(this.status == 'New'){
                this.disableSubStatus = true;
            }
            this.substatus = getFieldValue(data, SUBSTATUS);
            getSubStatus({caseId : this.recordId, currentStatus : this.status, currentSubStatus : this.substatus
            }).then(result =>{
                this.subStatusOpt = result;
                if(this.subStatusOpt.length >=1)
                  this.disableSubStatus = false;
            })
            .catch(error =>{
               console.log('subStatuserr-->',error);
            })
        }
    }
    
    connectedCallback(){
        getField({
            recordId : this.recordId,
        }).then( result =>{
            for(let key in result){
                console.log('key ==== ',key);
                if(key == 'Case Detail'){
                    this.caseDetailsfields = result[key];
                    if(this.caseDetailsfields.length == 0){
                        this.showCaseDetailsfields = false;
                    }
                } else if(key == 'Life Cycle Management'){
                 this.lifeCyclefields = result[key];
                 for(var i=0;i<this.lifeCyclefields.length;i++){
                     if(this.lifeCyclefields[i]=='Status') {
                     this.lifeCyclefields.splice(i, 1);
                     this.hideStatus = false;
                     }
                     if(this.lifeCyclefields[i]=='Core_Sub_Status__c') {
                        this.lifeCyclefields.splice(i, 1); 
                        this.hideSubStatus = false;
                     }
                 }
                 if(this.lifeCyclefields.length == 0 && (this.hideStatus == true && this.hideSubStatus == true)){
                    this.showLifeCyclefields = false;
                }
                } else if(key == 'Hot Case Management'){
                    this.hotCasefields = result[key];
                    if(this.hotCasefields.length == 0){
                        this.showHotCasefields = false;
                    }
                } else if(key == 'System/Integration Information'){
                    this.systemfields = result[key];
                    if(this.systemfields.length == 0){
                        this.showSystemfields = false;
                    }
                } else if(key == 'New Backend System'){
                    this.backendSystemfields = result[key];
                    if(this.backendSystemfields.length == 0){
                        this.showBackendSystemfields = false;
                    }
                } else if(key == 'Case Description Information'){
                    this.caseDescriptionfields = result[key];
                    if(this.caseDescriptionfields.length > 0){
                        this.showCaseDescriptionfields = true;
                    }
                } else if(key == 'Case Service Level'){
                    this.serviceLevelfields = result[key];
                    if(this.serviceLevelfields.length == 0){
                        this.showServiceLevelfields = false;
                    }
                } else if(key == 'Additional Information'){
                    this.additionalfields = result[key];
                    if(this.additionalfields.length == 0){
                        this.showAdditionalfields = false;
                    }
                }
            }
        }).catch( error =>{
            console.log('Error--',error);
        })
    }
    handleChange(event) {
        this.tempSubStatus = '';
        if(event.target.name == 'Status'){
            this.statusValue = event.detail.value;
            if(this.tempSubStatus == 'Close-Pending'){
                this.tempSubStatus = '';
            }
        getSubStatus({caseId : this.recordId, currentStatus : event.detail.value, currentSubStatus : this.tempSubStatus
        })
        .then(result =>{
            this.subStatusOpt = result;
            if(this.subStatusOpt.length >=1)
              this.disableSubStatus = false;
            else
            this.disableSubStatus = true;
        })
        .catch(error =>{
           console.log('subStatuserr-->',error);
        })
    } else{
        this.substatusValue = event.detail.value;
    }
    }
    handlePopup(event){
        this.isShowModal=true;
    }
    hideModalBox(event){
        this.isShowModal=false;
    }
    saveMethod(){
        if(this.hideSubStatus == false){
        var element=this.template.querySelector('.substatusvalidation');
        if(element.value == null && this.subStatusOpt.length >=1) {
            element.setCustomValidity("Please select the field");
            element.reportValidity();
        } else {
            this.handleSaveRecord();
         }
    } else {
        this.handleSaveRecord();
     }
    }
   
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleClick(event){
        if(event.target.label === 'Collapse All') {
          this.activeSections = [];
          this.label = 'Expand All';
        } else {
            this.label = 'Collapse All';
        this.activeSections = ['Case Description Information','Case Detail','Life Cycle Management','Hot Case Management','System/Integration Information',
        'New Backend System','Case Service Level','Additional Information'];
        }
    }

    handleSaveRecord() {
        this.spinner = true;
        const fields = {};
        fields[CASEID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS.fieldApiName] = this.statusValue;
        if(this.statusValue == 'New'){
            fields[SUBSTATUS.fieldApiName] = '';
        }
        else{
            fields[SUBSTATUS.fieldApiName] = this.substatusValue;
        }
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.spinner = false;
           this.isShowModal = false;
           window.location.reload();
        })
        .catch(error => {
            let errorMessage = JSON.stringify(error.body.output.errors[0].message);
            this.showToast('Error', errorMessage , 'error');
            console.log('InvalidError--'+errorMessage);
            this.spinner = false;
        });
    }
    handleSuccess(event) {
        window.location.reload();
    }
}