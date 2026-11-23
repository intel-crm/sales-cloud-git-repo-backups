import { api, LightningElement, track, wire } from 'lwc';
import getTacticMappings from '@salesforce/apex/Core_MDF_Tactics_Controller.getTacticMappings';
import getSavedKpiData from '@salesforce/apex/Core_MDF_Tactics_Controller.getSavedKpiData';
import saveKpiData from '@salesforce/apex/Core_MDF_Tactics_Controller.saveKpiData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KpiTable extends LightningElement {


    @api actTactics;
    @api mode;
    @api recordId;
    @api ipaclone;

     /* @track tacticOptions = [
            { label: 'Digital Media', value: 'Digital Media' },
            { label: 'Legacy Media', value: 'Legacy Media' },
            { label: 'Event', value: 'Event' },
            { label: 'Lead Cultivation', value: 'Lead Cultivation' },
            { label: 'Training', value: 'Training' },
            { label: 'Funded Headcount', value: 'Funded Headcount' },
            { label: 'Technical Services', value: 'Technical Services' },
            { label: 'Incentive', value: 'Incentive' },
        ];*/
        @track selectedTactics = [];
        @track data = [];
        allMappings = {};

        // Initilize the values
        connectedCallback() {
         //this.handleTacticChange(this.actTactics);
            if(this.mode != ''){
                this.loadSavedKpiData();
            }
        }
    
        /*handleTacticChange(event) {
          //if (event) {
                this.selectedTactics = JSON.parse(JSON.stringify(this.actTactics));
         // }
        
            this.data = this.selectedTactics.map((tactic, index) => {
                const template = this.allMappings[tactic];
                if (!template) {
                    console.warn(`No mapping found for tactic: ${tactic}`);
                    return null;
                }
        
                // Fully clone every nested object
                return JSON.parse(JSON.stringify({
                    id: `${index}-${tactic}-${Date.now()}`,
                    tactic,
                    firstKpi: {
                        label: template.firstKpi.label,
                        value: ''
                    },
                    otherKpis: template.otherKpis.map(kpi => ({
                        label: kpi.label,
                        value: ''
                    })),
                    percentageField: template.percentageField,
                    percentageValue: '',
                    rowspan: template.otherKpis.length + 1
                }));
            }).filter(row => row !== null);
        }
    
        handleKpiChange(event) {
            const rowId = event.target.dataset.id;
            const index = event.target.dataset.kpiIndex;
            const newValue = parseFloat(event.target.value);
        
            const row = this.data.find(item => item.id === rowId);
            if (row) {
                if (index === undefined || index === null || index === 'first') {
                    row.firstKpi.value = newValue;
                } else {
                    const kpiIdx = parseInt(index);
                    if (!isNaN(kpiIdx)) {
                        row.otherKpis[kpiIdx].value = newValue;
                    }
                }
            }
        }
    
        handlePercentageChange(event) {
            const rowId = event.target.dataset.id;
            const newValue = parseFloat(event.target.value);
            const row = this.data.find(item => item.id === rowId);
            if (row) {
                row.percentageValue = newValue;
            }
        }
    
        handleSave() {
            if (!this.validateAtLeastOneKpiPerTactic()) {
                return; // Validation failed, block save
            }
            const payload = JSON.parse(JSON.stringify(this.data));
            saveKpiData({ rawRecords: payload, pfrId: this.recordId })
                .then(() => {
                    this.showToast('Success', 'Data saved successfully!', 'success');
                })
                .catch(error => {
                    const message = error.body && error.body.message ? error.body.message : 'An error occurred';
                    this.showToast('Error', message, 'error');
                });
        }
    
        showToast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }    

        @api getTacticMetricsValues(){
            const payload = JSON.parse(JSON.stringify(this.data));
            return payload;
        }

        @api isTacticMetricsModified(){
            return true;
        }

        validateAtLeastOneKpiPerTactic() {
            let isValid = true;
            const tacticsChecked = new Set();
            const invalidTactics = new Set();
        
            // Clear previous invalid markings
            this.data.forEach(row => row.isInvalid = false);
        
            for (const row of this.data) {
                if (tacticsChecked.has(row.tactic)) {
                    continue; // Already validated this tactic
                }
        
                const tacticRows = this.data.filter(item => item.tactic === row.tactic);
        
                let hasValue = false;
                for (const tacticRow of tacticRows) {
                    // Check first KPI
                    if (tacticRow.firstKpi && tacticRow.firstKpi.value !== null && tacticRow.firstKpi.value !== '' && !isNaN(tacticRow.firstKpi.value)) {
                        hasValue = true;
                        break;
                    }
                    // Check other KPIs
                    if (tacticRow.otherKpis && tacticRow.otherKpis.length > 0) {
                        for (const kpi of tacticRow.otherKpis) {
                            if (kpi.value !== null && kpi.value !== '' && !isNaN(kpi.value)) {
                                hasValue = true;
                                break;
                            }
                        }
                    }
                    if (hasValue) break;
                }
        
                if (!hasValue) {
                    // Mark all rows of this tactic as invalid
                    tacticRows.forEach(item => item.isInvalid = true);
                    invalidTactics.add(row.tactic);
                    isValid = false;
                }
        
                tacticsChecked.add(row.tactic);
            }
        
            if (!isValid) {
                const tacticsList = Array.from(invalidTactics).join(', ');
                this.showToast('Validation Error', `Please enter at least one tactic metrics value for tactics: ${tacticsList}`, 'error');
            }
        
            return isValid;
        }*/
        kpiIndexIsZero(kpiIndex){
           if(kpiIndex === 0){
                return true;
            }
            return false;
        }

        loadSavedKpiData() {
            getSavedKpiData({ pfrId: this.recordId })
            .then((result) => {
                console.log('Loaded saved data', result);
                this.data = result;
            })
            .catch((error) => {
                console.error('Error loading saved data', error);
            });
        }
        

}