/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';

export default class PrmSelectedPartnerRow extends LightningElement {

    @api sobKey;
    @api specialty;
    @api value = ['option1']; // default value for the checkbox group, this is required 
    @api map1 = new Map();
    @api confirmscreen = false;
    @track comments;
    @api index = [];
    @api checked = false;
    @api supChecked = false;
    @api singleRecChecked = false;
    @api showcheckbox = false;
    @api isSelect = false;
    //@api mapofaccidandspcritid = [];
    @api lstofaccidandspcritid = [];
    @track isspinnerloaded = false;


    get options() {
        var retOps = [];
        //let mapOfAccIdCritId;
        let lstOfSpCritId = [];
        for (let i = 0; i < this.specialty.length; i++) {

            if (this.specialty[i].Specialty_Criteria_Associations__r !== undefined && this.specialty[i].Specialty_Criteria_Associations__r.length > 0) {
                for (let j = 0; j < this.specialty[i].Specialty_Criteria_Associations__r.length; j++) {
                    let optionVal = { label: '', value: '' };
                    optionVal.value = this.specialty[i].Specialty_Criteria_Associations__r[j].PRM_Criteria_Id__c;
                    optionVal.label = this.specialty[i].Specialty_Criteria_Associations__r[j].PRM_Criteria_Id__r.Name;
                    retOps.push(optionVal);
                }
            }
        }
        //To show previously selected criteria Id while persist data(After initial Load of component)
        if (this.lstofaccidandspcritid !== null && this.lstofaccidandspcritid !== undefined) {

            if (this.lstofaccidandspcritid.length > 0) {
                for (let lstRec = 0; lstRec < this.lstofaccidandspcritid.length; lstRec++) {
                    if (this.lstofaccidandspcritid[lstRec].PRM_Account_Id__c === this.sobKey.accountId && this.lstofaccidandspcritid[lstRec].PRM_Partner_Role__c === this.sobKey.acmpartnerRole) {
                        lstOfSpCritId.push(this.lstofaccidandspcritid[lstRec].PRM_Specialty_Criteria_Id__c);
                        if (lstOfSpCritId !== undefined) {
                            if (lstOfSpCritId.length > 0) {
                                this.value = lstOfSpCritId;
                            }
                        }
                    }
                }
            }
        }
        /*const selectedSpCritEvent = new CustomEvent('selectedspsritvalue', { detail: this.value });
        this.dispatchEvent(selectedSpCritEvent);*/

        return retOps;
    }

    handleChange(event) {
        let map1 = new Map();
        let changeValue = new Object();
        changeValue = event.detail.value;
        console.log('changeValue>>', changeValue, 'Type>>', typeof (changeValue));
        //let mapOfAccIdAndRole;
        let currentAccPartnerRole;
        let sobKeyAccId;
        map1 = new Map([[this.sobKey.id, changeValue]]);
        console.log('map1?????', map1);
        currentAccPartnerRole = this.sobKey.acmpartnerRole;
        sobKeyAccId = this.sobKey.accountId;

        event.preventDefault();
        const selectedEvent = new CustomEvent('mapvalue', {
            detail:
                { mapOfAccIdAndspCrit: map1, partnerRole: currentAccPartnerRole, accId: sobKeyAccId }
        });
        this.dispatchEvent(selectedEvent);
    }
    handleCommentChange(evt) {

        var comments = evt.target.value;
        var commentMap;
        commentMap = new Map([[this.sobKey.id, comments != null ? comments : '']]);
        const selectedCommentEvent = new CustomEvent('mapcommentvalue', { detail: commentMap });
        this.dispatchEvent(selectedCommentEvent);
    }
    handleSuppressEmailChange(evt){
        var supEmail = evt.target.checked;
        var suppressEmailMap;
        if (this.supChecked === false) {
            this.supChecked = true;
        }
        else if (this.supChecked === true) {
            this.supChecked = false;
        }
        suppressEmailMap = new Map([[this.sobKey.id, this.supChecked]]);
        const selectedSupEmailEvent = new CustomEvent('mapsupemailvalue', { detail: suppressEmailMap });
        this.dispatchEvent(selectedSupEmailEvent);
    }


    handleCheckboxValue(event) {
        var reccheckboxMap;
        //var accRecId;

        if (this.singleRecChecked === false) {
            this.singleRecChecked = true;
        }
        else if (this.singleRecChecked === true) {
            this.singleRecChecked = false;
            this.checked = false;
        }
        reccheckboxMap = new Map([[this.sobKey.id, this.singleRecChecked]]);
        const newCheckboxEvent = new CustomEvent('mapvaluechange', { detail: reccheckboxMap });
        this.dispatchEvent(newCheckboxEvent);
    }

    handleAllCheckboxValChange(event) {
        if (this.checked === true) {
            this.checked = false;
        }
        else if (this.checked === false) {
            this.checked = true;
        }
        const allCheckboxEvent = new CustomEvent('allcheckboxvaluechange', { detail: this.checked });
        this.dispatchEvent(allCheckboxEvent);
    }
}