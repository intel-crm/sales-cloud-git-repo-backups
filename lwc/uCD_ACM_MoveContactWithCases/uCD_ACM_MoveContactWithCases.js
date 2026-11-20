import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEntitlement from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getEntitlementDetails';
import getIPSPro from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getIPSProjects';
import getCases from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getCasesDetails';
//import getAccessToAcctSelection from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getAccessToAcctSelection';
import getAccountContactRelationship from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getAccountContactRelationship';
import getSubscribtions from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getSubscribtions';
import getAccRelatedContacts from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.getAccRelatedContacts';
import checkUserAccess from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.checkUserAccess';
import changeAccount from '@salesforce/apex/UCD_ACM_MoveContactWithCases_Cont.changeAccount';
import { loadStyle } from 'lightning/platformResourceLoader';
import UCD_ACM_MoveContactWithCasesStyles from '@salesforce/resourceUrl/UCD_ACM_MoveContactWithCasesStyles';
import { getRecord } from 'lightning/uiRecordApi';
const CONT_FIELDS = [
    'Contact.Name',
    'Contact.Account.Name',
    'Contact.Account.Core_PSG_Account__c',
    'Contact.Account.Core_IsODM__c',
    'Contact.Account.Core_CNDA_Number__c',
    'Contact.Account.Core_Business_Party_Id__c',
    'Contact.Account.Core_English_Only_Name__c',
    'Contact.Account.Core_Export_Compliance_Block__c ',
    'Contact.Account.Core_IPS_Active__c'
];
const TARGETACCOUNT_FIELDS = [
    'Account.Name',
    'Account.Core_PSG_Account__c',
    'Account.Core_IsODM__c',
    'Account.Core_CNDA_Number__c',
    'Account.Core_Business_Party_Id__c',
    'Account.Core_English_Only_Name__c',
    'Account.Core_Export_Compliance_Block__c ',
    'Account.Core_IPS_Active__c',
    'Account.Owner.UserRole.Name',
    'Account.Core_Intel_Partner_Alliance_PartnerGroup__c'
];

export default class UCD_ACM_MoveContactWithCases extends NavigationMixin(LightningElement) {
    @api recordId;
    @track keepEntitlements = false;
    @track enabledEntiSelected = true;
    @track isCaseContChecked = false;
    @track disableDropdown = true;
    @track targetAccDetails = {};
    @track currentAccDetails = {};
    @track gecCaseFound = false;
    @track isLoading = false;
    @track userAccess = false;
    recordName;
    accountName;
    contAccId = null;
    searchQuery = ''; // For storing search query
    isChecked = false; // For storing checkbox state
    hidePopUpWarning = false;
    moveAccoutWarningMessage = '';
    targetAccountId = '';
    caseContactChgId = null;
    @track contactsListforCaseMove = [];
    @track PCRelationshipData;
    @track subscriptionsData;
    @track entitlementData;
    @track ipsProjectData;
    @track casesData;
    @track casewithoutProj = [];
    @track casewithoutProjData = [];
    @track caseswithProjData = [];
    @track caseswithoutProdData = [];
    searchQuery = '';

    @track PCRelationshipColumns = [
        {
            label: 'Account',
            fieldName: 'pcrAccUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'pcrAccName' },
                target: '_blank'
            }
        },
        { label: 'Partner Role', fieldName: 'PRM_Partner_Role__c' },
        {
            label: 'Relationship',
            fieldName: 'pcrRelatshUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'pcrRelationshipName' },
                target: '_blank'
            }
        },
        { label: 'Start Date', fieldName: 'PRM_Start_Date_Dt__c' },
        { label: 'End Date', fieldName: 'PRM_End_Date_Dt__c' },
        {
            label: 'SelecteInActive Indicaterd',
            fieldName: 'PRM_InActive_Ind__c',
            type: 'boolean',
            typeAttributes: {
                variant: 'base',
                trueValue: 'TRUE',
                falseValue: 'FALSE'
            }
        },
        { label: 'Status', fieldName: 'PRM_Status_Nm__c' },
        {
            label: 'Record Link',
            fieldName: 'pcrUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'pcrRecordLinkName' },
                target: '_blank'
            }
        }
    ];

    @track subscriptionsColumns = [
        { label: 'Partner Subscription', fieldName: 'subPartnerName', sortable: true },
        {
            label: 'Contact',
            fieldName: 'subContactUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'subContactName' },
                target: '_blank'
            }
        },
        { label: 'Created Date', fieldName: 'CreatedDate' },
        { label: 'Status', fieldName: 'PRM_Status_Nm__c' },
        { label: 'Status Reason', fieldName: 'PRM_Status_Reason_Txt__c' },
        { label: 'Last Modeified Date', fieldName: 'LastModifiedDate' },
        {
            label: 'Record Link',
            fieldName: 'subUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'subRecordLinkName' },
                target: '_blank'
            }
        }];

    @track entiColumns = [
        {
            label: 'Name',
            fieldName: 'entiUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            }
        },
        { label: 'Contact Name', fieldName: 'contactName', sortable: true },
        { label: 'Entitlement', fieldName: 'entiName', sortable: true },
        { label: 'Entitlement Type', fieldName: 'Core_Entitlement_Type__c', sortable: true },
        {
            label: 'Selected',
            fieldName: 'Core_Selected__c',
            type: 'boolean',
            typeAttributes: {
                variant: 'base',
                trueValue: 'TRUE',
                falseValue: 'FALSE'
            }
        }
    ];

    @track ipsProjectColumns = [
        { label: 'Account', fieldName: 'Core_IPS_Contact_Account__c', sortable: true },
        { label: 'Primier Support Project', fieldName: 'ipsProjectName' },
        { label: 'Provisioning Date', fieldName: 'Core_IPS_Provisioning_Date__c' },
        {
            label: 'Selective Member',
            fieldName: 'Core_Selective_Member__c',
            type: 'boolean',
            typeAttributes: {
                variant: 'base',
                trueValue: 'TRUE',
                falseValue: 'FALSE'
            }
        },
        {
            label: 'User',
            fieldName: 'userUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'userName' },
                target: '_blank'
            }
        },
        { label: 'Status', fieldName: 'Core_Status__c' },
    ];

    @track caseswithoutProdColumns = [
        { label: 'Contact Name', fieldName: 'contactName', sortable: true },
        { label: 'Case Number', fieldName: 'caseNumber' },
        { label: 'Status', fieldName: 'caseStatus' },
        { label: 'Owner', fieldName: 'caseOwner' },
        { label: 'Product Name', fieldName: 'caseProductName' },
        { label: 'IPS Project', fieldName: 'caseIPSProject' },
        { label: 'IPS Product', fieldName: 'caseIPSProduct' },
        { label: 'IPS Supported Product', fieldName: 'caseIPSSupportedProduct' },
        {
            label: 'Asset Id',
            fieldName: 'assetUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'caseAssetName' },
                target: '_blank'
            }
        },
        {
            label: 'GEC Case',
            fieldName: 'caseGecCase',
            type: 'boolean',
            typeAttributes: {
                variant: 'base',
                trueValue: 'TRUE',
                falseValue: 'FALSE'
            }
        },
        {
            label: 'Account Name',
            fieldName: 'accIdUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'caseAccountName' },
                target: '_blank'
            }
        }
    ];

    @track caseswithProdColumns = [
        { label: 'Contact Name', fieldName: 'contactName', sortable: true },
        { label: 'Case Number', fieldName: 'caseNumber' },
        { label: 'Status', fieldName: 'caseStatus' },
        { label: 'Owner', fieldName: 'caseOwner' },
        { label: 'Product Name', fieldName: 'caseProductName' },
        { label: 'IPS Project', fieldName: 'caseIPSProject' },
        { label: 'IPS Product', fieldName: 'caseIPSProduct' },
        { label: 'IPS Supported Product', fieldName: 'caseIPSSupportedProduct' },
        {
            label: 'Asset Id',
            fieldName: 'assetUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'caseAssetName' },
                target: '_blank'
            }
        },
        //{ label: 'GEC Status', fieldName: 'caseGecStatus' },
        {
            label: 'Account Name',
            fieldName: 'accIdUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'caseAccountName' },
                target: '_blank'
            }
        }
    ];

    connectedCallback() {
        this.isLoading = true;
        loadStyle(this, UCD_ACM_MoveContactWithCasesStyles);
        checkUserAccess()
            .then((result) => {
                if(result === true){
                    this.userAccess = true; 
                }
                else{
                    this.userAccess = false;
                }
                this.isLoading = false; 
            })
            .catch((error) => {
                console.error('Error fetching user access:', error);
            });
    }

    @wire(getRecord, { recordId: '$recordId', fields: CONT_FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            // Extract the field values from the data response
            this.recordName = data.fields.Name.value;
            this.accountName = data.fields.Account.value.fields.Name.value;
            this.contAccId = data.fields.Account.value.id;
            this.currentAccDetails = {
                currentAccName: data.fields.Account.value.fields.Name.value,
                currentAccPSGAcc: data.fields.Account.value.fields.Core_PSG_Account__c.value,
                currentAccIsODM: data.fields.Account.value.fields.Core_IsODM__c.value,
                currentAccCNDANumber: data.fields.Account.value.fields.Core_CNDA_Number__c.value,
                currentAccBPID: data.fields.Account.value.fields.Core_Business_Party_Id__c.value,
                currentAccEnglishName: data.fields.Account.value.fields.Core_English_Only_Name__c.value,
                currentAccECBlock: data.fields.Account.value.fields.Core_Export_Compliance_Block__c.value,
                currentAccIPSActive: data.fields.Account.value.fields.Core_IPS_Active__c.value
            };
            console.log('@Account->', this.currentAccDetails);
        } else if (error) {
            console.error('Error fetching getRecord Method: ', error);
        }
    }

    @wire(getEntitlement, { recordId: '$recordId' })
    wiredEntitlementRecord({ error, data }) {
        if (data) {
            this.entitlementData = data.map(entData => {
                console.log('@!@#Core_Selected__c-> ', entData.Core_Selected__c);
                if (entData.Core_Selected__c === true) {
                    this.enabledEntiSelected = false;
                }
                return {
                    ...entData,
                    contactName: entData.Core_Contact_Id__r.Name,
                    entiName: entData.Core_Entitlement_Id__r.Name,
                    entiUrl: `/lightning/r/Core_Contact_Entitlement__c/${entData.Id}/view`
                };
            });

        } else if (error) {
            console.error('Error fetching wiredEntitlementRecord Method :', error);
        }
    }

    @wire(getAccountContactRelationship, { contactId: '$recordId' })
    wiredPCRelationshipRecord({ error, data }) {
        if (data) {

            this.PCRelationshipData = data.map(pcrData => ({
                ...pcrData,
                pcrAccName: pcrData.PRM_Account_Id__r.Name,
                pcrRelationshipName: pcrData.PRM_Relationship_Id__r.Name,
                pcrUrl: `/lightning/r/PRM_Account_Contact_Relationship__c/${pcrData.Id}/view`,
                pcrAccUrl: `/lightning/r/Account/${pcrData.PRM_Account_Id__c}/view`,
                pcrRelatshUrl: `/lightning/r/PRM_ContactRelationships__c/${pcrData.PRM_Relationship_Id__c}/view`,
                pcrRecordLinkName: 'Record Link'
            }));

        } else if (error) {
            console.error('@#@#Error fetching wiredPCRelationshipRecord Method :', error);
        }
    }

    @wire(getSubscribtions, { contactId: '$recordId' })
    wiredSubscribtionsRecord({ error, data }) {
        if (data) {

            //this.subscriptionsData = data;
            this.subscriptionsData = data.map(subData => ({
                ...subData,
                subPartnerName: subData.PRM_Partner_Subscription_Id__r.Name,
                subContactName: subData.PRM_Contact_Id__r.Name,
                subContactUrl: `/lightning/r/Contact/${subData.PRM_Contact_Id__c}/view`,
                subUrl: `/lightning/r/user/${subData.Id}/view`,
                subRecordLinkName: 'Record Link'
            }));


        } else if (error) {
            console.error('Error fetching wiredSubscribtionsRecord Method:', error);
        }
    }

    @wire(getIPSPro, { contactId: '$recordId' })
    wiredIPSProjectRecord({ error, data }) {
        if (data) {
            this.ipsProjectData = data.map(ipsMember => ({
                ...ipsMember,
                ipsProjectName: ipsMember.Core_IPS_Project__r.Name,
                userName: ipsMember.Core_User__r.Name,
                userUrl: `/lightning/r/user/${ipsMember.Core_User__c}/view`
            }));
            console.log('@#@#this.ipsProjectData-> ', this.ipsProjectData);
        } else if (error) {
            console.error('Error fetching wiredIPSProjectRecord Method:', error);
        }
    } 

   /* @wire(getAccRelatedContacts, { contactId: '$recordId', accountId: '$contAccId' })
    wiredgetAccRelatedContacts({ error, data }) {
        if (data) {
            this.contactsListforCaseMove = data;
        } else if (error) {
            console.error('Error fetching getAccRelatedContacts Method:', error);
        }
    } */

        //Ganesh Changes
//handleRelatedContact(event) {
//    this.selectedContactId = event.detail;
 //   this.fetchRelatedContacts();}
    
fetchRelatedContacts() {
    if (!this.recordId || !this.contAccId) {
        this.contactsListforCaseMove = [];
        return;
    }
    console.log('Ganesh Fetch Account');

    getAccRelatedContacts({
        contactId: this.recordId,
        accountId: this.contAccId
    })
    .then(result => {
        console.log('Ganesh Fetch Account result-> ', result);
        this.contactsListforCaseMove = result || [];
    })
    .catch(error => {
        console.error('Error fetching contacts:', error);
        this.contactsListforCaseMove = [];
    });
}

//Ganesh Changes End
    @wire(getCases, { contactId: '$recordId' })
    wiredCasesRecord({ error, data }) {
        if (data) {
            for (let cs of data) {
                if (!this.gecCaseFound && cs.Core_IPS_GEC_Case__c && cs.Core_IPS_GEC_Status__c !== null && cs.Core_IPS_GEC_Status__c?.startsWith('On Hold')) {
                    this.gecCaseFound = true;
                }

                if (cs.Core_IPS_Project_Case__c !== null && cs.Core_IPS_Project_Case__c !== undefined) {
                    this.caseswithProjData = [...this.caseswithProjData,
                    {
                        contactName: cs.Contact?.Name,
                        caseNumber: cs.CaseNumber,
                        caseStatus: cs.Status,
                        caseOwner: cs.Owner?.Name,
                        caseProductName: cs.Product?.Name,
                        caseIPSProject: cs.Core_IPS_Project_Case__r?.Name,
                        caseIPSProduct: cs.Core_IPS_Product_Org1__r?.Name,
                        caseIPSSupportedProduct: cs.Core_IPS_Product_Org1__r?.Name,
                        caseAssetName: cs.Asset?.Name,
                        caseGecCase: cs.Core_IPS_GEC_Case__c,
                        caseAccountName: cs.Account?.Name,
                        assetUrl: `/lightning/r/Asset/${cs.AssetId}/view`,
                        accIdUrl: `/lightning/r/Account/${cs.AccountId}/view`
                    }];
                }
                else {
                    this.casewithoutProj.push(cs);
                    this.casewithoutProjData = [...this.casewithoutProjData, {
                        contactName: cs.Contact?.Name,
                        caseNumber: cs.CaseNumber,
                        caseStatus: cs.Status,
                        caseOwner: cs.Owner?.Name,
                        caseProductName: cs.Product?.Name,
                        caseIPSProduct: cs.Core_IPS_Product_Org1__r?.Name,
                        caseIPSSupportedProduct: cs.Core_IPS_Product_Org1__r?.Name,
                        caseAssetName: cs.Asset?.Name,
                        caseGecCase: cs.Core_IPS_GEC_Case__c,
                        caseAccountName: cs.Account?.Name,
                        //caseGecStatus: cs.Core_IPS_GEC_Status__c,
                        assetUrl: `/lightning/r/Asset/${cs.AssetId}/view`,
                        accIdUrl: `/lightning/r/Account/${cs.AccountId}/view`
                    }];
                }
            }
        } else if (error) {
            console.error('Error fetching wiredCasesRecord Method:', error);
        }
    }

    // @wire(getAccessToAcctSelection)
    // wiredAccess({ error, data }) {
    //     if (data) {
    //         this.hasAccess = data;
    //     } else if (error) {
    //         console.error('Error fetching wiredAccess Method: ', error);
    //     }
    // }

    handleChangeAction(event) {
        console.log('@Account->', event);
        this.targetAccountId = event.target.value;
    }

    // handleCaseContactNameChange(event) {
    //     this.caseContactChgId = event.target.value;
    // }
    @wire(getRecord, { recordId: '$targetAccountId', fields: TARGETACCOUNT_FIELDS })
    wiredTargetAccount({ error, data }) {
        if (data) {
            this.targetAccDetails = {
                targetAccName: data.fields.Name.value,
                targetAccPSGAcc: data.fields.Core_PSG_Account__c.value,
                targetAccIsODM: data.fields.Core_IsODM__c.value,
                targetAccCNDANumber: data.fields.Core_CNDA_Number__c.value,
                targetAccBPID: data.fields.Core_Business_Party_Id__c.value,
                targetAccEnglishName: data.fields.Core_English_Only_Name__c.value,
                targetAccECBlock: data.fields.Core_Export_Compliance_Block__c.value,
                targetAccIPSActive: data.fields.Core_IPS_Active__c.value,
                targetAccOwnerRoleName: data.fields.Owner.value.fields.UserRole.value ? data.fields.Owner.value.fields.UserRole.value.fields.Name.value : '' ,
                targetAccIsIPA: data.fields.Core_Intel_Partner_Alliance_PartnerGroup__c.value
            };
            console.log('@Account->', this.targetAccDetails);
        } else if (error) {
            console.error('Error fetching wiredTargetAccount Method:', error);
            this.targetAccDetails = {};
        }
    }
    

    // Handler for Search input change
    handleSearchChange(event) {
        this.searchQuery = event.target.value;
    }

    handleCloseModalPopup() {
        this.hidePopUpWarning = false;
    }

    handleEntitlementChange(event) {
        this.keepEntitlements = event.target.checked;
    }

    handleCaseContChecked(event) {
        this.isCaseContChecked = event.target.checked;
        this.disableDropdown = !event.target.checked;
        //Ganesh CHanges

        if(this.isCaseContChecked){
            console.log('Ganesh this.isCaseContChecked',this.isCaseContChecked);
        this.fetchRelatedContacts();

        //Ganesh Changes End
        }
    }
    submitDetailsPopup() {
        this.handleSaveRecord(true);
    }
    handleSelectContCase(event) {
        console.log('Selected Contact ID:', event.detail.selectedItem.Id
        );
        console.log('Selected Contact Name:', event.detail.selectedItem.Name
        );
        this.caseContactChgId = event.detail.selectedItem.Id;
    }

    hasValidateSave(bypass) {
        let flag = false;

        if (this.contAccId === this.targetAccountId) {
            this.showToast('Current account and target account is same.', 'Error', 'error');
            return flag;
        }
        if (this.gecCaseFound) {
            this.showToast(' GEC Cases Found, moving contact and Entitlements is not allowed.', 'Error', 'error');
            return flag;
        }
        if (this.targetAccountId === '') {
            this.showToast(' Account : INVALID ACCOUNT ', 'Error', 'error'); // '+tg.Name+' removed by prem
            return flag;
        }
        if (this.targetAccDetails.targetAccIsODM != this.currentAccDetails.currentAccIsODM && this.keepEntitlements == true) {
            this.showToast('Keep Entitlements is not allowed when moving contact from a standard account to an ODM account or from an ODM account to standard account', 'Error', 'error');
            return flag;
        }
        if (this.targetAccDetails.targetAccCNDANumber == undefined && this.keepEntitlements == true && this.targetAccDetails.targetAccPSGAcc != true) {
            this.showToast('CNDA must be filled manually by the user on the Account record : ' + this.targetAccDetails.targetAccName, 'Error', 'error');
            return flag;
        }

        if (this.targetAccDetails.targetAccBPID == undefined && this.keepEntitlements == true && this.targetAccDetails.targetAccPSGAcc != true) {
            this.showToast('Account must be connected to UCD with Unified ID:' + this.targetAccDetails.targetAccName, 'Error', 'error');
            return flag;
        }

        if (this.targetAccDetails.targetAccEnglishName == undefined && this.keepEntitlements == true) {
            this.showToast('English Only Name must be filled manually by the user on the Account record : ' + this.targetAccDetails.targetAccName, 'Error', 'error');
            return flag;
        }

        if (this.currentAccDetails.currentAccECBlock == true) {
            this.showToast(' Account :' + this.currentAccDetails.currentAccName + ' is on  GEC Hold ', 'Error', 'error');
            return flag;
        }

        //Do not process if target account or current Acccount has GEC on Hold Validation
        if (this.targetAccDetails.targetAccECBlock == true) {
            this.showToast(' Account :' + this.targetAccDetails.targetAccName + ' is on  GEC Hold ', 'Error', 'error');
            return flag;
        }

        // Validate target Account's owner has a role setup
        if (this.targetAccDetails.targetAccIPSActive == true && this.keepEntitlements == true, this.targetAccDetails.targetAccOwnerRoleName === '') {
            this.showToast('Please contact IT Support to have them manually set the UserRole to Account :' + this.targetAccDetails.targetAccName + '\'s Owner :', 'Error', 'error');
            return flag;
        }

        if (this.PCRelationshipData.length > 0 && this.targetAccDetails.targetAccIsIPA == false) {
            this.showToast('Contact cannot be move to Non-IPA  Account as Current Contact contains Partner Contact Relationship : ' + this.targetAccDetails.targetAccName, 'Error', 'error');
            return flag;
        }
        if (this.targetAccDetails.targetAccPSGAcc == false && this.currentAccDetails.currentAccPSGAcc == true && !this.hidePopUpWarning && !bypass) {
            this.popUpHeading = 'Warning Message';
            this.moveAccoutWarningMessage1 = 'You are moving the contact from a PSG account to a non-PSG account.';
            this.moveAccoutWarningMessage2 = 'Are you sure you want to proceed?';
            this.hidePopUpWarning = true;
            this.isLoading = false;
            return flag;
        }

        return true;
    }
    handleSaveClick() {
        this.handleSaveRecord(false);
    }

    // Handler for Save button click
    handleSaveRecord(bypass) {
        this.isLoading = true;
        let valiFlag = this.hasValidateSave(bypass);

        if (valiFlag) {
            if (this.targetAccountId !== null) {
                changeAccount({
                    casewithoutProj: this.casewithoutProj,
                    accountId: this.targetAccountId,
                    contactId: this.recordId,
                    keepEntitlements: this.keepEntitlements,
                    moveCase: this.isCaseContChecked,
                    caseMoveContactId: this.caseContactChgId,
                    PCRList: this.PCRelationshipData
                })
                    .then((result) => {
                        console.log('!@#@# Final Result-> ', result);
                        if (result === 'Successful') {
                            console.log('Account successfully changed');
                            // Navigate back to the Contact record page
                            this.backToContact();
                            this.isLoading = false;
                        }
                        if (result === 'Change In Progress') {
                            this.isLoading = false;
                            this.showToast('Account change for this contact already in Progress. Please try later.', 'Error', 'error');
                        }
                        if (result.includes('ERROR')) {
                            this.isLoading = false;
                            this.backToContact();
                            this.showToast(result, 'Error', 'error');
                        }
                    })
                    .catch(error => {
                        // Error handler
                        this.isLoading = false;
                        console.error('Error in handleSearchClick method: ', error);
                    });
            }
        }
    }

    showToast(message, title, type) {
        this.isLoading = false;
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    backToContact() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Contact',
                actionName: 'view',
            },
        });
    }
}