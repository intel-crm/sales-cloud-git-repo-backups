import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class PRM_NavigationComponent_PCC extends NavigationMixin(LightningElement){
    handleHome(){
        this[NavigationMixin.Navigate]({ 
            type: 'standard__webPage', attributes: { url: 'https://intel--crmdevint3.sandbox.my.site.com/partneradmin/s/ddr2' } }); 
            }
    
    handleClick() { 
        this[NavigationMixin.Navigate]({ 
        type: 'standard__webPage', attributes: { url: 'https://www.example.com' } }); 
        }
}