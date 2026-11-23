import { LightningElement,track,api } from 'lwc';
import Sales_DowntimeNotificationOnRecord from '@salesforce/label/c.Sales_DowntimeNotificationOnRecord';
import Sales_DowntimeNotificationOnHomePage from '@salesforce/label/c.Sales_DowntimeNotificationOnHomePage';
import Sales_DowntimeDefault from '@salesforce/label/c.Sales_DowntimeDefault';
export default class CustomNotification extends LightningElement {

    label={
        Sales_DowntimeNotificationOnRecord,
        Sales_DowntimeNotificationOnHomePage,
        Sales_DowntimeDefault
    };
    @api objectApiName; //to track the component visibility on homepage and record page 
    @track NotificationColor; 
    @track ischecked;

    

    connectedCallback(){
        //get Downtime value as yes/no    
         var downtime=Sales_DowntimeDefault.split(",");
         var showdowntime=downtime[0];
         var colvalue=downtime[1];

         //if downtime is yes show blank template
        if(this.showdowntime=='Yes'){
            this.ischecked=true;
        }
        //if downtime is no show template with custom label values
        else{
            this.ischecked=false;
            //if value after ',' in Sales_DowntimeDefault custom label is red then show notification in red
            if(colvalue=='red'){
                this.NotificationColor=true;
            }
            //if value after ',' in Sales_DowntimeDefault custom label is black then show notification in black
            else{
            this.NotificationColor=false;
            }
        }  
    }
}