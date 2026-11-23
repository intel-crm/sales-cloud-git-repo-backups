import { LightningElement ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PrmObjectListView extends NavigationMixin(LightningElement)  {
    input;
    @track navItems = [
        { label: 'Home', value: 'home' },
        { label: 'Acnts', value: 'Account' },
        { label: 'Contacts', value: 'Contact' },
        { label: 'Opportunities', value: 'Opportunity' }
        // Add more items as needed
    ];

    navigateToPage(event){
        console.log('cas');
         this.input  = event.target.value;
         console.log('cas'+this.input);
         if(this.input === 'home')
         {

         }
         else{
        const pageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: event.target.value,
                actionName: 'list'
            }
        };
        this[NavigationMixin.Navigate](pageRef);
    }
    }
}