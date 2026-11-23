import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class IpaReDirect extends NavigationMixin(LightningElement) 
{
    connectedCallback()
    {
        console.log('Line 8 IPARedirect');
        //Logic to extract PrefLangIETF Cookie from document.cookie. 
        //Logic to extract the exact page within the community the user is trying to land.
        window.location.replace('https://crmdevipa-intelcloudcrm.cs45.force.com/ipa/s/?language=es');
        /*this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
               url : "http://salesforce.com"
            }
        }); */
        console.log('Line 15 IPARedirect');
    }
}