import {LightningElement, api,track} from 'lwc';
import { registerComponentForInit, initializeWithHeadless,getHeadlessBundle } from 'c/quanticHeadlessLoader';
export default class core_IPS_SearchBeforeSubmit_Lex extends LightningElement {
  /** @type {string} */
  @api engineId = 'IPSSBS-engine';
  /** @type {string} */
  @api searchHub = 'IPSSBS';
  /** @type {string} */
  @api pipeline = 'IPSSBS';
  /** @type {boolean} */
  @api disableStateInUrl = false;
  /** @type {boolean} */
  @api skipFirstSearch = false;
  @api caseinfo;
  caseData;
  @track searchText;
  unsubscribe;
  
  @api rdcUserRoles;
  @api dict;
  @api map1;
  logCustomEvent;
  deflectedid;
  screenValidate = false;

  handleResultTemplateRegistration(event) {
    event.stopPropagation();
    const resultTemplatesManager = event.detail;
   
  }
  
  connectedCallback() {

    this.disableStateInUrl = true;
    registerComponentForInit(this, this.engineId);
    this.caseData = JSON.parse(this.caseinfo);
    
    //To handle search text
    this.searchText = this.caseData.ProductName;

    let screenValidate = sessionStorage.getItem("screenValidation");
    this.screenValidate = screenValidate == 'true' ? true:false;

  }

  @track hasValues;
  handleHasValues(event){
    this.hasValues = event.detail.hasvalue;
  }

  @track noresults;
  handlenoResults(event){
    this.noresults = event.detail.noresult;
  }
  
  renderedCallback() {
  initializeWithHeadless(this, this.engineId, this.initialize);
 
  }

  
  initialize = (engine) => {
    if(sessionStorage.getItem('deflectionId')!= null && sessionStorage.getItem('deflectionId')!= undefined && sessionStorage.getItem('deflectionId')!= ''){
     this.deflectedid = sessionStorage.getItem('deflectionId');
    }
    this.contextController = CoveoHeadless.buildContext(engine);
    this.headless = getHeadlessBundle(this.engineId);
    const { logCustomEvent } = this.headless.loadGenericAnalyticsActions(engine)
    this.logCustomEvent = (payload) => engine.dispatch(logCustomEvent(payload));

    this.contextController.set({"subject":this.caseData.Subject, "product": this.caseData.ProductName}); //"product": this.caseData.ProductName
    this.unsubscribe = this.contextController.subscribe(() => this.updateState());
    this.handleCustomEventForCheckForAnswer();
  }

  @track state;

  updateState() {
    this.state = this.contextController.state;
  }

  @api handleClickEventForDeflection(){  // continueToCaseCreation button custom event pass to coveo
       this.logCustomEvent({
        evt: 'Continue to Case Creation',
        type: 'Continue to Case Creation'
    });
  }

  count = 1;
  handleCustomEventForCheckForAnswer(){   // CheckForAnswer button custom event pass to coveo
    if(this.screenValidate){ 
      if(this.count == 1){
        this.logCustomEvent({
          evt: this.deflectedid,
          type: 'caseDeflection'
        });
        this.count++;
        sessionStorage.removeItem('screenValidation');
      }
    }
  }

}