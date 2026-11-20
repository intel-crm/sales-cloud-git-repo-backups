import { LightningElement,track,api,wire } from 'lwc';
import getMagResponses from '@salesforce/apex/Core_IPS_MAG_Response_LEX_Controller.getMagResponses';
import getEnvironmentalDetailResponse from '@salesforce/apex/Core_IPS_MAG_Response_LEX_Controller.getEnvironmentalDetailResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Core_IPS_MAG_Response_LEX extends LightningElement {
    @api recordId;
    @track show = false;
    @track gecResponseCount = 0;
    @track magResponseCount = 0;
    @track records =[];
    @track responseColumns = [{
        label:'Question No',
        fieldName:'questionNo',
        type:'text'
    },{
        label:'GEC Question',
        fieldName:'gecQuestion',
        type:'text'
    },{
        label:'GEC Answer',
        fieldName:'gecAnswer',
        type:'text'
    },{
        label:'Submitted By',
        fieldName:'submittedById',
        type:'url',
        typeAttributes: {label: { fieldName: 'submittedByName' }, target: '_blank'}
    },{
        label:'Created Date',
        fieldName:'createdDate',
        type: 'date',
        typeAttributes: {  
            day: 'numeric',  
            month: 'numeric',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            second: '2-digit',  
            hour12: true 
        }
    }];
    
    @wire(getMagResponses, {caseId : '$recordId'})
    magResponses({data,error}){
        
        if(data){
            if(data.length > 0){
                this.show = false;
            } else {
                this.show = true;
            }
            for(let i= 0; i< data.length; i++) {
                let obj ={
                    'questionNo' : i+1,
                    'gecQuestion': data[i].Core_IPS_GEC_Question1__c,
                    'gecAnswer': data[i].Core_IPS_GEC_Question2__c,
                    'submittedById': '/' + data[i].LastModifiedById,
                    'submittedByName':data[i].LastModifiedBy.Name,
                    'createdDate':data[i].CreatedDate
                }
                this.records = [...this.records, obj];
                
            }
            
        } else if(error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
                
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
                console.log(error.body);
                this.showToast(this.error);
            }
           
        }
       
    }

    @wire(getEnvironmentalDetailResponse,{caseId : '$recordId'}) 
    environResponses({data,error}){
       
        if(data){
            for(let i= 0; i< data.length; i++) {
                if(data[i].Core_IPS_Responses__r != undefined){
                    
                    for(let j = 0; j < data[i].Core_IPS_Responses__r.length; j++){
                        if((data[i].Core_IPS_Responses__r[j].Core_IPS_Question_Master__r.RecordType.DeveloperName === 'Core_IPS_MAG_Question' && data[i].Core_IPS_Responses__r[j].Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c === undefined) || (data[i].Core_IPS_Responses__r[j].Core_IPS_Answer__c != null && data[i].Core_IPS_Responses__r[j].Core_IPS_Question_Master__r.RecordType.DeveloperName === 'Core_IPS_MAG_Question' && data[i].Core_IPS_Responses__r[j].Core_IPS_Question_Master__r.Core_IPS_Environment_Detail_Answer__c != undefined)){
                           
                            if(!(data[i].Core_IPS_Responses__r.length>0) && this.show === true){
                                this.show = true;
                            } else {
                                this.show = false;
                            }
                            let questionNo;
                            let gecQuestion;
                            let gecAnswer;
                            let submittedById;
                            let submittedByName;
                            let createdDate;
                            let tempStr;
                            if(data[i].Core_IPS_Responses__r.length > 0){
                                tempStr = data[i].Core_IPS_Responses__r[j].Core_IPS_Question__c;
                                questionNo = tempStr.slice(0,1);
                                gecQuestion = tempStr.substr(2);
                                gecAnswer = data[i].Core_IPS_Responses__r[j].Core_IPS_Answer__c;
                                submittedById = '/' + data[i].Core_IPS_Responses__r[j].LastModifiedById;
                                submittedByName = data[i].Core_IPS_Responses__r[j].LastModifiedBy.Name;
                                createdDate = data[i].Core_IPS_Responses__r[j].CreatedDate;
                            }
                            let obj ={
                                'questionNo' : questionNo,
                                'gecQuestion': gecQuestion,
                                'gecAnswer': gecAnswer,
                                'submittedById': submittedById,
                                'submittedByName' : submittedByName,
                                'createdDate': createdDate
                            }
                            this.records = [...this.records, obj];
                        }
                    }
                }
            }
           
        } else if(error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
                console.log(error.body);
                this.showToast(this.error);
            }
           
        }
    }

    showToast(message){
        const event = new ShowToastEvent({
            "title": "Error",
            "message": message
        });
        this.dispatchEvent(event);
    }
}