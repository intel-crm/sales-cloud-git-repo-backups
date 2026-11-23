import { LightningElement } from 'lwc';
import SAY_HELLO from '@salesforce/resourceUrl/hello_from_Scripted_Browsing';
import { loadScript } from 'lightning/platformResourceLoader';

export default class Browser_Monitoring extends LightningElement {
    clickHandler() {
        console.log('hello from helloWorld.js');
    }
    renderedCallback() {
        loadScript(this, SAY_HELLO)
        .then(() => console.log('Loaded sayHello'))
        .catch(error => console.log(error));
    }
}