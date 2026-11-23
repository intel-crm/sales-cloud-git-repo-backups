import { LightningElement, track, api } from 'lwc';

/** Documentation for ipamultiSelectPicklist Component
 *
 * @property {object} values this holds the filter options for each filter
 * @property {String} picklistlabel the placeholder for each filter
 * @property {object} Key key for template loop of options
 */
export default class App extends LightningElement {
    @api
    values = [];

    @api
    picklistlabel;

    @api
    key;

    /**
     * boolean variable defines whether to show the dropdown or not for filter
     *
     * @private
     * @type {boolean}
     */
    showdropdown;

    /**
     * keeps track of select event on each option and stores them in an array
     *
     * @private
     * @type {object}
     */
    @track selectedvalues = [];

    /**
     * keeps track of select event and captures the category id
     *
     * @private
     * @type {object}
     */
    @track catselectedId = [];

    /**
     * keeps track of select event and captures the specification id
     *
     * @private
     * @type {object}
     */
    @track specselectedId = [];

    /**
     * keeps track of select event and captures the specification values id
     *
     * @private
     * @type {object}
     */
    @track specvalselectedId = [];

    /**
     * When the cursor is moved out of filter,closes the filter dropdown
     * 
     * @private
     */
    handleleave() {
        const sddcheck= this.showdropdown;
        if(sddcheck) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    /**
     * Connected callback - updates picklist label to displayed in each filter
     *
     * @private
     */
    connectedCallback(){
        this.picklistlabel = this.values[0].label;
    }

    /**
     * Fetches the values which are selected from the child component when select event occurs
     *
     * @private
     */
    fetchSelectedValues() {
        this.selectedvalues = [];
        this.catselectedId =[];
        this.specselectedId = [];
        this.specvalselectedId = [];
        this.template.querySelectorAll('c-ipa-picklist-value').forEach(
            (element) => {
                if(element.selected){
                    this.selectedvalues.push(element.value);
                    if(element.objectname === 'PMP_Category__c') {
                        this.catselectedId.push(element.id.substring(0, 18));
                        this.dispatchEvent(new CustomEvent('selection', {
                            detail: {
                                sevalues:this.selectedvalues,
                                sevalid:this.catselectedId,
                                obj:element.objectname,
                            },
                          }));
                    } else if(element.objectname === 'PMP_Specification__c') {
                        this.specselectedId.push(element.id.substring(0, 18));
                        this.dispatchEvent(new CustomEvent('selection', {
                            detail: {
                                sevalues:this.selectedvalues,
                                sevalid:this.specselectedId,
                                obj:element.objectname,
                            },
                          }));
                    } else {
                        this.specvalselectedId.push(element.id.substring(0, 18));
                        this.dispatchEvent(new CustomEvent('selection', {
                            detail: {
                                sevalues:this.selectedvalues,
                                sevalid:this.specvalselectedId,
                                obj:element.objectname,
                            },
                          }));
                    }
                }
            }
        );
        this.refreshOrginalList();
    }

    /**
     * Refreshes the options to be displayed when select, unselect or clear all occurs
     * 
     * @private
     */
    refreshOrginalList() {
        const picklistvalues = this.values.map((eachvalue) => ({...eachvalue}));
        picklistvalues.forEach((element, index) => {
            if(this.selectedvalues.includes(element.value)){
                picklistvalues[index].selected = true;
            }else{
                picklistvalues[index].selected = false;
                if(picklistvalues[index].objname === 'PMP_Category__c') {
                    this.dispatchEvent(new CustomEvent('unselect', {
                        detail: {
                            remval:picklistvalues[index].value,
                            remid:picklistvalues[index].id,
                            obj:picklistvalues[index].objname,
                        }, 
                      }));
                } else if(element.objectname === 'PMP_Specification__c') {
                    this.dispatchEvent(new CustomEvent('unselect', {
                        detail: {
                            remval:picklistvalues[index].value,
                            remid:picklistvalues[index].id,
                            obj:picklistvalues[index].objname,
                        }, 
                      }));
                } else {
                    this.dispatchEvent(new CustomEvent('unselect', {
                        detail: {
                            remval:picklistvalues[index].value,
                            remid:picklistvalues[index].id,
                            obj:picklistvalues[index].objname,
                        }, 
                      }));
                }
            }
        });
        this.values = picklistvalues;
    }

    /**
     * When any filter is clicked determines whether to show or close the dropdown
     * 
     * @private
     */
    handleShowdropdown() {
        const sdd = this.showdropdown;
        if(sdd){
            this.showdropdown = false;
            this.fetchSelectedValues();
        }else{
            this.showdropdown = true;
        }
    }

    /**
     * Called by the parent component to clear all selections
     * 
     * @private
     */
    @api
    clearselections() {
    const picklistvaluesremoval = this.values.map((eachvalue) => ({...eachvalue}));
    picklistvaluesremoval.forEach((element, index) => {
        picklistvaluesremoval[index].selected = false;
            });
    this.values = picklistvaluesremoval;
    }
}