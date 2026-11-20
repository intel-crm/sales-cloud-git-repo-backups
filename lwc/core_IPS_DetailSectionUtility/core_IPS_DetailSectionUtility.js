import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { fireEvent  } from 'c/core_IPS_Pubsub'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from "lightning/navigation";
import MAPRECORD_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Name';
import MAPNAME_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Name__c';
import STATUS_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Status__c';
import OWNER_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.OwnerId';
import OWNERNAME_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.OwnerId';
import SUPPORTORGNAME_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Support_Org_Name__c';
import SUPPORTORG_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Product_Organization__c';
import SUPPORTORGNM_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Product_Organization__r.Name';
import PRDFOCUSAREA_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Product_Organization__r.Core_Organization_Description__c';
import CREATEDBY_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.CreatedById';
import CREATEDBYNAME_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.CreatedBy.Name';
import LASTMODIFIEDBY_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.LastModifiedById';
import LASTMODIFIEDBYNAME_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.LastModifiedBy.Name';
import CREATEDDATE_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.CreatedDate';
import LASTMODIFIEDDATE_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.LastModifiedDate';

import ACCESSFLAG_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_IPS_MAP_Access_Flag__c';
import DESC_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_IPS_MAP_Description__c';

import updateMAPRecord from '@salesforce/apex/Core_IPS_NewMapHomePageController.updateMAPRecord';
import deleteMAPRecord from '@salesforce/apex/Core_IPS_NewMapHomePageController.deleteMAPRecord';

import isCurrentUserOrgAdminMember from '@salesforce/apex/Core_IPS_NewMapHomePageController.isCurrentUserOrgAdminMember';
import isNewMapButtonVisible from '@salesforce/apex/Core_IPS_NewMapHomePageController.isNewMapButtonVisible';

export default class Core_IPS_DetailSectionUtility extends NavigationMixin(LightningElement) {
    
    lightningcardTitle = "Product Access Detail";
    iconName = "standard:product";

    @api recordId;

    @track spinnerOn = false;
    @track isEditEnabled = true;
    @track isEditClicked = false;
    @track currentPageReference;
    @track selectedSupportedOrg;
    @track selectedOwner;
    @track mapRecord;
    @track mapUniqueName;
    @track mapName;
    @track status;
    @track owner;
    @track ownerName;
    @track supportOrgName;
    @track supportOrg;
    @track supportOrgNM; 
    @track productFocusArea;
    @track createdBy;
    @track createdByName;
    @track lastModifiedBy;
    @track lastModifiedByName;
    @track createdDate;
    @track lastModifiedDate; 

    @track mapAccessFlag;
    @track mapDescription;

    @track mapNameTemp;
    @track statusTemp;
    @track productFocusAreaTemp;
    @track supportOrgTemp;
    @track supportOrgNameTemp;
    @track ownerTemp;

    @track accessFlagTemp;
    @track descTemp;
    @track isVisible = false;

    @track isCurUsrOrgAdminMember = false;
    @track accessFlagOptions = [{
            value: 'Par Hidden',
            label: 'Par Hidden'
        },
        {
            value: 'Auto Approve',
            label: 'Auto Approve'
        },
        {
            value: 'Approval Required',
            label: 'Approval Required'
        }
    ];
    @wire(CurrentPageReference)
        currentPageReference;
    
    @wire(getRecord, { recordId: '$currentPageReference.attributes.recordId' , fields: ['Core_IPS_MAP_PAR__c.Owner.Name', MAPRECORD_FIELD, MAPNAME_FIELD, STATUS_FIELD, OWNER_FIELD, SUPPORTORGNAME_FIELD, SUPPORTORG_FIELD, PRDFOCUSAREA_FIELD, CREATEDBY_FIELD, LASTMODIFIEDBY_FIELD, CREATEDBYNAME_FIELD, LASTMODIFIEDBYNAME_FIELD, OWNERNAME_FIELD, SUPPORTORGNM_FIELD, CREATEDDATE_FIELD,  LASTMODIFIEDDATE_FIELD, ACCESSFLAG_FIELD, DESC_FIELD] })
    wiredResult({data, error}) {
        if(data) {
            this.mapRecord = data;
            this.mapUniqueName = getFieldValue(this.mapRecord, MAPRECORD_FIELD);
            this.mapNameTemp = getFieldValue(this.mapRecord, MAPNAME_FIELD); 
            this.mapName = this.mapNameTemp;
            this.ownerTemp = getFieldValue(this.mapRecord, OWNER_FIELD);
            if(this.ownerTemp.startsWith("00G")) {
                this.owner = '/lightning/setup/Queues/page?address=%2Fp%2Fown%2FQueue%2Fd%3Fid%3D'+this.ownerTemp;
            } else {
                this.owner = '/lightning/r/' + this.ownerTemp + '/view'; // '/' + this.ownerTemp; 
            }
            let ownerNameVal = getFieldValue(this.mapRecord, 'Core_IPS_MAP_PAR__c.Owner.Name');
            this.selectedOwner = {
                Name : ownerNameVal
            }
            this.ownerName = ownerNameVal;
            this.supportOrgNameTemp = 
            this.supportOrgName = getFieldValue(this.mapRecord, SUPPORTORGNAME_FIELD);
            this.supportOrgTemp = getFieldValue(this.mapRecord, SUPPORTORG_FIELD);
            fireEvent(this.currentPageReference, 'supportOrgIdPublish', this.supportOrgTemp);
            this.supportOrg = '/lightning/r/' + this.supportOrgTemp + '/view'; //'/' + this.supportOrgTemp;
            let supportOrgName = getFieldValue(this.mapRecord, SUPPORTORGNM_FIELD);
            this.selectedSupportedOrg = { 
                Name: supportOrgName
            }
            this.supportOrgNM = supportOrgName;
            this.productFocusArea = getFieldValue(this.mapRecord, SUPPORTORGNAME_FIELD);
            this.createdBy = '/lightning/r/' + getFieldValue(this.mapRecord, CREATEDBY_FIELD) + '/view'; //'/' + getFieldValue(this.mapRecord, CREATEDBY_FIELD);
            this.createdByName = getFieldValue(this.mapRecord, CREATEDBYNAME_FIELD);
            this.lastModifiedBy = '/lightning/r/' + getFieldValue(this.mapRecord, LASTMODIFIEDBY_FIELD) + '/view'; //'/' + getFieldValue(this.mapRecord, LASTMODIFIEDBY_FIELD);
            this.lastModifiedByName = getFieldValue(this.mapRecord, LASTMODIFIEDBYNAME_FIELD);
            let dt1 = getFieldValue(this.mapRecord, CREATEDDATE_FIELD);
            this.createdDate = new Date(dt1).toLocaleString();
            let dt2 = getFieldValue(this.mapRecord, LASTMODIFIEDDATE_FIELD);
            this.lastModifiedDate = new Date(dt2).toLocaleString();

            this.accessFlagTemp = getFieldValue(this.mapRecord, ACCESSFLAG_FIELD); 
            this.mapAccessFlag = this.accessFlagTemp;

            this.descTemp = getFieldValue(this.mapRecord, DESC_FIELD);
            this.mapDescription = this.descTemp; 

            isCurrentUserOrgAdminMember({ supportOrgId : this.supportOrgTemp }) 
            .then(result => {
                this.isCurUsrOrgAdminMember = result;
                fireEvent(this.currentPageReference, 'isCurUsrOrgAdminMemberPublish', this.isCurUsrOrgAdminMember);
                console.log('core_IPS_DetailSectionUtility ::: this.isCurUsrOrgAdminMember ::: ', result);
            }) 
            .catch(error2 => {
                console.error('core_IPS_DetailSectionUtility ::: error in validating current user is org admin member or not ', error2);
            })

        }
        if(error) {
            console.error('core_IPS_DetailSectionUtility ::: Error in loading MAP Record. Error : ', JSON.stringify(error));
        }
    }

    /*@wire(isNewMapButtonVisible)
    wiredRecords({ data }) {
        if (data) {
            this.isVisible = data;
            fireEvent(this.currentPageReference, 'isAddProductVisiblePublish', this.isVisible);
        }
    }*/

    connectedCallback() {
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        isNewMapButtonVisible()
            .then(result =>{
                this.isVisible = result;
                console.log('core_IPS_DetailSectionUtility ::: this.isVisible ::: ', result);
                fireEvent(this.currentPageReference, 'isAddProductVisiblePublish', this.isVisible);
            })
            .catch(error => {
                console.error('core_IPS_DetailSectionUtility ::: Error in loading isNewMapButtonVisible. Error : ', JSON.stringify(error));
            })
    }

    changeModeToEdit() {
        this.isEditEnabled = false;
        this.isEditClicked = true;
    }

    @track error;
    deleteRec() {
        this.spinnerOn = true;
        let mapRec = {
            Id : this.recordId,
        }
        deleteMAPRecord({rec:mapRec})
            .then(result =>{
                if(result!== undefined && result!==null ) {
                    console.log('Record deleted :::', result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted',
                            variant: 'success'
                        })
                    );
                    this.spinnerOn = false;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Product_Access_Request'
                        }
                    });
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message:'Error deleting record',
                        variant: 'error'
                    })
                );
                this.spinnerOn = false;
                console.error('core_IPS_DetailSectionUtility ::: Error in deleting MAP Record. Error : ', JSON.stringify(error));
            })
    }

    handleSave() {
        this.spinnerOn = true;
        let mapRec = {
            Id : this.recordId,
            Core_Name__c : this.mapNameTemp,
            Core_IPS_MAP_Description__c: this.descTemp,
            Core_IPS_MAP_Access_Flag__c:this.accessFlagTemp
        }
        
        updateMAPRecord({ mapRecord : mapRec })
            .then(result => {
                if (result !== undefined) {
                    this.mapNameTemp = result.Core_Name__c;
                    this.mapName = this.mapNameTemp;
                    this.descTemp = result.Core_IPS_MAP_Description__c;
                    this.mapDescription = this.descTemp; 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record Updated Successfully!',
                            variant: 'success'
                        })
                    );
                    this.isEditClicked = false;
                    this.isEditEnabled = true;
                    this.spinnerOn = false;
                }
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                if(error!==undefined) {
                    console.log("THis is the error: " + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Record Updated Failed!',
                            variant: 'error'
                        })
                    );
                    this.isEditClicked = false;
                    this.isEditEnabled = true;
                }
                this.spinnerOn = false;
                console.error('core_IPS_DetailSectionUtility ::: Error in updating MAP Record. Error : ', JSON.stringify(error));
            })
    }
    handleCancel2() {
        this.isEditClicked = false;
        this.isEditEnabled = true;
    }
    handleMapNameChange(event) {
        console.log('core_IPS_DetailSectionUtility ::: this.mapName ::: '+ event.detail.value);
        this.mapNameTemp = event.detail.value;
    }
handleAccessFlagChange(event) {
        console.log('core_IPS_DetailSectionUtility ::: this.accessFlagTemp ::: '+ event.detail.value);
        console.log('core_IPS_DetailSectionUtility ::: this.accessFlagTempPrevValue ::: '+this.mapAccessFlag);
       
        this.accessFlagTemp = event.detail.value;
    }
    handleDescriptionChange(event) {
        this.descTemp = event.detail.value;
    }
}