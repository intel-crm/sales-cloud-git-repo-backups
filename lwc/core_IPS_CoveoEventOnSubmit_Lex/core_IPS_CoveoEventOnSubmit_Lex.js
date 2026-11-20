import { LightningElement, api,track } from 'lwc';

import { registerComponentForInit, initializeWithHeadless, getHeadlessBundle } from 'c/quanticHeadlessLoader';
export default class Core_IPS_coveoEventOnSubmit_Lex extends LightningElement {

  /** @type {string} */
  @api engineId = 'IPSSBS-engine';
  /** @type {string} */
  @api searchHub = 'IPSSBS';
  /** @type {string} */
  @api pipeline = 'IPSSBS';
  skipFirstSearch = true;
  disableStateInUrl =  true;
  logCustomEvent; 
  headless;
   
    connectedCallback() {
        registerComponentForInit(this, this.engineId);
        try {
            initializeWithHeadless(this, this.engineId, this.initialize);
        } catch (error) {
            return;
        }            
    }

    initialize = (engine) => {
        this.headless = getHeadlessBundle(this.engineId);
        const { logCustomEvent } = this.headless.loadGenericAnalyticsActions(engine);
        this.logCustomEvent = (payload) => engine.dispatch(logCustomEvent(payload));
        }

    @api sendEventTOCoveo() {
        this.logCustomEvent({
            evt: 'submitButton',
            type: 'caseCreation'
        })
    }

}