import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import qtEndCustomerOppId from '@salesforce/schema/SBQQ__Quote__c.Pricing_End_Customer_Opportunity_Txt__c';
import qtAccountId from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c';
import qtProjectName from '@salesforce/schema/SBQQ__Quote__c.Pricing_Project_Name_Nm__c';
import qtBidDate from '@salesforce/schema/SBQQ__Quote__c.Pricing_Bid_Dt__c';
import qtType from '@salesforce/schema/SBQQ__Quote__c.Pricing_Program_Type_Nm__c';
import getOpportunityRecordTypeId from '@salesforce/apex/pricing_Opportunity_On_Quote.getOpportunityRecordTypeId';
import isAEorFSEUser from '@salesforce/apex/pricing_Opportunity_On_Quote.isAEorFSEUser';
import Pricing_New_Opportunity_Error from '@salesforce/label/c.Pricing_New_Opportunity_Error';
import Pricing_Tender_CCG_Quote from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import Pricing_End_Customer_Opportunity_Error from '@salesforce/label/c.Pricing_End_Customer_Opportunity_Error';


export default class Pricing_New_Opportunity_On_Quote extends NavigationMixin(LightningElement) {

    @api recordId;
    @track oppoRecordTypeId = [];
    @track qtOppData = {
        qtAccountId: '',
        qtProjectName: '',
        qtBidDate: '',
        oppStageName: 'Qualify',
        oppType: 'Deal: Sell-to',
        oppProductSegment: '',
        oppMilitaryAerospaceGovmtEndUse: 'No'
    };

    openModal = false;
    noAccess = false;
    errorMsg = '';
    selectedOppRecordType = '';
    disableNext = true;
    endCustOppId;

    @wire(getRecord, { recordId: '$recordId', fields: [qtEndCustomerOppId, qtAccountId, qtProjectName, qtBidDate, qtType] })
    quote({ error, data }) {
        if (data) {
            this.endCustOppId = data.fields.Pricing_End_Customer_Opportunity_Txt__c.value;
            if (this.endCustOppId != null && this.endCustOppId != undefined && this.endCustOppId != '') {
                this.errorMsg = Pricing_End_Customer_Opportunity_Error;
                this.noAccess = true;
                this.openModal = false;
            } else {
                this.getAEorFSEUser();
            }
            this.qtOppData.qtAccountId = data.fields.SBQQ__Account__c.value;
            this.qtOppData.qtProjectName = data.fields.Pricing_Project_Name_Nm__c.value;
            this.qtOppData.qtBidDate = data.fields.Pricing_Bid_Dt__c.value;
            this.qtOppData.oppProductSegment = data.fields.Pricing_Program_Type_Nm__c.value == Pricing_Tender_CCG_Quote ? 'Client Computing' : 'Data Center Computing';

        } else if (error) {
            this.showToastMsgError(error);
            console.error('Error @ getRecord --> ', JSON.stringify(error));
        }
    };

    getAEorFSEUser() {
        isAEorFSEUser()
            .then(data => {
                if (data != null && data != undefined) {
                    if (data) {
                        this.openModal = true;
                        this.getOpportunityRecordId();
                    } else {
                        this.errorMsg = Pricing_New_Opportunity_Error;
                        this.noAccess = true;
                    }
                }
            })
            .catch(error => {
                this.showToastMsgError(error);
                console.error('Error @ isAEorFSEUsers --> ' + JSON.stringify(error));
            });
    }

    //method to get Opportunity Record Type Id
    getOpportunityRecordId() {
        getOpportunityRecordTypeId()
            .then(data => {
                let any = [];
                any = JSON.parse(data);
                any.forEach(record => {
                    if (record.active && record.available && record.name != 'Master') {
                        let rec = {};
                        rec["label"] = record.name;
                        rec["value"] = record.recordTypeId;
                        this.oppoRecordTypeId.push(rec);
                    }
                });
            })
            .catch(error => {
                this.showToastMsgError(error);
                console.error('Error @ getOpportunityRecordId --> ', JSON.stringify(error));
            });
    }

    handleQLTypeSelection(event) {
        this.selectedOppRecordType = event.target.value;
        this.disableNext = false;
    }

    handleNext() {
        this.disableNext = true;
        const defaultValues = encodeDefaultFieldValues({
            // AccountId: this.qtOppData.qtAccountId, 
            Name: this.qtOppData.qtProjectName,
            CloseDate: this.qtOppData.qtBidDate,
            StageName: this.qtOppData.oppStageName,
            Core_Opportunity_Type__c: this.qtOppData.oppType,
            Core_Product_Segment__c: this.qtOppData.oppProductSegment,
            Core_Military_Aerospace_Govmt_End_Use__c: this.qtOppData.oppMilitaryAerospaceGovmtEndUse,
            Pricing_Quote_Id__c: this.recordId,
        });

        let oppRecordPage = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            },
            state: {
                recordTypeId: this.selectedOppRecordType,
                defaultFieldValues: defaultValues,
                //navigationLocation: 'RELATED_LIST', // to make it stay on the original record page where the component is placed
            }
        };
        this[NavigationMixin.Navigate](oppRecordPage);
        this.disableNext = true;
    }

    showToastMsgError(error) {
        if (Array.isArray(error.body)) {
            this.error += error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error += error.body.message;
        }
        this.noAccess = true;
        this.openModal = false;
    }

    disconnectedCallback() {
        this.openModal = false;
        this.noAccess = false;
        this.errorMsg = '';
        this.selectedOppRecordType = '';
        this.disableNext = true;
        this.endCustOppId;
    }

}