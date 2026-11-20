/**
 * The ipaPartnerModalCommunities component
 * <p>Ipa Partner Modal Communities gets the BoardingSubcomponent Object {@link ipaPartnerOnboardingService.BoardingSubcomponent} from the {@link ipaPartnerOnboardingService.getSubComponentData} service based on the step.componentData value.</p>
 * <p>This component handles the community selection and enables the user to submit the selection to the  {@link ipaPartnerOnboardingService.submitCommunitySelection} service.</p>
 * <p>A sample of the modal rendering can be seen in https://d.pr/i/nmAGt4</p>

 * @example
 * <!-- HTML component example -->
 * <c-ipa-partner-modal-terms-and-conditions></c-ipa-partner-modal-terms-and-conditions>
 *
 * @extends LightningElement
 * @namespace ipaPartnerModalCommunities
 * @property {ipaPartnerOnboardingService.BoardingStep} step  used for data retrieval and unique rendering
 * @property {Slot} tile slot for the tile, usually an ipaPartnerWelcomeTile
 */
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, api, track } from 'lwc';

import { getSubComponentData, submitCommunitySelection } from "c/ipaPartnerOnboardingService";
import { MockPartnerOnboardingService } from 'c/ipaMockData';

import submit from '@salesforce/label/c.IPA_Partner_Submit';
import skip from '@salesforce/label/c.IPA_Partner_Skip';
import cancel from '@salesforce/label/c.IPA_Partner_Cancel';
import closeModal from '@salesforce/label/c.IPA_Partner_CloseModal';
import close from '@salesforce/label/c.IPA_Partner_Close';


export default class IpaPartnerModalCommunities extends LightningElement {

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
    @track footerLinkData;
    @track imageUrl;
    @track fields;
    @track formChanged = false;
    @track sourceLabel;
    @track selectedLabel;
    @track currentSelectedOptions;
    @track label = {
        submit,
        skip,
        cancel,
        closeModal,
        close
    }
    @track communityOptions;
    @track selectedOptions;
    @track requiredOptions;
    @track submitFormAndRedirectLinkData;
    @track closeModalAndRedrirectLinkData;
    @track isNonPrimary = false;
    // ******* Private variables ********
    _step;
    stepId;
    componentData;
    modalTitle;
    _originalSelected;


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


    handleChange(event) {
        // Get the list of the "value" attribute on all the selected options
        const selectedOptionsList = event.detail.value;
        // console.log(`Options selected: ${selectedOptionsList}`);
        this.currentSelectedOptions = selectedOptionsList;
        this.formChanged = this._originalSelected.toString() !== selectedOptionsList.slice().sort().toString();
        // console.log('arraychanged', this._originalSelected.toString(), 'selected',selectedOptionsList.slice().sort().toString(), this.formChanged)
        // check if it changed from the original
    }

    closeModal(){
        this.template.querySelector('c-core-intc-modal').closeModal();
    }

    handleButtonStep(e) {
        let type = e.currentTarget.dataset.type;
        if (type === 'cancel') {
            // close modal without submitting or skipping form
        } else if ((type === 'skip') ||  (type === 'submit'))  {
            // submit the form to mark it as complete
            // possible redirect afterwards
            this.submitAndMarkComplete();
        }

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
            // console.log("getSubComponentData", this.componentData, JSON.parse(JSON.stringify(result)));

            this.content = result.content.map((item, contentIndex) => ({
                    ...item,
                    id: 'content-' + contentIndex,
                    isLinks:  (item.type === 'links'),
                    isText:  (item.type === 'text'),
                    isRichText:  (item.type === 'richtext'),
                    body: (item.type === 'links') ? this.addIds(item.body, 'link-' + contentIndex) : item.body
            }));

            this.communityOptions = result.community.communityOptions;
            this.selectedOptions = result.community.selectedOptions || [];
            this.requiredOptions = result.community.requiredOptions || [];
            this.footerLinkData = result.community.footerLinkData;
            this.sourceLabel = result.community.sourceLabel;
            this.selectedLabel = result.community.selectedLabel;

            this._originalSelected = Array.from(new Set([...this.selectedOptions,...this.requiredOptions])).sort();

            this.submitFormAndRedirectLinkData = result.submitFormAndRedirectLinkData;
            this.closeModalAndRedrirectLinkData = result.closeModalAndRedrirectLinkData;

            // remove the label for non primary
            if (result.submitFormAndRedirectLinkData && result.submitFormAndRedirectLinkData.label) {
                this.label.submit = result.submitFormAndRedirectLinkData.label;
                this.isNonPrimary = true;

            }
            if (result.closeModalAndRedrirectLinkData && result.closeModalAndRedrirectLinkData.label) {
                this.label.skip = result.closeModalAndRedrirectLinkData.label;
            }

            if (result.imageUrl) {
                this.imageUrl = result.imageUrl;
            }
            // fields
        }
        this.isLoading = false;
    }

    async submitAndMarkComplete() {
        // on close
        this.isLoading = true;

        try {
            if (USE_MOCK) {
                await MockPartnerOnboardingService.submitCommunitySelection(this.stepId, this.currentSelectedOptions);
            } else {
                await submitCommunitySelection(this.stepId, this.currentSelectedOptions);
            }
            this.dispatchEvent(new CustomEvent('markstepcomplete', { detail: {stepId:this.stepId}}));

            if (this.submitFormAndRedirectLinkData && this.submitFormAndRedirectLinkData.externalUrl){
                // console.log('redirect current',  this.submitFormAndRedirectLinkData.externalUrl);
                window.location.href = this.submitFormAndRedirectLinkData.externalUrl;
            }
        } catch(e) {
            console.error('submitCommunitySelection error', `${e}`,this.stepId, this.currentSelectedOptions);
        }

        this.isLoading = false;
        this.template.querySelector('c-core-intc-modal').closeModal();
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