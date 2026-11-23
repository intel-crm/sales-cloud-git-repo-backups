import { LightningElement, wire, api } from 'lwc';
//import getOpportunities from '<a class="bp-suggestions-mention" href="https://www.forcetalks.com/salesforceintegration/" rel="nofollow">@salesforce</a>/apex/BarChartController.getOpportunities'; 
export default class ParentBarchart extends LightningElement {
    @api chartConfigurations;
    @api accountTypeName;
    @api totalCount;
   /* @wire(getOpportunities)
    getOpportunities({ error, data }) {
        if (error) {
            this.error = error;
            this.chartConfiguration = undefined;
        } else if (data) {
            
        }
    }*/

    connectedCallback(){

        console.log('chartconfiguration');
        console.log(this.chartConfigurations);

            /*let dqScore = [100,200,300,400,500];            
            let chartLabel = ['DQ score'];*/
           /*data.forEach(opp => {
                chartAmtData.push(opp.amount);
                chartRevData.push(opp.expectRevenue);
                chartLabel.push(opp.stage);
            });*/
            // this.chartConfiguration = {
            //     type: 'bar',
            //     data: {
            //         datasets: [{
            //             label: 'DQ score',
            //             backgroundColor: "green",
            //             data: chartAmtData,
            //         }],
            //         labels: chartLabel,
            //     },
            //     options: {},
            // };
           // console.log('data => ', data);
            // this.error = undefined;
    }
}