import { LightningElement } from 'lwc';

export default class IpsTypeHeadPicklist extends LightningElement {

    renderedCallback() {
        let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input").setAttribute("list", listId);
    }


    myFunction(event) {
        console.log('test' + event.target.value);
    }
}