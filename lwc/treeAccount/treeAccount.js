import { LightningElement, track } from 'lwc';
import getTreeData from '@salesforce/apex/hierarchySample.getTreeData';

export default class TreeAccount extends LightningElement {
    @track items = [];



    handleSelect(){
        getTreeData({
    })
    // eslint-disable-next-line no-irregular-whitespace
    .then(result =>{
    // eslint-disable-next-line no-console
        window.console.log("This is result: " +JSON.stringify(result));
        window.console.log("This is result: " +JSON.parse(result));
        window.console.log('result::'+result);
        this.items = (JSON.parse(result));
    // eslint-disable-next-line no-irregular-whitespace
    })
    // eslint-disable-next-line no-irregular-whitespace
    .catch(error =>{
    // eslint-disable-next-line no-console
        console.log("THis is the error: " +error)
    })
    }

}