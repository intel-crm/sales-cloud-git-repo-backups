import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchInitialData from "@salesforce/apex/PRM_CIMAccountSearchNew.performsearch";


export default class Prm_SelfReg extends LightningElement {

    emailValue;
    firstNameValue;
    lastNameValue;
    countryValue;
    accountName;
    website;
    isSpinner;
    showpage1 = true;
    showexpand = false;
    showpage2 = false;
    resultobj  = [];
    actions = [
        { label: 'Select', name: 'selectThis' },
    ];
    columns = [
        { label: 'AccountName', fieldName: 'AccountName', type: 'text' },
        { label: 'IPABadge', fieldName: 'IPABadge', type: 'text' },
        { label: 'AccountAddress', fieldName: 'AccountAddress', type: 'text' },
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions }
        }
    ];
    
    handleInputEmailChange(event){
        this.emailValue = event.target.value;
    }

    handleInputFirstNameChange(event){
        this.firstNameValue = event.target.value;
    } 
    
    handleInputLastnameChange(event){
        this.lastNameValue = event.target.value;
    }

    handleInputCountry(event){
        this.countryValue = event.target.value;
    }

    handleAccName(event){
        this.accountName = event.target.value;
    }

    handleWebsite(event){
        this.website = event.target.value;
    }
    handleExpandClick(){
        var countryName = {};
        this.isSpinner = true;
        
        countryName.CountryCode2 = this.countryValue;
        
        console.log('>>>>'+JSON.stringify(countryName));
        fetchInitialData({
            accountName: this.accountName,accountAddress1: JSON.stringify(countryName),
            accountURL: this.website,bizOrgType: null,
            emailAddress: null,searchLimit: '10',
            minimumSearchScore: '1' })
        .then((result1) => {
          this.showexpand = true;
          if (!result1) {
            const evt = new ShowToastEvent({
              title: "Error",
              message: "No matching account with this domain. Please click on expand search.",
              variant: "error"
            });
            
            this.dispatchEvent(evt);
            //this.closeAction();
            
          } else {
            console.log('>>result1'+result1);
            this.resultobj = [];
            this.resultobj = JSON.parse(result1).SearchResults;
            console.log(JSON.stringify(this.resultobj));
            if(this.resultobj){
                this.resultobj.forEach(rec =>{
                    var addressrec = [rec.AccountAddress.AddressLine1, rec.AccountAddress.AddressLine2, rec.AccountAddress.City,rec.AccountAddress.StateCode2,
                    rec.AccountAddress.PostalCode,rec.AccountAddress.CountryCode2].filter(Boolean).join(", ");
                    rec.AccountAddress = addressrec;
                });
            }else{
                this.resultobj = JSON.parse(result1);
                console.log('>>>>error'+JSON.stringify(this.resultobj));
            }
          }
          this.isSpinner = false;
        })
        .catch((error1) => {
          this.isSpinner = false;
          console.log(">>>>resultiner" + JSON.stringify(error1));
        });
    }
    handleClick(){
        var countryName = {};
        this.isSpinner = true;
        
        countryName.CountryCode2 = this.countryValue;
        
        console.log('>>>>'+JSON.stringify(countryName));
        fetchInitialData({
            accountName: null,accountAddress1: JSON.stringify(countryName),
            accountURL: null,bizOrgType: null,
            emailAddress: this.emailValue,searchLimit: '10',
            minimumSearchScore: '1' })
        .then((result1) => {
          this.showexpand = true;
          if (!result1) {
            const evt = new ShowToastEvent({
              title: "Error",
              message: "No matching account with this domain. Please click on expand search.",
              variant: "error"
            });
            this.dispatchEvent(evt);
            this.showpage2 = true;
            this.showpage1 = false;
            //this.closeAction();
          } else {
            console.log('>>result1'+result1);
            this.resultobj = [];
            this.resultobj = JSON.parse(result1).SearchResults;
            if(this.resultobj){
                this.resultobj.forEach(rec =>{
                    var addressrec = [rec.AccountAddress.AddressLine1, rec.AccountAddress.AddressLine2, rec.AccountAddress.City,rec.AccountAddress.StateCode2,
                    rec.AccountAddress.PostalCode,rec.AccountAddress.CountryCode2].filter(Boolean).join(", ");
                    rec.AccountAddress = addressrec;
                });
            }else{
                this.resultobj = JSON.parse(result1);
                console.log('>>>>error'+this.resultobj);
            }
            this.showpage2 = true;
            this.showpage1 = false;
          }
          this.isSpinner = false;
        })
        .catch((error1) => {
          this.isSpinner = false;
          console.log(">>>>resultiner" + JSON.stringify(error1));
        });

    }
    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'selectThis':
            const evt = new ShowToastEvent({
            title: "Selected Account",
            message: "You have selected "+JSON.stringify(row.AccountName),
            variant: "success"
            });
            this.dispatchEvent(evt);
            break;
            default:
        }
    }

}