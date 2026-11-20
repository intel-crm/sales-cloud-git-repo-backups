import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// Page Reference Types
// https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.reference_page_reference_type

export default class PsMpLink extends NavigationMixin(LightningElement) {

    // Public Attributes / Properties
    @api className = '';
    @api label = '';
    @api newWindow; // Opens url in new window/tab.
    @api truncate = 0; // Truncates to a certain character limit and adds elipsis
    @api inverse; // Optional way to use inverse styling
    @api preview; // Disables link
    @api hideIcon;

    // Navigation Types - one of these values muste exist or an error will be thrown
    // External URL - Use to navigate to a normal url outside of the community pages.
    @api externalUrl; 
    // Community Page - The name of the community page. ie. 'home'
    @api communityPage = '';
    // Object Page - also if recordId is set, this value is required
    @api objectPage = ''; 
    // Record Page - record detail page - objectPage must also be given
    @api recordId = '';
    // Custom Page Reference - direct page reference can also be used (See Reference Types Above)
    @api pageReference = null;
    
    
    @api params = {}; // Can be used for any community page. Use searchParams for L2 Search.

    // TODO Refactor search params
    @api searchParams = {}; // Specific to the L2 Intel Search. See documentation.

    @track href = '';
    @track truncatedString = '';
    @track hasSlotContent;

    connectedCallback() {
        this.connected = true;
        this.truncateIt();
        this.generateUrl();
    }

    get aClass() {
        return [
            this.className,
            this.preview ? 'preview' : '',
            this.inverse ? 'color-white text-underline iconWhite' : ''
        ].join(' ');
    }

    get slotClass() {
        return !this.hasSlotContent && this.label ? 'slds-hide' : '';
    }

    get showNewWindowIcon() {
        return (this.externalUrl || this.newWindow) && !this.hideIcon ? true : false;
    }

    handleSlotChange(evt) {
        this.hasSlotContent = evt.target.assignedNodes().length !== 0;
    }

    get formattedPageReference() {
        if (this.pageReference) return this.pageReference;

        // Page Reference -- Community Page
        if (this.communityPage) {
            return {
                type: 'comm__namedPage',
                attributes: {
                    pageName: this.communityPage
                }
            };
        }

        // Page Reference -- Record Page
        if (this.recordId) {
            if (!this.objectPage) {
                throw new TypeError(
                    'psMpLink Error: record-id given, but missing object-page attribute.'
                    );
            }
            return {
                type: "standard__recordPage",
                attributes: {
                    recordId: this.recordId,
                    objectApiName: this.objectPage,
                    actionName: "view"
                }
            };
        }

        // Page Reference -- Object Page
        if (this.objectPage) {
            return {
                type: "standard__objectPage",
                attributes: {
                    objectApiName: this.objectPage,
                    actionName: "list"
                },
                state: {
                    filterName: "Recent"
                }
            }
        }
    
        // TODO refactor out of this component, into somewhere else
        if (this.searchParams && this.searchParams.cat) {
            return {
                type: "standard__recordPage",
                attributes: {
                    recordId: this.searchParams.cat,
                    objectApiName: 'PMP_Offering_Category__c',
                    actionName: "view"
                }
            };
        }
        
        throw new TypeError(
            `An attribute must be passed to psMpLink component for lightning page reference.
            ie. community-page, object-page... see psMpLinkcomponent for details.`);
    }

    handleClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        if (this.preview) return;
        // this.href should be a source of truth at this point
        if (this.newWindow || this.externalUrl) {
            window.open(this.href);
        } else {
            this[NavigationMixin.Navigate](this.formattedPageReference);
        }
    }

    // For truncated labels
	truncateIt() {
		let resetTruncated = this.truncatedString;
		if (this.truncate > 3 && !this.hasSlotContent && this.label && this.label.length > this.truncate - 3) {
			this.truncatedString = this.label.substring(0, this.truncate - 3).trim();
			resetTruncated = false;
		}
		if (resetTruncated) this.truncatedString = '';
    }

    generateUrl() {
        if (this.externalUrl) {
            this.href = this.externalUrl;
        } else {
            // attempt to get page reference, throws error on invalid structure
            const pageReference = this.formattedPageReference;
            this[NavigationMixin.GenerateUrl](pageReference).then(url => {

                //TODO: Deal with params / search params
                if (this.searchParams) {
                    // params = '?search=' +
                    // encodeURIComponent(JSON.stringify(this.searchParams));
                }

                // TODO: NEED FROM ISG?
                // ADDING TIMEOUT RESOLVES SALESFORCE BUG w/ NAVIGATION URL
                // Bug: When navigating back sometimes urlResponse will return
                // javascript:void(0) with same exact pageReference.
                // - fix added 6/7/2019

                this.href = url;
            });
        }
    }

}