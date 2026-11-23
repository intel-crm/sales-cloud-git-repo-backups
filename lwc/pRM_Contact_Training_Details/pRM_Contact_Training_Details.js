import { LightningElement, track, wire } from 'lwc';
import getContactTrainingCredits from '@salesforce/apex/PRM_External_Objects_Data.getContactTrainingCredits';
import getPageURL from '@salesforce/apex/PRM_External_Objects_Data.getPageURL';
import header from '@salesforce/label/c.PRM_Training_Dashboard_Label';
import measurementPeriodheader from '@salesforce/label/c.PRM_Measurement_Period';
import currentMeasurementPeriod from '@salesforce/label/c.PRM_Current_measurement_period';
import previousMeasurementPeriod from '@salesforce/label/c.PRM_Previous_Measurement_Period';
import dashcurrMeasurementPeriod from '@salesforce/label/c.PRM_Dash_MeasurementPeriod_Current';
import dashprevMeasurementPeriod from '@salesforce/label/c.PRM_Dash_MeasurementPeriod_Prev';
import link from '@salesforce/label/c.PRM_Training_Report_Link';
export default class PRM_Contact_Training_Credits extends LightningElement {
    headerLbl = header;
    linkLbl = link;
    @track timePeriodValue= currentMeasurementPeriod;
    @track trainingDetails;
    @track credits;
    @track error;
    @track error2;
    @track pageUrl;
    @track spinner = false;
    label = {
        currentMeasurementPeriod,
        previousMeasurementPeriod,
        dashcurrMeasurementPeriod,
        dashprevMeasurementPeriod,
        measurementPeriodheader
    };
    measurementoptions = [
        { value: 	currentMeasurementPeriod, label: 	dashcurrMeasurementPeriod},
        { value: 	previousMeasurementPeriod, label: 	dashprevMeasurementPeriod}
        
    ];
    async connectedCallback() {
        console.log('inside connected');
        this.spinner = true;
        getPageURL().then((result) => {
            console.log('page url'+this.pageUrl);
            this.pageUrl = result;
            this.error2 = undefined;
        }).catch((err) => {
            console.log('error url'+this.pageUrl);
            this.error2 = err;
            this.pageUrl = '';
        });
    }
    renderedCallback(){
        this.handleSearch();
    }

    changeTimeperiod(event){
        this.timePeriodValue = event.target.value;
        this.spinner = true;
        console.log('timePeriodValue---->'+this.timePeriodValue);
        this.handleSearch();
    }
    async handleSearch(){
        try{
            this.trainingDetails = await getContactTrainingCredits({trainingperiod:this.timePeriodValue});
            console.log('trainingdetails---->'+this.trainingDetails);
            this.spinner = false;
        }
        catch(error){
            this.spinner = false;
            console.log(error.body.message);
        }
    }

}