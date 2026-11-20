import { LightningElement, track, api } from 'lwc';

export default class Core_MDF_CCP_lwcMultiselectPicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api value;
    @api options = [];
    @api parentrecord;
    @api fieldnameapi;
    @track dropdown = false;
    @api disabled = false;
    @api multiSelect = false;
    @api selectedOptions = [];
    @track values;
    @track optionData;
    @track searchString;
    @track noResultMessage;

    connectedCallback() {
        this.dropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        if(optionData){
            for(var i = 0; i < optionData.length; i++) {
                optionData[i].isVisible = true;
            }
        }
        var values = this.value ? (JSON.parse(JSON.stringify(this.value))) : null;
     
        if(values) {
            var count = 0;
            for(var i = 0; i < optionData.length; i++) {
                    if(values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }  
            }
                this.searchString = count + ' Option(s) Selected';
          
        }
        this.values = values;
        this.optionData = optionData;
    }

    selectOptions() {
        if(this.disabled == false){
            console.log('onclick');
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            console.log('selectOptions',options);
            for(var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
                console.log('options[i].isVisible',options[i].isVisible);
                console.log('optionsOnClick',options[i]);
            }
            if(options.length > 0) {
                console.log('OptionsLength',options.length);
                this.dropdown = true;
            }
            this.optionData = options;
            console.log('OnclickOptionData',this.optionData);
        }
    }

    optionsFilter(event) {
        this.searchString = event.target.value;
        console.log('this.searchString',this.searchString);
        if( this.searchString && this.searchString.length > 0 ) {
            if(this.searchString.length >= 2) {
                for(var i = 0; i < this.optionData.length; i++) {
                    if(this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        console.log('equal',this.optionData[i].label.toLowerCase().trim());
                        this.optionData[i].isVisible = true;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
            }
            this.dropdown = true;
        } else {
            this.dropdown = false;
        }
    }

    itemSelect(event) {
        var selectedVal = event.currentTarget.dataset.id;
        console.log('selectedVal',selectedVal);
        if(selectedVal) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            console.log('options',options);
            for(var i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {
                        if(this.values != null && this.values != '' && this.values.includes(options[i].value)) {
                            let removedValue = [];
                            removedValue = this.values.split(';');
                            console.log('RemoveVal',removedValue);
                            var selectedvalues = '';
                            var isFirst = true;
                            removedValue.forEach(listVal =>{
                                if(listVal == selectedVal || listVal == undefined){

                                }
                                else{
                                // selectedvalues = selectedvalues+listVal+';';
                                    if(isFirst == true){
                                        selectedvalues = selectedvalues+listVal;
                                        isFirst = false;
                                    }
                                    else{
                                        selectedvalues = selectedvalues+';'+listVal;
                                    }
                                }
                            })
                                this.values = selectedvalues;
                        } else {
                            if(this.values == ''){
                                this.values = this.values+options[i].value;
                            }
                            else if(this.values == null){
                                this.values = options[i].value;
                            }
                            else{
                           this.values = this.values+';'+options[i].value;
                            }
                        }
                        options[i].selected = options[i].selected ? false : true;   
                }
                if(options[i].selected) {
                    count++;
                }
            }
            console.log('selectedValPush',this.values);
            this.optionData = options;
            console.log('optionData',this.optionData);
                this.searchString = count + ' Option(s) Selected';

                const eventPick = new CustomEvent('multiselectpicklistchanged', {
                    bubbles : true,
                    composed : true,
                    cancelable : true,
                    detail: {
                        data : {
                            selectedValue : this.values,
                            relatedRecord : this.parentrecord,
                            fieldnameapi : this.fieldnameapi,
                        }
                    }
                });
                this.dispatchEvent(eventPick);
                this.dropdown = false;
        }
    }

    blurOption() {
      /*  var previousLabel;
        var count = 0;
        console.log('OnBlur');
        for(var i = 0; i < this.optionData.length; i++) {
            if(this.optionData[i].value === this.values) {
                previousLabel = this.optionData[i].label;
            }
            if(this.optionData[i].selected) {
                count++;
            }
        }
            this.searchString = count + ' Option(s) Selected'; */
            this.dropdown = false;
            this.dispatchEvent(new CustomEvent('select', {
                detail: {
                    'payloadType' : 'multi-select',
                    'payload' : {
                        'values' : this.values
                    }
                }
            }));
    }

    removePill(event) {
        console.log('Event',event);
        var value = event.currentTarget.name;
        console.log('RemovePillValue',value);
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for(var i = 0; i < options.length; i++) {
            if(options[i].value === value) {
                options[i].selected = false;
               let removedValue = [];
               removedValue = this.values.split(';');
               console.log('RemoveVal',removedValue);
               var selectedvalues = '';
               var isFirst = true;
               removedValue.forEach(listVal =>{
                if(listVal == value || listVal == undefined){

                }
                else{
                    if(isFirst == true){
                        selectedvalues = selectedvalues+listVal;
                        isFirst = false;
                    }
                    else{
                        selectedvalues = selectedvalues+';'+listVal;
                    }
                }
            })
                this.values = selectedvalues;
                console.log('removepill',this.values);
            }
            if(options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
            this.searchString = count + ' Option(s) Selected';

                const eventPick = new CustomEvent('multiselectpicklistchanged', {
                    bubbles : true,
                    composed : true,
                    cancelable : true,
                    detail: {
                        data : {
                            selectedValue : this.values,
                            relatedRecord : this.parentrecord,
                            fieldnameapi : this.fieldnameapi,
                        }
                    }
                });
                this.dispatchEvent(eventPick);
    } 
 
}