import { LightningElement, track,api } from 'lwc';
const columns = [
    { label: 'Clone', fieldName: 'Clone', type: 'checkbox' },
    { label: 'TEAM MEMBER', fieldName: 'StageName', type: 'text' },
    { label: 'ACCESS LEVEL', fieldName: 'CloseDate', type: 'text' },
    { label: 'MEMBER ROLE', fieldName: 'TeamMemberRole', type: 'text' },
    { label: 'TEAM MEMBER REGION', fieldName: 'Core_Team_Member_Geo__c', type: 'text' },
];
export default class Renewal_Opportunity extends LightningElement {
   columns = columns;
   @track oppTeamMembers;
   @api recordId;
   /*
   // Fetching the opportunity list
@wire(fetchOppTeamMembers,{searchText:'$searchText'})
wiredOppTeamMembers(result){
    if(result.data){
// opportunity variable will contain the data that we are recieving
        this.oppTeamMembers = result.data
    }
    else if(result.error){
        console.log('Error fetching opportunities',error)
    }
}*/

}