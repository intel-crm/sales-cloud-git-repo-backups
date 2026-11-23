import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LWCPlatformEvent extends LightningElement {
    @track status;
    @track message;
    @track recordId;
    @track isShowModalSuccess= false;   
    @track isShowModalFail= false;   
    subscription = {};
    @api channelName = '/event/Techdicer_Event__e';
    @track resultEvent='';
    @track statusstring='';
    connectedCallback() {
        // Register error listener     
        this.registerErrorListener();
        this.handleSubscribe();
    }
 
    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
             console.log('New message received 1: ', JSON.stringify(response.data.payload.status__c));
            // console.log('New message received 2: ', response);
          //  var obj =JSON.stringify(response);
            self.resultEvent=response.data.payload.status__c;
            console.log('resultevent type:'+typeof(this.resultEvent));
            console.log('resultevent type:'+this.resultEvent);
            // console.log('obj.data.payload-->'+this.resultEvent);
            // console.log('obj.data.payload1-->'+this.resultEvent.data.payload);
           // console.log(obj.data.payload.message__c);
            // console.log('self.channelName-->'+self.channelName);
            // console.log('objData.status__c--->'+objData.status__c);
          
            //self.message = objData.message__c;
          //  this.statusstring="abc";
          console.log('New message boolean: ',response.data.payload.isLoading__c);
          if(self.resultEvent=='abc'){
            console.log('hi');
            self.isShowModalSuccess=true;
          }
          
           // self.recordId = objData.recordid__c;
            self.ShowToast('Techdicer Plaform Event', self.message, 'success', 'dismissable');
        };
 
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
        this.actionToggleBar();
    }
    showModal(){
        
    }
    
    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
 
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    //progress bar:
    progress = 0;
    isProgressing = false;

    get computedLabel() {
        return this.isProgressing ? 'Stop' : 'Start';
    }

    actionToggleBar() {
        if (this.isProgressing) {
            // progress bar stop
            this.isProgressing = false;
            clearInterval(this._interval);
        } else {
            // progress bar start
            this.isProgressing = true;            
            this._interval = setInterval(() => {
                this.progress = this.progress === 100 ? 0 : this.progress + 1;
            }, 200);
        }
    }

    disconnectedCallback() {
        // the component gets disconnected       
        clearInterval(this._interval);
    }

}