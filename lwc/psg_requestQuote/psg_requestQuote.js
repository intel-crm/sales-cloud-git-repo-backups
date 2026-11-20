import { LightningElement,api,track,wire } from 'lwc';
import { getObjectInfo,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import QUOTE_OBJECT from '@salesforce/schema/SBQQ__Quote__c';
//import  getUserInformation from '@salesforce/apex/PSG_Utility.getUserInformation';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
//import ACCOUNT_NAMEEEEE from '@salesforce/schema/USER.Account.Name';
//import UsrRoleName from '@salesforce/schema/User.Account.Name';
//import UsrId from '@salesforce/user/Id';
//import setStartDate from '@salesforce/apex/PSG_RequestDPA.setStartDate';//added for DPA,ALN
import { refreshApex } from '@salesforce/apex';


const FIELDS = ['SBQQ__Quote__c.core_cpq_navigate_to_iqr__c','SBQQ__Quote__c.Name', 'SBQQ__Quote__c.SBQQ__Status__c','SBQQ__Quote__c.core_cpq_distystatus_txt__c' ,'SBQQ__Quote__c.core_cpq_quote_type_nm__c','SBQQ__Quote__c.core_cpq_end_customer_nm__r.Name','SBQQ__Quote__c.core_cpq_active_cb__c','SBQQ__Quote__c.core_cpq_distributor_disty_view_nm__c'];
//const currentDistributor;
export default class psg_requestQuote extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;
    @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT }) objectInfo;
    @track radiobuttonvalue = '';
    get radiooptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    
    @api recordId;
    @track quoteObjRec;
    @api isEditMode = false;
    @track disableSave=true;
    @track isSubmitted=false;
    @track isResubmitted=false;
    @track isPending=false;
    @track isDraft = false;
    @track lockRecord=false;
    @track lockPartialRecord = false;
    @track inProgressQuote = false;
    @track requestButtonLabel;
    @track requestUpdateAction = false;
    @track isCpQuote= false;
   // @track nameField = ACCOUNT_NAME;
    @track enableDPARequest = false;//added for DPA
    @track requestDPAFlag = false;//added for DPA
    @track enableALNRequest = false;//added for ALN
    @track requestALNFlag = false;//added for ALN
    @api distributorName;
    @track pendingvisblity=false;
    @track enableSaveCancel = false;
    @track status;
    @track isNewStatus = false;
    @track isOPNValid = false;
    @track name='Quote Request';
    @track saveDataVar = false;
    @track submitDataVar = false;
    @track savePendingDataVar = false;
    @track submitPendingDataVar = false;
    @track enableRadioOption = false;
    @track showNewSearchOptions = false;
    @track attachmentEnable = false;
    @track showSpinner = false;
    @track radioButtonMsg = false;//added
    @track currentDistributor ;
    radioButtonValue = '';
    
    // Changes made for TWC3133-3750 - Bishal Singh
    @track relatedList = false;
    @track dpaalnRecords;
    @track dpaAlnColumn = [
        { label: 'CIS #', fieldName: 'core_cpq_cis__c' , type: 'button', typeAttributes: { label: { fieldName: 'core_cpq_cis__c'} , name: 'redirect_dpa_aln' , variant: 'base'}},
        { label: 'SAP#', fieldName: 'core_cpq_dpa_aln_no_nbr__c' },
        { label: 'Status', fieldName: 'core_cpq_status_txt__c' },
        { label: 'Request Type', fieldName: 'core_cpq_record_type_identifier__c' },
        { label: 'SAP End Customer', fieldName: 'core_cpq_sap_end_customer_nm__r' },
        { label: 'SAP Distributor', fieldName: 'core_cpq_sap_distributor__c' },
        { label: 'Ship Start Date', fieldName: 'core_cpq_ship_start_date_dt__c' },
        { label: 'Ship End Date', fieldName: 'core_cpq_ship_end_date_dt__c' }
    ];
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'DPA_ALNs__r',
        fields:  ['core_cpq_dpa_aln__c.Id','core_cpq_dpa_aln__c.core_cpq_dpa_aln_no_nbr__c', 'core_cpq_dpa_aln__c.core_cpq_cis__c', 'core_cpq_dpa_aln__c.core_cpq_status_txt__c', 'core_cpq_dpa_aln__c.core_cpq_record_type_identifier__c' , 
                   'core_cpq_dpa_aln__c.core_cpq_active_quote__r.Name','core_cpq_dpa_aln__c.core_cpq_sap_end_customer_nm__r.Name', 'core_cpq_dpa_aln__c.core_cpq_sap_distributor__c',
                   'core_cpq_dpa_aln__c.core_cpq_dpa_owner__c', 'core_cpq_dpa_aln__c.core_cpq_ship_start_date_dt__c', 'core_cpq_dpa_aln__c.core_cpq_ship_end_date_dt__c','core_cpq_dpa_aln__c.core_cpq_change_flag__c']
    })getDPAALNRecords({ error, data }) {
        if (data) {
            let tempRecords = [];
            data.records.forEach( obj => {
                let tempRecord = {};
                tempRecord.Id = obj.fields.Id.value;
                tempRecord.core_cpq_cis__c = obj.fields.core_cpq_cis__c.value;
                tempRecord.core_cpq_dpa_aln_no_nbr__c = obj.fields.core_cpq_dpa_aln_no_nbr__c.value;
                tempRecord.core_cpq_status_txt__c = obj.fields.core_cpq_status_txt__c.value;
				tempRecord.core_cpq_record_type_identifier__c = obj.fields.core_cpq_record_type_identifier__c.value;
				tempRecord.core_cpq_sap_end_customer_nm__r = obj.fields.core_cpq_sap_end_customer_nm__r.value;
				tempRecord.core_cpq_sap_distributor__c = obj.fields.core_cpq_sap_distributor__c.value;
				tempRecord.core_cpq_ship_start_date_dt__c = obj.fields.core_cpq_ship_start_date_dt__c.value;
				tempRecord.core_cpq_ship_end_date_dt__c = obj.fields.core_cpq_ship_end_date_dt__c.value;
                tempRecords.push( tempRecord );
            } );
            this.dpaalnRecords = tempRecords;
            if(this.dpaalnRecords != undefined && this.dpaalnRecords.length>0){
                this.relatedList=true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dpaalnRecords = undefined;
        }
    }

    @track typeOptions=[
        {label:'--None--',value:''},
        {label:'Budgetary',value:'Budgetary'},
        {label:'Design Win',value:'Design Win'},
        {label:'Tools',value:'Tools'}, 
        {label:'Transfer Pricing',value:'Transfer Pricing'}, 
        
    ];
    //added for DPA
    @track dpaQuoteColomns = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_distystatus_txt__c',editable:false},
        {fname:'core_cpq_quote_type_nm__c',editable:false},
        {fname:'core_cpq_quote_approved_date_dt__c',editable:false},
        {fname:'core_cpq_quote_created_date__c',editable:false},
        //added
        //{fname:'core_cpq_cm_name_disty_view_nm__c',editable:false},//not free text
      //  {fname:'core_cpq_cm_country__c',editable:false},
         //free text
         //free text

        {fname:'core_cpq_disty_name_for_dpa__c',editable:false},
        {fname:'core_cpq_disty_email_address_for_dpa__c',editable:false},
        {fname:'core_cpq_cm_name_disty_nm__c',editable:true},//remove comments
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        

        {fname:'core_cpq_cm_state_txt__c',editable:true},//remove comments
        
        {fname:'core_cpq_dpa_Comments__c',editable:true},
        {fname:'core_cpq_cm_country_disty_nm__c',editable:true},//remove comments
        //{fname:'core_cpq_cm_name_disty_nm__c',editable:true}, free text
        //{fname:'core_cpq_cm_country_disty_nm__c',editable:true}, free text
        
        
        //{fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        //{fname:'core_cpq_ultimate_quote_number_nbr',editable:false},//added
        
    ];
    //added for DPA
    @track dpaQuoteColomnsTranferPricing = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_distystatus_txt__c',editable:false},
        {fname:'core_cpq_quote_type_nm__c',editable:false},
        {fname:'core_cpq_quote_approved_date_dt__c',editable:false},
        {fname:'core_cpq_quote_created_date__c',editable:false},
        
        //{fname:'core_cpq_cm_name_disty_view_nm__c',editable:false},
     //   {fname:'core_cpq_cm_country__c',editable:false},
        {fname:'core_cpq_disty_name_for_dpa__c',editable:false},
        {fname:'core_cpq_disty_email_address_for_dpa__c',editable:false},
        //{fname:'CreatedDate',editable:false},
        {fname:'core_cpq_cm_name_disty_nm__c',editable:true},//remove comments
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        
        
        {fname:'core_cpq_cm_state_txt__c',editable:true},//remove comments
        //{fname:'core_cpq_cm_name_disty_nm__c',editable:true},//remove comments
        {fname:'core_cpq_dpa_Comments__c',editable:true},//remove comments
        
        
        {fname:'core_cpq_cm_country_disty_nm__c',editable:true},
       // {fname:'core_cpq_cm_name_disty_nm__c',editable:true}, free text
       // {fname:'core_cpq_cm_country_disty_nm__c',editable:true}, free text
        
        
        //{fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        //{fname:'core_cpq_ultimate_quote_number_nbr',editable:false},//added
        
    ];

    //added for ALN
    @track alnQuoteColomns = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_distystatus_txt__c',editable:false},
        {fname:'core_cpq_quote_type_nm__c',editable:false},
        {fname:'core_cpq_quote_approved_date_dt__c',editable:false},
        {fname:'core_cpq_quote_created_date__c',editable:false},
      
        //{fname:'core_cpq_quote_approved_date_dt__c',editable:false},
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        //{fname:'core_cpq_disty_name_for_dpa__c',editable:false},
        {fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        //{fname:'core_cpq_disty_email_address_for_dpa__c',editable:false},
        //{fname:'core_cpq_quote_created_date__c',editable:false},
       
        /*{fname:'core_cpq_cm_name_disty_view_nm__c',editable:false},
        {fname:'core_cpq_cm_country__c',editable:false},*/
        {fname:'core_cpq_final_ship_to_customer_dpa__c',editable:true},
        {fname:'core_cpq_final_ship_to_country__c',editable:true},
        
        /*{fname:'core_cpq_ship_start_date_disty_view__c',editable:true},
        {fname:'core_cpq_ship_end_date_disty_view__c',editable:true},
        
        {fname:'core_cpq_duration_disty_view__c',editable:true},//added*/
        {fname:'core_cpq_dpa_Comments__c',editable:true},
        
    ];
    @track quoteLink;
    @track quotecoloumsCP = [
        {fname:'Name', editable:false},

        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_parent_account__c',editable:false},
        {fname:'core_cpq_active_cb__c',editable : false},
        {fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        {fname:'core_cpq_ec_country__c',editable:false},
        {fname:'SBQQ__Status__c',editable:false},
        {fname:'core_cpq_business_unit_nm__c',editable:false},
        {fname:'core_cpq_quote_type_nm__c',editable:false},
    
        //Seibel fields
        {fname:'core_cpq_siebel_quote_no_txt__c',editable:false},
        {fname:'core_cpq_siebel_rfq_num_txt__c',editable:false},
        {fname:'core_cpq_owner_disty_txt__c',editable:false},
        {fname:'core_cpq_ultimate_quote_number_nbr__c',editable:false},
    ];
    //Only for Drafat Status
    // for Draft its LockRecord and for New/Pending its LockPartialRecord
    // for InProgress/Approved (LockRecord == false && LockPartialRecord == false)
    @track quoteColumns = [

        {fname:'core_cpq_end_customer_disty_nm__c',required:true},
        {fname:'core_cpq_cm_name_disty_nm__c',required:false},

        {fname:'Pricing_Project_Name_Nm__c',required:false},
        {fname:'core_cpq_cm_state_txt__c',required:false},

        {fname:'core_cpq_end_customer_city_disty_nm__c',required:true},
        {fname:'core_cpq_cm_city_disty_nm__c',required:false},

        {fname:'core_cpq_end_customer_country_disty_nm__c',required:true},
        {fname:'core_cpq_cm_country_disty_nm__c',required:false},

        {fname:'core_cpq_end_customer_state_disty_txt__c',required:true},
        {fname:'core_cpq_business_unit_nm__c',required:true},

        {fname:'core_cpq_owner_disty_txt__c',required:false}, 
        {fname:'core_cpq_comments_to_disty_txt__c',editable:false},

        
        {fname:'SBQQ__Status__c',editable:false,required:false},
        {fname:'core_cpq_comments_by_disty_txt__c',editable:true},

        {fname:'core_cpq_quote_type_nm__c',required:true,override:true},
    ];
    //for New , Pending , In Progress Status
    @track quoteColumnsLocked = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_parent_account__c',editable:false},
        {fname:'core_cpq_ultimate_quote_number_nbr__c',editable:false},
        {fname:'core_cpq_opportunity_disty_view_nm__c',editable:false},
        {fname:'core_cpq_siebel_quote_no_txt__c',editable:false},
        {fname:'core_cpq_siebel_rfq_num_txt__c',editable:false},
        {fname:'core_cpq_active_cb__c',editable:false},
        {fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        {fname:'core_cpq_requestor_disty_view_nm__c',editable:false},
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        {fname:'core_cpq_cm_name_disty_view_nm__c',editable:false},
        {fname:'core_cpq_ec_country__c',editable:false},
        {fname:'core_cpq_cm_country__c',editable:false},
        {fname:'SBQQ__Status__c',editable:false},
        {fname:'Pricing_Project_Name_Nm__c',editable:true,required:false}, 
        {fname:'core_cpq_business_unit_nm__c',editable:true,required:true},
        {fname:'core_cpq_quote_type_nm__c',editable:false,override:true,required:true},
        {fname:'core_cpq_owner_disty_txt__c',editable:false,required:false},
        //{fname:'SBQQ__Opportunity2__c',editable:false},
        {fname:'core_cpq_change_revision_requested__c',editable:false},
		{fname:'core_cpq_comments_to_disty_txt__c',editable:false},
        //{fname:'core_cpq_end_customer_nm__c',editable:false},
        
    ];

    @track inprogressRevisionColumns = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_parent_account__c',editable:false},
        {fname:'core_cpq_ultimate_quote_number_nbr__c',editable:false},
        {fname:'core_cpq_opportunity_disty_view_nm__c',editable:false},
        {fname:'core_cpq_siebel_quote_no_txt__c',editable:false},
        {fname:'core_cpq_siebel_rfq_num_txt__c',editable:false},
        {fname:'core_cpq_active_cb__c',editable:true},
        {fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        {fname:'core_cpq_change_revision_requested__c',editable:false},
        
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        {fname:'core_cpq_ec_country__c',editable:false},
        {fname:'core_cpq_cm_name_disty_view_nm__c',editable:false},
        {fname:'core_cpq_cm_country__c',editable:false},
        {fname:'SBQQ__Status__c',editable:false},
        {fname:'core_cpq_quote_type_nm__c',editable:false,override:true,required:true},
        {fname:'core_cpq_business_unit_nm__c',editable:true,required:true}, 
        {fname:'Pricing_Project_Name_Nm__c',editable:true,required:false}, 
        {fname:'core_cpq_requestor_disty_view_nm__c',editable:false},
        {fname:'core_cpq_owner_disty_txt__c',editable:false,required:false},
	    {fname:'core_cpq_comments_to_disty_txt__c',editable:false},
        
    ]; 
    @track DistyFields = [ 
        {fname:'core_cpq_end_customer_disty_nm__c',editable:true,required:true},
        {fname:'core_cpq_cm_name_disty_nm__c',editable:true,required:false},
        {fname:'core_cpq_end_customer_city_disty_nm__c',editable:true,required:true},
        {fname:'core_cpq_cm_city_disty_nm__c',editable:true,required:false},
        {fname:'core_cpq_end_customer_country_disty_nm__c',editable:true,required:true},
        {fname:'core_cpq_cm_country_disty_nm__c',editable:true,required:false},
		{fname:'core_cpq_end_customer_state_disty_txt__c',editable:true,required:true},
        {fname:'core_cpq_cm_state_txt__c',editable:true,required:false},
        {fname:'core_cpq_comments_by_disty_txt__c',editable:true}
        
    ];
    @track DistyApprovedRevisionFields=[
        {fname:'core_cpq_end_customer_disty_nm__c',editable:false,required:true},
        {fname:'core_cpq_cm_name_disty_nm__c',editable:false,required:false},
        {fname:'core_cpq_end_customer_city_disty_nm__c',editable:false,required:true},
        {fname:'core_cpq_cm_city_disty_nm__c',editable:false,required:false},
        {fname:'core_cpq_end_customer_country_disty_nm__c',editable:false,required:true},
        {fname:'core_cpq_cm_country_disty_nm__c',editable:false,required:false},
		{fname:'core_cpq_end_customer_state_disty_txt__c',editable:false,required:true},
        {fname:'core_cpq_cm_state_txt__c',editable:false,required:false},
        {fname:'core_cpq_comments_by_disty_txt__c',editable:false}

    ];

    @track quoteColumnsLockedOriginal = this.quoteColumnsLocked;
    @track approvedRevisionColumns = [
        {fname:'Name', editable:false},
        {fname:'core_cpq_revision_nbr__c',editable:false},
        {fname:'core_cpq_parent_account__c',editable:false},
        {fname:'core_cpq_ultimate_quote_number_nbr__c',editable:false},
        {fname:'core_cpq_opportunity_disty_view_nm__c',editable:false},
        {fname:'core_cpq_siebel_quote_no_txt__c',editable:false},
        {fname:'core_cpq_siebel_rfq_num_txt__c',editable:false},
        {fname:'core_cpq_active_cb__c',editable:false},
        //{fname:'core_cpq_distributor_disty_view_nm__c',editable:false},
        
        {fname:'core_cpq_requestor_disty_view_nm__c',editable:false},
        {fname:'core_cpq_end_customer_disty_view_nm__c',editable:false},
        {fname:'core_cpq_ec_country__c',editable:false},
        {fname:'core_cpq_cm_name_disty_view_nm__c',editable:false},
        {fname:'core_cpq_cm_country__c',editable:false},
       
        {fname:'SBQQ__Status__c',editable:false},
        
        {fname:'Pricing_Project_Name_Nm__c',editable:false,required:false}, 

        {fname:'core_cpq_quote_type_nm__c',editable:true,override:true,required:true},

        {fname:'core_cpq_owner_disty_txt__c',editable:false,required:false},
        //{fname:'SBQQ__Opportunity2__c',editable:false},
       
        {fname:'core_cpq_change_revision_requested__c',editable:false},
		{fname:'core_cpq_comments_to_disty_txt__c',editable:false},
        //{fname:'core_cpq_end_customer_nm__c',editable:false},
        
    ];
    @track unapprovedRevisionColumns = [
        {fname:'core_cpq_business_unit_nm__c',editable:true},
        {fname:'core_cpq_quote_type_nm__c',editable:true,override:true},
        {fname:'core_cpq_account_name_nm__c',editable:true},
        //opportunity missing
        {fname:'core_cpq_volume_nbr__c',editable:true},
        {fname:'core_cpq_first_ship_date_dt__c',editable:true},
        {fname:'core_cpq_production_end_date_dt__c',editable:true},
        {fname:'core_cpq_segment_nm__c',editable:true},
    ];
    //Accordion Sections
    @track activeSections = ['quoteDetails','notes','quoteLines']; 
    

    //Quote Details Section
    @track quoteRec = {
        sobjectType: 'SBQQ__Quote__c',
        //SBQQ__Status__c:'Draft',
        core_cpq_quote_type_nm__c:''
    };
    
    @track sentToOptions=[
        { label: 'EMEA', value: 'EMEA' },
        { label: 'Test Queue', value: 'Test' }
    ];

    //Attachments Sections
    @track attachmentList = [];
    
    //@track CreatorNameVal;
    //Quote Line Section
    @track qlRecList=[];
    @track qlEditList=[];
    @track validGroupMember=false;
    /*@wire(getUserInformation, {})
    getUserInformation({error,data}){
        if(data){
            //this.result=data;
            this.currentDistributor=data.Account.Name;
            console.log('DistyName'+this.currentDistributor);
           // console.log("This is data"+data.Id)
        }
        if(error){
           // console.log(error);
        }
    }*/
    
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS , currentDistributor:'$currentDistributor'})
    wiredRecord({ error, data }) {
        if (data) {
            
            this.quoteObjRec = data;
            this.quoteLink = this.quoteObjRec.fields.core_cpq_navigate_to_iqr__c.value;
            this.name = this.quoteObjRec.fields.Name.value;
            //console.log('name55555 '+JSON.stringify(this.name));
            //this.status = this.quoteObjRec.fields.SBQQ__Status__c.value;
            this.status = this.quoteObjRec.fields.core_cpq_distystatus_txt__c.value;
            let isActive = this.quoteObjRec.fields.core_cpq_active_cb__c.value;
            this.quoteType = this.quoteObjRec.fields.core_cpq_quote_type_nm__c.value;//added for DPA
            this.distributorName=this.quoteObjRec.fields.core_cpq_distributor_disty_view_nm__c.value;
            
            console.log('status2222222 '+this.status);
             console.log('Distributor '+this.distributorName);
             console.log('DistributorCurrent '+this.currentDistributor);
            this.quoteRec.core_cpq_quote_type_nm__c = this.quoteObjRec.fields.core_cpq_quote_type_nm__c.value;
            //console.log('EndCustomerName'+this.quoteObjRec.fields.core_cpq_end_customer_nm__r.value.fields.Name.value);
            if((this.currentDistributor != undefined)){
                
                if(this.status == 'Draft' || this.status == 'New' || this.status == 'Pending'){
                    this.attachmentEnable = false;
                }else{
                    this.attachmentEnable = true;
                }
                if(this.status != 'Draft' && this.status != 'New'){
                    this.lockRecord = true;
                    console.log('record locked1');
                }
                //added for disty visiblity
                if((this.status == 'In Progress' || this.status == 'Approved' || this.status == 'Rejected' || this.status == 'Cancelled') && isActive && (this.currentDistributor===this.distributorName || this.validGroupMember == true)){
                    console.log('In Progress or Approved');
                    this.inProgressQuote=true;
                }    
                
                if(this.status == 'In Progress'){
                    console.log('In Progress');
                    this.requestButtonLabel = 'Request to Update';
                }
                if((this.status == 'Approved' || this.status == 'Rejected' || this.status == 'Cancelled')){
                    this.requestButtonLabel = 'Request for Revision'
                }
                if(this.quoteType== 'Contract Pricing' && !(this.quoteType == 'Budgetary' || this.quoteType == 'Tools' || this.quoteType=='Design Win' || this.quoteType=='Transfer Pricing' )){
                    this.isCpQuote=true;
                    this.attachmentEnable = true;
                    this.quoteColumnsLocked=this.quotecoloumsCP;
                    this.quoteColumnsLockedOriginal=this.quotecoloumsCP;
                }
                // Changes made for TWC3133-3750 - Bishal Singh
                
                //added for DPA
                if(this.status == 'Approved' && !(this.quoteType == 'Budgetary')){
                    this.enableDPARequest = true;
                    console.log('in status approved DPA');
                }
                //added for ALN
                if(this.status == 'Approved' && !(this.quoteType == 'Budgetary')){
                    this.enableALNRequest = true;
                    console.log('in status approved ALN');
                }
                if(this.status == 'Pending' && (this.currentDistributor===this.distributorName || this.validGroupMember == true )){
                    console.log('For pending inactive11');
                    this.lockPartialRecord = true;
                    this.pendingvisblity=false;
                // this.lockRecord = false;
                }
                if(this.status == 'Draft'){
                    this.isDraft = true;
                }
                if(this.status == 'New'/* || this.status == 'Pending'*/){
                    this.isNewStatus = true;
                }
                if(this.isNewStatus == true || this.inProgressQuote == true || this.isDraft == true){
                    this.showNewSearchOptions = true;
                }
                //added for disty pending visiblity
                if((this.currentDistributor!==this.distributorName && this.validGroupMember != true) && (this.status=='Pending')){
                    console.log('In pending one');
                    this.pendingvisblity=true;
                    //this.inProgressQuote=false;
                    this.lockRecord = true;
                    this.attachmentEnable = true;
                    this.lockPartialRecord = false;

                }else if((this.currentDistributor!==this.distributorName && this.validGroupMember != true) && (this.status=='Draft' ||this.status=='New' )){
                    /*this.pendingvisblity=true;
                    this.lockRecord = false;
                    this.attachmentEnable = true;
                    console.log('In draft/New one');*/
                    this.pendingvisblity=true;
                    console.log('In draft/New one')
                    //this.inProgressQuote=false;
                    this.lockRecord = false;
                    this.attachmentEnable = true;
                    this.lockPartialRecord = false;
                }
            }
        }
    }
  
    

    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'PSG Quote - Submitted');
    }

    connectedCallback(){
        if(this.recordId != null && this.recordId != undefined){
            this.isEditMode=true;
            this.getQLData(this.recordId);
        } 
        
        
    }
    
    /*
    savequote(){
        this.isOPNValid = true;
        console.log('opn '+this.isOPNValid);
        if(this.savePendingDataVar == true){
            this.savePendingData();
        }else if(this.submitPendingDataVar == true){
            this.submitPendingData();
        }else if(this.submitDataVar == true){
            this.submitData();
        }else if(this.saveDataVar == true){
            this.saveData();
        }
        this.savePendingDataVar = false;
        this.submitPendingDataVar = false;
        this.submitDataVar = false;
        this.saveDataVar = false;
    }
    */
    

    handleOnLoad(){
        this.disableSave=false;
    }

    //Accordian section selection
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }
    handleChange(event){
        console.log('inside handle event');
        this.quoteRec[event.target.name] = event.detail.value;
        this.radiobuttonvalue = null;
        this.radioButtonMsg = false;//added
        if(event.detail.value == 'Design Win' && this.quoteType != 'Design Win'){//uncomment for bug fix
            this.enableRadioOption = true;
        }else{
            this.enableRadioOption = false;
        }
    }
    addnewquoteline(event){
        console.log('inside add new quoteline '+JSON.stringify(event.detail));
        //console.log('addnewquoteline requestquote '+JSON.stringify(event.detail));
        this.qlRecList = JSON.parse(JSON.stringify(event.detail));
    }
    submitPendingData(){
        this.submitPendingDataVar = true;
        var isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isValid = isValid && element.reportValidity();
        });
        this.template.querySelectorAll('.customInput').forEach(element => {
            isValid = isValid && element.reportValidity();
        });
        this.template.querySelectorAll('lightning-radio-group').forEach(element => {
            isValid = isValid && element.reportValidity();
        });
            
        if (isValid) {
            console.log('Inside validate');
            this.isResubmitted=true;
            this.saveData();
        }
        else{
            this.showToast('Required Fields Missing','Please fill all the required Data','error');
        }
    }

    savePendingData(){
        this.savePendingDataVar = true;
        this.isPending=true;
        this.saveData();
    }

    submitData(){
        this.submitDataVar = true;
        var isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isValid = isValid && element.reportValidity();
        });
        this.template.querySelectorAll('.customInput').forEach(element => {
            isValid = isValid && element.reportValidity();
        });
        this.template.querySelectorAll('lightning-radio-group').forEach(element => {
            isValid = isValid && element.reportValidity();
        });
        if (isValid) {
            this.isSubmitted=true;
            this.saveData();
        }
        else{
            this.showToast('Required Fields Missing','Please fill in all the mandatory fields','error');
        }
    }

    
    handleRadioSelection(event){
        this.radiobuttonvalue = event.detail.value;
        this.radiobuttonvalue = tempValue;
        if(this.radiobuttonvalue == 'No'){
            this.radioButtonMsg = true;
            //this.showToast('Info','create a Budgetary Quote prior to requesting for a Design Win Quote','warning');
        }else{
            this.radioButtonMsg = false;
        }
        console.log('radioButtonMsgoo'+radioButtonMsg);
    }
   
    cancelEdit(){
        this.navigateToHomePage();
    }
    requestUpdate(){  
        this.showSpinner = true;     
        this.requestUpdateAction = true;
        this.inProgressQuote = false;
        this.enableSaveCancel = true;
        //this.lockRecord = false;

        var requestUpdateColumns = [
            {fname:'SBQQ__Distributor__c',required:true},
            {fname:'core_cpq_quote_owner_name__c',required:true},
            {fname:'Pricing_Created_Date__c',required:true},
            {fname:'SBQQ__Account__c',required:true},
            {fname:'core_cpq_contract_manufacturer_nm__c',required:true},
            {fname:'core_cpq_cm_country_nm__c',required:true}
        ];
            //this.quoteColumnsLocked = this.quoteColumnsLocked.concat(requestUpdateColumns);
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').opencolumnsupdaterequest();
        console.log('request update status'+this.status);
        if(this.status == 'Approved' || this.status == 'Rejected' || this.status == 'Cancelled'){
            this.quoteColumnsLocked = this.approvedRevisionColumns;
            this.DistyFields = this.DistyApprovedRevisionFields;
        }else{
            this.quoteColumnsLocked = this.inprogressRevisionColumns;
        }
        this.showSpinner = false;
        console.log('request update');
    }
    //added for DPA
    requestDPAAction(){  
        this.showSpinner = true;     
        this.requestUpdateAction = true;
        this.inProgressQuote = false;
        this.enableSaveCancel = true;
        this.requestDPAFlag = true;
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').opencolumnsDPArequest();//added for DPA
        if(this.status == 'Approved' && !(this.quoteType == 'Transfer Pricing')){
            this.quoteColumnsLocked = this.dpaQuoteColomns;
            //this.sosFields =[];//added for DPA
        }else if(this.status == 'Approved' && (this.quoteType == 'Transfer Pricing')){
            this.quoteColumnsLocked = this.dpaQuoteColomnsTranferPricing;
        }
        
        this.showSpinner = false;
        console.log('request update DPA');
        
    }
    //added for ALN
    requestALNAction(){  
        this.showSpinner = true; 
        /*var quote = this.quoteRec;
        var quoteMap = {};
        if(this.isEditMode){
            quote.Id = this.recordId;
            quoteMap[quote.Id] = quote;
        }
        var quoteData = this.template.querySelectorAll('lightning-input-field');
        quoteData.forEach(function(element){
            (quoteMap[quote.Id])[element.fieldName] = element.value;
        })
        console.log('ALNQmap'+JSON.stringify(this.quoteMap));
        console.log('QuoteALN'+JSON.stringify(this.quote));
        setStartDate({quoteMap : quoteMap})  
                .then(result=>{ 
                    const inputFields = this.template.querySelectorAll(
                        'lightning-input-field'
                    );
                 console.log('ipfields'+JSON.stringify(inputFields));
                   if (inputFields) {
                        inputFields.forEach(field => {
                            field.reset();
                        });
                    }
                    console.log('Success under setStartDate');
                   // window.location.reload()
                })  
                .catch(error=>{  

                    this.showToast('Error',JSON.stringify(error.body.message),'error');
                    console.log('Error in Updating Record '+JSON.stringify(error.body.message),'error');
                    this.showSpinner=false;
                }) */
               
        this.requestUpdateAction = true;
        this.inProgressQuote = false;
        this.enableSaveCancel = true;
        this.requestALNFlag = true;
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').opencolumnsDPArequest();//added for ALN
        if(this.status == 'Approved'){
            this.quoteColumnsLocked = this.alnQuoteColomns;
        }
        this.showSpinner = false;
        console.log('request update DPA');
    }
    cancelRequestUpdate(){
        this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        this.requestUpdateAction = false;
        this.inProgressQuote = true;
        this.enableSaveCancel = true;
        this.enableRadioOption = false;//added for radio button bug
        console.log('request update');
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').closeupdaterequest(quoteMap,this.status);
    }
    //added for DPA
    cancelDPARequestUpdate(){
        this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        this.requestUpdateAction = false;
        this.inProgressQuote = true;
        this.enableSaveCancel = true;
        console.log('request update');
        this.requestDPAFlag = false;
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').closeupdaterequest(quoteMap,this.status);
    }  
    //added for ALN
    cancelALNRequestUpdate(){
        this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        this.requestUpdateAction = false;
        this.inProgressQuote = true;
        this.enableSaveCancel = true;
        console.log('request update');
        this.requestALNFlag = false;
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').closeupdaterequest(quoteMap,this.status);
    }  
    sendRequestUpdate(){
        //this.requestUpdateAction = false;
        //this.inProgressQuote = true;
        //this.enableSaveCancel = true;
        //this.sendUpdateRequest = true;
        this.enableRadioOption = false;
        var quote = this.quoteRec;
        var quoteMap = {};
        if(this.isEditMode){
            quote.Id = this.recordId;
	    if(this.radiobuttonvalue != null){
                quote.core_cpq_confirmed_order__c = this.radiobuttonvalue;
            }
            quoteMap[quote.Id] = quote;
        }
        var quoteData = this.template.querySelectorAll('lightning-input-field');
        quoteData.forEach(function(element){
            (quoteMap[quote.Id])[element.fieldName] = element.value;
        })
        
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').sendupdaterequest(quoteMap,this.status);
       console.log('afterErrorApprove');
        //this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;//commented for col defect approved
        //added for col defect approved
        if(this.status == 'Approved' || this.status == 'Rejected' || this.status == 'Cancelled'){
            this.quoteColumnsLocked = this.approvedRevisionColumns;
        }else{
            this.quoteColumnsLocked = this.inprogressRevisionColumns;
        }
        
    }
    //added for DPA
    sendRequesDPAtUpdate(){
        //this.requestUpdateAction = false;
        //this.inProgressQuote = true;
        //this.enableSaveCancel = true;
        //this.sendUpdateRequest = true;
        this.enableRadioOption = false;
        var quote = this.quoteRec;
        var quoteMap = {};
        if(this.isEditMode){
            quote.Id = this.recordId;
            quoteMap[quote.Id] = quote;
        }
        var quoteData = this.template.querySelectorAll('lightning-input-field');
        quoteData.forEach(function(element){
            (quoteMap[quote.Id])[element.fieldName] = element.value;
        })

        
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').senddparequest(quoteMap,this.status,this.quoteType);//added for DPA
       // this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        /*this.requestDPAFlag = false;
        this.requestUpdateAction = false;
        this.inProgressQuote = true;*/
       // this.requestDPAFlag = false
       // this.requestUpdateAction = false;
       console.log('reqDPAinsidesedDPAreq'+this.requestDPAFlag);
       if(this.status == 'Approved' && !(this.quoteType == 'Transfer Pricing')&& this.requestDPAFlag == true){
        this.quoteColumnsLocked = this.dpaQuoteColomns;
        //this.sosFields =[];//added for DPA
        }else if(this.status == 'Approved' && (this.quoteType == 'Transfer Pricing'&& this.requestDPAFlag == true)){
            this.quoteColumnsLocked = this.dpaQuoteColomnsTranferPricing;
        }else{
            this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        }
        
    }

    //added for ALN
    sendRequestALNUpdate(){
        //this.requestUpdateAction = false;
        //this.inProgressQuote = true;
        //this.enableSaveCancel = true;
        //this.sendUpdateRequest = true;
        this.enableRadioOption = false;
        var quote = this.quoteRec;
        var quoteMap = {};
        if(this.isEditMode){
            quote.Id = this.recordId;
            quoteMap[quote.Id] = quote;
        }
        var quoteData = this.template.querySelectorAll('lightning-input-field');
        quoteData.forEach(function(element){
            (quoteMap[quote.Id])[element.fieldName] = element.value;
        })

        
        const returnValue = this.template.querySelector('c-psg_quote-line-detail').sendalnrequest(quoteMap,this.status,this.quoteType);//added for ALN

        console.log('reqDPAinsidesedDPAreq'+this.requestDPAFlag);
        if(this.status == 'Approved' && this.requestALNFlag == true){
            this.quoteColumnsLocked = this.alnQuoteColomns;
        }else{
            this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        }
        
    }    

    showToast(msgTitle,msg,type){
        console.log('In Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }
    handleCloseUpdateRequest(event){
        console.log('handleCloseUpdateRequest2');
        this.requestUpdateAction = false;
        this.inProgressQuote = true;
        if(this.requestDPAFlag == true){
            this.requestDPAFlag = false;//added for DPA
            this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        }
        if(this.requestALNFlag == true){
            this.requestALNFlag = false;//added for ALN
            this.quoteColumnsLocked = this.quoteColumnsLockedOriginal;
        }
        console.log('afterErrorApprovehandleCloseUpdateRequest');
    }
    //added for DPA
    
    handleCloseDpaRequest(event){
        console.log('handleCloseDPARequest2');
        this.requestUpdateAction = false;
        this.inProgressQuote = true;
        this.requestDPAFlag = false;
        this.requestALNFlag = false;
    }
    //Navigate to List View
    navigateToQuoteListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__Quote__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.quoteLink
            }
        });
    }
    navigateToLightningComponent() {
        this[NavigationMixin.Navigate]({
            "type": "standard__component",
            "attributes": {
                //Here customLabelExampleAura is name of lightning aura component
                //This aura component should implement lightning:isUrlAddressable
                "componentName": "c__psg_requestQuoteParent"
            }
        });
    }
    navigateToQuoteDetail(data) {
        console.log('entering navigate2222');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: data,
                objectApiName: 'SBQQ__Quote__c',
                actionName: 'view'
            }
        });
    }
    // Changes made for TWC3133-3750 - Bishal Singh
    navigateToDPAsALNsDetail(event) {
        switch(event.detail.action.name){
            case 'redirect_dpa_aln':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: event.detail.row.Id,
                        objectApiName: 'core_cpq_dpa_aln__c',
                        actionName: 'view'
                    }
                });
        }
        
    }

    //Navigate to home page
    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

}