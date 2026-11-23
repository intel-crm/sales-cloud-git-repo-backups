import { LightningElement, wire, api, track } from 'lwc';
import AvailablecontactsforaddingtoprojectMembers from '@salesforce/apex/Core_IPS_Portal_Project_Controller.AvailablecontactsforaddingtoprojectMembers';
import AvailableIPSProducts from '@salesforce/apex/Core_IPS_Portal_Project_Controller.AvailableIPSProducts';
import createProjRecord from '@salesforce/apex/Core_IPS_Portal_Project_Controller.createProjects';
import upsertProjectMembers from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.upsertProjectMembers';
import upsertIPSProducts from '@salesforce/apex/Core_IPS_Portal_Project_Controller.upsertIPSProducts';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import interestedpartiesGradeout from '@salesforce/apex/Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController';
import getcurrentuserprofile from '@salesforce/apex/Core_IPS_TestAllRecords.getcurrentuserprofile';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserName from '@salesforce/schema/User.Name';
import EdqAlign from '@salesforce/resourceUrl/EdqAlignment';
import { loadStyle } from 'lightning/platformResourceLoader';
import progressbarImg from '@salesforce/resourceUrl/progressbarImg';

import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required';

export default class Core_IPS_projectCreation extends NavigationMixin(LightningElement) {
    @track progressbarImg = progressbarImg;
    userId = Id;
    currentUserName;
    @track showpage1 = true;
    @api showpage2 = false;
    @api showpage3 = false;
    @api showboolean1 = false;
    @api showboolean2 = false;
    @api showboolean3 = false;
    @api showboolean4 = false;
    @api recordId;
    @api enableMembers = false;
    @api removeNotification = false;
    @track isSpinner;
    @track grade = false;
    emailOutPutValue;
    @api showspinner = false;
    label={
       
        Core_IPS_Required
    }
    alphanum_validation = '[a-zA-Z0-9\/,.:\'+() ?-]*$';
    connectedCallback() {
        loadStyle(this, EdqAlign);
        let projectURL = window.location.href;
        let newURL = new URL(projectURL).searchParams;
        this.recordId = newURL.get('recordId');
        interestedpartiesGradeout()
            .then(result => {
                this.emailOutPutValue = result[0].Core_IPS_Email_Opt_Out__c;
                if (this.emailOutPutValue == true) {
                    this.grade = true;
                } else {
                    this.grade = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
        this.getCurUserprofile();
    }
    @api projectName;
    @api projDescription;
    @api notification;
    @api parties;
    @track hideButton = true;
    inputVal;
    handleChange(event) {
        var value;
        if (event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
        if (event.target.dataset.id === 'ProjectName') {
            this.projectName = value.trim();
            this.inputVal = this.projectName.replace(/\s/g, '').length;
            if(this.projectName!=''){
            this.template.querySelector('.validateProject').classList.remove('showRequired');
            this.isProjectRequired=false;
            }

        } else if (event.target.dataset.id === 'descriptionFeild') {
            this.projDescription = value;
        }
    }
    isProjectRequired=false;
    handleContinuetoAddMembers() {
        if (this.inputVal == 0 || this.projectName == '' || this.projectName == undefined) {
            this.showpage2 = false;
            this.showpage1 = true;
            //this.showToast('Error', 'Please fill in the required details', 'Error');
        this.template.querySelector('.validateProject').classList.add('showRequired');
        this.template.querySelector('.validateProject')?.scrollIntoView();
        this.isProjectRequired=true;
        } else {
            this.isSpinner = true;
            this.showpage2 = true;
            this.showpage1 = false;
            this.AvailabcontactsforaddingtoprojectMembers();
        }
    }
    handleContinuetoAddMembersback() {
        this.showpage1 = true;
        this.showpage2 = false;
    }
    handleContinuetoAddProducts() {
        this.isSpinner = true;
        this.showpage2 = false;
        this.showpage3 = true;
        this.AvailIPSProducts();
    }
    handleContinuetoAddProductsback() {
        this.showpage2 = true;
        this.showpage3 = false;
    }
    handleChangeParties(event) {
        if (event.target.name == "enableIntParty") {
            if (this.enableMembers == false) {
                this.enableMembers = true;
            } else {
                this.enableMembers = false;
            }
        }
        if (event.target.name == "removeNotif") {
            if (this.removeNotification == false) {
                this.removeNotification = true;
            } else {
                this.removeNotification = false;
            }
        }
    }
    handleNavigateBacktoDashboard() {
        if(this.showpage2==true){
            this.showpage2 = false;
            this.showpage1 = true;
        }
        else if(this.showpage3==true){
            this.showpage3 = false;
            this.showpage2 = true;
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
        }
    }
handleNavigationToHome(){
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'home'
        },
    });
}


    @api errorMsg;
    tempProjMembersOptions = [];
    projinitialRecords = [];
    AvailabcontactsforaddingtoprojectMembers() {
        this.isSpinner = true;
        AvailablecontactsforaddingtoprojectMembers({ projIdfromJS: this.recordId })
            .then(result => {
                if (result) {
                    this.isSpinner = false;
                    let options = [];
                    result.forEach(eachRecord => {
                        options.push({ label: eachRecord.Name, value: eachRecord.Id });
                    });
                    this.tempProjMembersOptions = options;
                    this.projinitialRecords = options;
                }
            })
            .catch(error => {
                this.isSpinner = false;
                this.errorMsg = error;

            })
    }
    availableProductOptions = [];
    initialRecords = [];
    AvailibleSearchProducts = [];
    AvailIPSProducts() {
        console.log('OUTPUT : this.recordId',this.recordId);
        this.isSpinner = true;
        AvailableIPSProducts({ projIdfromJS: this.recordId })
            .then(result => {
                if (result) {
                    console.log('OUTPUT : ',result);
                    this.isSpinner = false;
                    let options = [];
                    result.forEach(eachRecord => {
                        options.push({ label: eachRecord.Name, value: eachRecord.Id });
                    });
                    console.log('options : ',options);
                    this.availableProductOptions = options;
                    this.AvailibleSearchProducts = options;
                    this.initialRecords = options;
                }
            })
            .catch(error => {
                this.isSpinner = false;
                this.errorMsg = error;
            })
    }
    projSearchChangeHandler(event) {
        this.tempProjArray = this.projectsMembersArray;
        let projVar = event.detail.value;
        if (projVar) {
            this.tempProjMembersOptions = this.projinitialRecords;
            if (this.tempProjMembersOptions) {
                let recs = [];
                for (let key of this.tempProjMembersOptions) {
                    let valuesArray = Object.values(key);
                    for (let val of valuesArray) {
                        let projInput = projVar.toLowerCase();
                        if (val) {
                            if (val.toLowerCase().includes(projInput)) {
                                recs.push(key);
                                break;
                            }
                        }
                        this.tempProjMembersOptions = recs;
                    }
                }
            }
        } else {
            this.tempProjMembersOptions = this.projinitialRecords;
        }
    }

    prodSearchChangeHandler(event) {
        this.tempProdArray = this.productsArray;
        let tempVar = event.detail.value;
        if (tempVar) {
            this.availableProductOptions = this.initialRecords;
            if (this.availableProductOptions) {
                let recs = [];
                for (let rec of this.availableProductOptions) {
                    let prodInput = tempVar.toLowerCase();
                    if (rec.label.toLowerCase().includes(prodInput)) {
                        recs.push(rec);
                    }
                }
                this.availableProductOptions = recs;
            }
        } else {
            this.availableProductOptions = this.initialRecords;
        }
    }
    @api productsArray = [];
    handleChangeProducts(event) {
        this.productsArray = event.detail.value;
        let setProdArray = [...new Set(this.tempProdArray)];
        if (this.tempVar == '') {
            this.tempProdArray = [];
        } else {
            this.productsArray = [...new Set(setProdArray.concat(this.productsArray))];
        }
    this.template.querySelector('.validateDualProject').classList.remove('showRequiredProducts');
      this.isProjectRequired=false;

    }
    @api projectsMembersArray = [];
    handleChangeProjectmembers(event) {
        this.projectsMembersArray = event.detail.value;
        let setProjArray = [...new Set(this.tempProjArray)];
        if (this.projVar == '') {
            this.tempProjArray = [];
        } else {
            this.projectsMembersArray = [...new Set(setProjArray.concat(this.projectsMembersArray))];
        }
    }
    async handleCreateProject() {
        sessionStorage.setItem("autoRefresh", "RefreshProject");
        this.isSpinner = true;
        this.showspinner = true;
        if (this.productsArray.length > 0) {
            await this.createProjects();
        } else {
            this.isSpinner = false;
            //this.showErrorToast();
            this.template.querySelector('.validateDualProject').classList.add('showRequiredProducts');
            this.template.querySelector('.validateDualProject')?.scrollIntoView();
            this.isProjectRequired=true;
            
        }
    }
    navigateToViewProject() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'project-detail'
            },
            state: {
                recordId: this.recordId
            }
        });

    }
    async createProjects() {
        await createProjRecord({
                projName: this.projectName,
                projDes: this.projDescription,
                parties: this.enableMembers,
                notify: this.removeNotification,
                userName: this.value
            })
            .then(async(result) => {
                if (result.Id) {
                    this.recordId = result.Id;
                    if (this.projectsMembersArray && this.recordId !== null) {
                        await this.upsertProjectMem(JSON.stringify(this.projectsMembersArray), this.recordId);
                    }
                    if (this.tempProjMembersOptions && this.recordId !== null) {
                        await this.upsertIPSProducts(JSON.stringify(this.productsArray), this.recordId);
                    }
                    this.isSpinner = false;
                    this.showToast('Success', 'Project has been created.', 'success');
                    this.navigateToViewProject();
                }
            })
            .catch(error => {
                this.errorMsg = error;
                this.isSpinner = false;
                this.showToast('ERROR', error);
            })
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    async upsertProjectMem(projectmem, projectId) {
        await upsertProjectMembers({
                selectedIdsInsecondPage: projectmem,
                ipsProject: projectId
            })
            .then(result => {

                if (result) {}
            })
            .catch(error => {
                this.errorMsg = error;
                this.showToast('ERROR', error.body.message, 'error');
            })
    }
    async upsertIPSProducts(productmem, projectId) {
        await upsertIPSProducts({
                selectedIdsInThirdPage: productmem,
                ipsProject: projectId
            })
            .then(result => {
                if (result) {}
            })
            .catch(error => {
                this.errorMsg = error;
                this.showToast('ERROR', error.body.message, 'error');
            })
    }
    handleCancel() {
        this.showpage1 = false;
        this.showpage2 = false;
        this.showpage3 = false;
    }
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Please select atleast one Product',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    @track isPartnerORpartnerFAE = false;
    getCurUserprofile() {
        getcurrentuserprofile().then(result => {
            let rslt = result;
            if (rslt == 'PartnerAgent' || rslt == 'PartnerFAE') {
                this.isPartnerORpartnerFAE = true;
            } else {
                this.isPartnerORpartnerFAE = false;
            }
        });
    }
    value = 'None';
    get options() {
        return [
            { label: '--None--', value: 'None' },
            { label: this.currentUserName, value: this.currentUserName },
        ];
    }
    handleSupportedOwnerChange(event) {
        this.value = event.detail.value;
    }
    @wire(getRecord, { recordId: Id, fields: [UserName] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            let options = [];
            //options.push({ label: Name, value: this.currentUserName });
            options.push({ label: this.currentUserName, value: this.currentUserName });
        } else if (error) {
            this.showToast('ERROR', error);
        }
    }
}