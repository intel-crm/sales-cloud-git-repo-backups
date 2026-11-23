import { LightningElement, api, track } from 'lwc';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';

export default class CrmMeetingBriefMap extends LightningElement {
    @api recordId;
    @track mapMarkers = [];
    @track mapCenter = {};
    @track error;
    @track isModalOpen = false;

    connectedCallback() {
        this.fetchExecutiveMeetingBriefData();
    }

    fetchExecutiveMeetingBriefData() {
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(result => {
                this.executiveBriefData = result;
                this.crmLocation = this.executiveBriefData.CRM_Location__c;

                console.log('Map executiveBriefData is:' + JSON.stringify(this.executiveBriefData));
                console.log('Map location is:' + JSON.stringify(this.crmLocation));
                this.error = undefined;

                // Set map data after fetching the location
                this.setMapData();
            })
            .catch(error => {
                this.error = error;
                this.executiveBriefData = undefined;
                console.log('Oops error:' + JSON.stringify(this.error));
            });
    }

    setMapData() {
        if (this.crmLocation) {
            this.mapMarkers = [
                {
                    location: {
                        Street: this.crmLocation.street,
                        City: this.crmLocation.city,
                        State: this.crmLocation.state,
                        PostalCode: this.crmLocation.postalCode,
                        Country: this.crmLocation.country
                    },
                    title: 'Meeting Location',
                    description: 'Location based on CRM_Location__c field'
                }
            ];
            this.mapCenter = {
                location: {
                    Street: this.crmLocation.street,
                    City: this.crmLocation.city,
                    State: this.crmLocation.state,
                    PostalCode: this.crmLocation.postalCode,
                    Country: this.crmLocation.country
                }
            };
        } else {
            console.error('Incomplete address data:', this.crmLocation);
        }
    }

    handleShowMap() {
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }
}