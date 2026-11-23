import { LightningElement,api } from 'lwc';
import getContent from '@salesforce/apex/Core_MDF_Community_Announcement.getContent';
export default class Core_MDF_Community_Announcement extends LightningElement {

@api sectionCode;
connectedCallback() {
     this.getAnnouncement();
}
AnnouncementUI =[];
    getAnnouncement(){
         getContent({sectionCode : this.sectionCode})
        .then(data => {
           this.AnnouncementUI  = data;
        })
        .catch(error => {
          console.log('error-->' , error);
        });
    }
    }