import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [
  'AccountPlan.RelationshipStrengths',
  'AccountPlan.RelationshipOpportunities',
  'AccountPlan.RelationshipWeaknesses',
  'AccountPlan.RelationshipThreats'
];

export default class Crm_Swot_Analysis extends LightningElement {
  @api recordId;

  @track strengths = '';
  @track opportunities = '';
  @track weaknesses = '';
  @track threats = '';

  @track isCollapsed = true;

  get iconName() {
    return this.isCollapsed ? 'utility:chevronright' : 'utility:chevrondown';
  }

  toggleSection() {
    this.isCollapsed = !this.isCollapsed;
    console.log('Toggled! isCollapsed:', this.isCollapsed);
  }

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  wiredRecord({ error, data }) {
    if (data) {
      console.log('Fetched SWOT:', data);
      this.strengths = data.fields.RelationshipStrengths.value || '';
      this.opportunities = data.fields.RelationshipOpportunities.value || '';
      this.weaknesses = data.fields.RelationshipWeaknesses.value || '';
      this.threats = data.fields.RelationshipThreats.value || '';
    } else if (error) {
      console.error('Error fetching SWOT data:', error);
    }
  }

  handleChange(event) {
    const label = event.target.label.toLowerCase();
    this[label] = event.target.value;
  }

  handleSave() {
    // existing logic here
  }
  sanitizeHTML(input) {
    const div = document.createElement('div');
    div.innerHTML = input;
    return div.textContent || div.innerText || '';
  }
  get cleanedStrengths() {
    return this.sanitizeHTML(this.strengths);
  }
  
  get cleanedOpportunities() {
    return this.sanitizeHTML(this.opportunities);
  }
  
  get cleanedWeaknesses() {
    return this.sanitizeHTML(this.weaknesses);
  }
  
  get cleanedThreats() {
    return this.sanitizeHTML(this.threats);
  }
  
}