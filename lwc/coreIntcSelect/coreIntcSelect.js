import { LightningElement, api, track } from 'lwc';

/**
 * A reusable component for a select input. It includes an asterisk indicator if the select is required, as well as a message
 * area if a value is not selected.
 *
 * ### Notes:
 * * If no option has selected = true, and there is no <code>value</code> set, then the first option will be shown by default.
 * * Whenever the value is changed, a change event is thrown with the new value.
 * * If a select is required, the <code>requiredOptionLabel</code> will be added to the select as the first option.
 * * The <code>requiredErrorText</code> value is displayed when the user has not selected a value for a required select. This text
 *   does not display initially, but will display after the value has been changed.
 *
 * <div id="core-examples" sf-attr="c-coreintcselect_coreintcselect">
 *  <demo-core-intc-select show1="true"></demo-core-intc-select>
 *  <demo-core-intc-select show2="true"></demo-core-intc-select>
 *  <demo-core-intc-select show3="true"></demo-core-intc-select>
 *  <demo-core-intc-select show4="true"></demo-core-intc-select>
 *  <demo-core-intc-select show5="true"></demo-core-intc-select>
 *  <demo-core-intc-select show6="true"></demo-core-intc-select>
 * </div>
 *
 * @example
 * // JavaScript component example 1 - 6
 * // All examples reference this JavaScript
 * class MySelectComponent {
 *   optionsA = [
 *     {
 *       label: 'Arizona',
 *       value: 'AZ',
 *     },
 *     {
 *       label: 'California',
 *       value: 'CA',
 *       selected: true,
 *     },
 *     {
 *       label: 'Oregon',
 *       value: 'OR',
 *     },
 *   ];
 *
 *   optionsB = [
 *     {
 *       label: 'Arizona',
 *       value: 'AZ',
 *     },
 *     {
 *       label: 'California',
 *       value: 'CA',
 *       selected: true,
 *     },
 *     {
 *       label: 'Oregon',
 *       value: 'OR',
 *     },
 *   ];
 *
 *   checkValidity() {
 *     const coreSelect = this.template.querySelector('c-core-intc-select');
 *     if (coreSelect) {
 *       console.log(coreSelect.checkValidity());
 *     }
 *   }
 *
 *   reportValidity() {
 *     const coreSelect = this.template.querySelector('c-core-intc-select');
 *     if (coreSelect) {
 *       console.log(coreSelect.reportValidity());
 *     }
 *   }
 * }
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Not required -->
 * <c-core-intc-select name="example1" label="States" aria-label="Choose a state" options={optionsA}></c-core-intc-select>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Required -->
 * <c-core-intc-select name="example2" label="States" aria-label="Choose a state" options={optionsA} required></c-core-intc-select>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Disabled -->
 * <c-core-intc-select name="example3" label="States" aria-label="Choose a state" options={optionsA} disabled></c-core-intc-select>
 *
 * @example
 * <!-- HTML component example 4 -->
 * <!-- No selected option, so defaults to first option -->
 * <c-core-intc-select name="example4" label="States" aria-label="Choose a state" options={optionsB}></c-core-intc-select>
 *
 * @example
 * <!-- HTML component example 5 -->
 * <!-- No selected option, but value specified -->
 * <c-core-intc-select name="example5" label="States" aria-label="Choose a state" options={optionsB} value="OR"></c-core-intc-select>
 *
 * @example
 * <!-- HTML component example 6 -->
 * <!-- No selected option, no value, but required -->
 * <c-core-intc-select name="example6" label="States" aria-label="Choose a state" options={optionsB} required></c-core-intc-select>
 *
 *
 * @augments LightningElement
 * @property {string} [ariaLabel] Text used for the aria accessibility label.
 * @property {boolean} [disabled] Indicates if the select should be disabled.
 * @property {boolean} [hideLabel] Indicates if the label should be hidden.
 * @property {string} [label=''] Text to use as the label.
 * @property {string} name Name to use for form select element name.
 * @property {boolean} [required] Indicates if the select is required.
 * @property {string} [requiredErrorText=Complete this field] Text to display when the input is required and the user does not select a value.
 * @property {string} [requiredOptionLabel=Select an option] Text to use for the first option to indicate the select is required.
 * @property {SelectOptions[]} options Array of available options for the select.
 * @property {string} [value] initial value of select.
 */
class CoreIntcSelect extends LightningElement {
  // Need to delegate the focus behavior to inside the template content
  static delegatesFocus = true;

  // ******* API variables - defined in class properties *******
  @api ariaLabel;

  @api label = '';

  @api hideLabel;

  @api name;

  @api disabled;

  @api required;

  @api requiredOptionLabel = 'Select an option';

  @api requiredErrorText = 'Complete this field';

  @api options = [];

  /**
   * set value
   *
   * @type {string}
   * @param {string} val initial or dynamic value of select input
   * @private
   */
  @api set value(val) {
    this.val = val;
  }

  /**
   * get value
   *
   * @type {string}
   * @returns {string} current input value
   * @private
   */
  get value() {
    return this.val;
  }

  /**
   * Checks current validity without reporting it.
   *
   * @returns {boolean} returns validity boolean
   * @public
   */
  @api checkValidity() {
    this.isValid = !!(this.val || !this.required);
    return this.isValid;
  }

  /**
   * Report validity shows error message if invalid.
   *
   * @returns {boolean} returns validity boolean
   * @public
   */
  @api reportValidity() {
    this.checkValidity();
    this.isTouched = true;
    return this.isValid;
  }

  // ******* Track variables ********
  /**
   * Generic object used to track if select is valid
   *
   * @type {object}
   * @property {boolean} isValid Indicates if the component is valid.
   * @private
   */
  @track isValid;

  /**
   * Generic object used to track if select is touched
   *
   * @type {object}
   * @property {boolean} isValid Indicates if the component is touched.
   * @private
   */
  @track isTouched;

  /**
   * Sets accessibility label
   *
   * @type {object}
   * @private
   */
  get accessibilityLabel() {
    return this.ariaLabel || this.label;
  }

  /**
   * Determines if label should be shown
   *
   * @type {boolean}
   * @private
   */
  get showLabel() {
    return !this.hideLabel && this.label !== '';
  }

  /**
   * get formatted options gets and maps options: key, label, value, selected
   *
   * @type {boolean}
   * @private
   */
  get formattedOptions() {
    const requiredOption = {
      label: this.requiredOptionLabel, value: '', selected: !this.val,
    };
    const options = (this.required && this.options.length && this.options[0].value !== '')
      ? [requiredOption].concat(this.options) : (this.options || []);
    return options.map((opt, idx) => ({
      key: `${this.label || 'opt-'}-${idx}`,
      label: opt.label,
      value: opt.value,
      selected: opt.selected || this.val === opt.value,
    }));
  }

  /**
   * Get slds classes based on if is touch or is valid
   *
   * @type {boolean}
   * @private
   */
  get classes() {
    return [
      this.isTouched && !this.isValid ? 'slds-has-error' : '',
      'slds-form-element',
    ].join(' ');
  }

  /**
   * Handle change method passes in event parameter and set is touched to true,
   * sets the value to the target value,
   * calls check validity, and dispatches an event
   *
   * @param {event} evt dropdown change event
   *
   * @private
   */
  handleChange(evt) {
    this.isTouched = true;
    this.val = evt.currentTarget.value;
    this.checkValidity();
    this.dispatchEvent(new CustomEvent('change', {
      detail: this.val,
    }));
  }

  /**
   * Handle blur method sets is touched to true and calls check validity method
   *
   * @private
   */
  handleBlur() {
    this.isTouched = true;
    this.checkValidity();
  }
}
export default CoreIntcSelect;

// ********* Type Definitions ************
/**
 * Represents a question and answer used by the {@link CoreIntcSelect} component.
 *
 * @typedef SelectOptions
 * @property {string} label  The option label that is shown in the UI.
 * @property {string} value  The value of the select option.
 * @property {boolean} [selected=false]  The option is selected. Default is false.
 */