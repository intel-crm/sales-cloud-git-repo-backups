import {LightningElement, api, track} from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Chart extends LightningElement {
 @api loaderVariant = 'base';
 @track chartConfig;


 @track isChartJsInitialized;
 @api checkValue(value) {
     //renderedCallback(){
        
    this.chartConfig = value; 
    
    if(this.chart!=null){
        this.chart.destroy();
    }
 //}
 //renderedCallback() {
  //if (this.isChartJsInitialized) {
   //return;
  //}
  // load static resources.
  console.log('called Again');
  
  Promise.all([loadScript(this, chartjs)])
   .then(() => {
    this.isChartJsInitialized = false;
    const ctx = this.template.querySelector('canvas.barChart').getContext('2d');
    this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
    this.chart.canvas.parentNode.style.height = '100%';  
    this.chart.canvas.parentNode.style.width = '100%';   
   })
   .catch(error => {
    this.dispatchEvent(
     new ShowToastEvent({
      title: 'Error loading ChartJS',
      message: error.message,
      variant: 'error',
     })
    );
   });
 }
}