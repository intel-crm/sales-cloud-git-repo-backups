import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import communityPath from '@salesforce/community/basePath';
import getCurrentproj from '@salesforce/apex/Core_IPS_Portal_Project_Controller.getCurrentproj';
import AvailableIPSProducts from '@salesforce/apex/Core_IPS_Portal_Project_Controller.AvailableIPSProducts';
import existingIPSProducts from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.existingIPSProducts';
import existingProjectMembers from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.existingProjectMembers';
import AvailablecontactsforaddingtoprojectMembers from '@salesforce/apex/Core_IPS_Portal_Project_Controller.AvailablecontactsforaddingtoprojectMembers';
import upsertIPSProducts from '@salesforce/apex/Core_IPS_Portal_Project_Controller.upsertIPSProducts';
import addOrRemoveProducts from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProducts';
import addOrRemoveProjMembers from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.addOrRemoveProjMembers';
import getChildIPSProdctsToProject from '@salesforce/apex/Core_IPS_Portal_Project_Controller.getChildIPSProdctsToProject';
import getcaseRecordsUnderproject from '@salesforce/apex/Core_IPS_Portal_Project_Controller.getcaseRecordsUnderproject';
import getOwnerOfProject from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.getOwnerOfProject';
import Id from '@salesforce/user/Id';
import { loadStyle } from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/portalDataTableColors'
import interestedpartiesGradeout from '@salesforce/apex/Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController';
import editProjectRecord from '@salesforce/apex/Core_IPS_Portal_ProjectUtility_LWC.editProjectRecord';
import Custom from '@salesforce/resourceUrl/CustomCSS_LWC';
import PortalSiteURL from '@salesforce/label/c.Core_IPS_PortalSiteURL_LWC';
import getErrorMsg from '@salesforce/label/c.Core_IPS_Error_Msg';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required';
const timezone = TIME_ZONE;
const columns = [
{
    label: 'Action', fieldName: 'linkCase', type: 'url', sortable: 'true',
    typeAttributes: {
        label: 'Comment',
        target: '_self'
    },
    wrapText: 'true', 
    hideDefaultActions: 'true',
    initialWidth: 79,
},
{
    label: 'Case Number', fieldName: 'linkCase', type: 'url', sortable: 'true',
    typeAttributes: {
        label: { fieldName: 'CaseNumber' },
        target: '_self'
    },
    wrapText: 'true',
    hideDefaultActions: 'true',
    initialWidth: 82,
},
{ label: 'Status', fieldName: 'Status', type: 'text', sortable: 'true',wrapText: 'true', hideDefaultActions: 'true',initialWidth: 90 },
{ label: 'Subject', fieldName: 'Subject', type: 'text', sortable: 'true' ,wrapText: 'true', hideDefaultActions: 'true',},
{
    label: 'Opened',
    fieldName: 'CreatedDate',
    type: 'date',
    sortable: 'true',
    typeAttributes: {
        day: 'numeric',
        month: 'numeric',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true,
        timeZone: timezone
    },
    wrapText: 'true',
    hideDefaultActions: 'true',
    initialWidth: 160,
},
{
    label: 'Modified', initialWidth: 160, fieldName: 'LastModifiedDate', type: 'date',  hideDefaultActions : true, sortable: 'true', typeAttributes: {
        timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit',
        minute: '2-digit',
        hour12: true
    },
    wrapText: 'true',
    hideDefaultActions: 'true',
    initialWidth: 160,
},
//{ label: 'Date Opened', fieldName: 'CreatedDate', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true',initialWidth: 160, },
//{ label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 160,},

{ label: 'Last ModifiedeFormat', fieldName: 'LastModifiedDateFormat', type: 'text', sortable: 'true', },
{ label: 'Date OpenedFormat', fieldName: 'CreatedDateFormat', type: 'text', sortable: 'true', },
   
];
export default class Core_IPS_projectDetail extends NavigationMixin(LightningElement) {
@api recordId; // which will come from UI
@api objectApiName = 'Core_IPS_Project__c';
@track showmaincmp = true;
@track showproducts = true;
@track showprojMem = true;
@track currentCaseData;
@track statusValue;
name;
description;
status;
enablemembers;
removenotificationdetails;
projectId;
mpnda;
hasAccess = true;
renderOnce = false;
casesList = [];
error;
columns = columns;
rowLimit = 25;
rowOffSet = 0;
@api showTable = false;
emailOutPutValue;
gradeout = false;
projNavigation;
@track isSpinner;
@track hideButton = true;
getValue;
label={
    Core_IPS_Required,
}
isProjectRequired=false;
isProjectStatusRequired=false;
connectedCallback() {
    loadStyle(this, Custom);
    this.getValue = sessionStorage.getItem("autoRefresh");
    sessionStorage.removeItem("autoRefresh");
    let testURL1 = window.location.href;
    let projectURL = encodeURI(testURL1);
    let newURL = new URL(projectURL).searchParams;
    this.recordId = newURL.get('recordId');
    this.AvailIPSProducts()
        .then(() => this.existingIPSProducts());
    this.AvailabcontactsforaddingtoprojectMembers();
    this.existingProjectMembers();
    this.getChildIPSProdctsToProject();
    this.loadData();
    ///gradeout enable interested parties checkbox//
    interestedpartiesGradeout()
        .then(result => {
            this.emailOutPutValue = result[0].Core_IPS_Email_Opt_Out__c;
            if (this.emailOutPutValue == true) {
                this.gradeout = true;
            }
            else {
                this.gradeout = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.accounts = undefined;
        })
}
renderedCallback() {
    if (this.isCssLoaded) return
    this.isCssLoaded = true
    loadStyle(this, COLORS).then(() => {
    }).catch(error => {
    })
}
loadData() {
    sessionStorage.setItem('ProjectCase', 'caseproject');
    sessionStorage.setItem('ProjId', this.recordId);
    return getcaseRecordsUnderproject({ ipsProject: this.recordId, fetchType: 'Load Data' })
        .then(result => {
            if (result.length > 0) {
                this.showTable = true;
                result = JSON.parse(JSON.stringify(result));
                let cols = columns;
                this.columns = cols.filter(c => c.fieldName != 'LastModifiedDateFormat' && c.fieldName != 'CreatedDateFormat' );
                
                result.forEach(record => {
                    record.linkCase = communityPath + '/case-detail?recordId=' + record.Id;
                    if (record.CreatedDate) {
                        record.CreatedDateFormat = record.CreatedDate;
                    }
                    if (record.LastModifiedDate) {
                        record.LastModifiedDateFormat = record.LastModifiedDate;
                    }

                });
            }
            this.casesList = result;
        })
        .catch(error => {
            this.error = error;
            this.casesList = undefined;
        });
}
@track sortBy;
@track sortDirection;
handleSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(event.detail.fieldName, event.detail.sortDirection)
}

sortData(fieldname, direction) {
        if(fieldname == 'CreatedDate')  {
            fieldname = 'CreatedDateFormat';
        }
        else if(fieldname == 'LastModifiedDate'){
            fieldname = 'LastModifiedDateFormat';
        }
    let parseData = JSON.parse(JSON.stringify(this.casesList));
    let keyValue = (a) => {
        return a[fieldname];
        
    };
    let isReverse = direction === 'asc' ? 1 : -1;
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : '';
        y = keyValue(y) ? keyValue(y) : '';
        if(fieldname==='CreatedDateFormat' || fieldname==='LastModifiedDateFormat') {
            if(x==''){
                x=0;
            }
            if(y==''){
                y=0;
            }
            
            var dx = new Date(x);
            var dy = new Date(y);
            return isReverse * (dx.getTime() - dy.getTime());
        }  
        else{
            return isReverse * ((x > y) - (y > x));
        }    
    });
    this.casesList = parseData;
    this.pagenation(this.casesList);
    this.refreshPageination();
}
@track isModalOpen = false;
handleEdit() {
    this.isModalOpen = true;
}
handleCancel() {
    this.isModalOpen = false;
}
openEditModal() {
    this.isModalOpen = true;
}
handleSubmit() {
    this.isModalOpen = false;
    this.showToast('Success', 'Project has been updated.', 'success');
    setTimeout(() => window.location.reload(), 1000);
}
showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(evt);
}
handleNavigateBack() {
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'home'
        },
    });
    sessionStorage.removeItem('ProjectCase');
    sessionStorage.removeItem("ProjectCreation");
}
get projTypeOptions() {
    return [
        { label: "Inactive", value: "Inactive" },
        { label: "Active", value: "Active" },
        { label: "Draft", value: "Draft" },
    ];
}
@track UpdateRecordId;
@track currentData;
@track nameInput;
projName;
@track theRecord = {};
@track removeNotification;
@track enableInterestedMem;
hideButton = true;
inputVal;
doSomething(event) {
    if (event.target.name == 'removeNotiy') {
        this.removeNotification = event.target.checked;
        this.theRecord[event.target.name] = event.target.checked;
    } else if (event.target.name == 'enableMembers') {
        this.enableInterestedMem = event.target.checked;
        this.theRecord[event.target.name] = event.target.checked;
    } else {
        this.theRecord[event.target.name] = event.target.value;
    }
    if (event.target.name == 'status') {
        this.statusValue = event.target.value;
        this.template.querySelector('.validateStatus').classList.remove('showRequired');
        this.isProjectStatusRequired=false;

    }
    if (event.target.name == 'projectName') {
        this.reqName = event.detail.value.trim();
        // this.inputVal = this.reqName.replace(/\s/g, '').length;
         if(this.reqName != ''){
        this.template.querySelector('.validateProject').classList.remove('showRequired');
        this.isProjectRequired=false;
         }

    }
}
handleEdit() {
    let strProjectData = JSON.parse(JSON.stringify(this.theRecord));
    if (this.removeNotification == undefined) {
        this.removeNotification = this.currentCaseData.Core_IPS_Remove_Notification_Details__c;
    }
    if (this.enableInterestedMem == undefined) {
        this.enableInterestedMem = this.currentCaseData.Core_IPS_EnableMemberasInterestedParties__c;
    }
    let projectObj = {
        Id: this.recordId,
        Name: (this.currentCaseData.Name != strProjectData.projectName) && (strProjectData.projectName != null || strProjectData.projectName != undefined) ? strProjectData.projectName : this.currentCaseData.Name,
        Core_Project_Description__c: (this.currentCaseData.Core_Project_Description__c != strProjectData.projDescription) && (strProjectData.projDescription != null || strProjectData.projDescription != undefined) ? strProjectData.projDescription : this.currentCaseData.Core_Project_Description__c,
        Core_MPNDA__c: (this.currentCaseData.Core_MPNDA__c != strProjectData.MPNDA) && (strProjectData.MPNDA != null || strProjectData.MPNDA != undefined) ? strProjectData.MPNDA : this.currentCaseData.Core_MPNDA__c,
        Core_IPS_Remove_Notification_Details__c: this.removeNotification,
        Core_IPS_EnableMemberasInterestedParties__c: this.enableInterestedMem,
        Core_Status__c: (this.currentCaseData.Core_Status__c != strProjectData.status) && (strProjectData.status != null || strProjectData.status != undefined) ? strProjectData.status : this.currentCaseData.Core_Status__c,
    }
    if (this.inputVal == 0 || projectObj.Name == '' || projectObj.Name == undefined) {
        //this.showToast('ERROR', 'Please Fill Project Name', 'error');
        this.template.querySelector('.validateProject').classList.add('showRequired');
        this.template.querySelector('.validateProject')?.scrollIntoView();
        this.isProjectRequired=true;
        this.isModalOpen = true;
    } else {
        this.isSpinner = true;
        editProjectRecord({ newprojRecordId: this.recordId, projectData: projectObj })
            .then(result => {
                if (result == 'error') {
                    this.isSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Project Cannot be Updated',
                            variant: 'error'
                        }),
                    );
                } else {
                    this.isSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Project Record Update Successful',
                            variant: 'success'
                        }),
                    );
                }
            })
            .catch(error => {
                this.error = error;
            });
        this.isModalOpen = false;
        setTimeout(() => window.location.reload(), 1000);
    }
}
handleEditProject() {
    if (this.statusValue == 'Draft') {
        //this.showToast('Error', 'Status: Project Status value cannot be changed to Draft once the project is active', 'error');
     this.template.querySelector('.validateStatus').classList.add('showRequired');
     this.template.querySelector('.validateStatus')?.scrollIntoView();
    this.isProjectStatusRequired=true;
    } else {
        this.handleEdit();
    }
}
closeEditModal() {
    this.isModalOpen = false;
}
@api errorMsg;
gradevalue;
grade;
RequiredName;
@wire(getCurrentproj, { pId: '$recordId' })
getCurrproj({ error, data }) {
    if (data) {
        this.hasAccess = true;
        this.isSpinner = false;
        let projData = JSON.parse(JSON.stringify(data));
        this.currentCaseData = projData;
        this.gradevalue = this.currentCaseData.Core_IPS_EnableMemberasInterestedParties__c;
       /* if (this.gradevalue == true) {
            this.gradeout = true;
        } else {
            this.gradeout = false;
        }*/

       // start Kamala on 28-04-2026 - TWC745-9174 as part of Lightening Component exception 
        /** projData.forEach(item => {
            this.RequiredName = projData?.Name;
        }); **/
        //end Kamala
    }
    else if (error) {
        this.hasAccess = false;
        this.isSpinner = false;
        this.errorMsg = error;
        if (this.hasAccess == true) {
            this.showToast('ERROR', error.body.message, 'error');
        }
    }
}
availableProductOptions = [];
initialRecords = [];
AvailIPSProducts() {
    return AvailableIPSProducts({ projIdfromJS: this.recordId })
        .then(result => {
            if (result) {
                let options = [];
                result.forEach(eachRecord => {
                    options.push({ label: eachRecord.Name, value: eachRecord.Id });
                });
                this.availableProductOptions = options;
                this.initialRecords = options;
            }
        })
        .catch(error => {
            this.errorMsg = error;
        })
}
selectedexistingProds = [];
defalutprodvalues = [];
@api initialProds;
storedProdValues;
existingIPSProducts() {
    return existingIPSProducts({ projIdfromJS: this.recordId })
        .then(result => {
            if (result) {
                this.initialProds = result;
                let options = [];
                let values = [];
                result.forEach(eachRecord => {
                    options.push({ label: eachRecord.Core_Supported_Product_Name__c, value: eachRecord.Core_Intel_Product__c });
                    values.push(eachRecord.Core_Intel_Product__c);
                });
                let mergedOptions = [...this.availableProductOptions];
                for (let i = 0; i < options.length; i++) {
                    if (!mergedOptions.some(option => option.value === options[i].value)) {
                        mergedOptions.push(options[i]);
                    }
                }
                this.selectedexistingProds = options;
                this.availableProductOptions = mergedOptions;
                this.initialRecords = mergedOptions;
                this.defalutprodvalues = values;
                this.storedProdValues = values;
            }
        })
        .catch(error => {
            this.errorMsg = error;
        })
}
countProdSearch = 0;
defprod = [];
prodSearchChangeHandler(event) {
    let tempVar = event.detail.value;
    if (tempVar) {
        if (this.countProdSearch == 0) {
            this.defprod = this.defalutprodvalues;
            this.countProdSearch = 1;
        } this.availableProductOptions = this.initialRecords;
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
@api tempProjMembersOptions = [];
initialMemberRecords = [];
AvailabcontactsforaddingtoprojectMembers() {
    AvailablecontactsforaddingtoprojectMembers({ projIdfromJS: this.recordId })
        .then(result => {
            if (result) {
                let options = [];
                result.forEach(eachRecord => {
                    options.push({ label: eachRecord.Name, value: eachRecord.Id });
                });
                this.tempProjMembersOptions = options;
                this.initialMemberRecords = options;
            }
        })
        .catch(error => {
            this.errorMsg = error;

        })
}
selectedexistingProj = [];
defalutprojvalues = [];
initialProjectMembers = [];
existingProjectMembers() {
    existingProjectMembers({ projIdfromJS: this.recordId })
        .then(result => {
            if (result) {
                let options = [];
                let values = [];
                this.initialProjectMembers = result;
                result.forEach(eachRecord => {
                    options.push({ label: eachRecord.Core_IPS_Contact__r.FirstName + ' ' + eachRecord.Core_IPS_Contact__r.LastName, value: eachRecord.Core_IPS_Contact__c });
                    values.push(eachRecord.Core_IPS_Contact__c);
                });
                for (let i = 0; i < options.length; i++) {
                    this.selectedexistingProj = this.tempProjMembersOptions.push(options[i]);
                }
                this.defalutprojvalues = values;
            }
        })
        .catch(error => {
            this.errorMsg = error;

        })
}
/** Author: Shruti Hasilkar
 * Date: 22/4/2022
 * Description: Search the Project members based on the given input.
 */
//defproj = [];//commented by sabira on  30-10-2026 as part of TWC745-9523
//countProjSearch = 0;//commented by on 30-10-2026 sabira as part of TWC745-9523
projMemSearchChangeHandler(event) {
    //commented by sabira on  30-10-2026 as part of TWC745-9523
    /* let tempSelectedValues = this.defalutprojvalues;
    let tempVar = event.detail.value;
    if (tempVar) {
        if (this.countProjSearch == 0) {
            this.defproj = this.defalutprojvalues;
            this.countProjSearch = 1;
        }
        this.tempProjMembersOptions = this.initialMemberRecords;
        if (this.tempProjMembersOptions) {
            let recs = [];
            for (let rec of this.tempProjMembersOptions) {
                if (rec.label.toLowerCase().includes(tempVar.toLowerCase())) {
                    recs.push(rec);
                }
            }
            this.tempProjMembersOptions = recs;
        }
        this.defalutprojvalues = tempSelectedValues ;  //commented by sabira  as part of TWC745-9523*/
        // Begin Change by Sabira  on  30-10-2026 as Part of TWC745-9523
    const searchValue = event.detail.value || '';
 
    if (searchValue) {
        this.tempProjMembersOptions = this.initialMemberRecords.filter(
            rec => rec.label.toLowerCase().includes(searchValue.toLowerCase())
        );
    } /* end change by sabira  on  30-10-2026 part of TWC745-9523 */
    else {
        this.tempProjMembersOptions = this.initialMemberRecords;
         // this.defalutprojvalues = tempSelectedValues; //commented by sabiraon  30-10-2026 as a  part of TWC745-9523
    }
}
@api productsArray = [];
@api remove_productsArray = [];
@api productsArr = [];
@api showaddProd = false;
selectedOptionsList = [];
/** Author: Shruti Hasilkar
 * Date: 18/4/2022
 * Description: the existing functionality was not working
 * this method is to get the selected Asset Ids.
 */
handleChangeProducts(event) {
    this.selectedOptionsList = event.detail.value;
    if (this.defprod.length > 1 && (!this.selectedOptionsList.includes[this.defprod[1]])) {
        this.selectedOptionsList = [...this.selectedOptionsList, ...this.defprod];
        this.defalutprodvalues = [...new Set(this.selectedOptionsList)];
        this.defprod = this.defalutprodvalues;
        this.countProdSearch = 0;
    }
    this.showaddProd = true;
}
/** Author: Shruti Hasilkar
 * Date: 19/4/2022
 * Description: Add or Remove the Product from the Dual box.
 */
initialProdsIds = [];
handleAddOrRemoveProd(event) {
    this.isSpinner = true;
    let tempProd = JSON.parse(JSON.stringify(this.initialProds));
    for (let i = 0; i < tempProd.length; i++) {
        let temp = tempProd[i].Core_Intel_Product__c;
        this.initialProdsIds.push(temp);
    }
    addOrRemoveProducts({
        initialIds: this.initialProdsIds,
        selectedIds: this.selectedOptionsList,
        projID: this.recordId
    })
        .then(result => {
            if (result == 'Success') {
                this.isSpinner = false;
                this.showToast('Success', 'Product Add / Remove operation is done.', 'success');
                this.showaddProd = false;
            }
            else {
                this.showToast('ERROR', result, 'error');
            }
            setTimeout(() => window.location.reload(), 1000);

        })
        .catch(error => {
            this.errorMsg = error;
            this.showToast('ERROR', error.body.message, 'error');

        })
}
@api projectsMembersArray = [];
@api showaddProj = false;
selectedProjMembers = [];
showProjectMemberOwnerNote = false;
projectMemberOwnerNote = getErrorNoteMsg;
userId = Id;
 
handleChangeProjectmembers(event) {
     // arrow button clicks move items and always dispatch change before the click bubbles to handleClickProjectmembers
    this.suppressProjMemberClick = true;
    //commented by sabira on  30-10-2026as part of TWC745-9523
     /* this.projectsMembersArray = JSON.stringify(event.detail.value);
    this.selectedProjMembers = event.detail.value;
    if (this.defproj) {
        this.selectedProjMembers = [...this.selectedProjMembers, ...this.defproj];
        this.defalutprojvalues = [...new Set(this.selectedProjMembers)];
        this.defproj = [];
        this.countProjSearch = 0;
    }
    this.validateProjectOwner();
}  //commented upto here  by sabira on  30-10-2026as part of TWC745-9523 */  
 //Begin change  by sabira on  30-10-2026  part of TWC745-9523
    const changedValues = event.detail.value || [];
    // Identify the options currently visible in the filtered list.
    const visibleValues = new Set(
        this.tempProjMembersOptions.map(option => option.value)
    );
    // Keep previously selected members that are hidden by the filter.added 
    const previouslySelected = this.defalutprojvalues || [];
 
    const hiddenSelectedValues = previouslySelected.filter(
        memberId => !visibleValues.has(memberId)
    );
    // Combine the current selection with hidden selected members.
    this.selectedProjMembers = [...new Set([
        ...changedValues,
        ...hiddenSelectedValues
    ])];
    // Save the complete, latest selection for the next operation.
    this.defalutprojvalues = [...this.selectedProjMembers];
    this.projectsMembersArray = JSON.stringify(this.selectedProjMembers);
    this.validateProjectOwner();
    /* End  change upto here   by sabira on  30-10-2026 part of TWC745-9523 */ 
}
 
suppressProjMemberClick = false;
// fires on click of a member row, separate from the onchange handler
handleClickProjectmembers() {
    // skip this click, it belongs to an arrow button that already fired onchange
    if (this.suppressProjMemberClick) {
        this.suppressProjMemberClick = false;
        return;
    }
    // click fires before onchange updates selectedProjMembers, so read the live value from the DOM
    const dualListbox = this.template.querySelector('.selectProjOptions');
    const currentValues = dualListbox ? dualListbox.value : this.selectedProjMembers;
    this.projectsMembersArray = JSON.stringify(currentValues);
    this.selectedProjMembers = currentValues;
    //commented this if block by sabira on  30-10-2026  as a part of TWC745-9523 
   /* if (this.defproj) {
        this.selectedProjMembers = [...this.selectedProjMembers, ...this.defproj];
        this.defalutprojvalues = [...new Set(this.selectedProjMembers)];
        this.defproj = [];
        this.countProjSearch = 0;
    } //commented by sabira   on  30-10-2026 as a part of TWC745-9523  */ 
    
    getOwnerOfProject({
        projId: this.recordId
    })
        .then(result => {
            let memIdIsThere = this.selectedProjMembers.includes(result);
            if (memIdIsThere == false) {
                this.showProjectMemberOwnerNote = true;
            } else {
                this.showProjectMemberOwnerNote = false;
            }
        })
        .catch(error => {
            this.errorMsg = error;
            this.showToast('ERROR', error.body.message, 'error');
            this.showToast('ERROR', JSON.stringify(error));
        })
}
validateProjectOwner() {
    getOwnerOfProject({
        projId: this.recordId
    })
        .then(result => {
console.log('testing results',result );
            let memIdIsThere = this.selectedProjMembers.includes(result);
            if (memIdIsThere == false) {
                this.showToast('Error', getErrorMsg, 'error');
                setTimeout(() => window.location.reload(), 1000);
            } else {
                if (this.projectsMembersArray != null && this.projectsMembersArray != undefined) {
                    this.showaddProj = true;
                }
            }
        })
        .catch(error => {
            this.errorMsg = error;
            this.showToast('ERROR', error.body.message, 'error');
            this.showToast('ERROR', JSON.stringify(error));
        })
}
initialProjMem = [];
handleSaveMemeber() {
    this.isSpinner = true;
    let tempProjMem = JSON.parse(JSON.stringify(this.initialProjectMembers));
    for (let i = 0; i < tempProjMem.length; i++) {
        let temp = tempProjMem[i].Core_IPS_Contact__c;
        this.initialProjMem.push(temp);
    }
    addOrRemoveProjMembers({
        initialProjMemIds: this.initialProjMem,
        selectedProMemIds: this.selectedProjMembers,
        projID: this.recordId
    })
        .then(result => {
            if (result == 'Success') {
                this.isSpinner = false;
                this.showToast('Success', 'Project member Add / Remove operation is done.', 'success');
                this.showaddProj = false;
            }
            else {
                this.showToast('ERROR', result, 'error');
            }
            setTimeout(() => window.location.reload(), 1000);

        })
        .catch(error => {
            this.errorMsg = error;
            this.showToast('ERROR', error.body.message, 'error');
        })
}
@api childProds = [];
getChildIPSProdctsToProject() {
    getChildIPSProdctsToProject({
        ipsProject: this.recordId
    })
        .then(result => {

            if (result) {
                this.childProds = result;
            }
        })
        .catch(error => {
            this.errorMsg = error;
            this.showToast('ERROR', error.body.message, 'error');
        })
}
//minhaj
@track applicationPageUrl;
@track isPrintClicked = false;
@track showProjDetails = true;
getPrintView() {
    this.isPrintClicked = true;
    this.showProjDetails = false;
    let baseURL = '/' + PortalSiteURL + '/apex';
    this.applicationPageUrl = this.generateIframeUrl(baseURL);
}
closeModal() {
    this.isPrintClicked = false;
    this.showProjDetails = true;
}
generateIframeUrl(baseURL) {
    let generatedUrl = '';
    let pageName = 'Core_IPS_ProjectDetailPrint_Page';
    generatedUrl = baseURL + '/' + pageName + '?recordId=' + this.recordId;
    return generatedUrl;
}
@track totalCaseList;
handleCasePaginationChangeInProject(event) {
    this.totalCaseList = event.detail;
}
pagenation(recordsList) {
    this.casesList = recordsList;
    if (this.casesList.length <= 5) {
        this.totalCaseList = this.casesList;
    } else if (this.casesList.length > 5) {
        this.totalCaseList = this.casesList.slice(0, 5);
    }
}
@track isrefreshPageination = false;
    refreshPageination() {
        if (this.isrefreshPageination == false) {
            this.isrefreshPageination = true;
        }
        else {
            this.isrefreshPageination = false;
        }
    }
reqName = [];
handleStatusChange(event) {
    this.statusValue = event.target.value;
    this.hideButton = true;
    if (this.statusValue == "Draft") {
        this.hideButton = false;
    }

}
handleError() {
    this.showToast('Error', 'Status: Project Status value can not be changed to Draft once the project is active', 'error');

}
}