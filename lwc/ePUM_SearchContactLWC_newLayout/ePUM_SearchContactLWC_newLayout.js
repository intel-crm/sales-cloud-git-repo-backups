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
import EPUM_ContactRolesResTitle1 from '@salesforce/label/c.EPUM_ContactRolesResTitle1';
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
import EPUM_SendInvite from '@salesforce/label/c.EPUM_SendInvite';
import EPUM_isContactDeleted from '@salesforce/label/c.EPUM_isContactDeleted';
import EPUM_ChatWithIntelLink from '@salesforce/label/c.EPUM_ChatWithIntelLink';
import EPUM_ChatWithIntel from '@salesforce/label/c.EPUM_ChatWithIntel';
import EPUM_RowsPerPage from '@salesforce/label/c.EPUM_RowsPerPage';
import styleResource from '@salesforce/resourceUrl/IpaResources';
import LastLoginDate from '@salesforce/schema/User.LastLoginDate';
//import CallCenter from '@salesforce/schema/User.CallCenter';
import upArrow_white from '@salesforce/resourceUrl/upArrow_white';
import Setting from '@salesforce/schema/TenantUsageEntitlement.Setting';
import onBoardingRedirect from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.onBoardingRedirect";

export default class EPUM_SearchContactLWC extends LightningElement {


    label = {
        PAGE_SIZE,
        EPUM_AreYouSure,
        EPUEPUM_DoYouWantToSave,
        EPUM_ContactRolesResTitle,
        EPUM_ContactRolesResTitle1,
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
        EPUM_isContactDeleted,
        EPUM_InviteAsContactNotExistMsg,
        EPUM_Tier,
        EPUM_ManagePersonnel_SubTittle,
        EPUM_ManagePersonnel,
        EPUM_Select,
        EPUM_Next,
        EPUM_Previous,
        EPUM_EmailValidationMsg,
        EPUM_ContactRolesResSubTitle,
        EPUM_ContactSuccess,
        EPUM_SendInvite,
        EPUM_ChatWithIntelLink,
        EPUM_ChatWithIntel,
        EPUM_RowsPerPage //Akshay Change**************************************
    };


    partnerRole;
    loggedUserPartnerRole;
    partnerTier;
    message
    isDisplayChatWithIntelLink = false;
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
    @track selectConId = '';
    validationmsg = '';
    isSearch = false;

    selectedContactIdWrap = {}; //Akshay Change**************************************
    selectedContactId = ''; //Akshay Change**************************************
    sameOPID = true; //Akshay Change**************************************
    loggedUserOPID = ''; //Akshay Change**************************************
    loggedUserId = ''; //Akshay Change**************************************
    listOfOPIDs; //Akshay Change**************************************
    contactsAllDetails = []; //Akshay Change**************************************
    filteredContactList = []; //Akshay Change**************************************
    searchString = {};

    //subhadeep draco change Manage Personal----Start
    showModalWindow = false;
    filterColumns = [];
    firstNameButton = true;
    firstNameField = false;
    lastNameButton = true;
    lastNameField = false;
    emailButton = true;
    emailField = false;
    statusButton = true;
    statusField = false;
    locationButton = true;
    locationField = false;
    res1Button = true;
    res1Field = false;
    res2Button = true;
    res2Field = false;

    fNameSearchText = '';
    lNameSearchText = '';
    emailSearchText = '';
    statusSearchText = '';
    locationSearchText = '';
    res1SearchText = '';
    res2SearchText = '';

    showFNamePill = false;
    showLNamePill = false;
    showEmailPill = false;
    showStatusPill = false;
    showLocationPill = false;
    showRes1Pill = false;
    showRes2Pill = false;

    fNamePillText = '';
    lNamePillText = '';
    emailPillText = '';
    statusPillText = '';
    locationPillText = '';
    rep1PillText = '';
    rep2PillText = '';

    dataList;
    statusList = ["Active", "Invited", "Suspended"];
    //fnametext = '';
    //subhadeep draco change Manage Personal----End

    //pagination related
    startPage;
    endPage;
    pageSize = parseInt(this.label.PAGE_SIZE);
    totalNoOfContacts;
    paginationlistRows;
    startPageNo = 1;
    totalPageNo = 1;
    rowsPerPage = 5; //Akshay Change**************************************
    pageListArray = []; //Akshay Change**************************************
    @track jumpToPageArray = []; //Akshay Change**************************************
    jumpToPage = 1; //Akshay Change**************************************
    defaultSortDirection = 'asc';


    dTData = [];
    inviteUser;
    locationSet = new Set();
    roleSet = new Set();
    actL = [];

    /** The constructor() method fires when a component instance is created */
    constructor() {
        super();
        /**if seubscription is missing or t&c is not checked then will direct to onboarding page */
		onBoardingRedirect()
		.then(data => { 
			if(data) {
				var result = JSON.parse(data);
				if(!result.stepOneCompleted && result.redirectUrl != '') {
					window.location.href = result.redirectUrl;
				}
			}         
        })
        .catch(error => {
            console.log('error message',error);
        });
    }

    @wire(contactListView)
    contactListView({ error, data }) {
        this.isLoading = true;
        if (data) {
            let statusSet = new Set();
            let conDataRow = {};
            this.partnerRole = data.contactPartnerRole;
            this.loggedUserPartnerRole = data.loggedUserPartnerRole;
            this.partnerTier = data.accountPartnerTier;
            this.contacts = data.lstContactToReturn;
            this.loggedUserOPID = data.loggedUserOPID;
            this.loggedUserId = data.loggedUserId;
            this.listOfOPIDs = data.listOfOPIDs;
            this.totalNoOfContacts = this.contacts.length;
            this.isLoading = false;

            if (this.totalNoOfContacts > 0) {
                for (var i = 0; i < this.totalNoOfContacts; i++) {
                    conDataRow = this.prepareConData(this.contacts[i]);
                    this.dTData.push(conDataRow);
                    statusSet.add(conDataRow.activeStatus);
                    this.locationSet.add(conDataRow.ContactOPID_Name);
                    //if (conDataRow.Roles != undefined)
                        //this.roleSet.add(conDataRow.Roles);
                }
                console.log(this.roleSet);
                //this.statusList = statusSet;
            }

            if (this.locationSet.size > 0) {
                this.locationSet.forEach((v) => {
                    let loc = {};
                    loc.label = v;
                    loc.value = v;
                    this.actL.push(loc);
                });
            }

            for (var con in this.contacts){
                let conData = {};
                conData.Id = this.contacts[con].Id;
                conData.Name = this.contacts[con].Name;
                conData.Email = this.contacts[con].Email;
                conData.Account_Id = this.contacts[con].Account.Id;
                conData.Account_Name = this.contacts[con].Account.Name;
                conData.ContactOPID_Id = this.contacts[con].Core_IPA_One_Partner_Id__c;
                if(conData.ContactOPID_Id == null) conData.ContactOPID_Id = conData.Account_Id;
                conData.ContactPartnerRole = this.contacts[con].Core_IPA_PartnerRole__c;
                // Get the last signed in date of the user
                var LastSignonDate = [];
                if (this.contacts[con].Users && this.contacts[con].Users[0].LastLoginDate && this.contacts[con].Users[0].LastLoginDate != null){
                    LastSignonDate = this.contacts[con].Users[0].LastLoginDate.split("T");
                    conData.LastUserLogin = LastSignonDate[0];
                } else{conData.LastUserLogin = "NA"}
                // Get the "Responsibility Assigned" for the GUI and store it in "Roles" variable
                var roles = [];
                var lstEntitlements = this.contacts[con].Contact_Entitlements__r;
                if (lstEntitlements && lstEntitlements.length > 0) {
                    if (lstEntitlements.length == 1 && lstEntitlements[0].Core_Entitlement_Id__r.Name == 'Employee') {
                        roles.push(lstEntitlements[0].Core_Entitlement_Id__r.Core_Display_Name__c);
                        this.roleSet.add(lstEntitlements[0].Core_Entitlement_Id__r.Core_Display_Name__c);
                    }
                    for (var conEnt in lstEntitlements) {
                        if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name != 'Employee') {
                            roles.push(lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c);
                            this.roleSet.add(lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c);
                        }
                        if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin') {
                            roles = [lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c];
                            this.roleSet.add(lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c);
                            break;
                        }
                        if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin Delegate') {
                            roles = [lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c];
                            this.roleSet.add(lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c);
                            break;
                        }
                    }
                }
                
                if(roles.includes("Partner Admin Delegate")){
                    conData.classVar = "primaryAdminDelegate";
                }else if(roles.includes("Partner Admin")){
                    conData.classVar = "primaryAdmin";
                }else{
                    conData.classVar = "others";
                }
                conData.Roles = roles;
                //this.roleSet.add(conData.Roles);
                //Get the OPID name for the contact and benifit details for contact partner role.
                conData.ContactPRBenifit = "Basic"; 
                for(var OPID in this.listOfOPIDs){
                    if(conData.ContactOPID_Id == this.listOfOPIDs[OPID].Id){
                        conData.ContactOPID_Name = this.listOfOPIDs[OPID].Name;
                        for(var membership in this.listOfOPIDs[OPID].Channel_Memberships1__r){
                            if(this.listOfOPIDs[OPID].Channel_Memberships1__r[membership].PRM_Partner_Role__c == conData.ContactPartnerRole){
                                if(this.listOfOPIDs[OPID].Channel_Memberships1__r[membership].PRM_Tier_Name_txt__c != "Member"){
                                    conData.ContactPRBenifit = "Advanced"
                                }
                            } 
                        }
                    }
                }
                //Get the status of the contact if Active, Suspended or Invited
                var lstActiveStatus = this.contacts[con].Account_Contact_Relationships__r;
                var isActive = 'Invited';
                var loopThrough = true;
                if (lstActiveStatus && lstActiveStatus.length > 0) {
                    for (var conStat in lstActiveStatus) {
                        if (loopThrough == true && lstActiveStatus[conStat].PRM_InActive_Ind__c == false && lstActiveStatus[conStat].PRM_Status_Nm__c == "Complete"){
                            isActive = 'Active';
                            loopThrough = false;
                        }
                        if (loopThrough == true && lstActiveStatus[conStat].PRM_InActive_Ind__c == true && lstActiveStatus[conStat].PRM_Status_Nm__c == "Complete"){
                            isActive = 'Suspended';
                        }
                    }
                }
                conData.activeStatus = isActive;
                this.contactsAllDetails[con] = conData;
            }
            console.log(this.roleSet);
            console.log("Below is list before OPID based sorting: ");
            console.log(this.contactsAllDetails);
            var result1 = [];
            var result2 = [];
            for (var con in this.contactsAllDetails) {
                if (this.contactsAllDetails[con].ContactOPID_Id === this.loggedUserOPID) {
                    result1.push(this.contactsAllDetails[con]);
                } else {
                    result2.push(this.contactsAllDetails[con]);
                }
            }
            this.contactsAllDetails = result1.concat(result2);
            console.log("Below is list after OPID based sorting: ");
            console.log(this.contactsAllDetails);

            this.dTData = this.contactsAllDetails;
            this.applyFilterMethod();
            this.pagination(this.filteredContactList);
        } 
        else {
            console.log("Error" + JSON.stringify(error));
            this.isLoading = false;
        }

    }

    // Akshay change - START**************************************
    handleOnselect_recPerPg(event) {
        this.rowsPerPage = parseInt(event.detail.value);
        this.startPage = 0;
        this.endPage = this.rowsPerPage - 1;
        if (this.filteredData.length > 0) {
            this.pagination(this.filteredData);
        }
        else
            this.pagination(this.contacts);
    }
    // Akshay change - END**************************************

    // Akshay Filter change - START**************************************
    applyFilterMethod(filterData){
        if (filterData == null) {
            this.filteredContactList = this.contactsAllDetails;
        } else {
            this.filteredContactList = this.contactsAllDetails.filter(item => item.Name.toLowerCase().indexOf(filterData.Name.toLowerCase()) > -1);
                                                        //.filter(item => item.Email.toLowerCase().indexOf(filterData.Name.toLowerCase()) > -1);
        }
        console.log("Below are the filtered contacts: ");
        console.log(this.filteredContactList);
    }
    // Akshay Filter change - END**************************************

    get getValidationMsg() {
        if (this.message === this.label.EPUM_InviteAsContactNotExistMsg || this.message === this.label.EPUM_isContactExitssWithSameRoleMsg) {
            return true;
        } else {
            return false;
        }
    }

    pagination(data) {
        this.totalNoOfContacts = this.filteredContactList.length;
        this.startPage = 0;
        this.endPage = this.rowsPerPage - 1; //Akshay Change - Changed variable pageSize to rowsPerPage*******************
        this.paginationlistRows = [];
        this.startPageNo = 1;
        this.totalPageNo = Math.ceil(this.filteredContactList.length / this.rowsPerPage); //Akshay Change - Changed variable pageSize to rowsPerPage*******************

        if (this.totalNoOfContacts > 0) {
            for (var i = 0; i < this.rowsPerPage; i++) { //Akshay Change - Changed variable pageSize to rowsPerPage*******************
                if (this.totalNoOfContacts > i) {
                    this.paginationlistRows.push(this.filteredContactList[i]);
                    console.log("Below is data from filteredContactList: ");
                    console.log(this.filteredContactList[i]);
                }
            }
        }
        this.jumpToPageArray = [];
        for (i=1; i < this.totalPageNo + 1; i++){
            this.jumpToPageArray.push(i);
        }

        var conDataArray = [];
        if (this.totalNoOfContacts > 0) {
            for (var i = 0; i < this.totalNoOfContacts; i++) { 
                conDataArray.push(this.filteredContactList[i]);
            }
        }

        this.dTData = this.contactsAllDetails;
        console.debug(this.filteredContactList);
    }

    prepareConData(data) {
        let conData = {};
        conData.Id = data.Id;
        conData.Name = data.Name;
        conData.Email = data.Email;
        conData.AccName = data.Account.Name;
        conData.ContactOPID_Id = data.Core_IPA_One_Partner_Id__c;

        var lstEntitlements = data.Contact_Entitlements__r;
        var lstActiveStatus = data.Account_Contact_Relationships__r;
        var LastSignonDate = [];

        if (data.Users && data.Users[0].LastLoginDate && data.Users[0].LastLoginDate != null) {
            LastSignonDate = data.Users[0].LastLoginDate.split("T");
            conData.LastUserLogin = LastSignonDate[0];
        } else { conData.LastUserLogin = "NA" }

        // Get the "Responsibility Assigned" for the GUI and store it in "Roles" variable
        var lstEntitlements = data.Contact_Entitlements__r;
        if (lstEntitlements && lstEntitlements.length > 0) {
            for (var conEnt in lstEntitlements) {
                if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Employee') {
                    conData.Roles = lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c;
                    conData.classVar = "others";
                }
                if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin') {
                    conData.Roles = lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c;
                    conData.classVar = "primaryAdmin";
                    break;
                }
                if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin Delegate') {
                    conData.Roles = lstEntitlements[conEnt].Core_Entitlement_Id__r.Core_Display_Name__c;
                    conData.classVar = "primaryAdminDelegate";
                    break;
                }
            }
        }

        for (var OPID in this.listOfOPIDs) {
            if (conData.ContactOPID_Id == this.listOfOPIDs[OPID].Id) {
                conData.ContactOPID_Name = this.listOfOPIDs[OPID].Name;
            }
        }

        var isActive = 'Invited';
        var loopThrough = true;
        if (lstActiveStatus && lstActiveStatus.length > 0) {
            for (var conStat in lstActiveStatus) {
                if (loopThrough == true && lstActiveStatus[conStat].PRM_InActive_Ind__c == false && lstActiveStatus[conStat].PRM_Status_Nm__c == "Complete") {
                    isActive = 'Active';
                    loopThrough = false;
                }
                if (loopThrough == true && lstActiveStatus[conStat].PRM_InActive_Ind__c == true && lstActiveStatus[conStat].PRM_Status_Nm__c == "Complete") {
                    isActive = 'Suspended';
                }
            }
        }
        conData.activeStatus = isActive;

        return conData;
    }

    previousButton() {
        this.isLoading = true;
        this.paginationlistRows = [];
        var counter = 0;
        for (i = this.startPage - this.rowsPerPage; i < this.startPage; i++) { //Akshay Change - Changed variable pageSize to rowsPerPage*******************
            if (i > -1) {
                this.paginationlistRows.push(this.filteredContactList[i]);
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
        for (i = this.endPage + 1; i < this.endPage + this.rowsPerPage + 1; i++) { //Akshay Change - Changed variable pageSize to rowsPerPage*******************
            if (this.filteredContactList.length > i) {
                this.paginationlistRows.push(this.filteredContactList[i]);
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

    firstButton() {
        this.jumpToPageMethod(1);
    }

    jumpToPageMethod(data){
        this.isLoading = true;
        this.paginationlistRows = [];
        var counter = 0;
        var jumpPageRow = (this.rowsPerPage * (data - 1));
        for (i = jumpPageRow; i < jumpPageRow + this.rowsPerPage; i++) {
            if (this.filteredContactList.length > i) {
                this.paginationlistRows.push(this.filteredContactList[i]);
            }
            counter++;
        }
        this.startPage = jumpPageRow;
        this.endPage = jumpPageRow + counter - 1;
        this.startPageNo = data;
        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
        this.isLoading = false;
    }

    DTcolumns = [
        {label: 'Name', fieldName: 'Name', sortable: true},
        {label: 'Email', fieldName: 'Email', type: 'email'},
        {label: 'Role', fieldName: 'roleType', sortable: true},
        {label: 'Last Signin', fieldName: 'LastUserLogin', sortable: true},
        {label: 'Status', fieldName: 'activeStatus', sortable: true},
        {label: 'Location / Account', fieldName: 'AccName', sortable: true},
    ];

    searchContact() {
        this.message = '';
        this.validationmsg = "";
        this.createNew = false;
        this.sendInvite = false;
        this.isDisplayChatWithIntelLink = false;
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

            if (this.template.querySelector(".searchInput").value !== "" && emailPattern.test(value)) {
                this.isLoading = true;

                searchContactByEmail({
                    searchKeyWord: value.trim(),
                    userId: Id
                }).then(result => {
                    console.log('result contact search' + JSON.stringify(result))
                    if (result.isContactExistsinDB) {

                        if (result.isContactExistsinOnePartnerAcc && result.isContactExitssWithSameRole && !result.isPendingContact && !result.isContactDeleted && !result.isSendInvite) {
                            this.startPage = 0;
                            this.endPage = [result.contactDetails].length;
                            this.totalNoOfContacts = [result.contactDetails].length;
                            this.isSearch = true;
                            this.startPageNo = 1;
                            this.totalPageNo = 1;
                            console.log('result.contactDetails' + JSON.stringify(result.contactDetails))
                            let searchCons = [result.contactDetails];
                            for (let key in searchCons) {
                                this.paginationlistRows.push(this.prepareConData(searchCons[key]));
                            }
                        } else if (result.isSendInvite) {
                            this.sendInvite = true;
                            this.contactDetails = result;
                            //this.message = this.label.EPUM_isSendInviteMsg
                        } else if (result.isPendingContact) {
                            this.message = this.label.EPUM_isPendingContactMsg;
                        }
                        // For LoginDeleted - start
                        else if (result.isContactDeleted) {
                            this.message = this.label.EPUM_isContactDeleted;
                        }
                        // For LoginDeleted - End  

                        else if (!result.isContactExistsinOnePartnerAcc) {
                            this.message = this.label.EPUM_isContactExistsinOnePartnerAccMsg;
                        } else if (!result.isContactExitssWithSameRole) {
                            this.message = this.label.EPUM_isContactExitssWithSameRoleMsg;
                            this.isDisplayChatWithIntelLink = true;
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
            } else {
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
        this.pagination(this.filteredContactList);
        this.isLoading = false;
        this.validationmsg = ""
        this.isSearch = false;

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
    }

    getRowId(event) {

        this.areDetailsVisible = true;
        this.selectedContactIdWrap.selectedContactId = event.currentTarget.dataset.myid;
        this.selectConId = event.target.id.split('-')[0];
        this.selectedContactIdWrap.loggedUserOPID = this.loggedUserOPID;
        this.selectedContactIdWrap.loggedUserPartnerRole = this.loggedUserPartnerRole;
        this.selectedContactIdWrap.loggedUserId = this.loggedUserId;   

        for(var con in this.filteredContactList){
            if(this.filteredContactList[con].Id === this.selectConId){
                this.selectedContactIdWrap.selectedConDetails = this.filteredContactList[con];
                console.debug(this.selectedContactIdWrap.selectedConDetails);
            }
        }

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
                this.template.querySelector("c-epum-contact-entitlement-view").handleValueChange(this.selectedContactIdWrap);

            }
        }

    }

    onParentAccept() {
        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
            this.template.querySelector("c-epum-contact-entitlement-view").savefromParent(this.oldconid, this.selectedContactIdWrap.selectedContactId);
        }
        this.parentunsavedChangesModal = false;
    }

    onParentReject() {
        this.parentunsavedChangesModal = false;
        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
            this.template.querySelector("c-epum-contact-entitlement-view").handleValueChange(this.selectedContactIdWrap);

        }
    }


    showConDeatils;
    handleunsavedevent(event) {
        if(event.detail.navToList){
            console.log(this.template.querySelectorAll('div.slds-m-horizontal_x-small.slds-m-top_small'));
            this.template.querySelector('div.slds-m-horizontal_x-small.slds-m-top_small').scrollIntoView();
            return;
        }
        this.parentunsavedChanges = event.detail.change;
        this.oldconid = event.detail.oldcontactId;
        console.log(this.parentunsavedChanges);
        console.log("in handle save event");
        console.log(event.detail.isCancel);
        
       /* if(event.detail.isCancel){
            this.showConDeatils = event.detail.isCancel;
            let conTable = this.template.querySelector(".overflowDataClass");
            console.log(conTable);
            conTable.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
            this.parentunsavedChanges = true;
            this.showConDeatils = false;
        }*/
        if(!this.parentunsavedChanges){
            this.showConDeatils = this.parentunsavedChanges;
            let conEntl = this.template.querySelector("c-epum-contact-entitlement-view");
            console.log("Scroll down to: " + conEntl);
            console.log(this.template);
            conEntl.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
        }
    }

    showInviteUser() {
        this.inviteUser = true;
    }

    sendInviteToUser() {
        this.isLoading = true;
        createACR({
            contact: this.contactDetails.contactDetails,
            acr: this.contactDetails.contactDetails.Account_Contact_Relationships__r ? this.contactDetails.contactDetails.Account_Contact_Relationships__r[0] : null
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
                this.isLoading = false;
                const event = new ShowToastEvent({
                    title: result.message,
                    variant: 'Error',
                    mode: 'dismissable'
                });
                console.log('contact creation' + JSON.stringify(result));

                this.dispatchEvent(event);
            }

        }).catch(error => {
            this.isLoading = false;
        })
    }

    searchTextChange(event) {
        this.searchKeyword = event.target.value;
    }

    // Akshay change - START**************************************
    handleSearchName(event){
        this.searchString.Name = event.target.value;
        //this.applyFilterMethod(this.searchString);
        //this.pagination(this.filteredContactList);
        this.fNameSearchText = this.searchString.Name;
    }

    handleJumpToPage(event) {
        this.jumpToPageMethod(parseInt(event.detail.value));
    }

    handleNameSort(){
        var sortData = {};
        sortData.field = 'Name';
        sortData.sortDirection = this.defaultSortDirection;
        this.onHandleSort(sortData);
        this.pagination(this.filteredContactList);
    }
    handleEmailSort(){
        var sortData = {};
        sortData.field = 'Email';
        sortData.sortDirection = this.defaultSortDirection;
        this.onHandleSort(sortData);
        this.pagination(this.filteredContactList);
    }
    handleRolesSort(){
        var sortData = {};
        sortData.field = 'Roles';
        sortData.sortDirection = this.defaultSortDirection;
        this.onHandleSort(sortData);
        this.pagination(this.filteredContactList);
    }
    handleSigninSort(){
        var sortData = {};
        sortData.field = 'LastUserLogin';
        sortData.sortDirection = this.defaultSortDirection;
        this.onHandleSort(sortData);
        this.pagination(this.filteredContactList);
    }
    handleStatusSort(){
        var sortData = {};
        sortData.field = 'activeStatus';
        sortData.sortDirection = this.defaultSortDirection;
        this.onHandleSort(sortData);
        this.pagination(this.filteredContactList);
    }
    handleOPIDSort(){
        var sortData = {};
        sortData.field = 'ContactOPID_Name';
        sortData.sortDirection = this.defaultSortDirection;
        this.onHandleSort(sortData);
        this.pagination(this.filteredContactList);
    }

    // Column data sort Handle
    onHandleSort(data) {
        var sortedBy = data.field;
        var sortDirection = data.sortDirection;
        const cloneData = [...this.filteredContactList];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.filteredContactList = cloneData;
        if(sortDirection === 'asc'){
            this.defaultSortDirection = 'desc';
        } else {
            this.defaultSortDirection = 'asc';
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                    return primer(x[field]);
                }
            : function (x) {
                    return x[field];
                };

        return function (a, b) {
            a = key(a).toLowerCase();
            b = key(b).toLowerCase();
            return reverse * ((a > b) - (b > a));
        };
    }

    // Akshay change - END**************************************

    closehandler() {
        this.inviteUser = false;
    }

    get validPrevious() {
        return this.startPage == 0 ? true : false;
    }

    get validNext() {
        return this.endPage + 1 >= this.totalNoOfContacts ? true : false;
    }

    get validFirst() {
        return this.startPage == 0 ? true : false;
    }

    //subhadeep draco change Manage Personal----Start

    popUpFilter() {
        this.showModalWindow = true;
        //this.filterColumns = ['First name','Last Name','Email','Status','Location','Res 1','Res 2'];

    }



    closeModal(event) {
        if (event.target.id.split('-')[0] == 'clModal' || event.target.id.split('-')[0] == 'cancelModal') {

            if (this.showFNamePill != true)
                this.fNameSearchText = '';
            if (this.showLNamePill != true)
                this.lNameSearchText = '';
            if (this.showEmailPill != true)
                this.emailSearchText = '';
            if (this.showStatusPill != true)
                this.statusSearchText = '';
            if (this.showLocationPill != true)
                this.locationSearchText = '';
            if (this.showRes1Pill != true)
                this.res1SearchText = '';
            if (this.showRes2Pill != true)
                this.res2SearchText = '';
        }

        this.firstNameButton = true;
        this.firstNameField = false;
        this.lastNameButton = true;
        this.lastNameField = false;
        //this.fNameSearchText = '';
        this.emailButton = true;
        this.emailField = false;
        this.statusButton = true;
        this.statusField = false;
        this.locationButton = true;
        this.locationField = false;
        this.res1Button = true;
        this.res1Field = false;
        this.res2Button = true;
        this.res2Field = false;
        this.showModalWindow = false;

    }

    enterFilterText(event) {
        //alert(event.target.id.split('-')[0]);
        if (event.target.id.split('-')[0] == 'firstName') {
            this.firstNameButton = false;
            this.firstNameField = true;
        }
        if (event.target.id.split('-')[0] == 'lastName') {
            this.lastNameButton = false;
            this.lastNameField = true;

        }
        if (event.target.id.split('-')[0] == 'emailId') {
            this.emailButton = false;
            this.emailField = true;
        }
        if (event.target.id.split('-')[0] == 'status') {
            this.statusButton = false;
            this.statusField = true;
        }
        if (event.target.id.split('-')[0] == 'location') {
            this.locationButton = false;
            this.locationField = true;
        }
        if (event.target.id.split('-')[0] == 'res1') {
            this.res1Button = false;
            this.res1Field = true;
        }
        if (event.target.id.split('-')[0] == 'res2') {
            this.res2Button = false;
            this.res2Field = true;
        }

    }


    allStatus = [];
    statusSet = new Set();
    acctLocSet = new Set();
    acctRoleSet = new Set();
    searchFilterText(event) {
        //this.fNameSearchText = event.target.value;
        if (event.target.id.split('-')[0] == 'firstNameText') {
            this.fNameSearchText = event.target.value;
            //this.searchString = 
            //var fnText = this.fNameSearchText;
            //alert(this.fNameSearchText);
            // showFNamePill = true;
        }
        if (event.target.id.split('-')[0] == 'lastNameText') {
            this.lNameSearchText = event.target.value;
            //alert(this.lNameSearchText);
        }
        if (event.target.id.split('-')[0] == 'emailText') {
            this.emailSearchText = event.target.value;
            //alert(this.emailSearchText);
        }
        if (event.target.id.split('-')[0] == 'statusText') {
            console.log(event.target.value);
            this.statusSearchText = event.target.value;

        }
        if (event.target.id.split('-')[0] == 'locationText') {
            this.locationSearchText = event.target.value;
        }
        if (event.target.id.split('-')[0] == 'res1Text') {
            this.res1SearchText = event.target.value;
        }
        if (event.target.id.split('-')[0] == 'res2Text') {
            this.res2SearchText = event.target.value;
        }
        if (this.statusList.includes(event.target.id.split('-')[0])) {
            //let statusSet = new Set();
            let dId = event.target.id;
            let stCheckBox = this.template.querySelectorAll('[data-id="' + dId + '"]');
            stCheckBox.checked = true;


            this.statusSet.add(event.target.id.split('-')[0]);
            console.log(this.statusSet);
            //this.allStatus = statusSet;
            console.log(this.allStatus);
            console.log('status event---> ' + event.target.id.split('-')[0]);
            // this.allStatus.push(event.target.id.split('-')[0]);
            console.log(this.allStatus);
        }
        if (this.locationSet.has(event.target.value)) {
            //console.log('location event---> ' + event.target.id.split('-')[0]);
            console.log('location event---> ' + event.target.value);
            this.acctLocSet.add(event.target.value);
            //this.acctLocSet.add(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            console.log(this.acctLocSet);
        }

        if (this.roleSet.has(event.target.id.replaceAll(event.target.id.slice(-2), ''))) {
            console.log('roles event---> ' + event.target.id.split('-')[0]);
            this.acctRoleSet.add(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            console.log(this.acctRoleSet);
        }
        //alert(event.target.id);
        //alert(event.target.value);
        console.log(event.target);

    }

    searchString = '';
    searchConList = [];
    allLocation = [];
    allRoles = [];
    //statusLabel = [];
    showFilterdData(event) {
        this.allStatus = Array.from(this.statusSet);
        this.allLocation = Array.from(this.acctLocSet);
        this.allRoles = Array.from(this.acctRoleSet);
        if (this.fNameSearchText == '' && this.lNameSearchText == '' && this.emailSearchText == '' && this.allStatus.length == 0) {
            this.closeModal(event);
        }


        if (this.fNameSearchText != '') {
            this.fNameSearchText;

        }


        console.log("First name search text" + this.fNameSearchText);
        console.log("Last Name search text" + this.lNameSearchText);
        console.log("email search text" + this.emailSearchText);
        console.log(this.allRoles);
        var contactList = [];
        console.log(this.filteredContactList);
        this.searchString = this.fNameSearchText + ',' + this.lNameSearchText + ',' + this.emailSearchText + ',';
        this.searchConList = this.searchString.split(',');
        console.log(this.searchString);
        let statusSize = this.allStatus.length;
        var conFilterEmail = new Set();
        let sFlag = true;
        let rFlag = true;

        //var output = this.dTData.filter(con => con.Name.split(' ')[0]);
        for (var con in this.dTData) {
            let iFlag = false;
console.log(this.dTData[con]);
            let conString = this.dTData[con].Name.split(' ')[0] + ',' + this.dTData[con].Name.split(' ')[1] + ',' + this.dTData[con].Email + ',' + this.dTData[con].AccName + ',' + this.dTData[con].activeStatus;

           /* if (this.dTData[con].Name.split(' ')[0].startsWith(this.fNameSearchText) && this.dTData[con].Email.startsWith(this.emailSearchText)
                && this.dTData[con].Name.split(' ')[1].startsWith(this.lNameSearchText)) {*/
                    if (this.dTData[con].Name.startsWith(this.fNameSearchText) && this.dTData[con].Email.startsWith(this.emailSearchText)) {      
                iFlag = true;
                if (this.allStatus.length > 0)
                    for (let st in this.allStatus) {
                        if (this.dTData[con].activeStatus.startsWith(this.allStatus[st])) {
                            iFlag = true;
                            break;
                        }
                        else
                            iFlag = false;

                    }

                if (this.allLocation.length > 0) {
                    sFlag = false;
                    console.log('in loc data');
                    for (let aL in this.allLocation) {
                        console.log(this.dTData[con].ContactOPID_Name.startsWith(this.allLocation[aL]));
                        if (this.dTData[con].ContactOPID_Name.startsWith(this.allLocation[aL])) {
                            sFlag = true;
                            break;
                        }
                        else
                            sFlag = false;
                    }
                }

                if (this.allRoles.length > 0) {
                    rFlag = false;
                    console.log('in roles data');
                    for (let aR in this.allRoles) {
                        console.log(this.allRoles[aR]);
                        //let count = 0;
                        //console.log(this.dTData[con].Roles.startsWith(this.allRoles[aR]));
                        if (this.dTData[con].Roles.includes(this.allRoles[aR])) {
                            //console.log('True');
                            rFlag = true;
                            break;
                        }
                        else
                            rFlag = false;

                       /* if(this.dTData[con].Roles.length < count)
                        count++;*/
                    }
                }

            }

            if (iFlag && sFlag && rFlag)
                conFilterEmail.add(this.dTData[con].Email);
        }
        let emailArray = Array.from(conFilterEmail);
        console.log('email list');
        console.log(conFilterEmail);
        for (var ct in this.contactsAllDetails) {
            if (emailArray.includes(this.contactsAllDetails[ct].Email))
                contactList.push(this.contactsAllDetails[ct]);
        }

        console.log('filterd filteredContactList list');
        console.log(contactList);
        this.filteredContactList = contactList;
        console.log("pill log " + this.fNameSearchText + this.lNameSearchText + this.emailSearchText);
        if (this.fNameSearchText != '') {
            this.showFNamePill = true;
            //this.fNamePillText = 'First Name starts with ' + this.fNameSearchText;
            this.fNamePillText = 'Name starts with ' + this.fNameSearchText;
            console.log("first pill " + this.showFNamePill);
        }

        if (this.lNameSearchText != '') {
            this.showLNamePill = true;
            this.lNamePillText = 'Last Name starts with ' + this.lNameSearchText;
            console.log("last pill " + this.showLNamePill);
        }

        if (this.emailSearchText != '') {
            this.showEmailPill = true;
            this.emailPillText = 'Email starts with ' + this.emailSearchText;
            console.log(this.showEmailPill);
        }

        if (this.statusSearchText != '') {
            this.showStatusPill = true;
            this.statusPillText = 'Status starts with ' + this.statusSearchText;
        }

        if (this.locationSearchText != '') {
            this.showLocationPill = true;
            this.locationPillText = 'Located in ' + this.locationSearchText;
        }

        if (this.res1SearchText != '') {
            this.showRes1Pill = true;
            this.rep1PillText = 'Reponsibility 1 ' + this.res1SearchText;
        }

        if (this.res2SearchText != '') {
            this.showRes2Pill = true;
            this.rep2PillText = 'Reponsibility 2 ' + this.res2SearchText;
        }

        if (this.allStatus.length > 0) {
            for (let st in this.allStatus) {
                if (this.allStatus[st] == "Active") {
                    this.showAcStatusPill = true;
                    this.statusPillTextAc = this.allStatus[st];
                }
                if (this.allStatus[st] == "Invited") {
                    this.showInStatusPill = true;
                    this.statusPillTextIn = this.allStatus[st];
                }
                if (this.allStatus[st] == "Suspended") {
                    this.showSuStatusPill = true;
                    this.statusPillTextSu = this.allStatus[st];
                }


            }
            //this.showStatusPill = true;
        }

        this.filteredData = contactList;
        this.closeModal(event);
        this.pagination(contactList);
    }
    showAcStatusPill;
    statusPillTextAc;
    showInStatusPill;
    statusPillTextIn;
    showSuStatusPill;
    statusPillTextSu;

    filteredData = [];

    handlePillRemove(event) {

        if (event.target.id.split('-')[0] == 'fNamePill') {
            this.fNameSearchText = '';
            this.showFNamePill = false;
            this.showFilterdData(event);
        }
        if (event.target.id.split('-')[0] == 'lNamePill') {
            this.lNameSearchText = '';
            this.showLNamePill = false;
            this.showFilterdData(event);
        }
        if (event.target.id.split('-')[0] == 'emailPill') {
            this.emailSearchText = '';
            this.showEmailPill = false;
            this.showFilterdData(event);
        }
        if (event.target.id.split('-')[0] == 'statusPill') {
            this.statusSearchText = '';
            this.showStatusPill = false;
            this.showFilterdData(event);
        }
        if (event.target.id.split('-')[0] == 'locationPill') {
            this.locationSearchText = '';
            this.showLocationPill = false;
            this.showFilterdData(event);
        }
        if (event.target.id.split('-')[0] == 'res1Pill') {
            this.res1SearchText = '';
            this.showRes1Pill = false;
            this.showFilterdData(event);
        }
        if (event.target.id.split('-')[0] == 'res2Pill') {
            this.res2SearchText = '';
            this.showRes2Pill = false;
            this.showFilterdData(event);
        }

        if (this.allStatus.includes(event.target.id.split('-')[0])) {
            let statusIndex = this.allStatus.indexOf(event.target.id.split('-')[0]);
            console.log('ststusIndex ' + statusIndex);
            console.log('Remove status ' + event.target.id.split('-')[0]);
            this.statusSet.delete(event.target.id.split('-')[0]);
            //console.log(this.allStatus.splice(statusIndex,1));
            console.log(this.allStatus);
            this.showFilterdData(event);
        }

        if (this.allLocation.includes(event.target.id.replaceAll(event.target.id.slice(-2), ''))) {
            this.acctLocSet.delete(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            this.showFilterdData(event);
        }

        if (this.allRoles.includes(event.target.id.replaceAll(event.target.id.slice(-2), ''))) {
            this.acctRoleSet.delete(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            this.showFilterdData(event);
        }
    }

    get acctLocationList() {
        return this.actL;
    }

    //subhadeep draco change Manage Personal----End
}