import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getCampaignBudgetsForCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.getCampaignBudgetsForCampaign';
import { getRecord } from 'lightning/uiRecordApi';
import IS_LEGACY from '@salesforce/schema/Campaign.Core_MDF_Supports_legacy_program__c';
import PROGRAM_NAME from '@salesforce/schema/Campaign.Core_MDF_Program__c';
import PROPBASEDINDICATOR from '@salesforce/schema/Campaign.Core_MDF_Proposal_Based_Ind__c';
//import REIMBURSEMENT_RATE from '@salesforce/schema/Core_MDF_Campaign_Budgets__c.Core_MDF_Reimbursement_Rate_Pct__c';
import Core_MDF_Campaign_Budgets_Section_Legacy from "@salesforce/label/c.Core_MDF_Campaign_Budgets_Section_Legacy";
import Core_MDF_Campaign_Budgets_Section_No_Budgets from "@salesforce/label/c.Core_MDF_Campaign_Budgets_Section_No_Budgets";
import Core_MDF_Campaign_Budgets_Label from "@salesforce/label/c.Core_MDF_Campaign_Budgets_Label";
import Core_MDF_Budget_Name_Label from "@salesforce/label/c.Core_MDF_Budget_Name_Label";
import Core_MDF_Budget_Amount_Label from "@salesforce/label/c.Core_MDF_Budget_Amount_Label";
import Core_MDF_Reimbursement_Rate_Label from "@salesforce/label/c.Core_MDF_Reimbursement_Rate_Label";
import Core_MDF_Reimbursement_Amount_Label from "@salesforce/label/c.Core_MDF_Reimbursement_Amount_Label";
import Core_MDF_budgetTypeRRValuesMap from '@salesforce/label/c.Core_MDF_budgetTypeRRValuesMap';
import Core_MDF_CampaignBudgets_ErrMsg from '@salesforce/label/c.Core_MDF_CampaignBudgets_ErrMsg';
import getBudgetsAmountOnActiveActivities from '@salesforce/apex/Core_MDF_CampaignCreatePage.getBudgetsAmountOnActiveActivities';
import Core_MDF_Camp_Budget_Msg from '@salesforce/label/c.Core_MDF_Camp_Budget_Msg';
import REIMBURSEMENT_RATE from '@salesforce/schema/Core_MDF_Custom_Picklist__c.Core_MDF_Reimbursement_Rate__c';
import CUSTOM_PICKLIST_OBJECT from '@salesforce/schema/Core_MDF_Custom_Picklist__c';
import { addExistingReimbursementRate } from 'c/core_MDF_utilityModule';
import Core_MDF_Campaign_Reimbursement_Amount from "@salesforce/label/c.Core_MDF_Campaign_Reimbursement_Amount";
//aditya
import Core_MDF_Budget_Consumption from "@salesforce/label/c.Core_MDF_Budget_Consumption";
import Core_MDF_Available_Budget_Amount from "@salesforce/label/c.Core_MDF_Available_Budget_Amount_Label";

//import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
//import CAMPAIGN_BUDGETS_OBJECT from '@salesforce/schema/Core_MDF_Campaign_Budgets__c';


export default class Core_MDF_CampaignBudgets extends LightningElement {
    @api campaignBudgets;
    @api recordId;
    @api recMode;
    @api campId;
    @api oldCampaignBudgets;
    @api activityAmtBudgets;
    @api activityBudgets;
    @api recStatus;
    @api isProposalCampaign;
    @api campaignFieldValues;
    @track displayComponent = true;
    @track displayMode = false;
    @track budgetsExist = true;
    @track legacyCampaign = false;
    @track isPropBased;
    @track requiredFields = true;
    @track negativeValueError = false;
    @track budgetAmountError = false;
    @track budgetAmountActivityError = false;
    @track enableBudgetAmountEdit = false;
    @track campaignBudgets;
    @track ActivityAmt;
    @track validAmt = true;
    @track budgetindex;
    @track activitybamt;
    @track activityAmtBudgets;
    @api programName;
    
    @track isEEFProg=false;   
    isCoGTMProg=false;
    //@track showForm = false;
    camapign;

    campaignBudgetsLegacyError = Core_MDF_Campaign_Budgets_Section_Legacy;
    campaignBudgetsNoBudgetsWarning = Core_MDF_Campaign_Budgets_Section_No_Budgets;
    campaignBudgetsLabel = Core_MDF_Campaign_Budgets_Label;
    budgetNameLabel = Core_MDF_Budget_Name_Label;
    budgetAmountLabel = Core_MDF_Budget_Amount_Label;
    reimbursementRateLabel = Core_MDF_Reimbursement_Rate_Label;
    reimbursementAmountLabel = Core_MDF_Reimbursement_Amount_Label;
    budgetTypeRrOptionsStr = Core_MDF_budgetTypeRRValuesMap;
    budgetAmountErrMsg = Core_MDF_CampaignBudgets_ErrMsg;
    budgetAmountActivityErrorMsg = Core_MDF_Camp_Budget_Msg;
    campReimbAmtLabel = Core_MDF_Campaign_Reimbursement_Amount;
    consumedBudgetAmtLabel = Core_MDF_Budget_Consumption;
    availableBudgetAmtLabel = Core_MDF_Available_Budget_Amount;

    @wire(getRecord, { recordId: '$recordId', fields: [IS_LEGACY,PROPBASEDINDICATOR, PROGRAM_NAME] })
    wiredRecord({ data }) {
        if (data) {
            this.camapign = data;
            if (this.camapign != undefined) {
                if (this.camapign.fields.Core_MDF_Supports_legacy_program__c.value == 'Yes') {
                    this.legacyCampaign = true;
                    this.budgetsExist = false;
                }
                else {
                    this.legacyCampaign = false;
                }
                if(this.camapign.fields.Core_MDF_Proposal_Based_Ind__c.value == false){
                    this.isPropBased = false;
                }
                if(this.camapign.fields.Core_MDF_Program__c.value === 'Ecosystem Extension Fund'){
                    this.isEEFProg = true;
                } else if(this.camapign.fields.Core_MDF_Program__c.value === 'CoGTM') {
                    this.isCoGTMProg = true;
                }
            }
        }
    }
   @wire(getObjectInfo, { objectApiName: CUSTOM_PICKLIST_OBJECT })
    wiredResult1({ data }) {
        if(data) {
            this.customPickListMetadata = data;
        }

    }
    
    @wire(getPicklistValues,{recordTypeId: '012000000000000AAA', fieldApiName: REIMBURSEMENT_RATE })
    reimbursementRateOptions({data}) {
        if(data){
            this.customPicRRvalues=data;
        }
    }
    /* below code is to get REIMBURSEMENT_RATE pic values from field not needed as of now
    @wire(getObjectInfo, { objectApiName: CAMPAIGN_BUDGETS_OBJECT })
    wiredResult1({ data }) {
        if(data) {
            console.log('data 58 ' + JSON.stringify(data));
            this.campaignBudgetsMetadata = data;
            console.log('data 58 ' + this.campaignBudgetsMetadata.defaultRecordTypeId);
        }
    }
    @wire(getPicklistValues,{ recordTypeId: '$campaignBudgetsMetadata.defaultRecordTypeId', fieldApiName: REIMBURSEMENT_RATE })
    wiredResult2({ data }) {
        if(data) {
            console.log('data 68 - ' + JSON.stringify(data));
            this.reimbursementRatePicklist=data.values;
            this.options = this.reimbursementRatePicklist;
            //this.showForm = true;
        }
    } */
    /*
    oemCmpRROptions =  [
        { label: '50%', value: '50%' },
        { label: '55%', value: '55%' },
        { label: '60%', value: '60%' },
        { label: '65%', value: '65%' },
        { label: '70%', value: '70%' },
        { label: '75%', value: '75%' },
    ];
    mdfRROptions = [
        { label: '50%', value: '50%' },
        { label: '55%', value: '55%' },
        { label: '60%', value: '60%' },
        { label: '65%', value: '65%' },
        { label: '70%', value: '70%' },
        { label: '75%', value: '75%' },
        { label: '80%', value: '80%' },
        { label: '85%', value: '85%' },
        { label: '90%', value: '90%' },
        { label: '95%', value: '95%' },
        { label: '100%', value: '100%' },
    ];
    mdfPlusRROptions = [
        { label: '50%', value: '50%' },
        { label: '55%', value: '55%' },
        { label: '60%', value: '60%' },
        { label: '65%', value: '65%' },
        { label: '70%', value: '70%' },
        { label: '75%', value: '75%' },
        { label: '80%', value: '80%' },
        { label: '85%', value: '85%' },
        { label: '90%', value: '90%' },
        { label: '95%', value: '95%' },
        { label: '100%', value: '100%'},
    ];*/
    budgetTypeRrOptionMap = new Map();
    @api cmpBudgetsErrorToRetainMap = new Map();
    @track actAssociatedCmpBudgetsErrorMap = new Map();
    @track isCmpBudgetValidatedOnInitOnce = false

    connectedCallback() {
        //Gets called only for Display
        if (this.displayComponent && (this.recordId != undefined && this.recordId != null && this.recordId != '')) {
            //this.budgetTypeRrOptionMap.set('OEM CMP', this.oemCmpRROptions);
            //this.budgetTypeRrOptionMap.set('MDF', this.mdfRROptions);
            //this.budgetTypeRrOptionMap.set('MDF+', this.mdfPlusRROptions);

            //TWC3117-10490 - [CCF/DCF/IPA] - Reimbursement Rate Values
            const budgetTypeRRMap = new Map(Object.entries(JSON.parse(this.budgetTypeRrOptionsStr)));
            for (const key of budgetTypeRRMap.keys()) {
                const rrOtions = [];

                const options = budgetTypeRRMap.get(key);
                options.forEach(value => {
                    rrOtions.push({ label: value, value: value });
                });
                this.budgetTypeRrOptionMap.set(key, rrOtions);
            }
            
            this.getCampaignBudgetsForCampaign(this.recordId);
            this.displayComponent = false;
            this.displayMode = true;
            this.requiredFields = false;
        }
        console.log('in campaign budgets cmp campaignBudgets ' + JSON.stringify(this.campaignBudgets));
        console.log('in campaign budgets cmp old campaignBudgets ' + JSON.stringify(this.oldCampaignBudgets));
        console.log('in campaign budgets cmp mode ' + this.recMode);
        console.log('in campaign budgets cmp status ' + this.recStatus);

        if (this.recMode === 'edit' && this.recStatus !== 'Cancelled' && this.recStatus !== 'Completed') {
            this.enableBudgetAmountEdit = true;
            this.actAssociatedCmpBudgetsErrorMap = new Map(this.cmpBudgetsErrorToRetainMap);
        } else {
            this.enableBudgetAmountEdit = false;
        }

        if(this.programName != undefined && this.programName == 'CoGTM') {
            this.isCoGTMProg = true;
        }
    }

    renderedCallback(){
        if (this.enableBudgetAmountEdit && !this.isCmpBudgetValidatedOnInitOnce) {
            this.actAssociatedCmpBudgetsErrorMap.forEach((amountErrorMsg, budgetId) => {
                const spendingTargetUIElement = this.template.querySelector(`lightning-input[data-cmp="${budgetId}"]`);
                spendingTargetUIElement.setCustomValidity(amountErrorMsg);
                spendingTargetUIElement.classList.add('addMargin');
                spendingTargetUIElement.reportValidity();
                this.validAmt = false;
            });
            this.isCmpBudgetValidatedOnInitOnce = true;
        }        
    }

    async handleChange(event) {
        let key = event.target.dataset.id;
        
        this.budgetindex = key;
        let campaignBudgetsClone = JSON.parse(JSON.stringify(this.campaignBudgets));
        var activityBudgetAmt =[];
        let budgetAmountActivityErrorMsg;
        let activityAmtBudgets = JSON.parse(JSON.stringify(this.activityAmtBudgets));
        let oldcampaignBudgets = JSON.parse(JSON.stringify(this.oldCampaignBudgets));
        let ActivityAmt = activityAmtBudgets[campaignBudgetsClone[key].budgetId];
        this.budgetAmountActivityError =false;
        
        if (event.target.name == 'Budget Amount') {
            campaignBudgetsClone[key].budgetAmount = event.target.value;
            this.negativeValueError = (event.target.value < 0 || event.target.value == 0) ? true : false;
            let enteredAmount = event.target.value;
            let rr =campaignBudgetsClone[key].budgetRR.substring(0, campaignBudgetsClone[key].budgetRR.length - 1) / 100;
            //US1017349 Changes start :: Added extra condition to dispaly error message when user decreases budget amount on Active Activities
            if (this.recMode === 'edit' && oldcampaignBudgets[key].budgetAmount > enteredAmount && this.activityBudgets.includes(oldcampaignBudgets[key].budgetId)) {
                this.budgetAmountError = false;
                const hideBudgetErrorEvent = new CustomEvent('error');
                this.dispatchEvent(hideBudgetErrorEvent);
            } else if (this.recMode === 'edit' && oldcampaignBudgets[key].budgetAmount <= enteredAmount && this.activityBudgets.includes(oldcampaignBudgets[key].budgetId)) {
                this.budgetAmountError = false;
            }
            if (this.recMode === 'edit') {
                await this.getBudgetsAmountOnActiveActivities(this.campId, campaignBudgetsClone[key].budgetId, enteredAmount, key, rr);
                // this.getBudgetsAmountOnActiveActivities(this.campId,campaignBudgetsClone[key].budgetId);
            }
        } else {
            campaignBudgetsClone[key].budgetRR = event.target.value;
        }
        //PRB10049874 fix - Appear error "Sum of all activities cannot exceed Campaign Amount"
        campaignBudgetsClone[key].budgetRAmount = (campaignBudgetsClone[key].budgetAmount * ((campaignBudgetsClone[key].budgetRR.substring(0, campaignBudgetsClone[key].budgetRR.length - 1)) / 100)).toFixed(2);
        this.campaignBudgets = campaignBudgetsClone;

        const passEvent = new CustomEvent('campaignbudgets', {
            detail: {
                budgetData: this.campaignBudgets,
                cmpBudgetsErrorToRetainMap: Array.from(this.actAssociatedCmpBudgetsErrorMap.entries())
            }
        });
        this.dispatchEvent(passEvent);
        
    }
    async getBudgetsAmountOnActiveActivities(campId,budgetId,enteredAmount,campaignBudgetsClone,rr)
    {
        var budgetamtcmp = this.template.querySelectorAll(".budgamtcmp");
        await getBudgetsAmountOnActiveActivities({campaignId:campId,budgetId:budgetId}).then((result) => {if(result){
            var activityBudgetAmt =[];
             activityBudgetAmt = result;
             this.activityAmtBudgets = activityBudgetAmt;
           
             this.activitybamt = activityBudgetAmt;
             if ((enteredAmount*rr)  < activityBudgetAmt[budgetId]){
               
                this.budgetAmountActivityErrorMsg = 'Campaign Spending Limit (USD) entered should be Greater than or equal to' +' '+'$'+(((activityBudgetAmt[budgetId]).toFixed(2))/rr).toFixed(2);
 
                budgetamtcmp[campaignBudgetsClone].setCustomValidity(this.budgetAmountActivityErrorMsg);
                budgetamtcmp[campaignBudgetsClone].reportValidity();
                this.validAmt = false;               
                 const budgetError = this.template.querySelector('[data-id="' +this.budgetindex+ '"]');
                 budgetError.classList.add('addMargin');
                 this.actAssociatedCmpBudgetsErrorMap.set(budgetId, this.budgetAmountActivityErrorMsg);
            }
            else {
                budgetamtcmp[campaignBudgetsClone].setCustomValidity('');
                budgetamtcmp[campaignBudgetsClone].reportValidity();
                this.validAmt = true;
                const budgetError = this.template.querySelector('[data-id="' + this.budgetindex + '"]');
                budgetError.classList.remove('addMargin');
                this.actAssociatedCmpBudgetsErrorMap.delete(budgetId);
            }
        }
        }
        ).catch((error) => { });
    }
    getCampaignBudgetsForCampaign(campaignRecordId) {

        getCampaignBudgetsForCampaign({ campaignId: campaignRecordId })
            .then(result => {
                console.log(' getCampaignBudgetsForCampaign 2 >>> ' + JSON.stringify(result));
                if (result) {
                    let campaignBudgetsValues = [];
                    var campaignBudgetsFromApex = result;
                    for (var key in campaignBudgetsFromApex) {
                        // US982502 - [Opal - CCF/DCF] - [Campaign] - RR% until 100% for MDF and MDF+ start
                        let rrOptions;
                        if (this.budgetTypeRrOptionMap.has(campaignBudgetsFromApex[key].Core_MDF_Budget_Type_Nm__c)) {
                            rrOptions = this.budgetTypeRrOptionMap.get(campaignBudgetsFromApex[key].Core_MDF_Budget_Type_Nm__c);
                        }

                        // New RR changes - RP
                        let finalRROptions = [];
                        finalRROptions = addExistingReimbursementRate(campaignBudgetsFromApex[key].Core_MDF_Reimbursement_Rate_Pct__c, rrOptions);

                        // US982502 - [Opal - CCF/DCF] - [Campaign] - RR% until 100% for MDF and MDF+ end
                        //aditya
                        var budgetNameString =this.getBudgetNameString(campaignBudgetsFromApex[key].Core_MDF_Budget_Name_Id__r.Title, campaignBudgetsFromApex[key].Core_MDF_Budget_Type_Nm__c,campaignBudgetsFromApex[key].Core_MDF_Start_Date_Dt__c , campaignBudgetsFromApex[key].Core_MDF_End_Date_Dt__c,campaignBudgetsFromApex[key].Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c, campaignBudgetsFromApex[key].Core_MDF_Consumed_Budget_Amount__c, campaignBudgetsFromApex[key].Core_MDF_Available_Budget_Amount__c);
                        if (campaignBudgetsFromApex[key].Core_MDF_Active_ind__c) {
                            //aditya
                            let obj = { campaignId: this.recordId, budgetId: '', disable: this.displayMode, budgetName: budgetNameString, budgetAmount: campaignBudgetsFromApex[key].Core_MDF_Budget_Amt__c, budgetRR: campaignBudgetsFromApex[key].Core_MDF_Reimbursement_Rate_Pct__c, budgetRAmount: campaignBudgetsFromApex[key].Core_MDF_Reimbursement_Amt__c, options: finalRROptions, consumedBudgetAmount: campaignBudgetsFromApex[key].Core_MDF_Consumed_Budget_Amount__c, availableBudgetAmount: campaignBudgetsFromApex[key].Core_MDF_Available_Budget_Amount__c};
                            campaignBudgetsValues = [...campaignBudgetsValues, obj];
                        }
                    }
                    this.campaignBudgets = campaignBudgetsValues;

                    if (this.campaignBudgets.length == 0) {
                        this.budgetsExist = false;
                    }
                    else {
                        this.budgetsExist = true;
                    }
                }
            })
            .catch(e => {
                console.log('Error' + e);
            })
    }

    @api isValid() {
        let validity = true;
        for (var i in this.campaignBudgets) {
            if (this.campaignBudgets[i].budgetAmount == 0 || this.campaignBudgets[i].budgetAmount == '' || this.campaignBudgets[i].budgetAmount < 0) {
                validity = false;
                this.negativeValueError = false;
            }
        }
        if (validity) {
            return true;
        }
        else { return false; }
    }

    //US1017349 Changes:: Method to check whether budget amount is decreased or not
    @api isBudgetAmountDecreased() {

      
        let validData = true;
        let existingCampaignBudgetsMap = new Map();
        let arr1 =[];
         if(this.oldCampaignBudgets !== undefined && this.oldCampaignBudgets !== null && this.oldCampaignBudgets.length > 0){
             console.log('Enter here at 395');
            for(let a = 0; a < this.oldCampaignBudgets.length; a++ ){
                existingCampaignBudgetsMap.set(this.oldCampaignBudgets[a].budgetId, this.oldCampaignBudgets[a]);

            }
        }
        

        
        if(existingCampaignBudgetsMap !== undefined && existingCampaignBudgetsMap !== null && this.activitybamt !== undefined && Object.entries(this.activitybamt).length > 0){
            console.log('Enter here at 403'+existingCampaignBudgetsMap.length);
            for (let i = 0; i < this.oldCampaignBudgets.length; i++){

                arr1=JSON.stringify(this.activitybamt);

                var jsonObj = JSON.parse(arr1);

             console.log('Enter here at 381'+ 'If'+((this.campaignBudgets[i].budgetAmount)*(((this.campaignBudgets[i].budgetRR).substring(0, this.campaignBudgets[i].budgetRR.length - 1)) / 100))+'is less than this'+(jsonObj[this.campaignBudgets[i].budgetId]));
                
               if((((this.campaignBudgets[i].budgetAmount)*(((this.campaignBudgets[i].budgetRR).substring(0, this.campaignBudgets[i].budgetRR.length - 1)) / 100)) < (jsonObj[this.campaignBudgets[i].budgetId]))){
                    console.log('Inside Budget Id matches map ::' + existingCampaignBudgetsMap.get(this.campaignBudgets[i].budgetId).budgetAmount);
                    validData = false;
                    this.budgetAmountError = false;
                    break;
                }
            }            
        }
    
        return validData;
    }
    setCustomRRValues(event){
        /*if(this.campaignFieldValues?.Core_MDF_Program__c == 'Channel MDF' && !this.isPropBased){
            this.accBasedRrOptions = [];
            let budgets = JSON.parse(JSON.stringify(this.campaignBudgets));
            this.controllingValue = this.customPicRRvalues?.controllerValues[this.campaignFieldValues['Core_MDF_Opal_Budget_Type_Txt__c']];
            this.customPicRRvalues?.values.forEach(item => {
                if(item?.validFor.includes(this.controllingValue)){
                    this.accBasedRrOptions.push({label:item.label, value: item.value});
                }
            })
            budgets.forEach(item =>{
                item.options = this.accBasedRrOptions; 
            })
            this.campaignBudgets = budgets;
        }*/
    }

    //US1017349 Changes end
    /*
    get options() {
        return [
            { label: '50%', value: '50%' },
            { label: '55%', value: '55%' },
            { label: '60%', value: '60%' },
            { label: '65%', value: '65%' },
            { label: '70%', value: '70%' },
            { label: '75%', value: '75%' },
            { label: '80%', value: '80%' },
            { label: '85%', value: '85%' },
            { label: '90%', value: '90%' },
            { label: '95%', value: '95%' },
            { label: '100%', value: '100%' }
        ];
    }*/
    /*
    handleRRChange(event) {
        console.log('handleRRChange called');
        this.options = [
            { label: '35%', value: '35%' },
            { label: '40%', value: '40%' }
        ];
    }*/
    //on detail page campaign budgets section
    checkForUndefinedEmptyAndNull(input) {
        if (input !== undefined && input !== null && input !== "") {
            return true;
        } else {
            return false;
        }
    }
    //aditya
    getBudgetNameString(budgetTitle, budgetType, startDate, endDate, budgetRefNumber, consumedBudgetAmount, availableBudgetAmount) {
        if(this.checkForUndefinedEmptyAndNull(startDate) && this.checkForUndefinedEmptyAndNull(endDate)){
            startDate = startDate.replaceAll('-','/');
            endDate = endDate.replaceAll('-','/');
        }
        return budgetRefNumber+': '+budgetTitle + ': ' + budgetType + ': ' + startDate + ' - ' + endDate + ' - ' + consumedBudgetAmount + ' - ' + availableBudgetAmount;
    }
}