import { LightningElement, track ,api} from 'lwc';
//import searchContactOrUser from '@salesforce/apex/PSG_QuoteDocumentEmailController.searchContactOrUser';
//import getInitDetails from '@salesforce/apex/PSG_QuoteDocumentEmailController.getInitDetails';
//import sendEmailController from '@salesforce/apex/PSG_QuoteDocumentEmailController.sendEmailController';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';

export default class Psg_QuoteDocumentEmail extends LightningElement {
    @api recId;
    emptyAvailablePeople = '';
    searchTrue = false;
    toRequired = false;
    spinnerTrue = true;
    requestorPresent = false;
    lookupSearch = false;
    ccRecipient = false;
    bccRecipient = false;
    subject = '';
    body;
    @track availablePeople=[];
    @track _getRecentContact = [];
    @track _addToSelectedList = [];
    @track _ccSelectedList =[];
    @track _bccSelectedList =[];
    @track _searchContacts = []; 
    @track tempSelection;
    @track searchTerm;
    getSearchObject;
    getViewList = 'Recent Contacts';
    @track toRecipientList=[];
    @track ccRecipientList =[];
    @track bccRecipientList=[];
    
    /*@api set recordId(value) {
        this.recId = value;
        getInitDetails({recordId: this.recId})
        .then((result) => {
            if(result){
                let contWrap = result['contactWrapper'];
                let emailDetails = result['emailDetails'];
                let recentContact = result['availableContact'];
                contWrap.forEach( ele => {
                    if(ele.peopleId == Id && ele.name.includes('currentPresent')){
                        this.bccRecipient = true;
                        this.bccRecipientList = this.bccRecipientList.concat(ele.email);
                    }else{
                        this.toRecipientList = this.toRecipientList.concat(ele.email);
                    }
                })
                for(var key in emailDetails){
                    this.subject = key;
                    this.body = emailDetails[key];
                }
                if(this.toRecipientList.length <= 0){
                    this.toRequired = false;
                }else{
                    this.toRequired = true;
                }
                this._getRecentContact = recentContact;
			    this.availablePeople = this._getRecentContact;                  
                this.spinnerTrue = false;
                this.requestorPresent = true;
            }
        });        
    }*/
    get recordId() {
        return this.recId;
    }

    handleInput(event){
        if (event.target.value.length < 3) {
            this.availablePeople = this._getRecentContact;
            this.getViewList = 'Recent Contacts';
            this.emptyAvailablePeople = '';
            return;
        }else{
            this.searchTerm = event.target.value;
        }
    }
    setOption(event){
        this.getSearchObject = (event.target.value);
    }
    //Handle Recent Search option
    /*handleSearchRequest(event) {
        event.preventDefault();
        this.emptyAvailablePeople = '';
        this.availablePeople = [];
        this.searchTrue = true;
        searchContactOrUser({ searchString: this.searchTerm, objectName : this.getSearchObject })
        .then((result) => {
            if(result){
                JSON.parse(JSON.stringify(result));
                if(this.getSearchObject == 'User')
                    this.getViewList = 'Users';
                else if(this.getSearchObject == 'Contact')
                    this.getViewList = 'Contacts';
                this._searchContacts = result;
                this.availablePeople = this._searchContacts;
                if (this.availablePeople.length == 0){
                    this.emptyAvailablePeople = 'No matched found. Try searching by name or email from different view';
                }
                this.searchTrue = false;
            }
        })
        .catch((error) => {
            console.error("Error:", error);
        });
    }*/

    handleSelection(event){
        this.tempSelection = event.currentTarget.dataset.value;
    }

    handleSelectionAdd(event){
        let selection = event.target.dataset.val;
        if(selection == 'addToSelected'){
            this.availablePeople.forEach(ele => {
                if(ele.email == this.tempSelection) {
                    let addTrue = false;
                    if(this._addToSelectedList.length > 0){
                        this._addToSelectedList.forEach(element =>{
                            if(element.peopleId == ele.peopleId){
                                addTrue = true;
                            }
                        })
                    }
                    if(!addTrue){
                        this._addToSelectedList.push(ele);
                        JSON.parse(JSON.stringify(this._addToSelectedList));
                    }
                }
            });
            this.availablePeople = this.availablePeople.filter(ele => ele.email != this.tempSelection);
            this._getRecentContact = this._getRecentContact.filter(ele => ele.email != this.tempSelection);
        }else if(selection == 'ccSelected'){
            this.availablePeople.forEach(ele => {
                if(ele.email == this.tempSelection) {
                    let addTrue = false;
                    if(this._ccSelectedList.length > 0){
                        this._ccSelectedList.forEach(element =>{
                            if(element.peopleId == ele.peopleId){
                                addTrue = true;
                            }
                        })
                    }
                    if(!addTrue){
                        this._ccSelectedList.push(ele);
                        JSON.parse(JSON.stringify(this._ccSelectedList));
                    }
                }
            });
            this.availablePeople = this.availablePeople.filter(ele => ele.email != this.tempSelection);
            this._getRecentContact = this._getRecentContact.filter(ele => ele.email != this.tempSelection);
        }else if(selection == 'bccSelected'){
            this.availablePeople.forEach(ele => {
                if(ele.email == this.tempSelection) {
                    let addTrue = false;
                    if(this._bccSelectedList.length > 0){
                        this._bccSelectedList.forEach(element =>{
                            if(element.peopleId == ele.peopleId){
                                addTrue = true;
                            }
                        })
                    }
                    if(!addTrue){
                        this._bccSelectedList.push(ele);
                        JSON.parse(JSON.stringify(this._bccSelectedList));
                    }
                }
            });
            this.availablePeople = this.availablePeople.filter(ele => ele.email != this.tempSelection);
            this._getRecentContact = this._getRecentContact.filter(ele => ele.email != this.tempSelection);
        }

    }

    handleSave(){
        try{
            if(this._addToSelectedList.length > 0){
                this._addToSelectedList.forEach( ele => {
                    if(!this.toRecipientList.includes(ele.email) && !this.ccRecipientList.includes(ele.email) && !this.bccRecipientList.includes(ele.email)){
                        this.toRecipientList = this.toRecipientList.concat(ele.email);
                    }
                })
            }
    
            if(this._ccSelectedList.length > 0){
                this._ccSelectedList.forEach( ele => {
                    if(!this.toRecipientList.includes(ele.email) && !this.ccRecipientList.includes(ele.email) && !this.bccRecipientList.includes(ele.email)){
                        this.ccRecipientList = this.ccRecipientList.concat(ele.email);
                        this.ccRecipient = true;
                    }
                })
            }
    
            if(this._bccSelectedList.length > 0){
                this._bccSelectedList.forEach( ele => {
                    if(!this.toRecipientList.includes(ele.email) && !this.ccRecipientList.includes(ele.email) && !this.bccRecipientList.includes(ele.email)){
                        this.bccRecipientList = this.bccRecipientList.concat(ele.email);
                        this.bccRecipient = true;
                    }
                })
            }
            this.availablePeople = this._getRecentContact;
            this.lookupSearch = false;
            if(this.toRecipientList.length <= 0)
                this.toRequired = false;
            else
                this.toRequired = true;
        }catch(error){
            console.log("SaveError::: " + error);
        }
    }

    handleSelectionRemove(event){
        let selection = event.target.dataset.val;
        if(selection == 'addToSelected'){
            this._addToSelectedList.forEach(ele => {
                if(ele.email == this.tempSelection) {
                    this.availablePeople.push(ele);
                }
            });
            this._addToSelectedList = this._addToSelectedList.filter(ele => ele.email != this.tempSelection);
            if(this.toRecipientList.includes(this.tempSelection)){
                let index = this.toRecipientList.indexOf(this.tempSelection);
                this.toRecipientList.splice(index,1);
            }
        }else if(selection == 'ccSelected'){
            this._ccSelectedList.forEach(ele => {
                if(ele.email == this.tempSelection) {
                    this.availablePeople.push(ele);
                }
            });
            this._ccSelectedList = this._ccSelectedList.filter(ele => ele.email != this.tempSelection);
            if(this.ccRecipientList.includes(this.tempSelection)){
                let index = this.ccRecipientList.indexOf(this.tempSelection);
                this.ccRecipientList.splice(index,1);
                if(this.ccRecipientList.length == 0){
                    this.ccRecipient = false;
                }
            }
        }else if(selection == 'bccSelected'){
            this._bccSelectedList.forEach(ele => {
                if(ele.email == this.tempSelection) {
                    this.availablePeople.push(ele);
                }
            });
            this._bccSelectedList = this._bccSelectedList.filter(ele => ele.email != this.tempSelection);
            if(this.bccRecipientList.includes(this.tempSelection)){
                let index = this.bccRecipientList.indexOf(this.tempSelection);
                this.bccRecipientList.splice(index,1);
                if(this.bccRecipientList.length == 0){
                    this.bccRecipient = false;
                }
            }
        }
    }

    removeFromList(event){
        try{
            let removeElement = event.currentTarget.dataset.value;
            let btnId = event.currentTarget.dataset.btnid;
            if(this.toRecipientList.includes(removeElement) && btnId=='fromTo'){
                let index = this.toRecipientList.indexOf(removeElement);
                this.toRecipientList.splice(index,1);
                this._addToSelectedList.forEach(ele =>{
                    if(ele.email == removeElement) {
                        JSON.parse(JSON.stringify(this.availablePeople));
                        this.availablePeople.push(ele);
                    }
                });
                this._addToSelectedList = this._addToSelectedList.filter(ele => ele.email != removeElement);
                if(this.toRecipientList.length <= 0)
                    this.toRequired = false;
                else
                    this.toRequired = true;
                refreshApex(this.toRecipientList);
            }
            else if(this.ccRecipientList.includes(removeElement) && btnId=='fromCc'){
                let index = this.ccRecipientList.indexOf(removeElement);
                this.ccRecipientList.splice(index,1);
                this._ccSelectedList.forEach(ele =>{
                    if(ele.email == removeElement) {
                        this.availablePeople.push(ele);
                        JSON.parse(JSON.stringify(this.availablePeople));
                    }
                });
                this._ccSelectedList = this._ccSelectedList.filter(ele => ele.email != removeElement);
                if(this.ccRecipientList.length == 0){
                    this.ccRecipient = false;
                }
                refreshApex(this.ccRecipientList);
            }
            else if(this.bccRecipientList.includes(removeElement) && btnId=='fromBcc'){
                let index = this.bccRecipientList.indexOf(removeElement);
                this.bccRecipientList.splice(index,1);
                this._bccSelectedList.forEach(ele =>{
                    if(ele.email == removeElement) {
                        JSON.parse(JSON.stringify(this.availablePeople));
                        this.availablePeople.push(ele);
                    }
                });
                this._bccSelectedList = this._bccSelectedList.filter(ele => ele.email != removeElement);
                if(this.bccRecipientList.length == 0){
                    this.bccRecipient = false;
                }
                refreshApex(this.bccRecipientList);
            }
        }catch(error){
            console.log("RemoverError::: " + error);
        }
        
    }

    handleRecipient(){
        this.lookupSearch = true;
    }
    
    handleCancel(){
        this.lookupSearch = false;
        this.availablePeople = this._getRecentContact;
    }

    handleCloseAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /*handleSendEmail(){
        this.spinnerTrue = true;
        this.requestorPresent = false;
        sendEmailController({recordId: this.recordId, getToRecipientList: this.toRecipientList ,getCcRecipientList: this.ccRecipientList ,getBccRecipientList: this.bccRecipientList})
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Email',
                message: 'Sent successfully',
                variant: 'success',
                mode: 'dismissable'
            }))
            this.dispatchEvent(new CloseActionScreenEvent());
            console.log(history.back());
        })
        .catch((error) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Failed to sent email',
                message: error.body.message + ', connect with administrator for this',
                variant: 'error',
                mode: 'dismissable'
            }))
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    }*/
}