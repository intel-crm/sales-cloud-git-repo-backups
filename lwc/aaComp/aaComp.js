import { LightningElement } from 'lwc';
import {add as addition, myVar, Person} from 'c/abComp';

export default class AaComp extends LightningElement {

    handleClick()
    {
        
        console.log(myVar);
        let x = myVar;
        console.log(addition(2,3));
        x = 8;
        console.log(x);
        const p = new Person();
        console.log(p + '  ****  ' + JSON.stringify(p));
        p.firstName = 'Rajat';
        console.log(p + '  ****  ' + JSON.stringify(p));
    }
}