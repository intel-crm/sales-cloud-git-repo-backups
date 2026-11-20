import {LightningElement, api} from 'lwc';
import NavigationButtons from '@salesforce/resourceUrl/NavigationButtons';
import { loadStyle } from 'lightning/platformResourceLoader'

/**
 * The `QuanticNumberButton` component is used internally to display a button in a set of buttons with numeric labels.
 * @fires CustomEvent#select
 * @category Utility
 * @example
 * <c-quantic-number-button number="1" selected onselect={select}></c-quantic-number-button>
 */
export default class QuanticNumberButton extends LightningElement {
  /**
   * The number to display as button label.
   * @api
   * @type {number}
   */
  @api number;
  /**
   * The selected number in the set of buttons.
   * @api
   * @type {number}
   */
  @api selected;
  /**
   * The value for aria-label.
   * @api
   * @type {string}
   */
  @api ariaLabelValue;
  
   @api isFirstButton;
  showFirstButton;
  maxnumber;
  tempvallue;
  
 connectedCallback(){
    loadStyle(this, NavigationButtons);
    this.maxnumber = this.number;
    if(this.isFirstButton == "true"){
      this.showFirstButton = true;
      this.tempvallue = this.number;
    }
    else if (this.isFirstButton == "false"){
      this.showFirstButton = false;
      sessionStorage.setItem('Intialvalue',this.number);
    }
  }

  get isPressed() {
    return `${this.selected}`;
  }

  get buttonClasses() {
    const classes = ['slds-button', 'slds-m-left_xx-small'];
    classes.push(
      this.selected ? 'slds-button_brand' : 'slds-button_outline-brand'
    );
    return classes.join(' ');
  }
    get variant() {
    return this.selected ? 'brand' : 'brand-outline';
  }


  select(event) {
  
    if(parseInt(event.target.value) > parseInt(sessionStorage.getItem('Intialvalue'))) {
      this.selected = parseInt(sessionStorage.getItem('Intialvalue'));
      this.number = parseInt(sessionStorage.getItem('Intialvalue'));
      this.dispatchEvent(new CustomEvent('select', {detail: this.number}));
    }else {
    this.selected = parseInt(event.target.value);
    this.number = parseInt(event.target.value);
    this.dispatchEvent(new CustomEvent('select', {detail: this.number}));
    }
}
}