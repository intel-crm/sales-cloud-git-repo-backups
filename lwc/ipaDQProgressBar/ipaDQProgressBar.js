import { LightningElement,track} from 'lwc';
import executeBatch from '@salesforce/apex/PMP_DQBatchProgressController.executeBatchJob';
import getBatchJobStatus from '@salesforce/apex/PMP_DQBatchProgressController.getBatchJobStatus';
import getBatchJobInfo from '@salesforce/apex/PMP_DQBatchProgressController.getBatchJobInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IpaDQProgressBar extends LightningElement {
    batchId;
    error;
    apexJob;
    processedPercent=0;
    setTimeInterval;
    progress;
    jobCompleted = false;
    disabled =false;
    batchCompleted;
    loadSpinner =true;
    connectedCallback()
    {
        this.getBatchJobInfo();
    }
    executeBatch() {
        executeBatch({})
        .then((data) => {
         if(data)
         {
            this.showToast('Success!','The Job has been successfully initiated.','success');
            this.batchId = data;
            this.getBatchJobStatus(this.batchId);
            if(this.jobCompleted)
            {
                this.progress = 100;
            }
         }           
        })
        .catch(error => {
            if(error)
            {
                this.showToast('Error!','An Error has occured. Please try again or contact System Administrator.','error');
                this.error = error;
            }          
        });
    }
    getBatchJobStatus(batchId)
    {       
      this.setTimeInterval = setInterval(() => {
        getBatchJobStatus({jobID: batchId})
       .then((data) => {
          if(data)
          {
            this.apexJob=data;
            if(this.apexJob.JobItemsProcessed != 0){
                this.processedPercent = (this.apexJob.JobItemsProcessed / this.apexJob.TotalJobItems) * 100;
            }
            this.progress = this.progress === 100 ? clearInterval(this.setTimeInterval) : this.processedPercent;
            console.log('this.progress',this.progress);
            if(this.progress === 100)
            {
                this.jobCompleted=true;
                this.disabled =true;
            }
          }  
       })
       .catch(error => {

       });
      }, 1000); 

    }
    getBatchJobInfo()
    {
        getBatchJobInfo({})
        .then((data) => {
         if(data)
         {
            this.loadSpinner= false;
            console.log('Entry1');
            console.log('data'+data);
            if(data>0)
            {
                this.disabled =true;
                this.batchCompleted =true;
                this.progress=100;
            }           
            console.log('this.disabled--->'+ this.disabled);
         }           
        })
        .catch(error => {
            if(error)
            {
                this.loadSpinner= false;
                console.log('Entry2');
                this.error = error;
            }          
        });
    }

    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}