import { LightningElement , api} from 'lwc';
export default class Core_MDF_SiteAdobeAnalyticsSupport extends LightningElement {
@api pageName;



connectedCallback() {
   this.loadAnalyticsSupport();
}

salesforceWait (params) {
    try {
      if (params.when()) {
        params.callback();
        return;
      }
      const tries = params.tries || 20;
      const time = params.time || 250;

      console.log(params);

      let executions = 1;
      const interval = setInterval(() => {
        console.log('params.when() '+params.when())
        if (params.when()) {
          console.log('wait-when()');
          clearInterval(interval);
          console.log('wait-clearinterval()');
          params.callback();
          console.log('wait-paramscallback');
        } else if (executions >= tries && tries > 0) {
          clearInterval(interval);
          console.log('wait-second clear interval');
          if (params.ifNoMoreTries) {
            console.log('wait-params-no more tries');
            params.ifNoMoreTries();
          }
        } else {
          executions += 1;
          console.log('executions' + executions);
        }
      }, time);
    } catch (e) {
      console.error('Exception in SalesforceWait Method '+e.message);
    }
  };

/*renderedCallback(){
  this.loadAnalyticsSupport();
}*/
// function definition

testingFunction (){
console.log('wap_tms ' + wap_tms);
console.log('window.wap_tms ' + window.wap_tms);
console.log('title ' + window.document.title);
console.log('SecureWindow ' + SecureWindow);
}

loadAnalyticsSupport(){
   var pageName = this.pageName; 
   console.log('Page Name==>'+pageName);
   try{
   if (pageName != ''){
     try {

  console.log('start here' );
  console.log('wap_tms'+wap_tms );
  console.log('window.wap_tms'+Window.wap_tms );
      this.salesforceWait({
        //when: () => !!wap_tms?.custom?.trackGaVirtualPageView,
        when: () => this.testingFunction,
        callback: () => {
          console.log('callback in LWC-SalesforceWait');
	      	//window.wap_tms.custom.trackGaVirtualPageView(pageName);
          this.testingFunction();
        },
        tries: 100,
      });
     
console.log('end here' );
      
} catch(e) {
	  console.error('e.message inside loadAnalyticsSupport salesforceWait ' + e.message );
}
 
   }
   }
   catch(e){
     console.error('e.message => ' + e.message );
   }
   
}







}