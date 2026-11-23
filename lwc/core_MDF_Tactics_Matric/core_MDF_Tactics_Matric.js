import { LightningElement, track, wire, api } from 'lwc';
import getTacticMappings from '@salesforce/apex/Core_MDF_Tactics_Matric_Controller.getTacticMappings';
import tactics from '@salesforce/label/c.Core_MDF_Activity_Tactics';
import tactic_Metrics from '@salesforce/label/c.Core_MDF_Tactic_Metrics';
import tactic_metrics_help_text from '@salesforce/label/c.Core_MDF_Tactic_Metrics_Help_Text';
import goal_Values from '@salesforce/label/c.Core_MDF_Goal_Values';
import GoalValue_for_Claim_Help_Text from '@salesforce/label/c.Core_MDF_GoalValue_for_Claim_Help_Text';
import Values_to_Date from '@salesforce/label/c.Core_MDF_Values_to_Date';
import Values_to_Date_Help_Text from '@salesforce/label/c.Core_MDF_Values_to_Date_Help_Text';
import numberError from '@salesforce/label/c.Core_MDF_KPI_Number_Error';
import labelCompleteThisFieldError from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';

export default class Core_MDF_Tactics_Matric extends LightningElement {

    // Public properties
    @api editable = false;
    @api activityId;// Activity Id
    @api recordId;//Claim Id
    @api objectName;

    // Roshan - Tactics POC
    _prefillClaimAttributes = [];
    @api
    get prefillClaimAttributes() {
        return this._prefillClaimAttributes;
    }
    set prefillClaimAttributes(value) {
        this._prefillClaimAttributes = Array.isArray(value) ? value : [];
        this.applyPrefillValues();
    }

    // Tracked properties for custom labels
    @track tactics = tactics;
    @track tactic_Metrics = tactic_Metrics;
    @track tactic_metrics_help_text = tactic_metrics_help_text;
    @track goal_Values = goal_Values;
    @track GoalValue_for_Claim_Help_Text = GoalValue_for_Claim_Help_Text;
    @track Values_to_Date = Values_to_Date;
    @track Values_to_Date_Help_Text = Values_to_Date_Help_Text;
    @track numberError = numberError;
    @track labelCompleteThisFieldError = labelCompleteThisFieldError;

    // Tracked data properties
    @track data = [];
    @track showTacticMetrics = false; // Flag to show/hide tactic metrics



    // Lifecycle hook: Called when the component is inserted into the DOM
    connectedCallback() {
        if (this.activityId || this.recordId) {
            this.fetchTacticMappings();
        } else {
            console.warn('Missing activityId or recordId');
        }
    }
    // Fetch tactic mappings from Apex
    fetchTacticMappings() {
        getTacticMappings({ activityId: this.activityId, recordId: this.recordId })
            .then((result) => {
                console.log('Apex result:::::', JSON.stringify(result));
                if (result && result.length > 0) {
                    this.showTacticMetrics = result[0].ipaOutcomeBased;

                    this.data = result.map((item) => {
                        return {
                            ...item,
                            kpis: item.kpis.map((kpi, index) => ({
                                ...kpi,
                                isFirstRow: index === 0
                            }))
                        };
                    });

                    // Roshan - Tactics POC
                    this.applyPrefillValues();

                }
                //AI PIC
                /*if (this.objectName == 'PartnerFundClaim') {
                    let tacticMetricsOnLoad = this.getAllMatricValueforRecordcreation();
                    console.log('initial tactics metrics',tacticMetricsOnLoad);
                    const tacticMetricsEvent = new CustomEvent('tacticMetricsEvent', {detail : {tacticMetricsOnLoad}});
                    this.dispatchEvent(tacticMetricsEvent);
                }*/
                
                
            })
            .catch((error) => {
                console.error('Apex error:', error);
            });
    }
     // Handle input field changes
    handleInputChange(event) {

        const inputField = event.target;
        const fieldValue = inputField.value;
        const itemIndex = event.target.dataset.item;
        const kpiIndex = event.target.dataset.kpi;

        // Validation: Negative number check OR  Decimal number check
        if (parseFloat(fieldValue) < 0 || !Number.isInteger(Number(fieldValue))) {
            inputField.setCustomValidity(numberError);
            inputField.reportValidity();
            return;
        }
        // Clear previous error
        inputField.setCustomValidity("");
        inputField.reportValidity();
        // Update the data model
        try {
            this.data[itemIndex].kpis[kpiIndex].claimAttributeValue = fieldValue;
        } catch (error) {
            console.log('Error:', error.message);

        }
    }
    // Validate all input fields
    @api validate() {
        const allInputs = this.template.querySelectorAll('lightning-input');
        let allValid = true;

        allInputs.forEach(input => {
            const value = input.value;

            if (!input.reportValidity()) {
                allValid = false;
            }

            // Negative or decimal check
            if (parseFloat(value) < 0 || !Number.isInteger(Number(value))) {
                input.setCustomValidity(numberError);
                input.reportValidity();
                allValid = false;
                return allValid;
            }

            // Clear previous error if valid
            input.setCustomValidity('');
            input.reportValidity();
        });


        if (allValid) {
            //       this.getAllMatricValueforRecordcreation(); // this is for Testing
            return allValid;
        }

    }
    // Generate payload for record creation
    @api getAllMatricValueforRecordcreation() {
        let claimAttributesObj = [];

        this.data.forEach((item) => {
            item.kpis.forEach((kpi) => {
                const tactics = item.tacticLabelForRecordCreation;
                const tacticMetric = kpi.tacticMetricsLabelForRecordCreation;
                const goalValue = kpi.activityAttributevalue;
                const valueToDate = kpi.claimAttributeValue;

                // Create object for Goal Value
                if (goalValue !== null && goalValue !== undefined && goalValue !== '') {
                    const activityAttributeObj = {
                        Core_MDF_Tactics_nm__c: tactics,
                        Core_MDF_Field_Name_nm__c: tacticMetric,
                        Core_MDF_Field_Value_nbr__c: goalValue,
                        Core_MDF_Type_nm__c: "KPI - Activity",
                        Core_MDF_Is_Active_Ind__c: true
                    }
                    if (kpi.kpiActivityAttributesId) {
                        activityAttributeObj.Id = kpi.kpiActivityAttributesId;
                    }
                    claimAttributesObj.push(activityAttributeObj);
                }
                // Create object for Value To Date
                if (valueToDate !== null && valueToDate !== undefined && valueToDate !== '') {
                    const claimAttributeObj = {
                        Core_MDF_Tactics_nm__c: tactics,
                        Core_MDF_Field_Name_nm__c: tacticMetric,
                        Core_MDF_Field_Value_nbr__c: valueToDate,
                        Core_MDF_Type_nm__c: "KPI - Claim",
                        Core_MDF_Is_Active_Ind__c: true
                    }
                    if (kpi.kpiClaimAttributesId) {
                        claimAttributeObj.Id = kpi.kpiClaimAttributesId;
                    }
                    claimAttributesObj.push(claimAttributeObj);
                }
            });
        });

        console.log('Generated Payload:', JSON.stringify(claimAttributesObj));
        return claimAttributesObj;
    }

    // Roshan - Tactics POC
    applyPrefillValues() {
        if (!this.data.length || !this._prefillClaimAttributes.length) {
            return;
        }

        this.data = this.data.map((item) => {
            const updatedKpis = item.kpis.map((kpi) => {
                const matchingClaimAttribute = this._prefillClaimAttributes.find((attribute) =>
                    attribute.Core_MDF_Type_nm__c === 'KPI - Claim' &&
                    attribute.Core_MDF_Tactics_nm__c === item.tacticLabelForRecordCreation &&
                    attribute.Core_MDF_Field_Name_nm__c === kpi.tacticMetricsLabelForRecordCreation
                );

                if (!matchingClaimAttribute) {
                    return kpi;
                }

                return {
                    ...kpi,
                    claimAttributeValue: matchingClaimAttribute.Core_MDF_Field_Value_nbr__c,
                    kpiClaimAttributesId: matchingClaimAttribute.Id || kpi.kpiClaimAttributesId
                };
            });

            return {
                ...item,
                kpis: updatedKpis
            };
        });
    }
}