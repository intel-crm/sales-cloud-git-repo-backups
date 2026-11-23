// apexWireMethodToFunction.js
import { LightningElement, wire, track,api } from 'lwc';
import InsertSObjects from '@salesforce/apex/CruderCntrl.InsertSObjects';
import UpdateSObjects from '@salesforce/apex/CruderCntrl.UpdateSObjects';
import ReadSObjects from '@salesforce/apex/CruderCntrl.ReadSObjects';
import DeleteSObjects from '@salesforce/apex/CruderCntrl.DeleteSObjects';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';

const DELAY = 300;

export default class ApexWireMethodToFunction extends NavigationMixin(LightningElement) {
@api inputSObjectListSent;
//@api insertSObjectListSent;
 @api CruderCntrl  =[];    
 @api message;    
 @api operation;
 @track spinnerOn = false;

            connectedCallback() {
               if(this.operation==='insert'){
                this.handleValueChangeInsert();
               }

               if(this.operation ==='Update'){
                this.handleValueChangeUpdate();
               }

               if(this.operation ==='Read'){
                this.handleValueChangeRead();
               }
               if(this.operation ==='Delete'){
                this.handleValueDelete();
               }
            }
@api handleValueChangeInsert() {
    console.log('in crud12Insert'+JSON.stringify(this.inputSObjectListSent));
    
        InsertSObjects ( { inputSObjectList: this.inputSObjectListSent } )
        .then(results => {
    if(results!=undefined){
        console.log('ResultInsertIncrud ', JSON.stringify(results));
        this.results.forEach(function (value){
            this.CruderCntrl.push(value);
        })
        console.log( this.CruderCntrl.length);
        console.log( this.CruderCntrl[3].sObjID);
        return refreshApex(this.CruderCntrl);
    }       
        })
        .catch(error => {
            console.error('Error in Insert ', error);
        })    }


    @api handleValueChangeUpdate(){
        console.log('in crud12Update'+JSON.stringify(this.inputSObjectListSent));
        UpdateSObjects( { inputSObjectList: this.inputSObjectListSent } )
        .then(results => {
        if(results!=undefined){
            console.log('ResultUpdate ', JSON.stringify(results));
            this.results.forEach(function (value){
                this.CruderCntrl.push(value);
            })
            console.log( this.CruderCntrl.length);
            console.log( this.CruderCntrl[3].sObjID);
            return refreshApex(this.CruderCntrl);
        }       
    })
    .catch(error => {
            })    
    } 

    @api handleValueChangeRead(){
        console.log('in crud12Read'+JSON.stringify(this.inputSObjectListSent));
        ReadSObjects( { query: this.inputSObjectListSent } )
        .then(results => {
        if(results!=undefined){
            console.log('ResultRead ', JSON.stringify(results));
            console.log('hi.... ');
            this.results.forEach(function (value){
                this.CruderCntrl.push(value);
            })
            console.log( this.CruderCntrl.length);
            console.log( this.CruderCntrl[3].sObjID);
            return refreshApex(this.CruderCntrl);
        }       
    })
    .catch(error => {
            })    
    } 
    handleValueDelete(){
        console.log('in crudDelete'+JSON.stringify(this.inputSObjectListSent));
        DeleteSObjects( { inputSObjectList: this.inputSObjectListSent } )
        .then(results => {
        if(results!=undefined){
            console.log('ResultDelete ', JSON.stringify(results));
            console.log('hi.... ');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted',
                    variant: 'success'
                })
            );
            console.log('hi2.... ');

            this.spinnerOn = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'Product_Access_Request'
                }
            }
            );
            console.log('hi3.... ');
            this.results.forEach(function (value){
                this.CruderCntrl.push(value);
            })
           // console.log( this.CruderCntrl.length);
            //console.log( this.CruderCntrl[3].sObjID);

            
           
            return refreshApex(this.CruderCntrl);
        }       
    })
    .catch(error => {
        console.log('hi34.... ');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error deleting record',
                message:'Error deleting record',
                variant: 'error'
            })
        );
        this.spinnerOn = false;
        console.error('core_IPS_DetailSectionUtility ::: Error in deleting MAP Record. Error : ', JSON.stringify(error));
            })    
    } 
}