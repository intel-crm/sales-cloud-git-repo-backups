import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import fetchContactEntitlements from '@salesforce/apex/EPUM_PartnerContactEnt_Controller.fetchContactEntitlements';
import saveContactEntitlements from '@salesforce/apex/EPUM_PartnerContactEnt_Controller.saveContactEntitlements';
import updateContactStatus from '@salesforce/apex/EPUM_PartnerContactEnt_Controller.updateContactStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isLoggedInUserPAOrPAD from '@salesforce/apex/EPUM_SearchContact.isLoggedInUserPAOrPAD';
import showReInvite from '@salesforce/apex/EPUM_SearchContact.showReInvite';
import Id from '@salesforce/user/Id';


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
import EPUM_EntSaveConfirmationHeader from '@salesforce/label/c.EPUM_EntSaveConfirmationHeader';
import EPUM_EntSaveConfirmationMsg from '@salesforce/label/c.EPUM_EntSaveConfirmationMsg';
import EPUM_Close from '@salesforce/label/c.EPUM_Close';
import 	EPUM_PAtoPAMessage from '@salesforce/label/c.EPUM_PAtoPAMessage';
import 	EPUM_PADtoPADMessage from '@salesforce/label/c.EPUM_PADtoPADMessage';
import PMP_Request_Support_URL from '@salesforce/label/c.PMP_Request_Support_URL';
import EPUM_lastSignin from '@salesforce/label/c.EPUM_LastSignIn';
import EPUM_PartnerRoleTitle from '@salesforce/label/c.EPUM_PartnerRoleTitle';
import EPUM_delete from '@salesforce/label/c.EPUM_Delete';
import EPUM_reInviteUser from '@salesforce/label/c.EPUM_ReinviteUser';


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
        EPUM_PADSelectMsg,
        EPUM_Close,
        EPUM_EntSaveConfirmationHeader,
        EPUM_EntSaveConfirmationMsg,
        EPUM_PAtoPAMessage,
        EPUM_PADtoPADMessage,
        PMP_Request_Support_URL,
        EPUM_lastSignin,
        EPUM_PartnerRoleTitle,
        EPUM_delete,
        EPUM_reInviteUser
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
    @track ContactUser_Id = '';
    @track isChangedmapMap = new Map();
    @track lstContactEntitlementsMap = new Map();
    @track isSelectedConPartnerAdmin = false;
    @track isLoggedInUserPartnerAdmin = false;
    @track isLoggedInUserPartnerAdminDelegate = false;
    @track isSelectedConPartnerAdminDelegate = false;
    @track paToPaMessage = false;
    @track padToPadMessage = false;
    @track padSelectMsg = '';
    comprised = 'Comprised of ';
    @track EntSavedconfirmPopup = false;
    refreshTimeout = 5000;

    @track selectedConDetails;
    @track sameOPIDUser = false;


    constructor() {
        super();
        isLoggedInUserPAOrPAD()
            .then(result => {
                if (result !== undefined) {
                    if (result.isPartnerAdmin) {
                        this.isLoggedInUserPartnerAdmin = true;
                    }
                    if (result.isPartnerAdminDelegate) {
                        this.isLoggedInUserPartnerAdminDelegate = true;
                    }
                }
            }).catch(error => {
                console.log('result error' + error)
                this.isLoading = false;
            });
    }

contactDetails;
showInviteOp;
showEntitlements = true;
showDelete;
showInviteButton;
    @api handleValueChange(selectedContactIdWrap) {
        this.buttonDisable = false;
        console.log(this.unsavedChangesModal);
        this.unsavedChangesModal = false;
        this.inviteUser = false;
        this.showEntitlements = true;
        this.scontactId = selectedContactIdWrap.selectedContactId;
        console.log(Object.assign({},selectedContactIdWrap.selectedConDetails));
        this.contactDetails = Object.assign({},selectedContactIdWrap.selectedConDetails);
        this.showInviteOp = false;
        this.ContactUser_Id = selectedContactIdWrap.selectedConDetails.ContactUser_Id;
        if(this.contactDetails.activeStatus != 'Active'){
        this.showEntitlements = false;

        showReInvite({
            cId: this.scontactId
        }).then(result =>{
            if (result != undefined)
            this.showInviteOp = true;

            else
            this.showInviteOp = false;
        }).catch(error => {
            console.log('result error' + error)
            //this.isLoading = false;
        })}
        

        console.log("con details");
        console.log(selectedContactIdWrap.selectedConDetails);
        this.selectedConDetails = selectedContactIdWrap.selectedConDetails;
        this.loggedUserOPID = selectedContactIdWrap.loggedUserOPID;
        this.loggedUserPartnerRole = selectedContactIdWrap.loggedUserPartnerRole;
        this.searchKeyword = selectedContactIdWrap.selectedContactEmail;//subhadeep change
        if (this.selectedConDetails.ContactOPID_Id == this.loggedUserOPID && this.selectedConDetails.ContactPartnerRole == this.loggedUserPartnerRole) {
            //alert('in same opid role');
            console.log(this.scontactId);
            console.log(Id);
            this.sameOPIDUser = true;
            //this.buttonDisable = false;
            this.showDelete = true;
            this.showInviteButton = true;
            if(this.ContactUser_Id == Id){
                //this.buttonDisable = true;
                this.showDelete = false;
            }
        } else {
            //alert('in diff opid role');
            this.sameOPIDUser = false;
            //this.buttonDisable = true;
            this.showDelete = false;
            this.showInviteButton = false;
            console.log('this.showInviteOp' + this.showInviteOp);
        }
        
        console.log('Same OPID checked inside the loop. The result is: ' + this.sameOPIDUser)
        var temp = this.template;
        this.isLoading = true;
        this.isUnsavedChages = false;
        this.errorOccured = false;
        this.padSelectMsg = '';
        //console.log(this.selectedConDetails)
        fetchContactEntitlements({
            sContactIdStr: selectedContactIdWrap.selectedContactId
        }).then(result => {
            if (result != undefined) {
                //console.log('updated result' + JSON.stringify(result))
                this.isCompVisible = true;
                this.paToPaMessage = false;
                this.padToPadMessage = false;
                this.newconId = '';
                if (result.auraProcessingMessage.isSuccess) {

                    this.EmployeeRemoval = this.label.EPUM_EmployeeRemoval;
                    this.lstContactEntitlements = result.lstContactEntWrapper;
                    var orgData = result.lstContactEntWrapper;
                    this.lstContactEntitlementsOrg = orgData;
                    this.isSelectedConPartnerAdmin = result.selectedConObj.isPartnerAdmin;
                    this.isSelectedConPartnerAdminDelegate = result.selectedConObj.isPartnerAdminDelegate;
                    var isAdminDelegate = false;
                    console.log(this.isSelectedConPartnerAdmin + ' '+this.isLoggedInUserPartnerAdminDelegate);
                    if(this.isSelectedConPartnerAdmin) //|| this.isSelectedConPartnerAdminDelegate)
                        this.showDelete = false;

                    for (var entList of this.lstContactEntitlements) {

                        //form dynamic PAD select msg
                        if (this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(entList.strEntName)) {
                            if (this.padSelectMsg == '') {
                                this.padSelectMsg = this.comprised + entList.entitlementNameStr + ', ';
                            } else {
                                this.padSelectMsg = this.padSelectMsg + entList.entitlementNameStr + ', ';
                            }
                        }
                        var entId = temp.querySelector('.' + entList.entitlementId);
                        if (entId != null && entId != undefined) {
                            entId.checked = entList.isSelected;
                        }
                        // Check PAD is available in the list & it is selected
                        if (entList.strEntName == "Partner Admin Delegate" && entList.isSelected == true) {
                            isAdminDelegate = true;
                        }

                        if(entList.strEntName == "Employee" && entList.isSelected == false){
                            //this.m = true;
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
                    this.padSelectMsg = this.padSelectMsg.substring(0, this.padSelectMsg.length - 2);
                    for (var conentList of this.lstContactEntitlements) {
                        // Non marketplace related entitlements should be visible only when logged in User OPID and selected contact OPID is same
                        // If logged in User OPID and selected contact OPID is different, only MP entitlements to be shown
                        if (this.sameOPIDUser == false && this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(conentList.strEntName) == false) {
                            conentList.isVisible = false;
                        } else {
                            conentList.isVisible = true;
                        }
                        console.log(conentList.strEntName + ' is Visible: ' + conentList.isVisible)


                        // If loggedIn user is Partner Admin Delegate,
                        if (this.isLoggedInUserPartnerAdminDelegate) {

                            //PAD should not able to assign/remove 'Partner Admin Delegate' role to any other contact
                            if (conentList.strEntName == "Partner Admin Delegate") {
                                conentList.readOnly = true;
                            }

                            //PAD should not remove Employee from Other PAD 
                            if (this.isSelectedConPartnerAdminDelegate) {
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
                        if (this.isSelectedConPartnerAdmin && (this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(conentList.strEntName) || conentList.strEntName == "Partner Admin Delegate")) {
                            conentList.readOnly = true;
                        }

                        // If selected Contact is PA, all the entitlements shall be in Read-Only and PA message shall be displayed
                        // Added by Akshay as part of TWC1811-161
                        if (this.isSelectedConPartnerAdmin && this.isLoggedInUserPartnerAdmin) {
                            //conentList.readOnly = true;
                            this.paToPaMessage = true;
                        }

                        // If PAD selects PAD, all the entitlements shall be in Read-Only and PAD message shall be displayed
                        // Added by Akshay as part of TWC1811-161
                        if (this.isSelectedConPartnerAdminDelegate && this.isLoggedInUserPartnerAdminDelegate && this.isLoggedInUserPartnerAdmin == false && this.isSelectedConPartnerAdmin == false) {
                            //conentList.readOnly = true;
                            this.padToPadMessage = true;
                        }

                        //If helptext is not there in entitlement detail, then dont show in the helptext icon in UI
                        if(conentList.entitlehelpText && conentList.entitlehelpText != null){
                            conentList.showHelpText = true;
                        }
                    }

                } else {
                    this.errorMessageStr = result.auraProcessingMessage.errorMsg;
                }
            }
            //this.buttonDisable = false;//subhadeep
            this.isLoading = false;
            this.isDisabled = true;
            const selectEvent = new CustomEvent('unsavedcustomevent', {
                detail: {
                    change: this.isUnsavedChages,
                    oldcontactId: this.scontactId
                    //conEntLoad: this.showConEntDetails//subhadeep change
                }
            });
            this.dispatchEvent(selectEvent);
            //this.showConEntDetails = false;
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
            if (result != undefined) {
                //this.handleValueChange(hvcConId); 
                this.isCompVisible = false;
                this.isLoading = false;
                console.log('result' + result)
                /*
                if (result) {
                    this.EntSavedconfirmPopup = true;
                    setTimeout(function () {
                        window.location.reload();
                    }, this.refreshTimeout);
                } else {
                    window.location.reload();
                }
                */
                const selectEvent = new CustomEvent('unsavedcustomevent', { //Akshay change
                    detail: { //Akshay change
                        change: false, //Akshay change
                        oldcontactId: this.scontactId, //Akshay change
                        navToList: true //Akshay change
                    }
                });
                this.dispatchEvent(selectEvent); //Akshay change
            }
        }).catch(error => {
            console.log('error:::::::', error);
            this.isLoading = false;
        })
        this.unsavedChangesModal = false;
    }

    confirmationNeeded() {
        if (this.isEmpDeselected) {
            this.requireValidation = true;
        } else {
            this.saveEntitlementChanges();
        }
    }

    saveEntBtn(event) {
        //alert('hi');
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
            this.buttonDisable = true;
        }

        if (event.target.name == "Partner Admin Delegate" && event.target.checked == true) {
            var check = event.target.ariaLabel;
            var divs = temp.querySelectorAll('.' + check), i;
            for (i = 0; i < divs.length; i++) {
                console.log('div' + divs[i].textContent);
                divs[i].textContent = '';
                let htmlCode1 = "<span class='PADSelectMsg'>";
                let htmlCode2 = "</span>";
                divs[i].innerHTML = htmlCode1 + this.padSelectMsg + htmlCode2;
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
                if (this.label.EPUM_ReadOnlyEntit_PA_PAD.includes(entitlementsList2[i].strEntName) && entitlementsList2[i].ContactEntitlement && entitlementsList2[i].ContactEntitlement.Core_Selected__c) {
                    entTemp += entitlementsList2[i].strEntName + ';';
                }
            }

            var entitlementsList = this.lstContactEntitlements;
            for (i = 0; i < entitlementsList.length; i++) {
                if (entitlementsList[i].strEntName != "Partner Admin Delegate" && entitlementsList[i].strEntName != "Employee") {
                    entitlementsList[i].readOnly = false;
                }
                if (entTemp.includes(entitlementsList[i].strEntName)) {
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
                oldcontactId: this.scontactId,
                //navToList: true//subhadeep change
            }

        });
        this.dispatchEvent(selectEvent);

    }

    cancelEntitlementChanges() {
        if (this.isUnsavedChages) {
            console.log('in if cancel');
            this.unsavedChangesModal = true;
        } else {
            console.log('in else cancel');
            //this.onAccept();
            this.isCompVisible = false;
            const selectEvent = new CustomEvent('unsavedcustomevent', {
                detail: {
                    change: this.isUnsavedChages,
                    oldcontactId: this.scontactId,
                    navToList: true//subhadeep change
                }
            });
            this.dispatchEvent(selectEvent);
        }

       /* let conEntl = this.template.querySelector('[data-id="redDiv"]');
        console.log("Scroll back up on Cancel to: " + conEntl);
        conEntl.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
        this.isCompVisible = false; */

        //let conEntl = this.template.querySelector("c-e-p-u-m-search-contact-l-w-c");
        //console.log(conEntl);
        /*if (this.isUnsavedChages) {
            this.unsavedChangesModal = true;
        } else {
            this.onAccept();
        }*/
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
        
        this.unsavedChangesModal = false;
        window.location.reload();
        this.EntSavedconfirmPopup = false;
        //this.sendCusEvent();
    }


    sendCusEvent(){
        const selectEvent = new CustomEvent('hidelistview', {
            detail: {
                hideDetails: true//subhadeep change
            }

        });
        this.dispatchEvent(selectEvent);
    }

    //subhadeep changes start
    inviteUser = false;
    searchKeyword = '';
    @track buttonDisable;
    suspendMembership(){
        //this.lstContactEntitlements.contactStatus = "Suspend";
        //console.log(this.lstContactEntitlements);
        this.isLoading =true;
        console.log(this.scontactId);
        //console.log(event.target.id.split('-')[0]);
        updateContactStatus({
            conId : this.scontactId,
            conStatus : this.contactDetails.activeStatus
            //conStatus : event.target.id.split('-')[0]
        }).then(result => {
            if (result != undefined) {
                this.isCompVisible = false;
                this.isLoading = false;
                console.log('result' + result)
                if (result) {
                    //this.inviteUser = true;
                    this.EntSavedconfirmPopup = true;
                    this.buttonDisable = true;
                    //this.showInviteOp = false;
                    /*setTimeout(function () {
                        window.location.reload();
                    }, this.refreshTimeout);*/
                } else {
                    console.log('in error');
                    //window.location.reload();
                }
            }
        }).catch(error => {
            console.log('error:::::::', error);
            this.isLoading = false;
        })
    }


    showConfirmation= false;
    showInviteModal(){
        console.log('in invite user');
        console.log(this.template.querySelector('c-e-p-u-m-invite-user-l-w-c'));
        this.template.querySelector("c-e-p-u-m-invite-user-l-w-c").sendInvitetoUser(this.contactDetails);
        this.isLoading = true;
       /* const selectEvent = new CustomEvent('unsavedcustomevent', {
            detail: {
                hideConDetl: true
                //change: this.isUnsavedChages,
                //oldcontactId: this.scontactId,
                //navToList: true//subhadeep change
            }

        });
        this.dispatchEvent(selectEvent);
        this.isCompVisible = false;*/
        //this.inviteUser = true;
    }

    removeIPAContact(){
        this.showConfirmation = false;
        this.suspendMembership();

    }
    cancelIPAModal(){
        this.showConfirmation = false;
    }
    doSuspend(){
        this.showConfirmation = true; 
    }

    closehandler(event){
        console.log(event);
        this.inviteUser = event.detail.changeModal;
        
        this.isLoading = false;
        if(event.detail.sendInvStatus){
            this.isCompVisible = false;
            const selectEvent = new CustomEvent('unsavedcustomevent', {
                detail: {
                    hideConDetl: true,
                    //change: true,
                    //oldcontactId: this.scontactId,
                    //navToList: false//subhadeep change
                }
    
            });
            this.dispatchEvent(selectEvent);
        }
    }

    get disDelButton(){
        return this.buttonDisable;
    }

    get opacityClass(){
        return this.contactDetails.activeStatus != 'Active' ? 'opClass' : '';
    }
}