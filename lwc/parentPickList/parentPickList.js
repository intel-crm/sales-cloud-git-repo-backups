import {
    LightningElement,
    track
} from 'lwc';

export default class ParentPickList extends LightningElement {
    @track pickList = new Map([
        ["First", ["Hi", "Hello", "How Are You?"]],
        ["Second", ["Bye", "Go", "Get Out!!"]]
    ]);
}