import { LightningElement, api, track } from 'lwc';
import getFieldsAndRecords from '@salesforce/apex/Core_MDF_GetObjectDetails.getFieldsAndRecords';
import getFilterCondition from '@salesforce/apex/Core_MDF_GetObjectDetails.getFilterCondition';//Ealay
import portalBaseURL from '@salesforce/label/c.Core_MDF_PFRCommunityLink';
import communityURLSection from '@salesforce/label/c.Core_MDF_CommunityURLSection';
import orgBaseURL from '@salesforce/label/c.Core_MDF_Environment_URL';
import UserType_Standard from '@salesforce/label/c.UserType_Standard';
import activatingPartnerObjLabel from '@salesforce/label/c.Core_MDF_Activating_Partners_Label';  //WW42 Activating Partner label defect fix
import contractLineItemLabel from '@salesforce/label/c.Core_MDF_Contract_Line_Item';

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

     connectedCallback() {
         this.restrictFieldVisiblityCriteria();
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
    /*async restrictFieldVisiblityCriteria() {
         console.log('Start restrictFieldVisiblityCriteria');
        try {
            this.filterConditionResult = await getFilterCondition({ //checkfieldVisisikity
                recordId: this.recordId,
                restrictFieldVisiblityCriteriaFieldAPIName: this.restrictFieldVisiblityCriteriaFieldAPIName
            });
            console.log('filterConditionResult Ealay result -->', this.filterConditionResult);
 
        } catch (error) {
            this.error = error;
            console.error('Error in restrictFieldVisiblityCriteria:', error);
            return false;
        }
    }*/
    restrictFieldVisiblityCriteria() {
        console.log('Start restrictFieldVisiblityCriteria');

        getFilterCondition({
            recordId: this.recordId,
            restrictFieldVisiblityCriteriaFieldAPIName: this.restrictFieldVisiblityCriteriaFieldAPIName
        })
            .then(result => {
                this.filterConditionResult = result;
                this.loadFieldsAndRecords(); 
                console.log('filterConditionResult Ealay result -->', this.filterConditionResult);
            })
            .catch(error => {
                this.error = error;
                console.error('Error in restrictFieldVisiblityCriteria:', error);
            });
    }

     loadFieldsAndRecords() {
        getFieldsAndRecords({
            relatedobjectApiName: this.relatedobjectApiName,
            strFields: this.strFields,
            criteriaField: this.criteriaFieldAPIName,
            criteriaFieldValue: this.recordId,
            additionalCriteria: this.additionalCriteria,
            sharingFlag: this.sharingFlag
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
                console.log('fieldsDescribe:' + JSON.stringify(fieldsDescribe));
                //Ealay
                console.log(' Ealay column hide value -->' + this.restrictFieldVisiblityFieldAPIName);
                if (!this.filterConditionResult) {
                    //this.restrictFieldVisiblityFieldAPIName = 'Core_MDF_Initial_Baseline_Quantity_nbr__c';
                    console.log('Outcome-based result is true — removing FlexiPage fields');
                    const fieldsColumnsToRemove = (this.restrictFieldVisiblityFieldAPIName || '').split(',').map(f => f.trim());
                    // Remove only those fields that are in flexipageFieldList
                    listOfFields = listOfFields.filter(field => !fieldsColumnsToRemove.includes(field));
                }
                console.log(' Ealay filterConditionResult after -->' + this.filterConditionResult);
                console.log('listOfFields:' + JSON.stringify(listOfFields));

                //Ealay
                let items = []; //local array to prepare columns

                //prepare the column with type = url 

                listOfFields.map(element => {
                    let fldDataType;
                    let fldDetail = fieldsDescribe[element];//fldDetail
                    let fldApi = fldDetail['fieldName'];
                    let fldLabel = fldDetail['fieldLabel'];
                    console.log('fldLabel : ' + fldLabel);
                    console.log('tData : ' + fldDetail);
                    fldDataType = fldDetail['dataType'];//fldDataType
                    // it will enter this if-block just once
                    if (fldDataType == 'REFERENCE') {

                        items = [...items,
                        {
                            label: fldLabel,
                            fieldName: 'URLField',
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
                console.log('this.columns 141' + JSON.stringify(this.columns));
                this.tableData = [];
                records.map(item => {
                    let recData = item;
                    let tdata = {};
                    listOfFields.map(fld => {
                        if (refFieldsList.includes(fld)) {
                            let refCol = isCustomObject ? fld.replace('__c', '__r') : fld;
                            tdata[fld] = recData[refCol]['Name'];
                            tdata['URLField'] = userType == UserType_Standard ? orgBaseURL + this.relatedobjectApiName + '/' + item[fld] + '/view' :
                                portalBaseURL + communityURLSection + item[fld];

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

                console.log('records', records);

                //create URL with Id and push it into the array
                console.log('this.tableData 92:' + this.tableData);
                console.log('this.tableData 95:' + JSON.stringify(this.tableData));


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

}