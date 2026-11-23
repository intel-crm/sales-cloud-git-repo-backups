import { LightningElement, wire, track} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
import QUOTE_TYPE from '@salesforce/schema/SBQQ__Quote__c.Pricing_Program_Type_Nm__c';
import { NavigationMixin } from 'lightning/navigation';
import { getFieldValue } from 'lightning/uiRecordApi';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import getAccountId from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.getAccount';
import isProgramTypeSelectionAllowed from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.isRecordTypeSelectionAllowed';
import capSizeCheck from '@salesforce/apex/Pricing_Manage_Small_Volume_Deal.capSizeCheck';
import { getRecord } from 'lightning/uiRecordApi';
import capSizeError from '@salesforce/label/c.Pricing_Tender_Cap_Size_Quarter_Limit_Error';
import smallVolumeQuote from '@salesforce/label/c.Pricing_Tender_Small_Volume_Quote';
import standardQuote from '@salesforce/label/c.Pricing_Tender_Standard_Quote';
import standardQuoteRecordType from '@salesforce/label/c.Pricing_Tender_Quote_Create_Name';
import smallVolumeQuoteRecordType from '@salesforce/label/c.Pricing_Tender_Quote_Create_Small_Volume';

export default class Pricing_Manage_SmallVolumeDeal extends NavigationMixin(LightningElement) {

    @track selectedValue; 
    @track isOpenModal;
    @track recordTypeId;
    @track quoteTypes = [];
    @track contactId;
    @track accountId;
    @track errorMsg = '';
    @track resultValue;

    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user;

    @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: QUOTE_TYPE })
    Values({error, data}) {
        if(data) {
            let quoteOptionType = [];
            for(let i = 0; i < data.values.length; i++) {
                quoteOptionType.push({
                    label: data.values[i].label,
                    value: data.values[i].value
                })
            }
            this.quoteTypes = quoteOptionType;
            console.log('quoteTypes ===> '+JSON.stringify(this.quoteTypes));
        }
        else if(error) {
            console.log('error ===> '+JSON.stringify(error));
        }
        this.selectedValue = standardQuote;
    }


    handleChange(event) {
        this.selectedValue = event.target.value;
        console.log('Selected value',this.selectedValue);
        this.errorMsg = '';
    }


    handleNext() {
        this.errorMsg = '';
        capSizeCheck({accId:this.accountId})
        .then(result =>{
            console.log('result next==>',result);
            this.resultValue = result.split(":");
            let capSize = Number(this.resultValue[1]);
            if(this.resultValue[0] === 'true') {
                this.getSelectedRecordTypeValue();
            } else if (this.resultValue[0] === 'false' && this.selectedValue === standardQuote) {
                this.getSelectedRecordTypeValue();
            }
            else if (this.resultValue[0] === 'false' && this.selectedValue === smallVolumeQuote) {
                console.log('show toast');
                this.errorMsg = capSizeError +' ('+capSize+' Quotes).';
            }
            
        })
        .catch(error => {
            console.log('error',error);
            this.error = error;
        });
        //this.isOpenModal = false;
    }

    getSelectedRecordTypeValue() {
        this.errorMsg = '';
        const rtis = this.objectInfo.data.recordTypeInfos;
        console.log('rtis===>',rtis);
        if(this.selectedValue === standardQuote) {
            this.recordTypeId = Object.keys(rtis).find(recordType => rtis[recordType].name == standardQuoteRecordType);
        }
        else if (this.selectedValue === smallVolumeQuote) {
            this.recordTypeId = Object.keys(rtis).find(recordType => rtis[recordType].name == smallVolumeQuoteRecordType);
        }
        this.isOpenModal = false;
        this.showRecordForm();
        
    }

    openModal() {
        this.errorMsg = '';
        this.contactId = getFieldValue(this.user.data, CONTACT_ID);
        getAccountId({contactId:this.contactId})
        .then(result =>{
            this.accountId = result;
            console.log('account id inside promise call===>',this.accountId);
            isProgramTypeSelectionAllowed({accId: this.accountId})
            .then(result =>{
                console.log('result',result);
                if(result === true) {
                    this.isOpenModal = true;
                } else if(result === false) {
                    this.isOpenModal = false;
                    const rtis = this.objectInfo.data.recordTypeInfos;
                    console.log('inside new quote');
                    this.recordTypeId = Object.keys(rtis).find(recordType => rtis[recordType].name == standardQuote);
                    console.log('record type id',this.recordTypeId);
                    this.showRecordForm();
                }
                console.log('modal open',this.isOpenModal);
            })
            .catch(error => {
                this.error = error;
                console.log('error===>',error);
            });
        })
        .catch(error => {
            this.error = error;
            console.log('error===>',error);
        });
   
    }

    showRecordForm() {
        this.errorMsg = '';
        let recordPage = {
                type: 'standard__objectPage',
                attributes: { 
                    objectApiName: 'SBQQ__Quote__c',
                    actionName: 'new',
                    nooverride : '1'
                },
                state: {
                    recordTypeId : this.recordTypeId 
                }
        };
        this[NavigationMixin.Navigate](recordPage);
        this.selectedValue = standardQuote;
        
    }

    closeModal() {
        this.errorMsg = '';
        this.isOpenModal = false;
        this.selectedValue = standardQuote;
    }
}