import { LightningElement,api, wire } from 'lwc';
import getDefaultCaseOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.getDefaultCaseOwner';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import removeCaseOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.removeCaseOwner';
import searchOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.searchOwner';
import updateCaseOwner from '@salesforce/apex/Core_IPS_ProjectController_Lex.updateCaseOwner';
import hasProjectEditAccess from '@salesforce/apex/Core_IPS_ProjectController_Lex.hasProjectEditAccess';
import userDetails from '@salesforce/apex/Core_IPS_ProjectController_Lex.userDetails';
import detailPage from '@salesforce/label/c.Core_IPS_Product_Detail_Page';
import Id from '@salesforce/user/Id';
export default class Core_IPS_changeDefaultCaseOwnerLex extends LightningElement {
    @api recordId;
    activeSections=['Selected','Search'];
    value = 'user';
    switchView;
    isUserData;
    isData;
    searchType = 'user';
    searchText;
    searchMsg;
    recValue =[];
    data=[];
    qData=[];
    showResult;
    searchKey;
    showAdd;
    disableBtn = true;
    userAccess = true;
    recsToInsert =[];
    spinner = true;
    userId = Id;
    profile;
    
    connectedCallback() {
        this.options = [
            {label: 'User', value:'user'},
            {label: 'Partner User', value:'partnerUser'},
            {label: 'Queue', value:'queue'}
        ]
        this.userColumns = [
            {label: 'First Name', fieldName: 'firstName', type:'text'},
            {label: 'Last Name', fieldName: 'lastName', type:'text'},
            {label: 'Email', fieldName: 'email', type:'email'}
        ];
        this.queueColumns = [
            {label: 'Name', fieldName: 'name', type:'text'},
            {label: 'Queue Name', fieldName: 'qName', type:'text'}
        ];
        this.userDetails();
        this.RefreshValues();
    }
    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 50));      
        this.hasProjectEditAccess();
        this.getDefaultCaseOwner();
    }
    userDetails(){
        userDetails({
            userId: Id
        })
        .then(data=>{
           if(data==true){
               this.spinner = false;
               this.userAccess = false;
           }
        })
        .catch(error=>{
            console.log('error:'+error);
        })
    }
    hasProjectEditAccess(){
        hasProjectEditAccess({
            projectId: this.recordId
        })
        .then(data=>{
            console.log('data--'+data);
            if(data==true)
               this.projAccess = true;
            else
               this.projAccess = false;
            this.spinner = false;
        })
        .catch(error=>{
            console.log('error:'+error);
        })
    }
    
    getDefaultCaseOwner() {
        getDefaultCaseOwner({
            productId: this.recordId
        })
        .then(data=>{
            if(data.hasData === true){
                this.isData = true;
                if(data.type == 'User'){
                    this.isUserData = true;
                    let obj = {
                        'firstName': data.returnData[0].FirstName,
                        'lastName': data.returnData[0].LastName,
                        'email': data.returnData[0].Email
                    }
                    this.recValue = obj;
                } 
                if(data.type == 'Queue'){
                    this.isUserData = false;
                    let obj = {
                        'name': data.returnData[0].Name,
                        'developerName': data.returnData[0].DeveloperName
                    }
                    this.recValue = obj;
                }
            } else {
                this.isData = false;
            }
        })
        .catch(error=>{
            console.log('error occured: '+JSON.stringify(error));
        })
    }

    removeCaseOwner(){
        removeCaseOwner({
            productId: this.recordId
        })
        .then(data=>{
            if(data === 1){
                console.log('successfully removed the case owner.');
                this.handleCancel();
            } 
            if(data ===2){
                console.log('error in removing the case owner.')
            }
        })
        .catch(error=>{
            console.log('error occured: '+ JSON.stringify(error));
        })
    }

    searchOwner() {
        this.qData = [];
        this.data = [];
        searchOwner({
            searchTxt: this.searchText,
            type: this.searchType,
            productId: this.recordId
        })
        .then(data=>{
            if(data.hasData) {
                this.showResult = true;
                if(data.type === 'User' || data.type === 'PartnerUser'){
                    this.switchView = true;
                    for(let i=0; i< data.returnData.length; i++) {
                        let obj = {
                            'type': 'User',
                            'id': data.returnData[i].Id,
                            'fullName': data.returnData[i].Name,
                            'firstName': data.returnData[i].FirstName,
                            'lastName': data.returnData[i].LastName,
                            'email' : data.returnData[i].Email
                        };
                        this.data =[...this.data, obj];
                    }
                } else if(data.type === 'Queue') {
                    this.switchView = false;
                    for(let i=0; i< data.returnData.length; i++){
                        let obj = {
                            'type': 'Queue',
                            'id': data.returnData[i].Queue.Id,
                            'name': data.returnData[i].Queue.Name,
                            'qName': data.returnData[i].Queue.DeveloperName
                        };
                        this.qData = [...this.qData, obj];
                    }
                }
            } else if(this.searchText!=null||this.searchText!='') {
                this.showResult = false;
                this.searchKey = true;
            }
        })
        .catch(error=>{
            console.log('error occured: '+JSON.stringify(error));
        })
    }

    updateCaseOwner(){
    
        let inputStr = this.recsToInsert[0].id;
        let type = this.recsToInsert[0].type;
        updateCaseOwner({
            inputString: inputStr,
            inputType: type,
            productId: this.recordId
        })
        .then(data=>{
            if(data ===1){
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Case Owner Updated Successfully',
                    variant: 'success'
                }));
                this.handleCancel();
            }
            if(data ===2){
                console.log('record update failed.');
                this.dispatchEvent(new ShowToastEvent({
                    message: 'Unable to update Case Owner',
                    variant: 'error'
                }));
            }
        })
        .catch(error=>{
            console.log('error occured: updating case owner '+JSON.stringify(error));
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

    getQSelected(event){
        this.recsToInsert = event.detail.selectedRows;
        if(this.recsToInsert.length>0){
            this.showAdd = true;
        } else {
            this.showAdd = false;
        }
    }

    handleRemove() {
        this.removeCaseOwner();
    }

    handleChange(event) {
        this.searchType = event.target.value;
    }

    handleKeyChange(event) {
        this.searchText = event.target.value;
        if(this.searchText != ''||this.searchText.length>=3){
            this.disableBtn = false;
        } else {
            this.disableBtn = true;
        }
        if(this.searchText.length >= 1 && this.searchText.length <= 2){ this.searchMsg = true; }
        else { this.searchMsg = false; }
    }

    onButtonClick() {
        this.searchOwner();
    }

    handleAdd(){
        this.updateCaseOwner();
    }

    handleCancel(){
        window.location.href = detailPage+this.recordId+'/view';
    }
}