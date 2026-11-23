import { LightningElement, wire, track, api } from 'lwc';
import contactListView from '@salesforce/apex/EPUM_SearchContact.contactListView';
import searchContactByEmail from '@salesforce/apex/EPUM_SearchContact.searchContactByEmail';
import createACR from '@salesforce/apex/EPUM_SearchContact.createACR';
import insertEpumLog from '@salesforce/apex/EPUM_SearchContact.insertEpumLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isLoggedInUserPAOrPAD from '@salesforce/apex/EPUM_SearchContact.isLoggedInUserPAOrPAD';
import Id from '@salesforce/user/Id';

import PAGE_SIZE from '@salesforce/label/c.EPUM_PageSize';
import EPUM_AreYouSure from '@salesforce/label/c.EPUM_AreYouSure';
import EPUEPUM_DoYouWantToSave from '@salesforce/label/c.EPUM_DoYouWantToSave';
import EPUM_ContactRolesResTitle from '@salesforce/label/c.EPUM_ContactRolesResTitle';
import EPUM_PartnerRoleTitle from '@salesforce/label/c.EPUM_PartnerRoleTitle';
import EPUM_SearchContact from '@salesforce/label/c.EPUM_SearchContact';
import EPUM_SearchByEmail from '@salesforce/label/c.EPUM_SearchByEmail';
import EPUM_ClearSearch from '@salesforce/label/c.EPUM_ClearSearch';
import EPUM_InviteAUser from '@salesforce/label/c.EPUM_InviteAUser';
import EPUM_name from '@salesforce/label/c.EPUM_name';
import EPUM_EmailId from '@salesforce/label/c.EPUM_EmailId';
import EPUM_ResponsibilitiesAssigned from '@salesforce/label/c.EPUM_ResponsibilitiesAssigned';
import EPUM_TotalUser from '@salesforce/label/c.EPUM_TotalUser';
import EPUM_Page from '@salesforce/label/c.EPUM_Page';
import EPUM_of from '@salesforce/label/c.EPUM_of';
import EPUM_Save from '@salesforce/label/c.EPUM_Save';
import EPUM_Discard from '@salesforce/label/c.EPUM_Discard';
import EPUM_isPendingContactMsg from '@salesforce/label/c.EPUM_isPendingContactMsg';
import EPUM_isContactExistsinOnePartnerAccMsg from '@salesforce/label/c.EPUM_isContactExistsinOnePartnerAccMsg';
import EPUM_isContactExitssWithSameRoleMsg from '@salesforce/label/c.EPUM_isContactExitssWithSameRoleMsg';
import EPUM_InviteAsContactNotExistMsg from '@salesforce/label/c.EPUM_InviteAsContactNotExistMsg';
import EPUM_Tier from '@salesforce/label/c.EPUM_Tier';
import EPUM_ManagePersonnel_SubTittle from '@salesforce/label/c.EPUM_ManagePersonnel_SubTittle';
import EPUM_ManagePersonnel from '@salesforce/label/c.EPUM_ManagePersonnel';
import EPUM_Select from '@salesforce/label/c.EPUM_Select';
import EPUM_Next from '@salesforce/label/c.EPUM_Next';
import EPUM_Previous from '@salesforce/label/c.EPUM_Previous';
import EPUM_EmailValidationMsg from '@salesforce/label/c.EPUM_EmailValidationMsg';
import EPUM_ContactRolesResSubTitle from '@salesforce/label/c.EPUM_ContactRolesResSubTitle';
import EPUM_ContactSuccess from '@salesforce/label/c.EPUM_ContactSuccess';
//import EPUM_isSendInviteMsg from '@salesforce/label/c.EPUM_isSendInviteMsg';
import styleResource from '@salesforce/resourceUrl/IpaResources';


export default class EPUM_SearchContactLWC extends LightningElement {
 

    label = {
        PAGE_SIZE,
        EPUM_AreYouSure,
        EPUEPUM_DoYouWantToSave,
        EPUM_ContactRolesResTitle,
        EPUM_PartnerRoleTitle,
        EPUM_SearchContact,
        EPUM_SearchByEmail,
        EPUM_ClearSearch,
        EPUM_InviteAUser,
        EPUM_name,
        EPUM_EmailId,
        EPUM_ResponsibilitiesAssigned,
        EPUM_TotalUser,
        EPUM_Page,
        EPUM_of,
        EPUM_Save,
        EPUM_Discard,
        EPUM_isPendingContactMsg,
        EPUM_isContactExistsinOnePartnerAccMsg,
        EPUM_isContactExitssWithSameRoleMsg,
        EPUM_InviteAsContactNotExistMsg,
        EPUM_Tier,
        EPUM_ManagePersonnel_SubTittle,
        EPUM_ManagePersonnel,
        EPUM_Select,
        EPUM_Next,
        EPUM_Previous,
        EPUM_EmailValidationMsg,
        EPUM_ContactRolesResSubTitle,
        EPUM_ContactSuccess
    };


    partnerRole;
    partnerTier;
    message
    createNew = true;
    sendInvite = true;
    contactDetails;
    contacts;
    @api searchKeyword = '';
    areDetailsVisible = false;
    isLoading = false;
    @track parentunsavedChangesModal = false;
    @track parentunsavedChanges = false;
    @track oldconid = '';
    @track selectConName = '';
    validationmsg = '';
    isSearch = false;

    selectedContactId = '';

    //pagination related
    startPage;
    endPage;
    pageSize = parseInt(this.label.PAGE_SIZE);
    totalNoOfContacts;
    paginationlistRows;
    startPageNo = 1;
    totalPageNo = 1;

    inviteUser;

    @wire(contactListView)
    contactListView({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.partnerRole = data.contactPartnerRole;
            this.partnerTier = data.accountPartnerTier;
            this.contacts = data.lstContactToReturn;
            this.pagination(data.lstContactToReturn);
            this.isLoading = false;
        } else {
            console.log("Error" + JSON.stringify(error));
            this.isLoading = false;
        }
        
    }

    get getValidationMsg(){
        if(this.message === this.label.EPUM_InviteAsContactNotExistMsg){
            return true;
        }else{
            return false;
        }
    }

    pagination(data) {
        this.totalNoOfContacts = data.length;
        this.startPage = 0;
        this.endPage = this.pageSize - 1;
        this.paginationlistRows = [];

        this.startPageNo = 1;
        this.totalPageNo = Math.ceil(data.length / this.pageSize);

        if (this.totalNoOfContacts > 0) {
            for (var i = 0; i < this.pageSize; i++) {
                if (this.totalNoOfContacts > i) {
                    this.paginationlistRows.push(this.prepareConData(data[i]));
                }
            }
        }
    }

    prepareConData(data) {
        let conData = {};
        conData.Id = data.Id;
        conData.Name = data.Name;
        conData.Email = data.Email;
        
        var lstEntitlements = data.Contact_Entitlements__r;

        var roles = [];
        if (lstEntitlements && lstEntitlements.length > 0) {
            
            if (lstEntitlements.length == 1 && lstEntitlements[0].Core_Entitlement_Id__r.Name == 'Employee') {
                roles.push(lstEntitlements[0].Core_Entitlement_Id__r.Core_Display_Name__c);
            }
            for (var conEnt in lstEntitlements) {
                if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name != 'Employee') {
                    roles.push(lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c);
                }
                if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin') {
                    roles = [lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c];
                    break;
                }
                if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin Delegate') {
                    roles = [lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c];
                    break;
                }
            }
        }
        // var lstContactRel = data.Account_Contact_Relationships__r;

        // if (lstContactRel && lstContactRel.length > 0) {
        //     if (lstContactRel[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c == 'PRIMARY' || lstContactRel[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c == 'PRIMCONTDEL') {
        //         roles = [lstContactRel[0].PRM_Relationship_Id__r.Name];
        //     }
        // }
        if(roles.includes("Partner Admin Delegate")){
            conData.classVar = "primaryAdminDelegate";
        }else if(roles.includes("Partner Admin")){
            conData.classVar = "primaryAdmin";
        }else{
            conData.classVar = "others";
        }
        conData.Roles = roles;
        return conData;
    }

    previousButton() {
        this.isLoading = true;
        this.paginationlistRows = [];
        var counter = 0;

        for (var i = this.startPage - this.pageSize; i < this.startPage; i++) {
            if (i > -1) {
                this.paginationlistRows.push(this.prepareConData(this.contacts[i]));
                counter++;
            } else {
                this.startPage++;
            }
        }

        this.startPage = this.startPage - counter;
        this.endPage = this.endPage - counter;
        this.startPageNo = (this.startPage == 0) ? 1 : this.startPageNo - 1;

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
        this.isLoading = false;
    }

    nextButton() {
        this.isLoading = true;
        this.paginationlistRows = [];
        var counter = 0;
        for (var i = this.endPage + 1; i < this.endPage + this.pageSize + 1; i++) {
            if (this.contacts.length > i) {
                this.paginationlistRows.push(this.prepareConData(this.contacts[i]));
            }
            counter++;
        }
        this.startPage = this.startPage + counter;
        this.endPage = this.endPage + counter;
        this.startPageNo += 1;

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
        this.isLoading = false;
    }

    searchContact() {
        this.message = '';
        this.validationmsg = "";
        this.createNew = false;
        this.sendInvite = false;
        this.paginationlistRows = [];
        this.totalNoOfContacts = 0;
        this.startPage = 0;
        this.endPage = 0;
        this.startPageNo = 1;
        this.totalPageNo = 1;
        var inputCmp = this.template.querySelector(".searchInput");
        inputCmp.setCustomValidity("");
        inputCmp.reportValidity();
           
        if (true) {

            var value = (this.template.querySelector(".searchInput").value).trim();

            var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
            
            if(this.template.querySelector(".searchInput").value !== "" &&  emailPattern.test(value)){
                this.isLoading = true;

                searchContactByEmail({
                    searchKeyWord: value.trim(),
                    userId: Id
                }).then(result => {
                    console.log('result contact search'+JSON.stringify(result))
                    if (result.isContactExistsinDB) {
                        if (result.isContactExistsinOnePartnerAcc && result.isContactExitssWithSameRole && !result.isPendingContact) {
                            this.startPage = 0;
                            this.endPage = [result.contactDetails].length;
                            this.totalNoOfContacts = [result.contactDetails].length;
                            this.isSearch = true;
                            this.startPageNo = 1;
                            this.totalPageNo = 1;
                            console.log('result.contactDetails'+JSON.stringify(result.contactDetails))
                            let searchCons = [result.contactDetails];
                            for (let key in searchCons) {
                                this.paginationlistRows.push(this.prepareConData(searchCons[key]));
                            }
                        } else if (result.isPendingContact) {
                            if (result.isSendInvite) {
                                this.sendInvite = true;
                                this.contactDetails = result.contactDetails;
                                //this.message = this.label.EPUM_isSendInviteMsg;
                            } else {
                                this.message = this.label.EPUM_isPendingContactMsg;
                            }
                        } else if (!result.isContactExistsinOnePartnerAcc) {
                            this.message = this.label.EPUM_isContactExistsinOnePartnerAccMsg;
                        } else if (!result.isContactExitssWithSameRole) {
                            this.message = this.label.EPUM_isContactExitssWithSameRoleMsg;
                        }
                        this.areDetailsVisible = false;
                        this.isLoading = false;
                    } else {
                        this.createNew = true;
                        this.message = this.label.EPUM_InviteAsContactNotExistMsg;
                        this.areDetailsVisible = false;
                        this.isLoading = false;
                    }
                }).catch(error => {
                    console.log('LWC search error' + JSON.stringify(error));
                    this.isLoading = false;
                });
            }else{
                this.isLoading = false;
                this.validationmsg = this.label.EPUM_EmailValidationMsg;
            }
            
        } else {
            this.isLoading = false;
        }

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
    }

    clearSearch() {
        this.isLoading = true;
        this.searchKeyword = '';
        this.message = '';
        this.areDetailsVisible = false;
        this.pagination(this.contacts);
        this.isLoading = false;
        this.validationmsg = ""
        this.isSearch = false;

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
    }

    getRowId(event) {

        this.areDetailsVisible = true;
        this.selectedContactId = event.currentTarget.dataset.myid;
        this.selectConName = event.target.id.split('-')[0];

        if (this.parentunsavedChanges) {
            this.parentunsavedChangesModal = true;
        } else {
            if(!this.isSearch){
                insertEpumLog().then(result => {
                    console.log('insert log result' + result);
                }).catch(error => {
                    console.log('insert log error' + error);
                })
            }
            if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
                this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
                this.template.querySelector("c-epum-contact-entitlement-view").handleValueChange(this.selectedContactId);

            }
        }

    }

    onParentAccept() {
        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
            this.template.querySelector("c-epum-contact-entitlement-view").savefromParent(this.oldconid, this.selectedContactId);
        }
        this.parentunsavedChangesModal = false;
    }

    onParentReject() {
        this.parentunsavedChangesModal = false;
        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
            this.template.querySelector("c-epum-contact-entitlement-view").handleValueChange(this.selectedContactId);

        }
    }

    handleunsavedevent(event) {
        this.parentunsavedChanges = event.detail.change;
        this.oldconid = event.detail.oldcontactId;
    }

    showInviteUser() {
        this.inviteUser = true;
    }

    sendInviteToUser() {
        this.isLoading = true;
        createACR({
            contact: this.contactDetails
        }).then(result => {
            if (result.status === 'success' && result.message === 'Invite sent successfully') {
                const event = new ShowToastEvent({
                    title: this.label.EPUM_ContactSuccess,
                    variant: 'success',
                    mode: 'dismissable'
                });
                console.log('contact creation' + JSON.stringify(result));
                this.isLoading = false;
                this.dispatchEvent(event);
                this.clearSearch();
            } else {
                const event = new ShowToastEvent({
                    title: result.message,
                    variant: 'Error',
                    mode: 'dismissable'
                });
                console.log('contact creation' + JSON.stringify(result));

                this.dispatchEvent(event);
            }

        }).catch(error => {

        })
    }

    searchTextChange(event) {
        this.searchKeyword = event.target.value;
    }

    closehandler() {
        this.inviteUser = false;
    }

    get validPrevious() {
        return this.startPage == 0 ? true : false;
    }

    get validNext() {
        return this.endPage + 1 >= this.totalNoOfContacts ? true : false;
    }

}