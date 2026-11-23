import { LightningElement, track } from 'lwc';
import getObjects from '@salesforce/apex/ObjectFieldMappingController.getAllObjects';
import getObjectFields from '@salesforce/apex/ObjectFieldMappingController.getObjectFields';
import getDRFields from '@salesforce/apex/ObjectFieldMappingController.getDRFields';
import getDRPFields from '@salesforce/apex/ObjectFieldMappingController.getDRPFields';
import saveMapping from '@salesforce/apex/ObjectFieldMappingController.saveMapping';
import saveDRPMapping from '@salesforce/apex/ObjectFieldMappingController.saveDRPMapping';

export default class CombinedComponent extends LightningElement {
    // Common properties for both Lightning Cards
    @track selectedObjectDR;
    @track objectOptionsDR = [];
    @track fieldOptionsDR = [];
    @track comboDataMapDR = new Map();

    @track selectedObjectDRP;
    @track objectOptionsDRP = [];
    @track fieldOptionsDRP = [];
    @track comboDataMapDRP = new Map();

    // Properties for the first Lightning Card (Design Registration Mapping)
    @track drFields = [];

    // Properties for the second Lightning Card (Design Registration Product Mapping)
    @track drpFields = [];

    connectedCallback() {
        // Load common objects for both Lightning Cards
        this.loadObjects();
        this.loaddrList();
    }

    loadObjects() {
        getObjects()
            .then(result => {
                this.objectOptionsDR = result.map(obj => ({ label: obj, value: obj }));
                this.objectOptionsDRP = result.map(obj => ({ label: obj, value: obj }));
            })
            .catch(error => {
                console.error('Error fetching objects', error);
            });
    }

    loaddrList() {
        // Load DR Fields
        getDRFields()
            .then(result => {
                this.drFields = result.map(item => ({ label: item, value: item }));
            })
            .catch(error => {
                console.error('Error fetching list', error);
            });

        // Load DRP Fields
        getDRPFields()
            .then(result => {
                this.drpFields = result.map(item => ({ label: item, value: item }));
            })
            .catch(error => {
                console.error('Error fetching list', error);
            });
    }

    handleObjectChangeDR(event) {
        const selectedobject = event.detail.value;

        this.loadFieldsDR(selectedobject.split('|')[1]);
    }

    handleObjectChangeDRP(event) {
        const selectedfield = event.detail.value;
        this.loadFieldsDRP(selectedfield.split('|')[1].trim());
    }

    loadFieldsDR(selectedobject) {
        getObjectFields({ selectedObject: selectedobject })
            .then(result => {
                this.fieldOptionsDR = result.map(field => ({ label: field, value: field }));
            })
            .catch(error => {
                console.error('Error fetching fields', error);
            });
    }

    loadFieldsDRP(selectedfield) {
        getObjectFields({ selectedObject: selectedfield })
            .then(result => {
                this.fieldOptionsDRP = result.map(field => ({ label: field, value: field }));
            })
            .catch(error => {
                console.error('Error fetching fields', error);
            });
    }

    handleFieldChangeDR(event) {
        const selectedValue = event.detail.value;
        const label = event.target.dataset.label;
        this.comboDataMapDR.set(label, selectedValue);
    }

    handleFieldChangeDRP(event) {
        const selectedValue = event.detail.value;
        const label = event.target.dataset.label;
        this.comboDataMapDRP.set(label, selectedValue);
    }

    handleSaveDR() {
        const comboDataArray = Array.from(this.comboDataMapDR.entries()).map(([label, selectedValue]) => ({
            label,
            selectedValue
        }));
        console.log('Combo Data Array DR:', comboDataArray);
        console.log('Selected object DR:', this.selectedObjectDR);
        saveMapping({
            comboDataArray,
            selectedObject: this.selectedObjectDR,
        })
        .then(() => {
            console.log('Mapping saved successfully');
        })
        .catch(error => {
            console.error('Error saving mapping', error);
            });
    }

    handleSaveDRP() {
        const comboDataArray = Array.from(this.comboDataMapDRP.entries()).map(([label, selectedValue]) => ({
            label,
            selectedValue
        }));
        console.log('Combo Data Array DRP:', comboDataArray);
        console.log('Selected object DRP:', this.selectedObjectDRP);
        saveDRPMapping({
            comboDataArray,
            selectedObject: this.selectedObjectDRP,
        })
        .then(() => {
            console.log('DRP Mapping saved successfully');
        })
        .catch(error => {
            console.error('Error saving DRP mapping', error);
        });
    }

    handleCancelDR() {
        // Reset selectedObject to blank
        this.selectedObjectDR = '';

        // Recreate fieldOptions to make options for each field empty
        this.fieldOptionsDR = {};

        // Reset DR fields
        this.drFields.forEach((field) => {
            this.fieldOptionsDR[field.value] = [];
        });
    }

    handleCancelDRP() {
        // Reset selectedObject to blank
        this.selectedObjectDRP = '';

        // Recreate fieldOptions to make options for each field empty
        this.fieldOptionsDRP = {};

        // Reset DRP fields
        this.drpFields.forEach((field) => {
            this.fieldOptionsDRP[field.value] = [];
        });
    }
}