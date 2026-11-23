import { LightningElement, api, track } from 'lwc';
import getMetrics from '@salesforce/apex/FinancialMetricController.getMetrics';
import deleteMetric from '@salesforce/apex/FinancialMetricController.deleteMetric';
import upsertMetrics from '@salesforce/apex/FinancialMetricController.upsertMetrics';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FinancialMetricsOverview extends LightningElement {
  @api recordId;
  @track metrics = [];
  showWarning = false;


  connectedCallback() {
    this.loadMetrics();
  }

  loadMetrics() {
    getMetrics({ accountPlanId: this.recordId })
      .then(result => {
        this.metrics = result.map(m => ({
          ...m,
          isGrossMargin: m.Metric_Type__c === 'Gross Margin'
        }));
      })
      .catch(error => {
        console.error('Error loading metrics:', error);
      });
  }

  handleAddMetric() {
    const newMetric = {
      Id: null,
      Account_Plan__c: this.recordId,
      Fiscal_Year__c: '',           // User will select
      CRM_Metric_Type__c: '',       // User will select
      CRM_Metric_Value__c: null,
      CRM_Percentage__c: null,
      isGrossMargin: false          // Set based on type once user selects
    };
  
    this.metrics = [...this.metrics, newMetric];
  }

  handleDeleteMetric(event) {
    const index = event.target.dataset.index;
    const metricToDelete = this.metrics[index];

    if (metricToDelete.Id) {
      deleteMetric({ metricId: metricToDelete.Id })
        .then(() => {
          this.removeMetricFromList(index);
        })
        .catch(error => {
          console.error('Error deleting metric:', error);
        });
    } else {
      this.removeMetricFromList(index);
    }
  }

  removeMetricFromList(index) {
    this.metrics = this.metrics.filter((_, i) => i !== parseInt(index));
  }

  handleFieldChange(event) {
    const index = event.target.dataset.index;
    const field = event.target.name;
    const value = event.target.value;
  
    let updatedMetrics = [...this.metrics];
    updatedMetrics[index][field] = value;
  
    // Update visibility of fields based on Metric Type
    if (field === 'CRM_Metric_Type__c') {
      updatedMetrics[index].isGrossMargin = value === 'Gross Margin';
    }
  
    this.metrics = updatedMetrics;
  }

  // Combobox options
  get metricTypeOptions() {
    return [
      { label: 'Market Cap', value: 'Market Cap' },
      { label: 'Account Revenue', value: 'Account Revenue' },
      { label: 'Net Income', value: 'Net Income' },
      { label: 'Cash & Investments', value: 'Cash & Investments' },
      { label: 'Debt Long Term', value: 'Debt Long Term' },
      { label: 'Price/Earnings', value: 'Price/Earnings' },
      { label: 'Gross Margin', value: 'Gross Margin' },
      { label: 'Employees', value: 'Employees' }
      
    ];
  }
  get fiscalYearOptions() {
    return [
      { label: 'FY 2025', value: 'FY 2025' },
      { label: 'FY 2024', value: 'FY 2024' },
      { label: 'FY 2023', value: 'FY 2023' },
      { label: 'FY 2022', value: 'FY 2022' },
      { label: 'FY 2021', value: 'FY 2021' },
    ];
  }
  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(evt);
  }
  handleSaveAll() {
    const hasMissingFields = this.metrics.some(metric => 
      !metric.CRM_Metric_Type__c || !metric.Fiscal_Year__c ||
      (metric.CRM_Metric_Type__c === 'Gross Margin' && (metric.CRM_Percentage__c === null || metric.CRM_Percentage__c === undefined)) ||
      (metric.CRM_Metric_Type__c !== 'Gross Margin' && (metric.CRM_Metric_Value__c === null || metric.CRM_Metric_Value__c === undefined))
    );
  
    if (hasMissingFields) {
      this.showWarning = true;
      return;
    }
  
    this.showWarning = false;
  
    // Continue with Apex save logic here...
  }
  
  
}