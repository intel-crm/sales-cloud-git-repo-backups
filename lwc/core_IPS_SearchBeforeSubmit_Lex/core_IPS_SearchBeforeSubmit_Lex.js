/**Updated: Implementation of Coveo CRGA changes on IPS portal SBS page-TWC745-9525-Gangadhar**/
import { LightningElement, api, track } from 'lwc';
import { registerComponentForInit, initializeWithHeadless, getHeadlessBundle } from 'c/quanticHeadlessLoader';
import Core_IPS_QuanticGeneratedAnswer from '@salesforce/label/c.Core_IPS_QuanticGeneratedAnswer'; //CRGA changes TWC745-9525-Gangadhar

const EVT_IN = 'consent:update';   // Listening for bridge //CRGA changes TWC745-9525-Gangadhar
const EVT_OUT = 'consent:request'; // Calling out to bridge //CRGA changes TWC745-9525-Gangadhar

export default class Core_IPS_SearchBeforeSubmit_Lex extends LightningElement {
  @api engineId = 'IPSSBS-engine';
  @api searchHub = 'IPSSBS';
  @api pipeline = 'IPSSBS';
  @api disableStateInUrl = false;
  @api skipFirstSearch = false;
  @api caseinfo;
  caseData;
  @track searchText;
  unsubscribe;
  
  @track showQuanticGeneratedAnswer = false; //CRGA changes TWC745-9525-Gangadhar
  @api rdcUserRoles;
  @api dict;
  @api map1;
  logCustomEvent;
  deflectedid;
  screenValidate = false;
  
  isPrcUser = false; 

  // Stable reference for event handshake processing //**CRGA changes TWC745-9525-Gangadhar-Begin
  handleConsentUpdate = (event) => {
    try {
        const rawConsent = event.detail.consent;

        const consentJson = rawConsent ? JSON.parse(rawConsent) : null;

        const countryCode = typeof consentJson?.country === 'string' ? consentJson.country.trim().toUpperCase() : '';

        // Regex Validation & China Evaluation
        if (/^[A-Z]{2}$/.test(countryCode) && countryCode === 'CN') {
            this.isPrcUser = true;
        } else {
            this.isPrcUser = false;
        }
    } catch (e) {
        this.isPrcUser = false;
    }

    // Evaluate visibility logic
    this.showQuanticGeneratedAnswer = Core_IPS_QuanticGeneratedAnswer === 'true' && !this.isPrcUser;
    //**CRGA changes TWC745-9525-Gangadhar-End

    // Dynamic runtime update to Coveo Context engine
    if (this.contextController) {
        this.contextController.set({
            "subject": this.caseData.Subject, 
            "product": this.caseData.ProductName,
            "language": typeof getLocaleCode === 'function' ? getLocaleCode() : '',
            "languageRoot": typeof getLanguageRoot === 'function' ? getLanguageRoot() : '',
            "referrer": typeof getReferrer === 'function' ? getReferrer() : '',
            "userSkipCRGA": this.isPrcUser
        });//CRGA changes TWC745-9525-Gangadhar
    }
  };

  handleResultTemplateRegistration(event) {
    event.stopPropagation();
  }
  
  connectedCallback() {
    this.disableStateInUrl = true;
    registerComponentForInit(this, this.engineId);
    this.caseData = JSON.parse(this.caseinfo);
    this.searchText = this.caseData.ProductName;

    let screenValidate = sessionStorage.getItem("screenValidation");
    this.screenValidate = screenValidate == 'true' ? true : false;
    
    window.addEventListener(EVT_IN, this.handleConsentUpdate);//CRGA changes TWC745-9525-Gangadhar-Begin
    
    window.dispatchEvent(new CustomEvent(EVT_OUT));//CRGA changes TWC745-9525-Gangadhar-Begin
  }

  disconnectedCallback() { //CRGA changes TWC745-9525-Gangadhar-Begin
    window.removeEventListener(EVT_IN, this.handleConsentUpdate);
  }
  
  renderedCallback() {
    initializeWithHeadless(this, this.engineId, this.initialize);
  }
  
  initialize = (engine) => {
    if(sessionStorage.getItem('deflectionId')) {
     this.deflectedid = sessionStorage.getItem('deflectionId');
    }
    this.contextController = CoveoHeadless.buildContext(engine);
    this.headless = getHeadlessBundle(this.engineId);
    const { logCustomEvent } = this.headless.loadGenericAnalyticsActions(engine);
    this.logCustomEvent = (payload) => engine.dispatch(logCustomEvent(payload));

    this.contextController.set({
        "subject": this.caseData.Subject, 
        "product": this.caseData.ProductName,
        "language": typeof getLocaleCode === 'function' ? getLocaleCode() : '',
        "languageRoot": typeof getLanguageRoot === 'function' ? getLanguageRoot() : '',
        "referrer": typeof getReferrer === 'function' ? getReferrer() : '',
        "userSkipCRGA": this.isPrcUser
    });//CRGA changes TWC745-9525-Gangadhar-Begin

    this.unsubscribe = this.contextController.subscribe(() => this.updateState());
    this.handleCustomEventForCheckForAnswer();
  }

  @track state;
  updateState() { this.state = this.contextController.state; }

  @api handleClickEventForDeflection(){  
       this.logCustomEvent({ evt: 'Continue to Case Creation', type: 'Continue to Case Creation' });
  }

  count = 1;
  handleCustomEventForCheckForAnswer(){   
    if(this.screenValidate && this.count == 1){
        this.logCustomEvent({ evt: this.deflectedid, type: 'caseDeflection' });
        this.count++;
        sessionStorage.removeItem('screenValidation');
    }
  }
}