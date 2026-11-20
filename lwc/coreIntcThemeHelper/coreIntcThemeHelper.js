/** @module coreIntcThemeHelper */

/**
 * Use this method to set root level scoped CSS [variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties).
 *
 * When setting CSS variables used in the <a href="coreIntcPageLayoutFull.html#cssVariables">coreIntcPageLayoutFull</a>, they should be set
 * as early in the component life-cycle as possible. This generally means calling the setCssVariables method in your component's connectedCallback method.
 *
 * Since Salesforce communities are a Single Page App (SPA), once these variables are set, they do not need to be set again unless the
 * site is reloaded, or you want to change values on different pages.
 *
 * @example
 * // Need to import the setCssVariables method
 * import { LightningElement } from 'lwc';
 * import { setCssVariables } from 'c/coreIntcThemeHelper';
 *
 * export default class myComponent extends LightningElement {
 *   // Example setting even and odd striping colors used in the layouts
 *   connectedCallback() {
 *     setCssVariables({
 *       coreIntcFullBladeEvenBackgroundColor: '#cccccc',
 *       coreIntcFullBladeOddBackgroundColor: '#aaaaaa',
 *     });
 *   }
 * }
 *
 * @param {object} config  An object with key:value pairs for setting root scope CSS variables. The key will be the
 * variable's [name](coreIntcPageLayoutFull.html#cssVariables), and the value will be the variable's value.
 * @public
 */
const setCssVariables = function setCssVariables(config) {
  window.focus('setCssVariables', config);
};



// eslint-disable-next-line
// eslint-disable-next-line import/prefer-default-export
export { setCssVariables };