import { LightningElement,track,wire,api} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import Core_IPS_New_Logo from '@salesforce/resourceUrl/Core_IPS_New_Logo';
import surveyQuestions from '@salesforce/apex/Core_ips_surveyrep_CTRL.init';
import captureSurvey from '@salesforce/apex/Core_ips_surveyrep_CTRL.captureSurvey';
import caseOwnerRedirectPage from '@salesforce/apex/Core_ips_surveyrep_CTRL.caseOwnerRedirectPage';
import surveyrepCss from '@salesforce/resourceUrl/surveyrepCss';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Core_IPS_HappyEmoji from '@salesforce/resourceUrl/Core_IPS_HappyEmoji';
import Core_IPS_NeutralEmoji from '@salesforce/resourceUrl/Core_IPS_NeutralEmoji';
import Core_IPS_SadEmoji from '@salesforce/resourceUrl/Core_IPS_SadEmoji'
import core_ips_surveyheader from '@salesforce/label/c.core_ips_surveyheader';
import Core_ips_surveyFooter1 from '@salesforce/label/c.Core_ips_surveyFooter1';
import Core_ips_surveyFooter2 from '@salesforce/label/c.Core_ips_surveyFooter2';
import core_ips_closeSurveyText from '@salesforce/label/c.core_ips_closeSurveyText';
 import skipSurveyDisable from '@salesforce/apex/Core_ips_surveyrep_CTRL.skipSurveyDisable';



export default class Core_ips_surveyrep_lwc extends  NavigationMixin(LightningElement){
    @track surveyrepCss1 = surveyrepCss;
    @track happyemj=Core_IPS_HappyEmoji;
    @track neutralemojiii=Core_IPS_NeutralEmoji;
    @track Core_IPS_SadEmoji = 	Core_IPS_SadEmoji;
   

    @track ips_Survey_Logo = Core_IPS_New_Logo;
    @track surveyheader=core_ips_surveyheader;
    @track footer1=Core_ips_surveyFooter1;
    @track footer2=Core_ips_surveyFooter2;
    @track closecasetext=core_ips_closeSurveyText;
    currentPageReference
     recordId;
     casenum;
     true1;
     true2;
     false;
     @track changeradio=[];
     @track l_All_Types;
     @track TypeOptions=[];
     values1='';
   @track valueFromInt;
   isLoaded=false;
   surveySettingvalues;
   @wire(CurrentPageReference)
   getPageReferenceParameters(currentPageReference) {
      if (currentPageReference) {
        
        
        let states = currentPageReference.state;
       
          this.casenum = states.c__caseId;
         this.recordId=states.c__recordId;
         if(this.recordId){
           
       
         }
      }
   }
   surveyCaptured=false;
connectedCallback(){
    loadStyle(this,surveyrepCss);
 

    caseOwnerRedirectPage({CaseID:this.recordId})
    .then(result=>{
this.surveyCaptured=result;



    })
    this.getinit();
  

}
 
 @track objects = [];
 optionValues = [];
 option2=[];
 showcontent=false;
 lstQuestions;
 empty='';
 sademojiii;
 nethieremojiii;
 happymojiii;
getinit(){
   
    surveyQuestions({
        mapram:this.recordId,answer:this.empty
    })
    .then(result => {
      
        this.lstQuestions=result;
        this.valueFromInt= result;
       
        this.valueFromInt = result.map((item) => 
        Object.assign({}, item, {selected:false}))
      
            for(let i = 0; i < this.valueFromInt.length; i++) {
               
            if(Object.keys(this.valueFromInt[i].mapAnswerId).length) {
            const keys = Object.keys(this.valueFromInt[i].mapAnswerId);
            
                keys.forEach((key, index) => {
                 
                   
                this.optionValues.push({label : key, value : key});
                });
            this.valueFromInt[i].options = this.optionValues;
         
           this.optionValues = [];
            }
            } 
               this.option2=this.valueFromInt[1].options;
      

       
this.showcontent=true;

       })
    .catch(error => {
       
        this.error = error;
        const event = new ShowToastEvent({
            title: this.error,
            message:
                'error in survey',
                variant: 'error',
        });
        this.dispatchEvent(event);
       
    });
}

@track mapOfValues = []; 
@track theRecord={};
name;
index;
radiovalues=[];
changeVlaueinRadio(event){
  
  let quesid=event.target.name;
let chanGeR=event.target.value;
    this.changeradio = chanGeR.replace(/['"]+/g, '');

if(!this.radiovalues.includes(quesid)){
    
    this.radiovalues.push(quesid);
  
}



    this.name=event.target.name;
    this.index = event.target.dataset.index;
  
    this.theRecord[ event.target.name] =(event.target.value).replaceAll(/['"]+/g, '');

   

 

}
mapOfValues=[];
   onClickSubmit(){
 
this.isLoaded=true;
  let answerdata=  JSON.stringify(this.theRecord);

 

if(this.radiovalues.length>=5){
    captureSurvey({answer :answerdata,mapram:this.recordId})
.then(result => {
   this.isLoaded=false;
    const event = new ShowToastEvent({
        title: 'Survey Report',
        message:
            'Survey Submitted Succesfully',
            variant: 'success',
    });
    this.dispatchEvent(event);
  
    
let origin=location.origin;
window.open(origin+'/lightning/r/Case/'+this.recordId+'/view','_self')

    

  
})
.catch(error => {
    this.error = error;
   
});
}
else{
    this.isLoaded=false;
    const event = new ShowToastEvent({
        title: 'Survey Report',
        message:
            'Please answer all required questions',
            variant: 'error',
    });
    this.dispatchEvent(event);
}
} 
TextAreaValue;  
freeTextAreaValue;
onchangeTextarea(event){
    this.TextAreaValue=event.detail.value;
    

    if(this.TextAreaValue!="" || this.TextAreaValue!=null ||this.TextAreaValue!=undefined ){
    this.theRecord[event.target.name] =event.detail.value;
   

    }
   
}
onchangeFreeTextarea(event){
    this.freeTextAreaValue=event.detail.value;
   

    if(this.freeTextAreaValue!="" || this.freeTextAreaValue!=null ||this.freeTextAreaValue!=undefined){
    this.theRecord[event.target.name] = event.detail.value;
   

    }
    

    
}
surveyCaptured1;
handleClick(event){
   
skipSurveyDisable({caseid:this.recordId})
    .then(result=>{

this.surveyCaptured1=result;



    })
let origin=location.origin;
window.open(origin+'/lightning/r/Case/'+this.recordId+'/view','_self')

}


}