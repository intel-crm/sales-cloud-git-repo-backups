import {LightningElement, track, wire, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getObjectInfo, getPicklistValuesByRecordType, getPicklistValues, getObjectInfos} from 'lightning/uiObjectInfoApi';
import PFR_OBJECT from '@salesforce/schema/PartnerFundRequest';
import getObjectFields from '@salesforce/apex/Core_MDF_PartnerFundRequestCreatePage.loadDynamicFields';
import Core_MDF_Save from "@salesforce/label/c.Core_MDF_PFRStatus";

export default class Core_MDF_CreateEditPFR extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordtype;
    @api recordtypeName;
    @api recordtypeDeveloperName;
    @api checkNewCommunityAttribute;
    @api selectedLookUpRecord;
    @api isActivityLayout;
    @api isActivityCreationOnCampaign;
    @api fieldSetName;
    @api mode;
    @track isSaveandNew = false;
    @track checkSaveComplete = false;
    @track picValuesByRecType;
    @track error;
    @track checkStatusAttribute = true;
    @track currentStatus;
    @track isLoaded = false;
    @track PFRFields;
    @track PFRFieldVisibility = {};
    @track PFRFieldDisabled = {};
    @track PFRFieldLabel = {};
    @track PFRFieldHelpText = {};
    @track PFRFieldValue = {};
    @track PFRRequiredFields = {};
    @track PFRPicValues = {};

    @wire(getPicklistValuesByRecordType, {recordTypeId: '$recordTypeId', objectApiName: '$objectApiName'})
    wiredOptions({error, data}){
        if(data){
            this.picValuesByRecType = data;
            this.error = undefined;
            this.initialization();
        }else if(error){
            this.error = error;
            this.picValuesByRecType = undefined;
        }}

    @wire(getObjectInfo, {objectApiName: PFR_OBJECT})
    pfrObjectInfo;
    @wire(getObjectInfos, { objectApiNames: [ CUSTOMPICKLIST_OBJECT] }) 
    objectInfos({data,error}){
        if(data){this.objectInfos = data}else if(error){console.error(error);}}
    @wire(getPicklistValuesByRecordType, { objectApiName: CUSTOMPICKLIST_OBJECT, recordTypeId: '$recTypeId' })
    picklist_Values;
    initialization(){
        this.isLoaded = true;
        this.getPFRFields();
    }

    getPFRFields(){
        getObjectFields({objectName: objAPIName, fieldSetName: this.fieldSetName})
        .then(result => {
            this.PFRFields = result;
            if(this.PFRFields != undefined && this.PFRFields != null){
                for(let i = 0; i < this.campaignFields.length; i++){
                    this.campaignRequiredFields[this.campaignFields[i].fieldAPIName] = this.campaignFields[i].isRequired;
                    this.campaignFieldVisibility[this.campaignFields[i].fieldAPIName] = true;
                    this.campaignFieldDisabled[this.campaignFields[i].fieldAPIName] = false;
                    this.campaignFieldLabel[this.campaignFields[i].fieldAPIName] = this.campaignFields[i].fieldLabel;
                    this.campaignFieldHelpText[this.campaignFields[i].fieldAPIName] = this.campaignFields[i].helpText;
                }
            }
        })
        .catch(e => {
            this.isLoaded = false;
            this.btnDisabled["saveBtn"] = false;
            this.scrollUp();
        })
    }
}