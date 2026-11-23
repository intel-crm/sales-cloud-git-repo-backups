import { LightningElement, api, track } from 'lwc';

export default class TreeItem extends LightningElement {
    @api nameVisible;
    @api levelVisible;
    @api checked;
    @track _item;

    @api get item() {
        return this._item;
    }

    set item(value) {
        this._item = JSON.parse(JSON.stringify(value));
    }
    
    get hasChildItems() {
        return this.item.items && this.item.items.length > 0;
    }

    get btncls(){
        let classCSS='';
        if(this.item.found){
            classCSS=classCSS+' '+'mybutton1';
        }
        else if(this.item.levelfound){
            classCSS=classCSS+' '+'mybutton';
        }
        else{
            classCSS=classCSS+' '+'mybutton2';
        }
        return classCSS;
    }

    get foundornot(){
        if(this.checked){
            if(this.item.levelfound || this.item.downlevelfound){
                return true;
            }
            else if(this.item.found){
                this.setdownlevel(this.item);
                return true;
            }
            return false;
        }
        return true;
    }

    setdownlevel(val){
        if(val.items && val.items.length!=0) {
            for (let itemVal of val.items) {
                itemVal.downlevelfound=true;
                this.setdownlevel(itemVal)
            }
        }
    }

    get toggleIconClass(){
        let classCSS='slds-m-bottom_xxx-small ';
        if(this.item.active){
            classCSS+='toggle-icon-active';
        }
        else if(!this.item.active){
            classCSS+='toggle-icon-inactive';
        }
        return classCSS;
    }

    toggleNode() {
    this.item.expanded=!this.item.expanded;
    }

    handleSelected(event) {
        const selectedKeys = this.item.label;
        this.dispatchEvent(new CustomEvent('selected', { detail: { selectedKeys: this.item.label,level: this.item.level,lastlevel:this.item.items.length==0 },bubbles:true,composed:true }));
    }

    get ToggleIconName() {
       return this.item.expanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    get isRoot(){
        if(this.item.level==0){
            return true;
        }
    }
}