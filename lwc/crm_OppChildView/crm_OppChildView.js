import { LightningElement,api,track,wire } from 'lwc';
import getChildOpptys from "@salesforce/apex/Core_OppChildViewController.getChildOpptys";
import updateOpportunity from "@salesforce/apex/Core_OppChildViewController.updateOpportunity";
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import ACC_FIELD from "@salesforce/schema/Opportunity.AccountId";
import SOLGROUP_FIELD from "@salesforce/schema/Opportunity.Core_Solution_Group__c";

const fields = [ACC_FIELD,SOLGROUP_FIELD];
export default class Crm_OppChildView extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @track objectInfo;
    @track recordDetail;
    @track recordTypeIdVal;
    returnData = [];
    @track totalSum = 0;
    @track openModel = false;
    defaultvalue = 'Deal Opportunity';
    @track optionVal = 'Deal Opportunity';
    lookupOppId;

    connectedCallback() {
        console.log('AA recordId--'+this.recordId+this.objectApiName+this.optionVal);
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo;

    @wire(getRecord, {recordId :'$recordId', fields : fields})
    recordDetail;

    get recordTypeId() {
        // Returns a map of record type Ids;
        var recordtypeinfo = this.objectInfo.data.recordTypeInfos;
        var uiCombobox = [];
    
        //this is to match structure of lightning combo box
        for(var eachRecordtype in  recordtypeinfo) {
            if(recordtypeinfo.hasOwnProperty(eachRecordtype) && (recordtypeinfo[eachRecordtype].name.includes("Deal") || recordtypeinfo[eachRecordtype].name.includes("Design")))
                uiCombobox.push({ label: recordtypeinfo[eachRecordtype].name, value: recordtypeinfo[eachRecordtype].name })
        }
        console.log('AA uiCombobox'+ JSON.stringify(uiCombobox));
        return uiCombobox;
    }

    handleNewOpp(){
        this.openModel = true;
        console.log('AA Openneeed');
        this.optionVal = 'Deal Opportunity';
        console.log('AA this.optionVal'+ this.optionVal);
    }
    closeModal(){
        this.openModel = false;
    }
    nextPage() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        console.log('AA before nextPage'+this.recordTypeIdVal)
        this.recordTypeIdVal=(Object.keys(rtis).find(rti => rtis[rti].name === this.optionVal));

        const defaultValuesForOpp = encodeDefaultFieldValues({
            AccountId : getFieldValue(this.recordDetail.data, ACC_FIELD),
            Core_Solution_Group__c : this.recordId,
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            },
            state: {
                recordTypeId : this.recordTypeIdVal,
                defaultFieldValues: defaultValuesForOpp
            }
        });
        console.log('AA after nextPage'+this.recordTypeIdVal);
        this.closeModal();
    }

    optionChangeHandler(event) {
        this.optionVal = event.detail.value;
        console.log('AA optionChangeHandler'+this.optionVal);
    }
    handleLookup(event) {
        console.log('AA on before Adding Existing Opp lookupOppId--'+this.lookupOppId);
        this.lookupOppId = event.detail.recordId;
        console.log('AA on Adding Existing Opp lookupOppId--'+this.lookupOppId);
    }
    handleSave(){
        console.log('AA on Save lookupOppId--'+this.lookupOppId+'--Id--'+this.recordId);
        let oppDataList = [];
        if(this.lookupOppId !== undefined && this.lookupOppId !== '' && this.lookupOppId !== this.recordId) {
            let oppData = new Object();
            oppData.Id= this.lookupOppId;
            oppData.Core_Solution_Group__c= this.recordId;
            oppDataList.push(oppData);

            updateOpportunity({oppDataString: JSON.stringify(oppDataList)})
            .then(result => {
                if(result == true ){
                    const evnt = new ShowToastEvent({
                        message: 'updated successfully!!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evnt);
                    
                    window.clearTimeout(this.delayTimeout);
                    this.delayTimeout = setTimeout(() => {
                        window.location.reload();
                    }, 500);          
                }
            })
           .catch(error => {
                console.error('AA err  ', error);
            });
        }
    }

    @wire(getChildOpptys,{oppId : "$recordId"})
    getWrapperData({data,error}) {
        if(data){
            const parseData = data;
            let sum = 0;
            //console.log('AA data frm Apex::'+JSON.stringify(parseData));
            let records = parseData.map((item, index) => ({
                    ...item,
                    decimalQuantity: item.TotalOppQuantity.toFixed(2)
            }));
            this.returnData = records.length === 0 ? {} : records;
            this.returnData.forEach((el) => sum += el.Amount);
            this.totalSum = sum;
            //console.log('AA oppIdDecimalQtyMap::'+JSON.stringify(this.oppIdDecimalQtyMap));
            /*this.returnData = parseData.length == 0 ? {} : parseData;
            console.log('AA returnData frm Apex::'+this.returnData);
            
            this.teamData = this.returnData.length == 0 ? [] : this.returnData[0].OpportunityTeamMembers;
            this.featureData = this.returnData.length == 0 ? [] : this.returnData[0].Opportunity_Features__r;

            console.log('AA teamData frm Apex::'+JSON.stringify(this.teamData));
            console.log('AA oppData frm Apex::'+JSON.stringify(this.featureData));*/
            /*let otmrecords = parseData.OpportunityTeamMembers.map((item, index) => ({
                        ...item,
                        userName: item.Name.toUpperCase(),
                        userURL: '/lightning/r/' + item.User.Id + '/view',
            }));
            console.log('AA otmrecords transformed::'+JSON.stringify(otmrecords));
            let records = parseData.map((item, index) => ({
                    ...item,
                    serialNumber: index + 1,
                    oppName: item.Name.toUpperCase(),
                    oppURL: '/lightning/r/' + item.Id + '/view',
                    decimalQuantity: item.TotalOpportunityQuantity.toFixed(2)
            }));
            this.returnData = records.length === 0 ? {} : records;
            this.returnData.forEach((el) => sum += el.Amount);
            this.totalSum = sum;
            console.log('AA returnData frm Apex::'+JSON.stringify(this.returnData));*/
        }
        if(error){
            console.log('AA error frm Apex::'+JSON.stringify(error));
        }
    }

    displayInfo = {
        additionalFields: ['StageName']
    }
    matchingInfo = {
        additionalFields: [ { fieldPath: 'StageName' } ]
    }
}