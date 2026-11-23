import { LightningElement,track,wire,api } from 'lwc';
import fetchComputerDetails from '@salesforce/apex/Sales_LicenseGenerationUtlity_Chatbot.retriveComputerDetails';
import hostReassigmentCall from '@salesforce/apex/Sales_LicenseGenerationUtlity_Chatbot.hostReassigment';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
const columns = [
    {label: 'Computer Name', fieldName: 'Sales_Computer_Name_Txt__c', type: 'text', finalwidth:600},
    {label: 'Primary ID', fieldName: 'Name', type: 'text', initialwidth:'20%'},
    {label: 'License Type', fieldName: 'Sales_License_Type__c', type: 'text', initialwidth:'20'}
];

const FIELDS = [ 'Sales_License__c.Id', 'Sales_License__c.Sales_License_Activation_Code__c'];
export default class Sales_GetComputerDetails_Bot extends NavigationMixin(LightningElement){
    @track hostlist;
    @api isDataFound;
    @api iscreateNewHost=false;
    @api recordId;
    @api selectedhostId;
    @api item;
    @api activateCodeonLoad;
    @api successmsg;
    @api sendactivationcodetochatmsg;
    @api successResponse;
    @api showMessage=false;
    @api isErrorMessage = false;
    hostNameInput;
    @track columns = columns;
    @track datatableconfig = {
            objectName: "Sales_Host__c",
            pageSize: 5,
            tableConfig: {
                columns: [
                    { label: 'Computer Name', fieldName: 'Sales_Computer_Name_Txt__c', type: 'text', finalwidth:500, sortable: true },
                    { label: 'Primary ID', fieldName: 'Name', type: 'text', initialwidth:'20%', sortable: true },
                    { label: 'License Type', fieldName: 'Sales_License_Type__c', type: 'text', initialwidth:'20', sortable: true }
                ],
                maxRowSelection: 1
            }
        };
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    license;

    handleOnLoad(){
        //INITIALIZATION
        if(this.license.data!=undefined){
                this.activateCodeonLoad=this.license.data.fields.Sales_License_Activation_Code__c.value;                                                  
                this.recordId=this.license.data.fields.Id.value;                                  
        }
    }

    createNewComputer(event){
        //this.closeQuickAction();
        
        //console.log('REcord id==>'+this.recordId);
        //this.iscreateNewHost = true;
        /*this[NavigationMixin.Navigate]({
            type: 'standard__webPage',//standard__component',//,
            attributes: {
                componentName: 'c:salesCreateNewHost'
            },
        });*/

        this.iscreateNewHost = true;
        /*var compDetails = {
            componentDef: "c:salesCreateNewHost",
            attributes: {
                //Value you want to pass to the next lwc component
                propertyValue: "500"
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDetails = btoa(JSON.stringify(compDetails));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDetails
            }
        });*/
    }

    closeQuickAction() {
        //const closeModal = new CustomEvent('close');
        eval("$A.get('e.force:closeQuickAction').fire();");
               // Dispatches the event.
        //this.dispatchEvent(closeModal);
    }

    handleRowSelection(event){
        var selectedRows=event.detail.selectedRows;
        console.log("You selected: " + selectedRows[0].Id);
        this.selectedhostId = selectedRows[0].Id;
        console.log("activationCode from SALESLWC: " + this.item);
    }
    
    inputChange(event){
        this.hostNameInput = event.target.value;
    }
    hostReassignment(event){
        hostReassigmentCall({activationCode : this.item, hostId:this.selectedhostId})
        .then(result => {
            var output = result;
            this.successResponse = output;
            this.isDataFound = false;
            this.selectedSerialNo = this.item;
            this.showMessage = true;

        })
        .catch(error => {
                let errorMessage = 'Error!!';
                if ( error.body.message) {
                    errorMessage =error.body.message;
                }
                console.log('error.body.message');
            })  
    }

    validateComputerName(event){
        console.log('this.item==>'+this.item);
        console.log("this.hostNameInput check: " + this.hostNameInput);
        console.log("this.activateCodeonLoad: " + this.activateCodeonLoad);
        if(this.activateCodeonLoad!=undefined && this.hostNameInput!=undefined && this.hostNameInput!=null && this.hostNameInput!=''){
            fetchComputerDetails({activationCode : this.activateCodeonLoad, hostName : this.hostNameInput})
            .then(result => {
                this.hostlist = result;
                if(this.hostlist[0] != undefined){
                    this.isDataFound = true;
                    this.isErrorMessage = false;
                    //this.showMessage = true;
                }else{
                    this.isDataFound = false;
                    this.isErrorMessage = true;
                    //this.showMessage = false;
                }
            })
            .catch(error => {
                    let errorMessage = 'Error!!';
                    if ( error.body.message) {
                        errorMessage =error.body.message;
                    }
                    console.log('errorMessage==>'+errorMessage);
                })   
        }
        
        else if(this.hostNameInput!=undefined && this.hostNameInput!=null && this.hostNameInput!=''){
            //check if user enters nothing...then show error msg
            console.log("this.hostNameInput : " + this.hostNameInput);
            console.log("this.item : " + this.item);
            fetchComputerDetails({activationCode : this.item, hostName : this.hostNameInput})
            .then(result => {
                this.hostlist = result;
                if(this.hostlist[0] != undefined){
                    this.isDataFound = true;
                    this.isErrorMessage = false;
                    //this.showMessage = true;
                }else{
                    this.isDataFound = false;
                    this.isErrorMessage = true;
                    //this.showMessage = false;
                }
            })
            .catch(error => {
                    let errorMessage = 'Error!!';
                    if ( error.body.message) {
                        errorMessage =error.body.message;
                    }
                    console.log('errorMessage==>'+errorMessage);
                })   
        }else{
            this.isErrorMessage = true;
            this.isDataFound = false;
        }   
    }
    }