import { LightningElement, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import Chartsjs from '@salesforce/resourceUrl/Chartsjs';
import pricingPubSub from 'c/pricingPubSub';

const pointRadius = 10;
export default class PricingRecommendationChart extends LightningElement {
    chartJson;

    isChartJSLoaded = false;
    @track showChart = false;
    @track myChart;

    connectedCallback() {
        pricingPubSub.register('loadchart', this.loadChart.bind(this));
        Promise.all([
            loadScript(this, Chartsjs + '/Chart.min.js'),
            loadScript(this, Chartsjs + '/samples/utils.js')
        ]).then(() => {
            this.isChartJSLoaded = true;
        });

    }

    get visibility() {
        if (this.showChart === true) {
            return 'slds-visible';
        } else {
            return 'slds-hidden';
        }
    }

    loadChart(payload, showChart) {
        if (this.isChartJSLoaded) {
            this.showChart = showChart;
            this.chartJson = payload;
            if (typeof (this.myChart) != "undefined") {
                this.myChart.destroy();
            }
            var ctx = this.template.querySelector(".myChart").getContext('2d');  // NOSONAR // node
            ctx.height = '300px';
            ctx.width = '300px';
            var lowPoints = [];  // NOSONAR
            var highPoints = [];  // NOSONAR
            var severePoints = []; // NOSONAR
            var eCapPoints = [];  // NOSONAR
            var requestedPricePoints = [];  // NOSONAR
            var dataSetsArr = [];  // NOSONAR

            this.chartJson[0].plots.low_risk.forEach(element => {
                if (element[0] < 0 || element[1] < 0) {
                    lowPoints.push({ x: 0, y: 0 });
                }
                else if (element[0] != null) {
                    lowPoints.push({ x: element[0], y: element[1] });
                }
            });

            if (lowPoints.length > 0) {
                dataSetsArr.push({
                    label: 'Low',
                    data: lowPoints,
                    borderColor: "#41c3f0",
                    backgroundColor: "#41c3f0",
                    fill: true,
                    pointRadius: pointRadius,
                    pointHoverRadius: pointRadius,
                    borderWidth: 0,
                    showLine: false
                });
            }

            this.chartJson[0].plots.high_risk.forEach(element => {
                if (element[0] < 0 || element[1] < 0) {
                    highPoints.push({ x: 0, y: 0 });
                }
                else if (element[0] != null) {
                    highPoints.push({ x: element[0], y: element[1] });
                }
            });

            if (highPoints.length > 0) {
                dataSetsArr.push({
                    label: 'High',
                    data: highPoints,
                    borderColor: "#488453",
                    backgroundColor: "#488453",
                    fill: true,
                    pointStyle: 'triangle',
                    pointRotation: 90,
                    pointRadius: pointRadius,
                    pointHoverRadius: pointRadius,
                    borderWidth: 0,
                    showLine: false
                });
            }

            this.chartJson[0].plots.severe_risk.forEach(element => {
                if (element[0] < 0 || element[1] < 0) {
                    severePoints.push({ x: 0, y: 0 });
                }
                else if (element[0] != null) {
                    severePoints.push({ x: element[0], y: element[1] });
                }
            });

            if (severePoints.length > 0) {
                dataSetsArr.push({
                    label: 'Severe',
                    data: severePoints,
                    borderColor: "#ee7d46",
                    backgroundColor: "#ee7d46",
                    fill: true,
                    pointStyle: 'triangle',
                    pointRotation: 180,
                    pointRadius: pointRadius,
                    pointHoverRadius: pointRadius,
                    pointBackgroundColor: '#ee7d46',
                    borderWidth: 0,
                    showLine: false
                });
            }

            if (this.chartJson[0].ecapPrice < 0) {
                eCapPoints.push({ x: 0, y: 0 });
            }

            else if (this.chartJson[0].ecapPrice != null) {
                eCapPoints.push({ x: this.chartJson[0].ecapPrice, y: 0 });
            }

            if (eCapPoints.length > 0) {
                dataSetsArr.push({
                    label: 'ECAP Price',
                    data: eCapPoints,
                    borderColor: "#446f97",
                    backgroundColor: "#446f97",
                    fill: true,
                    pointStyle: 'circle',
                    pointRadius: pointRadius,
                    pointHoverRadius: pointRadius,
                    pointBackgroundColor: '#446f97',
                    borderWidth: 0,
                    showLine: false
                });
            }

            if (this.chartJson[0].requestedPrice < 0) {
                requestedPricePoints.push({ x: 0, y: 0 });
            }

            else if (this.chartJson[0].requestedPrice != null) {
                requestedPricePoints.push({ x: this.chartJson[0].requestedPrice, y: 0 });
            }

            if (requestedPricePoints.length > 0) {
                dataSetsArr.push({
                    label: 'Requested Price',
                    data: requestedPricePoints,
                    borderColor: "#0067b5",
                    backgroundColor: "#0067b5",
                    fill: true,
                    pointStyle: 'rectRot',
                    pointRadius: pointRadius,
                    pointHoverRadius: pointRadius,
                    pointBackgroundColor: '#0067b5',
                    borderWidth: 0,
                    showLine: false
                });
            }

            this.myChart = new Chart(ctx, {
                type: "scatter",
                data: {
                    datasets: dataSetsArr
                },
                options: {
                    legend: { display: true },
                    scales: {
                        yAxes: [{
                            scaleLabel: {
                                display: true,
                                labelString: 'Probability of winning'
                            }
                        }],
                        xAxes: [{
                            scaleLabel: {
                                display: true,
                                labelString: 'Price (USD)'
                            }
                        }]
                    }
                }
            });
            this.myChart.update();
        }
    }
}