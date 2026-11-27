import { LightningElement, api, track } from 'lwc';
import { registerComponentForInit, initializeWithHeadless, getHeadlessBundle } from 'c/quanticHeadlessLoader';
import Core_IPS_QuanticGeneratedAnswer from '@salesforce/label/c.Core_IPS_QuanticGeneratedAnswer'; 

const EVT_IN = 'consent:update';   
const EVT_OUT = 'consent:request'; 

export default class core_IPS_SearchBeforeSubmit_Lex extends LightningElement {
  @api engineId = 'IPSSBS-engine';
  @api searchHub = 'IPSSBS';
  @api pipeline = 'IPSSBS';
  @api disableStateInUrl = false;
  @api skipFirstSearch = false;

  incaseinfo;
  @track caseData = {};

  @api
  get caseinfo() {
    return this.incaseinfo;
  }
  set caseinfo(value) {
    this.incaseinfo = value;
    if (value) {
      try {
        this.caseData = typeof value === 'string' ? JSON.parse(value) : value;
        this.searchText = this.caseData.ProductName;
        this.updateCoveoContext();
      } catch (e) {
        console.error('Error parsing caseinfo:', e);
      }
    }
  }

  @track searchText;
  unsubscribe;
  unsubscribeEngine;

  @track showQuanticGeneratedAnswer = Core_IPS_QuanticGeneratedAnswer === 'true'; 
  @api rdcUserRoles;
  @api dict;
  @api map1;
  logCustomEvent;
  deflectedid;
  screenValidate = false;
  isPrcUser = false;

  get generatedAnswerClass() {
    return this.showQuanticGeneratedAnswer ? '' : 'slds-hide';
  }

  updateCoveoContext() {
    if (this.contextController && this.caseData) {
      this.contextController.set({
        "subject": this.caseData.Subject || '',
        "product": this.caseData.ProductName || '',
        "language": typeof getLocaleCode === 'function' ? getLocaleCode() : '',
        "languageRoot": typeof getLanguageRoot === 'function' ? getLanguageRoot() : '',
        "referrer": typeof getReferrer === 'function' ? getReferrer() : '',
        "userSkipCRGA": this.isPrcUser
      });
    }
  }

  handleConsentUpdate = (event) => {
    try {
      const rawConsent = event.detail.consent;
      const consentJson = rawConsent ? JSON.parse(rawConsent) : null;
      const countryCode = typeof consentJson?.country === 'string' ? consentJson.country.trim().toUpperCase() : '';

      if (/^[A-Z]{2}$/.test(countryCode) && countryCode === 'CN') {
        this.isPrcUser = true;
      } else {
        this.isPrcUser = false;
      }
    } catch (e) {
      this.isPrcUser = false;
    }

    this.showQuanticGeneratedAnswer = Core_IPS_QuanticGeneratedAnswer === 'true' && !this.isPrcUser;
    this.updateCoveoContext();
  };

  handleResultTemplateRegistration(event) {
    event.stopPropagation();
  }

  @track hasValues = false;
  handleHasValues(event) {
    this.hasValues = event.detail?.hasValues ?? event.detail?.hasvalue ?? false;
  }

  @track noresults = false;
  handlenoResults(event) {
    this.noresults = event.detail?.noresult ?? false;
  }

  connectedCallback() {
    this.disableStateInUrl = true;
    registerComponentForInit(this, this.engineId);

    if (this.caseinfo && (!this.caseData || Object.keys(this.caseData).length === 0)) {
      this.caseData = typeof this.caseinfo === 'string' ? JSON.parse(this.caseinfo) : this.caseinfo;
      this.searchText = this.caseData.ProductName;
    }

    let screenValidate = sessionStorage.getItem("screenValidation");
    this.screenValidate = screenValidate == 'true' ? true : false;
   
    window.addEventListener(EVT_IN, this.handleConsentUpdate);
    window.dispatchEvent(new CustomEvent(EVT_OUT));
  }

  disconnectedCallback() { 
    window.removeEventListener(EVT_IN, this.handleConsentUpdate);
    if (this.unsubscribe) {
      this.unsubscribe();
    }
    if (this.unsubscribeEngine) {
      this.unsubscribeEngine();
    }
  }

  renderedCallback() {
    initializeWithHeadless(this, this.engineId, this.initialize);
  }

  initialize = (engine) => {
    if (sessionStorage.getItem('deflectionId')) {
      this.deflectedid = sessionStorage.getItem('deflectionId');
    }
    this.headless = getHeadlessBundle(this.engineId);
    this.contextController = this.headless.buildContext(engine);
    const { logCustomEvent } = this.headless.loadGenericAnalyticsActions(engine);
    this.logCustomEvent = (payload) => engine.dispatch(logCustomEvent(payload));

    this.updateCoveoContext();

    if (this.caseData && this.caseData.Subject) {
      const { updateQuery } = this.headless.loadQueryActions(engine);
      engine.dispatch(updateQuery({ q: this.caseData.Subject }));
    }

    this.unsubscribeEngine = engine.subscribe(() => {
      const facetValues = engine.state?.facetSet?.tabfilter?.response?.values;
      if (Array.isArray(facetValues)) {
        this.hasValues = facetValues.length > 0;
      }
      const resultsCount = engine.state?.search?.results?.length;
      const firstSearchExecuted = engine.state?.search?.response?.searchUid;
      if (firstSearchExecuted !== undefined) {
        this.noresults = resultsCount === 0;
      }
    });

    this.unsubscribe = this.contextController.subscribe(() => this.updateState());
    this.handleCustomEventForCheckForAnswer();
  }

  @track state;
  updateState() { 
    this.state = this.contextController.state; 
  }

  @api handleClickEventForDeflection() {  
    this.logCustomEvent({ evt: 'Continue to Case Creation', type: 'Continue to Case Creation' });
  }

  count = 1;
  handleCustomEventForCheckForAnswer() {  
    if (this.screenValidate && this.count == 1) {
      this.logCustomEvent({ evt: this.deflectedid, type: 'caseDeflection' });
      this.count++;
      sessionStorage.removeItem('screenValidation');
    }
  }
}