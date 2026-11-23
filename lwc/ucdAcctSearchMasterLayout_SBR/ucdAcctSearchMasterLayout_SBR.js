import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import profileAccess from "@salesforce/customPermission/SBR_Profile_Access";
import permissionSetAccess from "@salesforce/customPermission/Permission_Set_for_Partner";

import Id from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";
import PROFILE_NAME_FIELD from "@salesforce/schema/User.Profile.Name";
//import validProfiles from '@salesforce/label/c.UCD_Comarketing_ValidProfiles';
//import validProfilesforPartner from '@salesforce/label/c.UCD_Partner_ValidProfiles';
//import validProfilesforAccessEntitlement from '@salesforce/label/c.UCD_Access_Entitlement_ValidProfiles';
import validProfiles from "@salesforce/label/c.UCD_SBR_ValidProfiles";
import InsuffPriviliges from "@salesforce/label/c.UCD_ACM_InsuffPriviliges";
//import SBRMappingdetails from '@salesforce/apex/UCD_GenericAcctSearch_SBR.getSBRProcessMapping';

export default class UcdAcctSearchMasterLayout_SBR extends NavigationMixin(
  LightningElement,
) {
  @track isSpinner = true;
  @track currentUserProfileName;
  //validUserForComarketing = false;
  validUserForPartner = false;
  //validUserForAccessEntitlement = false;
  validUserForSBRRequest = false;
  AuthorizedUser = true;
  acctDetails = {};
  acctSearchStep = false;
  acctCreateStep = false;
  @track intelRecordTypeId;
  currentPageReference = null;

  InsuffPriviligesText = InsuffPriviliges;

  requestValueOption1 = "Opportunity Management";
  requestValueOption2 = "Other";
  requestValueOption3 = "CoMarketing";
  requestValueOption4 = "Partner";
  requestValueOption5 = "Access & Entitlement";

  acctReasonTrail = "Opportunity Management";
  //acctReasonTrail = '';
  acctReasonCreate = true;
  isSubmitDisabled = true;
  requestReasonType = [
    {
      label: "Opportunity Management",
      value: "Creating a new opportunity with no existing customer match",
      id: "Opp",
    },
    {
      label: "Other",
      value: "",
      id: "Oth",
    },
  ];

  constructor() {
    super();
    this.acctSearchStep = true;
    this.acctCreateStep = false;
    this.acctReasonCreate = false;
    this.isSubmitDisabled = true;
  }

  connectedCallback() {
    this.acctSearchStep = true;
    this.acctCreateStep = false;
    this.acctReasonCreate = false;

    /* setTimeout(() => {
            this.isSpinner = false;
        }, 1000);*/
  }

  renderedCallback() {}

  //ankit
  @wire(getRecord, { recordId: Id, fields: [PROFILE_NAME_FIELD] })
  currentUserInfo({ error, data }) {
    if (data) {
      this.currentUserProfileName = data.fields.Profile.value.fields.Name.value;

      for (let i = 0; i < validProfiles.split("|").length; i++) {
        if (validProfiles.split("|")[i] == this.currentUserProfileName) {
          this.validUserForSBRRequest = true;

          break;
        }
      }

      for (let i = 0; i < validProfiles.split("|").length; i++) {
        if (
          validProfiles.split("|")[i] == this.currentUserProfileName ||
          permissionSetAccess
        ) {
          this.validUserForPartner = true;
          break;
        }
      }

      if (this.validUserForSBRRequest == false) {
        this.AuthorizedUser = false;
        console.log("authorized" + this.AuthorizedUser);
      }
      this.isSpinner = false;
    } else if (error) {
    }
  }

  /*  @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          this.intelRecordTypeId = currentPageReference.state?.c__recordTypeId || null;
       }
    }*/

  handleSaveTrail(event) {
    this.isSubmitDisabled = false;
    this.acctReasonTrail = event.target.value;
    console.log("acctReasonTrailtarget" + this.acctReasonTrail);
  }

  acctSearchNextClickHandler(event) {
    this.acctDetails = event.detail;
    this.acctCreateStep = false;
    this.acctSearchStep = false;
    this.acctReasonCreate = true;
  }

  acctCreateBackClickHandler(event) {
    this.acctDetails = event.detail;
    this.acctCreateStep = false;
    this.acctSearchStep = true;
  }

  handleSave(event) {
    this.isOpenModal = true;
    if (!profileAccess) {
      console.log("error89-->");

      const eve = new ShowToastEvent({
        variant: "error",
        title: "Error!",
        message: "you are not authorized",
      });
      this.dispatchEvent(eve);
      console.log("error123-->");
    } else {
      this.acctSearchStep = false;
      this.acctReasonCreate = false;
      this.acctCreateStep = true;
    }
  }
  closeModal(event) {
    this.acctReasonCreate = false;
    const config = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Account",
        actionName: "list",
      },
    };
    this[NavigationMixin.Navigate](config);
  }
  closepopup(event) {
    this.acctReasonCreate = false;
    const config = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Account",
        actionName: "list",
      },
    };
    this[NavigationMixin.Navigate](config);
  }
}