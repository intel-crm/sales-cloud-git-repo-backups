import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import fetchContactEntitlements from '@salesforce/apex/EPUM_PartnerContactEnt_Controller.fetchContactEntitlements';
import saveContactEntitlements from '@salesforce/apex/EPUM_PartnerContactEnt_Controller.saveContactEntitlements';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isLoggedInUserPAOrPAD from '@salesforce/apex/EPUM_SearchContact.isLoggedInUserPAOrPAD';


//import labels
import EmpUnselectErrorMsg from '@salesforce/label/c.EPUM_EmpUnselectErrorMsg';
import BeingRemoved from '@salesforce/label/c.EPUM_BeingRemoved';
import BeingAssigned from '@salesforce/label/c.EPUM_BeingAssigned';
import ResponsibilityName from '@salesforce/label/c.EPUM_ResponsibilityName';
import EPUM_Status from '@salesforce/label/c.EPUM_Status';
import EPUM_Access from '@salesforce/label/c.EPUM_Access';
import EPUM_Save from '@salesforce/label/c.EPUM_Save';
import EPUM_Cancel from '@salesforce/label/c.EPUM_Cancel';
import EPUM_Discard from '@salesforce/label/c.EPUM_Discard';
import EPUM_DoYouWantToSave from '@salesforce/label/c.EPUM_DoYouWantToSave';
import EPUM_AreYouSure from '@salesforce/label/c.EPUM_AreYouSure';
import EPUM_Yes from '@salesforce/label/c.EPUM_Yes';
import EPUM_No from '@salesforce/label/c.EPUM_No';
import EPUM_EmployeeRemoval from '@salesforce/label/c.EPUM_EmployeeRemoval';
import EPUM_ReadOnlyEntit_PA_PAD from '@salesforce/label/c.EPUM_ReadOnlyEntit_PA_PAD';
import EPUM_PADSelectMsg from '@salesforce/label/c.EPUM_PADSelectMsg';
export default class EpumContactEntitlementView extends LightningElement {


    label = {
        EmpUnselectErrorMsg,
        BeingRemoved,
        BeingAssigned,
        ResponsibilityName,
        EPUM_Status,
        EPUM_Access,
        EPUM_Save,
        EPUM_Cancel,
        EPUM_Discard,
        EPUM_DoYouWantToSave,
        EPUM_AreYouSure,
        EPUM_Yes,
        EPUM_No,
        EPUM_ReadOnlyEntit_PA_PAD,
        EPUM_EmployeeRemoval,
        EPUM_PADSelectMsg
    };


    @api scontactId;
    @api selectedconname = '';
    @track errorOccured = false;
    @track lstContactEntitlements;
    @track lstContactEntitlementsOrg;
    @track errorMessageStr;
    @api isCompVisible = false;
    @track requireValidation = false;
    @track isLoading = false;
    @track EmployeeRemoval;
    @track isDisabled = false;
    @track localId = '';
    @track isEmpDeselected = false;
    @track isUnsavedChages = false;
    @track unsavedChangesModal = false;
    @track newconId = '';
    @track isChangedmapMap = new Map();
    @track lstContactEntitlementsMap = new Map();
    @track isSelectedConPartnerAdmin = false;
    @track isLoggedInUserPartnerAdmin = false;
    @track isLoggedInUserPartnerAdminDelegate = false;
    @track isSelectedConPartnerAdminDelegate = false;
    

    constructor() {
        super();
        isLoggedInUserPAOrPAD()
            .then(result => {
                if (result !== undefined) {
                    if (result.isPartnerAdmin) {
                        this.isLoggedInUserPartnerAdmin = true;
                    }
                    if(result.isPartnerAdminDelegate){
                        this.isLoggedInUserPartnerAdminDelegate = true;
                    }
                }
            }).catch(error => {
                console.log('result error' + error)
                this.isLoading = false;
            });
    }


    @api handleValueChange(selectedContactId) {
        this.scontactId = selectedContactId;
        var temp = this.template;
        this.isLoading = true;
        this.isUnsavedChages = false;
        this.errorOccured = false;

        fetchContactEntitlements({
            sContactIdStr: selectedContactId
        }).then(result => {
            if (result != undefined) {
                console.log('updated result'+JSON.stringify(result))
                this.isCompVisible = true;
                this.newconId = '';
                if (result.auraProcessingMessage.isSuccess) {
                    
                    this.EmployeeRemoval = this.label.EPUM_EmployeeRemoval;
                    this.lstContactEntitlements = result.lstContactEntWrapper;
                    var orgData = result.lstContactEntWrapper;
                    this.lstContactEntitlementsOrg = orgData;
                    this.isSelectedConPartnerAdmin = result.selectedConObj.isPartnerAdmin;
                    this.isSelectedConPartnerAdminDelegate = result.selectedConObj.isPartnerAdminDelegate;
                    var isAdminDelegate = false;

                    for (var entList of this.lstContactEntitlements) {
                        var entId = temp.querySelector('.' + entList.entitlementId);
                        if (entId != null && entId != undefined) {
                            entId.checked = entList.isSelected;
                        }
                        // Check PAD is available in the list & it is selected
                        if (entList.strEntName == "Partner Admin Delegate" && entList.isSelected == true) {
                            isAdminDelegate = true;
                        }

                        // set the error msg content as blank
                        if (entList.strEntName == "Employee") {
                            var divs = temp.querySelectorAll('.' + entList.entitlementId), i;
                            for (i = 0; i < divs.length; i++) {
                                divs[i].textContent = '';
                                break;
                            }

                        }

                        this.isChangedmapMap.set(entList.strEntName, false);
                        this.lstContactEntitlementsMap.set(entList.strEntName, entList);

                    }
                    for (var conentList of this.lstContactEntitlements) {


                        // If loggedIn user is Partner Admin Delegate,
                          if(this.isLoggedInUserPartnerAdminDelegate){  

                            //PAD should not able to assign/remove 'Partner Admin Delegate' role to any other contact
                            if (conentList.strEntName == "Partner Admin Delegate") {
                                conentList.readOnly = true;
                            }

                            //PAD should not remove Employee from Other PAD 
                            if(this.isSelectedConPartnerAdminDelegate){
                                if (conentList.strEntName == "Employee") {
                                    conentList.readOnly = true;
                                }
                            }
                        }

                        // If selected Contact is Partner Admin , then no one should remove Employee from that contact
                        if (this.isSelectedConPartnerAdmin && conentList.strEntName == "Employee" && conentList.isSelected == true) {
                            conentList.readOnly = true;
                        }

                        // if PAD is available in the list & it is selected , then other than employee & PAD role , all other should be in read only mode
                        if (isAdminDelegate && this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(conentList.strEntName)) {
                            conentList.readOnly = true;
                        }

                        // selected Contact is also PA , he should not be able to assign any role to himself
                        if (this.isSelectedConPartnerAdmin && (this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(conentList.strEntName) || conentList.strEntName == "Partner Admin Delegate" )) {
                            conentList.readOnly = true;
                        }
                    }

                } else {
                    this.errorMessageStr = result.auraProcessingMessage.errorMsg;
                }
            }
            this.isLoading = false;
            this.isDisabled = true;
            const selectEvent = new CustomEvent('unsavedcustomevent', {
                detail: {
                    change: this.isUnsavedChages,
                    oldcontactId: this.scontactId
                }
            });
            this.dispatchEvent(selectEvent);
        }).catch(error => {
            console.log('result error' + error)
            this.isLoading = false;
        })
    }


    @api savefromParent(selectedContactId, newConId) {
        this.scontactId = selectedContactId;
        this.newconId = newConId;
        var entitlementsList = this.lstContactEntitlements;
        this.saveEntitlementChanges();
    }

    // Method call on save button click
    @api saveEntitlementChanges() {
        this.isLoading = true;
        var conId = '';
        var hvcConId = '';

        if (this.newconId != '' && this.scontactId != '' && this.scontactId != null) {
            hvcConId = this.newconId;
            conId = this.scontactId;
        } else {
            conId = this.scontactId;
            hvcConId = this.scontactId;
        }
        saveContactEntitlements({
            lstContactEntWrapper: this.lstContactEntitlements,
            sContactIdStr: conId
        }).then(result => {
            if (result != undefined && result.length != 0) {
                //this.handleValueChange(hvcConId); 
                this.isCompVisible = false;
                window.location.reload();
            }
        }).catch(error => {
            console.log('error:::::::', error);
            this.isLoading = false;
        })
    }

    confirmationNeeded() {
        if (this.isEmpDeselected) {
            this.requireValidation = true;
        } else {
            this.saveEntitlementChanges();
        }
    }

    saveEntBtn(event) {
        var temp = this.template;
        this.isDisabled = false;
        let val = this.isChangedmapMap.get(event.target.name);
        this.isChangedmapMap.set(event.target.name, !val);

        //this.isEmpDeselected = false;

        for (let obj of this.isChangedmapMap.values()) {
            if (obj) {
                this.isUnsavedChages = true;
                break;
            } else {
                this.isUnsavedChages = false;
            }
        }

        for (let obj of this.isChangedmapMap.keys()) {
            console.log('obj' + this.isChangedmapMap.get(obj));
        }

        // Show the original status when user selects the employee role
        if (event.target.name == "Employee" && event.target.checked == true) {
            
            if (event.target.checked !== this.isChangedmapMap.get("Employee")) {
                this.isEmpDeselected = false;
            }
            

            var emp = this.lstContactEntitlementsMap.get(event.target.name);

            var check = event.target.ariaLabel;
            var divs = temp.querySelectorAll('.' + check), i;

            for (i = 0; i < divs.length; i++) {
                console.log('emp.isSelected' + emp.isSelected);
                divs[i].textContent = '';
                divs[i].textContent = (emp.isSelected) ? (emp.status == 'Processing') ? this.label.BeingAssigned : '' : (emp.status == 'Processing') ? this.label.BeingRemoved : '';
                break;
            }

        }

        // Show the error msg when user deselects the employee role
        if (event.target.name == "Employee" && event.target.checked == false) {
            this.localId = event.target.name;
            if (event.target.checked !== this.isChangedmapMap.get("Employee")) {
                this.isEmpDeselected = true;
            }
            //this.isEmpDeselected = true;
            this.errorOccured = true;


            var check = event.target.ariaLabel;
            var divs = temp.querySelectorAll('.' + check), i;

            for (i = 0; i < divs.length; i++) {
                console.log('div' + divs[i].textContent);
                divs[i].textContent = '';
                let htmlCode1 = "<span class='error' style=\"color: red;\">";
                let htmlCode2 = "</span>";
                divs[i].innerHTML = htmlCode1 + this.label.EmpUnselectErrorMsg + htmlCode2;
                break;
            }
            //this.requireValidation = true;
        }

        if (event.target.name == "Partner Admin Delegate" && event.target.checked == true) {
            var check = event.target.ariaLabel;
            var divs = temp.querySelectorAll('.' + check), i;
            for (i = 0; i < divs.length; i++) {
                console.log('div' + divs[i].textContent);
                divs[i].textContent = '';
                let htmlCode1 = "<span class='PADSelectMsg'>";
                let htmlCode2 = "</span>";
                divs[i].innerHTML = htmlCode1 + this.label.EPUM_PADSelectMsg + htmlCode2;
                break;
            }
            var entitlementsList = this.lstContactEntitlements;
            for (i = 0; i < entitlementsList.length; i++) {
                // if (entitlementsList[i].strEntName != "Partner Admin Delegate" && entitlementsList[i].strEntName != "Employee") {
                //     entitlementsList[i].readOnly = true;
                // }
                
                if (entitlementsList[i].strEntName != "Partner Admin Delegate" && entitlementsList[i].strEntName != "Employee" && this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(entitlementsList[i].strEntName)) {
                    entitlementsList[i].readOnly = true;
                    entitlementsList[i].isSelected = false;

                }
            }
            this.lstContactEntitlements = entitlementsList;
        }

        if (event.target.name == "Partner Admin Delegate" && event.target.checked == false) {

            var check = event.target.ariaLabel;
            var divs = temp.querySelectorAll('.' + check), i;

            for (i = 0; i < divs.length; i++) {
                divs[i].textContent = '';
                break;
            }

            var entTemp = '';
            var entitlementsList2 = this.lstContactEntitlements;
            for (i = 0; i < entitlementsList2.length; i++) {
                if (this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(entitlementsList2[i].strEntName) && entitlementsList2[i].ContactEntitlement && entitlementsList2[i].ContactEntitlement.Core_Selected__c){
                    entTemp += entitlementsList2[i].strEntName + ';';
                }               
            }

            var entitlementsList = this.lstContactEntitlements;
            for (i = 0; i < entitlementsList.length; i++) {
                if (entitlementsList[i].strEntName != "Partner Admin Delegate" && entitlementsList[i].strEntName != "Employee") {
                    entitlementsList[i].readOnly = false;
                }
                if(entTemp.includes(entitlementsList[i].strEntName)){
                    entitlementsList[i].isSelected = true;
                }
            }
            this.lstContactEntitlements = entitlementsList;
        }

        var temp = this.lstContactEntitlements;
        for (var entList of temp) {
            if (event.target.ariaLabel == entList.entitlementId) {
                entList.isSelected = event.target.checked;
            }

        }
        this.lstContactEntitlements = temp;

        const selectEvent = new CustomEvent('unsavedcustomevent', {
            detail: {
                change: this.isUnsavedChages,
                oldcontactId: this.scontactId
            }

        });
        this.dispatchEvent(selectEvent);

    }

    cancelEntitlementChanges() {
        if (this.isUnsavedChages) {
            this.unsavedChangesModal = true;
        } else {
            this.onAccept();
        }
    }

    hideModal(event) {
        this.requireValidation = false;
        this.isCompVisible = false;
        this.notification = false;
        this.handleValueChange(this.scontactId);
    }

    onAgree() {

        var entitlementsList = this.lstContactEntitlements;
        for (i = 0; i < entitlementsList.length; i++) {
            if (entitlementsList[i].strEntName == "Employee" && entitlementsList[i].isSelected == true) {
                entitlementsList[i].isSelected = false;
            }
        }
        this.lstContactEntitlements = entitlementsList;
        this.requireValidation = false;
        this.saveEntitlementChanges();
    }

    onAccept() {
        this.unsavedChangesModal = false;
        this.newconId = '';
        this.saveEntitlementChanges();
    }

    onReject() {
        window.location.reload();
    }
}