import { LightningElement, track, api, wire } from 'lwc';
import getSurveyList from '@salesforce/apex/Core_IPS_CaseSurveyFeedbackController.getSurveyFeedbackList';
import CURRENTUSERID from '@salesforce/user/Id';
export default class caseSurveyFeedbackList extends LightningElement {

    @api recordId;  
    @track isDataAvailable = false;
    @track errors;
    @track surveyResults;
    @track recordsToDisplay = 10;
    @track createdDate;
    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 30;
    heightInRem = 20;
    userId = CURRENTUSERID;

    //wrapper variables to display columns 
    @track column = [{
        label: 'Environment Detail Question',
        fieldName: 'surveyQuestion',       
        },
        {
            label: 'Environment Detail Answer',
            fieldName: 'surveyAnswer'
        },
        {
            label: 'Created Date',
            fieldName: 'createdDate'        
        },
    ];

    //call apex method to retrieve Case Survey Feedback
    @wire(getSurveyList, { caseId: '$recordId' })
    wiredSurvey({ data, error }) {
        if (data) {
            this.isDataAvailable = true;
            this.errors = undefined;
            let dataWrapper = [];
            
			for(let i=0;i<data.length;i++) {
                let dt2 = data[i].CreatedDate;
                this.createdDate = new Date(dt2).toLocaleString();
                console.log('this.createdDate : ',this.createdDate);
				let obj = {
					'surveyQuestion' : data[i].Core_IPS_Question__c,
					'surveyAnswer' : data[i].Core_IPS_Answer__c,
					'createdDate' : this.createdDate
				};
				dataWrapper = [...dataWrapper, obj];
			}
            this.surveyResults = dataWrapper;            
        }
        if (error) {
            this.surveyResults = undefined;
            this.errors = error;
        }
    }
  
}