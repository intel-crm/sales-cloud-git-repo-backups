import { LightningElement, api, wire, track } from 'lwc';
import  fetchAuditDocuments  from '@salesforce/apex/Core_MDF_AuditDoc_POC_Controller.fetchAuditDocuments';
import dummyMethod from '@salesforce/apex/Core_MDF_AuditDoc_POC_Controller.dummyMethod';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class Core_MDF_PIC_Process_FileDetails extends LightningElement {
    auditDocuments;
    emptyAuditDocuments;
    @api auditDocumentNames = [];
    showdropDown = false;
    values = [];
    checkValue = false;
    checkedBoxesIds = [];
    selectedValues = [];
    questionMetadata = [];
    claimLabel = 'Claim';
    options = [{label:'Yes', value: 'Yes'}, {label: 'No', value: 'No'}];
    //@track selectedResponse;
    value = 'Yes';
    showButton = false;showSpinner = false;disableSave=false;
    dummyData = [
        {
            key: 'QC1',
            label: 'Question1',
            effectiveDate:'2021/10/20',
            inEffectiveDate: '2021/12/20',
            response: 'No',
            fileType: 'Proof of Cost',
            fileNames: []
        },
        {
            key: 'QC2',
            label: 'Question2',
            effectiveDate:'2021/10/20',
            inEffectiveDate: '2021/12/30',
            response: 'No',
            fileType: 'Proof of Cost',
            fileNames: []
        },
        {
            key: 'QC3',
            label: 'Question3',
            effectiveDate:'2021/11/20',
            inEffectiveDate: '2021/12/20',
            response: 'No',
            fileType: 'Proof of Branding',
            fileNames: []
        },
        {
            key: 'QC4',
            label: 'Question4',
            effectiveDate:'2021/09/20',
            inEffectiveDate: '2021/10/20',
            response: 'No',
            fileType: 'Proof of Branding',
            fileNames: []
        },
        {
            key: 'QC5',
            label: 'Question5',
            effectiveDate:'2021/09/20',
            inEffectiveDate: '2021/10/20',
            response: 'No',
            fileType: 'Proof of Execution',
            fileNames: []
        },
        {
            key: 'QC6',
            label: 'Question6',
            effectiveDate:'2021/09/20',
            inEffectiveDate: '2021/10/20',
            response: 'No',
            fileType: 'Proof of Execution',
            fileNames: []
        }
    ]
    @api claimId;
    
    connectedCallback() {
        this.showButton = true;
    }

    handleSave() {
        this.disableSave = true;
        this.showSpinner = true;
        dummyMethod()
        .then(res => {
            alert(res);
            this.showSpinner = false;this.disableSave = false;
        }).catch(ex => {alert(ex)});
    }
    @wire( fetchAuditDocuments, {claimId : '$claimId'})
    wiredAuditDocuments({error, data}) {
        let auditDocumentObject = [{fileType: 'Proof of Cost', fileNames: [], uploadedBy: '', uploadedDate: '', title: []},
        {fileType: 'Proof of Branding', fileNames: [], uploadedBy: '', uploadedDate: '', title: []},
        {fileType: 'Proof of Execution', fileNames: [], uploadedBy: '', uploadedDate: '', title:[]}]
        if(data) {
            this.auditDocuments = data;
            if(this.auditDocuments.length > 0) {
                this.auditDocuments.map(auditdoc => {
                    let tempAuditDocs = [];
                    //this.auditDocumentNames = [...auditdoc, {label: auditdoc.Core_MDF_Document_Title__c, value: auditdoc.Core_MDF_Document_Title__c, selected: false}]
                    if(auditdoc.Core_MDF_Document_Types__c.includes(';')) {
                        tempAuditDocs = auditdoc.Core_MDF_Document_Types__c.split(';');
                    } else {
                        tempAuditDocs.push(auditdoc.Core_MDF_Document_Types__c);
                    }
                    console.log("audit document object", auditDocumentObject, auditdoc);
                    auditDocumentObject.map((objVal, index) => {
                       tempAuditDocs.map(tempDoc => {
                           console.log("tempDoc", tempDoc, objVal, tempAuditDocs);
                           if(tempDoc == objVal.fileType) {
                            auditDocumentObject[index].fileNames.push(auditdoc.Core_MDF_Int_Document_Name__c);
                            auditDocumentObject[index].title.push(auditdoc.Core_MDF_Document_Title__c);
                            console.log(auditDocumentObject[index].fileNames);
                           }
                           auditDocumentObject[index].uploadedBy = auditdoc.CreatedBy.Name;
                           auditDocumentObject[index].uploadedDate = auditdoc.CreatedDate;
                       })
                    })
                })
            }
            console.log("audit document object", auditDocumentObject);
            auditDocumentObject.map(docObj => {
                let fileNames = docObj.fileNames.join(';');
                docObj.fileNames = fileNames.replaceAll(';', '<br>');
                let titles = docObj.title.join(';');
                docObj.title = titles.replaceAll(';', '<br>');
            });
            this.auditDocuments = [...auditDocumentObject];
            this.dummyData.map(data => {
                let currentDate = new Date();
                if(new Date(data.inEffectiveDate) >= currentDate) {
                    if(data.fileType == 'Proof of Cost') {
                        data.fileNames.push({label:this.auditDocuments[0].title, value: this.auditDocuments[0].title, selected: false});
                    } else if(data.fileType == 'Proof of Branding') {
                        data.fileNames.push({label:this.auditDocuments[1].title, value: this.auditDocuments[1].title, selected: false});
                    } else {
                        data.fileNames.push({label:this.auditDocuments[2].title, value: this.auditDocuments[2].title, selected: false});
                    }
                    this.questionMetadata.push(data);
                }
            });
            console.log("question meta data", this.questionMetadata);
            this.emptyAuditDocuments = undefined;
        } else {
            this.auditDocuments = null;
            this.emptyAuditDocuments = error;
        }
        var fileSelection = this.template.querySelector(".multiSelectFiles");
        //fileSelection.disablePickilstMethod();
    }

    @api fetchSelectedValues() {

        this.selectedValues = [];

        //get all the selected values
        this.template.querySelectorAll('c-core_-m-d-f_-campaign_-picklist_-selection').forEach(
            element => {
                if (element.selected) {
                    console.log('Awesome' + element.label);
                    let obj = { label: element.label, value: element.value };
                    this.selectedValues.push(element.value);
                }
            }
        );
        console.log('this.selectedValues' + this.selectedValues);
        if(this.selectedValues.length > 0) {
            this.auditDocumentNames.map((auditDoc, index) => {
                this.selectedValues.map((selectVal) => {
                    if(selectVal == auditDoc.value) {
                        this.auditDocumentNames[index].selected = true;
                    }
                })
            })
        }

    }

    onPicklistSelection(event) {
        this.fetchSelectedValues();
        const value = this.selectedValues;
        console.log('lwc event value', value);
    }

    handleChange(event) {
        event.preventDefault();
        const val = event.target.value;
        const name = event.target.name;
        // this.questionMetadata.map(qnMdt => {
        //     if(qnMdt.key === name) {
        //         qnMdt.response = 'yes';
        //     } else {
        //         qnMdt.response = 'No';
        //     }
        // })
        var fileSelection = this.template.querySelector(".multiSelectFiles");
                // if no values are present in budget type list, disable the picklist
                if(fileSelection!==null && fileSelection!== '' && fileSelection !=='undefined' )
                {
                if(val){
                    fileSelection.enablePickilstMethod();
                }
                //enable the picklist when there are values in budget type list
                else{
                    fileSelection.disablePickilstMethod();
                }
            }
    }


}