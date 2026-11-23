import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Psg_quotelineBackButton extends NavigationMixin(LightningElement) {

    @track isPSG = false;
    @track isTender = false;
    @track userPemissionSet=[];

    connectedCallback(){
        
        this.getUserPermissionSets(userId);
    }      

    getUserPermissionSets(userId){
        getUserPermissionSets({ userId: userId})
        .then(data => {
            //this.userPemissionSet = data;
            console.log("PermissionSets:" + JSON.stringify(data));
            if(JSON.stringify(data).includes('PSG_'))
            {
                this.isPSG = true;
            }
            if(JSON.stringify(data).includes('Tender'))
            {
                this.isTender = true;
            }

        
        })
        .catch(error => {
            this.userPemissionSet = [];
        })
    }
    home() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
}