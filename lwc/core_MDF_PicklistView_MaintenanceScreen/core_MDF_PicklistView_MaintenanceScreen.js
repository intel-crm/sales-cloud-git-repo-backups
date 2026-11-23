import { LightningElement, track, api, wire } from 'lwc';
import getProgramData from "@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getProgramData";
import getObjectData from "@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getObjectData";
import getFieldData from "@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getFieldData";
import getPicklistValueDetails from "@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getPickListValuesData";
import getRecTypeDetails from "@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.GetRecordType";
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import updatePicklistValue from '@salesforce/apex/PicklistManager.createOrUpdatePLV';
import getPicklistValues from '@salesforce/apex/PicklistManager.getPicklistValues';
import fieldAttributesDetails from '@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.fieldAttributesDetails';
import { getRecordTypeId } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import selectedLabel from "@salesforce/label/c.Core_MDF_Chosen_Label";
import availableLabel from "@salesforce/label/c.Core_MDF_Available_Label";
import getExistingPLValues from '@salesforce/apex/PicklistManager.getExistingPLValues';
import GetRecordType from '@salesforce/apex/PicklistManager.GetRecordType';
import updateRecordTypes from '@salesforce/apex/PicklistManager.createOrUpdateRT';
import userAccess from '@salesforce/apex/PicklistManager.userAccess';
import getDependentFields from '@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getDependentfields';
import getDependentPicklistValues from '@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getDependentPicklistValues';
import getRTdetailsBasedOnObjectSelection from '@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getRTdetailsBasedOnObjectSelection';
import getPicklistValFromGVS from '@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getPicklistValFromGVS';
import getBackFillDetails from '@salesforce/apex/SmartPicklistBackfill.getBackFillDetails';
import getOrgName from '@salesforce/apex/SmartPicklistBackfill.getOrgName';
import getBackFillRecTypesDetails from '@salesforce/apex/SmartPicklistBackfill.getBackFillRecTypesDetails';

export default class core_MDF_PicklistView_MaintenanceScreen extends LightningElement {
    picklistMetadata = [];
    showObject = false;
    showFields = false;
    objData;
    pickListFieldsData;
    programList = [];
    @track isOpen = false;
    testFlag = true;
    programOptions = [];
    @track disableObjectSelection = true;
    selectedProgram;
    objectOptions = [];
    @track fieldOptions = [];
    @track gvsFieldOptions =[];
    @track disableGetPicklistdetails = true;
    showPickListFields = false;
    selectedObject;
    selectedField;
    programSelected = '';
    objectSelected = '';
    @track programValueSelected = '';
    @track objectValueSelected = '';
    @track showAccordion = false;
    showRecordtypeAccordions = false;
    showRTAccordionOnDependencyTab = false;
    showDependencyAccordions = false;
    nodependency = true;
    @track showDependencyTab;
    activeSections = [];
    @track showPicVal;
    draftValues;
    fieldIndex;
    @track recordTypeOptions = [];
    showRecordTypeDetails = false;
    @track val;
    @track pickOpt;
    @track avalPickOpt;

    @track objectApiName;
    @track recordTypeId;
    @track recordTypeName;
    @track selectedRTName;

    @track picklistValues = [];
    availpicklistValues = [];
    @track filteredValues = [];
    @track rTSelectedValuesFD = [];
    @track pValuesforFD = [];
    @track resultList=[];
    selectedfieldName;

    match = [];
    updatedValues = [];
    picklistValuesList = [];

    @track isNewRowEmpty = false;
    @track displayPopUp = false;
    updatedValue;
    currentRowIndex;
    @track showEdit = true;
    @track isSorted = false;
    levelPicklistValues;
    @track refreshTable = true;
    @track oldValue;
    @track isLoading = false;
    @track displayMessage = false;
    @track displayMessageforNoDependency = false;
    @track recordTypeTabName;
    @track gvsName;
    hasEditAccess;
    hasReadOnlyAccess;
    noAccess;
    @track displayMessageforNoRTAccess = false;

    columns = [{ label: 'No.', width: '5%' }, { label: 'PickList Value Label', width: '45%' }, { label: 'Picklist Value API Name', width: '50%' }];
    rtColumn = ['Available Values', 'Selected Values'];
    dpColumn = ['Controlling Field', 'Dependent Field'];
    fdcolumn = ['Client Computing', 'Data Center', 'Network & Intelligent Edge'];
    @track controlval = [];
    @track recordTypeInfos = [];
    @track recordTypeInfosonDep = [];
    @track dependentfieldsInfo = [];
    picklistValues = [];
    availpicklistValues = [];
    filteredValues = [];
    label = { availableLabel, selectedLabel };
    @track recordTypeSelectedPLValues = {};
    @track rTSelVal = {}
    @track recordTypeAvailablePLValues = {};
    @track selPLValues = [];
    @track fieldDependenciesMap = {};
    @track filteredfieldDependenciesMap = {}
    @track rtWrapperforFD;
    @track recId;
    //@track fdtableData = {};
    fdcolumns = [];
    tableData = [];
    treeDataList = [];
    @track processedData=[];
    @track data=[];
    @track dependentField;
    @track selectedFieldLabel;
    @track showBackFillModal = false; //POC
    @track orgName; //POC
    @track backFillBtnName; //POC
    @track showBackFillRecTypeModal; //POC
    @track backFillType;//POC

    //Initializer block - check for user access & load the Program values
    connectedCallback() {
        this.getProgramDetails();
        this.getuserAcess();
    }
    //To check the user access
    getuserAcess() {
        userAccess()
            .then((result) => {
                if (result == 'Edit') {
                    this.hasEditAccess = true;
                }
                else if (result == 'Read') {
                    this.hasReadOnlyAccess = true;
                }
                else if (result == 'No Access') {
                    this.noAccess = true;
                }
            })
            .catch(error => {
                console.log('error', error);
            });
    }
    //To get Program values
    getProgramDetails() {
        console.log('GETPROGRAM inside getProgramDetails method');
        getProgramData()
            .then((data) => {
                let programOpt = []
                if (data.length > 0) {
                    let programOptions = data;
                    programOptions.map(pgm => {
                        programOpt.push({ label: pgm, value: pgm });
                    });
                    this.programOptions = programOpt;
                    console.log('GETPROGRAM DATA programOptions'+programOpt);
                }

            })
            .catch(error => {
                console.log('GETPROGRAM DATA ERROR'+JSON.stringify(error));
                this.error = error;
            });
    }
    //Based on Program selection displaying Object values for selection
    handleProgramselection(event) {
        this.selectedProgram = event.target.value;
        let objOptions = [];
        getObjectData({ program: this.selectedProgram })
            .then(response => {
                if (response != {}) {
                    let objOpt = response;
                    for (const [key, value] of Object.entries(objOpt)) {
                        objOptions.push({ label: value, value: key });
                    }
                    this.objectOptions = objOptions;
                    this.disableObjectSelection = false;
                }
            })
            .catch(error => {
                console.log('error', error);
            })
    }
    //Enabling GetPicklistDetails button only after selecting Program and Object
    handleObjectSelection(event) {
        let objAPIName = event.target.value;
        this.selectedObject = objAPIName;
        this.disableGetPicklistdetails = false;
    }
    //On click of GetPicklistDetails button
    async getPicklistDetails(event) {
        this.showAccordion = true;
        this.fieldOptions = [];
        let data = [];
        this.showEdit = true;
        this.isLoading = true;
        await getFieldData({ objName: this.selectedObject, program: this.selectedProgram })
            .then(result => {
                if (result != {}) {
                    let fielOpt = result;
                    for (const [key, value] of Object.entries(fielOpt)) {
                        fieldAttributesDetails({ program: this.selectedProgram, objName: this.selectedObject, fldName: key })
                            .then(result => {
                                if(result!=null && result!={}){
                                    //This block is added to fetch the values from global values set
                                    if(result.gvsReferenceInd!= false && result.globalValueSetName!=undefined){
                                        this.gvsName = result.globalValueSetName;
                                        getPicklistValFromGVS({ globalValueSetName: this.gvsName })
                                            .then(gvsRes => {
                                                let gvsOpt = gvsRes;
                                                //code continues here.....
                                                if (gvsRes != {} && Object.keys(gvsRes).length) {
                                                    gvsRes.map((gvs, index) => {
                                                        gvs.id = index + 1;
                                                        gvs.isEditable = false;   
                                                        gvs.showEditIcon = result.isLabelNameSameAsAPIName ? false : true;
                                                        this.isSorted = result.sorted;
                                                        this.recordTypeTabName = result.recordTypeTabName!= null ? result.recordTypeTabName:'Picklist Values by RecordType';       
                        
                                                    })
                                                    data = gvsRes;
                                                    this.fieldOptions.push({ label: value, value: key, cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large', isExpanded: false, data: data, iconName: 'utility:chevronright', sort: this.isSorted });
                                                    this.fieldOptions.sort((a, b) => a.label.localeCompare(b.label));
                                                }
                                                //getPicklistValFromGVS method end
                                                }).catch(error => {
                                                    console.log('error at getpickvalfromgvs',error);
                                                })
                                    }
                                    //This block is added to fetch the values from picklist field if it didn't refers global value set
                                    else if(result.gvsReferenceInd == false){
                                        getPicklistValues({ objName: this.selectedObject, fieldAPIName: key })
                                        .then(response => {
                                            if (response != {} && Object.keys(response).length) {
                                                response.map((dt, index) => {
                                                    dt.id = index + 1;
                                                    dt.isEditable = false;   
                                                    dt.showEditIcon = result.isLabelNameSameAsAPIName ? false : true;
                                                    this.isSorted = result.sorted;
                                                    this.recordTypeTabName = result.recordTypeTabName!= null ? result.recordTypeTabName:'Picklist Values by RecordType';       

                                                })
                                                data = response;
                                                this.fieldOptions.push({ label: value, value: key, cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large', isExpanded: false, data: data, iconName: 'utility:chevronright', sort: this.isSorted });
                                                this.fieldOptions.sort((a, b) => a.label.localeCompare(b.label));

                                            }
                                            //getPicklistValues method ends here
                                        }).catch(error => {
                                            console.log('error occurred in getPicklistValues', error);
                                        })
                                        
                                    }
                                    //To sort the fieldOptions
                                    this.fieldOptions.sort((a, b) => a.label.localeCompare(b.label));

                                }

                            //field attributes method end
                            }).catch(error => {
                                console.log('error occured',error);
                            })
                    }

                    //this.fieldOptions = fldOptions;
                    console.log('field options', this.fieldOptions);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('error', error);
                this.isLoading = false;
            })

    }
    async getDataForEachPicklist(fieldAPIName) {
        let data = [];
        await getPicklistValues({ objName: this.selectedObject, fieldAPIName: fieldAPIName })
            .then(response => {
                if (response != {} && Object.keys(response).length) {
                    console.log('OUTPUT : getPicklistValues', response);
                    data = JSON.parse(JSON.stringify(response));
                    return data;
                }
            }).catch(error => {
                console.log('error occurred in getDataForEachPicklist', error);
            })
    }
    //this method will be called on Expansion of picklist field accordion
    getPicklistValueDetailsOnExpand(event) {
        let fieldAPIName = event.currentTarget.dataset.name;
        this.selectedField = fieldAPIName;
        let fldind = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        this.selectedfieldName = this.fieldOptions[fldind].label;
        this.fieldOptions.map((fld, index) => {
            if (fld.value == fieldAPIName) {
                this.fieldOptions[index].isExpanded = this.fieldOptions[index].isExpanded ? false : true;
                if (this.fieldOptions[index].isExpanded) {
                    this.fieldOptions[index].cssClassName = 'slds-section slds-is-open slds-var-p-left_large slds-var-p-right_large';
                    this.fieldOptions[index].iconName = 'utility:chevrondown';
                } else {
                    this.fieldOptions[index].cssClassName = 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large';
                    this.fieldOptions[index].iconName = 'utility:chevronright';
                }
            } else {
                if (this.fieldOptions[index].isExpanded) {
                    this.fieldOptions[index].isExpanded = false;
                }
            }
        });
    }
    //To fetch the recordtype details on clicking of RecordType tab
    getRecordTypeDetails(event) {
        this.isLoading = true;
        let recordTypeWrapperClass = {};
        let recTypeName = event.currentTarget.dataset.name;
        let recTypeIndex = this.recordTypeInfos.findIndex(rt => rt.name == recTypeName);
        if (recTypeIndex != -1) {
            this.recordTypeId = this.recordTypeInfos[recTypeIndex].id;
            recordTypeWrapperClass.recordTypeName = this.recordTypeInfos[recTypeIndex].name;
            recordTypeWrapperClass.recordTypeFullName = this.recordTypeInfos[recTypeIndex].developerName;
            let index = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
            console.log('line 368',this.fieldOptions[index].data);
            console.log('line 334 index', index);
            console.log('line 335', this.fieldOptions);
            console.log('line 442 selected field', this.selectedField);
            let picklistWrapper = {};
            if (index != -1) {
                recordTypeWrapperClass.pLWrapperParams = {
                    objectName: this.selectedObject,
                    fieldName: this.fieldOptions[index].label,
                    fieldAPIName: this.selectedField,
                    picklistValues: this.fieldOptions[index].data,
                    sorted: this.fieldOptions[index].sort
                }
            }
        }

        this.recordTypeInfos.map((recType, index) => {
            if (recType.name == recTypeName) {
                this.recordTypeInfos[recTypeIndex].isExpanded = this.recordTypeInfos[recTypeIndex].isExpanded ? false : true;
                if (this.recordTypeInfos[index].isExpanded) {
                    this.recordTypeInfos[index].cssClassName = 'slds-section slds-is-open slds-var-p-left_large slds-var-p-right_large';
                    this.recordTypeInfos[index].iconName = 'utility:chevrondown';
                } else {
                    this.recordTypeInfos[index].cssClassName = 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large';
                    this.recordTypeInfos[index].iconName = 'utility:chevronright';
                }
            } else {
                if (this.recordTypeInfos[index].isExpanded) {
                    this.recordTypeInfos[index].isExpanded = false;
                }
            }
        });

        console.log('line 478 recordTypeWrapperClass',recordTypeWrapperClass);
        this.getRTValues(recordTypeWrapperClass);
        console.log('rec type id', this.recordTypeId);
        console.log('rectype name line 396', recTypeName);
        this.isLoading = false;

    }
    //to add new row when user clicks on Add button to add a new entry to the picklist field
    addNewRow(event) {
        let fieldAPIName = event.target.dataset.name;
        console.log('in add new row method', fieldAPIName);
        let fieldOpt = JSON.parse(JSON.stringify(this.fieldOptions));
        console.log('in add new row fieldOpt', fieldOpt);
        let index = fieldOpt.findIndex(fld => fld.value == fieldAPIName);
        console.log('in add new row index', index);
        let fieldOptLength = fieldOpt[index].data.length;
        console.log('in add new row fieldOptLength', fieldOptLength);
        const newRow = { label: '', value: '', isActive: '', id: fieldOpt[index].data.length + 1, isNew: true, showEditIcon: fieldOpt[index].data[fieldOptLength - 1].showEditIcon, isEditable: false };
        if (index !== -1) {
            fieldOpt[index].data.push(newRow);
        }
        this.fieldOptions = [...fieldOpt];
        console.log('field options', JSON.stringify(this.fieldOptions));
    }
    //to handle updated value
    handleUpdatedValue(event) {
        this.updatedValue = event.target.value;
        console.log('updatedvalue', this.updatedValue);

        let index = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        let dataindex = this.fieldOptions[index].data.findIndex(fldt => fldt.id == this.currentRowIndex);
        console.log('at 415', this.fieldOptions[index].data[dataindex].label);
        console.log('at 415 value', this.fieldOptions[index].data[dataindex].value);
        //this.fieldOptions[index].data[dataindex].label = this.updatedValue; //commented as part of POC
         //POC start
        if(event.target.dataset.type=='apiname'){
             this.fieldOptions[index].data[dataindex].value = this.updatedValue;
        }
        else{
             this.fieldOptions[index].data[dataindex].label = this.updatedValue;
        }
        //POC end
        if (this.fieldOptions[index].data[dataindex].isNew) {
            this.fieldOptions[index].data[dataindex].value = this.updatedValue;
        }
    }
    //to handle edit
    handleEdit(event) {
        console.log('event', event.target.dataset.name);
        let index = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        console.log('line 452', index);
        this.currentRowIndex = event.target.dataset.name;
        let dataindex = this.fieldOptions[index].data.findIndex(fldt => fldt.id == this.currentRowIndex);
        console.log('line 454', dataindex);
        this.oldValue = this.fieldOptions[index].data[dataindex].label;
        console.log('line 432', this.oldValue);
        this.fieldOptions[index].data[dataindex].isEditable = true;
        if (this.fieldOptions[index].data[dataindex].label != '') {
            this.updatedValue = this.fieldOptions[index].data[dataindex].label;
            console.log('line 457', this.updatedValue);
            console.log('line 458', this.oldValue);
        }
        else {
            this.updatedValue = '';

        }
    }
    //to handle save button
    handleSave(event) {
        console.log('OUTPUT : 384', event.target.dataset.name);
        let fieldAPIName = event.target.dataset.name;
        let index = this.fieldOptions.findIndex(fld => fld.value == fieldAPIName);
        let picklistWrapper = {};
        this.isLoading = true;

        picklistWrapper.objectName = this.selectedObject;
        picklistWrapper.fieldName = this.fieldOptions[index].label;
        picklistWrapper.fieldAPIName = fieldAPIName;
        picklistWrapper.picklistValues = this.fieldOptions[index].data;
        console.log('Inside save data:'+JSON.stringify(this.fieldOptions[index].data));
        picklistWrapper.sorted = this.fieldOptions[index].sort;
        console.log('Inside handleSave picklistvalues:'+picklistWrapper.picklistValues);
        console.log('Inside handleSave picklistvalues sorted:'+picklistWrapper.sorted);

        updatePicklistValue({ pwcParams: picklistWrapper, backfill: false })
            .then(data => {
                console.log('data', JSON.stringify(data));
                console.log('after save field options', this.fieldOptions);
                if (data != {} && data != undefined) {
                    if (Object.keys(data).length > 0 && Object.keys(data)[0] == 'true') {
                        this.fieldOptions[index].isExpanded = true;
                        let picklistData = this.fieldOptions[index].data.filter(dt => dt.isEditable == true);
                        console.log('PICKLIST DATA:'+picklistData);
                        console.log('PICKLIST DATA LENGTH:'+picklistData.length);
                        if (picklistData != undefined && picklistData.length > 0) {
                            console.log('INSIDE PICKLIST DATA:'+picklistData);
                            picklistData.map(pdt => {
                                this.fieldOptions[index].data[(pdt.id - 1)].isEditable = false;
                            });
                        }
                        this.showAccordion = true;
                    }
                }
                this.isLoading = false;

            })
            .catch(ex => {
                console.log('OUTPUT : exception in handleSave', ex);
                this.isLoading = false;
            })
        const successEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Picklist Value inserted successfully',
            variant: 'success'
        });
        this.dispatchEvent(successEvent);
        const errorEvent = new ShowToastEvent({
            title: 'Error',
            message: 'Error Occured while inserting data',
            variant: 'error'
        });

    }
    //removing newly added row data from the datatable
    removeRow(event) {
        //alert('clicked the selected row');
        let delIndex = event.target.dataset.name;
        let index = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        let dataindex = this.fieldOptions[index].data.findIndex(fldt => fldt.id == delIndex);
        this.fieldOptions[index].data.splice(dataindex, 1);
        console.log('after delete', this.fieldOptions);
    }

    //Recordtype values datatable
    get rtTableData() {
        const maxLen = Math.max(
            this.picklistValues.length || 0,
            this.filteredValues.length || 0
        );
        const pickValData = [];
        for (let i = 0; i < maxLen; i++) {
            pickValData.push({
                id: i,
                availableValues: this.filteredValues[i]?.label || '',
                selectedValues: this.picklistValues[i]?.label || ''

            });
        }
        return pickValData;
    }

    handleActive() {
        this.showRecordtypeAccordions = true;
        this.recordTypeInfos = [];
        console.log('line 591 sel field',this.selectedField);
        getRTdetailsBasedOnObjectSelection({objName: this.selectedObject,fieldAPI:this.selectedField})
            .then(res => {
                if(res!= undefined && res != {}){
                    let rTInfo = res;
                    console.log('line 471',rTInfo);
                    rTInfo.map(rT => {
                        this.recordTypeInfos.push({ name: rT.name, id: rT.recordTypeId, label: rT.name, isExpanded: false, cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large', iconName: 'utility:chevronright', isEdit: false, developerName: rT.developerName });
                    });
                }
                console.log('at line 477', this.recordTypeInfos);
            }
            ).catch(error => {
                console.log('error at 619', error);
            });

        
        
    }

    editPicklistValuesOnRT(event) {
        let recTypeId = event.currentTarget.dataset.name;
        let recTypeIndex = this.recordTypeInfos.findIndex(rt => rt.id == recTypeId);
        this.recordTypeInfos[recTypeIndex].isEdit = true;

    }

    get sortedfieldOptions() {
        return this.fieldOptions.sort();
    }

    //to handle on click of save button on recordtype edit screen
    savePicklistValuesOnRT(event) {
        console.log('in save method SV', this.recordTypeSelectedPLValues);
        console.log('in save method AV', this.recordTypeAvailablePLValues);

        let rTypeId = event.currentTarget.dataset.name;
        console.log('line 476', rTypeId);
        let rTypeIndex = this.recordTypeInfos.findIndex(rt => rt.id == rTypeId);
        this.recordTypeInfos[rTypeIndex].isEdit = false;
        console.log('at 483 recordtype name', this.recordTypeInfos[rTypeIndex].name);
        console.log('at 484 Recordtype developer name', this.recordTypeInfos[rTypeIndex].developerName);
        let recordTypeWrapper = {};
        let refreshRTWrapper = {};
        let recordTypeWrapperList = [];
        let pLWrapper = {};
        let selectedValuesonRT = [];
        let fldInd = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        console.log('fldInd', fldInd);
        let picklistVallist = this.fieldOptions[fldInd].data;
        picklistVallist.map(pl => {
            this.recordTypeSelectedPLValues.map(rtPLval => {
                if (pl.label == rtPLval) {
                    selectedValuesonRT.push(pl);
                }
            }
            )
        })
        recordTypeWrapper.recordTypeName = this.recordTypeInfos[rTypeIndex].name;
        recordTypeWrapper.recordTypeFullName = this.selectedObject + '.' + this.recordTypeInfos[rTypeIndex].developerName;
        recordTypeWrapper.pLWrapperParams = {
            objectName: this.selectedObject,
            fieldName: this.fieldOptions[fldInd].label,
            fieldAPIName: this.selectedField,
            //picklistValues: this.fieldOptions[fldInd].data,
            picklistValues: selectedValuesonRT,
            sorted: this.fieldOptions[fldInd].sort
        }
        refreshRTWrapper = JSON.parse(JSON.stringify(recordTypeWrapper));
        refreshRTWrapper.pLWrapperParams.picklistValues = this.fieldOptions[fldInd].data;

        console.log('field values', JSON.stringify(this.fieldOptions[fldInd].data[0]));
        console.log('recordtype wrapper', JSON.stringify(recordTypeWrapper));
        recordTypeWrapperList.push(recordTypeWrapper);
        console.log('record type wrapper list', JSON.stringify(recordTypeWrapperList));
        this.isLoading = true;
        updateRecordTypes({ rtParams: recordTypeWrapper, backfill: false })
            .then(res => {
                console.log('at 553', JSON.stringify(res));
                if (res != {} && res != undefined) {
                    if (Object.keys(res).length > 0 && Object.keys(res)[0] == 'true') {
                        this.getRTValues(refreshRTWrapper);
                        const successEvent = new ShowToastEvent({
                            title: 'Success',
                            message: 'Record Type updated successfully',
                            variant: 'success'
                        });
                        this.dispatchEvent(successEvent);
                    }
                    else {
                        const errorEvent = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error Occured while updating Record Type',
                            variant: 'error'
                        });
                        this.dispatchEvent(errorEvent);
                    }
                }
            }).catch(error => {
                console.log('error', error);
            }).finally(() => {
                this.isLoading = false;
            });
    }
    //to handle on click of cancel button on recordtype edit screen
    handleRTSectionCancel(event) {
        let rTypeId = event.currentTarget.dataset.name;
        let rTypeIndex = this.recordTypeInfos.findIndex(rt => rt.id == rTypeId);
        this.recordTypeInfos[rTypeIndex].isEdit = false;
    }

    //to track the changed values from available to selected in a lightning dual list box
    handleRTValuesChange(event) {
        const selectedOptionsList = event.detail.value;
        //alert(`Options selected: ${selectedOptionsList}`);
        if (selectedOptionsList.length > this.recordTypeSelectedPLValues.length) {
            // Values moved from available to chosen
            const newValues = selectedOptionsList.filter(value => !this.recordTypeSelectedPLValues.includes(value));
            this.recordTypeSelectedPLValues = [...this.recordTypeSelectedPLValues, ...newValues];
            console.log('onchange selected values', newValues);
            console.log('at line491', this.recordTypeSelectedPLValues);
        } else {
            // Values moved from chosen to available
            const removedValues = this.recordTypeSelectedPLValues.filter(value => !selectedOptionsList.includes(value));
            this.recordTypeSelectedPLValues = selectedOptionsList;
            this.recordTypeAvailablePLValues = [...this.recordTypeAvailablePLValues, ...removedValues];
            console.log('on change available values', removedValues);
            console.log('at line 481 final avList', this.recordTypeAvailablePLValues);
        }
    }

    getRTValues(recordTypeWrapperClass) {
        this.isLoading = true;
        getExistingPLValues({ rtwo: recordTypeWrapperClass })
            .then(res => {
                if (res != undefined && res != {}) {
                    console.log('line 578', JSON.stringify(res));
                    this.recordTypeSelectedPLValues = [];
                    this.recordTypeAvailablePLValues = [];
                    let selData = [];
                    let selval = [];
                    const pickVal = res.pLWrapperParams.picklistValues;
                    pickVal.map((value) => {
                        selval.push(value.label);
                        selData.push(value);
                    });
                    console.log('line 589', pickVal);
                    console.log('line 593', selData);
                    this.recordTypeSelectedPLValues = selval;
                    this.picklistValues = selData;
                    console.log('line 681', this.picklistValues);
                    this.picklistValues.forEach(item => {
                        if (item.value.includes('&amp;') && item.label.includes('&amp;')) {
                            item.label = item.label.replaceAll('&amp;', '&');
                            item.value = item.value.replaceAll('&amp;', '&');
                        }
                        if(item.value.includes('&gt;') && item.label.includes('&gt;')) {
                            item.label = item.label.replaceAll('&gt;', '>');
                            item.value = item.value.replaceAll('&gt;', '>');
                        }
                        if(item.value.includes('&lt;') && item.label.includes('&lt;')) {
                            item.label = item.label.replaceAll('&lt;', '<');
                            item.value = item.value.replaceAll('&lt;', '<');
                        }
                    });
                    console.log('line 596', this.picklistValues);
                    
                    this.displayMessageforNoRTAccess = this.picklistValues.length<=0 ? true : false;
                    
                }


                getPicklistValueDetails({ objName: this.selectedObject, picklistField: this.selectedField })
                    .then((res) => {
                        let apvOpt = []
                        console.log('data at 603', JSON.stringify(res));
                        if (res.length > 0) {
                            let availpicklistValues = res;
                            availpicklistValues.map(apv => {
                                apvOpt.push({ label: apv, value: apv, class: "optionClass" });
                            });
                            this.availpicklistValues = apvOpt;
                            //console.log('available' + this.availpicklistValues);
                            console.log('available data' + JSON.stringify(this.availpicklistValues));

                            //To filter available values 
                            const uncommonPairs = [];
                            let allpickOpt = this.availpicklistValues;
                            let selpickOpt = this.picklistValues;
                            let availData = [];
                            allpickOpt.map(availPickVal => {
                                availData.push({ label: availPickVal.label, value: availPickVal.value });
                                let selectedPickValIndex = this.picklistValues.findIndex(plv => plv.label == availPickVal.label);
                                console.log('selected pic val ind', selectedPickValIndex);
                                if (selectedPickValIndex == -1) {
                                    uncommonPairs.push({ label: availPickVal.label, value: availPickVal.value });
                                }
                            });
                            this.recordTypeAvailablePLValues = availData;
                            console.log('uncommon pairs' + JSON.stringify(uncommonPairs));
                            console.log('recordTypeAvailablePLValues', JSON.stringify(this.recordTypeAvailablePLValues));
                            this.filteredValues = uncommonPairs;
                            console.log('line 629', this.filteredValues);
                            this.filteredValues.forEach(item => {
                                if (item.value.includes('&amp;') && item.label.includes('&amp;')) {
                                    item.label = item.label.replaceAll('&amp;', '&');
                                    item.value = item.value.replaceAll('&amp;', '&');
                                }
                            });
                            console.log('line 728', this.filteredValues);

                        }

                    })
                    .catch(error => {
                        this.error = error;
                    });
                this.isLoading = false;
            }
            ).catch(error => {
                console.log('error', error);
                this.isLoading = false;
            });
    }

    handleInputEditCancel(event) {
        let index = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        this.currentRowIndex = event.target.dataset.name;
        let dataindex = this.fieldOptions[index].data.findIndex(fldt => fldt.id == this.currentRowIndex);
        this.fieldOptions[index].data[dataindex].isEditable = false;
        console.log('line 721', this.oldValue);
        this.fieldOptions[index].data[dataindex].label = this.oldValue;
    }
    handleBackFillBtn(event){
        this.orgName = this.getOrgDetails();
        var buttonName = event.target.dataset.name;
        console.log('BUTTON NAME:'+buttonName);
        if(buttonName ="backFillBtn"){
            this.showBackFillModal = true;
        }
        if(buttonName ="backFillBtnRecType"){
            this.showBackFillRecTypeModal = true;
        }
        console.log('Inside showBackFillModal'+this.showBackFillModal);
        console.log('Inside showBackFillRecTypeModal'+this.showBackFillRecTypeModal);
         
    }

    getOrgDetails(){
        getOrgName()
            .then(res => {
               console.log('Inside getOrgName:'+JSON.stringify(res));
               this.orgName = res;
               if( this.orgName=="crmdevint3" || this.orgName=="crmdevsls3"){
                this.backFillBtnName = "DEVSLS";
               }
               if( this.orgName=="crmQA7"){
                this.backFillBtnName = "DEVINT";
               }
            }
            ).catch(error => {
                console.log('Inside getOrgName error', error);
            });

    }
    
    hideBackFillModal(event){
         this.showBackFillModal = false;
    }

    handlebackfill(event) {
        
        console.log('INSIDE BACKFILL');
         let fieldAPIName = event.target.dataset.name;
         console.log('INSIDE BACKFILL FIELDAPINAME:'+fieldAPIName);
        let index = this.fieldOptions.findIndex(fld => fld.value == fieldAPIName);
        console.log('INSIDE BACKFILL  index:'+index);
        let picklistWrapper = {};
        this.isLoading = true;

        picklistWrapper.objectName = this.selectedObject;
        picklistWrapper.fieldName = this.fieldOptions[index].label;
        picklistWrapper.fieldAPIName = fieldAPIName;
        picklistWrapper.picklistValues = this.fieldOptions[index].data;
        picklistWrapper.sorted = this.fieldOptions[index].sort;;
        console.log('INSIDE BACKFILL picklistValues:'+JSON.stringify(picklistWrapper.picklistValues));
        console.log('INSIDE BACKFILL picklistWrapper:'+JSON.stringify(picklistWrapper));
        getBackFillDetails( {pwcParams: picklistWrapper})
            .then(res => {
               console.log('Inside bckfill result:'+res);
            }
            ).catch(error => {
                console.log('Inside backfill error', error);
            });

    }
    hideBackFillRectypeModal(event){
         this.showBackFillRecTypeModal = false;
    }
    handlebackfillRecType(event) {
        console.log('Inside rectype recordTypeInfos:'+this.recordTypeInfos);
        let rTypeId = event.currentTarget.dataset.name;
        let rTypeIndex = this.recordTypeInfos.findIndex(rt => rt.id == rTypeId);
        this.recordTypeInfos[rTypeIndex].isEdit = false;
        let recordTypeWrapper = {};
        let refreshRTWrapper = {};
        let recordTypeWrapperList = [];
        let pLWrapper = {};
        let selectedValuesonRT = [];
        let fldInd = this.fieldOptions.findIndex(fld => fld.value == this.selectedField);
        let picklistVallist = this.fieldOptions[fldInd].data;
        picklistVallist.map(pl => {
            this.recordTypeSelectedPLValues.map(rtPLval => {
                if (pl.label == rtPLval) {
                    selectedValuesonRT.push(pl);
                }
            }
            )
        })
        recordTypeWrapper.recordTypeName = this.recordTypeInfos[rTypeIndex].name;
        recordTypeWrapper.recordTypeFullName = this.selectedObject + '.' + this.recordTypeInfos[rTypeIndex].developerName;
        recordTypeWrapper.pLWrapperParams = {
            objectName: this.selectedObject,
            fieldName: this.fieldOptions[fldInd].label,
            fieldAPIName: this.selectedField,
            //picklistValues: this.fieldOptions[fldInd].data,
            picklistValues: selectedValuesonRT,
            sorted: this.fieldOptions[fldInd].sort
        }
        refreshRTWrapper = JSON.parse(JSON.stringify(recordTypeWrapper));
        refreshRTWrapper.pLWrapperParams.picklistValues = this.fieldOptions[fldInd].data;
        this.isLoading = true;
        console.log('Inside rectype recordTypeWrapper:'+this.recordTypeWrapper);
        getBackFillRecTypesDetails({ recTypeParams: recordTypeWrapper })
            .then(res => {
                console.log('at getBackFillRecTypesDetails', JSON.stringify(res));
                
            }).catch(error => {
                console.log('error', error);
            }).finally(() => {
                this.isLoading = false;
            });
      

    }
    //method to handle dependency tab
    handleDependency() {
        this.isLoading = true;
        this.showDependencyAccordions = true;
        //this.dependentfieldsInfo = [];
        this.recordTypeInfosonDep = [];
        this.displayMessage = false;
        let fdata = [];

        getDependentFields({ objName: this.selectedObject, fldName: this.selectedField })
            .then(res => {
                if (res != undefined && res != {}) {

                    let depInfo = res;
                    console.log('line 799', JSON.stringify(res));
                    this.displayMessage=Object.keys(depInfo).length === 0;
                    console.log('line 840',this.displayMessage);
                }
            }
            ).catch(error => {
                console.log('error', error);
            });

        getRTdetailsBasedOnObjectSelection({objName: this.selectedObject,fieldAPI:this.selectedField})
            .then(res => {
                if (res != undefined && res != {}) {
                    let rTInfo = res;
                    console.log('line 471', rTInfo);
                    rTInfo.map(rT => {
                        this.recordTypeInfosonDep.push({ name: rT.name, id: rT.recordTypeId, label: rT.name, isExpanded: false, cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large', iconName: 'utility:chevronright', isEdit: false, developerName: rT.developerName });
                    });
                }
                console.log('at line 819', this.recordTypeInfosonDep);
                this.isLoading = false;
            }
            ).catch(error => {
                this.isLoading = false;
                console.log('error', error);
            });

            this.isLoading = false;
    }
    getFDDetails(event) {
        this.isLoading = true;
        let dfldName = event.currentTarget.dataset.name;
        let dfldIndex = this.dependentfieldsInfo.findIndex(df => df.name == dfldName);
        this.dependentField=this.dependentfieldsInfo[dfldIndex].label;
        if(this.selectedField='Core_MDF_Controlling_Field_nm__c'){
            this.controllingFieldLabel=this.selectedfieldName+' (Budget Type/Focus Area Values)';
        }
        else{
            this.controllingFieldLabel=this.selectedfieldName;
        }
        let recordTypeWrappperForFD = {};
        let rTIndex = this.recordTypeInfosonDep.findIndex(rt => rt.name == this.selectedRTName);
        if (rTIndex != -1) {
            recordTypeWrappperForFD.recordTypeName = this.selectedRTName;
            recordTypeWrappperForFD.recordTypeFullName = this.recordTypeInfosonDep[rTIndex].developerName;
            //let pLWrapperforFD = {};
            if (dfldIndex != -1) {
                recordTypeWrappperForFD.pLWrapperParams = {
                    objectName: this.selectedObject,
                    fieldName: this.dependentfieldsInfo[dfldIndex].label,
                    fieldAPIName: this.dependentfieldsInfo[dfldIndex].name,
                    picklistValues: this.dependentfieldsInfo[dfldIndex].data,
                    sorted: true
                }
            }

        }
        
        this.rtWrapperforFD = recordTypeWrappperForFD
        console.log('recordTypeWrappperForFD', this.rtWrapperforFD);
        console.log('line 902', this.pValuesforFD);

        this.dependentfieldsInfo.map((dfld, index) => {
            if (dfld.name == dfldName) {
                this.dependentfieldsInfo[dfldIndex].isExpanded = this.dependentfieldsInfo[dfldIndex].isExpanded ? false : true;
                if (this.dependentfieldsInfo[index].isExpanded) {
                    this.dependentfieldsInfo[index].cssClassName = 'slds-section slds-is-open slds-var-p-left_large slds-var-p-right_large';
                    this.dependentfieldsInfo[index].iconName = 'utility:chevrondown';
                } else {
                    this.dependentfieldsInfo[index].cssClassName = 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large';
                    this.dependentfieldsInfo[index].iconName = 'utility:chevronright';
                }
            } else {
                if (this.dependentfieldsInfo[index].isExpanded) {
                    this.dependentfieldsInfo[index].isExpanded = false;
                }
            }
        });
        console.log('line 914', this.selectedRTName);
        let recTypeIndex = this.recordTypeInfosonDep.findIndex(rt => rt.name == this.selectedRTName);
        let recordtypeId = this.recordTypeInfosonDep[recTypeIndex].id;
        console.log('line 916', this.recordTypeInfosonDep[recTypeIndex].id);
        this.recId = this.recordTypeInfosonDep[rTIndex].Id;
        //console.log('recId',this.recId);
        console.log('dfldName',dfldName);
        getDependentPicklistValues({ objName: this.selectedObject, fieldAPI: dfldName,recordtypeId:this.recordTypeInfosonDep[recTypeIndex].id })
            .then(res => {
                if (res != undefined && res != {}) {
                    let dep = res;
                    let cv = []
                    let fmap = {};
                    const treeData = [];
                    this.displayMessageforNoDependency =Object.keys(dep).length === 0;
                    console.log('line 844' + JSON.stringify(res));
                    this.fieldDependenciesMap={};
                    for (let [key, value] of Object.entries(dep)) {
                        let temp=[];
                        for (let i of value){
                             i=i.includes('&amp;')?i.replaceAll('&amp;','&'):(i.includes('&gt;')?i.replaceAll('&gt;','>'):(i.includes('&lt;')?i.replaceAll('&lt;','<'):i));
                             temp = [...temp,i];
                             console.log('line 941',i);

                        }
                        console.log('line 951',temp);
                        value = temp;

                        console.log('line 939',key);
                        cv.push(key);
                        console.log('line 936', value);
                        //fmap.push(key,value);
                        //this.fieldDependenciesMap.push({ key:key, value:value });
                        this.fieldDependenciesMap[key] = value;
                        this.fieldDependenciesMap = { ...this.fieldDependenciesMap};
                    }
                    console.log(cv);
                    this.controlval = cv;
                    //this.fieldDependenciesMap = dep;
                    console.log('line 963',this.fieldDependenciesMap);
                    this.processedData = [];
                    for (const [key, value] of Object.entries(this.fieldDependenciesMap)) {
                        this.processedData.push({ key: key, value: value });
                    }
                    console.log('processedData',this.processedData);

                }
                this.isLoading = false;
            }
            ).catch(error => {
                console.log('error at 935', error);
                this.isLoading = false;
            });
    }
    //creating row data for each field dependency map
    /*createTableData() {
        let rows = [];
        const maxRowCount = this.getMaxRowCount();

        for (let i = 0; i < maxRowCount; i++) {
            let rowData = {};

            Object.keys(this.fieldDependenciesMap).forEach((key) => {
                let list = this.fieldDependenciesMap[key];
                rowData[key] = list[i] || '';
            });

            rowData['id'] = i; // Adding an 'id' field for the key-field in the datatable
            rows.push(rowData);
        }

        return rows;
    }*/
    //to get the maximum list size
    /*getMaxRowCount() {
        return Math.max(...Object.values(this.fieldDependenciesMap).map((list) => list.length));
    }*/
    getFDDetailsBasedonRecordType(event) {
        this.isLoading = true;
        let recTypeName = event.currentTarget.dataset.name;
        let recTypeIndex = this.recordTypeInfosonDep.findIndex(rt => rt.name == recTypeName);
        this.selectedRTName = recTypeName;
        console.log('this.selectedRTName',this.selectedRTName);
        this.recordTypeInfosonDep.map((recType, index) => {
            if (recType.name == recTypeName) {
                this.recordTypeInfosonDep[recTypeIndex].isExpanded = this.recordTypeInfosonDep[recTypeIndex].isExpanded ? false : true;
                if (this.recordTypeInfosonDep[index].isExpanded) {
                    this.recordTypeInfosonDep[index].cssClassName = 'slds-section slds-is-open slds-var-p-left_large slds-var-p-right_large';
                    this.recordTypeInfosonDep[index].iconName = 'utility:chevrondown';
                } else {
                    this.recordTypeInfosonDep[index].cssClassName = 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large';
                    this.recordTypeInfosonDep[index].iconName = 'utility:chevronright';
                }
            } else {
                if (this.recordTypeInfosonDep[index].isExpanded) {
                    this.recordTypeInfosonDep[index].isExpanded = false;
                }
            }
            
        });
        getDependentFields({ objName: this.selectedObject, fldName: this.selectedField })
            .then(res => {
                if (res != undefined && res != {}) {
                    this.isLoading = true;
                    this.dependentfieldsInfo = [];
                    let depInfo = res;
                    this.displayMessageforNoDependency=false;
                    console.log('line 799', JSON.stringify(res));
                    this.displayMessage=Object.keys(depInfo).length === 0;
                    console.log('line 840',this.displayMessage);
                    for (const [key, value] of Object.entries(depInfo)) {
                        console.log('line 832', key);
                        //if(this.dependentfieldsInfo.findIndex(df => df.label == value)== -1){
                        getDependentPicklistValues({ objName: this.selectedObject, fieldAPI: key,recordtypeId:this.recordTypeInfosonDep[recTypeIndex].id })
                        .then(fdres=>{
                            console.log('1102',fdres);
                            this.displayMessageforNoDependency =Object.keys(fdres).length === 0?true:false;
                            console.log('line 1103',this.displayMessageforNoDependency);
                            if(fdres!=undefined && fdres!= {}){
                                if(!this.displayMessageforNoDependency){
                            console.log('line1104',Object.keys(fdres).length);
                            this.dependentfieldsInfo.push({ name: key, id: key, label: value, isExpanded: false, cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large', iconName: 'utility:chevronright' });
                                }
                            }
                            console.log('line 1133',this.dependentfieldsInfo);
                            this.isLoading = false;
                        }
                        ).catch(error=>{
                            console.log('error at 1105',error);
                            this.isLoading = false;
                        }
                        );

                        //this.dependentfieldsInfo.push({ name: key, id: key, label: value, isExpanded: false, cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large', iconName: 'utility:chevronright' });
                        //}
                    }
                    
                    this.dependentfieldsInfo.sort((a, b) => a.label.localeCompare(b.label));
                    this.dependentfieldsInfo=this.dependentfieldsInfo.sort();
                    console.log('this.dependentfieldsInfo', this.dependentfieldsInfo);
                    this.showRTAccordionOnDependencyTab = true; // need to fix this 
                    console.log('this.showRTAccordionOnDependencyTab', this.showRTAccordionOnDependencyTab);
                }
                console.log('this.showRTAccordionOnDependencyTab', this.showRTAccordionOnDependencyTab);
                console.log('at line 804', this.dependentfieldsInfo);
                this.isLoading = false;
            }
            ).catch(error => {
                console.log('error', error);
                this.isLoading = false;
            });

        this.isLoading = false;

    }

}