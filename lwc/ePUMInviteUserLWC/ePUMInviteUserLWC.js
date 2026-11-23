import { LightningElement, api, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import fetchContactPickListValues from '@salesforce/apex/EPUM_SearchContact.fetchContactPickListValues';
import createContact from '@salesforce/apex/EPUM_SearchContact.createContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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
import PRM_Embargoed_country from '@salesforce/label/c.PRM_Embargoed_country';
import EPUM_RestrctdContriesErrmsg from '@salesforce/label/c.EPUM_RestrictedCountriesErrMsg';
import EPUM_IntelDomainMail from '@salesforce/label/c.EPUM_IntelDomainMail';
import EPUM_WebsiteMandatory from '@salesforce/label/c.EPUM_WebsiteMandatory';
import styleResource from '@salesforce/resourceUrl/IpaResources';
import sendReInvite from '@salesforce/apex/EPUM_SearchContact.sendReInvite';


export default class EPUMInviteUserLWC extends LightningElement {

    
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
        EPUM_SelectOption,
        PRM_Embargoed_country,
        EPUM_RestrctdContriesErrmsg,
        EPUM_IntelDomainMail,
        EPUM_WebsiteMandatory
    };

    @api showModal;
    @api searchedEmail;
    @track errMessage = '';
    @track apexErrMessage = '';
    @track countryPicklistValues;
    @track preferredLanguagePicklistValues;
    @track isLoading = true;
   //ResCntryValues =["CUB","PRK","IRN","SDN","SYR","Crimea region of Ukraine"];
    @track ResCntryValues;
    @track buttonDisable=false;
    @track ResCntryValuesErrmsg=false;
    //@track showErrimage=false;
    @track newContact = {
        'sobjectType': 'Contact',
        'Email': this.searchedEmail,
        'FirstName': '',
        'LastName': '',
        'MailingCountry': '',
        'Core_Preferred_Language__c': 'ENG'
    }

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
        var evt = new CustomEvent('closemodalevent',{
            detail: {
                changeModal: this.showModal
            }
        });
        this.dispatchEvent(evt);
    }

    onChange(event) {
         
        console.log("picklist value --> "+event.target.value);
        
        if (event.target.name == 'lastname') {
            this.newContact.LastName = event.target.value;
        }
        if (event.target.name == 'firstname') 
        {
            this.newContact.FirstName = event.target.value;
        }
        if (event.target.name == 'email') 
        {
            this.newContact.Email = event.target.value;
            //var inputCmp = this.template.querySelector(".inputfield"); //getting element
            let domainCheck = this.newContact.Email.split("@")[1];
            if (domainCheck == "intel.com"){ 
                event.target.setCustomValidity(this.label.EPUM_IntelDomainMail);
                document.getElementById('e').focus();
                return false;
            } else {
                //Removing validation error
                event.target.setCustomValidity(""); // if there was a custom error before, reset it
                returnvalue = event.target.value;
            }
        }
        if (event.target.name == 'Country') 
        {
 
    /*---------  DRACO - To restrict Embargo countries to submit invitation @ 22/1/2021 - Praveena start -----------*/
    
    this.ResCntryValues=this.label.PRM_Embargoed_country.split(',');


        if (this.ResCntryValues.indexOf(event.target.value)>-1)
            { 
                //alert(event.target.value);
                this.buttonDisable=true;
                this.ResCntryValuesErrmsg=false;
                this.errMessage = this.label.EPUM_RestrctdContriesErrmsg;
                //alert(this.buttonDisable);
                //this.dispatchEvent(event);
           
            }
            else 
            {
                this.buttonDisable=false;
                this.ResCntryValuesErrmsg=false;
                this.newContact.MailingCountry = event.target.value; 
                this.errMessage = '';
            }
        /*--------- DRACO - To restrict Embargo countries to submit invitation @ 22/1/2021 - Praveena end --------------*/
        }
        if (event.target.name == 'Preferred Language') 
        {
            this.newContact.Core_Preferred_Language__c = event.target.value;
        }
    }
    submitDetails() {
        //console.log("this.newContact --> "+json.stringify(this.newContact));
        console.log(this.newContact);
    
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
       // if (allValid && allcomboValid && this.newContact.MailingCountry != '' && this.newContact.MailingCountry !=this.ResCntryValues) {
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
                        //this.errMessage = result.message;
                        this.apexErrMessage = result.message;
                        if(this.apexErrMessage.includes("Website is mandatory for extending invite")){
                            this.errMessage = this.label.EPUM_WebsiteMandatory;
                        } 
                        else if(this.apexErrMessage.includes("This registration was denied because the registrant identified their location as an embargoed country or their IP address is from an embargoed country.")){
                            this.errMessage = this.label.EPUM_RestrictedCountriesErrMsg;
                        }else{
                            this.errMessage = result.message;
                        }
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

    @api sendInvitetoUser(conDetails){
        let cEmail = conDetails.Email;
        sendReInvite({
            cEmail: cEmail
        }).then(result => {
            this.isLoading = false;
                    console.log('return');
                    console.log(result);
                    console.log(result.message);
                    if (result.status === 'success' /*&& result.message === 'Invite sent successfully'*/) {//subhadeep change result.message
                        console.log('inside result success');
                        const event = new ShowToastEvent({
                            title: 'Invitation sent successfully',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        console.log('invitation sent' + JSON.stringify(result));

                        this.dispatchEvent(event);

                        var evt = new CustomEvent('closemodalevent',{
                            detail: {
                                sendInvStatus: true
                            }
                        });
                        this.dispatchEvent(evt);
                        /*this.closeModal();
                        this.navigateToWebPage();*/
                    } else {
                        this.errMessage = result.message;
                    }
        })
    }
}