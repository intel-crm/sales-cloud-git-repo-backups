import { LightningElement, wire,api } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
//import Pubsub from './pubsub';


export default class PubSub_ToBeDeleted extends LightningElement {

@wire(CurrentPageReference) curPageRef;
@api selectedmenu;
connectedCallback(){
    console.log('Inside Publisher CB');
}
getMessage(){
    console.log('Inside getMessage');
}
sendMessage(){
    console.log('Event Firing');
    let message = {
        "message":"Hello Pub Sub"
    }
    Pubsub.fire('simpleEvent',message);
    console.log('Event Fired');
}

}