import { LightningElement, api, wire } from 'lwc';
import getKPIs from '@salesforce/apex/AccountPlanKPIController.getKPIs';
import { loadScript } from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/chartJs';

export default class AccountPlanKPIController extends LightningElement {
    @api recordId;
    opportunityStages = [];
    totalOpportunities = 0;
    opportunityWinRate = 0;
    chart;
    chartInitialized = false;

    @wire(getKPIs, { recordId: '$recordId' })
    wiredKPIs({ error, data }) {
        if (data) {
            this.totalOpportunities = data.opportunityStages.reduce((sum, stage) => sum + stage.count, 0);
            this.opportunityWinRate = data.opportunityWinRate;

            this.opportunityStages = data.opportunityStages.map((stage, index) => ({
                ...stage,
                color: this.getStageColor(index)
            }));

            if (!this.chartInitialized) {
                this.chartInitialized = true;
                this.loadChart();
            } else {
                this.updateChart();
            }
        } else if (error) {
            console.error("Error loading data:", error);
        }
    }

    getStageColor(index) {
        const colors = ['#2F80ED', '#27AE60', '#F2994A', '#9B51E0', '#EB5757', '#56CCF2', '#BB6BD9', '#FFA07A', '#1F78B4'];
        return colors[index % colors.length];
    }

    loadChart() {
        loadScript(this, ChartJS)
            .then(() => {
                const canvas = this.template.querySelector('canvas');
                if (canvas) {
                    const ctx = canvas.getContext('2d');
                    this.chart = new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: this.opportunityStages.map(stage => stage.stage),
                            datasets: [{
                                data: this.opportunityStages.map(stage => stage.count),
                                backgroundColor: this.opportunityStages.map(stage => stage.color),
                                borderWidth: 0
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '70%',
                            plugins: {
                                legend: { display: false },
                                tooltip: { enabled: false }
                            }
                        }
                    });
                }
            })
            .catch(error => console.error("Chart.js failed to load:", error));
    }

    updateChart() {
        if (this.chart) {
            this.chart.data.labels = this.opportunityStages.map(stage => stage.stage);
            this.chart.data.datasets[0].data = this.opportunityStages.map(stage => stage.count);
            this.chart.data.datasets[0].backgroundColor = this.opportunityStages.map(stage => stage.color);
            this.chart.update();
        }
    }
}