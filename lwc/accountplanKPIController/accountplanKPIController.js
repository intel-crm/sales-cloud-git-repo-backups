import { LightningElement, api,wire } from 'lwc';
import getAccountPlan from '@salesforce/apex/AccountPlanKPIController.getAccountName';
export default class AccountMetrics extends LightningElement {
    @api recordId;
    accountName;
    @api opportunityLink;

    // Sample data structure for demo (replace with actual data in production)
    stageData = [
        { stage: 'Qualify', count: 78, color: '#660099' },
        { stage: 'Design', count: 14, color: '#00BFFF' },
        { stage: 'Define', count: 5, color: '#DA70D6' },
        { stage: 'Production Win', count: 3, color: '#1E90FF' },
        { stage: 'Production Cancelled', count: 2, color: '#40E0D0' },
        { stage: 'Develop', count: 1, color: '#2E8B57' },
        { stage: 'Production Lost', count: 1, color: '#FF8C00' },
    ];

     // Wire the account name
     @wire(getAccountPlan, { recordId: '$recordId' })
     wiredAccountPlan({ error, data }) {
         if (data) {
             this.accountName = data;
         } else if (error) {
             console.error('Error loading account plan:', error);
         }
     }

    get totalOpportunities() {
        return this.stageData.reduce((acc, s) => acc + s.count, 0);
    }

    get processedStages() {
        return this.stageData.map(stage => ({
            ...stage,
            style: `background-color: ${stage.color};`
        }));
    }

    get segments() {
        const total = this.totalOpportunities;
        let offset = 0;
        let segments = [];

        for (const stage of this.stageData) {
            const percent = (stage.count / total) * 100;
            const segment = {
                key: stage.stage,
                color: stage.color,
                dasharray: `${percent} ${100 - percent}`,
                dashoffset: offset
            };
            segments.push(segment);
            offset -= percent;
        }

        return segments;
    }
}