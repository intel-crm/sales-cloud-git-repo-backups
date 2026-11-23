import { LightningElement ,wire,track} from 'lwc';
import UserId from '@salesforce/user/Id';
import fetchrecords from '@salesforce/apex/ShowBlades.fetchrecords';
export default class GetID extends LightningElement {
   // @track currentId ;
   // currentId = UserId ;

@wire (fetchrecords ,{Id : UserId})
display;

}