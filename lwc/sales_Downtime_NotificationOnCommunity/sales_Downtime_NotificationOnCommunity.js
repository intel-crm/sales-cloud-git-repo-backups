import { LightningElement,track } from 'lwc';
import Sales_DowntimeNotificationOnHomePage from '@salesforce/label/c.Sales_DowntimeNotificationOnHomePage';
import Sales_DowntimeDefault from '@salesforce/label/c.Sales_DowntimeDefault';

export default class Sales_Downtime_Notification extends LightningElement {
    label={
        Sales_DowntimeNotificationOnHomePage,
        Sales_DowntimeDefault,
    
    };  
    @track showOnHomeOnly; 
    showOnHomeOnly=false;
    homepagemsg= Sales_DowntimeNotificationOnHomePage;

    connectedCallback(){
        //To show component only on Home Page
            if(this.label.Sales_DowntimeDefault=='Yes') {
                this.showOnHomeOnly=true;
            }      
        }   
    }