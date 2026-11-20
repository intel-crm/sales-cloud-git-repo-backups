import { LightningElement, api } from 'lwc';
import { DefaultScreenConfig, subscribeToScreenChange } from './screenBreakpoints';

/**
 * @typedef ScreenConfig
 * @property {string} mediaQuery media query for this screen size
 * @property {string} name name for screen size (ie. 'small' / 'large')
 * @property {string} [abbr] abbreviated name (ie. 'sm' / 'lg')
 * @property {boolean} [isMobile] true if screen is 'Mobile'
 * @property {boolean} [isTablet] true if screen is 'Tablet'
 * @property {boolean} [isDesktop] true if screen is 'Desktop'
 */

/**
 * Utility Component
 * This component is for UI Utilities and has a <template>
 *
 * - Screen Changes / Breakpoints:
 * Use this component to respond to screen changes
 *
 * @private
 * @example
 * <!-- HTML component example 1 -->
 * <c-core-intc-utilities onscreenchange={handleScreenChange}></c-core-intc-utilities>
 *
 * @augments LightningElement
 * @property {ScreenConfig[]} additionalBreakpoints specify custom screen sizes / breakpoints (in addition to defaults)
 */
class CoreIntcUtilities extends LightningElement {
  @api additionalBreakpoints = [];

  /**
   * connected callback
   */
  connectedCallback() {
    this.initScreenChangeHandler();
  }

  /**
   * disconnected
   */
  disconnectedCallback() {
    this.removeScreenChangeHandler();
  }

  /**
   * screen change handler
   */
  initScreenChangeHandler() {
    // Always add in DefaultScreenConfig for consistency across core experience
    const screens = [...DefaultScreenConfig, ...(this.additionalBreakpoints || [])];
    this.removeScreenChangeHandler = subscribeToScreenChange(screens, (screen) => {
      this.dispatchEvent(new CustomEvent('screenchange', { detail: { screen } }));
    });
  }
}
export default CoreIntcUtilities;