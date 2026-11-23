import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import fetchContactPickListValues from '@salesforce/apex/EPUM_SearchContact.fetchContactPickListValues';
import createContact from '@salesforce/apex/EPUM_SearchContact.createContact';
import createContacts from '@salesforce/apex/CreateNewContactDemo.createContacts';
import EPUM_InviteAUser from '@salesforce/label/c.EPUM_InviteAUser';
import EPUM_Close from '@salesforce/label/c.EPUM_Close';
import EPUM_Cancel from '@salesforce/label/c.EPUM_Cancel';
import EPUM_FirstName from '@salesforce/label/c.EPUM_FirstName';
import EPUM_LastName from '@salesforce/label/c.EPUM_LastName';
import EPUM_WorkEmail from '@salesforce/label/c.EPUM_WorkEmail';
import EPUM_Country from '@salesforce/label/c.EPUM_Country';
import EPUM_PreferredLanguage from '@salesforce/label/c.EPUM_PreferredLanguage';
import EPUM_SendInvite from '@salesforce/label/c.EPUM_SendInvite';
import EPUM_ContactSuccess from '@salesforce/label/c.EPUM_ContactSuccess';
import EPUM_InviteUserMsg from '@salesforce/label/c.EPUM_InviteUserMsg';
import EPUM_FielsSelectionErrorMsg from '@salesforce/label/c.EPUM_FielsSelectionErrorMsg';
import EPUM_SelectOption from '@salesforce/label/c.EPUM_SelectOption'; 
import styleResource from '@salesforce/resourceUrl/IpaResources';





export default class BulkContactCreation extends NavigationMixin(LightningElement) {


    //

    label = {
        EPUM_InviteAUser,
        EPUM_InviteUserMsg,
        EPUM_Close,
        EPUM_Cancel,
        EPUM_FirstName,
        EPUM_LastName,
        EPUM_WorkEmail,
        EPUM_Country,
        EPUM_PreferredLanguage,
        EPUM_SendInvite,
        EPUM_FielsSelectionErrorMsg,
        EPUM_ContactSuccess,
        EPUM_SelectOption
    };


         rowData=[];
    @api showModal;
    @api searchedEmail;
    @track errMessage = '';
    @track countryPicklistValues;
    @track preferredLanguagePicklistValues;
    @track isLoading = true;
    
    @track newContact = [{
        'sobjectType': 'Contact',
        'Email': '',
        'FirstName': '',
        'LastName': '',
        'MailingCountry': '',
        'Core_Preferred_Language__c': 'ENG'
    }]

    connectedCallback() {
        this.newContact.Email = this.searchedEmail;
        fetchContactPickListValues({
            searchedEmail: this.searchedEmail
        })
            .then(result => {
                this.isLoading = false;
                let keys = Object.keys(result.lstCountryValues);
                let options = [];
                let j = 1;
                for (let i = 0; i < keys.length; i++) {
                    let option = {
                        label: result.lstCountryValues[keys[i]].strLabel,
                        value: result.lstCountryValues[keys[i]].strValue
                    };
                    options = [...options, option];
                }
                this.countryPicklistValues = options;

                let lang = Object.keys(result.lstPreferredLanguageValues);
                let langoptions = [];
                /*for (let i = 0; i < lang.length; i++) {
                    let option = {
                        label: result.lstPreferredLanguageValues[lang[i]].strLabel,
                        value: result.lstPreferredLanguageValues[lang[i]].strValue
                    };
                    langoptions = [...langoptions, option];
                }
                this.preferredLanguagePicklistValues = langoptions;*/


                //----------------------------------------------------------
                //-----------------------START------------------------------
                //----------------------------------------------------------
                for (let i = 0; i < keys.length; i++) {
                    if(result.lstPreferredLanguageValues[keys[i]] !== null && result.lstPreferredLanguageValues[keys[i]] !== undefined){
                        if(result.lstPreferredLanguageValues[keys[i]].strValue === "ENG"){
                            let option = {
                                label: result.lstPreferredLanguageValues[keys[i]].strLabel,
                                value: result.lstPreferredLanguageValues[keys[i]].strValue
                            };
                            langoptions[0] = option;
                        }else if(result.lstPreferredLanguageValues[keys[i]].strValue !== "ENG"){
                            let option = {
                                label: result.lstPreferredLanguageValues[keys[i]].strLabel,
                                value: result.lstPreferredLanguageValues[keys[i]].strValue
                            };
                            langoptions[j] = option;
                            j++;
                        }
                    }
                }
                this.preferredLanguagePicklistValues = langoptions;
                //---------------------------------------------------------
                //-----------------------END-------------------------------
                //---------------------------------------------------------


            })
            .catch(error => {
                this.isLoading = false;
                this.errMessage = JSON.stringify(error);
                console.log("Error" + JSON.stringify(error))
            });

    }

    closeModal() {
        this.showModal = false;
        var evt = new CustomEvent('closemodalevent');
        this.dispatchEvent(evt);
    }

    onChange(event) {

        //console.log("picklist value --> "+event.target.value);
        var keyValue;
        if (event.target.name == 'lastname') {
            keyValue=event.target.dataset.targetId;
            this.newContact[keyValue].LastName = event.target.value;
           
        }
        if (event.target.name == 'firstname') {
            keyValue=event.target.dataset.targetId;
            this.newContact[keyValue].FirstName = event.target.value;
            
        }
        if (event.target.name == 'email') {
            keyValue=event.target.dataset.targetId;
            this.newContact[keyValue].Email = event.target.value;
            
        }
        if (event.target.name == 'Country') {
            keyValue=event.target.dataset.targetId;
            this.newContact[keyValue].MailingCountry = event.target.value;
        }
        if (event.target.name == 'Preferred Language') {
            keyValue=event.target.dataset.targetId;
            this.newContact[keyValue].Core_Preferred_Language__c = event.target.value;
        }
        
    }

    submitDetails() {
        

        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const allcomboValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid && allcomboValid && this.newContact.MailingCountry != '') {

            this.isLoading = true;
            createContact({
                con: this.newContact,
                loggedInUserId: userId
            })
                .then(result => {
                    this.isLoading = false;

                    if (result.status === 'success' && result.message === 'Invite sent successfully') {
                        const event = new ShowToastEvent({
                            title: this.label.EPUM_ContactSuccess,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        console.log('contact creation' + JSON.stringify(result));

                        this.dispatchEvent(event);
                        this.closeModal();
                        this.navigateToWebPage();
                    } else {
                        this.errMessage = result.message;
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    this.errMessage = JSON.stringify(error);
                    console.log("Error" + JSON.stringify(error))
                });
        } else {
            this.errMessage = this.label.EPUM_FielsSelectionErrorMsg;
        }
    }

    navigateToWebPage() {
        window.location.reload();
    }

    //




    keyIndex = 0;
    @track itemList = [
        {
            id: 0
        }
    ];

    addRow() {
        this.rowData.push(this.newContact);
        
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
        var RowItemList = this.newContact;
        RowItemList.push({
            'sobjectType': 'Contact',
            'Email': '',
            'FirstName': '',
            'LastName': '',
            'MailingCountry': '',
            'Core_Preferred_Language__c': 'ENG'
        });
        // set the updated list to attribute (contactList) again    
        this.newContact= RowItemList;
    }

    removeRow(event) {
        var keyValue=event.target.accessKey;
       
        this.newContact[keyValue].FirstName='';
        this.newContact[keyValue].LastName='';
        
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    handleSubmit() {
        var tempdata=[];
        for(var i=0;i<this.newContact.length;i++){
            if(!(this.newContact[i].LastName==='' && this.newContact[i].FirstName=='')){
                    tempdata.push(this.newContact[i]);
            }

        }
        this.newContact=tempdata;

        createContacts({Conts:this.newContact,loggedInUserId:userId}).then(data=>{
             console.log(JSON.stringify(data));
        }).catch(error=>{
            console.log(JSON.stringify(error));
        })
        
        /*var isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if (isVal) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contacts successfully created',
                    variant: 'success',
                }),
            );
            // Navigate to the Account home page
           /* this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Contact',
                    actionName: 'home',
                },
            });*/

       /* } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please enter all the required fields',
                    variant: 'error',
                }),
            );
        }*/
    }

}