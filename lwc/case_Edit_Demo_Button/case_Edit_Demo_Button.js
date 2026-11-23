import { api, LightningElement, track, wire } from 'lwc';
import getCurrentCase from '@salesforce/apex/Core_IPS_TestAllRecords.getCurrentCase';
import getCurrentCaseComments from '@salesforce/apex/Core_IPS_TestAllRecords.getCurrentCaseComments';
import getattachments from '@salesforce/apex/Core_IPS_TestAllRecords.getattachments';
import retriveCaseData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.geCloneCaseDetails'; //Anil Case Copy
import getCaseData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.getCaseDetails'; //Anil Case Copy
import displayProductVariant from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.displayProductVariant'; //Anil Case Copy
import displaySubCategoryData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.displaySubCategoryData'; //Anil Case Copy
import displayCategoryData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.displayCategoryData'; //Anil Case Copy
import getBaseUrlToLoadIframePage from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.getBaseUrlToLoadIframePage'; //Anil Case Copy
import insertCaseData from "@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.insertCaseData";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/Core_IPS_TestAllRecords.uploadFile';
import getCaseClosed from '@salesforce/apex/Core_IPS_TestAllRecords.getCaseClosed';
import saveNewComment from '@salesforce/apex/Core_IPS_TestAllRecords.saveNewComment'; 
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
const attachmentcolumns = [
    { label: 'File Name', fieldName: 'Title', type: 'text' },
    { label: 'Description', fieldName: 'Description', type: 'text' },
    { label: 'File Size', fieldName: 'ContentSize', type: 'number' },
    {
        label: 'Download',
        type: 'button-icon',
        initialWidth: 135,
        typeAttributes: { iconName: 'utility:download', name: 'download_file', title: 'Click to download' }
    },
    { label: 'Upload Status', fieldName: 'Upload Status', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
];
export default class Core_IPS_CaseDetail_LWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @api selectedRecordId;
    @track showmaincmp = true;
    @track showCopycmp = false;
    @track selectedItem = 'caseComments';
    caseComments = false;
    caseInformation = false;
    isCaseClosed = false;
    environment = false;
    attachments = false;
    interestedParties = false;
    columns = attachmentcolumns;
    @track attachmentRecords;
    attachmentInitialRecords;
    @track attachmentData;
    fileData
    @track ccCommentValue;
    connectedCallback() {
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        // eslint-disable-next-line no-console
        console.log('id ===> ' + newURL.get('recordId'));
        this.recordId = newURL.get('recordId');
        console.log('recordId--' + this.recordId);


    }
    renderedCallback() {
        console.log('recordId renderedCallback--' + this.recordId);
    }
    handleKeyChange(event) {
        console.log(event.detail.name);

    }
    handleSelect(event) {
        const selected = event.target.value;
        if (selected == 'caseComments') {
            this.caseComments = true;
        }
        else {
            this.caseComments = false;
        }
        if (selected == 'caseInformation') {
            this.caseInformation = true;
        } else {
            this.caseInformation = false;
        }
        if (selected == 'environment') {
            this.environment = true;
        } else {
            this.environment = false;
        }
        if (selected == 'attachments') {
            this.attachments = true;
            this.getAttach();
        } else {
            this.attachments = false;
        }
        if (selected == 'interestedParties') {
            this.interestedParties = true;
        } else {
            this.interestedParties = false;
        }
    }

    @track isModalOpen = false;
    openCsModal() {
        this.isModalOpen = true;
    }
    closeCsModal() {
        this.isModalOpen = false;
    }
    closeTheCase() {
        getCaseClosed({ caseId: this.recordId })
            .then((result) => {
                if (result =='error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Case Cannot be Updated',
                            variant: 'error'
                        }),
                    );
                } else {
                    window.open("case-detail?recordId=" + this.recordId, "_self");
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Case Record Update Successful',
                            variant: 'success'
                        }),
                    );
                }

            })
            .catch((error) => {
                this.error = error;
            });
        this.isModalOpen = false;
    }
    @track isEditCase = false;
    openEditModal() {
        this.isEditCase = true;
    }
    closeEditModal() {
        this.isEditCase = false;
    }
    submitDetails() {
        this.isEditCase = false;
    }

    //calling apex method for current case data
    @track currentCaseData;
    /*   curCaseRecId = this.recordId;
      getCurCase() {
         console.log('This is record Id',this.recordId);
         getCurrentCase({ csId: this.recordId })
             .then((result) => {
                 this.currentCaseData = result;
                 console.log('CURRENT CASE',this.currentCaseData);
                 console.log('CURRENT CASE',result);
                 this.error = undefined;
             })
             .catch((error) => {
                 this.error = error;
                 this.currentCaseData = undefined;
             });
     }   */

    @wire(getCurrentCase, { csId: '$recordId' })
    getCurCase({ error, data }) {
        if (data) {
            let cData = JSON.parse(JSON.stringify(data));
            this.currentCaseData = cData;
            if (cData.Status == 'Closed' || cData.Core_IPS_GEC_Flag__c == true) {
                this.isCaseClosed = true;
                console.log('THIS CASE IS CLOSED ', cData.Status);
            }
            console.log('CURRENT CASE', cData);
            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.currentCaseData = undefined;
        }
    }
    //calling apex method for current case comments data
    @track currentCaseComments;
    initialCaseComments;
    /*  getCurCaseCmts() {
         getCurrentCaseComments({ csId: this.recordId })
             .then((result) => {
                 this.currentCaseComments = result;
                 this.initialCaseComments = result;
                 console.log('CURRENT Comments',this.currentCaseComments);
                 console.log('CURRENT Comments',result);
                 this.error = undefined;
             })
             .catch((error) => {
                 this.error = error;
                 this.currentCaseComments = undefined;
             });
     } */

    @wire(getCurrentCaseComments, { csId: '$recordId' })
    getCurCaseCmts({ error, data }) {
        if (data) {
            this.currentCaseComments = data;
            this.initialCaseComments = data;
            console.log('CURRENT Comments', this.currentCaseComments);
            console.log('CURRENT Comments', data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.currentCaseComments = undefined;
        }
    }
    //comment search
    handleCommentSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.currentCaseComments = this.initialCaseComments;
            if (this.currentCaseComments) {
                let recs = [];
                for (let rec of this.currentCaseComments) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.currentCaseComments = recs;
            }
        } else {
            this.currentCaseComments = this.initialCaseComments;
        }
    }
    //back button navigation
    handleNavigateBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

    caseCmtSection = true;
    newCommentBtn(event) {
        if(event.target.name="newCommentBtn"){
            this.caseCmtSection = false;
        }else{
            this.caseCmtSection = true;
        }
        console.log('New Comment Btn');
    }
    get commentOptions() {
        return [
            { label: 'Public to Customers', value: 'Public to Customers' },
            { label: 'Private to Partner', value: 'Private to Partner' },
            { label: 'Private to Intel', value: 'Private to Intel' },
            { label: 'Private to Agents', value: 'Private to Agents' },
        ];
    }

    @track PublictoCustomers = false;
    @track PrivatetoPartner = false;
    @track PrivatetoIntel = true;
    @track PrivatetoAgents = false;
    commentValue = 'Private to Intel';
    handleRadioChange(event){
        const selectedOption = event.detail.value;
        console.log('selectedOption ' + selectedOption);
        if (selectedOption == 'Public to Customers'){
            this.PublictoCustomers = true;
        }else{
            this.PublictoCustomers = false;
        }
        if (selectedOption == 'Private to Partner'){
            this.PrivatetoPartner = true;
        }else{
            this.PrivatetoPartner = false;
        }
        if (selectedOption == 'Private to Intel'){
            this.PrivatetoIntel = true;
        }else{
            this.PrivatetoIntel = false;
        }
        if (selectedOption == 'Private to Agents'){
            this.PrivatetoAgents = true;
        }else{
            this.PrivatetoAgents = false;
        }
        
    }
    getCommentValue(event) {
        this.ccCommentValue = event.target.value;
        console.log('CaseComment Method ', this.ccCommentValue);
    }
    //@track testVisible = 'Public to Customers';
    sendCommentBtn() {
        saveNewComment({ csId: this.recordId, visibility : this.ccCommentValue , comment: this.ccCommentValue })
            .then((result) => {
                console.log('THIS case Comment RESULT ', result);

                if (result === 'error' || result == 'error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Comment Cannot be Added',
                            variant: 'error'
                        }),
                    );
                } else {
                    window.open("case-detail?recordId=" + this.recordId, "_self");
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Comment Added Successfully',
                            variant: 'success'
                        }),
                    );
                }

            })
            .catch((error) => {
                this.error = error;
            });
        this.caseCmtSection = true;
        console.log('Send Comment Btn');
    }


    /*----------------*/
    getAttach() {
        getattachments()
            .then(result => {
                this.attachmentRecords = result;
                console.log('attachmentreuslt@@@', result);
                this.attachmentInitialRecords = result;
                this.attachmentData = result;
                console.log('attachments data', this.attachmentData);
                this.showTable = true;
            })
            .catch(error => {
                this.error = error;
                console.log('Case Error ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Cases',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.attachmentRecords = undefined;
                this.attachmentInitialRecords = undefined;
            });

    }

    get CaseTypeOptions() {
        return [
            { label: "Question", value: "Question" },
            { label: "Design Review", value: "Design Review" },
            { label: "Feature Request", value: "Feature Request" },
            { label: "Debug Request", value: "Debug Request" },
        ];
    }

    severityValue = 'Medium';
    get caseSeverityoptions() {
        return [
            { label: "Low", value: "Low" },
            { label: "Medium", value: "Medium" },
            { label: "High", value: "High" },
            { label: "Critical", value: "Critical" },
        ];
    }

    OEMValue = 'No';
    get OEMOptions() {
        return [
            { label: "Yes", value: "Yes" },
            { label: "No", value: "No" },
        ];
    }


    //attachment search
    attachmentsearchbox(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.attachmentData = this.attachmentInitialRecords;
            if (this.attachmentData) {
                let recs = [];
                for (let rec of this.attachmentData) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.attachmentData = recs;
            }
        } else {
            this.attachmentData = this.attachmentInitialRecords;
        }
    }

    attachfilesection = true;
    attachhandleClick() {
        this.attachfilesection = false;
    }

    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }
    submit() {
        const { base64, filename, recordId } = this.fileData
        uploadFile({ base64, filename, recordId }).then(result => {
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
        this.attachfilesection = true;
    }
    /*Anil Start*/
    @api clonedCase;
    @api errorMsg;
    @api subject;
    @api caseDescription;
    @api severity;
    @api caseType;
    @api customerReferenceID;
    @api endcustomer;
    @api endCustomer;
    @api contactId;
    @api projectName;
    @api ProductName;
    @api productvariantName;
    @api caseProductVariantOptions;
    @api CaseSubcategoryoptions;
    @api CaseCategoryoptions;
    @api error;
    @api getdatafromwire;
    @api caseIssueCategoryId;
    @api caseIssueSubCategoryId;
    @api selectedProductId;
    @api prodId;
    @api CategoryName;
    @api SubCategoryName;
    @api caseinsertion;
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
        "childQuestion2": undefined
    };
    @wire(getCaseData, { recId: '$recordId' })
    getCase({ error, data }) {
        if (data) {
            //let cData = JSON.parse(JSON.stringify(data));
            //console.log('result stringfy--'+JSON.stringify(data));
            this.getdatafromwire = data[0];
            //console.log('result stringfy--'+JSON.stringify(this.getdatafromwire));
            for (let key in this.getdatafromwire) {
                if (key == 'Core_Product_Variant__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.productvariantName = this.getdatafromwire[key];
                    }
                }
                if (key == 'AssetId') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.selectedProductId = this.getdatafromwire[key];
                    }
                }
                if (key == 'Core_Case_Issue_Category__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.caseIssueCategoryId = this.getdatafromwire[key];
                    }
                }
                if (key == 'Core_Case_Issue_Sub_Category__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.caseIssueSubCategoryId = this.getdatafromwire[key];
                    }
                }
                if (key == 'Core_IPS_Supported_Product__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.prodId = this.getdatafromwire[key];
                    }
                }
            }
        } else if (error) {
            console.log('error--' + this.error);
        }
    }
    showCopy() {
        //alert('recordId--'+this.recordId);
        this.showmaincmp = false;
        this.showCopycmp = true;
        this.getcloneCaseData();
        this.getproductVariants();
        this.getsubcategoryData();
        this.getcategoryData();
        console.log('selectedProductId res--' + this.selectedProductId);
        console.log('caseIssueCategoryId res--' + this.caseIssueCategoryId);
        console.log('caseIssueSubCategoryId res--' + this.caseIssueSubCategoryId);
        console.log('prodId res--' + this.prodId);
    }
    gobackToCase() {
        this.showmaincmp = true;
        this.showCopycmp = false;
    }
    //Call Apex clone Method
    getcloneCaseData() {
        retriveCaseData({ recId: this.recordId })
            .then(result => {
                if (result != '' && result != undefined && result != null) {
                    //console.log('result--'+JSON.stringify(result));
                    this.caseinsertion = result;
                    this.clonedCase = result[0];
                    //console.log('result cloned case 0 without stringify--'+this.clonedCase);
                    console.log('result cloned case 0 with stringify--' + JSON.stringify(this.clonedCase));
                    for (let key in this.clonedCase) {
                        // console.log(`${key} key---> ${this.clonedCase[key]}`);
                        if (key == 'ContactId') {
                            if (this.clonedCase[key] != undefined) {
                                this.contactId = this.clonedCase[key];
                            }
                        }
                        if (key == 'Subject') {
                            if (this.clonedCase[key] != undefined) {
                                this.subject = this.clonedCase[key];
                                // this.caseInfo.Subject = this.subject;
                                this.caseInfo["Subject"] = this.subject;
                            }
                        }
                        if (key == 'Core_Severity__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.severity = this.clonedCase[key];
                            }
                        }
                        if (key == 'Description') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseDescription = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_CaseType__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseType = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_IPS_Product_name__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.ProductName = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_IPS_Project_Case__r') {
                            if (this.clonedCase[key] != undefined) {
                                //this.projectName = this.clonedCase[key];
                                //console.log('projectName without stringfy--'+this.clonedCase[key]);
                                // console.log('projectName with stringfy--'+JSON.stringify(this.clonedCase[key]));
                                for (let innerkey in this.clonedCase[key]) {
                                    //console.log(`${innerkey} projectName---> ${this.clonedCase[key][innerkey]}`);
                                    if (innerkey == 'Name') {
                                        this.projectName = this.clonedCase[key][innerkey];
                                    }
                                    if (innerkey == 'Id') {
                                    }
                                }
                            }
                        }
                        //shifted to wire method
                        /* if(key == 'Core_Product_Variant__c'){
                            if(this.clonedCase[key] != undefined ){
                                this.productvariantName = this.clonedCase[key];
                            } 
                        } */
                        if (key == 'Core_Customer_Reference_ID__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.customerReferenceID = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_End_Customer__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.endcustomer = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_External_Issue_Category__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.CategoryName = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_External_Issue_Subcategory__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.SubCategoryName = this.clonedCase[key];
                            }
                        }
                    }    // for loop ends   
                    console.log('subject---', this.subject, 'severity--', this.severity, 'caseDescription--', this.caseDescription, 'caseType---', this.caseType, 'ProductName--', this.ProductName, 'projectName--', this.projectName);
                    console.log('caseInfo--' + JSON.stringify(this.caseInfo));
                }
                else {
                    console.log('error');
                }
            })
            .catch(error => {
                this.errorMsg = error;
                console.log('error--' + this.errorMsg);
                console.log('errorMsgqqq--' + JSON.stringify(this.errorMsg));
            })
    }
    getproductVariants() {

        displayProductVariant({ selectedProductId: this.selectedProductId })
            .then(result => {
                if (result != null) {
                    console.log('caseProductVariantOptions res--' + JSON.stringify(result));
                    this.caseProductVariantOptions = [];
                    for (let i = 0; i < result.length; i++) {
                        this.caseProductVariantOptions = [
                            ...this.caseProductVariantOptions,
                            { value: result[i].Id, label: result[i].Name }
                        ];
                    }
                    console.log('result caseProductVariantOptions--' + this.caseProductVariantOptions);
                }
                else {
                    this.caseProductVariantOptions = [
                        { value: 'None', label: 'None' }
                    ];
                }
            })
            .catch(error => {
            })
    }
    getsubcategoryData() {
        displaySubCategoryData({ caseIssueCategoryId: this.caseIssueCategoryId })
            .then(result => {
                if (result != null) {
                    console.log('CaseSubcategoryoptions res--' + JSON.stringify(result));
                    this.CaseSubcategoryoptions = [];
                    for (let i = 0; i < result.length; i++) {
                        this.CaseSubcategoryoptions = [
                            ...this.CaseSubcategoryoptions,
                            { value: result[i].Id, label: result[i].Name }
                        ];
                    }
                    console.log('result CaseSubcategoryoptions--' + this.CaseSubcategoryoptions);
                }
                else {
                    this.CaseSubcategoryoptions = [
                        { value: 'None', label: 'None' }
                    ];
                }
            })
            .catch(error => {
            })
    }
    getcategoryData() {
        displayCategoryData({ prodId: this.prodId })
            .then(result => {
                if (result != null) {
                    console.log('CaseCategoryoptions res--' + JSON.stringify(result));
                    this.CaseCategoryoptions = [];
                    for (let i = 0; i < result.length; i++) {
                        this.CaseCategoryoptions = [
                            ...this.CaseCategoryoptions,
                            { value: result[i].Id, label: result[i].Name }
                        ];
                    }
                    console.log('result CaseCategoryoptions--' + this.CaseCategoryoptions);
                }
                else {
                    this.CaseCategoryoptions = [
                        { value: 'None', label: 'None' }
                    ];
                }
            })
            .catch(error => {
            })
    }
    activeSectionsMessage = '';
    activeSections = ['A', 'B', 'C', 'D'];
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
    @api showboolean1;
    @api showboolean2;
    handleChangeMINDS(event) {
        if (event.target.name == "yeschecked") {
            this.showboolean1 = true;
            this.showboolean2 = false;
        }
        if (event.target.name == "nochecked") {
            this.showboolean1 = false;
            this.showboolean2 = true;
        }
    }
    value = 'IND';
    get countryOptions() {
        return [
            { label: "Aruba", value: "ABW" },
            { label: "Afghanistan", value: "AFG" },
            { label: "Angola", value: "AGO" },
            { label: "Anguilla", value: "AIA" },
            { label: "Åland Islands", value: "ALA" },
            { label: "Albania", value: "ALB" },
            { label: "Andorra", value: "AND" },
            { label: "United Arab Emirates", value: "ARE" },
            { label: "Argentina", value: "ARG" },
            { label: "Armenia", value: "ARM" },
            { label: "American Samoa", value: "ASM" },
            { label: "Antarctica", value: "ATA" },
            { label: "French Southern Territories", value: "ATF" },
            { label: "Antigua and Barbuda", value: "ATG" },
            { label: "Australia", value: "AUS" },
            { label: "Austria", value: "AUT" },
            { label: "Azerbaijan", value: "AZE" },
            { label: "Burundi", value: "BDI" },
            { label: "Belgium", value: "BEL" },
            { label: "Benin", value: "BEN" },
            { label: "Bonaire, Sint Eustatius and Saba", value: "BES" },
            { label: "Burkina Faso", value: "BFA" },
            { label: "Bangladesh", value: "BGD" },
            { label: "Bulgaria", value: "BGR" },
            { label: "Bahrain", value: "BHR" },
            { label: "Bahamas", value: "BHS" },
            { label: "Bosnia and Herzegovina", value: "BIH" },
            { label: "Saint Barthélemy", value: "BLM" },
            { label: "Belarus", value: "BLR" },
            { label: "Belize", value: "BLZ" },
            { label: "Bermuda", value: "BMU" },
            { label: "Bolivia (Plurinational State of)", value: "BOL" },
            { label: "Brazil", value: "BRA" },
            { label: "Barbados", value: "BRB" },
            { label: "Brunei Darussalam", value: "BRN" },
            { label: "Bhutan", value: "BTN" },
            { label: "Bouvet Island", value: "BVT" },
            { label: "Botswana", value: "BWA" },
            { label: "Central African Republic", value: "CAF" },
            { label: "Canada", value: "CAN" },
            { label: "Cocos (Keeling) Islands", value: "CCK" },
            { label: "Switzerland", value: "CHE" },
            { label: "Chile", value: "CHL" },
            { label: "China", value: "CHN" },
            { label: "Côte d'Ivoire", value: "CIV" },
            { label: "Cameroon", value: "CMR" },
            { label: "Congo, Democratic Republic of the", value: "COD" },
            { label: "Congo", value: "COG" },
            { label: "Cook Islands", value: "COK" },
            { label: "Colombia", value: "COL" },
            { label: "Comoros", value: "COM" },
            { label: "Cabo Verde", value: "CPV" },
            { label: "Costa Rica", value: "CRI" },
            { label: "Cuba", value: "CUB" },
            { label: "Curaçao", value: "CUW" },
            { label: "Christmas Island", value: "CXR" },
            { label: "Cayman Islands", value: "CYM" },
            { label: "Cyprus", value: "CYP" },
            { label: "Czechia", value: "CZE" },
            { label: "Germany", value: "DEU" },
            { label: "Djibouti", value: "DJI" },
            { label: "Dominica", value: "DMA" },
            { label: "Denmark", value: "DNK" },
            { label: "Dominican Republic", value: "DOM" },
            { label: "Algeria", value: "DZA" },
            { label: "Ecuador", value: "ECU" },
            { label: "Egypt", value: "EGY" },
            { label: "Eritrea", value: "ERI" },
            { label: "Western Sahara", value: "ESH" },
            { label: "Spain", value: "ESP" },
            { label: "Estonia", value: "EST" },
            { label: "Ethiopia", value: "ETH" },
            { label: "Finland", value: "FIN" },
            { label: "Fiji", value: "FJI" },
            { label: "Falkland Islands (Malvinas)", value: "FLK" },
            { label: "France", value: "FRA" },
            { label: "Faroe Islands", value: "FRO" },
            { label: "Micronesia (Federated States of)", value: "FSM" },
            { label: "Gabon", value: "GAB" },
            { label: "United Kingdom of Great Britain and Northern Ireland", value: "GBR" },
            { label: "Georgia", value: "GEO" },
            { label: "Guernsey", value: "GGY" },
            { label: "Ghana", value: "GHA" },
            { label: "Gibraltar", value: "GIB" },
            { label: "Guinea", value: "GIN" },
            { label: "Guadeloupe", value: "GLP" },
            { label: "Gambia", value: "GMB" },
            { label: "Guinea-Bissau", value: "GNB" },
            { label: "Equatorial Guinea", value: "GNQ" },
            { label: "Greece", value: "GRC" },
            { label: "Grenada", value: "GRD" },
            { label: "Greenland", value: "GRL" },
            { label: "Guatemala", value: "GTM" },
            { label: "French Guiana", value: "GUF" },
            { label: "Guam", value: "GUM" },
            { label: "Guyana", value: "GUY" },
            { label: "Hong Kong", value: "HKG" },
            { label: "Heard Island and McDonald Islands", value: "HMD" },
            { label: "Honduras", value: "HND" },
            { label: "Croatia", value: "HRV" },
            { label: "Haiti", value: "HTI" },
            { label: "Hungary", value: "HUN" },
            { label: "Indonesia", value: "IDN" },
            { label: "Isle of Man", value: "IMN" },
            { label: "India", value: "IND" },
            { label: "British Indian Ocean Territory", value: "IOT" },
            { label: "Ireland", value: "IRL" },
            { label: "Iran (Islamic Republic of)", value: "IRN" },
            { label: "Iraq", value: "IRQ" },
            { label: "Iceland", value: "ISL" },
            { label: "Israel", value: "ISR" },
            { label: "Italy", value: "ITA" },
            { label: "Jamaica", value: "JAM" },
            { label: "Jersey", value: "JEY" },
            { label: "Jordan", value: "JOR" },
            { label: "Japan", value: "JPN" },
            { label: "Kazakhstan", value: "KAZ" },
            { label: "Kenya", value: "KEN" },
            { label: "Kyrgyzstan", value: "KGZ" },
            { label: "Cambodia", value: "KHM" },
            { label: "Kiribati", value: "KIR" },
            { label: "Saint Kitts and Nevis", value: "KNA" },
            { label: "Korea, Republic of", value: "KOR" },
            { label: "Kuwait", value: "KWT" },
            { label: "Lao People's Democratic Republic", value: "LAO" },
            { label: "Lebanon", value: "LBN" },
            { label: "Liberia", value: "LBR" },
            { label: "Libya", value: "LBY" },
            { label: "Saint Lucia", value: "LCA" },
            { label: "Liechtenstein", value: "LIE" },
            { label: "Sri Lanka", value: "LKA" },
            { label: "Lesotho", value: "LSO" },
            { label: "Lithuania", value: "LTU" },
            { label: "Luxembourg", value: "LUX" },
            { label: "Latvia", value: "LVA" },
            { label: "Macao", value: "MAC" },
            { label: "Saint Martin (French part)", value: "MAF" },
            { label: "Morocco", value: "MAR" },
            { label: "Monaco", value: "MCO" },
            { label: "Moldova, Republic of", value: "MDA" },
            { label: "Madagascar", value: "MDG" },
            { label: "Maldives", value: "MDV" },
            { label: "Mexico", value: "MEX" },
            { label: "Marshall Islands", value: "MHL" },
            { label: "North Macedonia", value: "MKD" },
            { label: "Mali", value: "MLI" },
            { label: "Malta", value: "MLT" },
            { label: "Myanmar", value: "MMR" },
            { label: "Montenegro", value: "MNE" },
            { label: "Mongolia", value: "MNG" },
            { label: "Northern Mariana Islands", value: "MNP" },
            { label: "Mozambique", value: "MOZ" },
            { label: "Mauritania", value: "MRT" },
            { label: "Montserrat", value: "MSR" },
            { label: "Martinique", value: "MTQ" },
            { label: "Mauritius", value: "MUS" },
            { label: "Malawi", value: "MWI" },
            { label: "Malaysia", value: "MYS" },
            { label: "Mayotte", value: "MYT" },
            { label: "Namibia", value: "NAM" },
            { label: "New Caledonia", value: "NCL" },
            { label: "Niger", value: "NER" },
            { label: "Norfolk Island", value: "NFK" },
            { label: "Nigeria", value: "NGA" },
            { label: "Nicaragua", value: "NIC" },
            { label: "Niue", value: "NIU" },
            { label: "Netherlands", value: "NLD" },
            { label: "Norway", value: "NOR" },
            { label: "Nepal", value: "NPL" },
            { label: "Nauru", value: "NRU" },
            { label: "New Zealand", value: "NZL" },
            { label: "Oman", value: "OMN" },
            { label: "Pakistan", value: "PAK" },
            { label: "Panama", value: "PAN" },
            { label: "Pitcairn", value: "PCN" },
            { label: "Peru", value: "PER" },
            { label: "Philippines", value: "PHL" },
            { label: "Palau", value: "PLW" },
            { label: "Papua New Guinea", value: "PNG" },
            { label: "Poland", value: "POL" },
            { label: "Puerto Rico", value: "PRI" },
            { label: "Korea (Democratic People's Republic of)", value: "PRK" },
            { label: "Portugal", value: "PRT" },
            { label: "Paraguay", value: "PRY" },
            { label: "Palestine, State of", value: "PSE" },
            { label: "French Polynesia", value: "PYF" },
            { label: "Qatar", value: "QAT" },
            { label: "Réunion", value: "REU" },
            { label: "Romania", value: "ROU" },
            { label: "Russian Federation", value: "RUS" },
            { label: "Rwanda", value: "RWA" },
            { label: "Saudi Arabia", value: "SAU" },
            { label: "Sudan", value: "SDN" },
            { label: "Senegal", value: "SEN" },
            { label: "Singapore", value: "SGP" },
            { label: "South Georgia and the South Sandwich Islands", value: "SGS" },
            { label: "Saint Helena, Ascension and Tristan da Cunha", value: "SHN" },
            { label: "Svalbard and Jan Mayen", value: "SJM" },
            { label: "Solomon Islands", value: "SLB" },
            { label: "Sierra Leone", value: "SLE" },
            { label: "El Salvador", value: "SLV" },
            { label: "San Marino", value: "SMR" },
            { label: "Somalia", value: "SOM" },
            { label: "Saint Pierre and Miquelon", value: "SPM" },
            { label: "Serbia", value: "SRB" },
            { label: "South Sudan", value: "SSD" },
            { label: "Sao Tome and Principe", value: "STP" },
            { label: "Suriname", value: "SUR" },
            { label: "Slovakia", value: "SVK" },
            { label: "Slovenia", value: "SVN" },
            { label: "Sweden", value: "SWE" },
            { label: "Eswatini", value: "SWZ" },
            { label: "Sint Maarten (Dutch part)", value: "SXM" },
            { label: "Seychelles", value: "SYC" },
            { label: "Syrian Arab Republic", value: "SYR" },
            { label: "Turks and Caicos Islands", value: "TCA" },
            { label: "Chad", value: "TCD" },
            { label: "Togo", value: "TGO" },
            { label: "Thailand", value: "THA" },
            { label: "Tajikistan", value: "TJK" },
            { label: "Tokelau", value: "TKL" },
            { label: "Turkmenistan", value: "TKM" },
            { label: "Timor-Leste", value: "TLS" },
            { label: "Tonga", value: "TON" },
            { label: "Trinidad and Tobago", value: "TTO" },
            { label: "Tunisia", value: "TUN" },
            { label: "Turkey", value: "TUR" },
            { label: "Tuvalu", value: "TUV" },
            { label: "Taiwan, Province of China", value: "TWN" },
            { label: "Tanzania, United Republic of", value: "TZA" },
            { label: "Uganda", value: "UGA" },
            { label: "Ukraine", value: "UKR" },
            { label: "United States Minor Outlying Islands", value: "UMI" },
            { label: "Uruguay", value: "URY" },
            { label: "United States of America", value: "USA" },
            { label: "Uzbekistan", value: "UZB" },
            { label: "Holy See", value: "VAT" },
            { label: "Saint Vincent and the Grenadines", value: "VCT" },
            { label: "Venezuela (Bolivarian Republic of)", value: "VEN" },
            { label: "Virgin Islands (British)", value: "VGB" },
            { label: "Virgin Islands (U.S.)", value: "VIR" },
            { label: "Viet Nam", value: "VNM" },
            { label: "Vanuatu", value: "VUT" },
            { label: "Wallis and Futuna", value: "WLF" },
            { label: "Samoa", value: "WSM" },
            { label: "Yemen", value: "YEM" },
            { label: "South Africa", value: "ZAF" },
            { label: "Zambia", value: "ZMB" },
            { label: "Zimbabwe", value: "ZWE" }
        ];
    }
    handleClick() {
        insertCaseData({
            caseList: this.caseinsertion
        })
            .then((result) => {
                console.log('Jai Matadi==');
                this.handleNavigateHome();
            })
            .catch((error) => {
                console.log(error);
                this.error = error;
            });
    }
    handleNavigateHome() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }


    //showExportPDF starts here
    @api isExportButtonClicked = false;
    //@api openModal1 = false;
    @track applicationPageUrl;
    @api isPrintButtonClicked = false;
    showPrint() {
        this.isPrintButtonClicked = true;
        this.showmaincmp = false;
        this.setIframePage();

    }
    showExportPDF() {
        //alert('recordId--'+this.recordId);
        this.isExportButtonClicked = true;
        this.setIframePage();
        //this.showmaincmp = false;

        /* 
        var test ='https://'+window.location.hostname+'/apex/Core_IPS_Case_ExportPDF?id='+this.recordId;
        console.log(test);
        window.open(test); */
    }
    closeModal() {
        this.showmaincmp = true;
        this.isExportButtonClicked = false;
        this.isPrintButtonClicked = false;
    }
    setIframePage() {
        getBaseUrlToLoadIframePage()
            .then(result => {
                if (result) {
                    let communityName = result;
                    let baseUrl = communityName ? '/' + communityName + '/apex' : '/apex';
                    console.log('baseUrl---' + baseUrl);
                    this.applicationPageUrl = this.generateIframeUrl(baseUrl);
                    console.log('applicationPageUrl---' + this.applicationPageUrl);
                }
                else {
                    this.applicationPageUrl = '';
                }
            })
            .catch(error => {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                }
                else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                console.log('error:', JSON.stringify(error));
            })
    }
    generateIframeUrl(baseUrl) {
        //alert('recordId baseUrl--'+this.recordId);
        let generatedUrl = '';
        let pageName = 'Core_IPS_Case_ExportPDF_LEX';
        //let pageName = 'Core_IPS_Case_ExportPDF';
        generatedUrl = pageName ? baseUrl + '/' + pageName + '?Id=' + this.recordId : '';
        return generatedUrl;
    }
    //showPrshowExportPDF int ends here
    /*Anil End*/
}