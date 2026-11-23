import { LightningElement, wire } from 'lwc';
import getAsyncJobs from '@salesforce/apex/Product_AsyncApexJob.getAsyncJobs';
import getLastRefreshDate from '@salesforce/apex/Product_RetrieveProdData.getLastRefreshDate';
 


export default class ProductAsyncApexJob extends LightningElement {
    // Add more statuses as needed
    asyncJobs=[];
    lastJobRun;
    connectedCallback(){
        this.asyncJobsData();
        this.getLRD();
    }
    getLRD(){
        getLastRefreshDate()
        .then(data => {
            if(data){
                this.lastJobRun = data;
            }else if(error){
                console.log(error);
            }
        });
    }
    asyncJobsData(){
        getAsyncJobs()
        .then(data => {
            if (data) {
                this.asyncJobs = JSON.parse(JSON.stringify(data));
                for(let i=0;i<data.length;i++){
                    //this.asyncJobs[i].ApexClassName = this.asyncJobs[i].ApexClass.Name;
                    if(this.asyncJobs[i].Status=='Completed'){
                        this.asyncJobs[i].completed = true
                    }
                    else if(this.asyncJobs[i].Status=='Failed'){
                        this.asyncJobs[i].failed = true;
                    }
                    else if(this.asyncJobs[i].Status=='Aborted'){
                        this.asyncJobs[i].failed = true;
                    }
                    else if(this.asyncJobs[i].Status=='Processing'){
                        this.asyncJobs[i].processing = true
                    }
                    else if(this.asyncJobs[i].Status=='Queued'){
                        this.asyncJobs[i].processing = true
                    }
                    else if(this.asyncJobs[i].Status=='Preparing'){
                        this.asyncJobs[i].processing = true
                    }
                    else if(this.asyncJobs[i].Status=='Holding'){
                        this.asyncJobs[i].processing = true
                    }
                }
                /*let lastJobRunList = this.asyncJobs.filter(dataRec => dataRec.Status == 'Completed');
                if(lastJobRunList.length>=1){
                    this.lastJobRun = lastJobRunList[0].CompletedDate;
                }
                */
            }
        });
    }
}