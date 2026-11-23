import { LightningElement, wire,api, track } from "lwc";
import getRecordDetail from '@salesforce/apex/Core_IPS_ProjectController_Lex.getRecordDetail';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Core_IPS_Project__c.Id";
import NAME_FIELD from "@salesforce/schema/Core_IPS_Project__c.Name";
import OWNER_FIELD from "@salesforce/schema/Core_IPS_Project__c.OwnerId";
import MPNDA_FIELD from "@salesforce/schema/Core_IPS_Project__c.Core_MPNDA__c";
import STATUS_FIELD from "@salesforce/schema/Core_IPS_Project__c.Core_Status__c";
import PRIVATE_FIELD from "@salesforce/schema/Core_IPS_Project__c.Id";
import DESCRIPTION_FIELD from "@salesforce/schema/Core_IPS_Project__c.Id";
import SUPPORTLEVEL_FIELD from "@salesforce/schema/Core_IPS_Project__c.Name";
import REGION_FIELD from "@salesforce/schema/Core_IPS_Project__c.OwnerId";
import SUBREGION_FIELD from "@salesforce/schema/Core_IPS_Project__c.Core_MPNDA__c";
import MEMBERSINTERESTEDPARTIES_FIELD from "@salesforce/schema/Core_IPS_Project__c.Core_Status__c";
import ISTINTERESTEDPARTIES_FIELD from "@salesforce/schema/Core_IPS_Project__c.Id";
import REMOVENOTIF_FIELD from "@salesforce/schema/Core_IPS_Project__c.Name";
import LASTMODIFYBY_FIELD from "@salesforce/schema/Core_IPS_Project__c.Name";
export default class Core_IPS_ProjectDetails_Lex extends LightningElement {

  @track Id;
  @track Name;
  @track OwnerId;
  @track Mpnda;
  @track Status;
  @track Private;
  @track no_of_opp;
  @track description;
  @track supportLevel;
  @track intelSupportOwner;
  @track region;
  @track partnerSupportOwner;
  @track subRegion;
  @track membersIP;
  @track removeNotif;
  @track ISTIP;
  @track projId;
  @track createdBy;
  @track legacyTeamId;
  @track lastModifyBy;
  @track groupId;
  @track error;
  @track editFlag = false;
  @api recordId;
  connectedCallback() {
      console.log('projectIdinline--'+this.recordId);
    getRecordDetail({
        projectId: this.recordId
    })
      .then((data) => {
        if(data){
          console.log('datain--'+data[0].Name);
          for (let i = 0; i < data.length; i++) {
                  this.Name = data[i].Name,
                  this.OwnerId = data[i].Owner.Name,
                  this.Mpnda = data[i].Core_MPNDA__c,
                  this.Status = data[i].Core_Status__c,
                  this.Private = data[i].Core_IPS_Private__c,
                  this.no_of_opp = data[i].Core_Number_of_Opportunities__c,
                  this.description = data[i].Core_Project_Description__c,
                  this.supportLevel = data[i].Core_IPS_Support_Level__c,
                  this.intelSupportOwner = data[i].Core_IPS_Intel_Support_Owner__r.Name,
                  this.region = data[i].Region__c,
                  this.partnerSupportOwner = data[i].Core_IPS_Partner_Support_Owner__r.Name,
                  this.subRegion = data[i].Sub_Region__c,
                  this.membersIP = data[i].Core_IPS_EnableMemberasInterestedParties__c,
                  this.removeNotif = data[i].Core_IPS_Remove_Notification_Details__c,
                  this.ISTIP = data[i].Core_IPS_Enable_ISTasInterested_Parties__c,
                  this.projId = data[i].Core_IPS_Project_ID__c,
                  this.createdBy = data[i].CreatedById,
                  this.legacyTeamId = data[i].Core_IPS_Legacy_Collab_Team_ID__c,
                  this.lastModifyBy = data[i].LastModifiedById,
                  this.groupId = data[i].Core_IPS_GroupId__c      
          }
        }
      })
      .catch((error) => {
        this.error = error;
      });
  }
  get options(){
    return[
      {label:'Inactive', Value:'Inactive'},
      {label:'Active', Value:'Active'},
      {label:'Draft', Value:'Draft'},
    ];
  }
  handleEditFlag() {
    this.editFlag = true;
  }
  handleNameChange(event) {
    this.Name = event.target.value;
  }
  handleOwnerChange(event) {
    this.OwnerId = event.target.value;
  }
  handleMPNDAChange(event) {
    this.Mpnda = event.target.value;
  }
  handleStatusChange(event) {
    this.Status = event.target.value;
    console.log('statusin--'+this.Status);
  }
  handlePrivateChange(event) {
    this.Private = event.target.value;
  }
  handleDescriptionChange(event) {
    this.description = event.target.value;
  }
  handleSupportLevelChange(event) {
    this.supportLevel = event.target.value;
  }
  handleRegionChange(event) {
    this.region = event.target.value;
  }
  handleSubRegionChange(event) {
    this.subRegion = event.target.value;
  }
  handleMembersIPChange(event) {
    this.membersIP = event.target.value;
  }
  handleRemoveNotifChange(event) {
    this.removeNotif = event.target.value;
  }
  handleISTIPChange(event) {
    this.ISTIP = event.target.value;
  }
  handleLastModifyByChange(event) {
    this.lastModifyBy = event.target.value;
  }
  handleUpdateName() {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[NAME_FIELD.fieldApiName] = this.Name;
    //fields[OWNER_FIELD.fieldApiName] = this.OwnerId;
    fields[MPNDA_FIELD.fieldApiName] = this.Mpnda;
    fields[STATUS_FIELD.fieldApiName] = this.Status;
    //fields[PRIVATE_FIELD.fieldApiName] = this.Private;
    //fields[DESCRIPTION_FIELD.fieldApiName] = this.description;
    /*fields[SUPPORTLEVEL_FIELD.fieldApiName] = this.supportLevel;
    //fields[REGION_FIELD.fieldApiName] = this.region;
    //fields[SUBREGION_FIELD.fieldApiName] = this.subRegion;
    fields[MEMBERSINTERESTEDPARTIES_FIELD.fieldApiName] = this.membersIP;
    fields[ISTINTERESTEDPARTIES_FIELD.fieldApiName] = this.removeNotif;
    fields[REMOVENOTIF_FIELD.fieldApiName] = this.ISTIP;
    //fields[LASTMODIFYBY_FIELD.fieldApiName] = this.lastModifyBy;*/
    console.log('namein--'+this.Name);
    const recordInput = { fields };
    console.log('recin--'+recordInput);
    updateRecord(recordInput)
      .then(() => {
        this.editFlag = false;
      })
      .catch((error) => {
        console.log("Error updating date => " + error.body.message);
      });
  }
}