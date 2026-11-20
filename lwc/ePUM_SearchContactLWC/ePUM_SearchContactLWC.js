import { LightningElement, wire, track, api } from 'lwc';
import contactListView from '@salesforce/apex/EPUM_SearchContact.contactListView';
import searchContactByEmail from '@salesforce/apex/EPUM_SearchContact.searchContactByEmail';
import createACR from '@salesforce/apex/EPUM_SearchContact.createACR';
import insertEpumLog from '@salesforce/apex/EPUM_SearchContact.insertEpumLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isLoggedInUserPAOrPAD from '@salesforce/apex/EPUM_SearchContact.isLoggedInUserPAOrPAD';
import Id from '@salesforce/user/Id';
import {exportCSV} from 'c/exportToExcelUtils';
import PRM_BlockedContactError from  '@salesforce/label/c.PRM_BlockedContactError'
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
import EPUM_isExistingIPASelfRegistration from '@salesforce/label/c.EPUM_isExistingIPASelfRegistration';
import EPUM_manageTeamMember from '@salesforce/label/c.EPUM_manageTeamMember';
import EPUM_Close from '@salesforce/label/c.EPUM_Close';
import EPUM_SelectFilter from '@salesforce/label/c.EPUM_selectFilter';
import EPUM_Status from '@salesforce/label/c.EPUM_Status';
import EPUM_conStatus from '@salesforce/label/c.EPUM_conStatus';
import EPUM_namePH from '@salesforce/label/c.EPUM_namePH';
import EPUM_emailPH from '@salesforce/label/c.EPUM_emailPH';
import EPUM_Location from '@salesforce/label/c.EPUM_Location';
import EPUM_ContactLocation from '@salesforce/label/c.EPUM_ContactLocation';
import EPUM_locationPH from '@salesforce/label/c.EPUM_locationPH';
import EPUM_ResponsibilityName from '@salesforce/label/c.EPUM_ResponsibilityName';
import EPUM_Cancel from '@salesforce/label/c.EPUM_Cancel';
import EPUM_apply from '@salesforce/label/c.EPUM_apply';
import EPUM_LastSignIn from '@salesforce/label/c.EPUM_lastSignin';
import EPUM_locOrAcct from '@salesforce/label/c.EPUM_locOrAcct';
import EPUM_isSendInviteMsgNew from '@salesforce/label/c.EPUM_isSendInviteMsgNew';
import EPUM_ActiveIPAContact from '@salesforce/label/c.EPUM_ActiveIPAContact';
import PRM_Country from '@salesforce/label/c.PRM_Country';
import Core_Intc_Show_More from '@salesforce/label/c.IPA_Benefits_ShowMore';
import Core_Intc_Show_Less from '@salesforce/label/c.Core_Intc_Show_Less';
import EPUM_ShowMoreDate_A_MM_DD_YYYY from '@salesforce/label/c.EPUM_ShowMoreDate_A_MM_DD_YYYY';
import EPUM_ShowMoreDate_B_MM_DD_YYYY from '@salesforce/label/c.EPUM_ShowMoreDate_B_MM_DD_YYYY';
import EPUM_ShowMoreDate_C_MM_DD_YYYY from '@salesforce/label/c.EPUM_ShowMoreDate_C_MM_DD_YYYY';
import EPUM_ShowMoreText_A from '@salesforce/label/c.EPUM_ShowMoreText_A';
import EPUM_ShowMoreText_B from '@salesforce/label/c.EPUM_ShowMoreText_B';
import EPUM_ShowMoreText_C from '@salesforce/label/c.EPUM_ShowMoreText_C';
import PRM_Filter_Button from '@salesforce/label/c.PRM_Filter_Button';
import EPUM_WebsiteMandatory from '@salesforce/label/c.EPUM_WebsiteMandatory';
import EPUM_IntelDomainMail from '@salesforce/label/c.EPUM_IntelDomainMail';
import EPUM_RestrctdContriesErrmsg from '@salesforce/label/c.EPUM_RestrictedCountriesErrMsg';
import PRM_Export_Button from '@salesforce/label/c.PRM_Export_Button';
import styleResource from '@salesforce/resourceUrl/IpaResources';
import LastLoginDate from '@salesforce/schema/User.LastLoginDate';
//import CallCenter from '@salesforce/schema/User.CallCenter';
//import upArrow_white from '@salesforce/resourceUrl/upArrow_white';
import Setting from '@salesforce/schema/TenantUsageEntitlement.Setting';
import onBoardingRedirect from "@salesforce/apex/PRM_IPAPartnerOnboarding_CTRL.onBoardingRedirect";
import Blocked_Domains_Non_Prc1 from '@salesforce/label/c.Blocked_Domains_Non_Prc1';
import Blocked_Domains_Non_Prc2 from '@salesforce/label/c.Blocked_Domains_Non_Prc2';
import Blocked_Domains_Non_Prc3 from '@salesforce/label/c.Blocked_Domains_Non_Prc3';
import Blocked_Domains_Prc1 from '@salesforce/label/c.Blocked_Domains_Prc1';
import Blocked_Domains_Prc2 from '@salesforce/label/c.Blocked_Domains_Prc2';
import PRM_BlockedDomainError from '@salesforce/label/c.PRM_BlockedDomainError';
import PRM_BlockedDomainErrorLabel from '@salesforce/label/c.PRM_BlockedDomainErrorLabel';
import IPA_Request_Support_URL from '@salesforce/label/c.IPA_Request_Support_URL';
import PRM_Bulk_Invite_Process from '@salesforce/label/c.PRM_Bulk_Invite_Process';
import PRM_Invite_Member_Title from '@salesforce/label/c.PRM_Invite_Member_Title';
import PRM_Customer_support_link from '@salesforce/label/c.PRM_Customer_support_link';

export default class EPUM_SearchContactLWC extends LightningElement {


    label = {
        PAGE_SIZE,
        EPUM_AreYouSure,
        EPUEPUM_DoYouWantToSave,
        PRM_Customer_support_link,
        EPUM_ContactRolesResTitle,
        EPUM_ContactRolesResTitle1,
        PRM_Invite_Member_Title,
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
        EPUM_RowsPerPage,
        EPUM_isExistingIPASelfRegistration,
        EPUM_manageTeamMember,
        EPUM_Close,
        EPUM_SelectFilter,
        EPUM_Status,
        EPUM_conStatus,
        EPUM_namePH,
        EPUM_emailPH,
        EPUM_Location,
        EPUM_ContactLocation,
        EPUM_locationPH,
        EPUM_ResponsibilityName,
        EPUM_Cancel,
        EPUM_apply,
        EPUM_LastSignIn,
        EPUM_locOrAcct,
        EPUM_isSendInviteMsgNew,
        EPUM_ActiveIPAContact,
        PRM_Country,
        PRM_Filter_Button,
        Core_Intc_Show_More,
        Core_Intc_Show_Less,
        EPUM_ShowMoreDate_A_MM_DD_YYYY,
        EPUM_ShowMoreDate_B_MM_DD_YYYY,
        EPUM_ShowMoreDate_C_MM_DD_YYYY,
        EPUM_ShowMoreText_A,
        EPUM_ShowMoreText_B,
        EPUM_ShowMoreText_C,
        EPUM_WebsiteMandatory,
	EPUM_IntelDomainMail,
	EPUM_RestrctdContriesErrmsg,
	PRM_Export_Button,
	PRM_BlockedDomainError,
	IPA_Request_Support_URL,
	PRM_BlockedDomainErrorLabel,
    PRM_Bulk_Invite_Process,
    PRM_BlockedContactError
    };


    partnerRole;
    loggedUserPartnerRole;
    partnerTier;
    message
    isDisplayChatWithIntelLink = false;
    createNew = true;
    @track sendInvite = true;
    contactDetails;
    contacts;
    @api searchKeyword = '';
    areDetailsVisible = false;
    isLoading = false;
    
    @track parentunsavedChangesModal = false;
    @track parentunsavedChanges = false;
    @track oldconid = '';
    @track selectConId = '';
    @track apexErrMessage = '';
    @track toggleButtonLabel = '';
    @track showMoreBoolean = false;  
    @track clickedButtonLabel = this.label.Core_Intc_Show_More;  
    @track boolVisible = false; 
    @track showMore_A = false;
    @track showMore_B = false;
    @track showMore_C = false;
    @track showMoreVisibility = false;
    validationmsg = '';
    blockedDomain = false;
    isSearch = false;
    @track BlockedContact=false;

    selectedContactIdWrap = {};
    selectedContactId = '';
    sameOPID = true;
    loggedUserOPID = '';
    loggedUserIntelAccId = '';
    loggedUserId = '';
    listOfOPIDs;
    contactsAllDetails = [];
    filteredContactList = [];
    searchString = {};
    setEntNames;

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
    listOfBlockedDomain = [];

    dataList;
    statusList = ["Active","Invited"];
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
    @track resultDate;
    currentDate = new Date();
    startDateA = new Date(parseInt(EPUM_ShowMoreDate_A_MM_DD_YYYY.substring(6,10)),parseInt(EPUM_ShowMoreDate_A_MM_DD_YYYY.substring(0,2))-1,parseInt(EPUM_ShowMoreDate_A_MM_DD_YYYY.substring(3,5)));
    startDateB = new Date(parseInt(EPUM_ShowMoreDate_B_MM_DD_YYYY.substring(6,10)),parseInt(EPUM_ShowMoreDate_B_MM_DD_YYYY.substring(0,2))-1,parseInt(EPUM_ShowMoreDate_B_MM_DD_YYYY.substring(3,5)));
    startDateC = new Date(parseInt(EPUM_ShowMoreDate_C_MM_DD_YYYY.substring(6,10)),parseInt(EPUM_ShowMoreDate_C_MM_DD_YYYY.substring(0,2))-1,parseInt(EPUM_ShowMoreDate_C_MM_DD_YYYY.substring(3,5)));
    endDateA = new Date(parseInt(EPUM_ShowMoreDate_A_MM_DD_YYYY.substring(17,21)),parseInt(EPUM_ShowMoreDate_A_MM_DD_YYYY.substring(11,13))-1,parseInt(EPUM_ShowMoreDate_A_MM_DD_YYYY.substring(14,16))+1);
    endDateB = new Date(parseInt(EPUM_ShowMoreDate_B_MM_DD_YYYY.substring(17,21)),parseInt(EPUM_ShowMoreDate_B_MM_DD_YYYY.substring(11,13))-1,parseInt(EPUM_ShowMoreDate_B_MM_DD_YYYY.substring(14,16))+1);
    endDateC = new Date(parseInt(EPUM_ShowMoreDate_C_MM_DD_YYYY.substring(17,21)),parseInt(EPUM_ShowMoreDate_C_MM_DD_YYYY.substring(11,13))-1,parseInt(EPUM_ShowMoreDate_C_MM_DD_YYYY.substring(14,16))+1);

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
            this.loggedUserIntelAccId = data.loggedUserIntelAccId;
            this.loggedUserId = data.loggedUserId;
            this.listOfOPIDs = data.listOfOPIDs;
            this.totalNoOfContacts = this.contacts.length;
            this.coreEntNames = data.coreEntNames;
            this.isLoading = false;

            if(this.currentDate >= this.startDateA && this.currentDate <= this.endDateA){
                this.showMore_A = true;
            }
            if(this.currentDate >= this.startDateB && this.currentDate <= this.endDateB){
                this.showMore_B = true;
            }
            if(this.currentDate >= this.startDateC && this.currentDate <= this.endDateC){
                this.showMore_C = true;
            }

            if((this.showMore_A == true || this.showMore_B == true || this.showMore_C == true)){
                this.showMoreVisibility = true;
            }
            console.log('List of Core Contact Entitlements for IPA are: ');
            console.log(this.coreEntNames);

            if (this.totalNoOfContacts > 0) {
                for (var i = 0; i < this.totalNoOfContacts; i++) {
                    conDataRow = this.prepareConData(this.contacts[i]);
                    this.dTData.push(conDataRow);
                    statusSet.add(conDataRow.activeStatus);
                    this.locationSet.add(this.contacts[i].Account.BillingCountry);
                    //this.locationSet.add(conDataRow.ContactOPID_Name);
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
               // conData.OPIDCountry = this.contacts[con].Account.BillingCountry; //Akshay Change
                conData.OPIDCountry = this.contacts[con].MailingCountry; //UAT issue >> Country should get fetched from contact 
                if (this.contacts[con].Users) conData.ContactUser_Id = this.contacts[con].Users[0].Id;
                if(conData.ContactOPID_Id == null) conData.ContactOPID_Id = conData.Account_Id;
                conData.ContactPartnerRole = this.contacts[con].Core_IPA_PartnerRole__c;
                // Get the last signed in date of the user
                var LastSignonDate = [];
                if (this.contacts[con].Users && this.contacts[con].Users[0].LastLoginDate && this.contacts[con].Users[0].LastLoginDate != null){
                    LastSignonDate = this.contacts[con].Users[0].LastLoginDate.split("T");
                    conData.LastUserLogin = LastSignonDate[0];
                } else{conData.LastUserLogin = "NA"}
                //Get the status of the contact if Active, Suspended or Invited
                var lstActiveStatus = this.contacts[con].Account_Contact_Relationships__r;
                var isActive = 'Invited';
                var loopThrough = true;
                if (lstActiveStatus && lstActiveStatus.length > 0) {
                    for (var conStat in lstActiveStatus) {
                        if (loopThrough == true && lstActiveStatus[conStat].PRM_Relationship_Id__r.Name == 'Employee' && lstActiveStatus[conStat].PRM_InActive_Ind__c == false && lstActiveStatus[conStat].PRM_Status_Nm__c == "Complete"){
                            isActive = 'Active';
                            loopThrough = false;
                        }
                        if (loopThrough == true && lstActiveStatus[conStat].PRM_Relationship_Id__r.Name == 'Employee' && lstActiveStatus[conStat].PRM_InActive_Ind__c == true && lstActiveStatus[conStat].PRM_Status_Nm__c == "Complete"){
                            isActive = 'Suspended';
                        }
                    }
                }
                conData.activeStatus = isActive;
                // Get the "Responsibility Assigned" for the GUI and store it in "Roles" variable
                var roles = [];
                var lstEntitlements = this.contacts[con].Contact_Entitlements__r;
                if (lstEntitlements && lstEntitlements.length > 0 && conData.activeStatus == 'Active') {
                    if (lstEntitlements.length == 1 && lstEntitlements[0].Core_Entitlement_Id__r.Name == 'Employee') {
                        roles.push(lstEntitlements[0].Core_Entitlement_Id__r.Core_Display_Name__c);
                        this.roleSet.add(lstEntitlements[0].Core_Entitlement_Id__r.Core_Display_Name__c);
                    }
                    for (var conEnt in lstEntitlements) {
                        if (lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Employee') {
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

                this.contactsAllDetails[con] = conData;
            }
            
           /* for(let rl in this.roleSet){
                console.log('in role' + rl);
                roleObj.name = rl;
                roleObj.isResChecked = false;
                this.roleList.push(roleObj);
            }*/

            this.roleSet.forEach((v) => {
                let roleObj ={};
                roleObj.name = v;
                roleObj.isResChecked = false;
                this.roleList.push(roleObj);
            });
            console.log('role List');
            console.log(this.roleList);
            this.statusList.forEach((v) => {
                let statusObj = {};
                statusObj.name = v;
                statusObj.isStatChecked = false;
                this.statusArr.push(statusObj);
            });
            console.log("Below is list before OPID based sorting: ");
            console.log(this.contactsAllDetails);
            var result1 = [];
            var result2 = [];
            for (var con in this.contactsAllDetails) {
                if (this.contactsAllDetails[con].ContactOPID_Id == this.loggedUserOPID && this.contactsAllDetails[con].ContactPartnerRole == this.loggedUserPartnerRole) {
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

    // Draco[Shubham] : Start - Changes for the functionality to download contacts in excel format

    contactHeaders = {
        Name: "Name",
        Email: "Email Id",
	    LastUserLogin: "Last Sign-In",
        activeStatus:"IPA Membership",
	    OPIDCountry : "Country",
	    Roles : "Responsibilities Assigned"
    }
    
    //timeStamp = current.toLocaleString();
    fileName = 'ContactList'
    exportHandler(){
        //console.log('Download triggered')

        //console.log('Time stamp',this.timeStamp)
        exportCSV(this.contactHeaders, this.contactsAllDetails, "ContactList")
    }

    // Draco[Shubham] : End - changes related to contacts in excel format *******************


    roleList = [];
    statusArr = [];
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
        if ((this.message === this.label.EPUM_isSendInviteMsgNew || this.message === this.label.EPUM_isSendInviteMsgNew 
            || this.message === this.label.EPUM_isContactExitssWithSameRoleMsg) && !this.BlockedContact) {
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
                    //console.log("Below is data from filteredContactList: ");
                    //console.log(this.filteredContactList[i]);
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
        conData.locationAccount = data.Account.BillingCountry;

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
        //this.paginationlistRows = [];
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
            if(value.includes('@')){
                var domainCheck = value.split("@")[1];
            } else{
                var domainCheck = 'Invalid';
            }
            
            var intelDomain = false;
            if (domainCheck.toLowerCase()===('intel.com'.toLowerCase())){ 
               intelDomain = true;
               this.validationmsg = this.label.EPUM_IntelDomainMail;
                return false;
            }

            if (this.template.querySelector(".searchInput").value !== "" && emailPattern.test(value)&& intelDomain == false) {
                this.isLoading = true;
                
                searchContactByEmail({
                    searchKeyWord: value.trim(),
                    userId: Id
                }).then(result => {
                    console.log('result'+result);
        if(result.accGeo != 'PRC'){
            this.listOfBlockedDomain = Blocked_Domains_Non_Prc1.split(';');
            this.listOfBlockedDomain.push(...Blocked_Domains_Non_Prc2.split(';'));
            this.listOfBlockedDomain.push(...Blocked_Domains_Non_Prc3.split(';'));
        }
        else{
            this.listOfBlockedDomain = Blocked_Domains_Prc1.split(';');
            this.listOfBlockedDomain.push(...Blocked_Domains_Prc2.split(';'));
        }

        this.listOfBlockedDomain.forEach(labelValue => {
            if (domainCheck.toLowerCase() == labelValue.toLowerCase()) {
                this.blockedDomain = true;
                this.isLoading = false;
                console.log('domainCheck - ' + domainCheck);
                console.log('labelValue - ' + labelValue);
                
            }
        });
        if(!this.blockedDomain){
                    if (result.isContactExistsinDB) {
                        if(result.acrActive){
                        this.message = this.label.EPUM_ActiveIPAContact;
                        this.isDisplayChatWithIntelLink = true;
                        }
                        else if(result.isContactDeleted){
                            this.sendInvite = true;
                            this.message = this.label.EPUM_isSendInviteMsgNew;
                            this.contactDetails = result;
                        }
                        
                            
                        /*if (result.isContactExistsinOnePartnerAcc && result.isContactExitssWithSameRole && !result.isPendingContact && !result.isContactDeleted && !result.isSendInvite) {
                            console.log('contact exists here');
                            this.message = 'The Contact has Active IPA Membership. Need help please contact Support';
                            /*this.startPage = 0;
                            this.endPage = [result.contactDetails].length;
                            this.totalNoOfContacts = [result.contactDetails].length;
                            this.isSearch = true;
                            this.startPageNo = 1;
                            this.totalPageNo = 1;
                            console.log('result.contactDetails' + JSON.stringify(result.contactDetails))*/
                            //let searchCons = [result.contactDetails];
                           /* for (let key in searchCons) {
                                this.paginationlistRows.push(this.prepareConData(searchCons[key]));
                            }
                        }*/ else if (result.isSendInvite) {
                            this.sendInvite = true;
                            this.contactDetails = result;
                            this.message = this.label.EPUM_isSendInviteMsgNew
                        } else if (result.isPendingContact) {
                            this.message = this.label.EPUM_isPendingContactMsg;
                            this.isDisplayChatWithIntelLink = true;
                        }
                        // For LoginDeleted - start
                        /*else if (result.isContactDeleted) {
                            this.message = this.label.EPUM_isContactDeleted;
                        }*/
                        // For LoginDeleted - End  
                        //For contacts with existing self registration - START
                        else if(result.isExistingIPASelfRegistration) {
                            this.message = this.label.EPUM_isExistingIPASelfRegistration;
                            this.isDisplayChatWithIntelLink = true;
                        }
                        //For contacts with existing self registration - END

                        else if (!result.isContactExistsinOnePartnerAcc) {
                            this.message = this.label.EPUM_isContactExistsinOnePartnerAccMsg;
                            this.isDisplayChatWithIntelLink = true;
                            console.log('1')
                        } else if (!result.isContactExitssWithSameRole) {
                            this.message = this.label.EPUM_isContactExitssWithSameRoleMsg;
                            this.isDisplayChatWithIntelLink = true;
                            console.log('2')
                        }else if(!result.isSendInvite){
                            this.message = this.label.EPUM_isContactExitssWithSameRoleMsg;
                            this.isDisplayChatWithIntelLink = true;
                            console.log('non ipa--non match PR in account');
                        }

                        this.areDetailsVisible = false;
                        this.isLoading = false;
                    } else {
                        this.createNew = true;
                        this.message = this.label.EPUM_isSendInviteMsgNew;
                        this.areDetailsVisible = false;
                        this.isLoading = false;
                    }
    }
    if(result.BlockedContact){
       // this.ValidationMsg='This contact is blocked for Intel Partner Alliance registration. Please contact support for further information'
        this.createNew=false;
        this.sendInvite=false;
        this.message=this.label.PRM_BlockedContactError;
        this.getValidationMsg=false;
        this.BlockedContact=true;
        console.log('validationmsg' + this.validationmsg );
        console.log('result.BlockedContact' + result.BlockedContact );
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
	this.blockedDomain = false;

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }
    }

    getRowId(event) {
        //this.showConDeatils = false;
        this.areDetailsVisible = true;
        this.selectedContactIdWrap.selectedContactId = event.currentTarget.dataset.myid;
        this.selectConId = event.target.id.split('-')[0];
        if(this.loggedUserOPID != null){
            this.selectedContactIdWrap.loggedUserOPID = this.loggedUserOPID;
        } else{
            this.selectedContactIdWrap.loggedUserOPID = this.loggedUserIntelAccId;
        }
        
        this.selectedContactIdWrap.loggedUserPartnerRole = this.loggedUserPartnerRole;
        this.selectedContactIdWrap.loggedUserId = this.loggedUserId;   

        for(var con in this.filteredContactList){
            if(this.filteredContactList[con].Id === this.selectConId){
                this.selectedContactIdWrap.selectedConDetails = this.filteredContactList[con];
                console.debug(this.selectedContactIdWrap.selectedConDetails);
            }
        }

        if (this.parentunsavedChanges) {
            console.log('in if row')
            this.parentunsavedChangesModal = true;
        } else {
            console.log('in else row')
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
        this.parentunsavedChanges = event.detail.change;
        this.oldconid = event.detail.oldcontactId;
        console.log(this.parentunsavedChanges);
        console.log("in handle save event"+this.showConDeatils);
        console.log(event.detail.hideConDetl);
        
        
        if(event.detail.hideDetails){
            this.showConDeatils = false;
            this.template.querySelector('div.slds-m-horizontal_x-small.slds-m-top_small').scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
        }
       /* if(event.detail.hideConDetl){
            console.log('in hideConDetl sec');
            this.template.querySelector('div.slds-m-horizontal_x-small.slds-m-top_small').scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
            return;
        }*/
        
        if(!this.parentunsavedChanges){
            this.showConDeatils = this.parentunsavedChanges;
            let conEntl = this.template.querySelector("c-epum-contact-entitlement-view");
            console.log("Scroll down to: " + conEntl);
            console.log(this.template);
            conEntl.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
        }

        if(event.detail.navToList){
            console.log(this.template.querySelectorAll('div.slds-m-horizontal_x-small.slds-m-top_small'));
            this.template.querySelector('div.slds-m-horizontal_x-small.slds-m-top_small').scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
            //return;
        }        
    }

    handleHideConList(event){
        if(event.detail.hideDetails){
            this.showConDeatils = true;
            console.log('in hide con1');
            this.template.querySelector('div.slds-m-around--large').scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
        }
    }

    showInviteUser() {
        if (this.searchKeyword.toLowerCase()===('intel.com'.toLowerCase())){ 
            this.validationmsg = this.label.EPUM_IntelDomainMail;
            this.message = '';
            this.sendInvite = false;
            this.createNew = false;
            this.isLoading = false;
        } else if (this.searchKeyword == ''){ 
            this.validationmsg = this.label.EPUM_EmailValidationMsg;
            this.message = '';
            this.sendInvite = false;
            this.createNew = false;
            this.isLoading = false;
        } else{
        this.inviteUser = true;
    }
    }

    sendInviteToUser() {
        console.log('in send invite');
        console.log(this.contactDetails);
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
                this.apexErrMessage = result.message;
                if(this.apexErrMessage.includes("Website is mandatory for extending")){
                    this.message = this.label.EPUM_WebsiteMandatory;
                    this.sendInvite = false;
                } else if(this.apexErrMessage.includes("embargoed country")){
                    this.message = this.label.EPUM_RestrctdContriesErrmsg;
                    this.sendInvite = false;
                } else{
                    //this.message = result.message;
                    const event = new ShowToastEvent({
                        title: result.message,
                        variant: 'Error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
                    
                console.log('contact creation' + JSON.stringify(result));

            }

        }).catch(error => {
            console.log(error);
            this.isLoading = false;
        })
    }

    searchTextChange(event) {
        this.searchKeyword = event.target.value;
    }

    // Akshay change - START**************************************
    handleShowMoreClick(event) {  
        if (this.showMoreBoolean === false) {  
            this.clickedButtonLabel = this.label.Core_Intc_Show_Less;   
            this.showMoreBoolean = true;  
            this.boolVisible = true;   
        } else if (this.showMoreBoolean === true) {  
            this.clickedButtonLabel = this.label.Core_Intc_Show_More;              
            this.showMoreBoolean = false; 
            this.boolVisible = false;   
        }  
    }  

    handleSearchName(event){
        this.searchString.Name = event.target.value;
        this.applyFilterMethod(this.searchString);
        this.pagination(this.filteredContactList);
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
        sortData.field = 'OPIDCountry';
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

    closehandler(event) {
        console.log('in SC cls Handlr');
        this.inviteUser = false;
        if(event.detail.sendInvStatus)
        this.template.querySelector('div.slds-m-horizontal_x-small.slds-m-top_small').scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
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
            console.log('acctRoleSet size '+this.acctRoleSet.size);
                /*if(this.acctRoleSet.size > 0){
                    this.roleList.forEach((v) => {
                        //console.log(v);
                        if(this.acctRoleSet.has(v.name)){
                        v.isResChecked = false;
                        this.acctRoleSet.delete(v.name);
                        console.log('in close modal '+v);
                        }
                    });*/
                    /*this.acctRoleSet.forEach((value) => {

                    });
                }*/
           /* if(this.statusSet.size > 0){
                this.statusArr.forEach((v) =>{
                    if(this.statusSet.has(v.name)){
                        v.isStatChecked = false;
                        this.statusSet.delete(v.name);
                        console.log(v);
                    }
                });
            }*/
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
        //this.res2Button = true;
        //this.res2Field = false;
        this.showModalWindow = false;

        //this.acctRoleSet.splice(-this.resCounter);

    }

    enterFilterText(event) {
        this.firstNameField = false;
        this.emailField = false;
        this.statusField = false;
        this.locationField = false;
        this.res1Field = false;

        this.firstNameButton = true;
        this.emailButton = true;
        this.statusButton = true;
        this.locationButton = true;
        this.res1Button = true;

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
            //event.stopPropagation();
            this.locationButton = false;
            this.locationField = true;
            //let conLoc = this.template.querySelector('[data-id="locationC"]');
            //console.log("Scroll down to: " + conLoc);
            //conLoc.scrollIntoView();
           // console.log('evt modal');
            //event.stopPropagation();
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
        }
        if (event.target.id.split('-')[0] == 'lastNameText') {
            this.lNameSearchText = event.target.value;
        }
        if (event.target.id.split('-')[0] == 'emailText') {
            this.emailSearchText = event.target.value;
        }
        if (event.target.id.split('-')[0] == 'statusText') {
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
            /*let dId = event.target.id;
            let stCheckBox = this.template.querySelectorAll('[data-id="' + dId + '"]');
            stCheckBox.checked = true;*/
            this.statusArr.forEach((v) =>{
                if(event.target.id.split('-')[0] == v.name){
                    v.isStatChecked = event.target.checked;
                    console.log(v);
                }
            });

            if(!event.target.checked){
                this.statusSet.delete(event.target.id.split('-')[0]);
            }
            else
                this.statusSet.add(event.target.id.split('-')[0]);

                //this.allStatus.forEach(item => this.statusSet.add(item));  

            console.log(this.statusSet);
            console.log(this.allStatus);
            console.log('status event---> ' + event.target.id.split('-')[0]);
            console.log(this.allStatus);
        }
        if (this.locationSet.has(event.target.value)) {
            this.acctLocSet.clear();
            console.log('in loc evt');
            console.log('location event---> ' + event.target.value);
            this.acctLocSet.add(event.target.value);
            console.log(this.acctLocSet);
            
        }

        if (this.roleSet.has(event.target.id.replaceAll(event.target.id.slice(-2), ''))) {
            console.log('op'+event.target.checked);
            let selRole = event.target.id.replaceAll(event.target.id.slice(-2), '');
            /*for(let i in this.roleList){
                console.log(i.name);
                //if(event.target.id.replaceAll(event.target.id.slice(-2), '') == i)
            }*/
            
            this.roleList.forEach((v) => {
                //console.log(v);
                if(selRole == v.name){
                v.isResChecked = event.target.checked;
                console.log(v);
                }
            });
            //this.resCounter++;
            /*if(event.target.checked)
            this.isResChecked = false;

            else
            this.isResChecked = true;
*/

            if(!event.target.checked){
                this.acctRoleSet.delete(selRole);
                /*let inRole = this.allRoles.indexOf(selRole);
               if(inRole > -1)
               this.allRoles.splice(inRole,1);*/
                //this.resCounter--;
            }
            else{
                this.acctRoleSet.add(selRole);
                //this.resCounter++;
            }
           // this.allRoles.forEach(item => this.acctRoleSet.add(item));
            console.log('reslog'+this.resCounter);
            console.log('roles event---> ' + event.target.id.split('-')[0]);
           // this.acctRoleSet.add(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            console.log(this.acctRoleSet);
        }
        console.log(event.target.id.split('-')[0]);

    }
    //isResChecked = false;
    searchString = '';
    searchConList = [];
    allLocation = [];
    allRoles = [];
    resCounter = 0;

    showFilterdData(event) {

        if (this.template.querySelector("c-epum-contact-entitlement-view") != null) {
            this.template.querySelector("c-epum-contact-entitlement-view").isCompVisible = false;
        }

        //this.showConDeatils = true;
        console.log('in filterdata method');
        console.log(event);
        /*if(event.target.id.split('-')[0] == 'applyFilter'){
            this.allRoles.forEach(item => this.acctRoleSet.add(item));
            this.allStatus.forEach(item => this.statusSet.add(item));
        }*/
        this.resCounter = 0;
        this.allStatus = Array.from(this.statusSet);
        this.allLocation = Array.from(this.acctLocSet);
        //this.acctRoleSet.forEach(item => this.allRoles.push(item));
        console.log(this.acctRoleSet);
        this.allRoles = Array.from(this.acctRoleSet);
       // this.acctRoleSet.clear();
        //this.statusSet.clear();
       /* this.roleList.forEach((v) => {
            //console.log(v);
            if(this.allRoles.includes(v.name)){
            v.isResChecked = !v.isResChecked;
            console.log(v);
            }
        });

        this.statusArr.forEach((v) =>{
            if(this.allStatus.includes(v.name)){
                v.isStatChecked = !v.isStatChecked;
                console.log(v);
            }
        });*/

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
        //console.log(this.filteredContactList);
        this.searchString = this.fNameSearchText + ',' + this.lNameSearchText + ',' + this.emailSearchText + ',';
        this.searchConList = this.searchString.split(',');
        //console.log(this.searchString);
        let statusSize = this.allStatus.length;
        var conFilterEmail = new Set();
        let sFlag = true;
        let rFlag = true;

        //var output = this.dTData.filter(con => con.Name.split(' ')[0]);
        for (var con in this.dTData) {
            let iFlag = false;
            //console.log(this.dTData[con]);
            //let conString = this.dTData[con].Name.split(' ')[0] + ',' + this.dTData[con].Name.split(' ')[1] + ',' + this.dTData[con].Email + ',' + this.dTData[con].AccName + ',' + this.dTData[con].activeStatus;

           /* if (this.dTData[con].Name.split(' ')[0].startsWith(this.fNameSearchText) && this.dTData[con].Email.startsWith(this.emailSearchText)
                && this.dTData[con].Name.split(' ')[1].startsWith(this.lNameSearchText)) {*/
                    if (this.dTData[con].Name.toLowerCase().includes(this.fNameSearchText.toLowerCase()) && this.dTData[con].Email.toLowerCase().includes(this.emailSearchText.toLowerCase())) {      
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
                    //console.log('in loc data');
                    for (let aL in this.allLocation) {
                        //console.log(this.dTData[con].ContactOPID_Name.startsWith(this.allLocation[aL]));
                        if (this.dTData[con].OPIDCountry.startsWith(this.allLocation[aL])) {
                            sFlag = true;
                            break;
                        }
                        else
                            sFlag = false;
                    }
                }

                if (this.allRoles.length > 0) {
                    rFlag = false;
                   // console.log('in roles data');
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
       // console.log(contactList);
        this.filteredContactList = contactList;
        console.log("pill log " + this.fNameSearchText + this.lNameSearchText + this.emailSearchText);
        if (this.fNameSearchText != '') {
            this.showFNamePill = true;
            //this.fNamePillText = 'First Name starts with ' + this.fNameSearchText;
            this.fNamePillText = 'Name like ' + this.fNameSearchText;
            console.log("first pill " + this.showFNamePill);
        }

        if (this.lNameSearchText != '') {
            this.showLNamePill = true;
            this.lNamePillText = 'Last Name starts with ' + this.lNameSearchText;
            console.log("last pill " + this.showLNamePill);
        }

        if (this.emailSearchText != '') {
            this.showEmailPill = true;
            this.emailPillText = 'Email like ' + this.emailSearchText;
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
console.log(event.target.id.replaceAll(event.target.id.slice(-2), ''))
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
            this.statusArr.forEach((v) =>{
                if(event.target.id.split('-')[0] == v.name){
                    v.isStatChecked = false;
                    console.log(v);
                }
            });
            //console.log(this.allStatus.splice(statusIndex,1));
            console.log(this.allStatus);
            this.showFilterdData(event);
        }

        if (this.allLocation.includes(event.target.id.replaceAll(event.target.id.slice(-2), ''))) {
            this.acctLocSet.delete(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            this.showFilterdData(event);
        }

        if (this.allRoles.includes(event.target.id.replaceAll(event.target.id.slice(-2), ''))) {
            this.allRoles.forEach(item => this.acctRoleSet.add(item));
            this.acctRoleSet.delete(event.target.id.replaceAll(event.target.id.slice(-2), ''));
            console.log(this.acctRoleSet);
            this.roleList.forEach((v) => {
                //console.log(v);
                if(event.target.id.replaceAll(event.target.id.slice(-2), '') == v.name){
                v.isResChecked = false;
                console.log(v);
                }
            });
            this.showFilterdData(event);
        }
    }

    get acctLocationList() {
        return this.actL;
    }
}