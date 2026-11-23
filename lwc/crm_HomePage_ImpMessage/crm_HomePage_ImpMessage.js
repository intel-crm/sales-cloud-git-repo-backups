import { LightningElement,wire,api,track } from 'lwc';
import Core_Banner_Imp_Message from '@salesforce/label/c.Core_Banner_Imp_Message';
import {getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.FirstName';
import getBannerTextMsg from '@salesforce/apex/Core_HomePage_Messages.getBannerTextMsgLWC';
import getKPIBannerTextMsg from '@salesforce/apex/Core_HomePage_Messages.getkpiTextMsgLWC';
import kpiTemplate from './crm_HomePage_KPIMessage.html';
import defaultTemplate from './crm_HomePage_ImpMessage.html';

export default class Crm_HomePage_ImpMessage extends LightningElement {

    label = {Core_Banner_Imp_Message};
    @api minimumHeight;
    @api bannerType;
    @track error;
    @track name;
    @track message;
    @track kpiHeadmessage;
    @track kpiBodymessage;

    render(){
        return this.bannerType == 'KPI' ? kpiTemplate: defaultTemplate;
    }

    @wire(getRecord, {recordId: USER_ID,fields: [NAME_FIELD]}) 
    wireuser({error,data}) {
        if (error) {
            this.error = error ; 
        } else if (data) {
            this.name = data.fields.FirstName.value;
        }
    }
    get headerStyling() {
        if (this.minimumHeight) {
            return 'height:'+this.minimumHeight+'px;';
        }
    }

    @wire(getBannerTextMsg)
    getWrapperData({error,data}) {
        if(data){
            this.message = (data === undefined || data == '')? [] : data;
        }
        if(error) {
            console.error('Error -'+error);
            const evnt = new ShowToastEvent({
                title : error.statusText +' !!',
                message : error.body.exceptionType +'::'+ error.body.stackTrace,
                variant : 'Error',
                mode : 'dismissable'
            });
            this.dispatchEvent(evnt);   
        }
    }

    @wire(getKPIBannerTextMsg)
    getKPIData({error,data}) {
        if(data){
            this.kpiHeadmessage = (data === undefined || data == '')? [] : data.Head;
            this.kpiBodymessage = (data === undefined || data == '')? [] : data.Body;
        }
        if(error) {
            console.error('Error -'+error);
            const evnt = new ShowToastEvent({
                title : error.statusText +' !!',
                message : error.body.exceptionType +'::'+ error.body.stackTrace,
                variant : 'Error',
                mode : 'dismissable'
            });
            this.dispatchEvent(evnt);   
        }
    }

}