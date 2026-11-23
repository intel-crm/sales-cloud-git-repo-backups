import { LightningElement,wire,track,api } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDescriptiveFeatureData from '@salesforce/apex/Core_DescriptiveFeaturesUtility.getDescriptiveFeatureData';

const dataTableColumns = [
    { label: 'Intel Platform', fieldName: 'intelPlatform',initialWidth: 200,sortable: "true" },
    { label: 'Platform BU', fieldName: 'platformBU' ,initialWidth: 200},
    { label: 'Feature Type', fieldName: 'featureType' ,initialWidth: 200,sortable: "true" },
    { label: 'Feature Value', fieldName: 'featureValue' ,initialWidth: 200 },
    { label: 'Active', fieldName: 'isActive' ,initialWidth: 100 }
    
];

export default class Core_DescriptiveFeaturesUtilityLWC extends LightningElement {

    @track showTable = true;
    @track loaded = false;
    @track dataList = [];
    @track rowOffset = 0;
    @track dataTableColumns = dataTableColumns ;


    connectedCallback() {
    
    getDescriptiveFeatureData()
    .then(result =>{

        this.dataList = result.descriptiveFeatures;

    })
    .catch(error =>{
        this.errorMsg = error;
            this.toastTitle = "Failure";
            this.toastMessage = JSON.stringify(error.body.message);
            this.toastVariant = "error";
            
          

    });

    }

}