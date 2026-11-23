import { LightningElement, api, wire } from 'lwc';
import getExistingTeamMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getExistingTeamMembers';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAddTeamMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAddTeamMembers';
import insertTeamMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.insertTeamMembers';
import hasProjectEditAccess from '@salesforce/apex/Core_IPS_ProjectController_Lex.hasProjectEditAccess';
import helpTxt from '@salesforce/label/c.Core_IPS_HelpText';
import detailPage from '@salesforce/label/c.Core_IPS_Project_Detail_Page';
export default class Core_IPS_supportTeamMemberLex extends NavigationMixin(LightningElement) {
    @api recordId;
    hasAccess;
    existingData =[];
    existData;
    searchData =[];
    recsToInsert =[];
    activeSections = ['Existing', 'Add'];
    hasData = false;
    disableBtn = true;
    searchText ='';
    errorMessage;
    showError;
    showToast;
    showAdd;
    showTable = true;
    searchMsg;
    defaultSortDirection = 'asc';
    defSortDirection = 'asc';
    sortDirection = 'asc';
    sDirection = 'asc';
    sortedBy;
    sBy;
    tempRecordId;
    cnt=0;
    spinner = true;
    currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        console.log('currentPageReference'+this.currentPageReference?.state?.c__recordId);
        this.recordId = this.currentPageReference?.state?.c__recordId;
        if(this.cnt==1&&this.recordId!=this.tempRecordId){
           window.location.reload();
        }
    }
    projectrecordId() {
        if(this.currentPageReference != null && this.currentPageReference != undefined){
            return this.currentPageReference?.state?.c__recordId;
        }        
    }
    connectedCallback(){
        this.columns =[
            {label: 'First Name', fieldName: 'firstName', sortable: true, type: 'text'},
            {label: 'Last Name', fieldName: 'lastName', sortable: true, type: 'text'},
            {label: 'Email', fieldName: 'email', sortable: true, type:'email'},
            {label: 'Profile', fieldName: 'profile', sortable: true, type: 'text'}
        ];
        this.recordId = this.projectrecordId();
        this.tempRecordId = this.recordId;
        this.cnt=1;
        this.hasProjectEditAccess();
        this.getExistingTeamMembers();
    }

    label ={
        helpTxt
    };

    hasProjectEditAccess(){
        hasProjectEditAccess({
            projectId: this.recordId
        })
        .then(data=>{
            if(data === true) {
                this.hasAccess = true;
            } else {
                this.hasAccess = false;
                this.dispatchEvent(new ShowToastEvent({
                    message: 'You do not have permission to Add Intel Support Team',
                    variant: 'error',
                }));
            }
            this.spinner = false;
        })
        .catch(error=>{
            console.log('error occured: project edit access, '+JSON.stringify(error));
        })
    }   

    getExistingTeamMembers(){
        getExistingTeamMembers({
            projId: this.recordId
        })
        .then(data=>{
            this.existData =data;
            for(let i = 0; i< data.length; i++){
                let obj = {
                    'firstName': data[i].Core_IPS_User__r.FirstName,
                    'lastName': data[i].Core_IPS_User__r.LastName,
                    'email': data[i].Core_IPS_User__r.Email,
                    'profile': data[i].Core_IPS_Profile__c
                };
                this.existingData = [...this.existingData, obj];
            }
        })
        .catch(error=>{
            console.log('error occured in fetching team members: '+error);
            this.showTable = false;
        })
    }

    getAddTeamMembers(){
        this.searchData = [];
        this.showError = false;
        getAddTeamMembers({
            projId: this.recordId,
            searchTxt: this.searchText,
            existingData: this.existData
        })
        .then(data=>{
            if(data.userList != null ){
                this.hasData = true;
                for(let i=0; i< data.userList.length; i++){
                    let obj = {
                        'userId': data.userList[i].Id,
                        'firstName': data.userList[i].FirstName,
                        'lastName': data.userList[i].LastName,
                        'email': data.userList[i].Email,
                        'profile': data.userList[i].Profile.Name
                    };
                    console.log('ad t mem 0'+JSON.stringify(obj));
                    this.searchData = [...this.searchData, obj];
                }
            } else {
                this.errorMessage = data.Message;
                this.showError = true;
                this.hasData = false;
            }
        })
        .catch(error=>{
            console.log('error occured while fetching add team members: '+ JSON.stringify(error));
        })
    }

    insertTeamMembers(){
        this.spinner = true;
        let finalStrList =[];
        for(let i =0; i<this.recsToInsert.length; i++) {
            finalStrList = [...finalStrList , JSON.stringify(this.recsToInsert[i])];
        }
        insertTeamMembers({
            inputStrings: finalStrList,
            projId : this.recordId
        })
        .then(data=>{
            if(data === 1){
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Intel Support Team Member added successfully',
                    variant: 'success',
                }));
                window.location.reload();
                console.log('records are inserted.');
            } 
            if(data === 2){
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Unable to add Intel Support Team Member',
                    variant: 'error',
                }));
                this.spinner = false;
                console.log('recoreds are not inserted');
            }
        })
        .catch(error=>{
            console.log('error occured: Inserting Team Member '+ JSON.stringify(error));
        })
    }

    getSelected(event){
        this.recsToInsert = event.detail.selectedRows;
        if(this.recsToInsert.length>0){
            this.showAdd = true;
        } else {
            this.showAdd = false;
        }
    }


    handleKeyChange(event){
        this.searchText = event.target.value;
        if(this.searchText != ''||this.searchText.length>=3){
            this.disableBtn = false;
        } else {
            this.disableBtn = true;
        }
        if(this.searchText.length >= 1 && this.searchText.length <= 2){ this.searchMsg = true; }
        else { this.searchMsg = false; }
        
    }

    onButtonClick(){
        this.getAddTeamMembers();
    }

    handleAdd(){
        this.insertTeamMembers();
    }

    handleExit(){
        window.location.href = detailPage+this.recordId+'/view';
    }

    handleSort(event){
        this.sortedBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection,this.existingData, 'existingData');
    }

    handleSorting(event){
        let loadedData = this.searchData;
        this.sBy = event.detail.fieldName;       
        this.sDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName,event.detail.sortDirection,loadedData, 'searchData');
    }

    sortData(fieldname, direction,inputData, type) {       
        let parseData = JSON.parse(JSON.stringify(inputData));           
        let sortedData = (key) => {
            return key[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {               
            x = sortedData(x) ? sortedData(x).toLowerCase() : ''; 
            y = sortedData(y) ? sortedData(y).toLowerCase() : '';           
            return isReverse * ((x > y) - (y > x));
        });
        if(type === 'existingData'){
            this.existingData = parseData;
        }
        if(type === 'searchData') {
            this.searchData = parseData;
        }   
    }
}