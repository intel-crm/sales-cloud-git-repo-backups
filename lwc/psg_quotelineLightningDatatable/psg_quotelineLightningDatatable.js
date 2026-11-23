import { LightningElement, track,wire,api } from 'lwc';
//import getAllQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.fetchAllQuoteLines';
//import addNewQuoteLine from '@salesforce/apex/PSG_QuoteLineDataTableController.addNewQuoteLine';
//import deleteRecord from '@salesforce/apex/PSG_QuoteLineDataTableController.deleteRecord';
//import updateQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.updateQuoteLines';
//import cloneRecord from '@salesforce/apex/PSG_QuoteLineDataTableController.cloneRecord';
//import createDPA from '@salesforce/apex/PSG_RequestDPA.createDPA';//added for DPA
//import createALN from '@salesforce/apex/PSG_RequestDPA.createALN';//added for ALN
import ALN_OBJECT from '@salesforce/schema/core_cpq_dpa_aln__c';//added for ALN
//import validateOPN from '@salesforce/apex/PSG_QuoteLineDataTableController.validateOPN'; 
//import sendQuoteRequestUpdate from '@salesforce/apex/PSG_QuoteLineDataTableController.sendQuoteRequestUpdate';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/PSG_CustomDataTable';
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PSG_QuoteLineTablePagination from '@salesforce/label/c.PSG_QuoteLineTablePagination';
import { reduceErrors } from 'c/psg_ldsutils';
//import colors from '@salesforce/resourceUrl/PSG_DataTable';
//import MapHistoryComponent from '../mapHistoryComponent/mapHistoryComponent';

const actions = [
    { label: 'Delete', name: 'delete' },
    //{ label: 'Clone', name: 'clone' },
];
export default class CustomDatatableDemo extends  NavigationMixin( LightningElement ) {
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT }) objectInfo;
    @track data = [];
    @track draftValues = [];
    @track columns = [];
    @api recordId;
    //lastSavedData = [];
    @track quoteLineList = [];
    @track tempSearchQuoteLineList = [];
    @track quoteList = [];
    @track quoteMap = {};
    @track oldQuoteLineList = [];
    @track mandatoryColumns = [];
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @track fieldapinametemp = '';
    @track objectApiName = 'SBQQ__QuoteLine__c';
    @track quoteLineMap = {};
    @track actualQuoteLineMap = {};
    @track oldQuoteLineMap = {};
    @track dynamicColumnMap = {};
    @track filterData = [];
    @track selectedValue;
    @track dataReturn= [];
    @track isOpen = false;
    @track selectedValues = [];
    @track showSpinner = false;
    @track copyDraftValues = [];
    @api hideSearchFeatures = false;
    @api isDistiPortal = false;
    @api inProgressQuote = false;
    @api isCpQuote = false;
    @api pendingvisblity= false;
    @api requestDPAFlag =  false;//added for DPA
    @api requestALNFlag =  false;//added for ALN
    @api isDraft = false;
    @track isNewRecord = false;
    @api isNewStatus = false;
    @track status;
    @track isEditable = false;
    @track isModal2Open = false;
    @api suppressBottomBar = false;
    @track disableSearch = false;
    @track disableAddLines = false;
    @track ishideCheckbox = false;//added to hide checkBox
    @track tempRow = {Id:''};
    @track errors;
    @api  currentDistributor;
    //Pagination
    @track page = 1; 
    @track items = []; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @track count = 1;
    //Pagination
    @track distyColumns = [];
    @track distyPendingColumns = [];
    @track distyReadOnlyPendingColumns = [];
    @track distyDPAColumns = [];
    @track distyCPColumns = [];

    @track columnsToAdd = [];
    @track preSelectedRows = [];
    @track selection = [];
    //@track ismancheck=false;

    label = {
        PSG_QuoteLineTablePagination
    };
    
    //Pagination
    @api showNewSearchOptions = false;

    @track options = [
        {label: 'Type', value: 'Type'},
        {label: 'Industry', value: 'Industry'},
        {label: 'Phone', value: 'Phone'},
        {label: 'Fax', value: 'Fax'},
    ];
    @track _selected = []; // this array tracks the seleted values
    listDualPickListOptions = [
        { value: 'core_cpq_product_nm__c', label: 'Product/Part#'},
        { value: 'SBQQ__ListPrice__c', label: 'List Unit Price' },
        { value: 'core_cpq_quote_line_type_document__c', label: 'Line Type' },
        { value: 'price_suggested_resale_amt__c', label: 'Suggested Resale' },
        { value: 'core_cpq_distributor_margin_pct__c', label: 'Distributor Margin %' },
        { value: 'price_brokencost_amt__c', label: 'Broken Cost' },
        { value: 'core_cpq_requested_qty__c', label: 'Requested Quantity' },
        { value: 'price_requested_resale_amt__c', label: 'Requested Resale' },
        { value: 'core_cpq_production_dt__c', label: 'Production Start Date' },
        { value: 'core_cpq_pricing_start_date_dt__c', label: 'Pricing Start Date' },
        { value: 'core_cpq_pricing_end_date_dt__c', label: 'Pricing End Date' },
        { value: 'PSG_Reg_Number_txt__c', label: 'PSG Reg #' },
        { value: 'core_cpq_product_family_txt__c', label: 'Product Family' },
        { value: 'core_cpq_contracted_price__c', label: 'Contracted Price' },
    ];
    @track dynamicColumns;
    //multipicklist variables
    @track
    state = {
        title: 'Welcome to Lightning Web Components Playground!',
    };
    @api
    sendupdaterequest(quoteMap,status){
        this.showSpinner = true;
        this.handleSave(quoteMap,status);
        this.showSpinner = true;
    }
    @api
    senddparequest(quoteMap,status,quoteType){//added for DPA
        this.showSpinner = true;
        //this.handleSave(quoteMap,status);
        this.handleDPASave(quoteMap,status,quoteType);
       // this.showSpinner = true;
    }  
    @api
    sendalnrequest(quoteMap,status,quoteType){//added for DPA
        this.showSpinner = true;
        //this.handleSave(quoteMap,status);
        this.handleALNSave(quoteMap,status,quoteType);
       // this.showSpinner = true;
    }   
    @api
    closeupdaterequest(){
        this.columns = this.distyPendingColumns;
        console.log('closeupdaterequestlogs');
    }
    @api
    closedparequest(){//added for DPA
        this.requestDPAFlag = false;
        //this.requestUpdateAction = false;
        this.inProgressQuote = true;
        console.log('closeDPAup');
        this.columns = this.distyPendingColumns;
    }
    @api
    opencolumnsupdaterequest(){
        this.showSpinner = true;
        console.log('calling:: opencolumnsupdaterequest');
        this.columns = [];
        this.columns.push({
                label: 'Revision Request', fieldName: 'core_cpq_revision_request_category_nm__c',editable: true,sortable: true,type: 'picklist', typeAttributes: {
                        placeholder: 'Choose Category', options: [
                            { label: 'Choose Category', value: 'Choose Category'},
                            { label: 'Add', value: 'Add' },
                            { label: 'Change', value: 'Change'},
                            { label: 'Loss', value: 'Loss'},
                            { label: 'Other PSG OPN', value: 'Other Altera Part'},
                            { label: 'Win', value: 'Win'},
                             
                            
                        ] 
                        , value: { fieldName: 'core_cpq_revision_request_category_nm__c'}
                        , context: { fieldName: 'Id' }
                        , fieldapiname: 'core_cpq_revision_request_category_nm__c'
                }
        });
        this.columns.push({label:'* Justification',fieldName:'core_cpq_justification_txt__c',editable: true,sortable: true,required:true,cellAttributes: {
            class: {
                fieldName: 'applyJustificationColor'
            },
            alignment: 'left'
        },initialWidth: 150});
        this.columns = this.distyReadOnlyPendingColumns;
        this.columns =  [...this.columns,this.distyReadOnlyPendingColumns];
        console.log('opencolumnsupdaterequestcols'+JSON.stringify(this.columns));
        console.log('this.distyReadOnlyPendingColumns'+JSON.stringify(this.distyReadOnlyPendingColumns));
        console.log('exiting:: opencolumnsupdaterequest');
        this.showSpinner = false;
    }
    //added for DPA
    @api opencolumnsDPArequest()
        
    {
         this.showSpinner = true;
         this.columns = [];

        console.log('calling:: opencolumnsDPArequest');
        this.columns = [
        
        {label:'Line #',fieldName:'Name',editable: false,sortable: true}, 
        {label:'* Part Number',fieldName:'core_cpq_opn__c',editable: false,sortable: true},
        {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: false,sortable: true},
        {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: false,sortable: true},
        {label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:true},   
        {label:'Broken Cost',fieldName:'price_brokencost_amt__c',editable: true,sortable: true,required:false},
		
		
     
        {label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,type: 'boolean',
            cellAttributes: {
                alignment: 'center'
            }
        },  
		
		{label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,type: 'boolean',
            cellAttributes: {
                alignment: 'center'
            }
        },
        
        {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true}]
        console.log('Exiting:: opencolumnsDPArequest');
        this.showSpinner = false;
    }
        //-------
    @api
    sendValidationResult(data){
        console.log('calling:: sendValidationResult');
        if(data != null && data != undefined){
            let map1 = new Map();
            map1 = data;
            let quoteLineListToUpdate = [];
            this.quoteLineList.forEach(function(element){
                console.log('map2 '+JSON.stringify(element));
                if(data[element.Id] != null && data[element.Id] != undefined){
                    data[element.Id].forEach(function(fieldName){
                        element['applycolor'] = "slds-theme_error";
                        quoteLineListToUpdate.push(element);
                    });

                }
            });
        }
        console.log('Exiting:: sendValidationResult');
    }
    @track yourSelectedValues;
    get options() {
        return [
            {
                label: 'supports',
                value: 'supports',
            },
            {
                label: 'has ability to show',
                value: 'shows',
            },
        ];
    }

    get msOptions () {
        return [{'key':1,'value':'Jaipur'},
                       {'key':2,'value':'Pune', 'selected' : true},
                       {'key':3,'value':'Hyderabad'},
                       {'key':4,'value':'Banglore'},
                       {'key':5,'value':'Gurgaon'},
                       {'key':6,'value':'Mumbai'},
                       {'key':7,'value':'Chennai'},
                       {'key':8,'value':'Noida'},
                       {'key':9,'value':'Delhi'},];
    }
    //multipicklist variables\

    //@wire(getAllQuoteLines,{ quoteId: '$recordId'}) quoteLineList; 
    renderedCallback() {
       Promise.all([
            loadStyle(this, CustomDataTableResource)
        ]).then(() => { })
    }
    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'PSG Quote Line - Create');
    } 
    connectedCallback() {
        console.log('calling:: connectedCallback');
        this.disableAddLines = false;
        this.disableSearch = false;
        this.pageSize = PSG_QuoteLineTablePagination;
        if( this.requestDPAFlag == false && this.requestALNFlag == false){//added to hidecheckbox 
            this.ishideCheckbox = true;
        }
        //this.triggerError();
        this.showSpinner = false;
        var localActions;
        /*if(this.recordId == null || this.isDraft == true){
            this.isEditable = true;
        }*/
        //this.isEditable = true;
        //added for DPA
        /*if(this.requestDPAFlag == true){
            this.inProgressQuote =false;
        }*/
        if(this.recordId == null){
            this.isNewRecord = true;
            this.disableSearch = true;
        }
        if(this.isEditable == true){
            localActions = actions;
            console.log('isEditable:: true');
        }else{
            console.log('isEditable:: false');
        }
        this.mandatoryColumns = ["core_cpq_opn__c","SBQQ__Quantity__c","core_cpq_years_nbr__c","core_cpq_production_dt__c","price_requested_resale_amt__c","core_cpq_justification_txt__c"];
        //this.setDataTableColumns();
        //Setting columns for non-disti portal
        if(this.isDistiPortal == false){
            this.columns =
            [   
                {
                    label: 'Product/Part#', fieldName: 'core_cpq_product_nm__c',type: 'lookup',editable: true,sortable: true,typeAttributes: {
                        placeholder: 'Select Product',
                        uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                        object: "Product2",
                        icon: "standard:product",
                        label: "Product/Part#",
                        displayFields: "Name",
                        displayFormat: "Name",
                        filters: "",
                        valueId: {fieldName: 'ParentId'},
                        defaultRecord: {fieldName: 'SBQQ__ProductName__c'},
                    }
                }, 
                {label:'List Unit Price',fieldName:'SBQQ__ListPrice__c',editable: true,sortable: true,required:true},
                /*{
                    label: 'Line Type', fieldName: 'core_cpq_quote_line_type_document__c',editable: false,sortable: true,type: 'picklist', typeAttributes: {
                        placeholder: 'Choose line type', options: [
                            { label: 'Flat', value: 'Flat'},
                            { label: 'Prototype', value: 'Prototype'},
                            { label: 'Qty Limited', value: 'Qty Limited'},
                            { label: 'Time Limited', value: 'Time Limited'},
                            { label: 'AVP', value: 'AVP' },
                            { label: 'VTP', value: 'VTP' },
                        ] 
                        , value: { fieldName: 'core_cpq_quote_line_type_document__c'}
                        , context: { fieldName: 'Id' }
                        ,fieldapiname: 'core_cpq_quote_line_type_document__c'
                    }
                },*/
                {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true,required:true},
                {label:'Suggested Resale',fieldName:'price_suggested_resale_amt__c',editable: true,sortable: true,required:true},
                {label:'Distributor Margin %',fieldName:'core_cpq_distributor_margin_pct__c',editable: true,sortable: true,required:true},
                {label:'Broken Cost',fieldName:'price_brokencost_amt__c',editable: true,sortable: true,required:false},
                {label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:false},
                {label:'Requested Resale',fieldName:'price_requested_resale_amt__c',editable: true,sortable: true,required:false},
                {label:'Std/Fwd Cost',fieldName:'price_std_fwd_cost_amt__c',editable: true,sortable: true,required:false},
                {label:'Production Start Date',fieldName:'core_cpq_production_dt__c',editable: true,sortable: true,required:true},
                {label:'Pricing Start Date',fieldName:'core_cpq_pricing_start_date_dt__c',editable: false,sortable: true,required:false},
                {label:'Pricing End Date',fieldName:'core_cpq_pricing_end_date_dt__c',editable: false,sortable: true,required:false},
                {label:'PSG Reg #',fieldName:'core_cpq_reg_number_txt__c',editable: true,sortable: true,required:false},
                {label:'Product Family',fieldName:'core_cpq_product_family_txt__c',editable: true,sortable: true,required:false},
                {label:'Contracted Price',fieldName:'core_cpq_contracted_price__c',editable: true,sortable: true,required:false},

                {label:'Line #',fieldName:'Name',editable: false,sortable: true,required:false},
                {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: true,sortable: true,required:false},
                {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: true,sortable: true,required:false},
                {label:'Altera Reg Number',fieldName:'core_cpq_altera_reg_txt__c',editable: this.isEditable,sortable: true,required:false},
                {
                    label: 'Revision Request Category', fieldName: 'core_cpq_revision_request_category_nm__c',editable: this.isEditable,sortable: true,type: 'picklist', typeAttributes: {
                        placeholder: 'Choose Category', options: [
                            { label: 'W', value: 'W'},
                            { label: 'L', value: 'L'},
                            { label: 'O', value: 'O'},
                            { label: 'C', value: 'C'},
                            { label: 'A', value: 'A' }
                        ] 
                        , value: { fieldName: 'core_cpq_revision_request_category_nm__c'}
                        , context: { fieldName: 'Id' }
                    }
                },
                {label:'Revision reason',fieldName:'core_cpq_revision_reason_txt__c',editable: this.isEditable,sortable: true,required:true},
                {label:'Disty Cost',fieldName:'price_disty_cost_nbr__c',editable: false,sortable: true,required:false},
                {label:'MSVP L1',fieldName:'price_msvp_l1_amt__c',editable: true,sortable: true,required:false},
                {label:'MSVP L2',fieldName:'price_msvp_l2_amt__c',editable: true,sortable: true,required:false},
                {label:'Intel Margin %',fieldName:'core_cpq_intel_margin_pct__c',editable: true,sortable: true,required:false},
                {label:'# of Years',fieldName:'core_cpq_contracted_price__c',editable: true,sortable: true,required:false},
                {
                    label: 'Margin Exception', fieldName: 'core_cpq_margin_exception_txt__c',editable: true,sortable: true,type: 'picklist', typeAttributes: {
                        placeholder: 'Choose Margin Exception', options: [
                            { label: 'Approved DDR', value: 'Approved DDR'},
                            { label: 'Budgetary', value: 'Budgetary'},
                            { label: 'Non-component', value: 'Non-component'},
                            { label: 'PDP/AD', value: 'PDP/AD'},
                            { label: 'eASIC', value: 'eASIC' },
                            { label: 'Enpirion', value: 'Enpirion' },
                        ] 
                        , value: { fieldName: 'core_cpq_margin_exception_txt__c'}
                        , context: { fieldName: 'Id' }
                    }
                },
				{label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,required:false},
				{label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,required:false},
                
                {
                    type: 'action',
                    typeAttributes: { rowActions: actions },
                }
            ];
        }else{
            //this.columns = this.distyColumns;
        }
        
        console.log('calling from connectedCallback:: fetchQuoteLineDetails');
        this.fetchQuoteLineDetails();
        console.log('exiting from connectedCallback:: fetchQuoteLineDetails');
        //this.data = [{ 'Id': '12345', 'Name': 'Acme', 'AccountNumber': 'CD355119-A', 'Rating': 'Hot','phone': 12537 }, { 'Id': '34567', 'Name': 'Mace', 'AccountNumber': 'CD355120-A', 'Rating': 'Cold', 'phone': 1978234 }];
        
        //this.data = JSON.stringify(this.quoteLineList);
        //save last saved copy
        //console.log('this.data '+JSON.stringify(this.data));
        //this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        //var dynamicColumnMap = {};
        this.dynamicColumnMap['core_cpq_product_nm__c'] = {
            label: 'Product/Part#', fieldName: 'core_cpq_product_nm__c',type: 'lookup',editable: true,sortable: true,typeAttributes: {
                placeholder: 'Select Product',
                uniqueId: { fieldName: 'Id' }, //pass Id of current record to lookup for context
                object: "Product2",
                icon: "standard:product",
                label: "Product/Part#",
                displayFields: "Name",
                displayFormat: "Name",
                filters: "",
                valueId: {fieldName: 'ParentId'},
                defaultRecord: {fieldName: 'SBQQ__ProductName__c'}
            }
        };

        this.dynamicColumnMap['SBQQ__ListPrice__c'] = {label:'List Unit Price',fieldName:'SBQQ__ListPrice__c',editable: true,sortable: true,required:true};
        this.dynamicColumnMap['core_cpq_quote_line_type_document__c'] = {
            label: 'Quote Line Type', fieldName: 'core_cpq_quote_line_type_document__c',editable: true,sortable: true,type: 'picklist', typeAttributes: {
                placeholder: 'Choose Line Type', options: [
                    { label: 'Flat', value: 'Flat'},
                    { label: 'Prototype', value: 'Prototype'},
                    { label: 'Qty Limited', value: 'Qty Limited'},
                    { label: 'Time Limited', value: 'Time Limited'},
                    { label: 'AVP', value: 'AVP' },
                    { label: 'VTP', value: 'VTP' },
                ] 
                , value: { fieldName: 'core_cpq_quote_line_type_document__c'}
                , context: { fieldName: 'Id' }
            }
        };
        this.dynamicColumnMap['price_suggested_resale_amt__c'] = {label:'Suggested Resale',fieldName:'price_suggested_resale_amt__c',editable: true,sortable: true,required:true};
        this.dynamicColumnMap['core_cpq_distributor_margin_pct__c'] = {label:'Distributor Margin %',fieldName:'core_cpq_distributor_margin_pct__c',editable: true,sortable: true,required:true};
        this.dynamicColumnMap['price_brokencost_amt__c'] = {label:'Broken Cost',fieldName:'price_brokencost_amt__c',editable: true,sortable: true,required:false};
        this.dynamicColumnMap['core_cpq_requested_qty__c'] = {label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:false};
        this.dynamicColumnMap['price_requested_resale_amt__c'] = {label:'Requested Resale',fieldName:'price_requested_resale_amt__c',editable: true,sortable: true,required:false};
        this.dynamicColumnMap['price_std_fwd_cost_amt__c'] = {label:'Std/Fwd Cost',fieldName:'price_std_fwd_cost_amt__c',editable: true,sortable: true,required:false}
        this.dynamicColumnMap['core_cpq_production_dt__c'] = {label:'Production Start Date',fieldName:'core_cpq_production_dt__c',editable: true,sortable: true,required:true};
        this.dynamicColumnMap['core_cpq_pricing_start_date_dt__c'] = {label:'Pricing Start Date',fieldName:'core_cpq_pricing_start_date_dt__c',editable: false,sortable: true,required:false};
        this.dynamicColumnMap['core_cpq_pricing_end_date_dt__c'] = {label:'Pricing End Date',fieldName:'core_cpq_pricing_end_date_dt__c',editable: false,sortable: true,required:false};
        this.dynamicColumnMap['core_cpq_reg_number_txt__c'] = {label:'PSG Reg #',fieldName:'core_cpq_reg_number_txt__c',editable: true,sortable: true,required:false};
        this.dynamicColumnMap['core_cpq_product_family_txt__c'] = {label:'Product Family',fieldName:'core_cpq_product_family_txt__c',editable: true,sortable: true,required:false};
        this.dynamicColumnMap['core_cpq_contracted_price__c'] = {label:'Contracted Price',fieldName:'core_cpq_contracted_price__c',editable: true,sortable: true,required:false};
    }
    
    applyRedColor(dataToAppyColor){
        console.log('calling:: applyRedColor');
        dataToAppyColor.forEach(ele => {
            ele.format = 'slds-text-color_error';
        });
        console.log('exiting:: applyRedColor');
    }

    /*updateDataValues(updateItem) {
        console.log('calling:: updateDataValues');
        let copyData = [... this.data];
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
        console.log('exiting:: updateDataValues');
    }*/

    setDataTableColumns(){
        console.log('calling:: setDataTableColumns');
        this.distyColumns = [];
        this.distyPendingColumns = [];
        this.distyColumns =  [...this.distyColumns,
            {label: 'Action',
                type: 'action',
                fixedWidth: 100,
                typeAttributes: { rowActions: actions },
            },//added to move
            {label:'Line #',fieldName:'Name',editable: false,sortable: true,required:true,initialWidth: 150},
            {label:'* Part Number',fieldName:'core_cpq_opn__c',editable: this.isEditable,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyOPNColor'
                    },
                    alignment: 'left',
                }, initialWidth: 150
            },
            //{label:'Pricing Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true},
            //{label:'LBound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',type:'number',editable: this.isEditable,sortable: true,required:false},
            //{label:'UBound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',type:'number',editable: this.isEditable,sortable: true,required:false},
            {label:'* Estimated Annual Usage Qty',fieldName:'SBQQ__Quantity__c',type:'number',editable: this.isEditable,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyQuantityColor'
                    },
                    alignment: 'left'
                }, initialWidth: 150
            },

            {label:'* # of Years',fieldName:'core_cpq_years_nbr__c',type:'number',editable: this.isEditable,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyYearsColor'
                    },
                    alignment: 'left'
                }
            },

            {label:'* Requested Resale',fieldName:'price_requested_resale_amt__c',type:'currency',editable: this.isEditable,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyrequestedresaleColor'},alignment: 'left'}, initialWidth: 150},
            {label:'* Prod Start Date',fieldName:'core_cpq_production_dt__c',type:'date-local',editable: this.isEditable,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },
                cellAttributes: {
                    class: {fieldName : 'applyProdDateColor'},
                    alignment: 'left'
                }, initialWidth: 150
            },            
            {label:'Disty Comments',fieldName:'core_cpq_external_comments_txt__c',type:'text',editable: this.isEditable,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyexternalcommentsColor'},alignment: 'left'}, initialWidth: 150},
            {label:' Design Registration Product',fieldName:'core_cpq_altera_reg_txt__c',type:'text',editable: this.isEditable,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyalteraregColor'},alignment: 'left'}, initialWidth: 150},
            {label:'Competitor',fieldName:'core_cpq_competitor_name_nm__c',type:'text',editable: this.isEditable,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applycompnameColor'},alignment: 'left'}, initialWidth: 150},
            {label:'Competitor Part',fieldName:'core_cpq_competitor_part_txt__c',type:'text',editable: this.isEditable,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applycomppartColor'},alignment: 'left'}, initialWidth: 150},
            {label:'Competitor Price',fieldName:'core_cpq_competitor_price_amt__c',type:'currency',editable: this.isEditable,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applycomppriceColor'},alignment: 'left'}, initialWidth: 150}, 
            /*{label: 'Action',
                type: 'action',
                fixedWidth: 100,
                typeAttributes: { rowActions: actions },
            }*/
        ];
        if(this.inProgressQuote == true){
            console.log('inProgressQuote :: true');
            this.distyPendingColumns.push(
                /*{label: 'Action',
                type: 'action',
                fixedWidth: 100,
                typeAttributes: { rowActions: actions },
                },//added to move*/
                {
                    label: 'Revision Request', fieldName: 'core_cpq_revision_request_category_nm__c',editable: true,sortable: true,type: 'picklist',initialWidth: 200, typeAttributes: {
                            placeholder: 'Choose Category', options: [
                                { label: 'Choose Category', value: 'Choose Category'},
                                { label: 'Win', value: 'Win'},
                                { label: 'Loss', value: 'Loss'},
                                { label: 'Add', value: 'Add' },
                                { label: 'Change', value: 'Change'},
                                { label: 'Other PSG OPN', value: 'Other Altera Part'},
                                

                                
                            ] 
                            , value: { fieldName: 'core_cpq_revision_request_category_nm__c'}
                            , context: { fieldName: 'Id' }
                            , fieldapiname: 'core_cpq_revision_request_category_nm__c',cellAttributes: {class: {fieldName: 'applyrequestcategoryColor'},alignment: 'left'}
                    }
            });
            //Change made by Tejaswini/Himanshu - TWC3133-4919
            this.distyPendingColumns.push({label:'* Justification',fieldName:'core_cpq_justification_txt__c',editable: true,sortable: true,required:true,cellAttributes: {
                class: {
                    fieldName: 'applyJustificationColor'
                },
                alignment: 'left'
            },
                initialWidth: 150,
            });
        }
        //added for DPA
        
        this.distyDPAColumns = [
    
            {label:'Line #',fieldName:'Name',editable: false,sortable: true, initialWidth: 150}, 
            {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true, initialWidth: 150},
            {label:'* Part Number',fieldName:'Core_OPN__c',editable: false,sortable: true, initialWidth: 150},
            
			{label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                }, initialWidth: 150
            },  
			{label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },
            {label:'Parent Quote Active Flag',fieldName:'core_cpq_parent_quote_active_flag__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                }, initialWidth: 150
            },//Active Pricing
            //{label:'Pricing Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true},
            {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: false,sortable: true, initialWidth: 150},
            {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: false,sortable: true, initialWidth: 150},
            {label:'Quoted Qty',fieldName:'SBQQ__Quantity__c',editable: false,sortable: true, initialWidth: 150},

            
            {label:'Start Date',fieldName:'core_cpq_ship_start_for_dpa__c',type:'date-local',editable: true,sortable: true,required:false,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                }, initialWidth: 150
            },
            {label:'* Requested Qty',fieldName:'core_cpq_requested_qty__c',type:'number',editable: true,min:'0',sortable: true,required: true, initialWidth: 150},
            {label:'Disty Value Added',fieldName:'core_cpq_disty_value_add_dpa__c',type:'currency',editable: true,sortable: true,required:false, initialWidth: 150}, 
            
            {label:'List Unit Price',fieldName:'SBQQ__ListPrice__c',type:'number',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                }, initialWidth: 150
            },
            {label:'Disty Cost $',fieldName:'price_disty_cost_nbr__c',type:'currency',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },
            },
            {label:'Suggested Resale $',fieldName:'price_suggested_resale_amt__c',type:'currency',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                }, initialWidth: 150
            },
            {label:'Broken Cost $',fieldName:'price_brokencost_amt__c',type:'currency',editable: false,sortable: true,required:false,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                }, initialWidth: 150
            },
            {label:'Disti Margin %',fieldName:'core_cpq_distributor_margin_pct__c',type:'number',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                }, initialWidth: 150
            }

            
            //{label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:true},   
           
        ]
        this.distyCPColumns = [
    
            {label:'Line #',fieldName:'Name',editable: false,sortable: true, initialWidth: 150}, 
            {label:'Part Number',fieldName:'Core_OPN__c',editable: false,sortable: true,required:false, initialWidth: 150},
            
			{label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                }, initialWidth: 150
            },  
			{label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },  
           /* {label:'Parent Quote Active Flag',fieldName:'core_cpq_parent_quote_active_flag__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                }
            },//Active Pricing*/
            {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true, initialWidth: 150},
            {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: false,sortable: true, initialWidth: 150},
            {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: false,sortable: true, initialWidth: 150},
            {label:'Estimated Annual Usage Qty',fieldName:'SBQQ__Quantity__c',editable: false,sortable: true,initialWidth: 150},
            {label:' # of Years',fieldName:'core_cpq_years_nbr__c',type:'number',editable: false,sortable: true,required:false,initialWidth: 100},
            {label:'Production Start Date',fieldName:'core_cpq_production_dt__c',editable: false,sortable: true,required:false,initialWidth: 150},
            {label:'Price Start Date',fieldName:'core_cpq_pricing_start_date_dt__c',editable: false,sortable: true,required:false,initialWidth: 150},
            {label:'Price End Date',fieldName:'core_cpq_pricing_end_date_dt__c',editable: false,sortable: true,required:false,initialWidth: 150},
            {label:'Suggested Resale $',fieldName:'price_suggested_resale_amt__c',type:'currency',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                }, initialWidth: 150
            },
            {label:'Disty Cost $',fieldName:'price_disty_cost_nbr__c',editable: false,type:'currency',sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Broken Cost $',fieldName:'price_brokencost_amt__c',editable: false,sortable: true,type:'currency',required:false,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Intel PSG Registration Number',fieldName:'core_cpq_altera_reg_txt__c',type:'text',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'}, initialWidth: 150},
            
           
            
           /* {label:'List Unit Price',fieldName:'SBQQ__ListPrice__c',editable: false,sortable: true},
           
            {label:'Suggested Resale $',fieldName:'price_suggested_resale_amt__c',editable: false,sortable: true},
            {label:'Broken Cost $',fieldName:'price_brokencost_amt__c',editable: false,sortable: true,required:false},
            {label:'Disti Margin %',fieldName:'core_cpq_distributor_margin_pct__c',editable: false,sortable: true}*/

            
            //{label:'Requested Quantity',fieldName:'core_cpq_requested_qty__c',editable: true,sortable: true,required:true},   
           
        ]
        //added for ALN
        this.distyALNColumns = [
    
            {label:'Line #',fieldName:'Name',editable: false,sortable: true,initialWidth: 150}, 
            {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true,initialWidth: 150},
            {label:'* Part Number',fieldName:'Core_OPN__c',editable: false,sortable: true,initialWidth: 150},
			
            {label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },
			{label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },
            {label:'Parent Quote Active Flag',fieldName:'core_cpq_parent_quote_active_flag__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },  
            //{label:'Pricing Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true},
            {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: false,sortable: true,initialWidth: 150},
            {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: false,sortable: true,initialWidth: 150},
           /* {label:'Quoted Qty',fieldName:'SBQQ__Quantity__c',editable: false,sortable: true},

            {label:'Value Add',fieldName:'core_cpq_disty_value_add_dpa__c',type:'currency',editable: true,sortable: true,required:false},
            {label:'Start Date',fieldName:'core_cpq_ship_start_for_dpa__c',type:'date-local',editable: true,sortable: true,required:false,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },
            },
            {label:'Requested Qty',fieldName:'core_cpq_requested_qty__c',type:'number',editable: true,sortable: true},   
            */
            {label:'List Unit Price',fieldName:'SBQQ__ListPrice__c',type:'number',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Disty Cost $',fieldName:'price_disty_cost_nbr__c',type:'currency',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Broken Cost $',fieldName:'price_brokencost_amt__c',type:'currency',editable: false,sortable: true,required:false,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Suggested Resale $',fieldName:'price_suggested_resale_amt__c',type:'currency',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Disti Margin %',fieldName:'core_cpq_distributor_margin_pct__c',type:'number',editable: false,sortable: true,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            }

        ]        

        this.distyPendingColumns =  [...this.distyPendingColumns,
            {label: 'Action',
                type: 'action',
                fixedWidth: 100,
                typeAttributes: { rowActions: actions },
            },//added to move actions
            {label:'Line #',fieldName:'Name',editable: false,sortable: true,required:true, initialWidth: 150},
			
            {label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                }, initialWidth: 150
            },
			{label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                }, initialWidth: 150
            },
            {label:'* Part Number',fieldName:'core_cpq_opn__c',editable: true,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyOPNColor'
                    },
                    alignment: 'left',
                    tabindex :"10"
                }, initialWidth: 150
            },
            {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true ,initialWidth: 150},
            {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',type:'number',editable: true,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applylboundColor'},alignment: 'left',tabindex :'20'},initialWidth: 150},
            {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',type:'number',editable: true,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyupperboundColor'},alignment: 'left',tabindex :'30'},initialWidth: 150},
            {label:'* Estimated Annual Usage Qty',fieldName:'SBQQ__Quantity__c',type:'number',editable: true,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyQuantityColor'
                    },
                    alignment: 'left',
                    tabindex :'40'
                },initialWidth: 150
            },
            {label:'* # of Years',fieldName:'core_cpq_years_nbr__c',type:'number',editable: true,sortable: true,required:true,initialWidth: 100,
                cellAttributes: {
                    class: {
                        fieldName: 'applyYearsColor'
                    },
                    alignment: 'left',
                    tabindex :'50'
                }
            },
            //added as part of defect
           
            /*{label:'Price Eligibility Date',fieldName:'core_cpq_price_eligibility_date_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },cellAttributes: {class: {fieldName: 'applypriceeligibilityColor'},alignment: 'left'}
            },*/
            {label:'* Production Start Date',fieldName:'core_cpq_production_dt__c',type:'date-local',editable: true,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },
                cellAttributes: {
                    class: {fieldName : 'applyProdDateColor'},
                    alignment: 'left',
                    tabindex :'60'
                },initialWidth: 150
            },
            {label:'Pricing Start Date',fieldName:'core_cpq_pricing_start_date_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },cellAttributes: {class: {fieldName: 'applypricestartColor'},alignment: 'left'},initialWidth: 150
            },
            {label:'Pricing End Date',fieldName:'core_cpq_pricing_end_date_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },cellAttributes: {class: {fieldName: 'applypriceendColor'},alignment: 'left'}, initialWidth: 150
            },
            {label:'Parent Quote',fieldName:'core_cpq_parent_quote_txt__c',type:'text',editable: false,sortable: true,required:false, initialWidth: 150},//cellAttributes: {class: {fieldName: 'applyrequestedresaleColor'},alignment: 'left'}},
            {label:'* Requested Resale',fieldName:'price_requested_resale_amt__c',type:'currency',editable: true,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyrequestedresaleColor'},alignment: 'left',tabindex :'70'},
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Suggested Resale',fieldName:'price_suggested_resale_amt__c',type:'currency',editable: false,sortable: true,required:false,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Disty Cost',fieldName:'price_disty_cost_nbr__c',type:'currency',editable: false,sortable: true,required:false,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Broken Cost',fieldName:'price_brokencost_amt__c',type:'currency',editable: false,sortable: true,required:false,
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Design Registration Product',fieldName:'core_cpq_altera_reg_txt__c',type:'text',editable: true,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyalteraregColor'},alignment: 'left',tabindex :'80'},initialWidth: 150},
            {label:'Disty Comments',fieldName:'core_cpq_external_comments_txt__c',type:'text',editable: true,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyexternalcommentsColor'},alignment: 'left',tabindex :'90'},initialWidth: 150},
            //added Comments for Disty as part of defect 
            {label:'Comments for Disty',fieldName:'core_cpq_comments_for_disty_txt__c',type:'text',editable: false,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyexternalcommentsColor'},alignment: 'left'},initialWidth: 150},
            /*{label: 'Action',
                type: 'action',
                fixedWidth: 100,
                typeAttributes: { rowActions: actions },
            }  */  
        ];
        this.distyReadOnlyPendingColumns = [
            {label:'Line #',fieldName:'Name',editable: false,sortable: true,required:true,initialWidth: 150},
			
            {label:'$ Change Flag',fieldName:'core_cpq_dollar_change_flag_cb__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },
			   {label:'Active Pricing',fieldName:'core_cpq_active_Pricing__c',editable: false,sortable: true,type: 'boolean',
                cellAttributes: {
                    alignment: 'center'
                },initialWidth: 150
            },
            {label:'* Part Number',fieldName:'core_cpq_opn__c',editable: false,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyOPNColor'
                    },
                    alignment: 'left',
                    
                },initialWidth: 150
            },
            {label:'Quote Line Type',fieldName:'core_cpq_quote_line_type_document__c',editable: false,sortable: true,initialWidth: 150},
            {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',type:'number',editable: false,sortable: true,required:false,initialWidth: 150},
            {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',type:'number',editable: false,sortable: true,required:false,initialWidth: 150},
            {label:'* Estimated Annual Usage Qty',fieldName:'SBQQ__Quantity__c',type:'number',editable: false,sortable: true,required:true,
                cellAttributes: {
                    class: {
                        fieldName: 'applyQuantityColor'
                    },
                    alignment: 'left'
                },initialWidth: 150
            },
            {label:'* # of Years',fieldName:'core_cpq_years_nbr__c',type:'number',editable: false,sortable: true,required:true,initialWidth: 100,
                cellAttributes: {
                    class: {
                        fieldName: 'applyYearsColor'
                    },
                    alignment: 'left'
                }
            },
            //added as part of defect
            
            /*{label:'Price Eligibility Date',fieldName:'core_cpq_price_eligibility_date_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                }
            },*/
            {label:'* Production Start Date',fieldName:'core_cpq_production_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },
                cellAttributes: {
                    class: {fieldName : 'applyProdDateColor'},
                    alignment: 'left'
                },initialWidth: 150
            },
            {label:'Pricing Start Date',fieldName:'core_cpq_pricing_start_date_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },
                cellAttributes: {alignment: 'left'},initialWidth: 150
            },
            {label:'Pricing End Date',fieldName:'core_cpq_pricing_end_date_dt__c',type:'date-local',editable: false,sortable: true,required:true,
                typeAttributes:{
                    month: "2-digit",
                    day: "2-digit"
                },initialWidth: 150
            },
            {label:'Parent Quote',fieldName:'core_cpq_parent_quote_txt__c',type:'text',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},initialWidth: 150},
            {label:'* Requested Resale',fieldName:'price_requested_resale_amt__c',type:'currency',editable: false,sortable: true,required:false,cellAttributes: {class: {fieldName: 'applyrequestresaleColor'},alignment: 'left'},//cellAttributes: {class: {fieldName: 'applyrequestresaleColor'},alignment: 'left',tabindex :'70'}
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Suggested Resale',fieldName:'price_suggested_resale_amt__c',type:'currency',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Disty Cost',fieldName:'price_disty_cost_nbr__c',type:'currency',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },
            },
            {label:'Broken Cost',fieldName:'price_brokencost_amt__c',type:'currency',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},
                typeAttributes: { 
                    minimumFractionDigits: '2', maximumFractionDigits: '2'
                },initialWidth: 150
            },
            {label:'Design Registration Product',fieldName:'core_cpq_altera_reg_txt__c',type:'text',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},initialWidth: 150},
            {label:'Disty Comments',fieldName:'core_cpq_external_comments_txt__c',type:'text',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},initialWidth: 150},
            //added Comments for Disty as part of defect 
            {label:'Comments for Disty',fieldName:'core_cpq_comments_for_disty_txt__c',type:'text',editable: false,sortable: true,required:false,cellAttributes: {alignment: 'left'},initialWidth: 150},
            /*{label: 'Action',
                type: 'action',
                fixedWidth: 100,
                typeAttributes: { rowActions: actions },
            }*/    
        ];

        console.log('exiting:: setDataTableColumns');
    }

    /*addNewQuoteLine(){
        console.log('calling:: addNewQuoteLine');
        this.showSpinner = true;
        this.disableSearch = true;
        //this.quoteLineList.push(this.tempRow);
        addNewQuoteLine({recordId: this.recordId,quoteLineLst :this.quoteLineList})  
        .then(result=>{ 
        this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        //this.quoteLineMap = JSON.parse(JSON.stringify(result.quoteLineMap));
        //console.log(' quoteLineMap '+JSON.stringify(this.quoteLineMap));
        //this.quoteLineMap.set(quoteLine.Id,{ ...quoteLine });
        this.showSpinner = false; 
        let index = this.quoteLineList.length;
        if(index > 0){
            let lastQuoteLine = this.quoteLineList[index-1];
            lastQuoteLine.Id = 'row'+ this.count;

            if(lastQuoteLine.core_cpq_opn__c == null || lastQuoteLine.core_cpq_opn__c == undefined || lastQuoteLine.core_cpq_opn__c == ''){
                //lastQuoteLine.applyOPNColor = "slds-theme_alert-texture slds-text-color_default";
                lastQuoteLine.applyOPNColor = "slds-theme_error slds-text-color_default";
                //this.quoteLineList[index-1].applyOPNColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.SBQQ__Quantity__c == null || lastQuoteLine.SBQQ__Quantity__c == undefined || lastQuoteLine.SBQQ__Quantity__c == ''){
                lastQuoteLine.applyQuantityColor = "slds-theme_error slds-text-color_default";
                //this.quoteLineList[index-1].applyQuantityColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.core_cpq_years_nbr__c == null || lastQuoteLine.core_cpq_years_nbr__c == undefined || lastQuoteLine.core_cpq_years_nbr__c == ''){
                lastQuoteLine.applyYearsColor = "slds-theme_error slds-text-color_default";
                //this.quoteLineList[index-1].applyYearsColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.core_cpq_production_dt__c == null || lastQuoteLine.core_cpq_production_dt__c == undefined || lastQuoteLine.core_cpq_production_dt__c == ''){
                lastQuoteLine.applyProdDateColor = "slds-theme_error slds-text-color_default";
                //this.quoteLineList[index-1].applyProdDateColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.price_requested_resale_amt__c == null || lastQuoteLine.price_requested_resale_amt__c == undefined || lastQuoteLine.price_requested_resale_amt__c == ''){
                lastQuoteLine.applyrequestedresaleColor = "slds-theme_error slds-text-color_default";
                //this.quoteLineList[index-1].applyrequestedresaleColor = "slds-theme_error slds-text-color_default";
            }
            //Change made by Tejaswini/Himanshu - TWC3133-4919
            if(lastQuoteLine.core_cpq_justification_txt__c == null || lastQuoteLine.core_cpq_justification_txt__c == undefined || lastQuoteLine.core_cpq_justification_txt__c == ''){
                lastQuoteLine.applyJustificationColor = "slds-theme_error slds-text-color_default";
                //this.quoteLineList[index-1].applyJustificationColor = "slds-theme_error slds-text-color_default";
            }//added for enhancement
            let tempMap = {};
            tempMap = this.actualQuoteLineMap;
            tempMap[lastQuoteLine.Id] = lastQuoteLine;
            this.actualQuoteLineMap = tempMap;
            this.items.push(lastQuoteLine);
            this.updateDraftValues(lastQuoteLine);
            this.updateDraftValues(lastQuoteLine);
            //this.draftValues.push(lastQuoteLine);
            this.count = this.count + 1;
        }
        this.totalRecountCount = this.items.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.endingRecord = this.totalRecountCount;
        this.page = this.totalPage;
        this.showLastPage(this.page);
        
        console.log('dispatchingNewEvent:: addNewQuoteLine');
        const selectEvent = new CustomEvent('addnewquoteline', {
            detail: this.draftValues
        });
        this.dispatchEvent(selectEvent);
        /*var test = result;
            test.forEach(item => {
                this.quoteLineList.push(item);  
            });
        }) 
        .catch(error=>{  
            this.showSpinner = false;
            this.showToast('Error Loading QuoteLines',JSON.stringify(error),'error');
            console.log('Error Updating Records',JSON.stringify(error),'error');
        })
    }*/
    /*
    @api
    validateopn(){
        this.showSpinner = true;
        console.log('inside quotelinedatatable validate');
        var opndata = new Map();
        var opndata1 = new Map();
        var opnList = [];
        var invalidOPNError = 'Invalid OPN : ';
        var invalidOPNExists = false;
        var i = 0;
        this.draftValues.forEach(function(quoteLine){
            console.log('test 1 '+quoteLine.core_cpq_opn__c);
            console.log('test 2 '+i);
            opndata.set( i , quoteLine.core_cpq_opn__c);
            opnList.push(quoteLine.core_cpq_opn__c);
            i = i + 1;
        });

        opndata1 = [...opndata];
        console.log('opn map  '+JSON.stringify(opndata1));
        validateOPN({opnList : opnList})
        .then(data => {
            this.showSpinner = false;
            console.log('test 2 '+data);
            if(data != 'success'){
                this.showToast('Error',data,'error');
            }
            const selectEvent = new CustomEvent('savequote', {
                detail: this.draftValues
            });
            this.dispatchEvent(selectEvent);
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('error 22222222222');
            this.showToast('Error Validating OPN',JSON.stringify(error),'error');
            console.log('Error Updating Records',JSON.stringify(error),'error');
            
        })        
    }
    */
    updateDraftValues(updateItem) {
        console.log('calling:: updateDraftValues');
        let draftValueChanged = false;
        let copyDraftValues = [];
        //let copyDraftValues = [...this.draftValues];
        //copyDraftValues.push.apply(copyDraftValues, this.draftValues);
        for (let index = 0; index < this.draftValues.length; index++) {
            console.log('copyDraftValues:: pushed');
            copyDraftValues.push(this.draftValues[index]);
        }
    
        //AutoCalculation 
        var distyMargin;
        var brokenCost;
        var suggestedResale;
        var contractedPrice;
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        /*
        if(data) {
            for(let key in data) {
                // Preventing unexcepted data
                if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                    this.mapOfValues.push({value:data[key], key:key});
                }
            }
        }
        */
    
        for (let index = 0; index < copyDraftValues.length; index++) {
            console.log('interatingOver:: copyDraftValues');
            let item = copyDraftValues[index];
    
            //copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                console.log('itemId is equalWith:: updateItem');
                //if(this.isDistiPortal == false){
                for (let field in updateItem) {
                    console.log('interatingOver:: updateItem');
                    item[field] = updateItem[field];
                    item[field] = updateItem[field];
    
                    console.log('enteringFieldChecking::' + field);
                    if (field != 'core_cpq_action_txt__c' && field != 'core_cpq_altera_reg_txt__c' && field != 'core_cpq_revision_request_category_nm__c' && field != 'core_cpq_revision_reason_txt__c') {
                        item['core_cpq_action_txt__c'] = 'Edit';
                    }
                    if (field == 'core_cpq_opn__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyOPNColor = "slds-theme_default slds-text-color_default";
                            //item['applyOPNColor'] = 'slds-text-color_default slds-theme_default';
                        } else {
                            updateItem.applyOPNColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'SBQQ__Quantity__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyQuantityColor = "slds-theme_default slds-text-color_default";
                            //item['applyQuantityColor'] = 'slds-text-color_default slds-theme_default';
                        } else {
                            updateItem.applyQuantityColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'core_cpq_years_nbr__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyYearsColor = "slds-theme_default slds-text-color_default";
                            //item['applyYearsColor'] = "slds-text-color_default slds-theme_default";
                        } else {
                            updateItem.applyYearsColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'core_cpq_production_dt__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyProdDateColor = "slds-theme_default slds-text-color_default";
                            //item['applyProdDateColor'] = 'slds-text-color_default slds-theme_default';
                        } else {
                            updateItem.applyProdDateColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'price_requested_resale_amt__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyrequestedresaleColor = "slds-theme_default slds-text-color_default";
                            //item['applyProdDateColor'] = 'slds-text-color_default slds-theme_default';
                        } else {
                            updateItem.applyrequestedresaleColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    //Change made by Tejaswini/Himanshu - TWC3133-4919
                    if (field == 'core_cpq_justification_txt__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyJustificationColor = "slds-theme_default slds-text-color_default";
                            //item['applyProdDateColor'] = 'slds-text-color_default slds-theme_default';
                        } else {
                            updateItem.applyJustificationColor = "slds-theme_error slds-text-color_default";
                        }
                    } //added for enhancement
    
                    if (field == 'core_cpq_revision_request_category_nm__c') {
                        let preSelectedIdLst = [];
                        preSelectedIdLst = [...this.preSelectedRows];
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            if (updateItem[field] != 'Choose Category') {
                                preSelectedIdLst.push(item.Id);
                                this.preSelectedRows = preSelectedIdLst;
                            } else {
                                var filtered = preSelectedIdLst.filter(function(value, index, arr) {
                                    return value != item.Id;
                                });
                                this.preSelectedRows = filtered;
                            }
                        }
                    }
                    console.log('exitingFieldChecking:: ' + field);
                    //if((this.actualQuoteLineMap).has(item.Id)){
                    //    ((this.actualQuoteLineMap).get(item.Id)).field = updateItem[field];
                    //}
                    console.log('enteringFieldUpate:: fetchingDetailsFromUpdateItem || fetchingDetailsFromQuoteLineMap');
                    (this.actualQuoteLineMap[item.Id])[field] = updateItem[field];
                    if (item.Id != null && item.Id != undefined && this.quoteLineMap[item.Id] != null) {
                        (this.quoteLineMap[item.Id])[field] = updateItem[field];
    
                        item['core_cpq_opn__c'] = this.quoteLineMap[item.Id].core_cpq_opn__c;
                        item['SBQQ__Quantity__c'] = this.quoteLineMap[item.Id].SBQQ__Quantity__c;
                        item['core_cpq_years_nbr__c'] = this.quoteLineMap[item.Id].core_cpq_years_nbr__c;
                        item['core_cpq_production_dt__c'] = this.quoteLineMap[item.Id].core_cpq_production_dt__c;
                        item['price_requested_resale_amt__c'] = this.quoteLineMap[item.Id].price_requested_resale_amt__c; //added for enhancement
                        item['core_cpq_altera_reg_txt__c'] = this.quoteLineMap[item.Id].core_cpq_altera_reg_txt__c; //added for DRP pending
                        item['SBQQ__Quote__c'] = this.quoteLineMap[item.Id].SBQQ__Quote__c;
                        if (this.isDistiPortal == false) {
                            console.log('isDistiPortal:: false');
                            distyMargin = this.quoteLineMap[item.Id].core_cpq_distributor_margin_pct__c;
                            brokenCost = this.quoteLineMap[item.Id].price_brokencost_amt__c;
                            suggestedResale = this.quoteLineMap[item.Id].price_suggested_resale_amt__c;
                            contractedPrice = this.quoteLineMap[item.Id].core_cpq_contracted_price__c;
    
                            if ((field == 'price_suggested_resale_amt__c' || field == 'core_cpq_distributor_margin_pct__c') && distyMargin != null) {
                                item['price_brokencost_amt__c'] = suggestedResale - (suggestedResale * (distyMargin / 100));
                            } else if (field == 'price_brokencost_amt__c' && brokenCost != null) {
                                item['core_cpq_distributor_margin_pct__c'] = ((suggestedResale - brokenCost) / suggestedResale) * 100;
                            }
                        }
                    }
                }
                console.log('exitingTheLoop:: updateItem');
                //}
                draftValueChanged = true;
            }
        }
        console.log('exitingTheLoop:: copyDraftValues');
        //});
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
            console.log('draftValuesPushed:: copyDraftValues');
        } else {
            var updateItem1={};
            for(let field in updateItem){
                updateItem1[field]=updateItem[field];
            }
            this.draftValues = [...copyDraftValues, updateItem1];
            console.log('draftValuesPushed:: copyDraftValuesWithUpdateItems');
        }
        this.quoteLineList.forEach(function(quoteLine) {
            console.log('iteratingTheLoop:: quoteLineList');
            if (quoteLine.Id == updateItem.Id) {
    
                if (updateItem.applyOPNColor != null) {
                    quoteLine.applyOPNColor = updateItem.applyOPNColor;
                }
                if (updateItem.applyQuantityColor != null) {
                    quoteLine.applyQuantityColor = updateItem.applyQuantityColor;
                }
                if (updateItem.applyYearsColor != null) {
                    quoteLine.applyYearsColor = updateItem.applyYearsColor;
                }
                if (updateItem.applyProdDateColor != null) {
                    quoteLine.applyProdDateColor = updateItem.applyProdDateColor;
                }
                if (updateItem.applyrequestedresaleColor != null) {
                    quoteLine.applyrequestedresaleColor = updateItem.applyrequestedresaleColor;
                }
                //Change made by Tejaswini/Himanshu - TWC3133-4919
                if (updateItem.applyJustificationColor != null) {
                    quoteLine.applyJustificationColor = updateItem.applyJustificationColor;
                }
                //added for enhancement
            }
        });
        console.log('exitingTheLoop:: quoteLineList');
        this.items.forEach(function(quoteLine) {
            console.log('exitingTheLoop:: items');
            if (quoteLine.Id == updateItem.Id) {
                if (updateItem.applyOPNColor != null) {
                    quoteLine.applyOPNColor = updateItem.applyOPNColor;
                }
                if (updateItem.applyQuantityColor != null) {
                    quoteLine.applyQuantityColor = updateItem.applyQuantityColor;
                }
                if (updateItem.applyYearsColor != null) {
                    quoteLine.applyYearsColor = updateItem.applyYearsColor;
                }
                if (updateItem.applyProdDateColor != null) {
                    quoteLine.applyProdDateColor = updateItem.applyProdDateColor;
                }
                if (updateItem.applyrequestedresaleColor != null) {
                    quoteLine.applyrequestedresaleColor = updateItem.applyrequestedresaleColor;
                }
                //Change made by Tejaswini/Himanshu - TWC3133-4919
                if (updateItem.applyJustificationColor != null) {
                    quoteLine.applyJustificationColor = updateItem.applyJustificationColor;
                }
            }
        });
        console.log('exitingTheLoop:: quoteLineList');
        console.log('exiting:: updateDraftValues');
    }
    /*
    handleChange(event){
        var fname=event.target.fieldName;
        var index=this.qlColumns.findIndex(col => col.fname == fname);
        this.qlColumns[index].value=event.target.value;

        var dMarginIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Distributor_Margin_Pct__c");
        var bCostIndex = this.qlColumns.findIndex(col => col.fname == "PSG_BrokenCost_Amt__c");
        var resaleIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Suggested_Resale_Amt__c");
        var contractedPriceIndex = this.qlColumns.findIndex(col => col.fname == "PSG_Contracted_Price__c");
        console.log('contractedPriceIndex >> +'+contractedPriceIndex);
        var listPriceIndex = this.qlColumns.findIndex(col => col.fname == "SBQQ__ListPrice__c");
        if(fname=='PSG_Suggested_Resale_Amt__c' || fname=='PSG_Distributor_Margin_Pct__c' ){
             //Broken cost = Suggested resale - (Suggested resale * (distributor margin %/100))
            var suggestedResale=this.qlColumns[resaleIndex].value;
            var distyMargin=this.qlColumns[dMarginIndex].value;
            var brokenCost= suggestedResale - (suggestedResale * (distyMargin/100));
            this.qlColumns[bCostIndex].value=brokenCost.toFixed(2);
        }
        else if(fname=='PSG_BrokenCost_Amt__c'){
            // Distributor margin =(Suggested resale - broken cost)/suggested resale
            var suggestedResale=this.qlColumns[resaleIndex].value;
            var brokenCost=this.qlColumns[bCostIndex].value;
            var distyMargin= ((suggestedResale - brokenCost)/suggestedResale)*100;
            this.qlColumns[dMarginIndex].value=distyMargin.toFixed(2);
        }else if(fname=='PSG_Contracted_Price__c'){
            console.log('Your are inside PSG_Contracted_Price__c condition');
            var contractedPriceId = this.qlColumns[contractedPriceIndex].value;
            //call the method from here
            fetchContractedPrice({contractedPriceId:contractedPriceId}).then(result=>{
                console.log('Data received '+result);
                var contractedPrice = result;
                console.log('Contracted Price :'+contractedPrice);
                this.qlColumns[listPriceIndex].value = contractedPrice;
                console.log('>>'+contractedPrice+ ' '+ contractedPriceId );

             })
             .catch(error=>{
                 console.log('no records found'+error);
             })
           

        }
    }
    */

    //listener handler to get the context and data
    //updates datatable
    picklistChanged(event){
        console.log('entering:: picklistChanged');
        event.stopPropagation();
        var dataRecieved = {};
        dataRecieved = event.detail.data;
        let context = dataRecieved.context;
        let value = dataRecieved.value;
        let fieldapiname = ''+dataRecieved.fieldapiname;
        let myMap = new Map();
        myMap.set('Id',context);
        myMap.set(fieldapiname,value);
        let updatedItem = {};
        updatedItem['Id'] = context;
        updatedItem[fieldapiname] = value;
        console.log('calling from picklistChanged:: updateDraftValues');
        this.updateDraftValues(updatedItem);
        console.log('exiting from picklistChanged:: updateDraftValues');
        console.log('calling from picklistChanged:: updateDraftValues');
        this.updateDraftValues(updatedItem);
        console.log('exiting from picklistChanged:: updateDraftValues');
        //this.updateDataValues(updatedItem);
        console.log('calling from picklistChanged:: updateDraftValues');
        console.log('dispatchingNewEvent:: addNewQuoteLine');
        const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
        this.dispatchEvent(selectEvent);
        console.log('exiting:: picklistChanged');
    }

    handleSelection(event) {
        event.stopPropagation();
        console.log('calling:: handleSelection');
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.key, ParentId: dataRecieved.selectedId };
        console.log('calling from handleSelection:: updateDraftValues');
        this.updateDraftValues(updatedItem);
        console.log('exiting from handleSelection:: updateDraftValues');
        console.log('calling from handleSelection:: updateDraftValues');
        //this.updateDataValues(updatedItem);
        console.log('exiting from handleSelection:: updateDraftValues');
        console.log('exiting:: handleSelection');
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //event.preventDefault();
        console.log('calling:: handleCellChange');
        console.log('calling from handleCellChange:: updateDraftValues');
        this.updateDraftValues(event.detail.draftValues[0]);
        console.log('exiting from handleCellChange:: updateDraftValues');
        console.log('calling from handleCellChange:: updateDraftValues');
        this.updateDraftValues(event.detail.draftValues[0]);
        console.log('exiting from handleCellChange:: updateDraftValues');
        console.log('dispatchingNewEvent:: addNewQuoteLine');
        const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
        this.dispatchEvent(selectEvent);
        console.log('exiting:: handleCellChange');
    }
    //added for DPA
    handleDPASave(quoteMap,status,quoteType) {
        this.showSpinner = true;
        let updatedFields =  this.template.querySelector('c-psg_customized-data-table').draftValues; 
        let selectedline = this.template.querySelector('c-psg_customized-data-table').getSelectedRows();
        let selectedQuoteLineList = [];
       // let listdata =  this.template.querySelector('lightning-datatable').quoteLineList; 
        let DPAmap=new Map;
        //this.oldQuoteLineList = this.template.querySelector('c-psg_customized-data-table').getSelectedRows();
        //****** */
    
        let oldMap = this.oldQuoteLineMap;
       // this.oldQuoteLineList = this.template.querySelector('c-psg_customized-data-table').getSelectedRows();
       //this.oldQuoteLineList = this.template.querySelector('[data-id="datarow"]').getSelectedRows();
       //added for persistence
       this.oldQuoteLineList = [];
       const instance = this;
       const filterMap = new Map(Object.entries(this.actualQuoteLineMap));
       console.log('selectedhas1111 '+filterMap);
       //this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        this.selection.forEach(function(selectedIdKey){
            if(filterMap.has(selectedIdKey)){
                instance.oldQuoteLineList.push(filterMap.get(selectedIdKey));
            }
        });
    
        let ismancheck=false;
        let changeFlagCheck=false;
        let parentQuoteFlagCheck=false;
        this.oldQuoteLineList.forEach(function(quoteLine){
            if(quoteLine.core_cpq_requested_qty__c === undefined || quoteLine.core_cpq_requested_qty__c == ''){
                ismancheck=true;
            }
            if(quoteLine.core_cpq_dollar_change_flag_cb__c == true){
                changeFlagCheck=true;
            }
            if(quoteLine.core_cpq_parent_quote_active_flag__c == false && quoteType=='Transfer Pricing'){
                parentQuoteFlagCheck=true;
            }

        });
        

//sendQuoteRequestUpdate({oldQuoteLineList : selectedQuoteLineList, quoteLineMap : this.actualQuoteLineMap,oldQuoteList : this.quoteList,quoteMap : quoteMap,status : status})  
    //if(selectedQuoteLineList != null && selectedQuoteLineList.length > 0){
            if(this.oldQuoteLineList.length!=0){
                if(changeFlagCheck==false && parentQuoteFlagCheck==false){
                    if(ismancheck==false){
                        /*createDPA({oldQuoteLineList : this.oldQuoteLineList,quoteLineMap : this.actualQuoteLineMap,quoteMap : quoteMap})  
                        .then(result=>{ 

                        
                                this.draftValues = [];
                                /*const selectEvent = new CustomEvent('closeupdaterequest', {
                                    detail: true
                                });
                                this.dispatchEvent(selectEvent);
                                this.connectedCallback();
                                //this.navigateToALNDetail(result);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'DPA Request Sent Successfully',
                                    variant: 'success'
                                })
                            );
                            this.navigateToALNDetail(result);
                            this.showSpinner=false;
                            //ShowToastEvent.fire();
                        // this.showToast('Success','success');
                        })  
                        .catch(error=>{  
                            console.log('Error Updating Records488',JSON.stringify(reduceErrors(error))); 
                           // Chnages made BY Himasnhu / Tejaswini TWC3133-4925
                            this.showToast('Error Requesting DPA',reduceErrors(error).join(","),'error');
                            this.showSpinner=false;
                        })*/ 
                    }
                    else{
                        this.showToast('Error','Please fill Requested Quantity for all selected lines','error');
                        this.showSpinner=false;
                    }
                }else{
                    if(parentQuoteFlagCheck==true && changeFlagCheck ==true && quoteType=='Transfer Pricing'){
                        this.showToast('Error','DPA cannot be requested for QL with $ Change flag set to true and Parent Quote active flag set to false','error');
                    }
                    else if(changeFlagCheck == false && parentQuoteFlagCheck ==true && quoteType=='Transfer Pricing'){
                        this.showToast('Error','DPA cannot be requested for QL with Parent Quote active flag set to false','error');
                        
                    }else{
                        this.showToast('Error','DPA cannot be requested for QL with $ Change flag Set to true','error');
                    }
                    
                    this.showSpinner=false;
                }
            }
            else{
                this.showToast('Error','Select atleast one line for DPA Request','error');
                this.showSpinner=false;
            }
    //}else{
        console.log('test2');
        /*
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please Select a Quote Line',
                variant: 'error'
            })
        );
        */
       // this.showSpinner=false;
    //}
    console.log('completedhandleDPASave');

    }
        //**** */
    //added for ALN
    handleALNSave(quoteMap,status,quoteType) {
        this.showSpinner = true;
        let updatedFields =  this.template.querySelector('c-psg_customized-data-table').draftValues; 
        let selectedline = this.template.querySelector('c-psg_customized-data-table').getSelectedRows();
        //this.oldQuoteLineList = this.template.querySelector('c-psg_customized-data-table').getSelectedRows();


        //persistance
        this.oldQuoteLineList = [];
        const instance = this;
        const filterMap = new Map(Object.entries(this.actualQuoteLineMap));
        //this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        this.selection.forEach(function(selectedIdKey){

            if(filterMap.has(selectedIdKey)){
                 instance.oldQuoteLineList.push(filterMap.get(selectedIdKey));
            }
        });
        //******8 */
        //change flag check
        let changeFlagCheck=false;
        let parentQuoteFlagCheck=false;
        let stepFlagCheck=false;
        this.oldQuoteLineList.forEach(function(quoteLine){
            if(quoteLine.core_cpq_dollar_change_flag_cb__c == true){
                changeFlagCheck=true;
            }
            if(quoteLine.core_cpq_parent_quote_active_flag__c == false && quoteType=='Transfer Pricing'){
                parentQuoteFlagCheck=true;
            }
            if(quoteLine.core_cpq_quote_line_type_document__c == 'Step'){
                stepFlagCheck=true;
            }
        })
        if(this.oldQuoteLineList.length!=0){
            if(this.oldQuoteLineList.length == 1){
                if(stepFlagCheck == false){
                    if(changeFlagCheck==false && parentQuoteFlagCheck==false){
                        /*createALN({oldQuoteLineList : this.oldQuoteLineList,quoteLineMap : this.actualQuoteLineMap,quoteMap : quoteMap})  
                            .then(result=>{ 
                                    this.draftValues = [];
                                    /*const selectEvent = new CustomEvent('closeupdaterequest', {
                                        detail: true
                                    });
                                    this.dispatchEvent(selectEvent);
                                    
                                    this.connectedCallback();
                                    
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'ALN Request Sent Successfully',
                                        variant: 'success'
                                    })
                                );
                                this.navigateToALNDetail(result);
                                this.showSpinner=false;

                            })  
                            .catch(error=>{  

                                console.log('Error DPAReq',JSON.stringify(error),'error');
                                // Changes made by Himanshu/Tejaswini TWC3133-4925
                                this.showToast('Error requesting ALN',reduceErrors(error).join(",") ,'error');
                                this.showSpinner=false;
                            })*/
                    }else{
                        if(parentQuoteFlagCheck==true && changeFlagCheck ==true && quoteType=='Transfer Pricing'){
                            this.showToast('Error','ALN cannot be requested for QL with $ Change flag set to true and Parent Quote active flag set to false','error');
                        }
                        else if(changeFlagCheck == false && parentQuoteFlagCheck ==true && quoteType=='Transfer Pricing'){
                            this.showToast('Error','ALN cannot be requested for QL with Parent Quote active flag set to false','error');
                            
                        }else{
                            this.showToast('Error','ALN cannot be requested for QL with $ Change flag Set to true','error');
                        }
                        this.showSpinner=false;
                    }
                }else{
                    this.showToast('Error','ALN can not be requested for Quote Lines with Step Pricing Method','error');
                    this.showSpinner=false;
                }
            }else{
                this.showToast('Error','Only one OPN of a Quote can be requested for ALN','error');
                this.showSpinner=false;
            }
        }
        else{
            this.showToast('Error','Select one line for ALN Request','error');
            this.showSpinner=false;
        }

        console.log('completedhandleALNSave');

    }
    //**** */    
    handleSave(quoteMap,status) {
        this.showSpinner = true;
        //save last saved copy
        //this.lastSavedData = JSON.parse(JSON.stringify(this.draftValues));
        for (let index = 0; index < this.draftValues.length; index++) {
            this.draftValues[index].SBQQ__Quote__c = this.recordId;
        }
        //this.updateQuoteLines(this.draftValues,quoteMap);
        //this.updateQuoteLines(quoteMap,status);
        //pass this.draftValues either to updateRecord LWC service to
        //update changed records
        //(https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_update_record)
        // or use a wire function to update data through apex 
        //(https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex)

        //WRITE YOUR UPDATE LOGIC HERE

        //once data is updated, do following
        // Clear all draft values
        

        // Refresh data in the datatable with below command
        //if you are datatable is being loaded with wired function
        //(https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.apex)
        // return refreshApex(this.data);
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        //this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
    
    /*fetchQuoteLineDetails(){
        this.showSpinner = true;
        getAllQuoteLines({quoteId: this.recordId})  
        .then(result=>{ 
        this.showSpinner = false; 
        var prodRec = {Id:"01to0000000zceEAAQ",Name:"100 SERIES HM160_Siddu"};
        //console.log('call 1 '+JSON.stringify(result[0]));
        //var prodRec = {Id:"01to0000000zceEAAQ",Name:"100 SERIES HM160_Siddu"};
        //this.template.querySelector("c-psg_customized-data-table").selectItem(prodRec); 
        console.log('call 1');
        this.qlList=[];
        console.log('call 2');
        this.quoteList = JSON.parse(JSON.stringify(result.quoteList));
        
        if(this.quoteList != null && this.quoteList.length > 0){
            this.status = this.quoteList[0].core_cpq_distystatus_txt__c;
        }
        console.log('call 4');
        if(this.recordId == null || (this.status != null && (this.status =='Draft' || this.status =='New' || this.status =='Pending'))){
            this.isEditable = true;
            console.log('this.isEditable '+this.isEditable);
        } 
        /*if(this.recordId != null && (this.pendingvisblity == true) && (this.status != null && (this.status =='Draft' || this.status =='New'))){//added for disty pending visiblity
            this.isEditable = false;
            console.log('this.isEditable222 '+this.isEditable);
        }

        this.setDataTableColumns();
        console.log('call 6');
        if(this.recordId == null || (this.status != null && (this.status =='Draft' || this.status =='New'))){
            this.columns = this.distyColumns;
        }else if((this.status =='Pending' || this.inProgressQuote == true) && (this.pendingvisblity == false)){
            this.columns = this.distyPendingColumns;
            console.log('pendingReq1');
        }else if((this.status == 'In Progress' || this.status == 'Approved' || this.status == 'Rejected' || this.status == 'Cancelled') && this.requestDPAFlag == false && this.requestALNFlag == false && this.isCpQuote == false){//added for DPA
            this.columns = this.distyReadOnlyPendingColumns;
            console.log('readOnlyPending1s');
        }
        else if(this.pendingvisblity == true && this.status =='Pending'){//added for pending visiblity
            this.columns = this.distyReadOnlyPendingColumns;
            console.log('readOnlyPending')
        }
        else if(this.isCpQuote==true){//added for DPA
            this.columns = this.distyCPColumns;
            console.log('readOnlyPending');
        }else if(this.status == 'Approved' && this.requestDPAFlag == true && this.requestALNFlag == false){
            this.columns = this.distyDPAColumns;
            console.log('readOnlyPendingReqDPA');
        }else if(this.status == 'Approved' && this.requestDPAFlag == false && this.requestALNFlag == true){
            this.columns = this.distyALNColumns;
            console.log('readOnlyPendingReqALN');
        }
        this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        //this.data = JSON.stringify(this.quoteLineList);
        
         //   this.quoteLineList.push(this.tempRow);
        //test
        this.oldQuoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        var myMap = {};
        var myMap2 = new Map();
        let index = 0;
        let emptyQuoteLines = false;
        this.quoteLineList.forEach(function(quoteLine){
            if(quoteLine.Id == null || quoteLine.Id == undefined){
                quoteLine.Id = 'row0';
                emptyQuoteLines = true;
                if(quoteLine.core_cpq_opn__c == null || quoteLine.core_cpq_opn__c == undefined || quoteLine.core_cpq_opn__c == ''){
                    quoteLine.applyOPNColor = "slds-theme_error slds-text-color_default";
                }
                if(quoteLine.SBQQ__Quantity__c == null || quoteLine.SBQQ__Quantity__c == undefined || quoteLine.SBQQ__Quantity__c == ''){
                    quoteLine.applyQuantityColor = "slds-theme_error slds-text-color_default";
                }
                if(quoteLine.core_cpq_years_nbr__c == null || quoteLine.core_cpq_years_nbr__c == undefined || quoteLine.core_cpq_years_nbr__c == ''){
                    quoteLine.applyYearsColor = "slds-theme_error slds-text-color_default";
                }
                if(quoteLine.core_cpq_production_dt__c == null || quoteLine.core_cpq_production_dt__c == undefined || quoteLine.core_cpq_production_dt__c == ''){
                    quoteLine.applyProdDateColor = "slds-theme_error slds-text-color_default";
                }
                if(quoteLine.price_requested_resale_amt__c == null || quoteLine.price_requested_resale_amt__c == undefined || quoteLine.price_requested_resale_amt__c == ''){
                    quoteLine.applyrequestedresaleColor = "slds-theme_error slds-text-color_default";
                }//added for enhancement
            }
            //Change made by Tejaswini/Himanshu - TWC3133-4919
            //Added to highlight the Justification field to ensuer that user can see them as mandatory field.
            if(quoteLine.core_cpq_justification_txt__c == null || quoteLine.core_cpq_justification_txt__c == undefined || quoteLine.core_cpq_justification_txt__c == ''){
                quoteLine.applyJustificationColor = "slds-theme_error slds-text-color_default";
            }
            myMap[quoteLine.Id] = quoteLine;
            myMap2.set(quoteLine.Id,{ ...quoteLine });

            //console.log('mymap2.keys '+JSON.stringify(mymap2.keys()));
            //console.log('mymap2.values '+JSON.stringify(mymap2.values()));
            //(this.actualQuoteLineMap).set(quoteLine.Id,{ ...quoteLine });
        });
        if(emptyQuoteLines == true){
            this.draftValues = this.quoteLineList;

            const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
            this.dispatchEvent(selectEvent);
        }
        console.log('test3');
        this.quoteLineMap = myMap;
        console.log('test4');
        this.actualQuoteLineMap = myMap;
        this.oldQuoteLineMap = myMap2;
        console.log('test5');
        //this.lastSavedData = JSON.parse(JSON.stringify(result));
        //this.draftValues = JSON.parse(JSON.stringify(result));

        //Pagination
        this.items = this.quoteLineList;
        this.totalRecountCount = this.items.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.quoteLineList = this.items.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
        //Pagination
        }) 
        .catch(error=>{  
        this.qlList=[];
        this.showSpinner=false;
        this.showToast('Error Loading QuoteLines',JSON.stringify(error),'error');
        console.log('Error Updating Records',JSON.stringify(error),'error');
        }) 
    }*/

    /*deleteRecord(deleteRecordId){
        console.log('deleteRecordId '+deleteRecordId );
        let index = 0;
        let recordIndex = 0;
        let isNewRecordDeletion = false;

        let removeFromQuoteLineList = false;
        let removeFromItems = false;
        let removeFromDraftList = false;
        this.quoteLineList.forEach (function (eachItem) {
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(/*eachItemId.includes('row') && eachItemId == deleteRecordIdStr){
                recordIndex = index;
                removeFromQuoteLineList = true;
                if(eachItemId.includes('row')){
                    isNewRecordDeletion = true;
                }
            }
            index = index + 1;
        }); 

        let itemsIndex = 0;
        let itemsRecordIndex = 0;
        this.items.forEach (function (eachItem) {
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(/*eachItemId.includes('row') && eachItemId == deleteRecordIdStr){
                itemsRecordIndex = itemsIndex;
                removeFromItems = true;
                //isNewRecordDeletion = true;
            }
            itemsIndex = itemsIndex + 1;
        }); 

        let draftItemsIndex = 0;
        let draftItemsRecordIndex = 0;
        this.draftValues.forEach (function (eachItem) {
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(/*eachItemId.includes('row') && eachItemId == deleteRecordIdStr){
                draftItemsRecordIndex = draftItemsIndex;
                removeFromDraftList = true;
                //isNewRecordDeletion = true;
            }
            draftItemsIndex = draftItemsIndex + 1;
        }); 
        let quoteLine;
        if(removeFromQuoteLineList == true){
            let tempQuoteLineList = this.quoteLineList;
            quoteLine = tempQuoteLineList[recordIndex];
            (tempQuoteLineList).splice(recordIndex,1);
            this.quoteLineList = [...tempQuoteLineList];
        }
        if(removeFromItems == true){
            let itemsTempQuoteLineList = this.items;
            (itemsTempQuoteLineList).splice(itemsRecordIndex,1);
            this.items = [...itemsTempQuoteLineList];
        }
        if(removeFromDraftList == true){
            let draftItemsTempQuoteLineList = this.draftValues;
            (draftItemsTempQuoteLineList).splice(draftItemsRecordIndex,1);
            this.draftValues = [...draftItemsTempQuoteLineList];
        }
        console.log('eeeeeee1');
        //reset pagination
        this.totalRecountCount = this.items.length;
        console.log('eeeeeee2'); 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        console.log('eeeeeee3');
        //this.endingRecord = this.totalRecountCount;
        this.displayRecordPerPage(this.page);
        console.log('eeeeeee4');
        //reset pagination
        if(quoteLine.Id != null){
            delete this.actualQuoteLineMap[quoteLine.Id];
        }
        if(isNewRecordDeletion == false){
            deleteRecord({recordId: deleteRecordId})  
            .then(result=>{ 
                this.showSpinner=false;
                console.log('deleted succesfully');
                //this.connectedCallback();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
                this.dispatchEvent(selectEvent);
            })  
            .catch(error=>{  
                this.showSpinner=false;
                this.showToast('Error deleting Record',JSON.stringify(error),'error');
            }) 
        }else{
            this.showSpinner=false;
            const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
            this.dispatchEvent(selectEvent);
        }
    }*/
    /*updateQuoteLines(quoteMap,status){
        if(this.isDistiPortal == false || this.inProgressQuote == false){
            console.log('actual update');
            updateQuoteLines({quoteLineList : this.draftValues})  
            .then(result=>{ 
                this.showSpinner=false;
                this.draftValues = [];
                this.connectedCallback();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated',
                        variant: 'success'
                    })
                );
            })  
            .catch(error=>{  
                this.showSpinner=false;
                this.showToast('Error in Updating Record',JSON.stringify(error),'error');
            }) 
        }else{
            console.log('not actual update');
            let selectedQuoteLineList = [];
            //let selectedDraftValQuoteLineList = [];
            let oldMap = this.oldQuoteLineMap;
            //this.oldQuoteLineList = this.template.querySelector('c-psg_customized-data-table').getSelectedRows();
            this.oldQuoteLineList = this.template.querySelector('c-psg_customized-data-table').draftValues;
            // selectedDraftValQuoteLineList = this.template.querySelector('c-psg_customized-data-table').draftValues;

           // console.log('oldtestQLDraftList '+JSON.stringify(selectedDraftValQuoteLineList));
            this.oldQuoteLineList.forEach(function(quoteLine){
                //console.log('test '+JSON.stringify(oldMap.get(quoteLine.Id)));
                if(!((''+quoteLine.Id).includes('row'))){
                    if(quoteLine.core_cpq_revision_request_category_nm__c != 'Choose Category' && quoteLine.core_cpq_revision_request_category_nm__c != null){
                        selectedQuoteLineList.push(oldMap.get(quoteLine.Id));
                    }
                }else{
                    if(quoteLine.core_cpq_revision_request_category_nm__c != 'Choose Category' && quoteLine.core_cpq_revision_request_category_nm__c != null){
                        selectedQuoteLineList.push(quoteLine);
                    }
                }
                
            });
            
        //if(selectedQuoteLineList != null && selectedQuoteLineList.length > 0){
            sendQuoteRequestUpdate({oldQuoteLineList : selectedQuoteLineList, quoteLineMap : this.actualQuoteLineMap,oldQuoteList : this.quoteList,quoteMap : quoteMap,status : status})  
            .then(result=>{ 
                this.showSpinner=false;
                this.draftValues = [];
                const selectEvent = new CustomEvent('closeupdaterequest', {
                    detail: true
                });
                this.dispatchEvent(selectEvent);
                this.connectedCallback();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote Request Sent Successfully',
                        variant: 'success'
                    })
                );
            })  
            .catch(error=>{  
                this.showSpinner=false;
                let errorJSON = error.body.pageErrors;
                let errorMsg = '';
                if(error.body.message != undefined && error.body.message != ''){
                        errorMsg=error.body.message;
                    }
                    if(errorJSON!=null && errorJSON!=undefined){
                        errorJSON.forEach(function(element){
                            errorMsg = errorMsg + element.message;
                        })
                    }
                if(errorMsg.includes("Quote Record cannot be created or edited during Freeze Period!")){
                    this.showToast('Error','Quote Record cannot be created or edited during Freeze Period!','error');
                }
                else{
                    this.showToast('Error',JSON.stringify(error.body.message),'error');
                }
                
                console.log('error 2');
                console.log('Error in Updating Record '+JSON.stringify(error),'error');
            }) 
        //}else{
            console.log('test2');
            /*
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Select a Quote Line',
                    variant: 'error'
                })
            );
            
            this.showSpinner=false;
        //}
        console.log('completed');
        }
    }*/
    /*cloneRecord(cloneRecordId){
        cloneRecord({recordId: cloneRecordId})  
        .then(result=>{ 
            this.showSpinner=false;
            this.connectedCallback();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record cloned successfully',
                    variant: 'success'
                })
            );
        })  
        .catch(error=>{  
            this.showSpinner=false;
            this.showToast('Error cloning Record',JSON.stringify(error),'error');
        }) 
    }*/
    triggerError(event) {
        this.errors = {
             rows: {
                 b: {
                     title: 'These Fields are Mandatory',
                     messages: [
                         'Please enter a value',
                     ],
                     fieldNames: ['OPN']
                 }
             },
             table: {
                 title: 'Your entry cannot be saved. Fix the errors and try again.',
                 messages: [
                     'Row 2 amount must be number',
                     'Row 2 email is invalid'
                 ]
             }
         };
     }
    showToast(msgTitle,msg,type){
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }
    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.quoteLineList];

        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        this.quoteLineList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }
    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: this.objectApiName,
                        actionName: 'edit'
                    }
                });
                break;
                case 'delete':
                    this.showSpinner = true;
                    if(this.inProgressQuote == true){
                        if(row.Id != null && (''+row.Id).length < 15){
                            this.deleteRecord(row.Id);
                        }else{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'You cannot delete an existing quoteline',
                                    variant: 'error'
                                })
                            );
                            this.showSpinner = false;
                        }
                    }else{
                        this.deleteRecord(row.Id);
                    }
                    break;
                case 'clone':
                    this.showSpinner = true;
                    //this.cloneRecord(row.Id);
                    break;
            default:
        }
    }
    onchangeHandle(event){
        this.disableAddLines = true;
        if((this.tempSearchQuoteLineList == null || this.tempSearchQuoteLineList == undefined) || 
           (this.tempSearchQuoteLineList != null && this.tempSearchQuoteLineList.length == 0)){
            this.tempSearchQuoteLineList =  this.quoteLineList;
        }
        this.dataReturn = [];
        this.selectedValue = event.target.value;
        let currentList = this.tempSearchQuoteLineList;
        
        if(this.selectedValue.length > 0 && this.selectedValue!== undefined && this.selectedValue !== null){
            let concat ='';
            let cnt = 0;
            for (let index = 0; index < currentList.length; index++) {
                console.log('onchangeHandle 1');
                concat+= currentList[index].core_cpq_revision_request_category_nm__c;
                concat+= currentList[index].core_cpq_justification_txt__c;
                concat+= currentList[index].Name;
                concat+= currentList[index].core_cpq_opn__c;
                concat+= currentList[index].SBQQ__Quantity__c;
                concat+= currentList[index].core_cpq_years_nbr__c;
                concat+= currentList[index].price_requested_resale_amt__c;
                concat+= currentList[index].core_cpq_competitor_price_amt__c;
                concat+= currentList[index].core_cpq_competitor_part_txt__c;
                concat+= currentList[index].core_cpq_production_dt__c;
                concat+= currentList[index].core_cpq_altera_reg_txt__c;
                //console.log('concatenated String :'+concat);
                concat = concat.toLowerCase()+''+index;

                if(concat.includes(this.selectedValue.toLowerCase())){
                    this.isDataAvailable = true;
                    this.dataReturn.push(currentList[index]);
                  //  cnt++;
                }
                concat=null;
            }
            if(this.dataReturn.length <= 0){
                this.isDataAvailable = false;
            }
            
        }else{
            this.connectedCallback();
            this.resetPagination();
            //this.quoteLineList = this.tempSearchQuoteLineList;
        }
        if(this.selectedValue.length === 0){
            this.isDataAvailable = true;
            this.dataReturn = this.quoteLineList;
        }else{
            this.quoteLineList = this.dataReturn;
        }
    }
    openModel() {
        this.isOpen = true;
    }
    closeModel() {
        this.isOpen = false;
    }
    closeModel2(){
        this.isModal2Open = false;
        this.connectedCallback();
    }
    handleSubmit(event){
        console.log('inside handle submit');
        event.preventDefault(); 
              // stop the form from submitting
        const fields = event.detail.fields;
        fields.RecordTypeId  = this.recordTypeId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.isModal2Open = false;
        this.showSpinner = true;
    }
     handleSuccess(event){
        console.log('inside handle success');
        const updatedRecord = event.detail.id;
        this.connectedCallback();
        this.showSpinner = false;
    }
    //multiselect functions
    getSelectedItems () {
        this.yourSelectedValues = '';
        let self = this;
        this.template.querySelector ('c-psg_multi-pick-list').getSelectedItems().forEach (function (eachItem) {
                console.log (eachItem.value);
                self.yourSelectedValues += eachItem.value + ', ';
        });
    }

    handleOnItemSelected (event) {
        if (event.detail) {
            this.yourSelectedValues = '';
            let self = this;
            
            event.detail.forEach (function (eachItem) {
                    self.yourSelectedValues += eachItem.value + ', ';
            });
        }
    }
    navigateToNewQuoteLineWithDefaults() {
        const defaultValues = encodeDefaultFieldValues({
            //FirstName: 'Morag',
            //LastName: 'de Fault',
            //LeadSource: 'Other'
        });

        /*
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__QuoteLine__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
        */
        this.isModal2Open = true;
    }
    handleDualPickListChange(event) {
        this._selected = event.detail.value;
    }
    applyColumnSelection(event) {
        let tempColumns = [];
        let columnsSelected = this._selected;
        console.log('1');
        if(columnsSelected != null && columnsSelected != undefined){
            console.log('2');
            columnsSelected.forEach(column => {
                if(this.dynamicColumnMap[column] != undefined){
                    tempColumns.push(this.dynamicColumnMap[column]);
                }
                tempColumns.push({
                    type: 'action',
                    typeAttributes: { rowActions: actions },
                });
            });
            this.columns = tempColumns;
        }
        this.closeModel();
    }
    //navigate to ALN Detail Page
    navigateToALNDetail(data){console.log('entering navigate2222');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: data,
                objectApiName: 'core_cpq_dpa_aln__c',
                actionName: 'view'
            }
        });
    }
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    //clicking on next button this method will be called

    nextHandler(){
        if((this.page < this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }
    resetPagination(){
        this.page = 1; 
        this.startingRecord = 1;
    }
    showLastPage(totalPage) {
        this.endingRecord = this.totalRecountCount;
        this.displayRecordPerPage(totalPage);
    }
    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        if(this.startingRecord < this.totalRecountCount){
            this.endingRecord = (this.pageSize * page);
            this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                                    ? this.totalRecountCount : this.endingRecord; 
            this.quoteLineList = this.items.slice(this.startingRecord, this.endingRecord);
            this.template.querySelector(// added for persistance
                '[data-id="datarow"]'
            ).selectedRows = this.selection;

            this.startingRecord = this.startingRecord + 1;
        }else{
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    } 
    //added for persistence row selection in quotelinedata tables
    rowSelection(evt) {
        console.log('---underRowSelection---');
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selection);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
    
        
        this.quoteLineList.map((event) => {
            loadedItemsSet.add(event.Id);
        });
        
        if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((event) => {
                updatedItemsSet.add(event.Id);
            });
    
    
            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });        
        }


        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        var filtered = [...selectedItemsSet];
        this.selection = filtered;
    }
}