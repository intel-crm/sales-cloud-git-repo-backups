import { LightningElement,track } from 'lwc';

export default class Load_Ics_Chatbot extends LightningElement {
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = 'allow-same-origin allow-scripts allow-popups allow-forms allow-modals allow-top-navigation';
    @track url = 'https://ics-chatbot.intel.com/';
    @track width = '100%';
}