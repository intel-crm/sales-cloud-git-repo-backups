import { LightningElement, api,track } from 'lwc';
//import getFieldSet from '@salesforce/apex/UCD_GenericAcctSearch.getFieldSet';
import searchRecords from '@salesforce/apex/UCD_GenericAcctSearch.getAcctResults';
import fetchIdentifiers from "@salesforce/apex/UCD_GenericAcctSearch.fetchIdentifiers";

export default class objectClone extends LightningElement {
   
    @api objectApiName;
    @api fieldSetName;
    @track fieldSetFields = [];
    @track draftValues;
    @track searchList =[];
    @track searchResult =[];

    @track columns = [];
    @track showResult = false;


   /* connectedCallback(){
        console.log('INSIDE');
        getFieldSet({objectApiName: 'Account', fieldSetName: 'UCD_SearchField'})
         //getFieldSet({objectApiName: this.objectApiName, fieldSetName: this.fieldSetName})
        .then(result => {
            this.fieldSetFields = result;
            console.log('********'+JSON.stringify(result));
            console.log('********'+JSON.stringify(result.data));
        })
        .catch(error => {
            this.error = error;
            console.log('123'+JSON.stringify(error));
        });
    }*/
    @track idata=[];
    connectedCallback(){
        fetchIdentifiers ()
        .then((response) => {
            this.idata = response;
            console.log('1111'+JSON.stringify(this.idata));
           /* for (let i = 0; i < this.idata.length; i++) {
                this.identifiers.push({ label: this.idata[i].UI_Label__c, value: this.idata[i].UI_Label__c},)
            }
            this.identifiers.push({label: 'Contacts Associated', value: 'Contacts'});*/
        })
        .catch((error) => {
            console.log('&&&&&'+JSON.stringify(error));
        });
    }

    search(){
        this.searchList =[];
        let selectedRows = this.template.querySelectorAll('lightning-input');  
        for(let i=0;i<selectedRows.length;i++){
            let searchValues = {
               fieldLabel : " ",
               fieldAPIName : "",
               fieldValue :""
           };
                    
                searchValues.fieldAPIName = selectedRows[i].name;
                searchValues.fieldLabel = selectedRows[i].label;
            if(selectedRows[i].value !== ''){
                searchValues.fieldValue = selectedRows[i].value;
           }  
           this.searchList.push(searchValues);
           this.columns.push({label:selectedRows[i].label, fieldName:selectedRows[i].name})
       }       
        console.log('********'+JSON.stringify(this.columns));

        searchRecords({fDetails :  this.searchList, objectApiName: 'Account'})
                .then(result => {
                    this.searchResult = result;
                    this.showResult = true;
                    console.log('123'+JSON.stringify(result));
                })
                .catch(error => {
                    console.log('123'+JSON.stringify(error));
                });
    }


  /*  @api sysId = '202';
    theIframe;

    get fullUrl() {

    return `https://www.adobe.com`;
    }

    @api isReloaded = false;


renderedCallback() {
    console.log('rendred callback called' + this.theIframe);
        if(this.theIframe==undefined){
            this.theIframe =  this.template.querySelector('iframe');
            this.theIframe.onload = ()=>{
                console.log('Onload called'+this.isReloaded);

                if(!this.isReloaded){
                    this.isReloaded = true;
                    this.theIframe.src = this.theIframe.src ;

                }
            }
        }   

    }

    @api url;
    loading = false;

   
    connectedCallback() {
        this.loading = true;
    }

   
    renderedCallback() {

        const spinnerContainer = this.template.querySelector('.slds-spinner_container');
        const containerElem = this.template.querySelector('.iframe-container');
        const iframe = document.createElement('iframe');

        // onload() before setting 'src'
        iframe.onload = function() {
            console.log('iframe is loaded');
            spinnerContainer.classList.add("slds-hide"); // hide spinner
        };
        iframe.src = `https://www.adobe.com`; // iFrame src; add this URL to CSP
        iframe.id = 'iframe-1';
        iframe.width = '100%';
        iframe.setAttribute('frameborder', '0');

        containerElem.appendChild(iframe); // add iFrame to DOM
    }*/

}