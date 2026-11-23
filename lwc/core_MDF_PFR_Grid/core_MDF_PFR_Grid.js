import { LightningElement, track, api, wire } from 'lwc';
import getExistingActivityDetails from '@salesforce/apex/Core_MDF_PFR_Grid.getExistingActivityDetails';
import getCampaignDetails from '@salesforce/apex/Core_MDF_PFR_Grid.getCampaignDetails';
import getBudgetDetails from '@salesforce/apex/Core_MDF_PFR_Grid.getBudgetDetails';
import insertRecords from '@salesforce/apex/Core_MDF_PFR_Grid.insertRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import PARTNER_FUND_REQUEST_OBJECT from '@salesforce/schema/PartnerFundRequest';
import PFR_CUSTOMPICKLIST_OBJECT from '@salesforce/schema/Core_MDF_PFRCustomPicklist__c';
import ACTIVITY_ENGINEERING from '@salesforce/schema/PartnerFundRequest.Core_MDF_Activity_Engineering_Nm__c';
import POP_REQUIRMENTS from '@salesforce/schema/PartnerFundRequest.Core_MDF_POP_Requirement_nm__c';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import AVAILABLE_BUDGET_LABEL from '@salesforce/label/c.Core_MDF_Available_Budget_Label';
import AMOUNT_LABEL from '@salesforce/label/c.Core_MDF_Amount';
import ACTIVITY_NUMBER_LABEL from '@salesforce/label/c.Core_MDF_ActivityNumber';
import ENGINEERING_ACTIVITY_LABEL from '@salesforce/label/c.Core_MDF_Engineering_Activity';
import Core_MDF_Other_Engineering_Activity from '@salesforce/label/c.Core_MDF_Other_Engineering_Activity';
import TARGET_END_DATE_LABEL from '@salesforce/label/c.Core_MDF_Target_End_Date';
import POP_REQUIRMENT_LABEL from '@salesforce/label/c.Core_MDF_POP_Requirement';
import NRE_GRID_HEADER from '@salesforce/label/c.Core_MDF_NRE_Grid_Header';
import coGtmProgramName from '@salesforce/label/c.Core_MDF_Co_GTM_program_name';
//Akash- Cogtm custom Labels 
import Core_MDF_Available_Budget_Label from '@salesforce/label/c.Core_MDF_Available_Budget_Label';
import Core_MDF_Budget_StartEnd_Date_Error from '@salesforce/label/c.Core_MDF_Budget_StartEnd_Date_Error';
import Core_MDF_requiredLabel from '@salesforce/label/c.Core_MDF_requiredLabel';
import Core_MDF_mustbebeforeLabel from '@salesforce/label/c.Core_MDF_mustbebeforeLabel';
import Core_MDF_mustbeafterLabel from '@salesforce/label/c.Core_MDF_mustbeafterLabel';
import Core_MDF_Budget_Amount_Error from '@salesforce/label/c.Core_MDF_Budget_Amount_Error';
import Core_MDF_cannotbeNegativeLabel from '@salesforce/label/c.Core_MDF_cannotbeNegativeLabel';
import Core_MDF_cannotbezeroLabel from '@salesforce/label/c.Core_MDF_cannotbezeroLabel';
import Core_MDF_cannotexceed16digitLabel from '@salesforce/label/c.Core_MDF_cannotexceed16digitLabel';
import Core_MDF_CharactersLabel from '@salesforce/label/c.Core_MDF_CharactersLabel';
import Core_MDF_cannotexceedLabel from '@salesforce/label/c.Core_MDF_cannotexceedLabel';
import Core_MDF_insertedsuccessfullyLabel from '@salesforce/label/c.Core_MDF_insertedsuccessfullyLabel';
import Core_MDF_fixerrorLabel from '@salesforce/label/c.Core_MDF_fixerrorLabel';
import Core_MDF_Success from '@salesforce/label/c.Core_MDF_Success';
import Core_MDF_Error from '@salesforce/label/c.Core_MDF_Error';
import Core_MDF_NewPartnerFundRequest from '@salesforce/label/c.Core_MDF_NewPartnerFundRequest';
import Core_MDF_ViewPartnerFundRequest from '@salesforce/label/c.Core_MDF_ViewPartnerFundRequest';//made changes-Alekhya
import Core_MDF_newActivityLabel from '@salesforce/label/c.Core_MDF_newActivityLabel';
import Core_MDF_limit10ActvitiesLabel from '@salesforce/label/c.Core_MDF_limit10ActvitiesLabel';
import Core_MDF_validationErrorLabel from '@salesforce/label/c.Core_MDF_validationErrorLabel';
import Core_MDF_Help_Engineering_Activity_Text from '@salesforce/label/c.Core_MDF_Help_Engineering_Activity_Text';
import Core_MDF_Help_Engineering_Activity_Link from '@salesforce/label/c.Core_MDF_Help_Engineering_Activity_Link';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';//made changes-Alekhya
import OTHER_ENGINEERING_VALUES from '@salesforce/label/c.Core_MDF_Other_Engineering_Activity_Values';//made changes-ALekhya



export default class Core_MDF_PFR_Grid extends NavigationMixin(LightningElement) {
@api recordId;
@track recordTypeId;
@track pfrPicklistRecordTypeId;
@track activityEngineeringValues;
@track popReqValues;
@track draftValues = [];
dataErrors = {};
rowId = 0;
@track disableViewActivity = true;//made changes-Alekhya
disableCreateActivity = true;
@track isLoading = true;
@track campaignStartDate;
@track campaignEndDate;
@track campaignAccountId;
hasCreateAccess = false;
@api showCreateActivity = false;
@api showNewActivity = false;
applicationError = APPLICATION_ERROR;
availableBudgetLabel = AVAILABLE_BUDGET_LABEL;
activityAmountLabel = AMOUNT_LABEL;
activityNumberLabel = ACTIVITY_NUMBER_LABEL;
engineeringActivityLabel = ENGINEERING_ACTIVITY_LABEL;
otherEngineeringActivityLabel = Core_MDF_Other_Engineering_Activity;//made changes-Alekhya
targetEndDateLabel = TARGET_END_DATE_LABEL;
popRequirmentLabel = POP_REQUIRMENT_LABEL;
//Ramapriya - help link in Activity grid
helpEngineeringActivityText = Core_MDF_Help_Engineering_Activity_Text;
helpEngineeringActivityLink = Core_MDF_Help_Engineering_Activity_Link;
//Akash
availableBudgetLabel = Core_MDF_Available_Budget_Label;
selectedbudgeterrorLabel = Core_MDF_Budget_StartEnd_Date_Error;
isrequiredLabel = Core_MDF_requiredLabel;
recordssuccessMessageLabel = Core_MDF_insertedsuccessfullyLabel;
errormessageLabel = Core_MDF_fixerrorLabel;
successLabel = Core_MDF_Success;
errorLabel = Core_MDF_Error;
createActivityLabel = Core_MDF_NewPartnerFundRequest;
createViewLabel = Core_MDF_ViewPartnerFundRequest;//made changes-Alekhya
newActitvityLabel = Core_MDF_newActivityLabel;
limittenActvitiesLabel = Core_MDF_limit10ActvitiesLabel;
validationErrorLabel = Core_MDF_validationErrorLabel;
nreGridHeader = NRE_GRID_HEADER;
coGtmProgramName = coGtmProgramName;
@track showOtherActivityColumn = false;
@track newRowCount = 0;
showGrid = true;
@track viewDetailsVisible = true;//made changes Alekhya
hideViewButton = false;//made changes-Alekhya
@api isCommunity = false;//made changes-Alekhya

fieldLabels = {
    //Akash
    Core_MDF_Activity_Engineering_Nm__c: this.engineeringActivityLabel,
    Core_MDF_Other_Engineering_Activity_txt__c : this.otherEngineeringActivityLabel,
    Core_MDF_End_Date__c: this.targetEndDateLabel,
    BudgetId: this.availableBudgetLabel,
    Core_MDF_Budget_Amount_Local_amt__c: this.activityAmountLabel,
    Core_MDF_POP_Requirement_nm__c: this.popRequirmentLabel
};

@track data = [];
@track existingRecords = [];
@track newRecords = [];
@track budgetOptions = [];
budgetIdMap = new Map();
budgetIdToNameMap = new Map();
budgetKeyToRecordMap = new Map();

get disableNewActivityButton(){
    return !(this.showNewActivity && this.newRowCount < 10);
}
@track columnsMod = [];
get columns(){
    let cols = [
        {
            label: this.activityNumberLabel, 
            fieldName: 'recordUrl', 
            type: 'urlColumn',
            typeAttributes: { 
                label: { fieldName: 'Core_MDF_Activity_Number__c'}, 
                target: '_blank',
                value: { fieldName: 'recordUrl' },
                title: { fieldName: 'Core_MDF_Activity_Number__c'}
            },
            initialWidth: 110
            
        },{ 
            label: this.engineeringActivityLabel, 
            fieldName: 'Core_MDF_Activity_Engineering_Nm__c', 
            type: 'picklistColumn',
            editable: { fieldName: 'isNew' },
            hideDefaultActions: true, //hides the dropdown-made changes-Alekhya
            typeAttributes: { 
                options: {fieldName : 'activityEngineeringValues'}, 
                value: { fieldName: 'Core_MDF_Activity_Engineering_Nm__c' },
                placeholder: 'Select an option',
                context: { fieldName: 'Id' }
                
            }
        
        },
        //made changes-Alekhya
        {
            label: this.otherEngineeringActivityLabel,
            fieldName: 'Core_MDF_Other_Engineering_Activity_txt__c',
            type: 'text',
            editable: { fieldName: 'isNew' }
        },
        
        { 
            label: this.targetEndDateLabel, 
            fieldName: 'Core_MDF_End_Date__c', 
            type: 'date-local', 
            editable: { fieldName: 'isNew' },
            initialWidth: 130
        },
        { 
            label: this.availableBudgetLabel, 
            fieldName: 'BudgetId',
            type: 'picklistColumn', 
            editable: { fieldName: 'isNew' },
            hideDefaultActions: true, //hides the dropdown-made changes-Alekhya
            typeAttributes: { 
                options: {fieldName : 'budgetOptions'},
                value: { fieldName: 'BudgetId' }, 
                placeholder: 'Select Budget'
                
            }
        },
        { 
            label: this.activityAmountLabel, 
            fieldName: 'Core_MDF_Budget_Amount_Local_amt__c', 
            type: 'currency', 
            editable: { fieldName: 'isNew' },
            initialWidth:100
        },
        { 
            label: this.popRequirmentLabel, 
            fieldName: 'Core_MDF_POP_Requirement_nm__c', 
            type: 'picklistColumn',
            editable: { fieldName: 'isNew' },
            hideDefaultActions: true, //hides the dropdown-made changes-Alekhya
            typeAttributes: { 
                options: {fieldName : 'popReqValues'}, 
                value: { fieldName: 'Core_MDF_POP_Requirement_nm__c' }, 
                placeholder: 'Select an option', 
                context: { fieldName: 'Id' } 
            }
        },
        { 
            type: 'button-icon', 
            initialWidth: 60, 
            typeAttributes: { 
                iconName: 'utility:delete', 
                title: 'Delete', 
                variant: 'border-filled', 
                alternativeText: 'Delete',
                disabled: { fieldName: 'disableDelete' }
            }
        }
    ];

    //if (this.showOtherActivityColumn) {//made changes-Alekhya
        
    //}

    return cols;
}
set columns(value){
    this.columnsMod = value;
}
  
addPicklistValues(){
    let selectedOption;
    this.data = this.data.map(row => ({
        ...row,
        budgetOptions: this.budgetOptions,
        activityEngineeringValues : this.activityEngineeringValues,
        popReqValues : this.popReqValues
    }));
}


/* @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: ACTIVITY_ENGINEERING })
    ActivityEngineeringPicklistValues({ error, data }) {
        if (data) {
            this.activityEngineeringValues = data.values;

            this.data = this.data.map(row => ({
                ...row,
                activityEngineeringValues: this.activityEngineeringValues
            }));
        }else if (error) {
            this.handleServerExceptions();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: POP_REQUIRMENTS })
    PopRequirmentsPicklistValues({ error, data }) {
        if (data) {
            this.popReqValues = data.values;

            this.data = this.data.map(row => ({
                ...row,
                popReqValues: this.popReqValues
            }));
        }else if (error) {
            this.handleServerExceptions();
        }
    }*/


@wire(getObjectInfo, { objectApiName: PFR_CUSTOMPICKLIST_OBJECT })
wiredObjectInfo({ data, error }) {
    if (data) {
        const recordTypes = data.recordTypeInfos;
        const rtId = Object.keys(recordTypes).find(
            key => recordTypes[key].name === this.coGtmProgramName
        );
        this.pfrPicklistRecordTypeId = rtId;
    }else if(error){
        this.handleServerExceptions();
    }
}

//dependentEngineeringActivityValues = [];
//dependentPopReqValues = [];
controllingFieldValue = 'CoGTM';

@wire(getPicklistValuesByRecordType, { objectApiName: PFR_CUSTOMPICKLIST_OBJECT, recordTypeId: '$pfrPicklistRecordTypeId' })
picklistHandler({data, error}) {
    //Localization
    //Give access to Internal and External Generic Access PS
    if(data) {
        //const ctrlField = data.picklistFieldValues.Core_MDF_Program__c;
        const depEngineeringActivityField = data.picklistFieldValues.Core_MDF_Activity_Engineering_Nm__c;
        const depPopReqField = data.picklistFieldValues.Core_MDF_POP_Requirement_nm__c;

        // find controlling value index
        const depEngineeringActivityIndex = depEngineeringActivityField.controllerValues[this.controllingFieldValue];
        const depPopReqIndex = depPopReqField.controllerValues[this.controllingFieldValue];

        // filter dependent values
        this.activityEngineeringValues = depEngineeringActivityField.values.filter(v => v.validFor.includes(depEngineeringActivityIndex));
        this.popReqValues = depPopReqField.values.filter(v => v.validFor.includes(depPopReqIndex));

        this.data = this.data.map(row => ({
            ...row,
            activityEngineeringValues: this.activityEngineeringValues,
            popReqValues : this.popReqValues
        }));
    }else if (error) {
        this.handleServerExceptions();
    }
}



@wire(getBudgetDetails, { campaignId: '$recordId' })
getBudgetDetails({ error, data }) {
    if (data && Array.isArray(data)) {
        if(data.length > 0){
            this.budgetOptions = data.map(record => {
                let uniqueBudgetName = `${record.Core_MDF_budget_ref_nbr__c} : ${record.Title} : ${record.StartDate} - ${record.EndDate}`;
                this.budgetIdMap.set(uniqueBudgetName, record.Id);
                this.budgetIdToNameMap.set(record.Id, uniqueBudgetName);
                this.budgetKeyToRecordMap.set(uniqueBudgetName, record);
                return {
                    label: uniqueBudgetName,
                    value: uniqueBudgetName
                };
            });

            this.fetchExistingActivityDetails();

            let selectedOption;
            this.data = this.data.map(record => ({
                ...record,
                budgetOptions: this.budgetOptions,
                BudgetId : this.budgetIdToNameMap.get(record.BudgetId)
            }));
            this.error = undefined;
        }else{
            this.showGrid = false;
        }
        
    } else if (error) {
        this.error = error;
        this.data = [];
        this.handleServerExceptions();
    }
}

fetchExistingActivityDetails() {
    getExistingActivityDetails({ campaignId: this.recordId })
        .then(data => {
            if (data && data.activityOrCampaignList != null && Array.isArray(data.activityOrCampaignList)) {
                if(data.activityOrCampaignList.length > 0){
                    const hasActivityNumber = data.activityOrCampaignList.some(record => record.Core_MDF_Activity_Number__c);
                    //this.showOtherActivityColumn = data.activityOrCampaignList.some(record => record.Core_MDF_Activity_Engineering_Nm__c ==='Other' );//made changes
                    

                    if(hasActivityNumber){
                        this.showGrid = data.activityOrCampaignList[0].Core_MDF_Program__c == this.coGtmProgramName ? true : false;
                        this.data = [...data.activityOrCampaignList.map(record => ({
                            ...record,
                            disableDelete: 'Active',
                            isNew: false,
                            enableOtherField: true,//made changes
                            budgetOptions: this.budgetOptions,
                            BudgetId : this.budgetIdToNameMap.get(record.BudgetId),
                            recordUrl: data.recordBaseUrl + `${record.Id}`
                        }))];
                        this.existingRecords = this.data;
                        this.disableViewRecord();//made changes-Alekhya
                        this.error = undefined;
                        this.campaignStartDate = new Date(data.activityOrCampaignList[0].Campaign.StartDate);
                        this.campaignEndDate = new Date(data.activityOrCampaignList[0].Campaign.EndDate);
                        this.campaignAccountId = data.activityOrCampaignList[0].Campaign.Core_MDF_Account__c;
                    }else{
                        this.showGrid = data.activityOrCampaignList[0].Core_MDF_Channel_Program__r.Name == this.coGtmProgramName ? true : false;
                        var allowedStatuses = ['Draft', 'Revision Required', 'Planned', 'In Progress'];
                        if(allowedStatuses.includes(data.activityOrCampaignList[0].Status)){
                            this.data = [{ Id: String(this.rowId), isNew: true, Core_MDF_Activity_Engineering_Nm__c: '', Core_MDF_End_Date__c: '', BudgetId: '', Core_MDF_Budget_Amount_Local_amt__c: '', Core_MDF_POP_Requirement_nm__c: '', Core_MDF_Activity_Number__c: '' }];
                            this.newRowCount++;
                            this.addPicklistValues();
                        }
                        this.campaignStartDate = new Date(data.activityOrCampaignList[0].StartDate);
                        this.campaignEndDate = new Date(data.activityOrCampaignList[0].EndDate);
                        this.campaignAccountId = data.activityOrCampaignList[0].Core_MDF_Account__c;
                    }
                }
                this.isLoading = false;
                
            } else{
                this.isLoading = false;
                this.data = [{ Id: String(this.rowId), isNew: true, Core_MDF_Activity_Engineering_Nm__c: '', Core_MDF_End_Date__c: '', BudgetId: '', Core_MDF_Budget_Amount_Local_amt__c: '', Core_MDF_POP_Requirement_nm__c: '', Core_MDF_Activity_Number__c: '' }];
                this.newRowCount++;
                this.addPicklistValues();
                this.disableViewRecord();//made changes-Alekhya
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.data = [];
            this.handleServerExceptions();
            this.isLoading = false;
        });
}

getCampaignDetails(hasActiivtyCreateAccess){
    getCampaignDetails({ campaignId: this.recordId })
        .then(data => {
            if(data && hasActiivtyCreateAccess){
                this.hasCreateAccess = true;
            }
        })
        .catch(error => {
            this.error = error;
        });
}

@wire(getObjectInfo, { objectApiName: PARTNER_FUND_REQUEST_OBJECT })
objectInfo({ error, data }) {
    if (data) {
        const recordTypes = data.recordTypeInfos;
        const rtId = Object.keys(recordTypes).find(
            key => recordTypes[key].name === this.coGtmProgramName
        );
        this.recordTypeId = rtId;
        this.getCampaignDetails(data.createable);
    } else if (error) {
        this.handleServerExceptions();
    }
}

handleAddRow() {
    this.rowId++;
    this.newRowCount++;
    this.data = [...this.data, { Id: String(this.rowId), isNew: true, Core_MDF_Activity_Engineering_Nm__c: '', Core_MDF_End_Date__c: '', BudgetId: '', Core_MDF_Budget_Amount_Local_amt__c: '', Core_MDF_POP_Requirement_nm__c: '', Core_MDF_Activity_Number__c: '' }];
    this.addPicklistValues();
}

handleServerExceptions(){
    this.showToast(this.errorLabel, this.applicationError, 'error', 'dismissable');
}
//made changes-Alekhya
refreshColumns() {
this.columnsMod = [...this.columns]; // forces datatable to rebuild
}
handleCellChange(event) {

    const draftValues = event.detail.draftValues;
    let errors = { ...this.dataErrors };

    draftValues.forEach(update => {

        this.data = this.data.map(row => {
            if (row.Id === update.Id) {
                let updatedRow = { ...row, ...update };

                if(update.hasOwnProperty('Core_MDF_Activity_Engineering_Nm__c')){
                    if(update.Core_MDF_Activity_Engineering_Nm__c === 'Other'){
                        this.showOtherActivityColumn = true;
                        updatedRow.enableOtherField = true;
                        this.refreshColumns();//made changes-Alekhya
                    }else{
                        updatedRow.enableOtherField = true;//made changes-ALekhya
                        this.showOtherActivityColumn = true;  
                        this.refreshColumns();//made changes-Alekhya
                    }
                }

                if (update.BudgetId) {
                    let selectedBudget = this.budgetOptions.find(b => b.value === update.BudgetId);
                    updatedRow.BudgetName = selectedBudget ? selectedBudget.label : '';
                }

                return updatedRow;
            }
            return row;
        });

        //this.showOtherActivityColumn = this.data.some(row => row.Core_MDF_Activity_Engineering_Nm__c === 'Other');//made changes
        let existingRecord = this.newRecords.find(r => r.Id === update.Id);
        if (existingRecord) {
            Object.assign(existingRecord, update);
            if(update.hasOwnProperty('Core_MDF_Activity_Engineering_Nm__c') && update.Core_MDF_Activity_Engineering_Nm__c !== 'Other'){
                existingRecord.Core_MDF_Other_Engineering_Activity_txt__c = '';
            }
        } else {
            let newRec = { ...update };
            if(newRec.hasOwnProperty('Core_MDF_Activity_Engineering_Nm__c') && newRec.Core_MDF_Activity_Engineering_Nm__c !== 'Other'){
                newRec.Core_MDF_Other_Engineering_Activity_txt__c = '';
            }
            this.newRecords.push(newRec);
        }
    });


    const requiredFields = Object.keys(this.fieldLabels);
    let hasErrors = false;

    draftValues.forEach(update => {
        const rowId = String(update.Id);

        if (!errors.rows) {
            errors.rows = {};
        }

        if (!errors.rows[rowId]) {
            errors.rows[rowId] = { title: this.validationErrorLabel, messages: [], fieldNames: [] };
        }

        let rowErrors = errors.rows[rowId];
        const newDate = new Date(update.Core_MDF_End_Date__c);

        requiredFields.forEach(field => {
            if (update.hasOwnProperty(field) && field != 'Core_MDF_Other_Engineering_Activity_txt__c') {
                rowErrors = this.validateRequiredField(rowErrors, update[field], field, true);
            }
        });

        if (update.hasOwnProperty('Core_MDF_Other_Engineering_Activity_txt__c')) {
            rowErrors = this.validateCharacterLimit(rowErrors, update.Core_MDF_Other_Engineering_Activity_txt__c, 'Core_MDF_Other_Engineering_Activity_txt__c', 255, true);
        }/*else if(update.hasOwnProperty('Core_MDF_Activity_Engineering_Nm__c') && update.Core_MDF_Activity_Engineering_Nm__c != 'Other'){
            rowErrors = this.validateCharacterLimit(rowErrors, update.Core_MDF_Activity_Engineering_Nm__c, 'Core_MDF_Other_Engineering_Activity_txt__c', 255, true);
        }*/
        //made changes-Alekhya
            else if(update.hasOwnProperty('Core_MDF_Activity_Engineering_Nm__c')){
            // Always show the other activity column when any engineering activity is selected
            this.showOtherActivityColumn = true;
        }

        if (update.hasOwnProperty('Core_MDF_End_Date__c') && update.Core_MDF_End_Date__c) {
            rowErrors = this.validateDateField(rowErrors, update.Core_MDF_End_Date__c, 'Core_MDF_End_Date__c');

            //Validate Selected Budget
            rowErrors = this.validateBudgetRange(rowErrors, update, true);
        }

        if (update.hasOwnProperty('Core_MDF_Budget_Amount_Local_amt__c') && update.Core_MDF_Budget_Amount_Local_amt__c) {
            rowErrors = this.validateAmount(rowErrors, update.Core_MDF_Budget_Amount_Local_amt__c, 'Core_MDF_Budget_Amount_Local_amt__c', true);
        }

        if(update.hasOwnProperty('BudgetId')){
            //Validate Selected Budget
            rowErrors = this.validateBudgetRange(rowErrors, update, true);
        }



        // Check if row still has errors
        if (rowErrors.messages.length > 0) {
            errors.rows[rowId] = rowErrors;
            hasErrors = true;
        } else {
            delete errors.rows[rowId]; // Remove row from errors if valid
        }
    });

    this.dataErrors = errors;
    this.draftValues = [...draftValues];
    this.disableCreateActivity = false;

}

validateBudgetRange(rowErrors, update, clearExistingError){
    let record = this.data.find(pfr => pfr.Id === update.Id);
    if (record) {
        Object.assign(record, update);
        if(record.BudgetId && record.Core_MDF_End_Date__c){
            let budgetRecord = this.budgetKeyToRecordMap.get(record.BudgetId);
            let budgetStartDate = new Date(budgetRecord.StartDate);
            let budgetEndDate = new Date(budgetRecord.EndDate);
            let activityEndDate = new Date(record.Core_MDF_End_Date__c);

            let budgetRangeErrorStartAndEndDate = this.selectedbudgeterrorLabel;
            let budgetRangeErrorStartDate = this.selectedbudgeterrorLabel;
            let budgetRangeErrorEndDate = this.selectedbudgeterrorLabel;
            let fieldName = 'BudgetId';

            if(clearExistingError){
                // Remove existing required field errors
                rowErrors.messages = rowErrors.messages.filter(msg => !msg.includes(budgetRangeErrorStartAndEndDate));
                rowErrors.fieldNames = rowErrors.fieldNames.filter(f => f !== fieldName);
                rowErrors.messages = rowErrors.messages.filter(msg => !msg.includes(budgetRangeErrorStartDate));
                rowErrors.fieldNames = rowErrors.fieldNames.filter(f => f !== fieldName);
                rowErrors.messages = rowErrors.messages.filter(msg => !msg.includes(budgetRangeErrorEndDate));
                rowErrors.fieldNames = rowErrors.fieldNames.filter(f => f !== fieldName);
            }


            if(this.campaignStartDate < budgetStartDate && activityEndDate > budgetEndDate){
                rowErrors.messages.push(budgetRangeErrorStartAndEndDate);
                rowErrors.fieldNames.push(fieldName);
            }else if(this.campaignStartDate < budgetStartDate){
                rowErrors.messages.push(budgetRangeErrorStartDate);
                rowErrors.fieldNames.push(fieldName);
            }else if(activityEndDate > budgetEndDate){
                rowErrors.messages.push(budgetRangeErrorEndDate);
                rowErrors.fieldNames.push(fieldName);
            }
        }
    }

    return rowErrors;
}

validateRequiredField(rowErrors, value, fieldName, clearExistingError) {
    let errorMessage = this.fieldLabels[fieldName] + ' '+this.isrequiredLabel;
    if(clearExistingError){
        // Remove existing required field errors
        let hasErrorMessage = rowErrors.messages.some(msg => msg.includes(errorMessage));
        if(hasErrorMessage){
            rowErrors.messages = rowErrors.messages.filter(msg => !msg.includes(errorMessage));
            rowErrors.fieldNames = rowErrors.fieldNames.filter(f => f !== fieldName);    
        }
    }

    // Check if the field is empty or null
    if (value === null || value === undefined || value.toString().trim() === '') {
        rowErrors.messages.push(errorMessage);
        rowErrors.fieldNames.push(fieldName);
    }

    return rowErrors;
}

validateDateField(rowErrors, value, field){
    const activityEndDate = new Date(value);
    let dateErrorIndex = rowErrors.messages.findIndex(msg => msg.includes(this.fieldLabels[field]));
    //Add a comment
    if (activityEndDate < this.campaignStartDate) {
        let errorMessage = `${this.fieldLabels[field]} ${Core_MDF_mustbeafterLabel} ${this.campaignStartDate.toISOString().split('T')[0]}`;
        if (dateErrorIndex === -1) {
            rowErrors.messages.push(errorMessage);
            rowErrors.fieldNames.push(field);
        } else {
            rowErrors.messages[dateErrorIndex] = errorMessage;
        }
    } else if (activityEndDate > this.campaignEndDate) {
        let errorMessage = `${this.fieldLabels[field]} ${Core_MDF_mustbebeforeLabel} ${this.campaignEndDate.toISOString().split('T')[0]}`;
        if (dateErrorIndex === -1) {
            rowErrors.messages.push(errorMessage);
            rowErrors.fieldNames.push(field);
        } else {
            rowErrors.messages[dateErrorIndex] = errorMessage;
        }
    } else {
        if (dateErrorIndex !== -1) {
            rowErrors.messages.splice(dateErrorIndex, 1);
            rowErrors.fieldNames.splice(rowErrors.fieldNames.indexOf(field), 1);
        }
    }

    return rowErrors;
}

validateAmount(rowErrors, amount, fieldName, clearExistingError) {

    if(clearExistingError){
        // Remove existing amount errors
        rowErrors.messages = rowErrors.messages.filter(msg => !msg.includes(this.fieldLabels[fieldName]));
        rowErrors.fieldNames = rowErrors.fieldNames.filter(f => f !== fieldName);
    }

    // Validation checks
    if (parseFloat(amount) < 0) {
        rowErrors.messages.push(`${this.fieldLabels[fieldName]} ${Core_MDF_cannotbeNegativeLabel}`);
        rowErrors.fieldNames.push(fieldName);
    }

    if (parseFloat(amount) == 0) {
        rowErrors.messages.push(`${this.fieldLabels[fieldName]} ${Core_MDF_cannotbezeroLabel}`);
        rowErrors.fieldNames.push(fieldName);
    }

    if (parseFloat(amount) > 9999999999999999.00) {
        rowErrors.messages.push(`${this.fieldLabels[fieldName]} ${Core_MDF_cannotexceed16digitLabel}`);
        rowErrors.fieldNames.push(fieldName);
    }

    if ((parseFloat(amount) % 1) != 0) {
        rowErrors.messages.push(`${Core_MDF_Budget_Amount_Error}`);
        rowErrors.fieldNames.push(fieldName);
    }

    return rowErrors;
}

validateCharacterLimit(rowErrors, value, fieldName, characterLimit, clearExistingError){

    if(clearExistingError){
        // Remove existing errors
        rowErrors.messages = rowErrors.messages.filter(msg => !msg.includes(this.fieldLabels[fieldName]));
        rowErrors.fieldNames = rowErrors.fieldNames.filter(f => f !== fieldName);
    }
    
    let errorMessage = `${this.fieldLabels[fieldName]} ${Core_MDF_cannotexceedLabel} ` + characterLimit + ` ${Core_MDF_CharactersLabel}`;
    if (value.length > characterLimit) {
        if (!rowErrors.messages.includes(errorMessage)) {
            rowErrors.messages.push(errorMessage);
            rowErrors.fieldNames.push(fieldName);
        }
    }

    return rowErrors;
}


handleRowAction(event) {
    const rowId = event.detail.row.Id;
    this.data = this.data.filter(row => row.Id !== rowId);
    this.newRecords = this.newRecords.filter(row => row.Id !== rowId);
    this.newRowCount--;
    //this.showOtherActivityColumn = this.data.some(row => row.Core_MDF_Activity_Engineering_Nm__c === 'Other');//made changes
    if(this.newRecords.length == 0){
        this.disableCreateActivity = true;
    }
}
//made changes-Alekhya
disableViewRecord() {
    // If there are no existing records, disable the button
    if (!this.existingRecords || this.existingRecords.length === 0) {
        this.disableViewActivity = true;
    } else {
        this.disableViewActivity = false;
    }
}

//made changes-Alekhya
handleViewRecords() {
    console.log('this.isCommunity: ' + this.isCommunity);
    sessionStorage.setItem('hideViewButton', 'true');
    if(this.isCommunity){
        // External user  Experience Cloud
            this[NavigationMixin.GenerateUrl]({
                type: 'comm__namedPage',
                attributes: {
                pageName:'activity-expanded-view' 
            },
                state: {
                    c__recordId: this.recordId
                    //c__hideView: true
                }
                }).then(url => {
                // Open in new tab
                window.location.href = url;
            });
    
        } else {
        //Internal User 
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__navItemPage',
        attributes: { 
            apiName: 'Activity_Grid'            
        },
        state: {
            c__recordId: this.recordId
            //expanded: 'true'
            //c__hideView: true
        }
        }).then(url => {
                window.location.href = url; // new tab
    });
}
}
//made changes-Alekhya
@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference && currentPageReference.state) {
        const urlRecordId = currentPageReference.state.c__recordId;
        //const hideView = currentPageReference.state.c__hideView;
        if (urlRecordId) {
            this.recordId = urlRecordId;
            console.log('Received Record Id from URL:', this.recordId);
            var columns = JSON.parse(JSON.stringify(this.columns));
            columns.forEach(column => {              
            
            if (column.fieldName === 'Core_MDF_Activity_Engineering_Nm__c') {
                //column.initialWidth = 310;
                column.wrapText = true;
            }
            else if(column.fieldName === 'BudgetId'){
                //column.initialWidth = 500;
                column.wrapText = true;
            }
            else if(column.fieldName === 'Core_MDF_POP_Requirement_nm__c'){
                //column.initialWidth = 400;
                column.wrapText = true;
                //column.wrapTextMaxLines = 3;
            }
            else if(column.fieldName === 'Core_MDF_Other_Engineering_Activity_txt__c'){
                    column.wrapText = true;
            }
            if(column.fieldName === 'Core_MDF_Budget_Amount_Local_amt__c'){
                column.cellAttributes = { alignment: 'left' };
            }

        }); 
        this.columnsMod = columns;        
        console.log('Expanded view mode enabled');
        this.hideViewButton = true; // Hide in expanded view
        }
        else{
            this.columnsMod = this.columns;
            this.hideViewButton = false; // Show in normal view
        }
    }
        //this.hideViewButton = hideView === 'true';//make change
        /*if (hideView === 'true') {
            this.hideViewButton = true;
        } */
        else {
            this.hideViewButton = false;
            }
}


handleCreateRecords() {

    this.disableCreateActivity = true;
    let errors = { rows: {} };
    let hasErrors = false;
    let createRecords = [];

    const requiredFields = Object.keys(this.fieldLabels);

    this.newRecords.forEach(row => {
        const rowId = String(row.Id);
        let rowErrors = { title: this.validationErrorLabel, messages: [], fieldNames: [] };

        //Validate Required Fields
        requiredFields.forEach(field => {
            /*if(field == 'Core_MDF_Other_Engineering_Activity_txt__c' && row.Core_MDF_Activity_Engineering_Nm__c != 'Other'){
                return;
            }*/
            //made changes-Alekhya//make change use custom label
                if(field == 'Core_MDF_Other_Engineering_Activity_txt__c') {
                const otherValues = OTHER_ENGINEERING_VALUES.split(',');
                const hasOtherValue = otherValues.some(value => 
                row.Core_MDF_Activity_Engineering_Nm__c?.startsWith(value.trim())
            );
            if(!hasOtherValue) {
            return;
            }
}
            rowErrors = this.validateRequiredField(rowErrors, row[field], field, true);
        });

        if (row.hasOwnProperty('Core_MDF_Activity_Engineering_Nm__c') && row.Core_MDF_Activity_Engineering_Nm__c && row.hasOwnProperty('Core_MDF_Other_Engineering_Activity_txt__c')) {//made changes
            rowErrors = this.validateCharacterLimit(rowErrors, row.Core_MDF_Other_Engineering_Activity_txt__c, 'Core_MDF_Other_Engineering_Activity_txt__c', 255, false);
        }

        //Date Validation
        if (row.hasOwnProperty('Core_MDF_End_Date__c') && row.Core_MDF_End_Date__c) {
            rowErrors = this.validateDateField(rowErrors, row.Core_MDF_End_Date__c, 'Core_MDF_End_Date__c');

            //Validate Selected Budget
            //rowErrors = this.validateBudgetRange(rowErrors, row, true);
        }
        if (row.hasOwnProperty('Core_MDF_Budget_Amount_Local_amt__c')) {
            rowErrors = this.validateAmount(rowErrors,  row.Core_MDF_Budget_Amount_Local_amt__c, 'Core_MDF_Budget_Amount_Local_amt__c', false);
        }

        if(row.hasOwnProperty('BudgetId') || (row.hasOwnProperty('Core_MDF_End_Date__c') && row.Core_MDF_End_Date__c)){
            //Validate Selected Budget
            rowErrors = this.validateBudgetRange(rowErrors, row, false);
        }

        

        if (rowErrors.messages.length > 0) {
            errors.rows[rowId] = rowErrors;
            hasErrors = true;
        }else{
            let rowCopy = JSON.parse(JSON.stringify(row));

            rowCopy.SobjectType = 'PartnerFundRequest';
            rowCopy.Core_MDF_Exchange_Rate_ptc__c = 1;
            rowCopy.RecordTypeId = this.recordTypeId;
            rowCopy.CampaignId = this.recordId;
            rowCopy.Core_MDF_Budget_Type_nm__c = 'Co-Engineering';
            rowCopy.ChannelPartnerId = this.campaignAccountId;

            //To populate BudgetId in the final list
            if (rowCopy.BudgetId) {
                let budgetId = this.budgetIdMap.get(rowCopy.BudgetId);
                if (budgetId) {
                    rowCopy.BudgetId = budgetId;
                }
            }

            delete rowCopy.Id;
            createRecords.push(rowCopy);
        }
    });

    if (!hasErrors) {
        this.isLoading =true;
        insertRecords({ insertRecordList: createRecords })
        .then(result => {
            if(result){
                this.disableCreateActivity = true;
                this.isLoading = false;
                this.newRecords = [];
                this.newRowCount = 0;
                this.fetchExistingActivityDetails();
                this.showToast(this.successLabel, this.recordssuccessMessageLabel, 'success', 'dismissable');
                this.refreshPage();
            }else{
                this.disableCreateActivity = true;
                this.isLoading = false;                    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.errorLabel,
                        message: this.applicationError,
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.disableCreateActivity = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.errorLabel,
                    message: this.applicationError,
                    variant: 'error'
                })
            );
        });
    }else{
        this.dataErrors = { ...errors };
        this.disableCreateActivity = true;
        this.showToast(this.errorLabel, this.errormessageLabel, 'error', 'dismissable');
        return;
    }

    this.dataErrors = {};
}

refreshPage() {
    //Akash - added settimeout for refreshing the page after 2 seconds for campaign status update.
    setTimeout(() => {
        // Navigating to the same record refreshes the page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Campaign',
                actionName: 'view'
            }
        }, true);
    }, 2000);
}

showToast(title, message, variant, mode) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    this.dispatchEvent(evt);
}
}