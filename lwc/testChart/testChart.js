import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/TestChart';
import getLeadByStatus from '@salesforce/apex/PMP_CustomReportController.getLeadByStatus';

export default class LibsChartjs extends LightningElement {
    error;
    chart;
    chartjsInitialized = false;
    dataSet;

    /*connectedCallback()
    {
        getLeadByStatus()
        .then(result => {
            this.dataSet = result;
        })
        .catch(error => {
            this.error = error;
        });
    }
    config = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: Object.values(this.dataSet),
                    backgroundColor: [
                        'rgb(255, 99, 132)',
                        'rgb(255, 159, 64)',
                        'rgb(255, 205, 86)',
                        'rgb(75, 192, 192)',
                        'rgb(54, 162, 235)'
                    ],
                    label: 'Dataset 1'
                }
            ],
            labels: Object.keys(this.dataSet)
        },
        options: {
            responsive: false,
            plugins: {
                legend: {
                    position: 'right'
                }
            },
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    };

    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        loadScript(this, chartjs)
            .then(() => {
                const canvas = document.createElement('canvas');
                this.template.querySelector('div.chart').appendChild(canvas);
                const ctx = canvas.getContext('2d');
                this.chart = new window.Chart(ctx, this.config);
            })
            .catch((error) => {
                this.error = error;
            });
    }*/
}