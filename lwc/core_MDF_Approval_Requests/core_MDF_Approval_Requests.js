import { LightningElement, wire } from 'lwc';
import getRecordsToApprove from '@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.getRecordsToApprove';
import getValidationMessage from '@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.getValidationMessage';
import submitForApproval from '@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.submitForApproval';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import Core_MDF_Comments_CharLimit from "@salesforce/label/c.Core_MDF_Comments_CharLimit";
import checkClaimsAssociatedToCampaign from "@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.checkClaimsAssociatedToCampaign";
//Gayathri-Related to Seperate section for outcome-based campaign story
import Core_MDF_CoMarketing_Activity from '@salesforce/label/c.Core_MDF_CoMarketing_Activity';
import Core_MDF_OutcomeBased_Campaign from '@salesforce/label/c.Core_MDF_OutcomeBased_Campaign';
	

const cols=[
    { label: 'Name', fieldName: 'name' },
    { label: 'Type', fieldName: 'object'},
    { label: 'Comments', fieldName: 'comment', editable: true},
    { label: 'Make this rejection permanent?', fieldName: 'permanentReject',type : 'boolean' , editable: {fieldName: 'isCheckBoxEditable'} }
     
   
];

export default class Core_MDF_Approval_Requests extends NavigationMixin(LightningElement) {

    formFactor = formFactorPropertyName;                               
    isDesktop;                                                         totalApprovalcount = 0;
    approvalSummaryData = [];                                          approvalRequestUI = [];               
    columns = cols;                                                    recordsToFilter = [];        
    showSpinner = true;                                                recordsFromApex = [];         
    disableBulkApproval = true;                                        isRecordsAvailable = false;                 
    isDisableSingleApproval = false;                                   isDisableSearch = true;                      
    isModalOpen = false;                                               contentDetailUI = [];          
    specificContentId = '';                                            checkedBoxesIds = [];             
    countMessage;                                                      showTimeContent;
    approvalResultContent = [];                                        recordsToApproveCount;                
    showDefaultMsg = true;     
    successCount = 0;                                                  objToRecordsMap = new Map();       
    approvalButtonName;          
    successCountMessage;                                               recordsToApproveReject = [];          
    onSuccessShowToastMessage = '';                                    rowErrors = {};
    popUpSpinner = false;                                              summaryErrors = [];
    recordsToUnCheck = [];                                             disableBulkApproveButton = false;            
    updatedMin = 0;                                                    isShowResultContent = false; 
    commentsCharLim = Core_MDF_Comments_CharLimit;
    isRejectionModalOpen = false;
    isL2SalesApprover = false;
    objectsToApproved;
    enabledTerminalRejection = false;
    cmpObjToApprovalStageMap = new Map();
    campaigntoClaimMap = new Map();
    
    isL2RegionalSales=false;
    //to support terminal rejection for l1 approver
    isL1Approver = false;
    isL1Approval = false;
    
// Gayathri - controls Smart Assist visibility in bulk section (used by HTML if:true)
showSmartAssistBulk = false;
    //made changes-Alekhya
formatCurrency(value) {
    if (value === null || value === undefined || value === '') return value;

    let cleanValue = value.toString()
        .replaceAll('$', '')
        .replaceAll(',', '');

    let numValue = Number(cleanValue);

    if (Number.isNaN(numValue)) return value;

    return '$' + numValue.toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

    

    toggleSection(event) {
        let buttonid = event.currentTarget.dataset.buttonid;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section slds-is-close';
        }
    }

    connectedCallback() {
        if (this.formFactor == 'Large') {
            this.isDesktop = true;
        } else {
            this.isDesktop = false;//Mobile
        }
        this.getRecordsToApprove();
        this.handleCountDown();
        this.getValidationMessage();
    }

    SELECT_SAME_OBJECT_VALIDATION;
    BULK_APPROVAL_MAX_LIMIT_VALIDATION;
    BULK_APPROVAL_MAX_LIMIT_COUNT_VALIDATION;
    PERMANENT_REJECTION_CHECKBOX_MSG;
    PERMANENT_REJECTION_WARNING;
    PERMANENT_REJECTION_CLAIM_VALIDATION;

    getValidationMessage() {
        this.showSpinner = true;
        getValidationMessage()
        .then(data => {
            this.showSpinner = false;
            var result = JSON.parse(data);
            this.SELECT_SAME_OBJECT_VALIDATION = result.Core_MDF_Select_Same_Object_Type;      
            this.BULK_APPROVAL_MAX_LIMIT_VALIDATION = result.Core_MDF_Bulk_Approval_Max_Limit;
            this.BULK_APPROVAL_MAX_LIMIT_COUNT_VALIDATION = result.Core_MDF_Bulk_Approval_Max_Limit_Count;
            this.PERMANENT_REJECTION_CHECKBOX_MSG = result.Core_MDF_PermanentRejectionCheckboxMsg;
            this.PERMANENT_REJECTION_WARNING = result.Core_MDF_PermanentRejectionWarning;
            this.PERMANENT_REJECTION_CLAIM_VALIDATION = result.Core_MDF_PermanentRejectionClaimError;    
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
        });
    }

    handleCountDown() {
        var minOnLoad; var allowTimeChange = false;
        let currentTime; var entryOnload = true;
        setInterval(() => {
            currentTime = new Date();
            if (entryOnload) {
                minOnLoad = currentTime.getMinutes();
            } else {
                if (minOnLoad != currentTime.getMinutes()) {
                    minOnLoad = currentTime.getMinutes();
                    this.updatedMin = this.updatedMin + 1;
                    allowTimeChange = true;
                } else {
                    allowTimeChange = false;
                }
            }
            if (entryOnload) {
                this.showTimeContent = 'Updated a few seconds ago';
                entryOnload = false;
            } else if (allowTimeChange) {
                this.showTimeContent = 'Updated ' + this.updatedMin + ' Minutes ago';
            }
        }, 1000);
    }

    getRecordsToApprove() {
        this.showSpinner = true;
        var campaignIdList = [];
        getRecordsToApprove()
            .then(data => {
                console.log('data from apex', data);
                if (data != '') {
                    this.recordsFromApex = JSON.parse(data);
                    //Gayathri-Related to Seperate section for outcome-based campaign story
                    //this.approvalRequestUI = JSON.parse(data);
                    this.originalApprovalData = JSON.parse(data); // Store original data
                    this.processApprovalRequestData();
                    
                    let count = 0;
                    if (this.approvalRequestUI != null && this.approvalRequestUI.length > 0) {
                        this.approvalRequestUI.forEach(content => {
                            content.recordsToApprove.forEach(record => {
                                record.position = count;
                                record.isDisabled = false;
                                record.object = content.objectName;
                                record.icon = content.icon;
                                record.isSelected = false;
                                // Gayathri - initialize per-record flag used by single record Smart Assist
                                record.isPartnerFundRequest = (record.object === 'Co-Marketing Activity' || record.object === 'Outcome-Based Campaign');
                                this.recordsToFilter.push(record);
                                //Made changes-ALekhya
                               if (record.object === 'Budget') {
                                // Format all field arrays
                                 ['tableViewDetails', 'compactDetails', 'recordDetails'].forEach(detailType => {
                                     if (record[detailType]) {
                                         record[detailType].forEach(field => {
                                         // Check if this field contains amount/currency data
                                        if (field.value && field.value.toString().includes('$') && 
                                            field.value.toString().match(/\d/)) {
                                            field.value = this.formatCurrency(field.value);
                                        }
                                    });
                             }
                    });
                }
                                count++;
                                if(record.object == 'Campaign'){
                                    campaignIdList.push(record.id);
                                    record.tableViewDetails.forEach(field => {
                                    if(field.label == 'ApprovalStage'){
                                        this.cmpObjToApprovalStageMap.set(record.id,field.value);
                                    }
                                 });
                                }
                                });
                            
                            if(this.isL2SalesApprover == false && content.userPermission!=null  ){
                                this.isL2SalesApprover = content.userPermission.isL2SalesApprover;
                            }
                            // To check if current approver is IPA L1 Approver
                            if(this.isL1Approver == false && content.userPermission!=null  ){
                                this.isL1Approver = content.userPermission.isL1Approver;
                            }

                            if (!this.objToRecordsMap.has(content.objectName)) {
                                var selectedRecord = [];
                                this.objToRecordsMap.set(content.objectName, selectedRecord);
                            }
                        });
                        this.recordsToFilter = JSON.parse(JSON.stringify(this.recordsToFilter));
                        if (this.recordsToFilter != null && this.recordsToFilter.length > 0) {
                            this.totalApprovalcount = this.recordsToFilter.length;
                            this.isRecordsAvailable = true;
                            this.isDisableSearch = false;
                        }
                    }
                }
                this.showSpinner = false;
                                    checkClaimsAssociatedToCampaign({campaignId:campaignIdList})
                                    .then((result)=>{
                                        for(var key in result){
                                            this.campaigntoClaimMap.set(key,result[key]);
                                        }
                                    });
            })
            .catch(error => {
                console.error('error from apex1', error);  
                console.error('error from apex2', error?.body?.message || error?.message);
                console.error('error from apex3', error?.stack);
                this.showSpinner = false;
                this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
            });
    }
    //Gayathri-Related to Seperate section for outcome-based campaign story
    // NEW METHOD: Process approval data to separate Co-Marketing Activity records
    /*processApprovalRequestData() {
        let processedData = [];
        
        this.originalApprovalData.forEach(objGroup => {
            if (objGroup.objectName === Core_MDF_CoMarketing_Activity) {
                // Separate Co-Marketing Activity records based on isIPAOutcomeBased flag
                const separatedSections = this.separateCoMarketingRecords(objGroup);
                processedData.push(...separatedSections);
            } else {
                processedData.push(objGroup);
            }
        });
        
        this.approvalRequestUI = processedData;
    }*/
        processApprovalRequestData() {
            const processedData = [];
            let outcomeBasedSection;

            this.originalApprovalData.forEach(objGroup => {
                const sections =
                    objGroup.objectName === Core_MDF_CoMarketing_Activity
                        ? this.separateCoMarketingRecords(objGroup)
                        : [objGroup];

                sections.forEach(section => {
                    if (section.objectName !== Core_MDF_OutcomeBased_Campaign){
                        processedData.push(section);
                        return;
                    }

                    if (!outcomeBasedSection) {
                        outcomeBasedSection = {
                            ...section,
                            recordsToApprove: [...section.recordsToApprove]
                        };

                        processedData.push(outcomeBasedSection);
                    } else {
                        outcomeBasedSection.recordsToApprove.push(
                            ...section.recordsToApprove
                        );
                    }

                    outcomeBasedSection.count =
                        outcomeBasedSection.recordsToApprove.length;
                });
            });

            this.approvalRequestUI = processedData;
        } //indu

    // NEW METHOD: Utility method to separate Co-Marketing records using isIPAOutcomeBased flag
    separateCoMarketingRecords(coMarketingGroup) {
        const sections = [];
        const regularActivities = [];
        const outcomeBasedCampaigns = [];
        
        coMarketingGroup.recordsToApprove.forEach((record) => {
            if (record.isIPAOutcomeBased === true) {
                outcomeBasedCampaigns.push(record);
            } else {
                regularActivities.push(record);
            }
        });
        
        if (regularActivities.length > 0) {
            sections.push({
                objectName: Core_MDF_CoMarketing_Activity,
                count: regularActivities.length,
                recordsToApprove: regularActivities,
                icon: coMarketingGroup.icon,
                userPermission: coMarketingGroup.userPermission,
                byPassBulk: coMarketingGroup.byPassBulk
            });
        }
        
        if (outcomeBasedCampaigns.length > 0) {
            sections.push({
                objectName: Core_MDF_OutcomeBased_Campaign,
                count: outcomeBasedCampaigns.length,
                recordsToApprove: outcomeBasedCampaigns,
                icon: coMarketingGroup.icon,
                userPermission: coMarketingGroup.userPermission,
                byPassBulk: coMarketingGroup.byPassBulk
            });
        }
        
        return sections;
    }

    getApprovalTargetObjectName(displayName) {
        return (
            displayName === Core_MDF_CoMarketing_Activity ||
            displayName === Core_MDF_OutcomeBased_Campaign
        )
            ? 'Co-Marketing Activity'
            : displayName;
    } //indu

    refreshData(){
        location.reload();
    }

    onTileClick(event) {
        this.specificContentId = event.currentTarget.dataset.id;
        let divPosition = event.currentTarget.dataset.recordId;
        var currentDiv = this.template.querySelectorAll('.content');
        let totalContent = currentDiv.length;
        for (let i = 0; i < totalContent; i++) {
            if (i == divPosition) {
                currentDiv[i].classList.add('div-color');
            } else {
                currentDiv[i].classList.remove('div-color');
            }
        }
        this.displaySpecificContent();
    }

    displaySpecificContent() {
        this.showSpinner = true;
        this.contentDetailUI = [];
        this.recordsToFilter.forEach(record => {
            if (record.id == this.specificContentId) {
            // Gayathri - Ensure flag exists on detail record for single Smart Assist visibility
            record.isPartnerFundRequest = (record.object === 'Co-Marketing Activity' || record.object === 'Outcome-Based Campaign');
                this.contentDetailUI.push(record);
            }
            // Format currency for the detailed view-made changes Alekhya
            if (record.object === 'Budget') {
                ['tableViewDetails', 'compactDetails', 'recordDetails'].forEach(detailType => {
                if (record[detailType]) {
                    record[detailType].forEach(field => {
                    if (field.value && field.value.toString().includes('$') && 
                        field.value.toString().match(/\d/)) {
                        field.value = this.formatCurrency(field.value);
                }
            });
        }
    });
}
        });
        this.showSpinner = false;

        if (!this.isDesktop) {
            this[NavigationMixin.GenerateUrl]({
                type: "standard__component",
                attributes: {
                    componentName: "c__Core_MDF_navAuraCmp"
                },
                state: {
                    c__recId: JSON.stringify(this.contentDetailUI)
                }
            }).then(url => {
                window.open(url, "_blank");
            });
        }
    }

    handleFilterSearch(event) {
        this.showSpinner = true;
        let searchText = event.target.value.toLowerCase();
        var approvalRec;
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));
        if (searchText != '' && searchText != null) {
            var objectToRecords = new Map();
            for (var index in this.recordsToFilter) {
                let objectName = this.recordsToFilter[index].object;
                approvalRec = JSON.stringify(this.recordsToFilter[index]).toLowerCase();
                if (approvalRec.includes(searchText)) {
                    if (objectToRecords.has(objectName)) {
                        objectToRecords.get(objectName).push(this.recordsToFilter[index]);
                    } else {
                        var filteredRecords = [];
                        filteredRecords.push(this.recordsToFilter[index]);
                        objectToRecords.set(objectName, filteredRecords);
                    }
                }
            }
            this.approvalRequestUI.forEach(content => {
                var objectName = content.objectName;
                if (objectToRecords.has(objectName)) {
                    content.recordsToApprove = objectToRecords.get(objectName);
                } else {
                    content.recordsToApprove = [];
                }
            });
        } else {
            var objectToRecords = new Map();
            for (var index in this.recordsToFilter) {
                let objectName = this.recordsToFilter[index].object;
                if (objectToRecords.has(objectName)) {
                    objectToRecords.get(objectName).push(this.recordsToFilter[index]);
                } else {
                    var filteredRecords = [];
                    filteredRecords.push(this.recordsToFilter[index]);
                    objectToRecords.set(objectName, filteredRecords);
                }
            }
            this.approvalRequestUI.forEach(content => {
                var objectName = content.objectName;
                if (objectToRecords.has(objectName)) {
                    content.recordsToApprove = objectToRecords.get(objectName);
                }
            });
        }
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));

        let count = 0;
        this.approvalRequestUI.forEach(content => {
            if (content.recordsToApprove.length > 0) {
                content.recordsToApprove.forEach(record => {
                    record.position = count;
                    count++;
                });
            }
        });
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));
        this.showSpinner = false;
    }

    handleCheckBox(event) {
        this.showSpinner = true;
        let isChecked = event.target.checked;
        let selectedObject = event.target.name;
        let currentId = event.target.dataset.id;

        if (isChecked) {
            var recordLimitValidation;

            if(this.BULK_APPROVAL_MAX_LIMIT_VALIDATION.includes('#')){
                recordLimitValidation = this.BULK_APPROVAL_MAX_LIMIT_VALIDATION.replace('#',this.BULK_APPROVAL_MAX_LIMIT_COUNT_VALIDATION);
            }
            if (this.checkedBoxesIds.length >= this.BULK_APPROVAL_MAX_LIMIT_COUNT_VALIDATION) {
                this.showToastMessage('Warning',recordLimitValidation, 'warning', 'sticky');
                event.target.checked = false;
                this.showSpinner = false;
                return;
            }

            if (this.objToRecordsMap.size > 0) {
                let mapkeys = [...this.objToRecordsMap.keys()];
                var crossObjValidation = false;
                if (mapkeys.length > 0) {
                    for (let i = 0; i < mapkeys.length; i++) {
                        if (mapkeys[i] != selectedObject) {
                            if (this.objToRecordsMap.get(mapkeys[i]).length > 0) {
                                crossObjValidation = true;
                                break;
                            }
                        }
                    }
                }
                if (crossObjValidation) {
                    this.showToastMessage('Warning',this.SELECT_SAME_OBJECT_VALIDATION, 'warning', 'sticky');
                    event.target.checked = false;
                    this.showSpinner = false;
                    return;
                }
            }


            this.checkedBoxesIds.push(currentId);
            this.objectsToApproved=event.target.name;
            if (this.objToRecordsMap.has(selectedObject)) {
                this.objToRecordsMap.get(selectedObject).push(currentId);
            } else {
                var selectedRecord = [];
                selectedRecord.push(currentId);
                this.objToRecordsMap.set(selectedObject, selectedRecord);
            }

        } else {
            const index = this.checkedBoxesIds.indexOf(currentId);
            if (index > -1) {
                this.checkedBoxesIds.splice(index, 1);
            }
            if (this.objToRecordsMap.has(selectedObject)) {
                const index = this.objToRecordsMap.get(selectedObject).indexOf(currentId);
                if (index > -1) {
                    this.objToRecordsMap.get(selectedObject).splice(index, 1);
                }
            }
        }

        this.isDisableSingleApproval = false;
        this.disableBulkApproval = true;

        if (this.checkedBoxesIds != null) {
            this.recordsToApproveCount = this.checkedBoxesIds.length;
            if (this.recordsToApproveCount > 0) {
                this.showDefaultMsg = false;
                if (this.recordsToApproveCount > 1) {
                    this.countMessage = this.recordsToApproveCount + ' items selected';
                    this.isDisableSingleApproval = true;
                    this.disableBulkApproval = false;
                } else {
                    this.countMessage = this.recordsToApproveCount + ' item selected';
                }
            } else {
                this.showDefaultMsg = true;
            }
        }
        var objByPassMap = new Map();
        this.approvalRequestUI.forEach(content => {
            objByPassMap.set(content.objectName, content.byPassBulk);
            var objName = content.objectName;
            content.recordsToApprove.forEach(record => {
                if (objName == selectedObject) {
                    if (record.id == currentId) {
                        record.isSelected = isChecked;
                    }
                    else if (content.byPassBulk) {
                        record.isDisabled = isChecked;
                    }
                }
            });
            if (objName != selectedObject) {
                if (this.objToRecordsMap.has(selectedObject) && this.objToRecordsMap.get(selectedObject) != null) {
                    let currentsection = this.template.querySelector('[data-id="' + objName + '"]');
                    if (this.objToRecordsMap.get(selectedObject).length == 0) {
                        currentsection.className = 'slds-section slds-is-open';
                    } else {
                        currentsection.className = 'slds-section slds-is-close';
                    }
                }
            }
        });

        this.recordsToFilter.forEach(record => {
            if (record.object == selectedObject) {
                if (record.id == currentId) {
                    record.isSelected = isChecked;
                }
                else if (objByPassMap.get(record.object)) {
                    record.isDisabled = isChecked;
                }
            } else {
                if (isChecked) {
                    record.isDisabled = true;
                } else {
                    if (this.objToRecordsMap.has(selectedObject) && this.objToRecordsMap.get(selectedObject) != null) {
                        if (this.objToRecordsMap.get(selectedObject).length == 0) {
                            record.isDisabled = isChecked;
                        }
                    }
                }
            }
        });
        this.recordsToFilter = JSON.parse(JSON.stringify(this.recordsToFilter));
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));
        // Gayathri - Update Smart Assist bulk visibility
        const selectedRecords = this.recordsToFilter.filter(r => r.isSelected);
        this.showSmartAssistBulk = selectedRecords.length > 0 && 
                                   selectedRecords.every(r => r.object === 'Co-Marketing Activity' || r.object === 'Outcome-Based Campaign');
        
        this.showSpinner = false;
    }
    
    isInValidUserInput(row){
        
        let isInValid = false;
        if(row.permanentReject){
            if(this.cmpObjToApprovalStageMap.has(row.id) && this.cmpObjToApprovalStageMap.get(row.id) != 'L2 Regional Sales'
               && this.cmpObjToApprovalStageMap.get(row.id) != 'L1 Approval'){
                this.showToastMessage('Error','Marketing Campaigns cannot be Terminally Rejected', 'Error', 'pester');
                row.permanentReject = false;
                isInValid = true;
            }
            if(this.campaigntoClaimMap.has(row.id)){
                this.showToastMessage('Error',this.PERMANENT_REJECTION_CLAIM_VALIDATION, 'Error', 'pester');
                row.permanentReject = false;
                isInValid = true;
            }

            if(!isInValid){
                this.showToastMessage('Warning',this.PERMANENT_REJECTION_WARNING , 'warning', 'sticky');
            }
            return isInValid;
        }
    }
    
    
    checkCellValue(event) {
        var tableInput = [];
        tableInput = event.detail.draftValues;
        this.popUpSpinner = true;
        
        if(tableInput != null){
            tableInput.forEach(row => {
                if(!this.isInValidUserInput(row)){
                    if(row.comment != '' && row.comment != null && row.comment != undefined && row.comment.length > 1000){
                        row.comment = row.comment.substring(0,1000); //Truncating the comments entered to 1000 characters
                    }

                if(this.template.querySelector("lightning-datatable") != null && this.template.querySelector("lightning-datatable") != undefined){
                    if(row.hasOwnProperty('comment')){
                        var draftValue = this.template.querySelector("lightning-datatable").draftValues;
                        draftValue.forEach(record => {
                        if(record.id == row.id){
                            record.comment = row.comment;
                        }
                    });
                    this.template.querySelector("lightning-datatable").draftValues = JSON.parse(JSON.stringify(draftValue));
                    this.approvalRequestUI.forEach(content => {
                        content.recordsToApprove.forEach(record => {
                            if (record.id == row.id) {
                                    record.comments = row.comment;
                            }
                        });
                    });

                    this.recordsToFilter.forEach(record => {
                        if (record.id == row.id) {
                                record.comments = row.comment;
                        }
                    });

                    if(this.contentDetailUI != null && this.contentDetailUI.length == 1) {
                        if(this.contentDetailUI[0].id == row.id) { 
                                this.contentDetailUI[0].comments = row.comment;
                        }
                    }
                 }
                    

                    this.recordsToApproveReject.forEach(record => {
                        if(record.requestId == row.id){
                            if(row.hasOwnProperty('comment')){
                                record.comments = row.comment;
                            }
                             if(row.hasOwnProperty('permanentReject')){
                                record.permanentReject = row.permanentReject;
                            }
                        }
                    });

                 }
                }else{
                if(this.template.querySelector("lightning-datatable") != null && this.template.querySelector("lightning-datatable") != undefined){
                    var draftValue = this.template.querySelector("lightning-datatable").draftValues;
                    draftValue.forEach(record => {
                        if(record.id == row.id){
                            record.permanentReject = false;
                        }
                    });
                    this.template.querySelector("lightning-datatable").draftValues = JSON.parse(JSON.stringify(draftValue));
                }
                }
            });
        }
        
        this.popUpSpinner = true;
        this.popUpSpinner = false;
        this.recordsToApproveReject = JSON.parse(JSON.stringify(this.recordsToApproveReject));
        this.contentDetailUI = JSON.parse(JSON.stringify(this.contentDetailUI));
        this.recordsToFilter = JSON.parse(JSON.stringify(this.recordsToFilter));
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));
    }

    handleChangeCheckbox(event){
        this.enabledTerminalRejection = event.target.checked;
        this.recordsToApproveReject.forEach(record => {
                record.permanentReject = event.target.checked;
                if(event.target.checked == true && this.campaigntoClaimMap.has(record.requestId)){
                    this.showToastMessage('Error',this.PERMANENT_REJECTION_CLAIM_VALIDATION, 'Error', 'pester');
                    this.enabledTerminalRejection = false;
                    event.target.checked = false;
                    record.permanentReject = false;
                    return;
                }
        });
    }

    handleRejection(){
        this.handleSingelApproveReject();
    }

    // Gayathri - Smart Assist handler
    handleAISuggestion(event) {
        const recordId = event.target.dataset.id;
        
        if (recordId) {
            // Single record Smart Assist
            this.handleSingleSmartAssist(recordId);
        } else {
            // Bulk Smart Assist
            this.handleBulkSmartAssist();
        }
    }

    // Gayathri - Handle Smart Assist for single record
    handleSingleSmartAssist(recordId) {
        this.showSpinner = true;
        
        // Simulate AI processing
        setTimeout(() => {
            const selectedRecord = this.recordsToFilter.find(record => record.id === recordId);
            if (selectedRecord && (selectedRecord.object === 'Co-Marketing Activity' || selectedRecord.object === 'Outcome-Based Campaign')) {
                let aiSuggestion = '';
                
                if (selectedRecord.object === 'Co-Marketing Activity') {
                    aiSuggestion = 'AI Suggestion: This Co-Marketing Activity aligns with partner engagement strategies and demonstrates strong ROI potential. Recommended for approval based on activity metrics and partner collaboration history.';
                } else if (selectedRecord.object === 'Outcome-Based Campaign') {
                    aiSuggestion = 'AI Suggestion: This Outcome-Based Campaign shows strong performance indicators and aligns with strategic objectives. Recommended for approval based on outcome metrics and partner performance history.';
                } else {
                    aiSuggestion = 'AI Suggestion: This request meets all compliance requirements and is recommended for approval based on partner performance history.';
                }
                this.updateRecordWithAISuggestion(selectedRecord, aiSuggestion);
                this.showToastMessage('Success', 'Smart Assist suggestion applied successfully!', 'success', 'sticky');
            }
            this.showSpinner = false;
        }, 2000);
    }

    // Gayathri - Handle Smart Assist for bulk records
    handleBulkSmartAssist() {
        this.showSpinner = true;
        
        // Simulate AI processing for bulk records
        setTimeout(() => {
            const selectedRecords = this.recordsToFilter.filter(record => 
                record.isSelected && (record.object === 'Co-Marketing Activity' || record.object === 'Outcome-Based Campaign')
            );
            
            let successCount = 0;
            selectedRecords.forEach(record => {
                let aiSuggestion = '';
                
                if (record.object === 'Co-Marketing Activity') {
                    aiSuggestion = 'AI Suggestion: Bulk analysis indicates this Co-Marketing Activity supports strategic partner objectives and shows positive engagement metrics. Recommended for approval.';
                } else if (record.object === 'Outcome-Based Campaign') {
                    aiSuggestion = 'AI Suggestion: Bulk analysis indicates this Outcome-Based Campaign demonstrates strong performance potential and aligns with strategic goals. Recommended for approval.';
                } else {
                    aiSuggestion = 'AI Suggestion: Bulk analysis indicates this request aligns with partner program guidelines and is recommended for approval.';
                }
                this.updateRecordWithAISuggestion(record, aiSuggestion);
                successCount++;
            });
            
            this.showToastMessage('Success', 
                `Smart Assist suggestions applied to ${successCount} record${successCount > 1 ? 's' : ''}!`, 
                'success', 'sticky');
            this.showSpinner = false;
        }, 3000);
    }
    
    // Gayathri - Update record with AI suggestion
    updateRecordWithAISuggestion(record, suggestion) {
        // Update the record's comments with AI suggestion
        record.comments = suggestion;
        
        // Update in all relevant data structures
        this.approvalRequestUI.forEach(content => {
            content.recordsToApprove.forEach(rec => {
                if (rec.id === record.id) {
                    rec.comments = suggestion;
                }
            });
        });
        
        // Update content detail if this record is currently displayed
        if (this.contentDetailUI.length > 0 && this.contentDetailUI[0].id === record.id) {
            this.contentDetailUI[0].comments = suggestion;
        }
        
        // Trigger reactivity
        this.recordsToFilter = JSON.parse(JSON.stringify(this.recordsToFilter));
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));
        this.contentDetailUI = JSON.parse(JSON.stringify(this.contentDetailUI));
    }
       
    handleApproveReject(event) {
        this.approvalButtonName = event.target.name;
        this.approvalSummaryData = [];
        this.recordsToApproveReject = [];
        const currentId = event.target.dataset.id;
        let objectToApprove=event.target.dataset.recordId;
        if(this.cmpObjToApprovalStageMap.has(currentId)){
            if(this.cmpObjToApprovalStageMap.get(currentId) == 'L2 Regional Sales'){
                this.isL2RegionalSales=true;
            }

            if(this.cmpObjToApprovalStageMap.get(currentId) == 'L1 Approval'){
                this.isL1Approval=true;
            }
        }
        
        //Method for validations
        if (this.disableBulkApproval) {
            //To show checkbox for permanent/terminal rejection to L1 Approver & L2 Sales Approver
            //if(this.approvalButtonName == 'Reject' && this.isL2SalesApprover && objectToApprove == 'Campaign' && this.isL2RegionalSales){
            if(this.approvalButtonName == 'Reject' && objectToApprove == 'Campaign' 
                    && ((this.isL2SalesApprover  && this.isL2RegionalSales) || (this.isL1Approver && this.isL1Approval))){
                
                this.isRejectionModalOpen = true;
           }else{
               this.isRejectionModalOpen = false;
           }

            let approvalRecord = {};
            
            var selectedObject = event.target.dataset.recordId;
            this.approvalRequestUI.forEach(content => {
                if (content.objectName == selectedObject) {
                    content.recordsToApprove.forEach(record => {
                        if (record.id == currentId) {
                            approvalRecord = {
                                piwiId: record.piwiId,
                                requestId: record.id,
                                comments: record.comments,
                                actionStatus: this.approvalButtonName,
                                //targetObjectName: selectedObject, indu
                                targetObjectName: this.getApprovalTargetObjectName(selectedObject),
                                isDesktop: this.isDesktop,
                                permanentReject : this.enabledTerminalRejection
                                
                            };
                        }
                    });
                }
            });
            
            this.recordsToApproveReject.push(approvalRecord);
            this.recordsToApproveReject = JSON.parse(JSON.stringify(this.recordsToApproveReject));
            if(!((this.isL2SalesApprover || this.isL1Approver) && objectToApprove == 'Campaign' && this.approvalButtonName == 'Reject' 
                  && (this.isL2RegionalSales || this.isL1Approval))){
                this.handleSingelApproveReject();
            }
        } else {
            this.recordsToFilter.forEach(record => {
                if (record.isSelected) {
                    let isEditable = true;
                    if(this.cmpObjToApprovalStageMap.has(record.id) && this.cmpObjToApprovalStageMap.get(record.id) != 'L2 Regional Sales'
                      && this.cmpObjToApprovalStageMap.get(record.id) != 'L1 Approval'){
                        isEditable = false;
                    }

                    let data = {
                        id: record.id,
                        name: record.title,
                        object: record.object,
                        comment: record.comments,
                        permanentReject: false,
                        isCheckBoxEditable: isEditable
                    };
                   
                    this.approvalSummaryData.push(data);
                    let approvalRecord = {
                        piwiId: record.piwiId,
                        requestId: record.id,
                        comments: record.comments,
                        actionStatus: this.approvalButtonName,
                        //targetObjectName: record.object, indu
                        targetObjectName: this.getApprovalTargetObjectName(record.object),
                        title: record.title,
                        isDesktop: this.isDesktop,
                        permanentReject: false
                    };
                    this.recordsToApproveReject.push(approvalRecord);
                }
            });
            
            if(!(this.approvalButtonName=='Reject' && (this.isL2SalesApprover || this.isL1Approver) && this.objectsToApproved=='Campaign')){
                    this.columns = [...cols].filter(col => col.fieldName != 'permanentReject');
               }
              else{
                    this.columns = [...cols];
                 }
            this.approvalSummaryData = JSON.parse(JSON.stringify(this.approvalSummaryData));
            this.recordsToApproveReject = JSON.parse(JSON.stringify(this.recordsToApproveReject));
            this.isModalOpen = true;
        }
        
    }

    handleChangeComments(event) {
        let selectedId = event.target.dataset.id;
        let selectedObject = event.target.name;
        let value = event.target.value;
        this.approvalRequestUI.forEach(content => {
            if (content.objectName == selectedObject) {
                content.recordsToApprove.forEach(record => {
                    if (record.id == selectedId) {
                        record.comments = value;
                    }
                });
            }
        });
        this.recordsToFilter.forEach(record => {
            if (record.id == selectedId) {
                record.comments = value;
            }
        });
        this.recordsToFilter = JSON.parse(JSON.stringify(this.recordsToFilter));
        this.approvalRequestUI = JSON.parse(JSON.stringify(this.approvalRequestUI));
    }




    closeModal(event) {
        this.isModalOpen = false;
        this.summaryErrors = {};
        this.rowErrors = {};
        this.disableBulkApproveButton = false;
        this.isRejectionModalOpen = false;
        this.enabledTerminalRejection= false;
        this.isL2RegionalSales = false;
        this.isL1Approval = false;
    }

    closeErrorModal() {
        this.isShowResultContent = false;
        location.reload();
    }

    handleSingelApproveReject() {
        this.showSpinner = true;

        this.handleSubmitForApproval();
    }

    handleSubmitForApproval() {
        this.popUpSpinner = true;
        if (this.approvalButtonName == 'Approve') {
            this.onSuccessShowToastMessage = 'Approved Successfully!';
        } else if (this.approvalButtonName == 'Reject') {
            if(this.enabledTerminalRejection ){
                this.onSuccessShowToastMessage = 'Declined Successfully!';
            }
            else{
            this.onSuccessShowToastMessage = 'Rejected Successfully!';
        }
        }
        submitForApproval({ approvalWrapperStr: JSON.stringify(this.recordsToApproveReject) })
            .then(data => {
                this.popUpSpinner = false;
                this.isModalOpen = false;
                this.isRejectionModalOpen = false;
                this.enabledTerminalRejection = false ;
                this.showSpinner = false;
                this.isL2RegionalSales = false;
                this.isL1Approval = false;
                var showToastMsg = '';
                var fireToast = false;
                this.resetDetails();
                var result = JSON.parse(data);
                if (result != null && result != undefined) {
                    if (result.isSuccess) {
                        this.successCount = result.approvalSuccessResult.length;
                        this.successCountMessage = this.successCount == 1 ? this.successCount + ' Record ' + this.onSuccessShowToastMessage : this.successCount + ' Records ' + this.onSuccessShowToastMessage;
                        this.showToastMessage('Success', this.successCountMessage, 'success', 'pester');
                        location.reload();
                    }else {
                        var returnValue = result.approvalTotalResult;
                        if (result.showContent) {
                            if (returnValue != null && returnValue.length > 0) {
                                this.isShowResultContent = true;
                                this.approvalResultContent = returnValue;
                            }
                        } else {
                            if (returnValue.length > 0) {
                                showToastMsg = returnValue[0].message;
                            } else {
                                showToastMsg = result.message;
                            }
                            fireToast = true;
                        }

                        if (fireToast) {
                            var variant = result.variant
                            var header;
                            if (variant == 'warning') {
                                header = 'Alert';
                            } else if (variant == 'info') {
                                header = 'Info';
                            } else if (variant == 'error') {
                                header = 'Error';
                            }
                            this.showToastMessage(header, showToastMsg, variant, 'pester');
                        }
                    }
                }
            })
            .catch(error => {
                this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
                this.popUpSpinner = false;
                this.isModalOpen = false;
                this.showSpinner = false;
            });
            
    }

    resetDetails() {
        this.successCountMessage = '';
        this.disableBulkApproveButton = false;
    }

   /* handleNavigate(event) {
        var selectedRecId = event.target.dataset.recordId;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecId,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }*/
    
     handleNavigate(event) {
    const selectedRecId = event.target.dataset.recordId;
    
    const selectedRecord = this.recordsToFilter.find(rec => rec.id === selectedRecId);
    if (!selectedRecord) return;


    if (selectedRecord.isIPAOutcomeBased) {

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__navItemPage',
            attributes: { apiName: 'Core_MDF_Outcome_Based_Campaign_Detail' },
            state: { c__recordId: selectedRecId }
        }).then(url => {
            window.open(url, "_blank");
        });

    } else {

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: { recordId: selectedRecId, actionName: 'view' }
        }).then(url => {
            window.open(url, "_blank");
        });

    }
}



    showToastMessage(title, message, variant, mode) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            })
        );
    }
    handleSelected(event) {
        if(event.target.checked == false){
            event.target.value = '';
            this.isDisableSearch = false;
        } else {
            this.isDisableSearch = true;
        }
        this.handleFilterSearch(event);
     }
}