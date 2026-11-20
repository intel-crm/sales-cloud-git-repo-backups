import { LightningElement, api, track } from 'lwc';
import getObjectFields from '@salesforce/apex/Core_MDF_CustomLayoutConfig_Controller.getObjectFields';
import Core_MDF_Custom_LayoutCSS from '@salesforce/resourceUrl/Core_MDF_Custom_Layout';
import { loadStyle } from 'lightning/platformResourceLoader';
import portalBaseURL from '@salesforce/label/c.Core_MDF_PFRCommunityLink';
import communityURLSection from '@salesforce/label/c.Core_MDF_CommunityURLSection';

export default class Core_MDF_CustomLayoutConfig extends LightningElement {
    @api recordId;
    @api objAPIName;
    @api fieldAPIName;
    @api isSectionVisible;
    @api isCompactLayout;
    @api recordTypeName; 
    @api standardFieldAlign;
    @api hasToRetainDecimalValues;
    @track objectFields = [];
    @track compactLayoutFields = [];
    @track quickActionsButtons = [];
    @track quickActionsHideButtons = [];
    @track buttonMenu = false;
    @track activeSections = [];
    @track error;
    @track fieldView;
    @track hasRendered = true;
    @track isShow = false;
    @track parentObjRecordId;
    @track sectionVisible = false;
    @track siteURL;
    @track errorMessage = '';
    @track isSelected = false;
    @track title;
    @track cmptLayoutIcon;
    @track objLabel;
    @track isInternalUser;
    @track isExternalUser;
    @track campaignCSS = '';
    @api fieldAPIoperator;

    connectedCallback() {
         loadStyle(this, Core_MDF_Custom_LayoutCSS);
        if (this.hasRendered) {
            this.hasRendered = false;
            if(this.isCompactLayout == null){
                this.isCompactLayout = 'No';
            }
            this.siteURL = window.location.origin;
            this.fieldView = this.isCompactLayout == 'Yes' ? 'Compact Layout' : 'Detail Layout';
            if (this.isCompactLayout == 'No' && this.isSectionVisible == 'Yes') {
                this.sectionVisible = true;
            }
            console.log('objAPIName--LWC--->>>>>', this.objAPIName);
            this.getObjFields();
            this.campaignCSS = (this.objAPIName === 'Campaign' && this.campaignCSS === '') ? 'slds-p-horizontal_medium' : ''; 
        }
    }

    getObjFields() {
        getObjectFields({
            recordId: this.recordId,
            objAPIName: this.objAPIName,
            fieldAPIName: this.fieldAPIName,
            fieldAPIoperator : this.fieldAPIoperator,
            fieldView: this.fieldView
        }).then((result) => {
            console.log('Result-->' , result);
            if (result != null) {
                this.isShow = true;
                var objProperties = [];
                let objMap = new Map();
                let index = 1;
                let fieldRecord;
                var formatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });
                for (var key in result) {
                    if (key == 'Internal User') {
                        this.isInternalUser = true;
                    } else if (key == 'External User') {
                        this.isExternalUser = false;
                    }
                    for (let i = 0; i < result[key].length; i++) {
                        let record = {};
                        let type;
                        if (result[key][i].fieldValue != '' && result[key][i].fieldValue != null) {
                            if (result[key][i].fieldType == 'REFERENCE') {
                                
                                //record.url = key == 'Internal User' ? `/lightning/r/${result[key][i].parentObjectName}/${result[key][i].fieldValue}/view` : portalBaseURL + communityURLSection + result[key][i].fieldValue;
                                const hasCustomUrl = !!result[key][i].lookupCustomUrlInd;                                
                                if (key == 'Internal User') {                                    
                                    record.url = hasCustomUrl ? `/lightning/n/${result[key][i].lookupCustomUrlValue}?c__recordId=${result[key][i].fieldValue}` : `/lightning/r/${result[key][i].parentObjectName}/${result[key][i].fieldValue}/view`;
                                } else {                                    
                                    record.url = hasCustomUrl ? portalBaseURL +'s/'+ result[key][i].lookupCustomUrlValue + '?recordId=' + result[key][i].fieldValue : portalBaseURL + communityURLSection + result[key][i].fieldValue;
                                }
                                
                                record.urlName = result[key][i].fieldValueName;
                                record.parentObjectId = result[key][i].fieldValue;
                                record.parentObjectName = result[key][i].parentObjectName;
                                record.index = index;
                                record.tabIcon = result[key][i].tabIcon != '' ? result[key][i].tabIcon : '';
                                index = index + 1;
                                type = 'REFERENCE';
                            } else if (result[key][i].fieldType == 'DATE') {
                                var date = new Date(result[key][i].fieldValue);
                                let month = '' + (date.getMonth() + 1);
                                let day = '' + date.getDate();
                                let year = date.getFullYear();
                                result[key][i].fieldValue = [month, day, year].join('/');
                                type = 'STRING';
                            } else if (result[key][i].fieldType == 'BOOLEAN') {
                                record.booleanFieldValue = result[key][i].fieldValue == 'true' ? true : false;
                                type = 'BOOLEAN';
                            } else if (result[key][i].fieldType == 'CURRENCY') {
                                result[key][i].fieldValue = formatter.format(result[key][i].fieldValue);
                                type = 'STRING';
                            } else if (result[key][i].fieldApiName == 'Core_MDF_Budget_Amount_Local_amt__c') { //Akash changes for $ and %
                                result[key][i].fieldValue = formatter.format(result[key][i].fieldValue);
                                type = 'STRING';
                            } else if (result[key][i].fieldType == 'DOUBLE') {
                                let value = result[key][i].fieldValue;
                                if(value.indexOf('.') !== -1){
                                    result[key][i].fieldValue = Number(result[key][i].fieldValue.slice(0, result[key][i].fieldValue.lastIndexOf('.') + 0)).toLocaleString('en-US') + '.' + result[key][i].fieldValue.slice(result[key][i].fieldValue.lastIndexOf('.') + 1);
                                }
                                type = 'STRING';
                            }
                            else {
                                type = 'STRING';
                            }
                        } else {
                            type = 'STRING';
                        }
                        fieldRecord = result[key][i].fieldValue != '' ? record : '';

                        let loc;
                        if(this.standardFieldAlign){
                            //TWC3117-18842
                            if(this.objAPIName === 'Campaign') {
                                const noOfColumns = result[key][i].noOfColumns;
                                if (noOfColumns === '2') {
                                    loc = i % 2 === 0 ? 'standard-align-right-camp' : 'standard-align-left-camp';
                                } else if (noOfColumns === '1') {
                                    loc = 'standard-align-right-camp';
                                } else {
                                    loc = 'standard-align-section2';
                                }
                            } else {
                                loc = result[key][i].noOfColumns == '2' ? i % 2 == 0 ? 'standard-align-right' : 'standard-align-left' : 'standard-align-section2';
                            }
							//TWC3117-18842
                        }else{
                            loc = result[key][i].fieldPosition;
                        }
                        objProperties.push({
                            'label': result[key][i].fieldLabel,
                            'value': type != 'STRING' ? fieldRecord : result[key][i].fieldValue,
                            'isreferenceField': result[key][i].fieldType == 'REFERENCE' ? true : false,
                            'isbooleanField': result[key][i].fieldType == 'BOOLEAN' ? true : false,
                            'isRichTextField': result[key][i].isRichTextField,
                            'istextField':  (type == 'STRING' && !result[key][i].isRichTextField) ? true : false,
                            'position': result[key][i].fieldPosition,
                            'isAccessible': result[key][i].isAccessible,
                            'location':loc,
                            'helpText': result[key][i].helpText,
                            'section': result[key][i].section,
                            'noOfColumns': 12 / result[key][i].noOfColumns,
                            'isVisible': !result[key][i].hideIfNoValue ? true : result[key][i].fieldValue != '' && result[key][i].fieldValue != undefined ? true : false, //condition to make only those fields visible for which the (hideIfNoValue boolean is false) or (hideIfNoValue boolean is true then check if the field has value) 
			                      'isSectionHide' : result[key][i].hideSectionIfNoValue // This checkbox field used as indicator if all fields are having empty values and HideIfNoValue check box is true,then we hide the Section.
                        });
                        // creating a map based on Section
                        if (this.isCompactLayout == 'No') {
                            if (objMap.has(result[key][i].section)) {
                                var objList = objMap.get(result[key][i].section);
                                objList.push(objProperties[i]);
                                objMap.set(result[key][i].section, objList);
                            } else {
                                var objList = [];
                                objList.push(objProperties[i]);
                                objMap.set(result[key][i].section, objList);
                            }
                        }
                    }
                }
           if (this.isCompactLayout == 'No') {
                for (const [key, value] of objMap.entries()) {
                    // The following block of code is used to hide a section if no field have values
                    let showSection= false; // Initialize a boolean variable 'showSection' to false.                
                    for (var sec =0;sec<value.length;sec++){           // Start a for loop to iterate over the 'value' array.
                        if(value[sec].isVisible || (!value[sec].isVisible && !value[sec].isSectionHide)){  //The accordion section should only be displayed, when the any "fields" has a value. If any of the "fields" does not have a value, then the "isSectionVisible" checkbox must be unchecked.
                                showSection=true;
                                break;
                        }    
                    }
                    if(showSection){
                        this.objectFields.push({'key': key, 'value': value});
                        if (this.sectionVisible == true) {
                            this.activeSections.push(key);
                        } 
                    }
                    this.showLoading = false;
                }                   
            }
        } else {
            this.showLoading = false;
        }
        }).catch((error) => {
            console.log('Error in loading. Error : ', error);
        });
    }

    /* Handle Mouse Over*/
    handleMouseover(event) {
        this.parentObjRecordId = null;
        var index = event.target.getAttribute("data-id");
        const toolTipDiv = this.template.querySelector('[data-id="' + index + '"]');
        toolTipDiv.style.opacity = 1;
        toolTipDiv.style.display = "block";
        // eslint-disable-next-line
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            //this.parentObjRecordId = this.recordId;
        }, 200);
    }

    /* Handle Mouse Out*/
    handleMouseout(event) {
        var index = event.target.getAttribute("data-id");
        const toolTipDiv = this.template.querySelector('[data-id="' + index + '"]');
        toolTipDiv.style.opacity = 0;
        toolTipDiv.style.display = "none";
    }
}