import { LightningElement, wire,api } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import pubsub from 'c/pubsub';


export default class PubSub_ToBeDeleted extends LightningElement {

@wire(CurrentPageReference) curPageRef;
@api selectedmenu;
sendMessage(){
    console.log('Event Firing');
    let message = {
        "message":"Hello Pub Sub"
    }
    pubsub.fire('simpleEvent',message);
    console.log('Event Fired');
}

}