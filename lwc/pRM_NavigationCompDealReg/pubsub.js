import { LightningElement, wire,api } from 'lwc';

export default class Pubsub extends LightningElement{

    message;
    connectedCallback(){
        this.register();
    }
    register(){
        console.log('Event Registered----');
        pubsub.register('simpleEvent',this.handleEvent.bind(this));

    }
    handleEvent(messageFromEvt){
        console.log('Event Handled---',messageFromEvt);
        this.message = messageFromEvt ? JSON.stringify(messageFromEvt,null,'\t'):'no  message Payload';
    }
    
}