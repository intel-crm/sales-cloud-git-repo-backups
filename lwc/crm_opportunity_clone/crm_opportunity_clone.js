import { LightningElement,wire,api,track } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import { CurrentPageReference,NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';

import cloneMainOpp from '@salesforce/apex/CRM_Opportunity_Clone_Controller.cloneMainOpp';
import getOppTeamMembers from '@salesforce/apex/CRM_Opportunity_Clone_Controller.getOppTeamMembers';
import continueClone from '@salesforce/apex/CRM_Opportunity_Clone_Controller.continueClone';
import testWrapper from '@salesforce/apex/CRM_Opportunity_Clone_Controller.testWrapper';



const fields = [NAME_FIELD];
const columns = [
    { label : 'Team Member', fieldName : 'Name'},                                           //0
    { label : "Access Level", fieldName : "OpportunityAccessLevel", type :"text"},          //1
    { label : "Member Role", fieldName : "TeamMemberRole", type :"text"},                   //2
    { label : "Team Member Region" , fieldName : "Core_Team_Member_Geo__c", type :"text"},  //3
    { label : "Status" , fieldName : "isActive", type :"text"}                              //4
    ];

const prodColumns = [
    { label :"Product Name", fieldName : "ProdName", type : "text", wrapText : true},                        
    { label :"Type", fieldName : "ProdType", type : "text"},                                
    { label :"Quantity", fieldName : "Qty",type : "number", typeAttributes : {minimumFractionDigits: '2'},
    cellAttributes: { alignment: 'left' }},                                 
    { label :"Total Price", fieldName : "TotalPrice", type : "currency", typeAttributes : {minimumFractionDigits: '2'},
    cellAttributes: { alignment: 'left' }},                       
    { label :"Product Status", fieldName : "ProdStatus", type : "text"},                    
    { label : "Status" , fieldName : "isActiveProd", type :"text"}                          
];

const partnerColumns = [
    { label :"Partner", fieldName : "PartnerName", type : "text"},
    { label :"Partner Role", fieldName : "PartnerRole", type : "text"},
    { label :"Partner Type", fieldName : "PartnerType", type : "text"},
    { label :"Partner Program", fieldName : "PartnerProgram", type : "text"},
    { label : "Status" , fieldName : "isActivePart", type :"text"} 
];

const oppDescFeaturesColumns = [
    { label : "Feature Type" , fieldName : "featType", type :"text"},
    { label : "Feature Name" , fieldName : "featName", type :"text"}, 
    { label : "Status" , fieldName : "featActive", type :"text"}  
];


export default class Crm_opportunity_clone extends NavigationMixin(LightningElement) {
    @api recordId;
    @api oppId;

    @track isLoading = false;

    @track oppName;
    @track cloneOppName;
   

    @track cloneDesDate;
    @track currentDate;
    @track minDate;
    @track oppMINDS;

    @track selectedDescFeat=true;
    @track selectedOppPartners=true;
    @track selectedOppProducts=true;
    @track selectedOppSolutions=true;
    @track selectedOppAttachments=true;
    @track selectedOppTeamMembers = false; //review

    @track activeSectionName;
    @track opportunityId;

    @track showOppFeatures;
    @track showOppPartner;
    @track showOpportunityProductOption;
    @track showOpportunitySolution;
    @track isAttachment = false;
    @track showAttachment = false;
    @track showNote = false;
    @track showContentlink= false;

    @track showInactiveOppFeatures;
    @track showInactiveOppPartner;
    @track showInactiveOppProduct;
    @track showInactiveOppTeam;

    @track inactiveTeamFirst =[];
    @track inactiveTeamLast = [];

    @track opptyID;

    @track showRelatedListSection;

    @track teamMembers=[];
    @track inactiveTeamMembers = [];
    @track inactiveProds = [];
    @track inactiveDescFeatures = [];
    @track inactivePartners = [];

    @track selectedRows=[];
    @track nonOwnerRows =[];

    
    @track nonOwnerIds=[];

    teamColumns = columns.slice(0,4);
    

    inactiveTeamFirst = columns.slice(0,1);
    inactiveTeamLast = columns.slice(-3);
    inactiveTeam = this.inactiveTeamFirst.concat(this.inactiveTeamLast);

    prodCoulmns=prodColumns;
    oppDescFeaturesColumns = oppDescFeaturesColumns;
    partnerColumns = partnerColumns;

    @track inactiveOppTeamList = [];
    @track inactiveOppFeaturesList = [];
    @track inactiveOppParnersList = [];
    @track inactiveOppProductList = [];

    @track sendBooleanValues;
    

    @wire(CurrentPageReference)
    currentPageRef;

    get oppId() {
        this.opptyID = this.currentPageRef.state.c__oppId;
        return this.currentPageRef.state.c__oppId;
    }

    @wire(getRecord, { recordId: "$oppId", fields: fields })
    wiredRecord({ error, data }){
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading opportunity',
                    message,
                    variant: 'error',
                }),
            );
        }
        else if (data){
            this.opportunity = data;
            this.oppName = this.opportunity.fields.Name.value;
            this.cloneOppName = this.oppName;
        }
    }
    @wire(getOppTeamMembers,{oppId : "$oppId"})
    wiredTeam(Result){
        if(Result.data){
            this.teamMembers=Result.data.map(row => ({ 
                Id : row.Id,
                Name: row.Name,
                OpportunityAccessLevel: row.OpportunityAccessLevel,
                TeamMemberRole: row.TeamMemberRole,
                Core_Team_Member_Geo__c : row.Core_Team_Member_Geo__c
            }));
            //this.teamMembers = Result.data;
            console.log('Team100 ----- '+this.teamMembers);
            console.log('101---'+JSON.stringify(this.teamMembers));
            this.selectedRows = this.teamMembers.filter(row => row.TeamMemberRole.includes('Owner')).map(row => row.Id);
        }
        else if(Result.error){
            console.log('Error in team member js');
        }
    }

    get selectedRows() {
        return this.teamMembers.filter(row => row.TeamMemberRole.includes('Owner')).map(row => row.Id);
    }

    handleRowSelection(event) {
        const selectedRowIds = event.detail.selectedRows.map(row => row.Id);
        const ownerRowIds = this.teamMembers.filter(row => row.TeamMemberRole.includes('Owner')).map(row => row.Id);
        console.log('114---'+this.selectedRows);
        
         this.selectedRows  = [
            ...selectedRowIds.filter(Id => !ownerRowIds.includes(Id)), // Non-owner rows
            ...ownerRowIds // Owner rows
        ];
        this.nonOwnerRows = [...selectedRowIds.filter(Id => !ownerRowIds.includes(Id))];

        if(this.nonOwnerRows.length > 0 && this.nonOwnerRows !== null && this.nonOwnerRows !== undefined){
            this.selectedOppTeamMembers = true;
        }
        else {
            this.selectedOppTeamMembers = false;
        }
        console.log('191---'+this.selectedRows );
        console.log('192---'+this.nonOwnerRows+' length = '+ this.nonOwnerRows.length+' '+this.selectedOppTeamMembers);
        
    }

    getRowClass(row) {
    return row.TeamMemberRole.includes('Owner') ? 'slds-table__row data-owner="true"' : '';
    }


       
     get options() {
        return [
            { label: 'No', value: 'No' },
            { label: 'Yes', value: 'Yes' },
        ];
    }
    handleOppName(event){
        this.cloneOppName = event.target.value;
    }
    handleDescDate(event){
        this.cloneDesDate = event.target.value;
    }
    handleMINDS(event){
        this.oppMINDS = event.detail.value;
    }

    handleDescSelected(event){
        this.selectedDescFeat = event.target.checked;
    }
    handleOppPartners(event){
        this.selectedOppPartners=event.target.checked;
    }
    handleOppProducts(event){
        this.selectedOppProducts=event.target.checked;
    }
    handleOppSolutions(event){
        this.selectedOppSolutions=event.target.checked;
    }
    handleOppAttachments(event){
        this.selectedOppAttachments = event.target.checked;
    }

     connectedCallback() {
        var result = this.getFormattedDate();
        this.currentDate = result.unformattedDate;
        this.minDate = result.formattedDate;
        this.fetchOpportunity();
        console.log('244 : Formatted date'+result.formattedDate+' Unformatted Date: '+result.unformattedDate);
        console.log('245-------'+this.currentDate);
        console.log('246---'+this.currentPageRef.state.c__oppId+' '+this.teamMembers);
        
        console.log('248---'+this.selectedRows);
        console.log('249 conncectedcallback---'+this.nonOwnerRows+' length = '+ this.nonOwnerRows.length+' '+this.selectedOppTeamMembers);
        

        
    }
    getFormattedDate() {
        const today = new Date();       
        const month = String(today.getMonth() + 1);
        const day = String(today.getDate());
        const year = today.getFullYear();

        const unformattedDate = `${month}/${day}/${year}`;
        const formattedDate = today.toISOString().split('T')[0];

        return{
            unformattedDate : unformattedDate,
            formattedDate : formattedDate
        };

        //return `${month}/${day}/${year}`;
    }

     fetchOpportunity(){
         cloneMainOpp({oppId : this.currentPageRef.state.c__oppId})
        .then((res) => {
            console.log('fetchopptyRes---'+JSON.stringify(res));
            console.log('217---'+res.showFlags.showOppFeatures);    
            this.showOppFeatures = res.showFlags.showOppFeatures;
            this.showOppPartner = res.showFlags.showOppPartner;
            this.showOpportunityProductOption = res.showFlags.showOpportunityProductOption;
            this.showOpportunitySolution = res.showFlags.showOpportunitySolution;
            this.isAttachment = res.showFlags.isAttachment;
            this.showAttachment = res.showFlags.showAttachment;
            this.showNote = res.showFlags.showNote;
            this.showContentlink = res.showFlags.showContentlink;
            console.log('267---'+this.showAttachment+' '+this.showNote+' '+this.showContentlink);
            if(this.showOppFeatures || this.showOppPartner || this.showOpportunityProductOption || this.showOpportunitySolution || this.isAttachment){
                this.showRelatedListSection = true;
            }
            this.showInactiveOppFeatures = res.showFlags.showInactiveOppFeatures;
            this.showInactiveOppPartner = res.showFlags.showInactiveOppPartner;
            this.showInactiveOppProduct=res.showFlags.showInactiveOppProduct;
            this.showInactiveOppTeam = res.showFlags.showInactiveOppTeam;
            this.activeSectionName  = ['A','B','C']; 

            this.inactiveOppTeamList = res.inactiveLists.inactiveOppTeam || [];
            this.inactiveOppFeaturesList = res.inactiveLists.inactiveOppDescFts || [];
            this.inactiveOppParnersList = res.inactiveLists.inactiveOppPartner || [];
            this.inactiveOppProductList = res.inactiveLists.inactiveOppProducts || [];

            this.inactiveTeamMembers = this.inactiveOppTeamList.map(row => ({
                Id : row.Id,
                Name : row.Name,
                TeamMemberRole: row.TeamMemberRole,
                Core_Team_Member_Geo__c : row.Core_Team_Member_Geo__c,
                isActive : 'Inactive'
            }));

            this.inactiveProds = this.inactiveOppProductList.map(row =>({
                Id : row.Id,
                ProdName : row.Name,
                ProdType : row.Core_Product_Type__c,
                Qty: row.Quantity,
                TotalPrice : row.TotalPrice,
                ProdStatus : row.Core_Status__c,
                isActiveProd : 'Inactive'
            }));

            this.inactiveDescFeatures = this.inactiveOppFeaturesList.map(row => ({
                Id : row.Id,
                featType : row.Core_Feature_Type__c,
                featName : row.Core_Feature_Name__c,
                featActive : 'Inactive'
            }));

            this.inactivePartners = this.inactiveOppParnersList.map(row=>({
                Id : row.Id,
                PartnerName: row.Core_Partner__r.Name,
                PartnerRole : row.Core_Partner_Role__c,
                PartnerType : row.Core_Partner_Type__c,
                PartnerProgram : row.Core_Partner_Program__c,
                isActivePart : row.Core_Partner__r.Core_Deactivated__c === true ? 'Inactive' : 'Active  ' 
            }));

            
            
            //this.sendToApex();


        })
        .catch(error=> {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                    } 
                else if (typeof error.body.message === 'string') {
                     message = error.body.message;
                     }
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading  data',
                    message,
                    variant: 'error',
                }),
                 );
                });
    }
       
    handleDate(){
        var res = this.getFormattedDate();
        this.cloneDesDate=res.formattedDate;
    }
    handleSaveDummy(){
        console.log('this.selectedOppAttachments---'+this.selectedOppAttachments+' this.selectedOppSolutions---'+this.selectedOppSolutions+
        ' this.selectedOppProducts---'+this.selectedOppProducts+' this.selectedOppPartners---'+this.selectedOppPartners+' this.selectedDescFeat---'+this.selectedDescFeat);
        this.sendBooleanValues = {
                showEntities : {
                    showOppFeatures : this.showOppFeatures,
                    showOppPartner : this.showOppPartner,
                    showOpportunityProductOption : this.showOpportunityProductOption,
                    showOpportunitySolution : this.showOpportunitySolution,
                    isAttachment : this.isAttachment,
                    showAttachment : this.showAttachment,
                    showNote : this.showNote,
                    showContentlink : this.showContentlink
                },
                showSelections : {
                    selectedOppAttachments : this.selectedOppAttachments,
                    selectedOppSolutions : this.selectedOppSolutions,
                    selectedOppProducts : this.selectedOppProducts,
                    selectedOppPartners : this.selectedOppPartners,
                    selectedDescFeat : this.selectedDescFeat,
                    selectedOppTeamMembers : this.selectedOppTeamMembers
                }
            };
            console.log('wrapper data ---'+JSON.stringify(this.sendBooleanValues.showSelections));
    }

handleExpand(){
    this.activeSectionName  = ['A','B','C','D','E','F','G']; 
}

handleCollapse(){
    this.activeSectionName = [];
}


    handleSave(){
        const handleInputs = this.template.querySelectorAll('[data-id="input"]');
        let isValid = true;
        let firstInavalidInput = null;

        handleInputs.forEach( input => {
            if(!input.checkValidity()){
                input.reportValidity();
                if(!firstInavalidInput){
                    firstInavalidInput = input;
                }
                isValid =false;
            }
        });
        if(!isValid){
            firstInavalidInput.scrollIntoView({behavior : 'smooth',block : 'center'});
            return ;
        }
        this.sendBooleanValues = {
                showEntities : {
                    showOppFeatures : this.showOppFeatures,
                    showOppPartner : this.showOppPartner,
                    showOpportunityProductOption : this.showOpportunityProductOption,
                    showOpportunitySolution : this.showOpportunitySolution,
                    isAttachment : this.isAttachment,
                    showAttachment : this.showAttachment,
                    showNote : this.showNote,
                    showContentlink : this.showContentlink
                },
                showSelections : {
                    selectedOppAttachments : this.selectedOppAttachments,
                    selectedOppSolutions : this.selectedOppSolutions,
                    selectedOppProducts : this.selectedOppProducts,
                    selectedOppPartners : this.selectedOppPartners,
                    selectedDescFeat : this.selectedDescFeat,
                    selectedOppTeamMembers : this.selectedOppTeamMembers
                }
            };
            console.log('wrapper data ---'+JSON.stringify(this.sendBooleanValues.showSelections));

            const nonOwnerIdSet = new Set(this.nonOwnerRows);
            this.nonOwnerIds = Array.from(nonOwnerIdSet);

        this.isLoading = true;
        continueClone({oppId : this.opptyID, newOppName : this.cloneOppName, newOppDD : this.cloneDesDate, newOppMINDS : this.oppMINDS,payload : JSON.stringify(this.sendBooleanValues), teamIds : this.nonOwnerIds})
        .then((res)=> {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message: 'Opportunity has been cloned successfully',
                    variant : 'success',
                })
            );
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                recordId: res,
                actionName: 'view'
            }
            });
        })
        .catch(error => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent ({
                    title : 'Error Cloning the Opportunity',
                    message : error.body.message,
                    variant : 'error',
                })
            );
        });
    }

    
        sendToApex(){
            console.log('405---'+JSON.stringify(this.sendBooleanValues));
            testWrapper({payload : JSON.stringify(this.sendBooleanValues) })
        .then((res) =>{
            console.log('407---'+JSON.stringify(payload));
        })
        .catch(error => {
            console.log('411---'+JSON.stringify(error));
        });
        }
        
    
    handleCancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opptyID,
                actionName: 'view'
            }
        });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}