import { LightningElement, api , track} from 'lwc';
import sendEmail from '@salesforce/label/c.PMP_Benefits_SendEmail';



export default class ipaBenefitCard_copy extends LightningElement {
    @track _benefit;
    @track title = '';
    @track faIcon = '';
    @track description = '';
    @track alerts = [];
    @track metrics = [];
    @track links = [];
    @track contacts = {};
    // only true if all the metrics are sharing 1 link
    @track ctaButton = null;
    @track combinedFooter = null;
    @track sendEmail = sendEmail;

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

    @track cardStyle = 'Icon Body';

    @api set benefit(benefit) {
        this._benefit = benefit;
        // separate out the logic
        this.title = this._benefit.title;
        this.description = this._benefit.description;
        this.faIcon = this._benefit.faIcon;
        this.alerts = this.addIds(this._benefit.alerts, 'alerts');
        this.metrics = this.addIds(this._benefit.metrics, 'metric');
        this.links = this.addIds(this._benefit.links, 'benefit-link');
        // check if contacts exist otherwise make this false/null
        this.contacts = this._benefit.contacts;

        // check if shared link on metric then add a cta button else make cta button empty
        // if there is only 1 metric dont even combine it
        if (this.metrics && this.metrics.length > 1) {
            let tempCombinedCta = null;
            let tempCombinedFooter = [];

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
            });

            if (tempCombinedCta){
                // combine the button as well as the footer
                this.combinedFooter = tempCombinedFooter;
                this.ctaButton = tempCombinedCta;
            }
        }

    }


    get benefit() {
        return this._benefit;
    }

    get classes() {
        console.log('Icon-->',(this.faIcon ? this.faIcon : "") + " icon slds-m-right_medium");
        return {
            containerClass: "ipabenefit-card-container  slds-p-vertical_large " + (this.ifs.hasAlerts ? "has-alerts" : "" ),
            metricClass: this.singleCtaButton ? "combined-metric" : "separated-metrics",
            iconClass: (this.faIcon ? this.faIcon : "") + " icon slds-m-right_medium",
            attentionClass: "fa-attention-1 icon alert-icon"
        };
        console.log(iconClass);
    }



    get ifs() {
        return {
            hasAlerts: this.alerts && this.alerts.length > 0,
            hasMultipleMetrics: this.metrics && this.metrics.length > 1,
            hasContacts: this.contacts && Object.keys(this.contacts).length > 1,
            singleCtaButton: this.ctaButton != null,
            hasCombinedFooter: this.combinedFooter &&  this.combinedFooter.length > 0,
        }
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

}