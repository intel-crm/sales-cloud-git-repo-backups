import { LightningElement, api,track } from 'lwc';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';

export default class Crm_MeetingBrief_GoogleMap extends LightningElement {
    @api recordId;
    googleMapUrl;
    @track error;
    @track executiveBriefData;

    connectedCallback() {
        console.log('MAP Record id:'+this.recordId);
        this.fetchCurrentData();
    }
    
    fetchCurrentData() {
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(result => {
                this.executiveBriefData = result;
                console.log('MAP EXECUTIVE DATA IS:'+JSON.stringify(this.executiveBriefData));
                const address = this.executiveBriefData.CRM_Location__c;
                console.log('MAP ADDRESS :' + JSON.stringify(address));
                const locationCity = address.city;
                const locationState = address.state;
                const locationStreet = address.street;
                //this.googleMapUrl = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`;
                this.googleMapUrl = 'http://maps.google.com/maps?f=q&hl=en&q='+locationStreet+locationCity+locationState+'&om=1';
                 console.log('MAP Google Map URL:', this.googleMapUrl);
                 this.error= undefined;
              
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
                console.log('Oops error:' + JSON.stringify(this.error));
            });
    }
}