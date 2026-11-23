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
    console.log('--- 31WAP CONSENT STEP 2: LWC Received CustomEvent from Head Markup ---');
    try {
        const rawConsent = event.detail.consent;
        console.log('@@ 34[LWC Monitor] Raw payload string received:', rawConsent);

        const consentJson = rawConsent ? JSON.parse(rawConsent) : null;
        console.log('@@ 37[LWC Monitor] Parsed JSON Structure:', JSON.stringify(consentJson));

        const countryCode = typeof consentJson?.country === 'string' ? consentJson.country.trim().toUpperCase() : '';
        console.log('@@ 40[LWC Monitor] Isolated Country Code Detected:', countryCode);

        // Regex Validation & China Evaluation
        if (/^[A-Z]{2}$/.test(countryCode) && countryCode === 'CN') {
            this.isPrcUser = true;
            console.log('@@ 45[LWC Monitor] Match Found! User is verified from China (CN).');
        } else {
            this.isPrcUser = false;
            console.log('@@ 48[LWC Monitor] User network is NOT from China (CN). Found:', countryCode);
        }
    } catch (e) {
        console.error('!! 51[LWC Monitor] Critical exception caught during event payload parsing:', e);
        this.isPrcUser = false;
    }

    // Evaluate visibility logic
    console.log('@@ 56[LWC Monitor] Custom Label Rule Configuration (Core_IPS_QuanticGeneratedAnswer):', Core_IPS_QuanticGeneratedAnswer);
    this.showQuanticGeneratedAnswer = Core_IPS_QuanticGeneratedAnswer === 'true' && !this.isPrcUser;
    //**CRGA changes TWC745-9525-Gangadhar-End
    console.log('--- 59WAP CONSENT STEP 3: Final Template Render State Evaluation ---');
    console.log('@@ 60[LWC Monitor] showQuanticGeneratedAnswer value set to:', this.showQuanticGeneratedAnswer);
    console.log(this.showQuanticGeneratedAnswer ? '61 [LWC UI] Template will RENDER on page.' : ' [LWC UI] Template will HIDE (Suppressed due to CN location or label config).');

    // Dynamic runtime update to Coveo Context engine
    if (this.contextController) {
        console.log('@@65 [LWC Monitor] Synchronizing state to Coveo Headless Context Engine. userSkipCRGA:', this.isPrcUser);
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
    
    console.log('---90 WAP CONSENT STEP 1: Component Initialization & Handshake Request ---');
    console.log('@@91 [LWC Monitor] Establishing event listener for window theme channel...');
    window.addEventListener(EVT_IN, this.handleConsentUpdate);//CRGA changes TWC745-9525-Gangadhar-Begin
    
    console.log('@@94 [LWC Monitor] Dispatching "consent:request" up to global Head Markup scope...');
    window.dispatchEvent(new CustomEvent(EVT_OUT));//CRGA changes TWC745-9525-Gangadhar-Begin
  }

  disconnectedCallback() { //CRGA changes TWC745-9525-Gangadhar-Begin
    console.log('@@99 [LWC Monitor] Component disconnected. Tearing down event listeners.');
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

    console.log('@@116 [Coveo Engine] Initializing context mapping payload. userSkipCRGA initialized as:', this.isPrcUser);
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