import { LightningElement,track } from 'lwc';
import getObjects from '@salesforce/apex/ObjectFieldMappingController.getAllObjects';
import getObjectFields from '@salesforce/apex/ObjectFieldMappingController.getObjectFields';
import getDRPFields from '@salesforce/apex/ObjectFieldMappingController.getDRPFields';
import saveMapping from '@salesforce/apex/ObjectFieldMappingController.saveDRPMapping';
export default class DrpMappingPage extends LightningElement {
@track drpFields = [];
    @track selectedObject;
    @track objectOptions = [];
    @track fieldOptions = [];
    @track comboDataMap = new Map();

    connectedCallback() {
        this.loaddrList();
        this.loadObjects();
    }

    loadObjects() {
        getObjects()
            .then(result => {
                this.objectOptions = result.map(obj => ({ label: obj, value: obj }));
            })
            .catch(error => {
                console.error('Error fetching objects', error);
            });
    }

    loaddrList() {
        getDRPFields()
            .then(result => {
                this.drpFields = result.map(item => ({ label: item, value: item }));
            })
            .catch(error => {
                console.error('Error fetching list', error);
            });
    }
    getOptionsWithBlank(options) {
    // Add a blank option to the beginning of the options
    return [{ label: 'None', value: '' }, ...options];
}
    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        this.loadFields();
    }

    loadFields() {
        getObjectFields({ selectedObject: this.selectedObject })
            .then(result => {
                this.fieldOptions = result.map(field => ({ label: field, value: field }));
            })
            .catch(error => {
                console.error('Error fetching fields', error);
            });
    }

    handleFieldChange(event) {
  const selectedValue = event.detail.value;
    const label = event.target.dataset.label;
    this.comboDataMap.set(label, selectedValue);
    }

    handleSave() {
        
        const comboDataArray = Array.from(this.comboDataMap.entries()).map(([label, selectedValue]) => ({
            label,
            selectedValue
        }));
        console.log('Combo Data Array:', comboDataArray);
        console.log('Selected object:', this.selectedObject);
        saveMapping({
            comboDataArray,
            selectedObject: this.selectedObject,
        })
        .then(() => {
            console.log('Mapping saved successfully');
        })
        .catch(error => {
            console.error('Error saving mapping', error);
        });
    }
    handleCancel() {
        // Reset selectedObject to blank
        this.selectedObject = '';

    // Recreate fieldOptions to make options for each field empty
    this.fieldOptions = {};

    this.drpFields.forEach((field) => {
        this.fieldOptions[field.value] = [];
    });
    
    }
}