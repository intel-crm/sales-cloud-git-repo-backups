/**
 * The ipaPartnerModalTermsAndConditions component
 * <p>Ipa Partner Terms and Conditions gets the BoardingSubcomponent Object {@link ipaPartnerOnboardingService.BoardingSubcomponent} from the {@link ipaPartnerOnboardingService.getSubComponentData} service based on the step.componentData value.</p>
 * <p>This component handles the terms and condition rendering with the checkboxes the user to submit the selection to the  {@link ipaPartnerOnboardingService.submitTermsAndConditions} service.</p>
 * <p>A sample of the modal rendering can be seen in https://d.pr/i/rfB8lz</p>
 *
 * @example
 * <!-- HTML component example -->
 * <c-ipa-partner-modal-terms-and-conditions></c-ipa-partner-modal-terms-and-conditions>
 *
 * @extends LightningElement
 * @namespace ipaPartnerModalTermsAndConditions
 * @property {ipaPartnerOnboardingService.BoardingStep} step  used for data retrieval and unique rendering
 * @property {Slot} tile slot for the tile
 */

const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, api, track } from 'lwc';

import { getSubComponentData, submitTermsAndConditions } from "c/ipaPartnerOnboardingService";
import { MockPartnerOnboardingService } from 'c/ipaMockData';

import submit from '@salesforce/label/c.IPA_Partner_Submit';
import close from '@salesforce/label/c.IPA_Partner_Close';
import cancel from '@salesforce/label/c.IPA_Partner_Cancel';
import closeModal from '@salesforce/label/c.IPA_Partner_CloseModal';

export default class IpaPartnerModalTermsAndConditions extends LightningElement {

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
    @track isLoading;
    @track result;
    @track content;
    @track gdpr;
    @track footerLinkData;
    @track imageUrl;
    @track fields;
    @track formValid;
    @track checkboxValue = true;

    // ******* Private variables ********
    _step;
    stepId;
    componentData;
    modalTitle;
    requiredFields;
    fieldSubmit = {};

    label = {
        submit,
        cancel,
        close,
        closeModal
    };

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
    openModal(e){
        e.preventDefault();
        if (this.step.completed && !this.result) {
            this.fetchData();
        }
        this.template.querySelector('c-core-intc-modal').openModal();
    }
    submitForm(e) {
        e.preventDefault();
        this.submitTermsAndConditions();
    }

    closeModal(e){
        e.preventDefault();
        this.template.querySelector('c-core-intc-modal').closeModal();
    }

    async fetchData() {
         //console.log("fetch:getSubComponentData",this.componentData);
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
           // console.log("getSubComponentData", this.componentData, JSON.parse(JSON.stringify(result)));
                this.content = result.content ? result.content.map((item, contentIndex) => ({
                    ...item,
                    id: 'content-' + contentIndex,
                    isLinks:  (item.type === 'links'),
                    isText:  (item.type === 'text'),
                    isRichText:  (item.type === 'richtext'),
                    body: (item.type === 'links') ? this.addIds(item.body, 'link-' + contentIndex) : item.body
                })) : [];            

            this.gdpr = result.gdpr ? result.gdpr.map((item, contentIndex) => ({
                    ...item,
                    id: 'content-gdpr-' + contentIndex,
                    isLinks:  (item.type === 'links'),
                    isText:  (item.type === 'text'),
                    isRichText:  (item.type === 'richtext'),
                    body: (item.type === 'links') ? this.addIds(item.body, 'link-gdpr-' + contentIndex) : item.body
            })) : [];


            this.fields = result.fields;
            this.fieldSubmit = {};
            this.requiredFields = [];
            this.fields.forEach((item)=>{
                if(!item.value){
                    this.checkboxValue = false;
                }
                if (item.required){
                    this.requiredFields.push(item.name);
                }
                if (item.checked) {
                    this.fieldSubmit[item.name] = item.value;
                }
            });            
            this.footerLinkData = result.footerLinkData;
            if(this.requiredFields.length > 0 && this.requiredFields[0] == 'GDPR') {
                this.formValid = true;
            }
            if (result.imageUrl) {
                this.imageUrl = result.imageUrl;
            }
            // fields
        }
        this.isLoading = false;
    }

    async submitTermsAndConditions() {
        // on close
        this.isLoading = true;

        try {
            if (USE_MOCK) {
                await MockPartnerOnboardingService.submitTermsAndConditions(this.stepId, this.fieldSubmit);
            } else {
                await submitTermsAndConditions(this.stepId, this.fieldSubmit);
            }
            this.dispatchEvent(new CustomEvent('markstepcomplete', { detail: {stepId:this.stepId}}));

        } catch(e) {
            console.error('submitTermsAndConditions error', `${e}`,this.stepId, this.fieldSubmit);
        }

        this.isLoading = false;
        this.template.querySelector('c-core-intc-modal').closeModal();

    }

    handleAction(evt){
        // handle checkbox
        if (evt.target.checked){
            this.fieldSubmit[evt.target.name] = evt.target.value;
        } else if (this.fieldSubmit[evt.target.name] ) {
            // remove field submit value
            delete this.fieldSubmit[evt.target.name];
        }
        this.updateSubmitState();
    }

    updateSubmitState(){
        // corelate required with field submit

        this.formValid = this.requiredFields.reduce((acc,item)=> {
            return acc && typeof this.fieldSubmit[item] !== 'undefined'
        }, true);

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
            isFooterLinkValid: this.footerLinkData && this.isLinkDataComplete(this.footerLinkData),
            hasImageUrl: this.imageUrl,
            showModal: this.step && !this.step.completed
        }
    }

    isLinkDataComplete(linkData) {
        return linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
}

// ********* Type Definitions ************