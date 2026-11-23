import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDeflectedObject from '@salesforce/apex/Core_IPS_DeflectedObject_LWC_Ctrl.createDeflectedObject';


export default class Core_IPS_CaseCreate_LWC extends NavigationMixin(LightningElement) {
    @track showcasedetails_form1 = true;
    @track showcheckAnswers_form2 = false;
    @track showcaseCreation_form3 = false;
    @track hideButton = false;
    @api successMsg;
    @api assetId; //assetId from body component
    @api assetName; //assetName from body component
    @api project;
    caseInfoStringfy;
    @api deflectedid;
    communityCheck = true;


    connectedCallback() {
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.assetId = newURL.get('assetId');
        this.assetName = newURL.get('assetName');
        this.project = {
            Id: this.assetId,
            Name: this.assetName
        }
    }

    renderedCallback() {
        //console.log('assetId from bodycomponetrenderedCallback---'+this.recordId);

    }
    @api recordId;
    @api caseInfo = {
        "project": undefined,
        "projectName": undefined,
        "productvariant": undefined,
        "productvariantName": undefined,
        "Product": undefined,
        "ProductName": undefined,
        "Subject": undefined,
        "CategoryId": undefined,
        "CategoryName": undefined,
        "SubCategoryId": undefined,
        "SubCategoryName": undefined,
        "Language": undefined,
        "NickName": undefined,
        "testQuestion": undefined,
        "picklistQuestion": undefined,
        "childQuestion1": undefined,
        "childQuestion2": undefined,
        "prodEdqRecs": undefined,
        "showProdEdqs": undefined,
        "showEdqSection": undefined,
        "contactId ": undefined,
        "accountId": undefined,
    };

    @api casedatafromform3 = {
        "subject": undefined,
        "description": undefined,
        "caseType": undefined,
        "caseseverity": undefined,
        "custmerreference": undefined,
        "endcustomer": undefined
    };
    handleNavigateform1toform2() {
        const topDiv = this.template.querySelector('[data-id="redDiv"]');
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
        if (this.caseInfo.project == undefined || this.caseInfo.Product == undefined || this.caseInfo.Subject == undefined || this.caseInfo.Language == undefined) {
            const evt = new ShowToastEvent({
                title: 'Alert !!',
                message: 'Please fill in the Required Fields',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.showcheckAnswers_form2 = false;
            this.showcasedetails_form1 = true;
        } else {
            this.storeingInDeflected();
            this.showcheckAnswers_form2 = true;
            this.showcasedetails_form1 = false;
        }
    }

    //minhaj
    storeingInDeflected(){
         
        this.caseInfoStringfy = JSON.stringify(this.caseInfo);
        console.log("string JSON>>>>" + this.caseInfoStringfy);
       createDeflectedObject({caseInfo:this.caseInfoStringfy})
       .then(result =>{
           this.deflectedid = result;
           console.log('deflectedid variable>>>>>>>'+this.deflectedid);
       })
       .catch( error => {
           console.log("Error in apex createDeflectedObject");
           console.log(error);
       })
   }

   

    handleNavigateBackfrom1toHome() {
        console.log('inside handleNavigateBackfrom1toHome');
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    handleNavigatefrom2tofrom3() {
        console.log('inside form2');
        const topDiv = this.template.querySelector('[data-id="yellowDiv"]');
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
        this.showcaseCreation_form3 = true;
        this.showcheckAnswers_form2 = false;
        this.hideButton = true;
    }
    handleNavigateBackfrom2tofrom1() {
        console.log('inside handleNavigateBackfrom2tofrom1');
        this.showcheckAnswers_form2 = false;
        this.showcasedetails_form1 = true;
    }
    handleNavigateBackfrom3tofrom2() {
            console.log('inside handleNavigateBackfrom3tofrom2');
            this.showcaseCreation_form3 = false;
            this.showcheckAnswers_form2 = true;
            this.hideButton = false;
        }
        //custom event handler that gets all data from CaseCreation_form1 Component
    handlecaseEventData(event) {
        this.caseInfo = {
            "project": event.detail.project,
            "projectName": event.detail.projectName,
            "Product": event.detail.Product,
            "ProductName": event.detail.ProductName,
            "productvariant": event.detail.productvariant,
            "productvariantName": event.detail.productvariantName,
            "CategoryId": event.detail.CategoryId,
            "CategoryName": event.detail.CategoryName,
            "SubCategoryId": event.detail.SubCategoryId,
            "SubCategoryName": event.detail.SubCategoryName,
            "Subject": event.detail.subject,
            "Language": event.detail.language,
            "prodEdqRecs": event.detail.prodEdqRecs,
            "showProdEdqs": event.detail.showProdEdqs,
            "showEdqSection": event.detail.showEdqSection,
            "contactId": event.detail.contactId,
            "accountId": event.detail.accountId
        };
        console.log('Anil this.caseInfo---', JSON.stringify(this.caseInfo));
        console.log('Anil this.caseInfo prodEdqRecs---', JSON.stringify(this.caseInfo.prodEdqRecs));
        /* for(let key in this.caseInfo.prodEdqRecs){
            console.log(`${key} prodEdqRecs---> ${this.caseInfo.prodEdqRecs[key]}`);
        } */
    }
    @api subCatRecEdqs;
    @api showSubCatEdqs;
    handlecateedq(event) {
        console.log('handlecateedq', JSON.stringify(event.detail));
        this.subCatRecEdqs = event.detail.firstParam;
        this.showSubCatEdqs = event.detail.secondParam;
        console.log('ANil this.subCatRecEdqs', JSON.stringify(this.subCatRecEdqs));
    }
    @api sslcmode;
    handlemode(event) {
        console.log('handlemode----', JSON.stringify(event.detail));
        this.sslcmode = event.detail.firstParam;
    }
    handlecasedataform3(event) {
        console.log("handlecasedataform3 method called");
        this.casedatafromform3 = {
            "subject": event.detail.subject,
            "description": event.detail.description,
            "caseType": event.detail.caseType,
            "caseseverity": event.detail.caseseverity,
            "custmerreference": event.detail.custmerreference,
            "endcustomer": event.detail.endcustomer
        };
        console.log('this.casedatafromform3---', JSON.stringify(this.casedatafromform3));
    }
}