import { LightningElement, api,track, wire } from 'lwc';
import validateDealRegValues from '@salesforce/apex/PCC_DealFormValidationController.validateDealRegValues';
import { getRecord } from 'lightning/uiRecordApi';



export default class PCC_SubmitDealErrorPane extends LightningElement {
        @api recordId;
        @track errorWrapperList=[];
        @track loading = false;
        @api isSubmit = false;
        errorWrapperListSize = false;

        connectedCallback(){
            this.fetchDealRegFields();
        }

        refresh(){
            this.fetchDealRegFields();
        }

        @wire(getRecord, { recordId: '$recordId'})
        wiredRecord({ data }) {
            if (data) {
                this.fetchDealRegFields();
            }
        }

        fetchDealRegFields(){
            this.loading = true;
            validateDealRegValues({ recId: this.recordId ,isSubmit :this.isSubmit})
            .then((result) => {
                this.loading=false;
                let map = {};
                if(Object.hasOwn(result, 'errorFieldMap')){
                    this.errorWrapperList=[];
                    const tempMap = new Map(Object.entries(result.errorFieldMap));
                    tempMap.forEach((value, key) => {
                        map = {};
                        map['label'] = key;
                        map['value'] = value;
                        this.errorWrapperList.push(map);
                    });
                    if(this.errorWrapperList.length>=1){
                        this.errorWrapperListSize=true;
                    }
                    else{
                        this.errorWrapperListSize=false;
                    }
                }
                this.loading=false;
                if (this.isSubmit) {
                    const eventDetail = {
                        isSuccess: false,
                        message: '',
                        recordError: this.errorWrapperListSize,
                    };
                    if (result.customError !== '' && result.customError !== undefined ) {
                        eventDetail.isSuccess = false;
                        eventDetail.message = result.customError;
                    } else if (this.errorWrapperList.length === 0) {
                        eventDetail.isSuccess = true;
                        eventDetail.message = result.dealRegName;
                    }
                    this.dispatchEvent(new CustomEvent('dealsubmission', { detail: eventDetail }));
                }
            });
        }

        get scrollme(){
            if(!this.isSubmit && this.errorWrapperList.length>2){
                return 'scrollme';
            }
            return '';
        }
        get backgroundval(){
            if(!this.isSubmit){
                return 'bgcolor slds-box slds-box_x-small';
            }
            return '';
        }
}