import { LightningElement, track, wire, api } from 'lwc';
import findSelectedUsers from '@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedUsers';
import findSelectedUsersNew from '@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedUsersNew';

export default class DualListboxSimple extends LightningElement {
    @track _selected = [];
    @api searchKey;
    @track mapData= [];
    @track availableMapData= [];

    @wire(findSelectedUsers,{accountId: '$searchKey'}) 
    userWrapper({data, error}){
        window.console.log('In find selected users');
        window.console.log(JSON.stringify(data));
        if (data) {
            for(let key in data){
                if (data.hasOwnProperty(key)) { 
                this.mapData.push({label:data[key], value:key}); //Here we are creating the array to show on UI.
                }
            }
        }
        else if(error) {
            window.console.log(error);
        }
    }

    @wire(findSelectedUsersNew,{accountId: '$searchKey'}) 
    userWrapper1({data, error}){
        window.console.log('In find selected users NEW');
        window.console.log(JSON.stringify(data));
        if (data) {
            for(let key in data){
                if (data.hasOwnProperty(key)) { 
                    window.console.log('Key::'+key);
                this.availableMapData.push({label:data[key], value:key});
                this._selected.push(key); //Here we are creating the array to show on UI.
                window.console.log('SelectedFromApex::_selected::'+this._selected);
                window.console.log('SelectedFromApex::availableMapData::'+this.availableMapData);
                }
            }
        }
        else if(error) {
            window.console.log(error);
        }
    }

    selectedRecord(event){
        window.console.log('Inside selected Record');
        this.searchKey = event.detail.recordId;
        window.console.log('SelectedAtLast::'+this._selected);
    }       


   /* get options() {
        let tempArray = [];
        tempArray.push({ label: 'userWrapper.[i].Name',value: 'rtnValue[i].Name'});
        //this.options = tempArray;
        return tempArray;
    } */

    get selected() {
        window.console.log('Inside get selected');
        window.console.log('SelectedFromApex::availableMapData::'+this.availableMapData);
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(e) {
        window.console.log('Inside handleChange');
        this._selected = e.detail.value;
        window.console.log('SelectedFromApex::availableMapData::'+this.availableMapData);
    }
}