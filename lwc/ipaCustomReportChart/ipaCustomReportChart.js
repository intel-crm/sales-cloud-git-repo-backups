import {LightningElement,api,wire,track} from 'lwc';
import {loadScript} from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/ChartJs';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getMPIByGroup from '@salesforce/apex/PMP_CustomReportController.getMPIByGroup';

export default class IpaCustomReportChart extends LightningElement {

    @track dataSet;
    @api chartType;
    @api selectedGroup= 'PMP_IPA_Badge_Tier_Txt__c';
    connectedCallback()
    {
        this.loadData();
    }
    loadData()
    {
        getMPIByGroup({ selectedGroup: this.selectedGroup })
        .then(result => {
            this.dataSet = result;
            this.Initializechartjs();
        })
        .catch(error => {
            this.error = error;
        });
    }
    @api chartjsInitialized = false;
    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;
        Promise.all([
                loadScript(this, ChartJS)
            ])
            .then(() => {
                 
            })
            .catch(error => {
                console.log(error.message)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading chartJs',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    Initializechartjs() {
        console.log("loaded");
        var piechart;
        var chartType = '.' + this.chartType;
        var ctx = this.template.querySelector(chartType).getContext('2d');

        piechart = new window.Chart(ctx, {
            type: this.chartType,
            data: {
                labels: Object.keys(this.dataSet),
                datasets: [{
                    label: 'Record Count',
                    data: Object.values(this.dataSet),
                    backgroundColor: ["#0074D9", "#FF4136", "#2ECC40", "#FF851B", "#7FDBFF", "#B10DC9", "#FFDC00", "#001f3f", "#39CCCC", "#01FF70", "#85144b", "#F012BE", "#3D9970", "#111111", "#AAAAAA"]

                }]
            }
        });
    }
    
    get groupOptions() {
        return [
            { label: 'Tier', value: 'PMP_IPA_Badge_Tier_Txt__c' },
            { label: 'Benefit', value: 'PMP_Partner_Benefit_Type__c' }
        ];
    }

    handleGroupChange(event) {
        this.selectedGroup = event.detail.value;
        console.log('this.selectedGroup'+ this.selectedGroup);
        this.loadData();
    }

}