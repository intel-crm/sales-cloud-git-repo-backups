import { LightningElement, api } from 'lwc';

/**
 * Progress Indicator
 * - shows steps in a process (ie. Offering Submission)
 *
 * @augments LightningElement
 * @property {object[]} steps list of steps in process
 */
class IpaProgressIndicator extends LightningElement {
    @api steps = [];

    /**
     * Format Steps with Style Classes
     *
     * @returns {object[]} formatted steps
     * @private
     */
    get formattedSteps() {
      return this.steps.map((step, idx) => ({
        key: `progress-step-${idx}`,
        label: step.label,
        checked: step.checked,
        active: step.active,
        class: [
          step.checked ? 'checked' : '',
          step.active ? 'active' : '',
        ].join(' '),
        mobileClass: [
          'slds-progress__item',
          step.checked ? 'checked' : '',
          step.active ? 'active slds-is-active' : '',
        ].join(' '),
      }));
    }
}
export default IpaProgressIndicator;