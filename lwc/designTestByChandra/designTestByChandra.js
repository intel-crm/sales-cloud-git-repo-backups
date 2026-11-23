import { LightningElement,track,api } from 'lwc';

export default class Core_IPS_caseCreation_Form extends LightningElement {
    _selected = [];

  get options() {
      return [
          { label: 'Product 1', value: 'one' },
          { label: 'Product 2', value: 'two' },
          { label: 'Product 3', value: 'three' },
          { label: 'Product 4', value: 'four' },
          { label: 'Product 5', value: 'five' },
          { label: 'Product 6', value: 'six' },
      ];
  }

  get selected() {
      return this._selected.length ? this._selected : 'none';
  }

  handleChange(e) {
      this._selected = e.detail.value;
  }
}