import { LightningElement } from 'lwc';

export default class CommisionsTab extends LightningElement {
    constructor(){
        super();
        console.log('in constructor commissions tab');
        //window.open("https://account.activedirectory.windowsazure.com/applications/signin/9ed3c335-8fc5-47ab-8467-270f9739353e?tenantId=46c98d88-e344-4ed4-8496-4ed7712e255d");
    }

    connectedCallback(){
        console.log('in connectedCallback commissions tab');
        window.open("https://account.activedirectory.windowsazure.com/applications/signin/9ed3c335-8fc5-47ab-8467-270f9739353e?tenantId=46c98d88-e344-4ed4-8496-4ed7712e255d");

    }
    renderedCallback(){
        console.log('renderedCallback');
    }
    
}