import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SubmitCaseRecord from "@salesforce/apex/Core_IPS_CaseCreateLWCController.submitCaseRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Core_IPS_CaseCreateForm3_LWC extends NavigationMixin(LightningElement) {
    @api casedatainfo; //will come from parent
    @api subcatrecedqs; //will come from parent
    @api showcubcatedqs; //will come from parent
    @api showboolean1;
    @api showboolean2;
    communityCheck = true;
    @track hideButton = true;
    @ api myVal = '';
    @api subject;
    @api description;
    @api caseType;
    @api caseseverity;
    @api custmerreference;
    @api endcustomer;
    @api recordId;
    @api spinnerOn;
    get CaseTypeOptions() {
        return [
            { label: "Question", value: "Question" },
            { label: "Design Review", value: "Design Review" },
            { label: "Feature Request", value: "Feature Request" },
            { label: "Debug Request", value: "Debug Request" },
        ];
    }
    @api mode;
    @api createmode = false;
    @api sslcmode = false;
    constructor() {
			  super();
        this.template.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
    }
    @api trackvalidation = [];
    @track valCheck = true;
    @api trackchildataa = [];
    @api savealldataedq = [];
    @api myobjectdata = [];
    handleChangeChild(event) {
        console.log('inside handleChangeChild in form3');
        var s, c;
        var obj = {};
        var vb;
        if (event.detail.val === false) {
            this.valCheck = false;
            vb = event.detail.val;
            this.trackvalidation.push(vb);
        }
        if (event.detail.child === 'yes') {
            s = {
                "edq": [{ "qquestion": event.detail.qquestion, "llabel": event.detail.llabel, "vvalue": event.detail.vvalue, "rrequired": event.detail.rrequired, "ttype": event.detail.ttype, "val": event.detail.val }]
            };
            this.trackchildataa.push(s);
        }
        s = {
            "edq": [{ "qquestion": event.detail.qquestion, "llabel": event.detail.llabel, "vvalue": event.detail.vvalue, "rrequired": event.detail.rrequired, "ttype": event.detail.ttype, "val": event.detail.val }]
        };
        obj.edq = [];
        obj.edq.question = [event.detail.qquestion];
        obj.edq.label = [event.detail.llabel];
        obj.edq.value = [event.detail.vvalue];
        obj.edq.require = [event.detail.rrequired];
        obj.edq.type = [event.detail.ttype];
        this.savealldataedq.push(s);
        this.myobjectdata.push(obj);
        console.log('inside this.savealldataedq---' + JSON.stringify(this.savealldataedq));
        // console.log('inside this.myobjectdata---' + JSON.stringify(this.myobjectdata));
    }
    connectedCallback() {
        let projectURL = window.location.href;
        let newURL = new URL(projectURL).searchParams;
        this.mode = newURL.get('mode');
        console.log('mode for case creation--' + this.mode);
        if (this.mode == 'create') {
            this.createmode = true;
            this.sslcmode = false;
        } else if (this.mode == 'sslc') {
            this.sslcmode = true;
            this.createmode = false;
        }
        //Anil check data from parent component
			
        console.log('Anil casedatainfo--' + JSON.stringify(this.casedatainfo));
        console.log('Anil casedatainfo showProdEdqs--' + JSON.stringify(this.casedatainfo.showProdEdqs));
        console.log('Anil casedatainfo prodEdqRecs--' + JSON.stringify(this.casedatainfo.prodEdqRecs));
        console.log('Anil showcubcatedqs--' + this.showcubcatedqs);
				
			   console.log('Anil subcatrecedqs--' + JSON.stringify(this.subcatrecedqs));
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
    handleChange(event) {
        var value;
        if (event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
        if (event.target.dataset.id === 'countryField') {
            this.country = value;
        } else if (event.target.dataset.id === 'subjectField') {
            this.subject = value;
        } else if (event.target.dataset.id === 'descriptionFeild') {
            this.description = value;
        } else if (event.target.dataset.id === 'CaseType') {
            this.caseType = value;
        } else if (event.target.dataset.id === 'Severity') {
            this.caseseverity = value;
        } else if (event.target.dataset.id === 'custmerreference') {
            this.custmerreference = value;
        } else if (event.target.dataset.id === 'endcustomer') {
            this.endcustomer = value;
        }
        console.log('country--', this.country, 'subject--', this.subject, 'description--', this.description, 'this.caseType--', this.caseType);
        console.log('Severity--', this.caseseverity, 'custmerreference--', this.custmerreference, 'endcustomer--', this.endcustomer);
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    navigateToViewCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'case-detail'
            },
            state: {
                recordId: this.recordId
            }
        });
    }
    hanldeSaveReport() {
        this.spinnerOn = true;
        console.log('this.casedatainfo.showProdEdqs--' + this.casedatainfo.showProdEdqs);
        if (this.casedatainfo.showProdEdqs === true) {
            console.log('showProdEdq fired');
            this.template.querySelector('c-core_-i-p-s_dynamicformbuilder').callhandleQuestionAnswer();
        }
        //subcategory edq
        console.log('this.showcubcatedqs--' + this.showcubcatedqs);
        if (this.showcubcatedqs === true) {
            console.log('showcubcatedqs fired');
            this.template.querySelector('c-core_-i-p-s_dynamicformbuilder').callhandleQuestionAnswer();
        }
        var strEdq = JSON.stringify(this.savealldataedq);
        console.log("Handlesave method called EDQs--" + strEdq);
        var caseObj = {
            Core_IPS_Project_Case__c: this.casedatainfo.project,
            ContactId: this.casedatainfo["contactId"],
            AccountId: this.casedatainfo.accountId,
            AssetId: (this.casedatainfo.Product !== undefined && this.casedatainfo.Product !== null) ? this.casedatainfo.Product : '',
            Subject: this.subject,
            Core_Issue_Description__c: this.description,
            Core_Severity__c: this.caseseverity,
            Core_CaseType__c: this.caseType,
            Core_Case_Issue_Category__c: (this.casedatainfo.CategoryId !== undefined && this.casedatainfo.CategoryId !== null) ? this.casedatainfo.CategoryId : null,
            Core_Case_Issue_Sub_Category__c: (this.casedatainfo.SubCategoryId !== undefined && this.casedatainfo.SubCategoryId !== null) ? this.casedatainfo.SubCategoryId : null,
            Core_IPS_Customer_Visible__c: true
        }
        console.log('caseObj before submitting--' + JSON.stringify(caseObj));
        SubmitCaseRecord({ newRecord: caseObj, contactRecord: this.selectedContactRecord, CaseEDQData: strEdq })
            .then(result => {
                console.log('result--' + result);
                if (result !== undefined || result !== null) {
                    this.spinnerOn = false;
                    if (this.recordId !== null || this.recordId !== undefined) {
                        this.spinnerOn = false;
                        this.showToast('Success', 'Case has been created.', 'success');
                    }
                    this.recordId = result.Id;
                    console.log('result this.recordId--' + this.recordId);
                    /* if(this.recordId!== null && this.recordId!== undefined ){
                     //this.handleSaveEDQ();
                     SubmitCaseRecord({newRecord : caseObj, contactRecord: this.selectedContactRecord, CaseEDQData:strEdq })
                     .then(result => {
                         console.log('EDQ call sucessfull');
                     })
                     .catch(error => {
                         this.showToast('ERROR', error.body.message, 'error');
                         console.log('Error in SubmitCaseRecord edq ', error, JSON.stringify(error));
                         });
                    } */
                    this.navigateToViewCase();
                }
            })
            .catch(error => {
                this.showToast('ERROR', error.body.message, 'error');
                console.log('Error in SubmitCaseRecord ', error, JSON.stringify(error));
            });
    }
}