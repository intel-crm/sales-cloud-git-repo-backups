import { LightningElement, track,wire,api } from 'lwc';
import getAllQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.fetchAllQuoteLines';
import addNewQuoteLine from '@salesforce/apex/PSG_QuoteLineDataTableController.addNewQuoteLine';
import deleteRecord from '@salesforce/apex/PSG_QuoteLineDataTableController.deleteRecord';
import updateQuoteLines from '@salesforce/apex/PSG_QuoteLineDataTableController.updateQuoteLines';
import cloneRecord from '@salesforce/apex/PSG_QuoteLineDataTableController.cloneRecord';
import createDPA from '@salesforce/apex/PSG_RequestDPA.createDPA';//added for DPA
import createALN from '@salesforce/apex/PSG_RequestDPA.createALN';//added for ALN
import sendQuoteRequestUpdate from '@salesforce/apex/PSG_QuoteLineDataTableController.sendQuoteRequestUpdate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomDataTableResource from '@salesforce/resourceUrl/PSG_CustomDataTable';
import QUOTELINE_OBJECT from '@salesforce/schema/SBQQ__QuoteLine__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PSG_QuoteLineTablePagination from '@salesforce/label/c.PSG_QuoteLineTablePagination';
import { reduceErrors } from 'c/psg_ldsutils';

const actions = [
    { label: 'Delete', name: 'delete' },
];
export default class CustomDatatableDemo extends  NavigationMixin( LightningElement ) {
    @wire(getObjectInfo, { objectApiName: QUOTELINE_OBJECT }) objectInfo;
    @track data = [];
    @track draftValues = [];
    @track columns = [];
    @api recordId;
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
    @track page = 1; 
    @track items = []; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @track count = 1;
    @track distyColumns = [];
    @track distyPendingColumns = [];
    @track distyReadOnlyPendingColumns = [];
    @track distyDPAColumns = [];
    @track distyCPColumns = [];
    @track columnsToAdd = [];
    @track preSelectedRows = [];
    @track selection = [];
    label = {
        PSG_QuoteLineTablePagination
    };
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
        this.handleDPASave(quoteMap,status,quoteType);
    }  
    @api
    sendalnrequest(quoteMap,status,quoteType){//added for DPA
        this.showSpinner = true;
        this.handleALNSave(quoteMap,status,quoteType);
    }   
    @api
    closeupdaterequest(){
        this.columns = this.distyPendingColumns;
    }
    @api
    closedparequest(){//added for DPA
        this.requestDPAFlag = false;
        this.inProgressQuote = true;
        this.columns = this.distyPendingColumns;
    }
    @api
    opencolumnsupdaterequest(){
        this.showSpinner = true;
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
        this.showSpinner = false;
    }
    //added for DPA
    @api opencolumnsDPArequest(){
         this.showSpinner = true;
         this.columns = [];
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
        this.showSpinner = false;
    }
        //-------
    @api
    sendValidationResult(data){
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
        this.disableAddLines = false;
        this.disableSearch = false;
        this.pageSize = PSG_QuoteLineTablePagination;
        if( this.requestDPAFlag == false && this.requestALNFlag == false){//added to hidecheckbox 
            this.ishideCheckbox = true;
        }
        this.showSpinner = false;
        var localActions;
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
        }
        this.fetchQuoteLineDetails();
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
        dataToAppyColor.forEach(ele => {
            ele.format = 'slds-text-color_error';
        });
    }

    setDataTableColumns(){
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
            
        ];
        if(this.inProgressQuote == true){
            this.distyPendingColumns.push(
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
            },
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
            }, {label:'Lower Bound Qty',fieldName:'core_cpq_lower_bound_qty_qty__c',editable: false,sortable: true,initialWidth: 150},
            {label:'Upper Bound Qty',fieldName:'core_cpq_upper_bound_qty_nbr__c',editable: false,sortable: true,initialWidth: 150},
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
           
        ];
    }

    addNewQuoteLine(){
        this.showSpinner = true;
        this.disableSearch = true;
        addNewQuoteLine({recordId: this.recordId,quoteLineLst :this.quoteLineList})  
        .then(result=>{ 
        this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        this.showSpinner = false; 
        let index = this.quoteLineList.length;
        if(index > 0){
            let lastQuoteLine = this.quoteLineList[index-1];
            lastQuoteLine.Id = 'row'+ this.count;

            if(lastQuoteLine.core_cpq_opn__c == null || lastQuoteLine.core_cpq_opn__c == undefined || lastQuoteLine.core_cpq_opn__c == ''){
                lastQuoteLine.applyOPNColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.SBQQ__Quantity__c == null || lastQuoteLine.SBQQ__Quantity__c == undefined || lastQuoteLine.SBQQ__Quantity__c == ''){
                lastQuoteLine.applyQuantityColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.core_cpq_years_nbr__c == null || lastQuoteLine.core_cpq_years_nbr__c == undefined || lastQuoteLine.core_cpq_years_nbr__c == ''){
                lastQuoteLine.applyYearsColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.core_cpq_production_dt__c == null || lastQuoteLine.core_cpq_production_dt__c == undefined || lastQuoteLine.core_cpq_production_dt__c == ''){
                lastQuoteLine.applyProdDateColor = "slds-theme_error slds-text-color_default";
            }
            if(lastQuoteLine.price_requested_resale_amt__c == null || lastQuoteLine.price_requested_resale_amt__c == undefined || lastQuoteLine.price_requested_resale_amt__c == ''){
                lastQuoteLine.applyrequestedresaleColor = "slds-theme_error slds-text-color_default";
            }
            //Change made by Tejaswini/Himanshu - TWC3133-4919
            if(lastQuoteLine.core_cpq_justification_txt__c == null || lastQuoteLine.core_cpq_justification_txt__c == undefined || lastQuoteLine.core_cpq_justification_txt__c == ''){
                lastQuoteLine.applyJustificationColor = "slds-theme_error slds-text-color_default";
            }//added for enhancement
            let tempMap = {};
            tempMap = this.actualQuoteLineMap;
            tempMap[lastQuoteLine.Id] = lastQuoteLine;
            this.actualQuoteLineMap = tempMap;
            this.items.push(lastQuoteLine);
            this.updateDraftValues(lastQuoteLine);
            this.updateDraftValues(lastQuoteLine);
            this.count = this.count + 1;
        }
        this.totalRecountCount = this.items.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.endingRecord = this.totalRecountCount;
        this.page = this.totalPage;
        this.showLastPage(this.page);
        const selectEvent = new CustomEvent('addnewquoteline', {
            detail: this.draftValues
        });
        this.dispatchEvent(selectEvent);
        }) 
        .catch(error=>{  
            this.showSpinner = false;
            this.showToast('Error Loading QuoteLines',JSON.stringify(error),'error');
        })
    }
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [];
        for (let index = 0; index < this.draftValues.length; index++) {
            copyDraftValues.push(this.draftValues[index]);
        }
        var distyMargin;
        var brokenCost;
        var suggestedResale;
    
        for (let index = 0; index < copyDraftValues.length; index++) {
            let item = copyDraftValues[index];
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                    item[field] = updateItem[field];
                    if (field != 'core_cpq_action_txt__c' && field != 'core_cpq_altera_reg_txt__c' && field != 'core_cpq_revision_request_category_nm__c' && field != 'core_cpq_revision_reason_txt__c') {
                        item['core_cpq_action_txt__c'] = 'Edit';
                    }
                    if (field == 'core_cpq_opn__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyOPNColor = "slds-theme_default slds-text-color_default";
                        } else {
                            updateItem.applyOPNColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'SBQQ__Quantity__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyQuantityColor = "slds-theme_default slds-text-color_default";
                        } else {
                            updateItem.applyQuantityColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'core_cpq_years_nbr__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyYearsColor = "slds-theme_default slds-text-color_default";
                        } else {
                            updateItem.applyYearsColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'core_cpq_production_dt__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyProdDateColor = "slds-theme_default slds-text-color_default";
                        } else {
                            updateItem.applyProdDateColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    if (field == 'price_requested_resale_amt__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyrequestedresaleColor = "slds-theme_default slds-text-color_default";
                        } else {
                            updateItem.applyrequestedresaleColor = "slds-theme_error slds-text-color_default";
                        }
                    }
                    //Change made by Tejaswini/Himanshu - TWC3133-4919
                    if (field == 'core_cpq_justification_txt__c') {
                        if (updateItem[field] != null && updateItem[field] != undefined && updateItem[field] != '') {
                            updateItem.applyJustificationColor = "slds-theme_default slds-text-color_default";
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
                draftValueChanged = true;
            }
        }
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            var updateItem1={};
            for(let field in updateItem){
                updateItem1[field]=updateItem[field];
            }
            this.draftValues = [...copyDraftValues, updateItem1];
        }
        this.quoteLineList.forEach(function(quoteLine) {
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
        this.items.forEach(function(quoteLine) {
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
    }

    picklistChanged(event){
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
        this.updateDraftValues(updatedItem);
        this.updateDraftValues(updatedItem);
        const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
        this.dispatchEvent(selectEvent);
    }

    handleSelection(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.key, ParentId: dataRecieved.selectedId };
        this.updateDraftValues(updatedItem);
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
        this.updateDraftValues(event.detail.draftValues[0]);
        const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
        this.dispatchEvent(selectEvent);
    }
    //added for DPA
    handleDPASave(quoteMap,status,quoteType) {
        this.showSpinner = true;
       this.oldQuoteLineList = [];
       const instance = this;
       const filterMap = new Map(Object.entries(this.actualQuoteLineMap));
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

            if(this.oldQuoteLineList.length!=0){
                if(changeFlagCheck==false && parentQuoteFlagCheck==false){
                    if(ismancheck==false){
                        createDPA({oldQuoteLineList : this.oldQuoteLineList,quoteLineMap : this.actualQuoteLineMap,quoteMap : quoteMap})  
                        .then(result=>{ 

                        
                                this.draftValues = [];
                                this.connectedCallback();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'DPA Request Sent Successfully',
                                    variant: 'success'
                                })
                            );
                            this.navigateToALNDetail(result);
                            this.showSpinner=false;
                        })  
                        .catch(error=>{  
                            this.showToast('Error Requesting DPA',reduceErrors(error).join(","),'error');
                            this.showSpinner=false;
                        }) 
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

    }
        //**** */
    //added for ALN
    handleALNSave(quoteMap,status,quoteType) {
        this.showSpinner = true;
        this.oldQuoteLineList = [];
        const instance = this;
        const filterMap = new Map(Object.entries(this.actualQuoteLineMap));
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
                        createALN({oldQuoteLineList : this.oldQuoteLineList,quoteLineMap : this.actualQuoteLineMap,quoteMap : quoteMap})  
                            .then(result=>{ 
                                    this.draftValues = [];
                                    
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
                                this.showToast('Error requesting ALN',reduceErrors(error).join(",") ,'error');
                                this.showSpinner=false;
                            })
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

    }
    //**** */    
    handleSave(quoteMap,status) {
        this.showSpinner = true;
        for (let index = 0; index < this.draftValues.length; index++) {
            this.draftValues[index].SBQQ__Quote__c = this.recordId;
        }
        this.updateQuoteLines(quoteMap,status);
    }

    handleCancel(event) {
        this.draftValues = [];
    }
    
    fetchQuoteLineDetails(){
        this.showSpinner = true;
        getAllQuoteLines({quoteId: this.recordId})  
        .then(result=>{ 
        this.showSpinner = false; 
        this.qlList=[];
        this.quoteList = JSON.parse(JSON.stringify(result.quoteList));
        
        if(this.quoteList != null && this.quoteList.length > 0){
            this.status = this.quoteList[0].core_cpq_distystatus_txt__c;
        }
        if(this.recordId == null || (this.status != null && (this.status =='Draft' || this.status =='New' || this.status =='Pending'))){
            this.isEditable = true;
        } 

        this.setDataTableColumns();
        if(this.recordId == null || (this.status != null && (this.status =='Draft' || this.status =='New'))){
            this.columns = this.distyColumns;
        }else if((this.status =='Pending' || this.inProgressQuote == true) && (this.pendingvisblity == false)){
            this.columns = this.distyPendingColumns;
        }else if((this.status == 'In Progress' || this.status == 'Approved' || this.status == 'Rejected' || this.status == 'Cancelled') && this.requestDPAFlag == false && this.requestALNFlag == false && this.isCpQuote == false){//added for DPA
            this.columns = this.distyReadOnlyPendingColumns;
        }
        else if(this.pendingvisblity == true && this.status =='Pending'){//added for pending visiblity
            this.columns = this.distyReadOnlyPendingColumns;
        }
        else if(this.isCpQuote==true){//added for DPA
            this.columns = this.distyCPColumns;
        }else if(this.status == 'Approved' && this.requestDPAFlag == true && this.requestALNFlag == false){
            this.columns = this.distyDPAColumns;
        }else if(this.status == 'Approved' && this.requestDPAFlag == false && this.requestALNFlag == true){
            this.columns = this.distyALNColumns;
        }
        this.quoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        this.oldQuoteLineList = JSON.parse(JSON.stringify(result.quoteLineList));
        var myMap = {};
        var myMap2 = new Map();
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
            if(quoteLine.core_cpq_justification_txt__c == null || quoteLine.core_cpq_justification_txt__c == undefined || quoteLine.core_cpq_justification_txt__c == ''){
                quoteLine.applyJustificationColor = "slds-theme_error slds-text-color_default";
            }
            myMap[quoteLine.Id] = quoteLine;
            myMap2.set(quoteLine.Id,{ ...quoteLine });
        });
        if(emptyQuoteLines == true){
            this.draftValues = this.quoteLineList;

            const selectEvent = new CustomEvent('addnewquoteline', {detail: this.draftValues});
            this.dispatchEvent(selectEvent);
        }
        this.quoteLineMap = myMap;
        this.actualQuoteLineMap = myMap;
        this.oldQuoteLineMap = myMap2;
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
    }

    deleteRecord(deleteRecordId){
        let index = 0;
        let recordIndex = 0;
        let isNewRecordDeletion = false;

        let removeFromQuoteLineList = false;
        let removeFromItems = false;
        let removeFromDraftList = false;
        this.quoteLineList.forEach (function (eachItem) {
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(eachItemId == deleteRecordIdStr){
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
            if(eachItemId == deleteRecordIdStr){
                itemsRecordIndex = itemsIndex;
                removeFromItems = true;
            }
            itemsIndex = itemsIndex + 1;
        }); 

        let draftItemsIndex = 0;
        let draftItemsRecordIndex = 0;
        this.draftValues.forEach (function (eachItem) {
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(eachItemId == deleteRecordIdStr){
                draftItemsRecordIndex = draftItemsIndex;
                removeFromDraftList = true;
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
        this.totalRecountCount = this.items.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.displayRecordPerPage(this.page);
        if(quoteLine.Id != null){
            delete this.actualQuoteLineMap[quoteLine.Id];
        }
        if(isNewRecordDeletion == false){
            deleteRecord({recordId: deleteRecordId})  
            .then(result=>{ 
                this.showSpinner=false;
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
    }
    updateQuoteLines(quoteMap,status){
        if(this.isDistiPortal == false || this.inProgressQuote == false){
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
                console.log('error 1');
                this.showToast('Error in Updating Record',JSON.stringify(error),'error');
            }) 
        }else{
            let selectedQuoteLineList = [];
            let oldMap = this.oldQuoteLineMap;
            this.oldQuoteLineList = this.template.querySelector('c-psg_customized-data-table').draftValues;
            this.oldQuoteLineList.forEach(function(quoteLine){
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
            this.showSpinner=false;
        }
    }
    cloneRecord(cloneRecordId){
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
    }
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
                    this.cloneRecord(row.Id);
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
                concat = concat.toLowerCase()+''+index;

                if(concat.includes(this.selectedValue.toLowerCase())){
                    this.isDataAvailable = true;
                    this.dataReturn.push(currentList[index]);
                }
                concat=null;
            }
            if(this.dataReturn.length <= 0){
                this.isDataAvailable = false;
            }
            
        }else{
            this.connectedCallback();
            this.resetPagination();
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
        event.preventDefault(); 
        const fields = event.detail.fields;
        fields.RecordTypeId  = this.recordTypeId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.isModal2Open = false;
        this.showSpinner = true;
    }
     handleSuccess(event){
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
        });
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