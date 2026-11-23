import { LightningElement } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

export default class SbrPoc extends NavigationMixin(LightningElement) {
    objectApiName = 'Account';
    testrecordId ='';
    checkCondition = false;
    value = '';

    result = '';
    get options() {
        return [
            { label: 'Sales', value: 'Intel' },
            { label: 'Force', value: 'Ecd' },
        ];
    }

    handleChange1(event){
        this.result = event.detail.value;
    }

    handleClick(){
        alert(this.result);
        this.checkCondition = true;
        alert(this.checkCondition);

        if(this.result == 'Intel'){
            this.testrecordId ='0122D000002Ve9pQAC';
        }else if(this.result == 'Ecd'){
            this.testrecordId ='0122D000002Ve9pQAC';
        }
        
        const config = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                recordtypeId: '0122D000002Ve9pQAC'
          }
        };
        alert(this.testrecordId);
        this[NavigationMixin.Navigate](config);

    }


}