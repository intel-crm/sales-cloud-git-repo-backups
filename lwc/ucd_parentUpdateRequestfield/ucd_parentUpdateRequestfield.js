import { LightningElement } from 'lwc';

export default class Ucd_parentUpdateRequestfield extends LightningElement {
    recordId='...';
    handleRemove(){
        const childComp=this.template.querySelector('c-ucd-_-update-account-request-field');
        console.log('##childComp '+childComp);
        if(childComp){
            childComp.remove();
        }
    }
}