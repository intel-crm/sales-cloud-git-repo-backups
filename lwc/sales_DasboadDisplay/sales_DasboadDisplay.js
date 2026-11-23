import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Sales_DasboadDisplay  extends NavigationMixin (LightningElement)  {
    opendashboard(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": 'https://intel--crmdevsls3.sandbox.lightning.force.com/lightning/r/Dashboard/01Z2D000000kyalUAA/view?queryScope=userFolders'
            }
        });
    }
}