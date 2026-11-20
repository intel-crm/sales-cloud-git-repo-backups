import { LightningElement, api, wire, track } from 'lwc';
import getAllocationDetails from '@salesforce/apex/Core_MDF_PartnerFundAllocation.getAllocationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pfaDetails from '@salesforce/label/c.Core_MDF_PFA_Details';
import accountNode from '@salesforce/label/c.Core_MDF_Account_Node';
import Program from '@salesforce/label/c.Core_MDF_Bulk_Claim_Program';
import budgetType from '@salesforce/label/c.Core_MDF_Budget_Type_PFA';
import startDate from '@salesforce/label/c.Core_MDF_Start_Date';
import endDate from '@salesforce/label/c.Core_MDF_End_Date';
import Amount from '@salesforce/label/c.Core_MDF_Amount';
import activityReservedAmount from '@salesforce/label/c.Core_MDF_ActivityReservedAmount';
import activityAvailableAmount from '@salesforce/label/c.Core_MDF_ActivityAvailableAmount';
import claimReservedAmount from '@salesforce/label/c.Core_MDF_ClaimReservedAmount';
import claimAvailableAmount from '@salesforce/label/c.Core_MDF_ClaimAvailableAmount';
import errorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import noRecords from '@salesforce/label/c.Core_MDF_NoRecordsToDisplay';
import itemsToDisplay from '@salesforce/label/c.Core_MDF_Display_Msg';
import budgetTypesSelected from '@salesforce/label/c.Core_MDF_budgetTypes_selected';
import programsSelected from '@salesforce/label/c.Core_MDF_Programs_Selected';
import export_CSV from '@salesforce/label/c.Core_MDF_Export_CsvExportButtonLabel';
import export_Excel from '@salesforce/label/c.Core_MDF_Export_ExcelExportButtonLabel';
import limitForRecToDisplay from '@salesforce/label/c.Core_MDF_ClaimSelectionForAuditBatchSize';
import programHelpText from '@salesforce/label/c.Core_MDF_Program_HelpText';
import accountNodeHelpText from '@salesforce/label/c.Core_MDF_AccountNode_HelpText';
import budgetTypeHelpText from '@salesforce/label/c.Core_MDF_BudgetType_HelpText';
import startDateHelpText from '@salesforce/label/c.Core_MDF_StartDate_HelpText';
import endDateHelpText from '@salesforce/label/c.Core_MDF_EndDate_HelpText';
import amountHelpText from '@salesforce/label/c.Core_MDF_Amount_HelpText';
import activityResAmountHelpText from '@salesforce/label/c.Core_MDF_ActivityReservedAmount_HelpText';
import activityAvailAmountHelpText from '@salesforce/label/c.Core_MDF_ActivityAvailableAmount_HelpText';
import claimResAmountHelpText from '@salesforce/label/c.Core_MDF_ClaimReservedAmount_HelpText';
import claimAvailAmountHelpText from '@salesforce/label/c.Core_MDF_ClaimAvailableAmount_HelpText';
import glossaryOfTerms from '@salesforce/label/c.Core_MDF_Glossary_Of_Terms';

export default class Core_MDF_PartnerFundAllocation extends LightningElement {
    @track sortBy;        //to specify the fieldname for sorting
    @track sortDirection; //to specify directio of sorting - asc or desc
    @track error;
    @api exportAllocList = [];
    @api allocList; //Used to store total records
    @api allocToDisplay; //To display in datatable 
    @api budgetTypeList = []; //this will hold budget type values to be displayed in filter
    @api programList = []; //this will hold program values to be displayed in filter
    @track isSpinner = true;
    @track hasdata = true; //make it false and check
    limitexceeds = limitForRecToDisplay;
    @track selectedProgramValues = []; //it will hold program values returned from child component
    @track selectedbudgetTypeValues = [];  //it will hold budget type values returned from child component
    @track countr = 0; //Counter value for incrementing
    allbudgetTypes = []; //stores all budget type values
    allprograms = []; //stores all program values
    @track isLoaded = true;
    filterFlag = '';
    @api disable=false;
    @api budgetTypeSelectedValueCount;
    @api programSelectedValueCount;
    //Expose the labels to use it in template of html file
    label = {
        pfaDetails, budgetType, noRecords, itemsToDisplay, programsSelected, budgetTypeHelpText, startDate, endDate, startDateHelpText, endDateHelpText, Amount, amountHelpText,
        budgetTypesSelected, Program, export_CSV, export_Excel, programHelpText, accountNode, accountNodeHelpText, activityReservedAmount, activityAvailableAmount,
        claimReservedAmount, claimAvailableAmount, activityResAmountHelpText, activityAvailAmountHelpText, claimResAmountHelpText, claimAvailAmountHelpText, glossaryOfTerms

    };
    @track columns = [
        { label: Program, fieldName: 'programName', type: 'text', sortable: true },
        { label: accountNode, fieldName: 'accountURL', type: 'url', typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }, sortable: true },
        { label: budgetType, fieldName: 'budgetType', type: 'text', sortable: true },
        { label: startDate, fieldName: 'startDate', type: 'Date', sortable: true },
        { label: endDate, fieldName: 'endDate', type: 'Date', sortable: true },
        { label: Amount, fieldName: 'amount', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: activityReservedAmount, fieldName: 'activityReservedAmount', type: 'currency',/*typeAttributes: { currencyCode: 'USD', currencyDisplayAs: 'symbol' },*/ sortable: true, cellAttributes: { alignment: 'left' } },
        { label: activityAvailableAmount, fieldName: 'activityAvailableAmount', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: claimReservedAmount, fieldName: 'claimReservedAmount', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: claimAvailableAmount, fieldName: 'claimAvailableAmount', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' } },
    ];
    //To get the total record count and store unique budget type values & program values 
    @wire(getAllocationDetails, { offsetCount: 0, sortField: 'accountURL', direction: 'asc', totalRecords: true })
   async wiredAllocations({ error, data }) {
        if (data) {
            this.allocList = data;
            this.allocToDisplay = this.allocList.slice(0, parseInt(this.limitexceeds)); //To display 50 records on load
            this.hasdata = true;
            if (this.allocList.length > 0) {
                this.isSpinner = false;
                let budgetTypes = [];
                let programValues = [];
                //Looping over returned total records and filtering out unique budget types and programs
                for (var index = 0; index < this.allocList.length; index++) {

                    if (this.allocList[index].budgetType != null && this.allocList[index].budgetType != '' && this.allocList[index].budgetType != 'undefined' && (!budgetTypes.includes(this.allocList[index].budgetType))) {
                        budgetTypes.push(this.allocList[index].budgetType);
                        this.budgetTypeList = [...this.budgetTypeList, { label: this.allocList[index].budgetType, value: this.allocList[index].budgetType, selected: false }];

                    }
                    if (!programValues.includes(this.allocList[index].programName)) {
                        programValues.push(this.allocList[index].programName);
                        this.programList = [...this.programList, { label: this.allocList[index].programName, value: this.allocList[index].programName, selected: false }];
                    }
                }
                //sort budgetType values
                this.budgetTypeList.sort(function (a, b) {
                    return a.label.localeCompare(b.label);
                });
                //sort program values
                this.programList.sort(function (a, b) {
                    return a.label.localeCompare(b.label);
                });
                this.allbudgetTypes = [...this.budgetTypeList]; //It contains total budget type values and used in later methods
                this.allprograms = [...this.programList]; //It contains total program values and used in later methods
                // create instance of child component for budget type picklist
                var multiSelectBudgetType = this.template.querySelector(".multiSelectBudgetType");
                // if no values are present in budget type list, disable the picklist
                if(multiSelectBudgetType!==null && multiSelectBudgetType!== '' && multiSelectBudgetType !=='undefined' )
                {
                if(this.budgetTypeList.length === 0){
                    multiSelectBudgetType.disablePickilstMethod();
                }
                //enable the picklist when there are values in budget type list
                else{
                    multiSelectBudgetType.enablePickilstMethod();
                }
            }
        }
            else if (this.allocList.length === 0) {
                this.hasdata = false;
                this.isSpinner = false;

            }
            this.sortBy = 'accountURL';
            this.sortDirection = 'asc';
        } else if (error) {
            this.isSpinner = false;
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: errorMsg,
                    message: data,
                    variant: 'error'
                }),
            );
        }
        
    }

    helpTextClass = "slds-popover slds-nubbin_left-top-corner slds-popover_large slds-fall-into-ground slds-hide helpTextStyle"
    toggleHelpText() {
        this.helpTextClass = this.helpTextClass == 'slds-popover slds-nubbin_left-top-corner slds-popover_large slds-fall-into-ground slds-hide helpTextStyle' ? "slds-popover slds-nubbin_left-top-corner slds-popover_large slds-rise-from-ground helpTextStyle" : "slds-popover slds-nubbin_left-top-corner slds-popover_large slds-fall-into-ground slds-hide helpTextStyle"
    }
    //sorting logic
    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;
        console.log('event.detail.fieldName'+event.detail.fieldName);
        // sort direction
        this.sortDirection = event.detail.sortDirection;
        this.countr = 0;
        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(JSON.stringify(event.detail.fieldName), JSON.stringify(event.detail.sortDirection));
        this.isLoaded = true;
    }
    //Calling server side method to sort data as per sort field and direction
    sortData(fieldname, direction) {
        getAllocationDetails({ offsetCount: 0, sortField: fieldname, direction: direction, totalRecords: false, budgetTypeList: JSON.stringify(this.selectedbudgetTypeValues.value), programList: JSON.stringify(this.selectedProgramValues.value) })
            .then(result => {
                this.allocToDisplay = result;
            })
            .catch(error => {
                this.error = error;
            })
    }
    //For infinite scrolling   
    loadMoreData(event) {
        event.preventDefault();
        if (this.allocToDisplay != null && this.allocToDisplay.length >= parseInt(this.limitexceeds)) {
            this.isLoaded = true;
        }
        // increase the offset count by 50 on every loadmore event
        this.countr = this.countr + parseInt(this.limitexceeds);
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Set the onloadmore event taraget to make it visible to imperative call response to apex.
        this.targetDatatable = event.target;
        // Get new set of records and append to this.data
        this.getRecords();
    }
    //on budget type value selection
    async onBudgetTypeValueSelect(event) {
        this.selectedbudgetTypeValues = event.detail;
        this.allocToDisplay = [];
        this.isLoaded = true;
        this.countr = 0;
        let programs = [];

        if (this.selectedbudgetTypeValues.value.length >= 1 && !(this.selectedProgramValues.value != null && this.selectedProgramValues.value != '' && this.selectedProgramValues.value != 'undefined')) {
            this.filterFlag = 'budget';
        }
        //If user deselects previously selected budget type values, then displaying all budget types in filter
        if (this.selectedbudgetTypeValues.value.length === 0 && !this.selectedbudgetTypeValues.selected) {
            //this.programList = this.allprograms;
            for (var index = 0; index < this.allprograms.length; index++) {
                if (!programs.includes(this.allprograms[index].value)) {
                    if (this.selectedProgramValues.value != null && this.selectedProgramValues.value != '' && this.selectedProgramValues.value != 'undefined' && this.selectedProgramValues.value.includes(this.allprograms[index].value)) {
                        programs = [...programs, { label: this.allprograms[index].label, value: this.allprograms[index].value, selected: true }];
                    }
                    else {
                        programs = [...programs, { label: this.allprograms[index].label, value: this.allprograms[index].value, selected: false }];
                    }
                }
            }
            this.programList = [...programs];
        }
        //If budget value is selected, its related programs to be displayed in program filter
        if (this.selectedbudgetTypeValues.value.length > 0) {
            this.filterProgramByBudgetTypes();
        }
        getAllocationDetails({ offsetCount: 0, sortField: this.sortBy, direction: this.sortDirection, totalRecords: false, budgetTypeList: JSON.stringify(this.selectedbudgetTypeValues.value), programList: JSON.stringify(this.selectedProgramValues.value) })
            .then(result => {
                this.allocToDisplay = result;
            })

    }
    //on value selection
    async onProgramValueSelect(event) {
        this.selectedProgramValues = event.detail;
        this.allocToDisplay = [];
        this.isLoaded = true;
        this.countr = 0;
        let budgetTypes = [];
        if (this.selectedProgramValues.value.length >= 1 && !(this.selectedbudgetTypeValues.value != null && this.selectedbudgetTypeValues.value != '' && this.selectedbudgetTypeValues.value != 'undefined')) {
            this.filterFlag = 'program';
        }
        //If user deselects previously selected program values, resetting budget types values 
        if (this.selectedProgramValues.value.length === 0 && !this.selectedProgramValues.selected) {
            //this.budgetTypeList = this.allbudgetTypes;
            for (var index = 0; index < this.allbudgetTypes.length; index++) {
                if (!budgetTypes.includes(this.allbudgetTypes[index].value)) {
                    if (this.selectedbudgetTypeValues.value != null && this.selectedbudgetTypeValues.value != '' && this.selectedbudgetTypeValues.value != 'undefined' && this.selectedbudgetTypeValues.value.includes(this.allbudgetTypes[index].value)) {
                        budgetTypes = [...budgetTypes, { label: this.allbudgetTypes[index].label, value: this.allbudgetTypes[index].value, selected: true }];
                    }
                    else {
                        budgetTypes = [...budgetTypes, { label: this.allbudgetTypes[index].label, value: this.allbudgetTypes[index].value, selected: false }];
                    }
                }
            }
            this.budgetTypeList = [...budgetTypes];
        }
        //If program is selected, its related budget type values to be displayed in budget type filter
        if (this.selectedProgramValues.value.length > 0) {
            this.filterBudgetTypesByProgram(); //Calling filter method
        }
        var multiSelectBudgetType = this.template.querySelector(".multiSelectBudgetType");
        if(multiSelectBudgetType!==null && multiSelectBudgetType!== '' && multiSelectBudgetType !=='undefined' )
        {
        // if no values are present in budget type list, disable the picklist
            if(this.budgetTypeList.length === 0){
                multiSelectBudgetType.disablePickilstMethod();
            }
            //enable the picklist when there are values in budget type list
            else{
                multiSelectBudgetType.enablePickilstMethod();
            }
        }
                
        getAllocationDetails({ offsetCount: 0, sortField: this.sortBy, direction: this.sortDirection, totalRecords: false, budgetTypeList: JSON.stringify(this.selectedbudgetTypeValues.value), programList: JSON.stringify(this.selectedProgramValues.value) })
            .then(result => {
                this.allocToDisplay = result;
            })
    }
    //Method to filter records by selected budget type values
    filterProgramByBudgetTypes() {
        if (this.selectedbudgetTypeValues.value != null && this.selectedbudgetTypeValues.value != '' && this.selectedbudgetTypeValues.value != 'undefined') {
            let programs = [];
            let progList = [];
            if (this.filterFlag === 'program') {
                return;
            }
            //when budget type is selected first and no program is selected
            if (this.allocList != null && this.allocList != '' && this.allocList != 'undefined') {
                for (var index = 0; index < this.allocList.length; index++) {
                    if (this.selectedbudgetTypeValues.value.includes(this.allocList[index].budgetType)) {
                        //Storing the program values related to selected budget types.
                        if (!programs.includes(this.allocList[index].programName)) {
                            programs.push(this.allocList[index].programName);
                        }
                    }
                }
            }
            if (this.selectedProgramValues.value != '' && this.selectedProgramValues.value != null && this.selectedProgramValues.value != 'undefined') {
                let indexListToSplice = [];
                for (var index = 0; index < this.selectedProgramValues.value.length; index++) {
                    if (!programs.includes(this.selectedProgramValues.value[index])) {
                        indexListToSplice.push(index);
                    }
                }
                if (indexListToSplice.length > 0) {
                    for (var indexToSplice = 0; indexToSplice < indexListToSplice.length; indexToSplice++) {
                        index = indexListToSplice[indexToSplice] - indexToSplice;
                        this.selectedProgramValues.value.splice(index, 1);
                    }
                }

            }
            //Iterating over the programs and assigning it to program list for displaying in program filter
            if (programs.length > 0) {
                for (var index = 0; index < programs.length; index++) {
                    //progList = [...progList, { label: programs[index], value: programs[index], selected: false }];
                    if (this.selectedProgramValues.value != '' && this.selectedProgramValues.value != null && this.selectedProgramValues.value != 'undefined' && this.selectedProgramValues.value.includes(programs[index])) {
                        progList = [...progList, { label: programs[index], value: programs[index], selected: true }];
                    }
                    else {
                        progList = [...progList, { label: programs[index], value: programs[index], selected: false }];
                    }
                }
                //sort program values
                progList.sort(function (a, b) {
                    return a.label.localeCompare(b.label);
                });
                this.programList = [...progList];
            }
        }
        var multiSelectProgram = this.template.querySelector(".multiSelectProgram");
        if(multiSelectProgram!==null && multiSelectProgram!== '' && multiSelectProgram !=='undefined' )
        {
        //call child component method passing selected values length to populate message on picklist
        multiSelectProgram.populateSelectedMessage((this.selectedProgramValues.value != '' && this.selectedProgramValues.value != null && this.selectedProgramValues.value != 'undefined')? this.selectedProgramValues.value.length:0 ); 
        }
  
    }

    //Method to filter records by selected program values
    filterBudgetTypesByProgram() {
        if (this.selectedProgramValues.value != null && this.selectedProgramValues.value != '' && this.selectedProgramValues.value != 'undefined') {
            let budgetTypes = [];
            let budgtypeList = [];
            if (this.filterFlag === 'budget') {
                return;
            }
            if (this.allocList != null && this.allocList != '' && this.allocList != 'undefined') {
                for (var index = 0; index < this.allocList.length; index++) {
                    if (this.allocList[index].budgetType != null && this.allocList[index].budgetType != '' && this.allocList[index].budgetType != 'undefined' && this.selectedProgramValues.value.includes(this.allocList[index].programName)) {
                        //Storing the budget type values related to selected program.
                        if (!budgetTypes.includes(this.allocList[index].budgetType)) {
                            budgetTypes.push(this.allocList[index].budgetType);
                        }
                    }
                }
            }
            if (this.selectedbudgetTypeValues.value != '' && this.selectedbudgetTypeValues.value != null && this.selectedbudgetTypeValues.value != 'undefined') {
                let indexListToSplice = [];
                for (var index = 0; index < this.selectedbudgetTypeValues.value.length; index++) {
                    if (!budgetTypes.includes(this.selectedbudgetTypeValues.value[index])) {
                        indexListToSplice.push(index);
                    }

                }
                if (indexListToSplice.length > 0) {
                    for (var indexToSplice = 0; indexToSplice < indexListToSplice.length; indexToSplice++) {
                        index = indexListToSplice[indexToSplice] - indexToSplice;
                        this.selectedbudgetTypeValues.value.splice(index, 1);
                    }
                }
                
            }
            //If user selects program values first, then filter the records
            //Iterating over budget type values and assigning it to budgetType List for display in filter
            if (budgetTypes.length > 0) {
                for (var index = 0; index < budgetTypes.length; index++) {
                    if (this.selectedbudgetTypeValues.value != '' && this.selectedbudgetTypeValues.value != null && this.selectedbudgetTypeValues.value != 'undefined' && this.selectedbudgetTypeValues.value.includes(budgetTypes[index])) {
                        budgtypeList = [...budgtypeList, { label: budgetTypes[index], value: budgetTypes[index], selected: true }];
                    }
                    else {
                        budgtypeList = [...budgtypeList, { label: budgetTypes[index], value: budgetTypes[index], selected: false }];
                    }
                }
                //sort budgetType values
                budgtypeList.sort(function (a, b) {
                    return a.label.localeCompare(b.label);
                });

            }
            this.budgetTypeList = [...budgtypeList];
        }
        var multiSelectBudgetType = this.template.querySelector(".multiSelectBudgetType");
        if(multiSelectBudgetType!==null && multiSelectBudgetType!== '' && multiSelectBudgetType !=='undefined' )
        {
        //call child component method passing selected values length to populate message on picklist
        multiSelectBudgetType.populateSelectedMessage((this.selectedbudgetTypeValues.value != '' && this.selectedbudgetTypeValues.value != null && this.selectedbudgetTypeValues.value != 'undefined')? this.selectedbudgetTypeValues.value.length:0 ); 
        // if no values are present in budget type list, disable the picklist
            if(this.budgetTypeList.length === 0){
                multiSelectBudgetType.disablePickilstMethod();
            }
            //enable the picklist when there are values in budget type list
            else{
                multiSelectBudgetType.enablePickilstMethod();
            }
        }
    }
    //On scroll, method to load more data
    getRecords() {
        getAllocationDetails({ offsetCount: this.countr, sortField: this.sortBy, direction: this.sortDirection, totalRecords: false, budgetTypeList: JSON.stringify(this.selectedbudgetTypeValues.value), programList: JSON.stringify(this.selectedProgramValues.value) })
            .then(result => {
                // Returned result if from sobject and can't be extended so objectifying the result to make it extensible
                //use concate method 
                let currentData = [];
                currentData = [...this.allocToDisplay];
                this.allocToDisplay = currentData.concat(result);
                this.error = undefined;
                if (this.targetDatatable && result.length < parseInt(this.limitexceeds)) {
                    //stop Infinite Loading when threshold is reached
                    this.isLoaded = false;
                }
                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.allocToDisplay = undefined;
            });
    }
    async handleSelectedExport(event) {
        const selectedItemValue = event.detail.value;
        await this.getRecordsToExport();
        if (selectedItemValue == "ExportToExcel") {
            this.exportToExcel();
        }
        else if (selectedItemValue == "ExportToCsv") {
            this.exportToCSV();
        }
    }
    exportToCSV() {
        // populating column headers
        let columnHeader = [Program, accountNode, budgetType, startDate, endDate, Amount, activityReservedAmount, activityAvailableAmount, claimReservedAmount, claimAvailableAmount];  // This array holds the Column headers to be displayd
        // array of keys for fetching data in each column
        let jsonKeys = ["programName", "accountName", "budgetType", "startDate", "endDate", "amount", "activityReservedAmount", "activityAvailableAmount", "claimReservedAmount", "claimAvailableAmount"];// This array holds the keys in the json data  
        // data to be exported
        var jsonRecordsData = this.exportAllocList;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        //iterating over data
        for (let index = 0; index < jsonRecordsData.length; index++) {
            let counter = 0;
            // iterating over keys
            for (let iteratorObj in jsonKeys) {
                let dataKey = jsonKeys[iteratorObj];
                if (counter > 0) { csvIterativeData += csvSeperator; }
                if (jsonRecordsData[index][dataKey] !== null &&
                    jsonRecordsData[index][dataKey] !== undefined
                ) {
                    if(dataKey === "amount" ||dataKey ===  "activityReservedAmount" || dataKey === "activityAvailableAmount" ||dataKey ===  "claimReservedAmount"||dataKey ===  "claimAvailableAmount")
                    {
                        csvIterativeData += '"$' + jsonRecordsData[index][dataKey] + '"';
                    }
                    else
                    csvIterativeData += '"' + jsonRecordsData[index][dataKey] + '"';
                } else {
                    csvIterativeData += '""';
                }
                counter++;
            }
            csvIterativeData += newLineCharacter;
        }
        // creating a hidden element with href for exporting
        var hiddenElement = window.document.createElement('a');
        // using ufeff  byte order mark encoding to accomodate russian and chinese languages in csv
        var blob = new Blob(["\ufeff", csvIterativeData]);
        hiddenElement.href = window.URL.createObjectURL(blob, { type: "text/plain" });
        hiddenElement.target = '_self';
        hiddenElement.download = 'Allocations.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }
    exportToExcel() {
        // data to be exported
        var jsonRecordsData = this.exportAllocList;
        // populating a html table with data to be exported
        var finalExcelData = "<table border='1px'>";
        finalExcelData += "<tr>" + "<td>" + Program + "</td>" + "<td>" + accountNode + "</td>" + "<td>" + budgetType + "</td>" + "<td>" + startDate + "</td>" + "<td>" + endDate + "</td>" + "<td>" + Amount + "</td>" + "<td>" + activityReservedAmount + "</td>" + "<td>" + activityAvailableAmount + "</td>" + "<td>" + claimReservedAmount + "</td>" + "<td>" + claimAvailableAmount + "</td>" + "</tr>";
        for (let index = 0; index < jsonRecordsData.length; index++) {
            finalExcelData += "<tr>" + "<td>" + jsonRecordsData[index].programName + "</td>" + "<td>" + jsonRecordsData[index].accountName + "</td>" + "<td>";
            if (jsonRecordsData[index].budgetType !== null &&
                jsonRecordsData[index].budgetType !== undefined
            ) {
                finalExcelData += jsonRecordsData[index].budgetType;
            }
           
            finalExcelData += "</td>" + "<td>" + jsonRecordsData[index].startDate + "</td>" + "<td>" + jsonRecordsData[index].endDate + "</td>" + "<td>$" + jsonRecordsData[index].amount + "</td>" + "<td>$" + jsonRecordsData[index].activityReservedAmount + "</td>" + "<td>$" + jsonRecordsData[index].activityAvailableAmount + "</td>" + "<td>$" + jsonRecordsData[index].claimReservedAmount + "</td>" + "<td>$" + jsonRecordsData[index].claimAvailableAmount + "</td>" + "</tr>";
        }
        finalExcelData = finalExcelData + "</table>";
        // creating a hidden element with href for exporting
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:application/vnd.ms-excel,' + encodeURIComponent(finalExcelData);
        hiddenElement.target = '_self';
        hiddenElement.download = 'Allocations.xls';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }
    async getRecordsToExport() {
        await getAllocationDetails({ offsetCount: 0, sortField: '', direction: '', totalRecords: true, budgetTypeList: JSON.stringify([]), programList: JSON.stringify([]) })
            .then(result => {
                this.exportAllocList = result;
            })
            .catch(error => {
                this.error = error;
            });
    }
}