import { api, track, LightningElement } from 'lwc';
import getMileStones from '@salesforce/apex/Core_MilestoneScreenController_LEX.getMileStones';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_MileStone_LWC extends LightningElement {
    @api recordId;
    milestoneTable = [];
    show = false;
    columns = [
        { label: 'MileStone Type Name', fieldName: 'MileStoneTypeName' },
        { label: 'Case Number', fieldName: 'CaseNumber' },
        { label: 'Completion date', fieldName: 'Completiondate', type: 'date' },
        { label: 'Target Date', fieldName: 'TargetDate', type: 'date' },
        { label: 'Business Hours', fieldName: 'BusinessHours'},
        { label: 'Time Remaining in Hours', fieldName: 'TRH' },
        { label: 'Time Remaining in Days', fieldName: 'TRD'},
        { label: 'Violated', fieldName: 'Violated', type:'boolean'},
        { label: 'Completed', fieldName: 'Completed', type:'boolean'},
    ];
    connectedCallback(){
        this.getMileStones();

    }
    getMileStones(){
    getMileStones({recordId: this.recordId })
        .then(data => {
        if(data) {
            if(data.length > 0){
                this.show = false;
            } else {
                this.show = true;
            }
           
            let dataWrapper = [];
            for (let i = 0; i < data.length; i++) {
            let obj = {
                'MileStoneTypeName': (data[i].csMs != undefined) ? data[i].csMs.MilestoneType.Name : '',
                'CaseNumber': (data[i].csMs != undefined) ? data[i].csMs.Case.CaseNumber: '',
                'Completiondate': (data[i].csMs != undefined) ? data[i].csMs.CompletionDate:'',
                'TargetDate': (data[i].csMs != undefined) ?  data[i].csMs.TargetDate :'',
                'BusinessHours': data[i].businessHoursName,
                'TRH':data[i].timeRemaininginHours,
                'TRD':data[i].timeRemaininginDays,
                'Violated': (data[i].csMs.IsViolated != undefined) ?  data[i].csMs.IsViolated : '',
                'Completed': (data[i].csMs.IsCompleted != undefined) ? data[i].csMs.IsCompleted : '',

            };
           
                dataWrapper = [...dataWrapper, obj];
            
           
        }
        this.milestoneTable = dataWrapper;
        }
        console.log('core_MileStone_LWC'+this.milestoneTable);
    })
    .catch(error => {
        console.log(error);
        this.showToast('core_MileStone_LWC'+error.message);
    })

}
showToast(message){
    const event = new ShowToastEvent({
        "title": "Error",
        "message": message
    });
    this.dispatchEvent(event);
}
}