import { LightningElement,track,api,wire } from 'lwc';
import Sales_DowntimeNotificationOnRecord from '@salesforce/label/c.Sales_DowntimeNotificationOnRecord';
import Sales_DowntimeNotificationOnHomePage from '@salesforce/label/c.Sales_DowntimeNotificationOnHomePage';
import Sales_DowntimeDefault from '@salesforce/label/c.Sales_DowntimeDefault';
import Sales_DowntimeOnRecord from '@salesforce/label/c.Sales_DowntimeOnRecord';

import USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_EMAIL from '@salesforce/schema/User.Email';
import {getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class Sales_Downtime_Notification extends LightningElement {
    label={
        Sales_DowntimeNotificationOnRecord,
        Sales_DowntimeNotificationOnHomePage,
        Sales_DowntimeDefault,
        Sales_DowntimeOnRecord
    };
    
    //@api objectApiName; //to track the component visibility on homepage and record page 
    @api recordId;
    @track onboth;
    @track showOnHomeOnly;
    @track showOnRecordOnly;
    onboth=false;
    showOnHomeOnly=false;
    showOnRecordOnly=false;
    //onHomepageByUrl=false;
    homepagemsg= Sales_DowntimeNotificationOnHomePage;
    recordpagemsg= Sales_DowntimeNotificationOnRecord;

    
    /*
    currentUserProfileId;
    ProfileError;
    @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_ID]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserProfileId = data.fields.ProfileId.value;
           
        } else if (error) {
            this.ProfileError = error ;
        }
    }
    */



    connectedCallback(){
        //console.log('User id is'+this.currentUserProfileId);
        //To show component on both Homepage and License record Page
        if(this.label.Sales_DowntimeOnRecord=='Yes' && this.label.Sales_DowntimeDefault=='Yes'){
            this.onboth=true;
        }
        //To show component only on Home Page
        if((this.label.Sales_DowntimeOnRecord=='No' && this.label.Sales_DowntimeDefault=='Yes')  ){
            this.showOnHomeOnly=true;
        }
        //To show component only on Record Page
        if((this.label.Sales_DowntimeOnRecord=='Yes' && this.label.Sales_DowntimeDefault=='No')){
            this.showOnRecordOnly=true;
        }

        

        /*
        
            let split = JSON.stringify(this.baseUrl.pathname).split('psg/s/');
            if(split[1]==''||split[1]==null){
                this.onHomepageByUrl=true;
                
            
            */
            
        }   
    }