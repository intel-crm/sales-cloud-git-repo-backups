import { LightningElement, api, track, wire } from 'lwc';
import getFieldsAndRecords from '@salesforce/apex/Core_MDF_GetObjectDetails.getFieldsAndRecords';
import getFilterCondition from '@salesforce/apex/Core_MDF_GetObjectDetails.getFilterCondition';//Ealay
import portalBaseURL from '@salesforce/label/c.Core_MDF_PFRCommunityLink';
import communityURLSection from '@salesforce/label/c.Core_MDF_CommunityURLSection';
import orgBaseURL from '@salesforce/label/c.Core_MDF_Environment_URL';
import UserType_Standard from '@salesforce/label/c.UserType_Standard';
import activatingPartnerObjLabel from '@salesforce/label/c.Core_MDF_Activating_Partners_Label';  //WW42 Activating Partner label defect fix
import contractLineItemLabel from '@salesforce/label/c.Core_MDF_Contract_Line_Item';
import getClaimData from '@salesforce/apex/Core_MDF_GetObjectDetails.getClaimData';
import getTableHeader from '@salesforce/apex/Core_MDF_GetObjectDetails.getTableHeader';
import getLabelValue from '@salesforce/apex/Core_MDF_GetObjectDetails.getLabelValue';
import evaluateVisibilityCriteria from '@salesforce/apex/Core_MDF_GetObjectDetails.evaluateVisibilityCriteria';

export default class Core_MDF_Generic_Related_List extends LightningElement {

    @api recordId;  // record id from record detail page e.g. ''0012v00002WCUdxAAH'
    @api relatedobjectApiName; //kind of related list object API Name e.g. 'Activating Patners'
    //relatedobjectApiName => relatedobjectApiName
    @api strFields; //fldApiNamesList
    @api criteriaFieldAPIName; // This field will be used in WHERE condition e.g.'campaignId'
    //filter condition as a whole
    //additional filter condition -> string input
    @api additionalCriteria;
    @api sharingFlag;//to query with user context or not
    //Conditions to decide whether to display this whole component, e.g. "someField__c = 'IPA';someField__c = 'CoGTM'"
    @api componentVisibilityCriteria;
    //Logic that combines the above conditions by index, e.g. "1 AND 2 (3 OR 4)"
    @api componentVisibilityCriteriaLogic;
    //Comma separated field API names that should be hidden when no row has a value
    @api hideColumnIfNoData;
    //Field API name whose values across all rows are consolidated and shown as text below the table
    @api messageBelowTable;
    @track tableMessage; //consolidated text shown below the table
    @track componentVisible = true; //controls visibility of the entire component
    @track columns;   //columns for List of fields datatable
    @track tableData;   //data for list of fields datatable

    recordCount; //this displays record count inside the () => totalRecords/dataCount
    objectName; //this displays the Object Name whose records are getting displayed => relatedObjLabel
    //additional where condition 
    //Ealay
    @api restrictFieldVisiblityObjectAPIName;//remove while pushing
    @api restrictFieldVisiblityFieldAPIName;
    @api restrictFieldVisiblityCriteriaFieldAPIName;
    @track filterConditionResult = false;


    tableColumns;
    @api tableHeader; 
    @track showRelatedList = true;
    @track dynamicTableHeader;
    @api strLabels; //TWC3117-17837

     connectedCallback() {
        if(this.recordId?.startsWith('0RB')){
            this.getClaimDetails();
        }
        this.resolveTableHeader();
         this.restrictFieldVisiblityCriteria();
        this.evaluateComponentVisibility();
    }

    checkForUndefinedEmptyAndNull(input) {
        if (input !== undefined && input !== null && input !== "") {
            return true;
        } else {
            return false;
        }

    }

    setObjectName(objectApiName, objectLabel) {
        switch (objectApiName) {
            case 'Core_MDF_Camp_to_ActPartner__c':
                this.objectName = activatingPartnerObjLabel;
                break;
            case 'Core_MDF_Contract_Line_Item__c':
                this.objectName = contractLineItemLabel;
                break;
            default:
                this.objectName = objectLabel;
                break;
        }
    }
    restrictFieldVisiblityCriteria() {
        getFilterCondition({
            recordId: this.recordId,
            restrictFieldVisiblityCriteriaFieldAPIName: this.restrictFieldVisiblityCriteriaFieldAPIName
        })
            .then(result => {
                this.filterConditionResult = result;
                this.loadFieldsAndRecords(); 
            })
            .catch(error => {
                this.error = error;
                console.error('Error in restrictFieldVisiblityCriteria:', error);
            });
    }

     loadFieldsAndRecords() {
        getFieldsAndRecords({
            relatedobjectApiName: this.relatedobjectApiName,
            strFields: this.getQueryFields(),
            criteriaField: this.criteriaFieldAPIName,
            criteriaFieldValue: this.recordId,
            additionalCriteria: this.additionalCriteria,
            sharingFlag: this.sharingFlag,
            strLabels: this.strLabels //TWC3117-17837
        }) 
       
            .then(data => {
                let userType;
                let records = [];
                let listOfFields = [];
                let fieldsDescribe = {};
                let IdToValueMap = {};
                let refFieldsList = [];
                let isCustomObject;
                if (this.checkForUndefinedEmptyAndNull(data)) {
                    userType = data.userType;
                    //retrieved listOfRecords 
                    records = data.recordsData;
                    this.setObjectName(this.relatedobjectApiName, data.objectLabel);
                    isCustomObject = data.isCustomObject;
                    // fieldDataMap = data.fieldDataMap;
                    if (this.checkForUndefinedEmptyAndNull(data.fieldDataMap)) {
                        for (let key in data.fieldDataMap) {
                            fieldsDescribe[key] = data.fieldDataMap[key];
                        }
                    }
                    if (this.checkForUndefinedEmptyAndNull(data.IdToValueMap)) {
                        for (let key in data.IdToValueMap) {
                            IdToValueMap[key] = data.IdToValueMap[key];
                            refFieldsList.push(key);
                        }
                    }
                } else {
                    console.log('error in getFieldsAndRecords:' + data);//error msg in template
                }

                listOfFields = this.strFields.split(',');//remove the condition according
                //Ealay
                if (!this.filterConditionResult) {
                    //this.restrictFieldVisiblityFieldAPIName = 'Core_MDF_Initial_Baseline_Quantity_nbr__c';
                    const fieldsColumnsToRemove = (this.restrictFieldVisiblityFieldAPIName || '').split(',').map(f => f.trim());
                    // Remove only those fields that are in flexipageFieldList
                    listOfFields = listOfFields.filter(field => !fieldsColumnsToRemove.includes(field));
                }

                //Ealay
                let items = []; //local array to prepare columns

                const translatedLabels = (this.checkForUndefinedEmptyAndNull(data) && data.translatedLabels)
                    ? data.translatedLabels
                    : []; //TWC3117-17837 
                //prepare the column with type = url 

                listOfFields.map((element, index) => { //TWC3117-17837
                    let fldDataType;
                    let fldDetail = fieldsDescribe[element];//fldDetail
                    let fldApi = fldDetail['fieldName'];
                    let fldLabel = translatedLabels[index] || fldDetail['fieldLabel']; //TWC3117-17837
                    fldDataType = fldDetail['dataType'];//fldDataType
                    // it will enter this if-block just once
                    if (fldDataType == 'REFERENCE') {

                        items = [...items,
                        {
                            label: fldLabel,
                            fieldName: fldApi + '_URL',
                            type: 'url',
                            typeAttributes: {
                                label: {
                                    fieldName: fldApi
                                },
                                target: '_blank'
                            },
                            sortable: false,
                            hideDefaultActions: true
                        }
                        ];
                    } else {
                        items = [...items, {
                            label: fldLabel,
                            fieldName: fldApi
                        }];
                    }
                });

                //prepare table data
                this.columns = items;
                this.tableColumns = this.columns;
                this.tableData = [];
                records.map(item => {
                    let recData = item;
                    let tdata = {};
                    listOfFields.map(fld => {
                        if (refFieldsList.includes(fld)) {
                            /*let refCol = isCustomObject ? fld.replace('__c', '__r') : fld;
                            tdata[fld] = recData[refCol]['Name'];
                            tdata['URLField'] = userType == UserType_Standard ? orgBaseURL + this.relatedobjectApiName + '/' + item[fld] + '/view' :
                                portalBaseURL + communityURLSection + item[fld];*/

                            const relationshipPath = IdToValueMap[fld]; 
                            const lookupId = item[fld]; 
                            const urlField = fld + '_URL';
                            tdata[fld] = '';
                            tdata[urlField] = '';
                            if (lookupId && relationshipPath) {
                                const [relName, relField] = relationshipPath.split('.');
                                tdata[fld] = recData?.[relName]?.[relField] || '';
                                tdata[urlField] = userType == UserType_Standard ? orgBaseURL + this.relatedobjectApiName + '/' + lookupId + '/view' : portalBaseURL + communityURLSection + lookupId;
                            }
                        }
                        else {
                            let rawValue = recData[fld];
                            const picklistMap = data.picklistTranslatedMap?.[fld];
                            if (picklistMap && picklistMap[rawValue]) {
                                tdata[fld] = picklistMap[rawValue];  // Translated label
                            } else {
                                tdata[fld] = rawValue;  // english value
                            }
                        }
                    })
                    this.tableData.push(tdata);
                });

                //create URL with Id and push it into the array

                //hide columns that have no data across all rows
                this.hideEmptyColumns();

                //consolidate the configured field's values from all rows into the message below the table
                this.buildTableMessage(records, data);

                //assign values to display Object Name and Record Count on the screen
                this.recordCount = this.tableData.length;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                console.log('error', this.error);
                this.tableData = undefined;
                this.recordCount = 0;  //WW42 Activating Partner label defect fix
                this.setObjectName(this.relatedobjectApiName, this.objectName);
            })
    }

    get resolvedHeader() {
        return this.checkForUndefinedEmptyAndNull(this.dynamicTableHeader) ? this.dynamicTableHeader : this.objectName;
    }
    getClaimDetails() {
        getClaimData({
            recordId: this.recordId,
        })
            .then(result => {
                this.showRelatedList = result;
            })
            .catch(error => {
                this.error = error;
            });
    }
    resolveTableHeader(){
        getTableHeader({
            displayHeader: this.tableHeader,
        })
            .then(result => {
                //Metadata translation found -> use it
                if (this.checkForUndefinedEmptyAndNull(result)) {
                    this.dynamicTableHeader = result;
                    return;
                }
                //Otherwise fall back to resolving the value as a Custom Label (localized by user language)
                return this.resolveCustomLabelHeader();
            })
            .catch(error => {
                this.error = error;
            });
    }

    //Resolve the tableHeader value as a Salesforce Custom Label developer name
    resolveCustomLabelHeader() {
        if (!this.checkForUndefinedEmptyAndNull(this.tableHeader)) {
            return;
        }
        return getLabelValue({ labelName: this.tableHeader })
            .then(label => {
                if (this.checkForUndefinedEmptyAndNull(label)) {
                    this.dynamicTableHeader = label;
                }
            })
            .catch(error => {
                this.error = error;
                console.error('Error in resolveCustomLabelHeader:', error);
            });
    }

    //combine showRelatedList (claim logic) with the component visibility criteria result
    get isComponentVisible() {
        return this.showRelatedList && this.componentVisible;
    }

    //Build a single SOQL boolean expression from the criteria conditions and logic input
    buildVisibilityCriteriaString() {
        if (!this.checkForUndefinedEmptyAndNull(this.componentVisibilityCriteria)) {
            return '';
        }
        //Split "cond1;cond2;cond3" into a list of conditions
        const conditions = this.componentVisibilityCriteria
            .split(';')
            .map(c => c.trim())
            .filter(c => c);
        if (!conditions.length) {
            return '';
        }
        //No logic provided -> simply AND all the conditions together
        const logic = (this.componentVisibilityCriteriaLogic || '').trim();
        if (!logic) {
            return conditions.map(c => '(' + c + ')').join(' AND ');
        }
        //Logic provided (e.g. "1 AND 2 OR 3") -> replace each number with its condition
        return logic.replace(/\d+/g, number => {
            const condition = conditions[Number(number) - 1];
            return condition ? '(' + condition + ')' : number;
        });
    }

    //Evaluate whether the current record meets the criteria; hide the whole component if not
    evaluateComponentVisibility() {
        const criteria = this.buildVisibilityCriteriaString();
        //No criteria configured -> component stays visible
        if (!criteria) {
            this.componentVisible = true;
            return;
        }
        evaluateVisibilityCriteria({
            recordId: this.recordId,
            criteria: criteria
        })
            .then(result => {
                this.componentVisible = result;
            })
            .catch(error => {
                this.error = error;
                console.error('Error in evaluateComponentVisibility:', error);
                this.componentVisible = true;
            });
    }

    //Build the field list to query, appending the messageBelowTable field so its value is available
    getQueryFields() {
        const fields = (this.strFields || '').split(',').map(f => f.trim()).filter(f => f);
        if (this.checkForUndefinedEmptyAndNull(this.messageBelowTable)) {
            const msgField = this.messageBelowTable.trim();
            if (!fields.includes(msgField)) {
                fields.push(msgField);
            }
        }
        return fields.join(',');
    }

    //Consolidate the configured field's distinct values across all rows into a single text line
    buildTableMessage(records, data) {
        if (!this.checkForUndefinedEmptyAndNull(this.messageBelowTable)) {
            this.tableMessage = '';
            return;
        }
        const field = this.messageBelowTable.trim();
        const picklistMap = data && data.picklistTranslatedMap ? data.picklistTranslatedMap[field] : undefined;
        const values = [];
        (records || []).forEach(item => {
            let val = item[field];
            if (picklistMap && picklistMap[val]) {
                val = picklistMap[val];
            }
            if (this.checkForUndefinedEmptyAndNull(val) && !values.includes(val)) {
                values.push(val);
            }
        });
        this.tableMessage = values.join(', ');
    }

    //Hide columns whose configured fields have no data in any row
    hideEmptyColumns() {        if (!this.checkForUndefinedEmptyAndNull(this.hideColumnIfNoData)) {
            return;
        }
        const fieldsToCheck = this.hideColumnIfNoData
            .split(',')
            .map(f => f.trim())
            .filter(f => f);
        if (!fieldsToCheck.length || !this.tableData || !this.tableData.length) {
            return;
        }
        const emptyFields = fieldsToCheck.filter(field =>
            this.tableData.every(row => {
                const val = row[field];
                return val === undefined || val === null || val === '';
            })
        );
        if (emptyFields.length) {
            this.columns = this.columns.filter(col => {
                const baseField = col.type === 'url'
                    ? col.typeAttributes?.label?.fieldName
                    : col.fieldName;
                return !emptyFields.includes(baseField);
            });
            this.tableColumns = this.columns;
        }
    }

}