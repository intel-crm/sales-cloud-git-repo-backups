import { LightningElement, api } from 'lwc';
import IpaResources from '@salesforce/resourceUrl/IpaResources';

/** Marketplace/IPA Marquee (Default Component)
 *
 * This marquee is the simplest marquee component and the basis
 * for more complex marquees (ie. ipaMarqueeOffering)
 *
 * @augments LightningElement
 * @property {string} title Set the Title for the Marquee
 * @property {string} [alignment=left] can be 'left' or 'center'
 * @property {string} [backgroundColor=blue-steel-solid] background color (only implemented color is blue-steel-solid)
 * @property {string} [backgroundVariant=mosaic-l0] can be 'mosaic-l1', 'mosaic-l2', 'classic-blue-gradient'
 */
class IpaMarqueeDefault extends LightningElement {
  @api alignment = 'left';

  @api title = '';

  @api backgroundColor = 'blue-steel-solid';

  @api backgroundVariant = 'mosaic-l0';

  /**
   * rendered callback
   * - sets background dynamically based on variant
   *
   * @private
   */
  renderedCallback() {
    let bgUrl = '';
    switch (this.backgroundVariant) {
      case 'classic-blue-gradient':
      case 'blue-steel-solid':
        return;
      case 'mosaic-l0':
        bgUrl = `${IpaResources}/images/background-marquee-l0.svg`;
        console.log("BackgroungImage10=>>>>>>>>");
        break;
      case 'mosaic-l1':
        bgUrl = `${IpaResources}/images/background-marquee-l1.svg`;
        console.log("BackgroungImage11=>>>>>>>>");
        break;
      case 'mosaic-l2':
        bgUrl = `${IpaResources}/images/background-marquee-l2.svg`;
        console.log("BackgroungImage12=>>>>>>>>");
        break;
      default:
        console.log("BackgroungImagedefault=>>>>>>>>");
        return;
    }
    const el = this.template.querySelector('.marquee-outer-container');
    if (el && bgUrl) {
      el.style.backgroundColor = 'var(--blue-steel-shade2)';
      console.log("intel image=>>>>>"+bgUrl);
      el.style.backgroundImage = `url(${bgUrl})`;
      el.style.backgroundPosition = 'center';
    }
  }
}
export default IpaMarqueeDefault;