import {LightningElement, api, track} from 'lwc';
import { registerComponentForInit, initializeWithHeadless } from 'c/quanticHeadlessLoader';
// import {loadSearchAnalyticsActions} from '@coveo/headless';


export default class ExampleSearch extends LightningElement {
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
  handleResultTemplateRegistration(event) {
    event.stopPropagation();
    const resultTemplatesManager = event.detail;
  }

  
  pName;
  sName;
  // searchActionCreators;

  connectedCallback() {

    this.disableStateInUrl = true;
    registerComponentForInit(this, this.engineId);
    //console.log('data from example search>>>>>>>>>>>>>>'+this.caseinfo);
    this.caseData = JSON.parse(this.caseinfo);
    //To handle search text
    this.searchText = this.caseData.ProductName;
  
    //console.log('caseData in json>>>>>'+ this.caseData.Subject);
    //console.log('printing rdcRoles in example search', this.rdcUserRoles);
 
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
    
    this.contextController = CoveoHeadless.buildContext(engine);
    this.contextController.set({"subject":this.caseData.Subject, "product": this.caseData.ProductName}); //"product": this.caseData.ProductName
    // this.facetController.facetSearch.updateCaptions(dict);
    this.unsubscribe = this.contextController.subscribe(() => this.updateState());
   
  }

  @track state;

  updateState() {
    this.state = this.contextController.state;
  }

 
}