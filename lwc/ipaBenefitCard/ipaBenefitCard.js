/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for ipaBenefitCardList  Component
 * <br>
 * <p>Ipa Benefit Card gets the object {@link ipaBenefitService.Benefit } and renders the related data from it.</p>
 * <p> Rendering rule for the metrics is as follows:</p>

 * @namespace ipaBenefitCard
 * @property {ipaBenefitService.Benefit} benefit the Benefit object used for the component rendering
 *
 * @author Joshua Gonzalez
*/

import { LightningElement, api , track} from 'lwc';
import sendEmail from '@salesforce/label/c.IPA_Benefits_SendEmail';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';
import IPA_DZS_RDC_Benefit from '@salesforce/label/c.IPA_DZS_RDC_Title';

export default class ipaBenefitCard extends LightningElement {

    isIPA_DZS_RDC_Benefit = false;
    
    @api set benefit(benefit) {
        this._benefit = benefit;
        // separate out the logic
        this.title = this._benefit.title;
        this.description = this._benefit.description;
        this.faIcon = this._benefit.faIcon;
        this.alerts = this.addIds(this._benefit.alerts, 'alerts');
        this.adhocAlerts = this.addIds(this._benefit.adhocAlerts, 'adhocAlerts');
        this.metrics = this.addIds(this._benefit.metrics, 'metric', {isEmpty: false});
        this.links = this.addIds(this._benefit.links, 'benefit-link');
        // check if contacts exist otherwise make this false/null
        this.contacts = this._benefit.contacts;
        console.log('adhocmessage'+JSON.stringify(this.adhocAlerts));
        //check if benefit is Resource & Documentation Center to add custom link
        if(this.title == IPA_DZS_RDC_Benefit){
            this.isIPA_DZS_RDC_Benefit = true;
        }
        // check if shared link on metric then add a cta button else make cta button empty
        // if there is only 1 metric dont even combine it
        if (this.metrics && this.metrics.length > 0) {
            let tempCombinedCta = null;
            let tempCombinedFooter = [];
            let invalidMetrics = 0; //Utkarsh - 904 - Made changes to render matrics dyanamically.

            this.metrics.forEach((metric) => {
                if (tempCombinedCta == null) {
                    tempCombinedCta = metric.link;
                } else if (JSON.stringify(metric.link) !== JSON.stringify(tempCombinedCta)){
                    tempCombinedCta = false;
                } else {
                    // still a match
                }
                if (metric.description) {
                    tempCombinedFooter.push(metric.description);
                }
                // check if metric is empty
                if (!metric.value && !metric.unit && !metric.label) {
                    metric.isEmpty = true;
                    invalidMetrics++;
                }
            });
            if (tempCombinedCta){
                // combine the button as well as the footer
                this.combinedFooter = tempCombinedFooter;
                this.ctaButton = tempCombinedCta;
            }

            if (this.metrics.length == invalidMetrics) { //Utkarsh - 904 - Made changes to render matrics dyanamically.
                this.metrics = [];
            }
            
        }
    }

    @track _benefit;
    @track title = '';
    @track faIcon = '';
    @track description = '';
    @track alerts = [];
    @api adhocAlerts = [];
    @track metrics = [];
    @track links = [];
    @track contacts = {};
    // only true if all the metrics are sharing 1 link
    @track ctaButton = null;
    @track combinedFooter = null;
    @track msgUniqueId;
    @track activeSections ;
    
    cardStyle = 'Icon Body';
    label = {
        sendEmail
    };

    get contactList() {
        let tempContacts = [];

        if (this.contacts && this.contacts.contacts){
            tempContacts =  this.contacts.contacts.map((contact,index) => {
                return {
                    ...contact,
                    id: 'contact-' + index,
                    title: contact.name,
                    bodyTitle: contact.title,
                    icon: (contact.faIcon && contact.faIcon !== ''),
                    iconClass: contact.faIcon,
                    imageUrl: contact.iconUrl,
                    emailHref: 'mailto:' + contact.email
                }
            })
        }
       return tempContacts;
    }

    get benefit() {
        return this._benefit;
    }

    get classes() {
        return {
            containerClass: `ipabenefit-card-container  slds-p-vertical_large ${this.ifs.hasAlerts ? "has-alerts" : ""}${this.ifs.hasAdhocAlerts ? "has-adhocalerts" : ""}`,
            adhocContainerClass: "ipabenefit-card-container  slds-p-vertical_large " + (this.ifs.hasAdhocAlerts ? "has-adhocalerts" : "" ),
            metricClass: this.singleCtaButton ? "combined-metric" : "separated-metrics",
            iconClass: (this.faIcon ? this.faIcon : "") + " icon slds-m-right_medium",
            attentionClass: "fa-attention-1 icon alert-icon"
        };
    }

    get ifs() {
        return {
            hasAlerts: this.alerts && this.alerts.length > 0,
            hasAdhocAlerts: this.adhocAlerts && this.adhocAlerts.length > 0,
            hasMultipleMetrics: this.metrics && this.metrics.length > 1,
            hasContacts: this.contacts && Object.keys(this.contacts).length > 1,
            singleCtaButton: this.ctaButton != null,
            hasCombinedFooter: this.combinedFooter &&  this.combinedFooter.length > 0,
        }
    }

    addIds(arr, prefix, extraProps){
        if (arr && arr.length > 0) {
            return arr.map((item,index) => ({
                ...item,
                ...extraProps,
                id: prefix + '-' + index
            }));
        }
        return arr;
    }

    get isMetricsEmpty() { //Utkarsh - 904 - Made changes to render matrics dyanamically.
        return Array.isArray(this.metrics) && this.metrics.length === 0;
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
    
    handleSectionToggle(event){
        this.msgUniqueId = event.detail.openSections;
        
    }
}