/*import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formTitle from '@salesforce/label/c.Core_SSR_Create_Request';
import ErrorRequestType from '@salesforce/label/c.Core_SSR_Support_Request_Error';
import ErrorSubject from '@salesforce/label/c.Core_SSR_Subject_Error';
import ErrorDesc from '@salesforce/label/c.Core_SSR_Description_Error';
import ErrorDeadLine from '@salesforce/label/c.Core_SSR_Deadline_Error';
import ErrorUserAgreed from '@salesforce/label/c.Core_SSR_Opportunity_Checkflag_Error';
import getPicklist from '@salesforce/apex/Core_Create_SSR_Controller.getSupport_Request_Type_Picklist_Values';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import CreateSSR from '@salesforce/apex/Core_Create_SSR_Controller.CreateSSR';
const fields = [NAME_FIELD];
export default class Core_SSR_Create extends LightningElement {
    @track errorList = [];
    @track alertViewed = false;
    @track LoadComponent = true;
    @track options = [];
    @track userAgreed= false;
    @track RequestType ='';
    @track Subject='';
    @track Description='';
    @track DeadlineDate='';
    @api recordId;
    @track OppsName;
    @track OppsLink;
    @track isShowModal=false;
    label = {formTitle};
    connectedCallback(){  
        //alert('ConnectedCallBack');
        this.isShowModal = true;
        getPicklist()
            .then(result => {
                this.options = result;
            })
            .catch(error => {
                this.showErrorToast(error.body.message);
            })
    };
    @wire(getRecord, {recordId: '$recordId',fields }) Opportunity;
    renderedCallback() {
        //alert('RenderedCallBack');
        this.OppsName = getFieldValue(this.Opportunity.data, NAME_FIELD);
        this.OppsLink = "/"+this.recordId;
    }

    closeModel(){
        this.alertViewed= false;
        this.errorList = [];
    };
    hideModalBox() {  
        this.isShowModal = false;
        const closeModalEvent = new CustomEvent("modalclose");
        this.dispatchEvent(closeModalEvent);
    };
    handleChange(event){
        //alert(event.target.name);
        if( event.target.name == 'RequestType' ){
            this.RequestType = event.target.value;        
        }
        else if( event.target.name == 'Subject' ){
            this.Subject = event.target.value;
        }
        else if( event.target.name == 'Description' ){
            this.Description = event.target.value;
        }
        else if( event.target.name == 'DeadLineDate' ){
            this.DeadlineDate = event.target.value;
        }
        else if( event.target.name == 'UserAgreed' ){
            this.userAgreed = event.target.checked;
        }
    };

    doValidation(){
        this.errorList = [];
        if (this.RequestType === null || this.RequestType === '') {
            this.errorList.push (ErrorRequestType);
        }
        if (this.Subject === null || this.Subject === undefined || this.Subject.trim().length === 0) {
            this.errorList.push (ErrorSubject);
        }
        if (this.Description === null || this.Description === undefined || this.Description.trim().length === 0) {
            this.errorList.push (ErrorDesc);
        }
        if (this.DeadlineDate == null || this.DeadlineDate.trim() === '') {
            this.errorList.push (ErrorDeadLine);
        }
        if (this.userAgreed === null || this.userAgreed === false) {
            this.errorList.push (ErrorUserAgreed);
        }

    };
    createSSRRequest(){
        this.doValidation();
        if(this.errorList.length>0){
            //alert();
            this.alertViewed=true;
         
        }else{
            this.closeModel();
        alert('OppsID='+this.recordId+'\n'+
            'RequestType='+this.RequestType+'\n'+
                'Subject='+this.Subject+'\n'
                +'Description='+this.Description+'\n'
                +'DeadLineDate='+this.DeadlineDate+'\n'
                +'UserAgreed='+this.userAgreed);
             CreateSSR({ 
                OppsId : this.recordId, 
                RequestType : this.RequestType, 
                Subject : this.Subject,
                Description : this.Description,
                DeadlineDate : this.DeadlineDate,
                UserAgreed : this.userAgreed
            })
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'SSR created',
                    message: 'New SSR created.',
                    variant: 'success'
                });
                
                this.dispatchEvent(event);
                this.isShowModal = false;
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title : 'Error',
                    message : error.body.message,
                    variant : 'error'
                });
                this.dispatchEvent(event);
            });   
                 
            }

       
    };
    showErrorToast(ErrorList) {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: ErrorList,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}*/