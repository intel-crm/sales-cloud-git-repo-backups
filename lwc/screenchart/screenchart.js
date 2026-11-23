import { LightningElement,api } from 'lwc';
import chartsjs from '@salesforce/resourceUrl/Chartsjs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Screenchart extends LightningElement {

    @api chartConfig;
    @api totalCount;
 
    isChartJsInitialized;
    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        // load chartjs from the static resource
        Promise.all([loadScript(this, chartsjs+'/Chart.js')])
            .then(() => {
                this.isChartJsInitialized = true;
                const ctx = this.template.querySelector('canvas.barChart').getContext('2d');
                this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
            })
            .catch((error) => {
                console.log(error);
                console.log('J132 ',error)
                // this.showsuccessToast(error,Error);
              });
    }
}