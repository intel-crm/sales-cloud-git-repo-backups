/**
 *  The ipaPartnerModalViewConfirmation component
 * <p>Ipa Partner Modal View Confirmation gets the BoardingSubcomponent Object {@link ipaPartnerOnboardingService.BoardingSubcomponent} from the {@link ipaPartnerOnboardingService.getSubComponentData} service based on the step.componentData value.</p>
 * <p>This component handles the view confirmation renderings. When the user clicks the close button or closes the modal the {@link ipaPartnerOnboardingService.markAsCompleted} service is called.</p>
 * <p>A sample of the modal rendering can be seen in https://d.pr/i/jAqtBH</p>

* @example
* <!-- HTML component example -->
* <c-ipa-partner-modal-view-confirmation></c-ipa-partner-modal-view-confirmation>
*
* @extends LightningElement
* @namespace ipaPartnerModalViewConfirmation
* @property {ipaPartnerOnboardingService.BoardingStep} step  used for data retrieval and unique rendering
* @property {Slot} tile slot for the tile
*/
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, api, track, wire } from "lwc"; 
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import { getSubComponentData, markAsCompleted } from "c/ipaPartnerOnboardingService";
import { MockPartnerOnboardingService } from 'c/ipaMockData'; 
import close from '@salesforce/label/c.IPA_Partner_Close';
import tier from '@salesforce/label/c.IPA_Partner_Tier';
import company from '@salesforce/label/c.IPA_Partner_Company';
import role from '@salesforce/label/c.IPA_Partner_Role';
import responsibility from '@salesforce/label/c.IPA_Partner_Responsibility';
import employee from '@salesforce/label/c.IPA_Partner_Employee';
import closeModal from '@salesforce/label/c.IPA_Partner_CloseModal';
import PRM_AcceptableDomains from "@salesforce/label/c.PRM_AcceptableDomains";
import PRM_AcceptableDomains_Info from "@salesforce/label/c.PRM_AcceptableDomains_Info";
import PRM_Edit_ButtonLabel from "@salesforce/label/c.PRM_Edit_ButtonLabel";
import PRM_ValidDomain_Msg from "@salesforce/label/c.PRM_ValidDomain_Msg";
import PRM_BlacklistedDomain_Msg from "@salesforce/label/c.PRM_BlacklistedDomain_Msg";
import PRM_Remove_ButtonLabel from "@salesforce/label/c.PRM_Remove_ButtonLabel";
import PRM_AcceptableDomain_MaxLimit from "@salesforce/label/c.PRM_AcceptableDomain_MaxLimit";
import PRM_Cancel_ButtonLabel from "@salesforce/label/c.PRM_Cancel_ButtonLabel";
import PRM_Save_ButtonLabel from "@salesforce/label/c.PRM_Save_ButtonLabel";
import PRM_Add_ButtonLabel from "@salesforce/label/c.PRM_Add_ButtonLabel";
import PRM_AcceptableDomains_HelpText from "@salesforce/label/c.PRM_AcceptableDomains_HelpText";
import PRM_AcceptableDomains_Caution from "@salesforce/label/c.PRM_AcceptableDomains_Caution";
import PRM_DomainBlank_Msg from "@salesforce/label/c.PRM_DomainBlank_Msg";
import PRM_MaxDomains_Msg from "@salesforce/label/c.PRM_MaxDomains_Msg";
import getCompanyAndRoleInfo from "@salesforce/apex/PRM_CompanyProfileController.getCompanyAndRoleInfo";
import saveWhitelistedDomains from "@salesforce/apex/PRM_CompanyProfileController.saveWhitelistedDomains";
import PRM_Onboarding_ManageAcceptableDomain from "@salesforce/label/c.PRM_Onboarding_ManageAcceptableDomain_Label";
import PRM_Onboarding_ManageAcceptableDomain_Txt from "@salesforce/label/c.PRM_Onboarding_AcceptableDomain";

export default class IpaPartnerModalViewConfirmation extends LightningElement {

// ******* API variables - defined in class properties *******
    @api set step(step) {
        this._step = step;
        this.stepId = step.stepId;
        this.componentData = step.componentData;
        this.modalTitle = step.modalTitle;
    }

    get step(){
        return this._step;
    }

// ******* Track variables ********
    isLoading;
    result;
    content;
    footerLinkData;
    imageUrl;

    // grouping confirmation data
    @track groupCards = [];

    // tier confirmation data
    @track tierTableData = [];


    // responsibilities-confirmation
    @track responsibilitiesTableData = [];
    
    // acceptable domain track variable 
    isPrimary = false;
    isDomainChange = false;
    isDuplicate = false;
    isBlacklistDomain = false;
    accountId;
    @track responces = [];
    @track lastMap = new Map();
    @track cancelResponce = [];   
    countRecord = 0;

    @track label = {
    close,
    tier,
    company,
    role,
    responsibility,
    employee,
    closeModal,
    PRM_AcceptableDomains,	
    PRM_Edit_ButtonLabel,
    PRM_AcceptableDomains_Info,
    PRM_AcceptableDomains_Caution,
    PRM_ValidDomain_Msg,
    PRM_BlacklistedDomain_Msg,
    PRM_Remove_ButtonLabel,
    PRM_AcceptableDomain_MaxLimit,
    PRM_Cancel_ButtonLabel,
    PRM_Save_ButtonLabel,
    PRM_Add_ButtonLabel,
    PRM_AcceptableDomains_HelpText,
    PRM_DomainBlank_Msg,
    PRM_MaxDomains_Msg,
    PRM_Onboarding_ManageAcceptableDomain,
    PRM_Onboarding_ManageAcceptableDomain_Txt

    };

// ******* Private variables ********
    _step;
    stepId;
    componentData;
    modalTitle;
    cardStyle = 'Icon Body';
    closeModalAndRedrirectLinkData;
    disableSaveButton = false;
    wiredResult;
// ******* Functions ********
    connectedCallback() {
        if (!this.step.completed) {
            this.fetchData();
        }
        this.addEventListener('keyup', this.handleKeyPress.bind(this));
    }
    disconnectedCallback() {
        this.removeEventListener('keyup', this.handleKeyPress.bind(this));
    }
    handleKeyPress({code}) {
        if ('Escape' === code) {
            this.template.querySelector('c-core-intc-modal').closeModal();
        }
    }
/**
 * 
 * @param {object} value 
 */
// To fetch the domain list from apex
@wire(getCompanyAndRoleInfo)
companyProfileInfo(value) {
    this.wiredResult = value;
    const { data, error } = value;
    if (data) {
        var jsonString = JSON.parse(data).CompanyInfo;
        this.responces = jsonString.WhitelistedDomains;
        this.isPrimary = jsonString.isPrimary;
        this.blacklistDomain = jsonString.BlacklistDomains;
        this.cancelResponce = [...this.responces];
        this.accountId = jsonString.AccountId;            
    }
    if (error) {
        console.log("error", error);
    }
}  

/**
 * 
 * @param {boolean} event domain change event
 */
// call on change of input text of domain
handleAcceptDomainChange(event) {
    this.isDomainChange = true;
}
/**
 * 
 * @param event domain check event
 */
// call on blur of input text of domain
handleAcceptDomainBlur(event) {
    let inputDomain = event.target.value;
    let flag = true;
    if (this.isDomainChange) {
        this.isDomainChange = false;
        let isValid = true;
        if (!this.CheckIsValidDomain(inputDomain)) {
            isValid = false;
            this.showToastValidDomain();                
        }
        // To check weather domain is blacklisted or not
        else if (this.blacklistDomain.includes(inputDomain)) {
            this.isDuplicate = false;
            this.isBlacklistDomain = true;
            this.showToastBlackListDomain();
        } else {
            this.isBlacklistDomain = false;
        }

        if (inputDomain !== "") {
            for (let v of this.responces) {
                if (v.WhiteListName === inputDomain) {
                    flag = false;
                    break;
                }
            }
            // To check duplicacy
            if (flag) {
                this.isDuplicate = false;
                this.responces[event.target.name] = {
                    RecordId: event.target.title,
                    WhiteListName: event.target.value
                };
            } else {
                this.isDuplicate = true;
                event.target.label = "Duplicate Value";
            }
        } else {
            this.isDuplicate = false;
            this.responces[event.target.name] = {
                RecordId: event.target.title,
                WhiteListName: event.target.value
            };
        }
    }
}
/**
 * 
 * @param {object} event remove domain event 
 */
// Remove the whitelist domain
removeDomain(event) {
    let temp = this.template;
    this.responces.splice(event.target.name, 1);
    this.disableSaveButton = false;
}
/**
 * 
 * @param {object} event add domain event 
 */
// Adding domain in text field
addDomainTextField(event) {
    this.disableSaveButton = false;
    if (this.responces.length === 0) {
        this.responces.push({
            RecordId: "new" + this.countRecord,
            WhiteListName: ""
        });
        this.countRecord++;
    } else if (this.responces.length > 0) {			
            if (this.responces.length < PRM_AcceptableDomain_MaxLimit) {
                //change 10 to custom label
                this.responces.push({
                    RecordId: "new" + this.countRecord,
                    WhiteListName: ""
                });
                this.countRecord++;
            } else {
                this.showToastMoreDomain();
            }
    }
}
/**
 * 
 * @param {object} domain 
 * @returns {boolean} The value of domain entered is valid or not
 */
// Check valid domain
CheckIsValidDomain(domain) {
    let vsplit = domain.split(".");
    let isValid = true;
    if (domain.length > 80) {
        isValid = false;
    } else if (vsplit.length <= 1) {
        isValid = false;
    }else if(domain.length>1 && (domain.includes("@") || domain.includes(" ") || domain.includes("	"))){
        isValid = false;
    }
        else if (vsplit.length >1){
        vsplit.forEach(function(element) {
            if(element.length<1){
                isValid = false;
                return isValid;
            }
        });
    }
    return isValid;
}

// To save the acceptable domain
saveAcceptableDomain() {
    if (this.responces.length > 0) {
        this.lastMap.clear();
        for (let i = 0; i < this.responces.length; i++) {
            this.lastMap.set(this.responces[i].RecordId, this.responces[i].WhiteListName);
        }
    } else {
        this.lastMap.clear();
    }

    let temp = this.template;
    let isPassRegex = true;
    let isBlankValue = false;
    for (let val of this.responces) {
        if (val.WhiteListName.length == 0) {
            
            isBlankValue = true;
            break;
        }

        if (this.blacklistDomain.includes(val.WhiteListName)) {
            this.isBlacklistDomain = true;
            break;
        }
    
        if(!this.CheckIsValidDomain(val.WhiteListName)){
            isPassRegex=false;
            break;
        }	
    }
    
    if (isBlankValue && this.isDuplicate) {
        isBlankValue = false;
    }

    if (isBlankValue) {
        this.showToastBlankDomain();
    } 
    if (!isBlankValue && !this.isDuplicate && !this.isBlacklistDomain && isPassRegex) {
        this.isLoading = true;
        saveWhitelistedDomains({
            AcctId: this.accountId,
            whitelistedDomain: [...this.lastMap] //converting map to List<List<String>> and passing it to apex
        })
            .then((result) => {    
                this.disableSaveButton = true;
                this.closeAcceptableDomain();
                this.isLoading = false;
                refreshApex(this.wiredResult);
            })
            .catch((error) => {
                this.disableSaveButton = false;
                this.isLoading = false;
                const event = new ShowToastEvent({
                    message: JSON.stringify(error),
                    variant: "error",
                    mode: "dismissable"
                });
                this.dispatchEvent(event);
                console.log("THis is the error: " + JSON.stringify(error));
            });		
    } 
}

// After clicking close button
closeAcceptableDomain() {
    this.responces.splice(0, this.responces.length);
    this.responces = [...this.cancelResponce];
    this.lastMap.clear();
}
// When user tries to save domain with no value
showToastBlankDomain() {
    const event = new ShowToastEvent({
        message: this.label.PRM_DomainBlank_Msg,
        variant: "error",
        mode: "dismissable"
    });
    this.dispatchEvent(event);
}
// Max domain limit
showToastMoreDomain() {
    const event = new ShowToastEvent({
        message: this.label.PRM_MaxDomains_Msg,
        variant: "warning",
        mode: "dismissable"
    });
    this.dispatchEvent(event);
}
// Invalid domain
showToastValidDomain() {
    const event = new ShowToastEvent({
        message: this.label.PRM_ValidDomain_Msg,
        variant: "error",
        mode: "dismissable"
    });
    this.dispatchEvent(event);
}
// Blacklisted domain
showToastBlackListDomain() {
    const event = new ShowToastEvent({
        message: this.label.PRM_BlacklistedDomain_Msg,
        variant: "error",
        mode: "dismissable"
    });
    this.dispatchEvent(event);
}
    openModal(e){
        e.preventDefault();
        if (this.step.completed && !this.result) {
            this.fetchData();
        }
        this.template.querySelector('c-core-intc-modal').openModal();
    }
    closeButton() {
        this.template.querySelector('c-core-intc-modal').closeModal();
    }
    closeModal(e){
        if (this.step.completed) {
            if (this.closeModalAndRedrirectLinkData && this.closeModalAndRedrirectLinkData.externalUrl){
                window.location.href = this.closeModalAndRedrirectLinkData.externalUrl;
            }
        } else {
            this.markAsCompleted();
        }

        // Call mark as complete service here
        e.preventDefault();
    }

    async fetchData() {
        let result;
        try {
            if (USE_MOCK) {
                result = await MockPartnerOnboardingService.getSubComponentData(this.componentData);
            } else {
                result = await getSubComponentData(this.componentData);
            }
        } catch(e) {
            console.error('getSubComponentData error', `${e}`, this.componentData);
        }
        if (result)  {
            this.result  = result;
            this.content = ( this.componentData !== 'acceptable-domains') ? result.content.map((item, contentIndex) => ({
                    ...item,
                    id: 'content-' + contentIndex,
                    isLinks:  (item.type === 'links'),
                    isText:  (item.type === 'text'),
                    isRichText:  (item.type === 'richtext'),
                    body: (item.type === 'links') ? this.addIds(item.body, 'link-' + contentIndex) : item.body
            })) : [];

            this.footerLinkData = result.footerLinkData;

            if (result.imageUrl) {
                this.imageUrl = result.imageUrl;
            }

            // Preprocessing grouping confirmation
            if (this.componentData === 'grouping-confirmation') {
                let prevGroup = {
                    id: 'prev-group',
                    title: this.result.previousGroup.title,
                    cards: this.result.previousGroup.cards.map((item,cardIndex) => {
                        return {
                            ...item,
                            icon: true,
                            iconClass: 'fa-intel-user-o',
                            id: 'prev-card-' + cardIndex,
                            members:  this.addIds(item.members, 'pmem' + cardIndex)
                        }
                    })
                };
                let nextGroup = {
                    id: 'next-group',
                    title: this.result.newGroup.title,
                    cards: this.result.newGroup.cards.map((item,cardIndex) => {
                        return {
                            ...item,
                            icon: true,
                            iconClass: 'fa-intel-user-o',
                            id: 'next-card-' + cardIndex,
                            members:  this.addIds(item.members, 'pmem' + cardIndex)
                        }
                    })
                };

                this.groupCards = [prevGroup, nextGroup];
            }
            if (this.componentData === 'tier-confirmation') {
                this.tierTableData = this.result.tableData.map((item,index) => ({
                        ...item,
                        id: 'tier-' + index,
                        hasIcon: item.icon !== ''
                    }
                ));
            } else if (this.componentData === 'responsibilities-confirmation') {
                this.responsibilitiesTableData = this.result.tableData.map((item,index) => ({
                        ...item,
                        id: 'resposibilities-' + index
                    }
                ));
            }

            this.closeModalAndRedrirectLinkData = result.closeModalAndRedrirectLinkData;


            if (this.closeModalAndRedrirectLinkData && this.closeModalAndRedrirectLinkData.label) {
                this.label.close = this.closeModalAndRedrirectLinkData.label;
            }

        }
        this.isLoading = false;
    }

    async markAsCompleted() {
        // On close
        this.isLoading = true;
        // Submitting step loading
        try {
            if (USE_MOCK) {
                await MockPartnerOnboardingService.markAsCompleted(this.stepId, true);
            } else {
                await markAsCompleted(this.stepId, true)
            }
            this.dispatchEvent(new CustomEvent('markstepcomplete', { detail: {stepId:this.stepId}}));

            this.template.querySelector('c-core-intc-modal').closeModal();

            if (this.closeModalAndRedrirectLinkData && this.closeModalAndRedrirectLinkData.externalUrl){
                window.location.href = this.closeModalAndRedrirectLinkData.externalUrl;
            }

        } catch(e) {
            console.error('markAsCompleted error', `${e}`,this.stepId, this.fieldSubmit);
        }

        this.isLoading = false;
    }
    addIds(arr, prefix){
        if (arr && arr.length > 0) {
            return arr.map((item,index) => ({
                ...item,
                id: prefix + '-' + index
            }));
        }
        return arr;
    }

    get ifs() {
        return {
            isGroupingConfirmation: (this.componentData === 'grouping-confirmation') && this.groupCards,
            isTierConfirmation:  (this.componentData === 'tier-confirmation'),
            isResponsibilitiesConfirmation:  (this.componentData === 'responsibilities-confirmation'),
            isFooterLinkValid: this.footerLinkData && this.isLinkDataComplete(this.footerLinkData) && ( this.componentData !== 'acceptable-domains'),
            hasImageUrl: this.imageUrl,
            showModal: !this.step.completed || this.step.isLast,
            acceptabledomainTemplate: ( this.componentData === 'acceptable-domains')
        }
    }

    isLinkDataComplete(linkData) {
        return linkData.label && (linkData.communityPage || linkData.externalUrl)
}


/**
 * Creates a data object based on the coreIntcSimpleCard link properties and sends that
 * to the analytics library to be logged.
 *
 * @param {object} linkClickEvent  The corelinkclick event thrown by the coreIntcLink in coreIntcSimpleCard.
 * @private
 */
    handleLinkClick(linkClickEvent) {
    // Create the parameters for the analytics post
    const messageData = {
    analyticsType: 'click',
    element: '',
    pageTitle: linkClickEvent.detail.label || '',
    targetURL: linkClickEvent.detail.href || '',
    };

    // The event should not be needed above this in the hierarchy
    linkClickEvent.stopPropagation();

    // Call the helper library to log the analytics data
    makeIpaAnalyticsCall(messageData);
}
}

// ********* Type Definitions ************