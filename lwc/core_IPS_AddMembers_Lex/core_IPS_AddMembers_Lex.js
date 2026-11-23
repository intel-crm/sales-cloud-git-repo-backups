import { LightningElement,api,wire,track } from 'lwc';
import getExistingMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getExistingMembers';
import getAddMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.getAddMembers';
import insertProjectMembers from '@salesforce/apex/Core_IPS_ProjectController_Lex.insertProjectMembers';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation'; 
import hasProjectEditAccess from '@salesforce/apex/Core_IPS_ProjectController_Lex.hasProjectEditAccess';
import accessMessage from '@salesforce/label/c.Core_IPS_Project_Member_Access_Error';
import detailPage from '@salesforce/label/c.Core_IPS_Project_Detail_Page';
import activeMsg from '@salesforce/label/c.Core_IPS_Active_Project_Member';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'First Name', fieldName: 'FirstName', sortable: true, type: 'text'},
    { label: 'Last Name', fieldName: 'LastName', sortable: true, type: 'text' },
    { label: 'Email', fieldName: 'Email', sortable: true, type: 'text' },
    { label: 'Account Name', fieldName: 'Name', sortable: true, type: 'text' },
    { label: 'Id', fieldName: 'Id',type: 'Id' },
    { label: 'ContactId', fieldName: 'ContactId',type: 'Id' }
];
export default class Core_IPS_AddMembers_Lex extends NavigationMixin(LightningElement) {
    
    sections = ['A', 'B'];
    columns = columns.filter(col =>(col.label !== 'Id' && col.label !== 'ContactId'));
    existingMemList=[];
    memberList=[];
    addMemList = [];
    searchList = [];
    selectedMembers = [];
    recordsToDisplay = [];
    rowLimit =10;
    rowOffSet=0;
    rowLimit1 =10;
    rowOffSet1=0;
    switchView = true;
    projAccess;
    searchKey='';
    spinner=true;
    searchMsg;
    targetDatatable;
    targetDatatable1;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    addSortDirection = 'asc';
    sortedBy;
    key='';
    showTable = false;
    activeMembMsg = activeMsg;
    projDetailPage = detailPage;
    errorMessage = accessMessage;
    @api recordId;
    @track currentPageReference;
    tempRecordId;
    cnt=0;
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
    connectedCallback() {
       this.recordId = this.projectrecordId();
       this.tempRecordId = this.recordId;
       this.cnt=1;
       this.hasProjectEditAccess();
       this.getExistingMembers();
       this.RefreshValues();
    }
   async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 1500));
        this.getMembers('Load Data');
        this.getMembers('All Data');
    }
    hasProjectEditAccess(){
        hasProjectEditAccess({
            projectId: this.recordId
        })
        .then(data=>{
            if(data==true)
            this.projAccess = true;
            else{
            this.projAccess = false;
            const event = new ShowToastEvent({
                message: this.errorMessage,
                variant: 'error',
            });
            this.dispatchEvent(event);
            }
            this.spinner = false;
        })
        .catch(error=>{
            console.log('error:'+error);
        })
    }
    getExistingMembers(){
        return getExistingMembers({
            projectId1 : this.recordId,
            limitSize1 : this.rowLimit1,
            offset1 : this.rowOffSet1,
        })
        .then(data=>{
            if (this.targetDatatable1 && data==null) {
                this.targetDatatable1.enableInfiniteLoading = false;
            }
            for (let i = 0; i < data.length; i++) {
                let obj = {
                    'FirstName' : data[i].Core_IPS_Contact__r.FirstName,
                    'LastName' : data[i].Core_IPS_Contact__r.LastName,
                    'Email' : data[i].Core_IPS_Contact__r.Email,
                    'Name' : data[i].Core_IPS_Contact__r.Account.Name,
                };
                this.existingMemList = [...this.existingMemList, obj];
            }
            this.showTable = true;
            if(this.existingMemList.length != 0){
                this.sortData(this.sortedBy,this.sortDirection,this.existingMemList,'ExistingMembers');
            }
            console.log('existingMemCount:'+this.existingMemList.length);
        })
        .catch(error=>{
            console.log('error in fetching existing members '+error.message);
        })
    }
    loadMoreData(event){
        const currentRecord = this.existingMemList;
        const { target } = event;
        target.isLoading = true;
        this.targetDatatable1 = event.target;
        this.rowOffSet1 = this.rowOffSet1 + this.rowLimit1;
        this.getExistingMembers()
        .then(()=> {
            this.targetDatatable1.isLoading = false;
        }); 
       
    }
    
    getMembers(msg){
        let type = msg;
        return getAddMembers({           
            projectId : this.recordId,
            limitSize : this.rowLimit,
            offset : this.rowOffSet,
            fetchType : type
        })
        .then(data=>{
            if (this.targetDatatable && this.addMemList.length==this.memberList.length) {
                this.targetDatatable.enableInfiniteLoading = false;
            }
                if(type === 'Load Data') {
                let temp = JSON.parse(data);
                this.memberList = [...this.memberList, ...temp];
                }
                else if(type === 'All Data') {
                let temp1 = JSON.parse(data);
                this.addMemList = [...this.addMemList, ...temp1];
                }
            if(this.memberList.length != 0){
                this.sortData(this.sortedBy,this.addSortDirection,this.memberList,'AddMembers');
            }        
                this.switchView = true;  
                this.showMemTable = true;
                this.recordsToDisplay = this.memberList;
                console.log('ADDMemCount:'+this.memberList.length); 
        })
        .catch(error=>{
            this.showMemTable = false;
            this.switchView = false;
            console.log(' error in fetching add members: '+error.message);
        })
    }
    handleLoadMore(event) {
        if(this.searchList != undefined && this.searchList.length == 0){
            const currentRecord = this.memberList;
            const { target } = event;
            target.isLoading = true;
            this.targetDatatable = event.target;
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.getMembers('Load Data')
            .then(()=> {
               this.targetDatatable.isLoading = false;
            }); 
        }
    }
    handleKeyChange(event){
        try{
            let tempMembers = [];
            this.searchKey = event.target.value;
            if(this.searchKey.length>=3){
                this.addMemList.forEach(contact =>{
                    if(contact.FirstName != undefined && contact.FirstName.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    } else if(contact.LastName != undefined && contact.LastName.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    } else if(contact.Email != undefined && contact.Email.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    } else if(contact.Name != undefined && contact.Name.toLowerCase().indexOf(this.searchKey.toString().toLowerCase()) !== -1){
                        tempMembers.push(contact);
                    }
                });
                //this.getMembers('All Data');
                this.searchList = tempMembers;
                this.memberList = this.searchList;
                this.switchView = true;
                if(this.searchList.length==0){ this.switchView = false; }
            }       
            else if(this.searchKey =='' || this.searchKey == null || this.searchKey.length <= 2) {
                this.searchList=[];
                this.memberList = this.recordsToDisplay;
                this.switchView = true;
            } 
            if(this.searchKey.length >= 1 && this.searchKey.length <= 2){ this.searchMsg = true; }
            else { this.searchMsg = false; }

        } catch(error){
            console.log('error in search handler ');
        }
    }
    getSelectedMember(event) {  
        this.selectedMembers = event.detail.selectedRows; 
        console.log('selectedMembers--'+this.selectedMembers);  
    }
    addMember(){
        this.addMemberList('Add');
    }        
    addMemberDone(){
        this.addMemberList('AddDone');
    }
    addMemberList(msg){
        this.spinner = true;
        let param = msg;
        let projectMember1 = this.insertMembers();
        if(projectMember1.length==0){
            const event = new ShowToastEvent({
                message: 'Please select at least one Project Member',
                variant: 'info',
            });
            this.dispatchEvent(event);
            this.spinner = false;

        }
        else{ 
        insertProjectMembers({projectMemberInfo: projectMember1})  
            .then(result=>{  
                if(result=='Success'){
                    const event = new ShowToastEvent({
                        message: 'Member added successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    if(param == 'Add'){
                       window.location.reload();
                    }
                    else if(param == 'AddDone'){
                       this.cancel();
                    }   
                }
                else if(result=='failed'){ 
                    const event = new ShowToastEvent({
                        message: 'Unable to Add Member',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    this.spinner = false;
                }
                else if(result=='exception'){
                    const event = new ShowToastEvent({
                        message: 'You are not authorized to add a Project Members that are from Accounts that you do not own, or are not on its Account Team.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                    this.spinner = false;
                }
            })  
            .catch(error=>{  
                console.log('error in inserting project members: '+JSON.stringify(error));                     
            })
        }
    }
    cancel(){
        window.location.href = this.projDetailPage + this.recordId + '/view'
    }
    insertMembers(){
        let projectMember=[];   
        for (let i=0;i<this.selectedMembers.length;i++){
            let data = JSON.stringify(this.selectedMembers);                   
                if(this.selectedMembers[i].Id.Id!=null){
                    projectMember.push({Core_IPS_Contact__c:this.selectedMembers[i].ContactId,Core_User__c:this.selectedMembers[i].Id.Id,
                                        Core_IPS_Project__c:this.recordId,Core_Status__c:'Active',Core_Selective_Member__c:true}); 
                                
                }
        }
        return projectMember;    
    }
    handleSort(event){
        this.sortedBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(this.sortedBy, this.sortDirection ,this.existingMemList,'ExistingMembers');       
    }
    handleMemberSort(event){
        this.sortedBy = event.detail.fieldName;       
        this.addSortDirection = event.detail.sortDirection;       
        this.sortData(this.sortedBy, this.addSortDirection, this.memberList,'AddMembers');       
    }   
    sortData(fieldname, direction,inputData,type) {
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
            if(type == 'ExistingMembers'){
                this.existingMemList = parseData; 
            } 
            else if(type == 'AddMembers'){
                this.memberList = parseData;
            }  
    }

    
}