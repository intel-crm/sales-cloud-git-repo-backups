import { LightningElement, track, wire } from 'lwc';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

/* Apex */
import fetchUser from '@salesforce/apex/PMP_SearchCompanyLeadGenController.fetchUser';
import getPartnerProfession from '@salesforce/apex/PMP_SearchCompanyLeadGenController.getPartnerProfession';
import getDependentMap from '@salesforce/apex/PMP_SearchCompanyLeadGenController.getDependentMap';
import submitFunction from '@salesforce/apex/PMP_SearchCompanyLeadGenController.submit';

/* replaceLabels utility function */
import { replaceLabels } from 'c/coreIntcLabels';

import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext,
} from 'lightning/messageService';
import ipaMarketplaceChannel from '@salesforce/messageChannel/ipaMarketplace__c';

/* in separate file for simpler organization b/c there are so many */
import { insertLabelValue, labels } from './labels';

/**
 * Contact Partner Forms: Ask A Question & Request a Quote
 *
 * @class IpaContactPartnerForm
 * @augments LightningElement
 */
export default class IpaContactPartnerForm extends LightningElement {
  /** form type
   *  'requestQuote', 'askQuestion'
   *
   * @type {string}
   */
  @track formType;

  /** form data
   *  (to do)
   *
   * @type {object}
   */
  @track formData;

  /** submitted status
   *
   * @type {boolean}
   */
  @track submitted;

  /** termsChecked
   *
   * @type {boolean}
   */
  @track termsChecked;

  /** ELQ OPT IN Checked
   *
   * @type {boolean}
   */
   elQOptIn;

   /** partnerShareChecked
    *
    * @type {boolean}
    */
   partnerShareChecked;

  /** form heading
   *
   * @type {string}
   */
  @track heading;

  /** user details (preloaded form state) - to do
   *
   * @type {object}
   */
  @track userDetails = {};

  /** description max length value
   *
   * @type {number}
   */
  descriptionMaxLength = 500;

  /** description value (kept track of for # chars remaining text)
   *
   * @type {string}
   */
  descriptionValue = '';

  /** show custom "Terms and Conditions" checkbox error
   *
   * @type {string}
   */
  @track showTermsCheckboxError;

  /** show custom "Partner Info Share" checkbox error
   *
   * @type {string}
   */
  showPartnersInfoShareCheckboxError;

  
  /** all custom labels (loaded from ./labels.js)
   *
   * @type {object<string, string>}
   */
  labels = labels;

  /** label for "Terms and Conditions" required checkbox
   *  custom label includes link -> injected with #replaceLabels
   *
   * @type {string}
   */
  termsLabelItems = replaceLabels(labels.termsAndConditions, {
    Core_Intc_TermsAndConditionsUrl: labels.termsAndConditionsUrl,
  });

  /** label for privacy notice copy
   *  new change added - label for terms of use copy
   *  custom label includes link -> injected with #replaceLabels
   *
   * @type {string}
   */
  privacyLabelItems = replaceLabels(labels.privacyPolicy, {
    Core_Intc_PrivacyPolicyUrl: labels.privacyPolicyUrl,
    Core_Intc_TermsAndConditionsUrl: labels.termsAndConditionsUrl,
  });

  /**
   * @typedef SubmissionStep
   * @property {string} label label for step
   * @property {boolean} checked if CHECK appears
   * @property {boolean} active if this is the active step in the process
   */

  /** submission steps for the progress component
   *
   * @type {SubmissionStep[]}
   */
  submissionSteps = [
    { label: this.labels.submitted, checked: true },
    { label: this.labels.partnerReview, active: true },
    { label: this.labels.partnerRespond },
  ]

  /** countries list - to do
   *
   * @type {object[]}
   */
  @track countries = [];

  /** parter profession list - to do
   *
   * @type {object[]}
   */
  @track partnerProfessions = [];

  /** form ready ?
   *
   * @type {boolean}
   */
  @track formReady;

  /** maps countries -> states (to do)
   *
   * @type {object}
   */
  countryMap = {};

  /** message context
   *  Form is Launched through the Lightning Message Event
   *
   * @type {string}
   */
  @wire(MessageContext)
  messageContext;

  /**
   * is form read only
   *
   * @returns {boolean} read only value
   */
  get readOnly() {
    return !!this.userDetails.firstName;
  }

  /** handles terms change
   *
   * @param {event} evt checkbox change
   */
  handleTermsChange(evt) {
    this.termsChecked = evt.target.checked;
    this.showTermsCheckboxError = !this.termsChecked;
  }


  /** handles ELQ Opt In change
   *
   * @param {event} evt checkbox change
   */
  handleElqOptInChange(evt) {
    this.elQOptIn = evt.target.checked;
  }

  /** handles Partner Info Share In change
   *
   * @param {event} evt checkbox change
   */
  handlePartnersShareChange(evt) {
    this.partnerShareChecked = evt.target.checked;
    this.showPartnersInfoShareCheckboxError = !this.partnerShareChecked;
  }



  /**
   * minimum delivery date is today
   *
   * @returns {string} formatted date
   */
  get deliveryDateMin() {
    const d = new Date();
    return `${d.getFullYear()}-${(d.getMonth() + 1)}-${d.getDate()}`;
  }

  /**
   * states list is based off the country map and current country
   *
   * @returns {object[]} countries
   */
  get states() {
    return (this.countryMap[this.userDetails.country] || {}).children || [];
  }

  /** disabled if no states exist for selected country
   *
   * @returns {boolean} disabled condition of "state" dropdown
   */
  get statesDisabled() {
    return this.states.length === 0;
  }

  /** required if states exist in dropdown
   *
   * @returns {boolean} required condition of "state" dropdown
   */
  get statesRequired() {
    return this.states.length > 0;
  }

  /** chars left in textarea
   *
   * @returns {string} message for text area
   */
  get descriptionCharsRemaining() {
    return insertLabelValue(
      labels.charLimits.description,
      this.descriptionMaxLength - this.descriptionValue.length,
    );
  }

  /**
   * subscribes to message channel
   * Encapsulate logic for Lightning message service subscribe and unsubsubscribe
   */
  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        ipaMarketplaceChannel,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE },
      );
    }
  }

  /**
   * unsubscribes to message channel
   */
  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  /**
   * handle message received from message channel
   * window.contactPartnerModalIsOpen prevents multiple forms opening if
   * component exists in multiple places on page (ie. promocardlist component added twice)
   *
   * @param {object} message incoming message
   */
  handleMessage(message) {
    this.formType = message.payload.modalType;
    this.formData = { ...message.payload.modalData };
    this.isRequestQuote = this.formType === 'requestQuote';
    this.isAskQuestion = this.formType === 'askQuestion';
    if (this.isRequestQuote) {
      this.heading = this.labels.requestQuote.heading;
    }
    if (this.isAskQuestion) {
      this.heading = this.labels.askQuestion.heading;
    }
    this.prepare();
  }

  /**
   * handle modal close
   */
  handleClose() {
    this.formType = '';
    this.descriptionValue = '';
    window.contactPartnerModalIsOpen = false;
    if (!this.submitted) {
      this.analytics('cancel');
    }
  }

  /**
   * connected callback
   */
  connectedCallback() {
    if (!window.contactPartnerModalConnected) {
      this._connected = true;
      window.contactPartnerModalConnected = true;
      this.subscribeToMessageChannel();
    }
  }

  /**
   * disconnected callback
   */
  disconnectedCallback() {
    if (this._connected) {
      this._connected = false;
      window.contactPartnerModalConnected = false;
    }
    this.unsubscribeToMessageChannel();
  }

  /**
   * prepares form (reset, get user details, job functions, countries)
   */
  prepare() {
    this.submitted = false;
    this.showTermsCheckboxError = false;
    this.showPartnersInfoShareCheckboxError = false;
    this.termsChecked = false;
    this.elQOptIn = false;
    this.partnerShareChecked = false;
    const preparationPromises = [];
    // if user is logged in fetch user details
    if (this.formData.isLoggedIn) {
      preparationPromises.push(fetchUser().then((response) => {
        this.userDetails = { ...this.userDetails, ...response };
      }));
    } else if (!this.formData.isLoggedIn) {
      preparationPromises.push(fetchUser().then((response) => {
        this.userDetails = { ...this.userDetails, ...response };
      }));
    }
    if (!this.partnerProfessions.length) {
      preparationPromises.push(getPartnerProfession().then((response) => {
        this.partnerProfessions = [{ label: this.labels.chooseOne, value: '' }].concat(response);
      }));
    }
    if (!this.countries.length) {
      preparationPromises.push(getDependentMap().then((response) => {
        this.countries = response || [];
        this.countries.forEach((c) => { this.countryMap[c.value] = c; });
      }));
    }
    Promise.all(preparationPromises).then(() => {
      this.formReady = true;
    });
  }

  /** handles country change, refreshes list of states based on country selection
   *
   * @param {event} evt country dropdown change
   */
  handleCountryChange(evt) {
    // refresh w/ new list of states
    this.userDetails = { ...this.userDetails, country: evt.target.value };
  }

  /** change handler
   * performs custom validation to flag HTML tags
   *
   * @param {event} evt change event
   */
  handleCustomValidation(evt) {
    const { value } = evt.detail || '';
    const { name } = evt.currentTarget;
    // for character remaining # count
    if (name === 'description') {
      this.descriptionValue = value;
    }
    let customValidity = '';
    // Regex Pattern Matchers for Custom Validations
    const tagMatcher = /<("[^"]*"|'[^']*'|[^'">])*>/;
    const easyUrlMatcher = /(http:\/|ftp:\/|https:\/|\w+\.\w+\.\w+)+/;
    // eslint-disable-next-line max-len
    const emailMatcher = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if (['description'].includes(name) && value && value.match(tagMatcher)) {
      customValidity = this.labels.errors.noHTML;
    }
    if (['firstName', 'lastName', 'companyName'].includes(name) && value
      && (value.match(tagMatcher) || value.match(easyUrlMatcher))) {
      customValidity = this.labels.errors.noURL;
    }
    if (name === 'email' && value && !value.match(emailMatcher)) {
      customValidity = this.labels.errors.emailCheck;
    }
    evt.target.setCustomValidity(customValidity);
  }

  /**
   * handle cancel button click
   */
  handleCancel() {
    this.template.querySelector('c-core-intc-modal').closeModal();
  }

  /**
   * handle submit button
   */
  handleSubmit() {
    const isFormValid = this.checkFormValidity(true) && this.termsChecked && this.partnerShareChecked;
    if (isFormValid) {
      this.submit();
    } else {
      if (this.checkFormValidity(true) && !this.termsChecked) {
        this.showTermsCheckboxError = true;
        this.template.querySelector('[data-id="terms-checkbox"]').focus();
      }
      if (this.checkFormValidity(true) && !this.partnerShareChecked) {
        this.showPartnersInfoShareCheckboxError = true;
        this.template.querySelector('[data-id="partners-checkbox"]').focus();
      }
    }
  }

  /**
   * checks (and reports) input validity
   *
   * @param {boolean} report reports validity if true
   * @returns {boolean} validity of entire form
   */
  checkFormValidity(report = false) {
    const inputs = this.template.querySelectorAll(
      'lightning-input, lightning-textarea, c-core-intc-select',
    );
    let stillValid = true;
    inputs.forEach((input) => {
      if (report ? !input.reportValidity() : !input.checkValidity()) {
        if (report && stillValid) {
          input.scrollIntoView({ behavior: 'smooth' });
          input.focus();
        }
        stillValid = false;
      }
    });
    return stillValid;
  }

  /**
   * format form data and submit to backend
   */
  submit() {
    const form = new FormData(this.template.querySelector('form'));
    const params = [...form.entries()].reduce((data, entry) => ({
      ...data,
      [entry[0]]: entry[1],
    }), {});
    delete params.terms; // do not pass this value in params
    params.sessionId = this.sessionId();
    const formDataParams = {
      user: { ...this.userDetails, ...params }, // use existing user details if readonly
      offeringId: this.formData.oid,
      offeringName: this.formData.title,
      offeringRecId: this.formData.offRecId,
      partnerId: this.formData.autoPartnerId,
      partnerName: this.formData.name,
      optinConsent: this.elQOptIn,
    };
    if (this.isRequestQuote) {
      formDataParams.formType = 'quote';
    }
    if (this.isAskQuestion) {
      formDataParams.formType = 'contact';
    }
    // comments here are for backend QA / integration
    // eslint-disable-next-line no-console
    // console.log('Form Data:', formDataParams);
    submitFunction(formDataParams).then((response) => {
      // eslint-disable-next-line no-console
      console.log('RESPONSE', response);
      // eslint-disable-next-line no-console
    }).catch((err) => console.error(err));
    this.analytics('submit');
    this.submitted = true;
    this.heading = this.labels.inquiryProgress;
  }

  /**
   * get session id from window
   *
   * @returns {string} sessionId
   */
  sessionId() {
    const utag = window.focus('utag');
    return utag && utag.data ? utag.data.wa_amc_id : '';
  }

  /**
   * sends analytics
   *
   * @param {string} el the element for analytics
   */
  analytics(el) {
    const action = 'modal_contact-partner:';
    const formType = this.isRequestQuote ? 'request-a-quote' : 'ask-a-question';
    const details = [formType, this.formData.id];
    if (this.isRequestQuote) {
      details.push(this.formData.offRecId);
    }
    const analyticsObj = {
      analyticsType: 'click',
      element: el,
      details: action + details.join('|'),
    };
    makeIpaAnalyticsCall(analyticsObj);
  }
}