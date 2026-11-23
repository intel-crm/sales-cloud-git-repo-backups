/* eslint-disable no-undef */
import { LightningElement } from 'lwc';


export default class Scratch extends LightningElement {

  loaded = false;

  // renderedCallback() {
  //   if (!this.loaded) {
  //     this.template.querySelector('iframe').onload = () => {
  //       this.loaded = true;
  //     }
  //   }
  // }

  handleLoaded() {
    this.loaded = true;
  }

}